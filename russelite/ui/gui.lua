-- RussElite Main Interface - gui.lua
-- Premium Glassmorphism UI with Russian Empire Flag Toggle

local Gui = {}
local Database = nil

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Color Palette (Imperial Russian theme)
local COLORS = {
    ImperialGold = Color3.fromRGB(218, 165, 32),      -- Золотой
    ImperialBlack = Color3.fromRGB(10, 10, 10),        -- Чёрный
    ImperialWhite = Color3.fromRGB(240, 240, 240),      -- Белый
    ImperialRed = Color3.fromRGB(180, 30, 30),          -- Красный (флаг)
    ImperialBlue = Color3.fromRGB(30, 60, 180),         -- Синий (флаг)
    GlassBg = Color3.fromRGB(20, 20, 25),               -- Стеклянный фон
    GlassStroke = Color3.fromRGB(255, 255, 255),        -- Белая обводка
    Shadow = Color3.fromRGB(0, 0, 0),                   -- Тень
    Accent = Color3.fromRGB(200, 160, 40),              -- Золотой акцент
    Success = Color3.fromRGB(100, 200, 100),
    Error = Color3.fromRGB(255, 100, 100)
}

-- Configuration
local CONFIG = {
    Title = "RussElite",
    Subtitle = "Имперский Хаб",
    Version = "v3.0 Imperial",
    WindowSize = UDim2.new(0, 650, 0, 460),
    ToggleSize = UDim2.new(0, 60, 0, 60),
    GlassTransparency = 0.25,
    StrokeTransparency = 0.7,
    BorderRadius = 16,
    BaseURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/base/base.lua"
}

-- Safe container
local function GetContainer()
    local s, r = pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "RussEliteImperial"
        sg.Parent = CoreGui
        sg.ResetOnSpawn = false
        return sg
    end)
    if s then return r end
    local plr = Players.LocalPlayer
    if plr then
        local pg = plr:FindFirstChild("PlayerGui")
        if pg then
            local sg = Instance.new("ScreenGui")
            sg.Name = "RussEliteImperial"
            sg.Parent = pg
            sg.ResetOnSpawn = false
            return sg
        end
    end
    return nil
end

-- Tween utility
local function createTween(obj, props, duration, easing)
    return TweenService:Create(obj, TweenInfo.new(duration or 0.35, easing or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
end

-- Apply glass effect to any frame
local function applyGlass(frame, customRadius)
    -- Drop shadow (глубокая тень)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 24, 1, 24)
    shadow.Position = UDim2.new(0, -12, 0, -12)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = COLORS.Shadow
    shadow.ImageTransparency = 0.4
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 49, 49)
    shadow.ZIndex = 0
    shadow.Parent = frame
    
    -- Glass border (стеклянная обводка)
    local stroke = Instance.new("UIStroke")
    stroke.Name = "GlassStroke"
    stroke.Color = COLORS.GlassStroke
    stroke.Transparency = CONFIG.StrokeTransparency
    stroke.Thickness = 1.5
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = frame
    
    -- Inner glow gradient
    local gradient = Instance.new("UIGradient")
    gradient.Name = "GlassGradient"
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 200, 220)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(0.3, 0.92),
        NumberSequenceKeypoint.new(0.7, 0.92),
        NumberSequenceKeypoint.new(1, 0.85)
    })
    gradient.Rotation = 135
    gradient.Parent = stroke
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.Name = "GlassCorner"
    corner.CornerRadius = UDim.new(0, customRadius or CONFIG.BorderRadius)
    corner.Parent = frame
    
    return shadow, stroke, gradient, corner
end

