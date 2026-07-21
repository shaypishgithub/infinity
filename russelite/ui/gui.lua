-- RussElite Main Interface - gui.lua
-- Glassmorphism Script Hub Interface

local Gui = {}
local Modules = {
    Base = nil,
    Game = nil
}

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Configuration
local CONFIG = {
    Title = "RussElite",
    Version = "v1.0.0",
    PrimaryColor = Color3.fromRGB(100, 180, 255),
    AccentColor = Color3.fromRGB(80, 150, 255),
    BackgroundColor = Color3.fromRGB(15, 15, 25),
    GlassBackground = Color3.fromRGB(25, 25, 40),
    TextColor = Color3.fromRGB(255, 255, 255),
    GlassTransparency = 0.15,
    WindowSize = UDim2.new(0, 550, 0, 380),
    ToggleButtonSize = UDim2.new(0, 50, 0, 50),
    BorderRadius = 16,
    Modules = {
        Base = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/base/base.lua",
        Game = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/base/game.lua"
    }
}

-- Safe parent
local function GetSafeContainer()
    local success, result = pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "RussEliteHub"
        sg.Parent = CoreGui
        return sg
    end)
    
    if not success then
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        local sg = Instance.new("ScreenGui")
        sg.Name = "RussEliteHub"
        sg.Parent = playerGui
        return sg
    end
    
    return result
end

-- Utility functions
local function CreateTween(object, properties, duration, easingStyle, easingDirection)
    return TweenService:Create(
        object,
        TweenInfo.new(duration or 0.3, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out),
        properties
    )
end

local function ApplyGlassEffect(frame)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.7
    stroke.Thickness = 1
    stroke.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    corner.Parent = frame
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 220))
    })
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(0.5, 0.95),
        NumberSequenceKeypoint.new(1, 0.9)
    })
    gradient.Rotation = 45
    gradient.Parent = stroke
    
    return {Stroke = stroke, Corner = corner, Gradient = gradient}
end

-- Create toggle button
function Gui:CreateToggleButton()
    local container = GetSafeContainer()
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = CONFIG.ToggleButtonSize
    toggleButton.Position = UDim2.new(0.95, -25, 0.5, -25)
    toggleButton.BackgroundColor3 = CONFIG.GlassBackground
    toggleButton.BackgroundTransparency = CONFIG.GlassTransparency
    toggleButton.Text = "RE"
    toggleButton.TextColor3 = CONFIG.TextColor
    toggleButton.TextSize = 18
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = container
    
    ApplyGlassEffect(toggleButton)
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "✦"
    icon.TextColor3 = CONFIG.PrimaryColor
    icon.TextSize = 24
    icon.Font = Enum.Font.GothamBold
    icon.Parent = toggleButton
    
    return toggleButton
end

