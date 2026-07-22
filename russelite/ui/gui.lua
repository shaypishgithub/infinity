-- RussElite Main Interface - gui.lua
local Gui = {}
local Database = nil
local CurrentSubScripts = nil
local CurrentCategory = nil

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Configuration
local CONFIG = {
    Title = "RussElite",
    Version = "v2.2",
    TextColor = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(150, 150, 150),
    Background = Color3.fromRGB(0, 0, 0),
    Glass = Color3.fromRGB(15, 15, 15),
    StrokeColor = Color3.fromRGB(50, 50, 50),
    WindowSize = UDim2.new(0, 620, 0, 440),
    ToggleButtonSize = UDim2.new(0, 55, 0, 55),
    BorderRadius = 12,
    BaseURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/base/base.lua"
}

-- Safe GUI container
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
local function tween(obj, props, dur)
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- Apply style
local function applyStyle(frame)
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.StrokeColor
    stroke.Transparency = 0.5
    stroke.Thickness = 1
    stroke.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    corner.Parent = frame
end

-- Create toggle button
function Gui:CreateToggleButton()
    local btn = Instance.new("TextButton")
    btn.Name = "ToggleButton"
    btn.Size = CONFIG.ToggleButtonSize
    btn.Position = UDim2.new(0.93, -25, 0.5, -25)
    btn.BackgroundColor3 = CONFIG.Glass
    btn.BackgroundTransparency = 0.1
    btn.Text = ""
    btn.Parent = self.Container
    
    applyStyle(btn)
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "RE"
    icon.TextColor3 = CONFIG.TextColor
    icon.TextSize = 20
    icon.Font = Enum.Font.GothamBold
    icon.Parent = btn
    
    -- Star decoration
    local star = Instance.new("TextLabel")
    star.Size = UDim2.new(1, 0, 0, 15)
    star.Position = UDim2.new(0, 0, 0, -18)
    star.BackgroundTransparency = 1
    star.Text = "✦"
    star.TextColor3 = CONFIG.Accent
    star.TextSize = 16
    star.Font = Enum.Font.GothamBold
    star.Parent = btn
    
    return btn
end