-- Create Russian Empire Flag for toggle button
local function createImperialFlag(parent, size)
    local flag = Instance.new("Frame")
    flag.Name = "ImperialFlag"
    flag.Size = UDim2.new(1, 0, 1, 0)
    flag.BackgroundTransparency = 1
    flag.Parent = parent
    
    -- Three stripes: Black-Yellow-White (Russian Empire flag)
    local stripeHeight = 1/3
    
    -- Top: Black
    local blackStripe = Instance.new("Frame")
    blackStripe.Size = UDim2.new(1, 0, stripeHeight, 0)
    blackStripe.Position = UDim2.new(0, 0, 0, 0)
    blackStripe.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blackStripe.BorderSizePixel = 0
    blackStripe.Parent = flag
    
    -- Middle: Gold/Yellow
    local goldStripe = Instance.new("Frame")
    goldStripe.Size = UDim2.new(1, 0, stripeHeight, 0)
    goldStripe.Position = UDim2.new(0, 0, stripeHeight, 0)
    goldStripe.BackgroundColor3 = Color3.fromRGB(218, 165, 32)
    goldStripe.BorderSizePixel = 0
    goldStripe.Parent = flag
    
    -- Bottom: White
    local whiteStripe = Instance.new("Frame")
    whiteStripe.Size = UDim2.new(1, 0, stripeHeight, 0)
    whiteStripe.Position = UDim2.new(0, 0, stripeHeight * 2, 0)
    whiteStripe.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    whiteStripe.BorderSizePixel = 0
    whiteStripe.Parent = flag
    
    -- Imperial Eagle (текстовый символ)
    local eagle = Instance.new("TextLabel")
    eagle.Size = UDim2.new(0.6, 0, 0.5, 0)
    eagle.Position = UDim2.new(0.2, 0, 0.25, 0)
    eagle.BackgroundTransparency = 1
    eagle.Text = "👑"
    eagle.TextSize = size and size * 0.5 or 14
    eagle.Font = Enum.Font.GothamBold
    eagle.TextColor3 = Color3.fromRGB(255, 215, 0)
    eagle.ZIndex = 5
    eagle.Parent = flag
    
    -- Crown icon
    local crown = Instance.new("TextLabel")
    crown.Size = UDim2.new(0.4, 0, 0.3, 0)
    crown.Position = UDim2.new(0.3, 0, 0, 0)
    crown.BackgroundTransparency = 1
    crown.Text = "♛"
    crown.TextSize = size and size * 0.35 or 12
    crown.Font = Enum.Font.GothamBold
    crown.TextColor3 = Color3.fromRGB(255, 215, 0)
    crown.ZIndex = 6
    crown.Parent = flag
    
    return flag
end

-- Create Toggle Button with Imperial Flag
function Gui:CreateToggle()
    local btn = Instance.new("TextButton")
    btn.Name = "ImperialToggle"
    btn.Size = CONFIG.ToggleSize
    btn.Position = UDim2.new(0.94, -30, 0.5, -30)
    btn.BackgroundColor3 = COLORS.GlassBg
    btn.BackgroundTransparency = CONFIG.GlassTransparency
    btn.Text = ""
    btn.Parent = self.Container
    btn.ZIndex = 10
    
    applyGlass(btn, 50)
    btn.Shadow.ImageTransparency = 0.3
    btn.GlassStroke.Thickness = 2
    btn.GlassStroke.Transparency = 0.5
    
    -- Make it round
    btn.GlassCorner.CornerRadius = UDim.new(1, 0)
    
    -- Imperial Flag inside button
    local flagFrame = Instance.new("Frame")
    flagFrame.Size = UDim2.new(0.75, 0, 0.75, 0)
    flagFrame.Position = UDim2.new(0.125, 0, 0.125, 0)
    flagFrame.BackgroundTransparency = 1
    flagFrame.ZIndex = 11
    flagFrame.Parent = btn
    
    local flagCorner = Instance.new("UICorner")
    flagCorner.CornerRadius = UDim.new(1, 0)
    flagCorner.Parent = flagFrame
    
    createImperialFlag(flagFrame, 24)
    
    -- Glow ring around button
    local glowRing = Instance.new("UIStroke")
    glowRing.Color = COLORS.ImperialGold
    glowRing.Transparency = 0.6
    glowRing.Thickness = 2
    glowRing.LineJoinMode = Enum.LineJoinMode.Round
    glowRing.Parent = btn
    
    return btn
end

