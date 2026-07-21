-- ══════════════════════════════════════════════════════════════════
--  stats.lua  —  Статистика сессий, дней, вкладок (RussElite Edition)
--  ОБНОВЛЕНО: Интегрирован современный Glass GUI напрямую в модуль
-- ══════════════════════════════════════════════════════════════════
return function(deps)
    local RunService         = deps.RunService
    local HttpService        = deps.HttpService
    local Players            = deps.Players
    local player             = deps.player
    local T                  = deps.T
    local gui                = deps.gui
    local createNotification = deps.createNotification or function() end

    -- GUI Утилиты из gui.lua
    local mkCorner            = gui.mkCorner
    local mkStroke            = gui.mkStroke
    local mkGlassEffect       = gui.mkGlassEffect
    local createLabel         = gui.createLabel
    local createSectionHeader = gui.createSectionHeader

    -- ── Безопасная работа с ФС ────────────────────────────────────
    local function safeIsFolder(path)
        if not isfolder then return false end
        local ok, r = pcall(isfolder, path); return ok and r or false
    end
    local function safeMakeFolder(path)
        if makefolder then pcall(makefolder, path) end
    end
    local function safeWriteFile(path, data)
        if writefile then pcall(writefile, path, data) end
    end
    local function safeIsFile(path)
        if not isfile then return false end
        local ok, r = pcall(isfile, path); return ok and r or false
    end
    local function safeReadFile(path)
        if not readfile then return nil end
        local ok, r = pcall(readfile, path)
        return ok and r or nil
    end

    -- ── Состояние ─────────────────────────────────────────────────
    local statsData = {
        totalSeconds  = 0,
        totalSessions = 0,
        sessionStart  = tick(),
        tabClicks     = {},
        daySeconds    = {},
        streak        = 0,
        lastDayPlayed = 0,
    }
    local sessionTimerConn = nil

    -- ── Форматирование ────────────────────────────────────────────
    local function fmtTime(secs)
        secs = math.floor(secs)
        local h = math.floor(secs / 3600)
        local m = math.floor((secs % 3600) / 60)
        local s = secs % 60
        if h > 0 then return string.format("%dh %02dm", h, m) end
        return string.format("%02dm %02ds", m, s)
    end

    local function fmtTimerLive(secs)
        secs = math.floor(secs)
        return string.format("%02d:%02d:%02d",
            math.floor(secs / 3600),
            math.floor((secs % 3600) / 60),
            secs % 60)
    end

    -- ── Сохранение / загрузка ─────────────────────────────────────
    local function saveStats()
        pcall(function()
            if not safeIsFolder("RussElite") then safeMakeFolder("RussElite") end
            safeWriteFile("RussElite/stats.json", HttpService:JSONEncode(statsData))
        end)
    end

    local function loadStats()
        pcall(function()
            if not safeIsFile("RussElite/stats.json") then return end
            local raw = safeReadFile("RussElite/stats.json")
            if not raw then return end
            local data = HttpService:JSONDecode(raw)
            if data.totalSeconds  then statsData.totalSeconds  = data.totalSeconds  end
            if data.totalSessions then statsData.totalSessions = data.totalSessions end
            if data.tabClicks     then statsData.tabClicks     = data.tabClicks     end
            if data.daySeconds    then statsData.daySeconds    = data.daySeconds    end
            if data.streak        then statsData.streak        = data.streak        end
            if data.lastDayPlayed then statsData.lastDayPlayed = data.lastDayPlayed end
        end)
    end

    -- ── День / серия ──────────────────────────────────────────────
    local function updateDayStats(secsThisSession)
        local dow    = tonumber(os.date("%w")) or 0
        local dayIdx = tostring(dow == 0 and 7 or dow)
        statsData.daySeconds[dayIdx] = (statsData.daySeconds[dayIdx] or 0) + secsThisSession
        local todayNum = math.floor(os.time() / 86400)
        if statsData.lastDayPlayed == todayNum - 1 then
            statsData.streak = statsData.streak + 1
        elseif statsData.lastDayPlayed ~= todayNum then
            statsData.streak = 1
        end
        statsData.lastDayPlayed = todayNum
        saveStats()
    end

    -- ── Сессия ────────────────────────────────────────────────────
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

    local function startSessionTimer()
        statsData.sessionStart = tick()
        if sessionTimerConn then
            pcall(function() sessionTimerConn:Disconnect() end)
        end
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

    local function recordTabClick(name)
        statsData.tabClicks[name] = (statsData.tabClicks[name] or 0) + 1
        saveStats()
    end

    -- ════════════════════════════════════════════════════════════════════
    --  GUI ИНТЕГРАЦИЯ (Glass Dashboard)
    -- ════════════════════════════════════════════════════════════════════
    local function mkGlass(parent, size, pos, bgt, radius)
        local f = Instance.new("Frame")
        f.Size = size; f.Position = pos or UDim2.new(0,0,0,0)
        f.BackgroundColor3 = T.BgPanel; f.BackgroundTransparency = bgt or 0.1
        f.BorderSizePixel = 0; f.ZIndex = 4; f.Parent = parent
        mkCorner(f, radius or 12)
        mkStroke(f, 1, Color3.new(1,1,1), 0.82)
        mkGlassEffect(f) -- Быстрый стеклянный эффект
        return f
    end

    local function showStats(scrollingFrame)
        createSectionHeader("Statistics", scrollingFrame)

        -- Ряд 1: Основные метрики
        local row1 = Instance.new("Frame")
        row1.Size = UDim2.new(1,0,0,50); row1.BackgroundTransparency = 1
        row1.BorderSizePixel = 0; row1.ZIndex = 4; row1.Parent = scrollingFrame

        local c1 = mkGlass(row1, UDim2.new(0.31,0,1,0), UDim2.new(0,0,0,0), 0.08)
        createLabel(c1, "TOTAL TIME", UDim2.new(1,-12,0,14), UDim2.new(0,10,0,6), T.TextMuted, nil, Enum.Font.GothamBold, 9, 5)
        local timeLbl = createLabel(c1, fmtTime(statsData.totalSeconds), UDim2.new(1,-12,0,20), UDim2.new(0,10,0,24), T.TextMain, nil, Enum.Font.GothamBold, 15, 6)
        timeLbl:SetAttribute("TextRole","main")

        local c2 = mkGlass(row1, UDim2.new(0.31,0,1,0), UDim2.new(0.345,0,0,0), 0.08)
        createLabel(c2, "SESSIONS", UDim2.new(1,-12,0,14), UDim2.new(0,10,0,6), T.TextMuted, nil, Enum.Font.GothamBold, 9, 5)
        local sessLbl = createLabel(c2, tostring(statsData.totalSessions), UDim2.new(1,-12,0,20), UDim2.new(0,10,0,24), T.TextMain, nil, Enum.Font.GothamBold, 15, 6)
        sessLbl:SetAttribute("TextRole","main")

        local c3 = mkGlass(row1, UDim2.new(0.31,0,1,0), UDim2.new(0.69,0,0,0), 0.08)
        createLabel(c3, "STREAK", UDim2.new(1,-12,0,14), UDim2.new(0,10,0,6), T.TextMuted, nil, Enum.Font.GothamBold, 9, 5)
        local streakLbl = createLabel(c3, statsData.streak .. " days", UDim2.new(1,-12,0,20), UDim2.new(0,10,0,24), T.TextMain, nil, Enum.Font.GothamBold, 15, 6)
        streakLbl:SetAttribute("TextRole","main")

        -- Ряд 2: Живой таймер сессии
        local timerCard = mkGlass(scrollingFrame, UDim2.new(1,0,0,44), nil, 0.06, 14)
        createLabel(timerCard, "CURRENT SESSION", UDim2.new(0.5,0,1,0), UDim2.new(0,14,0,0), T.TextSub, nil, Enum.Font.Gotham, 11, 5)
        local liveLbl = createLabel(timerCard, "00:00:00", UDim2.new(0.5,0,1,0), UDim2.new(0.5,0,0,0), T.Accent, Enum.TextXAlignment.Right, Enum.Font.GothamBold, 18, 6)
        liveLbl:SetAttribute("TextRole","main")

        -- Оптимизированное обновление таймера (без лагов, раз в секунду)
        local lastUIUpdate = 0
        local liveConn; liveConn = RunService.Heartbeat:Connect(function()
            if not timerCard.Parent then liveConn:Disconnect(); return end
            local now = tick()
            if now - lastUIUpdate >= 1 then
                lastUIUpdate = now
                local elapsed = math.floor(now - statsData.sessionStart)
                liveLbl.Text = fmtTimerLive(elapsed)
                timeLbl.Text = fmtTime(statsData.totalSeconds + elapsed)
            end
        end)

        -- Ряд 3: Мини-график активности по дням (Glass Bars)
        createSectionHeader("Weekly Activity", scrollingFrame)
        local chartCard = mkGlass(scrollingFrame, UDim2.new(1,0,0,110), nil, 0.06, 14)
        
        local days = {"Mon","Tue","Wed","Thu","Fri","Sat","Sun"}
        for i=1, 7 do
            local daySecs = statsData.daySeconds[tostring(i)] or 0
            -- Максимум шкалы: 2 часа (7200 сек) = 100%
            local pct = math.clamp(daySecs / 7200, 0, 1) 
            local barMaxH = 70
            local barH = math.clamp(pct * barMaxH, 4, barMaxH)

            local offsetX = 10 + (i-1) * 40

            -- Подпись дня
            createLabel(chartCard, days[i], UDim2.new(0, 30, 0, 14), UDim2.new(0, offsetX, 1, -16), T.TextMuted, Enum.TextXAlignment.Center, Enum.Font.Gotham, 9, 5)

            -- Фон полоски
            local barBg = Instance.new("Frame")
            barBg.Size = UDim2.new(0, 26, 0, barMaxH)
            barBg.Position = UDim2.new(0, offsetX + 2, 0, 8)
            barBg.BackgroundColor3 = Color3.new(1,1,1)
            barBg.BackgroundTransparency = 0.92
            barBg.BorderSizePixel = 0; barBg.ZIndex = 4; barBg.Parent = chartCard
            mkCorner(barBg, 6)

            -- Заполнение полоски (Акцентное)
            local barFill = Instance.new("Frame")
            barFill.Size = UDim2.new(0, 26, 0, barH)
            barFill.Position = UDim2.new(0, offsetX + 2, 1, -16 - barH)
            barFill.BackgroundColor3 = T.Accent
            barFill.BackgroundTransparency = 0.15
            barFill.BorderSizePixel = 0; barFill.ZIndex = 5; barFill.Parent = chartCard
            mkCorner(barFill, 6)
            mkGlassEffect(barFill) -- Красивый стеклянный блик на графике
        end
    end

    -- ── Публичное API ─────────────────────────────────────────────
    return {
        init = function()
            loadStats()
            startSessionTimer()
            game:BindToClose(function()
                finishCurrentSession()
            end)
        end,

        showStats = showStats, -- Теперь доступно для вызова из logic.lua

        getData = function()
            return {
                totalSeconds  = statsData.totalSeconds,
                totalSessions = statsData.totalSessions,
                sessionStart  = statsData.sessionStart,
                tabClicks     = statsData.tabClicks,
                daySeconds    = statsData.daySeconds,
                streak        = statsData.streak,
                lastDayPlayed = statsData.lastDayPlayed,
            }
        end,

        formatTime      = fmtTime,
        formatTimerLive = fmtTimerLive,

        recordTabClick       = recordTabClick,
        finishCurrentSession = finishCurrentSession,
        startSessionTimer    = startSessionTimer,
        saveStats            = saveStats,
        loadStats            = loadStats,
    }
end
