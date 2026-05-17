-- gui.lua
-- Возвращает функцию-фабрику. Получает deps, строит весь визуал,
-- возвращает таблицу с фреймами и хелперами.
-- Чтобы сменить стиль — просто замени этот файл на другой.

return function(deps)
    local TweenService    = deps.TweenService
    local UserInputService= deps.UserInputService
    local CoreGui         = deps.CoreGui
    local MarketplaceService = deps.MarketplaceService
    local playerGui       = deps.playerGui
    local platformName    = deps.platformName
    local T               = deps.T
    local regA            = deps.regA
    local HubData         = deps.HubData

    -- notification будет передана позже через setNotification
    local createNotification = function() end

    -- ══════════════════════════════════════
    --  HELPERS
    -- ══════════════════════════════════════
    local function mkCorner(parent, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 8)
        c.Parent = parent
        return c
    end

    local function mkStroke(parent, thickness, color, transparency)
        local s = Instance.new("UIStroke")
        s.Thickness    = thickness    or 1
        s.Color        = color        or T.Stroke
        s.Transparency = transparency or 0.5
        s.Parent = parent
        return s
    end

    local function countScripts()
        local n = 0
        for _, cat in pairs(HubData) do
            if type(cat) == "table" then n = n + #cat end
        end
        return n
    end

    -- ══════════════════════════════════════
    --  SCREEN GUI
    -- ══════════════════════════════════════
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HackGui"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = false
    screenGui.ResetOnSpawn   = false

    local function Hide_UI(g)
        local ok = pcall(function()
            if get_hidden_gui then g.Parent = get_hidden_gui()
            elseif gethui then g.Parent = gethui()
            elseif syn and typeof(syn)=="table" and syn.protect_gui then
                syn.protect_gui(g); g.Parent = CoreGui
            elseif CoreGui:FindFirstChild("RobloxGui") then g.Parent = CoreGui.RobloxGui
            else g.Parent = CoreGui end
        end)
        if not ok then g.Parent = CoreGui end
    end
    Hide_UI(screenGui)

    -- ══════════════════════════════════════
    --  MAIN FRAME  560 × 370
    -- ══════════════════════════════════════
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.BackgroundColor3    = T.BgBase
    mainFrame.BackgroundTransparency = 0.04
    mainFrame.BorderSizePixel     = 0
    mainFrame.AnchorPoint         = Vector2.new(0.5, 0.5)
    mainFrame.Position            = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size                = UDim2.new(0, 560, 0, 370)
    mainFrame.ZIndex              = 2
    mainFrame.Parent              = screenGui
    mkCorner(mainFrame, 12)
    mkStroke(mainFrame, 1.5, T.StrokeBrt, 0.55)

    -- ══════════════════════════════════════
    --  HEADER
    -- ══════════════════════════════════════
    local headerFrame = Instance.new("Frame")
    headerFrame.BackgroundColor3 = T.BgSide
    headerFrame.BorderSizePixel  = 0
    headerFrame.Size             = UDim2.new(1, 0, 0, 44)
    headerFrame.ZIndex           = 4
    headerFrame.Parent           = mainFrame
    mkCorner(headerFrame, 12)

    local headerPatch = Instance.new("Frame")
    headerPatch.BackgroundColor3 = T.BgSide
    headerPatch.BorderSizePixel  = 0
    headerPatch.Size             = UDim2.new(1, 0, 0, 12)
    headerPatch.Position         = UDim2.new(0, 0, 1, -12)
    headerPatch.ZIndex           = 4
    headerPatch.Parent           = headerFrame

    local headerLine = Instance.new("Frame")
    headerLine.BackgroundColor3  = T.Separator
    headerLine.BorderSizePixel   = 0
    headerLine.Size              = UDim2.new(1, 0, 0, 1)
    headerLine.Position          = UDim2.new(0, 0, 1, -1)
    headerLine.ZIndex            = 5
    headerLine.Parent            = headerFrame

    local headerAccent = Instance.new("Frame")
    headerAccent.BackgroundColor3 = T.Accent
    headerAccent.BorderSizePixel  = 0
    headerAccent.Size             = UDim2.new(0, 4, 0, 24)
    headerAccent.Position         = UDim2.new(0, 12, 0.5, -12)
    headerAccent.ZIndex           = 6
    headerAccent.Parent           = headerFrame
    mkCorner(headerAccent, 3)
    regA(headerAccent)

    local logoIcon = Instance.new("ImageLabel")
    logoIcon.BackgroundTransparency = 1
    logoIcon.Image    = "rbxassetid://7072717762"
    logoIcon.Size     = UDim2.new(0, 22, 0, 22)
    logoIcon.Position = UDim2.new(0, 22, 0.5, -11)
    logoIcon.ZIndex   = 6
    logoIcon.Parent   = headerFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text            = "MEGAHACK"
    titleLabel.Font            = Enum.Font.GothamBold
    titleLabel.TextSize        = 16
    titleLabel.TextColor3      = T.TextMain
    titleLabel.TextXAlignment  = Enum.TextXAlignment.Left
    titleLabel.Size            = UDim2.new(0, 120, 0, 22)
    titleLabel.Position        = UDim2.new(0, 50, 0.5, -11)
    titleLabel.ZIndex          = 6
    titleLabel.Parent          = headerFrame
    titleLabel:SetAttribute("TextRole", "main")

    local versionBadge = Instance.new("Frame")
    versionBadge.BackgroundColor3    = T.Accent
    versionBadge.BackgroundTransparency = 0.3
    versionBadge.BorderSizePixel     = 0
    versionBadge.Size                = UDim2.new(0, 36, 0, 16)
    versionBadge.Position            = UDim2.new(0, 174, 0.5, -8)
    versionBadge.ZIndex              = 6
    versionBadge.Parent              = headerFrame
    mkCorner(versionBadge, 4)
    regA(versionBadge)

    local versionText = Instance.new("TextLabel")
    versionText.BackgroundTransparency = 1
    versionText.Text     = "v1.0"
    versionText.Font     = Enum.Font.GothamBold
    versionText.TextSize = 10
    versionText.TextColor3 = T.TextMain
    versionText.Size     = UDim2.new(1, 0, 1, 0)
    versionText.ZIndex   = 7
    versionText.Parent   = versionBadge
    versionText:SetAttribute("TextRole", "main")

    local scriptCountLabel = Instance.new("TextLabel")
    scriptCountLabel.BackgroundTransparency = 1
    scriptCountLabel.Text           = countScripts() .. " scripts"
    scriptCountLabel.Font           = Enum.Font.Gotham
    scriptCountLabel.TextSize       = 11
    scriptCountLabel.TextColor3     = T.TextSub
    scriptCountLabel.TextXAlignment = Enum.TextXAlignment.Right
    scriptCountLabel.Size           = UDim2.new(0, 120, 0, 20)
    scriptCountLabel.Position       = UDim2.new(1, -160, 0.5, -10)
    scriptCountLabel.ZIndex         = 6
    scriptCountLabel.Parent         = headerFrame

    local ok, gname = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)
    local gameNameHeader = Instance.new("TextLabel")
    gameNameHeader.BackgroundTransparency = 1
    gameNameHeader.Text           = ok and gname or "Unknown Game"
    gameNameHeader.Font           = Enum.Font.Gotham
    gameNameHeader.TextSize       = 11
    gameNameHeader.TextColor3     = T.TextMuted
    gameNameHeader.TextXAlignment = Enum.TextXAlignment.Right
    gameNameHeader.Size           = UDim2.new(0, 140, 0, 14)
    gameNameHeader.Position       = UDim2.new(1, -184, 0.5, 4)
    gameNameHeader.ZIndex         = 6
    gameNameHeader.Parent         = headerFrame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name                   = "CloseBtn"
    closeBtn.BackgroundColor3       = Color3.fromRGB(160, 40, 40)
    closeBtn.BackgroundTransparency = 0.4
    closeBtn.BorderSizePixel        = 0
    closeBtn.Size                   = UDim2.new(0, 24, 0, 24)
    closeBtn.Position               = UDim2.new(1, -36, 0.5, -12)
    closeBtn.Text                   = "×"
    closeBtn.TextColor3             = T.TextMain
    closeBtn.TextSize               = 18
    closeBtn.Font                   = Enum.Font.GothamBold
    closeBtn.ZIndex                 = 8
    closeBtn.Parent                 = headerFrame
    mkCorner(closeBtn, 6)
    closeBtn:SetAttribute("TextRole", "main")
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.1}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.4}):Play()
    end)

    -- ══════════════════════════════════════
    --  SIDEBAR
    -- ══════════════════════════════════════
    local sidebarFrame = Instance.new("Frame")
    sidebarFrame.BackgroundColor3 = T.BgSide
    sidebarFrame.BorderSizePixel  = 0
    sidebarFrame.Size             = UDim2.new(0, 130, 1, -44)
    sidebarFrame.Position         = UDim2.new(0, 0, 0, 44)
    sidebarFrame.ZIndex           = 3
    sidebarFrame.Parent           = mainFrame

    local sidebarPatch = Instance.new("Frame")
    sidebarPatch.BackgroundColor3 = T.BgSide
    sidebarPatch.BorderSizePixel  = 0
    sidebarPatch.Size             = UDim2.new(1, 0, 0, 12)
    sidebarPatch.Position         = UDim2.new(0, 0, 0, 0)
    sidebarPatch.ZIndex           = 3
    sidebarPatch.Parent           = sidebarFrame

    local sidebarBLCorner = Instance.new("Frame")
    sidebarBLCorner.BackgroundColor3 = T.BgSide
    sidebarBLCorner.BorderSizePixel  = 0
    sidebarBLCorner.Size             = UDim2.new(0, 12, 0, 12)
    sidebarBLCorner.Position         = UDim2.new(0, 0, 1, -12)
    sidebarBLCorner.ZIndex           = 3
    sidebarBLCorner.Parent           = mainFrame
    mkCorner(sidebarBLCorner, 12)

    local sidebarSep = Instance.new("Frame")
    sidebarSep.BackgroundColor3 = T.Separator
    sidebarSep.BorderSizePixel  = 0
    sidebarSep.Size             = UDim2.new(0, 1, 1, -44)
    sidebarSep.Position         = UDim2.new(0, 130, 0, 44)
    sidebarSep.ZIndex           = 4
    sidebarSep.Parent           = mainFrame

    local catScroll = Instance.new("ScrollingFrame")
    catScroll.BackgroundTransparency = 1
    catScroll.BorderSizePixel        = 0
    catScroll.Size                   = UDim2.new(1, 0, 1, -8)
    catScroll.Position               = UDim2.new(0, 0, 0, 8)
    catScroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
    catScroll.ScrollBarThickness     = 2
    catScroll.ScrollBarImageColor3   = T.Accent
    catScroll.ZIndex                 = 4
    catScroll.Parent                 = sidebarFrame
    regA(catScroll, "ScrollBarImageColor3")

    local catLayout = Instance.new("UIListLayout")
    catLayout.Padding     = UDim.new(0, 2)
    catLayout.SortOrder   = Enum.SortOrder.LayoutOrder
    catLayout.Parent      = catScroll
    local catPadding = Instance.new("UIPadding")
    catPadding.PaddingLeft  = UDim.new(0, 6)
    catPadding.PaddingRight = UDim.new(0, 6)
    catPadding.Parent       = catScroll
    catLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        catScroll.CanvasSize = UDim2.new(0, 0, 0, catLayout.AbsoluteContentSize.Y + 10)
    end)

    -- ══════════════════════════════════════
    --  CONTENT PANEL
    -- ══════════════════════════════════════
    local contentFrame = Instance.new("Frame")
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel        = 0
    contentFrame.Size                   = UDim2.new(1, -131, 1, -48)
    contentFrame.Position               = UDim2.new(0, 131, 0, 48)
    contentFrame.ZIndex                 = 3
    contentFrame.Parent                 = mainFrame

    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel        = 0
    scrollingFrame.Size                   = UDim2.new(1, -4, 1, 0)
    scrollingFrame.CanvasSize             = UDim2.new(0, 0, 0, 0)
    scrollingFrame.ScrollBarThickness     = 3
    scrollingFrame.ScrollBarImageColor3   = T.Accent
    scrollingFrame.ZIndex                 = 3
    scrollingFrame.Parent                 = contentFrame
    regA(scrollingFrame, "ScrollBarImageColor3")

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Padding   = UDim.new(0, 5)
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Parent    = scrollingFrame
    local scrollPadding = Instance.new("UIPadding")
    scrollPadding.PaddingLeft  = UDim.new(0, 8)
    scrollPadding.PaddingRight = UDim.new(0, 8)
    scrollPadding.PaddingTop   = UDim.new(0, 6)
    scrollPadding.Parent       = scrollingFrame
    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 16)
    end)

    -- ══════════════════════════════════════
    --  REOPEN BUTTON
    -- ══════════════════════════════════════
    local reopenButton = Instance.new("ImageButton")
    reopenButton.Size                   = UDim2.new(0, 46, 0, 46)
    reopenButton.Position               = UDim2.new(0.5, -23, 0.9, -23)
    reopenButton.BackgroundColor3       = T.BgSide
    reopenButton.BackgroundTransparency = 0.1
    reopenButton.Image                  = "rbxassetid://74283928898866"
    reopenButton.ImageTransparency      = 0.15
    reopenButton.ImageColor3            = T.TextMain
    reopenButton.Visible                = false
    reopenButton.ZIndex                 = 10
    reopenButton.Parent                 = screenGui
    mkCorner(reopenButton, 23)
    do local s = mkStroke(reopenButton, 1.5, T.Accent, 0.3); regA(s, "Color") end

    reopenButton.MouseEnter:Connect(function()
        TweenService:Create(reopenButton, TweenInfo.new(0.2), {BackgroundColor3 = T.Accent, BackgroundTransparency = 0}):Play()
    end)
    reopenButton.MouseLeave:Connect(function()
        TweenService:Create(reopenButton, TweenInfo.new(0.2), {BackgroundColor3 = T.BgSide, BackgroundTransparency = 0.1}):Play()
    end)

    -- ══════════════════════════════════════
    --  UI HELPERS (используются в logic.lua)
    -- ══════════════════════════════════════
    local function createSectionHeader(text, parent)
        local container = Instance.new("Frame")
        container.BackgroundTransparency = 1
        container.Size   = UDim2.new(1, 0, 0, 24)
        container.ZIndex = 3
        container.Parent = parent

        local line = Instance.new("Frame")
        line.BackgroundColor3 = T.Separator
        line.BorderSizePixel  = 0
        line.Size             = UDim2.new(1, 0, 0, 1)
        line.Position         = UDim2.new(0, 0, 1, -1)
        line.ZIndex           = 3
        line.Parent           = container

        local pip = Instance.new("Frame")
        pip.BackgroundColor3 = T.Accent
        pip.BorderSizePixel  = 0
        pip.Size             = UDim2.new(0, 3, 0, 14)
        pip.Position         = UDim2.new(0, 0, 0.5, -7)
        pip.ZIndex           = 4
        pip.Parent           = container
        mkCorner(pip, 2)
        regA(pip)

        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Text           = string.upper(text)
        lbl.Font           = Enum.Font.GothamBold
        lbl.TextSize       = 11
        lbl.TextColor3     = T.TextSub
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size           = UDim2.new(1, -12, 1, 0)
        lbl.Position       = UDim2.new(0, 10, 0, 0)
        lbl.ZIndex         = 4
        lbl.Parent         = container
        return container
    end

    local function createLabel(text, parent, size, position)
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Text           = text
        label.Size           = size     or UDim2.new(1, 0, 0, 24)
        label.Position       = position or UDim2.new(0, 0, 0, 0)
        label.TextSize       = 13
        label.TextColor3     = T.TextMain
        label.TextTransparency = 0.1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font           = Enum.Font.Gotham
        label.TextWrapped    = true
        label.ZIndex         = 4
        label.Parent         = parent
        label:SetAttribute("TextRole", "main")
        return label
    end

    local function createButton(text, parent, callback, isCategoryButton)
        if isCategoryButton then
            local btn = Instance.new("TextButton")
            btn.Size                   = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3       = T.BgBtn
            btn.BackgroundTransparency = 1
            btn.BorderSizePixel        = 0
            btn.Text                   = text
            btn.TextColor3             = T.TextSub
            btn.TextSize               = 12
            btn.TextXAlignment         = Enum.TextXAlignment.Left
            btn.Font                   = Enum.Font.Gotham
            btn.ZIndex                 = 5
            btn.Parent                 = parent
            mkCorner(btn, 6)
            local btnPad = Instance.new("UIPadding")
            btnPad.PaddingLeft = UDim.new(0, 10)
            btnPad.Parent      = btn

            local activeIndicator = Instance.new("Frame")
            activeIndicator.BackgroundColor3       = T.AccentGlow
            activeIndicator.BackgroundTransparency = 1
            activeIndicator.BorderSizePixel        = 0
            activeIndicator.Size                   = UDim2.new(0, 3, 0, 16)
            activeIndicator.Position               = UDim2.new(0, -6, 0.5, -8)
            activeIndicator.ZIndex                 = 6
            activeIndicator.Parent                 = btn
            mkCorner(activeIndicator, 2)
            regA(activeIndicator)

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundTransparency = 0.5, TextColor3 = T.TextMain}):Play()
            end)
            btn.MouseLeave:Connect(function()
                if btn:GetAttribute("Active") then return end
                TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundTransparency = 1, TextColor3 = T.TextSub}):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                for _, child in ipairs(parent:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:SetAttribute("Active", false)
                        TweenService:Create(child, TweenInfo.new(0.18), {BackgroundColor3 = T.BgBtn, BackgroundTransparency = 1, TextColor3 = T.TextSub}):Play()
                        local ind = child:FindFirstChild("Frame")
                        if ind then TweenService:Create(ind, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play() end
                    end
                end
                btn:SetAttribute("Active", true)
                TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = T.Accent, BackgroundTransparency = 0.35, TextColor3 = T.TextMain}):Play()
                TweenService:Create(activeIndicator, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
                callback()
            end)
            return btn
        else
            local btn = Instance.new("TextButton")
            btn.Size                   = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3       = T.BgBtn
            btn.BackgroundTransparency = 0.3
            btn.BorderSizePixel        = 0
            btn.Text                   = text
            btn.TextColor3             = T.TextMain
            btn.TextSize               = 13
            btn.TextTransparency       = 0.05
            btn.TextXAlignment         = Enum.TextXAlignment.Left
            btn.Font                   = Enum.Font.Gotham
            btn.ZIndex                 = 4
            btn.Parent                 = parent
            btn:SetAttribute("TextRole", "main")
            mkCorner(btn, 7)
            mkStroke(btn, 1, T.Stroke, 0.4)

            local btnPad = Instance.new("UIPadding")
            btnPad.PaddingLeft = UDim.new(0, 12)
            btnPad.Parent      = btn

            local accentLine = Instance.new("Frame")
            accentLine.BackgroundColor3       = T.Accent
            accentLine.BackgroundTransparency = 1
            accentLine.BorderSizePixel        = 0
            accentLine.Size                   = UDim2.new(0, 2, 0, 16)
            accentLine.Position               = UDim2.new(0, 6, 0.5, -8)
            accentLine.ZIndex                 = 5
            accentLine.Parent                 = btn
            mkCorner(accentLine, 2)
            regA(accentLine)

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = T.BgBtnHov, BackgroundTransparency = 0.1}):Play()
                TweenService:Create(accentLine, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = T.BgBtn, BackgroundTransparency = 0.3}):Play()
                TweenService:Create(accentLine, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = T.Accent, BackgroundTransparency = 0.4}):Play()
                task.delay(0.12, function()
                    TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = T.BgBtnHov, BackgroundTransparency = 0.1}):Play()
                end)
                callback()
            end)
            return btn
        end
    end

    -- ══════════════════════════════════════
    --  PUBLIC API
    -- ══════════════════════════════════════
    return {
        -- frames
        screenGui      = screenGui,
        mainFrame      = mainFrame,
        headerFrame    = headerFrame,
        headerPatch    = headerPatch,
        sidebarFrame   = sidebarFrame,
        sidebarPatch   = sidebarPatch,
        sidebarBLCorner= sidebarBLCorner,
        catScroll      = catScroll,
        scrollingFrame = scrollingFrame,
        closeBtn       = closeBtn,
        reopenButton   = reopenButton,
        -- game info
        gameName       = ok and gname or "Unknown",
        -- helpers
        mkCorner             = mkCorner,
        mkStroke             = mkStroke,
        createButton         = createButton,
        createLabel          = createLabel,
        createSectionHeader  = createSectionHeader,
        -- notification setter (вызывается из maybemenu после определения)
        setNotification = function(fn)
            createNotification = fn
        end,
    }
end
