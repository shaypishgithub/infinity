-- RussElite Main Interface - gui.lua [2026 Modern Glass Design]
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

-- Configuration - 2026 Modern Glass Aesthetic
local CONFIG = {
    Title = "RussElite",
    Version = "v3.0 • Glass",
    TextColor = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(200, 200, 200),
    Accent = Color3.fromRGB(100, 200, 255),           -- Modern blue
    AccentHover = Color3.fromRGB(120, 220, 255),
    Background = Color3.fromRGB(5, 5, 10),            -- Deep black
    Glass = Color3.fromRGB(25, 30, 45),               -- Dark glass
    GlassLight = Color3.fromRGB(40, 50, 70),          -- Light glass
    StrokeColor = Color3.fromRGB(80, 100, 150),       -- Glass border
    StrokeGlow = Color3.fromRGB(100, 200, 255),       -- Glow color
    WindowSize = UDim2.new(0, 720, 0, 520),
    ToggleButtonSize = UDim2.new(0, 60, 0, 60),
    BorderRadius = 20,
    BaseURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/base/base.lua"
}

-- Safe GUI container
local function GetSafeContainer()
    local success, result = pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "RussEliteHub2026"
        sg.Parent = CoreGui
        return sg
    end)
    if not success then
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        local sg = Instance.new("ScreenGui")
        sg.Name = "RussEliteHub2026"
        sg.Parent = playerGui
        return sg
    end
    return result
end

-- Tween helper with smooth animations
local function tween(obj, props, dur, style)
    local easing = style or Enum.EasingStyle.Quad
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.3, easing, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- Apply modern glass style
local function applyGlassStyle(frame, hasGlow)
    local stroke = Instance.new("UIStroke")
    stroke.Color = hasGlow and CONFIG.StrokeGlow or CONFIG.StrokeColor
    stroke.Transparency = 0.4
    stroke.Thickness = 1.5
    stroke.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    corner.Parent = frame
    
    -- Gradient effect for premium look
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, frame.BackgroundColor3),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(math.max(0, frame.BackgroundColor3.R*255-10)/255, 
                                                   math.max(0, frame.BackgroundColor3.G*255-10)/255, 
                                                   math.max(0, frame.BackgroundColor3.B*255-10)/255))
    })
    gradient.Rotation = 45
    gradient.Parent = frame
end

-- Create premium toggle button (floating action button)
function Gui:CreateToggleButton()
    local btn = Instance.new("TextButton")
    btn.Name = "ToggleButton"
    btn.Size = CONFIG.ToggleButtonSize
    btn.Position = UDim2.new(0.92, 0, 0.5, -30)
    btn.BackgroundColor3 = CONFIG.GlassLight
    btn.BackgroundTransparency = 0.15
    btn.Text = ""
    btn.Parent = self.Container
    btn.ZIndex = 100
    
    applyGlassStyle(btn, true)
    
    -- Icon with animation
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "⚡"
    icon.TextColor3 = CONFIG.Accent
    icon.TextSize = 26
    icon.Font = Enum.Font.GothamBold
    icon.Parent = btn
    
    -- Hover animations
    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundTransparency = 0.25}, 0.2, Enum.EasingStyle.Quad)
        tween(icon, {TextColor3 = CONFIG.AccentHover}, 0.2)
    end)
    
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundTransparency = 0.15}, 0.2, Enum.EasingStyle.Quad)
        tween(icon, {TextColor3 = CONFIG.Accent}, 0.2)
    end)
    
    return btn
end

