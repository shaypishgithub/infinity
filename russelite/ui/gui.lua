-- RussElite Main Interface - gui.lua
-- Premium Glassmorphism Design with Russian Empire Theme

local Gui = {}
local Database = nil
local CurrentCategory = nil

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

-- Configuration
local CONFIG = {
    Title = "RussElite",
    Version = "v3.0",
    PrimaryText = Color3.fromRGB(255, 255, 255),
    GoldAccent = Color3.fromRGB(200, 170, 80),
    DarkGold = Color3.fromRGB(140, 110, 40),
    GlassBase = Color3.fromRGB(18, 18, 25),
    GlassLight = Color3.fromRGB(25, 25, 35),
    DeepBlack = Color3.fromRGB(5, 5, 10),
    ImperialWhite = Color3.fromRGB(255, 255, 255),
    ImperialBlue = Color3.fromRGB(0, 40, 140),
    ImperialRed = Color3.fromRGB(180, 25, 25),
    WindowSize = UDim2.new(0, 650, 0, 460),
    ToggleSize = UDim2.new(0, 60, 0, 60),
    BorderRadius = 18,
    BaseURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/base/base.lua"
}

-- Safe container
local function GetSafeContainer()
    local success, result = pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "RussEliteHub"
        sg.Parent = CoreGui
        return sg
    end)
    if not success then
        local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
        local sg = Instance.new("ScreenGui")
        sg.Name = "RussEliteHub"
        sg.Parent = pg
        return sg
    end
    return result
end

-- Enhanced tween
local function tween(obj, props, dur, easing)
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.35, easing or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- Premium glass effect
local function applyGlass(frame, transparency)
    local trans = transparency or 0.3
    
    -- Main glass gradient
    local glassGrad = Instance.new("UIGradient")
    glassGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 220, 240)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 200))
    })
    glassGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.5, 0.88),
        NumberSequenceKeypoint.new(1, 0.82)
    })
    glassGrad.Rotation = 135
    glassGrad.Parent = frame
    
    -- Glass border stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.6
    stroke.Thickness = 1.2
    stroke.Parent = frame
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    corner.Parent = frame
    
    -- Inner glow
    local innerGlow = Instance.new("UIGradient")
    innerGlow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 180, 120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 130, 80))
    })
    innerGlow.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.95),
        NumberSequenceKeypoint.new(1, 0.98)
    })
    innerGlow.Rotation = -45
    innerGlow.Parent = stroke
    
    -- Drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.55
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 49, 49)
    shadow.ZIndex = 0
    shadow.Parent = frame
    
    return stroke, corner, glassGrad
end

-- Create Russian Empire flag
local function createRussianFlag(size)
    local sizeX = size or 50
    local sizeY = sizeX * 2/3
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, sizeX, 0, sizeY)
    container.BackgroundTransparency = 1
    
    -- White stripe
    local white = Instance.new("Frame")
    white.Size = UDim2.new(1, 0, 0.33, 0)
    white.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    white.Parent = container
    
    -- Blue stripe
    local blue = Instance.new("Frame")
    blue.Size = UDim2.new(1, 0, 0.34, 0)
    blue.Position = UDim2.new(0, 0, 0.33, 0)
    blue.BackgroundColor3 = Color3.fromRGB(0, 45, 150)
    blue.Parent = container
    
    -- Red stripe
    local red = Instance.new("Frame")
    red.Size = UDim2.new(1, 0, 0.33, 0)
    red.Position = UDim2.new(0, 0, 0.67, 0)
    red.BackgroundColor3 = Color3.fromRGB(190, 30, 30)
    red.Parent = container
    
    -- Gold border
    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(200, 170, 80)
    border.Transparency = 0.4
    border.Thickness = 1.5
    border.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 3)
    corner.Parent = container
    
    return container
end

