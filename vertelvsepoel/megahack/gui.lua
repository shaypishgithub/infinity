-- ══════════════════════════════════════════════════════════════════
--  gui.lua  —  RussElite Modern Glass UI (Полностью с нуля)
--  Черное стекло, белый текст, открытие/закрытие, детект Executor
-- ══════════════════════════════════════════════════════════════════
return function(deps)
    local TweenService       = deps.TweenService
    local UserInputService   = deps.UserInputService
    local CoreGui            = deps.CoreGui
    local MarketplaceService = deps.MarketplaceService
    local playerGui          = deps.playerGui
    local T                  = deps.T
    local regA               = deps.regA
    local HubData            = deps.HubData

    -- ════════════════════════════════════════
    --  УТИЛИТЫ (Быстрое стекло без лагов)
    -- ════════════════════════════════════════
    local function mkCorner(parent, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 12)
        c.Parent = parent
        return c
    end

    local function mkStroke(parent, thickness, color, alpha)
        local s = Instance.new("UIStroke")
        s.Thickness = thickness or 1
        s.Color = color or Color3.new(1, 1, 1)
        s.Transparency = alpha or 0.80
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = parent
        return s
    end

    -- Мгновенный Glass-эффект (не фрейм, а градиент поверх цвета!)
    local function mkGlass(parent)
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0.9, 0.9, 0.95))
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.80),   -- Верх: яркий белый блик
            NumberSequenceKeypoint.new(0.5, 0.90), -- Середина: затухание
            NumberSequenceKeypoint.new(1, 0.96)    -- Низ: почти прозрачный
        })
        g.Rotation = 90
        g.Parent = parent
        return g
    end

    local TWEEN_F = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- ════════════════════════════════════════
    --  СТАНДАРТНЫЕ ЭЛЕМЕНТЫ
    -- ════════════════════════════════════════
    local function createLabel(parent, text, size, pos, color, fontSize, isMain)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Text = text or ""
        l.Size = size or UDim2.new(1, 0, 0, 20)
        l.Position = pos or UDim2.new(0, 0, 0, 0)
        l.TextColor3 = color or Color3.new(1, 1, 1)
        l.Font = Enum.Font.GothamBold
        l.TextSize = fontSize or 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 5
        l.Parent = parent
        if isMain then l:SetAttribute("TextRole", "main") end
        return l
    end

    local function createSectionHeader(text, parent)
        local c = Instance.new("Frame")
        c.BackgroundTransparency = 1
        c.Size = UDim2.new(1, 0, 0, 28)
        c.ZIndex = 4
        c.Parent = parent

        local pip = Instance.new("Frame")
        pip.BackgroundColor3 = T.Accent
        pip.BackgroundTransparency = 0
        pip.Size = UDim2.new(0, 3, 0, 14)
        pip.Position = UDim2.new(0, 0, 0.5, -7)
        pip.ZIndex = 5
        pip.Parent = c
        mkCorner(pip, 2)
        regA(pip)

        createLabel(c, string.upper(text), UDim2.new(1, -12, 1, 0), UDim2.new(0, 10, 0, 0), T.TextSub, 10)
        return c
    end

    -- ════════════════════════════════════════
    --  SCREEN GUI & ЗАЩИТА
    -- ════════════════════════════════════════
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RussElite_GUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false

    pcall(function()
        if get_hidden_gui then screenGui.Parent = get_hidden_gui()
        elseif gethui then screenGui.Parent = gethui()
        elseif syn and syn.protect_gui then syn.protect_gui(screenGui); screenGui.Parent = CoreGui
        else screenGui.Parent = CoreGui end
    end)
    if not screenGui.Parent then screenGui.Parent = CoreGui end

    -- ════════════════════════════════════════
    --  ГЛАВНЫЙ ФРЕЙМ (Черное стекло)
    -- ════════════════════════════════════════
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16) -- Глубокий черный
    mainFrame.BackgroundTransparency = 0.03
    mainFrame.BorderSizePixel = 0
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size = UDim2.new(0, 600, 0, 420)
    mainFrame.ZIndex = 2
    mainFrame.Parent = screenGui
    mkCorner(mainFrame, 16)
    mkStroke(mainFrame, 1, Color3.new(1, 1, 1), 0.75) -- Белая обводка стекла
    mkGlass(mainFrame) -- Накладываем блик

    -- Полоска акцента снизу
    local accentBar = Instance.new("Frame")
    accentBar.BackgroundColor3 = T.Accent
    accentBar.BackgroundTransparency = 0.2
    accentBar.Size = UDim2.new(0.4, 0, 0, 2)
    accentBar.Position = UDim2.new(0.3, 0, 1, -3)
    accentBar.ZIndex = 4
    accentBar.Parent = mainFrame
    mkCorner(accentBar, 2)
    regA(accentBar)

    -- ════════════════════════════════════════
    --  ШАПКА (Заголовок + Кнопка Закрыть)
    -- ════════════════════════════════════════
    local headerFrame = Instance.new("Frame")
    headerFrame.BackgroundTransparency = 1
    headerFrame.Size = UDim2.new(1, 0, 0, 50)
    headerFrame.ZIndex = 5
    headerFrame.Parent = mainFrame

    -- Разделитель под шапкой
    local headerLine = Instance.new("Frame")
    headerLine.BackgroundColor3 = Color3.new(1, 1, 1)
    headerLine.BackgroundTransparency = 0.90
    headerLine.Size = UDim2.new(1, -20, 0, 1)
    headerLine.Position = UDim2.new(0, 10, 1, 0)
    headerLine.ZIndex = 6
    headerLine.Parent = headerFrame

    -- Название
    createLabel(headerFrame, "RUSSELITE", UDim2.new(0, 120, 0, 20), UDim2.new(0, 16, 0.5, -10), Color3.new(1, 1, 1), 16, true)

    -- Бейдж версии
    local verBadge = Instance.new("Frame")
    verBadge.BackgroundColor3 = T.Accent
    verBadge.BackgroundTransparency = 0.15
    verBadge.Size = UDim2.new(0, 36, 0, 16)
    verBadge.Position = UDim2.new(0, 140, 0.5, -8)
    verBadge.ZIndex = 8
    verBadge.Parent = headerFrame
    mkCorner(verBadge, 6)
    regA(verBadge)
    createLabel(verBadge, "v3.0", UDim2.new(1, 0, 1, 0), nil, Color3.new(1, 1, 1), 9, true)

    -- Инфо справа (Игрок и Игра)
    local player = deps.player
    createLabel(headerFrame, "@" .. player.Name, UDim2.new(0, 100, 0, 14), UDim2.new(1, -180, 0.5, -14), T.TextSub, 10)
    
    local ok_g, gname = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId).Name end)
    createLabel(headerFrame, ok_g and gname or "Unknown Game", UDim2.new(0, 140, 0, 14), UDim2.new(1, -180, 0.5, 4), T.TextMuted, 9)

    -- Кнопка Закрыть (Крестик)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.Position = UDim2.new(1, -36, 0.5, -13)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 22
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = 10
    closeBtn.Parent = headerFrame
    mkCorner(closeBtn, 13)
    closeBtn:SetAttribute("TextRole", "main")
    
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TWEEN_F, {BackgroundTransparency = 0.05, BackgroundColor3 = Color3.fromRGB(240, 40, 40)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TWEEN_F, {BackgroundTransparency = 0.3, BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
    end)

    -- ════════════════════════════════════════
    --  САЙДБАР (Меню слева)
    -- ════════════════════════════════════════
    local sidebarFrame = Instance.new("Frame")
    sidebarFrame.Name = "SidebarFrame"
    sidebarFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 22) -- Чуть светлее черного
    sidebarFrame.BackgroundTransparency = 0.05
    sidebarFrame.Size = UDim2.new(0, 150, 1, -50)
    sidebarFrame.Position = UDim2.new(0, 0, 0, 50)
    sidebarFrame.ZIndex = 3
    sidebarFrame.Parent = mainFrame
    mkCorner(sidebarFrame, 12)
    mkGlass(sidebarFrame)

    local sidebarSep = Instance.new("Frame")
    sidebarSep.BackgroundColor3 = Color3.new(1, 1, 1)
    sidebarSep.BackgroundTransparency = 0.94
    sidebarSep.Size = UDim2.new(0, 1, 1, -20)
    sidebarSep.Position = UDim2.new(1, -1, 0, 10)
    sidebarSep.ZIndex = 4
    sidebarSep.Parent = sidebarFrame

    local catScroll = Instance.new("ScrollingFrame")
    catScroll.BackgroundTransparency = 1
    catScroll.Size = UDim2.new(1, -6, 1, -12)
    catScroll.Position = UDim2.new(0, 6, 0, 6)
    catScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    catScroll.ScrollBarThickness = 0
    catScroll.ZIndex = 5
    catScroll.Parent = sidebarFrame

    local catLayout = Instance.new("UIListLayout")
    catLayout.Padding = UDim.new(0, 4)
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    catLayout.Parent = catScroll

    local catPad = Instance.new("UIPadding")
    catPad.PaddingLeft = UDim.new(0, 6)
    catPad.PaddingRight = UDim.new(0, 6)
    catPad.PaddingTop = UDim.new(0, 4)
    catPad.PaddingBottom = UDim.new(0, 4)
    catPad.Parent = catScroll

    catLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        catScroll.CanvasSize = UDim2.new(0, 0, 0, catLayout.AbsoluteContentSize.Y + 16)
    end)

    -- ════════════════════════════════════════
    --  КОНТЕНТ ПАНЕЛЬ (Справа)
    -- ════════════════════════════════════════
    local contentFrame = Instance.new("Frame")
    contentFrame.BackgroundTransparency = 1
    contentFrame.Size = UDim2.new(1, -162, 1, -62)
    contentFrame.Position = UDim2.new(0, 156, 0, 56)
    contentFrame.ZIndex = 3
    contentFrame.Parent = mainFrame

    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.ScrollBarThickness = 2
    scrollingFrame.ScrollBarImageColor3 = T.Accent
    scrollingFrame.ZIndex = 3
    scrollingFrame.Parent = contentFrame
    regA(scrollingFrame, "ScrollBarImageColor3")

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Padding = UDim.new(0, 6)
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Parent = scrollingFrame

    local scrollPad = Instance.new("UIPadding")
    scrollPad.PaddingLeft = UDim.new(0, 4)
    scrollPad.PaddingRight = UDim.new(0, 8)
    scrollPad.PaddingTop = UDim.new(0, 4)
    scrollPad.PaddingBottom = UDim.new(0, 8)
    scrollPad.Parent = scrollingFrame

    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 16)
    end)

    -- Панель для игр (скрыта по умолчанию)
    local gamesPanel = Instance.new("ScrollingFrame")
    gamesPanel.Name = "GamesPanel"
    gamesPanel.BackgroundTransparency = 1
    gamesPanel.Size = UDim2.new(1, 0, 1, 0)
    gamesPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
    gamesPanel.ScrollBarThickness = 2
    gamesPanel.ScrollBarImageColor3 = T.Accent
    gamesPanel.Visible = false
    gamesPanel.ZIndex = 3
    gamesPanel.Parent = contentFrame
    regA(gamesPanel, "ScrollBarImageColor3")

    local gamesGrid = Instance.new("UIGridLayout")
    gamesGrid.CellSize = UDim2.new(0, 130, 0, 100)
    gamesGrid.CellPadding = UDim2.new(0, 8, 0, 8)
    gamesGrid.SortOrder = Enum.SortOrder.LayoutOrder
    gamesGrid.Parent = gamesPanel

    local gamesPad = Instance.new("UIPadding")
    gamesPad.PaddingLeft = UDim.new(0, 4)
    gamesPad.PaddingTop = UDim.new(0, 4)
    gamesPad.PaddingRight = UDim.new(0, 4)
    gamesPad.PaddingBottom = UDim.new(0, 4)
    gamesPad.Parent = gamesPanel

    gamesGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        gamesPanel.CanvasSize = UDim2.new(0, 0, 0, gamesGrid.AbsoluteContentSize.Y + 20)
    end)

    -- ════════════════════════════════════════
    --  КНОПКА ОТКРЫТЬ (Плавающая)
    -- ════════════════════════════════════════
    local reopenButton = Instance.new("TextButton")
    reopenButton.Name = "ReopenBtn"
    reopenButton.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    reopenButton.BackgroundTransparency = 0.05
    reopenButton.Size = UDim2.new(0, 48, 0, 48)
    reopenButton.Position = UDim2.new(0.5, -24, 0.5, -24)
    reopenButton.Text = ""
    reopenButton.Visible = false
    reopenButton.ZIndex = 12
    reopenButton.Parent = screenGui
    mkCorner(reopenButton, 24)
    mkGlass(reopenButton)
    
    local reopenStroke = mkStroke(reopenButton, 1.5, T.Accent, 0.25)
    regA(reopenStroke, "Color")

    -- Иконка внутри
    local reIcon = Instance.new("ImageLabel")
    reIcon.Size = UDim2.new(0, 22, 0, 22)
    reIcon.Position = UDim2.new(0.5, -11, 0.5, -11)
    reIcon.BackgroundTransparency = 1
    reIcon.Image = "rbxassetid://74283928898866"
    reIcon.ImageColor3 = Color3.new(1, 1, 1)
    reIcon.ZIndex = 13
    reIcon.Parent = reopenButton

    reopenButton.MouseEnter:Connect(function()
        TweenService:Create(reopenButton, TWEEN_F, {BackgroundColor3 = T.Accent, BackgroundTransparency = 0.1}):Play()
    end)
    reopenButton.MouseLeave:Connect(function()
        TweenService:Create(reopenButton, TWEEN_F, {BackgroundColor3 = Color3.fromRGB(16, 16, 22), BackgroundTransparency = 0.05}):Play()
    end)

    -- ════════════════════════════════════════
    --  БАЗОВЫЙ СТРОИТЕЛЬ КНОПОК (Для скриптов)
    -- ════════════════════════════════════════
    local function createButton(text, parent, callback, isCategory)
        if isCategory then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3 = T.Accent
            btn.BackgroundTransparency = 1
            btn.Text = text
            btn.TextColor3 = T.TextSub
            btn.TextSize = 11
            btn.Font = Enum.Font.GothamMedium
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.ZIndex = 6
            btn.Parent = parent
            mkCorner(btn, 8)

            local btnPad = Instance.new("UIPadding")
            btnPad.PaddingLeft = UDim.new(0, 12)
            btnPad.Parent = btn

            btn.MouseEnter:Connect(function()
                if not btn:GetAttribute("Active") then
                    TweenService:Create(btn, TWEEN_F, {BackgroundTransparency = 0.85, TextColor3 = Color3.new(1,1,1)}):Play()
                end
            end)
            btn.MouseLeave:Connect(function()
                if not btn:GetAttribute("Active") then
                    TweenService:Create(btn, TWEEN_F, {BackgroundTransparency = 1, TextColor3 = T.TextSub}):Play()
                end
            end)
            btn.MouseButton1Click:Connect(function()
                for _, child in ipairs(parent:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:SetAttribute("Active", false)
                        TweenService:Create(child, TWEEN_F, {BackgroundTransparency = 1, TextColor3 = T.TextSub}):Play()
                    end
                end
                btn:SetAttribute("Active", true)
                TweenService:Create(btn, TWEEN_F, {BackgroundTransparency = 0.75, TextColor3 = T.Accent}):Play()
                if callback then callback() end
            end)
            return btn
        else
            -- Обычная кнопка скрипта (стеклянная)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 38)
            btn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
            btn.BackgroundTransparency = 0.1
            btn.Text = ""
            btn.ZIndex = 4
            btn.Parent = parent
            mkCorner(btn, 10)
            mkStroke(btn, 1, Color3.new(1, 1, 1), 0.82)
            mkGlass(btn)

            local leftBar = Instance.new("Frame")
            leftBar.BackgroundColor3 = T.Accent
            leftBar.BackgroundTransparency = 1
            leftBar.Size = UDim2.new(0, 3, 1, -12)
            leftBar.Position = UDim2.new(0, 0, 0, 6)
            leftBar.ZIndex = 5
            leftBar.Parent = btn
            mkCorner(leftBar, 2)
            regA(leftBar)

            local label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1
            label.Text = text
            label.Font = Enum.Font.Gotham
            label.TextSize = 13
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Size = UDim2.new(1, -26, 1, 0)
            label.Position = UDim2.new(0, 16, 0, 0)
            label.ZIndex = 6
            label.Parent = btn
            label:SetAttribute("TextRole", "main")

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TWEEN_F, {BackgroundTransparency = 0.0}):Play()
                TweenService:Create(leftBar, TWEEN_F, {BackgroundTransparency = 0}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TWEEN_F, {BackgroundTransparency = 0.1}):Play()
                TweenService:Create(leftBar, TWEEN_F, {BackgroundTransparency = 1}):Play()
            end)
            
            btn.MouseButton1Click:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.05), {BackgroundColor3 = T.Accent, BackgroundTransparency = 0.15}):Play()
                task.delay(0.1, function()
                    TweenService:Create(btn, TWEEN_F, {BackgroundColor3 = Color3.fromRGB(18, 18, 24), BackgroundTransparency = 0.0}):Play()
                end)
                if callback then callback() end
            end)
            return btn
        end
    end

    -- ════════════════════════════════════════
    --  КАРТОЧКИ ИГР
    -- ════════════════════════════════════════
    local function createGameCard(gameName, placeId, onClick)
        local card = Instance.new("TextButton")
        card.Name = "GameCard_" .. gameName
        card.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        card.BackgroundTransparency = 0.1
        card.Text = ""
        card.ZIndex = 4
        card.Parent = gamesPanel
        mkCorner(card, 10)
        local cs = mkStroke(card, 1, Color3.new(1, 1, 1), 0.82)
        mkGlass(card)

        local thumb = Instance.new("ImageLabel")
        thumb.Name = "GameCardBg"
        thumb.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        thumb.Size = UDim2.new(1, 0, 0, 64)
        thumb.Image = ""
        thumb.ImageTransparency = 1
        thumb.ScaleType = Enum.ScaleType.Crop
        thumb.ZIndex = 5
        thumb.Parent = card
        mkCorner(thumb, 10)

        local nameLbl = Instance.new("TextLabel")
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = gameName
        nameLbl.Font = Enum.Font.GothamMedium
        nameLbl.TextSize = 10
        nameLbl.TextColor3 = Color3.new(1, 1, 1)
        nameLbl.TextXAlignment = Enum.TextXAlignment.Center
        nameLbl.TextWrapped = true
        nameLbl.Size = UDim2.new(1, -4, 0, 30)
        nameLbl.Position = UDim2.new(0, 2, 1, -30)
        nameLbl.ZIndex = 7
        nameLbl.Parent = card
        nameLbl:SetAttribute("TextRole", "main")

        card.MouseEnter:Connect(function()
            TweenService:Create(card, TWEEN_F, {BackgroundTransparency = 0.0, BackgroundColor3 = Color3.fromRGB(28, 28, 38)}):Play()
            TweenService:Create(cs, TWEEN_F, {Color = T.Accent, Transparency = 0.4}):Play()
        end)
        card.MouseLeave:Connect(function()
            TweenService:Create(card, TWEEN_F, {BackgroundTransparency = 0.1, BackgroundColor3 = Color3.fromRGB(18, 18, 24)}):Play()
            TweenService:Create(cs, TWEEN_F, {Color = Color3.new(1, 1, 1), Transparency = 0.82}):Play()
        end)
        
        card.MouseButton1Click:Connect(function()
            if onClick then onClick() end
        end)

        return card, thumb
    end

    -- ════════════════════════════════════════
    --  ЭКСПОРТ ДЛЯ ДРУГИХ МОДУЛЕЙ
    -- ════════════════════════════════════════
    return {
        screenGui      = screenGui,
        mainFrame      = mainFrame,
        headerFrame    = headerFrame,
        sidebarFrame   = sidebarFrame,
        catScroll      = catScroll,
        contentFrame   = contentFrame,
        scrollingFrame = scrollingFrame,
        gamesPanel     = gamesPanel,
        closeBtn       = closeBtn,
        reopenButton   = reopenButton,
        gameName       = ok_g and gname or "Unknown",

        mkCorner            = mkCorner,
        mkStroke            = mkStroke,
        mkGlass             = mkGlass,
        createButton        = createButton,
        createLabel         = createLabel,
        createSectionHeader = createSectionHeader,
        createGameCard      = createGameCard,
    }
end
