--[[
    gui.lua - RussElite Imperial Hub Main Interface
    Modern glassmorphism design with tabs, smooth animations, and dynamic script loading.
--]]

local Gui = {}
local Database = nil
local CurrentView = "categories"
local CurrentScripts = nil
local CurrentCategoryName = nil

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Color palette – deep dark translucent with white text & gold accents
local C = {
    Black = Color3.fromRGB(0, 0, 0),
    DarkGlass = Color3.fromRGB(10, 10, 16),
    MediumGlass = Color3.fromRGB(18, 18, 26),
    LightGlass = Color3.fromRGB(26, 26, 36),
    White = Color3.fromRGB(255, 255, 255),
    Gold = Color3.fromRGB(212, 175, 55),
    GoldBright = Color3.fromRGB(255, 210, 80),
    Red = Color3.fromRGB(220, 50, 50),
    Green = Color3.fromRGB(60, 200, 110),
    Gray = Color3.fromRGB(160, 160, 170),
    StrokeWhite = Color3.fromRGB(255, 255, 255)
}

-- Config
local CFG = {
    Title = "RUSSELITE",
    Version = "Imperial v3",
    BaseURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/base/base.lua",
    WindowW = 660,
    WindowH = 470,
    ToggleSize = 58,
    Radius = 16,
    GlassAlpha = 0.85
}

-- Safe container
local function getContainer()
    local ok, sg = pcall(function()
        local s = Instance.new("ScreenGui")
        s.Name = "RussElite"
        s.ResetOnSpawn = false
        s.Parent = CoreGui
        return s
    end)
    if ok then return sg end
    local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        local s = Instance.new("ScreenGui")
        s.Name = "RussElite"
        s.ResetOnSpawn = false
        s.Parent = pg
        return s
    end
    return nil
end

-- Tween helper
local function tween(obj, props, dur, ease)
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.25, ease or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- Apply glass styling: corner, stroke, shadow
local function styleGlass(frame, radius)
    radius = radius or CFG.Radius

    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = C.Black
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 49, 49)
    shadow.ZIndex = frame.ZIndex - 1
    shadow.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.StrokeWhite
    stroke.Transparency = 0.8
    stroke.Thickness = 1.2
    stroke.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = frame
end

-- Clear children of a frame (optional class filter)
local function clearChildren(frame, classFilter)
    for _, child in ipairs(frame:GetChildren()) do
        if not classFilter or child:IsA(classFilter) then
            child:Destroy()
        end
    end
end