-- Create modern main window with glass-morphism
function Gui:CreateMainWindow()
    -- Background blur effect (dark overlay)
    local bgOverlay = Instance.new("Frame")
    bgOverlay.Name = "BGOverlay"
    bgOverlay.Size = UDim2.new(1, 0, 1, 0)
    bgOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bgOverlay.BackgroundTransparency = 0.7
    bgOverlay.Visible = false
    bgOverlay.ZIndex = 1
    bgOverlay.Parent = self.Container
    
    -- Main window
    local window = Instance.new("Frame")
    window.Name = "MainWindow"
    window.Size = CONFIG.WindowSize
    window.Position = UDim2.new(0.5, -360, 0.5, -260)
    window.BackgroundColor3 = CONFIG.Glass
    window.BackgroundTransparency = 0.1
    window.Visible = false
    window.ZIndex = 50
    window.Parent = self.Container
    
    applyGlassStyle(window)
    
    -- Premium header with gradient
    local headerBg = Instance.new("Frame")
    headerBg.Size = UDim2.new(1, 0, 0, 60)
    headerBg.BackgroundColor3 = CONFIG.GlassLight
    headerBg.BackgroundTransparency = 0.05
    headerBg.Parent = window
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    headerCorner.Parent = headerBg
    
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.Accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 140, 200))
    })
    headerGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(1, 0.95)
    })
    headerGradient.Rotation = 45
    headerGradient.Parent = headerBg
    
    -- Title
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0.6, 0, 1, 0)
    titleText.Position = UDim2.new(0.05, 0, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = CONFIG.Title
    titleText.TextColor3 = CONFIG.TextColor
    titleText.TextSize = 28
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = headerBg
    
    -- Version badge
    local versionBadge = Instance.new("Frame")
    versionBadge.Size = UDim2.new(0, 140, 0, 24)
    versionBadge.Position = UDim2.new(0.6, 0, 0.5, -12)
    versionBadge.BackgroundColor3 = CONFIG.Accent
    versionBadge.BackgroundTransparency = 0.3
    versionBadge.Parent = headerBg
    
    local versionCorner = Instance.new("UICorner")
    versionCorner.CornerRadius = UDim.new(0, 6)
    versionCorner.Parent = versionBadge
    
    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(1, 0, 1, 0)
    version.BackgroundTransparency = 1
    version.Text = CONFIG.Version
    version.TextColor3 = CONFIG.TextColor
    version.TextSize = 11
    version.Font = Enum.Font.GothamSemibold
    version.Parent = versionBadge
    
    -- Close button (modern X)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 36, 0, 36)
    closeBtn.Position = UDim2.new(0.93, 0, 0.5, -18)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = CONFIG.TextColor
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = 51
    closeBtn.Parent = headerBg
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 8)
    closeBtnCorner.Parent = closeBtn
    
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, {BackgroundTransparency = 0.1}, 0.2)
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, {BackgroundTransparency = 0.3}, 0.2)
    end)
    
    -- Premium search bar
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(0.93, 0, 0, 40)
    searchFrame.Position = UDim2.new(0.035, 0, 0, 72)
    searchFrame.BackgroundColor3 = CONFIG.GlassLight
    searchFrame.BackgroundTransparency = 0.2
    searchFrame.Parent = window
    
    applyGlassStyle(searchFrame, false)
    
    local searchIcon = Instance.new("TextLabel")
    searchIcon.Size = UDim2.new(0, 36, 1, 0)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Text = "🔎"
    searchIcon.TextColor3 = CONFIG.Accent
    searchIcon.TextSize = 16
    searchIcon.Font = Enum.Font.GothamBold
    searchIcon.Parent = searchFrame
    
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, -50, 1, 0)
    searchBox.Position = UDim2.new(0, 36, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.PlaceholderText = "Search scripts..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 180)
    searchBox.Text = ""
    searchBox.TextColor3 = CONFIG.TextColor
    searchBox.TextSize = 14
    searchBox.Font = Enum.Font.Gotham
    searchBox.Parent = searchFrame
    
    -- Content area with glass effect
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(0.93, 0, 1, -140)
    contentArea.Position = UDim2.new(0.035, 0, 0, 125)
    contentArea.BackgroundColor3 = CONFIG.Glass
    contentArea.BackgroundTransparency = 0.15
    contentArea.ClipsDescendants = true
    contentArea.Parent = window
    
    applyGlassStyle(contentArea, false)
    
    -- Back button (modern style)
    local backBtn = Instance.new("TextButton")
    backBtn.Name = "BackButton"
    backBtn.Size = UDim2.new(0, 90, 0, 28)
    backBtn.Position = UDim2.new(0.015, 0, 0.01, 0)
    backBtn.BackgroundColor3 = CONFIG.Accent
    backBtn.BackgroundTransparency = 0.4
    backBtn.Text = "← Back"
    backBtn.TextColor3 = CONFIG.TextColor
    backBtn.TextSize = 13
    backBtn.Font = Enum.Font.GothamBold
    backBtn.Visible = false
    backBtn.ZIndex = 51
    backBtn.Parent = contentArea
    
    local backBtnCorner = Instance.new("UICorner")
    backBtnCorner.CornerRadius = UDim.new(0, 8)
    backBtnCorner.Parent = backBtn
    
    backBtn.MouseEnter:Connect(function()
        tween(backBtn, {BackgroundTransparency = 0.2}, 0.2)
    end)
    backBtn.MouseLeave:Connect(function()
        tween(backBtn, {BackgroundTransparency = 0.4}, 0.2)
    end)
    
    -- Category scroll view
    local categoryScroll = Instance.new("ScrollingFrame")
    categoryScroll.Name = "CategoryScroll"
    categoryScroll.Size = UDim2.new(1, 0, 1, 0)
    categoryScroll.BackgroundTransparency = 1
    categoryScroll.ScrollBarThickness = 5
    categoryScroll.ScrollBarImageColor3 = CONFIG.Accent
    categoryScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    categoryScroll.Parent = contentArea
    
    local categoryGrid = Instance.new("UIGridLayout")
    categoryGrid.CellSize = UDim2.new(0, 140, 0, 110)
    categoryGrid.CellPadding = UDim2.new(0, 10, 0, 10)
    categoryGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    categoryGrid.VerticalAlignment = Enum.VerticalAlignment.Top
    categoryGrid.SortOrder = Enum.SortOrder.Name
    categoryGrid.Parent = categoryScroll
    
    -- Sub-script scroll view
    local subScroll = Instance.new("ScrollingFrame")
    subScroll.Name = "SubScriptScroll"
    subScroll.Size = UDim2.new(1, 0, 1, -40)
    subScroll.Position = UDim2.new(0, 0, 0, 40)
    subScroll.BackgroundTransparency = 1
    subScroll.ScrollBarThickness = 5
    subScroll.ScrollBarImageColor3 = CONFIG.Accent
    subScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    subScroll.Visible = false
    subScroll.Parent = contentArea
    
    local subList = Instance.new("UIListLayout")
    subList.SortOrder = Enum.SortOrder.Name
    subList.Padding = UDim.new(0, 8)
    subList.Parent = subScroll
    
    -- Sub-title
    local subTitle = Instance.new("TextLabel")
    subTitle.Name = "SubTitle"
    subTitle.Size = UDim2.new(1, 0, 0, 35)
    subTitle.BackgroundTransparency = 1
    subTitle.Text = ""
    subTitle.TextColor3 = CONFIG.Accent
    subTitle.TextSize = 18
    subTitle.Font = Enum.Font.GothamBold
    subTitle.Visible = false
    subTitle.ZIndex = 51
    subTitle.Parent = contentArea
    
    -- Status bar (modern design)
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, 0, 0, 45)
    statusBar.Position = UDim2.new(0, 0, 1, -45)
    statusBar.BackgroundColor3 = CONFIG.GlassLight
    statusBar.BackgroundTransparency = 0.1
    statusBar.Parent = window
    
    local statusBarCorner = Instance.new("UICorner")
    statusBarCorner.CornerRadius = UDim.new(0, 10)
    statusBarCorner.Parent = statusBar
    
    -- Status indicator dot
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 12, 0, 12)
    statusDot.Position = UDim2.new(0.03, 0, 0.5, -6)
    statusDot.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    statusDot.Parent = statusBar
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = statusDot
    
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(0.9, -30, 1, 0)
    statusText.Position = UDim2.new(0.08, 0, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Ready • Loaded"
    statusText.TextColor3 = CONFIG.TextSecondary
    statusText.TextSize = 13
    statusText.Font = Enum.Font.Gotham
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusBar
    
    return {
        Container = self.Container,
        BGOverlay = bgOverlay,
        Window = window,
        TitleBar = headerBg,
        CloseButton = closeBtn,
        SearchBox = searchBox,
        ContentArea = contentArea,
        CategoryScroll = categoryScroll,
        SubScroll = subScroll,
        SubTitle = subTitle,
        BackButton = backBtn,
        StatusText = statusText,
        StatusDot = statusDot
    }
end

-- Populate categories with modern cards
function Gui:PopulateCategories(searchText)
    if not Database or not Database.categories then return end
    
    local scroll = self.Elements.CategoryScroll
    
    -- Clear existing
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local count = 0
    for categoryName, _ in pairs(Database.categories) do
        if not searchText or categoryName:lower():find(searchText:lower(), 1, true) then
            count = count + 1
            
            local card = Instance.new("Frame")
            card.Name = categoryName
            card.Size = UDim2.new(0, 135, 0, 105)
            card.BackgroundColor3 = CONFIG.GlassLight
            card.BackgroundTransparency = 0.25
            card.Parent = scroll
            
            applyGlassStyle(card, false)
            
            -- Card content
            local inner = Instance.new("Frame")
            inner.Size = UDim2.new(1, -2, 1, -2)
            inner.Position = UDim2.new(0, 1, 0, 1)
            inner.BackgroundTransparency = 1
            inner.Parent = card
            
            -- Icon/Emoji
            local icon = Instance.new("TextLabel")
            icon.Size = UDim2.new(1, 0, 0, 40)
            icon.BackgroundTransparency = 1
            icon.Text = "📦"
            icon.TextColor3 = CONFIG.Accent
            icon.TextSize = 32
            icon.Font = Enum.Font.GothamBold
            icon.Parent = inner
            
            -- Category name
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 30)
            label.Position = UDim2.new(0, 0, 0, 45)
            label.BackgroundTransparency = 1
            label.Text = categoryName
            label.TextColor3 = CONFIG.TextColor
            label.TextSize = 12
            label.Font = Enum.Font.GothamSemibold
            label.TextWrapped = true
            label.Parent = inner
            
            -- Click effect
            local clickableBtn = Instance.new("TextButton")
            clickableBtn.Size = UDim2.new(1, 0, 1, 0)
            clickableBtn.BackgroundTransparency = 1
            clickableBtn.Text = ""
            clickableBtn.Parent = card
            
            -- Hover animations
            local originalTransparency = card.BackgroundTransparency
            
            clickableBtn.MouseEnter:Connect(function()
                tween(card, {BackgroundTransparency = 0.1}, 0.2)
                tween(icon, {TextColor3 = CONFIG.AccentHover}, 0.2)
                tween(card, {Size = UDim2.new(0, 145, 0, 115)}, 0.2)
            end)
            
            clickableBtn.MouseLeave:Connect(function()
                tween(card, {BackgroundTransparency = 0.25}, 0.2)
                tween(icon, {TextColor3 = CONFIG.Accent}, 0.2)
                tween(card, {Size = UDim2.new(0, 135, 0, 105)}, 0.2)
            end)
            
            clickableBtn.MouseButton1Click:Connect(function()
                self:OnCategoryClick(categoryName)
            end)
        end
    end
    
    scroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(count / 4) * 125)
