return function(deps)
    local T = deps.T
    local ThemeColors = deps.ThemeColors
    local TweenService = deps.TweenService
    local CoreGui = deps.CoreGui
    local playerGui = deps.playerGui
    local gui = deps.gui
    local Tw, MkCorner, MkStroke, MkNeonGlow = gui.Tw, gui.MkCorner, gui.MkStroke, gui.MkNeonGlow

    local NotifStack = 0
    local TW = gui.TW

    return function(title, subtitle, duration, notifType)
        duration = duration or 3; notifType = notifType or "info"
        local notifGui = Instance.new("ScreenGui")
        notifGui.Name = "MH_Notify_" .. tick(); notifGui.ResetOnSpawn = false
        notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function() if gethui then notifGui.Parent = gethui() else notifGui.Parent = CoreGui end end)
        if not notifGui.Parent then notifGui.Parent = playerGui end

        local typeColors = { info = ThemeColors.NeonPrimary, success = ThemeColors.Success, warning = ThemeColors.Warning, error = ThemeColors.Error }
        local typeColor = typeColors[notifType] or ThemeColors.NeonPrimary
        local W, H = 280, 72
        local startY = 20 + (NotifStack * (H + 8)); NotifStack = NotifStack + 1

        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(0, W, 0, H); holder.Position = UDim2.new(1, -(W + 16), 0, startY)
        holder.BackgroundTransparency = 1; holder.ZIndex = 100; holder.Parent = notifGui

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = ThemeColors.GlassDark
        bg.BackgroundTransparency = 0.08; bg.BorderSizePixel = 0; bg.ZIndex = 101; bg.Parent = holder
        MkCorner(bg, 12); MkStroke(bg, 1.5, typeColor, 0.3); MkNeonGlow(bg, typeColor, 10).ZIndex = 100

        local bar = Instance.new("Frame"); bar.Size = UDim2.new(0, 3, 1, -16); bar.Position = UDim2.new(0, 8, 0, 8)
        bar.BackgroundColor3 = typeColor; bar.BorderSizePixel = 0; bar.ZIndex = 103; bar.Parent = bg; MkCorner(bar, 3)

        local titleLbl = Instance.new("TextLabel"); titleLbl.Size = UDim2.new(1, -60, 0, 20); titleLbl.Position = UDim2.new(0, 22, 0, 12)
        titleLbl.BackgroundTransparency = 1; titleLbl.Text = title; titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 13; titleLbl.TextColor3 = ThemeColors.TextBright; titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.ZIndex = 104; titleLbl.Parent = bg

        local subLbl = Instance.new("TextLabel"); subLbl.Size = UDim2.new(1, -60, 0, 14); subLbl.Position = UDim2.new(0, 22, 0, 34)
        subLbl.BackgroundTransparency = 1; subLbl.Text = subtitle or ""; subLbl.Font = Enum.Font.Gotham
        subLbl.TextSize = 11; subLbl.TextColor3 = ThemeColors.TextDim; subLbl.TextXAlignment = Enum.TextXAlignment.Left
        subLbl.ZIndex = 104; subLbl.Parent = bg

        local progTrack = Instance.new("Frame"); progTrack.Size = UDim2.new(1, -16, 0, 2); progTrack.Position = UDim2.new(0, 8, 1, -6)
        progTrack.BackgroundColor3 = ThemeColors.GlassLight; progTrack.BackgroundTransparency = 0.5
        progTrack.BorderSizePixel = 0; progTrack.ZIndex = 103; progTrack.Parent = bg; MkCorner(progTrack, 1)

        local progFill = Instance.new("Frame"); progFill.Size = UDim2.new(1, 0, 1, 0)
        progFill.BackgroundColor3 = typeColor; progFill.BackgroundTransparency = 0.3
        progFill.BorderSizePixel = 0; progFill.ZIndex = 104; progFill.Parent = progTrack; MkCorner(progFill, 1)

        holder.Position = UDim2.new(1, 20, 0, startY)
        Tw(holder, {Position = UDim2.new(1, -(W + 16), 0, startY)}, TW.Spring):Play()

        task.spawn(function()
            local start = tick()
            while holder.Parent and (tick() - start) < duration do
                progFill.Size = UDim2.new(1 - ((tick() - start) / duration), 0, 1, 0)
                task.wait(0.05)
            end
            if holder.Parent then
                Tw(holder, {Position = UDim2.new(1, 20, 0, startY)}, TW.Fast):Play()
                task.delay(0.2, function() NotifStack = math.max(0, NotifStack - 1); notifGui:Destroy() end)
            end
        end)
    end
end
