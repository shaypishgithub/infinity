-- RussElite Main Interface - gui.lua
-- Full black UI, loads scripts from base.lua database

local Gui = {}
local Database = nil

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Config
local CONFIG = {
    Title = "RussElite",
    Version = "v2.0",
    TextColor = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(120, 120, 120),     -- grey accent (no blue)
    Background = Color3.fromRGB(0, 0, 0),
    Glass = Color3.fromRGB(15, 15, 15),
    StrokeColor = Color3.fromRGB(60, 60, 60),
    GlassTransparency = 0.0,                     -- fully opaque black glass
    WindowSize = UDim2.new(0, 600, 0, 420),
    ToggleButtonSize = UDim2.new(0, 50, 0, 50),
    BorderRadius = 12,
    BaseURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/base/base.lua"
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

-- Tween helper
local function tween(obj, props, dur, easing, dir)
    return TweenService:Create(obj,
        TweenInfo.new(dur or 0.3, easing or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

-- Apply black glass style
local function applyStyle(frame)
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.StrokeColor
    stroke.Transparency = 0.7
    stroke.Thickness = 1
    stroke.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    corner.Parent = frame

    return stroke, corner
end

-- Load database
local function LoadDatabase(callback)
    local statusText = Gui.Elements and Gui.Elements.StatusText
    if statusText then statusText.Text = "Loading database..." end

    local ok, result = pcall(function()
        local data = game:HttpGet(CONFIG.BaseURL)
        local func = loadstring(data)
        if func then
            local db = func()
            return db
        end
    end)

    if ok and result then
        Database = result
        if statusText then statusText.Text = "Database loaded." end
        callback()
    else
        warn("Failed to load database:", result)
        if statusText then statusText.Text = "Database error!" end
    end
end

-- Create toggle button
function Gui:CreateToggleButton()
    local container = self.Root

    local btn = Instance.new("TextButton")
    btn.Name = "ToggleButton"
    btn.Size = CONFIG.ToggleButtonSize
    btn.Position = UDim2.new(0.95, -25, 0.5, -25)
    btn.BackgroundColor3 = CONFIG.Glass
    btn.BackgroundTransparency = CONFIG.GlassTransparency
    btn.Text = "RE"
    btn.TextColor3 = CONFIG.TextColor
    btn.TextSize = 18
    btn.Font = Enum.Font.GothamBold
    btn.Parent = container

    applyStyle(btn)

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "✦"
    icon.TextColor3 = CONFIG.Accent
    icon.TextSize = 24
    icon.Font = Enum.Font.GothamBold
    icon.Parent = btn

    return btn
end

-- Create main window
function Gui:CreateMainWindow()
    local container = self.Root

    local window = Instance.new("Frame")
    window.Name = "MainWindow"
    window.Size = CONFIG.WindowSize
    window.Position = UDim2.new(0.5, -300, 0.5, -210)
    window.BackgroundColor3 = CONFIG.Background
    window.BackgroundTransparency = 0.0
    window.Visible = false
    window.Parent = container

    applyStyle(window)

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = CONFIG.Glass
    titleBar.BackgroundTransparency = 0.0
    titleBar.Parent = window

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    titleCorner.Parent = titleBar

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0.6, 0, 1, 0)
    titleText.Position = UDim2.new(0.02, 0, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = CONFIG.Title
    titleText.TextColor3 = CONFIG.TextColor
    titleText.TextSize = 20
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(0.2, 0, 1, 0)
    versionLabel.Position = UDim2.new(0.6, 0, 0, 0)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = CONFIG.Version
    versionLabel.TextColor3 = CONFIG.Accent
    versionLabel.TextSize = 12
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.TextTransparency = 0.5
    versionLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(0.93, 0, 0.15, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = CONFIG.TextColor
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeBtn

    -- Search bar
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(0.96, 0, 0, 30)
    searchFrame.Position = UDim2.new(0.02, 0, 0, 50)
    searchFrame.BackgroundColor3 = CONFIG.Glass
    searchFrame.BackgroundTransparency = 0.0
    searchFrame.Parent = window

    applyStyle(searchFrame)

    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(0.9, 0, 1, 0)
    searchBox.Position = UDim2.new(0.05, 0, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.PlaceholderText = "🔍 Search scripts..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    searchBox.Text = ""
    searchBox.TextColor3 = CONFIG.TextColor
    searchBox.TextSize = 14
    searchBox.Font = Enum.Font.Gotham
    searchBox.Parent = searchFrame

    -- Content area (scrollable list of scripts)
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Name = "ScriptList"
    scrollingFrame.Size = UDim2.new(0.96, 0, 1, -90)
    scrollingFrame.Position = UDim2.new(0.02, 0, 0, 85)
    scrollingFrame.BackgroundColor3 = CONFIG.Glass
    scrollingFrame.BackgroundTransparency = 0.0
    scrollingFrame.ScrollBarThickness = 4
    scrollingFrame.ScrollBarImageColor3 = CONFIG.Accent
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.Parent = window

    applyStyle(scrollingFrame)

    local listLayout = Instance.new("UIGridLayout")
    listLayout.CellSize = UDim2.new(0, 120, 0, 80)
    listLayout.CellPadding = UDim2.new(0, 8, 0, 8)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.Name
    listLayout.Parent = scrollingFrame

    -- Status bar
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(0.96, 0, 0, 22)
    statusBar.Position = UDim2.new(0.02, 0, 0.95, -22)
    statusBar.BackgroundColor3 = CONFIG.Glass
    statusBar.BackgroundTransparency = 0.0
    statusBar.Parent = window

    applyStyle(statusBar)

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(0.9, 0, 1, 0)
    statusText.Position = UDim2.new(0.05, 0, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Ready"
    statusText.TextColor3 = CONFIG.Accent
    statusText.TextSize = 12
    statusText.Font = Enum.Font.Gotham
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusBar

    return {
        Window = window,
        TitleBar = titleBar,
        CloseButton = closeBtn,
        SearchBox = searchBox,
        ScrollingFrame = scrollingFrame,
        ListLayout = listLayout,
        StatusBar = statusBar,
        StatusText = statusText
    }
end

-- Build script cards from database
function Gui:PopulateScripts(filter)
    local frame = self.Elements.ScrollingFrame
    local layout = self.Elements.ListLayout

    -- Clear existing cards
    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    if not Database or not Database.categories then return end

    local searchText = filter or ""
    searchText = searchText:lower()

    local sortedCategories = {}
    for name, _ in pairs(Database.categories) do
        table.insert(sortedCategories, name)
    end
    table.sort(sortedCategories)

    local yCount = 0
    local columns = math.floor(frame.AbsoluteSize.X / (120 + 8)) or 4

    for _, name in ipairs(sortedCategories) do
        if searchText == "" or name:lower():find(searchText, 1, true) then
            local card = Instance.new("Frame")
            card.Name = name
            card.Size = UDim2.new(0, 120, 0, 80)
            card.BackgroundColor3 = CONFIG.Glass
            card.BackgroundTransparency = 0.0
            card.Parent = frame

            applyStyle(card)

            -- Icon
            local iconId = Database.imageIds[name] or "rbxasset://textures/ui/GuiImagePlaceholder.png"
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 50, 0, 50)
            icon.Position = UDim2.new(0.5, -25, 0.05, 0)
            icon.BackgroundTransparency = 1
            icon.Image = iconId
            icon.ScaleType = Enum.ScaleType.Fit
            icon.Parent = card

            -- Name label
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Position = UDim2.new(0, 0, 0, 58)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = CONFIG.TextColor
            label.TextSize = 12
            label.Font = Enum.Font.Gotham
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.Parent = card

            -- Click to load script
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.Parent = card

            btn.MouseButton1Click:Connect(function()
                self:RunScript(name)
            end)

            -- Hover animation
            btn.MouseEnter:Connect(function()
                tween(card, {BackgroundTransparency = 0.05}, 0.2)
            end)
            btn.MouseLeave:Connect(function()
                tween(card, {BackgroundTransparency = 0.0}, 0.2)
            end)

            yCount = yCount + 1
        end
    end

    -- Update canvas size
    local rows = math.ceil(yCount / columns)
    frame.CanvasSize = UDim2.new(0, 0, 0, rows * (80 + 8) + 8)
end

-- Run a script from the database
function Gui:RunScript(categoryName)
    if not Database or not Database.categories[categoryName] then
        self.Elements.StatusText.Text = "Script not found!"
        return
    end

    local fileName = Database.categories[categoryName]
    local url = Database.baseUrl .. "/" .. fileName

    self.Elements.StatusText.Text = "Loading " .. categoryName .. "..."
    self.Elements.StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)

    local ok, err = pcall(function()
        local source = game:HttpGet(url)
        local func = loadstring(source)
        if func then
            func()
        end
    end)

    if ok then
        self.Elements.StatusText.Text = categoryName .. " executed!"
        self.Elements.StatusText.TextColor3 = Color3.fromRGB(100, 200, 100)
        task.delay(3, function()
            self.Elements.StatusText.Text = "Ready"
            self.Elements.StatusText.TextColor3 = CONFIG.Accent
        end)
    else
        self.Elements.StatusText.Text = "Error: " .. tostring(err)
        self.Elements.StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.delay(4, function()
            self.Elements.StatusText.Text = "Ready"
            self.Elements.StatusText.TextColor3 = CONFIG.Accent
        end)
    end
end

-- Toggle window visibility
function Gui:ToggleWindow()
    local window = self.Elements.Window
    if window.Visible then
        tween(window, {BackgroundTransparency = 1, Size = UDim2.new(0, 550, 0, 370)}, 0.25)
        task.wait(0.25)
        window.Visible = false
    else
        window.Visible = true
        window.BackgroundTransparency = 1
        tween(window, {BackgroundTransparency = 0.0, Size = CONFIG.WindowSize}, 0.25)
    end
end

-- Drag functionality
function Gui:MakeDraggable(window, titleBar)
    local dragging, startPos, startInput
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = window.Position
            startInput = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Initialize
function Gui:Init()
    self.Root = GetSafeContainer()
    self.Elements = {}

    -- Toggle button
    self.Elements.ToggleButton = self:CreateToggleButton()

    -- Main window
    local winParts = self:CreateMainWindow()
    for k, v in pairs(winParts) do
        self.Elements[k] = v
    end

    -- Make draggable
    self:MakeDraggable(self.Elements.Window, self.Elements.TitleBar)

    -- Toggle button events
    self.Elements.ToggleButton.MouseButton1Click:Connect(function()
        self:ToggleWindow()
    end)
    self.Elements.CloseButton.MouseButton1Click:Connect(function()
        self:ToggleWindow()
    end)

    -- Search filter
    self.Elements.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:PopulateScripts(self.Elements.SearchBox.Text)
    end)

    -- Load database and populate
    LoadDatabase(function()
        self:PopulateScripts()
    end)
end

-- Start
Gui:Init()
