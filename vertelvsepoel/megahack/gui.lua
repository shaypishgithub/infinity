-- ══════════════════════════════════════════════════════════════════
--  gui.lua  —  Построение интерфейса (исправленный)
--  ИСПРАВЛЕНО: dummyPatch объявлен ДО использования в return {}
--  ИСПРАВЛЕНО: createNotification — заглушка, заменяется через setNotification()
-- ══════════════════════════════════════════════════════════════════
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

    local createNotification = function() end  -- заглушка, заменяется setNotification()

    -- ─────────────────────────────────────────
    -- ГЛОБАЛЬНЫЕ СТИЛИ
    -- ─────────────────────────────────────────
    local CORNER_RADIUS = 16
    local TWEEN_FAST    = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- ─────────────────────────────────────────
    -- HELPERS
    -- ─────────────────────────────────────────
    local function mkCorner(parent, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or CORNER_RADIUS)
        c.Parent = parent
        return c
    end

    local function mkStroke(parent, thickness, color, alpha)
        local s = Instance.new("UIStroke")
        s.Thickness       = thickness or 1
        s.Color           = color or Color3.new(1, 1, 1)
        s.Transparency    = alpha or 0.85
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent          = parent
        return s
    end

    local function mkGlassSheen(parent, zIdx)
        local sh = Instance.new("Frame")
        sh.Name                   = "GlassSheen"
        sh.BackgroundColor3       = Color3.new(1, 1, 1)
        sh.BackgroundTransparency = 0.94
        sh.BorderSizePixel        = 0
        sh.Size                   = UDim2.new(1, 0, 1, 0)
        sh.ZIndex                 = zIdx or 10
        sh.Parent                 = parent
        local cornerR = CORNER_RADIUS
        local existingCorner = parent:FindFirstChildWhichIsA("UICorner")
        if existingCorner then cornerR = existingCorner.CornerRadius.Offset end
        mkCorner(sh, cornerR)
        local g = Instance.new("UIGradient")
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,   0.3),
            NumberSequenceKeypoint.new(0.4, 0.9),
            NumberSequenceKeypoint.new(1,   1),
        })
        g.Rotation = 45
        g.Parent   = sh
        return sh
    end

    local function countScripts()
        local n = 0
        for _, cat in pairs(HubData) do
            if type(cat) == "table" then n = n + #cat end
        end
        return n
    end

    -- ─────────────────────────────────────────
    -- SCREEN GUI
    -- ─────────────────────────────────────────
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name           = "HackGui_Refined"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn   = false

    local function Hide_UI(g)
        local ok = pcall(function()
            if get_hidden_gui then
                g.Parent = get_hidden_gui()
            elseif gethui then
                g.Parent = gethui()
            elseif syn and typeof(syn) == "table" and syn.protect_gui then
                syn.protect_gui(g); g.Parent = CoreGui
            elseif CoreGui:FindFirstChild("RobloxGui") then
                g.Parent = CoreGui.RobloxGui
            else
                g.Parent = CoreGui
            end
        end)
        if not ok then g.Parent = CoreGui end
    end
    Hide_UI(screenGui)

    -- ─────────────────────────────────────────
    -- MAIN FRAME
    -- ─────────────────────────────────────────
    local mainFrame = Instance.new("Frame")
    mainFrame.Name                   = "MainFrame"
    mainFrame.BackgroundColor3       = T.BgBase
    mainFrame.BackgroundTransparency = 0.12
    mainFrame.BorderSizePixel        = 0
    mainFrame.AnchorPoint            = Vector2.new(0.5, 0.5)
    mainFrame.Position               = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size                   = UDim2.new(0, 580, 0, 380)
    mainFrame.ZIndex                 = 2
    mainFrame.Parent                 = screenGui
    mkCorner(mainFrame, CORNER_RADIUS)
    mkStroke(mainFrame, 1.2, Color3.new(1, 1, 1), 0.75)
    mkGlassSheen(mainFrame, 3)

    local bottomAccent = Instance.new("Frame")
    bottomAccent.BackgroundColor3       = T.Accent
    bottomAccent.BackgroundTransparency = 0.40
    bottomAccent.BorderSizePixel        = 0
    bottomAccent.Size                   = UDim2.new(0.4, 0, 0, 2)
    bottomAccent.Position               = UDim2.new(0.3, 0, 1, -3)
    bottomAccent.ZIndex                 = 4
    bottomAccent.Parent                 = mainFrame
    mkCorner(bottomAccent, 2)
    regA(bottomAccent)

    -- ─────────────────────────────────────────
    -- HEADER
    -- ─────────────────────────────────────────
    local headerFrame = Instance.new("Frame")
    headerFrame.Name                 = "HeaderFrame"
    headerFrame.BackgroundTransparency = 1
    headerFrame.Size                 = UDim2.new(1, 0, 0, 50)
    headerFrame.ZIndex               = 5
    headerFrame.Parent               = mainFrame

    local headerLine = Instance.new("Frame")
    headerLine.BackgroundColor3       = Color3.new(1, 1, 1)
    headerLine.BackgroundTransparency = 0.90
    headerLine.BorderSizePixel        = 0
    headerLine.Size                   = UDim2.new(1, -24, 0, 1)
    headerLine.Position               = UDim2.new(0, 12, 1, 0)
    headerLine.ZIndex                 = 7
    headerLine.Parent                 = headerFrame

    local logoIcon = Instance.new("ImageLabel")
    logoIcon.BackgroundTransparency = 1
    logoIcon.Image    = "rbxassetid://7072717762"
    logoIcon.Size     = UDim2.new(0, 18, 0, 18)
    logoIcon.Position = UDim2.new(0, 16, 0.5, -9)
    logoIcon.ZIndex   = 8
    logoIcon.Parent   = headerFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text           = "MEGAHACK"
    titleLabel.Font           = Enum.Font.GothamBold
    titleLabel.TextSize       = 14
    titleLabel.TextColor3     = T.TextMain
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size           = UDim2.new(0, 100, 0, 20)
    titleLabel.Position       = UDim2.new(0, 42, 0.5, -10)
    titleLabel.ZIndex         = 8
    titleLabel.Parent         = headerFrame
    titleLabel:SetAttribute("TextRole", "main")

    local versionBadge = Instance.new("Frame")
    versionBadge.BackgroundColor3       = T.Accent
    versionBadge.BackgroundTransparency = 0.20
    versionBadge.BorderSizePixel        = 0
    versionBadge.Size                   = UDim2.new(0, 36, 0, 16)
    versionBadge.Position               = UDim2.new(0, 132, 0.5, -8)
    versionBadge.ZIndex                 = 8
    versionBadge.Parent                 = headerFrame
    mkCorner(versionBadge, 6)
    regA(versionBadge)

    local versionText = Instance.new("TextLabel")
    versionText.BackgroundTransparency = 1
    versionText.Text    = "v1.0"
    versionText.Font    = Enum.Font.GothamBold
    versionText.TextSize = 10
    versionText.TextColor3 = T.TextMain
    versionText.Size    = UDim2.new(1, 0, 1, 0)
    versionText.ZIndex  = 9
    versionText.Parent  = versionBadge
    versionText:SetAttribute("TextRole", "main")

    local scriptCountLabel = Instance.new("TextLabel")
    scriptCountLabel.BackgroundTransparency = 1
    scriptCountLabel.Text           = countScripts() .. " scripts"
    scriptCountLabel.Font           = Enum.Font.Gotham
    scriptCountLabel.TextSize       = 11
    scriptCountLabel.TextColor3     = T.TextSub
    scriptCountLabel.TextXAlignment = Enum.TextXAlignment.Right
    scriptCountLabel.Size           = UDim2.new(0, 110, 0, 18)
    scriptCountLabel.Position       = UDim2.new(1, -162, 0.5, -9)
    scriptCountLabel.ZIndex         = 8
    scriptCountLabel.Parent         = headerFrame

    local ok, gname = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)
    local gameNameHeader = Instance.new("TextLabel")
    gameNameHeader.BackgroundTransparency = 1
    gameNameHeader.Text           = ok and gname or "Unknown Game"
    gameNameHeader.Font           = Enum.Font.Gotham
    gameNameHeader.TextSize       = 10
    gameNameHeader.TextColor3     = T.TextMuted
    gameNameHeader.TextXAlignment = Enum.TextXAlignment.Right
    gameNameHeader.Size           = UDim2.new(0, 140, 0, 14)
    gameNameHeader.Position       = UDim2.new(1, -184, 0.5, 6)
    gameNameHeader.ZIndex         = 8
    gameNameHeader.Parent         = headerFrame

    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name                   = "CloseBtn"
    closeBtn.BackgroundColor3       = Color3.fromRGB(200, 60, 60)
    closeBtn.BackgroundTransparency = 0.40
    closeBtn.BorderSizePixel        = 0
    closeBtn.Size                   = UDim2.new(0, 24, 0, 24)
    closeBtn.Position               = UDim2.new(1, -36, 0.5, -12)
    closeBtn.Text                   = "×"
    closeBtn.TextColor3             = T.TextMain
    closeBtn.TextSize               = 18
    closeBtn.Font                   = Enum.Font.Gotham
    closeBtn.ZIndex                 = 10
    closeBtn.Parent                 = headerFrame
    mkCorner(closeBtn, 12)
    closeBtn:SetAttribute("TextRole", "main")
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TWEEN_FAST, {BackgroundTransparency=0.1, BackgroundColor3=Color3.fromRGB(230,50,50)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TWEEN_FAST, {BackgroundTransparency=0.40, BackgroundColor3=Color3.fromRGB(200,60,60)}):Play()
    end)

    -- ─────────────────────────────────────────
    -- SIDEBAR
    -- ─────────────────────────────────────────
    local sidebarFrame = Instance.new("Frame")
    sidebarFrame.Name                   = "SidebarFrame"
    sidebarFrame.BackgroundTransparency = 1
    sidebarFrame.Size                   = UDim2.new(0, 140, 1, -50)
    sidebarFrame.Position               = UDim2.new(0, 0, 0, 50)
    sidebarFrame.ZIndex                 = 3
    sidebarFrame.Parent                 = mainFrame

    local sidebarSep = Instance.new("Frame")
    sidebarSep.BackgroundColor3       = Color3.new(1, 1, 1)
    sidebarSep.BackgroundTransparency = 0.94
    sidebarSep.BorderSizePixel        = 0
    sidebarSep.Size                   = UDim2.new(0, 1, 1, -20)
    sidebarSep.Position               = UDim2.new(1, -1, 0, 10)
    sidebarSep.ZIndex                 = 4
    sidebarSep.Parent                 = sidebarFrame

    local catScroll = Instance.new("ScrollingFrame")
    catScroll.BackgroundTransparency = 1
    catScroll.BorderSizePixel        = 0
    catScroll.Size                   = UDim2.new(1, -6, 1, -12)
    catScroll.Position               = UDim2.new(0, 6, 0, 6)
    catScroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
    catScroll.ScrollBarThickness     = 0
    catScroll.ZIndex                 = 5
    catScroll.Parent                 = sidebarFrame

    local catLayout = Instance.new("UIListLayout")
    catLayout.Padding   = UDim.new(0, 4)
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    catLayout.Parent    = catScroll

    local catPad = Instance.new("UIPadding")
    catPad.PaddingLeft  = UDim.new(0, 6)
    catPad.PaddingRight = UDim.new(0, 6)
    catPad.PaddingTop   = UDim.new(0, 4)
    catPad.Parent       = catScroll

    catLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        catScroll.CanvasSize = UDim2.new(0, 0, 0, catLayout.AbsoluteContentSize.Y + 12)
    end)

    -- ИСПРАВЛЕНО: dummyPatch объявляется ДО return {}, не после
    local dummyPatch = Instance.new("Frame")
    dummyPatch.Visible = false
    dummyPatch.Parent  = mainFrame

    -- ─────────────────────────────────────────
    -- CONTENT PANEL
    -- ─────────────────────────────────────────
    local contentFrame = Instance.new("Frame")
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel        = 0
    contentFrame.Size                   = UDim2.new(1, -152, 1, -62)
    contentFrame.Position               = UDim2.new(0, 146, 0, 56)
    contentFrame.ZIndex                 = 3
    contentFrame.Parent                 = mainFrame

    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel        = 0
    scrollingFrame.Size                   = UDim2.new(1, 0, 1, 0)
    scrollingFrame.CanvasSize             = UDim2.new(0, 0, 0, 0)
    scrollingFrame.ScrollBarThickness     = 2
    scrollingFrame.ScrollBarImageColor3   = T.Accent
    scrollingFrame.ZIndex                 = 3
    scrollingFrame.Parent                 = contentFrame
    regA(scrollingFrame, "ScrollBarImageColor3")

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Padding   = UDim.new(0, 6)
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Parent    = scrollingFrame

    local scrollPad = Instance.new("UIPadding")
    scrollPad.PaddingLeft  = UDim.new(0, 4)
    scrollPad.PaddingRight = UDim.new(0, 8)
    scrollPad.PaddingTop   = UDim.new(0, 2)
    scrollPad.Parent       = scrollingFrame

    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 10)
    end)

    -- ─────────────────────────────────────────
    -- REOPEN BUTTON
    -- ─────────────────────────────────────────
    local reopenButton = Instance.new("ImageButton")
    reopenButton.Size                   = UDim2.new(0, 46, 0, 46)
    reopenButton.Position               = UDim2.new(0.5, -23, 0.9, -23)
    reopenButton.BackgroundColor3       = T.BgSide
    reopenButton.BackgroundTransparency = 0.15
    reopenButton.Image                  = "rbxassetid://74283928898866"
    reopenButton.ImageTransparency      = 0.10
    reopenButton.ImageColor3            = T.TextMain
    reopenButton.Visible                = false
    reopenButton.ZIndex                 = 12
    reopenButton.Parent                 = screenGui
    mkCorner(reopenButton, 23)

    local reopenRing = mkStroke(reopenButton, 1.5, T.Accent, 0.3)
    regA(reopenRing, "Color")

    reopenButton.MouseEnter:Connect(function()
        TweenService:Create(reopenButton, TWEEN_FAST, {BackgroundColor3=T.Accent, BackgroundTransparency=0.1}):Play()
    end)
    reopenButton.MouseLeave:Connect(function()
        TweenService:Create(reopenButton, TWEEN_FAST, {BackgroundColor3=T.BgSide, BackgroundTransparency=0.15}):Play()
    end)

    -- ─────────────────────────────────────────
    -- UI HELPERS
    -- ─────────────────────────────────────────
    local function createSectionHeader(text, parent)
        local container = Instance.new("Frame")
        container.BackgroundTransparency = 1
        container.Size   = UDim2.new(1, 0, 0, 28)
        container.ZIndex = 4
        container.Parent = parent

        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Text           = string.upper(text)
        lbl.Font           = Enum.Font.GothamBold
        lbl.TextSize       = 11
        lbl.TextColor3     = T.Accent
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size           = UDim2.new(1, 0, 1, 0)
        lbl.ZIndex         = 5
        lbl.Parent         = container
        return container
    end

    local function createLabel(text, parent, size, position)
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Text             = text
        label.Size             = size or UDim2.new(1, 0, 0, 24)
        label.Position         = position or UDim2.new(0, 0, 0, 0)
        label.TextSize         = 12
        label.TextColor3       = T.TextMain
        label.TextTransparency = 0.1
        label.TextXAlignment   = Enum.TextXAlignment.Left
        label.Font             = Enum.Font.Gotham
        label.TextWrapped      = true
        label.ZIndex           = 4
        label.Parent           = parent
        label:SetAttribute("TextRole", "main")
        return label
    end

    local function createButton(text, parent, callback, isCategoryButton)
        if isCategoryButton then
            local btn = Instance.new("TextButton")
            btn.Size                   = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3       = T.Accent
            btn.BackgroundTransparency = 1
            btn.BorderSizePixel        = 0
            btn.Text                   = text
            btn.TextColor3             = T.TextSub
            btn.TextSize               = 12
            btn.TextXAlignment         = Enum.TextXAlignment.Left
            btn.Font                   = Enum.Font.GothamMedium
            btn.ZIndex                 = 6
            btn.Parent                 = parent
            mkCorner(btn, 8)

            local btnPad = Instance.new("UIPadding")
            btnPad.PaddingLeft = UDim.new(0, 14)
            btnPad.Parent      = btn

            btn.MouseEnter:Connect(function()
                if btn:GetAttribute("Active") then return end
                TweenService:Create(btn, TWEEN_FAST, {BackgroundTransparency=0.92, TextColor3=T.TextMain}):Play()
            end)
            btn.MouseLeave:Connect(function()
                if btn:GetAttribute("Active") then return end
                TweenService:Create(btn, TWEEN_FAST, {BackgroundTransparency=1, TextColor3=T.TextSub}):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                for _, child in ipairs(parent:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:SetAttribute("Active", false)
                        TweenService:Create(child, TWEEN_FAST, {BackgroundTransparency=1, TextColor3=T.TextSub}):Play()
                    end
                end
                btn:SetAttribute("Active", true)
                TweenService:Create(btn, TWEEN_FAST, {BackgroundTransparency=0.80, TextColor3=T.Accent}):Play()
                callback()
            end)
            return btn
        else
            local btn = Instance.new("TextButton")
            btn.Size                   = UDim2.new(1, 0, 0, 36)
            btn.BackgroundColor3       = T.BgPanel
            btn.BackgroundTransparency = 0.40
            btn.BorderSizePixel        = 0
            btn.Text                   = ""
            btn.ZIndex                 = 4
            btn.Parent                 = parent
            mkCorner(btn, 10)
            local s = mkStroke(btn, 1, Color3.new(1, 1, 1), 0.88)

            local label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1
            label.Text           = text
            label.Font           = Enum.Font.Gotham
            label.TextSize       = 13
            label.TextColor3     = T.TextMain
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Size           = UDim2.new(1, -20, 1, 0)
            label.Position       = UDim2.new(0, 12, 0, 0)
            label.ZIndex         = 6
            label.Parent         = btn
            label:SetAttribute("TextRole", "main")

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TWEEN_FAST, {BackgroundTransparency=0.20, BackgroundColor3=T.BgBtnHov}):Play()
                TweenService:Create(s,   TWEEN_FAST, {Transparency=0.6}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TWEEN_FAST, {BackgroundTransparency=0.40, BackgroundColor3=T.BgPanel}):Play()
                TweenService:Create(s,   TWEEN_FAST, {Transparency=0.88}):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.05), {BackgroundColor3=T.Accent, BackgroundTransparency=0.3}):Play()
                task.delay(0.08, function()
                    TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3=T.BgBtnHov, BackgroundTransparency=0.20}):Play()
                end)
                callback()
            end)
            return btn
        end
    end

    -- ─────────────────────────────────────────
    -- PUBLIC API
    -- ─────────────────────────────────────────
    return {
        screenGui      = screenGui,
        mainFrame      = mainFrame,
        headerFrame    = headerFrame,
        headerPatch    = dummyPatch,       -- для совместимости с logic.lua
        sidebarFrame   = sidebarFrame,
        sidebarPatch   = dummyPatch,
        sidebarBLCorner = dummyPatch,
        catScroll      = catScroll,
        scrollingFrame = scrollingFrame,
        closeBtn       = closeBtn,
        reopenButton   = reopenButton,
        gameName       = ok and gname or "Unknown",
        mkCorner       = mkCorner,
        mkStroke       = mkStroke,
        createButton   = createButton,
        createLabel    = createLabel,
        createSectionHeader = createSectionHeader,
        setNotification = function(fn) createNotification = fn end,
    }
end
