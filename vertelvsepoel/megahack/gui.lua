═══════════════════════════════════════════════════════════════
--  gui.lua — 3D Glass Neon UI Construction v3
--  2026 Edition: Floating panels, neon borders, depth shadows
═══════════════════════════════════════════════════════════════

return function(deps)
    local TweenService       = deps.TweenService
    local UserInputService   = deps.UserInputService
    local CoreGui            = deps.CoreGui
    local MarketplaceService = deps.MarketplaceService
    local playerGui          = deps.playerGui
    local platformName       = deps.platformName
    local T                  = deps.T
    local regA               = deps.regA
    local HubData            = deps.HubData

    local CORNER   = 16
    local CORNER_S = 10
    local CORNER_XS = 6
    local TWEEN_F  = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local TWEEN_M  = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local TWEEN_S  = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- ═══ GLASS HELPERS ═══

    local function mkCorner(parent, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or CORNER)
        c.Parent = parent
        return c
    end

    local function mkStroke(parent, thickness, color, alpha)
        local s = Instance.new("UIStroke")
        s.Thickness       = thickness or 1
        s.Color           = color or T.StrokeBrt
        s.Transparency    = alpha or 0.6
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent          = parent
        return s
    end

    -- 3D Shadow: creates offset dark copy behind element
    local function mk3DShadow(parent, offsetX, offsetY, blur, alpha)
        local shadow = Instance.new("Frame")
        shadow.Name                   = "_3DShadow"
        shadow.Size                   = parent.Size
        shadow.Position               = parent.Position + UDim2.new(0, offsetX or 4, 0, offsetY or 4)
        shadow.BackgroundColor3       = T.ShadowDeep
        shadow.BackgroundTransparency = alpha or 0.3
        shadow.BorderSizePixel        = 0
        shadow.ZIndex                 = parent.ZIndex - 1
        shadow.Parent                 = parent.Parent
        mkCorner(shadow, CORNER)
        return shadow
    end

    -- Neon Border Glow: creates glowing border effect
    local function mkNeonBorder(parent, color, thickness)
        local glow = Instance.new("Frame")
        glow.Name                   = "_NeonBorder"
        glow.Size                   = parent.Size + UDim2.new(0, (thickness or 4) * 2, 0, (thickness or 4) * 2)
        glow.Position               = parent.Position - UDim2.new(0, thickness or 4, 0, thickness or 4)
        glow.BackgroundColor3       = color or T.Accent
        glow.BackgroundTransparency = 0.75
        glow.BorderSizePixel        = 0
        glow.ZIndex                 = parent.ZIndex - 2
        glow.Parent                 = parent.Parent
        mkCorner(glow, CORNER + (thickness or 4))
        return glow
    end

    -- Glass Sheen: top-half white gradient overlay
    local function mkGlassSheen(parent, zIdx)
        local sh = Instance.new("Frame")
        sh.Name                   = "_GlassSheen"
        sh.BackgroundColor3       = Color3.new(1, 1, 1)
        sh.BackgroundTransparency = 0.94
        sh.BorderSizePixel        = 0
        sh.Size                   = UDim2.new(1, 0, 0.5, 0)
        sh.ZIndex                 = zIdx or 10
        sh.ClipsDescendants       = true
        sh.Parent                 = parent
        local r = CORNER
        local ec = parent:FindFirstChildWhichIsA("UICorner")
        if ec then r = ec.CornerRadius.Offset end
        mkCorner(sh, r)
        local g = Instance.new("UIGradient")
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.15),
            NumberSequenceKeypoint.new(0.4, 0.65),
            NumberSequenceKeypoint.new(1, 1.0),
        })
        g.Rotation = 90
        g.Parent = sh
        return sh
    end

    -- Neon Glow Line (horizontal)
    local function mkNeonLine(parent, size, pos, color, zIdx)
        local line = Instance.new("Frame")
        line.Name                   = "NeonLine"
        line.Size                   = size or UDim2.new(0.4, 0, 0, 2)
        line.Position               = pos or UDim2.new(0.3, 0, 0, 0)
        line.BackgroundColor3       = color or T.Accent
        line.BackgroundTransparency = 0.2
        line.BorderSizePixel        = 0
        line.ZIndex                 = zIdx or 10
        line.Parent                 = parent
        mkCorner(line, 1)
        return line
    end

    -- Floating card with 3D effect
    local function mkGlassCard(parent, size, pos, bgCol, bgAlpha, zIdx, cardRadius)
        local card = Instance.new("Frame")
        card.Size                   = size or UDim2.new(1, 0, 0, 40)
        card.Position               = pos or UDim2.new(0, 0, 0, 0)
        card.BackgroundColor3       = bgCol or T.BgCard
        card.BackgroundTransparency = bgAlpha ~= nil and bgAlpha or 0.2
        card.BorderSizePixel        = 0
        card.ZIndex                 = zIdx or 4
        card.Parent                 = parent
        local rad = cardRadius or CORNER_S
        mkCorner(card, rad)
        mkStroke(card, 1, T.StrokeBrt, 0.55)
        mk3DShadow(card, 3, 3, 0, 0.5)
        mkGlassSheen(card, zIdx + 2)
        return card
    end

    -- ═══ SCREEN GUI ═══

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name           = "MegaHack_GUI"
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
                syn.protect_gui(g)
                g.Parent = CoreGui
            else
                g.Parent = CoreGui
            end
        end)
        if not ok then g.Parent = CoreGui end
    end
    protectGui(screenGui)

    -- ═══ MAIN FRAME with 3D + Neon ═══

    local mainFrame = Instance.new("Frame")
    mainFrame.Name                   = "MainFrame"
    mainFrame.BackgroundColor3       = T.BgBase
    mainFrame.BackgroundTransparency = 0.04
    mainFrame.BorderSizePixel        = 0
    mainFrame.AnchorPoint            = Vector2.new(0.5, 0.5)
    mainFrame.Position               = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size                   = UDim2.new(0, 620, 0, 420)
    mainFrame.ZIndex                 = 5
    mainFrame.Parent                 = screenGui
    mkCorner(mainFrame, CORNER)
    mkStroke(mainFrame, 1, T.StrokeBrt, 0.4)
    mk3DShadow(mainFrame, 6, 6, 0, 0.4)
    mkNeonBorder(mainFrame, T.Accent, 3)
    mkGlassSheen(mainFrame, 7)

    -- Top neon glow bar
    local topNeonGlow = Instance.new("Frame")
    topNeonGlow.Name                   = "_NeonGlowTop"
    topNeonGlow.Size                   = UDim2.new(0.6, 0, 0, 2)
    topNeonGlow.Position               = UDim2.new(0.2, 0, 0, -1)
    topNeonGlow.BackgroundColor3       = T.Accent
    topNeonGlow.BackgroundTransparency = 0.1
    topNeonGlow.BorderSizePixel        = 0
    topNeonGlow.ZIndex                 = 8
    topNeonGlow.Parent                 = mainFrame
    mkCorner(topNeonGlow, 1)
    regA(topNeonGlow)

    -- Bottom neon glow bar
    local bottomNeonGlow = Instance.new("Frame")
    bottomNeonGlow.Name                   = "_NeonGlowBottom"
    bottomNeonGlow.Size                   = UDim2.new(0.4, 0, 0, 2)
    bottomNeonGlow.Position               = UDim2.new(0.3, 0, 1, -1)
    bottomNeonGlow.BackgroundColor3       = T.Accent2
    bottomNeonGlow.BackgroundTransparency = 0.2
    bottomNeonGlow.BorderSizePixel        = 0
    bottomNeonGlow.ZIndex                 = 8
    bottomNeonGlow.Parent                 = mainFrame
    mkCorner(bottomNeonGlow, 1)

    -- ═══ HEADER ═══

    local headerFrame = Instance.new("Frame")
    headerFrame.Name                   = "HeaderFrame"
    headerFrame.BackgroundTransparency = 1
    headerFrame.Size                   = UDim2.new(1, 0, 0, 56)
    headerFrame.ZIndex                 = 6
    headerFrame.Parent                 = mainFrame

    -- Header separator - neon line
    local headerLine = Instance.new("Frame")
    headerLine.BackgroundColor3       = T.Accent
    headerLine.BackgroundTransparency = 0.5
    headerLine.BorderSizePixel        = 0
    headerLine.Size                   = UDim2.new(1, -24, 0, 1)
    headerLine.Position               = UDim2.new(0, 12, 1, 0)
    headerLine.ZIndex                 = 7
    headerLine.Parent                 = headerFrame
    regA(headerLine)

    -- Logo with glow
    local logoGlow = Instance.new("ImageLabel")
    logoGlow.BackgroundTransparency = 1
    logoGlow.Image                 = "rbxassetid://7072717762"
    logoGlow.ImageColor3           = T.Accent
    logoGlow.ImageTransparency     = 0.5
    logoGlow.Size                  = UDim2.new(0, 26, 0, 26)
    logoGlow.Position              = UDim2.new(0, 13, 0.5, -13)
    logoGlow.ZIndex                = 8
    logoGlow.Parent                = headerFrame

    local logoIcon = Instance.new("ImageLabel")
    logoIcon.BackgroundTransparency = 1
    logoIcon.Image    = "rbxassetid://7072717762"
    logoIcon.Size     = UDim2.new(0, 22, 0, 22)
    logoIcon.Position = UDim2.new(0, 15, 0.5, -11)
    logoIcon.ZIndex   = 9
    logoIcon.Parent   = headerFrame

    -- Title with 3D text effect
    local titleShadow = Instance.new("TextLabel")
    titleShadow.BackgroundTransparency = 1
    titleShadow.Text           = "MEGAHACK"
    titleShadow.Font           = Enum.Font.GothamBold
    titleShadow.TextSize       = 16
    titleShadow.TextColor3     = Color3.new(T.Accent.R * 0.3, T.Accent.G * 0.3, T.Accent.B * 0.3)
    titleShadow.TextTransparency = 0.3
    titleShadow.TextXAlignment = Enum.TextXAlignment.Left
    titleShadow.Size           = UDim2.new(0, 120, 0, 22)
    titleShadow.Position       = UDim2.new(0, 44, 0.5, -9)
    titleShadow.ZIndex         = 8
    titleShadow.Parent         = headerFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text           = "MEGAHACK"
    titleLabel.Font           = Enum.Font.GothamBold
    titleLabel.TextSize       = 16
    titleLabel.TextColor3     = T.TextMain
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size           = UDim2.new(0, 120, 0, 22)
    titleLabel.Position       = UDim2.new(0, 43, 0.5, -10)
    titleLabel.ZIndex         = 9
    titleLabel.Parent         = headerFrame
    titleLabel:SetAttribute("TextRole", "main")

    -- Version badge with neon
    local versionBadge = Instance.new("Frame")
    versionBadge.BackgroundColor3       = T.Accent
    versionBadge.BackgroundTransparency = 0.25
    versionBadge.BorderSizePixel        = 0
    versionBadge.Size                   = UDim2.new(0, 42, 0, 19)
    versionBadge.Position               = UDim2.new(0, 156, 0.5, -9)
    versionBadge.ZIndex                 = 9
    versionBadge.Parent                 = headerFrame
    mkCorner(versionBadge, CORNER_XS)
    mkStroke(versionBadge, 1, T.AccentGlow, 0.5)
    regA(versionBadge)

    local versionText = Instance.new("TextLabel")
    versionText.BackgroundTransparency = 1
    versionText.Text       = "v3.0"
    versionText.Font       = Enum.Font.GothamBold
    versionText.TextSize   = 10
    versionText.TextColor3 = Color3.new(1, 1, 1)
    versionText.Size       = UDim2.new(1, 0, 1, 0)
    versionText.ZIndex     = 10
    versionText.Parent     = versionText
    versionText:SetAttribute("TextRole", "main")
    versionText.Parent     = versionBadge

    -- Script count
    local function countScripts()
        local n = 0
        for _, cat in pairs(HubData) do
            if type(cat) == "table" then n = n + #cat end
        end
        return n
    end

    local scriptCountLabel = Instance.new("TextLabel")
    scriptCountLabel.BackgroundTransparency = 1
    scriptCountLabel.Text           = countScripts() .. " scripts"
    scriptCountLabel.Font           = Enum.Font.Gotham
    scriptCountLabel.TextSize       = 11
    scriptCountLabel.TextColor3     = T.TextSub
    scriptCountLabel.TextXAlignment = Enum.TextXAlignment.Right
    scriptCountLabel.Size           = UDim2.new(0, 110, 0, 18)
    scriptCountLabel.Position       = UDim2.new(1, -168, 0.5, -10)
    scriptCountLabel.ZIndex         = 9
    scriptCountLabel.Parent         = headerFrame

    -- Game name
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
    gameNameHeader.Size           = UDim2.new(0, 140, 0, 14)
    gameNameHeader.Position       = UDim2.new(1, -190, 0.5, 6)
    gameNameHeader.ZIndex         = 9
    gameNameHeader.Parent         = headerFrame

    -- Close button with neon hover
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name                   = "CloseBtn"
    closeBtn.BackgroundColor3       = T.BgCard
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.BorderSizePixel        = 0
    closeBtn.Size                   = UDim2.new(0, 28, 0, 28)
    closeBtn.Position               = UDim2.new(1, -40, 0.5, -14)
    closeBtn.Text                   = "×"
    closeBtn.TextColor3             = T.TextSub
    closeBtn.TextSize               = 18
    closeBtn.Font                   = Enum.Font.GothamBold
    closeBtn.ZIndex                 = 11
    closeBtn.Parent                 = headerFrame
    mkCorner(closeBtn, 14)
    mkStroke(closeBtn, 1, T.StrokeBrt, 0.5)
    closeBtn:SetAttribute("TextRole", "main")

    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TWEEN_S, {
            BackgroundColor3 = Color3.fromRGB(255, 40, 40),
            BackgroundTransparency = 0.15,
            TextColor3 = Color3.new(1, 1, 1)
        }):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TWEEN_S, {
            BackgroundColor3 = T.BgCard,
            BackgroundTransparency = 0.2,
            TextColor3 = T.TextSub
        }):Play()
    end)

    -- ═══ SIDEBAR ═══

    local sidebarFrame = Instance.new("Frame")
    sidebarFrame.Name                   = "SidebarFrame"
    sidebarFrame.BackgroundColor3       = T.BgSide
    sidebarFrame.BackgroundTransparency = 0.15
    sidebarFrame.Size                   = UDim2.new(0, 155, 1, -56)
    sidebarFrame.Position               = UDim2.new(0, 0, 0, 56)
    sidebarFrame.ZIndex                 = 4
    sidebarFrame.Parent                 = mainFrame
    mkCorner(sidebarFrame, CORNER)
    mkGlassSheen(sidebarFrame, 5)

    -- Sidebar neon edge
    local sidebarEdge = Instance.new("Frame")
    sidebarEdge.BackgroundColor3       = T.Accent
    sidebarEdge.BackgroundTransparency = 0.6
    sidebarEdge.BorderSizePixel        = 0
    sidebarEdge.Size                   = UDim2.new(0, 1, 1, -24)
    sidebarEdge.Position               = UDim2.new(1, -1, 0, 12)
    sidebarEdge.ZIndex                 = 6
    sidebarEdge.Parent                 = sidebarFrame
    regA(sidebarEdge)

    local catScroll = Instance.new("ScrollingFrame")
    catScroll.BackgroundTransparency = 1
    catScroll.BorderSizePixel        = 0
    catScroll.Size                   = UDim2.new(1, -8, 1, -16)
    catScroll.Position               = UDim2.new(0, 8, 0, 8)
    catScroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
    catScroll.ScrollBarThickness     = 0
    catScroll.ZIndex                 = 5
    catScroll.Parent                 = sidebarFrame

    local catLayout = Instance.new("UIListLayout")
    catLayout.Padding   = UDim.new(0, 3)
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    catLayout.Parent    = catScroll

    local catPad = Instance.new("UIPadding")
    catPad.PaddingLeft   = UDim.new(0, 4)
    catPad.PaddingRight  = UDim.new(0, 4)
    catPad.PaddingTop    = UDim.new(0, 4)
    catPad.PaddingBottom = UDim.new(0, 4)
    catPad.Parent        = catScroll

    catLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        catScroll.CanvasSize = UDim2.new(0, 0, 0, catLayout.AbsoluteContentSize.Y + 16)
    end)

    -- ═══ CONTENT AREA ═══

    local contentFrame = Instance.new("Frame")
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel        = 0
    contentFrame.Size                   = UDim2.new(1, -168, 1, -68)
    contentFrame.Position               = UDim2.new(0, 160, 0, 62)
    contentFrame.ZIndex                 = 4
    contentFrame.Parent                 = mainFrame

    -- Scripts scrolling frame
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel        = 0
    scrollingFrame.Size                   = UDim2.new(1, 0, 1, 0)
    scrollingFrame.CanvasSize             = UDim2.new(0, 0, 0, 0)
    scrollingFrame.ScrollBarThickness     = 2
    scrollingFrame.ScrollBarImageColor3   = T.Accent
    scrollingFrame.ZIndex                 = 4
    scrollingFrame.Parent                 = contentFrame
    regA(scrollingFrame, "ScrollBarImageColor3")

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Padding   = UDim.new(0, 6)
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Parent    = scrollingFrame

    local scrollPad = Instance.new("UIPadding")
    scrollPad.PaddingLeft   = UDim.new(0, 2)
    scrollPad.PaddingRight  = UDim.new(0, 8)
    scrollPad.PaddingTop    = UDim.new(0, 2)
    scrollPad.PaddingBottom = UDim.new(0, 8)
    scrollPad.Parent        = scrollingFrame

    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 16)
    end)

    -- Games panel (hidden by default)
    local gamesPanel = Instance.new("ScrollingFrame")
    gamesPanel.Name                   = "GamesPanel"
    gamesPanel.BackgroundTransparency = 1
    gamesPanel.BorderSizePixel        = 0
    gamesPanel.Size                   = UDim2.new(1, 0, 1, 0)
    gamesPanel.CanvasSize             = UDim2.new(0, 0, 0, 0)
    gamesPanel.ScrollBarThickness     = 2
    gamesPanel.ScrollBarImageColor3   = T.Accent
    gamesPanel.Visible                = false
    gamesPanel.ZIndex                 = 4
    gamesPanel.Parent                 = contentFrame
    regA(gamesPanel, "ScrollBarImageColor3")

    local gamesGrid = Instance.new("UIGridLayout")
    gamesGrid.CellSize    = UDim2.new(0, 132, 0, 100)
    gamesGrid.CellPadding = UDim2.new(0, 10, 0, 10)
    gamesGrid.SortOrder   = Enum.SortOrder.LayoutOrder
    gamesGrid.Parent      = gamesPanel

    local gamesPad = Instance.new("UIPadding")
    gamesPad.PaddingLeft   = UDim.new(0, 6)
    gamesPad.PaddingTop    = UDim.new(0, 8)
    gamesPad.PaddingRight  = UDim.new(0, 6)
    gamesPad.PaddingBottom = UDim.new(0, 8)
    gamesPad.Parent        = gamesPanel

    gamesGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        gamesPanel.CanvasSize = UDim2.new(0, 0, 0, gamesGrid.AbsoluteContentSize.Y + 20)
    end)

    -- ═══ REOPEN BUTTON (floating, neon) ═══

    local reopenButton = Instance.new("TextButton")
    reopenButton.Name                   = "ReopenBtn"
    reopenButton.BackgroundColor3       = T.BgCard
    reopenButton.BackgroundTransparency = 0.15
    reopenButton.BorderSizePixel        = 0
    reopenButton.Size                   = UDim2.new(0, 44, 0, 44)
    reopenButton.Position               = UDim2.new(0, 16, 0.5, -22)
    reopenButton.Text                   = ""
    reopenButton.ZIndex                 = 100
    reopenButton.Parent                 = screenGui
    reopenButton.Visible                = false
    mkCorner(reopenButton, 22)
    mkStroke(reopenButton, 1, T.Accent, 0.3)
    mkNeonBorder(reopenButton, T.Accent, 2)

    local reopenIcon = Instance.new("TextLabel")
    reopenIcon.BackgroundTransparency = 1
    reopenIcon.Text           = "⬡"
    reopenIcon.Font           = Enum.Font.GothamBold
    reopenIcon.TextSize       = 22
    reopenIcon.TextColor3     = T.Accent
    reopenIcon.Size           = UDim2.new(1, 0, 1, 0)
    reopenIcon.ZIndex         = 101
    reopenIcon.Parent         = reopenButton
    regA(reopenIcon, "TextColor3")

    -- ═══ GAME NAME (for home tab) ═══

    local gameName = "Unknown"
    if ok_g and gname then
        gameName = gname
    end

    -- ═══ HELPER FUNCTIONS ═══

    local function createSectionHeader(text, parent)
        local header = Instance.new("Frame")
        header.Size                   = UDim2.new(1, 0, 0, 28)
        header.BackgroundColor3       = T.BgCard
        header.BackgroundTransparency = 0.6
        header.BorderSizePixel        = 0
        header.ZIndex                 = 4
        header.Parent                 = parent
        mkCorner(header, CORNER_XS)

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Text           = "  ◆ " .. text:upper()
        label.Font           = Enum.Font.GothamBold
        label.TextSize       = 11
        label.TextColor3     = T.Accent
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Size           = UDim2.new(1, -8, 1, 0)
        label.Position       = UDim2.new(0, 4, 0, 0)
        label.ZIndex         = 5
        label.Parent         = header
        regA(label, "TextColor3")

        -- Small neon accent line
        local accentDot = Instance.new("Frame")
        accentDot.Size                   = UDim2.new(0, 3, 0, 12)
        accentDot.Position               = UDim2.new(0, 8, 0.5, -6)
        accentDot.BackgroundColor3       = T.Accent
        accentDot.BackgroundTransparency = 0.3
        accentDot.BorderSizePixel        = 0
        accentDot.ZIndex                 = 6
        accentDot.Parent                 = header
        mkCorner(accentDot, 2)
        regA(accentDot)

        return header
    end

    local function createButton(text, parent, callback, zIdx)
        local btn = Instance.new("TextButton")
        btn.Size                   = UDim2.new(1, 0, 0, 36)
        btn.BackgroundColor3       = T.BgBtn
        btn.BackgroundTransparency = 0.15
        btn.BorderSizePixel        = 0
        btn.Text                   = text
        btn.TextColor3             = T.TextMain
        btn.Font                   = Enum.Font.GothamBold
        btn.TextSize               = 12
        btn.TextXAlignment         = Enum.TextXAlignment.Left
        btn.ZIndex                 = zIdx or 5
        btn.Parent                 = parent
        mkCorner(btn, CORNER_S)
        mkStroke(btn, 1, T.StrokeBrt, 0.6)
        mk3DShadow(btn, 2, 2, 0, 0.55)

        -- Left accent bar
        local accentBar = Instance.new("Frame")
        accentBar.Size                   = UDim2.new(0, 3, 1, -10)
        accentBar.Position               = UDim2.new(0, 8, 0, 5)
        accentBar.BackgroundColor3       = T.Accent
        accentBar.BackgroundTransparency = 0.4
        accentBar.BorderSizePixel        = 0
        accentBar.ZIndex                 = 6
        accentBar.Parent                 = btn
        mkCorner(accentBar, 2)
        regA(accentBar)

        -- Text padding
        local txt = Instance.new("TextLabel")
        txt.BackgroundTransparency = 1
        txt.Text           = text
        txt.Font           = Enum.Font.GothamBold
        txt.TextSize       = 12
        txt.TextColor3     = T.TextMain
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.Size           = UDim2.new(1, -32, 1, 0)
        txt.Position       = UDim2.new(0, 20, 0, 0)
        txt.ZIndex         = 7
        txt.Parent         = btn
        txt:SetAttribute("TextRole", "main")

        btn.Text = ""

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TWEEN_S, {
                BackgroundTransparency = 0.05,
                BackgroundColor3 = T.BgBtnHov
            }):Play()
            TweenService:Create(accentBar, TWEEN_S, {
                BackgroundTransparency = 0.1
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TWEEN_S, {
                BackgroundTransparency = 0.15,
                BackgroundColor3 = T.BgBtn
            }):Play()
            TweenService:Create(accentBar, TWEEN_S, {
                BackgroundTransparency = 0.4
            }):Play()
        end)

        if callback then
            btn.MouseButton1Click:Connect(callback)
        end

        return btn, txt
    end

    local function createLabel(text, parent, zIdx)
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Text           = text
        lbl.Font           = Enum.Font.Gotham
        lbl.TextSize       = 11
        lbl.TextColor3     = T.TextSub
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size           = UDim2.new(1, -16, 0, 18)
        lbl.Position       = UDim2.new(0, 8, 0, 0)
        lbl.ZIndex         = zIdx or 5
        lbl.Parent         = parent
        return lbl
    end

    local function createGameCard(gameName, placeId, callback)
        local card = Instance.new("Frame")
        card.Name                   = "GameCardBg"
        card.Size                   = UDim2.new(0, 132, 0, 100)
        card.BackgroundColor3       = T.BgCard
        card.BackgroundTransparency = 0.2
        card.BorderSizePixel        = 0
        card.ZIndex                 = 4
        card.Parent                 = gamesPanel
        mkCorner(card, CORNER_S)
        mkStroke(card, 1, T.StrokeBrt, 0.6)

        -- 3D Shadow
        mk3DShadow(card, 2, 2, 0, 0.5)

        -- Thumbnail
        local thumb = Instance.new("ImageLabel")
        thumb.Size                   = UDim2.new(1, -8, 0, 58)
        thumb.Position               = UDim2.new(0, 4, 0, 4)
        thumb.BackgroundColor3       = T.BgPanel
        thumb.BackgroundTransparency = 0.1
        thumb.Image                  = ""
        thumb.ImageTransparency      = 1
        thumb.ScaleType              = Enum.ScaleType.Crop
        thumb.ZIndex                 = 5
        thumb.Parent                 = card
        mkCorner(thumb, CORNER_XS)

        -- Game name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text           = gameName
        nameLabel.Font           = Enum.Font.GothamBold
        nameLabel.TextSize       = 10
        nameLabel.TextColor3     = T.TextMain
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        nameLabel.TextTruncate   = Enum.TextTruncate.AtEnd
        nameLabel.Size           = UDim2.new(1, -8, 0, 16)
        nameLabel.Position       = UDim2.new(0, 4, 1, -20)
        nameLabel.ZIndex         = 5
        nameLabel.Parent         = card
        nameLabel:SetAttribute("TextRole", "main")

        -- Neon hover
        local hoverGlow = Instance.new("UIStroke")
        hoverGlow.Thickness       = 2
        hoverGlow.Color           = T.Accent
        hoverGlow.Transparency    = 1
        hoverGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        hoverGlow.Parent          = card

        local btn = Instance.new("TextButton")
        btn.Size                   = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text                   = ""
        btn.ZIndex                 = 7
        btn.Parent                 = card

        btn.MouseEnter:Connect(function()
            TweenService:Create(card, TWEEN_S, {BackgroundTransparency = 0.08}):Play()
            TweenService:Create(hoverGlow, TWEEN_S, {Transparency = 0.4}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(card, TWEEN_S, {BackgroundTransparency = 0.2}):Play()
            TweenService:Create(hoverGlow, TWEEN_S, {Transparency = 1}):Play()
        end)

        if callback then
            btn.MouseButton1Click:Connect(callback)
        end

        return card, thumb
    end

    -- ═══ DRAGGING ═══

    local dragging, dragInput, dragStart, startPos

    headerFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    headerFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            -- Smooth tween
            TweenService:Create(mainFrame, TWEEN_S, {Position = newPos}):Play()
        end
    end)

    -- ═══ RETURN ALL REFS ═══

    return {
        screenGui           = screenGui,
        mainFrame           = mainFrame,
        headerFrame         = headerFrame,
        sidebarFrame        = sidebarFrame,
        catScroll           = catScroll,
        catLayout           = catLayout,
        contentFrame        = contentFrame,
        scrollingFrame      = scrollingFrame,
        gamesPanel          = gamesPanel,
        closeBtn            = closeBtn,
        reopenButton        = reopenButton,
        gameName            = gameName,

        mkCorner            = mkCorner,
        mkStroke            = mkStroke,
        mk3DShadow          = mk3DShadow,
        mkNeonBorder        = mkNeonBorder,
        mkGlassSheen        = mkGlassSheen,
        mkNeonLine          = mkNeonLine,
        mkGlassCard         = mkGlassCard,

        createSectionHeader = createSectionHeader,
        createButton        = createButton,
        createLabel         = createLabel,
        createGameCard      = createGameCard,
    }
end
