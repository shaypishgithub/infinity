-- menu.lua
local Core = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/loader/core.lua", true))() 

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MegaHackV2"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local function hideGui(g)
    pcall(function()
        if gethui then g.Parent = gethui()
        elseif syn and syn.protect_gui then syn.protect_gui(g); g.Parent = game.CoreGui
        else g.Parent = game.CoreGui end
    end)
end
hideGui(screenGui)

-- NEW MODERN DESIGN: Top Navigation + Content Cards + Side Panel
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 720, 0, 480)
mainFrame.Position = UDim2.new(0.5, -360, 0.5, -240)
mainFrame.BackgroundColor3 = Core.Settings.Theme.Primary
mainFrame.BackgroundTransparency = Core.Settings.Transparency
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 2
mainStroke.Color = Core.GetAccentColor()

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 60)
topBar.BackgroundColor3 = Core.Settings.Theme.Secondary
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 16)

local logo = Instance.new("TextLabel")
logo.Text = "MEGAHACK"
logo.Font = Enum.Font.Code
logo.TextSize = 28
logo.TextColor3 = Core.GetAccentColor()
logo.BackgroundTransparency = 1
logo.Position = UDim2.new(0, 24, 0.5, -14)
logo.Size = UDim2.new(0, 180, 0, 40)
logo.Parent = topBar

-- Navigation Tabs (horizontal)
local navFrame = Instance.new("Frame")
navFrame.Size = UDim2.new(1, -280, 0, 50)
navFrame.Position = UDim2.new(0, 220, 0, 8)
navFrame.BackgroundTransparency = 1
navFrame.Parent = topBar

local navLayout = Instance.new("UIListLayout")
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.Padding = UDim.new(0, 8)
navLayout.Parent = navFrame

local tabs = {}
local currentTab = "Home"

local function createTab(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 110, 1, 0)
    btn.BackgroundColor3 = Core.Settings.Theme.Button
    btn.BackgroundTransparency = 0.6
    btn.Text = name
    btn.TextColor3 = Core.Settings.Theme.TextSecondary
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 15
    btn.Parent = navFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            TweenService:Create(t, TweenInfo.new(0.2), {BackgroundTransparency = 0.6, TextColor3 = Core.Settings.Theme.TextSecondary}):Play()
        end
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1, TextColor3 = Core.Settings.Theme.TextPrimary}):Play()
        currentTab = name
        Core.TrackTab(name)
        callback()
    end)
    tabs[name] = btn
    return btn
end

-- Content Area
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -40, 1, -100)
content.Position = UDim2.new(0, 20, 0, 80)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 6
content.ScrollBarImageColor3 = Core.GetAccentColor()
content.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 12)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = content

-- Accent Selector
local accentPanel = Instance.new("Frame")
accentPanel.Size = UDim2.new(0, 140, 0, 160)
accentPanel.Position = UDim2.new(1, -160, 0, 80)
accentPanel.BackgroundColor3 = Core.Settings.Theme.Panel
accentPanel.Parent = mainFrame
Instance.new("UICorner", accentPanel).CornerRadius = UDim.new(0, 12)

local function createAccentBtn(colorName, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 50, 0, 50)
    b.BackgroundColor3 = color
    b.Text = ""
    b.Parent = accentPanel
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    b.MouseButton1Click:Connect(function()
        Core.Settings.Theme.CurrentAccent = colorName
        Core.UpdateTheme()
        Core.SaveConfig()
        Core.Notify("Theme", "Accent changed to " .. colorName, 2)
    end)
end

createAccentBtn("Red", Core.DefaultTheme.Accents.Red)
createAccentBtn("Green", Core.DefaultTheme.Accents.Green)
createAccentBtn("Purple", Core.DefaultTheme.Accents.Purple)
createAccentBtn("Yellow", Core.DefaultTheme.Accents.Yellow)

-- Tab Functions
local function showHome()
    -- clear content
    for _, child in pairs(content:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end
    -- Player card, stats, etc. (modern card style)
    Core.Notify("Welcome", "MegaHack V2 Loaded", 3)
end

local function showUpdates()
    -- New tab content with changelog
    for _, child in pairs(content:GetChildren()) do if not child:IsA("UIListLayout") then child:Destroy() end end
    
    local header = Instance.new("TextLabel")
    header.Text = "Recent Updates"
    header.Font = Enum.Font.GothamBold
    header.TextSize = 22
    header.TextColor3 = Core.GetAccentColor()
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundTransparency = 1
    header.Parent = content

    local changes = {
        "• Completely new modern UI",
        "• Multiple accent colors (Red/Green/Purple/Yellow)",
        "• Separated Core + Menu",
        "• Improved notifications",
        "• Better config system",
        "• New Updates tab",
        "• Enhanced drag & performance"
    }

    for _, change in ipairs(changes) do
        local lbl = Instance.new("TextLabel")
        lbl.Text = change
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 16
        lbl.TextColor3 = Core.Settings.Theme.TextPrimary
        lbl.Size = UDim2.new(1, -20, 0, 30)
        lbl.BackgroundTransparency = 1
        lbl.Parent = content
    end
end

-- Register tabs
createTab("Home", showHome)
createTab("Updates", showUpdates)
createTab("Scripts", function() 
    -- populate scripts with categories
end)
createTab("Settings", function()
    -- color pickers, toggles etc.
end)

-- Draggable
local dragging
local dragInput
local dragStart
local startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

topBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateInput(input)
    end
end)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -50, 0, 10)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1, 0.3, 0.3)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 24
closeBtn.Parent = topBar
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Init
Core.LoadConfig()
Core.LoadStats()
Core.Settings.Stats.sessions = (Core.Settings.Stats.sessions or 0) + 1
Core.SaveStats()

showHome()

Core.Notify("MegaHack V2", "New interface loaded successfully", 4)

return screenGui
