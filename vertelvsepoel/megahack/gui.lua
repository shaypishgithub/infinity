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

    local createNotification = function() end

    local CORNER   = 16
    local CORNER_S = 10
    local TWEEN_F  = TweenInfo.new(0.18, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)
    local TWEEN_M  = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    local function mkCorner(parent, r)
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or CORNER); c.Parent = parent; return c
    end

    local function mkStroke(parent, thickness, color, alpha)
        local s = Instance.new("UIStroke"); s.Thickness = thickness or 1; s.Color = color or Color3.new(1,1,1); s.Transparency = alpha or 0.85; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = parent; return s
    end

    -- Optimized True Glass (Single Gradient, 0 extra frames)
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
        local n = 0; for _, cat in pairs(HubData) do if type(cat) == "table" then n = n + #cat end end; return n
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RussElite_GUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false

    local function protectGui(g)
        local ok = pcall(function()
            if get_hidden_gui then g.Parent = get_hidden_gui()
            elseif gethui then g.Parent = gethui()
            elseif syn and typeof(syn) == "table" and syn.protect_gui then syn.protect_gui(g); g.Parent = CoreGui
            else g.Parent = CoreGui end
        end)
        if not ok then g.Parent = CoreGui end
    end
    protectGui(screenGui)

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.BackgroundColor3 = T.BgBase
    mainFrame.BackgroundTransparency = 0.04
    mainFrame.BorderSizePixel = 0
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5,0,0.5,0)
    mainFrame.Size = UDim2.new(0,590,0,400)
    mainFrame.ZIndex = 2
    mainFrame.Parent = screenGui
    mkCorner(mainFrame, CORNER)
    mkStroke(mainFrame, 1, Color3.new(1,1,1), 0.80)
    mkGlassEffect(mainFrame)

    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.BackgroundColor3 = T.Accent
    accentBar.BackgroundTransparency = 0.2
    accentBar.BorderSizePixel = 0
    accentBar.Size = UDim2.new(0.38,0,0,2)
    accentBar.Position = UDim2.new(0.31,0,1,-3)
    accentBar.ZIndex = 4
    accentBar.Parent = mainFrame
    mkCorner(accentBar, 2)
    regA(accentBar)

    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "HeaderFrame"
    headerFrame.BackgroundTransparency = 1
    headerFrame.Size = UDim2.new(1,0,0,52)
    headerFrame.ZIndex = 5
    headerFrame.Parent = mainFrame

    local headerLine = Instance.new("Frame")
    headerLine.BackgroundColor3 = Color3.new(1,1,1)
    headerLine.BackgroundTransparency = 0.90
    headerLine.BorderSizePixel = 0
    headerLine.Size = UDim2.new(1,-24,0,1)
    headerLine.Position = UDim2.new(0,12,1,0)
    headerLine.ZIndex = 6
    headerLine.Parent = headerFrame

    local logoIcon = Instance.new("ImageLabel")
    logoIcon.BackgroundTransparency = 1
    logoIcon.Image = "rbxassetid://7072717762"
    logoIcon.Size = UDim2.new(0,20,0,20)
    logoIcon.Position = UDim2.new(0,16,0.5,-10)
    logoIcon.ZIndex = 8
    logoIcon.Parent = headerFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "RUSSELITE"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 15
    titleLabel.TextColor3 = T.TextMain
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0,110,0,22)
    titleLabel.Position = UDim2.new(0,44,0.5,-11)
    titleLabel.ZIndex = 8
    titleLabel.Parent = headerFrame
    titleLabel:SetAttribute("TextRole","main")

    local versionBadge = Instance.new("Frame")
    versionBadge.BackgroundColor3 = T.Accent
    versionBadge.BackgroundTransparency = 0.2
    versionBadge.BorderSizePixel = 0
    versionBadge.Size = UDim2.new(0,38,0,17)
    versionBadge.Position = UDim2.new(0,148,0.5,-8)
    versionBadge.ZIndex = 8
    versionBadge.Parent = headerFrame
    mkCorner(versionBadge, 6)
    regA(versionBadge)

    local versionText = Instance.new("TextLabel")
    versionText.BackgroundTransparency = 1
    versionText.Text = "v3.0"
    versionText.Font = Enum.Font.GothamBold
    versionText.TextSize = 10
    versionText.TextColor3 = T.TextMain
    versionText.Size = UDim2.new(1,0,1,0)
    versionText.ZIndex = 9
    versionText.Parent = versionBadge
    versionText:SetAttribute("TextRole","main")

    local scriptCountLabel = Instance.new("TextLabel")
    scriptCountLabel.BackgroundTransparency = 1
    scriptCountLabel.Text = countScripts() .. " scripts"
    scriptCountLabel.Font = Enum.Font.Gotham
    scriptCountLabel.TextSize = 11
    scriptCountLabel.TextColor3 = T.TextSub
    scriptCountLabel.TextXAlignment = Enum.TextXAlignment.Right
    scriptCountLabel.Size = UDim2.new(0,110,0,18)
    scriptCountLabel.Position = UDim2.new(1,-168,0.5,-9)
    scriptCountLabel.ZIndex = 8
    scriptCountLabel.Parent = headerFrame

    local ok_g, gname = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId).Name end)
    local gameNameHeader = Instance.new("TextLabel")
    gameNameHeader.BackgroundTransparency = 1
    gameNameHeader.Text = ok_g and gname or "Unknown Game"
    gameNameHeader.Font = Enum.Font.Gotham
    gameNameHeader.TextSize = 10
    gameNameHeader.TextColor3 = T.TextMuted
    gameNameHeader.TextXAlignment = Enum.TextXAlignment.Right
    gameNameHeader.Size = UDim2.new(0,140,0,14)
    gameNameHeader.Position = UDim2.new(1,-190,0.5,6)
    gameNameHeader.ZIndex = 8
    gameNameHeader.Parent = headerFrame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.BackgroundColor3 = Color3.fromRGB(195,55,55)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.BorderSizePixel = 0
    closeBtn.Size = UDim2.new(0,26,0,26)
    closeBtn.Position = UDim2.new(1,-38,0.5,-13)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = T.TextMain
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.ZIndex = 10
    closeBtn.Parent = headerFrame
    mkCorner(closeBtn, 13)
    closeBtn:SetAttribute("TextRole","main")
    closeBtn.MouseEnter:Connect(function() TweenService:Create(closeBtn, TWEEN_F, {BackgroundTransparency=0.05, BackgroundColor3=Color3.fromRGB(230,50,50)}):Play() end)
    closeBtn.MouseLeave:Connect(function() TweenService:Create(closeBtn, TWEEN_F, {BackgroundTransparency=0.3, BackgroundColor3=Color3.fromRGB(195,55,55)}):Play() end)

    local sidebarFrame = Instance.new("Frame")
    sidebarFrame.Name = "SidebarFrame"
    sidebarFrame.BackgroundColor3 = T.BgSide
    sidebarFrame.BackgroundTransparency = 0.1
    sidebarFrame.Size = UDim2.new(0,148,1,-52)
    sidebarFrame.Position = UDim2.new(0,0,0,52)
    sidebarFrame.ZIndex = 3
    sidebarFrame.Parent = mainFrame
    mkGlassEffect(sidebarFrame)

    local sidebarSep = Instance.new("Frame")
    sidebarSep.BackgroundColor3 = Color3.new(1,1,1)
    sidebarSep.BackgroundTransparency = 0.94
    sidebarSep.BorderSizePixel = 0
    sidebarSep.Size = UDim2.new(0,1,1,-20)
    sidebarSep.Position = UDim2.new(1,-1,0,10)
    sidebarSep.ZIndex = 4
    sidebarSep.Parent = sidebarFrame

    local catScroll = Instance.new("ScrollingFrame")
    catScroll.BackgroundTransparency = 1
    catScroll.BorderSizePixel = 0
    catScroll.Size = UDim2.new(1,-6,1,-12)
    catScroll.Position = UDim2.new(0,6,0,6)
    catScroll.CanvasSize = UDim2.new(0,0,0,0)
    catScroll.ScrollBarThickness = 0
    catScroll.ZIndex = 5
    catScroll.Parent = sidebarFrame

    local catLayout = Instance.new("UIListLayout")
    catLayout.Padding = UDim.new(0,3)
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    catLayout.Parent = catScroll

    local catPad = Instance.new("UIPadding")
    catPad.PaddingLeft = UDim.new(0,6); catPad.PaddingRight = UDim.new(0,6); catPad.PaddingTop = UDim.new(0,4); catPad.PaddingBottom = UDim.new(0,4)
    catPad.Parent = catScroll

    catLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() catScroll.CanvasSize = UDim2.new(0,0,0, catLayout.AbsoluteContentSize.Y + 16) end)

    local contentFrame = Instance.new("Frame")
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.Size = UDim2.new(1,-160,1,-64)
    contentFrame.Position = UDim2.new(0,154,0,58)
    contentFrame.ZIndex = 3
    contentFrame.Parent = mainFrame

    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.Size = UDim2.new(1,0,1,0)
    scrollingFrame.CanvasSize = UDim2.new(0,0,0,0)
    scrollingFrame.ScrollBarThickness = 2
    scrollingFrame.ScrollBarImageColor3 = T.Accent
    scrollingFrame.ZIndex = 3
    scrollingFrame.Parent = contentFrame
    regA(scrollingFrame, "ScrollBarImageColor3")

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Padding = UDim.new(0,5)
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Parent = scrollingFrame

    local scrollPad = Instance.new("UIPadding")
    scrollPad.PaddingLeft = UDim.new(0,2); scrollPad.PaddingRight = UDim.new(0,8); scrollPad.PaddingTop = UDim.new(0,2); scrollPad.PaddingBottom = UDim.new(0,6)
    scrollPad.Parent = scrollingFrame

    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scrollingFrame.CanvasSize = UDim2.new(0,0,0, scrollLayout.AbsoluteContentSize.Y + 14) end)

    local gamesPanel = Instance.new("ScrollingFrame")
    gamesPanel.Name = "GamesPanel"
    gamesPanel.BackgroundTransparency = 1
    gamesPanel.BorderSizePixel = 0
    gamesPanel.Size = UDim2.new(1,0,1,0)
    gamesPanel.CanvasSize = UDim2.new(0,0,0,0)
    gamesPanel.ScrollBarThickness = 2
    gamesPanel.ScrollBarImageColor3 = T.Accent
    gamesPanel.Visible = false
    gamesPanel.ZIndex = 3
    gamesPanel.Parent = contentFrame
    regA(gamesPanel, "ScrollBarImageColor3")

    local gamesGrid = Instance.new("UIGridLayout")
    gamesGrid.CellSize = UDim2.new(0,128,0,96)
    gamesGrid.CellPadding = UDim2.new(0,8,0,8)
    gamesGrid.SortOrder = Enum.SortOrder.LayoutOrder
    gamesGrid.Parent = gamesPanel

    local gamesPad = Instance.new("UIPadding")
    gamesPad.PaddingLeft = UDim.new(0,4); gamesPad.PaddingTop = UDim.new(0,6); gamesPad.PaddingRight = UDim.new(0,4); gamesPad.PaddingBottom = UDim.new(0,6)
    gamesPad.Parent = gamesPanel

    gamesGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() gamesPanel.CanvasSize = UDim2.new(0,0,0, gamesGrid.AbsoluteContentSize.Y + 20) end)

    local reopenButton = Instance.new("TextButton")
    reopenButton.Name = "ReopenBtn"
    reopenButton.BackgroundColor3 = T.BgSide
    reopenButton.BackgroundTransparency = 0.2
    reopenButton.BorderSizePixel = 0
    reopenButton.Size = UDim2.new(0,44,0,44)
    reopenButton.Position = UDim2.new(0,20,0.5,-22)
    reopenButton.ZIndex = 10
    reopenButton.Text = ""
    reopenButton.Parent = screenGui
    mkCorner(reopenButton, 12)
    mkStroke(reopenButton, 1, T.Accent, 0.5)
    mkGlassEffect(reopenButton)
    reopenButton.Visible = false

    local function createButton(parent, text, size, pos, callback, zidx)
        local btn = Instance.new("TextButton")
        btn.Size = size or UDim2.new(1,0,0,32)
        btn.Position = pos or UDim2.new(0,0,0,0)
        btn.BackgroundColor3 = T.BgBtn
        btn.BackgroundTransparency = 0.2
        btn.BorderSizePixel = 0
        btn.Text = text or "Button"
        btn.TextColor3 = T.TextMain
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.ZIndex = zidx or 5
        btn.Parent = parent
        mkCorner(btn, CORNER_S)
        mkStroke(btn, 1, Color3.new(1,1,1), 0.82)
        mkGlassEffect(btn)
        btn.MouseEnter:Connect(function() TweenService:Create(btn, TWEEN_F, {BackgroundTransparency = 0.05, BackgroundColor3 = T.BgBtnHov}):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(btn, TWEEN_F, {BackgroundTransparency = 0.2, BackgroundColor3 = T.BgBtn}):Play() end)
        if callback then btn.MouseButton1Click:Connect(callback) end
        return btn
    end

    local function createLabel(parent, text, size, pos, color, align, font, textSize, zidx)
        local l = Instance.new("TextLabel")
        l.Text = text or ""
        l.Size = size or UDim2.new(1,0,0,20)
        l.Position = pos or UDim2.new(0,0,0,0)
        l.TextColor3 = color or T.TextMain
        l.TextXAlignment = align or Enum.TextXAlignment.Left
        l.Font = font or Enum.Font.Gotham
        l.TextSize = textSize or 12
        l.BackgroundTransparency = 1
        l.ZIndex = zidx or 5
        l.Parent = parent
        return l
    end

    local function createSectionHeader(text, parent)
        createLabel(parent, text, UDim2.new(1,0,0,24), nil, T.TextSub, nil, Enum.Font.GothamBold, 12, 5)
    end

    local function createGameCard(name, placeId, onClick)
        local card = Instance.new("Frame")
        card.Name = "GameCard"
        card.Size = UDim2.new(1,0,1,0)
        card.BackgroundColor3 = T.BgPanel
        card.BackgroundTransparency = 0.1
        card.BorderSizePixel = 0
        card.ZIndex = 4
        card.Parent = gamesPanel
        mkCorner(card, 12)
        mkStroke(card, 1, Color3.new(1,1,1), 0.82)
        mkGlassEffect(card)

        local thumb = Instance.new("ImageLabel")
        thumb.Size = UDim2.new(1,-8,0,60)
        thumb.Position = UDim2.new(0,4,0,4)
        thumb.BackgroundColor3 = T.BgBtn
        thumb.BackgroundTransparency = 0.5
        thumb.ImageTransparency = 1
        thumb.ZIndex = 5
        thumb.Parent = card
        mkCorner(thumb, 8)

        createLabel(card, name, UDim2.new(1,-8,0,20), UDim2.new(0,4,1,-24), T.TextMain, Enum.TextXAlignment.Center, Enum.Font.GothamBold, 11, 6)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,1,0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 7
        btn.Parent = card
        if onClick then btn.MouseButton1Click:Connect(onClick) end

        return card, thumb
    end

    return {
        mainFrame = mainFrame, headerFrame = headerFrame, sidebarFrame = sidebarFrame, catScroll = catScroll,
        contentFrame = contentFrame, scrollingFrame = scrollingFrame, gamesPanel = gamesPanel,
        closeBtn = closeBtn, reopenButton = reopenButton, gameName = ok_g and gname or "Unknown Game",
        createButton = createButton, createLabel = createLabel, createSectionHeader = createSectionHeader, createGameCard = createGameCard,
        mkCorner = mkCorner, mkStroke = mkStroke, mkGlassEffect = mkGlassEffect,
    }
end