-- Create Main Window
function Gui:CreateWindow()
    local window = Instance.new("Frame")
    window.Name = "MainWindow"
    window.Size = CONFIG.WindowSize
    window.Position = UDim2.new(0.5, -325, 0.5, -230)
    window.BackgroundColor3 = COLORS.GlassBg
    window.BackgroundTransparency = CONFIG.GlassTransparency
    window.Visible = false
    window.ClipsDescendants = false
    window.Parent = self.Container
    window.ZIndex = 20
    
    applyGlass(window)
    window.Shadow.ImageTransparency = 0.25
    window.GlassStroke.Thickness = 2
    window.GlassStroke.Transparency = 0.6
    
    -- Top glass accent line
    local topAccent = Instance.new("Frame")
    topAccent.Size = UDim2.new(1, -20, 0, 2)
    topAccent.Position = UDim2.new(0, 10, 0, 2)
    topAccent.BackgroundColor3 = COLORS.ImperialGold
    topAccent.BackgroundTransparency = 0.3
    topAccent.BorderSizePixel = 0
    topAccent.ZIndex = 25
    topAccent.Parent = window
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(1, 0)
    accentCorner.Parent = topAccent
    
    -- Title Bar with imperial style
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = COLORS.GlassBg
    titleBar.BackgroundTransparency = 0.4
    titleBar.Parent = window
    titleBar.ZIndex = 21
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    titleCorner.Parent = titleBar
    
    -- Imperial Eagle icon in title
    local eagleIcon = Instance.new("TextLabel")
    eagleIcon.Size = UDim2.new(0, 35, 0, 35)
    eagleIcon.Position = UDim2.new(0.015, 0, 0.15, 0)
    eagleIcon.BackgroundTransparency = 1
    eagleIcon.Text = "👑"
    eagleIcon.TextSize = 24
    eagleIcon.Font = Enum.Font.GothamBold
    eagleIcon.ZIndex = 25
    eagleIcon.Parent = titleBar
    
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0, 180, 0, 30)
    titleText.Position = UDim2.new(0.07, 0, 0.2, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = CONFIG.Title
    titleText.TextColor3 = COLORS.ImperialWhite
    titleText.TextSize = 22
    titleText.Font = Enum.Font.GothamBlack
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.ZIndex = 25
    titleText.Parent = titleBar
    
    -- Gold underline for title
    local titleUnderline = Instance.new("Frame")
    titleUnderline.Size = UDim2.new(0, 140, 0, 2)
    titleUnderline.Position = UDim2.new(0.07, 0, 0.75, 0)
    titleUnderline.BackgroundColor3 = COLORS.ImperialGold
    titleUnderline.BackgroundTransparency = 0.4
    titleUnderline.BorderSizePixel = 0
    titleUnderline.ZIndex = 25
    titleUnderline.Parent = titleBar
    
    -- Version badge
    local versionBadge = Instance.new("TextLabel")
    versionBadge.Size = UDim2.new(0, 100, 0, 20)
    versionBadge.Position = UDim2.new(0.35, 0, 0.45, 0)
    versionBadge.BackgroundColor3 = COLORS.ImperialGold
    versionBadge.BackgroundTransparency = 0.7
    versionBadge.Text = CONFIG.Version
    versionBadge.TextColor3 = COLORS.ImperialWhite
    versionBadge.TextSize = 10
    versionBadge.Font = Enum.Font.GothamBold
    versionBadge.ZIndex = 25
    versionBadge.Parent = titleBar
    
    local versionCorner = Instance.new("UICorner")
    versionCorner.CornerRadius = UDim.new(0, 8)
    versionCorner.Parent = versionBadge
    
    -- Close button (golden)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(0.93, 0, 0.18, 0)
    closeBtn.BackgroundColor3 = COLORS.ImperialGold
    closeBtn.BackgroundTransparency = 0.5
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = COLORS.ImperialWhite
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = 30
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeBtn
    
    -- Close button glow
    local closeGlow = Instance.new("UIStroke")
    closeGlow.Color = COLORS.ImperialGold
    closeGlow.Transparency = 0.3
    closeGlow.Thickness = 1.5
    closeGlow.Parent = closeBtn
    
    -- Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(0.96, 0, 1, -100)
    contentArea.Position = UDim2.new(0.02, 0, 0, 60)
    contentArea.BackgroundColor3 = COLORS.GlassBg
    contentArea.BackgroundTransparency = 0.5
    contentArea.ClipsDescendants = true
    contentArea.ZIndex = 22
    contentArea.Parent = window
    
    applyGlass(contentArea, 14)
    
    -- Back button
    local backBtn = Instance.new("TextButton")
    backBtn.Name = "BackBtn"
    backBtn.Size = UDim2.new(0, 80, 0, 28)
    backBtn.Position = UDim2.new(0.01, 0, 0.01, 0)
    backBtn.BackgroundColor3 = COLORS.ImperialGold
    backBtn.BackgroundTransparency = 0.5
    backBtn.Text = "◀ Назад"
    backBtn.TextColor3 = COLORS.ImperialWhite
    backBtn.TextSize = 12
    backBtn.Font = Enum.Font.GothamBold
    backBtn.Visible = false
    backBtn.ZIndex = 30
    backBtn.Parent = contentArea
    
    local backCorner = Instance.new("UICorner")
    backCorner.CornerRadius = UDim.new(0, 10)
    backCorner.Parent = backBtn
    
    -- Category Scroll
    local categoryScroll = Instance.new("ScrollingFrame")
    categoryScroll.Name = "CategoryScroll"
    categoryScroll.Size = UDim2.new(1, 0, 1, 0)
    categoryScroll.BackgroundTransparency = 1
    categoryScroll.ScrollBarThickness = 4
    categoryScroll.ScrollBarImageColor3 = COLORS.ImperialGold
    categoryScroll.ScrollBarImageTransparency = 0.5
    categoryScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    categoryScroll.ZIndex = 23
    categoryScroll.Parent = contentArea
    
    local categoryGrid = Instance.new("UIGridLayout")
    categoryGrid.Name = "CategoryGrid"
    categoryGrid.CellSize = UDim2.new(0, 140, 0, 95)
    categoryGrid.CellPadding = UDim2.new(0, 10, 0, 10)
    categoryGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    categoryGrid.SortOrder = Enum.SortOrder.Name
    categoryGrid.Parent = categoryScroll
    
    -- Sub-script Scroll
    local subScroll = Instance.new("ScrollingFrame")
    subScroll.Name = "SubScroll"
    subScroll.Size = UDim2.new(1, 0, 1, -36)
    subScroll.Position = UDim2.new(0, 0, 0, 36)
    subScroll.BackgroundTransparency = 1
    subScroll.ScrollBarThickness = 4
    subScroll.ScrollBarImageColor3 = COLORS.ImperialGold
    subScroll.ScrollBarImageTransparency = 0.5
    subScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    subScroll.Visible = false
    subScroll.ZIndex = 23
    subScroll.Parent = contentArea
    
    local subList = Instance.new("UIListLayout")
    subList.SortOrder = Enum.SortOrder.Name
    subList.Padding = UDim.new(0, 8)
    subList.Parent = subScroll
    
    -- Sub-script title
    local subTitle = Instance.new("TextLabel")
    subTitle.Name = "SubTitle"
    subTitle.Size = UDim2.new(1, 0, 0, 30)
    subTitle.Position = UDim2.new(0.01, 0, 0.01, 0)
    subTitle.BackgroundTransparency = 1
    subTitle.Text = ""
    subTitle.TextColor3 = COLORS.ImperialWhite
    subTitle.TextSize = 16
    subTitle.Font = Enum.Font.GothamBold
    subTitle.TextXAlignment = Enum.TextXAlignment.Left
    subTitle.Visible = false
    subTitle.ZIndex = 30
    subTitle.Parent = contentArea
    
    -- Status Bar
    local statusBar = Instance.new("Frame")
    statusBar.Name = "StatusBar"
    statusBar.Size = UDim2.new(0.96, 0, 0, 28)
    statusBar.Position = UDim2.new(0.02, 0, 0.94, -28)
    statusBar.BackgroundColor3 = COLORS.GlassBg
    statusBar.BackgroundTransparency = 0.4
    statusBar.ZIndex = 22
    statusBar.Parent = window
    
    applyGlass(statusBar, 10)
    
    -- Status indicator dot
    local statusDot = Instance.new("Frame")
    statusDot.Name = "StatusDot"
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(0.02, 0, 0.35, 0)
    statusDot.BackgroundColor3 = COLORS.ImperialGold
    statusDot.BorderSizePixel = 0
    statusDot.ZIndex = 25
    statusDot.Parent = statusBar
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = statusDot
    
    -- Pulsing animation for status dot
    coroutine.wrap(function()
        while statusDot and statusDot.Parent do
            for _, t in ipairs({0.3, 0.7}) do
                if not statusDot.Parent then break end
                createTween(statusDot, {BackgroundTransparency = t}, 0.8):Play()
                task.wait(0.8)
            end
        end
    end)()
    
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(0.85, 0, 1, 0)
    statusText.Position = UDim2.new(0.06, 0, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Готов к работе"
    statusText.TextColor3 = COLORS.ImperialWhite
    statusText.TextSize = 12
    statusText.Font = Enum.Font.Gotham
    statusText.TextTransparency = 0.3
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.ZIndex = 25
    statusText.Parent = statusBar
    
    return {
        Window = window,
        TitleBar = titleBar,
        CloseButton = closeBtn,
        ContentArea = contentArea,
        BackButton = backBtn,
        CategoryScroll = categoryScroll,
        CategoryGrid = categoryGrid,
        SubScroll = subScroll,
        SubList = subList,
        SubTitle = subTitle,
        StatusBar = statusBar,
        StatusDot = statusDot,
        StatusText = statusText,
        TopAccent = topAccent
    }
end

-- Populate categories with glass cards
function Gui:PopulateCategories(filter)
    local scroll = self.Elements.CategoryScroll
    local grid = self.Elements.CategoryGrid
    
    -- Clear
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    if not Database or not Database.categories then return end
    
    local search = (filter or ""):lower()
    local cats = {}
    for name in pairs(Database.categories) do table.insert(cats, name) end
    table.sort(cats)
    
    local count = 0
    local cols = math.max(1, math.floor(scroll.AbsoluteSize.X / (140 + 10)))
    
    for _, name in ipairs(cats) do
        if search == "" or name:lower():find(search, 1, true) then
            local card = Instance.new("Frame")
            card.Name = name
            card.Size = UDim2.new(0, 140, 0, 95)
            card.BackgroundColor3 = COLORS.GlassBg
            card.BackgroundTransparency = CONFIG.GlassTransparency + 0.1
            card.ZIndex = 23
            card.Parent = scroll
            
            applyGlass(card, 14)
            card.Shadow.ImageTransparency = 0.35
            
            -- Game Icon
            local iconId = Database.imageIds and Database.imageIds[name]
            if iconId then
                local icon = Instance.new("ImageLabel")
                icon.Size = UDim2.new(0, 50, 0, 50)
                icon.Position = UDim2.new(0.5, -25, 0.05, 0)
                icon.BackgroundTransparency = 1
                icon.Image = iconId
                icon.ScaleType = Enum.ScaleType.Fit
                icon.ZIndex = 24
                icon.Parent = card
                
                -- Icon glow
                local iconGlow = Instance.new("UIStroke")
                iconGlow.Color = COLORS.ImperialGold
                iconGlow.Transparency = 0.7
                iconGlow.Thickness = 1
                iconGlow.Parent = icon
            end
            
            -- Label
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -8, 0, 22)
            label.Position = UDim2.new(0, 4, 0, 63)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = COLORS.ImperialWhite
            label.TextSize = 12
            label.Font = Enum.Font.GothamBold
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.ZIndex = 24
            label.Parent = card
            
            -- Gold line separator
            local separator = Instance.new("Frame")
            separator.Size = UDim2.new(0.6, 0, 0, 1)
            separator.Position = UDim2.new(0.2, 0, 0, 58)
            separator.BackgroundColor3 = COLORS.ImperialGold
            separator.BackgroundTransparency = 0.5
            separator.BorderSizePixel = 0
            separator.ZIndex = 24
            separator.Parent = card
            
            -- Click button
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = 25
            btn.Parent = card
            
            btn.MouseButton1Click:Connect(function()
                self:OnCategoryClick(name)
            end)
            
            -- Hover animation
            btn.MouseEnter:Connect(function()
                createTween(card, {BackgroundTransparency = CONFIG.GlassTransparency - 0.05}, 0.2):Play()
                createTween(card.GlassStroke, {Transparency = 0.4}, 0.2):Play()
            end)
            btn.MouseLeave:Connect(function()
                createTween(card, {BackgroundTransparency = CONFIG.GlassTransparency + 0.1}, 0.2):Play()
                createTween(card.GlassStroke, {Transparency = CONFIG.StrokeTransparency}, 0.2):Play()
            end)
            
            count = count + 1
        end
    end
    
    local rows = math.ceil(count / cols)
    scroll.CanvasSize = UDim2.new(0, 0, 0, rows * (95 + 10) + 10)
end

-- Populate sub-scripts
function Gui:PopulateSubScripts(scripts, categoryName)
    local scroll = self.Elements.SubScroll
    local list = self.Elements.SubList
    
    -- Clear
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    self.Elements.SubTitle.Text = "📜 " .. categoryName .. " (" .. #scripts .. " скриптов)"
    
    for i, script in ipairs(scripts) do
        if type(script) == "table" and #script >= 2 then
            local name = tostring(script[1])
            local func = script[2]
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.96, 0, 0, 42)
            btn.BackgroundColor3 = COLORS.GlassBg
            btn.BackgroundTransparency = CONFIG.GlassTransparency + 0.05
            btn.Text = "  ⚡ " .. name
            btn.TextColor3 = COLORS.ImperialWhite
            btn.TextSize = 13
            btn.Font = Enum.Font.Gotham
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.ZIndex = 24
            btn.Parent = scroll
            
            applyGlass(btn, 12)
            btn.Shadow.ImageTransparency = 0.4
            
            -- Arrow
            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 24, 1, 0)
            arrow.Position = UDim2.new(0.93, 0, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▶"
            arrow.TextColor3 = COLORS.ImperialGold
            arrow.TextSize = 14
            arrow.Font = Enum.Font.GothamBold
            arrow.TextTransparency = 0.5
            arrow.ZIndex = 25
            arrow.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                self.Elements.StatusText.Text = "Запуск: " .. name
                self.Elements.StatusText.TextColor3 = COLORS.ImperialWhite
                
                local ok, err = pcall(func)
                
                if ok then
                    self.Elements.StatusText.Text = "✓ " .. name .. " выполнен!"
                    self.Elements.StatusText.TextColor3 = COLORS.Success
                else
                    self.Elements.StatusText.Text = "✗ Ошибка: " .. tostring(err)
                    self.Elements.StatusText.TextColor3 = COLORS.Error
                end
                
                task.delay(3, function()
                    self.Elements.StatusText.Text = "Готов к работе"
                    self.Elements.StatusText.TextColor3 = COLORS.ImperialWhite
                end)
            end)
            
            btn.MouseEnter:Connect(function()
                createTween(btn, {BackgroundTransparency = CONFIG.GlassTransparency - 0.1}, 0.15):Play()
                createTween(btn.GlassStroke, {Transparency = 0.3}, 0.15):Play()
                createTween(arrow, {TextTransparency = 0.1}, 0.15):Play()
            end)
            btn.MouseLeave:Connect(function()
                createTween(btn, {BackgroundTransparency = CONFIG.GlassTransparency + 0.05}, 0.15):Play()
                createTween(btn.GlassStroke, {Transparency = CONFIG.StrokeTransparency}, 0.15):Play()
                createTween(arrow, {TextTransparency = 0.5}, 0.15):Play()
            end)
        end
    end
    
    scroll.CanvasSize = UDim2.new(0, 0, 0, #scripts * (42 + 8) + 10)
    scroll.CanvasPosition = Vector2.new(0, 0)
end

-- Handle category click
function Gui:OnCategoryClick(categoryName)
    if not Database or not Database.categories then return end
    
    local fileName = Database.categories[categoryName]
    if not fileName then return end
    
    local url = Database.baseUrl .. "/" .. fileName
    
    self.Elements.StatusText.Text = "Загрузка " .. categoryName .. "..."
    self.Elements.StatusText.TextColor3 = COLORS.ImperialGold
    
    local ok, result = pcall(function()
        local src = game:HttpGet(url)
        local chunk = loadstring(src)
        if chunk then return chunk() end
    end)
    
    if not ok then
        self.Elements.StatusText.Text = "Ошибка: " .. tostring(result)
        self.Elements.StatusText.TextColor3 = COLORS.Error
        return
    end
    
    if type(result) == "table" then
        -- Switch to sub-script view
        self.Elements.CategoryScroll.Visible = false
        self.Elements.SubScroll.Visible = true
        self.Elements.SubTitle.Visible = true
        self.Elements.BackButton.Visible = true
        self:PopulateSubScripts(result, categoryName)
        self.Elements.StatusText.Text = "Загружено: " .. categoryName
        self.Elements.StatusText.TextColor3 = COLORS.Success
    else
        self.Elements.StatusText.Text = categoryName .. " выполнен!"
        self.Elements.StatusText.TextColor3 = COLORS.Success
        task.delay(2, function()
            self.Elements.StatusText.Text = "Готов к работе"
            self.Elements.StatusText.TextColor3 = COLORS.ImperialWhite
        end)
    end
end

-- Back to categories
function Gui:BackToCategories()
    self.Elements.CategoryScroll.Visible = true
    self.Elements.SubScroll.Visible = false
    self.Elements.SubTitle.Visible = false
    self.Elements.BackButton.Visible = false
    self.Elements.StatusText.Text = "Готов к работе"
    self.Elements.StatusText.TextColor3 = COLORS.ImperialWhite
end

-- Toggle window with animation
function Gui:ToggleWindow()
    local win = self.Elements.Window
    
    if win.Visible then
        createTween(win, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 600, 0, 410)
        }, 0.25):Play()
        
        task.wait(0.25)
        win.Visible = false
    else
        win.Visible = true
        win.BackgroundTransparency = 1
        win.Size = UDim2.new(0, 600, 0, 410)
        
        createTween(win, {
            BackgroundTransparency = CONFIG.GlassTransparency,
            Size = CONFIG.WindowSize
        }, 0.3):Play()
    end
