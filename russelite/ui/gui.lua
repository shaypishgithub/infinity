--// RussElite All-In-One GUI
--// Сначала показывает загрузку, затем открывает главный интерфейс

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
-- Пытаемся засунуть в CoreGui, если не получается — в PlayerGui
local GuiTarget = game:GetService("CoreGui")
local Success, Err = pcall(function() return GuiTarget:FindFirstChild("RobloxGui") end)
if not Success then GuiTarget = LocalPlayer:WaitForChild("PlayerGui") end

-- Настройки анимаций
local tweenFast = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenSmooth = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local tweenUIStroke = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
local tweenLoader = TweenInfo.new(0.8, Enum.EasingStyle.Expo, Enum.EasingDirection.Out)
local tweenFadeOut = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)

-- Утилита: Создание стеклянного элемента (Glassmorphism)
local function createGlass(props)
    local element = Instance.new(props.ClassName or "Frame")
    element.Name = props.Name or "Glass"
    element.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    element.BackgroundTransparency = props.BackgroundTransparency or 0.12
    element.Size = props.Size or UDim2.new(1, 0, 1, 0)
    element.Position = props.Position or UDim2.new(0.5, 0, 0.5, 0)
    element.AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5)
    element.BorderSizePixel = 0
    element.ClipsDescendants = props.ClipsDescendants or false
    element.Parent = props.Parent

    Instance.new("UICorner", element).CornerRadius = UDim.new(0, props.CornerRadius or 16)

    local stroke = Instance.new("UIStroke", element)
    stroke.Name = "GlowStroke"
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.88
    stroke.Thickness = 1.2

    -- Внутреннее свечение (эффект iPhone)
    if not props.IgnoreInnerGlow then
        local innerGlow = Instance.new("ImageLabel", element)
        innerGlow.Name = "InnerGlow"
        innerGlow.BackgroundTransparency = 1
        innerGlow.Size = UDim2.new(1, 0, 1, 0)
        innerGlow.Image = "rbxassetid://7669168585"
        innerGlow.ImageColor3 = Color3.fromRGB(200, 200, 255)
        innerGlow.ImageTransparency = 0.94
        innerGlow.ScaleType = Enum.ScaleType.Slice
        innerGlow.SliceCenter = Rect.new(100, 100, 100, 100)
        innerGlow.ZIndex = 0
    end

    return element
end

-- ========================================================
-- ЧАСТЬ 1: ЭКРАН ЗАГРУЗКИ (Имитация)
-- ========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RussElite"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = GuiTarget

local LoaderFrame = createGlass({
    Parent = ScreenGui,
    Name = "Loader",
    Size = UDim2.new(0, 350, 0, 200),
    CornerRadius = 20,
    InnerShadow = true
})

local LoaderTitle = Instance.new("TextLabel", LoaderFrame)
LoaderTitle.Size = UDim2.new(1, -40, 0, 40)
LoaderTitle.Position = UDim2.new(0, 20, 0, 30)
LoaderTitle.BackgroundTransparency = 1
LoaderTitle.Text = "RussElite"
LoaderTitle.Font = Enum.Font.GothamBold
LoaderTitle.TextSize = 32
LoaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoaderTitle.TextXAlignment = Enum.TextXAlignment.Left

local LoaderSub = Instance.new("TextLabel", LoaderFrame)
LoaderSub.Size = UDim2.new(1, -40, 0, 20)
LoaderSub.Position = UDim2.new(0, 20, 0, 70)
LoaderSub.BackgroundTransparency = 1
LoaderSub.Text = "Initializing modules..."
LoaderSub.Font = Enum.Font.Gotham
LoaderSub.TextSize = 14
LoaderSub.TextColor3 = Color3.fromRGB(180, 180, 180)
LoaderSub.TextXAlignment = Enum.TextXAlignment.Left

local BarBg = Instance.new("Frame", LoaderFrame)
BarBg.Size = UDim2.new(1, -40, 0, 6)
BarBg.Position = UDim2.new(0, 20, 0, 150)
BarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
BarBg.BackgroundTransparency = 0.5
BarBg.BorderSizePixel = 0
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

local BarFill = Instance.new("Frame", BarBg)
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BarFill.BackgroundTransparency = 0.1
BarFill.BorderSizePixel = 0
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

