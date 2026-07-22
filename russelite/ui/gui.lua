-- RussElite Main Interface - gui.lua
-- Premium Glass Morphism Design 2026
-- iPhone Aesthetic with Modern Glass Effects

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

-- Modern Premium Configuration
local CONFIG = {
    Title = "RussElite",
    Version = "v3.0 Pro",
    
    -- Premium Color Palette 2026
    TextColor = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(200, 200, 200),
    TextTertiary = Color3.fromRGB(150, 150, 150),
    
    -- Glass Effects
    GlassLight = Color3.fromRGB(25, 25, 25),
    GlassMedium = Color3.fromRGB(20, 20, 20),
    GlassDark = Color3.fromRGB(15, 15, 15),
    
    -- Accents
    PrimaryAccent = Color3.fromRGB(100, 200, 255),      -- Cyan Blue
    SecondaryAccent = Color3.fromRGB(150, 150, 150),    -- Grey
    SuccessAccent = Color3.fromRGB(100, 220, 140),      -- Green
    WarningAccent = Color3.fromRGB(255, 180, 100),      -- Orange
    ErrorAccent = Color3.fromRGB(255, 120, 120),        -- Red
    
    -- Background
    BackgroundDark = Color3.fromRGB(5, 5, 8),           -- Almost Black
    GlassStroke = Color3.fromRGB(60, 60, 70),           -- Dark Blue-Grey
    
    -- Sizes
    WindowSize = UDim2.new(0, 700, 0, 500),
    ToggleButtonSize = UDim2.new(0, 60, 0, 60),
    
    -- Styling
    BorderRadius = 20,
    SmallRadius = 12,
    TinyRadius = 8,
}

-- Safe GUI container
local function GetSafeContainer()
    local success, result = pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "RussEliteHub"
        sg.ResetOnSpawn = false
        sg.Parent = CoreGui
        return sg
    end)
    if not success then
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        local sg = Instance.new("ScreenGui")
        sg.Name = "RussEliteHub"
        sg.ResetOnSpawn = false
        sg.Parent = playerGui
        return sg
    end
    return result
end

-- Advanced Tween Helper
local function tween(obj, props, dur, style)
    local easingStyle = style or Enum.EasingStyle.Quad
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.35, easingStyle, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- Apply Premium Glass Style
local function applyGlassStyle(frame, isLight)
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.GlassStroke
    stroke.Transparency = 0.6
    stroke.Thickness = 1.5
    stroke.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    corner.Parent = frame
    
    -- Add blur effect visual (semi-transparent layer)
    local blur = Instance.new("UIGradient")
    blur.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200)),
    })
    blur.Transparency = NumberSequence.new(0.95)
    blur.Parent = frame
end

-- Apply Button Style
local function applyButtonStyle(button, isPrimary)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, CONFIG.SmallRadius)
    corner.Parent = button
    
    if isPrimary then
        button.BackgroundColor3 = CONFIG.PrimaryAccent
        button.BackgroundTransparency = 0.15
    else
        button.BackgroundColor3 = CONFIG.GlassLight
        button.BackgroundTransparency = 0.2
    end
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.GlassStroke
    stroke.Transparency = 0.5
    stroke.Thickness = 1
    stroke.Parent = button
end

