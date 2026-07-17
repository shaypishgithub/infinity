═══════════════════════════════════════════════════════════════
--  stats.lua — Statistics Module v3
═══════════════════════════════════════════════════════════════

return function(deps)
    local RunService         = deps.RunService
    local HttpService        = deps.HttpService
    local Players            = deps.Players
    local player             = deps.player
    local createNotification = deps.createNotification or function() end

    local function safeIsFolder(path)
        if not isfolder then return false end
        local ok, r = pcall(isfolder, path)
        return ok and r or false
    end
    local function safeMakeFolder(path)
        if makefolder then pcall(makefolder, path) end
    end
    local function safeWriteFile(path, data)
        if writefile then pcall(writefile, path, data) end
    end
    local function safeIsFile(path)
        if not isfile then return false end
        local ok, r = pcall(isfile, path)
        return ok and r or false
    end
    local function safeReadFile(path)
        if not readfile then return nil end
        local ok, r = pcall(readfile, path)
        return ok and r or nil
    end

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
            secs % 60
        )
    end

    local function saveStats()
        pcall(function()
            if not safeIsFolder("MegaHack") then safeMakeFolder("MegaHack") end
            safeWriteFile("MegaHack/stats.json", HttpService:JSONEncode(statsData))
        end)
    end

    local function loadStats()
        pcall(function()
            if not safeIsFile("MegaHack/stats.json") then return end
            local raw = safeReadFile("MegaHack/stats.json")
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

    return {
        init = function()
            loadStats()
            startSessionTimer()
            game:BindToClose(function()
                finishCurrentSession()
            end)
        end,

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