-- Create toggle button with flag
function Gui:CreateToggleButton()
    local btn = Instance.new("TextButton")
    btn.Name = "ToggleButton"
    btn.Size = CONFIG.ToggleSize
    btn.Position = UDim2.new(0.93, -30, 0.5, -30)
    btn.BackgroundColor3 = CONFIG.GlassBase
    btn.BackgroundTransparency = 0.25
    btn.Text = ""
    btn.Parent = self.Container
    
    applyGlass(btn, 0.25)
    
    -- Russian flag on button
    local flag = createRussianFlag(30)
    flag.Position = UDim2.new(0.5, -15, 0.2, 0)
    flag.Parent = btn
    
    -- Eagle icon
    local eagle = Instance.new("TextLabel")
    eagle.Size = UDim2.new(1, 0, 0, 18)
    eagle.Position = UDim2.new(0, 0, 0.55, 0)
    eagle.BackgroundTransparency = 1
    eagle.Text = "👑"
    eagle.TextSize = 16
    eagle.Parent = btn
    
    return btn
end

-- Create main window
function Gui:CreateMainWindow()
    local window = Instance.new("Frame")
    window.Name = "MainWindow"
    window.Size = CONFIG.WindowSize
    window.Position = UDim2.new(0.5, -325, 0.5, -230)
    window.BackgroundColor3 = CONFIG.GlassBase
    window.BackgroundTransparency = 0.2
    window.Visible = false
    window.ClipsDescendants = true
    window.Parent = self.Container
    
    applyGlass(window, 0.2)
    
    -- Title bar with flag
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 48)
    titleBar.BackgroundColor3 = CONFIG.GlassLight
    titleBar.BackgroundTransparency = 0.3
    titleBar.Parent = window
    
    applyGlass(titleBar, 0.3)
    
    -- Flag in title
    local titleFlag = createRussianFlag(36)
    titleFlag.Position = UDim2.new(0.015, 0, 0.13, 0)
    titleFlag.Parent = titleBar
    
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0.4, 0, 1, 0)
    titleText.Position = UDim2.new(0.09, 0, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = CONFIG.Title
    titleText.TextColor3 = CONFIG.PrimaryText
    titleText.TextSize = 22
    titleText.Font = Enum.Font.GothamBlack
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Gold accent line under title
    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(0, 40, 0, 2)
    accentLine.Position = UDim2.new(0.09, 0, 0.75, 0)
    accentLine.BackgroundColor3 = CONFIG.GoldAccent
    accentLine.BackgroundTransparency = 0.3
    accentLine.Parent = titleBar
    
    Instance.new("UICorner", accentLine).CornerRadius = UDim.new(1, 0)
    
    -- Version
    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(0.15, 0, 1, 0)
    version.Position = UDim2.new(0.5, 0, 0, 0)
    version.BackgroundTransparency = 1
    version.Text = CONFIG.Version
    version.TextColor3 = CONFIG.GoldAccent
    version.TextSize = 11
    version.Font = Enum.Font.GothamBold
    version.TextTransparency = 0.3
    version.Parent = titleBar
    
    -- Imperial eagle emblem
    local eagleEmblem = Instance.new("TextLabel")
    eagleEmblem.Size = UDim2.new(0, 30, 0, 30)
    eagleEmblem.Position = UDim2.new(0.85, 0, 0.2, 0)
    eagleEmblem.BackgroundTransparency = 1
    eagleEmblem.Text = "⚜"
    eagleEmblem.TextColor3 = CONFIG.GoldAccent
    eagleEmblem.TextSize = 24
    eagleEmblem.TextTransparency = 0.4
    eagleEmblem.Parent = titleBar
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(0.935, 0, 0.17, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    closeBtn.BackgroundTransparency = 0.4
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = CONFIG.PrimaryText
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    applyGlass(closeBtn, 0.4)
    
    -- Search bar
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(0.95, 0, 0, 36)
    searchFrame.Position = UDim2.new(0.025, 0, 0, 56)
    searchFrame.BackgroundColor3 = CONFIG.GlassLight
    searchFrame.BackgroundTransparency = 0.35
    searchFrame.Parent = window
    
    applyGlass(searchFrame, 0.35)
    
    local searchIcon = Instance.new("TextLabel")
    searchIcon.Size = UDim2.new(0, 30, 1, 0)
    searchIcon.Position = UDim2.new(0.01, 0, 0, 0)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Text = "🔍"
    searchIcon.TextSize = 14
    searchIcon.Parent = searchFrame
    
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(0.88, 0, 1, 0)
    searchBox.Position = UDim2.new(0.08, 0, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.PlaceholderText = "Поиск скриптов..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBox.Text = ""
    searchBox.TextColor3 = CONFIG.PrimaryText
    searchBox.TextSize = 14
    searchBox.Font = Enum.Font.Gotham
    searchBox.Parent = searchFrame
    
    -- Content area
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(0.95, 0, 1, -140)
    contentArea.Position = UDim2.new(0.025, 0, 0, 100)
    contentArea.BackgroundColor3 = CONFIG.GlassLight
    contentArea.BackgroundTransparency = 0.35
    contentArea.ClipsDescendants = true
    contentArea.Parent = window
    
    applyGlass(contentArea, 0.35)
    
    -- Back button
    local backBtn = Instance.new("TextButton")
    backBtn.Size = UDim2.new(0, 90, 0, 28)
    backBtn.Position = UDim2.new(0.015, 0, 0.015, 0)
    backBtn.BackgroundColor3 = CONFIG.GoldAccent
    backBtn.BackgroundTransparency = 0.5
    backBtn.Text = "◀  Назад"
    backBtn.TextColor3 = CONFIG.PrimaryText
    backBtn.TextSize = 13
    backBtn.Font = Enum.Font.GothamBold
    backBtn.Visible = false
    backBtn.Parent = contentArea
    
    applyGlass(backBtn, 0.5)
    
    -- Category scroll
    local categoryScroll = Instance.new("ScrollingFrame")
    categoryScroll.Name = "CategoryScroll"
    categoryScroll.Size = UDim2.new(1, 0, 1, 0)
    categoryScroll.BackgroundTransparency = 1
    categoryScroll.ScrollBarThickness = 4
    categoryScroll.ScrollBarImageColor3 = CONFIG.GoldAccent
    categoryScroll.ScrollBarImageTransparency = 0.5
    categoryScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    categoryScroll.Parent = contentArea
    
    local categoryGrid = Instance.new("UIGridLayout")
    categoryGrid.CellSize = UDim2.new(0, 135, 0, 95)
    categoryGrid.CellPadding = UDim2.new(0, 10, 0, 10)
    categoryGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    categoryGrid.SortOrder = Enum.SortOrder.Name
    categoryGrid.Parent = categoryScroll
    
    -- Sub-script scroll
    local subScroll = Instance.new("ScrollingFrame")
    subScroll.Name = "SubScriptScroll"
    subScroll.Size = UDim2.new(1, 0, 1, -40)
    subScroll.Position = UDim2.new(0, 0, 0, 40)
    subScroll.BackgroundTransparency = 1
    subScroll.ScrollBarThickness = 4
    subScroll.ScrollBarImageColor3 = CONFIG.GoldAccent
    subScroll.ScrollBarImageTransparency = 0.5
    subScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    subScroll.Visible = false
    subScroll.Parent = contentArea
    
    local subList = Instance.new("UIListLayout")
    subList.SortOrder = Enum.SortOrder.Name
    subList.Padding = UDim.new(0, 8)
    subList.Parent = subScroll
    
    -- Sub title
    local subTitle = Instance.new("TextLabel")
    subTitle.Name = "SubTitle"
    subTitle.Size = UDim2.new(1, 0, 0, 35)
    subTitle.BackgroundTransparency = 1
    subTitle.Text = ""
    subTitle.TextColor3 = CONFIG.GoldAccent
    subTitle.TextSize = 17
    subTitle.Font = Enum.Font.GothamBold
    subTitle.TextXAlignment = Enum.TextXAlignment.Left
    subTitle.Visible = false
    subTitle.Parent = contentArea
    
    -- Status bar
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(0.95, 0, 0, 28)
    statusBar.Position = UDim2.new(0.025, 0, 0.94, -28)
    statusBar.BackgroundColor3 = CONFIG.GlassLight
    statusBar.BackgroundTransparency = 0.35
    statusBar.Parent = window
    
    applyGlass(statusBar, 0.35)
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(0.85, 0, 1, 0)
    statusText.Position = UDim2.new(0.03, 0, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Готов к работе"
    statusText.TextColor3 = CONFIG.GoldAccent
    statusText.TextSize = 12
    statusText.Font = Enum.Font.Gotham
    statusText.TextTransparency = 0.3
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusBar
    
    -- Imperial eagle in status
    local statusEagle = Instance.new("TextLabel")
    statusEagle.Size = UDim2.new(0, 20, 1, 0)
    statusEagle.Position = UDim2.new(0.9, 0, 0, 0)
    statusEagle.BackgroundTransparency = 1
    statusEagle.Text = "⚜"
    statusEagle.TextColor3 = CONFIG.GoldAccent
    statusEagle.TextSize = 16
    statusEagle.TextTransparency = 0.5
    statusEagle.Parent = statusBar
    
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
    self.Elements.StatusText.Text = "Загрузка базы данных..."
    
    local success, result = pcall(function()
        local data = game:HttpGet(CONFIG.BaseURL)
        local func = loadstring(data)
        if func then return func() end
    end)
    
    if success and result then
        Database = result
        self.Elements.StatusText.Text = "База загружена!"
        self:PopulateCategories()
        task.delay(2, function()
            self.Elements.StatusText.Text = "Готов к работе"
        end)
    else
        self.Elements.StatusText.Text = "Ошибка загрузки базы!"
    end
end

-- Populate categories
function Gui:PopulateCategories(filter)
    local scroll = self.Elements.CategoryScroll
    local grid = self.Elements.CategoryGrid
    
    -- Clear
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    if not Database or not Database.categories then return end
    
    local searchText = (filter or ""):lower()
    local categories = {}
    
    for name in pairs(Database.categories) do
        table.insert(categories, name)
    end
    table.sort(categories)
    
    local count = 0
    local columns = math.max(1, math.floor(scroll.AbsoluteSize.X / (135 + 10)))
    
    for _, name in ipairs(categories) do
        if searchText == "" or name:lower():find(searchText, 1, true) then
            local card = Instance.new("Frame")
            card.Name = name
            card.Size = UDim2.new(0, 135, 0, 95)
            card.BackgroundColor3 = CONFIG.GlassBase
            card.BackgroundTransparency = 0.35
            card.Parent = scroll
            
            applyGlass(card, 0.35)
            
            -- Game icon
            local iconId = Database.imageIds and Database.imageIds[name]
            if iconId then
                local icon = Instance.new("ImageLabel")
                icon.Size = UDim2.new(0, 52, 0, 52)
                icon.Position = UDim2.new(0.5, -26, 0.08, 0)
                icon.BackgroundTransparency = 1
                icon.Image = iconId
                icon.ScaleType = Enum.ScaleType.Fit
                icon.Parent = card
                
                -- Icon glow
                local iconGlow = Instance.new("UIGradient")
                iconGlow.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, CONFIG.GoldAccent),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                })
                iconGlow.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.7),
                    NumberSequenceKeypoint.new(1, 0.9)
                })
                iconGlow.Parent = icon
            end
            
            -- Category name
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 0, 22)
            label.Position = UDim2.new(0, 5, 0, 65)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = CONFIG.PrimaryText
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
                tween(card, {BackgroundTransparency = 0.2}, 0.2)
                tween(card, {Size = UDim2.new(0, 140, 0, 100)}, 0.2, Enum.EasingStyle.Back)
            end)
            clickBtn.MouseLeave:Connect(function()
                tween(card, {BackgroundTransparency = 0.35}, 0.2)
                tween(card, {Size = UDim2.new(0, 135, 0, 95)}, 0.2)
            end)
            
            count = count + 1
        end
    end
    
    local rows = math.ceil(count / columns)
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
    
    self.Elements.SubTitle.Text = "📜  " .. categoryName .. "  (" .. #scripts .. " скриптов)"
    
    for i, script in ipairs(scripts) do
        if type(script) == "table" and #script >= 2 then
            local scriptName = tostring(script[1])
            local scriptFunc = script[2]
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.94, 0, 0, 42)
            btn.BackgroundColor3 = CONFIG.GlassBase
            btn.BackgroundTransparency = 0.35
            btn.Text = "  " .. scriptName
            btn.TextColor3 = CONFIG.PrimaryText
            btn.TextSize = 14
            btn.Font = Enum.Font.Gotham
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = scroll
            
            applyGlass(btn, 0.35)
            
            -- Arrow icon
            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 24, 1, 0)
            arrow.Position = UDim2.new(0.93, 0, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▶"
            arrow.TextColor3 = CONFIG.GoldAccent
            arrow.TextSize = 14
            arrow.Font = Enum.Font.GothamBold
            arrow.TextTransparency = 0.4
            arrow.Parent = btn
            
            -- Click handler
            btn.MouseButton1Click:Connect(function()
                self.Elements.StatusText.Text = "Запуск: " .. scriptName
                
                local success, err = pcall(scriptFunc)
                
                if success then
                    self.Elements.StatusText.Text = scriptName .. " ✓"
                else
                    self.Elements.StatusText.Text = "Ошибка: " .. tostring(err)
                end
                
                task.delay(2.5, function()
                    self.Elements.StatusText.Text = "Готов к работе"
                end)
            end)
            
            -- Hover
            btn.MouseEnter:Connect(function()
                tween(btn, {BackgroundTransparency = 0.2}, 0.15)
                tween(arrow, {TextTransparency = 0.1, TextColor3 = Color3.fromRGB(255, 220, 150)}, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                tween(btn, {BackgroundTransparency = 0.35}, 0.15)
                tween(arrow, {TextTransparency = 0.4, TextColor3 = CONFIG.GoldAccent}, 0.15)
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
    
    local success, result = pcall(function()
        local source = game:HttpGet(url)
        local chunk = loadstring(source)
        if chunk then return chunk() end
    end)
    
    if not success then
        self.Elements.StatusText.Text = "Ошибка: " .. tostring(result)
        return
    end
    
    if type(result) == "table" then
        -- Show sub-scripts
        self.Elements.CategoryScroll.Visible = false
        self.Elements.SubScroll.Visible = true
        self.Elements.SubTitle.Visible = true
        self.Elements.BackButton.Visible = true
        self.Elements.SearchBox.Visible = false
        CurrentCategory = categoryName
        
        self:PopulateSubScripts(result, categoryName)
        self.Elements.StatusText.Text = categoryName .. " загружен!"
    else
        self.Elements.StatusText.Text = categoryName .. " выполнен!"
        task.delay(2, function()
            self.Elements.StatusText.Text = "Готов к работе"
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
    CurrentCategory = nil
    self.Elements.StatusText.Text = "Готов к работе"
end

-- Toggle window
function Gui:ToggleWindow()
    local window = self.Elements.Window
    
    if window.Visible then
        tween(window, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 600, 0, 410)
        }, 0.25)
        task.wait(0.25)
        window.Visible = false
    else
        window.Visible = true
        window.BackgroundTransparency = 1
        window.Size = UDim2.new(0, 600, 0, 410)
        tween(window, {
            BackgroundTransparency = 0.2,
            Size = CONFIG.WindowSize
        }, 0.3, Enum.EasingStyle.Back)
    end
end

-- Drag functionality
function Gui:MakeDraggable()
    local window = self.Elements.Window
    local titleBar = self.Elements.TitleBar
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
            window.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Initialize
function Gui:Init()
    self.Container = GetSafeContainer()
    self.Elements = {}
    
    -- Create UI
    self.Elements.ToggleButton = self:CreateToggleButton()
    
    local winParts = self:CreateMainWindow()
    for k, v in pairs(winParts) do
        self.Elements[k] = v
    end
    
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
    
    self.Elements.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if self.Elements.CategoryScroll.Visible then
            self:PopulateCategories(self.Elements.SearchBox.Text)
        end
    end)
    
    -- Make draggable
    self:MakeDraggable()
    
    -- Load database
    self:LoadDatabase()
end

-- Start
Gui:Init()
