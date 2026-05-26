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
        f.BackgroundTransparency = bgt ~= nil and bgt or 0.15
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
    
    -- Обводка теперь использует глобальный Stroke из темы
    local stroke = mkStroke(f, 1, Color3.new(1,1,1), 0.78)
    
    return f
end
        -- просто тонкая акцентная линия без радуги
        local bar = Instance.new("Frame")
        bar.Name = "GradientBar"
        bar.Size = UDim2.new(1,0,0,2)
        bar.Position = UDim2.new(0,0,0,0)
        bar.BackgroundColor3 = T.Accent
        bar.BackgroundTransparency = 0.3
        bar.BorderSizePixel = 0
        bar.ZIndex = (zidx or 5) + 1
        bar.Parent = parent
        mkCorner(bar, 2)
        return bar
    end

    local function mkButton(parent, text, size, pos, accent, callback, zidx)
        local btn = Instance.new("TextButton")
        btn.Size = size or UDim2.new(0,110,0,28)
        btn.Position = pos or UDim2.new(0,0,0,0)
        btn.BackgroundColor3 = accent or T.Accent or Color3.fromRGB(100,80,220)
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
        btn.MouseEnter:Connect(function()
            btn.BackgroundTransparency = 0.15
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundTransparency = 0.35
        end)
        if callback then
            btn.MouseButton1Click:Connect(callback)
        end
        return btn
    end

    local function mkDivider(parent)
        local d = Instance.new("Frame")
        d.Size = UDim2.new(1,-24,0,1)
        d.Position = UDim2.new(0,12,0,0)
        d.BackgroundColor3 = Color3.new(1,1,1)
        d.BackgroundTransparency = 0.88
        d.BorderSizePixel = 0
        d.ZIndex = 5
        d.Parent = parent
        return d
    end

    local EXECUTORS = {
        { name="Delta", check=function() return type(is_delta_executor)=="function" and is_delta_executor() end,
          platform="📱 Mobile", rating=100, color=Color3.fromRGB(60,200,120) },
        { name="Velocity", check=function() return type(VELOCITY)~="nil" end,
          platform="💻 Windows", rating=94, color=Color3.fromRGB(80,160,255) },
        { name="Fluxus", check=function() return type(fluxus)~="nil" end,
          platform="💻 Windows", rating=82, color=Color3.fromRGB(255,140,60) },
        { name="Solara", check=function() return type(SOLARA_VERSION)~="nil" end,
          platform="💻 Windows", rating=39, color=Color3.fromRGB(220,100,80) },
        { name="Xeno", check=function() return type(xeno)~="nil" end,
          platform="💻 Windows", rating=40, color=Color3.fromRGB(200,90,200) },
        { name="Wave", check=function() return type(WAVE_VERSION)~="nil" end,
          platform="💻 Windows", rating=100, color=Color3.fromRGB(60,180,220) },
        { name="Volt", check=function() return type(VOLT)~="nil" end,
          platform="💻 Windows", rating=98, color=Color3.fromRGB(255,220,50) },
        { name="Matcha", check=function() return type(MATCHA)~="nil" end,
          platform="💻 Windows", rating=nil, color=Color3.fromRGB(100,200,140) },
        { name="Synapse Z",check=function() return type(syn)~="nil" end,
          platform="💻 Windows", rating=nil, color=Color3.fromRGB(180,80,255) },
    }

    local function detectExecutor()
        for _, e in ipairs(EXECUTORS) do
            local ok, res = pcall(e.check)
            if ok and res then
                return e
            end
        end
        if identifyexecutor then
            local ok2, name = pcall(identifyexecutor)
            if ok2 and name then
                return { name=name, platform=platformName, rating=nil, color=Color3.fromRGB(160,160,160) }
            end
        end
        return nil
    end

    return {
        showHome = function(scrollingFrame)
            createSectionHeader("Overview", scrollingFrame)

            local card = mkGlass(scrollingFrame, UDim2.new(1,0,0,100), nil, 4, 0.10, 14)
            card.Name = "HomeCard"

            local ok2, thumbnail = pcall(function()
                return Players:GetUserThumbnailAsync(
                    player.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size180x180
                )
            end)
            local avatarImg = Instance.new("ImageLabel")
            avatarImg.Size = UDim2.new(0,68,0,68)
            avatarImg.Position = UDim2.new(0,14,0.5,-34)
            avatarImg.BackgroundColor3 = T.BgSide or Color3.fromRGB(30,30,40)
            avatarImg.BackgroundTransparency = 0
            avatarImg.Image = ok2 and thumbnail or ""
            avatarImg.ZIndex = 7
            avatarImg.Parent = card
            mkCorner(avatarImg, 34)
            mkStroke(avatarImg, 2, T.Accent or Color3.fromRGB(120,80,255), 0.3)

            local nameLabel = mkLabel(card, player.Name,
                UDim2.new(1,-100,0,22), UDim2.new(0,92,0,10),
                T.TextMain, nil, Enum.Font.GothamBold, 16, 6)
            nameLabel:SetAttribute("TextRole","main")

            mkLabel(card, "🆔 " .. player.UserId,
                UDim2.new(1,-100,0,14), UDim2.new(0,92,0,34),
                T.TextSub, nil, Enum.Font.Gotham, 11, 6)

            mkLabel(card, "🎮 " .. gui.gameName .. " · " .. game.PlaceId,
                UDim2.new(1,-100,0,14), UDim2.new(0,92,0,50),
                T.TextMuted, nil, Enum.Font.Gotham, 10, 6)

            local platBadge = mkFrame(card,
                UDim2.new(0,60,0,17), UDim2.new(0,92,0,70),
                T.Accent or Color3.fromRGB(100,80,220), 0.45, 6)
            mkCorner(platBadge, 6)
            mkLabel(platBadge, platformName,
                UDim2.new(1,0,1,0), UDim2.new(0,0,0,0),
                Color3.new(1,1,1), Enum.TextXAlignment.Center,
                Enum.Font.GothamBold, 9, 7)

            local statsRow = Instance.new("Frame")
            statsRow.Size = UDim2.new(1,0,0,38)
            statsRow.BackgroundTransparency = 1
            statsRow.BorderSizePixel = 0
            statsRow.ZIndex = 4
            statsRow.Parent = scrollingFrame

            local fpsCard = mkGlass(statsRow,
                UDim2.new(0.48,0,1,0), UDim2.new(0,0,0,0), 4, 0.18, 10)
            fpsCard.Name = "FpsCard"
            local fpsLabel = mkLabel(fpsCard, "⚡ FPS: —",
                UDim2.new(1,-12,1,0), UDim2.new(0,10,0,0),
                T.TextMain, nil, Enum.Font.GothamBold, 12, 5)
            fpsLabel:SetAttribute("TextRole","main")

            local pingCard = mkGlass(statsRow,
                UDim2.new(0.48,0,1,0), UDim2.new(0.52,0,0,0), 4, 0.18, 10)
            pingCard.Name = "PingCard"
            local pingLabel = mkLabel(pingCard, "📡 Ping: —",
                UDim2.new(1,-12,1,0), UDim2.new(0,10,0,0),
                T.TextMain, nil, Enum.Font.GothamBold, 12, 5)
            pingLabel:SetAttribute("TextRole","main")

            do
                local lastTime, frames = tick(), 0
                local conn; conn = RunService.Heartbeat:Connect(function()
                    frames = frames + 1
                    local now = tick()
                    if now - lastTime >= 1 then
                        local fps = frames
                        local color = fps >= 55 and Color3.fromRGB(80,220,100)
                                   or fps >= 30 and Color3.fromRGB(220,180,40)
                                   or Color3.fromRGB(220,80,60)
                        fpsLabel.Text = "⚡ FPS: " .. fps
                        fpsLabel.TextColor3 = color
                        frames = 0; lastTime = now
                    end
                    if not fpsCard.Parent then conn:Disconnect() end
                end)
            end

            do
                local localPlayer = Players.LocalPlayer
                local conn2; conn2 = RunService.Heartbeat:Connect(function()
                    if localPlayer then
                        local ms = math.floor(localPlayer:GetNetworkPing() * 1000)
                        local color = ms <= 60 and Color3.fromRGB(80,220,100)
                                   or ms <= 120 and Color3.fromRGB(220,180,40)
                                   or Color3.fromRGB(220,80,60)
                        pingLabel.Text = "📡 Ping: " .. ms .. " ms"
                        pingLabel.TextColor3 = color
                    end
                    if not pingCard.Parent then conn2:Disconnect() end
                end)
            end

            createSectionHeader("Executor", scrollingFrame)
            local execCard = mkGlass(scrollingFrame, UDim2.new(1,0,0,90), nil, 4, 0.10, 14)
            execCard.Name = "ExecCard"

            local detected = detectExecutor()
            if detected then
                local dot = Instance.new("Frame")
                dot.Size = UDim2.new(0,10,0,10)
                dot.Position = UDim2.new(0,14,0,14)
                dot.BackgroundColor3 = detected.color or Color3.fromRGB(80,220,100)
                dot.BackgroundTransparency = 0
                dot.BorderSizePixel = 0
                dot.ZIndex = 7
                dot.Parent = execCard
                mkCorner(dot, 5)
                mkLabel(execCard, detected.name,
                    UDim2.new(1,-100,0,20), UDim2.new(0,32,0,8),
                    Color3.new(1,1,1), nil, Enum.Font.GothamBold, 17, 6)
                mkLabel(execCard, detected.platform or platformName,
                    UDim2.new(1,-32,0,14), UDim2.new(0,14,0,36),
                    T.TextSub, nil, Enum.Font.Gotham, 11, 6)
                if detected.rating then
                    local ratingColor = detected.rating >= 80 and Color3.fromRGB(80,220,100)
                                     or detected.rating >= 50 and Color3.fromRGB(220,180,40)
                                     or Color3.fromRGB(220,80,60)
                    local rLabel = mkLabel(execCard,
                        "Rating: " .. detected.rating .. "%",
                        UDim2.new(0,90,0,14), UDim2.new(0,14,0,54),
                        ratingColor, nil, Enum.Font.GothamBold, 11, 6)
                    local barBg = mkFrame(execCard,
                        UDim2.new(1,-28,0,4), UDim2.new(0,14,0,72),
                        Color3.new(1,1,1), 0.88, 6)
                    mkCorner(barBg, 3)
                    local barFill = mkFrame(execCard,
                        UDim2.new(detected.rating/100, 0, 0, 4),
                        UDim2.new(0,14,0,72),
                        ratingColor, 0, 7)
                    mkCorner(barFill, 3)
                end
            else
                local dot = Instance.new("Frame")
                dot.Size = UDim2.new(0,10,0,10)
                dot.Position = UDim2.new(0,14,0,14)
                dot.BackgroundColor3 = Color3.fromRGB(160,160,160)
                dot.BackgroundTransparency = 0
                dot.BorderSizePixel = 0
                dot.ZIndex = 7
                dot.Parent = execCard
                mkCorner(dot, 5)
                mkLabel(execCard, "Unknown Executor",
                    UDim2.new(1,-32,0,22), UDim2.new(0,32,0,8),
                    Color3.new(1,1,1), nil, Enum.Font.GothamBold, 15, 6)
                mkLabel(execCard, "Executor could not be identified automatically",
                    UDim2.new(1,-32,0,14), UDim2.new(0,14,0,36),
                    T.TextMuted, nil, Enum.Font.Gotham, 10, 6)
                mkLabel(execCard, platformName,
                    UDim2.new(1,-32,0,14), UDim2.new(0,14,0,52),
                    T.TextSub, nil, Enum.Font.Gotham, 11, 6)
            end

            createSectionHeader("Community", scrollingFrame)
            local links = {
                { icon="▶", label="YouTube", sub="@Vermax", color=Color3.fromRGB(220,60,60),
                  url="https://www.youtube.com/@sajne_ss" },
                { icon="✈", label="Telegram", sub="@vermax", color=Color3.fromRGB(40,160,240),
                  url="https://t.me/vertelevsepoel" },
                { icon="💬", label="Discord", sub="invite/vermax", color=Color3.fromRGB(88,101,242),
                  url="https://discord.com/invite/vermax" },
            }
            for _, link in ipairs(links) do
                local row = mkGlass(scrollingFrame,
                    UDim2.new(1,0,0,44), nil, 4, 0.14, 12)
                local accent = mkFrame(row,
                    UDim2.new(0,3,1,-12), UDim2.new(0,10,0,6),
                    link.color, 0, 6)
                mkCorner(accent, 2)
                mkLabel(row, link.icon .. " " .. link.label,
                    UDim2.new(0,140,0,20), UDim2.new(0,22,0,6),
                    Color3.new(1,1,1), nil, Enum.Font.GothamBold, 13, 6)
                mkLabel(row, link.sub,
                    UDim2.new(0,160,0,14), UDim2.new(0,22,0,26),
                    T.TextMuted, nil, Enum.Font.Gotham, 10, 6)
                mkButton(row, "Open ↗",
                    UDim2.new(0,72,0,24), UDim2.new(1,-84,0.5,-12),
                    link.color,
                    function()
                        if setclipboard then
                            setclipboard(link.url)
                        end
                    end,
                    6)
            end

            local footer = mkFrame(scrollingFrame,
                UDim2.new(1,0,0,24), nil,
                Color3.new(1,1,1), 0.96, 4)
            mkLabel(footer, "Megahack · Made with ❤",
                UDim2.new(1,0,1,0), UDim2.new(0,0,0,0),
                T.TextMuted, Enum.TextXAlignment.Center, Enum.Font.Gotham, 9, 5)
        end,
    }
end
