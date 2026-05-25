return function(deps)
    local RunService = deps.RunService
    local Players = deps.Players
    local T = deps.T
    local gui = deps.gui
    local player = deps.player
    local platformName = deps.platformName
    local createSectionHeader = gui.createSectionHeader
    local mkCorner = gui.mkCorner
    local mkStroke = gui.mkStroke

    local function mkFrame(parent, size, pos, bg, bgt, zidx)
        local f = Instance.new("Frame")
        f.Size = size or UDim2.new(1,0,0,40)
        f.Position = pos or UDim2.new(0,0,0,0)
        f.BackgroundColor3 = bg or T.BgPanel
        f.BackgroundTransparency = bgt or 0.15
        f.BorderSizePixel = 0
        f.ZIndex = zidx or 4
        f.Parent = parent
        return f
    end

    local function mkLabel(parent, text, size, pos, color, align, font, textSize, zidx)
        local l = Instance.new("TextLabel")
        l.Text = text or ""
        l.Size = size or UDim2.new(1,0,1,0)
        l.Position = pos or UDim2.new(0,0,0,0)
        l.TextColor3 = color or T.TextMain
        l.TextXAlignment = align or Enum.TextXAlignment.Left
        l.Font = font or Enum.Font.Gotham
        l.TextSize = textSize or 12
        l.BackgroundTransparency = 1
        l.ZIndex = zidx or 5
        l.Parent = parent
        return l
    end

    local function mkGlass(parent, size, pos, zidx, alpha, radius)
        local f = mkFrame(parent, size, pos, T.BgPanel, alpha or 0.72, zidx or 4)
        mkCorner(f, radius or 12)
        mkStroke(f, 1, Color3.new(1,1,1), 0.78)
        return f
    end

    local function mkGradientBar(parent, zidx)
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1,0,0,2)
        bar.Position = UDim2.new(0,0,0,0)
        bar.BackgroundColor3 = T.Accent or Color3.fromRGB(120,80,255)
        bar.BackgroundTransparency = 0
        bar.BorderSizePixel = 0
        bar.ZIndex = (zidx or 5) + 1
        bar.Parent = parent
        mkCorner(bar, 2)
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, T.Accent), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80,180,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(180,80,255))})
        g.Parent = bar
        return bar
    end

    local function mkButton(parent, text, size, pos, accent, callback, zidx)
        local btn = Instance.new("TextButton")
        btn.Size = size or UDim2.new(0,110,0,28)
        btn.Position = pos or UDim2.new(0,0,0,0)
        btn.BackgroundColor3 = accent or T.Accent
        btn.BackgroundTransparency = 0.35
        btn.BorderSizePixel = 0
        btn.Text = text or "Button"
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.ZIndex = zidx or 6
        btn.Parent = parent
        mkCorner(btn, 8)
        mkStroke(btn, 1, Color3.new(1,1,1), 0.72)
        btn.MouseEnter:Connect(function() btn.BackgroundTransparency = 0.15 end)
        btn.MouseLeave:Connect(function() btn.BackgroundTransparency = 0.35 end)
        if callback then btn.MouseButton1Click:Connect(callback) end
        return btn
    end

    local EXECUTORS = {
        {name="Delta", check=function() return type(is_delta_executor)=="function" and is_delta_executor() end, platform="📱 Mobile", rating=100, color=Color3.fromRGB(60,200,120)},
        {name="Velocity", check=function() return type(VELOCITY)~="nil" end, platform="💻 Windows", rating=94, color=Color3.fromRGB(80,160,255)},
        {name="Fluxus", check=function() return type(fluxus)~="nil" end, platform="💻 Windows", rating=82, color=Color3.fromRGB(255,140,60)},
        {name="Wave", check=function() return type(WAVE_VERSION)~="nil" end, platform="💻 Windows", rating=100, color=Color3.fromRGB(60,180,220)},
    }

    local function detectExecutor()
        for _, e in ipairs(EXECUTORS) do
            if pcall(e.check) then return e end
        end
        if identifyexecutor then
            local ok, name = pcall(identifyexecutor)
            if ok and name then return {name=name, platform=platformName, color=Color3.fromRGB(160,160,160)} end
        end
        return nil
    end

    return {
        showHome = function(scrollingFrame)
            createSectionHeader("Overview", scrollingFrame)

            local card = mkGlass(scrollingFrame, UDim2.new(1,0,0,100), nil, 4, 0.10, 14)
            mkGradientBar(card, 5)

            local ok, thumb = pcall(function() return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180) end)
            local avatar = Instance.new("ImageLabel")
            avatar.Size = UDim2.new(0,68,0,68); avatar.Position = UDim2.new(0,14,0.5,-34)
            avatar.BackgroundTransparency = 0; avatar.Image = ok and thumb or ""
            avatar.ZIndex = 7; avatar.Parent = card
            mkCorner(avatar, 34); mkStroke(avatar, 2, T.Accent, 0.3)

            mkLabel(card, player.Name, UDim2.new(1,-100,0,22), UDim2.new(0,92,0,10), T.TextMain, nil, Enum.Font.GothamBold, 16, 6)
            mkLabel(card, "🆔 " .. player.UserId, UDim2.new(1,-100,0,14), UDim2.new(0,92,0,34), T.TextSub, nil, Enum.Font.Gotham, 11, 6)
            mkLabel(card, "🎮 " .. gui.gameName .. " · " .. game.PlaceId, UDim2.new(1,-100,0,14), UDim2.new(0,92,0,50), T.TextMuted, nil, Enum.Font.Gotham, 10, 6)

            local statsRow = mkFrame(scrollingFrame, UDim2.new(1,0,0,38), nil, nil, 1)
            local fpsCard = mkGlass(statsRow, UDim2.new(0.48,0,1,0), UDim2.new(0,0,0,0), 4, 0.18, 10)
            local pingCard = mkGlass(statsRow, UDim2.new(0.48,0,1,0), UDim2.new(0.52,0,0,0), 4, 0.18, 10)

            local fpsLabel = mkLabel(fpsCard, "⚡ FPS: —", UDim2.new(1,-12,1,0), UDim2.new(0,10,0,0), T.TextMain, nil, Enum.Font.GothamBold, 12, 5)
            local pingLabel = mkLabel(pingCard, "📡 Ping: —", UDim2.new(1,-12,1,0), UDim2.new(0,10,0,0), T.TextMain, nil, Enum.Font.GothamBold, 12, 5)

            do local last, frames = tick(), 0
                RunService.Heartbeat:Connect(function()
                    frames += 1
                    if tick() - last >= 1 then
                        fpsLabel.Text = "⚡ FPS: " .. frames
                        fpsLabel.TextColor3 = frames >= 55 and Color3.fromRGB(80,220,100) or frames >= 30 and Color3.fromRGB(220,180,40) or Color3.fromRGB(220,80,60)
                        frames, last = 0, tick()
                    end
                end)
            end
            do
                RunService.Heartbeat:Connect(function()
                    local ms = math.floor(player:GetNetworkPing() * 1000)
                    pingLabel.Text = "📡 Ping: " .. ms .. " ms"
                    pingLabel.TextColor3 = ms <= 60 and Color3.fromRGB(80,220,100) or ms <= 120 and Color3.fromRGB(220,180,40) or Color3.fromRGB(220,80,60)
                end)
            end

            createSectionHeader("Executor", scrollingFrame)
            local execCard = mkGlass(scrollingFrame, UDim2.new(1,0,0,90), nil, 4, 0.10, 14)
            mkGradientBar(execCard, 5)
            local detected = detectExecutor()
            if detected then
                local dot = mkFrame(execCard, UDim2.new(0,10,0,10), UDim2.new(0,14,0,14), detected.color, 0, 7)
                mkCorner(dot, 5)
                mkLabel(execCard, detected.name, UDim2.new(1,-100,0,20), UDim2.new(0,32,0,8), Color3.new(1,1,1), nil, Enum.Font.GothamBold, 17, 6)
            end

            createSectionHeader("Unique", scrollingFrame)
            local uniq = mkGlass(scrollingFrame, UDim2.new(1,0,0,140), nil, 4, 0.12, 12)

            mkLabel(uniq, "Session Time", UDim2.new(1,-20,0,20), UDim2.new(0,14,0,12), T.TextMain, nil, Enum.Font.GothamBold, 13)
            local timeLabel = mkLabel(uniq, "00:00:00", UDim2.new(1,-20,0,20), UDim2.new(0,14,0,34), Color3.fromRGB(80,220,100), nil, Enum.Font.GothamBold, 14)

            local start = tick()
            RunService.Heartbeat:Connect(function()
                local t = tick() - start
                timeLabel.Text = string.format("%02d:%02d:%02d", t/3600, (t%3600)/60, t%60)
            end)

            mkButton(uniq, "Hide UI (F4)", UDim2.new(0,120,0,32), UDim2.new(0,14,0,65), Color3.fromRGB(255,100,100), function() gui.Enabled = not gui.Enabled end)
            mkButton(uniq, "Copy PlaceId + JobId", UDim2.new(0,160,0,32), UDim2.new(0,150,0,65), nil, function() if setclipboard then setclipboard(game.PlaceId .. " | " .. game.JobId) end end)
        end
    }
end