-- ==================== BUILD UI ====================
function Gui:Build()
    self.UI = {}

    -- Floating toggle button (always visible)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, CFG.ToggleSize, 0, CFG.ToggleSize)
    toggle.Position = UDim2.new(0.93, -CFG.ToggleSize/2, 0.5, -CFG.ToggleSize/2)
    toggle.BackgroundColor3 = C.DarkGlass
    toggle.BackgroundTransparency = 1 - CFG.GlassAlpha
    toggle.Text = ""
    toggle.Parent = self.Container
    styleGlass(toggle, CFG.ToggleSize/2)

    -- Crown icon inside toggle
    local crown = Instance.new("TextLabel")
    crown.Size = UDim2.new(0, CFG.ToggleSize * 0.5, 0, CFG.ToggleSize * 0.5)
    crown.Position = UDim2.new(0.5, -CFG.ToggleSize * 0.25, 0.5, -CFG.ToggleSize * 0.25)
    crown.BackgroundTransparency = 1
    crown.Text = "♔"
    crown.TextColor3 = C.Gold
    crown.TextSize = CFG.ToggleSize * 0.3
    crown.Font = Enum.Font.GothamBlack
    crown.Parent = toggle

    -- Toggle glow
    local toggleGlow = Instance.new("UIStroke")
    toggleGlow.Color = C.Gold
    toggleGlow.Transparency = 0.6
    toggleGlow.Thickness = 2
    toggleGlow.Parent = toggle

    self.UI.Toggle = toggle
    self.UI.ToggleGlow = toggleGlow

    -- Main Window
    local win = Instance.new("Frame")
    win.Size = UDim2.new(0, CFG.WindowW, 0, CFG.WindowH)
    win.Position = UDim2.new(0.5, -CFG.WindowW/2, 0.5, -CFG.WindowH/2)
    win.BackgroundColor3 = C.DarkGlass
    win.BackgroundTransparency = 1 - CFG.GlassAlpha
    win.Visible = false
    win.ClipsDescendants = true
    win.Parent = self.Container
    styleGlass(win)
    self.UI.Window = win

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 46)
    titleBar.BackgroundColor3 = C.MediumGlass
    titleBar.BackgroundTransparency = 1 - CFG.GlassAlpha
    titleBar.Parent = win
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, CFG.Radius)
    titleCorner.Parent = titleBar

    -- Crown icon
    local crownIcon = Instance.new("TextLabel")
    crownIcon.Size = UDim2.new(0, 28, 0, 28)
    crownIcon.Position = UDim2.new(0, 12, 0, 9)
    crownIcon.BackgroundTransparency = 1
    crownIcon.Text = "♔"
    crownIcon.TextColor3 = C.Gold
    crownIcon.TextSize = 20
    crownIcon.Font = Enum.Font.GothamBlack
    crownIcon.Parent = titleBar

    -- Title text
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 120, 0, 30)
    title.Position = UDim2.new(0, 44, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = CFG.Title
    title.TextColor3 = C.White
    title.TextSize = 18
    title.Font = Enum.Font.GothamBlack
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- Version label
    local ver = Instance.new("TextLabel")
    ver.Size = UDim2.new(0, 90, 0, 18)
    ver.Position = UDim2.new(0, 160, 0, 16)
    ver.BackgroundTransparency = 1
    ver.Text = CFG.Version
    ver.TextColor3 = C.Gold
    ver.TextSize = 10
    ver.Font = Enum.Font.GothamBold
    ver.TextTransparency = 0.4
    ver.TextXAlignment = Enum.TextXAlignment.Left
    ver.Parent = titleBar

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -36, 0, 9)
    closeBtn.BackgroundColor3 = C.Red
    closeBtn.BackgroundTransparency = 0.75
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = C.White
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    closeBtn.MouseEnter:Connect(function() tween(closeBtn, {BackgroundTransparency = 0.3}, 0.2) end)
    closeBtn.MouseLeave:Connect(function() tween(closeBtn, {BackgroundTransparency = 0.75}, 0.2) end)
    self.UI.Close = closeBtn

    -- Tab buttons container
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -24, 0, 32)
    tabBar.Position = UDim2.new(0, 12, 0, 54)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = win
    local tabList = Instance.new("UIListLayout")
    tabList.FillDirection = Enum.FillDirection.Horizontal
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Padding = UDim.new(0, 6)
    tabList.Parent = tabBar

    -- Tab buttons: Scripts, Settings, Credits
    local tabDefs = {
        {Name = "Scripts", LayoutOrder = 1},
        {Name = "Settings", LayoutOrder = 2},
        {Name = "Credits", LayoutOrder = 3}
    }
    local tabBtns = {}
    for _, tab in ipairs(tabDefs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 90, 1, 0)
        btn.BackgroundColor3 = C.LightGlass
        btn.BackgroundTransparency = 1 - CFG.GlassAlpha
        btn.Text = tab.Name
        btn.TextColor3 = C.White
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.Parent = tabBar
        styleGlass(btn, 10)
        tabBtns[tab.Name] = btn
    end
    self.UI.TabBtns = tabBtns

    -- Content frame (holds all tab pages)
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -24, 1, -135)
    contentArea.Position = UDim2.new(0, 12, 0, 92)
    contentArea.BackgroundColor3 = C.LightGlass
    contentArea.BackgroundTransparency = 1 - CFG.GlassAlpha
    contentArea.ClipsDescendants = true
    contentArea.Parent = win
    styleGlass(contentArea, 14)

    -- ===== SCRIPTS TAB CONTENT =====
    local scriptsPage = Instance.new("Frame")
    scriptsPage.Size = UDim2.new(1, 0, 1, 0)
    scriptsPage.BackgroundTransparency = 1
    scriptsPage.Visible = true
    scriptsPage.Parent = contentArea
    self.UI.ScriptsPage = scriptsPage

    -- Search bar (inside scripts page, only visible in categories view)
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(1, -12, 0, 32)
    searchFrame.Position = UDim2.new(0, 6, 0, 6)
    searchFrame.BackgroundColor3 = C.MediumGlass
    searchFrame.BackgroundTransparency = 1 - CFG.GlassAlpha
    searchFrame.Parent = scriptsPage
    styleGlass(searchFrame, 10)

    local searchIcon = Instance.new("TextLabel")
    searchIcon.Size = UDim2.new(0, 28, 1, 0)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Text = "🔍"
    searchIcon.TextSize = 13
    searchIcon.Font = Enum.Font.Gotham
    searchIcon.Parent = searchFrame

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -34, 1, 0)
    searchBox.Position = UDim2.new(0, 28, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.PlaceholderText = "Search scripts..."
    searchBox.PlaceholderColor3 = C.Gray
    searchBox.Text = ""
    searchBox.TextColor3 = C.White
    searchBox.TextSize = 13
    searchBox.Font = Enum.Font.Gotham
    searchBox.Parent = searchFrame
    self.UI.SearchBox = searchBox

    -- Back button (hidden by default)
    local backBtn = Instance.new("TextButton")
    backBtn.Size = UDim2.new(0, 70, 0, 26)
    backBtn.Position = UDim2.new(0, 8, 0, 8)
    backBtn.BackgroundColor3 = C.Gold
    backBtn.BackgroundTransparency = 0.5
    backBtn.Text = "← Back"
    backBtn.TextColor3 = C.White
    backBtn.TextSize = 12
    backBtn.Font = Enum.Font.GothamBold
    backBtn.Visible = false
    backBtn.Parent = scriptsPage
    local backCorner = Instance.new("UICorner")
    backCorner.CornerRadius = UDim.new(0, 8)
    backCorner.Parent = backBtn
    backBtn.MouseEnter:Connect(function() tween(backBtn, {BackgroundTransparency = 0.2}, 0.15) end)
    backBtn.MouseLeave:Connect(function() tween(backBtn, {BackgroundTransparency = 0.5}, 0.15) end)
    self.UI.BackBtn = backBtn

    -- Script view title
    local scriptTitle = Instance.new("TextLabel")
    scriptTitle.Size = UDim2.new(1, -80, 0, 30)
    scriptTitle.Position = UDim2.new(0, 80, 0, 5)
    scriptTitle.BackgroundTransparency = 1
    scriptTitle.Text = ""
    scriptTitle.TextColor3 = C.White
    scriptTitle.TextSize = 15
    scriptTitle.Font = Enum.Font.GothamBold
    scriptTitle.TextXAlignment = Enum.TextXAlignment.Left
    scriptTitle.Visible = false
    scriptTitle.Parent = scriptsPage
    self.UI.ScriptTitle = scriptTitle

    -- Category grid (scroll)
    local catScroll = Instance.new("ScrollingFrame")
    catScroll.Size = UDim2.new(1, 0, 1, -40)
    catScroll.Position = UDim2.new(0, 0, 0, 40)
    catScroll.BackgroundTransparency = 1
    catScroll.ScrollBarThickness = 3
    catScroll.ScrollBarImageColor3 = C.Gold
    catScroll.ScrollBarImageTransparency = 0.6
    catScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    catScroll.Parent = scriptsPage
    local catGrid = Instance.new("UIGridLayout")
    catGrid.CellSize = UDim2.new(0, 140, 0, 100)
    catGrid.CellPadding = UDim2.new(0, 10, 0, 10)
    catGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    catGrid.SortOrder = Enum.SortOrder.Name
    catGrid.Parent = catScroll
    self.UI.CatScroll = catScroll
    self.UI.CatGrid = catGrid

    -- Script list (scroll)
    local scriptScroll = Instance.new("ScrollingFrame")
    scriptScroll.Size = UDim2.new(1, 0, 1, -40)
    scriptScroll.Position = UDim2.new(0, 0, 0, 40)
    scriptScroll.BackgroundTransparency = 1
    scriptScroll.ScrollBarThickness = 3
    scriptScroll.ScrollBarImageColor3 = C.Gold
    scriptScroll.ScrollBarImageTransparency = 0.6
    scriptScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scriptScroll.Visible = false
    scriptScroll.Parent = scriptsPage
    local scriptList = Instance.new("UIListLayout")
    scriptList.SortOrder = Enum.SortOrder.Name
    scriptList.Padding = UDim.new(0, 6)
    scriptList.Parent = scriptScroll
    self.UI.ScriptScroll = scriptScroll
    self.UI.ScriptList = scriptList

    -- ===== SETTINGS TAB =====
    local settingsPage = Instance.new("Frame")
    settingsPage.Size = UDim2.new(1, 0, 1, 0)
    settingsPage.BackgroundTransparency = 1
    settingsPage.Visible = false
    settingsPage.Parent = contentArea
    self.UI.SettingsPage = settingsPage

    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Size = UDim2.new(1, 0, 0, 30)
    settingsTitle.Position = UDim2.new(0, 12, 0, 12)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Text = "Settings"
    settingsTitle.TextColor3 = C.White
    settingsTitle.TextSize = 16
    settingsTitle.Font = Enum.Font.GothamBold
    settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
    settingsTitle.Parent = settingsPage

    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(1, -24, 0, 24)
    versionLabel.Position = UDim2.new(0, 12, 0, 48)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "Version: " .. CFG.Version
    versionLabel.TextColor3 = C.Gray
    versionLabel.TextSize = 13
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    versionLabel.Parent = settingsPage

    -- ===== CREDITS TAB =====
    local creditsPage = Instance.new("Frame")
    creditsPage.Size = UDim2.new(1, 0, 1, 0)
    creditsPage.BackgroundTransparency = 1
    creditsPage.Visible = false
    creditsPage.Parent = contentArea
    self.UI.CreditsPage = creditsPage

    local creditsTitle = Instance.new("TextLabel")
    creditsTitle.Size = UDim2.new(1, 0, 0, 30)
    creditsTitle.Position = UDim2.new(0, 12, 0, 12)
    creditsTitle.BackgroundTransparency = 1
    creditsTitle.Text = "Credits"
    creditsTitle.TextColor3 = C.White
    creditsTitle.TextSize = 16
    creditsTitle.Font = Enum.Font.GothamBold
    creditsTitle.TextXAlignment = Enum.TextXAlignment.Left
    creditsTitle.Parent = creditsPage

    local devText = Instance.new("TextLabel")
    devText.Size = UDim2.new(1, -24, 0, 24)
    devText.Position = UDim2.new(0, 12, 0, 48)
    devText.BackgroundTransparency = 1
    devText.Text = "Developed by the RussElite Team"
    devText.TextColor3 = C.Gray
    devText.TextSize = 13
    devText.Font = Enum.Font.Gotham
    devText.TextXAlignment = Enum.TextXAlignment.Left
    devText.Parent = creditsPage

    -- Status bar
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, -24, 0, 26)
    statusBar.Position = UDim2.new(0, 12, 1, -34)
    statusBar.BackgroundColor3 = C.MediumGlass
    statusBar.BackgroundTransparency = 1 - CFG.GlassAlpha
    statusBar.Parent = win
    styleGlass(statusBar, 8)

    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 7, 0, 7)
    statusDot.Position = UDim2.new(0, 10, 0, 9)
    statusDot.BackgroundColor3 = C.Gold
    statusDot.BorderSizePixel = 0
    statusDot.Parent = statusBar
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = statusDot
    -- Pulsing dot
    task.spawn(function()
        while statusDot and statusDot.Parent do
            tween(statusDot, {BackgroundTransparency = 0.7}, 0.7)
            task.wait(0.7)
            tween(statusDot, {BackgroundTransparency = 0.2}, 0.7)
            task.wait(0.7)
        end
    end)

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -30, 1, 0)
    statusText.Position = UDim2.new(0, 22, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Ready"
    statusText.TextColor3 = C.Gray
    statusText.TextSize = 11
    statusText.Font = Enum.Font.Gotham
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusBar
    self.UI.StatusText = statusText
    self.UI.StatusDot = statusDot

    -- Gold accent line at bottom
    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(1, -20, 0, 1)
    accentLine.Position = UDim2.new(0, 10, 1, -1)
    accentLine.BackgroundColor3 = C.Gold
    accentLine.BackgroundTransparency = 0.5
    accentLine.BorderSizePixel = 0
    accentLine.Parent = win

    -- ========== TAB SWITCHING LOGIC ==========
    local function setActiveTab(tabName)
        for name, btn in pairs(self.UI.TabBtns) do
            local active = (name == tabName)
            tween(btn, {
                BackgroundColor3 = active and C.Gold or C.LightGlass,
                BackgroundTransparency = active and 0.3 or 1 - CFG.GlassAlpha
            }, 0.2)
        end
        self.UI.ScriptsPage.Visible = (tabName == "Scripts")
        self.UI.SettingsPage.Visible = (tabName == "Settings")
        self.UI.CreditsPage.Visible = (tabName == "Credits")
    end

    for name, btn in pairs(self.UI.TabBtns) do
        btn.MouseButton1Click:Connect(function()
            setActiveTab(name)
        end)
    end
    -- Default
    setActiveTab("Scripts")

    return self.UI
end

-- ==================== CATEGORIES & SCRIPTS ====================
function Gui:ShowCategories(filter)
    clearChildren(self.UI.CatScroll, "Frame")
    if not Database or not Database.categories then return end

    local search = (filter or ""):lower()
    local cats = {}
    for name in pairs(Database.categories) do table.insert(cats, name) end
    table.sort(cats)

    local count = 0
    local cols = math.max(1, math.floor(self.UI.CatScroll.AbsoluteSize.X / (140 + 10)))

    for _, name in ipairs(cats) do
        if search == "" or name:lower():find(search, 1, true) then
            local card = Instance.new("Frame")
            card.Size = UDim2.new(0, 140, 0, 100)
            card.BackgroundColor3 = C.MediumGlass
            card.BackgroundTransparency = 1 - CFG.GlassAlpha
            card.Parent = self.UI.CatScroll
            styleGlass(card, 12)

            if Database.imageIds and Database.imageIds[name] then
                local icon = Instance.new("ImageLabel")
                icon.Size = UDim2.new(0, 44, 0, 44)
                icon.Position = UDim2.new(0.5, -22, 0, 10)
                icon.BackgroundTransparency = 1
                icon.Image = Database.imageIds[name]
                icon.ScaleType = Enum.ScaleType.Fit
                icon.Parent = card
            end

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -8, 0, 18)
            label.Position = UDim2.new(0, 4, 0, 72)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = C.White
            label.TextSize = 11
            label.Font = Enum.Font.GothamBold
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.Parent = card

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.Parent = card
            btn.MouseButton1Click:Connect(function() self:LoadCategory(name) end)
            btn.MouseEnter:Connect(function() tween(card, {BackgroundTransparency = 1 - CFG.GlassAlpha - 0.07}, 0.15) end)
            btn.MouseLeave:Connect(function() tween(card, {BackgroundTransparency = 1 - CFG.GlassAlpha}, 0.15) end)
            count += 1
        end
    end
    local rows = math.ceil(count / cols)
    self.UI.CatScroll.CanvasSize = UDim2.new(0, 0, 0, rows * (100 + 10) + 10)
