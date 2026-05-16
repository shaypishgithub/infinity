-- NEW GUI LIBRARY + MAIN (Load this after Core)
-- https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/loader/menu (inspired modern redesign)

local Core = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/core.lua"))() -- Replace with actual core path if needed

local GUI = {}
local AccentColors = {
    Red = Color3.fromRGB(220, 50, 50),
    Green = Color3.fromRGB(50, 220, 80),
    Purple = Color3.fromRGB(160, 60, 220),
    Yellow = Color3.fromRGB(240, 200, 50),
    Cyan = Color3.fromRGB(50, 200, 220)
}

local CurrentAccent = AccentColors.Red
local Settings = {
    Transparency = 0.05,
    Locked = false,
    RGB = false,
    AccentKey = "Red"
}

-- Load Settings
pcall(function()
    if isfile("MegaHack/gui.json") then
        local data = game:GetService("HttpService"):JSONDecode(readfile("MegaHack/gui.json"))
        Settings = data
        CurrentAccent = AccentColors[Settings.AccentKey] or AccentColors.Red
    end
end)

local function SaveSettings()
    pcall(function()
        if not isfolder("MegaHack") then makefolder("MegaHack") end
        writefile("MegaHack/gui.json", game:GetService("HttpService"):JSONEncode(Settings))
    end)
end

-- Create Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MegaHackV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local function Hide(gui)
    pcall(function()
        if gethui then gui.Parent = gethui()
        elseif syn and syn.protect_gui then syn.protect_gui(gui); gui.Parent = game.CoreGui
        else gui.Parent = game.CoreGui end
    end)
end
Hide(ScreenGui)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 620, 0, 420)
Main.Position = UDim2.new(0.5, -310, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

local Glow = Instance.new("UIStroke")
Glow.Thickness = 2
Glow.Color = CurrentAccent
Glow.Transparency = 0.7
Glow.Parent = Main

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Text = "MEGAHACK"
Title.Font = Enum.Font.Code
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 20, 0.5, -11)
Title.Size = UDim2.new(0, 200, 0, 22)
Title.Parent = Header

local Version = Instance.new("TextLabel")
Version.Text = "V2 • NEON"
Version.Font = Enum.Font.Gotham
Version.TextSize = 13
Version.TextColor3 = CurrentAccent
Version.Position = UDim2.new(0, 160, 0.5, -8)
Version.Parent = Header

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, -50)
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
Sidebar.Parent = Main

local TabList = Instance.new("ScrollingFrame")
TabList.Size = UDim2.new(1, 0, 1, -10)
TabList.Position = UDim2.new(0, 0, 0, 10)
TabList.BackgroundTransparency = 1
TabList.ScrollBarThickness = 4
TabList.ScrollBarImageColor3 = CurrentAccent
TabList.Parent = Sidebar

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 4)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabList

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -170, 1, -60)
Content.Position = UDim2.new(0, 165, 0, 55)
Content.BackgroundTransparency = 1
Content.Parent = Main

local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, 0, 1, 0)
ContentScroll.BackgroundTransparency = 1
ContentScroll.ScrollBarThickness = 5
ContentScroll.ScrollBarImageColor3 = CurrentAccent
ContentScroll.Parent = Content

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 12)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ContentScroll

-- Tab System
local Tabs = {}
local ActiveTab = nil

local function CreateTab(name, icon, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = TabList
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 30, 1, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = icon or "●"
    iconLbl.TextColor3 = CurrentAccent
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.TextSize = 18
    iconLbl.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if ActiveTab == btn then return end
        if ActiveTab then
            ActiveTab.BackgroundTransparency = 1
            ActiveTab.TextColor3 = Color3.fromRGB(200, 200, 210)
        end
        btn.BackgroundTransparency = 0.6
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ActiveTab = btn
        Core:TrackTab(name)
        callback()
    end)

    table.insert(Tabs, btn)
    return btn
end

