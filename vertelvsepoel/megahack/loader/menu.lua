-- menu.lua
local Core = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/loader/core.lua", true))() 

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NeonHack"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local function hideGui(gui)
    if gethui then gui.Parent = gethui()
    elseif get_hidden_gui then gui.Parent = get_hidden_gui()
    else gui.Parent = game:GetService("CoreGui") end
end
hideGui(screenGui)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 620, 0, 420)
mainFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 56)
topBar.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 16)

local title = Instance.new("TextLabel")
title.Text = "NEON"
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(255, 80, 180)
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 24, 0, 12)
title.Parent = topBar

local subtitle = Instance.new("TextLabel")
subtitle.Text = "HACK"
subtitle.Font = Enum.Font.GothamBlack
subtitle.TextSize = 22
subtitle.TextColor3 = Color3.fromRGB(80, 220, 255)
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.new(0, 88, 0, 12)
subtitle.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -48, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 80)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = topBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 10)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 160, 1, -56)
sidebar.Position = UDim2.new(0, 0, 0, 56)
sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 23)
sidebar.Parent = mainFrame

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -160, 1, -56)
content.Position = UDim2.new(0, 160, 0, 56)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -20)
scroll.Position = UDim2.new(0, 10, 0, 10)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(120, 80, 255)
scroll.Parent = content

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local categories = {
    {name = "Home", color = Color3.fromRGB(80, 220, 255)},
    {name = "Updates", color = Color3.fromRGB(255, 180, 60)},
    {name = "Scripts", color = Color3.fromRGB(0, 255, 140)},
    {name = "Combat", color = Color3.fromRGB(255, 80, 80)},
    {name = "Movement", color = Color3.fromRGB(180, 100, 255)},
    {name = "Settings", color = Color3.fromRGB(255, 220, 80)},
}

local activeTab = nil

local function createTabButton(data)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 42)
    btn.Position = UDim2.new(0, 8, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    btn.Text = data.name
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, -12)
    accent.Position = UDim2.new(0, 8, 0, 6)
    accent.BackgroundColor3 = data.color
    accent.Parent = btn
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)
    
    btn.MouseButton1Click:Connect(function()
        if activeTab then
            TweenService:Create(activeTab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22,22,32), TextColor3 = Color3.fromRGB(200,200,210)}):Play()
        end
        TweenService:Create(btn, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(35,35,50), TextColor3 = Color3.new(1,1,1)}):Play()
        activeTab = btn
        Core:trackTab(data.name)
        loadTabContent(data.name)
    end)
    return btn
end

for _, cat in ipairs(categories) do
    createTabButton(cat)
end

function loadTabContent(tab)
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("GuiObject") and not child:IsA("UIListLayout") then child:Destroy() end
    end
    
    if tab == "Home" then
        local welcome = Instance.new("TextLabel")
        welcome.Text = "Welcome back, " .. player.Name
        welcome.Font = Enum.Font.GothamBlack
        welcome.TextSize = 18
        welcome.TextColor3 = Color3.fromRGB(255,255,255)
        welcome.Size = UDim2.new(1,0,0,60)
        welcome.BackgroundTransparency = 1
        welcome.Parent = scroll
    elseif tab == "Updates" then
        local upd = Instance.new("TextLabel")
        upd.Text = "• v2.0 Neon UI Release\n• New accent system\n• Performance improvements\n• Added Updates tab"
        upd.TextWrapped = true
        upd.TextXAlignment = Enum.TextXAlignment.Left
        upd.Size = UDim2.new(1, -20, 0, 140)
        upd.BackgroundColor3 = Color3.fromRGB(25,25,35)
        upd.Parent = scroll
        Instance.new("UICorner", upd).CornerRadius = UDim.new(0, 12)
    elseif tab == "Scripts" then
        for name, _ in pairs(Core.HubData) do
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1,0,0,38)
            b.BackgroundColor3 = Color3.fromRGB(28,28,38)
            b.Text = name
            b.TextColor3 = Color3.fromRGB(220,220,230)
            b.Font = Enum.Font.Gotham
            b.Parent = scroll
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
            b.MouseButton1Click:Connect(function()
                if Core.HubData[name] then
                    pcall(Core.HubData[name])
                end
            end)
        end
    elseif tab == "Settings" then
        local colors = {"Green", "Red", "Purple", "Yellow"}
        for _, c in ipairs(colors) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,0,40)
            btn.BackgroundColor3 = Core.settings.colors["accent"..c] or Color3.fromRGB(100,100,100)
            btn.Text = "Accent " .. c
            btn.Parent = scroll
            btn.MouseButton1Click:Connect(function()
                -- color picker logic
            end)
        end
    end
end

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Draggable
local dragging
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        local mousePos = input.Position
        local framePos = mainFrame.Position
        game:GetService("RunService").RenderStepped:Connect(function()
            if dragging then
                local delta = game:GetService("UserInputService").GetMouseLocation(game:GetService("UserInputService")) - mousePos
                mainFrame.Position = UDim2.new(0, framePos.X.Offset + delta.X, 0, framePos.Y.Offset + delta.Y)
            end
        end)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

Core:loadColorSettings()
Core:loadStats()
Core.stats.sessions += 1
Core:saveStats()

loadTabContent("Home")

Core:createNotification("NEON HACK", "Loaded successfully", 4)
