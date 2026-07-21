-- RussElite Main Interface - gui.lua
-- Full black UI, handles both direct scripts and sub-menu tables

local Gui = {}
local Database = nil

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Config
local CONFIG = {
    Title = "RussElite",
    Version = "v2.1",
    TextColor = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(150, 150, 150),
    Background = Color3.fromRGB(0, 0, 0),
    Glass = Color3.fromRGB(12, 12, 12),
    StrokeColor = Color3.fromRGB(50, 50, 50),
    WindowSize = UDim2.new(0, 620, 0, 440),
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
    stroke.Transparency = 0.6
    stroke.Thickness = 1
    stroke.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    corner.Parent = frame
end

-- Load database
local function LoadDatabase(callback)
    if Gui.Elements and Gui.Elements.StatusText then
        Gui.Elements.StatusText.Text = "Loading database..."
    end

    local ok, result = pcall(function()
        local data = game:HttpGet(CONFIG.BaseURL)
        local func = loadstring(data)
        if func then
            return func()
        end
    end)

    if ok and result then
        Database = result
        if Gui.Elements and Gui.Elements.StatusText then
            Gui.Elements.StatusText.Text = "Database loaded."
        end
        callback()
    else
        warn("Failed to load database:", result)
        if Gui.Elements and Gui.Elements.StatusText then
            Gui.Elements.StatusText.Text = "Database error!"
        end
    end
end

-- Create toggle button
function Gui:CreateToggleButton()
    local container = self.Root

    local btn = Instance.new("TextButton")
    btn.Name = "ToggleButton"
    btn.Size = CONFIG.ToggleButtonSize
    btn.Position = UDim2.new(0.94, -25, 0.5, -25)
    btn.BackgroundColor3 = CONFIG.Glass
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
    window.Position = UDim2.new(0.5, -310, 0.5, -220)
    window.BackgroundColor3 = CONFIG.Background
    window.Visible = false
    window.Parent = container

    applyStyle(window)

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = CONFIG.Glass
    titleBar.Parent = window

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    titleCorner.Parent = titleBar

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0.5, 0, 1, 0)
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
    versionLabel.Position = UDim2.new(0.5, 0, 0, 0)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = CONFIG.Version
    versionLabel.TextColor3 = CONFIG.Accent
    versionLabel.TextSize = 12
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.TextTransparency = 0.5
    versionLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
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
    searchFrame.Parent = window

    applyStyle(searchFrame)

    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(0.9, 0, 1, 0)
    searchBox.Position = UDim2.new(0.05, 0, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.PlaceholderText = "🔍 Search scripts..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBox.Text = ""
    searchBox.TextColor3 = CONFIG.TextColor
    searchBox.TextSize = 14
    searchBox.Font = Enum.Font.Gotham
    searchBox.Parent = searchFrame

    -- Content container (will hold either category grid or sub-script list)
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(0.96, 0, 1, -90)
    contentContainer.Position = UDim2.new(0.02, 0, 0, 85)
    contentContainer.BackgroundColor3 = CONFIG.Glass
    contentContainer.BackgroundTransparency = 0.0
    contentContainer.Parent = window

    applyStyle(contentContainer)

    -- Scrolling frame for categories (default view)
    local categoryScroll = Instance.new("ScrollingFrame")
    categoryScroll.Name = "CategoryScroll"
    categoryScroll.Size = UDim2.new(1, 0, 1, 0)
    categoryScroll.BackgroundTransparency = 1
    categoryScroll.ScrollBarThickness = 4
    categoryScroll.ScrollBarImageColor3 = CONFIG.Accent
    categoryScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    categoryScroll.Parent = contentContainer

    local categoryLayout = Instance.new("UIGridLayout")
    categoryLayout.CellSize = UDim2.new(0, 120, 0, 80)
    categoryLayout.CellPadding = UDim2.new(0, 8, 0, 8)
    categoryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    categoryLayout.SortOrder = Enum.SortOrder.Name
    categoryLayout.Parent = categoryScroll

    -- Sub-script view (hidden by default)
    local subScriptScroll = Instance.new("ScrollingFrame")
    subScriptScroll.Name = "SubScriptScroll"
    subScriptScroll.Size = UDim2.new(1, 0, 1, 0)
    subScriptScroll.BackgroundTransparency = 1
    subScriptScroll.ScrollBarThickness = 4
    subScriptScroll.ScrollBarImageColor3 = CONFIG.Accent
    subScriptScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    subScriptScroll.Visible = false
    subScriptScroll.Parent = contentContainer

    local subLayout = Instance.new("UIListLayout")
    subLayout.SortOrder = Enum.SortOrder.Name
    subLayout.Padding = UDim.new(0, 6)
    subLayout.Parent = subScriptScroll

    -- Back button (placed inside contentContainer, above the scrolls)
    local backBtn = Instance.new("TextButton")
    backBtn.Name = "BackBtn"
    backBtn.Size = UDim2.new(0, 80, 0, 24)
    backBtn.Position = UDim2.new(0.01, 0, 0.01, 0)
    backBtn.BackgroundColor3 = CONFIG.Accent
    backBtn.BackgroundTransparency = 0.7
    backBtn.Text = "◀ Back"
    backBtn.TextColor3 = CONFIG.TextColor
    backBtn.TextSize = 13
    backBtn.Font = Enum.Font.Gotham
    backBtn.Visible = false
    backBtn.Parent = contentContainer

    local backCorner = Instance.new("UICorner")
    backCorner.CornerRadius = UDim.new(0, 8)
    backCorner.Parent = backBtn

    -- Status bar
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(0.96, 0, 0, 22)
    statusBar.Position = UDim2.new(0.02, 0, 0.95, -22)
    statusBar.BackgroundColor3 = CONFIG.Glass
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
        ContentContainer = contentContainer,
        CategoryScroll = categoryScroll,
        CategoryLayout = categoryLayout,
        SubScriptScroll = subScriptScroll,
        SubLayout = subLayout,
        BackButton = backBtn,
        StatusBar = statusBar,
        StatusText = statusText
    }