-- ========================================================
-- ЧАСТЬ 2: ГЛАВНЫЙ ИНТЕРФЕЙС (Скрыт изначально)
-- ========================================================

local MainWindow = createGlass({
    Parent = ScreenGui,
    Name = "MainWindow",
    Size = UDim2.new(0, 0, 0, 0), -- Скрыт для анимации
    Position = UDim2.new(0.5, 0, 0.5, 0),
    CornerRadius = 24,
    ClipsDescendants = true
})

-- Верхняя панель (Для перетаскивания)
local TopBar = createGlass({
    Parent = MainWindow,
    Size = UDim2.new(1, 0, 0, 50),
    Position = UDim2.new(0, 0, 0, 0),
    AnchorPoint = Vector2.new(0, 0),
    CornerRadius = 24,
    BackgroundTransparency = 0.05,
    IgnoreInnerGlow = true
})

local TitleLabel = Instance.new("TextLabel", TopBar)
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "RussElite"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Меню вкладок (Слева)
local TabFrame = Instance.new("Frame", MainWindow)
TabFrame.Size = UDim2.new(0, 140, 1, -50)
TabFrame.Position = UDim2.new(0, 0, 0, 50)
TabFrame.BackgroundTransparency = 1
TabFrame.BorderSizePixel = 0

local TabPadding = Instance.new("UIListLayout", TabFrame)
TabPadding.Padding = UDim.new(0, 8)
TabPadding.SortOrder = Enum.SortOrder.LayoutOrder

local TabButtonData = {
    {Name = "Home", Layout = 1},
    {Name = "Base", Layout = 2, Module = "base/base.lua"},
    {Name = "Game", Layout = 3, Module = "base/game.lua"}
}

local activeTab = nil

for _, data in ipairs(TabButtonData) do
    local btn = createGlass({
        Parent = TabFrame,
        Name = data.Name .. "Tab",
        Size = UDim2.new(1, -16, 0, 40),
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0, 8, 0, 0),
        CornerRadius = 12,
        BackgroundTransparency = 0.85
    })
    btn.LayoutOrder = data.Layout
    btn.ZIndex = 5

    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = data.Name
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.ZIndex = 6

    btn.MouseEnter:Connect(function()
        if activeTab ~= btn then
            TweenService:Create(btn, tweenSmooth, {BackgroundTransparency = 0.7}):Play()
            TweenService:Create(btn.GlowStroke, tweenUIStroke, {Transparency = 0.7}):Play()
        end
    end)

    btn.MouseLeave:Connect(function()
        if activeTab ~= btn then
            TweenService:Create(btn, tweenSmooth, {BackgroundTransparency = 0.85}):Play()
            TweenService:Create(btn.GlowStroke, tweenUIStroke, {Transparency = 0.88}):Play()
        end
    end)

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if activeTab then
                TweenService:Create(activeTab, tweenSmooth, {BackgroundTransparency = 0.85}):Play()
                TweenService:Create(activeTab.GlowStroke, tweenUIStroke, {Transparency = 0.88}):Play()
                activeTab.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            activeTab = btn
            TweenService:Create(btn, tweenSmooth, {BackgroundTransparency = 0.5}):Play()
            TweenService:Create(btn.GlowStroke, tweenUIStroke, {Transparency = 0.5, Thickness = 1.5}):Play()
            label.TextColor3 = Color3.fromRGB(255, 255, 255)

            if data.Module then
                pcall(function()
                    loadstring(game:HttpGet('https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/'..data.Module))()
                end)
            end
        end
    end)
end

-- Зона контента (Справа)
local ContentFrame = createGlass({
    Parent = MainWindow,
    Name = "ContentArea",
    Size = UDim2.new(1, -140, 1, -50),
    Position = UDim2.new(0, 140, 0, 50),
    AnchorPoint = Vector2.new(0, 0),
    CornerRadius = 0,
    BackgroundTransparency = 0.9,
    IgnoreInnerGlow = true
})

local ContentLabel = Instance.new("TextLabel", ContentFrame)
ContentLabel.Size = UDim2.new(1, 0, 1, 0)
ContentLabel.BackgroundTransparency = 1
ContentLabel.Text = "Select a module to begin."
ContentLabel.Font = Enum.Font.GothamMedium
ContentLabel.TextSize = 16
ContentLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
ContentLabel.ZIndex = 5