-- Clear Content
local function ClearContent()
    for _, child in ipairs(ContentScroll:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end
end

-- Example Elements
local function AddButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 46)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(240, 240, 245)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 15
    btn.Parent = ContentScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", btn).Color = CurrentAccent; Instance.new("UIStroke", btn).Transparency = 0.8

    btn.MouseButton1Click:Connect(function()
        Services.TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = CurrentAccent}):Play()
        task.delay(0.15, function()
            Services.TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30,30,42)}):Play()
        end)
        callback()
    end)
end

local function AddSection(title)
    local sec = Instance.new("Frame")
    sec.Size = UDim2.new(1, -20, 0, 32)
    sec.BackgroundTransparency = 1
    sec.Parent = ContentScroll

    local lbl = Instance.new("TextLabel")
    lbl.Text = title:upper()
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextColor3 = CurrentAccent
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Parent = sec
end

-- Home
local function ShowHome()
    ClearContent()
    AddSection("WELCOME")
    AddButton("Player: " .. Core.Player.Name, function() end)
    AddButton("Playtime: " .. string.format("%.1f", Core.Stats.totalHours) .. "h", function() end)
end

-- Updates Tab
local function ShowUpdates()
    ClearContent()
    AddSection("RECENT UPDATES")
    local updates = {
        "• Completely new modern GUI",
        "• Accent color system (Red/Green/Purple/Yellow/Cyan)",
        "• Better performance & mobile support",
        "• Config saving for colors & settings",
        "• New neon design with glow effects",
        "• Separated Core + GUI"
    }
    for _, u in ipairs(updates) do
        local l = Instance.new("TextLabel")
        l.Text = u
        l.Font = Enum.Font.Gotham
        l.TextSize = 14
        l.TextColor3 = Color3.fromRGB(200,200,210)
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Size = UDim2.new(1, -30, 0, 28)
        l.BackgroundTransparency = 1
        l.Parent = ContentScroll
    end
end

-- Settings
local function ShowSettings()
    ClearContent()
    AddSection("ACCENT COLOR")

    for name, col in pairs(AccentColors) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.45, 0, 0, 50)
        b.BackgroundColor3 = col
        b.Text = name
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.GothamBold
        b.Parent = ContentScroll
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

        b.MouseButton1Click:Connect(function()
            CurrentAccent = col
            Settings.AccentKey = name
            SaveSettings()
            Glow.Color = col
            Core:Notify("ACCENT", "Changed to " .. name, 2)
            -- Refresh GUI colors if needed
        end)
    end

    AddSection("OTHER")
    AddButton("Anti-Ban / Anti-Kick", function() Core:SetupAntiBan() end)
    AddButton("Save Position", Core.SavePosition)
    AddButton("Teleport to Saved", Core.TeleportToSaved)
    AddButton("Rejoin", function() Core.Services.TeleportService:Teleport(game.PlaceId) end)
end

-- Register Tabs
CreateTab("Home", "🏠", ShowHome)
CreateTab("Updates", "📢", ShowUpdates)
CreateTab("All Scripts", "📜", function()
    ClearContent()
    AddSection("CATEGORIES")
    for catName, _ in pairs(Core.HubData) do
        AddButton(catName, function()
            ClearContent()
            AddSection(catName:upper())
            local data = Core.HubData[catName]
            if data then
                for _, hack in ipairs(data) do
                    if type(hack) == "table" and hack[1] then
                        AddButton(hack[1], hack[2])
                    end
                end
            end
        end)
    end
end)
CreateTab("Settings", "⚙", ShowSettings)

-- Draggable
local dragging
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        local mousePos = input.Position
        local framePos = Main.Position
        local conn
        conn = game:GetService("UserInputService").InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                local delta = inp.Position - mousePos
                Main.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
            end
        end)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                conn:Disconnect()
            end
        end)
    end
end)

-- Show
Main.Size = UDim2.new(0, 0, 0, 0)
Services.TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 620, 0, 420)}):Play()

ShowHome()
Core:Notify("MEGAHACK V2", "Loaded • New Interface", 4)

-- Return GUI for loader
GUI.ScreenGui = ScreenGui
return GUI