end

-- Make draggable
function Gui:MakeDraggable()
    local win = self.Elements.Window
    local bar = self.Elements.TitleBar
    local dragging, startPos, startInput
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = win.Position
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
            win.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Load database
function Gui:LoadDatabase()
    self.Elements.StatusText.Text = "Загрузка базы данных..."
    self.Elements.StatusText.TextColor3 = COLORS.ImperialGold
    
    local ok, result = pcall(function()
        local data = game:HttpGet(CONFIG.BaseURL)
        local func = loadstring(data)
        if func then return func() end
    end)
    
    if ok and result then
        Database = result
        self:PopulateCategories()
        self.Elements.StatusText.Text = "Имперский Хаб готов!"
        self.Elements.StatusText.TextColor3 = COLORS.Success
        task.wait(2)
        self.Elements.StatusText.Text = "Готов к работе"
        self.Elements.StatusText.TextColor3 = COLORS.ImperialWhite
    else
        self.Elements.StatusText.Text = "Ошибка загрузки базы!"
        self.Elements.StatusText.TextColor3 = COLORS.Error
    end
end

-- Initialize
function Gui:Init()
    self.Container = GetContainer()
    if not self.Container then return end
    
    self.Elements = {}
    
    -- Create UI
    self.Elements.ToggleButton = self:CreateToggle()
    local winParts = self:CreateWindow()
    for k, v in pairs(winParts) do self.Elements[k] = v end
    
    -- Events
    self.Elements.ToggleButton.MouseButton1Click:Connect(function()
        self:ToggleWindow()
    end)
    
    self.Elements.CloseButton.MouseButton1Click:Connect(function()
        self:ToggleWindow()
    end)
    
    self.Elements.BackButton.MouseButton1Click:Connect(function()
        self:BackToCategories()
    end)
    
    -- Make draggable
    self:MakeDraggable()
    
    -- Load database
    self:LoadDatabase()
end

-- Start
Gui:Init()
