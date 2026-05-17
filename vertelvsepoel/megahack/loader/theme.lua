-- theme.lua — Glass Minimalism Edition
-- Без UIStroke. Цвет применяется через BackgroundColor3 + Transparency.
-- Акцент, текст, фон — всё раздельно и чисто.

return function(deps)
    local TweenService   = deps.TweenService
    local RunService     = deps.RunService
    local HttpService    = deps.HttpService
    local playerGui      = deps.playerGui
    local mainFrame      = deps.mainFrame
    local scrollingFrame = deps.scrollingFrame
    local accentRegistry = deps.accentRegistry
    local createNotification = deps.createNotification

    -- ═══════════ ЦВЕТОВАЯ ТЕМА ═══════════
    -- Тёмный стеклянный минимализм с красным акцентом
    local T = {
        BgBase     = Color3.fromRGB(10, 10, 14),        -- почти чёрный
        BgGlass    = Color3.fromRGB(22, 22, 30),        -- стекло-слой
        BgPanel    = Color3.fromRGB(28, 28, 38),        -- панели
        BgBtn      = Color3.fromRGB(32, 32, 44),        -- кнопки
        BgBtnHov   = Color3.fromRGB(42, 42, 58),        -- ховер
        Accent     = Color3.fromRGB(200, 30, 30),       -- красный акцент
        AccentHov  = Color3.fromRGB(230, 50, 50),
        AccentGlow = Color3.fromRGB(255, 70, 70),
        AccentDim  = Color3.fromRGB(120, 18, 18),       -- приглушённый акцент
        TextMain   = Color3.fromRGB(235, 235, 242),     -- основной текст
        TextSub    = Color3.fromRGB(130, 130, 148),     -- второстепенный
        TextMuted  = Color3.fromRGB(72, 72, 88),        -- приглушённый
        Separator  = Color3.fromRGB(38, 38, 52),        -- разделитель
        -- Stroke убран полностью — используем только фоновые слои
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
    -- Stroke нет нигде — только BackgroundColor3 и TextColor3
    local function updateGuiColors(settings)
        clearRgbConnections()
        local acc = settings.colors.accentColor
        local bg  = settings.colors.bgColor
        local tx  = settings.colors.textColor

        -- Обновляем глобальную таблицу T
        T.Accent     = acc
        T.AccentHov  = Color3.new(math.min(acc.R*1.2,1),  math.min(acc.G*1.2,1),  math.min(acc.B*1.2,1))
        T.AccentGlow = Color3.new(math.min(acc.R*1.4,1),  math.min(acc.G*1.4,1),  math.min(acc.B*1.4,1))
        T.AccentDim  = Color3.new(acc.R*0.6, acc.G*0.6, acc.B*0.6)
        T.BgBase     = bg
        T.BgGlass    = Color3.new(math.min(bg.R+0.047,1), math.min(bg.G+0.047,1), math.min(bg.B+0.063,1))
        T.BgPanel    = Color3.new(math.min(bg.R+0.070,1), math.min(bg.G+0.070,1), math.min(bg.B+0.094,1))
        T.BgBtn      = Color3.new(math.min(bg.R+0.086,1), math.min(bg.G+0.086,1), math.min(bg.B+0.118,1))
        T.BgBtnHov   = Color3.new(math.min(bg.R+0.125,1), math.min(bg.G+0.125,1), math.min(bg.B+0.172,1))
        T.TextMain   = tx

        -- Акцент-реестр
        for _, entry in ipairs(accentRegistry) do
            if entry.obj and entry.obj.Parent then
                entry.obj[entry.prop] = acc
            end
        end

        -- Главный фрейм
        mainFrame.BackgroundColor3       = bg
        mainFrame.BackgroundTransparency = settings.transparency

        -- Проход по потомкам — только TextColor3 для текстовых элементов
        -- UIStroke не трогаем (их нет)
        for _, obj in pairs(mainFrame:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if settings.rgbAccent then
                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then conn:Disconnect() return end
                        obj.TextColor3 = Color3.fromHSV((tick() % 5) / 5, 0.85, 1)
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
            local col = settings.colors
            local data = {
                bgColor      = {col.bgColor.R,     col.bgColor.G,     col.bgColor.B},
                textColor    = {col.textColor.R,   col.textColor.G,   col.textColor.B},
                strokeColor  = {col.strokeColor.R, col.strokeColor.G, col.strokeColor.B},
                accentColor  = {col.accentColor.R, col.accentColor.G, col.accentColor.B},
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
                if data.rgbAccent   ~= nil then settings.rgbAccent   = data.rgbAccent    end
                if data.rgbStroke   ~= nil then settings.rgbStroke   = data.rgbStroke    end
            end
        end)
    end

    -- ═══════════ COLOR PICKER ═══════════
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
        container.Size   = UDim2.new(1, 0, 0, 340)
        container.ZIndex = 4
        container.Parent = parent

        local innerLayout = Instance.new("UIListLayout")
        innerLayout.Padding    = UDim.new(0, 6)
        innerLayout.SortOrder  = Enum.SortOrder.LayoutOrder
        innerLayout.Parent     = container

        innerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.Size = UDim2.new(1, 0, 0, innerLayout.AbsoluteContentSize.Y + 4)
        end)

        -- ── Type Selector ──
        local typeRow = Instance.new("Frame")
        typeRow.BackgroundTransparency = 1
        typeRow.Size        = UDim2.new(1, 0, 0, 28)
        typeRow.LayoutOrder = 1
        typeRow.ZIndex      = 5
        typeRow.Parent      = container

        local typeLayout = Instance.new("UIListLayout")
        typeLayout.FillDirection = Enum.FillDirection.Horizontal
        typeLayout.Padding       = UDim.new(0, 4)
        typeLayout.SortOrder     = Enum.SortOrder.LayoutOrder
        typeLayout.Parent        = typeRow

        local colorTypes = {
            {"BG",     "bgColor"},
            {"TEXT",   "textColor"},
            {"ACCENT", "accentColor"},
        }
        local typeButtons = {}

        for i, ct in ipairs(colorTypes) do
            local tb = Instance.new("TextButton")
            tb.Size                   = UDim2.new(0, 70, 1, 0)
            tb.BackgroundColor3       = i == 1 and T.Accent or T.BgPanel
            tb.BackgroundTransparency = i == 1 and 0.1 or 0.2
            tb.BorderSizePixel        = 0
            tb.Text                   = ct[1]
            tb.TextColor3             = i == 1 and T.TextMain or T.TextSub
            tb.TextSize               = 10
            tb.Font                   = Enum.Font.GothamBold
            tb.ZIndex                 = 6
            tb.Parent                 = typeRow
            tb:SetAttribute("TextRole", "main")
            Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 5)
            typeButtons[i] = tb

            tb.MouseButton1Click:Connect(function()
                selType = ct[2]
                syncFromType()
                for j, b in ipairs(typeButtons) do
                    TweenService:Create(b, TweenInfo.new(0.15), {
                        BackgroundColor3       = j == i and T.Accent or T.BgPanel,
                        BackgroundTransparency = j == i and 0.1 or 0.2,
                        TextColor3             = j == i and T.TextMain or T.TextSub,
                    }):Play()
                end
                if updatePickerUI then updatePickerUI() end
            end)
        end

        -- ── SV Square ──
        local svBase = Instance.new("ImageLabel")
        svBase.Size                   = UDim2.new(1, 0, 0, 120)
        svBase.BackgroundColor3       = Color3.fromHSV(curH, 1, 1)
        svBase.BorderSizePixel        = 0
        svBase.Image                  = "rbxassetid://4155801252"
        svBase.ImageTransparency      = 0
        svBase.LayoutOrder            = 2
        svBase.ZIndex                 = 5
        svBase.Parent                 = container
        Instance.new("UICorner", svBase).CornerRadius = UDim.new(0, 6)

        local svOverlay = Instance.new("ImageLabel")
        svOverlay.Size                = UDim2.new(1, 0, 1, 0)
        svOverlay.BackgroundTransparency = 1
        svOverlay.Image               = "rbxassetid://4155801252"
        svOverlay.ImageTransparency   = 0
        svOverlay.ZIndex              = 6
        svOverlay.Parent              = svBase

        local svCursor = Instance.new("Frame")
        svCursor.Size                 = UDim2.new(0, 10, 0, 10)
        svCursor.AnchorPoint          = Vector2.new(0.5, 0.5)
        svCursor.Position             = UDim2.new(curS, 0, 1 - curV, 0)
        svCursor.BackgroundColor3     = Color3.new(1, 1, 1)
        svCursor.BorderSizePixel      = 0
        svCursor.ZIndex               = 7
        svCursor.Parent               = svBase
        Instance.new("UICorner", svCursor).CornerRadius = UDim.new(1, 0)

        -- ── Hue Track ──
        local hueTrack = Instance.new("ImageLabel")
        hueTrack.Size                 = UDim2.new(1, 0, 0, 14)
        hueTrack.BackgroundColor3     = Color3.new(1, 1, 1)
        hueTrack.BorderSizePixel      = 0
        hueTrack.Image                = "rbxassetid://4155821570"
        hueTrack.LayoutOrder          = 3
        hueTrack.ZIndex               = 5
        hueTrack.Parent               = container
        Instance.new("UICorner", hueTrack).CornerRadius = UDim.new(0, 4)

        local hueCursor = Instance.new("Frame")
        hueCursor.Size                = UDim2.new(0, 6, 1, 4)
        hueCursor.AnchorPoint         = Vector2.new(0.5, 0.5)
        hueCursor.Position            = UDim2.new(curH, 0, 0.5, 0)
        hueCursor.BackgroundColor3    = Color3.new(1, 1, 1)
        hueCursor.BorderSizePixel     = 0
        hueCursor.ZIndex              = 6
        hueCursor.Parent              = hueTrack
        Instance.new("UICorner", hueCursor).CornerRadius = UDim.new(0, 3)

        -- ── Preview + Hex ──
        local previewRow = Instance.new("Frame")
        previewRow.BackgroundTransparency = 1
        previewRow.Size        = UDim2.new(1, 0, 0, 28)
        previewRow.LayoutOrder = 4
        previewRow.ZIndex      = 5
        previewRow.Parent      = container

        local previewSwatch = Instance.new("Frame")
        previewSwatch.Size                   = UDim2.new(0, 28, 1, 0)
        previewSwatch.BackgroundColor3       = Color3.fromHSV(curH, curS, curV)
        previewSwatch.BorderSizePixel        = 0
        previewSwatch.ZIndex                 = 6
        previewSwatch.Parent                 = previewRow
        Instance.new("UICorner", previewSwatch).CornerRadius = UDim.new(0, 5)

        local hexLabel = Instance.new("TextLabel")
        hexLabel.Text                    = "#"
        hexLabel.Position                = UDim2.new(0, 34, 0, 0)
        hexLabel.Size                    = UDim2.new(0, 16, 1, 0)
        hexLabel.BackgroundTransparency  = 1
        hexLabel.TextColor3              = T.TextSub
        hexLabel.TextSize                = 12
        hexLabel.Font                    = Enum.Font.GothamBold
        hexLabel.ZIndex                  = 6
        hexLabel.Parent                  = previewRow

        local hexBox = Instance.new("TextBox")
        hexBox.Size                   = UDim2.new(1, -56, 1, 0)
        hexBox.Position               = UDim2.new(0, 50, 0, 0)
        hexBox.BackgroundColor3       = T.BgPanel
        hexBox.BackgroundTransparency = 0.2
        hexBox.BorderSizePixel        = 0
        hexBox.Text                   = string.format("%02X%02X%02X", curR, curG, curB)
        hexBox.TextColor3             = T.TextMain
        hexBox.TextSize               = 12
        hexBox.Font                   = Enum.Font.GothamBold
        hexBox.ClearTextOnFocus       = false
        hexBox.ZIndex                 = 6
        hexBox.Parent                 = previewRow
        hexBox:SetAttribute("TextRole", "main")
        Instance.new("UICorner", hexBox).CornerRadius = UDim.new(0, 5)
        local hbPad = Instance.new("UIPadding")
        hbPad.PaddingLeft = UDim.new(0, 8)
        hbPad.Parent      = hexBox

        -- ── RGB Readout Row ──
        local readoutRow = Instance.new("Frame")
        readoutRow.BackgroundTransparency = 1
        readoutRow.Size        = UDim2.new(1, 0, 0, 18)
        readoutRow.LayoutOrder = 5
        readoutRow.ZIndex      = 5
        readoutRow.Parent      = container

        local readLayout = Instance.new("UIListLayout")
        readLayout.FillDirection = Enum.FillDirection.Horizontal
        readLayout.Padding       = UDim.new(0, 6)
        readLayout.SortOrder     = Enum.SortOrder.LayoutOrder
        readLayout.Parent        = readoutRow

        local rgbReadouts = {}
        local rgbColors   = {T.AccentGlow, Color3.fromRGB(80,200,80), Color3.fromRGB(80,140,255)}
        local rgbNames    = {"R","G","B"}
        for i = 1, 3 do
            local rl = Instance.new("TextLabel")
            rl.Size                   = UDim2.new(0, 60, 1, 0)
            rl.BackgroundColor3       = T.BgPanel
            rl.BackgroundTransparency = 0.2
            rl.BorderSizePixel        = 0
            rl.Text                   = rgbNames[i] .. ": 0"
            rl.TextColor3             = rgbColors[i]
            rl.TextSize               = 10
            rl.Font                   = Enum.Font.GothamBold
            rl.ZIndex                 = 6
            rl.Parent                 = readoutRow
            Instance.new("UICorner", rl).CornerRadius = UDim.new(0, 4)
            rgbReadouts[i] = rl
        end

        -- ── RGB Slider Tracks ──
        local rgbSlotContainer = Instance.new("Frame")
        rgbSlotContainer.BackgroundTransparency = 1
        rgbSlotContainer.Size        = UDim2.new(1, 0, 0, 60)
        rgbSlotContainer.LayoutOrder = 6
        rgbSlotContainer.ZIndex      = 5
        rgbSlotContainer.Parent      = container

        local rgbSlotLayout = Instance.new("UIListLayout")
        rgbSlotLayout.Padding    = UDim.new(0, 4)
        rgbSlotLayout.SortOrder  = Enum.SortOrder.LayoutOrder
        rgbSlotLayout.Parent     = rgbSlotContainer

        rgbSlotContainer:GetPropertyChangedSignal("AbsoluteContentSize"):Wait()

        local rgbPureCol = {
            Color3.fromRGB(255,0,0),
            Color3.fromRGB(0,255,0),
            Color3.fromRGB(0,0,255),
        }

        local rgbTracks   = {}
        local rgbCursors  = {}
        local rgbValLbls  = {}

        for i = 1, 3 do
            local slot = Instance.new("Frame")
            slot.BackgroundTransparency = 1
            slot.Size                   = UDim2.new(1, 0, 0, 16)
            slot.ZIndex                 = 5
            slot.Parent                 = rgbSlotContainer

            local track = Instance.new("ImageLabel")
            track.Size                   = UDim2.new(1, -38, 1, 0)
            track.Position               = UDim2.new(0, 0, 0, 0)
            track.BackgroundColor3       = T.BgPanel
            track.BackgroundTransparency = 0
            track.BorderSizePixel        = 0
            track.Image                  = ""
            track.ZIndex                 = 5
            track.Parent                 = slot
            Instance.new("UICorner", track).CornerRadius = UDim.new(0, 4)

            local tg = Instance.new("UIGradient", track)
            tg.Color = ColorSequence.new(Color3.new(0,0,0), rgbPureCol[i])

            local cur = Instance.new("Frame")
            cur.Size              = UDim2.new(0, 8, 1, 4)
            cur.AnchorPoint       = Vector2.new(0.5, 0.5)
            cur.Position          = UDim2.new(0, 0, 0.5, 0)
            cur.BackgroundColor3  = Color3.new(1, 1, 1)
            cur.BorderSizePixel   = 0
            cur.ZIndex            = 6
            cur.Parent            = track
            Instance.new("UICorner", cur).CornerRadius = UDim.new(0, 3)

            local valLbl = Instance.new("TextLabel")
            valLbl.Size                   = UDim2.new(0, 30, 1, 0)
            valLbl.Position               = UDim2.new(1, -30, 0, 0)
            valLbl.BackgroundTransparency = 1
            valLbl.Text                   = "0"
            valLbl.TextColor3             = T.TextMain
            valLbl.TextSize               = 10
            valLbl.Font                   = Enum.Font.GothamBold
            valLbl.TextXAlignment         = Enum.TextXAlignment.Right
            valLbl.ZIndex                 = 5
            valLbl.Parent                 = slot
            valLbl:SetAttribute("TextRole", "main")

            rgbTracks[i]  = track
            rgbCursors[i] = cur
            rgbValLbls[i] = valLbl
        end

        -- ── Apply Button ──
        local applyBtn = Instance.new("TextButton")
        applyBtn.Size                   = UDim2.new(1, 0, 0, 32)
        applyBtn.BackgroundColor3       = T.Accent
        applyBtn.BackgroundTransparency = 0.1
        applyBtn.BorderSizePixel        = 0
        applyBtn.Text                   = "APPLY  &  SAVE"
        applyBtn.TextColor3             = T.TextMain
        applyBtn.TextSize               = 12
        applyBtn.Font                   = Enum.Font.GothamBold
        applyBtn.LayoutOrder            = 7
        applyBtn.ZIndex                 = 5
        applyBtn.Parent                 = container
        applyBtn:SetAttribute("TextRole", "main")
        Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 6)

        applyBtn.MouseEnter:Connect(function()
            TweenService:Create(applyBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.AccentHov, BackgroundTransparency = 0}):Play()
        end)
        applyBtn.MouseLeave:Connect(function()
            TweenService:Create(applyBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Accent, BackgroundTransparency = 0.1}):Play()
        end)

        -- updatePickerUI — замыкание (объявляем заранее)
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
            local vals = {curR/255, curG/255, curB/255}
            local nums = {curR, curG, curB}
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
            TweenService:Create(applyBtn, TweenInfo.new(0.08), {BackgroundColor3 = T.AccentGlow, BackgroundTransparency = 0}):Play()
            task.delay(0.2, function()
                TweenService:Create(applyBtn, TweenInfo.new(0.2), {BackgroundColor3 = T.Accent, BackgroundTransparency = 0.1}):Play()
            end)
        end)

        -- ── Drag Logic ──
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

        game:GetService("UserInputService").InputChanged:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType ~= Enum.UserInputType.Touch then return end
            if draggingSV then
                local ap = svBase.AbsolutePosition; local as = svBase.AbsoluteSize
                curS = math.clamp((inp.Position.X - ap.X) / as.X, 0, 1)
                curV = 1 - math.clamp((inp.Position.Y - ap.Y) / as.Y, 0, 1)
                updatePickerUI()
            elseif draggingHue then
                local ap = hueTrack.AbsolutePosition; local as = hueTrack.AbsoluteSize
                curH = math.clamp((inp.Position.X - ap.X) / as.X, 0, 1)
                updatePickerUI()
            elseif draggingRGB > 0 then
                local i = draggingRGB
                local ap = rgbTracks[i].AbsolutePosition; local as = rgbTracks[i].AbsoluteSize
                local v = math.floor(math.clamp((inp.Position.X - ap.X) / as.X, 0, 1) * 255 + 0.5)
                if i == 1 then curR = v elseif i == 2 then curG = v else curB = v end
                curH, curS, curV = Color3.toHSV(Color3.fromRGB(curR, curG, curB))
                updatePickerUI()
            end
        end)

        game:GetService("UserInputService").InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                draggingSV, draggingHue, draggingRGB = false, false, 0
            end
        end)

        hexBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                local hex = hexBox.Text:gsub("[^%x]",""):upper()
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

    -- ═══════════ ПУБЛИЧНОЕ API ═══════════
    return {
        T                  = T,
        regA               = regA,
        updateGuiColors    = updateGuiColors,
        createColorPicker  = createColorPicker,
        saveColorSettings  = saveColorSettings,
        loadColorSettings  = loadColorSettings,
        clearRgbConnections = clearRgbConnections,
    }
end
