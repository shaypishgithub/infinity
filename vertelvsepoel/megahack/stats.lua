return function(deps)
    local RunService = deps.RunService
    local HttpService = deps.HttpService
    local SafeFile = deps.SafeFile

    local Stats = { totalSeconds = 0, totalSessions = 0, sessionStart = tick(), tabClicks = {}, daySeconds = {}, streak = 0, lastDayPlayed = 0 }

    local function fmtTime(secs)
        secs = math.floor(secs); local h = math.floor(secs / 3600); local m = math.floor((secs % 3600) / 60)
        if h > 0 then return string.format("%dh %02dm %02ds", h, m, secs % 60) end
        return string.format("%02dm %02ds", m, secs % 60)
    end

    local function loadStats()
        pcall(function()
            local raw = SafeFile.read("MegaHack/stats_v3.json")
            if not raw then return end
            local data = HttpService:JSONDecode(raw)
            for k,v in pairs(data) do if type(v) ~= "table" then Stats[k] = v elseif k == "tabClicks" or k == "daySeconds" then Stats[k] = v end end
        end)
    end

    local function saveStats()
        pcall(function() SafeFile.write("MegaHack/stats_v3.json", HttpService:JSONEncode(Stats)) end)
    end

    local function recordTab(name)
        Stats.tabClicks[name] = (Stats.tabClicks[name] or 0) + 1; saveStats()
    end

    loadStats()
    game:BindToClose(function()
        local elapsed = math.floor(tick() - Stats.sessionStart)
        if elapsed > 5 then
            Stats.totalSeconds = Stats.totalSeconds + elapsed; Stats.totalSessions = Stats.totalSessions + 1
            local dow = tonumber(os.date("%w")) or 0; local dayIdx = tostring(dow == 0 and 7 or dow)
            Stats.daySeconds[dayIdx] = (Stats.daySeconds[dayIdx] or 0) + elapsed
            local todayNum = math.floor(os.time() / 86400)
            if Stats.lastDayPlayed == todayNum - 1 then Stats.streak = Stats.streak + 1
            elseif Stats.lastDayPlayed ~= todayNum then Stats.streak = 1 end
            Stats.lastDayPlayed = todayNum
        end; saveStats()
    end)

    return { Stats = Stats, fmtTime = fmtTime, recordTab = recordTab, saveStats = saveStats }
end
