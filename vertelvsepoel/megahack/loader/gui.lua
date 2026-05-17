-- gui.lua — Glass Minimalism Edition
-- Без UIStroke. Цвет через BackgroundColor3 + Transparency.
-- Эффект стекла: полупрозрачные слои + градиенты.
-- Все связи с logic.lua сохранены 1:1.

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

    -- ══════════════════════════════════════
    --  HELPERS — без stroke
    -- ══════════════════════════════════════
    local function mkCorner(parent, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 8)
        c.Parent = parent
        return c
    end

    -- mkStroke оставляем как пустышку для совместимости с logic.lua
    -- (он вызывает gui.mkStroke в showAllScripts / showHome)
    local function mkStroke(parent, thickness, color, transparency)
        -- В этой версии stroke не создаём — возвращаем пустой объект-заглушку
        -- чтобы не ломать logic.lua который сохраняет возвращаемое значение
        return Instance.new("Folder") -- невидимый, ничего не делает
    end

    local function countScripts()
        local n = 0
        for _, cat in pairs(HubData) do
            if type(cat) == "table" then n = n + #cat end
        end
        return n
    end

    -- Создаёт стеклянную панель (полупрозрачный фон + тонкий светлый верхний край)
    local function mkGlass(parent, bgColor, alpha, radius)
        local f = Instance.new("Frame")
        f.BackgroundColor3       = bgColor or T.BgGlass
        f.BackgroundTransparency = alpha or 0.35
        f.BorderSizePixel        = 0
        f.Parent                 = parent
        if radius ~= 0 then mkCorner(f, radius or 8) end

        -- Светлый бликовый край сверху — имитация стекла
        local shine = Instance.new("Frame")
        shine.BackgroundColor3       = Color3.new(1, 1, 1)
        shine.BackgroundTransparency = 0.88
        shine.BorderSizePixel        = 0
        shine.Size                   = UDim2.new(0.6, 0, 0, 1)
        shine.Position               = UDim2.new(0.2, 0, 0, 0)
        shine.ZIndex                 = f.ZIndex + 1
        shine.Parent                 = f
        Instance.new("UICorner", shine).CornerRadius = UDim.new(1, 0)
        return f
    end

    -- ══════════════════════════════════════
    --  SCREEN GUI
    -- ══════════════════════════════════════
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

    -- ══════════════════════════════════════
    --  MAIN FRAME  570 × 380
    --  Стекло: тёмный фон + тонкая полупрозрачность
    -- ══════════════════════════════════════
    local mainFrame = Instance.new("Frame")
    mainFrame.Name                   = "MainFrame"
    mainFrame.BackgroundColor3       = T.BgBase
    mainFrame.BackgroundTransparency = 0.04
    mainFrame.BorderSizePixel        = 0
    mainFrame.AnchorPoint            = Vector2.new(0.5, 0.5)
    mainFrame.Position               = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size                   = UDim2.new(0, 570, 0, 380)
    mainFrame.ZIndex                 = 2
    mainFrame.Parent                 = screenGui
    mkCorner(mainFrame, 14)

    -- Внутренний стеклянный оверлей (очень тонкий белый слой)
    local glassOverlay = Instance.new("Frame")
    glassOverlay.BackgroundColor3       = Color3.new(1, 1, 1)
    glassOverlay.BackgroundTransparency = 0.96
    glassOverlay.BorderSizePixel        = 0
    glassOverlay.Size                   = UDim2.new(1, 0, 1, 0)
    glassOverlay.ZIndex                 = 2
    glassOverlay.Parent                 = mainFrame
    mkCorner(glassOverlay, 14)

    -- ══════════════════════════════════════
    --  HEADER — плоский, тёмный, без обводки
    --  Высота 48. Цвет — чуть светлее основного фона.
    -- ══════════════════════════════════════
    local headerFrame = Instance.new("Frame")
    headerFrame.BackgroundColor3       = T.BgGlass
    headerFrame.BackgroundTransparency = 0.15
    headerFrame.BorderSizePixel        = 0
    headerFrame.Size                   = UDim2.new(1, 0, 0, 48)
    headerFrame.ZIndex                 = 4
    headerFrame.Parent                 = mainFrame
    mkCorner(headerFrame, 14)

    -- Патч нижнего края (чтобы скруглены только верхние углы)
    local headerPatch = Instance.new("Frame")
    headerPatch.BackgroundColor3 = T.BgGlass
    headerPatch.BackgroundTransparency = 0.15
    headerPatch.BorderSizePixel  = 0
    headerPatch.Size             = UDim2.new(1, 0, 0, 14)
    headerPatch.Position         = UDim2.new(0, 0, 1, -14)
    headerPatch.ZIndex           = 4
    headerPatch.Parent           = headerFrame

    -- Разделитель — тонкая полупрозрачная линия (не UIStroke!)
    local headerLine = Instance.new("Frame")
    headerLine.BackgroundColor3       = Color3.new(1, 1, 1)
    headerLine.BackgroundTransparency = 0.92
    headerLine.BorderSizePixel        = 0
    headerLine.Size                   = UDim2.new(1, 0, 0, 1)
    headerLine.Position               = UDim2.new(0, 0, 1, -1)
    headerLine.ZIndex                 = 5
    headerLine.Parent                 = headerFrame

    -- Акцентная точка слева (маленький квадратик — заменяет вертикальную линию)
    local headerAccentDot = Instance.new("Frame")
    headerAccentDot.BackgroundColor3 = T.Accent
    headerAccentDot.BorderSizePixel  = 0
    headerAccentDot.Size             = UDim2.new(0, 6, 0, 6)
    headerAccentDot.Position         = UDim2.new(0, 14, 0.5, -3)
    headerAccentDot.ZIndex           = 6
    headerAccentDot.Parent           = headerFrame
    Instance.new("UICorner", headerAccentDot).CornerRadius = UDim.new(1, 0)
    regA(headerAccentDot)

    -- Логотип / иконка
    local logoIcon = Instance.new("ImageLabel")
    logoIcon.BackgroundTransparency = 1
    logoIcon.Image                  = "rbxassetid://7072717762"
    logoIcon.Size                   = UDim2.new(0, 20, 0, 20)
    logoIcon.Position               = UDim2.new(0, 26, 0.5, -10)
    logoIcon.ZIndex                 = 6
    logoIcon.Parent                 = headerFrame

    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text           = "MEGAHACK"
    titleLabel.Font           = Enum.Font.GothamBold
    titleLabel.TextSize       = 15
    titleLabel.TextColor3     = T.TextMain
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size           = UDim2.new(0, 110, 0, 20)
    titleLabel.Position       = UDim2.new(0, 52, 0.5, -10)
    titleLabel.ZIndex         = 6
    titleLabel.Parent         = headerFrame
    titleLabel:SetAttribute("TextRole", "main")

    -- Версия — маленький тег с акцентным фоном
    local versionBadge = Instance.new("Frame")
    versionBadge.BackgroundColor3       = T.Accent
    versionBadge.BackgroundTransparency = 0.25
    versionBadge.BorderSizePixel        = 0
    versionBadge.Size                   = UDim2.new(0, 34, 0, 16)
    versionBadge.Position               = UDim2.new(0, 166, 0.5, -8)
    versionBadge.ZIndex                 = 6
    versionBadge.Parent                 = headerFrame
    mkCorner(versionBadge, 4)
    regA(versionBadge)

    local versionText = Instance.new("TextLabel")
    versionText.BackgroundTransparency = 1
    versionText.Text     = "v1.0"
    versionText.Font     = Enum.Font.GothamBold
    versionText.TextSize = 9
    versionText.TextColor3 = T.TextMain
    versionText.Size     = UDim2.new(1, 0, 1, 0)
    versionText.ZIndex   = 7
    versionText.Parent   = versionBadge
    versionText:SetAttribute("TextRole", "main")

    -- Кол-во скриптов
    local scriptCountLabel = Instance.new("TextLabel")
    scriptCountLabel.BackgroundTransparency = 1
    scriptCountLabel.Text           = countScripts() .. " scripts"
    scriptCountLabel.Font           = Enum.Font.Gotham
    scriptCountLabel.TextSize       = 11
    scriptCountLabel.TextColor3     = T.TextSub
    scriptCountLabel.TextXAlignment = Enum.TextXAlignment.Right
    scriptCountLabel.Size           = UDim2.new(0, 100, 0, 18)
    scriptCountLabel.Position       = UDim2.new(1, -148, 0.5, -9)
    scriptCountLabel.ZIndex         = 6
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
    gameNameHeader.Size           = UDim2.new(0, 130, 0, 14)
    gameNameHeader.Position       = UDim2.new(1, -176, 0.5, 5)
    gameNameHeader.ZIndex         = 6
    gameNameHeader.Parent         = headerFrame

    -- ── Close Button ──
    -- Круглая кнопка — без stroke, только цвет фона
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name                   = "CloseBtn"
    closeBtn.BackgroundColor3       = Color3.fromRGB(180, 40, 40)
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
    mkCorner(closeBtn, 11)
    closeBtn:SetAttribute("TextRole", "main")

    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(220, 50, 50),
            BackgroundTransparency = 0,
        }):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(180, 40, 40),
            BackgroundTransparency = 0.3,
        }):Play()
    end)

    -- ══════════════════════════════════════
    --  SIDEBAR — 128px, стекло
    -- ══════════════════════════════════════
    local sidebarFrame = Instance.new("Frame")
    sidebarFrame.BackgroundColor3       = T.BgGlass
    sidebarFrame.BackgroundTransparency = 0.2
    sidebarFrame.BorderSizePixel        = 0
    sidebarFrame.Size                   = UDim2.new(0, 128, 1, -48)
    sidebarFrame.Position               = UDim2.new(0, 0, 0, 48)
    sidebarFrame.ZIndex                 = 3
    sidebarFrame.Parent                 = mainFrame

    -- Патч верхнего края sidebar
    local sidebarPatch = Instance.new("Frame")
    sidebarPatch.BackgroundColor3       = T.BgGlass
    sidebarPatch.BackgroundTransparency = 0.2
    sidebarPatch.BorderSizePixel        = 0
    sidebarPatch.Size                   = UDim2.new(1, 0, 0, 14)
    sidebarPatch.Position               = UDim2.new(0, 0, 0, 0)
    sidebarPatch.ZIndex                 = 3
    sidebarPatch.Parent                 = sidebarFrame

    -- Нижний левый угол (скруглён)
    local sidebarBLCorner = Instance.new("Frame")
    sidebarBLCorner.BackgroundColor3       = T.BgGlass
    sidebarBLCorner.BackgroundTransparency = 0.2
    sidebarBLCorner.BorderSizePixel        = 0
    sidebarBLCorner.Size                   = UDim2.new(0, 14, 0, 14)
    sidebarBLCorner.Position              = UDim2.new(0, 0, 1, -14)
    sidebarBLCorner.ZIndex                = 3
    sidebarBLCorner.Parent               = mainFrame
    mkCorner(sidebarBLCorner, 14)

    -- Тонкий разделитель sidebar/content (не UIStroke — обычный Frame 1px)
    local sidebarSep = Instance.new("Frame")
    sidebarSep.BackgroundColor3       = Color3.new(1, 1, 1)
    sidebarSep.BackgroundTransparency = 0.93
    sidebarSep.BorderSizePixel        = 0
    sidebarSep.Size                   = UDim2.new(0, 1, 1, -48)
    sidebarSep.Position               = UDim2.new(0, 128, 0, 48)
    sidebarSep.ZIndex                 = 4
    sidebarSep.Parent                 = mainFrame

    -- Категории-скролл
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
    catLayout.Padding   = UDim.new(0, 2)
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    catLayout.Parent    = catScroll

    local catPadding = Instance.new("UIPadding")
    catPadding.PaddingLeft   = UDim.new(0, 6)
    catPadding.PaddingRight  = UDim.new(0, 6)
    catPadding.PaddingTop    = UDim.new(0, 4)
    catPadding.Parent        = catScroll

    catLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        catScroll.CanvasSize = UDim2.new(0, 0, 0, catLayout.AbsoluteContentSize.Y + 10)
    end)

    -- ══════════════════════════════════════
    --  CONTENT PANEL
    -- ══════════════════════════════════════
    local contentFrame = Instance.new("Frame")
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel        = 0
    contentFrame.Size                   = UDim2.new(1, -130, 1, -52)
    contentFrame.Position               = UDim2.new(0, 130, 0, 52)
    contentFrame.ZIndex                 = 3
    contentFrame.Parent                 = mainFrame

    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel        = 0
    scrollingFrame.Size                   = UDim2.new(1, -4, 1, 0)
    scrollingFrame.CanvasSize             = UDim2.new(0, 0, 0, 0)
    scrollingFrame.ScrollBarThickness     = 2
    scrollingFrame.ScrollBarImageColor3   = T.Accent
    scrollingFrame.ZIndex                 = 3
    scrollingFrame.Parent                 = contentFrame
    regA(scrollingFrame, "ScrollBarImageColor3")

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Padding   = UDim.new(0, 5)
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Parent    = scrollingFrame

    local scrollPadding = Instance.new("UIPadding")
    scrollPadding.PaddingLeft   = UDim.new(0, 8)
    scrollPadding.PaddingRight  = UDim.new(0, 10)
    scrollPadding.PaddingTop    = UDim.new(0, 6)
    scrollPadding.Parent        = scrollingFrame

    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 16)
    end)

    -- ══════════════════════════════════════
    --  REOPEN BUTTON — плавающая кнопка
    -- ══════════════════════════════════════
    local reopenButton = Instance.new("ImageButton")
    reopenButton.Size                   = UDim2.new(0, 44, 0, 44)
    reopenButton.Position               = UDim2.new(0.5, -22, 0.9, -22)
    reopenButton.BackgroundColor3       = T.BgGlass
    reopenButton.BackgroundTransparency = 0.15
    reopenButton.Image                  = "rbxassetid://74283928898866"
    reopenButton.ImageTransparency      = 0.15
    reopenButton.ImageColor3            = T.TextMain
    reopenButton.Visible                = false
    reopenButton.ZIndex                 = 10
    reopenButton.Parent                 = screenGui
    mkCorner(reopenButton, 22)

    -- Акцентный ободок — через внутренний Frame а не UIStroke
    local reopenRing = Instance.new("Frame")
    reopenRing.BackgroundColor3       = T.Accent
    reopenRing.BackgroundTransparency = 0.5
    reopenRing.BorderSizePixel        = 0
    reopenRing.Size                   = UDim2.new(1, 4, 1, 4)
    reopenRing.Position               = UDim2.new(0, -2, 0, -2)
    reopenRing.ZIndex                 = 9
    reopenRing.Parent                 = reopenButton
    mkCorner(reopenRing, 24)
    regA(reopenRing)

    reopenButton.MouseEnter:Connect(function()
        TweenService:Create(reopenButton, TweenInfo.new(0.2), {
            BackgroundColor3 = T.Accent, BackgroundTransparency = 0
        }):Play()
    end)
    reopenButton.MouseLeave:Connect(function()
        TweenService:Create(reopenButton, TweenInfo.new(0.2), {
            BackgroundColor3 = T.BgGlass, BackgroundTransparency = 0.15
        }):Play()
    end)

    -- ══════════════════════════════════════
    --  UI HELPERS — используются в logic.lua
    -- ══════════════════════════════════════

    -- Section Header — горизонтальный заголовок с акцентом
    local function createSectionHeader(text, parent)
        local container = Instance.new("Frame")
        container.BackgroundTransparency = 1
        container.Size   = UDim2.new(1, 0, 0, 26)
        container.ZIndex = 3
        container.Parent = parent

        -- Акцентная полоска — цветной фоновый блок вместо stroke
        local pill = Instance.new("Frame")
        pill.BackgroundColor3       = T.Accent
        pill.BackgroundTransparency = 0.7
        pill.BorderSizePixel        = 0
        pill.Size                   = UDim2.new(1, 0, 1, 0)
        pill.ZIndex                 = 3
        pill.Parent                 = container
        mkCorner(pill, 5)
        regA(pill)

        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Text           = string.upper(text)
        lbl.Font           = Enum.Font.GothamBold
        lbl.TextSize       = 10
        lbl.TextColor3     = T.Accent
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size           = UDim2.new(1, -16, 1, 0)
        lbl.Position       = UDim2.new(0, 10, 0, 0)
        lbl.ZIndex         = 4
        lbl.Parent         = container
        regA(lbl, "TextColor3")

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
        label.TextTransparency = 0.1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font           = Enum.Font.Gotham
        label.TextWrapped    = true
        label.ZIndex         = 4
        label.Parent         = parent
        label:SetAttribute("TextRole", "main")
        return label
    end

    -- Button — два варианта: категория и обычная
    local function createButton(text, parent, callback, isCategoryButton)
        if isCategoryButton then
            -- ── Sidebar Category Button ──
            local btn = Instance.new("TextButton")
            btn.Size                   = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3       = T.BgBtn
            btn.BackgroundTransparency = 1
            btn.BorderSizePixel        = 0
            btn.Text                   = text
            btn.TextColor3             = T.TextSub
            btn.TextSize               = 11
            btn.TextXAlignment         = Enum.TextXAlignment.Left
            btn.Font                   = Enum.Font.Gotham
            btn.ZIndex                 = 5
            btn.Parent                 = parent
            mkCorner(btn, 6)

            local btnPad = Instance.new("UIPadding")
            btnPad.PaddingLeft = UDim.new(0, 12)
            btnPad.Parent      = btn

            -- Активный индикатор — цветной левый бордюр (Frame, не stroke)
            local activeBar = Instance.new("Frame")
            activeBar.BackgroundColor3       = T.Accent
            activeBar.BackgroundTransparency = 1
            activeBar.BorderSizePixel        = 0
            activeBar.Size                   = UDim2.new(0, 3, 0.5, 0)
            activeBar.Position               = UDim2.new(0, 0, 0.25, 0)
            activeBar.ZIndex                 = 6
            activeBar.Parent                 = btn
            mkCorner(activeBar, 2)
            regA(activeBar)

            btn.MouseEnter:Connect(function()
                if btn:GetAttribute("Active") then return end
                TweenService:Create(btn, TweenInfo.new(0.15), {
                    BackgroundTransparency = 0.65,
                    TextColor3 = T.TextMain,
                }):Play()
            end)
            btn.MouseLeave:Connect(function()
                if btn:GetAttribute("Active") then return end
                TweenService:Create(btn, TweenInfo.new(0.15), {
                    BackgroundTransparency = 1,
                    TextColor3 = T.TextSub,
                }):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                for _, child in ipairs(parent:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:SetAttribute("Active", false)
                        TweenService:Create(child, TweenInfo.new(0.15), {
                            BackgroundColor3 = T.BgBtn,
                            BackgroundTransparency = 1,
                            TextColor3 = T.TextSub,
                        }):Play()
                        local bar = child:FindFirstChild("Frame")
                        if bar then TweenService:Create(bar, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play() end
                    end
                end
                btn:SetAttribute("Active", true)
                TweenService:Create(btn, TweenInfo.new(0.15), {
                    BackgroundColor3 = T.Accent,
                    BackgroundTransparency = 0.82,
                    TextColor3 = T.TextMain,
                }):Play()
                TweenService:Create(activeBar, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
                callback()
            end)
            return btn

        else
            -- ── Content Button — стеклянный ──
            local btn = Instance.new("TextButton")
            btn.Size                   = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3       = T.BgPanel
            btn.BackgroundTransparency = 0.2
            btn.BorderSizePixel        = 0
            btn.Text                   = text
            btn.TextColor3             = T.TextMain
            btn.TextSize               = 12
            btn.TextTransparency       = 0.05
            btn.TextXAlignment         = Enum.TextXAlignment.Left
            btn.Font                   = Enum.Font.Gotham
            btn.ZIndex                 = 4
            btn.Parent                 = parent
            btn:SetAttribute("TextRole", "main")
            mkCorner(btn, 7)

            local btnPad = Instance.new("UIPadding")
            btnPad.PaddingLeft = UDim.new(0, 12)
            btnPad.Parent      = btn

            -- Блик сверху (стеклянный эффект)
            local btnShine = Instance.new("Frame")
            btnShine.BackgroundColor3       = Color3.new(1, 1, 1)
            btnShine.BackgroundTransparency = 0.9
            btnShine.BorderSizePixel        = 0
            btnShine.Size                   = UDim2.new(0.5, 0, 0, 1)
            btnShine.Position               = UDim2.new(0.1, 0, 0, 0)
            btnShine.ZIndex                 = 5
            btnShine.Parent                 = btn
            Instance.new("UICorner", btnShine).CornerRadius = UDim.new(1, 0)

            -- Левый акцентный пиксель (не stroke, а тонкий Frame)
            local accentPx = Instance.new("Frame")
            accentPx.BackgroundColor3       = T.Accent
            accentPx.BackgroundTransparency = 1
            accentPx.BorderSizePixel        = 0
            accentPx.Size                   = UDim2.new(0, 2, 0, 16)
            accentPx.Position               = UDim2.new(0, 5, 0.5, -8)
            accentPx.ZIndex                 = 5
            accentPx.Parent                 = btn
            mkCorner(accentPx, 2)
            regA(accentPx)

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.14), {
                    BackgroundColor3 = T.BgBtnHov,
                    BackgroundTransparency = 0.05,
                }):Play()
                TweenService:Create(accentPx, TweenInfo.new(0.14), {BackgroundTransparency = 0}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.14), {
                    BackgroundColor3 = T.BgPanel,
                    BackgroundTransparency = 0.2,
                }):Play()
                TweenService:Create(accentPx, TweenInfo.new(0.14), {BackgroundTransparency = 1}):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.07), {
                    BackgroundColor3 = T.Accent,
                    BackgroundTransparency = 0.55,
                }):Play()
                task.delay(0.1, function()
                    TweenService:Create(btn, TweenInfo.new(0.18), {
                        BackgroundColor3 = T.BgBtnHov,
                        BackgroundTransparency = 0.05,
                    }):Play()
                end)
                callback()
            end)
            return btn
        end
    end

    -- ══════════════════════════════════════
    --  PUBLIC API — идентичен оригинальному
    -- ══════════════════════════════════════
    return {
        -- frames (logic.lua читает эти поля напрямую)
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
        -- game info
        gameName         = ok and gname or "Unknown",
        -- helpers
        mkCorner             = mkCorner,
        mkStroke             = mkStroke,           -- пустышка, но не ломает logic.lua
        createButton         = createButton,
        createLabel          = createLabel,
        createSectionHeader  = createSectionHeader,
        -- notification setter
        setNotification = function(fn)
            createNotification = fn
        end,
    }
end