-- Create Toggle Button (Floating Action Button)
function Gui:CreateToggleButton()
    local btn = Instance.new("TextButton")
    btn.Name = "ToggleButton"
    btn.Size = CONFIG.ToggleButtonSize
    btn.Position = UDim2.new(0.94, -30, 0.08, -30)
    btn.BackgroundColor3 = CONFIG.PrimaryAccent
    btn.BackgroundTransparency = 0.1
    btn.Text = ""
    btn.ZIndex = 100
    btn.Parent = self.Container
    
    -- Apply premium style
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.PrimaryAccent
    stroke.Transparency = 0.4
    stroke.Thickness = 2
    stroke.Parent = btn
    
    -- Icon (RE Badge)
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "RE"
    icon.TextColor3 = CONFIG.TextColor
    icon.TextSize = 24
    icon.Font = Enum.Font.GothamBold
    icon.Parent = btn
    
    -- Glow effect
    local glow = Instance.new("Frame")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.3, 0, 1.3, 0)
    glow.Position = UDim2.new(-0.15, 0, -0.15, 0)
    glow.BackgroundColor3 = CONFIG.PrimaryAccent
    glow.BackgroundTransparency = 0.8
    glow.ZIndex = 0
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = glow
    glow.Parent = btn
    
    -- Hover animation
    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundTransparency = 0.05}, 0.2)
        tween(glow, {BackgroundTransparency = 0.7}, 0.2)
    end)
    
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundTransparency = 0.1}, 0.2)
        tween(glow, {BackgroundTransparency = 0.8}, 0.2)
    end)
    
    return btn
end

