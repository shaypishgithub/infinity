-- RussElite Main Interface - gui.lua
-- 3D Glass Black iPhone Style (2026 Aesthetic)

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
    Version = "v3.0",
    TextColor = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(160, 160, 160),
    Background = Color3.fromRGB(8, 8, 8),
    GlassTop = Color3.fromRGB(25, 25, 25), -- Для 3D эффекта сверху
    GlassBottom = Color3.fromRGB(5, 5, 5), -- Для тени снизу
    StrokeColor = Color3.fromRGB(60, 60, 60),
    WindowSize = UDim2.new(0, 650, 0, 460),
    BorderRadius = 16,
    BaseURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/base/base.lua"
}

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
        sg.Parent = playerGui
        return sg
    end
    return result
end

local function tween(obj, props, dur, style)
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.3, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- Функция применения 3D Glass эффекта
local function apply3DGlass(frame, isMainWindow)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    corner.Parent = frame

    -- Градиент для объема (свет сверху, тень снизу)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.GlassTop),
        ColorSequenceKeypoint.new(1, CONFIG.GlassBottom)
    })
    gradient.Rotation = 90
    gradient.Parent = frame

    -- Тонкая рамка
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.StrokeColor
    stroke.Transparency = 0.4
    stroke.Thickness = 1
    stroke.Parent = frame

    -- Блик света сверху (имитация кривизны стекла)
    if isMainWindow then
        local highlight = Instance.new("Frame")
        highlight.Name = "Highlight"
        highlight.Size = UDim2.new(1, 0, 0, 1)
        highlight.Position = UDim2.new(0, 0, 0, 0)
        highlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        highlight.BackgroundTransparency = 0.85
        highlight.BorderSizePixel = 0
        highlight.Parent = frame
        local hCorner = Instance.new("UICorner")
        hCorner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
        hCorner.Parent = highlight
    end
end

-- Создание кнопки открытия/закрытия (Стиль Dynamic Island)
function Gui:CreateToggleButton()
    -- Свечение позади кнопки
    local glow = Instance.new("Frame")
    glow.Name = "ToggleGlow"
    glow.Size = UDim2.new(0, 75, 0, 75)
    glow.Position = UDim2.new(0.935, -37, 0.5, -37)
    glow.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    glow.BackgroundTransparency = 0.85
    glow.Parent = self.Container
    Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton")
    btn.Name = "ToggleButton"
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0.935, -30, 0.5, -30)
    btn.BackgroundColor3 = CONFIG.Background
    btn.BackgroundTransparency = 0.05
    btn.Text = ""
    btn.Parent = self.Container
    apply3DGlass(btn, false)

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "RE"
    icon.TextColor3 = CONFIG.TextColor
    icon.TextSize = 22
    icon.Font = Enum.Font.GothamBold
    icon.Parent = btn

    -- Анимации кнопки
    btn.MouseEnter:Connect(function()
        tween(glow, {BackgroundTransparency = 0.7}, 0.3)
        tween(btn, {Size = UDim2.new(0, 65, 0, 65), Position = UDim2.new(0.935, -32, 0.5, -32)}, 0.2, Enum.EasingStyle.Back)
    end)
    btn.MouseLeave:Connect(function()
        tween(glow, {BackgroundTransparency = 0.85}, 0.3)
        tween(btn, {Size = UDim2.new(0, 60, 0, 60), Position = UDim2.new(0.935, -30, 0.5, -30)}, 0.2, Enum.EasingStyle.Back)
    end)

    return btn
end

