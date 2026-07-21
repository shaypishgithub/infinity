-- ══════════════════════════════════════════════════════════════════
--  gui.lua  —  UI Construction v2 (RussElite Optimized Glass)
--  FIXED:
--    • regA принимает (obj, prop) — prop необязателен (default BackgroundColor3)
--    • dummyPatch объявлен до return {}
--    • closeBtn.Name = "CloseBtn" (совпадает с theme.lua)
--    • gameName корректно экспортируется
--    • ВНЕСЕНО: Замена mkGlassSheen на быстрый UIGradient (0 лагов)
--    • ВНЕСЕНО: Кнопка Reopen переведена на TextButton для синхрона с theme.lua
-- ══════════════════════════════════════════════════════════════════
return function(deps)
    local TweenService       = deps.TweenService
    local UserInputService   = deps.UserInputService
    local CoreGui            = deps.CoreGui
    local MarketplaceService = deps.MarketplaceService
    local playerGui          = deps.playerGui
    local platformName       = deps.platformName
    local T                  = deps.T
    local regA               = deps.regA   -- function(obj, prop?)
    local HubData            = deps.HubData

    local createNotification = function() end  -- stub, заменяется через setNotification()

    -- ─────────────────────────────────────────
    --  CONSTANTS
    -- ─────────────────────────────────────────
    local CORNER   = 16 -- Чуть больше для современного стиля
    local CORNER_S = 10
    local TWEEN_F  = TweenInfo.new(0.18, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)
    local TWEEN_M  = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    -- ─────────────────────────────────────────
    --  LOW-LEVEL BUILDERS
    -- ─────────────────────────────────────────
    local function mkCorner(parent, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or CORNER)
        c.Parent = parent
        return c
    end

    local function mkStroke(parent, thickness, color, alpha)
        local s = Instance.new("UIStroke")
        s.Thickness       = thickness or 1
        s.Color           = color or Color3.new(1,1,1)
        s.Transparency    = alpha or 0.85
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent          = parent
        return s
    end

    local function mkGradient(parent, keypoints, rotation)
        local g = Instance.new("UIGradient")
        g.Transparency = NumberSequence.new(keypoints)
        g.Rotation     = rotation or 0
        g.Parent       = parent
        return g
    end

    -- НОВОЕ: Оптимизированный Glass Effect (без создания лишних фреймов)
    local function mkGlassEffect(parent)
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(0.95,0.95,1))
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.82),
            NumberSequenceKeypoint.new(0.5, 0.88),
            NumberSequenceKeypoint.new(1, 0.94)
        })
        g.Rotation = 90
        g.Parent = parent
        return g
    end

    local function countScripts()
        local n = 0
        for _, cat in pairs(HubData) do
            if type(cat) == "table" then n = n + #cat end
        end
        return n
    end

    -- ─────────────────────────────────────────
    --  SCREEN GUI + PROTECTION
    -- ─────────────────────────────────────────
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name           = "RussElite_GUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn   = false

    local function protectGui(g)
        local ok = pcall(function()
            if get_hidden_gui then
                g.Parent = get_hidden_gui()
            elseif gethui then
                g.Parent = gethui()
            elseif syn and typeof(syn) == "table" and syn.protect_gui then
                syn.protect_gui(g); g.Parent = CoreGui
            else
                g.Parent = CoreGui
            end
        end)
        if not ok then g.Parent = CoreGui end
    end
    protectGui(screenGui)

    -- ─────────────────────────────────────────
    --  MAIN FRAME
    -- ─────────────────────────────────────────
    local mainFrame = Instance.new("Frame")
    mainFrame.Name                   = "MainFrame"
    mainFrame.BackgroundColor3       = T.BgBase
    mainFrame.BackgroundTransparency = 0.04 -- Чуть прозрачнее для стекла
    mainFrame.BorderSizePixel        = 0
    mainFrame.AnchorPoint            = Vector2.new(0.5, 0.5)
    mainFrame.Position               = UDim2.new(0.5,0,0.5,0)
    mainFrame.Size                   = UDim2.new(0,590,0,400)
    mainFrame.ZIndex                 = 2
    mainFrame.Parent                 = screenGui
    mkCorner(mainFrame, CORNER)
    mkStroke(mainFrame, 1, Color3.new(1,1,1), 0.80)
    mkGlassEffect(mainFrame) -- Быстрый стеклянный блик

    local accentBar = Instance.new("Frame")
    accentBar.Name                   = "AccentBar"
    accentBar.BackgroundColor3       = T.Accent
    accentBar.BackgroundTransparency = 0.20
    accentBar.BorderSizePixel        = 0
    accentBar.Size                   = UDim2.new(0.38,0,0,2)
    accentBar.Position               = UDim2.new(0.31,0,1,-3)
    accentBar.ZIndex                 = 4
    accentBar.Parent                 = mainFrame
    mkCorner(accentBar, 2)
    regA(accentBar)

    -- ─────────────────────────────────────────
    --  HEADER  (52px)
    -- ─────────────────────────────────────────
    local headerFrame = Instance.new("Frame")
    headerFrame.Name                   = "HeaderFrame"
    headerFrame.BackgroundTransparency = 1
    headerFrame.Size                   = UDim2.new(1,0,0,52)
    headerFrame.ZIndex                 = 5
    headerFrame.Parent                 = mainFrame

    local headerLine = Instance.new("Frame")
    headerLine.BackgroundColor3       = Color3.new(1,1,1)
    headerLine.BackgroundTransparency = 0.90
    headerLine.BorderSizePixel        = 0
    headerLine.Size                   = UDim2.new(1,-24,0,1)
    headerLine.Position               = UDim2.new(0,12,1,0)
    headerLine.ZIndex                 = 6
    headerLine.Parent                 = headerFrame

    local logoIcon = Instance.new("ImageLabel")
    logoIcon.BackgroundTransparency = 1
    logoIcon.Image    = "rbxassetid://7072717762"
    logoIcon.Size     = UDim2.new(0,20,0,20)
    logoIcon.Position = UDim2.new(0,16,0.5,-10)
    logoIcon.ZIndex   = 8
    logoIcon.Parent   = headerFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text           = "RUSSELITE"
    titleLabel.Font           = Enum.Font.GothamBold
    titleLabel.TextSize       = 15
    titleLabel.TextColor3     = T.TextMain
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size           = UDim2.new(0,110,0,22)
    titleLabel.Position       = UDim2.new(0,44,0.5,-11)
    titleLabel.ZIndex         = 8
    titleLabel.Parent         = headerFrame
    titleLabel:SetAttribute("TextRole","main")

    local versionBadge = Instance.new("Frame")
    versionBadge.BackgroundColor3       = T.Accent
    versionBadge.BackgroundTransparency = 0.20
    versionBadge.BorderSizePixel        = 0
    versionBadge.Size                   = UDim2.new(0,38,0,17)
    versionBadge.Position               = UDim2.new(0,148,0.5,-8)
    versionBadge.ZIndex                 = 8
    versionBadge.Parent                 = headerFrame
    mkCorner(versionBadge, 6)
    regA(versionBadge)

    local versionText = Instance.new("TextLabel")
    versionText.BackgroundTransparency = 1
    versionText.Text       = "v3.0"
    versionText.Font       = Enum.Font.GothamBold
    versionText.TextSize   = 10
    versionText.TextColor3 = T.TextMain
    versionText.Size       = UDim2.new(1,0,1,0)
    versionText.ZIndex     = 9
    versionText.Parent     = versionBadge
    versionText:SetAttribute("TextRole","main")

    local scriptCountLabel = Instance.new("TextLabel")
    scriptCountLabel.BackgroundTransparency = 1
    scriptCountLabel.Text           = countScripts() .. " scripts"
    scriptCountLabel.Font           = Enum.Font.Gotham
    scriptCountLabel.TextSize       = 11
    scriptCountLabel.TextColor3     = T.TextSub
    scriptCountLabel.TextXAlignment = Enum.TextXAlignment.Right
    scriptCountLabel.Size           = UDim2.new(0,110,0,18)
    scriptCountLabel.Position       = UDim2.new(1,-168,0.5,-9)
    scriptCountLabel.ZIndex         = 8
    scriptCountLabel.Parent         = headerFrame

    local ok_g, gname = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)
    local gameNameHeader = Instance.new("TextLabel")
    gameNameHeader.BackgroundTransparency = 1
    gameNameHeader.Text           = ok_g and gname or "Unknown Game"
    gameNameHeader.Font           = Enum.Font.Gotham
    gameNameHeader.TextSize       = 10
    gameNameHeader.TextColor3     = T.TextMuted
    gameNameHeader.TextXAlignment = Enum.TextXAlignment.Right
    gameNameHeader.Size           = UDim2.new(0,140,0,14)
    gameNameHeader.Position       = UDim2.new(1,-190,0.5,6)
    gameNameHeader.ZIndex         = 8
    gameNameHeader.Parent         = headerFrame

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name                   = "CloseBtn"
    closeBtn.BackgroundColor3       = Color3.fromRGB(195,55,55)
    closeBtn.BackgroundTransparency = 0.30
    closeBtn.BorderSizePixel        = 0
    closeBtn.Size                   = UDim2.new(0,26,0,26)
    closeBtn.Position               = UDim2.new(1,-38,0.5,-13)
    closeBtn.Text                   = "×"
    closeBtn.TextColor3             = T.TextMain
    closeBtn.TextSize               = 20
    closeBtn.Font                   = Enum.Font.Gotham
    closeBtn.ZIndex                 = 10
    closeBtn.Parent                 = headerFrame
    mkCorner(closeBtn, 13)
    closeBtn:SetAttribute("TextRole","main")
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TWEEN_F, {BackgroundTransparency=0.05, BackgroundColor3=Color3.fromRGB(230,50,50)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TWEEN_F, {BackgroundTransparency=0.30, BackgroundColor3=Color3.fromRGB(195,55,55)}):Play()
    end)

    -- ─────────────────────────────────────────
    --  SIDEBAR  (148px)
    -- ─────────────────────────────────────────
    local sidebarFrame = Instance.new("Frame")
    sidebarFrame.Name                   = "SidebarFrame"
    sidebarFrame.BackgroundColor3       = T.BgSide -- Добавлен цвет для работы стекла
    sidebarFrame.BackgroundTransparency = 0.1  -- Стеклянная прозрачность
    sidebarFrame.Size                   = UDim2.new(0,148,1,-52)
    sidebarFrame.Position               = UDim2.new(0,0,0,52)
    sidebarFrame.ZIndex                 = 3
    sidebarFrame.Parent                 = mainFrame
    mkGlassEffect(sidebarFrame) -- Быстрый Glass

    local sidebarSep = Instance.new("Frame")
    sidebarSep.BackgroundColor3       = Color3.new(1,1,1)
    sidebarSep.BackgroundTransparency = 0.94
    sidebarSep.BorderSizePixel        = 0
    sidebarSep.Size                   = UDim2.new(0,1,1,-20)
    sidebarSep.Position               = UDim2.new(1,-1,0,10)
    sidebarSep.ZIndex                 = 4
    sidebarSep.Parent                 = sidebarFrame

    local catScroll = Instance.new("ScrollingFrame")
    catScroll.BackgroundTransparency = 1
    catScroll.BorderSizePixel        = 0
    catScroll.Size                   = UDim2.new(1,-6,1,-12)
    catScroll.Position               = UDim2.new(0,6,0,6)
    catScroll.CanvasSize             = UDim2.new(0,0,0,0)
    catScroll.ScrollBarThickness     = 0
    catScroll.ZIndex                 = 5
    catScroll.Parent                 = sidebarFrame

    local catLayout = Instance.new("UIListLayout")
    catLayout.Padding   = UDim.new(0,3)
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    catLayout.Parent    = catScroll

    local catPad = Instance.new("UIPadding")
    catPad.PaddingLeft   = UDim.new(0,6)
    catPad.PaddingRight  = UDim.new(0,6)
    catPad.PaddingTop    = UDim.new(0,4)
    catPad.PaddingBottom = UDim.new(0,4)
    catPad.Parent        = catScroll

    catLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        catScroll.CanvasSize = UDim2.new(0,0,0, catLayout.AbsoluteContentSize.Y + 16)
    end)

    -- ─────────────────────────────────────────
    --  CONTENT PANEL
    -- ─────────────────────────────────────────
    local contentFrame = Instance.new("Frame")
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel        = 0
    contentFrame.Size                   = UDim2.new(1,-160,1,-64)
    contentFrame.Position               = UDim2.new(0,154,0,58)
    contentFrame.ZIndex                 = 3
    contentFrame.Parent                 = mainFrame

    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel        = 0
    scrollingFrame.Size                   = UDim2.new(1,0,1,0)
    scrollingFrame.CanvasSize             = UDim2.new(0,0,0,0)
    scrollingFrame.ScrollBarThickness     = 2
    scrollingFrame.ScrollBarImageColor3   = T.Accent
    scrollingFrame.ZIndex                 = 3
    scrollingFrame.Parent                 = contentFrame
    regA(scrollingFrame, "ScrollBarImageColor3")

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Padding   = UDim.new(0,5)
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Parent    = scrollingFrame

    local scrollPad = Instance.new("UIPadding")
    scrollPad.PaddingLeft   = UDim.new(0,2)
    scrollPad.PaddingRight  = UDim.new(0,8)
    scrollPad.PaddingTop    = UDim.new(0,2)
    scrollPad.PaddingBottom = UDim.new(0,6)
    scrollPad.Parent        = scrollingFrame

    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0,0,0, scrollLayout.AbsoluteContentSize.Y + 14)
    end)

    -- ─────────────────────────────────────────
    --  GAMES PANEL
    -- ─────────────────────────────────────────
    local gamesPanel = Instance.new("ScrollingFrame")
    gamesPanel.Name                   = "GamesPanel"
    gamesPanel.BackgroundTransparency = 1
    gamesPanel.BorderSizePixel        = 0
    gamesPanel.Size                   = UDim2.new(1,0,1,0)
    gamesPanel.CanvasSize             = UDim2.new(0,0,0,0)
    gamesPanel.ScrollBarThickness     = 2
    gamesPanel.ScrollBarImageColor3   = T.Accent
    gamesPanel.Visible                = false
    gamesPanel.ZIndex                 = 3
    gamesPanel.Parent                 = contentFrame
    regA(gamesPanel, "ScrollBarImageColor3")

    local gamesGrid = Instance.new("UIGridLayout")
    gamesGrid.CellSize    = UDim2.new(0,128,0,96)
    gamesGrid.CellPadding = UDim2.new(0,8,0,8)
    gamesGrid.SortOrder   = Enum.SortOrder.LayoutOrder
    gamesGrid.Parent      = gamesPanel

    local gamesPad = Instance.new("UIPadding")
    gamesPad.PaddingLeft   = UDim.new(0,4)
    gamesPad.PaddingTop    = UDim.new(0,6)
    gamesPad.PaddingRight  = UDim.new(0,4)
    gamesPad.PaddingBottom = UDim.new(0,6)
    gamesPad.Parent        = gamesPanel

    gamesGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        gamesPanel.CanvasSize = UDim2.new(0,0,0, gamesGrid.AbsoluteContentSize.Y + 20)
    end)

    -- ─────────────────────────────────────────
    --  REOPEN BUTTON (Синхронизировано с theme.lua)
    -- ─────────────────────────────────────────
    local reopenButton = Instance.new("TextButton") -- TextButton для корректного поиска в theme.lua
    reopenButton.Name                   = "ReopenBtn"
    reopenButton.Size                   = UDim2.new(0,46,0,46)
    reopenButton.Position               = UDim2.new(0.5,-23,0.9,-23)
    reopenButton.BackgroundColor3       = T.BgSide
    reopenButton.BackgroundTransparency = 0.1
    reopenButton.Text                   = ""
    reopenButton.Visible                = false
    reopenButton.ZIndex                 = 12
    reopenButton.Parent                 = screenGui
    mkCorner(reopenButton, 23)
    mkGlassEffect(reopenButton)

    local reopenRing = mkStroke(reopenButton, 1.5, T.Accent, 0.28)
    regA(reopenRing, "Color")

    -- Иконка внутри кнопки (вместо свойства Image у ImageButton)
    local reIcon = Instance.new("ImageLabel")
    reIcon.Size = UDim2.new(0,24,0,24); reIcon.Position = UDim2.new(0.5,-12,0.5,-12)
    reIcon.BackgroundTransparency = 1; reIcon.Image = "rbxassetid://74283928898866"
    reIcon.ImageColor3 = T.TextMain; reIcon.ImageTransparency = 0.08; reIcon.ZIndex = 13
    reIcon.Parent = reopenButton

    reopenButton.MouseEnter:Connect(function()
        TweenService:Create(reopenButton, TWEEN_F, {BackgroundColor3=T.Accent, BackgroundTransparency=0.08}):Play()
    end)
    reopenButton.MouseLeave:Connect(function()
        TweenService:Create(reopenButton, TWEEN_F, {BackgroundColor3=T.BgSide, BackgroundTransparency=0.1}):Play()
    end)

    -- ─────────────────────────────────────────
    --  DUMMY PATCH — ДОЛЖЕН БЫТЬ ДО return {}
    -- ─────────────────────────────────────────
    local dummyPatch = Instance.new("Frame")
    dummyPatch.Visible = false
    dummyPatch.Parent  = mainFrame

    -- ─────────────────────────────────────────
    --  COMPONENT HELPERS
    -- ─────────────────────────────────────────
    local function createSectionHeader(text, parent)
        local container = Instance.new("Frame")
        container.BackgroundTransparency = 1
        container.Size   = UDim2.new(1,0,0,26)
        container.ZIndex = 4
        container.Parent = parent

        local pip = Instance.new("Frame")
        pip.BackgroundColor3       = T.Accent
        pip.BackgroundTransparency = 0
        pip.BorderSizePixel        = 0
        pip.Size                   = UDim2.new(0,3,0,14)
        pip.Position               = UDim2.new(0,0,0.5,-7)
        pip.ZIndex                 = 5
        pip.Parent                 = container
        mkCorner(pip, 2)
        regA(pip)

        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Text           = string.upper(text)
        lbl.Font           = Enum.Font.GothamBold
        lbl.TextSize       = 10
        lbl.TextColor3     = T.TextSub
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size           = UDim2.new(1,-12,1,0)
        lbl.Position       = UDim2.new(0,10,0,0)
        lbl.ZIndex         = 5
        lbl.Parent         = container
        return container
    end

    local function createLabel(text, parent, size, position)
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Text             = text
        label.Size             = size or UDim2.new(1,0,0,22)
        label.Position         = position or UDim2.new(0,0,0,0)
        label.TextSize         = 12
        label.TextColor3       = T.TextMain
        label.TextTransparency = 0.08
        label.TextXAlignment   = Enum.TextXAlignment.Left
        label.Font             = Enum.Font.Gotham
        label.TextWrapped      = true
        label.ZIndex           = 4
        label.Parent           = parent
        label:SetAttribute("TextRole","main")
        return label
    end

    local function createButton(text, parent, callback, isCategoryButton)
        if isCategoryButton then
            local btn = Instance.new("TextButton")
            btn.Size                   = UDim2.new(1,0,0,30)
            btn.BackgroundColor3       = T.Accent
            btn.BackgroundTransparency = 1
            btn.BorderSizePixel        = 0
            btn.Text                   = text
            btn.TextColor3             = T.TextSub
            btn.TextSize               = 11
            btn.TextXAlignment         = Enum.TextXAlignment.Left
            btn.Font                   = Enum.Font.GothamMedium
            btn.ZIndex                 = 6
            btn.Parent                 = parent
            mkCorner(btn, CORNER_S)

            local btnPad = Instance.new("UIPadding")
            btnPad.PaddingLeft = UDim.new(0,12)
            btnPad.Parent      = btn

            btn.MouseEnter:Connect(function()
                if btn:GetAttribute("Active") then return end
                TweenService:Create(btn, TWEEN_F, {BackgroundTransparency=0.90, TextColor3=T.TextMain}):Play()
            end)
            btn.MouseLeave:Connect(function()
                if btn:GetAttribute("Active") then return end
                TweenService:Create(btn, TWEEN_F, {BackgroundTransparency=1, TextColor3=T.TextSub}):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                for _, child in ipairs(parent:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:SetAttribute("Active", false)
                        TweenService:Create(child, TWEEN_F, {BackgroundTransparency=1, TextColor3=T.TextSub}):Play()
                    end
                end
                btn:SetAttribute("Active", true)
                TweenService:Create(btn, TWEEN_F, {BackgroundTransparency=0.78, TextColor3=T.Accent}):Play()
                callback()
            end)
            return btn
        else
            local btn = Instance.new("TextButton")
            btn.Size                   = UDim2.new(1,0,0,36)
            btn.BackgroundColor3       = T.BgPanel
            btn.BackgroundTransparency = 0.15 -- Оптимизировано под стекло
            btn.BorderSizePixel        = 0
            btn.Text                   = ""
            btn.ZIndex                 = 4
            btn.Parent                 = parent
            mkCorner(btn, CORNER_S)
            local s = mkStroke(btn, 1, Color3.new(1,1,1), 0.82)
            mkGlassEffect(btn) -- Стеклянный скрипт-карточки

            local leftBar = Instance.new("Frame")
            leftBar.BackgroundColor3       = T.Accent
            leftBar.BackgroundTransparency = 1
            leftBar.BorderSizePixel        = 0
            leftBar.Size                   = UDim2.new(0,2,1,-10)
            leftBar.Position               = UDim2.new(0,0,0,5)
            leftBar.ZIndex                 = 5
            leftBar.Parent                 = btn
            mkCorner(leftBar, 2)
            regA(leftBar)

            local label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1
            label.Text           = text
            label.Font           = Enum.Font.Gotham
            label.TextSize       = 13
            label.TextColor3     = T.TextMain
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Size           = UDim2.new(1,-24,1,0)
            label.Position       = UDim2.new(0,14,0,0)
            label.ZIndex         = 6
            label.Parent         = btn
            label:SetAttribute("TextRole","main")

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn,     TWEEN_F, {BackgroundTransparency=0.05, BackgroundColor3=T.BgBtnHov}):Play()
                TweenService:Create(s,       TWEEN_F, {Transparency=0.50}):Play()
                TweenService:Create(leftBar, TWEEN_F, {BackgroundTransparency=0}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn,     TWEEN_F, {BackgroundTransparency=0.15, BackgroundColor3=T.BgPanel}):Play()
                TweenService:Create(s,       TWEEN_F, {Transparency=0.82}):Play()
                TweenService:Create(leftBar, TWEEN_F, {BackgroundTransparency=1}):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.06), {BackgroundColor3=T.Accent, BackgroundTransparency=0.15}):Play()
                task.delay(0.10, function()
                    TweenService:Create(btn, TWEEN_F, {BackgroundColor3=T.BgBtnHov, BackgroundTransparency=0.05}):Play()
                end)
                callback()
            end)
            return btn
        end
    end

    -- ─────────────────────────────────────────
    --  GAME CARD BUILDER
    -- ─────────────────────────────────────────
    local function createGameCard(gameName, placeId, onClick)
        local card = Instance.new("TextButton")
        card.Name                   = "GameCard_" .. gameName
        card.BackgroundColor3       = T.BgPanel
        card.BackgroundTransparency = 0.1 -- Стекло
        card.BorderSizePixel        = 0
        card.Text                   = ""
        card.ZIndex                 = 4
        card.Parent                 = gamesPanel
        mkCorner(card, CORNER_S)
        local cs = mkStroke(card, 1, Color3.new(1,1,1), 0.82)
        mkGlassEffect(card) -- Стеклянная карточка игры

        local thumb = Instance.new("ImageLabel")
        thumb.Name                   = "GameCardBg"
        thumb.BackgroundColor3       = T.BgBtn
        thumb.BackgroundTransparency = 0
        thumb.BorderSizePixel        = 0
        thumb.Size                   = UDim2.new(1,0,0,62)
        thumb.Position               = UDim2.new(0,0,0,0)
        thumb.Image                  = ""
        thumb.ImageTransparency      = 1
        thumb.ScaleType              = Enum.ScaleType.Crop
        thumb.ZIndex                 = 5
        thumb.Parent                 = card
        mkCorner(thumb, CORNER_S)

        local overlay = Instance.new("Frame")
        overlay.BackgroundColor3       = T.BgPanel
        overlay.BackgroundTransparency = 0
        overlay.BorderSizePixel        = 0
        overlay.Size                   = UDim2.new(1,0,0.5,0)
        overlay.Position               = UDim2.new(0,0,0.5,0)
        overlay.ZIndex                 = 6
        overlay.Parent                 = thumb
        mkGradient(overlay, {
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }, 90)

        local nameLbl = Instance.new("TextLabel")
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text           = gameName
        nameLbl.Font           = Enum.Font.GothamMedium
        nameLbl.TextSize       = 10
        nameLbl.TextColor3     = T.TextMain
        nameLbl.TextXAlignment = Enum.TextXAlignment.Center
        nameLbl.TextWrapped    = true
        nameLbl.Size           = UDim2.new(1,-4,0,28)
        nameLbl.Position       = UDim2.new(0,2,1,-28)
        nameLbl.ZIndex         = 7
        nameLbl.Parent         = card
        nameLbl:SetAttribute("TextRole","main")

        card.MouseEnter:Connect(function()
            TweenService:Create(card, TWEEN_F, {BackgroundTransparency=0.02, BackgroundColor3=T.BgBtnHov}):Play()
            TweenService:Create(cs,   TWEEN_F, {Transparency=0.40, Color=T.Accent}):Play()
        end)
        card.MouseLeave:Connect(function()
            TweenService:Create(card, TWEEN_F, {BackgroundTransparency=0.1, BackgroundColor3=T.BgPanel}):Play()
            TweenService:Create(cs,   TWEEN_F, {Transparency=0.82, Color=Color3.new(1,1,1)}):Play()
        end)
        card.MouseButton1Click:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.06), {BackgroundColor3=T.Accent, BackgroundTransparency=0.1}):Play()
            task.delay(0.10, function()
                TweenService:Create(card, TWEEN_F, {BackgroundColor3=T.BgBtnHov, BackgroundTransparency=0.02}):Play()
            end)
            if onClick then onClick() end
        end)

        return card, thumb
    end

    -- ─────────────────────────────────────────
    --  PUBLIC API
    -- ─────────────────────────────────────────
    return {
        screenGui      = screenGui,
        mainFrame      = mainFrame,
        headerFrame    = headerFrame,
        headerPatch    = dummyPatch,
        sidebarFrame   = sidebarFrame,
        sidebarPatch   = dummyPatch,
        sidebarBLCorner= dummyPatch,
        catScroll      = catScroll,
        contentFrame   = contentFrame,
        scrollingFrame = scrollingFrame,
        gamesPanel     = gamesPanel,
        closeBtn       = closeBtn,
        reopenButton   = reopenButton,
        gameName       = ok_g and gname or "Unknown",

        mkCorner            = mkCorner,
        mkStroke            = mkStroke,
        mkGlassEffect       = mkGlassEffect, -- Экспорт для home.lua и stats.lua
        createButton        = createButton,
        createLabel         = createLabel,
        createSectionHeader = createSectionHeader,
        createGameCard      = createGameCard,

        setNotification = function(fn) createNotification = fn end,
    }
end
