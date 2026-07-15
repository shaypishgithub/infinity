return function(deps)
    local gui = deps.gui
    local ThemeColors = deps.ThemeColors
    local Settings = deps.Settings
    local ApplyColors = deps.ApplyColors
    local StartRGB = deps.StartRGB
    local ClearRGB = deps.ClearRGB
    local Notify = deps.Notify
    local UserInputService = deps.UserInputService
    local StatsModule = deps.StatsModule
    local SetTab = deps.SetTab

    local MkGlassPanel, MkNeonText, MkNeonButton, CreateSectionHeader, Tw, TW, MkCorner, MkStroke = gui.MkGlassPanel, gui.MkNeonText, gui.MkNeonButton, gui.CreateSectionHeader, gui.Tw, gui.TW, gui.MkCorner, gui.MkStroke

    local function OpenColorPicker(targetKey, callback)
        local popup = Instance.new("ScreenGui"); popup.Name = "MH_ColorPicker"; popup.ResetOnSpawn = false; popup.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function() if gethui then popup.Parent = gethui() else popup.Parent = game.CoreGui end end)
        if not popup.Parent then popup.Parent = game.Players.LocalPlayer.PlayerGui end

        local backdrop = Instance.new("Frame"); backdrop.Size = UDim2.new(1,0,1,0); backdrop.BackgroundColor3 = Color3.new(0,0,0); backdrop.BackgroundTransparency = 0.5; backdrop.ZIndex = 200; backdrop.Parent = popup
        backdrop.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then popup:Destroy() end end)

        local picker = Instance.new("Frame"); picker.Size = UDim2.new(0, 280, 0, 320); picker.AnchorPoint = Vector2.new(0.5,0.5); picker.Position = UDim2.new(0.5,0,0.5,0)
        picker.BackgroundColor3 = ThemeColors.GlassDark; picker.BackgroundTransparency = 0.08; picker.BorderSizePixel = 0; picker.ZIndex = 201; picker.Parent = popup
        MkCorner(picker, 16); MkStroke(picker, 1.5, Settings.colors.accent, 0.3)

        local curColor = Settings.colors[targetKey] or Color3.new(1,1,1); local curH, curS, curV = Color3.toHSV(curColor)
        local svBase = Instance.new("Frame"); svBase.Size = UDim2.new(0, 200, 0, 200); svBase.Position = UDim2.new(0, 20, 0, 40)
        svBase.BackgroundColor3 = Color3.fromHSV(curH, 1, 1); svBase.BorderSizePixel = 0; svBase.ZIndex = 204; svBase.Parent = picker
        MkCorner(svBase, 8)
        
        local svCursor = Instance.new("Frame"); svCursor.Size = UDim2.new(0, 12, 0, 12); svCursor.AnchorPoint = Vector2.new(0.5,0.5)
        svCursor.Position = UDim2.new(curS, 0, 1-curV, 0); svCursor.BackgroundColor3 = Color3.new(1,1,1); svCursor.BorderSizePixel = 0; svCursor.ZIndex = 208; svCursor.Parent = svBase
        MkCorner(svCursor, 6); MkStroke(svCursor, 2, Color3.new(0,0,0), 0)

        local hueSlider = Instance.new("Frame"); hueSlider.Size = UDim2.new(0, 200, 0, 16); hueSlider.Position = UDim2.new(0, 20, 0, 250)
        hueSlider.BackgroundColor3 = Color3.new(1,0,0); hueSlider.BorderSizePixel = 0; hueSlider.ZIndex = 204; hueSlider.Parent = picker; MkCorner(hueSlider, 8)
        local hGrad = Instance.new("UIGradient"); hGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1))}); hGrad.Parent = hueSlider
        
        local hueCursor = Instance.new("Frame"); hueCursor.Size = UDim2.new(0, 14, 0, 20); hueCursor.AnchorPoint = Vector2.new(0.5,0.5)
        hueCursor.Position = UDim2.new(curH, 0, 0.5, 0); hueCursor.BackgroundColor3 = Color3.fromHSV(curH,1,1); hueCursor.BorderSizePixel = 0; hueCursor.ZIndex = 206; hueCursor.Parent = hueSlider
        MkCorner(hueCursor, 4); MkStroke(hueCursor, 2, Color3.new(1,1,1), 0.3)

        local previewBox = Instance.new("Frame"); previewBox.Size = UDim2.new(0, 200, 0, 24); previewBox.Position = UDim2.new(0, 20, 0, 274)
        previewBox.BackgroundColor3 = curColor; previewBox.BorderSizePixel = 0; previewBox.ZIndex = 204; previewBox.Parent = picker
        MkCorner(previewBox, 6); MkStroke(previewBox, 1, Color3.new(1,1,1), 0.5)
        local hexLabel = Instance.new("TextLabel"); hexLabel.Size = UDim2.new(1,0,1,0); hexLabel.BackgroundTransparency = 1; hexLabel.Font = Enum.Font.GothamBold
        hexLabel.TextSize = 11; hexLabel.TextColor3 = Color3.new(1,1,1); hexLabel.ZIndex = 205; hexLabel.Parent = previewBox

        local function updateColor()
            local nc = Color3.fromHSV(curH, curS, curV); previewBox.BackgroundColor3 = nc; svBase.BackgroundColor3 = Color3.fromHSV(curH,1,1)
            hueCursor.BackgroundColor3 = Color3.fromHSV(curH,1,1); hexLabel.Text = string.format("#%02X%02X%02X", math.floor(nc.R*255), math.floor(nc.G*255), math.floor(nc.B*255))
        end

        local draggingSV, draggingHueS = false, false
        svBase.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true end end)
        hueSlider.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingHueS = true end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = false; draggingHueS = false end end)
        
        local conns = {}
        table.insert(conns, UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
            if draggingSV then
                curS = math.clamp((input.Position.X - svBase.AbsolutePosition.X) / svBase.AbsoluteSize.X, 0, 1)
                curV = 1 - math.clamp((input.Position.Y - svBase.AbsolutePosition.Y) / svBase.AbsoluteSize.Y, 0, 1)
                svCursor.Position = UDim2.new(curS, 0, 1-curV, 0); updateColor()
            elseif draggingHueS then
                curH = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
                hueCursor.Position = UDim2.new(curH, 0, 0.5, 0); updateColor()
            end
        end))

        local applyBtn = Instance.new("TextButton"); applyBtn.Size = UDim2.new(1,-40,0,30); applyBtn.Position = UDim2.new(0,20,1,-38)
        applyBtn.BackgroundColor3 = Settings.colors.accent; applyBtn.BackgroundTransparency = 0.25; applyBtn.BorderSizePixel = 0
        applyBtn.Text = "Apply"; applyBtn.Font = Enum.Font.GothamBold; applyBtn.TextSize = 12; applyBtn.TextColor3 = Color3.new(1,1,1); applyBtn.ZIndex = 204; applyBtn.Parent = picker
        MkCorner(applyBtn, 8)
        applyBtn.MouseButton1Click:Connect(function()
            callback(Color3.fromHSV(curH, curS, curV)); popup:Destroy()
            for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        end)
        picker.Size = UDim2.new(0,0,0,0); Tw(picker, {Size = UDim2.new(0,280,0,320)}, TW.Spring):Play()
    end

    return function(ScriptScroll)
        CreateSectionHeader("Appearance", ScriptScroll)
        
        local rgbCard = MkGlassPanel(ScriptScroll, UDim2.new(1, 0, 0, 50), nil, 4, 10, 0.15)
        MkNeonText(rgbCard, "🌈 RGB Mode", UDim2.new(0.6, 0, 0, 22), UDim2.new(0, 14, 0.5, -11), 14, ThemeColors.TextBright, 6)
        local rgbToggle = Instance.new("TextButton"); rgbToggle.Size = UDim2.new(0, 44, 0, 24); rgbToggle.Position = UDim2.new(1, -58, 0.5, -12)
        rgbToggle.BackgroundColor3 = Settings.rgbMode and ThemeColors.Success or ThemeColors.GlassLight; rgbToggle.BackgroundTransparency = 0.3
        rgbToggle.Text = Settings.rgbMode and "ON" or "OFF"; rgbToggle.Font = Enum.Font.GothamBold; rgbToggle.TextSize = 11
        rgbToggle.TextColor3 = Color3.new(1,1,1); rgbToggle.ZIndex = 8; rgbToggle.Parent = rgbCard; MkCorner(rgb