end

-- Populate sub-scripts
function Gui:PopulateSubScripts(scripts, categoryName)
    if not scripts or #scripts == 0 then return end
    
    local scroll = self.Elements.SubScroll
    
    -- Clear existing
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    self.Elements.SubTitle.Text = "📂 " .. categoryName
    
    for i, script in ipairs(scripts) do
        if type(script) == "table" and #script >= 2 then
            local scriptName = tostring(script[1])
            local scriptFunc = script[2]
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.96, 0, 0, 42)
            btn.BackgroundColor3 = CONFIG.GlassLight
            btn.BackgroundTransparency = 0.2
            btn.Text = "  ⚙️  " .. scriptName
            btn.TextColor3 = CONFIG.TextColor
            btn.TextSize = 13
            btn.Font = Enum.Font.Gotham
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = scroll
            
            applyGlassStyle(btn, false)
            
            -- Arrow
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
                self.Elements.StatusText.Text = "▶ Running: " .. scriptName
                self.Elements.StatusDot.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
                
                local success, err = pcall(scriptFunc)
                
                if success then
                    self.Elements.StatusText.Text = "✓ " .. scriptName .. " executed!"
                    self.Elements.StatusDot.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
                else
                    self.Elements.StatusText.Text = "✗ Error: " .. tostring(err)
                    self.Elements.StatusDot.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                end
                
                task.delay(4, function()
                    self.Elements.StatusText.Text = "Ready • Loaded"
                    self.Elements.StatusDot.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
                end)
            end)
            
            -- Hover effects
            btn.MouseEnter:Connect(function()
                tween(btn, {BackgroundTransparency = 0.05}, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                tween(btn, {BackgroundTransparency = 0.2}, 0.15)
            end)
        end
    end
    
    scroll.CanvasSize = UDim2.new(0, 0, 0, #scripts * (42 + 8) + 10)
end

-- Handle category click
function Gui:OnCategoryClick(categoryName)
    if not Database or not Database.categories then
        self.Elements.StatusText.Text = "✗ No database loaded!"
        self.Elements.StatusDot.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    local fileName = Database.categories[categoryName]
    if not fileName then
        self.Elements.StatusText.Text = "✗ Category not found!"
        return
    end
    
    local url = Database.baseUrl .. "/" .. fileName
    
    self.Elements.StatusText.Text = "⏳ Loading " .. categoryName .. "..."
    self.Elements.StatusDot.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
    
    local success, result = pcall(function()
        local source = game:HttpGet(url)
        local chunk = loadstring(source)
        if chunk then
            return chunk()
        end
    end)
    
    if not success then
        self.Elements.StatusText.Text = "✗ Error: " .. tostring(result)
        self.Elements.StatusDot.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
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
        self.Elements.StatusText.Text = "✓ " .. categoryName .. " loaded! (" .. #result .. " scripts)"
        self.Elements.StatusDot.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    else
        self.Elements.StatusText.Text = "✓ " .. categoryName .. " executed!"
        self.Elements.StatusDot.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        task.delay(3, function()
            self.Elements.StatusText.Text = "Ready • Loaded"
        end)
    end
end

-- Back to categories
function Gui:BackToCategories()
    self.Elements.CategoryScroll.Visible = true
    self.Elements.SubScroll.Visible = false
    self.Elements.SubTitle.Visible = false
    self.Elements.BackButton.Visible = false
    self.Elements.SearchBox.Visible = true
    
    CurrentSubScripts = nil
    CurrentCategory = nil
    
    self.Elements.StatusText.Text = "Ready • Loaded"
    self.Elements.StatusDot.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
end

-- Toggle window with smooth animations
function Gui:ToggleWindow()
    local window = self.Elements.Window
    local overlay = self.Elements.BGOverlay
    
    if window.Visible then
        -- Hide with animation
        tween(window, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quad)
        tween(overlay, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quad)
        
        task.wait(0.3)
        window.Visible = false
        overlay.Visible = false
    else
        -- Show with animation
        overlay.Visible = true
        overlay.BackgroundTransparency = 1
        window.Visible = true
        window.BackgroundTransparency = 1
        
        tween(window, {BackgroundTransparency = 0.1}, 0.3, Enum.EasingStyle.Quad)
        tween(overlay, {BackgroundTransparency = 0.7}, 0.3, Enum.EasingStyle.Quad)
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
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Load database
function Gui:LoadDatabase()
    local success, result = pcall(function()
        local baseSource = game:HttpGet(CONFIG.BaseURL)
        local baseChunk = loadstring(baseSource)
        if baseChunk then
            return baseChunk()
        end
    end)
    
    if success and type(result) == "table" then
        Database = result
        self:PopulateCategories("")
        self.Elements.StatusText.Text = "✓ Database loaded!"
    else
        self.Elements.StatusText.Text = "✗ Failed to load database"
        self.Elements.StatusDot.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    end
end

-- Initialize GUI
function Gui:Init()
    self.Container = GetSafeContainer()
    
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
    
    self.Elements.BGOverlay.MouseButton1Click:Connect(function()
        self:ToggleWindow()
    end)
    
    self.Elements.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if self.Elements.CategoryScroll.Visible then
            self:PopulateCategories(self.Elements.SearchBox.Text)
        end
    end)
    
    self:MakeDraggable()
    self:LoadDatabase()
end

-- Start
Gui:Init()
