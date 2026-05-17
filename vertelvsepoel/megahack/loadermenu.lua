-- ═══════════════════════════════════════════════════════════════════════
--  MegaHack Loader by vertelvsepoel
--  Красивый загрузчик для основного меню
--  Стилистика: тёмная тема с акцентным градиентом, плавные анимации
-- ═══════════════════════════════════════════════════════════════════════

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════════════
--  Параметры дизайна
-- ═══════════════════════════════════════════════════════════════════════
local DESIGN = {
    BgColor = Color3.fromRGB(12, 12, 15),
    CardColor = Color3.fromRGB(22, 22, 28),
    AccentGradient = {Color3.fromRGB(100, 80, 255), Color3.fromRGB(200, 60, 255)},
    TextMain = Color3.fromRGB(240, 240, 245),
    TextSub = Color3.fromRGB(160, 160, 170),
    StrokeColor = Color3.fromRGB(45, 45, 55),
    ErrorColor = Color3.fromRGB(255, 70, 80)
}

-- ═══════════════════════════════════════════════════════════════════════
--  Создание GUI
-- ═══════════════════════════════════════════════════════════════════════
local loaderGui = Instance.new("ScreenGui")
loaderGui.Name = "MegaHackLoader"
loaderGui.ResetOnSpawn = false
loaderGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
loaderGui.Parent = playerGui

-- Затемняющий фон (можно убрать, если мешает)
local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = DESIGN.BgColor
overlay.BackgroundTransparency = 0.4
overlay.BorderSizePixel = 0
overlay.Parent = loaderGui

-- Центральная карточка
local card = Instance.new("Frame")
card.Size = UDim2.new(0, 380, 0, 260)
card.Position = UDim2.new(0.5, -190, 0.5, -130)
card.BackgroundColor3 = DESIGN.CardColor
card.BackgroundTransparency = 0.1
card.BorderSizePixel = 0
card.Parent = loaderGui

-- Скругление углов
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 20)
corner.Parent = card

-- Обводка
local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Color = DESIGN.StrokeColor
stroke.Transparency = 0.6
stroke.Parent = card

-- Градиентный акцент (верхняя полоса)
local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(1, 0, 0, 4)
accentBar.Position = UDim2.new(0, 0, 0, 0)
accentBar.BackgroundColor3 = DESIGN.AccentGradient[1]
accentBar.BorderSizePixel = 0
accentBar.Parent = card
local accentCorner = Instance.new("UICorner")
accentCorner.CornerRadius = UDim.new(0, 20)
accentCorner.Parent = accentBar

-- Градиент для полосы (динамический)
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, DESIGN.AccentGradient[1]),
    ColorSequenceKeypoint.new(1, DESIGN.AccentGradient[2])
}
gradient.Rotation = 90
gradient.Parent = accentBar

-- Заголовок "MEGAHACK LOADER"
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 20, 0, 24)
title.BackgroundTransparency = 1
title.Text = "MEGAHACK LOADER"
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextColor3 = DESIGN.TextMain
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = card

-- Подзаголовок "by vertelvsepoel"
local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -40, 0, 20)
subtitle.Position = UDim2.new(0, 20, 0, 68)
subtitle.BackgroundTransparency = 1
subtitle.Text = "by vertelvsepoel"
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 13
subtitle.TextColor3 = DESIGN.TextSub
subtitle.TextXAlignment = Enum.TextXAlignment.Center
subtitle.Parent = card

-- Спиннер (анимированная иконка)
local spinnerContainer = Instance.new("Frame")
spinnerContainer.Size = UDim2.new(0, 48, 0, 48)
spinnerContainer.Position = UDim2.new(0.5, -24, 0.5, -40)
spinnerContainer.BackgroundTransparency = 1
spinnerContainer.Parent = card

local spinner = Instance.new("ImageLabel")
spinner.Size = UDim2.new(1, 0, 1, 0)
spinner.BackgroundTransparency = 1
spinner.Image = "rbxassetid://6023426926"  -- круглая загрузка
spinner.ImageColor3 = DESIGN.AccentGradient[1]
spinner.Parent = spinnerContainer

local spinTween = TweenService:Create(spinner, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {Rotation = 360})

