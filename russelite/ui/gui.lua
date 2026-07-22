
-- RussElite Imperial Hub - Main GUI (gui.lua)
local Gui = {}

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Theme Configuration
local C = {
    Background  = Color3.fromRGB(12, 12, 18),
    Header      = Color3.fromRGB(18, 18, 26),
    Panel       = Color3.fromRGB(22, 22, 32),
    Accent      = Color3.fromRGB(218, 165, 32),
    AccentBright= Color3.fromRGB(255, 205, 60),
    Text        = Color3.fromRGB(255, 255, 255),
    SubText     = Color3.fromRGB(150, 150, 165),
    Stroke      = Color3.fromRGB(255, 255, 255),
    Success     = Color3.fromRGB(80, 220, 120),
    Error       = Color3.fromRGB(240, 70, 70)
}

local CFG = {
    Title     = "RUSSELITE",
    Subtitle  = "IMPERIAL EDITION",
    Width     = 580,
    Height    = 380,
    BaseURL   = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/"
}

-- Safe Parent Resolution
local function getContainer()
    local ok, sg = pcall(function()
        local s = Instance.new("ScreenGui")
        s.Name = "RussEliteHub"
        s.ResetOnSpawn = false
        s.Parent = CoreGui
        return s
    end)
    if ok and sg then return sg end

    local lp = Players.LocalPlayer
    local pg = lp and lp:FindFirstChild("PlayerGui")
    if pg then
        local s = Instance.new("ScreenGui")
        s.Name = "RussEliteHub"
        s.ResetOnSpawn = false
        s.Parent = pg
        return s
    end
    return nil
end

-- Helper: Apply Glass Surface Styling
local function applyGlassStyle(instance, cornerRadius, strokeTransparency)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 12)
    corner.Parent = instance

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.Stroke
    stroke.Transparency = strokeTransparency or 0.85
    stroke.Thickness = 1
    stroke.Parent = instance

    return stroke
end

-- Helper: Smooth Tweens
local function tween(obj, props, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.25,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- Build Interface
function Gui:Build()
    self.Container = getContainer()
    if not self.Container then return end

    -- Floating Glass Toggle Button
    local toggle = Instance.new("TextButton")
    toggle.Name = "ToggleButton"
    toggle.Size = UDim2.new(0, 50, 0, 50)
    toggle.Position = UDim2.new(0.92, -25, 0.15, 0)
    toggle.BackgroundColor3 = C.Background
    toggle.BackgroundTransparency = 0.25
    toggle.Text = "♔"
    toggle.TextColor3 = C.Accent
    toggle.TextSize = 22
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = self.Container
    local toggleStroke = applyGlassStyle(toggle, 25, 0.7)

    self.Toggle = toggle

    -- Main Window
    local main = Instance.new("Frame")
    main.Name = "MainWindow"
    main.Size = UDim2.new(0, CFG.Width, 0, CFG.Height)
    main.Position = UDim2.new(0.5, -CFG.Width / 2, 0.5, -CFG.Height / 2)
    main.BackgroundColor3 = C.Background
    main.BackgroundTransparency = 0.18
    main.ClipsDescendants = true
    main.Visible = false
    main.Parent = self.Container
    applyGlassStyle(main, 14, 0.8)

    self.Window = main

    -- Header Bar
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundColor3 = C.Header
    header.BackgroundTransparency = 0.3
    header.Parent = main
    applyGlassStyle(header, 14, 0.9)

    -- Brand Icon & Title
    local crown = Instance.new("TextLabel")
    crown.Size = UDim2.new(0, 30, 1, 0)
    crown.Position = UDim2.new(0, 14, 0, 0)
    crown.BackgroundTransparency = 1
    crown.Text = "♔"
    crown.TextColor3 = C.Accent
    crown.TextSize = 20
    crown.Font = Enum.Font.GothamBold
    crown.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 120, 1, 0)
    title.Position = UDim2.new(0, 46, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = CFG.Title
    title.TextColor3 = C.Text
    title.TextSize = 16
    title.Font = Enum.Font.GothamBlack
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(0, 120, 1, 0)
    sub.Position = UDim2.new(0, 155, 0, 0)
    sub.BackgroundTransparency = 1
    sub.Text = "|  " .. CFG.Subtitle
    sub.TextColor3 = C.Accent
    sub.TextSize = 10
    sub.Font = Enum.Font.GothamBold
    sub.TextTransparency = 0.3
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = header

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BackgroundTransparency = 0.7
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = C.Text
    closeBtn.TextSize = 12
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    applyGlassStyle(closeBtn, 8, 0.8)

    self.CloseBtn = closeBtn

    -- Navigation Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 140, 1, -60)
    sidebar.Position = UDim2.new(0, 10, 0, 54)
    sidebar.BackgroundColor3 = C.Panel
    sidebar.BackgroundTransparency = 0.4
    sidebar.Parent = main
    applyGlassStyle(sidebar, 10, 0.9)

    local navList = Instance.new("UIListLayout")
    navList.Padding = UDim.new(0, 6)
    navList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    navList.SortOrder = Enum.SortOrder.LayoutOrder
    navList.Parent = sidebar

    local navPadding = Instance.new("UIPadding")
    navPadding.PaddingTop = UDim.new(0, 8)
    navPadding.Parent = sidebar

    -- Content Area
    local content = Instance.new("Frame")
    content.Name = "ContentArea"
    content.Size = UDim2.new(1, -170, 1, -60)
    content.Position = UDim2.new(0, 160, 0, 54)
    content.BackgroundColor3 = C.Panel
    content.BackgroundTransparency = 0.4
    content.Parent = main
    applyGlassStyle(content, 10, 0.9)

    self.Content = content

    -- Status Label
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 20)
    status.Position = UDim2.new(0, 10, 1, -24)
    status.BackgroundTransparency = 1
    status.Text = "System Ready"
    status.TextColor3 = C.SubText
    status.TextSize = 10
    status.Font = Enum.Font.Gotham
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = content

    self.Status = status

    -- Setup Tabs
    self:SetupTabs(sidebar)
    self:MakeDraggable(header)
    self:ConnectEvents()
