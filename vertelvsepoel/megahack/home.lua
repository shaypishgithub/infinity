═══════════════════════════════════════════════════════════════
--  home.lua — Home Tab v3 (3D Glass Neon)
═══════════════════════════════════════════════════════════════

return function(deps)
    local RunService = deps.RunService
    local Players    = deps.Players
    local T          = deps.T
    local gui        = deps.gui
    local player     = deps.player
    local platformName = deps.platformName

    local createSectionHeader = gui.createSectionHeader
    local mkGlassCard         = gui.mkGlassCard
    local mkCorner            = gui.mkCorner
    local mkStroke            = gui.mkStroke
    local mk3DShadow          = gui.mk3DShadow
    local mkNeonLine          = gui.mkNeonLine

    local function mkLabel(parent, text, size, pos, color, align, font, textSize, zidx)
        local l = Instance.new("TextLabel")
        l.Text                   = text or ""
        l.Size                   = size or UDim2.new(1, 0, 1, 0)
        l.Position               = pos or UDim2.new(0, 0, 0, 0)
        l.TextColor3             = color or T.TextMain
        l.TextXAlignment         = align or Enum.TextXAlignment.Left
        l.Font                   = font or Enum.Font.Gotham
        l.TextSize               = textSize or 12
        l.BackgroundTransparency = 1
        l.ZIndex                 = zidx or 5
        l.Parent                 = parent
        return l
    end

    local function mkBtn(parent, text, size, pos, color, callback, zidx)
        local btn = Instance.new("TextButton")
        btn.Size                   = size or UDim2.new(0, 80, 0, 26)
        btn.Position               = pos or UDim2.new(0, 0, 0, 0)
        btn.BackgroundColor3       = color or T.Accent
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel        = 0
        btn.Text                   = text or "Button"
        btn.TextColor3             = Color3.new(1, 1, 1)
        btn.Font                   = Enum.Font.GothamBold
        btn.TextSize               = 10
        btn.ZIndex                 = zidx or 7
        btn.Parent                 = parent
        mkCorner(btn, 6)
        mkStroke(btn, 1, T.AccentGlow, 0.5)

        btn.MouseEnter:Connect(function()
            btn.BackgroundTransparency = 0.12
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundTransparency = 0.3
        end)

        if callback then
            btn.MouseButton1Click:Connect(callback)
        end
        return btn
    end

    -- Executor detection
    local EXECUTORS = {
        { name = "Delta",   check = function() return type(is_delta_executor) == "function" and is_delta_executor() end, platform = "📱 Mobile", rating = 100, color = Color3.fromRGB(60, 220, 130) },
        { name = "Velocity", check = function() return type(VELOCITY) ~= "nil" end, platform = "💻 Windows", rating = 94, color = Color3.fromRGB(80, 170, 255) },
        { name = "Fluxus",  check = function() return type(fluxus) ~= "nil" end, platform = "💻 Windows", rating = 82, color = Color3.fromRGB(255, 150, 70) },
        { name = "Solara",  check = function() return type(SOLARA_VERSION) ~= "nil" end, platform = "💻 Windows", rating = 39, color = Color3.fromRGB(220, 110, 90) },
        { name = "Xeno",    check = function() return type(xeno) ~= "nil" end, platform = "💻 Windows", rating = 40, color = Color3.fromRGB(210, 100, 210) },
        { name = "Wave",    check = function() return type(WAVE_VERSION) ~= "nil" end, platform = "💻 Windows", rating = 100, color = Color3.fromRGB(70, 190, 230) },
        { name = "Volt",    check = function() return type(VOLT) ~= "nil" end, platform = "💻 Windows", rating = 98, color = Color3.fromRGB(255, 225, 60) },
        { name = "Matcha",  check = function() return type(MATCHA) ~= "nil" end, platform = "💻 Windows", rating = nil, color = Color3.fromRGB(110, 210, 150) },
        { name = "Synapse Z", check = function() return type(syn) ~= "nil" end, platform = "💻 Windows", rating = nil, color = Color3.fromRGB(190, 90, 255) },
    }

    local function detectExecutor()
        for _, e in ipairs(EXECUTORS) do
            local ok, res = pcall(e.check)
            if ok and res then return e end
        end
        if identifyexecutor then
            local ok2, name = pcall(identifyexecutor)
            if ok2 and name then
                return { name = name, platform = platformName, rating = nil, color = Color3.fromRGB(170, 170, 180) }
            end
        end
        return nil
    end

    return {
        showHome = function(scrollingFrame)
            -- Clear
            for _, child in ipairs(scrollingFrame:GetChildren()) do
                if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                    child:Destroy()
                end
            end

            createSectionHeader("Overview", scrollingFrame)

            -- Player card
            local card = mkGlassCard(scrollingFrame, UDim2.new(1, 0, 0, 108), nil, T.BgCard, 0.12, 4, 14)
            card.Name = "HomeCard"

            -- Avatar
            local ok2, thumbnail = pcall(function()
                return Players:GetUserThumbnailAsync(
                    player.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size180x180
                )
            end)

            local avatarBg = Instance.new("Frame")
            avatarBg.Size                   = UDim2.new(0, 72, 0, 72)
            avatarBg.Position               = UDim2.new(0, 14, 0.5, -36)
            avatarBg.BackgroundColor3       = T.BgDeep
            avatarBg.BackgroundTransparency = 0
            avatarBg.BorderSizePixel        = 0
            avatarBg.ZIndex                 = 6
            avatarBg.Parent                 = card
            mkCorner(avatarBg, 36)
            mkStroke(avatarBg, 2, T.Accent, 0.3)

            local avatarImg = Instance.new("ImageLabel")
            avatarImg.Size                   = UDim2.new(1, -4, 1, -4)
            avatarImg.Position               = UDim2.new(0, 2, 0, 2)
            avatarImg.BackgroundColor3       = T.BgDeep
            avatarImg.BackgroundTransparency = 1
            avatarImg.Image                  = ok2 and thumbnail or ""
            avatarImg.ZIndex                 = 7
            avatarImg.Parent                 = avatarBg
            mkCorner(avatarImg, 34)

            local nameLabel = mkLabel(card, player.Name,
                UDim2.new(1, -106, 0, 22), UDim2.new(0, 98, 0, 10),
                T.TextMain, nil, Enum.Font.GothamBold, 17, 7)
            nameLabel:SetAttribute("TextRole", "main")

            mkLabel(card, "🆔 " .. player.UserId,
                UDim2.new(1, -106, 0, 14), UDim2.new(0, 98, 0, 34),
                T.TextSub, nil, Enum.Font.Gotham, 11, 7)

            mkLabel(card, "🎮 " .. gui.gameName .. " · " .. game.PlaceId,
                UDim2.new(1, -106, 0, 14), UDim2.new(0, 98, 0, 52),
                T.TextMuted, nil, Enum.Font.Gotham, 10, 7)

            local platBadge = Instance.new("Frame")
            platBadge.Size                   = UDim2.new(0, 64, 0, 18)
            platBadge.Position               = UDim2.new(0, 98, 0, 72)
            platBadge.BackgroundColor3       = T.Accent
            platBadge.BackgroundTransparency = 0.4
            platBadge.BorderSizePixel        = 0
            platBadge.ZIndex                 = 7
            platBadge.Parent                 = card
            mkCorner(platBadge, 9)
            mkStroke(platBadge, 1, T.AccentGlow, 0.4)

            mkLabel(platBadge, platformName,
                UDim2.new(1, 0, 1, 0), nil,
                Color3.new(1, 1, 1), Enum.TextXAlignment.Center,
                Enum.Font.GothamBold, 9, 8)

            -- ═══ STATS ROW ═══
            local statsRow = Instance.new("Frame")
            statsRow.Size                   = UDim2.new(1, 0, 0, 42)
            statsRow.BackgroundTransparency = 1
            statsRow.ZIndex                 = 4
            statsRow.Parent                 = scrollingFrame

            local fpsCard = mkGlassCard(statsRow, UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0), T.BgCard, 0.2, 4, 10)
            fpsCard.Name = "FpsCard"
            local fpsLabel = mkLabel(fpsCard, "⚡ FPS: —",
                UDim2.new(1, -14, 1, 0), UDim2.new(0, 12, 0, 0),
                T.TextMain, nil, Enum.Font.GothamBold, 13, 6)
            fpsLabel:SetAttribute("TextRole", "main")

            local pingCard = mkGlassCard(statsRow, UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), T.BgCard, 0.2, 4, 10)
            pingCard.Name = "PingCard"
            local pingLabel = mkLabel(pingCard, "📡 Ping: —",
                UDim2.new(1, -14, 1, 0), UDim2.new(0, 12, 0, 0),
                T.TextMain, nil, Enum.Font.GothamBold, 13, 6)
            pingLabel:SetAttribute("TextRole", "main")

            -- FPS counter
            do
                local lastTime, frames = tick(), 0
                local conn
                conn = RunService.Heartbeat:Connect(function()
                    frames = frames + 1
                    local now = tick()
                    if now - lastTime >= 1 then
                        local fps = frames
                        local color = fps >= 55 and Color3.fromRGB(80, 230, 120)
                                   or fps >= 30 and Color3.fromRGB(230, 190, 50)
                                   or Color3.fromRGB(230, 80, 70)
                        fpsLabel.Text = "⚡ FPS: " .. fps
                        fpsLabel.TextColor3 = color
                        frames = 0
                        lastTime = now
                    end
                    if not fpsCard.Parent then conn:Disconnect() end
                end)
            end

            -- Ping counter
            do
                local conn2
                conn2 = RunService.Heartbeat:Connect(function()
                    local lp = Players.LocalPlayer
                    if lp then
                        local ms = math.floor(lp:GetNetworkPing() * 1000)
                        local color = ms <= 60 and Color3.fromRGB(80, 230, 120)
                                   or ms <= 120 and Color3.fromRGB(230, 190, 50)
                                   or Color3.fromRGB(230, 80, 70)
                        pingLabel.Text = "📡 Ping: " .. ms .. " ms"
                        pingLabel.TextColor3 = color
                    end
                    if not pingCard.Parent then conn2:Disconnect() end
                end)
            end

            -- ═══ EXECUTOR ═══
            createSectionHeader("Executor", scrollingFrame)
            local execCard = mkGlassCard(scrollingFrame, UDim2.new(1, 0, 0, 94), nil, T.BgCard, 0.12, 4, 14)
            execCard.Name = "ExecCard"

            local detected = detectExecutor()
            if detected then
                -- Neon dot
                local dot = Instance.new("Frame")
                dot.Size                   = UDim2.new(0, 12, 0, 12)
                dot.Position               = UDim2.new(0, 14, 0, 14)
                dot.BackgroundColor3       = detected.color
                dot.BackgroundTransparency = 0
                dot.BorderSizePixel        = 0
                dot.ZIndex                 = 7
                dot.Parent                 = execCard
                mkCorner(dot, 6)

                -- Glow around dot
                local dotGlow = Instance.new("Frame")
                dotGlow.Size                   = UDim2.new(0, 20, 0, 20)
                dotGlow.Position               = UDim2.new(0, 10, 0, 10)
                dotGlow.BackgroundColor3       = detected.color
                dotGlow.BackgroundTransparency = 0.6
                dotGlow.BorderSizePixel        = 0
                dotGlow.ZIndex                 = 6
                dotGlow.Parent                 = execCard
                mkCorner(dotGlow, 10)

                mkLabel(execCard, detected.name,
                    UDim2.new(1, -110, 0, 22), UDim2.new(0, 36, 0, 8),
                    Color3.new(1, 1, 1), nil, Enum.Font.GothamBold, 18, 7)

                mkLabel(execCard, detected.platform or platformName,
                    UDim2.new(1, -36, 0, 14), UDim2.new(0, 16, 0, 36),
                    T.TextSub, nil, Enum.Font.Gotham, 11, 7)

                if detected.rating then
                    local ratingColor = detected.rating >= 80 and Color3.fromRGB(80, 230, 120)
                                     or detected.rating >= 50 and Color3.fromRGB(230, 190, 50)
                                     or Color3.fromRGB(230, 80, 70)

                    mkLabel(execCard, "Rating: " .. detected.rating .. "%",
                        UDim2.new(0, 100, 0, 14), UDim2.new(0, 16, 0, 54),
                        ratingColor, nil, Enum.Font.GothamBold, 11, 7)

                    -- Neon progress bar
                    local barBg = Instance.new("Frame")
                    barBg.Size                   = UDim2.new(1, -32, 0, 4)
                    barBg.Position               = UDim2.new(0, 16, 0, 74)
                    barBg.BackgroundColor3       = T.BgDeep
                    barBg.BackgroundTransparency = 0.3
                    barBg.BorderSizePixel        = 0
                    barBg.ZIndex                 = 7
                    barBg.Parent                 = execCard
                    mkCorner(barBg, 2)

                    local barFill = Instance.new("Frame")
                    barFill.Size                   = UDim2.new(detected.rating / 100, 0, 1, 0)
                    barFill.Position               = UDim2.new(0, 16, 0, 74)
                    barFill.BackgroundColor3       = ratingColor
                    barFill.BackgroundTransparency = 0
                    barFill.BorderSizePixel        = 0
                    barFill.ZIndex                 = 8
                    barFill.Parent                 = execCard
                    mkCorner(barFill, 2)

                    -- Glow on bar
                    local barGlow = Instance.new("Frame")
                    barGlow.Size                   = UDim2.new(detected.rating / 100, 0, 0, 8)
                    barGlow.Position               = UDim2.new(0, 16, 0, 72)
                    barGlow.BackgroundColor3       = ratingColor
                    barGlow.BackgroundTransparency = 0.7
                    barGlow.BorderSizePixel        = 0
                    barGlow.ZIndex                 = 7
                    barGlow.Parent                 = execCard
                    mkCorner(barGlow, 4)
                end
            else
                local dot = Instance.new("Frame")
                dot.Size                   = UDim2.new(0, 12, 0, 12)
                dot.Position               = UDim2.new(0, 14, 0, 14)
                dot.BackgroundColor3       = Color3.fromRGB(120, 120, 140)
                dot.BackgroundTransparency = 0.3
                dot.BorderSizePixel        = 0
                dot.ZIndex                 = 7
                dot.Parent                 = execCard
                mkCorner(dot, 6)

                mkLabel(execCard, "Unknown Executor",
                    UDim2.new(1, -36, 0, 22), UDim2.new(0, 36, 0, 8),
                    Color3.new(1, 1, 1), nil, Enum.Font.GothamBold, 16, 7)

                mkLabel(execCard, "Executor could not be identified",
                    UDim2.new(1, -36, 0, 14), UDim2.new(0, 16, 0, 36),
                    T.TextMuted, nil, Enum.Font.Gotham, 10, 7)

                mkLabel(execCard, platformName,
                    UDim2.new(1, -36, 0, 14), UDim2.new(0, 16, 0, 54),
                    T.TextSub, nil, Enum.Font.Gotham, 11, 7)
            end

            -- ═══ COMMUNITY ═══
            createSectionHeader("Community", scrollingFrame)

            local links = {
                { icon = "▶", label = "YouTube",   sub = "@Vermax",              color = Color3.fromRGB(230, 60, 60),  url = "https://www.youtube.com/@sajne_ss" },
                { icon = "✈", label = "Telegram",  sub = "@vermax",              color = Color3.fromRGB(50, 170, 250), url = "https://t.me/vertelevsepoel" },
                { icon = "💬", label = "Discord",   sub = "invite/vermax",        color = Color3.fromRGB(98, 110, 250), url = "https://discord.com/invite/vermax" },
            }

            for _, link in ipairs(links) do
                local row = mkGlassCard(scrollingFrame, UDim2.new(1, 0, 0, 48), nil, T.BgCard, 0.16, 4, 12)

                -- Neon accent bar
                local accentBar = Instance.new("Frame")
                accentBar.Size                   = UDim2.new(0, 3, 1, -14)
                accentBar.Position               = UDim2.new(0, 10, 0, 7)
                accentBar.BackgroundColor3       = link.color
                accentBar.BackgroundTransparency = 0.2
                accentBar.BorderSizePixel        = 0
                accentBar.ZIndex                 = 7
                accentBar.Parent                 = row
                mkCorner(accentBar, 2)

                -- Glow
                local accentGlow = Instance.new("Frame")
                accentGlow.Size                   = UDim2.new(0, 8, 1, -10)
                accentGlow.Position               = UDim2.new(0, 8, 0, 5)
                accentGlow.BackgroundColor3       = link.color
                accentGlow.BackgroundTransparency = 0.75
                accentGlow.BorderSizePixel        = 0
                accentGlow.ZIndex                 = 5
                accentGlow.Parent                 = row
                mkCorner(accentGlow, 4)

                mkLabel(row, link.icon .. " " .. link.label,
                    UDim2.new(0, 150, 0, 20), UDim2.new(0, 22, 0, 6),
                    Color3.new(1, 1, 1), nil, Enum.Font.GothamBold, 13, 7)

                mkLabel(row, link.sub,
                    UDim2.new(0, 170, 0, 14), UDim2.new(0, 22, 0, 28),
                    T.TextMuted, nil, Enum.Font.Gotham, 10, 7)

                mkBtn(row, "Open →",
                    UDim2.new(0, 76, 0, 26), UDim2.new(1, -88, 0.5, -13),
                    link.color,
                    function()
                        if setclipboard then pcall(setclipboard, link.url) end
                    end, 7)
            end

            -- Footer
            local footer = Instance.new("Frame")
            footer.Size                   = UDim2.new(1, 0, 0, 26)
            footer.BackgroundColor3       = T.BgDeep
            footer.BackgroundTransparency = 0.5
            footer.BorderSizePixel        = 0
            footer.ZIndex                 = 4
            footer.Parent                 = scrollingFrame
            mkCorner(footer, 6)

            mkLabel(footer, "Megahack 2026 · Made with ♦",
                UDim2.new(1, 0, 1, 0), nil,
                T.TextMuted, Enum.TextXAlignment.Center, Enum.Font.Gotham, 9, 5)
        end,
    }
end