-- Текст состояния
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -40, 0, 24)
statusText.Position = UDim2.new(0, 20, 0, 160)
statusText.BackgroundTransparency = 1
statusText.Text = "Загрузка основного меню..."
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 14
statusText.TextColor3 = DESIGN.TextSub
statusText.TextXAlignment = Enum.TextXAlignment.Center
statusText.Parent = card

-- Кнопка повтора (изначально скрыта)
local retryBtn = Instance.new("TextButton")
retryBtn.Size = UDim2.new(0, 140, 0, 36)
retryBtn.Position = UDim2.new(0.5, -70, 0, 200)
retryBtn.BackgroundColor3 = DESIGN.AccentGradient[1]
retryBtn.BackgroundTransparency = 1
retryBtn.Text = "ПОВТОРИТЬ"
retryBtn.Font = Enum.Font.GothamBold
retryBtn.TextSize = 14
retryBtn.TextColor3 = DESIGN.TextMain
retryBtn.Visible = false
retryBtn.Parent = card
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = retryBtn
local btnStroke = Instance.new("UIStroke")
btnStroke.Thickness = 1.5
btnStroke.Color = DESIGN.AccentGradient[1]
btnStroke.Transparency = 0.5
btnStroke.Parent = retryBtn

-- Кнопка закрытия (крестик)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0, 12)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = DESIGN.TextSub
closeBtn.TextScaled = false
closeBtn.Parent = card

-- ═══════════════════════════════════════════════════════════════════════
--  Анимации появления
-- ═══════════════════════════════════════════════════════════════════════
card.BackgroundTransparency = 1
card.Position = UDim2.new(0.5, -190, 0.5, -130)
TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0.1
}):Play()
spinTween:Play()

-- ═══════════════════════════════════════════════════════════════════════
--  Функция плавного закрытия лоудера
-- ═══════════════════════════════════════════════════════════════════════
local function destroyLoader()
    spinTween:Cancel()
    TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(overlay, TweenInfo.new(0.3), {
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.35)
    loaderGui:Destroy()
end

-- ═══════════════════════════════════════════════════════════════════════
--  Обработка ошибок загрузки
-- ═══════════════════════════════════════════════════════════════════════
local function showError(message)
    spinTween:Pause()
    spinner.ImageColor3 = DESIGN.ErrorColor
    statusText.Text = "❌ " .. message
    statusText.TextColor3 = DESIGN.ErrorColor
    retryBtn.Visible = true
    TweenService:Create(retryBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
end

-- ═══════════════════════════════════════════════════════════════════════
--  Основная загрузка меню
-- ═══════════════════════════════════════════════════════════════════════
local function loadMainMenu()
    statusText.Text = "Подключение к репозиторию..."
    statusText.TextColor3 = DESIGN.TextSub
    spinner.ImageColor3 = DESIGN.AccentGradient[1]
    spinTween:Play()
    retryBtn.Visible = false

    local url = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/maybemenu.lua"
    local success, result = pcall(function()
        local code = game:HttpGet(url, true)
        local func = loadstring(code)
        if type(func) == "function" then
            func()
            return true
        else
            error("Не удалось скомпилировать скрипт")
        end
    end)

    if success and result == true then
        statusText.Text = "✓ Успешно! Запуск меню..."
        spinTween:Cancel()
        TweenService:Create(spinner, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
        task.wait(0.6)
        destroyLoader()
    else
        local errMsg = tostring(result):sub(1, 60)
        showError("Ошибка: " .. errMsg)
    end
end

-- ═══════════════════════════════════════════════════════════════════════
--  Обработчики кнопок
-- ═══════════════════════════════════════════════════════════════════════
retryBtn.MouseButton1Click:Connect(function()
    TweenService:Create(retryBtn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
    task.wait(0.1)
    loadMainMenu()
end)

closeBtn.MouseButton1Click:Connect(function()
    destroyLoader()
end)

-- Запуск загрузки
loadMainMenu()

-- Защита от повторного открытия (если скрипт запущен дважды)
if _G.__MEGAHACK_LOADER_ACTIVE then
    destroyLoader()
else
    _G.__MEGAHACK_LOADER_ACTIVE = true
end