-- Create main window
function Gui:CreateMainWindow()
    local container = GetSafeContainer()
    
    -- Main window frame
    local mainWindow = Instance.new("Frame")
    mainWindow.Name = "MainWindow"
    mainWindow.Size = CONFIG.WindowSize
    mainWindow.Position = UDim2.new(0.5, -275, 0.5, -190)
    mainWindow.BackgroundColor3 = CONFIG.GlassBackground
    mainWindow.BackgroundTransparency = CONFIG.GlassTransparency
    mainWindow.Visible = false
    mainWindow.Parent = container
    
    local elements = ApplyGlassEffect(mainWindow)
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = CONFIG.BackgroundColor
    titleBar.BackgroundTransparency = 0.3
    titleBar.Parent = mainWindow
    
    local titleBarCorner = Instance.new("UICorner")
    titleBarCorner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    titleBarCorner.Parent = titleBar
    
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(0.6, 0, 1, 0)
    titleText.Position = UDim2.new(0.02, 0, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = CONFIG.Title
    titleText.TextColor3 = CONFIG.TextColor
    titleText.TextSize = 20
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Version label
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Name = "VersionLabel"
    versionLabel.Size = UDim2.new(0.2, 0, 1, 0)
    versionLabel.Position = UDim2.new(0.6, 0, 0, 0)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = CONFIG.Version
    versionLabel.TextColor3 = CONFIG.PrimaryColor
    versionLabel.TextSize = 12
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.TextTransparency = 0.3
    versionLabel.Parent = titleBar
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Position = UDim2.new(0.92, 0, 0.1, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeButton.BackgroundTransparency = 0.8
    closeButton.Text = "✕"
    closeButton.TextColor3 = CONFIG.TextColor
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeButton
    
    -- Tab container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0.22, 0, 1, -55)
    tabContainer.Position = UDim2.new(0.01, 0, 0, 55)
    tabContainer.BackgroundColor3 = CONFIG.BackgroundColor
    tabContainer.BackgroundTransparency = 0.5
    tabContainer.Parent = mainWindow
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    tabCorner.Parent = tabContainer
    
    -- Content area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(0.74, 0, 1, -65)
    contentArea.Position = UDim2.new(0.25, 0, 0, 55)
    contentArea.BackgroundColor3 = CONFIG.BackgroundColor
    contentArea.BackgroundTransparency = 0.3
    contentArea.Parent = mainWindow
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    contentCorner.Parent = contentArea
    
    -- Create tabs
    local tabs = {
        {Name = "Universal", Icon = "🌐", Module = "Base"},
        {Name = "Game Specific", Icon = "🎮", Module = "Game"}
    }
    
    local tabButtons = {}
    
    for i, tab in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tab.Name .. "Tab"
        tabButton.Size = UDim2.new(0.9, 0, 0, 40)
        tabButton.Position = UDim2.new(0.05, 0, 0, 10 + (i - 1) * 50)
        tabButton.BackgroundColor3 = CONFIG.PrimaryColor
        tabButton.BackgroundTransparency = 0.85
        tabButton.Text = tab.Icon .. "  " .. tab.Name
        tabButton.TextColor3 = CONFIG.TextColor
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.Gotham
        tabButton.Parent = tabContainer
        
        local tabButtonCorner = Instance.new("UICorner")
        tabButtonCorner.CornerRadius = UDim.new(0, 12)
        tabButtonCorner.Parent = tabButton
        
        local tabStroke = Instance.new("UIStroke")
        tabStroke.Color = CONFIG.PrimaryColor
        tabStroke.Transparency = 0.5
        tabStroke.Thickness = 1
        tabStroke.Parent = tabButton
        
        table.insert(tabButtons, {
            Button = tabButton,
            Module = tab.Module,
            Name = tab.Name
        })
    end
    
    -- Status bar
    local statusBar = Instance.new("Frame")
    statusBar.Name = "StatusBar"
    statusBar.Size = UDim2.new(0.74, 0, 0, 25)
    statusBar.Position = UDim2.new(0.25, 0, 0.94, -25)
    statusBar.BackgroundColor3 = CONFIG.BackgroundColor
    statusBar.BackgroundTransparency = 0.5
    statusBar.Parent = mainWindow
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    statusCorner.Parent = statusBar
    
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(0.9, 0, 1, 0)
    statusText.Position = UDim2.new(0.05, 0, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Ready"
    statusText.TextColor3 = CONFIG.PrimaryColor
    statusText.TextSize = 12
    statusText.Font = Enum.Font.Gotham
    statusText.TextTransparency = 0.3
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusBar
    
    return {
        Window = mainWindow,
        TitleBar = titleBar,
        CloseButton = closeButton,
        TabContainer = tabContainer,
        ContentArea = contentArea,
        StatusBar = statusBar,
        StatusText = statusText,
        TabButtons = tabButtons
    }
end

-- Module loader
function Gui:LoadModule(moduleName, url)
    local statusText = self.Elements.StatusText
    
    statusText.Text = "Loading " .. moduleName .. " module..."
    
    local success, result = pcall(function()
        local moduleScript = game:HttpGet(url)
        local moduleFunc = loadstring(moduleScript)
        if moduleFunc then
            local module = moduleFunc()
            Modules[moduleName] = module
            
            if module and module.Init then
                module.Init(self.Elements.ContentArea)
            end
        end
    end)
    
    if success then
        statusText.Text = moduleName .. " module loaded successfully!"
        statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.delay(2, function()
            statusText.Text = "Ready"
            statusText.TextColor3 = CONFIG.PrimaryColor
        end)
    else
        statusText.Text = "Failed to load " .. moduleName .. " module!"
        statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        warn("Module load error:", result)
        task.delay(3, function()
            statusText.Text = "Ready"
            statusText.TextColor3 = CONFIG.PrimaryColor
        end)
    end
end

-- Handle tab selection
function Gui:SelectTab(button, tabData)
    -- Update button states
    for _, tab in ipairs(self.Elements.TabButtons) do
        local isSelected = (tab.Module == tabData.Module)
        CreateTween(tab.Button, {
            BackgroundTransparency = isSelected and 0.7 or 0.85
        }, 0.3):Play()
    end
    
    -- Load module if not loaded
    if not Modules[tabData.Module] then
        local moduleUrl = CONFIG.Modules[tabData.Module]
        if moduleUrl then
            self:LoadModule(tabData.Module, moduleUrl)
        end
    end
end

-- Make window draggable
function Gui:MakeDraggable(window, titleBar)
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Toggle window with animation
function Gui:ToggleWindow()
    local window = self.Elements.Window
    local toggleButton = self.Elements.ToggleButton
    
    if window.Visible then
        -- Fade out animation
        CreateTween(window, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 500, 0, 330)
        }, 0.3):Play()
        
        CreateTween(self.Elements.TitleBar, {
            BackgroundTransparency = 1
        }, 0.3):Play()
        
        task.wait(0.3)
        window.Visible = false
    else
        -- Fade in animation
        window.Visible = true
        window.BackgroundTransparency = 1
        
        CreateTween(window, {
            BackgroundTransparency = CONFIG.GlassTransparency,
            Size = CONFIG.WindowSize
        }, 0.3):Play()
        
        CreateTween(self.Elements.TitleBar, {
            BackgroundTransparency = 0.3
        }, 0.3):Play()
    end