-- Create Main Premium Window
function Gui:CreateMainWindow()
    -- Main Container
    local window = Instance.new("Frame")
    window.Name = "MainWindow"
    window.Size = CONFIG.WindowSize
    window.Position = UDim2.new(0.5, -350, 0.5, -250)
    window.BackgroundColor3 = CONFIG.BackgroundDark
    window.BackgroundTransparency = 0.05
    window.Visible = false
    window.ZIndex = 50
    window.Parent = self.Container
    
    applyGlassStyle(window)
    
    -- Decorative Top Gradient Bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 60)
    topBar.BackgroundColor3 = CONFIG.GlassMedium
    topBar.BackgroundTransparency = 0.3
    topBar.Parent = window
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    topCorner.Parent = topBar
    
    -- Gradient effect on top bar
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.PrimaryAccent),
        ColorSequenceKeypoint.new(1, CONFIG.GlassMedium),
    })
    gradient.Rotation = 90
    gradient.Transparency = NumberSequence.new(0.7)
    gradient.Parent = topBar
    
    -- Title Section
    local titleContainer = Instance.new("Frame")
    titleContainer.Size = UDim2.new(1, 0, 0, 60)
    titleContainer.BackgroundTransparency = 1
    titleContainer.Parent = topBar
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0.6, 0, 1, 0)
    titleText.Position = UDim2.new(0.04, 0, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "◆ " .. CONFIG.Title
    titleText.TextColor3 = CONFIG.TextColor
    titleText.TextSize = 28
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleContainer
    
    -- Version Badge
    local versionFrame = Instance.new("Frame")
    versionFrame.Size = UDim2.new(0, 90, 0, 28)
    versionFrame.Position = UDim2.new(0.58, 0, 0.5, -14)
    versionFrame.BackgroundColor3 = CONFIG.PrimaryAccent
    versionFrame.BackgroundTransparency = 0.3
    versionFrame.Parent = titleContainer
    
    local versionCorner = Instance.new("UICorner")
    versionCorner.CornerRadius = UDim.new(0, 8)
    versionCorner.Parent = versionFrame
    
    local versionText = Instance.new("TextLabel")
    versionText.Size = UDim2.new(1, 0, 1, 0)
    versionText.BackgroundTransparency = 1
    versionText.Text = "✨ " .. CONFIG.Version
    versionText.TextColor3 = CONFIG.PrimaryAccent
    versionText.TextSize = 12
    versionText.Font = Enum.Font.GothamBold
    versionText.Parent = versionFrame
    
    -- Close Button (Premium Style)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(0.92, -20, 0.1, -20)
    closeBtn.BackgroundColor3 = CONFIG.ErrorAccent
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = CONFIG.ErrorAccent
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleContainer
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 10)
    closeBtnCorner.Parent = closeBtn
    
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, {BackgroundTransparency = 0.1}, 0.2)
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, {BackgroundTransparency = 0.2}, 0.2)
    end)
    
    -- Search Bar (Premium)
    local searchFrame = Instance.new("Frame")
    searchFrame.Name = "SearchFrame"
    searchFrame.Size = UDim2.new(0.92, 0, 0, 40)
    searchFrame.Position = UDim2.new(0.04, 0, 0, 70)
    searchFrame.BackgroundColor3 = CONFIG.GlassLight
    searchFrame.BackgroundTransparency = 0.3
    searchFrame.Parent = window
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, CONFIG.SmallRadius)
    searchCorner.Parent = searchFrame
    
    local searchStroke = Instance.new("UIStroke")
    searchStroke.Color = CONFIG.GlassStroke
    searchStroke.Transparency = 0.5
    searchStroke.Thickness = 1
    searchStroke.Parent = searchFrame
    
    -- Search Icon
    local searchIcon = Instance.new("TextLabel")
    searchIcon.Size = UDim2.new(0, 40, 1, 0)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Text = "🔎"
    searchIcon.TextColor3 = CONFIG.PrimaryAccent
    searchIcon.TextSize = 18
    searchIcon.Font = Enum.Font.Gotham
    searchIcon.Parent = searchFrame
    
    -- Search Box
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(0.88, 0, 1, 0)
    searchBox.Position = UDim2.new(0.08, 0, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.PlaceholderText = "Search scripts..."
    searchBox.PlaceholderColor3 = CONFIG.TextTertiary
    searchBox.Text = ""
    searchBox.TextColor3 = CONFIG.TextColor
    searchBox.TextSize = 16
    searchBox.Font = Enum.Font.Gotham
    searchBox.Parent = searchFrame
    
    -- Content Area (Main)
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(0.96, 0, 1, -140)
    contentArea.Position = UDim2.new(0.02, 0, 0, 120)
    contentArea.BackgroundColor3 = CONFIG.GlassDark
    contentArea.BackgroundTransparency = 0.4
    contentArea.ClipsDescendants = true
    contentArea.Parent = window
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, CONFIG.SmallRadius)
    contentCorner.Parent = contentArea
    
    local contentStroke = Instance.new("UIStroke")
    contentStroke.Color = CONFIG.GlassStroke
    contentStroke.Transparency = 0.6
    contentStroke.Thickness = 1
    contentStroke.Parent = contentArea
    
    -- Back Button (Hidden by default)
    local backBtn = Instance.new("TextButton")
    backBtn.Name = "BackButton"
    backBtn.Size = UDim2.new(0, 80, 0, 32)
    backBtn.Position = UDim2.new(0.02, 0, 0.02, 0)
    backBtn.BackgroundColor3 = CONFIG.PrimaryAccent
    backBtn.BackgroundTransparency = 0.3
    backBtn.Text = "◀ Back"
    backBtn.TextColor3 = CONFIG.PrimaryAccent
    backBtn.TextSize = 13
    backBtn.Font = Enum.Font.GothamBold
    backBtn.Visible = false
    backBtn.Parent = contentArea
    
    local backBtnCorner = Instance.new("UICorner")
    backBtnCorner.CornerRadius = UDim.new(0, 8)
    backBtnCorner.Parent = backBtn
    
    backBtn.MouseEnter:Connect(function()
        tween(backBtn, {BackgroundTransparency = 0.2}, 0.2)
    end)
    backBtn.MouseLeave:Connect(function()
        tween(backBtn, {BackgroundTransparency = 0.3}, 0.2)
    end)
    
    -- Category Scroll
    local categoryScroll = Instance.new("ScrollingFrame")
    categoryScroll.Name = "CategoryScroll"
    categoryScroll.Size = UDim2.new(1, 0, 1, 0)
    categoryScroll.BackgroundTransparency = 1
    categoryScroll.ScrollBarThickness = 4
    categoryScroll.ScrollBarImageColor3 = CONFIG.PrimaryAccent
    categoryScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    categoryScroll.Parent = contentArea
    
    local categoryGrid = Instance.new("UIGridLayout")
    categoryGrid.CellSize = UDim2.new(0, 140, 0, 100)
    categoryGrid.CellPadding = UDim2.new(0, 10, 0, 10)
    categoryGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    categoryGrid.SortOrder = Enum.SortOrder.Name
    categoryGrid.Parent = categoryScroll
    
    -- Sub-Script Scroll
    local subScroll = Instance.new("ScrollingFrame")
    subScroll.Name = "SubScriptScroll"
    subScroll.Size = UDim2.new(1, 0, 1, -40)
    subScroll.Position = UDim2.new(0, 0, 0, 40)
    subScroll.BackgroundTransparency = 1
    subScroll.ScrollBarThickness = 4
    subScroll.ScrollBarImageColor3 = CONFIG.PrimaryAccent
    subScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    subScroll.Visible = false
    subScroll.Parent = contentArea
    
    local subList = Instance.new("UIListLayout")
    subList.SortOrder = Enum.SortOrder.Name
    subList.Padding = UDim.new(0, 6)
    subList.Parent = subScroll
    
    -- Sub-Title
    local subTitle = Instance.new("TextLabel")
    subTitle.Name = "SubTitle"
    subTitle.Size = UDim2.new(1, 0, 0, 35)
    subTitle.BackgroundTransparency = 1
    subTitle.Text = "Scripts"
    subTitle.TextColor3 = CONFIG.TextColor
    subTitle.TextSize = 18
    subTitle.Font = Enum.Font.GothamBold
    subTitle.Visible = false
    subTitle.Parent = contentArea
    
    -- Status Bar (Bottom)
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, 0, 0, 40)
    statusBar.Position = UDim2.new(0, 0, 1, -40)
    statusBar.BackgroundColor3 = CONFIG.GlassMedium
    statusBar.BackgroundTransparency = 0.3
    statusBar.Parent = window
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    statusCorner.Parent = statusBar
    
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(0.9, 0, 1, 0)
    statusText.Position = UDim2.new(0.05, 0, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "✓ Ready"
    statusText.TextColor3 = CONFIG.SuccessAccent
    statusText.TextSize = 14
    statusText.Font = Enum.Font.Gotham
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusBar
    
    return {
        Window = window,
        TitleBar = topBar,
        CloseButton = closeBtn,
        SearchBox = searchBox,
        CategoryScroll = categoryScroll,
        SubScroll = subScroll,
        SubTitle = subTitle,
        BackButton = backBtn,
        StatusText = statusText,
        ContentArea = contentArea
    }
end

-- Create Category Buttons
function Gui:PopulateCategories(filter)
    if not Database or not Database.categories then
        return
    end
    
    local scroll = self.Elements.CategoryScroll
    
    -- Clear old buttons
    for _, child in pairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local count = 0
    for categoryName, fileName in pairs(Database.categories) do
        if filter == "" or categoryName:lower():find(filter:lower(), 1, true) then
            count = count + 1
            
            local btn = Instance.new("TextButton")
            btn.Name = categoryName
            btn.Size = UDim2.new(1, -10, 0, 90)
            btn.BackgroundColor3 = CONFIG.GlassLight
            btn.BackgroundTransparency = 0.2
            btn.Text = ""
            btn.Parent = scroll
            
            -- Button styling
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, CONFIG.SmallRadius)
            corner.Parent = btn
            
            local stroke = Instance.new("UIStroke")
            stroke.Color = CONFIG.GlassStroke
            stroke.Transparency = 0.5
            stroke.Thickness = 1
            stroke.Parent = btn
            
            -- Icon
            local icon = Instance.new("TextLabel")
            icon.Size = UDim2.new(0, 40, 0, 40)
            icon.Position = UDim2.new(0.5, -20, 0.05, 0)
            icon.BackgroundColor3 = CONFIG.PrimaryAccent
            icon.BackgroundTransparency = 0.4
            icon.Text = "✦"
            icon.TextColor3 = CONFIG.PrimaryAccent
            icon.TextSize = 20
            icon.Font = Enum.Font.GothamBold
            icon.Parent = btn
            
            local iconCorner = Instance.new("UICorner")
            iconCorner.CornerRadius = UDim.new(0, 8)
            iconCorner.Parent = icon
            
            -- Category Name
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -10, 0, 25)
            nameLabel.Position = UDim2.new(0, 5, 0, 48)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = categoryName
            nameLabel.TextColor3 = CONFIG.TextColor
            nameLabel.TextSize = 13
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextWrapped = true
            nameLabel.Parent = btn
            
            -- Hover animation
            btn.MouseEnter:Connect(function()
                tween(btn, {BackgroundTransparency = 0.1}, 0.2)
                tween(icon, {BackgroundTransparency = 0.3}, 0.2)
            end)
            
            btn.MouseLeave:Connect(function()
                tween(btn, {BackgroundTransparency = 0.2}, 0.2)
                tween(icon, {BackgroundTransparency = 0.4}, 0.2)
            end)
            
            -- Click handler
            btn.MouseButton1Click:Connect(function()
                self:OnCategoryClick(categoryName)
            end)
        end
    end
    
    -- Update canvas size
    scroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(count / 4) * 105)
