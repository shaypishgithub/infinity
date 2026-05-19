-- ══════════════════════════════════════════════════════════════════
--  stats.lua  —  Статистика сессий, дней, вкладок
--  Зависимости: deps = { RunService, HttpService, Players, ... }
-- ══════════════════════════════════════════════════════════════════

return function(deps)
    local RunService       = deps.RunService
    local HttpService      = deps.HttpService
    local Players          = deps.Players
    local player           = deps.player
    local createNotification = deps.createNotification

    -- Вспомогательные функции для работы с файловой системой (если executor поддерживает)
    local safeIsFolder, safeMakeFolder, safeWriteFile, safeReadFile, safeIsFile
    safeIsFolder = function(path) pcall(function() return isfolder(path) end) return isfolder and isfolder(path) or false end
    safeMakeFolder = function(path) if makefolder then pcall(makefolder, path) end end
    safeWriteFile = function(path, data) if writefile then pcall(writefile, path, data) end end
    safeReadFile = function(path) if readfile then return pcall(readfile, path) and readfile(path) or nil end return nil end
    safeIsFile = function(path) if isfile then return isfile(path) end return false end

    -- ── Состояние статистики ──────────────────────────────────────
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

    -- ── Форматирование времени ────────────────────────────────────
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
            math.floor(secs/3600),
            math.floor((secs%3600)/60),
            secs%60)
    end

    -- ── Сохранение / загрузка ─────────────────────────────────────
    local function saveStats()
        pcall(function()
            if not safeIsFolder("MegaHack") then safeMakeFolder("MegaHack") end
            safeWriteFile("MegaHack/stats.json", HttpService:JSONEncode(statsData))
        end)
    end

    local function loadStats()
        pcall(function()
            if safeIsFile("MegaHack/stats.json") then
                local data = HttpService:JSONDecode(safeReadFile("MegaHack/stats.json"))
                if data.totalSeconds  then statsData.totalSeconds  = data.totalSeconds  end
                if data.totalSessions then statsData.totalSessions = data.totalSessions end
                if data.tabClicks     then statsData.tabClicks     = data.tabClicks     end
                if data.daySeconds    then statsData.daySeconds    = data.daySeconds    end
                if data.streak        then statsData.streak        = data.streak        end
                if data.lastDayPlayed then statsData.lastDayPlayed = data.lastDayPlayed end
            end
        end)
    end

    -- ── Обновление дневной статистики и серий ─────────────────────
    local function updateDayStats(secsThisSession)
        local dow    = tonumber(os.date("%w")) or 0
        local dayIdx = tostring(dow == 0 and 7 or dow)
        if not statsData.daySeconds[dayIdx] then statsData.daySeconds[dayIdx] = 0 end
        statsData.daySeconds[dayIdx] = statsData.daySeconds[dayIdx] + secsThisSession
        local todayNum = math.floor(os.time() / 86400)
        if statsData.lastDayPlayed == todayNum - 1 then
            statsData.streak = statsData.streak + 1
        elseif statsData.lastDayPlayed ~= todayNum then
            statsData.streak = 1
        end
        statsData.lastDayPlayed = todayNum
        saveStats()
    end

    -- ── Управление сессией ────────────────────────────────────────
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

    local function recordTabClick(name)
        if not statsData.tabClicks[name] then statsData.tabClicks[name] = 0 end
        statsData.tabClicks[name] = statsData.tabClicks[name] + 1
        saveStats()
    end

    -- ── Публичное API ─────────────────────────────────────────────
    return {
        -- Инициализация (загрузка + запуск таймера)
        init = function()
            loadStats()
            startSessionTimer()
            -- Автосохранение при закрытии игры
            game:BindToClose(function()
                finishCurrentSession()
            end)
        end,

        -- Получение копии данных (для отображения в UI)
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

        -- Форматирование времени
        formatTime      = fmtTime,
        formatTimerLive = fmtTimerLive,

        -- Операции
        recordTabClick      = recordTabClick,
        finishCurrentSession = finishCurrentSession,
        startSessionTimer   = startSessionTimer,
        saveStats           = saveStats,
        loadStats           = loadStats,
    }
end
