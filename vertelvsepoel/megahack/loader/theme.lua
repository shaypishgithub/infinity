-- theme.lua  ·  Glass Minimalism — переработанная цветовая система
-- stroke убран из визуала. textColor применяется через TextRole="main".
-- accentColor обновляет все зарегистрированные объекты через accentRegistry.

return function(deps)
    local TweenService      = deps.TweenService
    local RunService        = deps.RunService
    local HttpService       = deps.HttpService
    local playerGui         = deps.playerGui
    local mainFrame         = deps.mainFrame
    local scrollingFrame    = deps.scrollingFrame
    local accentRegistry    = deps.accentRegistry
    local createNotification = deps.createNotification

    -- ═══════════ ЦВЕТОВАЯ ТЕМА ═══════════
    local T = {
        BgBase    = Color3.fromRGB(11, 11, 15),
        BgSide    = Color3.fromRGB(16, 16, 22),
        BgPanel   = Color3.fromRGB(22, 22, 30),
        BgBtn     = Color3.fromRGB(28, 28, 38),
        BgBtnHov  = Color3.fromRGB(36, 36, 50),
        Accent    = Color3.fromRGB(150, 25, 25),
        AccentHov = Color3.fromRGB(185, 40, 40),
        AccentGlow= Color3.fromRGB(205, 55, 55),
        TextMain  = Color3.fromRGB(230, 230, 238),
        TextSub   = Color3.fromRGB(145, 145, 158),
        TextMuted = Color3.fromRGB(85,  85,  96),
        -- Stroke оставлен для совместимости (используется в logic.lua / searchBox),
        -- но не применяется к видимым панелям
        Stroke    = Color3.fromRGB(40, 40, 54),
        StrokeBrt = Color3.fromRGB(60, 60, 76),
        Separator = Color3.fromRGB(32, 32, 44),
    }

    local rgbConnections = {}

    local function regA(obj, prop)
        table.insert(accentRegistry, { obj = obj, prop = prop or "BackgroundColor3" })
    end

    local function clearRgbConnections()
        for _, c in pairs(rgbConnections) do
            pcall(function() c:Disconnect() end)
        end
        rgbConnections = {}
    end

    -- ═══════════ ОБНОВЛЕНИЕ ЦВЕТОВ ═══════════
    -- Применяет acc / bg / tx ко всем потомкам mainFrame.
    -- UIStroke обновляется только если rgbStroke=true (для searchBox и т.п.).
    -- TextColor3 обновляется по TextRole="main".
    -- Фоны панелей — через прямые присваивания именованных объектов (в logic.lua).
    local function updateGuiColors(settings)
        clearRgbConnections()
        local acc = settings.colors.accentColor
        local bg  = settings.colors.bgColor
        local tx  = settings.colors.textColor

        -- Пересчёт производных цветов
        T.Accent     = acc
        T.AccentHov  = Color3.new(math.min(acc.R*1.22,1), math.min(acc.G*1.22,1), math.min(acc.B*1.22,1))
        T.AccentGlow = Color3.new(math.min(acc.R*1.38,1), math.min(acc.G*1.38,1), math.min(acc.B*1.38,1))
        T.BgBase     = bg
        T.BgSide     = Color3.new(math.min(bg.R+0.020,1), math.min(bg.G+0.020,1), math.min(bg.B+0.028,1))
        T.BgPanel    = Color3.new(math.min(bg.R+0.043,1), math.min(bg.G+0.043,1), math.min(bg.B+0.060,1))
        T.BgBtn      = Color3.new(math.min(bg.R+0.067,1), math.min(bg.G+0.067,1), math.min(bg.B+0.090,1))
        T.BgBtnHov   = Color3.new(math.min(bg.R+0.098,1), math.min(bg.G+0.098,1), math.min(bg.B+0.137,1))
        T.TextMain   = tx

        -- accentRegistry: применяем accent ко всем зарегистрированным объектам
        for _, entry in ipairs(accentRegistry) do
            if entry.obj and entry.obj.Parent then
                entry.obj[entry.prop] = acc
            end
        end

        -- Фон главного окна
        mainFrame.BackgroundColor3       = bg
        mainFrame.BackgroundTransparency = settings.transparency

        -- Проход по потомкам mainFrame
        for _, obj in pairs(mainFrame:GetDescendants()) do
            -- UIStroke: обновляем цвет только если rgbStroke активен
            -- (нужен для searchBox в logic.lua — он сам вызывает mkStroke)
            if obj:IsA("UIStroke") then
                if settings.rgbStroke then
                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then
                            conn:Disconnect()
                            return
                        end
                        obj.Color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
                    end)
                    table.insert(rgbConnections, conn)
                end
                -- если rgbStroke выключен — не трогаем stroke вообще
                -- (в gui.lua stroke скрыт по умолчанию Transparency=1)

            -- Текст: обновляем только объекты с TextRole="main"
            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if settings.rgbAccent then
                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then
                            conn:Disconnect()
                            return
                        end
                        obj.TextColor3 = Color3.fromHSV((tick() % 5) / 5, 1, 1)
                    end)
                    table.insert(rgbConnections, conn)
                else
                    if obj:GetAttribute("TextRole") == "main" then
                        obj.TextColor3 = tx
                    end
                end
            end
        end
    end

    -- ═══════════ СОХРАНЕНИЕ / ЗАГРУЗКА ═══════════
    local function saveColorSettings(settings)
        pcall(function()
            if not isfolder("MegaHack") then makefolder("MegaHack") end
            local col  = settings.colors
            local data = {
                bgColor      = { col.bgColor.R,     col.bgColor.G,     col.bgColor.B     },
                textColor    = { col.textColor.R,   col.textColor.G,   col.textColor.B   },
                strokeColor  = { col.strokeColor.R, col.strokeColor.G, col.strokeColor.B },
                accentColor  = { col.accentColor.R, col.accentColor.G, col.accentColor.B },
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
                if data.bgColor     then settings.colors.bgColor     = Color3.new(table.unpack(data.bgColor))     end
                if data.textColor   then settings.colors.textColor   = Color3.new(table.unpack(data.textColor))   end
                if data.strokeColor then settings.colors.strokeColor = Color3.new(table.unpack(data.strokeColor)) end
                if data.accentColor then settings.colors.accentColor = Color3.new(table.unpack(data.accentColor)) end
                if data.transparency ~= nil then settings.transparency = data.transparency end
                if data.rgbAccent   ~= nil then settings.rgbAccent   = data.rgbAccent     end
                if data.rgbStroke   ~= nil then settings.rgbStroke   = data.rgbStroke     end
            end
        end)
    end

    -- ═══════════ COLOR PICKER ═══════════
    -- Полная реализация (совместима с logic.lua: createColorPicker(scrollingFrame))
    local function createColorPicker(parent, settings)
        local selType       = "bgColor"
        local curH, curS, curV = Color3.toHSV(settings.colors.bgColor)
        local curR = math.floor(settings.colors.bgColor.R * 255 + 0.5)
        local curG = math.floor(settings.colors.bgColor.G * 255 + 0.5)
        local curB = math.floor(settings.colors.bgColor.B * 255 + 0.5)

        local function syncFromType()
            local col  = settings.colors[selType]
            curH, curS, curV = Color3.toHSV(col)
            curR = math.floor(col.R * 255 + 0.5)
            curG = math.floor(col.G * 255 + 0.5)
            curB = math.floor(col.B * 255 + 0.5)
        end

        local container = Instance.new("Frame")
        container.BackgroundTransparency = 1
        container.Size   = UDim2.new(1, 0, 0, 340)
        container.ZIndex = 4
        container.Parent = parent

        local innerLayout = Instance.new("UIListLayout")
        innerLayout.Padding   = UDim.new(0, 6)
        innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        innerLayout.Parent    = container

        innerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.Size = UDim2.new(1, 0, 0, innerLayout.AbsoluteContentSize.Y + 4)
        end)

        -- ── Type selector row ──
        local typeRow = Instance.new("Frame")
        typeRow.BackgroundTransparency = 1
        typeRow.Size                   = UDim2.new(1, 0, 0, 28)
        typeRow.LayoutOrder            = 1
        typeRow.ZIndex                 = 4
        typeRow.Parent                 = container

        local typeLayout = Instance.new("UIListLayout")
        typeLayout.FillDirection = Enum.FillDirection.Horizontal
        typeLayout.Padding       = UDim.new(0, 4)
        typeLayout.SortOrder     = Enum.SortOrder.LayoutOrder
        typeLayout.Parent        = typeRow

        local colorTypes = {
            { key = "bgColor",     label = "BG"     },
            { key = "textColor",   label = "TEXT"   },
            { key = "accentColor", label = "ACCENT" },
        }
        local typeBtns = {}

        for i, ct in ipairs(colorTypes) do
            local tb = Instance.new("TextButton")
            tb.Size                   = UDim2.new(0, 68, 0, 26)
            tb.BackgroundColor3       = (i == 1) and T.Accent or T.BgBtn
            tb.BackgroundTransparency = (i == 1) and 0.3     or 0.4
            tb.BorderSizePixel        = 0
            tb.Text                   = ct.label
            tb.TextColor3             = T.TextMain
            tb.TextSize               = 11
            tb.Font                   = Enum.Font.GothamBold
            tb.ZIndex                 = 5
            tb.Parent                 = typeRow
            tb:SetAttribute("TextRole", "main")
            Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)

            typeBtns[i] = tb
            tb.MouseButton1Click:Connect(function()
                selType = ct.key
                syncFromType()
                for j, b in ipairs(typeBtns) do
                    TweenService:Create(b, TweenInfo.new(0.15), {
                        BackgroundColor3       = (j == i) and T.Accent or T.BgBtn,
                        BackgroundTransparency = (j == i) and 0.3      or 0.4,
                    }):Play()
                end
                if updatePickerUI then updatePickerUI() end
            end)
        end

        -- ── SV поле ──
        local svBase = Instance.new("Frame")
        svBase.Size             = UDim2.new(1, 0, 0, 110)
        svBase.BorderSizePixel  = 0
        svBase.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
        svBase.LayoutOrder      = 2
        svBase.ZIndex           = 4
        svBase.Parent           = container
        Instance.new("UICorner", svBase).CornerRadius = UDim.new(0, 8)

        local svGradW = Instance.new("UIGradient", svBase)
        svGradW.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1))
        svGradW.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1) })

        local svGradB = Instance.new("Frame")
        svGradB.Size             = UDim2.new(1,0,1,0)
        svGradB.BackgroundColor3 = Color3.new(0,0,0)
        svGradB.BackgroundTransparency = 0
        svGradB.BorderSizePixel  = 0
        svGradB.ZIndex           = 4
        svGradB.Parent           = svBase
        Instance.new("UICorner", svGradB).CornerRadius = UDim.new(0, 8)
        local svGradBg = Instance.new("UIGradient", svGradB)
        svGradBg.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0))
        svGradBg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0) })
        svGradBg.Rotation = 90

        local svCursor = Instance.new("Frame")
        svCursor.Size             = UDim2.new(0, 10, 0, 10)
        svCursor.AnchorPoint      = Vector2.new(0.5, 0.5)
        svCursor.BackgroundColor3 = Color3.new(1,1,1)
        svCursor.BorderSizePixel  = 0
        svCursor.ZIndex           = 6
        svCursor.Parent           = svBase
        Instance.new("UICorner", svCursor).CornerRadius = UDim.new(1, 0)

        -- ── Hue трек ──
        local hueTrack = Instance.new("Frame")
        hueTrack.Size            = UDim2.new(1, 0, 0, 16)
        hueTrack.BorderSizePixel = 0
        hueTrack.BackgroundColor3= Color3.new(1,1,1)
        hueTrack.LayoutOrder     = 3
        hueTrack.ZIndex          = 4
        hueTrack.Parent          = container
        Instance.new("UICorner", hueTrack).CornerRadius = UDim.new(0, 5)
        local hg = Instance.new("UIGradient", hueTrack)
        hg.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,   1,1)),
            ColorSequenceKeypoint.new(0.167,Color3.fromHSV(0.167,1,1)),
            ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333,1,1)),
            ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5, 1,1)),
            ColorSequenceKeypoint.new(0.667,Color3.fromHSV(0.667,1,1)),
            ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833,1,1)),
            ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,   1,1)),
        })

        local hueCursor = Instance.new("Frame")
        hueCursor.Size             = UDim2.new(0, 8, 1, 4)
        hueCursor.AnchorPoint      = Vector2.new(0.5, 0.5)
        hueCursor.BackgroundColor3 = Color3.new(1,1,1)
        hueCursor.BorderSizePixel  = 0
        hueCursor.ZIndex           = 6
        hueCursor.Parent           = hueTrack
        Instance.new("UICorner", hueCursor).CornerRadius = UDim.new(0, 4)

        -- ── Preview + HEX ──
        local previewRow = Instance.new("Frame")
        previewRow.BackgroundTransparency = 1
        previewRow.Size                   = UDim2.new(1, 0, 0, 28)
        previewRow.LayoutOrder            = 4
        previewRow.ZIndex                 = 4
        previewRow.Parent                 = container

        local previewSwatch = Instance.new("Frame")
        previewSwatch.Size             = UDim2.new(0, 28, 0, 28)
        previewSwatch.BackgroundColor3 = Color3.fromHSV(curH, curS, curV)
        previewSwatch.BorderSizePixel  = 0
        previewSwatch.ZIndex           = 5
        previewSwatch.Parent           = previewRow
        Instance.new("UICorner", previewSwatch).CornerRadius = UDim.new(0, 6)

        local hexBox = Instance.new("TextBox")
        hexBox.Size                   = UDim2.new(0, 90, 0, 26)
        hexBox.Position               = UDim2.new(0, 36, 0.5, -13)
        hexBox.BackgroundColor3       = T.BgBtn
        hexBox.BackgroundTransparency = 0.3
        hexBox.TextColor3             = T.TextMain
        hexBox.Text                   = string.format("%02X%02X%02X", curR, curG, curB)
        hexBox.TextSize               = 12
        hexBox.Font                   = Enum.Font.GothamBold
        hexBox.ClearTextOnFocus       = false
        hexBox.ZIndex                 = 5
        hexBox.Parent                 = previewRow
        hexBox:SetAttribute("TextRole", "main")
        Instance.new("UICorner", hexBox).CornerRadius = UDim.new(0, 6)

        -- RGB readouts
        local rgbReadouts = {}
        local readoutLabels = {"R", "G", "B"}
        for i = 1, 3 do
            local rl = Instance.new("TextLabel")
            rl.BackgroundTransparency = 1
            rl.Text       = readoutLabels[i] .. ": 0"
            rl.TextColor3 = T.TextSub
            rl.TextSize   = 11
            rl.Font       = Enum.Font.Gotham
            rl.Size       = UDim2.new(0, 36, 0, 26)
            rl.Position   = UDim2.new(0, 134 + (i-1)*42, 0.5, -13)
            rl.ZIndex     = 5
            rl.Parent     = previewRow
            rgbReadouts[i] = rl
        end

        -- ── RGB sliders ──
        local rgbPureCol = {Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255)}
        local sliderLabels = {"R", "G", "B"}
        local rgbTracks  = {}
        local rgbCursors = {}
        local rgbValLbls = {}

        for i = 1, 3 do
            local slot = Instance.new("Frame")
            slot.BackgroundTransparency = 1
            slot.Size                   = UDim2.new(1, 0, 0, 18)
            slot.LayoutOrder            = 4 + i
            slot.ZIndex                 = 4
            slot.Parent                 = container

            local slotLbl = Instance.new("TextLabel")
            slotLbl.BackgroundTransparency = 1
            slotLbl.Text      = sliderLabels[i]
            slotLbl.TextColor3= T.TextSub
            slotLbl.TextSize  = 11
            slotLbl.Font      = Enum.Font.GothamBold
            slotLbl.Size      = UDim2.new(0, 14, 1, 0)
            slotLbl.ZIndex    = 5
            slotLbl.Parent    = slot

            local track = Instance.new("Frame")
            track.Size             = UDim2.new(1, -50, 0, 10)
            track.Position         = UDim2.new(0, 18, 0.5, -5)
            track.BackgroundColor3 = T.BgBtn
            track.BorderSizePixel  = 0
            track.ZIndex           = 5
            track.Parent           = slot
            Instance.new("UICorner", track).CornerRadius = UDim.new(0, 5)

            local tg = Instance.new("UIGradient", track)
            tg.Color = ColorSequence.new(Color3.new(0,0,0), rgbPureCol[i])

            local cur = Instance.new("Frame")
            cur.Size             = UDim2.new(0, 8, 1, 4)
            cur.AnchorPoint      = Vector2.new(0.5, 0.5)
            cur.Position         = UDim2.new(0, 0, 0.5, 0)
            cur.BackgroundColor3 = Color3.new(1,1,1)
            cur.BorderSizePixel  = 0
            cur.ZIndex           = 6
            cur.Parent           = track
            Instance.new("UICorner", cur).CornerRadius = UDim.new(0, 4)

            local valLbl = Instance.new("TextLabel")
            valLbl.Size                   = UDim2.new(0, 28, 1, 0)
            valLbl.Position               = UDim2.new(1, -28, 0, 0)
            valLbl.BackgroundTransparency = 1
            valLbl.Text                   = "0"
            valLbl.TextColor3             = T.TextMain
            valLbl.TextSize               = 11
            valLbl.Font                   = Enum.Font.Gotham
            valLbl.TextXAlignment         = Enum.TextXAlignment.Right
            valLbl.ZIndex                 = 5
            valLbl.Parent                 = slot
            valLbl:SetAttribute("TextRole", "main")

            rgbTracks[i]  = track
            rgbCursors[i] = cur
            rgbValLbls[i] = valLbl
        end

        -- ── Apply button ──
        local applyBtn = Instance.new("TextButton")
        applyBtn.Size                   = UDim2.new(1, 0, 0, 30)
        applyBtn.BackgroundColor3       = T.Accent
        applyBtn.BackgroundTransparency = 0.2
        applyBtn.BorderSizePixel        = 0
        applyBtn.Text                   = "Apply & Save"
        applyBtn.TextColor3             = T.TextMain
        applyBtn.TextSize               = 13
        applyBtn.Font                   = Enum.Font.GothamBold
        applyBtn.LayoutOrder            = 8
        applyBtn.ZIndex                 = 5
        applyBtn.Parent                 = container
        applyBtn:SetAttribute("TextRole", "main")
        Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 7)
        regA(applyBtn)

        applyBtn.MouseEnter:Connect(function()
            TweenService:Create(applyBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
        end)
        applyBtn.MouseLeave:Connect(function()
            TweenService:Create(applyBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
        end)

        -- ── updatePickerUI ──
        local updatePickerUI
        updatePickerUI = function()
            local col = Color3.fromHSV(curH, curS, curV)
            svBase.BackgroundColor3  = Color3.fromHSV(curH, 1, 1)
            svCursor.Position        = UDim2.new(curS, 0, 1 - curV, 0)
            hueCursor.Position       = UDim2.new(curH, 0, 0.5, 0)
            previewSwatch.BackgroundColor3 = col
            curR = math.floor(col.R * 255 + 0.5)
            curG = math.floor(col.G * 255 + 0.5)
            curB = math.floor(col.B * 255 + 0.5)
            hexBox.Text = string.format("%02X%02X%02X", curR, curG, curB)
            rgbReadouts[1].Text = "R: " .. curR
            rgbReadouts[2].Text = "G: " .. curG
            rgbReadouts[3].Text = "B: " .. curB
            local vals = { curR/255, curG/255, curB/255 }
            local nums = { curR, curG, curB }
            for i = 1, 3 do
                rgbCursors[i].Position = UDim2.new(vals[i], 0, 0.5, 0)
                rgbValLbls[i].Text     = tostring(nums[i])
            end
        end

        updatePickerUI()

        applyBtn.MouseButton1Click:Connect(function()
            settings.colors[selType] = Color3.fromHSV(curH, curS, curV)
            updateGuiColors(settings)
            saveColorSettings(settings)
            createNotification("COLOR PICKER", "Color applied & saved!", 2, 74283928898866)
            TweenService:Create(applyBtn, TweenInfo.new(0.07), {BackgroundTransparency = 0}):Play()
            task.delay(0.15, function()
                TweenService:Create(applyBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
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
                local i  = draggingRGB
                local ap = rgbTracks[i].AbsolutePosition
                local as = rgbTracks[i].AbsoluteSize
                local v  = math.floor(math.clamp((inp.Position.X - ap.X) / as.X, 0, 1) * 255 + 0.5)
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
                local hex = hexBox.Text:gsub("[^%x]", ""):upper()
                if #hex == 6 then
                    local r = tonumber(hex:sub(1,2), 16)
                    local g = tonumber(hex:sub(3,4), 16)
                    local b = tonumber(hex:sub(5,6), 16)
                    if r and g and b then
                        curR, curG, curB = r, g, b
                        curH, curS, curV = Color3.toHSV(Color3.fromRGB(r, g, b))
                        updatePickerUI()
                    end
                end
            end
        end)

        return container
    end

    -- ═══════════ PUBLIC API ═══════════
    return {
        T                 = T,
        regA              = regA,
        updateGuiColors   = updateGuiColors,
        createColorPicker = createColorPicker,
        saveColorSettings = saveColorSettings,
        loadColorSettings = loadColorSettings,
        clearRgbConnections = clearRgbConnections,
    }
end
