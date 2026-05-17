-- ══════════════════════════════════════════════════════════════════
--  Megahack Loader by vertelvsepoel
-- ══════════════════════════════════════════════════════════════════

local TweenService = game:GetService("TweenService")
local Players      = game:GetService("Players")
local Lighting     = game:GetService("Lighting")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 5)
if not playerGui then warn("[MH Loader] PlayerGui not found!") return end

local BASE_ROOT = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack"

-- ══════════════════════════════════════
--  БЕЗОПАСНАЯ ПРЕДЗАГРУЗКА ТЕМЫ
-- ══════════════════════════════════════
local function safeLoad(url)
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(url .. "?t=" .. math.floor(tick()), true))()
    end)
    return ok and res or nil
end

-- Пробуем забрать тему игрока для кастомизации интерфейса лоадера
local T = {
    BgSide = Color3.fromRGB(20, 20, 25),
    Stroke = Color3.fromRGB(45, 45, 55),
    AccentGlow = Color3.fromRGB(0, 255, 140),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextSub = Color3.fromRGB(160, 160, 170)
}

local themeFactory = safeLoad(BASE_ROOT .. "/theme.lua")
if type(themeFactory) == "function" then
    local theme = themeFactory({
        TweenService = TweenService,
        RunService = game:GetService("RunService"),
        HttpService = game:GetService("HttpService"),
        UserInputService = game:GetService("UserInputService"),
        playerGui = playerGui,
        accentRegistry = {},
        createNotification = function() end
    })
    if theme and theme.T then T = theme.T end
end

-- ══════════════════════════════════════
--  СОЗДАНИЕ ИНТЕРФЕЙСА ЛОАДЕРА
-- ══════════════════════════════════════
local loaderGui = Instance.new("ScreenGui")
loaderGui.Name = "MH_Launcher"
loaderGui.Parent = playerGui
loaderGui.ResetOnSpawn = false
loaderGui.DisplayOrder = 99999

-- Эффект размытия заднего плана
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting
TweenService:Create(blur, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = 12}):Play()

-- Затемнение экрана
local fullBg = Instance.new("Frame")
fullBg.Size = UDim2.new(1, 0, 1, 0)
fullBg.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
fullBg.BackgroundTransparency = 1
fullBg.Parent = loaderGui
TweenService:Create(fullBg, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.4}):Play()

-- Центрированная карточка
local mainCard = Instance.new("Frame")
mainCard.Size = UDim2.new(0, 360, 0, 150)
mainCard.Position = UDim2.new(0.5, -180, 0.5, -75)
mainCard.BackgroundColor3 = T.BgSide
mainCard.BackgroundTransparency = 1
mainCard.Parent = fullBg

local cardCorner = Instance.new("UICorner", mainCard)
cardCorner.CornerRadius = UDim.new(0, 14)

local cardStroke = Instance.new("UIStroke", mainCard)
cardStroke.Thickness = 1
cardStroke.Color = T.Stroke
cardStroke.Transparency = 1

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "Megahack Loader"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextColor3 = T.TextMain
titleLabel.TextSize = 22
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 22)
titleLabel.BackgroundTransparency = 1
titleLabel.TextTransparency = 1
titleLabel.Parent = mainCard

-- Автор подзаголовок
local authorLabel = Instance.new("TextLabel")
authorLabel.Text = "by vertelvsepoel"
authorLabel.Font = Enum.Font.GothamItalic
authorLabel.TextColor3 = T.AccentGlow
authorLabel.TextSize = 12
authorLabel.Size = UDim2.new(1, 0, 0, 18)
authorLabel.Position = UDim2.new(0, 0, 0, 48)
authorLabel.BackgroundTransparency = 1
authorLabel.TextTransparency = 1
authorLabel.Parent = mainCard

-- Текст текущего статуса
local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "Connecting to repository..."
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextColor3 = T.TextSub
statusLabel.TextSize = 11
statusLabel.Size = UDim2.new(1, -40, 0, 20)
statusLabel.Position = UDim2.new(0, 20, 1, -50)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.BackgroundTransparency = 1
statusLabel.TextTransparency = 1
statusLabel.Parent = mainCard

-- Линия прогресса (Подложка)
local progressTrack = Instance.new("Frame")
progressTrack.Size = UDim2.new(1, -40, 0, 5)
progressTrack.Position = UDim2.new(0, 20, 1, -26)
progressTrack.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
progressTrack.BackgroundTransparency = 1
progressTrack.Parent = mainCard
Instance.new("UICorner", progressTrack).CornerRadius = UDim.new(0, 3)

-- Линия прогресса (Заполнение)
local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = T.AccentGlow
progressBar.BorderSizePixel = 0
progressBar.Parent = progressTrack
Instance.new("UICorner", progressBar).CornerRadius = UDim.new(0, 3)

-- Свечение линии
local barGlow = Instance.new("UIStroke", progressBar)
barGlow.Color = T.AccentGlow
barGlow.Thickness = 1.5
barGlow.Transparency = 0.5

-- Плавное появление (Fade In)
local tiIn = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
TweenService:Create(mainCard, tiIn, {BackgroundTransparency = 0}):Play()
TweenService:Create(cardStroke, tiIn, {Transparency = 0}):Play()
TweenService:Create(titleLabel, tiIn, {TextTransparency = 0}):Play()
TweenService:Create(authorLabel, tiIn, {TextTransparency = 0}):Play()
TweenService:Create(statusLabel, tiIn, {TextTransparency = 0}):Play()
TweenService:Create(progressTrack, tiIn, {BackgroundTransparency = 0}):Play()
task.wait(0.5)

-- Функция шагов загрузки
local function updateProgress(percentage, text, speed)
    statusLabel.Text = text
    TweenService:Create(progressBar, TweenInfo.new(speed or 0.3, Enum.EasingStyle.OutQuad), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
    task.wait(speed or 0.3)
end

-- ══════════════════════════════════════
--  ИМИТАЦИЯ И ЗАПУСК ОСНОВНОГО МЕНЮ
-- ══════════════════════════════════════
updateProgress(0.25, "Checking license & HWID...", 0.4)
updateProgress(0.50, "Downloading UI components...", 0.5)
updateProgress(0.80, "Injecting cheat logic maps...", 0.4)
updateProgress(1.00, "Done! Executing Maybemenu...", 0.3)

-- Плавное исчезновение (Fade Out)
local tiOut = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
TweenService:Create(blur, tiOut, {Size = 0}):Play()
TweenService:Create(fullBg, tiOut, {BackgroundTransparency = 1}):Play()
TweenService:Create(mainCard, tiOut, {BackgroundTransparency = 1}):Play()
TweenService:Create(cardStroke, tiOut, {Transparency = 1}):Play()
TweenService:Create(titleLabel, tiOut, {TextTransparency = 1}):Play()
TweenService:Create(authorLabel, tiOut, {TextTransparency = 1}):Play()
TweenService:Create(statusLabel, tiOut, {TextTransparency = 1}):Play()
TweenService:Create(progressBar, tiOut, {BackgroundTransparency = 1}):Play()
TweenService:Create(progressTrack, tiOut, {BackgroundTransparency = 1}):Play()

task.delay(0.3, function()
    loaderGui:Destroy()
    blur:Destroy()
end)

-- Самый важный момент — вызов твоего основного меню
local masterMenuUrl = BASE_ROOT .. "/maybemenu.lua"
local success, err = pcall(function()
    loadstring(game:HttpGet(masterMenuUrl, true))()
end)

if not success then
    warn("[MH Loader] Критическая ошибка при запуске maybemenu: " .. tostring(err))
end
