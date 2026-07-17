═══════════════════════════════════════════════════════════════
--  colorpicker.lua — Neon Glass Color Picker v3
--  FULLY COMPLETE - no truncation
═══════════════════════════════════════════════════════════════

return function(deps)
    local TweenService       = deps.TweenService
    local UserInputService   = deps.UserInputService
    local RunService         = deps.RunService
    local T                  = deps.T
    local gui                = deps.gui
    local settings           = deps.settings
    local updateGuiColors    = deps.updateGuiColors
    local saveColorSettings  = deps.saveColorSettings
    local createNotification = deps.createNotification or function() end

    local mkCorner = gui.mkCorner
    local mkStroke = gui.mkStroke
    local mk3DShadow = gui.mk3DShadow
    local mkGlassSheen = gui.mkGlassSheen

    local function createColorPicker(parent, colorPickerConnections)
        local selType          = "bgColor"
        local curH, curS, curV = Color3.toHSV(settings.colors.bgColor)
        local curR = math.floor(settings.colors.bgColor.R * 255 + 0.5)
        local curG = math.floor(settings.colors.bgColor.G * 255 + 0.5)
        local curB = math.floor(settings.colors.bgColor.B * 255 + 0.5)

        local function syncFromType()
            local col        = settings.colors[selType]
            curH, curS, curV = Color3.toHSV(col)
            curR = math.floor(col.R * 255 + 0.5)
            curG = math.floor(col.G * 255 + 0.5)
            curB = math.floor(col.B * 255 + 0.5)
        end

        local container = Instance.new("Frame")
        container.BackgroundTransparency = 1
        container.Size   = UDim2.new(1, 0, 0, 350)
        container.ZIndex = 4
        container.Parent = parent

        local innerLayout = Instance.new("UIListLayout")
        innerLayout.Padding   = UDim.new(0, 6)
        innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        innerLayout.Parent    = container

        innerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.Size = UDim2.new(1, 0, 0, innerLayout.AbsoluteContentSize.Y + 4)
        end)

        -- ═══ TYPE SELECTOR ═══
        local typeRow = Instance.new("Frame")
        typeRow.BackgroundTransparency = 1
        typeRow.Size        = UDim2.new(1, 0, 0, 30)
        typeRow.LayoutOrder = 1
        typeRow.ZIndex      = 4
        typeRow.Parent      = container

        local typeRowLayout = Instance.new("UIListLayout")
        typeRowLayout.FillDirection = Enum.FillDirection.Horizontal
        typeRowLayout.Padding       = UDim.new(0, 4)
        typeRowLayout.SortOrder     = Enum.SortOrder.LayoutOrder
        typeRowLayout.Parent        = typeRow

        local typeBtnMap  = {}
        local typeItems   = {
            { label = "BG",     key = "bgColor" },
            { label = "Text",   key = "textColor" },
            { label = "Stroke", key = "strokeColor" },
            { label = "Accent", key = "accentColor" },
        }

        local updatePickerUI -- forward declared

        local function refreshTypeBtns(activeKey)
            for _, td in ipairs(typeItems) do
                local b = typeBtnMap[td.key]
                if b then
                    if td.key == activeKey then
                        b.BackgroundColor3 = T.Accent
                        b.BackgroundTransparency = 0.2
                        b.TextColor3 = Color3.new(1, 1, 1)
                    else
                        b.BackgroundColor3 = T.BgBtn
                        b.BackgroundTransparency = 0.25
                        b.TextColor3 = T.TextSub
                    end
                end
            end
        end

        for i, td in ipairs(typeItems) do
            local btn = Instance.new("TextButton")
            btn.Size                   = UDim2.new(1/4, -3, 1, 0)
            btn.BackgroundColor3       = T.BgBtn
            btn.BackgroundTransparency = 0.25
            btn.BorderSizePixel        = 0
            btn.Text                   = td.label
            btn.TextColor3             = T.TextSub
            btn.TextSize               = 11
            btn.Font                   = Enum.Font.GothamBold
            btn.LayoutOrder            = i
            btn.ZIndex                 = 5
            btn.Parent                 = typeRow
            mkCorner(btn, 6)
            mkStroke(btn, 1, T.StrokeBrt, 0.5)
            typeBtnMap[td.key] = btn

            btn.MouseButton1Click:Connect(function()
                selType = td.key
                syncFromType()
                refreshTypeBtns(selType)
                if updatePickerUI then updatePickerUI() end
            end)
        end
        refreshTypeBtns(selType)

        -- ═══ SV SQUARE + RIGHT PANEL ═══
        local sqSz = 150
        local mainArea = Instance.new("Frame")
        mainArea.BackgroundTransparency = 1
        mainArea.Size        = UDim2.new(1, 0, 0, sqSz)
        mainArea.LayoutOrder = 2
        mainArea.ZIndex      = 4
        mainArea.Parent      = container

        -- SV Base
        local svBase = Instance.new("Frame")
        svBase.Size             = UDim2.new(0, sqSz, 0, sqSz)
        svBase.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
        svBase.BorderSizePixel  = 0
        svBase.ZIndex           = 5
        svBase.Parent           = mainArea
        mkCorner(svBase, 8)
        mkStroke(svBase, 1, T.StrokeBrt, 0.4)
        mk3DShadow(svBase, 3, 3, 0, 0.5)

        -- White gradient overlay
        local whiteOv = Instance.new("Frame")
        whiteOv.Size                   = UDim2.new(1, 0, 1, 0)
        whiteOv.BackgroundColor3       = Color3.new(1, 1, 1)
        whiteOv.BorderSizePixel        = 0
        whiteOv.ZIndex                 = 6
        whiteOv.Parent                 = svBase
        mkCorner(whiteOv, 8)
        local wg = Instance.new("UIGradient")
        wg.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1))
        wg.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        wg.Parent = whiteOv

        -- Black gradient overlay
        local blackOv = Instance.new("Frame")
        blackOv.Size                   = UDim2.new(1, 0, 1, 0)
        blackOv.BackgroundColor3       = Color3.new(0, 0, 0)
        blackOv.BorderSizePixel        = 0
        blackOv.ZIndex                 = 7
        blackOv.Parent                 = svBase
        mkCorner(blackOv, 8)
        local bg2 = Instance.new("UIGradient")
        bg2.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0))
        bg2.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        })
        bg2.Rotation = 90
        bg2.Parent = blackOv

        -- SV Cursor
        local svCursor = Instance.new("Frame")
        svCursor.Size             = UDim2.new(0, 12, 0, 12)
        svCursor.AnchorPoint      = Vector2.new(0.5, 0.5)
        svCursor.Position         = UDim2.new(curS, 0, 1 - curV, 0)
        svCursor.BackgroundColor3 = Color3.new(1, 1, 1)
        svCursor.BorderSizePixel  = 0
        svCursor.ZIndex           = 9
        svCursor.Parent           = svBase
        mkCorner(svCursor, 6)
        mkStroke(svCursor, 2, Color3.new(0, 0, 0), 0)

        -- ═══ RIGHT PANEL ═══
        local rightPanel = Instance.new("Frame")
        rightPanel.BackgroundTransparency = 1
        rightPanel.Size     = UDim2.new(1, -(sqSz + 10), 1, 0)
        rightPanel.Position = UDim2.new(0, sqSz + 10, 0, 0)
        rightPanel.ZIndex   = 4
        rightPanel.Parent   = mainArea

        -- Preview swatch with 3D
        local previewSwatch = Instance.new("Frame")
        previewSwatch.Size                   = UDim2.new(1, 0, 0, 54)
        previewSwatch.BackgroundColor3       = settings.colors[selType]
        previewSwatch.BackgroundTransparency = 0
        previewSwatch.BorderSizePixel        = 0
        previewSwatch.ZIndex                 = 5
        previewSwatch.Parent                 = rightPanel
        mkCorner(previewSwatch, 8)
        mkStroke(previewSwatch, 1, T.StrokeBrt, 0.4)
        mk3DShadow(previewSwatch, 2, 2, 0, 0.5)
        mkGlassSheen(previewSwatch, 7)

        local previewLbl = Instance.new("TextLabel")
        previewLbl.BackgroundTransparency = 1
        previewLbl.Text              = "PREVIEW"
        previewLbl.Font              = Enum.Font.GothamBold
        previewLbl.TextSize          = 9
        previewLbl.TextColor3        = Color3.new(1, 1, 1)
        previewLbl.TextTransparency  = 0.4
        previewLbl.Size              = UDim2.new(1, 0, 1, 0)
        previewLbl.ZIndex            = 8
        previewLbl.Parent            = previewSwatch

        -- Hex row
        local hexRow = Instance.new("Frame")
        hexRow.Size                   = UDim2.new(1, 0, 0, 28)
        hexRow.Position               = UDim2.new(0, 0, 0, 60)
        hexRow.BackgroundColor3       = T.BgCard
        hexRow.BackgroundTransparency = 0.2
        hexRow.BorderSizePixel        = 0
        hexRow.ZIndex                 = 5
        hexRow.Parent                 = rightPanel
        mkCorner(hexRow, 6)
        mkStroke(hexRow, 1, T.StrokeBrt, 0.5)

        local hashLbl = Instance.new("TextLabel")
        hashLbl.Size                  = UDim2.new(0, 18, 1, 0)
        hashLbl.Position              = UDim2.new(0, 4, 0, 0)
        hashLbl.BackgroundTransparency = 1
        hashLbl.Text                  = "#"
        hashLbl.TextColor3            = T.Accent
        hashLbl.TextSize              = 12
        hashLbl.Font                  = Enum.Font.GothamBold
        hashLbl.ZIndex                = 6
        hashLbl.Parent                = hexRow

        local hexBox = Instance.new("TextBox")
        hexBox.Size                   = UDim2.new(1, -24, 1, 0)
        hexBox.Position               = UDim2.new(0, 22, 0, 0)
        hexBox.BackgroundTransparency = 1
        hexBox.TextColor3             = T.TextMain
        hexBox.TextSize               = 12
        hexBox.Font                   = Enum.Font.Code
        hexBox.PlaceholderText        = "RRGGBB"
        hexBox.PlaceholderColor3      = T.TextMuted
        hexBox.Text                   = ""
        hexBox.ClearTextOnFocus       = false
        hexBox.ZIndex                 = 6
        hexBox.Parent                 = hexRow
        hexBox:SetAttribute("TextRole", "main")

        -- RGB readouts
        local rgbReadouts  = {}
        local channelNames = { "R", "G", "B" }
        for i, nm in ipairs(channelNames) do
            local lbl = Instance.new("TextLabel")
            lbl.Size                   = UDim2.new(1, 0, 0, 16)
            lbl.Position               = UDim2.new(0, 0, 0, 94 + (i - 1) * 18)
            lbl.BackgroundTransparency = 1
            lbl.Text                   = nm .. ": 0"
            lbl.TextColor3             = T.TextSub
            lbl.TextSize               = 11
            lbl.Font                   = Enum.Font.GothamBold
            lbl.TextXAlignment         = Enum.TextXAlignment.Left
            lbl.ZIndex                 = 5
            lbl.Parent                 = rightPanel
            rgbReadouts[i] = lbl
        end

        -- ═══ HUE SLIDER ═══
        local hueTrack = Instance.new("Frame")
        hueTrack.Size             = UDim2.new(1, 0, 0, 18)
        hueTrack.BackgroundColor3 = Color3.new(1, 0, 0)
        hueTrack.BorderSizePixel  = 0
        hueTrack.LayoutOrder      = 3
        hueTrack.ZIndex           = 5
        hueTrack.Parent           = container
        mkCorner(hueTrack, 9)
        mkStroke(hueTrack, 1, T.StrokeBrt, 0.4)
        mk3DShadow(hueTrack, 2, 2, 0, 0.5)

        -- Hue gradient
        local hueGrad = Instance.new("UIGradient")
        hueGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,    Color3.fromHSV(0, 1, 1)),
            ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
            ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
            ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5, 1, 1)),
            ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
            ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
            ColorSequenceKeypoint.new(1,    Color3.fromHSV(1, 1, 1)),
        })
        hueGrad.Parent = hueTrack

        -- Hue cursor
        local hueCursor = Instance.new("Frame")
        hueCursor.Size             = UDim2.new(0, 8, 0, 22)
        hueCursor.AnchorPoint      = Vector2.new(0.5, 0.5)
        hueCursor.Position         = UDim2.new(curH, 0, 0.5, 0)
        hueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
        hueCursor.BorderSizePixel  = 0
        hueCursor.ZIndex           = 8
        hueCursor.Parent           = hueTrack
        mkCorner(hueCursor, 4)
        mkStroke(hueCursor, 2, Color3.new(0, 0, 0), 0)

        -- ═══ RGB SLIDERS ═══
        local sliderData = {
            { label = "R", value = curR, max = 255, color = Color3.fromRGB(255, 80, 80) },
            { label = "G", value = curG, max = 255, color = Color3.fromRGB(80, 255, 80) },
            { label = "B", value = curB, max = 255, color = Color3.fromRGB(80, 80, 255) },
        }

        local rgbSliders = {}
        for i, sd in ipairs(sliderData) do
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size                   = UDim2.new(1, 0, 0, 28)
            sliderFrame.BackgroundTransparency = 1
            sliderFrame.LayoutOrder            = 4 + i
            sliderFrame.ZIndex                 = 4
            sliderFrame.Parent                 = container

            local sLabel = Instance.new("TextLabel")
            sLabel.Size                   = UDim2.new(0, 18, 1, 0)
            sLabel.BackgroundTransparency = 1
            sLabel.Text                   = sd.label
            sLabel.TextColor3             = sd.color
            sLabel.TextSize               = 12
            sLabel.Font                   = Enum.Font.GothamBold
            sLabel.ZIndex                 = 5
            sLabel.Parent                 = sliderFrame

            local track = Instance.new("Frame")
            track.Size                   = UDim2.new(1, -26, 0, 14)
            track.Position               = UDim2.new(0, 22, 0.5, -7)
            track.BackgroundColor3       = T.BgDeep
            track.BackgroundTransparency = 0.2
            track.BorderSizePixel        = 0
            track.ZIndex                 = 5
            track.Parent                 = sliderFrame
            mkCorner(track, 7)
            mkStroke(track, 1, T.StrokeBrt, 0.6)

            local fill = Instance.new("Frame")
            fill.Size                   = UDim2.new(sd.value / sd.max, 0, 1, 0)
            fill.BackgroundColor3       = sd.color
            fill.BackgroundTransparency = 0.2
            fill.BorderSizePixel        = 0
            fill.ZIndex                 = 6
            fill.Parent                 = track
            mkCorner(fill, 7)

            local cursor = Instance.new("Frame")
            cursor.Size             = UDim2.new(0, 10, 0, 18)
            cursor.AnchorPoint      = Vector2.new(0.5, 0.5)
            cursor.Position         = UDim2.new(sd.value / sd.max, 0, 0.5, 0)
            cursor.BackgroundColor3 = Color3.new(1, 1, 1)
            cursor.BorderSizePixel  = 0
            cursor.ZIndex           = 8
            cursor.Parent           = track
            mkCorner(cursor, 5)
            mkStroke(cursor, 1, sd.color, 0.3)

            rgbSliders[i] = {
                frame = sliderFrame,
                track = track,
                fill  = fill,
                cursor = cursor,
                data  = sd,
            }
        end

        -- ═══ APPLY BUTTON ═══
        local applyBtn = Instance.new("TextButton")
        applyBtn.Size                   = UDim2.new(1, 0, 0, 34)
        applyBtn.BackgroundColor3       = T.Accent
        applyBtn.BackgroundTransparency = 0.25
        applyBtn.BorderSizePixel        = 0
        applyBtn.Text                   = "✦  APPLY COLORS"
        applyBtn.TextColor3             = Color3.new(1, 1, 1)
        applyBtn.Font                   = Enum.Font.GothamBold
        applyBtn.TextSize               = 12
        applyBtn.LayoutOrder            = 8
        applyBtn.ZIndex                 = 5
        applyBtn.Parent                 = container
        mkCorner(applyBtn, 8)
        mkStroke(applyBtn, 1, T.AccentGlow, 0.4)
        mk3DShadow(applyBtn, 2, 2, 0, 0.4)

        applyBtn.MouseEnter:Connect(function()
            applyBtn.BackgroundTransparency = 0.1
        end)
        applyBtn.MouseLeave:Connect(function()
            applyBtn.BackgroundTransparency = 0.25
        end)

        applyBtn.MouseButton1Click:Connect(function()
            settings.colors[selType] = Color3.fromRGB(curR, curG, curB)
            updateGuiColors(settings)
            saveColorSettings(settings)
            createNotification("COLORS", "Applied " .. selType .. " change!", 2.5)
        end)

        -- ═══ UPDATE PICKER UI ═══
        function updatePickerUI()
            local col = Color3.fromRGB(curR, curG, curB)
            previewSwatch.BackgroundColor3 = col
            svBase.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
            svCursor.Position = UDim2.new(curS, 0, 1 - curV, 0)
            hueCursor.Position = UDim2.new(curH, 0, 0.5, 0)

            local hexStr = string.format("%02X%02X%02X", curR, curG, curB)
            if hexBox:IsFocused() == false then
                hexBox.Text = hexStr
            end

            rgbReadouts[1].Text = "R: " .. curR
            rgbReadouts[2].Text = "G: " .. curG
            rgbReadouts[3].Text = "B: " .. curB

            -- Update RGB sliders
            local vals = { curR, curG, curB }
            for i, slider in ipairs(rgbSliders) do
                local v = vals[i]
                slider.fill.Size  = UDim2.new(v / 255, 0, 1, 0)
                slider.cursor.Position = UDim2.new(v / 255, 0, 0.5, 0)
            end
        end

        -- ═══ SV DRAGGING ═══
        local svDragging = false
        svBase.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                svDragging = true
            end
        end)

        local function updateSV(input)
            if not svDragging then return end
            local relX = math.clamp((input.Position.X - svBase.AbsolutePosition.X) / svBase.AbsoluteSize.X, 0, 1)
            local relY = math.clamp((input.Position.Y - svBase.AbsolutePosition.Y) / svBase.AbsoluteSize.Y, 0, 1)
            curS = relX
            curV = 1 - relY
            local col = Color3.fromHSV(curH, curS, curV)
            curR = math.floor(col.R * 255 + 0.5)
            curG = math.floor(col.G * 255 + 0.5)
            curB = math.floor(col.B * 255 + 0.5)
            updatePickerUI()
        end

        svBase.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                updateSV(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSV(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                svDragging = false
            end
        end)

        -- ═══ HUE DRAGGING ═══
        local hueDragging = false
        hueTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                hueDragging = true
            end
        end)

        local function updateHue(input)
            if not hueDragging then return end
            local relX = math.clamp((input.Position.X - hueTrack.AbsolutePosition.X) / hueTrack.AbsoluteSize.X, 0, 1)
            curH = relX
            svBase.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
            local col = Color3.fromHSV(curH, curS, curV)
            curR = math.floor(col.R * 255 + 0.5)
            curG = math.floor(col.G * 255 + 0.5)
            curB = math.floor(col.B * 255 + 0.5)
            updatePickerUI()
        end

        hueTrack.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                updateHue(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                updateHue(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                hueDragging = false
            end
        end)

        -- ═══ RGB SLIDER DRAGGING ═══
        for i, slider in ipairs(rgbSliders) do
            local dragging = false
            slider.track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)

            local function updateSlider(input)
                if not dragging then return end
                local relX = math.clamp((input.Position.X - slider.track.AbsolutePosition.X) / slider.track.AbsoluteSize.X, 0, 1)
                local val = math.floor(relX * 255 + 0.5)
                if i == 1 then curR = val
                elseif i == 2 then curG = val
                else curB = val end
                curH, curS, curV = Color3.toHSV(Color3.fromRGB(curR, curG, curB))
                updatePickerUI()
            end

            slider.track.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    updateSlider(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        end

        -- ═══ HEX INPUT ═══
        hexBox.FocusLost:Connect(function()
            local txt = hexBox.Text:gsub("#", ""):gsub(" ", "")
            if #txt == 6 then
                local ok, r = pcall(tonumber, txt:sub(1, 2), 16)
                local _, g = pcall(tonumber, txt:sub(3, 4), 16)
                local _, b = pcall(tonumber, txt:sub(5, 6), 16)
                if ok and r and g and b then
                    curR, curG, curB = r, g, b
                    curH, curS, curV = Color3.toHSV(Color3.fromRGB(r, g, b))
                    updatePickerUI()
                end
            end
        end)

        -- Initial update
        updatePickerUI()

        return container
    end

    return {
        createColorPicker = createColorPicker,
    }
end