end

-- Setup animations
function Gui:SetupAnimations()
    local toggleButton = self.Elements.ToggleButton
    
    -- Hover animations
    toggleButton.MouseEnter:Connect(function()
        CreateTween(toggleButton, {
            BackgroundTransparency = 0.05,
            Size = UDim2.new(0, 55, 0, 55)
        }, 0.2, Enum.EasingStyle.Back):Play()
    end)
    
    toggleButton.MouseLeave:Connect(function()
        CreateTween(toggleButton, {
            BackgroundTransparency = CONFIG.GlassTransparency,
            Size = CONFIG.ToggleButtonSize
        }, 0.2, Enum.EasingStyle.Quad):Play()
    end)
    
    -- Close button hover
    local closeButton = self.Elements.CloseButton
    closeButton.MouseEnter:Connect(function()
        CreateTween(closeButton, {
            BackgroundTransparency = 0.3
        }, 0.2):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        CreateTween(closeButton, {
            BackgroundTransparency = 0.8
        }, 0.2):Play()
    end)
    
    -- Tab button hovers
    for _, tab in ipairs(self.Elements.TabButtons) do
        tab.Button.MouseEnter:Connect(function()
            if not Modules[tab.Module] then
                CreateTween(tab.Button, {
                    BackgroundTransparency = 0.75
                }, 0.2):Play()
            end
        end)
        
        tab.Button.MouseLeave:Connect(function()
            if not Modules[tab.Module] then
                CreateTween(tab.Button, {
                    BackgroundTransparency = 0.85
                }, 0.2):Play()
            end
        end)
    end
end

-- Initialize GUI
function Gui:Init()
    self.Elements = {}
    
    -- Create toggle button
    self.Elements.ToggleButton = self:CreateToggleButton()
    
    -- Create main window elements
    local windowElements = self:CreateMainWindow()
    for k, v in pairs(windowElements) do
        self.Elements[k] = v
    end
    
    -- Make window draggable
    self:MakeDraggable(self.Elements.Window, self.Elements.TitleBar)
    
    -- Setup animations
    self:SetupAnimations()
    
    -- Button events
    self.Elements.ToggleButton.MouseButton1Click:Connect(function()
        self:ToggleWindow()
    end)
    
    self.Elements.CloseButton.MouseButton1Click:Connect(function()
        self:ToggleWindow()
    end)
    
    -- Tab button events
    for _, tab in ipairs(self.Elements.TabButtons) do
        tab.Button.MouseButton1Click:Connect(function()
            self:SelectTab(tab.Button, tab)
        end)
    end
end

-- Start the GUI
Gui:Init()