end

-- Create Tab Buttons and Views
function Gui:SetupTabs(sidebar)
    local tabs = {
        { Name = "Universal", Path = "base/base.lua", Order = 1 },
        { Name = "Game Specific", Path = "base/game.lua", Order = 2 }
    }

    self.TabButtons = {}
    self.TabPages = {}

    for _, data in ipairs(tabs) do
        -- Button
        local btn = Instance.new("TextButton")
        btn.Name = "Tab_" .. data.Name
        btn.Size = UDim2.new(0.9, 0, 0, 34)
        btn.BackgroundColor3 = C.Header
        btn.BackgroundTransparency = 0.6
        btn.Text = data.Name
        btn.TextColor3 = C.SubText
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamMedium
        btn.LayoutOrder = data.Order
        btn.Parent = sidebar
        local btnStroke = applyGlassStyle(btn, 8, 0.9)

        -- Container Page
        local page = Instance.new("ScrollingFrame")
        page.Name = "Page_" .. data.Name
        page.Size = UDim2.new(1, -20, 1, -40)
        page.Position = UDim2.new(0, 10, 0, 10)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = C.Accent
        page.Visible = false
        page.Parent = self.Content

        -- Action Execute Button on Page
        local execBtn = Instance.new("TextButton")
        execBtn.Size = UDim2.new(1, -10, 0, 42)
        execBtn.Position = UDim2.new(0, 0, 0, 10)
        execBtn.BackgroundColor3 = C.Header
        execBtn.BackgroundTransparency = 0.3
        execBtn.Text = "⚡ Load " .. data.Name .. " Module"
        execBtn.TextColor3 = C.Text
        execBtn.TextSize = 13
        execBtn.Font = Enum.Font.GothamBold
        execBtn.Parent = page
        applyGlassStyle(execBtn, 8, 0.75)

        execBtn.MouseButton1Click:Connect(function()
            self:ExecuteModule(data.Name, data.Path)
        end)

        self.TabButtons[data.Name] = btn
        self.TabPages[data.Name] = page

        -- Tab Selection Handler
        btn.MouseButton1Click:Connect(function()
            self:SelectTab(data.Name)
        end)
    end

    -- Select First Tab by Default
    self:SelectTab("Universal")
end

-- Tab Switch Handler
function Gui:SelectTab(selectedName)
    for name, btn in pairs(self.TabButtons) do
        local page = self.TabPages[name]
        if name == selectedName then
            tween(btn, { BackgroundTransparency = 0.2, TextColor3 = C.AccentBright }, 0.2)
            page.Visible = true
        else
            tween(btn, { BackgroundTransparency = 0.6, TextColor3 = C.SubText }, 0.2)
            page.Visible = false
        end
    end
end

-- Execute Remote Script Module
function Gui:ExecuteModule(name, path)
    self.Status.Text = "Fetching " .. name .. "..."
    self.Status.TextColor3 = C.AccentBright

    task.spawn(function()
        local url = CFG.BaseURL .. path
        local ok, result = pcall(function()
            local code = game:HttpGet(url)
            return loadstring(code)
        end)

        if ok and type(result) == "function" then
            local execOk, execErr = pcall(result)
            if execOk then
                self.Status.Text = "✓ Executed: " .. name
                self.Status.TextColor3 = C.Success
            else
                self.Status.Text = "✗ Runtime Error: " .. tostring(execErr):sub(1, 40)
                self.Status.TextColor3 = C.Error
            end
        else
            self.Status.Text = "✗ Failed to load module code"
            self.Status.TextColor3 = C.Error
        end

        task.delay(3, function()
            self.Status.Text = "System Ready"
            self.Status.TextColor3 = C.SubText
        end)
    end)
end

-- Window Drag Functionality
function Gui:MakeDraggable(dragHandle)
    local dragging, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.Window.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.Window.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Interactive Event Handlers
function Gui:ConnectEvents()
    -- Toggle Open/Close Window
    local isOpen = false
    local function toggleWindow()
        isOpen = not isOpen
        if isOpen then
            self.Window.Visible = true
            self.Window.Size = UDim2.new(0, CFG.Width * 0.9, 0, CFG.Height * 0.9)
            self.Window.BackgroundTransparency = 1
            tween(self.Window, {
                Size = UDim2.new(0, CFG.Width, 0, CFG.Height),
                BackgroundTransparency = 0.18
            }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            tween(self.Window, {
                Size = UDim2.new(0, CFG.Width * 0.9, 0, CFG.Height * 0.9),
                BackgroundTransparency = 1
            }, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            task.wait(0.2)
            self.Window.Visible = false
        end
    end

    self.Toggle.MouseButton1Click:Connect(toggleWindow)
    self.CloseBtn.MouseButton1Click:Connect(toggleWindow)

    -- Toggle Hover Effect
    self.Toggle.MouseEnter:Connect(function()
        tween(self.Toggle, { BackgroundTransparency = 0.1, TextColor3 = C.AccentBright }, 0.2)
    end)
    self.Toggle.MouseLeave:Connect(function()
        tween(self.Toggle, { BackgroundTransparency = 0.25, TextColor3 = C.Accent }, 0.2)
    end)
end

-- Initialize Hub
Gui:Build()
