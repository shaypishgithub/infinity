═══════════════════════════════════════════════════════════════
--  games.lua — Games Virtual Tab + Lazy Icon Loader v3
═══════════════════════════════════════════════════════════════

return function(deps)
    local TweenService = deps.TweenService
    local RunService   = deps.RunService
    local T            = deps.T
    local gui          = deps.gui
    local categoryMap  = deps.categoryMap
    local gameIcons    = deps.gameIcons or {}

    local gamesPanel     = gui.gamesPanel
    local scrollingFrame = gui.scrollingFrame
    local createGameCard = gui.createGameCard

    local iconQueue      = {}
    local lazyLoaderConn = nil
    local gamesPopulated = false

    local function enqueueIcon(thumb, placeId)
        if not placeId or placeId == 0 then return end
        table.insert(iconQueue, { thumb = thumb, placeId = placeId, loaded = false })
    end

    local function startLazyLoader()
        if lazyLoaderConn then
            pcall(function() lazyLoaderConn:Disconnect() end)
            lazyLoaderConn = nil
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
                local inView   = cardAbsY < (panelAbsSize.Y + 140) and cardAbsY > -140

                if inView and loaded < BATCH_SIZE then
                    entry.loaded = true
                    loaded       = loaded + 1
                    local thumb  = entry.thumb
                    local pid    = entry.placeId

                    task.spawn(function()
                        local url = "https://assetgame.roblox.com/asset/?id=" .. tostring(pid)
                        local ok  = pcall(function()
                            thumb.Image = url
                            TweenService:Create(thumb,
                                TweenInfo.new(0.4, Enum.EasingStyle.Sine),
                                { ImageTransparency = 0 }
                            ):Play()
                        end)
                        if not ok and thumb.Parent then
                            -- Fallback to rbxthumb
                            thumb.Image = string.format("rbxthumb://type=Asset&id=%s&w=150&h=150", tostring(pid))
                            thumb.ImageTransparency = 0
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

    local function reset()
        if lazyLoaderConn then
            pcall(function() lazyLoaderConn:Disconnect() end)
            lazyLoaderConn = nil
        end
        gamesPopulated = false
        iconQueue = {}
        for _, child in ipairs(gamesPanel:GetChildren()) do
            if not child:IsA("UIGridLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end
    end

    local function showGames(callbacks)
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
                local placeId = gameIcons[catName]
                local _, thumb = createGameCard(catName, placeId, function()
                    if callbacks and callbacks.onCategoryClick then
                        callbacks.onCategoryClick(catName)
                    end
                end)

                if placeId and placeId ~= 0 and thumb then
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
        showGames   = showGames,
        reset       = reset,
        startLoader = startLazyLoader,
    }
end