-- Плавающая кнопка откытия/закрытия
local ToggleBtn = createGlass({
    Parent = ScreenGui,
    Name = "ToggleBtn",
    Size = UDim2.new(0, 55, 0, 55),
    Position = UDim2.new(0, 20, 0.5, 0),
    CornerRadius = 28,
    BackgroundTransparency = 0.05
})

local ToggleIcon = Instance.new("TextLabel", ToggleBtn)
ToggleIcon.Size = UDim2.new(1, 0, 1, 0)
ToggleIcon.BackgroundTransparency = 1
ToggleIcon.Text = "✕"
ToggleIcon.Font = Enum.Font.GothamBold
ToggleIcon.TextSize = 22
ToggleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleIcon.ZIndex = 10

local isOpen = true

local function toggleUI()
    isOpen = not isOpen
    if isOpen then
        TweenService:Create(MainWindow, tweenFast, {Size = UDim2.new(0, 550, 0, 380)}):Play()
        TweenService:Create(ToggleBtn, tweenFast, {Rotation = 0}):Play()
        ToggleIcon.Text = "✕"
    else
        TweenService:Create(MainWindow, tweenFast, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        TweenService:Create(ToggleBtn, tweenFast, {Rotation = 90}):Play()
        ToggleIcon.Text = "☰"
    end
end

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleUI()
    end
end)

ToggleBtn.MouseEnter:Connect(function()
    TweenService:Create(ToggleBtn.GlowStroke, tweenUIStroke, {Transparency = 0.5, Thickness = 2}):Play()
    TweenService:Create(ToggleBtn, tweenSmooth, {BackgroundTransparency = 0.0}):Play()
end)

ToggleBtn.MouseLeave:Connect(function()
    TweenService:Create(ToggleBtn.GlowStroke, tweenUIStroke, {Transparency = 0.88, Thickness = 1.2}):Play()
    TweenService:Create(ToggleBtn, tweenSmooth, {BackgroundTransparency = 0.05}):Play()
end)

-- Логика перетаскивания (Drag)
local dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragStart = input.Position
        startPos = MainWindow.Position
        local delta = (input.Position - dragStart)
        MainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragInput = nil end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

RunService:BindToRenderStep("RussEliteDrag", Enum.RenderPriority.Input.Value, function()
    if dragInput and dragStart then
        local delta = (dragInput.Position - dragStart)
        MainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ========================================================
-- ЧАСТЬ 3: ЗАПУСК ПРОЦЕССА
-- ========================================================

task.spawn(function()
    -- 1. Анимируем загрузку
    local loadSteps = {0.15, 0.4, 0.7, 1.0}
    local loadTexts = {"Parsing UI layout...", "Loading dependencies...", "Securing environment...", "Done!"}
    
    for i = 1, #loadSteps do
        TweenService:Create(BarFill, tweenLoader, {Size = UDim2.new(loadSteps[i], 0, 1, 0)}):Play()
        LoaderSub.Text = loadTexts[i]
        task.wait(0.6)
    end
    
    task.wait(0.3)
    
    -- 2. Плавно исчезает загрузчик
    TweenService:Create(LoaderFrame, tweenFadeOut, {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoaderTitle, tweenFadeOut, {TextTransparency = 1}):Play()
    TweenService:Create(LoaderSub, tweenFadeOut, {TextTransparency = 1}):Play()
    TweenService:Create(BarBg, tweenFadeOut, {BackgroundTransparency = 1}):Play()
    TweenService:Create(BarFill, tweenFadeOut, {BackgroundTransparency = 1}):Play()
    
    task.wait(1)
    LoaderFrame:Destroy()
    
    -- 3. Выдвигаем главный интерфейс
    toggleUI() -- Вызываем функцию, чтобы окно появилось (так как по умолчанию оно size 0,0)
    
    -- Активируем первую вкладку
    local firstTab = TabFrame:FindFirstChild("HomeTab")
    if firstTab then
        activeTab = firstTab
        TweenService:Create(firstTab, tweenSmooth, {BackgroundTransparency = 0.5}):Play()
        TweenService:Create(firstTab.GlowStroke, tweenUIStroke, {Transparency = 0.5, Thickness = 1.5}):Play()
        firstTab.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)