-- Create main window
function Gui:CreateMainWindow()
    local window = Instance.new("Frame")
    window.Name = "MainWindow"
    window.Size = CONFIG.WindowSize
    window.Position = UDim2.new(0.5, -310, 0.5, -220)
    window.BackgroundColor3 = CONFIG.Background
    window.BackgroundTransparency = 0.05
    window.Visible = false
    window.Parent = self.Container
    
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
    
    -- Version
    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(0.15, 0, 1, 0)
    version.Position = UDim2.new(0.45, 0, 0, 0)
    version.BackgroundTransparency = 1
    version.Text = CONFIG.Version
    version.TextColor3 = CONFIG.Accent
    version.TextSize = 11
    version.Font = Enum.Font.Gotham
    version.TextTransparency = 0.4
    version.Parent = titleBar
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(0.93, 0, 0.15, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = CONFIG.TextColor
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
    
    -- Search bar
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(0.96, 0, 0, 32)
    searchFrame.Position = UDim2.new(0.02, 0, 0, 48)
    searchFrame.BackgroundColor3 = CONFIG.Glass
    searchFrame.Parent = window
    
    applyStyle(searchFrame)
    
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(0.92, 0, 1, 0)
    searchBox.Position = UDim2.new(0.04, 0, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.PlaceholderText = "🔍 Search scripts..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBox.Text = ""
    searchBox.TextColor3 = CONFIG.TextColor
    searchBox.TextSize = 14
    searchBox.Font = Enum.Font.Gotham
    searchBox.Parent = searchFrame
    
    -- Content area
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(0.96, 0, 1, -130)
    contentArea.Position = UDim2.new(0.02, 0, 0, 88)
    contentArea.BackgroundColor3 = CONFIG.Glass
    contentArea.BackgroundTransparency = 0.1
    contentArea.ClipsDescendants = true
    contentArea.Parent = window
    
    applyStyle(contentArea)
    
    -- Back button (hidden by default)
    local backBtn = Instance.new("TextButton")
    backBtn.Name = "BackButton"
    backBtn.Size = UDim2.new(0, 80, 0, 26)
    backBtn.Position = UDim2.new(0.01, 0, 0.01, 0)
    backBtn.BackgroundColor3 = CONFIG.Accent
    backBtn.BackgroundTransparency = 0.6
    backBtn.Text = "◀ Back"
    backBtn.TextColor3 = CONFIG.TextColor
    backBtn.TextSize = 13
    backBtn.Font = Enum.Font.GothamBold
    backBtn.Visible = false
    backBtn.Parent = contentArea
    
    Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 8)
    
    -- Category scrolling frame
    local categoryScroll = Instance.new("ScrollingFrame")
    categoryScroll.Name = "CategoryScroll"
    categoryScroll.Size = UDim2.new(1, 0, 1, 0)
    categoryScroll.BackgroundTransparency = 1
    categoryScroll.ScrollBarThickness = 4
    categoryScroll.ScrollBarImageColor3 = CONFIG.Accent
    categoryScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    categoryScroll.Parent = contentArea
    
    local categoryGrid = Instance.new("UIGridLayout")
    categoryGrid.CellSize = UDim2.new(0, 130, 0, 90)
    categoryGrid.CellPadding = UDim2.new(0, 8, 0, 8)
    categoryGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    categoryGrid.SortOrder = Enum.SortOrder.Name
    categoryGrid.Parent = categoryScroll
    
    -- Sub-script scrolling frame (hidden)
    local subScroll = Instance.new("ScrollingFrame")
    subScroll.Name = "SubScriptScroll"
    subScroll.Size = UDim2.new(1, 0, 1, -35)
    subScroll.Position = UDim2.new(0, 0, 0, 35)
    subScroll.BackgroundTransparency = 1
    subScroll.ScrollBarThickness = 4
    subScroll.ScrollBarImageColor3 = CONFIG.Accent
    subScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    subScroll.Visible = false
    subScroll.Parent = contentArea
    
    local subList = Instance.new("UIListLayout")
    subList.SortOrder = Enum.SortOrder.Name
    subList.Padding = UDim.new(0, 6)
    subList.Parent = subScroll
    
    -- Sub-script title
    local subTitle = Instance.new("TextLabel")
    subTitle.Name = "SubTitle"
    subTitle.Size = UDim2.new(1, 0, 0, 30)
    subTitle.BackgroundTransparency = 1
    subTitle.Text = ""
    subTitle.TextColor3 = CONFIG.TextColor
    subTitle.TextSize = 16
    subTitle.Font = Enum.Font.GothamBold
    subTitle.TextXAlignment = Enum.TextXAlignment.Left
    subTitle.Visible = false
    subTitle.Parent = contentArea
    
    -- Status bar
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(0.96, 0, 0, 24)
    statusBar.Position = UDim2.new(0.02, 0, 0.94, -24)
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
        ContentArea = contentArea,
        BackButton = backBtn,
        CategoryScroll = categoryScroll,
        CategoryGrid = categoryGrid,
        SubScroll = subScroll,
        SubList = subList,
        SubTitle = subTitle,
        StatusText = statusText
    }
end

-- Load database
function Gui:LoadDatabase()
    self.Elements.StatusText.Text = "Loading database..."
    
    local success, result = pcall(function()
        local data = game:HttpGet(CONFIG.BaseURL)
        local func = loadstring(data)
        if func then
            return func()
        end
    end)
    
    if success and result then
        Database = result
        self.Elements.StatusText.Text = "Database loaded!"
        self:PopulateCategories()
        task.delay(2, function()
            self.Elements.StatusText.Text = "Ready"
        end)
    else
        self.Elements.StatusText.Text = "Failed to load database!"
        warn("Database error:", result)
    end
end