end

-- Populate category cards
function Gui:PopulateCategories(filter)
    local frame = self.Elements.CategoryScroll
    local layout = self.Elements.CategoryLayout

    -- Clear existing cards
    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    if not Database or not Database.categories then return end

    local searchText = filter or ""
    searchText = searchText:lower()

    local sorted = {}
    for name, _ in pairs(Database.categories) do
        table.insert(sorted, name)
    end
    table.sort(sorted)

    local columns = math.max(1, math.floor(frame.AbsoluteSize.X / (120 + 8)))
    local count = 0

    for _, name in ipairs(sorted) do
        if searchText == "" or name:lower():find(searchText, 1, true) then
            local card = Instance.new("Frame")
            card.Name = name
            card.Size = UDim2.new(0, 120, 0, 80)
            card.BackgroundColor3 = CONFIG.Glass
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

            -- Label
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Position = UDim2.new(0, 0, 0, 58)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = CONFIG.TextColor
            label.TextSize = 11
            label.Font = Enum.Font.Gotham
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.Parent = card

            -- Button
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.Parent = card

            btn.MouseButton1Click:Connect(function()
                self:OnCategoryClick(name)
            end)

            btn.MouseEnter:Connect(function()
                tween(card, {BackgroundTransparency = 0.05}, 0.2)
            end)
            btn.MouseLeave:Connect(function()
                tween(card, {BackgroundTransparency = 0.0}, 0.2)
            end)

            count = count + 1
        end
    end

    -- Update canvas size
    local rows = math.ceil(count / columns)
    frame.CanvasSize = UDim2.new(0, 0, 0, rows * (80 + 8) + 8)
end

