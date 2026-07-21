--// RussElite All-In-One (Исправленная версия)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- БЕЗОПАСНАЯ проверка куда вставлять GUI (CoreGui или PlayerGui)
local GuiParent
if syn and syn.protect_gui then
    GuiParent = syn.protect_gui(Instance.new("ScreenGui"))
elseif gethui then
    GuiParent = gethui()
else
    -- Стандартная проверка: есть ли доступ к CoreGui
    local testCore = Instance.new("ScreenGui")
    testCore.Name = "RussEliteTest"
    pcall(function() testCore.Parent = game:GetService("CoreGui") end)
    
    if testCore.Parent == game:GetService("CoreGui") then
        GuiParent = game:GetService("CoreGui")
        testCore:Destroy()
    else
        testCore:Destroy()
        GuiParent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

-- Анимации
local tweenFast = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenSmooth = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local tweenStroke = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
local tweenLoad = TweenInfo.new(0.6, Enum.EasingStyle.Expo, Enum.EasingDirection.Out)
local tweenFade = TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

-- Функция создания стекла
local function createGlass(props)
    local el = Instance.new(props.ClassName or "Frame")
    el.Name = props.Name or "Glass"
    el.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    el.BackgroundTransparency = props.Transparency or 0.1
    el.Size = props.Size or UDim2.new(1,0,1,0)
    el.Position = props.Position or UDim2.new(0.5,0,0.5,0)
    el.AnchorPoint = props.AnchorPoint or Vector2.new(0.5,0.5)
    el.BorderSizePixel = 0
    el.ClipsDescendants = props.Clips or false
    el.Parent = props.Parent

    local corner = Instance.new("UICorner", el)
    corner.CornerRadius = UDim.new(0, props.Radius or 16)

    local stroke = Instance.new("UIStroke", el)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.85
    stroke.Thickness = 1

    return el
end

-- Главный контейнер
local Screen = Instance.new("ScreenGui")
Screen.Name = "RussElite"
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Screen.ResetOnSpawn = false
Screen.Parent = GuiParent

----------------------------------------------------
-- ЭКРАН ЗАГРУЗКИ
----------------------------------------------------
local Loader = createGlass({Parent = Screen, Name = "Loader", Size = UDim2.new(0, 320, 0, 180), Radius = 20})

local LTitle = Instance.new("TextLabel", Loader)
LTitle.Size = UDim2.new(1, -40, 0, 40)
LTitle.Position = UDim2.new(0, 20, 0, 30)
LTitle.BackgroundTransparency = 1
LTitle.Text = "RussElite"
LTitle.Font = Enum.Font.GothamBold
LTitle.TextSize = 30
LTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LTitle.TextXAlignment = Enum.TextXAlignment.Left

local LSub = Instance.new("TextLabel", Loader)
LSub.Size = UDim2.new(1, -40, 0, 20)
LSub.Position = UDim2.new(0, 20, 0, 70)
LSub.BackgroundTransparency = 1
LSub.Text = "Initializing..."
LSub.Font = Enum.Font.Gotham
LSub.TextSize = 13
LSub.TextColor3 = Color3.fromRGB(170, 170, 170)
LSub.TextXAlignment = Enum.TextXAlignment.Left

local BarBg = Instance.new("Frame", Loader)
BarBg.Size = UDim2.new(1, -40, 0, 5)
BarBg.Position = UDim2.new(0, 20, 0, 140)
BarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
BarBg.BackgroundTransparency = 0.4
BarBg.BorderSizePixel = 0
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

local BarFill = Instance.new("Frame", BarBg)
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BarFill.BackgroundTransparency = 0
BarFill.BorderSizePixel = 0
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

----------------------------------------------------
-- ГЛАВНОЕ ОКНО (изначально скрыто размером 0)
----------------------------------------------------
local Main = createGlass({Parent = Screen, Name = "Main", Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), Radius = 20, Clips = true})

local TopBar = createGlass({Parent = Main, Name = "TopBar", Size = UDim2.new(1, 0, 0, 45), Position = UDim2.new(0, 0, 0, 0), AnchorPoint = Vector2.new(0,0), Radius = 20, Transparency = 0.05})

local TTitle = Instance.new("TextLabel", TopBar)
TTitle.Size = UDim2.new(1, -20, 1, 0)
TTitle.Position = UDim2.new(0, 18, 0, 0)
TTitle.BackgroundTransparency = 1
TTitle.Text = "RussElite"
TTitle.Font = Enum.Font.GothamBold
TTitle.TextSize = 17
TTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
TTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Боковое меню
local TabHolder = Instance.new("Frame", Main)
TabHolder.Size = UDim2.new(0, 130, 1, -45)
TabHolder.Position = UDim2.new(0, 0, 0, 45)
TabHolder.BackgroundTransparency = 1
TabHolder.BorderSizePixel = 0

local TabList = Instance.new("UIListLayout", TabHolder)
TabList.Padding = UDim.new(0, 6)
TabList.SortOrder = Enum.SortOrder.LayoutOrder

