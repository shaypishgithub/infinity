-- =============================================
--   Vertelevsepoel MegaHack Loader
--   Красивый стеклянный лоадер (Black & White Glass)
-- =============================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Создаём ScreenGui
local loaderGui = Instance.new("ScreenGui")
loaderGui.Name = "VertelevsepoelLoader"
loaderGui.ResetOnSpawn = false
loaderGui.IgnoreGuiInset = true
loaderGui.Parent = playerGui

-- Главный стеклянный фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 540, 0, 340)
mainFrame.Position = UDim2.new(0.5, -270, 0.5, -170)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
mainFrame.BackgroundTransparency = 0.32
mainFrame.BorderSizePixel = 0
mainFrame.Parent = loaderGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 28)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1.8
stroke.Transparency = 0.65
stroke.Parent = mainFrame

-- Градиент
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 12))
}
gradient.Rotation = 85
gradient.Parent = mainFrame

-- Название с 3D эффектом
local titleShadow = Instance.new("TextLabel")
titleShadow.Size = UDim2.new(1, 0, 0, 90)
titleShadow.Position = UDim2.new(0, 3, 0, 48)
titleShadow.BackgroundTransparency = 1
titleShadow.Text = "VERTELEVSEPOEL"
titleShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
titleShadow.TextTransparency = 0.75
titleShadow.TextScaled = true
titleShadow.Font = Enum.Font.GothamBold
titleShadow.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 90)
title.Position = UDim2.new(0, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "VERTELEVSEPOEL"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Прогресс бар
local progressFrame = Instance.new("Frame")
progressFrame.Size = UDim2.new(0.82, 0, 0, 16)
progressFrame.Position = UDim2.new(0.5, -0.82*270, 0.73, 0)
progressFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
progressFrame.BorderSizePixel = 0
progressFrame.Parent = mainFrame

local pCorner = Instance.new("UICorner")
pCorner.CornerRadius = UDim.new(0, 8)
pCorner.Parent = progressFrame

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
progressBar.BorderSizePixel = 0
progressBar.Parent = progressFrame

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 8)
barCorner.Parent = progressBar

-- Процент
local percentLabel = Instance.new("TextLabel")
percentLabel.Size = UDim2.new(0.82, 0, 0, 50)
percentLabel.Position = UDim2.new(0.5, -0.82*270, 0.82, 0)
percentLabel.BackgroundTransparency = 1
percentLabel.Text = "0%"
percentLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
percentLabel.TextScaled = true
percentLabel.Font = Enum.Font.GothamSemibold
percentLabel.Parent = mainFrame

-- Анимация загрузки 10 секунд
local function StartLoading()
    local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    
    TweenService:Create(progressBar, tweenInfo, {Size = UDim2.new(1, 0, 1, 0)}):Play()
    
    -- Проценты
    for i = 0, 100 do
        percentLabel.Text = i .. "%"
        wait(0.1)
    end
    
    -- Плавное исчезновение
    wait(0.3)
    local fadeInfo = TweenInfo.new(1.1, Enum.EasingStyle.Quint)
    
    TweenService:Create(mainFrame, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(stroke, fadeInfo, {Transparency = 1}):Play()
    TweenService:Create(title, fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(titleShadow, fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(percentLabel, fadeInfo, {TextTransparency = 1}):Play()
    
    wait(1.4)
    loaderGui:Destroy()
    
    -- === ЗАГРУЗКА МЕНЮ ===
    print("Vertelevsepoel Loader → Loading main script...")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/maybemenu.lua", true))()
end

-- Запуск
StartLoading()