end

function Gui:ShowScripts(scripts, categoryName)
    clearChildren(self.UI.ScriptScroll, "TextButton")
    self.UI.ScriptTitle.Text = categoryName .. " (" .. #scripts .. " scripts)"
    for _, script in ipairs(scripts) do
        if type(script) == "table" and #script >= 2 then
            local name = tostring(script[1])
            local func = script[2]
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.96, 0, 0, 42)
            btn.BackgroundColor3 = C.MediumGlass
            btn.BackgroundTransparency = 1 - CFG.GlassAlpha
            btn.Text = "  " .. name
            btn.TextColor3 = C.White
            btn.TextSize = 13
            btn.Font = Enum.Font.Gotham
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = self.UI.ScriptScroll
            styleGlass(btn, 10)

            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 24, 1, 0)
            arrow.Position = UDim2.new(1, -28, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▶"
            arrow.TextColor3 = C.Gold
            arrow.TextSize = 12
            arrow.Font = Enum.Font.GothamBold
            arrow.Parent = btn

            btn.MouseButton1Click:Connect(function()
                self.UI.StatusText.Text = "Running: " .. name
                self.UI.StatusText.TextColor3 = C.White
                local ok, err = pcall(func)
                if ok then
                    self.UI.StatusText.Text = "✓ Executed: " .. name
                    self.UI.StatusText.TextColor3 = C.Green
                else
                    self.UI.StatusText.Text = "✗ Error: " .. tostring(err):sub(1, 50)
                    self.UI.StatusText.TextColor3 = C.Red
                end
                task.delay(3, function()
                    self.UI.StatusText.Text = "Ready"
                    self.UI.StatusText.TextColor3 = C.Gray
                end)
            end)

            btn.MouseEnter:Connect(function()
                tween(btn, {BackgroundTransparency = 1 - CFG.GlassAlpha - 0.08}, 0.12)
                tween(arrow, {TextTransparency = 0.2}, 0.12)
            end)
            btn.MouseLeave:Connect(function()
                tween(btn, {BackgroundTransparency = 1 - CFG.GlassAlpha}, 0.12)
                tween(arrow, {TextTransparency = 0.6}, 0.12)
            end)
        end
    end
    self.UI.ScriptScroll.CanvasSize = UDim2.new(0, 0, 0, #scripts * (42 + 6) + 10)
    self.UI.ScriptScroll.CanvasPosition = Vector2.new(0, 0)
end

function Gui:LoadCategory(name)
    if not Database or not Database.categories[name] then return end
    local file = Database.categories[name]
    local url = Database.baseUrl .. "/" .. file
    self.UI.StatusText.Text = "Loading " .. name .. "..."
    self.UI.StatusText.TextColor3 = C.Gold

    local ok, result = pcall(function()
        local src = game:HttpGet(url)
        local chunk = loadstring(src)
        if chunk then return chunk() end
    end)
    if not ok then
        self.UI.StatusText.Text = "Error: " .. tostring(result):sub(1, 40)
        self.UI.StatusText.TextColor3 = C.Red
        return
    end

    if type(result) == "table" then
        CurrentView = "scripts"
        CurrentScripts = result
        CurrentCategoryName = name
        self.UI.CatScroll.Visible = false
        self.UI.ScriptScroll.Visible = true
        self.UI.ScriptTitle.Visible = true
        self.UI.BackBtn.Visible = true
        self.UI.SearchBox.Visible = false
        self:ShowScripts(result, name)
        self.UI.StatusText.Text = "Loaded: " .. name
        self.UI.StatusText.TextColor3 = C.Green
    else
        self.UI.StatusText.Text = "Executed: " .. name
        self.UI.StatusText.TextColor3 = C.Green
        task.delay(2, function()
            self.UI.StatusText.Text = "Ready"
            self.UI.StatusText.TextColor3 = C.Gray
        end)
    end
end

function Gui:BackToCategories()
    CurrentView = "categories"
    CurrentScripts = nil
    CurrentCategoryName = nil
    self.UI.CatScroll.Visible = true
    self.UI.ScriptScroll.Visible = false
    self.UI.ScriptTitle.Visible = false
    self.UI.BackBtn.Visible = false
    self.UI.SearchBox.Visible = true
    self.UI.StatusText.Text = "Ready"
    self.UI.StatusText.TextColor3 = C.Gray
end

-- ==================== WINDOW TOGGLE & DRAG ====================
function Gui:ToggleWindow()
    local win = self.UI.Window
    if win.Visible then
        tween(win, {BackgroundTransparency = 1, Size = UDim2.new(0, 600, 0, 420)}, 0.2)
        task.wait(0.2)
        win.Visible = false
    else
        win.Visible = true
        win.BackgroundTransparency = 1
        win.Size = UDim2.new(0, 600, 0, 420)
        tween(win, {BackgroundTransparency = 1 - CFG.GlassAlpha, Size = UDim2.new(0, CFG.WindowW, 0, CFG.WindowH)}, 0.25)
    end
end

function Gui:MakeDraggable()
    local win = self.UI.Window
    local bar = win:FindFirstChildOfClass("Frame") -- title bar
    local drag, startPos, startInput
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            startPos = win.Position
            startInput = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ==================== DATABASE LOADER ====================
function Gui:LoadDatabase()
    self.UI.StatusText.Text = "Loading database..."
    local ok, result = pcall(function()
        local data = game:HttpGet(CFG.BaseURL)
        local func = loadstring(data)
        if func then return func() end
    end)
    if ok and result then
        Database = result
        self:ShowCategories()
        self.UI.StatusText.Text = "Imperial Hub Ready"
        self.UI.StatusText.TextColor3 = C.Green
        task.wait(2)
        self.UI.StatusText.Text = "Ready"
        self.UI.StatusText.TextColor3 = C.Gray
    else
        self.UI.StatusText.Text = "Database error!"
        self.UI.StatusText.TextColor3 = C.Red
    end
end

-- ==================== INIT ====================
function Gui:Init()
    self.Container = getContainer()
    if not self.Container then return end

    self:Build()
    self:MakeDraggable()

    -- Event connections
    self.UI.Toggle.MouseButton1Click:Connect(function() self:ToggleWindow() end)
    self.UI.Close.MouseButton1Click:Connect(function() self:ToggleWindow() end)
    self.UI.BackBtn.MouseButton1Click:Connect(function() self:BackToCategories() end)
    self.UI.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if CurrentView == "categories" then
            self:ShowCategories(self.UI.SearchBox.Text)
        end
    end)

    -- Toggle hover effects
    self.UI.Toggle.MouseEnter:Connect(function()
        tween(self.UI.Toggle, {BackgroundTransparency = 1 - CFG.GlassAlpha - 0.1}, 0.2)
        tween(self.UI.ToggleGlow, {Transparency = 0.3}, 0.2)
    end)
    self.UI.Toggle.MouseLeave:Connect(function()
        tween(self.UI.Toggle, {BackgroundTransparency = 1 - CFG.GlassAlpha}, 0.2)
        tween(self.UI.ToggleGlow, {Transparency = 0.6}, 0.2)
    end)

    self:LoadDatabase()
end

-- Start
Gui:Init()
