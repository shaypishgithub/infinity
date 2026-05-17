-- gui.lua  ·  Glass Minimalism redesign
-- Структура та же (все поля в return совпадают), визуал — полностью новый.
-- Нет UIStroke на обычных кнопках/панелях — граница через прозрачность фона.
-- Цвет акцента / текста / фона применяется через T везде корректно.

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

    -- ──────────────────────────────────────
    --  HELPERS
    -- ──────────────────────────────────────
    local function mkCorner(parent, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 8)
        c.Parent = parent
        return c
    end

    -- mkStroke оставляем для совместимости с logic.lua (searchBox и т.п.)
    -- но делаем его невидимым по умолчанию (Transparency = 1)
    local function mkStroke(parent, thickness, color, transparency)
        local s = Instance.new("UIStroke")
        s.Thickness    = thickness    or 1
        s.Color        = color        or T.Accent
        s.Transparency = transparency or 1   -- скрыт по умолчанию
        s.Parent       = parent
        return s
    end

    -- Тонкая accent-полоска сверху панели (имитация glass edge)
    local function mkGlassEdge(parent, accentColor)
        local edge = Instance.new("Frame")
        edge.Name             = "GlassEdge"
        edge.BackgroundColor3 = accentColor or T.Accent
        edge.BackgroundTransparency = 0.55
        edge.BorderSizePixel  = 0
        edge.Size             = UDim2.new(1, -24, 0, 1)
        edge.Position         = UDim2.new(0, 12, 0, 0)
        edge.ZIndex           = edge.Parent and (parent.ZIndex or 3) + 1 or 4
        edge.Parent           = parent
        mkCorner(edge, 1)
        return edge
    end

    local function countScripts()
        local n = 0
        for _, cat in pairs(HubData) do
            if type(cat) == "table" then n = n + #cat end
        end
        return n
    end

    -- ──────────────────────────────────────
    --  SCREEN GUI
    -- ──────────────────────────────────────
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name           = "HackGui"
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

    -- ──────────────────────────────────────
    --  MAIN FRAME  580 × 380
    -- ──────────────────────────────────────
    local mainFrame = Instance.new("Frame")
    mainFrame.Name                   = "MainFrame"
    mainFrame.BackgroundColor3       = T.BgBase
    mainFrame.BackgroundTransparency = 0.04
    mainFrame.BorderSizePixel        = 0
    mainFrame.AnchorPoint            = Vector2.new(0.5, 0.5)
    mainFrame.Position               = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size                   = UDim2.new(0, 580, 0, 380)
    mainFrame.ZIndex                 = 2
    mainFrame.Parent                 = screenGui
    mkCorner(mainFrame, 14)

    -- Лёгкая тень через градиент по краям (без UIStroke)
    local shadowFrame = Instance.new("ImageLabel")
    shadowFrame.BackgroundTransparency = 1
    shadowFrame.Image                  = "rbxassetid://5028857084"   -- Roblox встроенная тень
    shadowFrame.ImageColor3            = Color3.new(0, 0, 0)
    shadowFrame.ImageTransparency      = 0.55
    shadowFrame.ScaleType              = Enum.ScaleType.Slice
    shadowFrame.SliceCenter            = Rect.new(24, 24, 276, 276)
    shadowFrame.Size                   = UDim2.new(1, 28, 1, 28)
    shadowFrame.Position               = UDim2.new(0, -14, 0, -14)
    shadowFrame.ZIndex                 = 1
    shadowFrame.Parent                 = mainFrame

    -- ──────────────────────────────────────
    --  HEADER  (тёмная полоса с blur-эффектом)
    -- ──────────────────────────────────────
    local headerFrame = Instance.new("Frame")
    headerFrame.BackgroundColor3       = T.BgSide
    headerFrame.BackgroundTransparency = 0.08
    headerFrame.BorderSizePixel        = 0
    headerFrame.Size                   = UDim2.new(1, 0, 0, 46)
    headerFrame.ZIndex                 = 4
    headerFrame.Parent                 = mainFrame
    mkCorner(headerFrame, 14)

    -- patch чтобы закрыть нижние скруглённые углы header
    local headerPatch = Instance.new("Frame")
    headerPatch.BackgroundColor3 = T.BgSide
    headerPatch.BackgroundTransparency = 0.08
    headerPatch.BorderSizePixel  = 0
    headerPatch.Size             = UDim2.new(1, 0, 0, 14)
    headerPatch.Position         = UDim2.new(0, 0, 1, -14)
    headerPatch.ZIndex           = 4
    headerPatch.Parent           = headerFrame

    -- тонкая accent-линия снизу header
    local headerAccentLine = Instance.new("Frame")
    headerAccentLine.BackgroundColor3       = T.Accent
    headerAccentLine.BackgroundTransparency = 0.4
    headerAccentLine.BorderSizePixel        = 0
    headerAccentLine.Size                   = UDim2.new(0, 48, 0, 2)
    headerAccentLine.Position               = UDim2.new(0, 14, 1, -2)
    headerAccentLine.ZIndex                 = 6
    headerAccentLine.Parent                 = headerFrame
    mkCorner(headerAccentLine, 1)
    regA(headerAccentLine)

    -- Лого-иконка (круглая)
    local logoWrap = Instance.new("Frame")
    logoWrap.BackgroundColor3       = T.Accent
    logoWrap.BackgroundTransparency = 0.25
    logoWrap.BorderSizePixel        = 0
    logoWrap.Size                   = UDim2.new(0, 28, 0, 28)
    logoWrap.Position               = UDim2.new(0, 12, 0.5, -14)
    logoWrap.ZIndex                 = 6
    logoWrap.Parent                 = headerFrame
    mkCorner(logoWrap, 8)
    regA(logoWrap)

    local logoIcon = Instance.new("ImageLabel")
    logoIcon.BackgroundTransparency = 1
    logoIcon.Image                  = "rbxassetid://7072717762"
    logoIcon.ImageColor3            = T.TextMain
    logoIcon.Size                   = UDim2.new(0, 18, 0, 18)
    logoIcon.Position               = UDim2.new(0.5, -9, 0.5, -9)
    logoIcon.ZIndex                 = 7
    logoIcon.Parent                 = logoWrap

    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text           = "MEGAHACK"
    titleLabel.Font           = Enum.Font.GothamBold
    titleLabel.TextSize       = 15
    titleLabel.TextColor3     = T.TextMain
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size           = UDim2.new(0, 110, 0, 20)
    titleLabel.Position       = UDim2.new(0, 48, 0.5, -10)
    titleLabel.ZIndex         = 6
    titleLabel.Parent         = headerFrame
    titleLabel:SetAttribute("TextRole", "main")

    -- badge версии — без stroke, просто полупрозрачный rect
    local versionBadge = Instance.new("Frame")
    versionBadge.BackgroundColor3       = T.Accent
    versionBadge.BackgroundTransparency = 0.45
    versionBadge.BorderSizePixel        = 0
    versionBadge.Size                   = UDim2.new(0, 34, 0, 15)
    versionBadge.Position               = UDim2.new(0, 162, 0.5, -7)
    versionBadge.ZIndex                 = 6
    versionBadge.Parent                 = headerFrame
    mkCorner(versionBadge, 4)
    regA(versionBadge)

    local versionText = Instance.new("TextLabel")
    versionText.BackgroundTransparency = 1
    versionText.Text      = "v1.0"
    versionText.Font      = Enum.Font.GothamBold
    versionText.TextSize  = 9
    versionText.TextColor3 = T.TextMain
    versionText.Size      = UDim2.new(1, 0, 1, 0)
    versionText.ZIndex    = 7
    versionText.Parent    = versionBadge
    versionText:SetAttribute("TextRole", "main")

    -- счётчик скриптов (справа)
    local scriptCountLabel = Instance.new("TextLabel")
    scriptCountLabel.BackgroundTransparency = 1
    scriptCountLabel.Text           = countScripts() .. " scripts"
    scriptCountLabel.Font           = Enum.Font.Gotham
    scriptCountLabel.TextSize       = 10
    scriptCountLabel.TextColor3     = T.TextSub
    scriptCountLabel.TextXAlignment = Enum.TextXAlignment.Right
    scriptCountLabel.Size           = UDim2.new(0, 100, 0, 18)
    scriptCountLabel.Position       = UDim2.new(1, -148, 0.5, -9)
    scriptCountLabel.ZIndex         = 6
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
    gameNameHeader.Size           = UDim2.new(0, 130, 0, 13)
    gameNameHeader.Position       = UDim2.new(1, -148, 0.5, 6)
    gameNameHeader.ZIndex         = 6
    gameNameHeader.Parent         = headerFrame

    -- кнопка закрыть — минималистичный крестик, без stroke
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name                   = "CloseBtn"
    closeBtn.BackgroundColor3       = Color3.fromRGB(180, 50, 50)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.BorderSizePixel        = 0
    closeBtn.Size                   = UDim2.new(0, 22, 0, 22)
    closeBtn.Position               = UDim2.new(1, -34, 0.5, -11)
    closeBtn.Text                   = "×"
    closeBtn.TextColor3             = T.TextMain
    closeBtn.TextSize               = 16
    closeBtn.Font                   = Enum.Font.GothamBold
    closeBtn.ZIndex                 = 8
    closeBtn.Parent                 = headerFrame
    mkCorner(closeBtn, 6)
    closeBtn:SetAttribute("TextRole", "main")
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(210, 60, 60)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.3, BackgroundColor3 = Color3.fromRGB(180, 50, 50)}):Play()
    end)

    -- ──────────────────────────────────────
    --  SIDEBAR  (стеклянная панель)
    -- ──────────────────────────────────────
    local sidebarFrame = Instance.new("Frame")
    sidebarFrame.BackgroundColor3       = T.BgSide
    sidebarFrame.BackgroundTransparency = 0.1
    sidebarFrame.BorderSizePixel        = 0
    sidebarFrame.Size                   = UDim2.new(0, 134, 1, -46)
    sidebarFrame.Position               = UDim2.new(0, 0, 0, 46)
    sidebarFrame.ZIndex                 = 3
    sidebarFrame.Parent                 = mainFrame

    -- patch: закрыть верхний скруглённый угол сайдбара
    local sidebarPatch = Instance.new("Frame")
    sidebarPatch.BackgroundColor3       = T.BgSide
    sidebarPatch.BackgroundTransparency = 0.1
    sidebarPatch.BorderSizePixel        = 0
    sidebarPatch.Size                   = UDim2.new(1, 0, 0, 14)
    sidebarPatch.Position               = UDim2.new(0, 0, 0, 0)
    sidebarPatch.ZIndex                 = 3
    sidebarPatch.Parent                 = sidebarFrame

    -- patch нижний-левый угол mainFrame (чтобы сайдбар заходил в corner)
    local sidebarBLCorner = Instance.new("Frame")
    sidebarBLCorner.BackgroundColor3       = T.BgSide
    sidebarBLCorner.BackgroundTransparency = 0.1
    sidebarBLCorner.BorderSizePixel        = 0
    sidebarBLCorner.Size                   = UDim2.new(0, 14, 0, 14)
    sidebarBLCorner.Position               = UDim2.new(0, 0, 1, -14)
    sidebarBLCorner.ZIndex                 = 3
    sidebarBLCorner.Parent                 = mainFrame
    mkCorner(sidebarBLCorner, 14)

    -- тонкий вертикальный разделитель (вместо stroke)
    local sidebarDivider = Instance.new("Frame")
    sidebarDivider.BackgroundColor3       = T.Accent
    sidebarDivider.BackgroundTransparency = 0.78
    sidebarDivider.BorderSizePixel        = 0
    sidebarDivider.Size                   = UDim2.new(0, 1, 1, -60)
    sidebarDivider.Position               = UDim2.new(0, 134, 0, 52)
    sidebarDivider.ZIndex                 = 4
    sidebarDivider.Parent                 = mainFrame
    regA(sidebarDivider)

    local catScroll = Instance.new("ScrollingFrame")
    catScroll.BackgroundTransparency = 1
    catScroll.BorderSizePixel        = 0
    catScroll.Size                   = UDim2.new(1, 0, 1, -10)
    catScroll.Position               = UDim2.new(0, 0, 0, 10)
    catScroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
    catScroll.ScrollBarThickness     = 2
    catScroll.ScrollBarImageColor3   = T.Accent
    catScroll.ZIndex                 = 4
    catScroll.Parent                 = sidebarFrame
    regA(catScroll, "ScrollBarImageColor3")

    local catLayout = Instance.new("UIListLayout")
    catLayout.Padding   = UDim.new(0, 3)
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    catLayout.Parent    = catScroll

    local catPadding = Instance.new("UIPadding")
    catPadding.PaddingLeft   = UDim.new(0, 7)
    catPadding.PaddingRight  = UDim.new(0, 7)
    catPadding.PaddingTop    = UDim.new(0, 4)
    catPadding.Parent        = catScroll

    catLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        catScroll.CanvasSize = UDim2.new(0, 0, 0, catLayout.AbsoluteContentSize.Y + 14)
    end)

    -- ──────────────────────────────────────
    --  CONTENT PANEL
    -- ──────────────────────────────────────
    local contentFrame = Instance.new("Frame")
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel        = 0
    contentFrame.Size                   = UDim2.new(1, -136, 1, -50)
    contentFrame.Position               = UDim2.new(0, 136, 0, 50)
    contentFrame.ZIndex                 = 3
    contentFrame.Parent                 = mainFrame

    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel        = 0
    scrollingFrame.Size                   = UDim2.new(1, -2, 1, 0)
    scrollingFrame.CanvasSize             = UDim2.new(0, 0, 0, 0)
    scrollingFrame.ScrollBarThickness     = 2
    scrollingFrame.ScrollBarImageColor3   = T.Accent
    scrollingFrame.ZIndex                 = 3
    scrollingFrame.Parent                 = contentFrame
    regA(scrollingFrame, "ScrollBarImageColor3")

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Padding   = UDim.new(0, 4)
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Parent    = scrollingFrame

    local scrollPadding = Instance.new("UIPadding")
    scrollPadding.PaddingLeft   = UDim.new(0, 10)
    scrollPadding.PaddingRight  = UDim.new(0, 10)
    scrollPadding.PaddingTop    = UDim.new(0, 8)
    scrollPadding.Parent        = scrollingFrame

    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 18)
    end)

    -- ──────────────────────────────────────
    --  REOPEN BUTTON
    -- ──────────────────────────────────────
    local reopenButton = Instance.new("ImageButton")
    reopenButton.Size                   = UDim2.new(0, 44, 0, 44)
    reopenButton.Position               = UDim2.new(0.5, -22, 0.9, -22)
    reopenButton.BackgroundColor3       = T.BgSide
    reopenButton.BackgroundTransparency = 0.1
    reopenButton.Image                  = "rbxassetid://74283928898866"
    reopenButton.ImageTransparency      = 0.1
    reopenButton.ImageColor3            = T.Accent
    reopenButton.Visible                = false
    reopenButton.ZIndex                 = 10
    reopenButton.Parent                 = screenGui
    mkCorner(reopenButton, 22)
    regA(reopenButton, "ImageColor3")

    reopenButton.MouseEnter:Connect(function()
        TweenService:Create(reopenButton, TweenInfo.new(0.2), {
            BackgroundColor3 = T.Accent, BackgroundTransparency = 0, ImageTransparency = 0
        }):Play()
    end)
    reopenButton.MouseLeave:Connect(function()
        TweenService:Create(reopenButton, TweenInfo.new(0.2), {
            BackgroundColor3 = T.BgSide, BackgroundTransparency = 0.1, ImageTransparency = 0.1
        }):Play()
    end)

    -- ──────────────────────────────────────
    --  UI HELPERS  (используются в logic.lua)
    -- ──────────────────────────────────────

    -- Section header — без stroke, с accent-пятном и разделителем
    local function createSectionHeader(text, parent)
        local container = Instance.new("Frame")
        container.BackgroundTransparency = 1
        container.Size                   = UDim2.new(1, 0, 0, 28)
        container.ZIndex                 = 3
        container.Parent                 = parent

        -- Тонкая accent-полоска слева
        local pip = Instance.new("Frame")
        pip.BackgroundColor3       = T.Accent
        pip.BackgroundTransparency = 0.2
        pip.BorderSizePixel        = 0
        pip.Size                   = UDim2.new(0, 2, 0, 14)
        pip.Position               = UDim2.new(0, 0, 0.5, -7)
        pip.ZIndex                 = 4
        pip.Parent                 = container
        mkCorner(pip, 1)
        regA(pip)

        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Text           = string.upper(text)
        lbl.Font           = Enum.Font.GothamBold
        lbl.TextSize       = 10
        lbl.TextColor3     = T.TextSub
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size           = UDim2.new(1, -12, 1, 0)
        lbl.Position       = UDim2.new(0, 10, 0, 0)
        lbl.ZIndex         = 4
        lbl.Parent         = container

        -- горизонтальный разделитель
        local divLine = Instance.new("Frame")
        divLine.BackgroundColor3       = T.Accent
        divLine.BackgroundTransparency = 0.85
        divLine.BorderSizePixel        = 0
        divLine.Size                   = UDim2.new(1, -10, 0, 1)
        divLine.Position               = UDim2.new(0, 10, 1, -1)
        divLine.ZIndex                 = 3
        divLine.Parent                 = container
        regA(divLine)

        return container
    end

    -- Label
    local function createLabel(text, parent, size, position)
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Text           = text
        label.Size           = size     or UDim2.new(1, 0, 0, 24)
        label.Position       = position or UDim2.new(0, 0, 0, 0)
        label.TextSize       = 13
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

    -- Button — стеклянный стиль, никаких UIStroke
    local function createButton(text, parent, callback, isCategoryButton)
        if isCategoryButton then
            -- ── SIDEBAR BUTTON ──
            local btn = Instance.new("TextButton")
            btn.Size                   = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3       = T.BgBtn
            btn.BackgroundTransparency = 1
            btn.BorderSizePixel        = 0
            btn.Text                   = text
            btn.TextColor3             = T.TextMuted
            btn.TextSize               = 12
            btn.TextXAlignment         = Enum.TextXAlignment.Left
            btn.Font                   = Enum.Font.Gotham
            btn.ZIndex                 = 5
            btn.Parent                 = parent
            mkCorner(btn, 7)

            local btnPad = Instance.new("UIPadding")
            btnPad.PaddingLeft = UDim.new(0, 12)
            btnPad.Parent      = btn

            -- accent-индикатор (левый край, появляется при активации)
            local activeIndicator = Instance.new("Frame")
            activeIndicator.BackgroundColor3       = T.Accent
            activeIndicator.BackgroundTransparency = 1
            activeIndicator.BorderSizePixel        = 0
            activeIndicator.Size                   = UDim2.new(0, 2, 0, 14)
            activeIndicator.Position               = UDim2.new(0, -5, 0.5, -7)
            activeIndicator.ZIndex                 = 6
            activeIndicator.Parent                 = btn
            mkCorner(activeIndicator, 1)
            regA(activeIndicator)

            btn.MouseEnter:Connect(function()
                if btn:GetAttribute("Active") then return end
                TweenService:Create(btn, TweenInfo.new(0.18), {
                    BackgroundTransparency = 0.65,
                    TextColor3 = T.TextSub
                }):Play()
            end)
            btn.MouseLeave:Connect(function()
                if btn:GetAttribute("Active") then return end
                TweenService:Create(btn, TweenInfo.new(0.18), {
                    BackgroundTransparency = 1,
                    TextColor3 = T.TextMuted
                }):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                -- сброс всех кнопок в родителе
                for _, child in ipairs(parent:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:SetAttribute("Active", false)
                        TweenService:Create(child, TweenInfo.new(0.18), {
                            BackgroundColor3 = T.BgBtn,
                            BackgroundTransparency = 1,
                            TextColor3 = T.TextMuted
                        }):Play()
                        local ind = child:FindFirstChildOfClass("Frame")
                        if ind and ind.Name ~= "GlassEdge" then
                            TweenService:Create(ind, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
                        end
                    end
                end
                btn:SetAttribute("Active", true)
                TweenService:Create(btn, TweenInfo.new(0.18), {
                    BackgroundColor3 = T.Accent,
                    BackgroundTransparency = 0.5,
                    TextColor3 = T.TextMain
                }):Play()
                TweenService:Create(activeIndicator, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
                callback()
            end)
            return btn
        else
            -- ── CONTENT BUTTON (glass card) ──
            local btn = Instance.new("TextButton")
            btn.Size                   = UDim2.new(1, 0, 0, 34)
            btn.BackgroundColor3       = T.BgPanel
            btn.BackgroundTransparency = 0.25
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
            mkCorner(btn, 8)

            local btnPad = Instance.new("UIPadding")
            btnPad.PaddingLeft = UDim.new(0, 14)
            btnPad.Parent      = btn

            -- тонкая accent-линия сверху (glass edge)
            local glassTop = Instance.new("Frame")
            glassTop.Name                   = "GlassEdge"
            glassTop.BackgroundColor3       = T.TextMain
            glassTop.BackgroundTransparency = 0.88
            glassTop.BorderSizePixel        = 0
            glassTop.Size                   = UDim2.new(1, -16, 0, 1)
            glassTop.Position               = UDim2.new(0, 8, 0, 0)
            glassTop.ZIndex                 = 5
            glassTop.Parent                 = btn
            mkCorner(glassTop, 1)

            -- accent-dot слева (появляется при hover)
            local accentDot = Instance.new("Frame")
            accentDot.BackgroundColor3       = T.Accent
            accentDot.BackgroundTransparency = 1
            accentDot.BorderSizePixel        = 0
            accentDot.Size                   = UDim2.new(0, 3, 0, 14)
            accentDot.Position               = UDim2.new(0, 5, 0.5, -7)
            accentDot.ZIndex                 = 5
            accentDot.Parent                 = btn
            mkCorner(accentDot, 2)
            regA(accentDot)

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {
                    BackgroundColor3 = T.BgBtnHov,
                    BackgroundTransparency = 0.08
                }):Play()
                TweenService:Create(accentDot, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {
                    BackgroundColor3 = T.BgPanel,
                    BackgroundTransparency = 0.25
                }):Play()
                TweenService:Create(accentDot, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.07), {
                    BackgroundColor3 = T.Accent,
                    BackgroundTransparency = 0.45
                }):Play()
                task.delay(0.1, function()
                    TweenService:Create(btn, TweenInfo.new(0.18), {
                        BackgroundColor3 = T.BgBtnHov,
                        BackgroundTransparency = 0.08
                    }):Play()
                end)
                callback()
            end)
            return btn
        end
    end

    -- ──────────────────────────────────────
    --  PUBLIC API  (имена совпадают с оригиналом)
    -- ──────────────────────────────────────
    return {
        screenGui        = screenGui,
        mainFrame        = mainFrame,
        headerFrame      = headerFrame,
        headerPatch      = headerPatch,
        sidebarFrame     = sidebarFrame,
        sidebarPatch     = sidebarPatch,
        sidebarBLCorner  = sidebarBLCorner,
        catScroll        = catScroll,
        scrollingFrame   = scrollingFrame,
        closeBtn         = closeBtn,
        reopenButton     = reopenButton,
        gameName         = ok and gname or "Unknown",
        mkCorner             = mkCorner,
        mkStroke             = mkStroke,
        createButton         = createButton,
        createLabel          = createLabel,
        createSectionHeader  = createSectionHeader,
        setNotification = function(fn)
            createNotification = fn
        end,
    }
end