local Tabs = {
    {Name = "Home", Id = 1},
    {Name = "Base", Id = 2, Url = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/base/base.lua"},
    {Name = "Game", Id = 3, Url = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/base/game.lua"}
}

local activeTab = nil

for _, tab in ipairs(Tabs) do
    local btn = createGlass({Parent = TabHolder, Name = tab.Name.."Tab", Size = UDim2.new(1, -14, 0, 36), AnchorPoint = Vector2.new(0,0), Position = UDim2.new(0, 7, 0, 0), Radius = 10, Transparency = 0.85})
    btn.LayoutOrder = tab.Id
    btn.ZIndex = 5

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = tab.Name
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.ZIndex = 6

    btn.MouseEnter:Connect(function()
        if activeTab ~= btn then
            TweenService:Create(btn, tweenSmooth, {Transparency = 0.7}):Play()
            TweenService:Create(btn.UIStroke, tweenStroke, {Transparency = 0.6}):Play()
        end
    end)

    btn.MouseLeave:Connect(function()
        if activeTab ~= btn then
            TweenService:Create(btn, tweenSmooth, {Transparency = 0.85}):Play()
            TweenService:Create(btn.UIStroke, tweenStroke, {Transparency = 0.85}):Play()
        end
    end)

    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            if activeTab then
                TweenService:Create(activeTab, tweenSmooth, {Transparency = 0.85}):Play()
                TweenService:Create(activeTab.UIStroke, tweenStroke, {Transparency = 0.85}):Play()
                if activeTab:FindFirstChild("TextLabel") then activeTab.TextLabel.TextColor3 = Color3.fromRGB(180, 180, 180) end
            end
            
            activeTab = btn
            TweenService:Create(btn, tweenSmooth, {Transparency = 0.5}):Play()
            TweenService:Create(btn.UIStroke, tweenStroke, {Transparency = 0.4, Thickness = 1.5}):Play()
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            if tab.Url then
                pcall(function() loadstring(game:HttpGet(tab.Url))() end)
            end
        end
    end)
end

-- Область контента
local Content = createGlass({Parent = Main, Name = "Content", Size = UDim2.new(1, -130, 1, -45), Position = UDim2.new(0, 130, 0, 45), AnchorPoint = Vector2.new(0,0), Radius = 0, Transparency = 0.95})
Instance.new("UIStroke", Content).Transparency = 1 -- Убираем stroke у контента

local CLabel = Instance.new("TextLabel", Content)
CLabel.Size = UDim2.new(1, 0, 1, 0)
CLabel.BackgroundTransparency = 1
CLabel.Text = "Select a module"
CLabel.Font = Enum.Font.Gotham
CLabel.TextSize = 15
CLabel.TextColor3 = Color3.fromRGB(100, 100, 110)

-- Кнопка скрытия/открытия
local Toggle = createGlass({Parent = Screen, Name = "Toggle", Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 20, 0.5, 0), Radius = 25, Transparency = 0.05})

local TIcon = Instance.new("TextLabel", Toggle)
TIcon.Size = UDim2.new(1, 0, 1, 0)
TIcon.BackgroundTransparency = 1
TIcon.Text = "✕"
TIcon.Font = Enum.Font.GothamBold
TIcon.TextSize = 20
TIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
TIcon.ZIndex = 10

local isOpen = false

local function ToggleUI()
    isOpen = not isOpen
    if isOpen then
        TweenService:Create(Main, tweenFast, {Size = UDim2.new(0, 500, 0, 350)}):Play()
        TweenService:Create(Toggle, tweenFast, {Rotation = 0}):Play()
        TIcon.Text = "✕"
    else
        TweenService:Create(Main, tweenFast, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        TweenService:Create(Toggle, tweenFast, {Rotation = 90}):Play()
        TIcon.Text = "☰"
    end
end

Toggle.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        ToggleUI()
    end
end)

Toggle.MouseEnter:Connect(function()
    TweenService:Create(Toggle.UIStroke, tweenStroke, {Transparency = 0.4, Thickness = 2}):Play()
end)
Toggle.MouseLeave:Connect(function()
    TweenService:Create(Toggle.UIStroke, tweenStroke, {Transparency = 0.85, Thickness = 1}):Play()
end)

----------------------------------------------------
-- ПЕРЕТАСКИВАНИЕ (ИСПРАВЛЕНО)
-- ---------------------------------------------------
local dragging, dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

----------------------------------------------------
-- ЗАПУСК
----------------------------------------------------
task.spawn(function()
    -- Анимация загрузки
    local steps = {0.2, 0.5, 0.8, 1.0}
    local texts = {"Parsing UI...", "Loading modules...", "Connecting...", "Done!"}
    
    for i, v in ipairs(steps) do
        TweenService:Create(BarFill, tweenLoad, {Size = UDim2.new(v, 0, 1, 0)}):Play()
        LSub.Text = texts[i]
        task.wait(0.5)
    end
    
    task.wait(0.3)
    
    -- Исчезновение загрузчика
    TweenService:Create(Loader, tweenFade, {BackgroundTransparency = 1}):Play()
    TweenService:Create(LTitle, tweenFade, {TextTransparency = 1}):Play()
    TweenService:Create(LSub, tweenFade, {TextTransparency = 1}):Play()
    TweenService:Create(BarBg, tweenFade, {BackgroundTransparency = 1}):Play()
    TweenService:Create(BarFill, tweenFade, {BackgroundTransparency = 1}):Play()
    
    task.wait(0.9)
    Loader:Destroy()
    
    -- Открытие главного окна
    ToggleUI()
    
    -- Выделение первой вкладки
    local firstTab = TabHolder:FindFirstChild("HomeTab")
    if firstTab then
        activeTab = firstTab
        TweenService:Create(firstTab, tweenSmooth, {Transparency = 0.5}):Play()
        TweenService:Create(firstTab.UIStroke, tweenStroke, {Transparency = 0.4}):Play()
        firstTab.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)