-- Populate categories
function Gui:PopulateCategories(filter)
    local scroll = self.Elements.CategoryScroll
    local grid = self.Elements.CategoryGrid
    
    -- Clear existing
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if not Database or not Database.categories then return end
    
    local searchText = (filter or ""):lower()
    local categories = {}
    
    for name, _ in pairs(Database.categories) do
        table.insert(categories, name)
    end
    table.sort(categories)
    
    local count = 0
    local columns = math.max(1, math.floor(scroll.AbsoluteSize.X / (130 + 8)))
    
    for _, name in ipairs(categories) do
        if searchText == "" or name:lower():find(searchText, 1, true) then
            local card = Instance.new("Frame")
            card.Name = name
            card.Size = UDim2.new(0, 130, 0, 90)
            card.BackgroundColor3 = CONFIG.Glass
            card.BackgroundTransparency = 0.05
            card.Parent = scroll
            
            applyStyle(card)
            
            -- Game icon
            local iconId = nil
            if Database.imageIds and Database.imageIds[name] then
                iconId = Database.imageIds[name]
            end
            
            if iconId then
                local icon = Instance.new("ImageLabel")
                icon.Size = UDim2.new(0, 50, 0, 50)
                icon.Position = UDim2.new(0.5, -25, 0.05, 0)
                icon.BackgroundTransparency = 1
                icon.Image = iconId
                icon.ScaleType = Enum.ScaleType.Fit
                icon.Parent = card
            end
            
            -- Category name
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -8, 0, 20)
            label.Position = UDim2.new(0, 4, 0, 62)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = CONFIG.TextColor
            label.TextSize = 12
            label.Font = Enum.Font.GothamBold
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.Parent = card
            
            -- Click button
            local clickBtn = Instance.new("TextButton")
            clickBtn.Size = UDim2.new(1, 0, 1, 0)
            clickBtn.BackgroundTransparency = 1
            clickBtn.Text = ""
            clickBtn.Parent = card
            
            clickBtn.MouseButton1Click:Connect(function()
                self:OnCategoryClick(name)
            end)
            
            -- Hover effects
            clickBtn.MouseEnter:Connect(function()
                tween(card, {BackgroundTransparency = 0.15}, 0.2)
            end)
            clickBtn.MouseLeave:Connect(function()
                tween(card, {BackgroundTransparency = 0.05}, 0.2)
            end)
            
            count = count + 1
        end
    end
    
    local rows = math.ceil(count / columns)
    scroll.CanvasSize = UDim2.new(0, 0, 0, rows * (90 + 8) + 8)
end