-- Populate sub-scripts list
function Gui:PopulateSubScripts(scriptList, categoryName)
    local scroll = self.Elements.SubScriptScroll
    local layout = self.Elements.SubLayout

    -- Clear
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then
            child:Destroy()
        end
    end

    -- Title at top
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0, 28)
    titleLabel.Position = UDim2.new(0.01, 0, 0.01, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "📜 " .. categoryName .. " Scripts"
    titleLabel.TextColor3 = CONFIG.TextColor
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = scroll

    -- Add each sub-script as a button
    for i, entry in ipairs(scriptList) do
        if type(entry) == "table" and #entry >= 2 then
            local name = entry[1]
            local func = entry[2]

            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(0.95, 0, 0, 36)
            itemBtn.BackgroundColor3 = CONFIG.Glass
            itemBtn.BackgroundTransparency = 0.0
            itemBtn.Text = "  " .. name
            itemBtn.TextColor3 = CONFIG.TextColor
            itemBtn.TextSize = 14
            itemBtn.Font = Enum.Font.Gotham
            itemBtn.TextXAlignment = Enum.TextXAlignment.Left
            itemBtn.Parent = scroll

            applyStyle(itemBtn)

            itemBtn.MouseButton1Click:Connect(function()
                self.Elements.StatusText.Text = "Running: " .. name
                local ok, err = pcall(func)
                if ok then
                    self.Elements.StatusText.Text = name .. " executed!"
                    self.Elements.StatusText.TextColor3 = Color3.fromRGB(100, 200, 100)
                else
                    self.Elements.StatusText.Text = "Error: " .. tostring(err)
                    self.Elements.StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
                task.delay(3, function()
                    self.Elements.StatusText.Text = "Ready"
                    self.Elements.StatusText.TextColor3 = CONFIG.Accent
                end)
            end)

            itemBtn.MouseEnter:Connect(function()
                tween(itemBtn, {BackgroundTransparency = 0.05}, 0.15)
            end)
            itemBtn.MouseLeave:Connect(function()
                tween(itemBtn, {BackgroundTransparency = 0.0}, 0.15)
            end)
        end
    end

    -- Update canvas
    scroll.CanvasSize = UDim2.new(0, 0, 0, (#scriptList * (36 + 6)) + 40)
    scroll.CanvasPosition = Vector2.new(0, 0)
end

-- Handle category click
function Gui:OnCategoryClick(categoryName)
    if not Database or not Database.categories[categoryName] then
        self.Elements.StatusText.Text = "Category not found"
        return
    end

    local fileName = Database.categories[categoryName]
    local url = Database.baseUrl .. "/" .. fileName

    self.Elements.StatusText.Text = "Loading " .. categoryName .. "..."
    self.Elements.StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)

    local ok, result = pcall(function()
        local source = game:HttpGet(url)
        local chunk = loadstring(source)
        if chunk then
            return chunk()
        end
    end)

    if not ok then
        self.Elements.StatusText.Text = "Error loading: " .. tostring(result)
        self.Elements.StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    -- Check if result is a table of sub-scripts
    if type(result) == "table" then
        -- Switch to sub-script view
        self.Elements.CategoryScroll.Visible = false
        self.Elements.SubScriptScroll.Visible = true
        self.Elements.BackButton.Visible = true
        self.Elements.SearchBox.Visible = false  -- hide search while in sub-menu
        self:PopulateSubScripts(result, categoryName)
        self.Elements.StatusText.Text = categoryName .. " scripts loaded"
        self.Elements.StatusText.TextColor3 = CONFIG.Accent
    else
        -- Direct execution (nothing returned or a function was executed internally)
        self.Elements.StatusText.Text = categoryName .. " executed!"
        self.Elements.StatusText.TextColor3 = Color3.fromRGB(100, 200, 100)
        task.delay(2, function()
            self.Elements.StatusText.Text = "Ready"
            self.Elements.StatusText.TextColor3 = CONFIG.Accent
        end)
    end
end

-- Go back to category view
function Gui:ShowCategories()
    self.Elements.CategoryScroll.Visible = true
    self.Elements.SubScriptScroll.Visible = false
    self.Elements.BackButton.Visible = false
    self.Elements.SearchBox.Visible = true
    self.Elements.StatusText.Text = "Ready"
    self.Elements.StatusText.TextColor3 = CONFIG.Accent
end

-- Toggle window
function Gui:ToggleWindow()
    local window = self.Elements.Window
    if window.Visible then
        tween(window, {BackgroundTransparency = 1, Size = UDim2.new(0, 580, 0, 400)}, 0.25)
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

    -- Toggle events
    self.Elements.ToggleButton.MouseButton1Click:Connect(function()
        self:ToggleWindow()
    end)
    self.Elements.CloseButton.MouseButton1Click:Connect(function()
        self:ToggleWindow()
    end)

    -- Back button
    self.Elements.BackButton.MouseButton1Click:Connect(function()
        self:ShowCategories()
    end)

    -- Search filter
    self.Elements.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:PopulateCategories(self.Elements.SearchBox.Text)
    end)

    -- Load database and populate
    LoadDatabase(function()
        self:PopulateCategories()
    end)
end

-- Start
Gui:Init()
