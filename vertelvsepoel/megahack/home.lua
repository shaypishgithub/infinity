-- ══════════════════════════════════════════════════════════════════
--  home.lua  —  Home tab content
--  Загружается из logic.lua через loadSubmodule("home.lua")
--  Зависимости передаются через deps (как games.lua / colorpicker.lua)
-- ══════════════════════════════════════════════════════════════════
return function(deps)
    local RunService   = deps.RunService
    local Players      = deps.Players
    local T            = deps.T
    local gui          = deps.gui
    local player       = deps.player
    local platformName = deps.platformName

    local createSectionHeader = gui.createSectionHeader
    local createLabel         = gui.createLabel
    local mkCorner            = gui.mkCorner
    local mkStroke            = gui.mkStroke

    -- ─── локальные хелперы (дублируют helpers из logic, без лишних deps) ──
    local function mkFrame(parent, size, pos, bg, bgt, zidx)
        local f = Instance.new("Frame")
        f.Size                   = size or UDim2.new(1,0,0,40)
        f.Position               = pos  or UDim2.new(0,0,0,0)
        f.BackgroundColor3       = bg   or T.BgPanel
        f.BackgroundTransparency = bgt  ~= nil and bgt or 0.15
        f.BorderSizePixel        = 0
        f.ZIndex                 = zidx or 4
        f.Parent                 = parent
        return f
    end

    local function mkLabel(parent, text, size, pos, color, align, font, textSize, zidx)
        local l = Instance.new("TextLabel")
        l.Text                   = text or ""
        l.Size                   = size or UDim2.new(1,0,1,0)
        l.Position               = pos  or UDim2.new(0,0,0,0)
        l.TextColor3             = color or T.TextMain
        l.TextXAlignment         = align or Enum.TextXAlignment.Left
        l.Font                   = font  or Enum.Font.Gotham
        l.TextSize               = textSize or 12
        l.BackgroundTransparency = 1
        l.ZIndex                 = zidx or 5
        l.Parent                 = parent
        return l
    end

    -- ─── PUBLIC API ────────────────────────────────────────────────────────
    return {
        -- showHome(scrollingFrame) — вызывается из logic.lua
        showHome = function(scrollingFrame)
            createSectionHeader("Overview", scrollingFrame)

            -- ── Карточка игрока ─────────────────────────────────────────────
            local card = Instance.new("Frame")
            card.Name                   = "HomeCard"
            card.Size                   = UDim2.new(1,0,0,92)
            card.BackgroundColor3       = T.BgPanel
            card.BackgroundTransparency = 0.12
            card.BorderSizePixel        = 0
            card.ZIndex                 = 4
            card.Parent                 = scrollingFrame
            mkCorner(card, 10)
            mkStroke(card, 1, Color3.new(1,1,1), 0.88)

            -- Аватар
            local ok2, thumbnail = pcall(function()
                return Players:GetUserThumbnailAsync(
                    player.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size180x180
                )
            end)
            local avatarImg = Instance.new("ImageLabel")
            avatarImg.Size                   = UDim2.new(0,64,0,64)
            avatarImg.Position               = UDim2.new(0,14,0.5,-32)
            avatarImg.BackgroundColor3       = T.BgSide
            avatarImg.BackgroundTransparency = 0
            avatarImg.Image                  = ok2 and thumbnail or ""
            avatarImg.ZIndex                 = 6
            avatarImg.Parent                 = card
            mkCorner(avatarImg, 32)

            mkLabel(card, player.Name,
                UDim2.new(1,-96,0,20), UDim2.new(0,88,0,14),
                T.TextMain, nil, Enum.Font.GothamBold, 15, 6)
            :SetAttribute("TextRole","main")

            mkLabel(card, "UID: " .. player.UserId,
                UDim2.new(1,-96,0,14), UDim2.new(0,88,0,36),
                T.TextSub, nil, Enum.Font.Gotham, 11, 6)

            mkLabel(card, "Game: " .. gui.gameName .. "  ·  PlaceId: " .. game.PlaceId,
                UDim2.new(1,-96,0,14), UDim2.new(0,88,0,52),
                T.TextMuted, nil, Enum.Font.Gotham, 10, 6)

            -- Бейдж платформы
            local platBadge = Instance.new("Frame")
            platBadge.Name                   = "PlatBadge"
            platBadge.BackgroundColor3       = T.Accent
            platBadge.BackgroundTransparency = 0.55
            platBadge.BorderSizePixel        = 0
            platBadge.Size                   = UDim2.new(0,52,0,16)
            platBadge.Position               = UDim2.new(0,88,0,70)
            platBadge.ZIndex                 = 6
            platBadge.Parent                 = card
            mkCorner(platBadge, 5)
            mkLabel(platBadge, platformName,
                UDim2.new(1,0,1,0), UDim2.new(0,0,0,0),
                T.TextMain, Enum.TextXAlignment.Center, Enum.Font.GothamBold, 9, 7)
            :SetAttribute("TextRole","main")

            -- ── FPS карточка ────────────────────────────────────────────────
            local fpsCard = mkFrame(
                scrollingFrame,
                UDim2.new(1,0,0,34),
                nil,
                T.BgPanel,    -- <-- цвет из T, применится через updateGuiColors
                0.18,
                4
            )
            fpsCard.Name = "FpsCard"
            mkCorner(fpsCard, 8)

            local fpsLabel = mkLabel(fpsCard, "FPS: Calculating...",
                UDim2.new(1,-16,1,0), UDim2.new(0,16,0,0),
                T.TextMain, nil, Enum.Font.Gotham, 12, 5)
            fpsLabel:SetAttribute("TextRole","main")

            do
                local lastTime, frames = tick(), 0
                local conn; conn = RunService.Heartbeat:Connect(function()
                    frames = frames + 1
                    local now = tick()
                    if now - lastTime >= 1 then
                        local fps   = frames
                        local color = fps >= 55 and Color3.fromRGB(80,220,100)
                                   or fps >= 30 and Color3.fromRGB(220,180,40)
                                   or Color3.fromRGB(220,80,60)
                        fpsLabel.Text       = "FPS: " .. fps
                        fpsLabel.TextColor3 = color
                        frames = 0; lastTime = now
                    end
                    if not fpsCard.Parent then conn:Disconnect() end
                end)
            end

            -- ── Сообщество ──────────────────────────────────────────────────
            createSectionHeader("Community", scrollingFrame)
            createLabel("▶  YouTube  ·  youtube.com/@Vermax",      scrollingFrame)
            createLabel("✈  Telegram  ·  t.me/@vermax",            scrollingFrame)
            createLabel("💬  Discord  ·  discord.com/invite/vermax", scrollingFrame)
        end,
    }
end
