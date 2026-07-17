═══════════════════════════════════════════════════════════════
--  notifications.lua — Neon Glass Notification System v3
═══════════════════════════════════════════════════════════════

return function(deps)
    local TweenService = deps.TweenService
    local CoreGui      = deps.CoreGui
    local T            = deps.T

    local notifGui = Instance.new("ScreenGui")
    notifGui.Name         = "MH_Notifications"
    notifGui.ResetOnSpawn = false
    notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    pcall(function()
        if get_hidden_gui then notifGui.Parent = get_hidden_gui()
        elseif gethui then notifGui.Parent = gethui()
        else notifGui.Parent = CoreGui end
    end)
    if not notifGui.Parent then notifGui.Parent = CoreGui end

    local notifContainer = Instance.new("Frame")
    notifContainer.Size                   = UDim2.new(0, 260, 1, 0)
    notifContainer.Position               = UDim2.new(1, -270, 0, 0)
    notifContainer.BackgroundTransparency = 1
    notifContainer.Parent                 = notifGui

    local notifLayout = Instance.new("UIListLayout")
    notifLayout.Padding       = UDim.new(0, 8)
    notifLayout.SortOrder     = Enum.SortOrder.LayoutOrder
    notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    notifLayout.Parent        = notifContainer

    local notifPad = Instance.new("UIPadding")
    notifPad.PaddingTop    = UDim.new(0, 16)
    notifPad.PaddingRight  = UDim.new(0, 0)
    notifPad.Parent        = notifContainer

    local function createNotification(title, subtitle, duration, iconId)
        duration = duration or 3

        local holder = Instance.new("Frame")
        holder.Size                   = UDim2.new(1, 0, 0, 72)
        holder.BackgroundTransparency = 1
        holder.ZIndex                 = 50
        holder.Parent                 = notifContainer

        -- Background card
        local bg = Instance.new("Frame")
        bg.Size                   = UDim2.new(1, 0, 0, 72)
        bg.BackgroundColor3       = T.BgCard
        bg.BackgroundTransparency = 1
        bg.BorderSizePixel        = 0
        bg.ZIndex                 = 51
        bg.Parent                 = holder
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)

        -- 3D Shadow
        local shadow = Instance.new("Frame")
        shadow.Size                   = UDim2.new(1, 0, 0, 72)
        shadow.Position               = UDim2.new(0, 3, 0, 3)
        shadow.BackgroundColor3       = Color3.fromRGB(0, 0, 8)
        shadow.BackgroundTransparency = 1
        shadow.BorderSizePixel        = 0
        shadow.ZIndex                 = 49
        shadow.Parent                 = holder
        Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 12)

        -- Neon border stroke
        local stroke = Instance.new("UIStroke")
        stroke.Thickness       = 1
        stroke.Color           = T.Accent
        stroke.Transparency    = 1
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent          = bg

        -- Left accent bar (neon)
        local bar = Instance.new("Frame")
        bar.Size                   = UDim2.new(0, 3, 1, -18)
        bar.Position               = UDim2.new(0, 10, 0, 9)
        bar.BackgroundColor3       = T.Accent
        bar.BackgroundTransparency = 1
        bar.BorderSizePixel        = 0
        bar.ZIndex                 = 54
        bar.Parent                 = bg
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)

        -- Icon
        local icon = Instance.new("ImageLabel")
        icon.Size                   = UDim2.new(0, 28, 0, 28)
        icon.Position               = UDim2.new(0, 20, 0.5, -14)
        icon.BackgroundTransparency = 1
        icon.Image                  = "rbxassetid://" .. tostring(iconId or 74283928898866)
        icon.ImageTransparency      = 1
        icon.ZIndex                 = 55
        icon.Parent                 = bg

        -- Title
        local mainTxt = Instance.new("TextLabel")
        mainTxt.BackgroundTransparency = 1
        mainTxt.Text              = title or "NOTIFICATION"
        mainTxt.Font              = Enum.Font.GothamBold
        mainTxt.TextColor3        = T.TextMain
        mainTxt.TextSize          = 13
        mainTxt.TextXAlignment    = Enum.TextXAlignment.Left
        mainTxt.Size              = UDim2.new(1, -64, 0, 18)
        mainTxt.Position          = UDim2.new(0, 56, 0, 14)
        mainTxt.TextTransparency  = 1
        mainTxt.ZIndex            = 55
        mainTxt.Parent            = bg

        -- Subtitle
        local subTxt = Instance.new("TextLabel")
        subTxt.BackgroundTransparency = 1
        subTxt.Text               = subtitle or ""
        subTxt.Font               = Enum.Font.Gotham
        subTxt.TextColor3         = T.TextSub
        subTxt.TextSize           = 11
        subTxt.TextXAlignment     = Enum.TextXAlignment.Left
        subTxt.Size               = UDim2.new(1, -64, 0, 14)
        subTxt.Position           = UDim2.new(0, 56, 0, 34)
        subTxt.TextTransparency   = 1
        subTxt.ZIndex             = 55
        subTxt.Parent             = bg

        -- Glass sheen
        local sheen = Instance.new("Frame")
        sheen.Size                   = UDim2.new(1, 0, 0.5, 0)
        sheen.BackgroundColor3       = Color3.new(1, 1, 1)
        sheen.BackgroundTransparency = 1
        sheen.BorderSizePixel        = 0
        sheen.ClipsDescendants       = true
        sheen.ZIndex                 = 56
        sheen.Parent                 = bg
        Instance.new("UICorner", sheen).CornerRadius = UDim.new(0, 12)
        local sheenGrad = Instance.new("UIGradient")
        sheenGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(0.5, 0.7),
            NumberSequenceKeypoint.new(1, 1.0),
        })
        sheenGrad.Rotation = 90
        sheenGrad.Parent = sheen

        -- ═══ ANIMATE IN ═══
        holder.Position = UDim2.new(0, 280, 0, 0)

        TweenService:Create(holder, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()

        task.delay(0.05, function()
            TweenService:Create(bg, TweenInfo.new(0.3), {BackgroundTransparency = 0.15}):Play()
            TweenService:Create(shadow, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 0.5}):Play()
            TweenService:Create(bar, TweenInfo.new(0.3), {BackgroundTransparency = 0.25}):Play()
            TweenService:Create(icon, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
            TweenService:Create(mainTxt, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
            TweenService:Create(subTxt, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
            TweenService:Create(sheen, TweenInfo.new(0.3), {BackgroundTransparency = 0.93}):Play()
        end)

        -- ═══ AUTO DISMISS ═══
        task.delay(duration, function()
            if not holder.Parent then return end
            TweenService:Create(holder, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0, 280, 0, 0)
            }):Play()
            task.delay(0.4, function()
                pcall(function() holder:Destroy() end)
            end)
        end)

        return holder
    end

    return {
        createNotification = createNotification,
        notifGui           = notifGui,
    }
end
