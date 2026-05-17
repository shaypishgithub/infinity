-- ══════════════════════════════════════════════════════════════════
--  Megahack Loader by vertelvsepoel (ОТДЕЛЬНЫЙ ЛОУДЕР)
-- ══════════════════════════════════════════════════════════════════

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local Lighting         = game:GetService("Lighting")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 5)
if not playerGui then warn("[MH Loader] PlayerGui not found!") return end

local BASE_ROOT = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack"

-- Функция безопасной загрузки для предзагрузки темы
local function safeLoad(url)
    local fullUrl = url .. "?t=" .. math.floor(tick())
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(fullUrl, true))()
    end)
    if ok and res then return res end
    return nil
end

-- ══════════════════════════════════════
--  ПОЛУЧЕНИЕ ЦВЕТОВОЙ ПАЛИТРЫ ИГРОКА
-- ══════════════════════════════════════
local themeFactory = safeLoad(BASE_ROOT .. "/theme.lua")
local T = {
    BgSide     = Color3.fromRGB(20, 20, 25),      -- дефолтные бэкап цвета
    AccentGlow = Color3.fromRGB(0, 255, 140),
    TextMain   = Color3.fromRGB(255, 255, 255),
    TextSub    = Color3.fromRGB(160, 160, 170),
    Stroke     = Color3.fromRGB(45, 45, 55)
}

if type(themeFactory) == "function" then
    local accentRegistry = {}
    local theme = themeFactory({
        TweenService     = TweenService,
        RunService       = game:GetService("RunService"),
        HttpService      = game:GetService("HttpService"),
        UserInputService = UserInputService,
        playerGui        = playerGui,
        accentRegistry   = accentRegistry,
        createNotification = function() end, -- заглушка
    })
    if theme and theme.T then
        T = theme.T -- Подставляем реальные цвета из темы игрока!
    end
end

-- ══════════════════════════════════════
--  СОЗДАНИЕ КРАСИВОГО ИНТЕРФЕЙСА (UI)
-- ══════════════════════════════════════
local loaderGui = Instance.new("ScreenGui")
loaderGui.Name = "MH_BeautifulLauncher"
loaderGui.Parent = playerGui
loaderGui.ResetOnSpawn = false
loaderGui.DisplayOrder = 99999

-- Эффект размытия заднего плана
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting
TweenService:Create(blur, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = 12}):Play()

-- Полупрозрачный задний фон
local fullBg = Instance.new("Frame")
fullBg.Size = UDim2.new(1, 0, 1, 0)
fullBg.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
fullBg.BackgroundTransparency = 1
fullBg.Parent = loaderGui
TweenService:Create(fullBg, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.35}):Play()

-- Главная карточка лоадера
local mainCard = Instance.new("Frame")
mainCard.Size = UDim2.new(0, 340, 0, 150)
mainCard.Position = UDim2.new(0.5, -170, 0.5, -75)
mainCard.BackgroundColor3 = T.BgSide
mainCard.BackgroundTransparency = 1
mainCard.Parent = fullBg

local cardCorner = Instance.new("UICorner", mainCard)
cardCorner.CornerRadius = UDim.new(0, 12)

local cardStroke = Instance.new("UIStroke", mainCard)
cardStroke.Thickness = 1
cardStroke.Color = T.Stroke
cardStroke.Transparency = 1

-- Название
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "Megahack Loader"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextColor3 = T.TextMain
titleLabel.TextSize = 22
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 24)
titleLabel.BackgroundTransparency = 1
titleLabel.TextTransparency = 1
titleLabel.Parent = mainCard

-- Копирайт автора
local authorLabel = Instance.new("TextLabel")
authorLabel.Text = "by vertelvsepoel"
authorLabel.Font = Enum.Font.GothamItalic
authorLabel.TextColor3 = T.AccentGlow
authorLabel.TextSize = 12
authorLabel.Size = UDim2.new(1, 0, 0, 18)
authorLabel.Position = UDim2.new(0, 0, 0, 50)
authorLabel.BackgroundTransparency = 1
authorLabel.TextTransparency = 1
authorLabel.Parent = mainCard