end

-- Load Database
function Gui:LoadDatabase()
    local success, result = pcall(function()
        local source = game:HttpGet(CONFIG.BaseURL)
        local chunk = loadstring(source)
        if chunk then
            return chunk()
        end
    end)
    
    if success and result then
        Database = result
        self:PopulateCategories("")
        self.Elements.StatusText.Text = "✓ Database loaded"
        self.Elements.StatusText.TextColor3 = CONFIG.SuccessAccent
    else
        self.Elements.StatusText.Text = "✗ Failed to load database"
        self.Elements.StatusText.TextColor3 = CONFIG.ErrorAccent
    end
end

-- Populate Sub-Scripts
function Gui:PopulateSubScripts(scripts, categoryName)
    local scroll = self.Elements.SubScroll
    
    -- Clear old buttons
    for _, child in pairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    self.Elements.SubTitle.Text = "📁 " .. categoryName
    
    if not scripts or #scripts == 0 then
        self.Elements.StatusText.Text = "No scripts found"
        self.Elements.StatusText.TextColor3 = CONFIG.TextTertiary
        return
    end
    
    for _, script in ipairs(scripts) do
        if type(script) == "table" and #script >= 2 then
            local scriptName = tostring(script[1])
            local scriptFunc = script[2]
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.98, 0, 0, 45)
            btn.BackgroundColor3 = CONFIG.GlassLight
            btn.BackgroundTransparency = 0.25
            btn.Text = "  ▶ " .. scriptName
            btn.TextColor3 = CONFIG.TextColor
            btn.TextSize = 14
            btn.Font = Enum.Font.Gotham
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = scroll
            
            -- Button styling
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = btn
            
            local stroke = Instance.new("UIStroke")
            stroke.Color = CONFIG.GlassStroke
            stroke.Transparency = 0.5
            stroke.Thickness = 1
            stroke.Parent = btn
            
            -- Hover effects
            btn.MouseEnter:Connect(function()
                tween(btn, {BackgroundTransparency = 0.15}, 0.2)
            end)
            
            btn.MouseLeave:Connect(function()
                tween(btn, {BackgroundTransparency = 0.25}, 0.2)
            end)
            
            -- Click handler
            btn.MouseButton1Click:Connect(function()
                self.Elements.StatusText.Text = "⚙️ Running: " .. scriptName
                self.Elements.StatusText.TextColor3 = CONFIG.WarningAccent
                
                local ok, err = pcall(scriptFunc)
                
                if ok then
                    self.Elements.StatusText.Text = "✓ " .. scriptName .. " executed!"
                    self.Elements.StatusText.TextColor3 = CONFIG.SuccessAccent
                else
                    self.Elements.StatusText.Text = "✗ Error: " .. tostring(err)
                    self.Elements.StatusText.TextColor3 = CONFIG.ErrorAccent
                end
                
                task.delay(4, function()
                    if self.Elements and self.Elements.StatusText then
                        self.Elements.StatusText.Text = "✓ Ready"
                        self.Elements.StatusText.TextColor3 = CONFIG.SuccessAccent
                    end
                end)
            end)
        end
    end
    
    scroll.CanvasSize = UDim2.new(0, 0, 0, #scripts * (45 + 6) + 10)
end

-- Handle Category Click
function Gui:OnCategoryClick(categoryName)
    if not Database or not Database.categories then
        self.Elements.StatusText.Text = "✗ No database loaded!"
        self.Elements.StatusText.TextColor3 = CONFIG.ErrorAccent
        return
    end
    
    local fileName = Database.categories[categoryName]
    if not fileName then
        self.Elements.StatusText.Text = "✗ Category not found!"
        self.Elements.StatusText.TextColor3 = CONFIG.ErrorAccent
        return
    end
    
    local url = Database.baseUrl .. "/" .. fileName
    
    self.Elements.StatusText.Text = "⏳ Loading " .. categoryName .. "..."
    self.Elements.StatusText.TextColor3 = CONFIG.WarningAccent
    
    local success, result = pcall(function()
        local source = game:HttpGet(url)
        local chunk = loadstring(source)
        if chunk then
            return chunk()
        end
    end)
    
    if not success then
        self.Elements.StatusText.Text = "✗ Error: " .. tostring(result)
        self.Elements.StatusText.TextColor3 = CONFIG.ErrorAccent
        return
    end
    
    if type(result) == "table" then
        self.Elements.CategoryScroll.Visible = false
        self.Elements.SubScroll.Visible = true
        self.Elements.SubTitle.Visible = true
        self.Elements.BackButton.Visible = true
        self.Elements.SearchBox.Visible = false
        
        CurrentSubScripts = result
        CurrentCategory = categoryName
        
        self:PopulateSubScripts(result, categoryName)
        self.Elements.StatusText.Text = categoryName .. " loaded! (" .. #result .. " scripts)"
        self.Elements.StatusText.TextColor3 = CONFIG.SuccessAccent
    else
        self.Elements.StatusText.Text = "✓ " .. categoryName .. " executed!"
        self.Elements.StatusText.TextColor3 = CONFIG.SuccessAccent
        task.delay(2, function()
            if self.Elements and self.Elements.StatusText then
                self.Elements.StatusText.Text = "✓ Ready"
            end
        end)
    end
end

-- Back to Categories
function Gui:BackToCategories()
    self.Elements.CategoryScroll.Visible = true
    self.Elements.SubScroll.Visible = false
    self.Elements.SubTitle.Visible = false
    self.Elements.BackButton.Visible = false
    self.Elements.SearchBox.Visible = true
    
    CurrentSubScripts = nil
    CurrentCategory = nil
    
    self.Elements.StatusText.Text = "✓ Ready"
    self.Elements.StatusText.TextColor3 = CONFIG.SuccessAccent
end

-- Toggle Window
function Gui:ToggleWindow()
    local window = self.Elements.Window
    
    if window.Visible then
        -- Hide with animation
        tween(window, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        window.Visible = false
    else
        -- Show with animation
        window.Visible = true
        window.BackgroundTransparency = 1
        tween(window, {BackgroundTransparency = 0.05}, 0.3)
    end
end

-- Make Window Draggable
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

-- Initialize GUI
function Gui:Init()
    self.Container = GetSafeContainer()
    
    -- Create UI elements
    self.Elements = {}
    self.Elements.ToggleButton = self:CreateToggleButton()
    
    local winParts = self:CreateMainWindow()
    for k, v in pairs(winParts) do
        self.Elements[k] = v
    end
    
    -- Event handlers
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
    
    -- Make draggable
    self:MakeDraggable()
    
    -- Load database
    CONFIG.BaseURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/base/base.lua"
    self:LoadDatabase()
    
    print("🎨 RussElite GUI Loaded - Premium 2026 Edition")
end

-- Start
Gui:Init()

return Gui
