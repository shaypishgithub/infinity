-- ════════════════════════════════════════════════════════════════════════════════
--  logic.lua  —  v2  Full Logic Layer (RussElite Optimized Glass Edition)
-- ════════════════════════════════════════════════════════════════════════════════

local BASE_RAW = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/"

return function(deps)
    local TweenService       = deps.TweenService
    local UserInputService   = deps.UserInputService
    local Players            = deps.Players
    local RunService         = deps.RunService
    local TeleportService    = deps.TeleportService
    local HttpService        = deps.HttpService
    local MarketplaceService = deps.MarketplaceService
    local player             = deps.player
    local playerGui          = deps.playerGui
    local platformName       = deps.platformName
    local T                  = deps.T
    local gui                = deps.gui
    local HubData            = deps.HubData
    local baseUrl            = deps.baseUrl
    local categoryMap        = deps.categoryMap
    local gameIcons          = deps.gameIcons or {}
    local createNotification = deps.createNotification
    local safeLoad           = deps.safeLoad

    -- GUI refs
    local mainFrame           = gui.mainFrame
    local headerFrame         = gui.headerFrame
    local sidebarFrame        = gui.sidebarFrame
    local catScroll           = gui.catScroll
    local contentFrame        = gui.contentFrame
    local scrollingFrame      = gui.scrollingFrame
    local gamesPanel          = gui.gamesPanel
    local closeBtn            = gui.closeBtn
    local reopenButton        = gui.reopenButton
    local createButton        = gui.createButton
    local createLabel         = gui.createLabel
    local createSectionHeader = gui.createSectionHeader
    local createGameCard      = gui.createGameCard
    local mkCorner            = gui.mkCorner
    local mkStroke            = gui.mkStroke
    local mkGlassEffect       = gui.mkGlassEffect -- Оптимизированный стеклянный эффект

    -- ════════════════════════════════════════════════════════════════════════════════
    --  LOAD SUBMODULES
    -- ════════════════════════════════════════════════════════════════════════════════
    local GamesModule, ColorPickerModule, HomeModule

    local function loadSubmodule(name)
        local url = BASE_RAW .. name
        local ok, result = pcall(function()
            return loadstring(game:HttpGet(url, true))()
        end)
        if not ok then
            warn("[RussElite] Failed to load submodule: " .. name .. " | " .. tostring(result))
            return nil
        end
        return result
    end

    -- ════════════════════════════════════════════════════════════════════════════════
    --  STATE
    -- ════════════════════════════════════════════════════════════════════════════════
    local rgbConnections         = {}
    local colorPickerConnections = {}

    local settings = {
        locked       = false,
        rgbAccent    = false,
        rgbStroke    = false,
        transparency = 0.04, -- Чуть прозрачнее для стеклянного эффекта
        colors = {
            bgColor     = T.BgBase,
            textColor   = T.TextMain,
            strokeColor = T.Stroke,
            accentColor = T.Accent,
        }
    }

    -- ════════════════════════════════════════════════════════════════════════════════
    --  HELPERS
    -- ════════════════════════════════════════════════════════════════════════════════
    local function clearRgbConnections()
        for _, c in pairs(rgbConnections) do pcall(function() c:Disconnect() end) end
        rgbConnections = {}
    end

    local function ensureFolder()
        pcall(function()
            if not isfolder("RussElite") then makefolder("RussElite") end
        end)
    end

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

    local function mkFrame(parent, size, pos, bg, bgt, zidx)
        local f = Instance.new("Frame")
        f.Size                   = size or UDim2.new(1,0,0,40)
        f.Position               = pos  or UDim2.new(0,0,0,0)
        f.BackgroundColor3       = bg   or T.BgPanel
        f.BackgroundTransparency = bgt  ~= nil and bgt or 0.1 -- Адаптировано под Glass
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

    -- Быстрая стеклянная карточка для логики (скрипты, настройки и т.д.)
    local function mkGlass(parent, size, pos, bgt, radius)
        local f = mkFrame(parent, size, pos, T.BgPanel, bgt or 0.1)
        mkCorner(f, radius or 12)
        mkStroke(f, 1, Color3.new(1,1,1), 0.82)
        mkGlassEffect(f)
        return f
    end

    -- ════════════════════════════════════════════════════════════════════════════════
    --  STATS STATE
    -- ════════════════════════════════════════════════════════════════════════════════
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

    local function saveStats()
        pcall(function()
            ensureFolder()
            writefile("RussElite/stats.json", HttpService:JSONEncode(statsData))
        end)
    end

    local function loadStats()
        pcall(function()
            if isfile("RussElite/stats.json") then
                local data = HttpService:JSONDecode(readfile("RussElite/stats.json"))
                if data.totalSeconds  then statsData.totalSeconds  = data.totalSeconds  end
                if data.totalSessions then statsData.totalSessions = data.totalSessions end
                if data.tabClicks     then statsData.tabClicks     = data.tabClicks     end
                if data.daySeconds    then statsData.daySeconds    = data.daySeconds    end
                if data.streak        then statsData.streak        = data.streak        end
                if data.lastDayPlayed then statsData.lastDayPlayed = data.lastDayPlayed end
            end
        end)
    end

    local function recordTabClick(name)
        if not statsData.tabClicks[name] then statsData.tabClicks[name] = 0 end
        statsData.tabClicks[name] = statsData.tabClicks[name] + 1
        saveStats()
    end

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

    -- ════════════════════════════════════════════════════════════════════════════════
    --  SAVE / LOAD COLORS
    -- ════════════════════════════════════════════════════════════════════════════════
    local function saveColorSettings()
        pcall(function()
            ensureFolder()
            local col = settings.colors
            writefile("RussElite/colorSettings.json", HttpService:JSONEncode({
                bgColor      = {col.bgColor.R,     col.bgColor.G,     col.bgColor.B},
                textColor    = {col.textColor.R,   col.textColor.G,   col.textColor.B},
                strokeColor  = {col.strokeColor.R, col.strokeColor.G, col.strokeColor.B},
                accentColor  = {col.accentColor.R, col.accentColor.G, col.accentColor.B},
                transparency = settings.transparency,
                rgbAccent    = settings.rgbAccent,
                rgbStroke    = settings.rgbStroke,
            }))
        end)
    end

    local function loadColorSettings()
        pcall(function()
            if not isfile("RussElite/colorSettings.json") then return end
            local data = HttpService:JSONDecode(readfile("RussElite/colorSettings.json"))
            if data.bgColor     then settings.colors.bgColor     = Color3.new(table.unpack(data.bgColor))     end
            if data.textColor   then settings.colors.textColor   = Color3.new(table.unpack(data.textColor))   end
            if data.strokeColor then settings.colors.strokeColor = Color3.new(table.unpack(data.strokeColor)) end
            if data.accentColor then settings.colors.accentColor = Color3.new(table.unpack(data.accentColor)) end
            if data.transparency ~= nil then settings.transparency = data.transparency end
            if data.rgbAccent   ~= nil then settings.rgbAccent   = data.rgbAccent     end
            if data.rgbStroke   ~= nil then settings.rgbStroke   = data.rgbStroke     end
        end)
    end

    local function saveSettings()
        saveColorSettings()
        createNotification("SETTINGS", "Settings saved!", 3)
    end

