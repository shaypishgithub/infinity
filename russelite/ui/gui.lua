-- RussElite Main Interface - gui.lua (iPhone Glassmorphism 2026 Style)
local Gui = {}
local Database = nil
local CurrentSubScripts = nil
local CurrentCategory = nil

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local CONFIG = {
    Title = "RussElite",
    Version = "v2.2",
    TextColor = Color3.fromRGB(255, 255, 255),
    SecondaryText = Color3.fromRGB(180, 180, 180),
    Accent = Color3.fromRGB(220, 220, 220),
    Background = Color3.fromRGB(8, 8, 8),
    Glass = Color3.fromRGB(18, 18, 18),
    CardGlass = Color3.fromRGB(25, 25, 25),
    StrokeColor = Color3.fromRGB(255, 255, 255),
    WindowSize = UDim2.new(0, 600, 0, 420),
    ToggleButtonSize = UDim2.new(0, 110, 0, 42),
    BorderRadius = 18,
    BaseURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/base/base.lua"
}

-- Safe GUI Container
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

-- Helper: Tween Animation
local function tween(obj, props, dur, style, dir)
    local t = TweenService:Create(
        obj, 
        TweenInfo.new(dur or 0.3, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), 
        props
    )
    t:Play()
    return t
end

-- Helper: Glassmorphism Styling
local function applyGlassStyle(frame, radius, strokeTrans, bgTrans)
    frame.BackgroundColor3 = CONFIG.Glass
    frame.BackgroundTransparency = bgTrans or 0.25

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or CONFIG.BorderRadius)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.StrokeColor
    stroke.Transparency = strokeTrans or 0.85
    stroke.Thickness = 1.2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame

    return stroke, corner
end

-- Create Floating iOS Pill Toggle Button (Открыть / Закрыть)
function Gui:CreateToggleButton()
    local btn = Instance.new("TextButton")
    btn.Name = "ToggleButton"
    btn.Size = CONFIG.ToggleButtonSize
    btn.Position = UDim2.new(0.95, -120, 0.08, 0)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = self.Container

    applyGlassStyle(btn, 22, 0.7, 0.2)

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 6)
    layout.Parent = btn

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.BackgroundTransparency = 1
    icon.Text = ""
    icon.TextColor3 = CONFIG.TextColor
    icon.TextSize = 16
    icon.Font = Enum.Font.GothamBold
    icon.Parent = btn

    local label = Instance.new("TextLabel")
    label.Name = "BtnLabel"
    label.Size = UDim2.new(0, 60, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Открыть"
    label.TextColor3 = CONFIG.TextColor
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.Parent = btn

    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundTransparency = 0.1}, 0.2)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundTransparency = 0.2}, 0.2)
    end)

    return btn
end