-- Создание главного окна
function Gui:CreateMainWindow()
    -- Тень окна
    local shadow = Instance.new("Frame")
    shadow.Name = "WindowShadow"
    shadow.Size = CONFIG.WindowSize + UDim2.new(0, 20, 0, 20)
    shadow.Position = UDim2.new(0.5, -335, 0.5, -240)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.3
    shadow.Parent = self.Container
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, CONFIG.BorderRadius + 4)

    local window = Instance.new("Frame")
    window.Name = "MainWindow"
    window.Size = CONFIG.WindowSize
    window.Position = UDim2.new(0.5, -325, 0.5, -230)
    window.BackgroundColor3 = CONFIG.Background
    window.BackgroundTransparency = 0.05
    window.Visible = false
    window.ClipsDescendants = true
    window.Parent = self.Container
    apply3DGlass(window, true)

    -- Title bar (Стиль iOS)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    titleBar.BackgroundTransparency = 0.95
    titleBar.Parent = window

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0.5, 0, 1, 0)
    titleText.Position = UDim2.new(0.03, 0, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = CONFIG.Title
    titleText.TextColor3 = CONFIG.TextColor
    titleText.TextSize = 22
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(0.15, 0, 1, 0)
    version.Position = UDim2.new(0.4, 0, 0, 0)
    version.BackgroundTransparency = 1
    version.Text = CONFIG.Version
    version.TextColor3 = CONFIG.Accent
    version.TextSize = 12
    version.Font = Enum.Font.GothamMedium
    version.TextTransparency = 0.5
    version.Parent = titleBar

    -- Кнопка закрытия (Минималистичный крестик)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(0, -5, 0.5, -14)
    closeBtn.AnchorPoint = Vector2.new(0, 0.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = CONFIG.TextColor
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

    -- Поиск (Стеклянная капсула)
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(0.94, 0, 0, 34)
    searchFrame.Position = UDim2.new(0.03, 0, 0, 52)
    searchFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    searchFrame.Parent = window
    apply3DGlass(searchFrame, false)

    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(0.9, 0, 1, 0)
    searchBox.Position = UDim2.new(0.05, 0, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.PlaceholderText = "Поиск скриптов..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    searchBox.Text = ""
    searchBox.TextColor3 = CONFIG.TextColor
    searchBox.TextSize = 14
    searchBox.Font = Enum.Font.Gotham
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = searchFrame

    -- Область контента
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(0.94, 0, 1, -135)
    contentArea.Position = UDim2.new(0.03, 0, 0, 94)
    contentArea.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    contentArea.BackgroundTransparency = 0.98
    contentArea.ClipsDescendants = true
    contentArea.Parent = window

    local backBtn = Instance.new("TextButton")
    backBtn.Name = "BackButton"
    backBtn.Size = UDim2.new(0, 85, 0, 28)
    backBtn.Position = UDim2.new(0, 0, 0, 0)
    backBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    backBtn.BackgroundTransparency = 0.2
    backBtn.Text = "◀ Назад"
    backBtn.TextColor3 = CONFIG.TextColor
    backBtn.TextSize = 13
    backBtn.Font = Enum.Font.GothamBold
    backBtn.Visible = false
    backBtn.Parent = contentArea
    Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 10)

    -- Сетка категорий
    local categoryScroll = Instance.new("ScrollingFrame")
    categoryScroll.Name = "CategoryScroll"
    categoryScroll.Size = UDim2.new(1, 0, 1, 0)
    categoryScroll.BackgroundTransparency = 1
    categoryScroll.ScrollBarThickness = 3
    categoryScroll.ScrollBarImageColor3 = CONFIG.Accent
    categoryScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    categoryScroll.Parent = contentArea

    local categoryGrid = Instance.new("UIGridLayout")
    categoryGrid.CellSize = UDim2.new(0, 140, 0, 100)
    categoryGrid.CellPadding = UDim2.new(0, 10, 0, 10)
    categoryGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    categoryGrid.SortOrder = Enum.SortOrder.Name
    categoryGrid.Parent = categoryScroll

    -- Список скриптов
    local subScroll = Instance.new("ScrollingFrame")
    subScroll.Name = "SubScriptScroll"
    subScroll.Size = UDim2.new(1, 0, 1, -35)
    subScroll.Position = UDim2.new(0, 0, 0, 35)
    subScroll.BackgroundTransparency = 1
    subScroll.ScrollBarThickness = 3
    subScroll.ScrollBarImageColor3 = CONFIG.Accent
    subScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    subScroll.Visible = false
    subScroll.Parent = contentArea

    local subList = Instance.new("UIListLayout")
    subList.SortOrder = Enum.SortOrder.Name
    subList.Padding = UDim.new(0, 8)
    subList.Parent = subScroll

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

    -- Статус бар (Стиль Home Indicator iPhone)
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(0.4, 0, 0, 4)
    statusBar.Position = UDim2.new(0.3, 0, 0.97, -10)
    statusBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    statusBar.BackgroundTransparency = 0.6
    statusBar.Parent = window
    Instance.new("UICorner", statusBar).CornerRadius = UDim.new(1, 0)

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(0.9, 0, 0, 20)
    statusText.Position = UDim2.new(0.05, 0, 0.96, -28)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Готово"
    statusText.TextColor3 = CONFIG.Accent
    statusText.TextSize = 11
    statusText.Font = Enum.Font.GothamMedium
    statusText.TextTransparency = 0.5
    statusText.Parent = window

    return {
        Window = window,
        Shadow = shadow,
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

-- Логика базы данных и скриптов (Сохранена оригинальная функциональность)
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
        task.delay(2, function() self.Elements.StatusText.Text = "Готово" end)
    else
        self.Elements.StatusText.Text = "Ошибка загрузки!"
        warn("Database error:", result)
    end
end

function Gui:PopulateCategories(filter)
    local scroll = self.Elements.CategoryScroll
    for _, child in ipairs(scroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    if not Database or not Database.categories then return end
    
    local searchText = (filter or ""):lower()
    local categories = {}
    for name, _ in pairs(Database.categories) do table.insert(categories, name) end
    table.sort(categories)
    
    local count = 0
    local columns = math.max(1, math.floor(scroll.AbsoluteSize.X / 150))
    
    for _, name in ipairs(categories) do
        if searchText == "" or name:lower():find(searchText, 1, true) then
            local card = Instance.new("Frame")
            card.Size = UDim2.new(0, 140, 0, 100)
            card.BackgroundColor3 = CONFIG.Background
            card.BackgroundTransparency = 0.1
            card.Parent = scroll
            apply3DGlass(card, true)
            
            local iconId = Database.imageIds and Database.imageIds[name]
            if iconId then
                local icon = Instance.new("ImageLabel")
                icon.Size = UDim2.new(0, 50, 0, 50)
                icon.Position = UDim2.new(0.5, -25, 0.05, 0)
                icon.BackgroundTransparency = 1
                icon.Image = iconId
                icon.ScaleType = Enum.ScaleType.Fit
                icon.Parent = card
            end
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 0, 20)
            label.Position = UDim2.new(0, 5, 0, 70)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = CONFIG.TextColor
            label.TextSize = 12
            label.Font = Enum.Font.GothamBold
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.Parent = card
            
            local clickBtn = Instance.new("TextButton")
            clickBtn.Size = UDim2.new(1, 0, 1, 0)
            clickBtn.BackgroundTransparency = 1
            clickBtn.Text = ""
            clickBtn.Parent = card
            
            clickBtn.MouseButton1Click:Connect(function() self:OnCategoryClick(name) end)
            clickBtn.MouseEnter:Connect(function() tween(card, {BackgroundTransparency = 0.0}, 0.2) end)
            clickBtn.MouseLeave:Connect(function() tween(card, {BackgroundTransparency = 0.1}, 0.2) end)
            count = count + 1
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(count / columns) * 110 + 10)
end

function Gui:PopulateSubScripts(scripts, categoryName)
    local scroll = self.Elements.SubScroll
    for _, child in ipairs(scroll:GetChildren()) do if child:IsA("TextButton") or child:IsA("Frame") then child:Destroy() end end
    self.Elements.SubTitle.Text = "📜 " .. categoryName .. " (" .. #scripts .. ")"
    
    for _, script in ipairs(scripts) do
        if type(script) == "table" and #script >= 2 then
            local scriptName = tostring(script[1])
            local scriptFunc = script[2]
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.96, 0, 0, 40)
            btn.BackgroundColor3 = CONFIG.Background
            btn.BackgroundTransparency = 0.1
            btn.Text = "   " .. scriptName
            btn.TextColor3 = CONFIG.TextColor
            btn.TextSize = 14
            btn.Font = Enum.Font.Gotham
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = scroll
            apply3DGlass(btn, false)

            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 20, 1, 0)
            arrow.Position = UDim2.new(0.95, -20, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▶"
            arrow.TextColor3 = CONFIG.Accent
            arrow.TextSize = 12
            arrow.Font = Enum.Font.GothamBold
            arrow.Parent = btn

            btn.MouseButton1Click:Connect(function()
                self.Elements.StatusText.Text = "Выполнение: " .. scriptName
                local success, err = pcall(scriptFunc)
                if success then
                    self.Elements.StatusText.Text = scriptName .. " выполнен!"
                    self.Elements.StatusText.TextColor3 = Color3.fromRGB(100, 220, 100)
                else
                    self.Elements.StatusText.Text = "Ошибка: " .. tostring(err)
                    self.Elements.StatusText.TextColor3 = Color3.fromRGB(255, 80, 80)
                end
                task.delay(3, function()
                    self.Elements.StatusText.Text = "Готово"
                    self.Elements.StatusText.TextColor3 = CONFIG.Accent
                end)
            end)
            btn.MouseEnter:Connect(function() tween(btn, {BackgroundTransparency = 0.0}, 0.15) end)
            btn.MouseLeave:Connect(function() tween(btn, {BackgroundTransparency = 0.1}, 0.15) end)
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, #scripts * 48 + 10)
    scroll.CanvasPosition = Vector2.new(0, 0)
end

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
        self.Elements.StatusText.TextColor3 = Color3.fromRGB(255, 80, 80)
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
        self.Elements.StatusText.Text = categoryName .. " загружено!"
    else
        self.Elements.StatusText.Text = categoryName .. " выполнен!"
        task.delay(2, function() self.Elements.StatusText.Text = "Готово" end)
    end
end

function Gui:BackToCategories()
    self.Elements.CategoryScroll.Visible = true
    self.Elements.SubScroll.Visible = false
    self.Elements.SubTitle.Visible = false
    self.Elements.BackButton.Visible = false
    self.Elements.SearchBox.Visible = true
    CurrentSubScripts = nil
    CurrentCategory = nil
    self.Elements.StatusText.Text = "Готово"
    self.Elements.StatusText.TextColor3 = CONFIG.Accent
end

function Gui:ToggleWindow()
    local win = self.Elements.Window
    local shad = self.Elements.Shadow
    if win.Visible then
        tween(win, {Size = UDim2.new(0, 600, 0, 420)}, 0.2)
        tween(shad, {Size = UDim2.new(0, 620, 0, 440)}, 0.2)
        task.wait(0.2)
        win.Visible = false
        shad.Visible = false
    else
        shad.Visible = true
        win.Visible = true
        win.Size = UDim2.new(0, 600, 0, 420)
        shad.Size = UDim2.new(0, 620, 0, 440)
        tween(win, {Size = CONFIG.WindowSize}, 0.35, Enum.EasingStyle.Back)
        tween(shad, {Size = CONFIG.WindowSize + UDim2.new(0, 20, 0, 20)}, 0.35, Enum.EasingStyle.Back)
    end
end

function Gui:MakeDraggable()
    local window = self.Elements.Window
    local titleBar = self.Elements.TitleBar
    local shadow = self.Elements.Shadow
    local dragging, dragStart, startPos = false, nil, nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            shadow.Position = window.Position + UDim2.new(0, -10, 0, -10)
        end
    end)
end

function Gui:Init()
    self.Container = GetSafeContainer()
    self.Elements = {}
    self.Elements.ToggleButton = self:CreateToggleButton()
    local winParts = self:CreateMainWindow()
    for k, v in pairs(winParts) do self.Elements[k] = v end
    
    self.Elements.ToggleButton.MouseButton1Click:Connect(function() self:ToggleWindow() end)
    self.Elements.CloseButton.MouseButton1Click:Connect(function() self:ToggleWindow() end)
    self.Elements.BackButton.MouseButton1Click:Connect(function() self:BackToCategories() end)
    
    self.Elements.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if self.Elements.CategoryScroll.Visible then self:PopulateCategories(self.Elements.SearchBox.Text) end
    end)
    
    self:MakeDraggable()
    self:LoadDatabase()
end

Gui:Init()