-- Статус бар текст
local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "Connecting to core..."
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextColor3 = T.TextSub
statusLabel.TextSize = 11
statusLabel.Size = UDim2.new(1, -40, 0, 18)
statusLabel.Position = UDim2.new(0, 20, 1, -52)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.BackgroundTransparency = 1
statusLabel.TextTransparency = 1
statusLabel.Parent = mainCard

-- Полоска прогресса (Трэк)
local progressTrack = Instance.new("Frame")
progressTrack.Size = UDim2.new(1, -40, 0, 5)
progressTrack.Position = UDim2.new(0, 20, 1, -28)
progressTrack.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
progressTrack.BackgroundTransparency = 1
progressTrack.Parent = mainCard
Instance.new("UICorner", progressTrack).CornerRadius = UDim.new(0, 3)

-- Полоска прогресса (Заполнение)
local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = T.AccentGlow
progressBar.BorderSizePixel = 0
progressBar.Parent = progressTrack
Instance.new("UICorner", progressBar).CornerRadius = UDim.new(0, 3)

local barGlow = Instance.new("UIStroke", progressBar)
barGlow.Color = T.AccentGlow
barGlow.Thickness = 1.5
barGlow.Transparency = 0.5

-- Анимация плавного появления лоадера
local tiIn = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
TweenService:Create(mainCard, tiIn, {BackgroundTransparency = 0}):Play()
TweenService:Create(cardStroke, tiIn, {Transparency = 0}):Play()
TweenService:Create(titleLabel, tiIn, {TextTransparency = 0}):Play()
TweenService:Create(authorLabel, tiIn, {TextTransparency = 0}):Play()
TweenService:Create(statusLabel, tiIn, {TextTransparency = 0}):Play()
TweenService:Create(progressTrack, tiIn, {BackgroundTransparency = 0}):Play()
task.wait(0.4)

-- Функция управления заполнением полосы
local function setProgress(percent, text)
    statusLabel.Text = text
    TweenService:Create(progressBar, TweenInfo.new(0.4, Enum.EasingStyle.OutQuad), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
end

-- ══════════════════════════════════════
--  ИМИТАЦИЯ ПРОГРЕССА И ИНЖЕКТ МЕНЮ
-- ══════════════════════════════════════
task.wait(0.2)
setProgress(0.25, "Checking repository structures...")
task.wait(0.4)

setProgress(0.55, "Fetching source codes...")
task.wait(0.5)

setProgress(0.85, "Decrypting assets and modules...")
task.wait(0.3)

setProgress(1.0, "Done! Executing maybemenu.lua...")
task.wait(0.4)

-- Анимация плавного исчезновения лоадера
local tiOut = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
TweenService:Create(blur, tiOut, {Size = 0}):Play()
TweenService:Create(fullBg, tiOut, {BackgroundTransparency = 1}):Play()
TweenService:Create(mainCard, tiOut, {BackgroundTransparency = 1}):Play()
TweenService:Create(cardStroke, tiOut, {Transparency = 1}):Play()
TweenService:Create(titleLabel, tiOut, {TextTransparency = 1}):Play()
TweenService:Create(authorLabel, tiOut, {TextTransparency = 1}):Play()
TweenService:Create(statusLabel, tiOut, {TextTransparency = 1}):Play()
TweenService:Create(progressBar, tiOut, {BackgroundTransparency = 1}):Play()
TweenService:Create(progressTrack, tiOut, {BackgroundTransparency = 1}):Play()

task.delay(0.35, function()
    loaderGui:Destroy()
    blur:Destroy()
end)

-- ══════════════════════════════════════
--  ГЛАВНЫЙ ЗАПУСК ОСНОВНОГО МЕНЮ
-- ══════════════════════════════════════
local mainScriptUrl = BASE_ROOT .. "/maybemenu.lua?t=" .. math.floor(tick())
local ok, err = pcall(function()
    loadstring(game:HttpGet(mainScriptUrl, true))()
end)

if not ok then
    warn("[MH Loader] Критическая ошибка при запуске maybemenu: " .. tostring(err))
end