-- Populate sub-scripts
function Gui:PopulateSubScripts(scripts, categoryName)
    local scroll = self.Elements.SubScroll
    local list = self.Elements.SubList
    
    -- Clear
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Set title
    self.Elements.SubTitle.Text = "📜 " .. categoryName .. " Scripts (" .. #scripts .. ")"
    
    -- Add script buttons
    for i, script in ipairs(scripts) do
        if type(script) == "table" and #script >= 2 then
            local scriptName = tostring(script[1])
            local scriptFunc = script[2]
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.95, 0, 0, 38)
            btn.BackgroundColor3 = CONFIG.Glass
            btn.BackgroundTransparency = 0.05
            btn.Text = "  " .. scriptName
            btn.TextColor3 = CONFIG.TextColor
            btn.TextSize = 14
            btn.Font = Enum.Font.Gotham
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = scroll
            
            applyStyle(btn)
            
            -- Arrow indicator
            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 20, 1, 0)
            arrow.Position = UDim2.new(0.95, -20, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▶"
            arrow.TextColor3 = CONFIG.Accent
            arrow.TextSize = 12
            arrow.Font = Enum.Font.GothamBold
            arrow.Parent = btn
            
            -- Click handler
            btn.MouseButton1Click:Connect(function()
                self.Elements.StatusText.Text = "Running: " .. scriptName
                self.Elements.StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
                
                local success, err = pcall(scriptFunc)
                
                if success then
                    self.Elements.StatusText.Text = scriptName .. " executed!"
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
            
            -- Hover effects
            btn.MouseEnter:Connect(function()
                tween(btn, {BackgroundTransparency = 0.15}, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                tween(btn, {BackgroundTransparency = 0.05}, 0.15)
            end)
        end
    end
    
    -- Update canvas size
    scroll.CanvasSize = UDim2.new(0, 0, 0, #scripts * (38 + 6) + 10)
    scroll.CanvasPosition = Vector2.new(0, 0)
end

-- Handle category click
function Gui:OnCategoryClick(categoryName)
    if not Database or not Database.categories then
        self.Elements.StatusText.Text = "No database loaded!"
        return
    end
    
    local fileName = Database.categories[categoryName]
    if not fileName then
        self.Elements.StatusText.Text = "Category not found!"
        return
    end
    
    local url = Database.baseUrl .. "/" .. fileName
    
    self.Elements.StatusText.Text = "Loading " .. categoryName .. "..."
    self.Elements.StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    
    -- Fetch and execute the script
    local success, result = pcall(function()
        local source = game:HttpGet(url)
        local chunk = loadstring(source)
        if chunk then
            return chunk()
        end
    end)
    
    if not success then
        self.Elements.StatusText.Text = "Error: " .. tostring(result)
        self.Elements.StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    -- Check if result is a table (sub-scripts)
    if type(result) == "table" then
        -- Switch to sub-script view
        self.Elements.CategoryScroll.Visible = false
        self.Elements.SubScroll.Visible = true
        self.Elements.SubTitle.Visible = true
        self.Elements.BackButton.Visible = true
        self.Elements.SearchBox.Visible = false
        
        CurrentSubScripts = result
        CurrentCategory = categoryName
        
        self:PopulateSubScripts(result, categoryName)
        self.Elements.StatusText.Text = categoryName .. " loaded! (" .. #result .. " scripts)"
        self.Elements.StatusText.TextColor3 = Color3.fromRGB(150, 200, 150)
    else
        -- Direct script executed
        self.Elements.StatusText.Text = categoryName .. " executed!"
        self.Elements.StatusText.TextColor3 = Color3.fromRGB(100, 200, 100)
        task.delay(2, function()
            self.Elements.StatusText.Text = "Ready"
            self.Elements.StatusText.TextColor3 = CONFIG.Accent
        end)
    end
end

-- Go back to categories
function Gui:BackToCategories()
    self.Elements.CategoryScroll.Visible = true
    self.Elements.SubScroll.Visible = false
    self.Elements.SubTitle.Visible = false
    self.Elements.BackButton.Visible = false
    self.Elements.SearchBox.Visible = true
    
    CurrentSubScripts = nil
    CurrentCategory = nil
    
    self.Elements.StatusText.Text = "Ready"
    self.Elements.StatusText.TextColor3 = CONFIG.Accent
end

-- Toggle window
function Gui:ToggleWindow()
    local window = self.Elements.Window
    
    if window.Visible then
        -- Hide
        window.BackgroundTransparency = 0.05
        tween(window, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 580, 0, 400)
        }, 0.2)
        
        task.wait(0.2)
        window.Visible = false
    else
        -- Show
        window.Visible = true
        window.BackgroundTransparency = 1
        window.Size = UDim2.new(0, 580, 0, 400)
        
        tween(window, {
            BackgroundTransparency = 0.05,
            Size = CONFIG.WindowSize
        }, 0.2)
    end
end

-- Make window draggable
function Gui:MakeDraggable()
    local window = self.Elements.Window
    local titleBar = self.Elements.TitleBar
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
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
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Initialize
function Gui:Init()
    self.Container = GetSafeContainer()
    
    -- Create UI elements
    self.Elements = {}
    self.Elements.ToggleButton = self:CreateToggleButton()
    
    local winParts = self:CreateMainWindow()
    for k, v in pairs(winParts) do
        self.Elements[k] = v
    end
    
    -- Setup event handlers
    self.Elements.ToggleButton.MouseButton1Click:Connect(function()
        self:ToggleWindow()
    end)
    
    self.Elements.CloseButton.MouseButton1Click:Connect(function()
        self:ToggleWindow()
    end)
    
    self.Elements.BackButton.MouseButton1Click:Connect(function()
        self:BackToCategories()
    end)
    
    self.Elements.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if self.Elements.CategoryScroll.Visible then
            self:PopulateCategories(self.Elements.SearchBox.Text)
        end
    end)
    
    -- Make window draggable
    self:MakeDraggable()
    
    -- Load database
    self:LoadDatabase()
end

-- Start everything
Gui:Init()
