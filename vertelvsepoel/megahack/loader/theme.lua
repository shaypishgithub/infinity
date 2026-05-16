-- theme.lua (Module) — исправлено: stroke влияет только на обводку, текст использует textColor
return function(deps)
    local TweenService = deps.TweenService
    local RunService = deps.RunService
    local HttpService = deps.HttpService
    local playerGui = deps.playerGui
    local mainFrame = deps.mainFrame
    local scrollingFrame = deps.scrollingFrame
    local accentRegistry = deps.accentRegistry
    local createNotification = deps.createNotification

    -- ═══════════ ЦВЕТОВАЯ ТЕМА ═══════════
    local T = {
        BgBase    = Color3.fromRGB(13, 13, 17),
        BgSide    = Color3.fromRGB(19, 19, 25),
        BgPanel   = Color3.fromRGB(24, 24, 32),
        BgBtn     = Color3.fromRGB(30, 30, 40),
        BgBtnHov  = Color3.fromRGB(38, 38, 52),
        Accent    = Color3.fromRGB(155, 28, 28),
        AccentHov = Color3.fromRGB(190, 42, 42),
        AccentGlow= Color3.fromRGB(200, 50, 50),
        TextMain  = Color3.fromRGB(228, 228, 235),
        TextSub   = Color3.fromRGB(140, 140, 152),
        TextMuted = Color3.fromRGB(90, 90, 100),
        Stroke    = Color3.fromRGB(44, 44, 56),
        StrokeBrt = Color3.fromRGB(68, 68, 82),
        Separator = Color3.fromRGB(35, 35, 46),
    }

    local rgbConnections = {}
    local colorPickerConnections = {}

    local function regA(obj, prop)
        table.insert(accentRegistry, { obj = obj, prop = prop or "BackgroundColor3" })
    end

    -- ═══════════ ОЧИСТКА RGB ═══════════
    local function clearRgbConnections()
        for _, c in pairs(rgbConnections) do
            c:Disconnect()
        end
        rgbConnections = {}
    end

    -- ═══════════ ОБНОВЛЕНИЕ ЦВЕТОВ (ИСПРАВЛЕНО) ═══════════
    local function updateGuiColors(settings)
        clearRgbConnections()
        local acc = settings.colors.accentColor
        local bg  = settings.colors.bgColor
        local tx  = settings.colors.textColor
        local stk = settings.colors.strokeColor

        -- Обновляем глобальную таблицу T (включая Stroke)
        T.Accent     = acc
        T.AccentHov  = Color3.new(math.min(acc.R*1.22,1), math.min(acc.G*1.22,1), math.min(acc.B*1.22,1))
        T.AccentGlow = Color3.new(math.min(acc.R*1.35,1), math.min(acc.G*1.35,1), math.min(acc.B*1.35,1))
        T.BgBase     = bg
        T.BgSide     = Color3.new(math.min(bg.R+0.024,1), math.min(bg.G+0.024,1), math.min(bg.B+0.031,1))
        T.BgPanel    = Color3.new(math.min(bg.R+0.043,1), math.min(bg.G+0.043,1), math.min(bg.B+0.059,1))
        T.BgBtn      = Color3.new(math.min(bg.R+0.067,1), math.min(bg.G+0.067,1), math.min(bg.B+0.090,1))
        T.BgBtnHov   = Color3.new(math.min(bg.R+0.098,1), math.min(bg.G+0.098,1), math.min(bg.B+0.137,1))
        T.TextMain   = tx
        T.Stroke     = stk   -- ← важно: обновляем цвет обводки по умолчанию

        -- Акцент-элементы
        for _, entry in ipairs(accentRegistry) do
            if entry.obj and entry.obj.Parent then
                entry.obj[entry.prop] = acc
            end
        end

        -- Фон главного окна
        mainFrame.BackgroundColor3 = bg
        mainFrame.BackgroundTransparency = settings.transparency

        -- Проход по всем потомкам: stroke и текст обрабатываются раздельно
        for _, obj in pairs(mainFrame:GetDescendants()) do
            if obj:IsA("UIStroke") then
                -- ТОЛЬКО обводка (UIStroke)
                if settings.rgbStroke then
                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then
                            conn:Disconnect()
                            return
                        end
                        obj.Color = Color3.fromHSV((tick()%5)/5, 1, 1)
                    end)
                    table.insert(rgbConnections, conn)
                else
                    obj.Color = stk
                end
            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
                -- ТОЛЬКО текст
                if settings.rgbAccent then
                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then
                            conn:Disconnect()
                            return
                        end
                        obj.TextColor3 = Color3.fromHSV((tick()%5)/5, 1, 1)
                    end)
                    table.insert(rgbConnections, conn)
                else
                    -- Используем textColor (tx), а НЕ strokeColor
                    if obj:GetAttribute("TextRole") == "main" then
                        obj.TextColor3 = tx
                    end
                end
            end
        end
    end

    -- ═══════════ СОХРАНЕНИЕ / ЗАГРУЗКА НАСТРОЕК ═══════════
    local function saveColorSettings(settings)
        pcall(function()
            if not isfolder("MegaHack") then makefolder("MegaHack") end
            local col = settings.colors
            local data = {
                bgColor     = {col.bgColor.R, col.bgColor.G, col.bgColor.B},
                textColor   = {col.textColor.R, col.textColor.G, col.textColor.B},
                strokeColor = {col.strokeColor.R, col.strokeColor.G, col.strokeColor.B},
                accentColor = {col.accentColor.R, col.accentColor.G, col.accentColor.B},
                transparency = settings.transparency,
                rgbAccent    = settings.rgbAccent,
                rgbStroke    = settings.rgbStroke,
            }
            writefile("MegaHack/colorSettings.json", HttpService:JSONEncode(data))
        end)
    end

    local function loadColorSettings(settings)
        pcall(function()
            if isfile("MegaHack/colorSettings.json") then
                local data = HttpService:JSONDecode(readfile("MegaHack/colorSettings.json"))
                if data.bgColor then settings.colors.bgColor = Color3.new(data.bgColor[1], data.bgColor[2], data.bgColor[3]) end
                if data.textColor then settings.colors.textColor = Color3.new(data.textColor[1], data.textColor[2], data.textColor[3]) end
                if data.strokeColor then settings.colors.strokeColor = Color3.new(data.strokeColor[1], data.strokeColor[2], data.strokeColor[3]) end
                if data.accentColor then settings.colors.accentColor = Color3.new(data.accentColor[1], data.accentColor[2], data.accentColor[3]) end
                if data.transparency ~= nil then settings.transparency = data.transparency end
                if data.rgbAccent ~= nil then settings.rgbAccent = data.rgbAccent end
                if data.rgbStroke ~= nil then settings.rgbStroke = data.rgbStroke end
            end
        end)
    end

    -- ═══════════ ВИДЖЕТ ВЫБОРА ЦВЕТА (полная реализация) ═══════════
    local function createColorPicker(parent, settings)
        local selType = "bgColor"
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
        container.Size = UDim2.new(1, 0, 0, 340)
        container.ZIndex = 4
        container.Parent = parent

        local innerLayout = Instance.new("UIListLayout")
        innerLayout.Padding = UDim.new(0, 6)
        innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        innerLayout.Parent = container

        innerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.Size = UDim2.new(1, 0, 0, innerLayout.AbsoluteContentSize.Y + 4)
        end)

        -- ── Type selector ──
        local typeRow = Instance.new("Frame")
        typeRow.BackgroundTransparency = 1
        typeRow.Size = UDim2.new(1, 0, 0, 28)
        typeRow.LayoutOrder = 1
        typeRow.ZIndex = 4
        typeRow.Parent = container

        local typeRowLayout = Instance.new("UIListLayout")
        typeRowLayout.FillDirection = Enum.FillDirection.Horizontal
        typeRowLayout.Padding = UDim.new(0, 4)
        typeRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
        typeRowLayout.Parent = typeRow

        local typeBtnMap = {}
        local typeItems = {
            { label = "BG Color",   key = "bgColor" },
            { label = "Text",       key = "textColor" },
            { label = "Stroke",     key = "strokeColor" },
            { label = "Accent",     key = "accentColor" },
        }

        local updatePickerUI

        local function refreshTypeBtns(activeKey)
            for _, td in ipairs(typeItems) do
                local b = typeBtnMap[td.key]
                if b then
                    if td.key == activeKey then
                        b.BackgroundColor3 = T.Accent
                        b.BackgroundTransparency = 0.15
                        b.TextColor3 = T.TextMain
                    else
                        b.BackgroundColor3 = T.BgBtn
                        b.BackgroundTransparency = 0.3
                        b.TextColor3 = T.TextSub
                    end
                end
            end
        end

        for i, td in ipairs(typeItems) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1/4, -3, 1, 0)
            btn.BackgroundColor3 = T.BgBtn
            btn.BackgroundTransparency = 0.3
            btn.BorderSizePixel = 0
            btn.Text = td.label
            btn.TextColor3 = T.TextSub
            btn.TextSize = 11
            btn.Font = Enum.Font.GothamBold
            btn.LayoutOrder = i
            btn.ZIndex = 5
            btn.Parent = typeRow
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
            local s = Instance.new("UIStroke", btn)
            s.Thickness = 1
            s.Color = T.Stroke
            s.Transparency = 0.35
            typeBtnMap[td.key] = btn
            btn.MouseButton1Click:Connect(function()
                selType = td.key
                syncFromType()
                refreshTypeBtns(selType)
                if updatePickerUI then updatePickerUI() end
            end)
        end
        refreshTypeBtns(selType)

        -- ── SV square + info panel ──
        local sqSz = 148
        local mainArea = Instance.new("Frame")
        mainArea.BackgroundTransparency = 1
        mainArea.Size = UDim2.new(1, 0, 0, sqSz)
        mainArea.LayoutOrder = 2
        mainArea.ZIndex = 4
        mainArea.Parent = container

        local svBase = Instance.new("Frame")
        svBase.Size = UDim2.new(0, sqSz, 0, sqSz)
        svBase.Position = UDim2.new(0, 0, 0, 0)
        svBase.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
        svBase.BorderSizePixel = 0
        svBase.ZIndex = 5
        svBase.Parent = mainArea
        Instance.new("UICorner", svBase).CornerRadius = UDim.new(0, 5)
        local svStroke = Instance.new("UIStroke", svBase)
        svStroke.Thickness = 1
        svStroke.Color = T.Stroke
        svStroke.Transparency = 0.3

        local whiteOv = Instance.new("Frame")
        whiteOv.Size = UDim2.new(1, 0, 1, 0)
        whiteOv.BackgroundColor3 = Color3.new(1, 1, 1)
        whiteOv.BorderSizePixel = 0
        whiteOv.ZIndex = 6
        whiteOv.Parent = svBase
        Instance.new("UICorner", whiteOv).CornerRadius = UDim.new(0, 5)
        local wg = Instance.new("UIGradient", whiteOv)
        wg.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1))
        wg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})

        local blackOv = Instance.new("Frame")
        blackOv.Size = UDim2.new(1, 0, 1, 0)
        blackOv.BackgroundColor3 = Color3.new(0, 0, 0)
        blackOv.BorderSizePixel = 0
        blackOv.ZIndex = 7
        blackOv.Parent = svBase
        Instance.new("UICorner", blackOv).CornerRadius = UDim.new(0, 5)
        local bg2 = Instance.new("UIGradient", blackOv)
        bg2.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0))
        bg2.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})
        bg2.Rotation = 90

        local svCursor = Instance.new("Frame")
        svCursor.Size = UDim2.new(0, 10, 0, 10)
        svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
        svCursor.Position = UDim2.new(curS, 0, 1 - curV, 0)
        svCursor.BackgroundColor3 = Color3.new(1, 1, 1)
        svCursor.BorderSizePixel = 0
        svCursor.ZIndex = 9
        svCursor.Parent = svBase
        Instance.new("UICorner", svCursor).CornerRadius = UDim.new(0, 5)
        local cs = Instance.new("UIStroke", svCursor)
        cs.Thickness = 2
        cs.Color = Color3.new(0.1, 0.1, 0.1)
        cs.Transparency = 0

        local rightPanel = Instance.new("Frame")
        rightPanel.BackgroundTransparency = 1
        rightPanel.Size = UDim2.new(1, -(sqSz + 8), 1, 0)
        rightPanel.Position = UDim2.new(0, sqSz + 8, 0, 0)
        rightPanel.ZIndex = 4
        rightPanel.Parent = mainArea

        local previewSwatch = Instance.new("Frame")
        previewSwatch.Size = UDim2.new(1, 0, 0, 52)
        previewSwatch.BackgroundColor3 = settings.colors[selType]
        previewSwatch.BorderSizePixel = 0
        previewSwatch.ZIndex = 5
        previewSwatch.Parent = rightPanel
        Instance.new("UICorner", previewSwatch).CornerRadius = UDim.new(0, 6)
        local ps = Instance.new("UIStroke", previewSwatch)
        ps.Thickness = 1
        ps.Color = T.Stroke
        ps.Transparency = 0.3

        local previewLbl = Instance.new("TextLabel")
        previewLbl.BackgroundTransparency = 1
        previewLbl.Text = "PREVIEW"
        previewLbl.Font = Enum.Font.GothamBold
        previewLbl.TextSize = 9
        previewLbl.TextColor3 = Color3.new(1, 1, 1)
        previewLbl.TextTransparency = 0.45
        previewLbl.Size = UDim2.new(1, 0, 1, 0)
        previewLbl.ZIndex = 6
        previewLbl.Parent = previewSwatch

        local hexRow = Instance.new("Frame")
        hexRow.Size = UDim2.new(1, 0, 0, 26)
        hexRow.Position = UDim2.new(0, 0, 0, 58)
        hexRow.BackgroundColor3 = T.BgPanel
        hexRow.BackgroundTransparency = 0.15
        hexRow.BorderSizePixel = 0
        hexRow.ZIndex = 5
        hexRow.Parent = rightPanel
        Instance.new("UICorner", hexRow).CornerRadius = UDim.new(0, 5)
        local hs = Instance.new("UIStroke", hexRow)
        hs.Thickness = 1
        hs.Color = T.Stroke
        hs.Transparency = 0.3

        local hashLbl = Instance.new("TextLabel")
        hashLbl.Size = UDim2.new(0, 18, 1, 0)
        hashLbl.Position = UDim2.new(0, 2, 0, 0)
        hashLbl.BackgroundTransparency = 1
        hashLbl.Text = "#"
        hashLbl.TextColor3 = T.TextSub
        hashLbl.TextSize = 12
        hashLbl.Font = Enum.Font.GothamBold
        hashLbl.ZIndex = 6
        hashLbl.Parent = hexRow

        local hexBox = Instance.new("TextBox")
        hexBox.Size = UDim2.new(1, -20, 1, 0)
        hexBox.Position = UDim2.new(0, 20, 0, 0)
        hexBox.BackgroundTransparency = 1
        hexBox.TextColor3 = T.TextMain
        hexBox.TextSize = 11
        hexBox.Font = Enum.Font.Code
        hexBox.PlaceholderText = "RRGGBB"
        hexBox.PlaceholderColor3 = T.TextMuted
        hexBox.Text = ""
        hexBox.ClearTextOnFocus = false
        hexBox.ZIndex = 6
        hexBox.Parent = hexRow

        local rgbReadouts = {}
        local channelNames = {"R","G","B"}
        for i, nm in ipairs(channelNames) do
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 15)
            lbl.Position = UDim2.new(0, 0, 0, 90 + (i-1)*18)
            lbl.BackgroundTransparency = 1
            lbl.Text = nm .. ": 0"
            lbl.TextColor3 = T.TextSub
            lbl.TextSize = 11
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 5
            lbl.Parent = rightPanel
            rgbReadouts[i] = lbl
        end

        -- ── Hue slider ──
        local hueTrack = Instance.new("Frame")
        hueTrack.Size = UDim2.new(1, 0, 0, 16)
        hueTrack.BackgroundColor3 = Color3.new(1, 0, 0)
        hueTrack.BorderSizePixel = 0
        hueTrack.LayoutOrder = 3
        hueTrack.ZIndex = 5
        hueTrack.Parent = container
        Instance.new("UICorner", hueTrack).CornerRadius = UDim.new(0, 4)
        local hts = Instance.new("UIStroke", hueTrack)
        hts.Thickness = 1
        hts.Color = T.Stroke
        hts.Transparency = 0.3

        local hueGrad = Instance.new("UIGradient", hueTrack)
        hueGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0/6, Color3.fromHSV(0/6, 1, 1)),
            ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6, 1, 1)),
            ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6, 1, 1)),
            ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6, 1, 1)),
            ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6, 1, 1)),
            ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6, 1, 1)),
            ColorSequenceKeypoint.new(6/6, Color3.fromHSV(6/6, 1, 1)),
        })

        local hueCursor = Instance.new("Frame")
        hueCursor.Size = UDim2.new(0, 6, 1, 4)
        hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
        hueCursor.Position = UDim2.new(curH, 0, 0.5, 0)
        hueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
        hueCursor.BorderSizePixel = 0
        hueCursor.ZIndex = 6
        hueCursor.Parent = hueTrack
        Instance.new("UICorner", hueCursor).CornerRadius = UDim.new(0, 3)
        local hcs = Instance.new("UIStroke", hueCursor)
        hcs.Thickness = 1
        hcs.Color = T.Stroke
        hcs.Transparency = 0

        -- ── RGB sliders ──
        local rgbTracks = {}
        local rgbCursors = {}
        local rgbValLbls = {}
        local rgbPureCol = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1)}

        for i, nm in ipairs(channelNames) do
            local slot = Instance.new("Frame")
            slot.BackgroundTransparency = 1
            slot.Size = UDim2.new(1, 0, 0, 22)
            slot.LayoutOrder = 3 + i
            slot.ZIndex = 4
            slot.Parent = container

            local nmLbl = Instance.new("TextLabel")
            nmLbl.Size = UDim2.new(0, 14, 1, 0)
            nmLbl.BackgroundTransparency = 1
            nmLbl.Text = nm
            nmLbl.TextColor3 = T.TextSub
            nmLbl.TextSize = 11
            nmLbl.Font = Enum.Font.GothamBold
            nmLbl.ZIndex = 5
            nmLbl.Parent = slot

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -52, 0, 12)
            track.Position = UDim2.new(0, 18, 0.5, -6)
            track.BackgroundColor3 = Color3.new(0, 0, 0)
            track.BorderSizePixel = 0
            track.ZIndex = 5
            track.Parent = slot
            Instance.new("UICorner", track).CornerRadius = UDim.new(0, 4)
            local tts = Instance.new("UIStroke", track)
            tts.Thickness = 1
            tts.Color = T.Stroke
            tts.Transparency = 0.3

            local tg = Instance.new("UIGradient", track)
            tg.Color = ColorSequence.new(Color3.new(0,0,0), rgbPureCol[i])

            local cur = Instance.new("Frame")
            cur.Size = UDim2.new(0, 8, 1, 4)
            cur.AnchorPoint = Vector2.new(0.5, 0.5)
            cur.Position = UDim2.new(0, 0, 0.5, 0)
            cur.BackgroundColor3 = Color3.new(1, 1, 1)
            cur.BorderSizePixel = 0
            cur.ZIndex = 6
            cur.Parent = track
            Instance.new("UICorner", cur).CornerRadius = UDim.new(0, 4)
            local cus = Instance.new("UIStroke", cur)
            cus.Thickness = 1
            cus.Color = T.Stroke
            cus.Transparency = 0

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0, 30, 1, 0)
            valLbl.Position = UDim2.new(1, -30, 0, 0)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = "0"
            valLbl.TextColor3 = T.TextMain
            valLbl.TextSize = 11
            valLbl.Font = Enum.Font.Gotham
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.ZIndex = 5
            valLbl.Parent = slot
            valLbl:SetAttribute("TextRole", "main")

            rgbTracks[i] = track
            rgbCursors[i] = cur
            rgbValLbls[i] = valLbl
        end

        -- ── Apply button ──
        local applyBtn = Instance.new("TextButton")
        applyBtn.Size = UDim2.new(1, 0, 0, 30)
        applyBtn.BackgroundColor3 = T.Accent
        applyBtn.BackgroundTransparency = 0.15
        applyBtn.BorderSizePixel = 0
        applyBtn.Text = "✔  Apply & Save"
        applyBtn.TextColor3 = T.TextMain
        applyBtn.TextSize = 13
        applyBtn.Font = Enum.Font.GothamBold
        applyBtn.LayoutOrder = 7
        applyBtn.ZIndex = 5
        applyBtn.Parent = container
        applyBtn:SetAttribute("TextRole", "main")
        Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 6)
        local aps = Instance.new("UIStroke", applyBtn)
        aps.Thickness = 1
        aps.Color = T.Accent
        aps.Transparency = 0.35

        applyBtn.MouseEnter:Connect(function()
            TweenService:Create(applyBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
        end)
        applyBtn.MouseLeave:Connect(function()
            TweenService:Create(applyBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play()
        end)

        updatePickerUI = function()
            local col = Color3.fromHSV(curH, curS, curV)
            svBase.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
            svCursor.Position = UDim2.new(curS, 0, 1 - curV, 0)
            hueCursor.Position = UDim2.new(curH, 0, 0.5, 0)
            previewSwatch.BackgroundColor3 = col
            curR = math.floor(col.R * 255 + 0.5)
            curG = math.floor(col.G * 255 + 0.5)
            curB = math.floor(col.B * 255 + 0.5)
            hexBox.Text = string.format("%02X%02X%02X", curR, curG, curB)
            rgbReadouts[1].Text = "R: " .. curR
            rgbReadouts[2].Text = "G: " .. curG
            rgbReadouts[3].Text = "B: " .. curB
            local vals = {curR/255, curG/255, curB/255}
            local nums = {curR, curG, curB}
            for i = 1, 3 do
                rgbCursors[i].Position = UDim2.new(vals[i], 0, 0.5, 0)
                rgbValLbls[i].Text = tostring(nums[i])
            end
        end

        updatePickerUI()

        applyBtn.MouseButton1Click:Connect(function()
            settings.colors[selType] = Color3.fromHSV(curH, curS, curV)
            updateGuiColors(settings)
            saveColorSettings(settings)
            createNotification("COLOR PICKER", "Color applied & saved!", 2, 74283928898866)
            TweenService:Create(applyBtn, TweenInfo.new(0.08), {BackgroundColor3 = T.AccentGlow, BackgroundTransparency = 0}):Play()
            task.delay(0.18, function()
                TweenService:Create(applyBtn, TweenInfo.new(0.2), {BackgroundColor3 = T.Accent, BackgroundTransparency = 0.15}):Play()
            end)
        end)

        -- ── Drag logic ──
        local draggingSV, draggingHue, draggingRGB = false, false, 0

        svBase.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                draggingSV = true
            end
        end)
        hueTrack.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                draggingHue = true
            end
        end)
        for i = 1, 3 do
            rgbTracks[i].InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    draggingRGB = i
                end
            end)
        end

        UserInputService.InputChanged:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType ~= Enum.UserInputType.Touch then return end
            if draggingSV then
                local ap = svBase.AbsolutePosition; local as = svBase.AbsoluteSize
                curS = math.clamp((inp.Position.X - ap.X)/as.X, 0, 1)
                curV = 1 - math.clamp((inp.Position.Y - ap.Y)/as.Y, 0, 1)
                updatePickerUI()
            elseif draggingHue then
                local ap = hueTrack.AbsolutePosition; local as = hueTrack.AbsoluteSize
                curH = math.clamp((inp.Position.X - ap.X)/as.X, 0, 1)
                updatePickerUI()
            elseif draggingRGB > 0 then
                local i = draggingRGB
                local ap = rgbTracks[i].AbsolutePosition; local as = rgbTracks[i].AbsoluteSize
                local v = math.floor(math.clamp((inp.Position.X - ap.X)/as.X, 0, 1)*255 + 0.5)
                if i == 1 then curR = v elseif i == 2 then curG = v else curB = v end
                curH, curS, curV = Color3.toHSV(Color3.fromRGB(curR, curG, curB))
                updatePickerUI()
            end
        end)

        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                draggingSV, draggingHue, draggingRGB = false, false, 0
            end
        end)

        hexBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                local hex = hexBox.Text:gsub("[^%x]",""):upper()
                if #hex == 6 then
                    local r = tonumber(hex:sub(1,2),16)
                    local g = tonumber(hex:sub(3,4),16)
                    local b = tonumber(hex:sub(5,6),16)
                    if r and g and b then
                        curR, curG, curB = r, g, b
                        curH, curS, curV = Color3.toHSV(Color3.fromRGB(r,g,b))
                        updatePickerUI()
                    end
                end
            end
        end)

        return container
    end

    -- ═══════════ ПУБЛИЧНОЕ API ═══════════
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
