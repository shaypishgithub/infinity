return function(deps)
    local gui = deps.gui
    local ThemeColors = deps.ThemeColors
    local Settings = deps.Settings
    local StatsModule = deps.StatsModule
    local RunService = deps.RunService
    local Players = deps.Players
    local player = deps.player
    local Notify = deps.Notify
    local gname = deps.gname
    local platformName = deps.platformName

    local MkGlassPanel, MkNeonText, MkNeonButton, CreateSectionHeader = gui.MkGlassPanel, gui.MkNeonText, gui.MkNeonButton, gui.CreateSectionHeader

    return function(ScriptScroll)
        CreateSectionHeader("Overview", ScriptScroll)
        
        local userCard = MkGlassPanel(ScriptScroll, UDim2.new(1, 0, 0, 110), nil, 4, 14, 0.12)
        local ok2, thumb = pcall(function() return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180) end)
        
        local avatarFrame = Instance.new("Frame"); avatarFrame.Size = UDim2.new(0, 72, 0, 72); avatarFrame.Position = UDim2.new(0, 14, 0.5, -36)
        avatarFrame.BackgroundColor3 = ThemeColors.GlassMid; avatarFrame.BackgroundTransparency = 0.2
        avatarFrame.BorderSizePixel = 0; avatarFrame.ZIndex = 6; avatarFrame.Parent = userCard
        gui.MkCorner(avatarFrame, 36); gui.MkStroke(avatarFrame, 2, Settings.colors.accent, 0.3)
        
        local avatarImg = Instance.new("ImageLabel"); avatarImg.Size = UDim2.new(1, -4, 1, -4); avatarImg.Position = UDim2.new(0, 2, 0, 2)
        avatarImg.BackgroundColor3 = Color3.new(0,0,0); avatarImg.BackgroundTransparency = 1
        avatarImg.Image = ok2 and thumb or ""; avatarImg.ZIndex = 7; avatarImg.Parent = avatarFrame; gui.MkCorner(avatarImg, 34)

        MkNeonText(userCard, player.Name, UDim2.new(1, -100, 0, 24), UDim2.new(0, 96, 0, 12), 17, ThemeColors.TextBright, 7)
        MkNeonText(userCard, "🆔 " .. player.UserId, UDim2.new(1, -100, 0, 16), UDim2.new(0, 96, 0, 38), 11, ThemeColors.TextDim, 7)
        MkNeonText(userCard, "🎮 " .. (gname or "Unknown") .. " · " .. game.PlaceId, UDim2.new(1, -100, 0, 16), UDim2.new(0, 96, 0, 56), 10, ThemeColors.TextMuted, 7)
        
        local platBadge = Instance.new("Frame"); platBadge.Size = UDim2.new(0, 70, 0, 20); platBadge.Position = UDim2.new(0, 96, 0, 78)
        platBadge.BackgroundColor3 = Settings.colors.accent; platBadge.BackgroundTransparency = 0.4
        platBadge.BorderSizePixel = 0; platBadge.ZIndex = 7; platBadge.Parent = userCard
        gui.MkCorner(platBadge, 6); gui.MkStroke(platBadge, 1, Settings.colors.accent, 0.3)
        local pt = Instance.new("TextLabel"); pt.Size = UDim2.new(1,0,1,0); pt.BackgroundTransparency = 1
        pt.Text = platformName; pt.Font = Enum.Font.GothamBold; pt.TextSize = 10
        pt.TextColor3 = Color3.new(1,1,1); pt.ZIndex = 8; pt.Parent = platBadge

        CreateSectionHeader("Performance", ScriptScroll)
        local statsRow = Instance.new("Frame"); statsRow.Size = UDim2.new(1, 0, 0, 50); statsRow.BackgroundTransparency = 1; statsRow.ZIndex = 4; statsRow.Parent = ScriptScroll
        local fpsCard = MkGlassPanel(statsRow, UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0), 4, 10, 0.2)
        local fpsLabel = MkNeonText(fpsCard, "⚡ FPS: —", UDim2.new(1, -12, 1, 0), UDim2.new(0, 10, 0, 0), 14, ThemeColors.TextBright, 6)
        local pingCard = MkGlassPanel(statsRow, UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), 4, 10, 0.2)
        local pingLabel = MkNeonText(pingCard, "📡 Ping: —", UDim2.new(1, -12, 1, 0), UDim2.new(0, 10, 0, 0), 14, ThemeColors.TextBright, 6)

        local lastTime, frames = tick(), 0
        RunService.Heartbeat:Connect(function()
            frames = frames + 1; local now = tick()
            if now - lastTime >= 1 then
                local fps = frames; fpsLabel.Text = "⚡ FPS: " .. fps
                fpsLabel.TextColor3 = fps >= 55 and ThemeColors.Success or fps >= 30 and ThemeColors.Warning or ThemeColors.Error
                frames = 0; lastTime = now
            end
            if not fpsCard.Parent then return end
        end)
        RunService.Heartbeat:Connect(function()
            local ms = math.floor((player:GetNetworkPing() or 0) * 1000)
            pingLabel.Text = "📡 Ping: " .. ms .. " ms"
            pingLabel.TextColor3 = ms <= 60 and ThemeColors.Success or ms <= 120 and ThemeColors.Warning or ThemeColors.Error
            if not pingCard.Parent then return end
        end)

        CreateSectionHeader("Session", ScriptScroll)
        local sessCard = MkGlassPanel(ScriptScroll, UDim2.new(1, 0, 0, 80), nil, 4, 12, 0.15)
        MkNeonText(sessCard, "⏱ Total Time: " .. StatsModule.fmtTime(StatsModule.Stats.totalSeconds), UDim2.new(0.5, 0, 0, 20), UDim2.new(0, 0, 0, 10), 13, ThemeColors.TextNormal, 6)
        MkNeonText(sessCard, "🔄 Sessions: " .. StatsModule.Stats.totalSessions .. "  |  🔥 Streak: " .. StatsModule.Stats.streak .. " days", UDim2.new(0.5, 0, 0, 20), UDim2.new(0, 0, 0, 35), 11, ThemeColors.TextDim, 6)
        
        local topTabs = {}
        for name, count in pairs(StatsModule.Stats.tabClicks) do table.insert(topTabs, {name=name, count=count}) end
        table.sort(topTabs, function(a,b) return a.count > b.count end)
        local topText = "Most Used: "
        for i = 1, math.min(3, #topTabs) do topText = topText .. topTabs[i].name .. " (" .. topTabs[i].count .. ")" .. (i < math.min(3, #topTabs) and " • " or "") end
        if #topTabs == 0 then topText = "Most Used: None yet" end
        MkNeonText(sessCard, topText, UDim2.new(1, -20, 0, 16), UDim2.new(0, 10, 0, 56), 10, ThemeColors.TextMuted, 6)

        CreateSectionHeader("Community", ScriptScroll)
        local links = {
            {icon="▶", label="YouTube", sub="@Vermax", color=ThemeColors.Error, url="https://www.youtube.com/@sajne_ss"},
            {icon="✈", label="Telegram", sub="@vermax", color=ThemeColors.NeonPrimary, url="https://t.me/vertelevsepoel"},
            {icon="💬", label="Discord", sub="invite/vermax", color=Color3.fromRGB(88,101,242), url="https://discord.com/invite/vermax"},
        }
        for _, link in ipairs(links) do
            local row = MkGlassPanel(ScriptScroll, UDim2.new(1, 0, 0, 48), nil, 4, 10, 0.18)
            local accent = Instance.new("Frame"); accent.Size = UDim2.new(0, 3, 1, -14); accent.Position = UDim2.new(0, 8, 0, 7)
            accent.BackgroundColor3 = link.color; accent.BorderSizePixel = 0; accent.ZIndex = 6; accent.Parent = row; gui.MkCorner(accent, 2)
            MkNeonText(row, link.icon .. " " .. link.label, UDim2.new(0, 140, 0, 22), UDim2.new(0, 20, 0, 8), 14, ThemeColors.TextBright, 6)
            MkNeonText(row, link.sub, UDim2.new(0, 160, 0, 16), UDim2.new(0, 20, 0, 28), 10, ThemeColors.TextMuted, 6)
            MkNeonButton(row, "Open →", UDim2.new(0, 72, 0, 28), UDim2.new(1, -84, 0.5, -14), function()
                if setclipboard then pcall(setclipboard, link.url); Notify("Copied!", "Link copied", 2, "success") end
            end, link.color, 8)
        end
    end
end
