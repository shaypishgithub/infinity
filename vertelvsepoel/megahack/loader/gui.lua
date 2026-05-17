-- ============================================================================
-- gui.lua — полностью новый минималистичный интерфейс, эффект стекла
-- ============================================================================
return function(deps)
    local TweenService    = deps.TweenService
    local UserInputService = deps.UserInputService
    local CoreGui         = deps.CoreGui
    local MarketplaceService = deps.MarketplaceService
    local playerGui       = deps.playerGui
    local platformName    = deps.platformName
    local T               = deps.T
    local regA            = deps.regA
    local HubData         = deps.HubData

    local createNotification = function() end

    -- ---------- Вспомогательные функции ----------
    local function roundCorners(obj, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 8)
        c.Parent = obj
        return c
    end

    local function addBorder(obj, thickness, color, transp)
        local s = Instance.new("UIStroke")
        s.Thickness = thickness or 1
        s.Color = color or T.Border
        s.Transparency = transp or 0.5
        s.Parent = obj
        return s
    end

    local function countScripts()
        local n = 0
        for _, cat in pairs(HubData) do
            if type(cat) == "table" then n = n + #cat end
        end
        return n
    end

    -- ---------- Создание ScreenGui с сокрытием ----------
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AuraHub"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false

    local function hideGui(g)
        local ok = pcall(function()
            if get_hidden_gui then g.Parent = get_hidden_gui()
            elseif gethui then g.Parent = gethui()
            elseif syn and syn.protect_gui then
                syn.protect_gui(g)
                g.Parent = CoreGui
            else
                g.Parent = CoreGui
            end
        end)
        if not ok then g.Parent = CoreGui end
    end
    hideGui(screenGui)

    -- ---------- Главное окно (стеклянное, скруглённое) ----------
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "GlassFrame"
    mainFrame.BackgroundColor3 = T.BgGlass
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size = UDim2.new(0, 520, 0, 380)
    mainFrame.ZIndex = 2
    mainFrame.Parent = screenGui
    roundCorners(mainFrame, 16)
    addBorder(mainFrame, 1, T.Border, 0.4)

    -- Тень (имитация через дополнительный фрейм)
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.BackgroundColor3 = Color3.new(0, 0, 0)
    shadow.BackgroundTransparency = 0.8
    shadow.BorderSizePixel = 0
    shadow.Size = UDim2.new(1, 4, 1, 4)
    shadow.Position = UDim2.new(0, -2, 0, -2)
    shadow.ZIndex = 1
    shadow.Parent = mainFrame
    roundCorners(shadow, 18)

    -- ---------- Верхняя панель (заголовок, управление) ----------
    local header = Instance.new("Frame")
    header.BackgroundColor3 = T.BgGlass
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, 48)
    header.ZIndex = 4
    header.Parent = mainFrame
    roundCorners(header, 12)
    -- отрезаем нижние углы
    local headerMask = Instance.new("Frame")
    headerMask.BackgroundColor3 = T.BgGlass
    headerMask.BackgroundTransparency = 0.3
    headerMask.BorderSizePixel = 0
    headerMask.Size = UDim2.new(1, 0, 0, 12)
    headerMask.Position = UDim2.new(0, 0, 1, -12)
    headerMask.ZIndex = 4
    headerMask.Parent = header

    -- Логотип / иконка
    local logoIcon = Instance.new("ImageLabel")
    logoIcon.BackgroundTransparency = 1
    logoIcon.Image = "rbxassetid://7072717762"
    logoIcon.Size = UDim2.new(0, 26, 0, 26)
    logoIcon.Position = UDim2.new(0, 16, 0.5, -13)
    logoIcon.ZIndex = 6
    logoIcon.Parent = header

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Text = "AURA"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = T.TextLight
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Size = UDim2.new(0, 80, 0, 28)
    title.Position = UDim2.new(0, 52, 0.5, -14)
    title.ZIndex = 6
    title.Parent = header
    title:SetAttribute("TextRole", "main")

    local versionTag = Instance.new("Frame")
    versionTag.BackgroundColor3 = T.Accent
    versionTag.BackgroundTransparency = 0.25
    versionTag.BorderSizePixel = 0
    versionTag.Size = UDim2.new(0, 44, 0, 18)
    versionTag.Position = UDim2.new(0, 136, 0.5, -9)
    versionTag.ZIndex = 6
    versionTag.Parent = header
    roundCorners(versionTag, 6)
    regA(versionTag)

    local versionLabel = Instance.new("TextLabel")
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "v2.0"
    versionLabel.Font = Enum.Font.GothamBold
    versionLabel.TextSize = 10
    versionLabel.TextColor3 = T.TextLight
    versionLabel.Size = UDim2.new(1, 0, 1, 0)
    versionLabel.ZIndex = 7
    versionLabel.Parent = versionTag
    versionLabel:SetAttribute("TextRole", "main")

    local scriptCount = Instance.new("TextLabel")
    scriptCount.BackgroundTransparency = 1
    scriptCount.Text = countScripts() .. " scripts"
    scriptCount.Font = Enum.Font.Gotham
    scriptCount.TextSize = 11
    scriptCount.TextColor3 = T.TextDim
    scriptCount.TextXAlignment = Enum.TextXAlignment.Right
    scriptCount.Size = UDim2.new(0, 110, 0, 20)
    scriptCount.Position = UDim2.new(1, -160, 0.5, -10)
    scriptCount.ZIndex = 6
    scriptCount.Parent = header

    local gameName = Instance.new("TextLabel")
    local ok, gname = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId).Name end)
    gameName.BackgroundTransparency = 1
    gameName.Text = ok and gname or "Unknown"
    gameName.Font = Enum.Font.Gotham
    gameName.TextSize = 10
    gameName.TextColor3 = T.TextMuted
    gameName.TextXAlignment = Enum.TextXAlignment.Right
    gameName.Size = UDim2.new(0, 130, 0, 14)
    gameName.Position = UDim2.new(1, -184, 0.5, 4)
    gameName.ZIndex = 6
    gameName.Parent = header

    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.BackgroundColor3 = T.BgCard
    closeBtn.BackgroundTransparency = 0.5
    closeBtn.BorderSizePixel = 0
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -14)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = T.TextLight
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = 8
    closeBtn.Parent = header
    roundCorners(closeBtn, 14)
    closeBtn:SetAttribute("TextRole", "main")
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.1 }):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.5 }):Play()
    end)

    -- ---------- Боковая панель (категории) ----------
    local sidebar = Instance.new("Frame")
    sidebar.BackgroundColor3 = T.BgSide
    sidebar.BackgroundTransparency = 0.4
    sidebar.BorderSizePixel = 0
    sidebar.Size = UDim2.new(0, 130, 1, -48)
    sidebar.Position = UDim2.new(0, 0, 0, 48)
    sidebar.ZIndex = 3
    sidebar.Parent = mainFrame
    roundCorners(sidebar, 0)

    -- Сглаживание углов снизу
    local sidebarBottomPatch = Instance.new("Frame")
    sidebarBottomPatch.BackgroundColor3 = T.BgSide
    sidebarBottomPatch.BackgroundTransparency = 0.4
    sidebarBottomPatch.BorderSizePixel = 0
    sidebarBottomPatch.Size = UDim2.new(0, 16, 0, 16)
    sidebarBottomPatch.Position = UDim2.new(0, 0, 1, -16)
    sidebarBottomPatch.ZIndex = 3
    sidebarBottomPatch.Parent = mainFrame
    roundCorners(sidebarBottomPatch, 12)

    -- Разделительная линия (тонкая)
    local divider = Instance.new("Frame")
    divider.BackgroundColor3 = T.Border
    divider.BackgroundTransparency = 0.6
    divider.BorderSizePixel = 0
    divider.Size = UDim2.new(0, 1, 1, -48)
    divider.Position = UDim2.new(0, 130, 0, 48)
    divider.ZIndex = 4
    divider.Parent = mainFrame

    -- Скроллинг для категорий
    local catScroll = Instance.new("ScrollingFrame")
    catScroll.BackgroundTransparency = 1
    catScroll.BorderSizePixel = 0
    catScroll.Size = UDim2.new(1, 0, 1, -12)
    catScroll.Position = UDim2.new(0, 0, 0, 8)
    catScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    catScroll.ScrollBarThickness = 2
    catScroll.ScrollBarImageColor3 = T.Accent
    catScroll.ZIndex = 4
    catScroll.Parent = sidebar
    regA(catScroll, "ScrollBarImageColor3")

    local catLayout = Instance.new("UIListLayout")
    catLayout.Padding = UDim.new(0, 4)
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    catLayout.Parent = catScroll
    local catPad = Instance.new("UIPadding")
    catPad.PaddingLeft = UDim.new(0, 8)
    catPad.PaddingRight = UDim.new(0, 8)
    catPad.PaddingTop = UDim.new(0, 4)
    catPad.Parent = catScroll
    catLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        catScroll.CanvasSize = UDim2.new(0, 0, 0, catLayout.AbsoluteContentSize.Y + 8)
    end)

    -- ---------- Контентная область ----------
    local contentContainer = Instance.new("Frame")
    contentContainer.BackgroundTransparency = 1
    contentContainer.Size = UDim2.new(1, -142, 1, -56)
    contentContainer.Position = UDim2.new(0, 136, 0, 52)
    contentContainer.ZIndex = 3
    contentContainer.Parent = mainFrame

    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.Size = UDim2.new(1, -4, 1, 0)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.ScrollBarThickness = 3
    scrollingFrame.ScrollBarImageColor3 = T.Accent
    scrollingFrame.ZIndex = 3
    scrollingFrame.Parent = contentContainer
    regA(scrollingFrame, "ScrollBarImageColor3")

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = scrollingFrame
    local contentPad = Instance.new("UIPadding")
    contentPad.PaddingLeft = UDim.new(0, 6)
    contentPad.PaddingRight = UDim.new(0, 6)
    contentPad.PaddingTop = UDim.new(0, 6)
    contentPad.Parent = scrollingFrame
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 12)
    end)

    -- ---------- Кнопка повторного открытия (плавающая) ----------
    local reopenBtn = Instance.new("ImageButton")
    reopenBtn.Size = UDim2.new(0, 48, 0, 48)
    reopenBtn.Position = UDim2.new(0.5, -24, 0.9, -24)
    reopenBtn.BackgroundColor3 = T.BgSide
    reopenBtn.BackgroundTransparency = 0.2
    reopenBtn.Image = "rbxassetid://74283928898866"
    reopenBtn.ImageTransparency = 0.2
    reopenBtn.ImageColor3 = T.TextLight
    reopenBtn.Visible = false
    reopenBtn.ZIndex = 10
    reopenBtn.Parent = screenGui
    roundCorners(reopenBtn, 24)
    addBorder(reopenBtn, 1.5, T.Accent, 0.3)
    regA(reopenBtn:FindFirstChildOfClass("UIStroke"), "Color")

    reopenBtn.MouseEnter:Connect(function()
        TweenService:Create(reopenBtn, TweenInfo.new(0.2), { BackgroundTransparency = 0, ImageTransparency = 0 }):Play()
    end)
    reopenBtn.MouseLeave:Connect(function()
        TweenService:Create(reopenBtn, TweenInfo.new(0.2), { BackgroundTransparency = 0.2, ImageTransparency = 0.2 }):Play()
    end)

    -- ---------- Хелперы для создания UI элементов (стиль минимализм) ----------
    local function createSectionHeader(text, parent)
        local frame = Instance.new("Frame")
        frame.BackgroundTransparency = 1
        frame.Size = UDim2.new(1, 0, 0, 28)
        frame.ZIndex = 3
        frame.Parent = parent

        local line = Instance.new("Frame")
        line.BackgroundColor3 = T.Border
        line.BackgroundTransparency = 0.5
        line.BorderSizePixel = 0
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, 1, -4)
        line.ZIndex = 3
        line.Parent = frame

        local dot = Instance.new("Frame")
        dot.BackgroundColor3 = T.Accent
        dot.BorderSizePixel = 0
        dot.Size = UDim2.new(0, 4, 0, 16)
        dot.Position = UDim2.new(0, 0, 0.5, -8)
        dot.ZIndex = 4
        dot.Parent = frame
        roundCorners(dot, 2)
        regA(dot)

        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Text = string.upper(text)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextColor3 = T.TextDim
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size = UDim2.new(1, -14, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.ZIndex = 4
        lbl.Parent = frame
        return frame
    end

    local function createLabel(text, parent, size, position)
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Size = size or UDim2.new(1, 0, 0, 24)
        lbl.Position = position or UDim2.new(0, 0, 0, 0)
        lbl.TextSize = 12
        lbl.TextColor3 = T.TextLight
        lbl.TextTransparency = 0.1
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Gotham
        lbl.TextWrapped = true
        lbl.ZIndex = 4
        lbl.Parent = parent
        lbl:SetAttribute("TextRole", "main")
        return lbl
    end

    local function createButton(text, parent, callback, isCategory)
        if isCategory then
            -- Кнопка для боковой панели (категория)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3 = T.BgCard
            btn.BackgroundTransparency = 1
            btn.BorderSizePixel = 0
            btn.Text = text
            btn.TextColor3 = T.TextDim
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Font = Enum.Font.Gotham
            btn.ZIndex = 5
            btn.Parent = parent
            roundCorners(btn, 8)
            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 12)
            padding.Parent = btn

            local indicator = Instance.new("Frame")
            indicator.BackgroundColor3 = T.Accent
            indicator.BackgroundTransparency = 1
            indicator.BorderSizePixel = 0
            indicator.Size = UDim2.new(0, 3, 0, 20)
            indicator.Position = UDim2.new(0, -6, 0.5, -10)
            indicator.ZIndex = 6
            indicator.Parent = btn
            roundCorners(indicator, 2)
            regA(indicator)

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundTransparency = 0.3, TextColor3 = T.TextLight }):Play()
            end)
            btn.MouseLeave:Connect(function()
                if btn:GetAttribute("Active") then return end
                TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundTransparency = 1, TextColor3 = T.TextDim }):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                for _, child in ipairs(parent:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:SetAttribute("Active", false)
                        TweenService:Create(child, TweenInfo.new(0.15), { BackgroundTransparency = 1, TextColor3 = T.TextDim }):Play()
                        local ind = child:FindFirstChildOfClass("Frame")
                        if ind then TweenService:Create(ind, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play() end
                    end
                end
                btn:SetAttribute("Active", true)
                TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = T.Accent, BackgroundTransparency = 0.3, TextColor3 = T.TextLight }):Play()
                TweenService:Create(indicator, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
                callback()
            end)
            return btn
        else
            -- Обычная кнопка в контенте
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 34)
            btn.BackgroundColor3 = T.BgCard
            btn.BackgroundTransparency = 0.3
            btn.BorderSizePixel = 0
            btn.Text = text
            btn.TextColor3 = T.TextLight
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Font = Enum.Font.Gotham
            btn.ZIndex = 4
            btn.Parent = parent
            btn:SetAttribute("TextRole", "main")
            roundCorners(btn, 8)
            addBorder(btn, 1, T.Border, 0.4)

            local btnPadding = Instance.new("UIPadding")
            btnPadding.PaddingLeft = UDim.new(0, 14)
            btnPadding.Parent = btn

            local accentLine = Instance.new("Frame")
            accentLine.BackgroundColor3 = T.Accent
            accentLine.BackgroundTransparency = 1
            accentLine.BorderSizePixel = 0
            accentLine.Size = UDim2.new(0, 2, 0, 18)
            accentLine.Position = UDim2.new(0, 6, 0.5, -9)
            accentLine.ZIndex = 5
            accentLine.Parent = btn
            roundCorners(accentLine, 2)
            regA(accentLine)

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = T.BgHover, BackgroundTransparency = 0.1 }):Play()
                TweenService:Create(accentLine, TweenInfo.new(0.12), { BackgroundTransparency = 0 }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = T.BgCard, BackgroundTransparency = 0.3 }):Play()
                TweenService:Create(accentLine, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.08), { BackgroundColor3 = T.Accent, BackgroundTransparency = 0.2 }):Play()
                task.delay(0.1, function()
                    TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = T.BgHover, BackgroundTransparency = 0.1 }):Play()
                end)
                callback()
            end)
            return btn
        end
    end

    -- Публичное API
    return {
        screenGui = screenGui,
        mainFrame = mainFrame,
        header = header,
        sidebar = sidebar,
        catScroll = catScroll,
        scrollingFrame = scrollingFrame,
        closeBtn = closeBtn,
        reopenButton = reopenBtn,
        gameName = ok and gname or "Unknown",
        mkCorner = roundCorners,
        mkStroke = addBorder,
        createButton = createButton,
        createLabel = createLabel,
        createSectionHeader = createSectionHeader,
        setNotification = function(fn) createNotification = fn end,
    }
end
