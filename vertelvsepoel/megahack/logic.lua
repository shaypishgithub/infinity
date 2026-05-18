-- ══════════════════════════════════════════════════════════════════
--  logic.lua  —  Вся логика: Home, Settings, Stats, поиск, категории
-- ══════════════════════════════════════════════════════════════════
return function(deps)
    local TweenService       = deps.TweenService
    local UserInputService   = deps.UserInputService
    local Players            = deps.Players
    local RunService         = deps.RunService
    local TeleportService    = deps.TeleportService
    local HttpService        = deps.HttpService
    local player             = deps.player
    local playerGui          = deps.playerGui
    local platformName       = deps.platformName
    local T                  = deps.T
    local gui                = deps.gui
    local HubData            = deps.HubData
    local baseUrl            = deps.baseUrl
    local categoryMap        = deps.categoryMap
    local createNotification = deps.createNotification
    local safeLoad           = deps.safeLoad

    local mainFrame           = gui.mainFrame
    local headerFrame         = gui.headerFrame
    local sidebarFrame        = gui.sidebarFrame
    local catScroll           = gui.catScroll
    local scrollingFrame      = gui.scrollingFrame
    local closeBtn            = gui.closeBtn
    local reopenButton        = gui.reopenButton
    local createButton        = gui.createButton
    local createLabel         = gui.createLabel
    local createSectionHeader = gui.createSectionHeader
    local mkCorner            = gui.mkCorner
    local mkStroke            = gui.mkStroke

    -- ══════════════════════════════════════
    --  SETTINGS STATE
    -- ══════════════════════════════════════
    local rgbConnections         = {}
    local colorPickerConnections = {}
    local settings = {
        locked       = false,
        rgbAccent    = false,
        rgbStroke    = false,
        transparency = 0.04,
        colors = {
            bgColor     = T.BgBase,
            textColor   = T.TextMain,
            strokeColor = T.Stroke,
            accentColor = T.Accent,
        }
    }

    local function clearRgbConnections()
        for _, c in pairs(rgbConnections) do pcall(function() c:Disconnect() end) end
        rgbConnections = {}
    end

    -- ══════════════════════════════════════
    --  STATS STATE
    -- ══════════════════════════════════════
    local statsData = {
        totalSeconds  = 0,
        totalSessions = 0,
        sessionStart  = tick(),
        tabClicks     = {},   -- {tabName = count}
        daySeconds    = {},   -- {[1..7] = seconds}  1=Пн
        streak        = 0,
        lastDayPlayed = 0,    -- os.time() день
    }

    local sessionTimerConn = nil  -- RunService соединение для текущей сессии

    local function ensureFolder()
        if not isfolder("MegaHack") then makefolder("MegaHack") end
    end

    local function saveStats()
        pcall(function()
            ensureFolder()
            writefile("MegaHack/stats.json", HttpService:JSONEncode(statsData))
        end)
    end

    local function loadStats()
        pcall(function()
            if isfile("MegaHack/stats.json") then
                local raw  = readfile("MegaHack/stats.json")
                local data = HttpService:JSONDecode(raw)
                if data.totalSeconds  then statsData.totalSeconds  = data.totalSeconds  end
                if data.totalSessions then statsData.totalSessions = data.totalSessions end
                if data.tabClicks     then statsData.tabClicks     = data.tabClicks     end
                if data.daySeconds    then statsData.daySeconds    = data.daySeconds    end
                if data.streak        then statsData.streak        = data.streak        end
                if data.lastDayPlayed then statsData.lastDayPlayed = data.lastDayPlayed end
            end
        end)
    end

    -- Записать клик по вкладке
    local function recordTabClick(name)
        if not statsData.tabClicks[name] then statsData.tabClicks[name] = 0 end
        statsData.tabClicks[name] = statsData.tabClicks[name] + 1
        saveStats()
    end

    -- Обновить стрик и дни
    local function updateDayStats(secsThisSession)
        local dow = tonumber(os.date("%w")) or 0  -- 0=воскр
        local dayIdx = dow == 0 and 7 or dow       -- 1=пн..7=воскр
        if not statsData.daySeconds[tostring(dayIdx)] then
            statsData.daySeconds[tostring(dayIdx)] = 0
        end
        statsData.daySeconds[tostring(dayIdx)] = statsData.daySeconds[tostring(dayIdx)] + secsThisSession

        -- стрик (сравниваем день)
        local todayNum = math.floor(os.time() / 86400)
        if statsData.lastDayPlayed == todayNum - 1 then
            statsData.streak = statsData.streak + 1
        elseif statsData.lastDayPlayed ~= todayNum then
            statsData.streak = 1
        end
        statsData.lastDayPlayed = todayNum
        saveStats()
    end

    -- Завершить сессию (вызывается при закрытии или вручную)
    local function finishCurrentSession()
        if sessionTimerConn then
            pcall(function() sessionTimerConn:Disconnect() end)
            sessionTimerConn = nil
        end
        local elapsed = math.floor(tick() - statsData.sessionStart)
        if elapsed > 5 then
            statsData.totalSeconds  = statsData.totalSeconds + elapsed
            statsData.totalSessions = statsData.totalSessions + 1
            updateDayStats(elapsed)
        end
        statsData.sessionStart = tick()
        saveStats()
    end

    -- Запустить таймер сессии
    local function startSessionTimer()
        statsData.sessionStart = tick()
        -- Авто-сохранение каждые 60 сек
        if sessionTimerConn then pcall(function() sessionTimerConn:Disconnect() end) end
        local acc = 0
        sessionTimerConn = RunService.Heartbeat:Connect(function(dt)
            acc = acc + dt
            if acc >= 60 then
                acc = 0
                local elapsed = math.floor(tick() - statsData.sessionStart)
                statsData.totalSeconds = statsData.totalSeconds + elapsed
                statsData.sessionStart = tick()
                saveStats()
            end
        end)
    end

    -- ══════════════════════════════════════
    --  UPDATE GUI COLORS
    -- ══════════════════════════════════════
    local function updateGuiColors()
        clearRgbConnections()
        local acc = settings.colors.accentColor
        local bg  = settings.colors.bgColor
        local tx  = settings.colors.textColor
        local str = settings.colors.strokeColor

        T.Accent     = acc
        T.AccentHov  = Color3.new(math.min(acc.R*1.22,1), math.min(acc.G*1.22,1), math.min(acc.B*1.22,1))
        T.AccentGlow = Color3.new(math.min(acc.R*1.35,1), math.min(acc.G*1.35,1), math.min(acc.B*1.35,1))
        T.BgBase     = bg
        T.BgSide     = Color3.new(math.min(bg.R+0.024,1), math.min(bg.G+0.024,1), math.min(bg.B+0.031,1))
        T.BgPanel    = Color3.new(math.min(bg.R+0.043,1), math.min(bg.G+0.043,1), math.min(bg.B+0.059,1))
        T.BgBtn      = Color3.new(math.min(bg.R+0.067,1), math.min(bg.G+0.067,1), math.min(bg.B+0.090,1))
        T.BgBtnHov   = Color3.new(math.min(bg.R+0.098,1), math.min(bg.G+0.098,1), math.min(bg.B+0.137,1))
        T.TextMain   = tx
        T.Stroke     = str

        for _, entry in ipairs(deps.accentRegistry or {}) do
            if entry.obj and entry.obj.Parent then
                pcall(function() entry.obj[entry.prop] = acc end)
            end
        end

        mainFrame.BackgroundColor3       = bg
        mainFrame.BackgroundTransparency = settings.transparency

        local closeBtnStroke = closeBtn:FindFirstChildOfClass("UIStroke")
        if closeBtnStroke then
            if settings.rgbStroke then
                local conn
                conn = RunService.Heartbeat:Connect(function()
                    if not closeBtn.Parent then conn:Disconnect() return end
                    closeBtnStroke.Color = Color3.fromHSV((tick()%5)/5, 1, 1)
                end)
                table.insert(rgbConnections, conn)
            else
                closeBtnStroke.Color = str
            end
        end

        for _, obj in pairs(mainFrame:GetDescendants()) do
            if obj:IsA("UIStroke") then
                if settings.rgbStroke then
                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then conn:Disconnect() return end
                        obj.Color = Color3.fromHSV((tick()%5)/5, 1, 1)
                    end)
                    table.insert(rgbConnections, conn)
                else
                    obj.Color = str
                end
            end
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                if settings.rgbAccent then
                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then conn:Disconnect() return end
                        obj.TextColor3 = Color3.fromHSV((tick()%5)/5, 1, 1)
                    end)
                    table.insert(rgbConnections, conn)
                else
                    if obj:GetAttribute("TextRole") == "main" then
                        obj.TextColor3 = tx
                    end
                end
            end
        end
    end

    -- ══════════════════════════════════════
    --  SAVE / LOAD COLORS
    -- ══════════════════════════════════════
    local function saveColorSettings()
        pcall(function()
            ensureFolder()
            local col  = settings.colors
            local data = {
                bgColor      = {col.bgColor.R,     col.bgColor.G,     col.bgColor.B},
                textColor    = {col.textColor.R,   col.textColor.G,   col.textColor.B},
                strokeColor  = {col.strokeColor.R, col.strokeColor.G, col.strokeColor.B},
                accentColor  = {col.accentColor.R, col.accentColor.G, col.accentColor.B},
                transparency = settings.transparency,
                rgbAccent    = settings.rgbAccent,
                rgbStroke    = settings.rgbStroke,
            }
            writefile("MegaHack/colorSettings.json", HttpService:JSONEncode(data))
        end)
    end

    local function loadColorSettings()
        pcall(function()
            if isfile("MegaHack/colorSettings.json") then
                local raw  = readfile("MegaHack/colorSettings.json")
                local data = HttpService:JSONDecode(raw)
                if data.bgColor     then settings.colors.bgColor     = Color3.new(table.unpack(data.bgColor))     end
                if data.textColor   then settings.colors.textColor   = Color3.new(table.unpack(data.textColor))   end
                if data.strokeColor then settings.colors.strokeColor = Color3.new(table.unpack(data.strokeColor)) end
                if data.accentColor then settings.colors.accentColor = Color3.new(table.unpack(data.accentColor)) end
                if data.transparency ~= nil then settings.transparency = data.transparency end
                if data.rgbAccent   ~= nil then settings.rgbAccent   = data.rgbAccent     end
                if data.rgbStroke   ~= nil then settings.rgbStroke   = data.rgbStroke     end
            end
        end)
    end

    local function saveSettings()
        saveColorSettings()
        createNotification("SETTINGS", "Settings saved!", 3)
    end

    -- ══════════════════════════════════════
    --  CLEAR CONTENT
    -- ══════════════════════════════════════
    local function clearContent()
        for _, c in pairs(colorPickerConnections) do
            pcall(function() c:Disconnect() end)
        end
        colorPickerConnections = {}
        for _, child in ipairs(scrollingFrame:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end
    end

    -- ══════════════════════════════════════
    --  HELPERS
    -- ══════════════════════════════════════
    local function fmtTime(secs)
        secs = math.floor(secs)
        local h = math.floor(secs / 3600)
        local m = math.floor((secs % 3600) / 60)
        local s = secs % 60
        if h > 0 then
            return string.format("%dч %02dм", h, m)
        else
            return string.format("%02dм %02dс", m, s)
        end
    end

    local function fmtTimerLive(secs)
        secs = math.floor(secs)
        local h = math.floor(secs / 3600)
        local m = math.floor((secs % 3600) / 60)
        local s = secs % 60
        return string.format("%02d:%02d:%02d", h, m, s)
    end

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

    -- ══════════════════════════════════════
    --  SEARCH
    -- ══════════════════════════════════════
    local function searchScriptsByMegahack(query)
        local results = {}
        for categoryName, hacks in pairs(HubData) do
            if type(hacks) == "table" then
                for _, hack in ipairs(hacks) do
                    if type(hack)=="table" and hack[1] and type(hack[1])=="string" then
                        if string.find(string.lower(hack[1]), string.lower(query)) then
                            table.insert(results, {name=hack[1], category=categoryName, func=hack[2]})
                        end
                    end
                end
            end
        end
        return results
    end

    local function searchScriptsOnScriptBlox(query)
        local results = {}
        local ok, response = pcall(function()
            return HttpService:GetAsync("https://scriptblox.com/api/script/search?q=" .. HttpService:UrlEncode(query))
        end)
        if ok then
            local data = HttpService:JSONDecode(response)
            if data and data.result and data.result.scripts then
                for _, script in ipairs(data.result.scripts) do
                    table.insert(results, {name=script.title, category="ScriptBlox", scriptId=script._id})
                end
            end
        end
        return results
    end

    -- ══════════════════════════════════════
    --  LOAD CATEGORY
    -- ══════════════════════════════════════
    local function loadHacksFromCategory(categoryName)
        clearContent()
        local fileName = categoryMap[categoryName]
        if not fileName then
            createSectionHeader("Category not found", scrollingFrame)
            createLabel("⚠  No entry in base.lua for: " .. categoryName, scrollingFrame)
            return
        end
        if not HubData[categoryName] then
            local data = safeLoad(baseUrl .. "/" .. fileName)
            if type(data) == "table" and #data > 0 then
                HubData[categoryName] = data
            else
                createSectionHeader("Error loading", scrollingFrame)
                createLabel("⚠  Failed to load or empty: " .. categoryName, scrollingFrame)
                return
            end
        end
        createSectionHeader(categoryName, scrollingFrame)
        for _, hack in ipairs(HubData[categoryName]) do
            if type(hack)=="table" and hack[1] and type(hack[1])=="string"
               and hack[2] and type(hack[2])=="function" then
                createButton(hack[1], scrollingFrame, function()
                    local ok2, err = pcall(hack[2])
                    if not ok2 then
                        createNotification("ERROR", "Script error: " .. tostring(err), 5, 7733968497)
                    end
                end)
            end
        end
    end

    -- ══════════════════════════════════════
    --  SHOW ALL SCRIPTS
    -- ══════════════════════════════════════
    local function showAllScripts()
        clearContent()
        createSectionHeader("Search Scripts", scrollingFrame)

        local searchBox = Instance.new("TextBox")
        searchBox.Size                   = UDim2.new(1, 0, 0, 32)
        searchBox.BackgroundColor3       = T.BgPanel
        searchBox.BackgroundTransparency = 0.2
        searchBox.TextColor3             = T.TextMain
        searchBox.PlaceholderText        = "Search scripts..."
        searchBox.PlaceholderColor3      = T.TextMuted
        searchBox.TextSize               = 13
        searchBox.Text                   = ""
        searchBox.Font                   = Enum.Font.Gotham
        searchBox.ClearTextOnFocus       = false
        searchBox.ZIndex                 = 4
        searchBox.Parent                 = scrollingFrame
        searchBox:SetAttribute("TextRole", "main")
        mkCorner(searchBox, 7)
        mkStroke(searchBox, 1, T.Stroke, 0.3)
        local sbPad = Instance.new("UIPadding")
        sbPad.PaddingLeft = UDim.new(0, 10)
        sbPad.Parent      = searchBox

        local resultsLabel = createLabel("Type to search...", scrollingFrame)
        resultsLabel.TextColor3 = T.TextMuted

        local function updateSearchResults(query)
            for _, child in ipairs(scrollingFrame:GetChildren()) do
                if child ~= searchBox and child ~= resultsLabel
                   and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                    child:Destroy()
                end
            end
            if query == "" then resultsLabel.Text = "Type to search..."; return end
            resultsLabel.Text = "Searching..."
            local mhResults = searchScriptsByMegahack(query)
            local sbResults = searchScriptsOnScriptBlox(query)
            resultsLabel.Text = "Found " .. (#mhResults + #sbResults) .. " results"
            for _, r in ipairs(mhResults) do
                createButton(r.name .. "  [" .. r.category .. "]", scrollingFrame, function()
                    local ok2, e = pcall(r.func)
                    if not ok2 then createNotification("ERROR", tostring(e), 5, 7733968497) end
                end)
            end
            for _, r in ipairs(sbResults) do
                createButton(r.name .. "  [ScriptBlox]", scrollingFrame, function()
                    createNotification("INFO", "ScriptBlox ID: " .. r.scriptId, 5)
                end)
            end
        end

        searchBox.FocusLost:Connect(function() updateSearchResults(searchBox.Text) end)
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            if #searchBox.Text >= 3 then
                task.delay(0.5, function() updateSearchResults(searchBox.Text) end)
            end
        end)
    end

    -- ══════════════════════════════════════
    --  SHOW HOME
    -- ══════════════════════════════════════
    local function showHome()
        clearContent()
        createSectionHeader("Overview", scrollingFrame)

        local card = Instance.new("Frame")
        card.Size                   = UDim2.new(1, 0, 0, 90)
        card.BackgroundColor3       = T.BgPanel
        card.BackgroundTransparency = 0.15
        card.BorderSizePixel        = 0
        card.ZIndex                 = 4
        card.Parent                 = scrollingFrame
        mkCorner(card, 8)

        local ok2, thumbnail = pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
        end)
        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Size                   = UDim2.new(0, 64, 0, 64)
        avatarImg.Position               = UDim2.new(0, 12, 0.5, -32)
        avatarImg.BackgroundColor3       = T.BgSide
        avatarImg.BackgroundTransparency = 0
        avatarImg.Image                  = ok2 and thumbnail or ""
        avatarImg.ZIndex                 = 5
        avatarImg.Parent                 = card
        mkCorner(avatarImg, 32)

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text                   = player.Name
        nameLabel.Font                   = Enum.Font.GothamBold
        nameLabel.TextSize               = 15
        nameLabel.TextColor3             = T.TextMain
        nameLabel.TextXAlignment         = Enum.TextXAlignment.Left
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size                   = UDim2.new(1, -90, 0, 20)
        nameLabel.Position               = UDim2.new(0, 86, 0, 14)
        nameLabel.ZIndex                 = 5
        nameLabel.Parent                 = card
        nameLabel:SetAttribute("TextRole", "main")

        local uidLabel = Instance.new("TextLabel")
        uidLabel.Text                   = "UserID: " .. player.UserId
        uidLabel.Font                   = Enum.Font.Gotham
        uidLabel.TextSize               = 11
        uidLabel.TextColor3             = T.TextSub
        uidLabel.TextXAlignment         = Enum.TextXAlignment.Left
        uidLabel.BackgroundTransparency = 1
        uidLabel.Size                   = UDim2.new(1, -90, 0, 14)
        uidLabel.Position               = UDim2.new(0, 86, 0, 36)
        uidLabel.ZIndex                 = 5
        uidLabel.Parent                 = card

        local gameLabel = Instance.new("TextLabel")
        gameLabel.Text                   = "Game: " .. gui.gameName .. "  ·  PlaceId: " .. game.PlaceId
        gameLabel.Font                   = Enum.Font.Gotham
        gameLabel.TextSize               = 10
        gameLabel.TextColor3             = T.TextMuted
        gameLabel.TextXAlignment         = Enum.TextXAlignment.Left
        gameLabel.BackgroundTransparency = 1
        gameLabel.Size                   = UDim2.new(1, -90, 0, 14)
        gameLabel.Position               = UDim2.new(0, 86, 0, 52)
        gameLabel.ZIndex                 = 5
        gameLabel.Parent                 = card

        local platformLabel = Instance.new("TextLabel")
        platformLabel.Text                   = platformName
        platformLabel.Font                   = Enum.Font.GothamBold
        platformLabel.TextSize               = 10
        platformLabel.TextColor3             = T.AccentGlow
        platformLabel.TextXAlignment         = Enum.TextXAlignment.Left
        platformLabel.BackgroundTransparency = 1
        platformLabel.Size                   = UDim2.new(0, 60, 0, 14)
        platformLabel.Position               = UDim2.new(0, 86, 0, 68)
        platformLabel.ZIndex                 = 5
        platformLabel.Parent                 = card

        local fpsCard = Instance.new("Frame")
        fpsCard.Size                   = UDim2.new(1, 0, 0, 32)
        fpsCard.BackgroundColor3       = T.BgPanel
        fpsCard.BackgroundTransparency = 0.2
        fpsCard.BorderSizePixel        = 0
        fpsCard.ZIndex                 = 4
        fpsCard.Parent                 = scrollingFrame
        mkCorner(fpsCard, 7)

        local fpsLabel = Instance.new("TextLabel")
        fpsLabel.Text                   = "FPS: Calculating..."
        fpsLabel.Font                   = Enum.Font.Gotham
        fpsLabel.TextSize               = 12
        fpsLabel.TextColor3             = T.TextMain
        fpsLabel.TextXAlignment         = Enum.TextXAlignment.Left
        fpsLabel.BackgroundTransparency = 1
        fpsLabel.Size                   = UDim2.new(1, -16, 1, 0)
        fpsLabel.Position               = UDim2.new(0, 16, 0, 0)
        fpsLabel.ZIndex                 = 5
        fpsLabel.Parent                 = fpsCard
        fpsLabel:SetAttribute("TextRole", "main")

        local lastTime, frameCount = tick(), 0
        RunService.Heartbeat:Connect(function()
            frameCount = frameCount + 1
            local cur  = tick()
            if cur - lastTime >= 1 then
                fpsLabel.Text = "FPS: " .. frameCount
                frameCount = 0; lastTime = cur
            end
        end)

        createSectionHeader("Social", scrollingFrame)
        createLabel("YouTube  ·  https://www.youtube.com/@Vermax",       scrollingFrame)
        createLabel("Telegram  ·  https://t.me/@vermax",                 scrollingFrame)
        createLabel("Discord  ·  https://discord.com/invite/vermax",     scrollingFrame)
    end

    -- ══════════════════════════════════════
    --  SHOW STATS
    -- ══════════════════════════════════════
    local function showStats()
        clearContent()

        -- ── 1. Session timer card ────────────────────────────────────────
        createSectionHeader("Stats", scrollingFrame)

        local sessionCard = mkFrame(scrollingFrame, UDim2.new(1,0,0,72), nil, T.BgPanel, 0.1, 4)
        mkCorner(sessionCard, 8)
        mkStroke(sessionCard, 1, T.Stroke, 0.3)

        local sessIconLbl = mkLabel(sessionCard,
            "🔥 " .. tostring(statsData.totalSessions) .. " sessions",
            UDim2.new(0,130,0,18), UDim2.new(0,8,0,6),
            T.Accent, Enum.TextXAlignment.Left, Enum.Font.GothamBold, 11, 5)

        local timerLbl = mkLabel(sessionCard,
            "Session: " .. fmtTimerLive(tick() - statsData.sessionStart),
            UDim2.new(1,-140,0,22), UDim2.new(0,8,0,26),
            T.TextMain, Enum.TextXAlignment.Left, Enum.Font.GothamBold, 14, 5)
        timerLbl:SetAttribute("TextRole","main")

        local totalLbl = mkLabel(sessionCard,
            "Total: " .. fmtTime(statsData.totalSeconds),
            UDim2.new(0,140,0,16), UDim2.new(0,8,0,50),
            T.TextSub, Enum.TextXAlignment.Left, Enum.Font.Gotham, 11, 5)

        local streakLbl = mkLabel(sessionCard,
            "🔥 Streak: " .. tostring(statsData.streak) .. " days",
            UDim2.new(0,110,0,16), UDim2.new(1,-118,0,50),
            T.AccentGlow, Enum.TextXAlignment.Right, Enum.Font.GothamBold, 11, 5)

        local finBtn = Instance.new("TextButton")
        finBtn.Size                   = UDim2.new(0,110,0,22)
        finBtn.Position               = UDim2.new(1,-118,0,4)
        finBtn.BackgroundColor3       = T.Accent
        finBtn.BackgroundTransparency = 0.35
        finBtn.BorderSizePixel        = 0
        finBtn.Text                   = "End Session"
        finBtn.TextColor3             = T.TextMain
        finBtn.TextSize               = 11
        finBtn.Font                   = Enum.Font.GothamBold
        finBtn.ZIndex                 = 5
        finBtn.Parent                 = sessionCard
        finBtn:SetAttribute("TextRole","main")
        mkCorner(finBtn, 5)
        mkStroke(finBtn, 1, T.Accent, 0.4)
        finBtn.MouseButton1Click:Connect(function()
            finishCurrentSession()
            startSessionTimer()
            createNotification("STATS", "Session saved!", 3, 7733960981)
            sessIconLbl.Text = "🔥 " .. tostring(statsData.totalSessions) .. " sessions"
            totalLbl.Text    = "Total: " .. fmtTime(statsData.totalSeconds)
            streakLbl.Text   = "🔥 Streak: " .. tostring(statsData.streak) .. " days"
        end)

        local timerRunning = true
        task.spawn(function()
            while timerRunning do
                task.wait(1)
                if not sessionCard.Parent then timerRunning = false; break end
                timerLbl.Text = "Session: " .. fmtTimerLive(tick() - statsData.sessionStart)
            end
        end)
        sessionCard.AncestryChanged:Connect(function()
            if not sessionCard.Parent then timerRunning = false end
        end)

        -- ── 2. Overview mini cards ───────────────────────────────────────
        createSectionHeader("Overview", scrollingFrame)

        local miniRow = mkFrame(scrollingFrame, UDim2.new(1,0,0,54), nil, Color3.new(0,0,0), 1, 4)
        local miniLayout = Instance.new("UIListLayout")
        miniLayout.FillDirection = Enum.FillDirection.Horizontal
        miniLayout.Padding       = UDim.new(0,6)
        miniLayout.SortOrder     = Enum.SortOrder.LayoutOrder
        miniLayout.Parent        = miniRow

        local avgSessionStr = "—"
        if statsData.totalSessions > 0 then
            avgSessionStr = fmtTime(statsData.totalSeconds / statsData.totalSessions)
        end

        local miniData = {
            {"⏱ Hours",    string.format("%.1f", statsData.totalSeconds / 3600)},
            {"🎮 Sessions", tostring(statsData.totalSessions)},
            {"⌀ Avg session", avgSessionStr},
        }
        for i, md in ipairs(miniData) do
            local mc = mkFrame(miniRow, UDim2.new(1/3,-4,1,0), nil, T.BgPanel, 0.1, 5)
            mc.LayoutOrder = i
            mkCorner(mc, 7)
            mkStroke(mc, 1, T.Stroke, 0.35)
            mkLabel(mc, md[1], UDim2.new(1,0,0,14), UDim2.new(0,0,0,6),
                T.TextMuted, Enum.TextXAlignment.Center, Enum.Font.Gotham, 10, 6)
            local vl = mkLabel(mc, md[2], UDim2.new(1,0,0,22), UDim2.new(0,0,0,22),
                T.TextMain, Enum.TextXAlignment.Center, Enum.Font.GothamBold, 14, 6)
            vl:SetAttribute("TextRole","main")
        end

        -- ── 3. Heatmap by day of week ────────────────────────────────────
        createSectionHeader("Activity by day of week", scrollingFrame)

        local heatCard = mkFrame(scrollingFrame, UDim2.new(1,0,0,68), nil, T.BgPanel, 0.1, 4)
        mkCorner(heatCard, 8)
        mkStroke(heatCard, 1, T.Stroke, 0.3)

        local dayNames = {"Mon","Tue","Wed","Thu","Fri","Sat","Sun"}

        local maxDay = 1
        for i = 1, 7 do
            local v = statsData.daySeconds[tostring(i)] or 0
            if v > maxDay then maxDay = v end
        end

        for i = 1, 7 do
            local secs  = statsData.daySeconds[tostring(i)] or 0
            local ratio = math.clamp(secs / maxDay, 0, 1)

            local dayNameLbl = Instance.new("TextLabel")
            dayNameLbl.Text                   = dayNames[i]
            dayNameLbl.Size                   = UDim2.new(0, 28, 0, 14)
            dayNameLbl.Position               = UDim2.new(0, 8 + (i-1)*34, 0, 4)
            dayNameLbl.BackgroundTransparency = 1
            dayNameLbl.TextColor3             = T.TextMuted
            dayNameLbl.TextSize               = 10
            dayNameLbl.Font                   = Enum.Font.Gotham
            dayNameLbl.TextXAlignment         = Enum.TextXAlignment.Center
            dayNameLbl.ZIndex                 = 5
            dayNameLbl.Parent                 = heatCard

            local cellH = math.floor(6 + ratio * 30)
            local cellF = mkFrame(heatCard,
                UDim2.new(0, 28, 0, cellH),
                UDim2.new(0, 8 + (i-1)*34, 0, 46 - cellH + 4),
                T.Accent, (1 - 0.3 - ratio * 0.55), 5)
            mkCorner(cellF, 4)

            local timeLbl = Instance.new("TextLabel")
            timeLbl.Text                   = (secs > 0) and fmtTime(secs) or "0m"
            timeLbl.Size                   = UDim2.new(0,42,0,12)
            timeLbl.Position               = UDim2.new(0, 8 + (i-1)*34 - 7, 0, 52)
            timeLbl.BackgroundTransparency = 1
            timeLbl.TextColor3             = T.TextSub
            timeLbl.TextSize               = 9
            timeLbl.Font                   = Enum.Font.Gotham
            timeLbl.TextXAlignment         = Enum.TextXAlignment.Center
            timeLbl.ZIndex                 = 5
            timeLbl.Parent                 = heatCard
        end

        -- ── 4. Donut chart: most used tabs ───────────────────────────────
        createSectionHeader("Most used tabs", scrollingFrame)

        local tabList = {}
        for name, cnt in pairs(statsData.tabClicks) do
            table.insert(tabList, {name=name, cnt=cnt})
        end
        table.sort(tabList, function(a,b) return a.cnt > b.cnt end)

        local donutCard = mkFrame(scrollingFrame, UDim2.new(1,0,0,120), nil, T.BgPanel, 0.1, 4)
        mkCorner(donutCard, 8)
        mkStroke(donutCard, 1, T.Stroke, 0.3)

        if #tabList == 0 then
            mkLabel(donutCard, "No data yet — open some tabs!",
                UDim2.new(1,0,1,0), UDim2.new(0,0,0,0),
                T.TextMuted, Enum.TextXAlignment.Center, Enum.Font.Gotham, 11, 5)
        else
            local palette = {
                T.Accent,
                T.AccentHov,
                T.AccentGlow,
                Color3.new(math.min(T.Accent.R*0.6,1), math.min(T.Accent.G*0.6,1), math.min(T.Accent.B*0.6,1)),
                Color3.new(math.min(T.Accent.R*0.4,1), math.min(T.Accent.G*0.4,1), math.min(T.Accent.B*0.4,1)),
            }

            local total = 0
            for _, t in ipairs(tabList) do total = total + t.cnt end
            if total == 0 then total = 1 end

            local topPct = tabList[1] and math.floor(tabList[1].cnt / total * 100) or 0
            local ringW, ringH = 90, 90

            local ringOuter = mkFrame(donutCard,
                UDim2.new(0, ringW, 0, ringH),
                UDim2.new(0, 8, 0.5, -ringH/2),
                T.Accent, 0.75, 5)
            mkCorner(ringOuter, ringW/2)

            local segContainer = mkFrame(donutCard,
                UDim2.new(0, ringW, 0, ringH),
                UDim2.new(0, 8, 0.5, -ringH/2),
                Color3.new(0,0,0), 1, 5)

            local top5 = {}
            for i=1, math.min(5,#tabList) do top5[i]=tabList[i] end

            local angle = 0
            for idx, t in ipairs(top5) do
                local sweep = (t.cnt / total) * 360
                local seg = Instance.new("Frame")
                seg.Size                   = UDim2.new(1,0,1,0)
                seg.BackgroundColor3       = palette[idx] or T.Accent
                seg.BackgroundTransparency = 0.3
                seg.BorderSizePixel        = 0
                seg.ZIndex                 = 5 + idx
                seg.ClipsDescendants       = true
                seg.Parent                 = segContainer
                local rotFrame = Instance.new("Frame")
                rotFrame.Size                   = UDim2.new(0.5,0,1,0)
                rotFrame.Position               = UDim2.new(0.5,0,0,0)
                rotFrame.BackgroundColor3       = palette[idx] or T.Accent
                rotFrame.BackgroundTransparency = 0
                rotFrame.BorderSizePixel        = 0
                rotFrame.Rotation               = angle
                rotFrame.ZIndex                 = 5 + idx
                rotFrame.Parent                 = segContainer
                angle = angle + sweep
            end

            local cutout = mkFrame(donutCard,
                UDim2.new(0, ringW-28, 0, ringH-28),
                UDim2.new(0, 8+14, 0.5, -(ringH-28)/2),
                T.BgPanel, 0.08, 9)
            mkCorner(cutout, (ringW-28)/2)

            mkLabel(cutout, topPct .. "%",
                UDim2.new(1,0,0,20), UDim2.new(0,0,0.5,-20),
                T.Accent, Enum.TextXAlignment.Center, Enum.Font.GothamBold, 14, 10)
            mkLabel(cutout, "top",
                UDim2.new(1,0,0,14), UDim2.new(0,0,0.5,2),
                T.TextMuted, Enum.TextXAlignment.Center, Enum.Font.Gotham, 9, 10)

            local legendX = ringW + 24
            for idx, t in ipairs(top5) do
                local pct = math.floor(t.cnt / total * 100)
                local dot = mkFrame(donutCard,
                    UDim2.new(0,8,0,8),
                    UDim2.new(0, legendX, 0, 10 + (idx-1)*20),
                    palette[idx] or T.Accent, 0, 6)
                mkCorner(dot, 2)
                local nm = t.name
                if #nm > 14 then nm = nm:sub(1,13) .. "…" end
                mkLabel(donutCard,
                    nm .. "  " .. pct .. "%",
                    UDim2.new(1, -(legendX+16), 0, 14),
                    UDim2.new(0, legendX+14, 0, 8 + (idx-1)*20),
                    T.TextMain, Enum.TextXAlignment.Left, Enum.Font.Gotham, 11, 6)
            end
        end

        -- ── 5. Top tabs bar chart ────────────────────────────────────────
        createSectionHeader("Top tabs", scrollingFrame)

        if #tabList == 0 then
            createLabel("Open some tabs — stats will appear here", scrollingFrame)
        else
            local total2 = 0
            for _, t in ipairs(tabList) do total2 = total2 + t.cnt end
            if total2 == 0 then total2 = 1 end

            for i=1, math.min(8, #tabList) do
                local t   = tabList[i]
                local pct = t.cnt / total2

                local barCard = mkFrame(scrollingFrame, UDim2.new(1,0,0,30), nil, T.BgPanel, 0.15, 4)
                mkCorner(barCard, 6)

                local nm = t.name
                if #nm > 18 then nm = nm:sub(1,17) .. "…" end
                mkLabel(barCard, nm,
                    UDim2.new(0,100,1,0), UDim2.new(0,8,0,0),
                    T.TextMain, Enum.TextXAlignment.Left, Enum.Font.Gotham, 11, 5)
                barCard:FindFirstChildOfClass("TextLabel"):SetAttribute("TextRole","main")

                local track = mkFrame(barCard,
                    UDim2.new(1,-145,0,8),
                    UDim2.new(0,112,0.5,-4),
                    T.BgBtn, 0.1, 5)
                mkCorner(track, 4)

                local fill = mkFrame(track,
                    UDim2.new(0,0,1,0),
                    UDim2.new(0,0,0,0),
                    T.Accent, 0.2, 6)
                mkCorner(fill, 4)
                TweenService:Create(fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(pct,0,1,0)
                }):Play()

                mkLabel(barCard,
                    tostring(t.cnt) .. " clicks",
                    UDim2.new(0,44,1,0), UDim2.new(1,-46,0,0),
                    T.TextSub, Enum.TextXAlignment.Right, Enum.Font.Gotham, 10, 5)
            end
        end

        -- ── 6. Controls ──────────────────────────────────────────────────
        createSectionHeader("Controls", scrollingFrame)
        createButton("Reset all stats", scrollingFrame, function()
            statsData.totalSeconds  = 0
            statsData.totalSessions = 0
            statsData.tabClicks     = {}
            statsData.daySeconds    = {}
            statsData.streak        = 0
            statsData.lastDayPlayed = 0
            statsData.sessionStart  = tick()
            saveStats()
            createNotification("STATS", "Stats reset!", 3, 7733968497)
            clearContent(); showStats(); updateGuiColors()
        end)
    end

    -- ══════════════════════════════════════
    --  UTILITIES
    -- ══════════════════════════════════════
    local function checkFunctions()
        local list = {
            "getrawmetatable","makefolder","getscriptbytecode","setthreadidentity","delfile","request",
            "isscriptable","iscclosure","lz4compress","getscripts","isfolder","sethiddenproperty",
            "getthreadidentity","readfile","getscriptclosure","delfolder","setscriptable","Drawing.new",
            "hookmetamethod","getrunningscripts","checkcaller","setrawmetatable","gethiddenproperty",
            "writefile","setrenderproperty","getnamecallmethod","isfile","fireclickdetector",
            "getnilinstances","getcustomasset","islclosure","loadstring","cache.iscached",
            "cache.invalidate","cloneref","cache.replace","getgc","compareinstances","getrenv",
            "hookfunction","setreadonly","getloadedmodules","fireproximityprompt","WebSocket.connect",
            "listfiles","gethui","isreadonly","getrenderproperty","lz4decompress","appendfile",
            "loadfile","getinstances","isexecutorclosure","getcallbackvalue","identifyexecutor",
            "firetouchinterest","getcallingscript","getsenv","clonefunction","getgenv","newcclosure",
            "getconnections","restorefunction",
        }
        local available, unavailable = {}, {}
        for _, funcName in ipairs(list) do
            local s = pcall(function()
                if funcName:find("%.") then
                    local parts = string.split(funcName, ".")
                    local obj = _G
                    for i, p in ipairs(parts) do
                        if i == #parts then
                            if obj[p] ~= nil then return true end
                        else
                            obj = obj[p]
                            if obj == nil then return false end
                        end
                    end
                else
                    return _G[funcName] ~= nil
                end
            end)
            if s then table.insert(available, funcName)
            else table.insert(unavailable, funcName) end
        end
        return available, unavailable
    end

    local function setupAntiBanKick()
        local mt = getrawmetatable(game)
        if mt then
            local oldNamecall = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "Kick" or method == "kick" then
                    createNotification("ANTI-KICK", "Kick attempt blocked", 3, 7733960981); return nil
                end
                if method == "Ban" or method == "ban" then
                    createNotification("ANTI-BAN",  "Ban attempt blocked",  3, 7733960981); return nil
                end
                return oldNamecall(self, ...)
            end)
            setreadonly(mt, true)
        end
        createNotification("PROTECTION", "Anti-Ban/Anti-Kick enabled", 3, 7733960981)
    end

    local function saveCoordinates()
        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart  = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local pos = rootPart.Position
            local txt = string.format("X: %.2f, Y: %.2f, Z: %.2f", pos.X, pos.Y, pos.Z)
            ensureFolder()
            writefile("MegaHack/coordinates.txt", txt)
            createNotification("SAVED", txt, 4, 7733960981)
        else
            createNotification("ERROR", "No HumanoidRootPart found", 3, 7733968497)
        end
    end

    local function teleportToCoordinates()
        if isfile("MegaHack/coordinates.txt") then
            local txt   = readfile("MegaHack/coordinates.txt")
            local x,y,z = txt:match("X: ([%d%.%-]+), Y: ([%d%.%-]+), Z: ([%d%.%-]+)")
            if x and y and z then
                local character = player.Character or player.CharacterAdded:Wait()
                local rootPart  = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
                    createNotification("TELEPORT", "Teleported to saved coordinates", 3, 7733960981)
                end
            else
                createNotification("ERROR", "Invalid coordinates format", 3, 7733968497)
            end
        else
            createNotification("ERROR", "No saved coordinates found", 3, 7733968497)
        end
    end

    -- ══════════════════════════════════════
    --  COLOR PICKER
    -- ══════════════════════════════════════
    local function createColorPicker(parent)
        local selType          = "bgColor"
        local curH, curS, curV = Color3.toHSV(settings.colors.bgColor)
        local curR = math.floor(settings.colors.bgColor.R * 255 + 0.5)
        local curG = math.floor(settings.colors.bgColor.G * 255 + 0.5)
        local curB = math.floor(settings.colors.bgColor.B * 255 + 0.5)

        local function syncFromType()
            local col  = settings.colors[selType]
            curH, curS, curV = Color3.toHSV(col)
            curR = math.floor(col.R * 255 + 0.5)
            curG = math.floor(col.G * 255 + 0.5)
            curB = math.floor(col.B * 255 + 0.5)
        end

        local container = Instance.new("Frame")
        container.BackgroundTransparency = 1
        container.Size   = UDim2.new(1, 0, 0, 340)
        container.ZIndex = 4
        container.Parent = parent

        local innerLayout = Instance.new("UIListLayout")
        innerLayout.Padding   = UDim.new(0, 6)
        innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        innerLayout.Parent    = container
        innerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.Size = UDim2.new(1, 0, 0, innerLayout.AbsoluteContentSize.Y + 4)
        end)

        local typeRow = Instance.new("Frame")
        typeRow.BackgroundTransparency = 1
        typeRow.Size        = UDim2.new(1, 0, 0, 28)
        typeRow.LayoutOrder = 1
        typeRow.ZIndex      = 4
        typeRow.Parent      = container
        local typeRowLayout = Instance.new("UIListLayout")
        typeRowLayout.FillDirection = Enum.FillDirection.Horizontal
        typeRowLayout.Padding       = UDim.new(0, 4)
        typeRowLayout.SortOrder     = Enum.SortOrder.LayoutOrder
        typeRowLayout.Parent        = typeRow

        local typeBtnMap = {}
        local typeItems  = {
            {label="BG Color", key="bgColor"},
            {label="Text",     key="textColor"},
            {label="Stroke",   key="strokeColor"},
            {label="Accent",   key="accentColor"},
        }
        local updatePickerUI

        local function refreshTypeBtns(activeKey)
            for _, td in ipairs(typeItems) do
                local b = typeBtnMap[td.key]
                if b then
                    if td.key == activeKey then
                        b.BackgroundColor3 = T.Accent; b.BackgroundTransparency = 0.15; b.TextColor3 = T.TextMain
                    else
                        b.BackgroundColor3 = T.BgBtn;  b.BackgroundTransparency = 0.3;  b.TextColor3 = T.TextSub
                    end
                end
            end
        end

        for i, td in ipairs(typeItems) do
            local btn = Instance.new("TextButton")
            btn.Size                   = UDim2.new(1/4, -3, 1, 0)
            btn.BackgroundColor3       = T.BgBtn
            btn.BackgroundTransparency = 0.3
            btn.BorderSizePixel        = 0
            btn.Text                   = td.label
            btn.TextColor3             = T.TextSub
            btn.TextSize               = 11
            btn.Font                   = Enum.Font.GothamBold
            btn.LayoutOrder            = i
            btn.ZIndex                 = 5
            btn.Parent                 = typeRow
            mkCorner(btn, 5); mkStroke(btn, 1, T.Stroke, 0.35)
            typeBtnMap[td.key] = btn
            btn.MouseButton1Click:Connect(function()
                selType = td.key; syncFromType(); refreshTypeBtns(selType)
                if updatePickerUI then updatePickerUI() end
            end)
        end
        refreshTypeBtns(selType)

        local sqSz    = 148
        local mainArea = Instance.new("Frame")
        mainArea.BackgroundTransparency = 1
        mainArea.Size        = UDim2.new(1, 0, 0, sqSz)
        mainArea.LayoutOrder = 2
        mainArea.ZIndex      = 4
        mainArea.Parent      = container

        local svBase = Instance.new("Frame")
        svBase.Size             = UDim2.new(0, sqSz, 0, sqSz)
        svBase.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
        svBase.BorderSizePixel  = 0
        svBase.ZIndex           = 5
        svBase.Parent           = mainArea
        mkCorner(svBase, 5); mkStroke(svBase, 1, T.Stroke, 0.3)

        local whiteOv = Instance.new("Frame")
        whiteOv.Size = UDim2.new(1,0,1,0); whiteOv.BackgroundColor3 = Color3.new(1,1,1)
        whiteOv.BorderSizePixel = 0; whiteOv.ZIndex = 6; whiteOv.Parent = svBase
        mkCorner(whiteOv, 5)
        local wg = Instance.new("UIGradient")
        wg.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1))
        wg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})
        wg.Parent = whiteOv

        local blackOv = Instance.new("Frame")
        blackOv.Size = UDim2.new(1,0,1,0); blackOv.BackgroundColor3 = Color3.new(0,0,0)
        blackOv.BorderSizePixel = 0; blackOv.ZIndex = 7; blackOv.Parent = svBase
        mkCorner(blackOv, 5)
        local bg2 = Instance.new("UIGradient")
        bg2.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0))
        bg2.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})
        bg2.Rotation = 90; bg2.Parent = blackOv

        local svCursor = Instance.new("Frame")
        svCursor.Size             = UDim2.new(0,10,0,10)
        svCursor.AnchorPoint      = Vector2.new(0.5, 0.5)
        svCursor.Position         = UDim2.new(curS, 0, 1-curV, 0)
        svCursor.BackgroundColor3 = Color3.new(1,1,1)
        svCursor.BorderSizePixel  = 0
        svCursor.ZIndex           = 9
        svCursor.Parent           = svBase
        mkCorner(svCursor, 5); mkStroke(svCursor, 2, Color3.new(0.1,0.1,0.1), 0)

        local rightPanel = Instance.new("Frame")
        rightPanel.BackgroundTransparency = 1
        rightPanel.Size     = UDim2.new(1, -(sqSz+8), 1, 0)
        rightPanel.Position = UDim2.new(0, sqSz+8, 0, 0)
        rightPanel.ZIndex   = 4; rightPanel.Parent = mainArea

        local previewSwatch = Instance.new("Frame")
        previewSwatch.Size             = UDim2.new(1,0,0,52)
        previewSwatch.BackgroundColor3 = settings.colors[selType]
        previewSwatch.BorderSizePixel  = 0; previewSwatch.ZIndex = 5; previewSwatch.Parent = rightPanel
        mkCorner(previewSwatch, 6); mkStroke(previewSwatch, 1, T.Stroke, 0.3)

        local previewLbl = Instance.new("TextLabel")
        previewLbl.BackgroundTransparency = 1; previewLbl.Text = "PREVIEW"
        previewLbl.Font = Enum.Font.GothamBold; previewLbl.TextSize = 9
        previewLbl.TextColor3 = Color3.new(1,1,1); previewLbl.TextTransparency = 0.45
        previewLbl.Size = UDim2.new(1,0,1,0); previewLbl.ZIndex = 6; previewLbl.Parent = previewSwatch

        local hexRow = Instance.new("Frame")
        hexRow.Size = UDim2.new(1,0,0,26); hexRow.Position = UDim2.new(0,0,0,58)
        hexRow.BackgroundColor3 = T.BgPanel; hexRow.BackgroundTransparency = 0.15
        hexRow.BorderSizePixel = 0; hexRow.ZIndex = 5; hexRow.Parent = rightPanel
        mkCorner(hexRow, 5); mkStroke(hexRow, 1, T.Stroke, 0.3)

        local hashLbl = Instance.new("TextLabel")
        hashLbl.Size = UDim2.new(0,18,1,0); hashLbl.Position = UDim2.new(0,2,0,0)
        hashLbl.BackgroundTransparency = 1; hashLbl.Text = "#"; hashLbl.TextColor3 = T.TextSub
        hashLbl.TextSize = 12; hashLbl.Font = Enum.Font.GothamBold; hashLbl.ZIndex = 6; hashLbl.Parent = hexRow

        local hexBox = Instance.new("TextBox")
        hexBox.Size = UDim2.new(1,-20,1,0); hexBox.Position = UDim2.new(0,20,0,0)
        hexBox.BackgroundTransparency = 1; hexBox.TextColor3 = T.TextMain; hexBox.TextSize = 11
        hexBox.Font = Enum.Font.Code; hexBox.PlaceholderText = "RRGGBB"
        hexBox.PlaceholderColor3 = T.TextMuted; hexBox.Text = ""
        hexBox.ClearTextOnFocus = false; hexBox.ZIndex = 6; hexBox.Parent = hexRow
        hexBox:SetAttribute("TextRole", "main")

        local rgbReadouts = {}
        local channelNames = {"R", "G", "B"}
        for i, nm in ipairs(channelNames) do
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1,0,0,15); lbl.Position = UDim2.new(0,0,0,90+(i-1)*18)
            lbl.BackgroundTransparency = 1; lbl.Text = nm..": 0"; lbl.TextColor3 = T.TextSub
            lbl.TextSize = 11; lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5; lbl.Parent = rightPanel
            rgbReadouts[i] = lbl
        end

        local hueTrack = Instance.new("Frame")
        hueTrack.Size = UDim2.new(1,0,0,16); hueTrack.BackgroundColor3 = Color3.new(1,0,0)
        hueTrack.BorderSizePixel = 0; hueTrack.LayoutOrder = 3; hueTrack.ZIndex = 5; hueTrack.Parent = container
        mkCorner(hueTrack, 4); mkStroke(hueTrack, 1, T.Stroke, 0.3)
        local hueGrad = Instance.new("UIGradient")
        hueGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0/6, Color3.fromHSV(0/6,1,1)),
            ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6,1,1)),
            ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6,1,1)),
            ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6,1,1)),
            ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6,1,1)),
            ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6,1,1)),
            ColorSequenceKeypoint.new(6/6, Color3.fromHSV(6/6,1,1)),
        })
        hueGrad.Parent = hueTrack

        local hueCursor = Instance.new("Frame")
        hueCursor.Size = UDim2.new(0,6,1,4); hueCursor.AnchorPoint = Vector2.new(0.5,0.5)
        hueCursor.Position = UDim2.new(curH,0,0.5,0); hueCursor.BackgroundColor3 = Color3.new(1,1,1)
        hueCursor.BorderSizePixel = 0; hueCursor.ZIndex = 6; hueCursor.Parent = hueTrack
        mkCorner(hueCursor, 3); mkStroke(hueCursor, 1, T.Stroke, 0)

        local rgbTracks, rgbCursors, rgbValLbls = {}, {}, {}
        local rgbPureCol = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1)}
        for i, nm in ipairs(channelNames) do
            local slot = Instance.new("Frame")
            slot.BackgroundTransparency = 1; slot.Size = UDim2.new(1,0,0,22)
            slot.LayoutOrder = 3+i; slot.ZIndex = 4; slot.Parent = container

            local nmLbl = Instance.new("TextLabel")
            nmLbl.Size = UDim2.new(0,14,1,0); nmLbl.BackgroundTransparency = 1; nmLbl.Text = nm
            nmLbl.TextColor3 = T.TextSub; nmLbl.TextSize = 11; nmLbl.Font = Enum.Font.GothamBold
            nmLbl.ZIndex = 5; nmLbl.Parent = slot

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1,-52,0,12); track.Position = UDim2.new(0,18,0.5,-6)
            track.BackgroundColor3 = Color3.new(0,0,0); track.BorderSizePixel = 0
            track.ZIndex = 5; track.Parent = slot
            mkCorner(track, 4); mkStroke(track, 1, T.Stroke, 0.3)
            local tg = Instance.new("UIGradient")
            tg.Color = ColorSequence.new(Color3.new(0,0,0), rgbPureCol[i]); tg.Parent = track

            local cur = Instance.new("Frame")
            cur.Size = UDim2.new(0,8,1,4); cur.AnchorPoint = Vector2.new(0.5,0.5)
            cur.Position = UDim2.new(0,0,0.5,0); cur.BackgroundColor3 = Color3.new(1,1,1)
            cur.BorderSizePixel = 0; cur.ZIndex = 6; cur.Parent = track
            mkCorner(cur, 4); mkStroke(cur, 1, T.Stroke, 0)

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0,30,1,0); valLbl.Position = UDim2.new(1,-30,0,0)
            valLbl.BackgroundTransparency = 1; valLbl.Text = "0"; valLbl.TextColor3 = T.TextMain
            valLbl.TextSize = 11; valLbl.Font = Enum.Font.Gotham
            valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.ZIndex = 5; valLbl.Parent = slot
            valLbl:SetAttribute("TextRole","main")

            rgbTracks[i]=track; rgbCursors[i]=cur; rgbValLbls[i]=valLbl
        end

        local applyBtn = Instance.new("TextButton")
        applyBtn.Size = UDim2.new(1,0,0,30); applyBtn.BackgroundColor3 = T.Accent
        applyBtn.BackgroundTransparency = 0.15; applyBtn.BorderSizePixel = 0
        applyBtn.Text = "✔  Apply & Save"; applyBtn.TextColor3 = T.TextMain
        applyBtn.TextSize = 13; applyBtn.Font = Enum.Font.GothamBold
        applyBtn.LayoutOrder = 7; applyBtn.ZIndex = 5; applyBtn.Parent = container
        applyBtn:SetAttribute("TextRole","main")
        mkCorner(applyBtn, 6); mkStroke(applyBtn, 1, T.Accent, 0.35)
        applyBtn.MouseEnter:Connect(function()
            TweenService:Create(applyBtn, TweenInfo.new(0.15), {BackgroundTransparency=0}):Play()
        end)
        applyBtn.MouseLeave:Connect(function()
            TweenService:Create(applyBtn, TweenInfo.new(0.15), {BackgroundTransparency=0.15}):Play()
        end)

        updatePickerUI = function()
            local col = Color3.fromHSV(curH, curS, curV)
            svBase.BackgroundColor3        = Color3.fromHSV(curH, 1, 1)
            svCursor.Position              = UDim2.new(curS, 0, 1-curV, 0)
            hueCursor.Position             = UDim2.new(curH, 0, 0.5, 0)
            previewSwatch.BackgroundColor3 = col
            curR = math.floor(col.R*255+0.5)
            curG = math.floor(col.G*255+0.5)
            curB = math.floor(col.B*255+0.5)
            hexBox.Text = string.format("%02X%02X%02X", curR, curG, curB)
            rgbReadouts[1].Text = "R: "..curR
            rgbReadouts[2].Text = "G: "..curG
            rgbReadouts[3].Text = "B: "..curB
            local vals = {curR/255, curG/255, curB/255}
            for i = 1, 3 do
                rgbCursors[i].Position = UDim2.new(vals[i], 0, 0.5, 0)
                rgbValLbls[i].Text     = tostring(math.floor(vals[i]*255+0.5))
            end
        end
        updatePickerUI()

        applyBtn.MouseButton1Click:Connect(function()
            settings.colors[selType] = Color3.fromHSV(curH, curS, curV)
            updateGuiColors(); saveColorSettings()
            createNotification("COLOR PICKER","Color applied & saved!",2,74283928898866)
            TweenService:Create(applyBtn, TweenInfo.new(0.08), {BackgroundColor3=T.AccentGlow, BackgroundTransparency=0}):Play()
            task.delay(0.18, function()
                TweenService:Create(applyBtn, TweenInfo.new(0.2), {BackgroundColor3=T.Accent, BackgroundTransparency=0.15}):Play()
            end)
        end)

        local draggingSV, draggingHue, draggingRGB = false, false, 0
        local c1 = svBase.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then draggingSV=true end
        end)
        local c2 = hueTrack.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then draggingHue=true end
        end)
        for i = 1, 3 do
            local ci = rgbTracks[i].InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then draggingRGB=i end
            end)
            table.insert(colorPickerConnections, ci)
        end
        table.insert(colorPickerConnections, c1)
        table.insert(colorPickerConnections, c2)

        local moveConn = UserInputService.InputChanged:Connect(function(inp)
            if inp.UserInputType~=Enum.UserInputType.MouseMovement and inp.UserInputType~=Enum.UserInputType.Touch then return end
            if draggingSV then
                local ap=svBase.AbsolutePosition; local as=svBase.AbsoluteSize
                curS=math.clamp((inp.Position.X-ap.X)/as.X,0,1)
                curV=1-math.clamp((inp.Position.Y-ap.Y)/as.Y,0,1)
                updatePickerUI()
            elseif draggingHue then
                local ap=hueTrack.AbsolutePosition; local as=hueTrack.AbsoluteSize
                curH=math.clamp((inp.Position.X-ap.X)/as.X,0,1); updatePickerUI()
            elseif draggingRGB>0 then
                local i=draggingRGB
                local ap=rgbTracks[i].AbsolutePosition; local as=rgbTracks[i].AbsoluteSize
                local v=math.floor(math.clamp((inp.Position.X-ap.X)/as.X,0,1)*255+0.5)
                if i==1 then curR=v elseif i==2 then curG=v else curB=v end
                curH,curS,curV=Color3.toHSV(Color3.fromRGB(curR,curG,curB)); updatePickerUI()
            end
        end)
        table.insert(colorPickerConnections, moveConn)

        local endConn = UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                draggingSV=false; draggingHue=false; draggingRGB=0
            end
        end)
        table.insert(colorPickerConnections, endConn)

        hexBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                local hex=hexBox.Text:gsub("[^%x]",""):upper()
                if #hex==6 then
                    local r=tonumber(hex:sub(1,2),16); local g=tonumber(hex:sub(3,4),16); local b=tonumber(hex:sub(5,6),16)
                    if r and g and b then
                        curR,curG,curB=r,g,b; curH,curS,curV=Color3.toHSV(Color3.fromRGB(r,g,b)); updatePickerUI()
                    end
                end
            end
        end)
        return container
    end

    -- ══════════════════════════════════════
    --  SHOW SETTINGS
    -- ══════════════════════════════════════
    local function showSettings()
        clearContent()
        local function saveAndUpdate()
            saveSettings(); updateGuiColors(); showSettings()
        end

        createSectionHeader("Color Picker", scrollingFrame)
        createColorPicker(scrollingFrame)

        createSectionHeader("Transparency", scrollingFrame)
        for _, t in ipairs({{"0%",0},{"10%",0.1},{"25%",0.25},{"50%",0.5},{"75%",0.75}}) do
            createButton(t[1], scrollingFrame, function()
                settings.transparency = t[2]; updateGuiColors(); saveAndUpdate()
            end)
        end

        createSectionHeader("Server", scrollingFrame)
        createButton("Rejoin", scrollingFrame, function()
            local ok2, e = pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
            if not ok2 then createNotification("ERROR","Rejoin failed: "..tostring(e),5,7733968497) end
        end)
        createButton("Server Hop", scrollingFrame, function()
            local ok2, e = pcall(function()
                local servers = HttpService:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
                ))
                if #servers.data > 0 then
                    TeleportService:TeleportToPlaceInstance(
                        game.PlaceId,
                        servers.data[math.random(1,#servers.data)].id,
                        player
                    )
                else
                    createNotification("ERROR","No servers found",5,7733968497)
                end
            end)
            if not ok2 then createNotification("ERROR","Server hop failed: "..tostring(e),5,7733968497) end
        end)
        createButton("Copy Server ID", scrollingFrame, function()
            local ok2, e = pcall(function()
                setclipboard(game.JobId)
                createNotification("SUCCESS","Server ID copied!",3)
            end)
            if not ok2 then createNotification("ERROR",tostring(e),5,7733968497) end
        end)

        createSectionHeader("Coordinates", scrollingFrame)
        createButton("Save Current Position",      scrollingFrame, saveCoordinates)
        createButton("Teleport to Saved Position", scrollingFrame, teleportToCoordinates)

        createSectionHeader("Security", scrollingFrame)
        createButton("Enable Anti-Ban / Anti-Kick", scrollingFrame, setupAntiBanKick)
        createButton("Check Executor Functions",    scrollingFrame, function()
            local av, unav = checkFunctions()
            createNotification("FUNCTIONS","Available: "..#av.."/"..(#av+#unav),5,7733960981)
            print("=== AVAILABLE ===")
            for _, f in ipairs(av)   do print("✓ "..f) end
            print("=== UNAVAILABLE ===")
            for _, f in ipairs(unav) do print("✗ "..f) end
        end)

        createSectionHeader("Appearance", scrollingFrame)
        createButton((settings.locked and "Unlock GUI" or "Lock GUI"), scrollingFrame, function()
            settings.locked = not settings.locked; saveColorSettings()
        end)
        createButton("RGB Accents: "..(settings.rgbAccent and "ON" or "OFF"), scrollingFrame, function()
            settings.rgbAccent = not settings.rgbAccent; saveColorSettings(); updateGuiColors()
        end)
        createButton("RGB Stroke: "..(settings.rgbStroke and "ON" or "OFF"), scrollingFrame, function()
            settings.rgbStroke = not settings.rgbStroke; saveColorSettings(); updateGuiColors()
        end)

        createSectionHeader("Actions", scrollingFrame)
        createButton("Apply & Restart", scrollingFrame, function()
            saveSettings()
            local ok2, r = pcall(function()
                gui.screenGui:Destroy()
                loadstring(game:HttpGet("https://pastefy.app/QVzDuYQA/raw", true))()
            end)
            if not ok2 then createNotification("ERROR","Restart failed: "..tostring(r),5,7733968497) end
        end)
        createButton("Close GUI", scrollingFrame, function() gui.screenGui:Destroy() end)
    end

    -- ══════════════════════════════════════
    --  DRAGGING
    -- ══════════════════════════════════════
    local function MakeDraggable(frame, dragPart)
        dragPart = dragPart or frame
        local dragging, dragInput, mousePos, framePos
        dragPart.InputBegan:Connect(function(input)
            if not settings.locked and (
                input.UserInputType == Enum.UserInputType.MouseButton1 or
                input.UserInputType == Enum.UserInputType.Touch
            ) then
                dragging  = true
                mousePos  = input.Position
                framePos  = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        dragPart.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or
               input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - mousePos
                frame.Position = UDim2.new(
                    framePos.X.Scale, framePos.X.Offset + delta.X,
                    framePos.Y.Scale, framePos.Y.Offset + delta.Y
                )
            end
        end)
    end

    -- ══════════════════════════════════════
    --  INIT
    -- ══════════════════════════════════════
    return {
        init = function()
            loadColorSettings()
            loadStats()
            startSessionTimer()

            -- ── Сайдбар: специальные вкладки ───────────────────────────
            local specialOrder = {"Home", "Stats", "Settings", "All Scripts"}
            local specialFuncs = {
                Home            = function()
                    recordTabClick("Home")
                    clearContent(); showHome(); updateGuiColors()
                end,
                Stats           = function()
                    recordTabClick("Stats")
                    clearContent(); showStats(); updateGuiColors()
                end,
                Settings        = function()
                    recordTabClick("Settings")
                    clearContent(); showSettings(); updateGuiColors()
                end,
                ["All Scripts"] = function()
                    recordTabClick("All Scripts")
                    clearContent(); showAllScripts(); updateGuiColors()
                end,
            }
            for _, name in ipairs(specialOrder) do
                createButton(name, catScroll, specialFuncs[name], true)
            end

            -- ── Сайдбар: категории ─────────────────────────────────────
            local sortedCats = {}
            for categoryName in pairs(categoryMap) do
                table.insert(sortedCats, categoryName)
            end
            table.sort(sortedCats)
            for _, categoryName in ipairs(sortedCats) do
                createButton(categoryName, catScroll, function()
                    recordTabClick(categoryName)
                    clearContent(); loadHacksFromCategory(categoryName); updateGuiColors()
                end, true)
            end

            -- Dragging
            MakeDraggable(mainFrame, headerFrame)
            MakeDraggable(reopenButton, reopenButton)

            -- Close / Reopen
            closeBtn.MouseButton1Click:Connect(function()
                finishCurrentSession()
                TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                    Size = UDim2.new(0,580,0,0), BackgroundTransparency = 1
                }):Play()
                task.delay(0.25, function()
                    mainFrame.Visible = false
                    mainFrame.Size    = UDim2.new(0,580,0,380)
                    mainFrame.BackgroundTransparency = settings.transparency
                    reopenButton.Visible = true
                    startSessionTimer()
                end)
            end)
            reopenButton.MouseButton1Click:Connect(function()
                mainFrame.Visible = true
                mainFrame.Size    = UDim2.new(0,580,0,0)
                mainFrame.BackgroundTransparency = 1
                reopenButton.Visible = false
                TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0,580,0,380), BackgroundTransparency = settings.transparency
                }):Play()
            end)

            -- Intro animation
            mainFrame.Size                   = UDim2.new(0,0,0,0)
            mainFrame.BackgroundTransparency = 1
            TweenService:Create(mainFrame, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0,580,0,380), BackgroundTransparency = settings.transparency
            }):Play()

            -- Показываем Home
            recordTabClick("Home")
            showHome()
            updateGuiColors()

            -- Подсвечиваем первую кнопку
            task.delay(0.1, function()
                local firstBtn = catScroll:FindFirstChildWhichIsA("TextButton")
                if firstBtn then
                    firstBtn:SetAttribute("Active", true)
                    TweenService:Create(firstBtn, TweenInfo.new(0.18), {
                        BackgroundColor3 = T.Accent, BackgroundTransparency = 0.35, TextColor3 = T.TextMain
                    }):Play()
                end
            end)

            -- Автосохранение сессии при выходе
            game:BindToClose(function()
                finishCurrentSession()
            end)

            createNotification("MEGAHACK V1", "Loaded  ·  " .. platformName, 3, 74283928898866)
        end
    }
end
