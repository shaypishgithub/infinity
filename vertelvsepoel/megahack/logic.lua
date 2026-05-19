-- ══════════════════════════════════════════════════════════════════
--  logic.lua  —  v2  (Full Logic Layer with separated stats module)
--  Загружает: games.lua, colorpicker.lua, stats.lua
-- ══════════════════════════════════════════════════════════════════

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

    -- ══════════════════════════════════════
    --  LOAD SUBMODULES
    --  games.lua, colorpicker.lua, stats.lua
    -- ══════════════════════════════════════
    local GamesModule, ColorPickerModule, StatsModule

    local function loadSubmodule(name)
        local url = BASE_RAW .. name
        local ok, result = pcall(function()
            return loadstring(game:HttpGet(url, true))()
        end)
        if not ok then
            warn("[MegaHack] Failed to load submodule: " .. name .. " | " .. tostring(result))
            return nil
        end
        return result
    end

    -- ══════════════════════════════════════
    --  STATE (не статистика)
    -- ══════════════════════════════════════
    local rgbConnections         = {}
    local colorPickerConnections = {}

    local settings = {
        locked       = false,
        rgbAccent    = false,
        rgbStroke    = false,
        transparency = 0.06,
        colors = {
            bgColor     = T.BgBase,
            textColor   = T.TextMain,
            strokeColor = T.Stroke,
            accentColor = T.Accent,
        }
    }

    -- ══════════════════════════════════════
    --  HELPERS
    -- ══════════════════════════════════════
    local function clearRgbConnections()
        for _, c in pairs(rgbConnections) do pcall(function() c:Disconnect() end) end
        rgbConnections = {}
    end

    local function ensureFolder()
        pcall(function()
            if not isfolder("MegaHack") then makefolder("MegaHack") end
        end)
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
    --  SAVE / LOAD COLORS
    -- ══════════════════════════════════════
    local function saveColorSettings()
        pcall(function()
            ensureFolder()
            local col = settings.colors
            writefile("MegaHack/colorSettings.json", HttpService:JSONEncode({
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
            if not isfile("MegaHack/colorSettings.json") then return end
            local data = HttpService:JSONDecode(readfile("MegaHack/colorSettings.json"))
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
        T.AccentGlow = Color3.new(math.min(acc.R*1.38,1), math.min(acc.G*1.38,1), math.min(acc.B*1.38,1))
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

        for _, obj in pairs(mainFrame:GetDescendants()) do
            if obj:IsA("UIStroke") then
                if settings.rgbStroke then
                    local conn; conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then conn:Disconnect(); return end
                        obj.Color = Color3.fromHSV((tick()%5)/5, 1, 1)
                    end)
                    table.insert(rgbConnections, conn)
                else
                    obj.Color = str
                end
            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if settings.rgbAccent then
                    local conn; conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then conn:Disconnect(); return end
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
    --  CLEAR CONTENT
    -- ══════════════════════════════════════
    local function clearContent()
        for _, c in pairs(colorPickerConnections) do
            pcall(function() c:Disconnect() end)
        end
        colorPickerConnections = {}

        if GamesModule then
            pcall(function() GamesModule.reset() end)
        end

        for _, child in ipairs(scrollingFrame:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end

        scrollingFrame.Visible = false
        gamesPanel.Visible     = false
    end

    local function showScrollPanel()
        scrollingFrame.Visible = true
        gamesPanel.Visible     = false
    end

    -- ══════════════════════════════════════
    --  LOAD SCRIPTS FROM CATEGORY
    -- ══════════════════════════════════════
    function loadHacksFromCategory(categoryName)
        clearContent()
        showScrollPanel()

        local fileName = categoryMap[categoryName]
        if not fileName then
            createSectionHeader("Not Found", scrollingFrame)
            createLabel("⚠  No entry in base.lua for: " .. categoryName, scrollingFrame)
            return
        end

        if not HubData[categoryName] then
            createLabel("⏳  Loading " .. categoryName .. "...", scrollingFrame)
            task.spawn(function()
                local data = safeLoad(baseUrl .. "/" .. fileName)
                if type(data) == "table" and #data > 0 then
                    HubData[categoryName] = data
                    for _, child in ipairs(scrollingFrame:GetChildren()) do
                        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                            child:Destroy()
                        end
                    end
                    createSectionHeader(categoryName, scrollingFrame)
                    for _, hack in ipairs(data) do
                        if type(hack)=="table" and type(hack[1])=="string" and type(hack[2])=="function" then
                            createButton(hack[1], scrollingFrame, function()
                                local ok2, err = pcall(hack[2])
                                if not ok2 then
                                    createNotification("ERROR", tostring(err), 5, 7733968497)
                                end
                            end)
                        end
                    end
                else
                    for _, child in ipairs(scrollingFrame:GetChildren()) do
                        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then child:Destroy() end
                    end
                    createSectionHeader("Load Error", scrollingFrame)
                    createLabel("⚠  Failed to load: " .. categoryName, scrollingFrame)
                end
            end)
            return
        end

        createSectionHeader(categoryName, scrollingFrame)
        task.spawn(function()
            local hacks = HubData[categoryName]
            for i, hack in ipairs(hacks) do
                if type(hack)=="table" and type(hack[1])=="string" and type(hack[2])=="function" then
                    createButton(hack[1], scrollingFrame, function()
                        local ok2, err = pcall(hack[2])
                        if not ok2 then
                            createNotification("ERROR", tostring(err), 5, 7733968497)
                        end
                    end)
                end
                if i % 12 == 0 then task.wait() end
            end
        end)
    end

    -- ══════════════════════════════════════
    --  SHOW GAMES
    -- ══════════════════════════════════════
    local function showGames()
        clearContent()
        if not GamesModule then
            GamesModule = loadSubmodule("games.lua")
            if not GamesModule then
                showScrollPanel()
                createSectionHeader("Error", scrollingFrame)
                createLabel("⚠  Failed to load games.lua", scrollingFrame)
                return
            end
            GamesModule = GamesModule({
                TweenService = TweenService,
                RunService   = RunService,
                Players      = Players,
                T            = T,
                gui          = gui,
                categoryMap  = categoryMap,
                gameIcons    = gameIcons,
            })
        end

        GamesModule.showGames({
            onCategoryClick = function(catName)
                StatsModule.recordTabClick(catName)   -- <<< через stats-модуль
                loadHacksFromCategory(catName)
                updateGuiColors()

                for _, child in ipairs(catScroll:GetChildren()) do
                    if child:IsA("TextButton") and child.Text == catName then
                        child:SetAttribute("Active", true)
                        TweenService:Create(child, TweenInfo.new(0.18), {
                            BackgroundTransparency = 0.78,
                            TextColor3 = T.Accent,
                        }):Play()
                    elseif child:IsA("TextButton") then
                        child:SetAttribute("Active", false)
                        TweenService:Create(child, TweenInfo.new(0.18), {
                            BackgroundTransparency = 1,
                            TextColor3 = T.TextSub,
                        }):Play()
                    end
                end
            end
        })
    end

    -- ══════════════════════════════════════
    --  SEARCH
    -- ══════════════════════════════════════
    local function searchScriptsByMegahack(query)
        local q = string.lower(query)
        local results = {}
        for categoryName, hacks in pairs(HubData) do
            if type(hacks) == "table" then
                for _, hack in ipairs(hacks) do
                    if type(hack)=="table" and type(hack[1])=="string" then
                        if string.find(string.lower(hack[1]), q, 1, true) then
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
            return HttpService:GetAsync(
                "https://scriptblox.com/api/script/search?q=" .. HttpService:UrlEncode(query)
            )
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

    local function showAllScripts()
        clearContent()
        showScrollPanel()
        createSectionHeader("Search Scripts", scrollingFrame)

        local searchBox = Instance.new("TextBox")
        searchBox.Size                   = UDim2.new(1,0,0,34)
        searchBox.BackgroundColor3       = T.BgPanel
        searchBox.BackgroundTransparency = 0.18
        searchBox.TextColor3             = T.TextMain
        searchBox.PlaceholderText        = "🔍  Search all scripts..."
        searchBox.PlaceholderColor3      = T.TextMuted
        searchBox.TextSize               = 13
        searchBox.Text                   = ""
        searchBox.Font                   = Enum.Font.Gotham
        searchBox.ClearTextOnFocus       = false
        searchBox.ZIndex                 = 4
        searchBox.Parent                 = scrollingFrame
        searchBox:SetAttribute("TextRole","main")
        mkCorner(searchBox, 8)
        mkStroke(searchBox, 1, T.Stroke, 0.28)

        local sbPad = Instance.new("UIPadding")
        sbPad.PaddingLeft = UDim.new(0,12)
        sbPad.Parent      = searchBox

        local resultsLabel = createLabel("Type to search all loaded categories...", scrollingFrame)
        resultsLabel.TextColor3 = T.TextMuted

        local debounceThread = nil

        local function updateSearchResults(query)
            for _, child in ipairs(scrollingFrame:GetChildren()) do
                if child ~= searchBox and child ~= resultsLabel
                   and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                    child:Destroy()
                end
            end
            if query == "" or #query < 2 then
                resultsLabel.Text = "Type to search all loaded categories..."
                return
            end
            resultsLabel.Text = "Searching..."
            task.spawn(function()
                local mhResults = searchScriptsByMegahack(query)
                local sbResults = searchScriptsOnScriptBlox(query)
                local total = #mhResults + #sbResults
                resultsLabel.Text = total > 0 and ("Found " .. total .. " results") or "No results found."

                if #mhResults > 0 then
                    createSectionHeader("Local Scripts (" .. #mhResults .. ")", scrollingFrame)
                end
                for i, r in ipairs(mhResults) do
                    createButton(r.name .. "  [" .. r.category .. "]", scrollingFrame, function()
                        local ok2, e = pcall(r.func)
                        if not ok2 then createNotification("ERROR", tostring(e), 5, 7733968497) end
                    end)
                    if i % 10 == 0 then task.wait() end
                end

                if #sbResults > 0 then
                    createSectionHeader("ScriptBlox (" .. #sbResults .. ")", scrollingFrame)
                end
                for _, r in ipairs(sbResults) do
                    createButton(r.name .. "  [ScriptBlox]", scrollingFrame, function()
                        createNotification("INFO", "ScriptBlox ID: " .. r.scriptId, 5)
                    end)
                end
            end)
        end

        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local txt = searchBox.Text
            if debounceThread then
                task.cancel(debounceThread)
                debounceThread = nil
            end
            if #txt >= 2 then
                debounceThread = task.delay(0.45, function()
                    updateSearchResults(txt)
                end)
            elseif #txt == 0 then
                updateSearchResults("")
            end
        end)
        searchBox.FocusLost:Connect(function()
            updateSearchResults(searchBox.Text)
        end)
    end

    -- ══════════════════════════════════════
    --  HOME  (без статистики)
    -- ══════════════════════════════════════
    local function showHome()
        clearContent()
        showScrollPanel()
        createSectionHeader("Overview", scrollingFrame)

        local card = Instance.new("Frame")
        card.Size                   = UDim2.new(1,0,0,92)
        card.BackgroundColor3       = T.BgPanel
        card.BackgroundTransparency = 0.12
        card.BorderSizePixel        = 0
        card.ZIndex                 = 4
        card.Parent                 = scrollingFrame
        mkCorner(card, 10)
        mkStroke(card, 1, Color3.new(1,1,1), 0.88)

        local ok2, thumbnail = pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
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
        mkLabel(card, "UID: " .. player.UserId,
            UDim2.new(1,-96,0,14), UDim2.new(0,88,0,36),
            T.TextSub, nil, Enum.Font.Gotham, 11, 6)
        mkLabel(card, "Game: " .. gui.gameName .. "  ·  PlaceId: " .. game.PlaceId,
            UDim2.new(1,-96,0,14), UDim2.new(0,88,0,52),
            T.TextMuted, nil, Enum.Font.Gotham, 10, 6)

        local platBadge = Instance.new("Frame")
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

        local fpsCard = mkFrame(scrollingFrame, UDim2.new(1,0,0,34), nil, T.BgPanel, 0.18, 4)
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

        createSectionHeader("Community", scrollingFrame)
        createLabel("▶  YouTube  ·  youtube.com/@Vermax",    scrollingFrame)
        createLabel("✈  Telegram  ·  t.me/@vermax",          scrollingFrame)
        createLabel("💬  Discord  ·  discord.com/invite/vermax", scrollingFrame)
    end

    -- ══════════════════════════════════════
    --  STATS  (использует StatsModule)
    -- ══════════════════════════════════════
    local function showStats()
        clearContent()
        showScrollPanel()
        createSectionHeader("Session", scrollingFrame)

        local data = StatsModule.getData()
        local sessionStart = data.sessionStart

        local sessionCard = mkFrame(scrollingFrame, UDim2.new(1,0,0,76), nil, T.BgPanel, 0.10, 4)
        mkCorner(sessionCard, 10)
        mkStroke(sessionCard, 1, T.Stroke, 0.28)

        mkLabel(sessionCard, "🔥 " .. tostring(data.totalSessions) .. " sessions",
            UDim2.new(0,130,0,18), UDim2.new(0,10,0,8),
            T.Accent, nil, Enum.Font.GothamBold, 11, 5)

        local timerLbl = mkLabel(sessionCard, "00:00:00",
            UDim2.new(0,120,0,32), UDim2.new(0,10,0,26),
            T.TextMain, nil, Enum.Font.GothamBold, 26, 5)

        mkLabel(sessionCard, "⚡ streak: " .. tostring(data.streak) .. " days",
            UDim2.new(0,110,0,16), UDim2.new(0,10,0,58),
            T.AccentGlow, nil, Enum.Font.GothamMedium, 10, 5)

        mkLabel(sessionCard, StatsModule.formatTime(data.totalSeconds) .. " total",
            UDim2.new(0,100,0,18), UDim2.new(1,-106,0,8),
            T.TextSub, Enum.TextXAlignment.Right, Enum.Font.Gotham, 11, 5)

        do
            local conn; conn = RunService.Heartbeat:Connect(function()
                if not timerLbl.Parent then conn:Disconnect(); return end
                timerLbl.Text = StatsModule.formatTimerLive(tick() - sessionStart)
            end)
        end

        createSectionHeader("Activity — This Week", scrollingFrame)

        local barCard = mkFrame(scrollingFrame, UDim2.new(1,0,0,72), nil, T.BgPanel, 0.10, 4)
        mkCorner(barCard, 10)
        mkStroke(barCard, 1, T.Stroke, 0.28)

        local days = {"Mon","Tue","Wed","Thu","Fri","Sat","Sun"}
        local maxVal = 1
        for i = 1, 7 do
            local v = data.daySeconds[tostring(i)] or 0
            if v > maxVal then maxVal = v end
        end

        for i, dayName in ipairs(days) do
            local val    = data.daySeconds[tostring(i)] or 0
            local frac   = val / maxVal
            local barH   = math.max(4, math.floor(44 * frac))
            local xOff   = (i-1) * (math.floor(200/7)) + 10
            local isToday= (tonumber(os.date("%w")) == (i % 7))

            local barFr = Instance.new("Frame")
            barFr.BackgroundColor3       = isToday and T.Accent or T.BgBtn
            barFr.BackgroundTransparency = isToday and 0.25 or 0.0
            barFr.BorderSizePixel        = 0
            barFr.Size                   = UDim2.new(0, math.floor(200/7) - 4, 0, barH)
            barFr.Position               = UDim2.new(0, xOff, 1, -(barH + 18))
            barFr.ZIndex                 = 5
            barFr.Parent                 = barCard
            mkCorner(barFr, 3)

            mkLabel(barCard, dayName,
                UDim2.new(0, math.floor(200/7)-4, 0, 14),
                UDim2.new(0, xOff, 1, -16),
                isToday and T.Accent or T.TextMuted,
                Enum.TextXAlignment.Center,
                Enum.Font.GothamBold, 9, 5)
        end

        createSectionHeader("Top Tabs", scrollingFrame)
        local tabList = {}
        for name, count in pairs(data.tabClicks) do
            table.insert(tabList, {name=name, count=count})
        end
        table.sort(tabList, function(a,b) return a.count > b.count end)
        for i = 1, math.min(6, #tabList) do
            local entry = tabList[i]
            local row   = mkFrame(scrollingFrame, UDim2.new(1,0,0,28), nil, T.BgPanel, 0.20, 4)
            mkCorner(row, 6)
            mkLabel(row, entry.name,
                UDim2.new(0.7,0,1,0), UDim2.new(0,10,0,0),
                T.TextMain, nil, Enum.Font.GothamMedium, 12, 5)
            mkLabel(row, tostring(entry.count) .. "×",
                UDim2.new(0.3,0,1,0), UDim2.new(0.7,0,0,0),
                T.TextSub, Enum.TextXAlignment.Right, Enum.Font.Gotham, 11, 5)
        end
        if #tabList == 0 then
            createLabel("No tab data yet — navigate around!", scrollingFrame)
        end
    end

    -- ══════════════════════════════════════
    --  SETTINGS  (color picker)
    -- ══════════════════════════════════════
    local function saveCoordinates()
        local char = player.Character
        if not char then createNotification("ERROR","No character",3,7733968497); return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then createNotification("ERROR","No HRP",3,7733968497); return end
        local pos = hrp.CFrame.Position
        pcall(function()
            ensureFolder()
            writefile("MegaHack/coordinates.json", HttpService:JSONEncode({x=pos.X,y=pos.Y,z=pos.Z}))
        end)
        createNotification("COORDS","Saved: "..math.floor(pos.X)..","..math.floor(pos.Y)..","..math.floor(pos.Z),3)
    end

    local function teleportToCoordinates()
        pcall(function()
            if isfile("MegaHack/coordinates.json") then
                local d = HttpService:JSONDecode(readfile("MegaHack/coordinates.json"))
                local char = player.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = CFrame.new(d.x,d.y,d.z) end
                end
                createNotification("TELEPORT","Teleported!",3)
            else
                createNotification("ERROR","No saved position",3,7733968497)
            end
        end)
    end

    local function setupAntiBanKick()
        local mt = getrawmetatable(game)
        if mt then
            local oldNamecall = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "Kick" or method == "kick" then
                    createNotification("ANTI-KICK","Kick attempt blocked",3,7733960981); return nil
                end
                if method == "Ban" or method == "ban" then
                    createNotification("ANTI-BAN","Ban attempt blocked",3,7733960981); return nil
                end
                return oldNamecall(self, ...)
            end)
            setreadonly(mt, true)
        end
        createNotification("PROTECTION","Anti-Ban/Anti-Kick enabled",3,7733960981)
    end

    local function checkFunctions()
        local list = {
            "getgenv","getrenv","getrawmetatable","setreadonly","hookfunction",
            "newcclosure","isexecutorclosure","checkcaller","islclosure",
            "isfolder","makefolder","writefile","readfile","isfile","deletefile",
            "setclipboard","rconsoleprint","rconsoleclear","rconsolecreate",
            "firetouchinterest","fireclickdetector","fireproximityprompt",
            "getconnections","getsenv","getscripts","getcallingscript",
        }
        local av, unav = {}, {}
        for _, f in ipairs(list) do
            if type(getfenv()[f]) == "function" then
                table.insert(av, f)
            else
                table.insert(unav, f)
            end
        end
        return av, unav
    end

    local function showSettings()
        clearContent()
        showScrollPanel()

        createSectionHeader("Color Picker", scrollingFrame)

        if not ColorPickerModule then
            ColorPickerModule = loadSubmodule("colorpicker.lua")
            if ColorPickerModule then
                ColorPickerModule = ColorPickerModule({
                    TweenService      = TweenService,
                    UserInputService  = UserInputService,
                    RunService        = RunService,
                    T                 = T,
                    gui               = gui,
                    settings          = settings,
                    updateGuiColors   = updateGuiColors,
                    saveColorSettings = saveColorSettings,
                    createNotification = createNotification,
                })
            end
        end

        if ColorPickerModule then
            ColorPickerModule.createColorPicker(scrollingFrame, colorPickerConnections)
        else
            createLabel("⚠  Failed to load colorpicker.lua", scrollingFrame)
        end

        createSectionHeader("Transparency", scrollingFrame)
        for _, t in ipairs({{"0%",0},{"10%",0.1},{"25%",0.25},{"50%",0.5},{"75%",0.75}}) do
            createButton(t[1], scrollingFrame, function()
                settings.transparency = t[2]; updateGuiColors(); saveColorSettings()
            end)
        end

        createSectionHeader("Appearance", scrollingFrame)
        createButton("Lock GUI: " .. (settings.locked and "ON" or "OFF"), scrollingFrame, function()
            settings.locked = not settings.locked; saveColorSettings()
            createNotification("GUI","Lock: "..(settings.locked and "ON" or "OFF"),2)
        end)
        createButton("RGB Accents: " .. (settings.rgbAccent and "ON" or "OFF"), scrollingFrame, function()
            settings.rgbAccent = not settings.rgbAccent; saveColorSettings(); updateGuiColors()
        end)
        createButton("RGB Stroke: " .. (settings.rgbStroke and "ON" or "OFF"), scrollingFrame, function()
            settings.rgbStroke = not settings.rgbStroke; saveColorSettings(); updateGuiColors()
        end)

        createSectionHeader("Utilities", scrollingFrame)
        createButton("Copy Username", scrollingFrame, function()
            pcall(function() setclipboard(player.Name) end)
            createNotification("COPY","Username copied!",2)
        end)
        createButton("Copy User ID", scrollingFrame, function()
            pcall(function() setclipboard(tostring(player.UserId)) end)
            createNotification("COPY","UserID copied!",2)
        end)
        createButton("Copy Server ID", scrollingFrame, function()
            pcall(function() setclipboard(game.JobId) end)
            createNotification("COPY","Server ID copied!",2)
        end)

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
                if servers.data and #servers.data > 0 then
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

        createSectionHeader("Coordinates", scrollingFrame)
        createButton("Save Current Position",      scrollingFrame, saveCoordinates)
        createButton("Teleport to Saved Position", scrollingFrame, teleportToCoordinates)

        createSectionHeader("Security", scrollingFrame)
        createButton("Enable Anti-Ban / Anti-Kick", scrollingFrame, setupAntiBanKick)
        createButton("Check Executor Functions",    scrollingFrame, function()
            local av, unav = checkFunctions()
            createNotification("FUNCTIONS","Available: "..#av.."/"..(#av+#unav),5,7733960981)
        end)

        createSectionHeader("Actions", scrollingFrame)
        createButton("Save Settings", scrollingFrame, saveSettings)
        createButton("Close GUI",     scrollingFrame, function() gui.screenGui:Destroy() end)
    end

    -- ══════════════════════════════════════
    --  DRAGGABLE
    -- ══════════════════════════════════════
    local function MakeDraggable(frame, dragPart)
        dragPart = dragPart or frame
        local dragging, dragInput, mousePos, framePos
        dragPart.InputBegan:Connect(function(input)
            if settings.locked then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
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
            -- Загружаем модуль статистики
            StatsModule = loadSubmodule("stats.lua")
            if not StatsModule then
                createNotification("ERROR", "Failed to load stats.lua", 5, 7733968497)
                return
            end
            -- Инициализируем StatsModule с нужными зависимостями
            StatsModule = StatsModule({
                RunService         = RunService,
                HttpService        = HttpService,
                Players            = Players,
                player             = player,
                createNotification = createNotification,
            })
            StatsModule.init()

            -- Остальная инициализация
            loadColorSettings()

            -- Сайдбар: специальные вкладки
            local specialOrder = {"Home", "Games", "Stats", "Settings", "All Scripts"}
            local specialFuncs = {
                Home = function()
                    StatsModule.recordTabClick("Home")
                    showHome(); updateGuiColors()
                end,
                Games = function()
                    StatsModule.recordTabClick("Games")
                    showGames(); updateGuiColors()
                end,
                Stats = function()
                    StatsModule.recordTabClick("Stats")
                    showStats(); updateGuiColors()
                end,
                Settings = function()
                    StatsModule.recordTabClick("Settings")
                    showSettings(); updateGuiColors()
                end,
                ["All Scripts"] = function()
                    StatsModule.recordTabClick("All Scripts")
                    showAllScripts(); updateGuiColors()
                end,
            }
            for _, name in ipairs(specialOrder) do
                createButton(name, catScroll, specialFuncs[name], true)
            end

            -- Сайдбар: категории игр
            local sortedCats = {}
            for catName in pairs(categoryMap) do table.insert(sortedCats, catName) end
            table.sort(sortedCats)
            for _, catName in ipairs(sortedCats) do
                createButton(catName, catScroll, function()
                    StatsModule.recordTabClick(catName)
                    loadHacksFromCategory(catName)
                    updateGuiColors()
                end, true)
            end

            -- Dragging
            MakeDraggable(mainFrame, headerFrame)
            MakeDraggable(reopenButton, reopenButton)

            -- Close / Reopen
            closeBtn.MouseButton1Click:Connect(function()
                StatsModule.finishCurrentSession()   -- <<< завершаем сессию через модуль
                TweenService:Create(mainFrame,
                    TweenInfo.new(0.25, Enum.EasingStyle.Quint),
                    {Size=UDim2.new(0,590,0,0), BackgroundTransparency=1}
                ):Play()
                task.delay(0.28, function()
                    mainFrame.Visible = false
                    mainFrame.Size    = UDim2.new(0,590,0,400)
                    mainFrame.BackgroundTransparency = settings.transparency
                    reopenButton.Visible = true
                    StatsModule.startSessionTimer()
                end)
            end)

            reopenButton.MouseButton1Click:Connect(function()
                mainFrame.Visible = true
                mainFrame.Size    = UDim2.new(0,590,0,0)
                mainFrame.BackgroundTransparency = 1
                reopenButton.Visible = false
                TweenService:Create(mainFrame,
                    TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    {Size=UDim2.new(0,590,0,400), BackgroundTransparency=settings.transparency}
                ):Play()
            end)

            -- Intro animation
            mainFrame.Size                   = UDim2.new(0,0,0,0)
            mainFrame.BackgroundTransparency = 1
            TweenService:Create(mainFrame,
                TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                {Size=UDim2.new(0,590,0,400), BackgroundTransparency=settings.transparency}
            ):Play()

            -- Default view
            StatsModule.recordTabClick("Home")
            showHome()
            updateGuiColors()

            task.delay(0.12, function()
                local first = catScroll:FindFirstChildWhichIsA("TextButton")
                if first then
                    first:SetAttribute("Active", true)
                    TweenService:Create(first, TweenInfo.new(0.18), {
                        BackgroundTransparency = 0.78,
                        TextColor3 = T.Accent,
                    }):Play()
                end
            end)

            createNotification("MEGAHACK V2", "Loaded  ·  " .. platformName, 3, 74283928898866)
        end
    }
end
