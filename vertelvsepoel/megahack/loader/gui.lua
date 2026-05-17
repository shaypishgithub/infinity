-- gui.lua
-- Стеклянный минималистичный UI. Все публичные поля совместимы с logic.lua.
-- Никакого stroke-мусора. Цвет применяется везде через T и accentRegistry.

return function(deps)
    local TweenService       = deps.TweenService
    local UserInputService   = deps.UserInputService
    local CoreGui            = deps.CoreGui
    local MarketplaceService = deps.MarketplaceService
    local T                  = deps.T
    local regA               = deps.regA
    local HubData            = deps.HubData

    -- ───────────────────────────────
    --  УТИЛИТЫ
    -- ───────────────────────────────
    local function corner(p, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 8)
        c.Parent = p
        return c
    end

    -- Лёгкий стеклянный бордер (белый, полупрозрачный)
    local function glassBorder(p, alpha)
        local s = Instance.new("UIStroke")
        s.Thickness    = 1
        s.Color        = Color3.new(1, 1, 1)
        s.Transparency = alpha or 0.80
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = p
        return s
    end

    -- Блик стекла сверху
    local function glassSheen(p, z)
        local f = Instance.new("Frame")
        f.Name                   = "_Sheen"
        f.BackgroundColor3       = Color3.new(1, 1, 1)
        f.BackgroundTransparency = 0.90
        f.BorderSizePixel        = 0
        f.Size                   = UDim2.new(1, 0, 0.42, 0)
        f.ZIndex                 = z or 10
        f.Parent                 = p
        corner(f, 10)
        local g = Instance.new("UIGradient")
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.45),
            NumberSequenceKeypoint.new(1, 1.00),
        })
        g.Rotation = 90
        g.Parent   = f
        return f
    end

    local function countScripts()
        local n = 0
        for _, c in pairs(HubData) do
            if type(c) == "table" then n = n + #c end
        end
        return n
    end

    -- ───────────────────────────────
    --  SCREEN GUI
    -- ───────────────────────────────
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name           = "MegaHackUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = false
    screenGui.ResetOnSpawn   = false

    pcall(function()
        if gethui then screenGui.Parent = gethui()
        elseif get_hidden_gui then screenGui.Parent = get_hidden_gui()
        elseif syn and syn.protect_gui then syn.protect_gui(screenGui); screenGui.Parent = CoreGui
        else screenGui.Parent = CoreGui end
    end)
    if not screenGui.Parent then screenGui.Parent = CoreGui end

    -- ───────────────────────────────
    --  MAIN FRAME  600 × 390
    -- ───────────────────────────────
    local mainFrame = Instance.new("Frame")
    mainFrame.Name                   = "Main"
    mainFrame.BackgroundColor3       = T.BgBase
    mainFrame.BackgroundTransparency = 0.06
    mainFrame.BorderSizePixel        = 0
    mainFrame.AnchorPoint            = Vector2.new(0.5, 0.5)
    mainFrame.Position               = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size                   = UDim2.new(0, 600, 0, 390)
    mainFrame.ZIndex                 = 2
    mainFrame.Parent                 = screenGui
    corner(mainFrame, 14)
    glassBorder(mainFrame, 0.70)
    glassSheen(mainFrame, 3)

    -- Акцент снизу
    local btmGlow = Instance.new("Frame")
    btmGlow.BackgroundColor3       = T.Accent
    btmGlow.BackgroundTransparency = 0.52
    btmGlow.BorderSizePixel        = 0
    btmGlow.Size                   = UDim2.new(0.55, 0, 0, 2)
    btmGlow.Position               = UDim2.new(0.225, 0, 1, -2)
    btmGlow.ZIndex                 = 4
    btmGlow.Parent                 = mainFrame
    corner(btmGlow, 2)
    regA(btmGlow)

    -- ───────────────────────────────
    --  HEADER  48px
    -- ───────────────────────────────
    local header = Instance.new("Frame")
    header.BackgroundColor3       = T.BgSide
    header.BackgroundTransparency = 0.08
    header.BorderSizePixel        = 0
    header.Size                   = UDim2.new(1, 0, 0, 48)
    header.ZIndex                 = 5
    header.Parent                 = mainFrame
    corner(header, 14)
    glassSheen(header, 7)

    -- Патч нижних углов header
    local headerPatch = Instance.new("Frame")
    headerPatch.BackgroundColor3       = T.BgSide
    headerPatch.BackgroundTransparency = 0.08
    headerPatch.BorderSizePixel        = 0
    headerPatch.Size                   = UDim2.new(1, 0, 0, 14)
    headerPatch.Position               = UDim2.new(0, 0, 1, -14)
    headerPatch.ZIndex                 = 5
    headerPatch.Parent                 = header

    -- Разделитель header/контент
    local hLine = Instance.new("Frame")
    hLine.BackgroundColor3       = Color3.new(1, 1, 1)
    hLine.BackgroundTransparency = 0.87
    hLine.BorderSizePixel        = 0
    hLine.Size                   = UDim2.new(1, 0, 0, 1)
    hLine.Position               = UDim2.new(0, 0, 1, -1)
    hLine.ZIndex                 = 7
    hLine.Parent                 = header

    -- Цветной пип
    local hPip = Instance.new("Frame")
    hPip.BackgroundColor3 = T.Accent
    hPip.BorderSizePixel  = 0
    hPip.Size             = UDim2.new(0, 3, 0, 22)
    hPip.Position         = UDim2.new(0, 14, 0.5, -11)
    hPip.ZIndex           = 8
    hPip.Parent           = header
    corner(hPip, 2)
    regA(hPip)

    -- Иконка
    local icon = Instance.new("ImageLabel")
    icon.BackgroundTransparency = 1
    icon.Image    = "rbxassetid://7072717762"
    icon.Size     = UDim2.new(0, 22, 0, 22)
    icon.Position = UDim2.new(0, 24, 0.5, -11)
    icon.ZIndex   = 8
    icon.Parent   = header

    -- Заголовок
    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text           = "MEGAHACK"
    titleLbl.Font           = Enum.Font.GothamBold
    titleLbl.TextSize       = 15
    titleLbl.TextColor3     = T.TextMain
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Size           = UDim2.new(0, 120, 0, 22)
    titleLbl.Position       = UDim2.new(0, 52, 0.5, -11)
    titleLbl.ZIndex         = 8
    titleLbl.Parent         = header
    titleLbl:SetAttribute("TextRole", "main")

    -- Версия badge
    local verBg = Instance.new("Frame")
    verBg.BackgroundColor3       = T.Accent
    verBg.BackgroundTransparency = 0.28
    verBg.BorderSizePixel        = 0
    verBg.Size                   = UDim2.new(0, 34, 0, 17)
    verBg.Position               = UDim2.new(0, 176, 0.5, -8)
    verBg.ZIndex                 = 8
    verBg.Parent                 = header
    corner(verBg, 5)
    regA(verBg)

    local verLbl = Instance.new("TextLabel")
    verLbl.BackgroundTransparency = 1
    verLbl.Text     = "v2.0"
    verLbl.Font     = Enum.Font.GothamBold
    verLbl.TextSize = 10
    verLbl.TextColor3 = T.TextMain
    verLbl.Size     = UDim2.new(1, 0, 1, 0)
    verLbl.ZIndex   = 9
    verLbl.Parent   = verBg
    verLbl:SetAttribute("TextRole", "main")

    -- Счётчик скриптов
    local scriptCnt = Instance.new("TextLabel")
    scriptCnt.BackgroundTransparency = 1
    scriptCnt.Text           = countScripts() .. " scripts"
    scriptCnt.Font           = Enum.Font.Gotham
    scriptCnt.TextSize       = 11
    scriptCnt.TextColor3     = T.TextSub
    scriptCnt.TextXAlignment = Enum.TextXAlignment.Right
    scriptCnt.Size           = UDim2.new(0, 100, 0, 18)
    scriptCnt.Position       = UDim2.new(1, -154, 0.5, -9)
    scriptCnt.ZIndex         = 8
    scriptCnt.Parent         = header

    -- Игра
    local ok, gname = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId).Name end)
    local gameLbl = Instance.new("TextLabel")
    gameLbl.BackgroundTransparency = 1
    gameLbl.Text           = ok and gname or "Unknown"
    gameLbl.Font           = Enum.Font.Gotham
    gameLbl.TextSize       = 10
    gameLbl.TextColor3     = T.TextMuted
    gameLbl.TextXAlignment = Enum.TextXAlignment.Right
    gameLbl.Size           = UDim2.new(0, 140, 0, 14)
    gameLbl.Position       = UDim2.new(1, -188, 0.5, 6)
    gameLbl.ZIndex         = 8
    gameLbl.Parent         = header

    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name                   = "CloseBtn"
    closeBtn.BackgroundColor3       = Color3.fromRGB(170, 46, 46)
    closeBtn.BackgroundTransparency = 0.28
    closeBtn.BorderSizePixel        = 0
    closeBtn.Size                   = UDim2.new(0, 24, 0, 24)
    closeBtn.Position               = UDim2.new(1, -36, 0.5, -12)
    closeBtn.Text                   = "×"
    closeBtn.TextColor3             = T.TextMain
    closeBtn.TextSize               = 18
    closeBtn.Font                   = Enum.Font.GothamBold
    closeBtn.ZIndex                 = 10
    closeBtn.Parent                 = header
    corner(closeBtn, 7)
    closeBtn:SetAttribute("TextRole", "main")
    closeBtn.MouseEnter:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.13), {BackgroundTransparency = 0}):Play() end)
    closeBtn.MouseLeave:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.13), {BackgroundTransparency = 0.28}):Play() end)

    -- ───────────────────────────────
    --  SIDEBAR  142px
    -- ───────────────────────────────
    local sidebar = Instance.new("Frame")
    sidebar.BackgroundColor3       = T.BgSide
    sidebar.BackgroundTransparency = 0.12
    sidebar.BorderSizePixel        = 0
    sidebar.Size                   = UDim2.new(0, 142, 1, -48)
    sidebar.Position               = UDim2.new(0, 0, 0, 48)
    sidebar.ZIndex                 = 3
    sidebar.Parent                 = mainFrame
    glassSheen(sidebar, 4)

    local sidebarPatch = Instance.new("Frame")
    sidebarPatch.BackgroundColor3       = T.BgSide
    sidebarPatch.BackgroundTransparency = 0.12
    sidebarPatch.BorderSizePixel        = 0
    sidebarPatch.Size                   = UDim2.new(1, 0, 0, 14)
    sidebarPatch.ZIndex                 = 3
    sidebarPatch.Parent                 = sidebar

    local sidebarBLCorner = Instance.new("Frame")
    sidebarBLCorner.BackgroundColor3       = T.BgSide
    sidebarBLCorner.BackgroundTransparency = 0.12
    sidebarBLCorner.BorderSizePixel        = 0
    sidebarBLCorner.Size                   = UDim2.new(0, 14, 0, 14)
    sidebarBLCorner.Position               = UDim2.new(0, 0, 1, -14)
    sidebarBLCorner.ZIndex                 = 3
    sidebarBLCorner.Parent                 = mainFrame
    corner(sidebarBLCorner, 14)

    -- Вертикальный разделитель
    local sideSep = Instance.new("Frame")
    sideSep.BackgroundColor3       = Color3.new(1, 1, 1)
    sideSep.BackgroundTransparency = 0.90
    sideSep.BorderSizePixel        = 0
    sideSep.Size                   = UDim2.new(0, 1, 1, -48)
    sideSep.Position               = UDim2.new(0, 142, 0, 48)
    sideSep.ZIndex                 = 4
    sideSep.Parent                 = mainFrame

    -- Скролл категорий
    local catScroll = Instance.new("ScrollingFrame")
    catScroll.BackgroundTransparency = 1
    catScroll.BorderSizePixel        = 0
    catScroll.Size                   = UDim2.new(1, 0, 1, -4)
    catScroll.Position               = UDim2.new(0, 0, 0, 4)
    catScroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
    catScroll.ScrollBarThickness     = 2
    catScroll.ScrollBarImageColor3   = T.Accent
    catScroll.ZIndex                 = 5
    catScroll.Parent                 = sidebar
    regA(catScroll, "ScrollBarImageColor3")

    local catLayout = Instance.new("UIListLayout")
    catLayout.Padding   = UDim.new(0, 2)
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    catLayout.Parent    = catScroll
    local catPad = Instance.new("UIPadding")
    catPad.PaddingLeft  = UDim.new(0, 6)
    catPad.PaddingRight = UDim.new(0, 6)
    catPad.PaddingTop   = UDim.new(0, 6)
    catPad.Parent       = catScroll
    catLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        catScroll.CanvasSize = UDim2.new(0, 0, 0, catLayout.AbsoluteContentSize.Y + 14)
    end)

    -- ───────────────────────────────
    --  CONTENT
    -- ───────────────────────────────
    local contentFrame = Instance.new("Frame")
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel        = 0
    contentFrame.Size                   = UDim2.new(1, -145, 1, -52)
    contentFrame.Position               = UDim2.new(0, 145, 0, 52)
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
    scrollPad.PaddingTop   = UDim.new(0, 8)
    scrollPad.Parent       = scrollingFrame
    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 20)
    end)

    -- ───────────────────────────────
    --  REOPEN BUTTON
    -- ───────────────────────────────
    local reopenButton = Instance.new("ImageButton")
    reopenButton.Size                   = UDim2.new(0, 46, 0, 46)
    reopenButton.Position               = UDim2.new(0.5, -23, 0.9, -23)
    reopenButton.BackgroundColor3       = T.BgSide
    reopenButton.BackgroundTransparency = 0.08
    reopenButton.Image                  = "rbxassetid://74283928898866"
    reopenButton.ImageTransparency      = 0.08
    reopenButton.ImageColor3            = T.TextMain
    reopenButton.Visible                = false
    reopenButton.ZIndex                 = 14
    reopenButton.Parent                 = screenGui
    corner(reopenButton, 23)
    glassBorder(reopenButton, 0.60)
    local reopenAccent = Instance.new("UIStroke")
    reopenAccent.Thickness    = 1.5
    reopenAccent.Color        = T.Accent
    reopenAccent.Transparency = 0.18
    reopenAccent.Parent       = reopenButton
    regA(reopenAccent, "Color")

    reopenButton.MouseEnter:Connect(function()
        TweenService:Create(reopenButton, TweenInfo.new(0.17), {BackgroundColor3=T.Accent, BackgroundTransparency=0}):Play()
    end)
    reopenButton.MouseLeave:Connect(function()
        TweenService:Create(reopenButton, TweenInfo.new(0.17), {BackgroundColor3=T.BgSide, BackgroundTransparency=0.08}):Play()
    end)

    -- ───────────────────────────────
    --  HELPERS ДЛЯ logic.lua
    -- ───────────────────────────────

    local function createSectionHeader(text, parent)
        local c = Instance.new("Frame")
        c.BackgroundTransparency = 1
        c.Size   = UDim2.new(1, 0, 0, 28)
        c.ZIndex = 4
        c.Parent = parent

        local line = Instance.new("Frame")
        line.BackgroundColor3       = Color3.new(1, 1, 1)
        line.BackgroundTransparency = 0.90
        line.BorderSizePixel        = 0
        line.Size                   = UDim2.new(1, 0, 0, 1)
        line.Position               = UDim2.new(0, 0, 1, -1)
        line.ZIndex                 = 4
        line.Parent                 = c

        local pip = Instance.new("Frame")
        pip.BackgroundColor3 = T.Accent
        pip.BorderSizePixel  = 0
        pip.Size             = UDim2.new(0, 3, 0, 14)
        pip.Position         = UDim2.new(0, 0, 0.5, -7)
        pip.ZIndex           = 5
        pip.Parent           = c
        corner(pip, 2)
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
        lbl.Parent         = c
        return c
    end

    local function createLabel(text, parent, size, position)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Text           = text
        l.Size           = size     or UDim2.new(1, 0, 0, 24)
        l.Position       = position or UDim2.new(0, 0, 0, 0)
        l.TextSize       = 12
        l.TextColor3     = T.TextMain
        l.TextTransparency = 0.06
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Font           = Enum.Font.Gotham
        l.TextWrapped    = true
        l.ZIndex         = 4
        l.Parent         = parent
        l:SetAttribute("TextRole", "main")
        return l
    end

    local function createButton(text, parent, callback, isCat)
        if isCat then
            -- Sidebar tab
            local btn = Instance.new("TextButton")
            btn.Size                   = UDim2.new(1, 0, 0, 32)
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
            corner(btn, 8)

            local pad = Instance.new("UIPadding")
            pad.PaddingLeft = UDim.new(0, 30)
            pad.Parent      = btn

            local strip = Instance.new("Frame")
            strip.BackgroundColor3       = T.Accent
            strip.BackgroundTransparency = 1
            strip.BorderSizePixel        = 0
            strip.Size                   = UDim2.new(0, 3, 0, 16)
            strip.Position               = UDim2.new(0, 8, 0.5, -8)
            strip.ZIndex                 = 7
            strip.Parent                 = btn
            corner(strip, 2)
            regA(strip)

            local function setActive(on)
                if on then
                    TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3=T.Accent, BackgroundTransparency=0.68, TextColor3=T.TextMain}):Play()
                    TweenService:Create(strip, TweenInfo.new(0.15), {BackgroundTransparency=0}):Play()
                else
                    TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3=T.BgBtn, BackgroundTransparency=1, TextColor3=T.TextSub}):Play()
                    TweenService:Create(strip, TweenInfo.new(0.15), {BackgroundTransparency=1}):Play()
                end
            end

            btn.MouseEnter:Connect(function()
                if not btn:GetAttribute("Active") then
                    TweenService:Create(btn, TweenInfo.new(0.13), {BackgroundTransparency=0.78, TextColor3=T.TextMain}):Play()
                end
            end)
            btn.MouseLeave:Connect(function()
                if not btn:GetAttribute("Active") then
                    TweenService:Create(btn, TweenInfo.new(0.13), {BackgroundTransparency=1, TextColor3=T.TextSub}):Play()
                end
            end)
            btn.MouseButton1Click:Connect(function()
                for _, ch in ipairs(parent:GetChildren()) do
                    if ch:IsA("TextButton") and ch ~= btn then
                        ch:SetAttribute("Active", false)
                        TweenService:Create(ch, TweenInfo.new(0.13), {BackgroundColor3=T.BgBtn, BackgroundTransparency=1, TextColor3=T.TextSub}):Play()
                        local s = ch:FindFirstChildWhichIsA("Frame")
                        if s and s.Name ~= "_Sheen" then
                            TweenService:Create(s, TweenInfo.new(0.13), {BackgroundTransparency=1}):Play()
                        end
                    end
                end
                btn:SetAttribute("Active", true)
                setActive(true)
                callback()
            end)
            return btn

        else
            -- Content card
            local card = Instance.new("TextButton")
            card.Size                   = UDim2.new(1, 0, 0, 36)
            card.BackgroundColor3       = T.BgPanel
            card.BackgroundTransparency = 0.20
            card.BorderSizePixel        = 0
            card.Text                   = ""
            card.ZIndex                 = 4
            card.Parent                 = parent
            corner(card, 9)
            glassBorder(card, 0.82)

            -- Блик
            local sh = Instance.new("Frame")
            sh.Name                   = "_Sheen"
            sh.BackgroundColor3       = Color3.new(1, 1, 1)
            sh.BackgroundTransparency = 0.93
            sh.BorderSizePixel        = 0
            sh.Size                   = UDim2.new(1, 0, 0.5, 0)
            sh.ZIndex                 = 5
            sh.Parent                 = card
            corner(sh, 9)

            -- Акцент полоска
            local bar = Instance.new("Frame")
            bar.BackgroundColor3       = T.Accent
            bar.BackgroundTransparency = 1
            bar.BorderSizePixel        = 0
            bar.Size                   = UDim2.new(0, 3, 0, 18)
            bar.Position               = UDim2.new(0, 8, 0.5, -9)
            bar.ZIndex                 = 6
            bar.Parent                 = card
            corner(bar, 2)
            regA(bar)

            -- Текст кнопки
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Text           = text
            lbl.Font           = Enum.Font.Gotham
            lbl.TextSize       = 13
            lbl.TextColor3     = T.TextMain
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Size           = UDim2.new(1, -24, 1, 0)
            lbl.Position       = UDim2.new(0, 20, 0, 0)
            lbl.ZIndex         = 6
            lbl.Parent         = card
            lbl:SetAttribute("TextRole", "main")

            card.MouseEnter:Connect(function()
                TweenService:Create(card, TweenInfo.new(0.12), {BackgroundColor3=T.BgBtnHov, BackgroundTransparency=0.08}):Play()
                TweenService:Create(bar,  TweenInfo.new(0.12), {BackgroundTransparency=0}):Play()
            end)
            card.MouseLeave:Connect(function()
                TweenService:Create(card, TweenInfo.new(0.12), {BackgroundColor3=T.BgPanel, BackgroundTransparency=0.20}):Play()
                TweenService:Create(bar,  TweenInfo.new(0.12), {BackgroundTransparency=1}):Play()
            end)
            card.MouseButton1Click:Connect(function()
                TweenService:Create(card, TweenInfo.new(0.07), {BackgroundColor3=T.Accent, BackgroundTransparency=0.42}):Play()
                task.delay(0.14, function()
                    TweenService:Create(card, TweenInfo.new(0.16), {BackgroundColor3=T.BgBtnHov, BackgroundTransparency=0.08}):Play()
                end)
                callback()
            end)
            return card
        end
    end

    -- ───────────────────────────────
    --  PUBLIC API
    -- ───────────────────────────────
    return {
        screenGui       = screenGui,
        mainFrame       = mainFrame,
        headerFrame     = header,
        headerPatch     = headerPatch,
        sidebarFrame    = sidebar,
        sidebarPatch    = sidebarPatch,
        sidebarBLCorner = sidebarBLCorner,
        catScroll       = catScroll,
        scrollingFrame  = scrollingFrame,
        closeBtn        = closeBtn,
        reopenButton    = reopenButton,
        gameName        = ok and gname or "Unknown",
        -- helpers
        mkCorner            = corner,
        mkStroke            = glassBorder,
        createButton        = createButton,
        createLabel         = createLabel,
        createSectionHeader = createSectionHeader,
        setNotification = function(fn) end,  -- logic.lua дёргает это, нам не нужно
    }
end
