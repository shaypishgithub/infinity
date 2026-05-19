-- ══════════════════════════════════════════════════════════════════
--  games.lua  —  Games Virtual Tab + Lazy Icon Loader
--  Загружается из logic.lua через loadstring(game:HttpGet(...))()
-- ══════════════════════════════════════════════════════════════════
return function(deps)
    local TweenService = deps.TweenService
    local RunService   = deps.RunService
    local Players      = deps.Players
    local T            = deps.T
    local gui          = deps.gui
    local categoryMap  = deps.categoryMap
    local gameIcons    = deps.gameIcons or {}

    local gamesPanel        = gui.gamesPanel
    local catScroll         = gui.catScroll
    local scrollingFrame    = gui.scrollingFrame
    local createGameCard    = gui.createGameCard
    local mkCorner          = gui.mkCorner
    local mkStroke          = gui.mkStroke

    -- ── STATE ──────────────────────────────────────────────────────
    local iconQueue      = {}   -- {thumb=ImageLabel, placeId=int, loaded=bool}
    local lazyLoaderConn = nil
    local gamesPopulated = false

    -- ── LAZY ICON LOADER ───────────────────────────────────────────
    local function enqueueIcon(thumb, placeId)
        if not placeId then return end
        table.insert(iconQueue, {thumb = thumb, placeId = placeId, loaded = false})
    end

    local function startLazyLoader()
        if lazyLoaderConn then
            pcall(function() lazyLoaderConn:Disconnect() end)
        end
        local acc            = 0
        local BATCH_INTERVAL = 0.15
        local BATCH_SIZE     = 4

        lazyLoaderConn = RunService.Heartbeat:Connect(function(dt)
            acc = acc + dt
            if acc < BATCH_INTERVAL then return end
            acc = 0

            local loaded       = 0
            local panelAbsPos  = gamesPanel.AbsolutePosition
            local panelAbsSize = gamesPanel.AbsoluteSize
            local scrollY      = gamesPanel.CanvasPosition.Y

            for i = #iconQueue, 1, -1 do
                local entry = iconQueue[i]
                if entry.loaded or not entry.thumb or not entry.thumb.Parent then
                    table.remove(iconQueue, i)
                    continue
                end

                local cardAbsY = entry.thumb.AbsolutePosition.Y - panelAbsPos.Y + scrollY
                local inView   = cardAbsY < (panelAbsSize.Y + 120) and cardAbsY > -120

                if inView and loaded < BATCH_SIZE then
                    entry.loaded = true
                    loaded       = loaded + 1
                    local thumb  = entry.thumb
                    local pid    = entry.placeId

                    task.spawn(function()
                        local ok, url = pcall(function()
                            return Players:GetUserThumbnailAsync(
                                pid,
                                Enum.ThumbnailType.GameIcon,
                                Enum.ThumbnailSize.Size420x420
                            )
                        end)
                        if not ok or not url or url == "" then
                            ok, url = pcall(function()
                                return "https://assetgame.roblox.com/asset/?id=" .. tostring(pid)
                            end)
                        end
                        if ok and url and url ~= "" then
                            if thumb and thumb.Parent then
                                thumb.Image = url
                                TweenService:Create(thumb,
                                    TweenInfo.new(0.35, Enum.EasingStyle.Sine),
                                    {ImageTransparency = 0}
                                ):Play()
                            end
                        end
                    end)
                end
            end

            if #iconQueue == 0 then
                pcall(function() lazyLoaderConn:Disconnect() end)
                lazyLoaderConn = nil
            end
        end)
    end

    -- ── PUBLIC: reset (вызывается при clearContent) ────────────────
    local function reset()
        if lazyLoaderConn then
            pcall(function() lazyLoaderConn:Disconnect() end)
            lazyLoaderConn = nil
        end
    end

    -- ── PUBLIC: showGames ──────────────────────────────────────────
    local function showGames(callbacks)
        -- callbacks.onCategoryClick(catName) — навигация в logic.lua
        scrollingFrame.Visible = false
        gamesPanel.Visible     = true

        if gamesPopulated then
            startLazyLoader()
            return
        end
        gamesPopulated = true
        iconQueue = {}

        local sortedCats = {}
        for catName in pairs(categoryMap) do
            table.insert(sortedCats, catName)
        end
        table.sort(sortedCats)

        task.spawn(function()
            for idx, catName in ipairs(sortedCats) do
                local placeId    = gameIcons[catName]
                local _, thumb   = createGameCard(catName, placeId, function()
                    if callbacks and callbacks.onCategoryClick then
                        callbacks.onCategoryClick(catName)
                    end
                end)

                if placeId then
                    enqueueIcon(thumb, placeId)
                end

                if idx % 8 == 0 then
                    task.wait()
                end
            end
            startLazyLoader()
        end)
    end

    return {
        showGames    = showGames,
        reset        = reset,
        startLoader  = startLazyLoader,
    }
end
