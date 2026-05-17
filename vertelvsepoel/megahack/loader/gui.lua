-- gui.lua  ·  Glass Minimal redesign
-- Полностью переписан визуал. Все публичные поля совместимы с logic.lua / theme.lua.
-- Убраны UIStroke'и с обводками — вместо них полупрозрачные подложки дают
-- эффект «стекла» без лишнего шума. Цвет текста / акцент применяется явно везде.

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

    -- ─────────────────────────────────────────
    --  HELPERS
    -- ─────────────────────────────────────────
    local function mkCorner(parent, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 10)
        c.Parent = parent
        return c
    end

    -- Тонкая полупрозрачная стеклянная обводка (белая, почти невидимая)
    local function mkStroke(parent, thickness, color, alpha)
        local s = Instance.new("UIStroke")
        s.Thickness    = thickness or 1
        s.Color        = color or Color3.new(1, 1, 1)
        s.Transparency = alpha or 0.80
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = parent
        return s
    end

    -- Блик сверху (имитация стекла)
    local function mkGlassSheen(parent, zIdx)
        local sh = Instance.new("Frame")
        sh.Name                   = "GlassSheen"
        sh.BackgroundColor3       = Color3.new(1, 1, 1)
        sh.BackgroundTransparency = 0.88
        sh.BorderSizePixel        = 0
        sh.Size                   = UDim2.new(1, 0, 0.44, 0)
        sh.ZIndex                 = zIdx or 10
        sh.Parent                 = parent
        mkCorner(sh, 10)
        local g = Instance.new("UIGradient")
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.50),
            NumberSequenceKeypoint.new(1, 1.00),
        })
        g.Rotation = 90
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
    --  SCREEN GUI
    -- ─────────────────────────────────────────
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name           = "HackGui"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = false
    screenGui.ResetOnSpawn   = false

    local function Hide_UI(g)
        local ok = pcall(function()
            if get_hidden_gui then g.Parent = get_hidden_gui()
            elseif gethui then g.Parent = gethui()
            elseif syn and typeof(syn) == "table" and syn.protect_gui then
                syn.protect_gui(g); g.Parent = CoreGui
            elseif CoreGui:FindFirstChild("RobloxGui") then g.Parent = CoreGui.RobloxGui
            else g.Parent = CoreGui end
        end)
        if not ok then g.Parent = CoreGui end
    end
    Hide_UI(screenGui)

    -- ─────────────────────────────────────────
    --  MAIN FRAME  580 × 380
    -- ─────────────────────────────────────────
    local mainFrame = Instance.new("Frame")
    mainFrame.Name                   = "MainFrame"
    mainFrame.BackgroundColor3       = T.BgBase
    mainFrame.BackgroundTransparency = 0.06
    mainFrame.BorderSizePixel        = 0
    mainFrame.AnchorPoint            = Vector2.new(0.5, 0.5)
    mainFrame.Position               = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size                   = UDim2.new(0, 580, 0, 380)
    mainFrame.ZIndex                 = 2
    mainFrame.Parent                 = screenGui
    mkCorner(mainFrame, 14)
    mkStroke(mainFrame, 1, Color3.new(1, 1, 1), 0.72)
    mkGlassSheen(mainFrame, 3)

    -- Акцент-черта снизу
    local bottomAccent = Instance.new("Frame")
    bottomAccent.BackgroundColor3       = T.Accent
    bottomAccent.BackgroundTransparency = 0.50
    bottomAccent.BorderSizePixel        = 0
    bottomAccent.Size                   = UDim2.new(0.6, 0, 0, 2)
    bottomAccent.Position               = UDim2.new(0.2, 0, 1, -2)
    bottomAccent.ZIndex                 = 4
    bottomAccent.Parent                 = mainFrame
    mkCorner(bottomAccent, 2)
    regA(bottomAccent)

    -- ─────────────────────────────────────────
    --  HEADER  46px
    -- ─────────────────────────────────────────
    local headerFrame = Instance.new("Frame")
    headerFrame.BackgroundColor3       = T.BgSide
    headerFrame.BackgroundTransparency = 0.10
    headerFrame.BorderSizePixel        = 0
    headerFrame.Size                   = UDim2.new(1, 0, 0, 46)
    headerFrame.ZIndex                 = 5
    headerFrame.Parent                 = mainFrame
    mkCorner(headerFrame, 14)
    mkGlassSheen(headerFrame, 6)

    -- Патч нижних скруглений header
    local headerPatch = Instance.new("Frame")
    headerPatch.BackgroundColor3       = T.BgSide
    headerPatch.BackgroundTransparency = 0.10
    headerPatch.BorderSizePixel        = 0
    headerPatch.Size                   = UDim2.new(1, 0, 0, 14)
    headerPatch.Position               = UDim2.new(0, 0, 1, -14)
    headerPatch.ZIndex                 = 5
    headerPatch.Parent                 = headerFrame

    -- Разделитель header/content
    local headerLine = Instance.new("Frame")
    headerLine.BackgroundColor3       = Color3.new(1, 1, 1)
    headerLine.BackgroundTransparency = 0.88
    headerLine.BorderSizePixel        = 0
    headerLine.Size                   = UDim2.new(1, 0, 0, 1)
    headerLine.Position               = UDim2.new(0, 0, 1, -1)
    headerLine.ZIndex                 = 7
    headerLine.Parent                 = headerFrame

    -- Цветной пип-акцент
    local headerPip = Instance.new("Frame")
    headerPip.BackgroundColor3 = T.Accent
    headerPip.BorderSizePixel  = 0
    headerPip.Size             = UDim2.new(0, 3, 0, 22)
    headerPip.Position         = UDim2.new(0, 14, 0.5, -11)
    headerPip.ZIndex           = 8
    headerPip.Parent           = headerFrame
    mkCorner(headerPip, 2)
    regA(headerPip)

    -- Иконка
    local logoIcon = Instance.new("ImageLabel")
    logoIcon.BackgroundTransparency = 1
    logoIcon.Image    = "rbxassetid://7072717762"
    logoIcon.Size     = UDim2.new(0, 20, 0, 20)
    logoIcon.Position = UDim2.new(0, 24, 0.5, -10)
    logoIcon.ZIndex   = 8
    logoIcon.Parent   = headerFrame

    -- Название
    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text           = "MEGAHACK"
    titleLabel.Font           = Enum.Font.GothamBold
    titleLabel.TextSize       = 15
    titleLabel.TextColor3     = T.TextMain
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size           = UDim2.new(0, 110, 0, 20)
    titleLabel.Position       = UDim2.new(0, 50, 0.5, -10)
    titleLabel.ZIndex         = 8
    titleLabel.Parent         = headerFrame
    titleLabel:SetAttribute("TextRole", "main")

    -- Бейдж версии
    local versionBadge = Instance.new("Frame")
    versionBadge.BackgroundColor3       = T.Accent
    versionBadge.BackgroundTransparency = 0.28
    versionBadge.BorderSizePixel        = 0
    versionBadge.Size                   = UDim2.new(0, 34, 0, 16)
    versionBadge.Position               = UDim2.new(0, 164, 0.5, -8)
    versionBadge.ZIndex                 = 8
    versionBadge.Parent                 = headerFrame
    mkCorner(versionBadge, 5)
    regA(versionBadge)

    local versionText = Instance.new("TextLabel")
    versionText.BackgroundTransparency = 1
    versionText.Text      = "v1.0"
    versionText.Font      = Enum.Font.GothamBold
    versionText.TextSize  = 10
    versionText.TextColor3 = T.TextMain
    versionText.Size      = UDim2.new(1, 0, 1, 0)
    versionText.ZIndex    = 9
    versionText.Parent    = versionBadge
    versionText:SetAttribute("TextRole", "main")

    -- Счётчик скриптов
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

    -- Название игры
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
    closeBtn.BackgroundColor3       = Color3.fromRGB(175, 48, 48)
    closeBtn.BackgroundTransparency = 0.30
    closeBtn.BorderSizePixel        = 0
    closeBtn.Size                   = UDim2.new(0, 22, 0, 22)
    closeBtn.Position               = UDim2.new(1, -34, 0.5, -11)
    closeBtn.Text                   = "×"
    closeBtn.TextColor3             = T.TextMain
    closeBtn.TextSize               = 17
    closeBtn.Font                   = Enum.Font.GothamBold
    closeBtn.ZIndex                 = 10
    closeBtn.Parent                 = headerFrame
    mkCorner(closeBtn, 7)
    closeBtn:SetAttribute("TextRole", "main")

    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.13), {BackgroundTransparency = 0}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.13), {BackgroundTransparency = 0.30}):Play()
    end)

    -- ─────────────────────────────────────────
    --  SIDEBAR  136px
    -- ─────────────────────────────────────────
    local sidebarFrame = Instance.new("Frame")
    sidebarFrame.BackgroundColor3       = T.BgSide
    sidebarFrame.BackgroundTransparency = 0.12
    sidebarFrame.BorderSizePixel        = 0
    sidebarFrame.Size                   = UDim2.new(0, 136, 1, -46)
    sidebarFrame.Position               = UDim2.new(0, 0, 0, 46)
    sidebarFrame.ZIndex                 = 3
    sidebarFrame.Parent                 = mainFrame
    mkGlassSheen(sidebarFrame, 4)

    local sidebarPatch = Instance.new("Frame")
    sidebarPatch.BackgroundColor3       = T.BgSide
    sidebarPatch.BackgroundTransparency = 0.12
    sidebarPatch.BorderSizePixel        = 0
    sidebarPatch.Size                   = UDim2.new(1, 0, 0, 14)
    sidebarPatch.Position               = UDim2.new(0, 0, 0, 0)
    sidebarPatch.ZIndex                 = 3
    sidebarPatch.Parent                 = sidebarFrame

    local sidebarBLCorner = Instance.new("Frame")
    sidebarBLCorner.BackgroundColor3       = T.BgSide
    sidebarBLCorner.BackgroundTransparency = 0.12
    sidebarBLCorner.BorderSizePixel        = 0
    sidebarBLCorner.Size                   = UDim2.new(0, 14, 0, 14)
    sidebarBLCorner.Position               = UDim2.new(0, 0, 1, -14)
    sidebarBLCorner.ZIndex                 = 3
    sidebarBLCorner.Parent                 = mainFrame
    mkCorner(sidebarBLCorner, 14)

    -- Вертикальный разделитель
    local sidebarSep = Instance.new("Frame")
    sidebarSep.BackgroundColor3       = Color3.new(1, 1, 1)
    sidebarSep.BackgroundTransparency = 0.90
    sidebarSep.BorderSizePixel        = 0
    sidebarSep.Size                   = UDim2.new(0, 1, 1, -46)
    sidebarSep.Position               = UDim2.new(0, 136, 0, 46)
    sidebarSep.ZIndex                 = 4
    sidebarSep.Parent                 = mainFrame

    -- Скролл категорий
    local catScroll = Instance.new("ScrollingFrame")
    catScroll.BackgroundTransparency = 1
    catScroll.BorderSizePixel        = 0
    catScroll.Size                   = UDim2.new(1, 0, 1, -6)
    catScroll.Position               = UDim2.new(0, 0, 0, 6)
    catScroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
    catScroll.ScrollBarThickness     = 2
    catScroll.ScrollBarImageColor3   = T.Accent
    catScroll.ZIndex                 = 5
    catScroll.Parent                 = sidebarFrame
    regA(catScroll, "ScrollBarImageColor3")

    local catLayout = Instance.new("UIListLayout")
    catLayout.Padding   = UDim.new(0, 2)
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    catLayout.Parent    = catScroll

    local catPad = Instance.new("UIPadding")
    catPad.PaddingLeft  = UDim.new(0, 7)
    catPad.PaddingRight = UDim.new(0, 7)
    catPad.PaddingTop   = UDim.new(0, 4)
    catPad.Parent       = catScroll

    catLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        catScroll.CanvasSize = UDim2.new(0, 0, 0, catLayout.AbsoluteContentSize.Y + 12)
    end)

    -- ─────────────────────────────────────────
    --  CONTENT PANEL
    -- ─────────────────────────────────────────
    local contentFrame = Instance.new("Frame")
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel        = 0
    contentFrame.Size                   = UDim2.new(1, -138, 1, -50)
    contentFrame.Position               = UDim2.new(0, 138, 0, 50)
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

    local scrollPad = Instance.new("UIPadding")
    scrollPad.PaddingLeft  = UDim.new(0, 8)
    scrollPad.PaddingRight = UDim.new(0, 10)
    scrollPad.PaddingTop   = UDim.new(0, 7)
    scrollPad.Parent       = scrollingFrame

    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 18)
    end)

    -- ─────────────────────────────────────────
    --  REOPEN BUTTON
    -- ─────────────────────────────────────────
    local reopenButton = Instance.new("ImageButton")
    reopenButton.Size                   = UDim2.new(0, 44, 0, 44)
    reopenButton.Position               = UDim2.new(0.5, -22, 0.9, -22)
    reopenButton.BackgroundColor3       = T.BgSide
    reopenButton.BackgroundTransparency = 0.10
    reopenButton.Image                  = "rbxassetid://74283928898866"
    reopenButton.ImageTransparency      = 0.10
    reopenButton.ImageColor3            = T.TextMain
    reopenButton.Visible                = false
    reopenButton.ZIndex                 = 12
    reopenButton.Parent                 = screenGui
    mkCorner(reopenButton, 22)

    local reopenRing = Instance.new("UIStroke")
    reopenRing.Thickness    = 1.5
    reopenRing.Color        = T.Accent
    reopenRing.Transparency = 0.20
    reopenRing.Parent       = reopenButton
    regA(reopenRing, "Color")

    reopenButton.MouseEnter:Connect(function()
        TweenService:Create(reopenButton, TweenInfo.new(0.17),
            {BackgroundColor3 = T.Accent, BackgroundTransparency = 0}):Play()
    end)
    reopenButton.MouseLeave:Connect(function()
        TweenService:Create(reopenButton, TweenInfo.new(0.17),
            {BackgroundColor3 = T.BgSide, BackgroundTransparency = 0.10}):Play()
    end)

    -- ─────────────────────────────────────────
    --  UI HELPERS  (вызываются из logic.lua)
    -- ─────────────────────────────────────────

    local function createSectionHeader(text, parent)
        local container = Instance.new("Frame")
        container.BackgroundTransparency = 1
        container.Size   = UDim2.new(1, 0, 0, 26)
        container.ZIndex = 4
        container.Parent = parent

        local line = Instance.new("Frame")
        line.BackgroundColor3       = Color3.new(1, 1, 1)
        line.BackgroundTransparency = 0.90
        line.BorderSizePixel        = 0
        line.Size                   = UDim2.new(1, 0, 0, 1)
        line.Position               = UDim2.new(0, 0, 1, -1)
        line.ZIndex                 = 4
        line.Parent                 = container

        local pip = Instance.new("Frame")
        pip.BackgroundColor3 = T.Accent
        pip.BorderSizePixel  = 0
        pip.Size             = UDim2.new(0, 3, 0, 13)
        pip.Position         = UDim2.new(0, 0, 0.5, -6)
        pip.ZIndex           = 5
        pip.Parent           = container
        mkCorner(pip, 2)
        regA(pip)

        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Text           = string.upper(text)
        lbl.Font           = Enum.Font.GothamBold
        lbl.TextSize       = 10
        lbl.TextColor3     = T.Accent
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size           = UDim2.new(1, -14, 1, 0)
        lbl.Position       = UDim2.new(0, 12, 0, 0)
        lbl.ZIndex         = 5
        lbl.Parent         = container
        -- Цвет секции = акцент → обновляется через updateGuiColors в logic.lua
        -- Здесь не ставим TextRole="main" чтобы заголовок не перекрашивался в textColor
        return container
    end

    local function createLabel(text, parent, size, position)
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Text           = text
        label.Size           = size     or UDim2.new(1, 0, 0, 24)
        label.Position       = position or UDim2.new(0, 0, 0, 0)
        label.TextSize       = 12
        label.TextColor3     = T.TextMain
        label.TextTransparency = 0.08
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
            -- ── Sidebar tab ──
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
            btn.ZIndex                 = 6
            btn.Parent                 = parent
            mkCorner(btn, 8)

            local btnPad = Instance.new("UIPadding")
            btnPad.PaddingLeft = UDim.new(0, 28)
            btnPad.Parent      = btn

            local strip = Instance.new("Frame")
            strip.BackgroundColor3       = T.Accent
            strip.BackgroundTransparency = 1
            strip.BorderSizePixel        = 0
            strip.Size                   = UDim2.new(0, 3, 0, 16)
            strip.Position               = UDim2.new(0, 8, 0.5, -8)
            strip.ZIndex                 = 7
            strip.Parent                 = btn
            mkCorner(strip, 2)
            regA(strip)

            btn.MouseEnter:Connect(function()
                if btn:GetAttribute("Active") then return end
                TweenService:Create(btn, TweenInfo.new(0.14),
                    {BackgroundTransparency = 0.75, TextColor3 = T.TextMain}):Play()
            end)
            btn.MouseLeave:Connect(function()
                if btn:GetAttribute("Active") then return end
                TweenService:Create(btn, TweenInfo.new(0.14),
                    {BackgroundTransparency = 1, TextColor3 = T.TextSub}):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                for _, child in ipairs(parent:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:SetAttribute("Active", false)
                        TweenService:Create(child, TweenInfo.new(0.14), {
                            BackgroundColor3       = T.BgBtn,
                            BackgroundTransparency = 1,
                            TextColor3             = T.TextSub,
                        }):Play()
                        local s = child:FindFirstChildWhichIsA("Frame")
                        if s and s.Name ~= "GlassSheen" then
                            TweenService:Create(s, TweenInfo.new(0.14), {BackgroundTransparency = 1}):Play()
                        end
                    end
                end
                btn:SetAttribute("Active", true)
                TweenService:Create(btn, TweenInfo.new(0.14), {
                    BackgroundColor3       = T.Accent,
                    BackgroundTransparency = 0.70,
                    TextColor3             = T.TextMain,
                }):Play()
                TweenService:Create(strip, TweenInfo.new(0.14), {BackgroundTransparency = 0}):Play()
                callback()
            end)
            return btn

        else
            -- ── Content card-button (стеклянная карточка) ──
            local btn = Instance.new("TextButton")
            btn.Size                   = UDim2.new(1, 0, 0, 34)
            btn.BackgroundColor3       = T.BgPanel
            btn.BackgroundTransparency = 0.22
            btn.BorderSizePixel        = 0
            btn.Text                   = ""
            btn.TextSize               = 0
            btn.ZIndex                 = 4
            btn.Parent                 = parent
            mkCorner(btn, 9)
            mkStroke(btn, 1, Color3.new(1, 1, 1), 0.82)

            -- Верхний блик
            local sheen = Instance.new("Frame")
            sheen.Name                   = "Sheen"
            sheen.BackgroundColor3       = Color3.new(1, 1, 1)
            sheen.BackgroundTransparency = 0.92
            sheen.BorderSizePixel        = 0
            sheen.Size                   = UDim2.new(1, 0, 0.5, 0)
            sheen.ZIndex                 = 5
            sheen.Parent                 = btn
            mkCorner(sheen, 9)

            -- Акцент-полоска слева (hover)
            local accentBar = Instance.new("Frame")
            accentBar.BackgroundColor3       = T.Accent
            accentBar.BackgroundTransparency = 1
            accentBar.BorderSizePixel        = 0
            accentBar.Size                   = UDim2.new(0, 3, 0, 18)
            accentBar.Position               = UDim2.new(0, 8, 0.5, -9)
            accentBar.ZIndex                 = 6
            accentBar.Parent                 = btn
            mkCorner(accentBar, 2)
            regA(accentBar)

            local label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1
            label.Text           = text
            label.Font           = Enum.Font.Gotham
            label.TextSize       = 13
            label.TextColor3     = T.TextMain
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Size           = UDim2.new(1, -24, 1, 0)
            label.Position       = UDim2.new(0, 20, 0, 0)
            label.ZIndex         = 6
            label.Parent         = btn
            label:SetAttribute("TextRole", "main")

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.12),
                    {BackgroundColor3 = T.BgBtnHov, BackgroundTransparency = 0.10}):Play()
                TweenService:Create(accentBar, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.12),
                    {BackgroundColor3 = T.BgPanel, BackgroundTransparency = 0.22}):Play()
                TweenService:Create(accentBar, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.07),
                    {BackgroundColor3 = T.Accent, BackgroundTransparency = 0.45}):Play()
                task.delay(0.13, function()
                    TweenService:Create(btn, TweenInfo.new(0.15),
                        {BackgroundColor3 = T.BgBtnHov, BackgroundTransparency = 0.10}):Play()
                end)
                callback()
            end)
            return btn
        end
    end

    -- ─────────────────────────────────────────
    --  PUBLIC API  (совместимо с logic.lua и theme.lua)
    -- ─────────────────────────────────────────
    return {
        -- frames
        screenGui       = screenGui,
        mainFrame       = mainFrame,
        headerFrame     = headerFrame,
        headerPatch     = headerPatch,
        sidebarFrame    = sidebarFrame,
        sidebarPatch    = sidebarPatch,
        sidebarBLCorner = sidebarBLCorner,
        catScroll       = catScroll,
        scrollingFrame  = scrollingFrame,
        closeBtn        = closeBtn,
        reopenButton    = reopenButton,
        -- meta
        gameName        = ok and gname or "Unknown",
        -- helpers
        mkCorner            = mkCorner,
        mkStroke            = mkStroke,
        createButton        = createButton,
        createLabel         = createLabel,
        createSectionHeader = createSectionHeader,
        -- notification setter
        setNotification = function(fn)
            createNotification = fn
        end,
    }
end
