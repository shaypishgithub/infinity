-- ============================================================================
-- theme.lua — цветовая схема, регистрация акцентных элементов, RGB-эффекты
-- ============================================================================
return function(deps)
    local TweenService = deps.TweenService
    local RunService   = deps.RunService
    local HttpService  = deps.HttpService
    local playerGui    = deps.playerGui
    local mainFrame    = deps.mainFrame
    local scrollingFrame = deps.scrollingFrame
    local accentRegistry = deps.accentRegistry
    local createNotification = deps.createNotification

    -- ---------- Базовая цветовая палитра (минимализм, тёмный стекло) ----------
    local T = {
        BgGlass    = Color3.fromRGB(20, 20, 25),   -- основа полупрозрачная
        BgSide     = Color3.fromRGB(15, 15, 20),
        BgCard     = Color3.fromRGB(28, 28, 35),
        BgHover    = Color3.fromRGB(38, 38, 48),
        Accent     = Color3.fromRGB(100, 150, 255), -- неоново-синий акцент
        AccentGlow = Color3.fromRGB(130, 180, 255),
        TextLight  = Color3.fromRGB(245, 245, 250),
        TextDim    = Color3.fromRGB(160, 160, 175),
        TextMuted  = Color3.fromRGB(110, 110, 125),
        Border     = Color3.fromRGB(50, 50, 60),    -- тонкая рамка (вместо stroke)
    }

    -- Хранилище RGB-коннектов
    local rgbConnections = {}
    local colorPickerConnections = {}

    local function regA(obj, prop)
        table.insert(accentRegistry, { obj = obj, prop = prop or "BackgroundColor3" })
    end

    local function clearRgbConnections()
        for _, c in pairs(rgbConnections) do
            c:Disconnect()
        end
        rgbConnections = {}
    end

    -- ---------- Обновление цветов интерфейса ----------
    local function updateGuiColors(settings)
        clearRgbConnections()

        local acc = settings.colors.accentColor
        local bg  = settings.colors.bgColor
        local txt = settings.colors.textColor

        -- Обновляем глобальную таблицу T
        T.Accent     = acc
        T.AccentGlow = Color3.new(math.min(acc.R * 1.25, 1), math.min(acc.G * 1.25, 1), math.min(acc.B * 1.25, 1))
        T.BgGlass    = bg
        T.BgSide     = Color3.new(math.min(bg.R + 0.025, 1), math.min(bg.G + 0.025, 1), math.min(bg.B + 0.04, 1))
        T.BgCard     = Color3.new(math.min(bg.R + 0.045, 1), math.min(bg.G + 0.045, 1), math.min(bg.B + 0.07, 1))
        T.BgHover    = Color3.new(math.min(bg.R + 0.08, 1), math.min(bg.G + 0.08, 1), math.min(bg.B + 0.12, 1))
        T.TextLight  = txt
        T.TextDim    = Color3.new(math.min(txt.R * 0.7, 1), math.min(txt.G * 0.7, 1), math.min(txt.B * 0.7, 1))
        T.Border     = Color3.new(math.min(bg.R + 0.12, 1), math.min(bg.G + 0.12, 1), math.min(bg.B + 0.18, 1))

        -- Акцентные элементы (регистр)
        for _, entry in ipairs(accentRegistry) do
            if entry.obj and entry.obj.Parent then
                entry.obj[entry.prop] = acc
            end
        end

        -- Фон главного окна (стекло)
        mainFrame.BackgroundColor3 = bg
        mainFrame.BackgroundTransparency = settings.transparency or 0.15

        -- Проход по всем потомкам: обрабатываем UIStroke (минимально) и текст
        for _, obj in pairs(mainFrame:GetDescendants()) do
            if obj:IsA("UIStroke") then
                -- Для обводок используем Border (акцент, если rgb-режим)
                if settings.rgbAccent then
                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then conn:Disconnect() return end
                        obj.Color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
                    end)
                    table.insert(rgbConnections, conn)
                else
                    obj.Color = T.Border
                end
            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
                if settings.rgbAccent then
                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then conn:Disconnect() return end
                        obj.TextColor3 = Color3.fromHSV((tick() % 5) / 5, 1, 1)
                    end)
                    table.insert(rgbConnections, conn)
                else
                    if obj:GetAttribute("TextRole") == "main" then
                        obj.TextColor3 = txt
                    end
                end
            end
        end
    end

    -- ---------- Сохранение / загрузка настроек цветов ----------
    local function saveColorSettings(settings)
        pcall(function()
            if not isfolder("MegaHack") then makefolder("MegaHack") end
            local col = settings.colors
            local data = {
                bgColor     = { col.bgColor.R, col.bgColor.G, col.bgColor.B },
                textColor   = { col.textColor.R, col.textColor.G, col.textColor.B },
                accentColor = { col.accentColor.R, col.accentColor.G, col.accentColor.B },
                transparency = settings.transparency,
                rgbAccent    = settings.rgbAccent,
            }
            writefile("MegaHack/colorSettings.json", HttpService:JSONEncode(data))
        end)
    end

    local function loadColorSettings(settings)
        pcall(function()
            if isfile("MegaHack/colorSettings.json") then
                local data = HttpService:JSONDecode(readfile("MegaHack/colorSettings.json"))
                if data.bgColor     then settings.colors.bgColor     = Color3.new(data.bgColor[1], data.bgColor[2], data.bgColor[3]) end
                if data.textColor   then settings.colors.textColor   = Color3.new(data.textColor[1], data.textColor[2], data.textColor[3]) end
                if data.accentColor then settings.colors.accentColor = Color3.new(data.accentColor[1], data.accentColor[2], data.accentColor[3]) end
                if data.transparency ~= nil then settings.transparency = data.transparency end
                if data.rgbAccent    ~= nil then settings.rgbAccent   = data.rgbAccent end
            end
        end)
    end

    -- ---------- Улучшенный цветовой пикер (чистый, без stroke) ----------
    local function createColorPicker(parent, settings)
        local selType = "bgColor"   -- bgColor, textColor, accentColor
        local curH, curS, curV = Color3.toHSV(settings.colors.bgColor)
        local curR = math.floor(settings.colors.bgColor.R * 255 + 0.5)
        local curG = math.floor(settings.colors.bgColor.G * 255 + 0.5)
        local curB = math.floor(settings.colors.bgColor.B * 255 + 0.5)

        local function syncFromType()
            local col = settings.colors[selType]
            curH, curS, curV = Color3.toHSV(col)
            curR = math.floor(col.R * 255 + 0.5)
            curG = math.floor(col.G * 255 + 0.5)
            curB = math.floor(col.B * 255 + 0.5)
        end

        local container = Instance.new("Frame")
        container.BackgroundTransparency = 1
        container.Size = UDim2.new(1, 0, 0, 320)
        container.ZIndex = 4
        container.Parent = parent

        local innerLayout = Instance.new("UIListLayout")
        innerLayout.Padding = UDim.new(0, 8)
        innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        innerLayout.Parent = container
        innerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.Size = UDim2.new(1, 0, 0, innerLayout.AbsoluteContentSize.Y + 8)
        end)

        -- ----- Строка выбора типа -----
        local typeRow = Instance.new("Frame")
        typeRow.BackgroundTransparency = 1
        typeRow.Size = UDim2.new(1, 0, 0, 32)
        typeRow.LayoutOrder = 1
        typeRow.ZIndex = 4
        typeRow.Parent = container

        local typeRowLayout = Instance.new("UIListLayout")
        typeRowLayout.FillDirection = Enum.FillDirection.Horizontal
        typeRowLayout.Padding = UDim.new(0, 6)
        typeRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
        typeRowLayout.Parent = typeRow

        local typeBtnMap = {}
        local typeItems = {
            { label = "BG",     key = "bgColor" },
            { label = "TEXT",   key = "textColor" },
            { label = "ACCENT", key = "accentColor" },
        }
        local updatePickerUI

        local function refreshTypeBtns(activeKey)
            for _, td in ipairs(typeItems) do
                local b = typeBtnMap[td.key]
                if b then
                    if td.key == activeKey then
                        b.BackgroundColor3 = T.Accent
                        b.BackgroundTransparency = 0.2
                        b.TextColor3 = T.TextLight
                    else
                        b.BackgroundColor3 = T.BgCard
                        b.BackgroundTransparency = 0.5
                        b.TextColor3 = T.TextDim
                    end
                end
            end
        end

        for i, td in ipairs(typeItems) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1 / #typeItems, -4, 1, 0)
            btn.BackgroundColor3 = T.BgCard
            btn.BackgroundTransparency = 0.5
            btn.BorderSizePixel = 0
            btn.Text = td.label
            btn.TextColor3 = T.TextDim
            btn.TextSize = 12
            btn.Font = Enum.Font.GothamBold
            btn.LayoutOrder = i
            btn.ZIndex = 5
            btn.Parent = typeRow
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = btn
            typeBtnMap[td.key] = btn
            btn.MouseButton1Click:Connect(function()
                selType = td.key
                syncFromType()
                refreshTypeBtns(selType)
                if updatePickerUI then updatePickerUI() end
            end)
        end
        refreshTypeBtns(selType)

        -- ----- Основная область: SV квадрат + предпросмотр -----
        local mainArea = Instance.new("Frame")
        mainArea.BackgroundTransparency = 1
        mainArea.Size = UDim2.new(1, 0, 0, 150)
        mainArea.LayoutOrder = 2
        mainArea.ZIndex = 4
        mainArea.Parent = container

        local svSize = 140
        local svBase = Instance.new("Frame")
        svBase.Size = UDim2.new(0, svSize, 0, svSize)
        svBase.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
        svBase.BorderSizePixel = 0
        svBase.ZIndex = 5
        svBase.Parent = mainArea
        local svCorner = Instance.new("UICorner")
        svCorner.CornerRadius = UDim.new(0, 8)
        svCorner.Parent = svBase

        -- Белый и чёрный градиенты (SV палитра)
        local whiteGrad = Instance.new("Frame")
        whiteGrad.Size = UDim2.new(1, 0, 1, 0)
        whiteGrad.BackgroundColor3 = Color3.new(1, 1, 1)
        whiteGrad.BorderSizePixel = 0
        whiteGrad.ZIndex = 6
        whiteGrad.Parent = svBase
        local wCorner = Instance.new("UICorner")
        wCorner.CornerRadius = UDim.new(0, 8)
        wCorner.Parent = whiteGrad
        local wGrad = Instance.new("UIGradient")
        wGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
        wGrad.Parent = whiteGrad

        local blackGrad = Instance.new("Frame")
        blackGrad.Size = UDim2.new(1, 0, 1, 0)
        blackGrad.BackgroundColor3 = Color3.new(0, 0, 0)
        blackGrad.BorderSizePixel = 0
        blackGrad.ZIndex = 7
        blackGrad.Parent = svBase
        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 8)
        bCorner.Parent = blackGrad
        local bGrad = Instance.new("UIGradient")
        bGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
        bGrad.Rotation = 90
        bGrad.Parent = blackGrad

        -- Курсор на SV
        local svCursor = Instance.new("Frame")
        svCursor.Size = UDim2.new(0, 10, 0, 10)
        svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
        svCursor.Position = UDim2.new(curS, 0, 1 - curV, 0)
        svCursor.BackgroundColor3 = Color3.new(1, 1, 1)
        svCursor.BorderSizePixel = 0
        svCursor.ZIndex = 9
        svCursor.Parent = svBase
        local cursCorner = Instance.new("UICorner")
        cursCorner.CornerRadius = UDim.new(0, 5)
        cursCorner.Parent = svCursor
        local cursStroke = Instance.new("UIStroke")
        cursStroke.Thickness = 1.5
        cursStroke.Color = Color3.new(0, 0, 0)
        cursStroke.Transparency = 0.2
        cursStroke.Parent = svCursor

        -- Правая панель (превью + HEX + RGB)
        local rightPanel = Instance.new("Frame")
        rightPanel.BackgroundTransparency = 1
        rightPanel.Size = UDim2.new(1, -(svSize + 12), 1, 0)
        rightPanel.Position = UDim2.new(0, svSize + 12, 0, 0)
        rightPanel.ZIndex = 4
        rightPanel.Parent = mainArea

        local preview = Instance.new("Frame")
        preview.Size = UDim2.new(1, 0, 0, 48)
        preview.BackgroundColor3 = settings.colors[selType]
        preview.BorderSizePixel = 0
        preview.ZIndex = 5
        preview.Parent = rightPanel
        local prevCorner = Instance.new("UICorner")
        prevCorner.CornerRadius = UDim.new(0, 8)
        prevCorner.Parent = preview
        local previewLabel = Instance.new("TextLabel")
        previewLabel.BackgroundTransparency = 1
        previewLabel.Text = "PREVIEW"
        previewLabel.Font = Enum.Font.GothamBold
        previewLabel.TextSize = 9
        previewLabel.TextColor3 = Color3.new(1, 1, 1)
        previewLabel.TextTransparency = 0.4
        previewLabel.Size = UDim2.new(1, 0, 1, 0)
        previewLabel.ZIndex = 6
        previewLabel.Parent = preview

        -- HEX поле
        local hexFrame = Instance.new("Frame")
        hexFrame.Size = UDim2.new(1, 0, 0, 32)
        hexFrame.Position = UDim2.new(0, 0, 0, 56)
        hexFrame.BackgroundColor3 = T.BgCard
        hexFrame.BackgroundTransparency = 0.3
        hexFrame.BorderSizePixel = 0
        hexFrame.ZIndex = 5
        hexFrame.Parent = rightPanel
        local hexCorner = Instance.new("UICorner")
        hexCorner.CornerRadius = UDim.new(0, 6)
        hexCorner.Parent = hexFrame

        local hexBox = Instance.new("TextBox")
        hexBox.Size = UDim2.new(1, -24, 1, 0)
        hexBox.Position = UDim2.new(0, 12, 0, 0)
        hexBox.BackgroundTransparency = 1
        hexBox.TextColor3 = T.TextLight
        hexBox.TextSize = 12
        hexBox.Font = Enum.Font.Code
        hexBox.PlaceholderText = "RRGGBB"
        hexBox.PlaceholderColor3 = T.TextMuted
        hexBox.Text = ""
        hexBox.ClearTextOnFocus = false
        hexBox.ZIndex = 6
        hexBox.Parent = hexFrame
        hexBox:SetAttribute("TextRole", "main")

        -- RGB значения
        local rgbReadouts = {}
        for i, ch in ipairs({ "R", "G", "B" }) do
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 18)
            lbl.Position = UDim2.new(0, 0, 0, 96 + (i - 1) * 20)
            lbl.BackgroundTransparency = 1
            lbl.Text = ch .. ": 0"
            lbl.TextColor3 = T.TextDim
            lbl.TextSize = 11
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 5
            lbl.Parent = rightPanel
            rgbReadouts[i] = lbl
        end

        -- ----- Hue слайдер -----
        local hueTrack = Instance.new("Frame")
        hueTrack.Size = UDim2.new(1, 0, 0, 18)
        hueTrack.BackgroundColor3 = Color3.new(1, 0, 0)
        hueTrack.BorderSizePixel = 0
        hueTrack.LayoutOrder = 3
        hueTrack.ZIndex = 5
        hueTrack.Parent = container
        local hueCorner = Instance.new("UICorner")
        hueCorner.CornerRadius = UDim.new(0, 9)
        hueCorner.Parent = hueTrack

        local hueGrad = Instance.new("UIGradient")
        local colors = {}
        for i = 0, 6 do
            table.insert(colors, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
        end
        hueGrad.Color = ColorSequence.new(colors)
        hueGrad.Parent = hueTrack

        local hueCursor = Instance.new("Frame")
        hueCursor.Size = UDim2.new(0, 6, 1, -6)
        hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
        hueCursor.Position = UDim2.new(curH, 0, 0.5, 0)
        hueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
        hueCursor.BorderSizePixel = 0
        hueCursor.ZIndex = 6
        hueCursor.Parent = hueTrack
        local hcCorner = Instance.new("UICorner")
        hcCorner.CornerRadius = UDim.new(0, 3)
        hcCorner.Parent = hueCursor

        -- ----- RGB слайдеры -----
        local rgbTracks, rgbCursors, rgbLabels = {}, {}, {}
        local rgbColors = { Color3.new(1, 0, 0), Color3.new(0, 1, 0), Color3.new(0, 0, 1) }

        for i = 1, 3 do
            local slot = Instance.new("Frame")
            slot.BackgroundTransparency = 1
            slot.Size = UDim2.new(1, 0, 0, 26)
            slot.LayoutOrder = 3 + i
            slot.ZIndex = 4
            slot.Parent = container

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(0, 16, 1, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = ("RGB")[i]
            nameLbl.TextColor3 = T.TextDim
            nameLbl.TextSize = 11
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.ZIndex = 5
            nameLbl.Parent = slot

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -60, 0, 10)
            track.Position = UDim2.new(0, 20, 0.5, -5)
            track.BackgroundColor3 = Color3.new(0, 0, 0)
            track.BorderSizePixel = 0
            track.ZIndex = 5
            track.Parent = slot
            local trCorner = Instance.new("UICorner")
            trCorner.CornerRadius = UDim.new(0, 5)
            trCorner.Parent = track
            local grad = Instance.new("UIGradient")
            grad.Color = ColorSequence.new(Color3.new(0, 0, 0), rgbColors[i])
            grad.Parent = track

            local cursor = Instance.new("Frame")
            cursor.Size = UDim2.new(0, 8, 1, -4)
            cursor.AnchorPoint = Vector2.new(0.5, 0.5)
            cursor.Position = UDim2.new(0, 0, 0.5, 0)
            cursor.BackgroundColor3 = Color3.new(1, 1, 1)
            cursor.BorderSizePixel = 0
            cursor.ZIndex = 6
            cursor.Parent = track
            local curCorner = Instance.new("UICorner")
            curCorner.CornerRadius = UDim.new(0, 4)
            curCorner.Parent = cursor

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0, 34, 1, 0)
            valLbl.Position = UDim2.new(1, -34, 0, 0)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = "0"
            valLbl.TextColor3 = T.TextLight
            valLbl.TextSize = 10
            valLbl.Font = Enum.Font.Gotham
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.ZIndex = 5
            valLbl.Parent = slot
            valLbl:SetAttribute("TextRole", "main")

            rgbTracks[i] = track
            rgbCursors[i] = cursor
            rgbLabels[i] = valLbl
        end

        -- Кнопка Apply
        local applyBtn = Instance.new("TextButton")
        applyBtn.Size = UDim2.new(1, 0, 0, 34)
        applyBtn.BackgroundColor3 = T.Accent
        applyBtn.BackgroundTransparency = 0.2
        applyBtn.BorderSizePixel = 0
        applyBtn.Text = "✓ APPLY"
        applyBtn.TextColor3 = T.TextLight
        applyBtn.TextSize = 13
        applyBtn.Font = Enum.Font.GothamBold
        applyBtn.LayoutOrder = 7
        applyBtn.ZIndex = 5
        applyBtn.Parent = container
        applyBtn:SetAttribute("TextRole", "main")
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = applyBtn

        applyBtn.MouseEnter:Connect(function()
            TweenService:Create(applyBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
        end)
        applyBtn.MouseLeave:Connect(function()
            TweenService:Create(applyBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.2 }):Play()
        end)

        -- Функция обновления всего UI пикера
        updatePickerUI = function()
            local col = Color3.fromHSV(curH, curS, curV)
            svBase.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
            svCursor.Position = UDim2.new(curS, 0, 1 - curV, 0)
            hueCursor.Position = UDim2.new(curH, 0, 0.5, 0)
            preview.BackgroundColor3 = col
            curR = math.floor(col.R * 255 + 0.5)
            curG = math.floor(col.G * 255 + 0.5)
            curB = math.floor(col.B * 255 + 0.5)
            hexBox.Text = string.format("%02X%02X%02X", curR, curG, curB)
            rgbReadouts[1].Text = "R: " .. curR
            rgbReadouts[2].Text = "G: " .. curG
            rgbReadouts[3].Text = "B: " .. curB
            for i = 1, 3 do
                local v = i == 1 and curR or (i == 2 and curG or curB)
                rgbCursors[i].Position = UDim2.new(v / 255, 0, 0.5, 0)
                rgbLabels[i].Text = tostring(v)
            end
        end
        updatePickerUI()

        applyBtn.MouseButton1Click:Connect(function()
            settings.colors[selType] = Color3.fromHSV(curH, curS, curV)
            updateGuiColors(settings)
            saveColorSettings(settings)
            createNotification("COLOR", "Applied & saved", 2, 74283928898866)
            TweenService:Create(applyBtn, TweenInfo.new(0.1), { BackgroundColor3 = T.AccentGlow, BackgroundTransparency = 0 }):Play()
            task.delay(0.2, function()
                TweenService:Create(applyBtn, TweenInfo.new(0.15), { BackgroundColor3 = T.Accent, BackgroundTransparency = 0.2 }):Play()
            end)
        end)

        -- Drag логика
        local draggingSV, draggingHue, draggingRGB = false, false, 0
        local connections = {}

        local function startDragSV(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                draggingSV = true
            end
        end
        local function startDragHue(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                draggingHue = true
            end
        end
        table.insert(connections, svBase.InputBegan:Connect(startDragSV))
        table.insert(connections, hueTrack.InputBegan:Connect(startDragHue))
        for i = 1, 3 do
            table.insert(connections, rgbTracks[i].InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    draggingRGB = i
                end
            end))
        end

        local moveConn = UserInputService.InputChanged:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType ~= Enum.UserInputType.Touch then return end
            if draggingSV then
                local ap = svBase.AbsolutePosition
                local as = svBase.AbsoluteSize
                curS = math.clamp((inp.Position.X - ap.X) / as.X, 0, 1)
                curV = 1 - math.clamp((inp.Position.Y - ap.Y) / as.Y, 0, 1)
                updatePickerUI()
            elseif draggingHue then
                local ap = hueTrack.AbsolutePosition
                local as = hueTrack.AbsoluteSize
                curH = math.clamp((inp.Position.X - ap.X) / as.X, 0, 1)
                updatePickerUI()
            elseif draggingRGB > 0 then
                local i = draggingRGB
                local ap = rgbTracks[i].AbsolutePosition
                local as = rgbTracks[i].AbsoluteSize
                local val = math.floor(math.clamp((inp.Position.X - ap.X) / as.X, 0, 1) * 255 + 0.5)
                if i == 1 then curR = val elseif i == 2 then curG = val else curB = val end
                curH, curS, curV = Color3.toHSV(Color3.fromRGB(curR, curG, curB))
                updatePickerUI()
            end
        end)
        table.insert(connections, moveConn)

        local endConn = UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                draggingSV, draggingHue, draggingRGB = false, false, 0
            end
        end)
        table.insert(connections, endConn)

        hexBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                local hex = hexBox.Text:gsub("[^%x]", ""):upper()
                if #hex == 6 then
                    local r = tonumber(hex:sub(1, 2), 16)
                    local g = tonumber(hex:sub(3, 4), 16)
                    local b = tonumber(hex:sub(5, 6), 16)
                    if r and g and b then
                        curR, curG, curB = r, g, b
                        curH, curS, curV = Color3.toHSV(Color3.fromRGB(r, g, b))
                        updatePickerUI()
                    end
                end
            end
        end)

        -- Сохраняем коннекты для последующей очистки
        for _, c in ipairs(connections) do
            table.insert(colorPickerConnections, c)
        end

        return container
    end

    -- Публичное API
    return {
        T = T,
        regA = regA,
        updateGuiColors = updateGuiColors,
        createColorPicker = createColorPicker,
        saveColorSettings = saveColorSettings,
        loadColorSettings = loadColorSettings,
        clearRgbConnections = clearRgbConnections,
    }
end