-- Create Main Glass Window
function Gui:CreateMainWindow()
    local window = Instance.new("Frame")
    window.Name = "MainWindow"
    window.Size = CONFIG.WindowSize
    window.Position = UDim2.new(0.5, -300, 0.5, -210)
    window.Visible = false
    window.ClipsDescendants = true
    window.Parent = self.Container

    applyGlassStyle(window, CONFIG.BorderRadius, 0.8, 0.15)

    -- Header / Titlebar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 46)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = window

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0.4, 0, 1, 0)
    titleText.Position = UDim2.new(0.04, 0, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = CONFIG.Title
    titleText.TextColor3 = CONFIG.TextColor
    titleText.TextSize = 20
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(0.2, 0, 1, 0)
    version.Position = UDim2.new(0.26, 0, 0, 2)
    version.BackgroundTransparency = 1
    version.Text = CONFIG.Version
    version.TextColor3 = CONFIG.SecondaryText
    version.TextSize = 11
    version.Font = Enum.Font.Gotham
    version.TextXAlignment = Enum.TextXAlignment.Left
    version.Parent = titleBar

    -- Close Button (iOS Widget Close Style)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.Position = UDim2.new(0.96, -26, 0.22, 0)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = CONFIG.TextColor
    closeBtn.TextSize = 12
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    applyGlassStyle(closeBtn, 13, 0.85, 0.4)

    -- Search Bar
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(0.92, 0, 0, 36)
    searchFrame.Position = UDim2.new(0.04, 0, 0, 48)
    searchFrame.Parent = window
    applyGlassStyle(searchFrame, 10, 0.9, 0.4)

    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(0.95, 0, 1, 0)
    searchBox.Position = UDim2.new(0.03, 0, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.PlaceholderText = "🔍 Поиск скриптов..."
    searchBox.PlaceholderColor3 = CONFIG.SecondaryText
    searchBox.Text = ""
    searchBox.TextColor3 = CONFIG.TextColor
    searchBox.TextSize = 13
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.Parent = searchFrame

    -- Content Container
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(0.92, 0, 1, -125)
    contentArea.Position = UDim2.new(0.04, 0, 0, 92)
    contentArea.BackgroundTransparency = 1
    contentArea.ClipsDescendants = true
    contentArea.Parent = window

    -- Back Button
    local backBtn = Instance.new("TextButton")
    backBtn.Name = "BackButton"
    backBtn.Size = UDim2.new(0, 90, 0, 28)
    backBtn.Position = UDim2.new(0, 0, 0, 0)
    backBtn.Text = "‹ Назад"
    backBtn.TextColor3 = CONFIG.TextColor
    backBtn.TextSize = 13
    backBtn.Font = Enum.Font.GothamBold
    backBtn.Visible = false
    backBtn.Parent = contentArea
    applyGlassStyle(backBtn, 8, 0.8, 0.3)

    -- SubTitle Text
    local subTitle = Instance.new("TextLabel")
    subTitle.Name = "SubTitle"
    subTitle.Size = UDim2.new(0.7, 0, 0, 28)
    subTitle.Position = UDim2.new(0, 100, 0, 0)
    subTitle.BackgroundTransparency = 1
    subTitle.Text = ""
    subTitle.TextColor3 = CONFIG.TextColor
    subTitle.TextSize = 14
    subTitle.Font = Enum.Font.GothamBold
    subTitle.TextXAlignment = Enum.TextXAlignment.Left
    subTitle.Visible = false
    subTitle.Parent = contentArea

    -- Categories Grid Frame
    local categoryScroll = Instance.new("ScrollingFrame")
    categoryScroll.Name = "CategoryScroll"
    categoryScroll.Size = UDim2.new(1, 0, 1, 0)
    categoryScroll.BackgroundTransparency = 1
    categoryScroll.ScrollBarThickness = 2
    categoryScroll.ScrollBarImageColor3 = CONFIG.SecondaryText
    categoryScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    categoryScroll.Parent = contentArea

    local categoryGrid = Instance.new("UIGridLayout")
    categoryGrid.CellSize = UDim2.new(0, 130, 0, 95)
    categoryGrid.CellPadding = UDim2.new(0, 10, 0, 10)
    categoryGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left
    categoryGrid.SortOrder = Enum.SortOrder.Name
    categoryGrid.Parent = categoryScroll

    -- SubScripts List Frame
    local subScroll = Instance.new("ScrollingFrame")
    subScroll.Name = "SubScriptScroll"
    subScroll.Size = UDim2.new(1, 0, 1, -36)
    subScroll.Position = UDim2.new(0, 0, 0, 36)
    subScroll.BackgroundTransparency = 1
    subScroll.ScrollBarThickness = 2
    subScroll.ScrollBarImageColor3 = CONFIG.SecondaryText
    subScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    subScroll.Visible = false
    subScroll.Parent = contentArea

    local subList = Instance.new("UIListLayout")
    subList.SortOrder = Enum.SortOrder.Name
    subList.Padding = UDim.new(0, 8)
    subList.Parent = subScroll

    -- Status Bar Footer
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(0.92, 0, 0, 22)
    statusBar.Position = UDim2.new(0.04, 0, 1, -28)
    statusBar.Parent = window
    applyGlassStyle(statusBar, 8, 0.9, 0.5)

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -16, 1, 0)
    statusText.Position = UDim2.new(0, 8, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Система готова"
    statusText.TextColor3 = CONFIG.SecondaryText
    statusText.TextSize = 11
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

-- Load Database
function Gui:LoadDatabase()
    self.Elements.StatusText.Text = "Загрузка базы данных..."
    
    local success, result = pcall(function()
        local data = game:HttpGet(CONFIG.BaseURL)
        local func = loadstring(data)
        if func then return func() end
    end)
    
    if success and result then
        Database = result
        self.Elements.StatusText.Text = "База данных загружена успешно"
        self:PopulateCategories()
        task.delay(2, function()
            self.Elements.StatusText.Text = "Система готова"
        end)
    else
        self.Elements.StatusText.Text = "Ошибка загрузки базы данных!"
    end
end

-- Populate Categories
function Gui:PopulateCategories(filter)
    local scroll = self.Elements.CategoryScroll
    
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    if not Database or not Database.categories then return end
    
    local searchText = (filter or ""):lower()
    local categories = {}
    
    for name, _ in pairs(Database.categories) do
        table.insert(categories, name)
    end
    table.sort(categories)
    
    local count = 0
    for _, name in ipairs(categories) do
        if searchText == "" or name:lower():find(searchText, 1, true) then
            local card = Instance.new("Frame")
            card.Name = name
            card.Size = UDim2.new(0, 130, 0, 95)
            card.Parent = scroll
            
            applyGlassStyle(card, 14, 0.85, 0.35)

            -- Icon
            local iconId = Database.imageIds and Database.imageIds[name]
            if iconId then
                local icon = Instance.new("ImageLabel")
                icon.Size = UDim2.new(0, 42, 0, 42)
                icon.Position = UDim2.new(0.5, -21, 0.12, 0)
                icon.BackgroundTransparency = 1
                icon.Image = iconId
                icon.ScaleType = Enum.ScaleType.Fit
                icon.Parent = card
            end

            -- Label
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 0, 24)
            label.Position = UDim2.new(0, 5, 0, 64)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = CONFIG.TextColor
            label.TextSize = 12
            label.Font = Enum.Font.GothamBold
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.Parent = card

            -- Interactive Button
            local clickBtn = Instance.new("TextButton")
            clickBtn.Size = UDim2.new(1, 0, 1, 0)
            clickBtn.BackgroundTransparency = 1
            clickBtn.Text = ""
            clickBtn.Parent = card

            clickBtn.MouseButton1Click:Connect(function()
                self:OnCategoryClick(name)
            end)

            clickBtn.MouseEnter:Connect(function()
                tween(card, {BackgroundTransparency = 0.15}, 0.2)
            end)
            clickBtn.MouseLeave:Connect(function()
                tween(card, {BackgroundTransparency = 0.35}, 0.2)
            end)

            count = count + 1
        end
    end

    local columns = math.floor(scroll.AbsoluteSize.X / 140)
    columns = math.max(1, columns)
    local rows = math.ceil(count / columns)
    scroll.CanvasSize = UDim2.new(0, 0, 0, rows * 105 + 10)
end

-- Populate SubScripts
function Gui:PopulateSubScripts(scripts, categoryName)
    local scroll = self.Elements.SubScroll
    
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    self.Elements.SubTitle.Text = categoryName .. " (" .. #scripts .. ")"

    for i, script in ipairs(scripts) do
        if type(script) == "table" and #script >= 2 then
            local scriptName = tostring(script[1])
            local scriptFunc = script[2]

            local btnFrame = Instance.new("Frame")
            btnFrame.Size = UDim2.new(1, -6, 0, 42)
            btnFrame.Parent = scroll
            applyGlassStyle(btnFrame, 12, 0.88, 0.3)

            local btnText = Instance.new("TextLabel")
            btnText.Size = UDim2.new(0.8, 0, 1, 0)
            btnText.Position = UDim2.new(0.04, 0, 0, 0)
            btnText.BackgroundTransparency = 1
            btnText.Text = scriptName
            btnText.TextColor3 = CONFIG.TextColor
            btnText.TextSize = 13
            btnText.Font = Enum.Font.Gotham
            btnText.TextXAlignment = Enum.TextXAlignment.Left
            btnText.Parent = btnFrame

            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 20, 1, 0)
            arrow.Position = UDim2.new(0.92, 0, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "›"
            arrow.TextColor3 = CONFIG.SecondaryText
            arrow.TextSize = 18
            arrow.Font = Enum.Font.GothamBold
            arrow.Parent = btnFrame

            local clickBtn = Instance.new("TextButton")
            clickBtn.Size = UDim2.new(1, 0, 1, 0)
            clickBtn.BackgroundTransparency = 1
            clickBtn.Text = ""
            clickBtn.Parent = btnFrame

            clickBtn.MouseButton1Click:Connect(function()
                self.Elements.StatusText.Text = "Запуск: " .. scriptName
                local success, err = pcall(scriptFunc)
                if success then
                    self.Elements.StatusText.Text = "Успешно: " .. scriptName
                else
                    self.Elements.StatusText.Text = "Ошибка: " .. tostring(err)
                end
                task.delay(3, function() self.Elements.StatusText.Text = "Система готова" end)
            end)

            clickBtn.MouseEnter:Connect(function()
                tween(btnFrame, {BackgroundTransparency = 0.1}, 0.2)
            end)
            clickBtn.MouseLeave:Connect(function()
                tween(btnFrame, {BackgroundTransparency = 0.3}, 0.2)
            end)
        end
    end

    scroll.CanvasSize = UDim2.new(0, 0, 0, #scripts * 50 + 10)
    scroll.CanvasPosition = Vector2.new(0, 0)
end

-- Handle Category Click
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
        self.Elements.CategoryScroll.Visible = false
        self.Elements.SubScroll.Visible = true
        self.Elements.SubTitle.Visible = true
        self.Elements.BackButton.Visible = true
        self.Elements.SearchBox.Parent.Visible = false

        CurrentSubScripts = result
        CurrentCategory = categoryName

        self:PopulateSubScripts(result, categoryName)
        self.Elements.StatusText.Text = categoryName .. " загружено"
    else
        self.Elements.StatusText.Text = categoryName .. " выполнено"
        task.delay(2, function() self.Elements.StatusText.Text = "Система готова" end)
    end
end

-- Go Back
function Gui:BackToCategories()
    self.Elements.CategoryScroll.Visible = true
    self.Elements.SubScroll.Visible = false
    self.Elements.SubTitle.Visible = false
    self.Elements.BackButton.Visible = false
    self.Elements.SearchBox.Parent.Visible = true

    CurrentSubScripts = nil
    CurrentCategory = nil
    self.Elements.StatusText.Text = "Система готова"
end

-- Toggle Window Animation
function Gui:ToggleWindow()
    local window = self.Elements.Window
    local btnLabel = self.Elements.ToggleButton:FindFirstChild("BtnLabel")

    if window.Visible then
        if btnLabel then btnLabel.Text = "Открыть" end
        tween(window, {Size = UDim2.new(0, 600, 0, 0), BackgroundTransparency = 1}, 0.25)
        task.wait(0.25)
        window.Visible = false
    else
        window.Visible = true
        if btnLabel then btnLabel.Text = "Закрыть" end
        window.Size = UDim2.new(0, 600, 0, 0)
        tween(window, {Size = CONFIG.WindowSize, BackgroundTransparency = 0.15}, 0.3, Enum.EasingStyle.Back)
    end
end

-- Draggable Functionality
function Gui:MakeDraggable()
    local window = self.Elements.Window
    local titleBar = self.Elements.TitleBar

    local dragging, dragStart, startPos

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

-- Initialize Hub
function Gui:Init()
    self.Container = GetSafeContainer()
    self.Elements = {}

    self.Elements.ToggleButton = self:CreateToggleButton()
    local parts = self:CreateMainWindow()
    for k, v in pairs(parts) do self.Elements[k] = v end

    self.Elements.ToggleButton.MouseButton1Click:Connect(function() self:ToggleWindow() end)
    self.Elements.CloseButton.MouseButton1Click:Connect(function() self:ToggleWindow() end)
    self.Elements.BackButton.MouseButton1Click:Connect(function() self:BackToCategories() end)

    self.Elements.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if self.Elements.CategoryScroll.Visible then
            self:PopulateCategories(self.Elements.SearchBox.Text)
        end
    end)

    self:MakeDraggable()
    self:LoadDatabase()
end

Gui:Init()
