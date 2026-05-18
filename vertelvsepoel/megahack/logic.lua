-- ══════════════════════════════════════════════════════════════════
--  logic.lua — Вся логика: Home, Stats, Settings, Games, поиск,
--              категории, dragging, RGB, color picker
-- ══════════════════════════════════════════════════════════════════
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
    local isMobile           = deps.isMobile
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
    --  RGB СИСТЕМА (одно соединение на всё)
    -- ══════════════════════════════════════
    local rgbTargets  = {}
    local rgbLoopConn = nil

    local function startRgbLoop()
        if rgbLoopConn then return end
        rgbLoopConn = RunService.Heartbeat:Connect(function()
            if #rgbTargets == 0 then return end
            local col = Color3.fromHSV((tick() % 5) / 5, 1, 1)
            for i = #rgbTargets, 1, -1 do
                local e = rgbTargets[i]
                if e.obj and e.obj.Parent then
                    pcall(function() e.obj[e.prop] = col end)
                else
                    table.remove(rgbTargets, i)
                end
            end
        end)
    end

    local function stopRgbLoop()
        if rgbLoopConn then
            pcall(function() rgbLoopConn:Disconnect() end)
            rgbLoopConn = nil
        end
        rgbTargets = {}
    end

    local function addRgbTarget(obj, prop)
        table.insert(rgbTargets, { obj = obj, prop = prop or "TextColor3" })
    end

    -- ══════════════════════════════════════
    --  SETTINGS STATE
    -- ══════════════════════════════════════
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

    -- ══════════════════════════════════════
    --  STATS STATE
    -- ══════════════════════════════════════
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
                local data = HttpService:JSONDecode(readfile("MegaHack/stats.json"))
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

    local function updateDayStats(secs)
        local dow    = tonumber(os.date("%w")) or 0
        local dayIdx = dow == 0 and 7 or dow
        local key    = tostring(dayIdx)
        statsData.daySeconds[key] = (statsData.daySeconds[key] or 0) + secs
        local today = math.floor(os.time() / 86400)
        if statsData.lastDayPlayed == today - 1 then
            statsData.streak = statsData.streak + 1
        elseif statsData.lastDayPlayed ~= today then
            statsData.streak = 1
        end
        statsData.lastDayPlayed = today
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
                statsData.totalSeconds = statsData.totalSeconds + 60
                statsData.sessionStart = tick()
                saveStats()
            end
        end)
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
            if isfile("MegaHack/colorSettings.json") then
                local data = HttpService:JSONDecode(readfile("MegaHack/colorSettings.json"))
                if data.bgColor     then settings.colors.bgColor     = Color3.new(table.unpack(data.bgColor))     end
                if data.textColor   then settings.colors.textColor   = Color3.new(table.unpack(data.textColor))   end
                if data.strokeColor then settings.colors.strokeColor = Color3.new(table.unpack(data.strokeColor)) end
                if data.accentColor then settings.colors.accentColor = Color3.new(table.unpack(data.accentColor)) end
                if data.transparency ~= nil then settings.transparency = data.transparency end
                if data.rgbAccent   ~= nil  then settings.rgbAccent   = data.rgbAccent    end
                if data.rgbStroke   ~= nil  then settings.rgbStroke   = data.rgbStroke    end
            end
        end)
    end

    local function saveSettings()
        saveColorSettings()
        createNotification("SETTINGS", "Сохранено!", 3)
    end

    -- ══════════════════════════════════════
    --  UPDATE GUI COLORS
    -- ══════════════════════════════════════
    local function updateGuiColors()
        stopRgbLoop()

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

        for _, obj in ipairs(mainFrame:GetDescendants()) do
            if obj:IsA("UIStroke") then
                if settings.rgbStroke then
                    addRgbTarget(obj, "Color")
                else
                    obj.Color = str
                end
            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if settings.rgbAccent then
                    addRgbTarget(obj, "TextColor3")
                else
                    if obj:GetAttribute("TextRole") == "main" then
                        obj.TextColor3 = tx
                    end
                end
            elseif obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
                if obj.Name == "SidebarFrame" then
                    obj.BackgroundColor3 = T.BgSide
                end
            end
        end

        if #rgbTargets > 0 then startRgbLoop() end
    end

    -- ══════════════════════════════════════
    --  CLEAR CONTENT
    -- ══════════════════════════════════════
    local function clearContent()
        stopRgbLoop()
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
        if h > 0 then return string.format("%dч %02dм", h, m)
        else return string.format("%02dм %02dс", m, secs % 60) end
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

    local TWEEN_F = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- ══════════════════════════════════════
    --  LOAD CATEGORY (скрипты)
    -- ══════════════════════════════════════
    local function loadHacksFromCategory(categoryName)
        clearContent()
        local fileName = categoryMap[categoryName]
        if not fileName then
            createSectionHeader("Не найдено", scrollingFrame)
            createLabel("⚠  Нет записи в base.lua: " .. categoryName, scrollingFrame)
            return
        end
        if not HubData[categoryName] then
            local data = safeLoad(baseUrl .. "/" .. fileName)
            if type(data) == "table" and #data > 0 then
                HubData[categoryName] = data
            else
                createSectionHeader("Ошибка загрузки", scrollingFrame)
                createLabel("⚠  Пусто или ошибка: " .. categoryName, scrollingFrame)
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
                        createNotification("ERROR", tostring(err):sub(1,80), 5, 7733968497)
                    end
                end)
            end
        end
        updateGuiColors()
    end

    -- ══════════════════════════════════════
    --  GAMES DATABASE
    --  { "Название", placeId, "ключCategoryMap или nil", "описание" }
    -- ══════════════════════════════════════
    local GamesDB = {
        { "Brookhaven 🏡RP",           4924922222,   "Brookhaven",      "Популярный ролевой город"       },
        { "Evade",                      11857579316,  "Evade",           "Побег от монстров"              },
        { "Murder Mystery 2",           142823291,    "MM2",             "Классическая игра убийства"     },
        { "Blox Fruits",                2753915549,   "BloxFruit",       "One Piece RPG приключение"      },
        { "Blade Ball",                 13772394625,  "BladeBall",       "Отбивай шары чтобы выжить"      },
        { "Tower of Hell",              1962086868,   "TowerOfHell",     "Обби со случайными башнями"     },
        { "Adopt Me!",                  920587237,    "AdoptMe",         "Корми и торгуй питомцами"       },
        { "Ragdoll Engine",             537413528,    "RagdollEngine",   "Физика тряпичной куклы"         },
        { "Natural Disaster Survival",  189707,       "NaturalDisaster", "Переживи катастрофы"            },
        { "Grow a Garden",              126884695634, "GrowGarden",      "Выращивай растения"             },
        { "Rivals",                     17625359962,  "Rivals",          "FPS шутер"                      },
        { "Forsaken",                   6456798030,   "FORSAKEN",        "Хоррор побег"                   },
        { "Loot Up",                    16767714145,  "LootUp",          "RPG лут и прокачка"             },
        { "Duel MVS",                   14390898948,  "DuelsMVS",        "PvP дуэли"                      },
        { "Violence District",          12660203816,  "ViolenceDistrict","Открытый мир криминал"          },
        { "3008 (IKEA)",                2768379856,   "IKEA3008",        "Выживание в IKEA"               },
        { "Steal a Brainroot",          12345678901,  "StealBrainRoot",  "Укради и сбеги"                 },
        { "Night",                      98765432100,  "Night",           "Атмосферная ночная игра"        },
        { "Weird Strict Dad",           11111111111,  "Weird",           "Скрытное побег от папы"         },
        -- Сюда добавляй новые игры:
        -- { "Название", placeId, "ключКатегории", "описание" },
    }

    -- ══════════════════════════════════════
    --  LAZY ICON LOADER
    -- ══════════════════════════════════════
    local iconCache = {}

    local function getIconUrl(placeId)
        if iconCache[placeId] then return iconCache[placeId] end
        local url = "rbxthumb://type=GameIcon&id=" .. tostring(placeId) .. "&w=150&h=150"
        iconCache[placeId] = url
        return url
    end

    local function bindLazyIcons(sf)
        local margin = sf.AbsoluteSize.Y * 1.5
        local function refresh()
            local canvasY = sf.CanvasPosition.Y
            for _, card in ipairs(sf:GetChildren()) do
                if card:IsA("Frame") and card:GetAttribute("PlaceId") then
                    local icon = card:FindFirstChild("GameIcon")
                    if icon and icon:IsA("ImageLabel") and icon.Image == "" then
                        local cardTop = card.AbsolutePosition.Y - sf.AbsolutePosition.Y + canvasY
                        if cardTop < canvasY + margin then
                            icon.Image = getIconUrl(card:GetAttribute("PlaceId"))
                        end
                    end
                end
            end
        end
        sf:GetPropertyChangedSignal("CanvasPosition"):Connect(refresh)
        task.defer(refresh)
    end

    -- ══════════════════════════════════════
    --  SHOW GAMES
    -- ══════════════════════════════════════
    local function showGames()
        clearContent()
        createSectionHeader("🎮 Games  (" .. #GamesDB .. ")", scrollingFrame)

        -- Поисковая строка
        local searchBox = Instance.new("TextBox")
        searchBox.Size                   = UDim2.new(1,0,0,34)
        searchBox.BackgroundColor3       = T.BgPanel
        searchBox.BackgroundTransparency = 0.2
        searchBox.TextColor3             = T.TextMain
        searchBox.PlaceholderText        = "🔍  Найти игру..."
        searchBox.PlaceholderColor3      = T.TextMuted
        searchBox.TextSize               = 13
        searchBox.Text                   = ""
        searchBox.Font                   = Enum.Font.Gotham
        searchBox.ClearTextOnFocus       = false
        searchBox.ZIndex                 = 5
        searchBox.Parent                 = scrollingFrame
        searchBox:SetAttribute("TextRole","main")
        mkCorner(searchBox, 9)
        mkStroke(searchBox, 1, T.Stroke, 0.3)
        local sbPad = Instance.new("UIPadding")
        sbPad.PaddingLeft = UDim.new(0, 10)
        sbPad.Parent      = searchBox

        -- Держатель карточек (отдельный Frame, чтобы не трогать searchBox при фильтрации)
        local cardHolder = Instance.new("Frame")
        cardHolder.BackgroundTransparency = 1
        cardHolder.Size                   = UDim2.new(1,0,0,0)
        cardHolder.AutomaticSize          = Enum.AutomaticSize.Y
        cardHolder.ZIndex                 = 4
        cardHolder.Parent                 = scrollingFrame

        local cardLayout = Instance.new("UIListLayout")
        cardLayout.Padding   = UDim.new(0,6)
        cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
        cardLayout.Parent    = cardHolder

        -- Строитель карточек
        local CARD_H   = 56
        local ICON_SZ  = 38
        local BATCH    = 14

        local function buildCard(entry)
            local name, placeId, scriptKey, desc = entry[1], entry[2], entry[3], entry[4]

            local card = Instance.new("TextButton")
            card.Size                   = UDim2.new(1,0,0,CARD_H)
            card.BackgroundColor3       = T.BgPanel
            card.BackgroundTransparency = 0.38
            card.BorderSizePixel        = 0
            card.Text                   = ""
            card.AutoButtonColor        = false
            card.ZIndex                 = 5
            card:SetAttribute("PlaceId", placeId)
            card.Parent                 = cardHolder
            mkCorner(card, 10)
            local cs = mkStroke(card, 1, Color3.new(1,1,1), 0.85)

            -- Иконка (пустая — ленивая загрузка)
            local icon = Instance.new("ImageLabel")
            icon.Name                   = "GameIcon"
            icon.Size                   = UDim2.new(0,ICON_SZ,0,ICON_SZ)
            icon.Position               = UDim2.new(0,9,0.5,-ICON_SZ/2)
            icon.BackgroundColor3       = T.BgSide
            icon.BackgroundTransparency = 0.15
            icon.Image                  = ""
            icon.ZIndex                 = 7
            icon.Parent                 = card
            mkCorner(icon, 7)

            -- Название
            local nameLbl = Instance.new("TextLabel")
            nameLbl.Text              = name
            nameLbl.Font              = Enum.Font.GothamMedium
            nameLbl.TextSize          = 13
            nameLbl.TextColor3        = T.TextMain
            nameLbl.TextXAlignment    = Enum.TextXAlignment.Left
            nameLbl.TextTruncate      = Enum.TextTruncate.AtEnd
            nameLbl.Size              = UDim2.new(1, -(ICON_SZ+scriptKey and 80 or 30), 0, 18)
            nameLbl.Position          = UDim2.new(0, ICON_SZ+16, 0, 10)
            nameLbl.BackgroundTransparency = 1
            nameLbl.ZIndex            = 7
            nameLbl.Parent            = card
            nameLbl:SetAttribute("TextRole","main")

            -- Описание
            local descLbl = Instance.new("TextLabel")
            descLbl.Text              = desc or ""
            descLbl.Font              = Enum.Font.Gotham
            descLbl.TextSize          = 10
            descLbl.TextColor3        = T.TextMuted
            descLbl.TextXAlignment    = Enum.TextXAlignment.Left
            descLbl.TextTruncate      = Enum.TextTruncate.AtEnd
            descLbl.Size              = UDim2.new(1, -(ICON_SZ+24), 0, 14)
            descLbl.Position          = UDim2.new(0, ICON_SZ+16, 0, 31)
            descLbl.BackgroundTransparency = 1
            descLbl.ZIndex            = 7
            descLbl.Parent            = card

            -- Бейдж категории
            if scriptKey then
                local badge = Instance.new("Frame")
                badge.AutomaticSize          = Enum.AutomaticSize.X
                badge.Size                   = UDim2.new(0,0,0,15)
                badge.Position               = UDim2.new(1,-6,0.5,-7)
                badge.AnchorPoint            = Vector2.new(1,0)
                badge.BackgroundColor3       = T.Accent
                badge.BackgroundTransparency = 0.50
                badge.BorderSizePixel        = 0
                badge.ZIndex                 = 8
                badge.Parent                 = card
                mkCorner(badge, 4)
                local bp = Instance.new("UIPadding")
                bp.PaddingLeft = UDim.new(0,5); bp.PaddingRight = UDim.new(0,5); bp.Parent = badge
                local bTxt = Instance.new("TextLabel")
                bTxt.Text              = scriptKey
                bTxt.Font              = Enum.Font.GothamBold
                bTxt.TextSize          = 9
                bTxt.TextColor3        = T.TextMain
                bTxt.BackgroundTransparency = 1
                bTxt.AutomaticSize     = Enum.AutomaticSize.X
                bTxt.Size              = UDim2.new(0,0,1,0)
                bTxt.ZIndex            = 9
                bTxt.Parent            = badge
            end

            -- Hover (только PC)
            if not isMobile then
                card.MouseEnter:Connect(function()
                    TweenService:Create(card, TWEEN_F, {BackgroundTransparency=0.18, BackgroundColor3=T.BgBtnHov}):Play()
                    TweenService:Create(cs,   TWEEN_F, {Transparency=0.50}):Play()
                end)
                card.MouseLeave:Connect(function()
                    TweenService:Create(card, TWEEN_F, {BackgroundTransparency=0.38, BackgroundColor3=T.BgPanel}):Play()
                    TweenService:Create(cs,   TWEEN_F, {Transparency=0.85}):Play()
                end)
            end

            card.MouseButton1Click:Connect(function()
                TweenService:Create(card, TweenInfo.new(0.05), {BackgroundColor3=T.Accent, BackgroundTransparency=0.28}):Play()
                task.delay(0.1, function()
                    TweenService:Create(card, TWEEN_F, {BackgroundColor3=T.BgBtnHov, BackgroundTransparency=0.18}):Play()
                end)
                if scriptKey and categoryMap[scriptKey] then
                    recordTabClick(scriptKey)
                    loadHacksFromCategory(scriptKey)
                else
                    createNotification(name, "Скриптов для этой игры пока нет", 3)
                end
            end)
        end

        -- Инкрементальный рендер: BATCH карточек за кадр
        local function renderList(list)
            for _, c in ipairs(cardHolder:GetChildren()) do
                if not c:IsA("UIListLayout") then c:Destroy() end
            end
            local i = 1
            local function batch()
                local n = 0
                while i <= #list and n < BATCH do
                    buildCard(list[i]); i = i + 1; n = n + 1
                end
                if i <= #list then
                    task.wait(); batch()
                else
                    task.defer(function() bindLazyIcons(scrollingFrame) end)
                end
            end
            batch()
        end

        renderList(GamesDB)

        -- Фильтрация с debounce
        local token = 0
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local q = string.lower(searchBox.Text)
            local t = tick(); token = t
            task.delay(0.3, function()
                if token ~= t then return end
                if q == "" then renderList(GamesDB); return end
                local filtered = {}
                for _, e in ipairs(GamesDB) do
                    local n  = string.lower(e[1])
                    local k  = string.lower(e[3] or "")
                    local d  = string.lower(e[4] or "")
                    if string.find(n,q,1,true) or string.find(k,q,1,true) or string.find(d,q,1,true) then
                        table.insert(filtered, e)
                    end
                end
                renderList(filtered)
            end)
        end)
    end

    -- ══════════════════════════════════════
    --  SHOW ALL SCRIPTS (с исправленным debounce)
    -- ══════════════════════════════════════
    local function showAllScripts()
        clearContent()
        createSectionHeader("Поиск скриптов", scrollingFrame)

        local searchBox = Instance.new("TextBox")
        searchBox.Size                   = UDim2.new(1,0,0,34)
        searchBox.BackgroundColor3       = T.BgPanel
        searchBox.BackgroundTransparency = 0.2
        searchBox.TextColor3             = T.TextMain
        searchBox.PlaceholderText        = "Введи название скрипта..."
        searchBox.PlaceholderColor3      = T.TextMuted
        searchBox.TextSize               = 13
        searchBox.Text                   = ""
        searchBox.Font                   = Enum.Font.Gotham
        searchBox.ClearTextOnFocus       = false
        searchBox.ZIndex                 = 5
        searchBox.Parent                 = scrollingFrame
        searchBox:SetAttribute("TextRole","main")
        mkCorner(searchBox, 9)
        mkStroke(searchBox, 1, T.Stroke, 0.3)
        local sbPad = Instance.new("UIPadding")
        sbPad.PaddingLeft = UDim.new(0,10); sbPad.Parent = searchBox

        local resultsLabel = createLabel("Начни вводить...", scrollingFrame)
        resultsLabel.TextColor3 = T.TextMuted

        local function updateResults(query)
            for _, child in ipairs(scrollingFrame:GetChildren()) do
                if child ~= searchBox and child ~= resultsLabel
                   and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                    child:Destroy()
                end
            end
            if query == "" then resultsLabel.Text = "Начни вводить..."; return end
            resultsLabel.Text = "Ищем..."

            -- Локальный поиск по HubData
            local mhResults = {}
            for categoryName, hacks in pairs(HubData) do
                if type(hacks) == "table" then
                    for _, hack in ipairs(hacks) do
                        if type(hack)=="table" and type(hack[1])=="string" then
                            if string.find(string.lower(hack[1]), string.lower(query), 1, true) then
                                table.insert(mhResults, {name=hack[1], category=categoryName, func=hack[2]})
                            end
                        end
                    end
                end
            end

            -- ScriptBlox (асинхронно)
            task.spawn(function()
                local sbResults = {}
                local ok2, response = pcall(function()
                    return HttpService:GetAsync(
                        "https://scriptblox.com/api/script/search?q=" .. HttpService:UrlEncode(query)
                    )
                end)
                if ok2 then
                    local data = HttpService:JSONDecode(response)
                    if data and data.result and data.result.scripts then
                        for _, s in ipairs(data.result.scripts) do
                            table.insert(sbResults, {name=s.title, scriptId=s._id})
                        end
                    end
                end

                resultsLabel.Text = "Найдено: " .. (#mhResults + #sbResults)

                local all = {}
                for _, r in ipairs(mhResults) do table.insert(all, r) end
                for _, r in ipairs(sbResults) do
                    table.insert(all, {name=r.name.."  [ScriptBlox]", category="ScriptBlox", scriptId=r.scriptId})
                end

                local i = 1
                local function batch()
                    local n = 0
                    while i <= #all and n < 10 do
                        local r = all[i]
                        createButton(r.name, scrollingFrame, function()
                            if r.func then
                                local ok3,e = pcall(r.func)
                                if not ok3 then createNotification("ERROR",tostring(e):sub(1,80),5,7733968497) end
                            elseif r.scriptId then
                                createNotification("ScriptBlox", "ID: "..r.scriptId, 4)
                            end
                        end)
                        i = i + 1; n = n + 1
                    end
                    if i <= #all then task.wait(); batch() end
                end
                batch()
            end)
        end

        local token = 0
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            if #searchBox.Text < 3 then return end
            local t = tick(); token = t
            task.delay(0.45, function()
                if token == t then updateResults(searchBox.Text) end
            end)
        end)
        searchBox.FocusLost:Connect(function()
            updateResults(searchBox.Text)
        end)
    end

    -- ══════════════════════════════════════
    --  SHOW HOME
    -- ══════════════════════════════════════
    local function showHome()
        clearContent()
        createSectionHeader("Обзор", scrollingFrame)

        local card = mkFrame(scrollingFrame, UDim2.new(1,0,0,90), nil, T.BgPanel, 0.15, 4)
        mkCorner(card, 8)

        local ok2, thumbnail = pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
        end)
        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Size                   = UDim2.new(0,64,0,64)
        avatarImg.Position               = UDim2.new(0,12,0.5,-32)
        avatarImg.BackgroundColor3       = T.BgSide
        avatarImg.BackgroundTransparency = 0
        avatarImg.Image                  = ok2 and thumbnail or ""
        avatarImg.ZIndex                 = 5
        avatarImg.Parent                 = card
        mkCorner(avatarImg, 32)

        mkLabel(card, player.Name,
            UDim2.new(1,-90,0,20), UDim2.new(0,86,0,14),
            T.TextMain, Enum.TextXAlignment.Left, Enum.Font.GothamBold, 15, 5)
            :SetAttribute("TextRole","main")

        mkLabel(card, "UserID: " .. player.UserId,
            UDim2.new(1,-90,0,14), UDim2.new(0,86,0,36),
            T.TextSub, Enum.TextXAlignment.Left, Enum.Font.Gotham, 11, 5)

        mkLabel(card, "Game: " .. gui.gameName .. "  ·  PlaceId: " .. game.PlaceId,
            UDim2.new(1,-90,0,14), UDim2.new(0,86,0,52),
            T.TextMuted, Enum.TextXAlignment.Left, Enum.Font.Gotham, 10, 5)

        mkLabel(card, platformName,
            UDim2.new(0,60,0,14), UDim2.new(0,86,0,68),
            T.AccentGlow, Enum.TextXAlignment.Left, Enum.Font.GothamBold, 10, 5)

        -- FPS счётчик
        local fpsCard = mkFrame(scrollingFrame, UDim2.new(1,0,0,32), nil, T.BgPanel, 0.2, 4)
        mkCorner(fpsCard, 7)
        local fpsLabel = mkLabel(fpsCard, "FPS: ...",
            UDim2.new(1,-16,1,0), UDim2.new(0,16,0,0),
            T.TextMain, Enum.TextXAlignment.Left, Enum.Font.Gotham, 12, 5)
        fpsLabel:SetAttribute("TextRole","main")

        local lastTime, frameCount = tick(), 0
        local fpsConn
        fpsConn = RunService.Heartbeat:Connect(function()
            frameCount = frameCount + 1
            local cur  = tick()
            if cur - lastTime >= 1 then
                if not fpsLabel.Parent then fpsConn:Disconnect(); return end
                fpsLabel.Text = "FPS: " .. frameCount
                frameCount = 0; lastTime = cur
            end
        end)

        createSectionHeader("Ссылки", scrollingFrame)
        createLabel("YouTube  ·  https://youtube.com/@Vermax",   scrollingFrame)
        createLabel("Telegram  ·  https://t.me/@vermax",          scrollingFrame)
        createLabel("Discord  ·  https://discord.com/invite/vermax", scrollingFrame)
    end

    -- ══════════════════════════════════════
    --  SHOW STATS
    -- ══════════════════════════════════════
    local function showStats()
        clearContent()
        createSectionHeader("Статистика", scrollingFrame)

        -- Карточка сессии
        local sessionCard = mkFrame(scrollingFrame, UDim2.new(1,0,0,72), nil, T.BgPanel, 0.1, 4)
        mkCorner(sessionCard, 8); mkStroke(sessionCard, 1, T.Stroke, 0.3)

        local sessLbl = mkLabel(sessionCard, "🔥 " .. statsData.totalSessions .. " сессий",
            UDim2.new(0,130,0,18), UDim2.new(0,8,0,6),
            T.Accent, Enum.TextXAlignment.Left, Enum.Font.GothamBold, 11, 5)

        local timerLbl = mkLabel(sessionCard, "Сессия: " .. fmtTimerLive(tick() - statsData.sessionStart),
            UDim2.new(1,-140,0,22), UDim2.new(0,8,0,26),
            T.TextMain, Enum.TextXAlignment.Left, Enum.Font.GothamBold, 14, 5)
        timerLbl:SetAttribute("TextRole","main")

        local totalLbl = mkLabel(sessionCard, "Всего: " .. fmtTime(statsData.totalSeconds),
            UDim2.new(0,140,0,16), UDim2.new(0,8,0,50),
            T.TextSub, Enum.TextXAlignment.Left, Enum.Font.Gotham, 11, 5)

        local streakLbl = mkLabel(sessionCard, "🔥 Стрик: " .. statsData.streak .. " дней",
            UDim2.new(0,110,0,16), UDim2.new(1,-118,0,50),
            T.AccentGlow, Enum.TextXAlignment.Right, Enum.Font.GothamBold, 11, 5)

        local finBtn = Instance.new("TextButton")
        finBtn.Size=UDim2.new(0,110,0,22); finBtn.Position=UDim2.new(1,-118,0,4)
        finBtn.BackgroundColor3=T.Accent; finBtn.BackgroundTransparency=0.35
        finBtn.BorderSizePixel=0; finBtn.Text="Завершить"; finBtn.TextColor3=T.TextMain
        finBtn.TextSize=11; finBtn.Font=Enum.Font.GothamBold; finBtn.ZIndex=5; finBtn.Parent=sessionCard
        finBtn:SetAttribute("TextRole","main")
        mkCorner(finBtn,5); mkStroke(finBtn,1,T.Accent,0.4)
        finBtn.MouseButton1Click:Connect(function()
            finishCurrentSession(); startSessionTimer()
            createNotification("STATS","Сессия сохранена!",3,7733960981)
            sessLbl.Text  = "🔥 " .. statsData.totalSessions .. " сессий"
            totalLbl.Text = "Всего: " .. fmtTime(statsData.totalSeconds)
            streakLbl.Text= "🔥 Стрик: " .. statsData.streak .. " дней"
        end)

        local timerRunning = true
        task.spawn(function()
            while timerRunning do
                task.wait(1)
                if not sessionCard.Parent then timerRunning=false; break end
                timerLbl.Text = "Сессия: " .. fmtTimerLive(tick()-statsData.sessionStart)
            end
        end)
        sessionCard.AncestryChanged:Connect(function()
            if not sessionCard.Parent then timerRunning=false end
        end)

        -- Топ вкладок
        createSectionHeader("Топ вкладок", scrollingFrame)
        local tabList = {}
        for name, cnt in pairs(statsData.tabClicks) do table.insert(tabList, {name=name, cnt=cnt}) end
        table.sort(tabList, function(a,b) return a.cnt > b.cnt end)

        if #tabList == 0 then
            createLabel("Открой несколько вкладок — здесь появится статистика", scrollingFrame)
        else
            local total = 0
            for _, t in ipairs(tabList) do total = total + t.cnt end
            if total == 0 then total = 1 end
            local palette = {T.Accent, T.AccentHov, T.AccentGlow,
                Color3.new(math.min(T.Accent.R*0.6,1), 0, 0),
                Color3.new(math.min(T.Accent.R*0.4,1), 0, 0)}

            for i=1, math.min(8, #tabList) do
                local t   = tabList[i]
                local pct = t.cnt / total
                local barCard = mkFrame(scrollingFrame, UDim2.new(1,0,0,30), nil, T.BgPanel, 0.15, 4)
                mkCorner(barCard, 6)
                local nm = #t.name > 18 and t.name:sub(1,17).."…" or t.name
                mkLabel(barCard, nm, UDim2.new(0,100,1,0), UDim2.new(0,8,0,0), T.TextMain,
                    Enum.TextXAlignment.Left, Enum.Font.Gotham, 11, 5)
                local track = mkFrame(barCard, UDim2.new(1,-145,0,8), UDim2.new(0,112,0.5,-4), T.BgBtn, 0.1, 5)
                mkCorner(track, 4)
                local fill = mkFrame(track, UDim2.new(0,0,1,0), UDim2.new(0,0,0,0), palette[i] or T.Accent, 0.2, 6)
                mkCorner(fill, 4)
                TweenService:Create(fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size=UDim2.new(pct,0,1,0)
                }):Play()
                mkLabel(barCard, tostring(t.cnt).." раз", UDim2.new(0,44,1,0), UDim2.new(1,-46,0,0),
                    T.TextSub, Enum.TextXAlignment.Right, Enum.Font.Gotham, 10, 5)
            end
        end

        createSectionHeader("Управление", scrollingFrame)
        createButton("Сбросить статистику", scrollingFrame, function()
            statsData.totalSeconds=0; statsData.totalSessions=0; statsData.tabClicks={}
            statsData.daySeconds={}; statsData.streak=0; statsData.lastDayPlayed=0
            statsData.sessionStart=tick(); saveStats()
            createNotification("STATS","Статистика сброшена!",3,7733968497)
            clearContent(); showStats(); updateGuiColors()
        end)
    end

    -- ══════════════════════════════════════
    --  COLOR PICKER
    -- ══════════════════════════════════════
    local function createColorPicker(parent)
        local selType          = "bgColor"
        local curH, curS, curV = Color3.toHSV(settings.colors.bgColor)
        local curR = math.floor(settings.colors.bgColor.R*255+0.5)
        local curG = math.floor(settings.colors.bgColor.G*255+0.5)
        local curB = math.floor(settings.colors.bgColor.B*255+0.5)

        local function syncFromType()
            local col = settings.colors[selType]
            curH,curS,curV = Color3.toHSV(col)
            curR=math.floor(col.R*255+0.5); curG=math.floor(col.G*255+0.5); curB=math.floor(col.B*255+0.5)
        end

        local container = Instance.new("Frame")
        container.BackgroundTransparency=1; container.Size=UDim2.new(1,0,0,340)
        container.ZIndex=4; container.Parent=parent
        local innerLayout = Instance.new("UIListLayout")
        innerLayout.Padding=UDim.new(0,6); innerLayout.SortOrder=Enum.SortOrder.LayoutOrder
        innerLayout.Parent=container
        innerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.Size=UDim2.new(1,0,0,innerLayout.AbsoluteContentSize.Y+4)
        end)

        -- Тип цвета
        local typeRow = Instance.new("Frame")
        typeRow.BackgroundTransparency=1; typeRow.Size=UDim2.new(1,0,0,28)
        typeRow.LayoutOrder=1; typeRow.ZIndex=4; typeRow.Parent=container
        local trLayout = Instance.new("UIListLayout")
        trLayout.FillDirection=Enum.FillDirection.Horizontal; trLayout.Padding=UDim.new(0,4)
        trLayout.SortOrder=Enum.SortOrder.LayoutOrder; trLayout.Parent=typeRow

        local typeBtnMap = {}
        local typeItems  = {
            {label="Фон",    key="bgColor"},
            {label="Текст",  key="textColor"},
            {label="Обводка",key="strokeColor"},
            {label="Акцент", key="accentColor"},
        }
        local updatePickerUI

        local function refreshTypeBtns(activeKey)
            for _, td in ipairs(typeItems) do
                local b = typeBtnMap[td.key]
                if b then
                    if td.key==activeKey then
                        b.BackgroundColor3=T.Accent; b.BackgroundTransparency=0.15; b.TextColor3=T.TextMain
                    else
                        b.BackgroundColor3=T.BgBtn;  b.BackgroundTransparency=0.3;  b.TextColor3=T.TextSub
                    end
                end
            end
        end

        for i, td in ipairs(typeItems) do
            local btn = Instance.new("TextButton")
            btn.Size=UDim2.new(1/4,-3,1,0); btn.BackgroundColor3=T.BgBtn; btn.BackgroundTransparency=0.3
            btn.BorderSizePixel=0; btn.Text=td.label; btn.TextColor3=T.TextSub; btn.TextSize=11
            btn.Font=Enum.Font.GothamBold; btn.LayoutOrder=i; btn.ZIndex=5; btn.Parent=typeRow
            mkCorner(btn,5); mkStroke(btn,1,T.Stroke,0.35); typeBtnMap[td.key]=btn
            btn.MouseButton1Click:Connect(function()
                selType=td.key; syncFromType(); refreshTypeBtns(selType)
                if updatePickerUI then updatePickerUI() end
            end)
        end
        refreshTypeBtns(selType)

        local sqSz = 148
        local mainArea = Instance.new("Frame")
        mainArea.BackgroundTransparency=1; mainArea.Size=UDim2.new(1,0,0,sqSz)
        mainArea.LayoutOrder=2; mainArea.ZIndex=4; mainArea.Parent=container

        local svBase = Instance.new("Frame")
        svBase.Size=UDim2.new(0,sqSz,0,sqSz); svBase.BackgroundColor3=Color3.fromHSV(curH,1,1)
        svBase.BorderSizePixel=0; svBase.ZIndex=5; svBase.Parent=mainArea
        mkCorner(svBase,5); mkStroke(svBase,1,T.Stroke,0.3)

        local whiteOv = Instance.new("Frame")
        whiteOv.Size=UDim2.new(1,0,1,0); whiteOv.BackgroundColor3=Color3.new(1,1,1)
        whiteOv.BorderSizePixel=0; whiteOv.ZIndex=6; whiteOv.Parent=svBase; mkCorner(whiteOv,5)
        local wg=Instance.new("UIGradient"); wg.Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(1,1,1))
        wg.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}); wg.Parent=whiteOv

        local blackOv = Instance.new("Frame")
        blackOv.Size=UDim2.new(1,0,1,0); blackOv.BackgroundColor3=Color3.new(0,0,0)
        blackOv.BorderSizePixel=0; blackOv.ZIndex=7; blackOv.Parent=svBase; mkCorner(blackOv,5)
        local bg2=Instance.new("UIGradient"); bg2.Color=ColorSequence.new(Color3.new(0,0,0),Color3.new(0,0,0))
        bg2.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})
        bg2.Rotation=90; bg2.Parent=blackOv

        local svCursor = Instance.new("Frame")
        svCursor.Size=UDim2.new(0,10,0,10); svCursor.AnchorPoint=Vector2.new(0.5,0.5)
        svCursor.Position=UDim2.new(curS,0,1-curV,0); svCursor.BackgroundColor3=Color3.new(1,1,1)
        svCursor.BorderSizePixel=0; svCursor.ZIndex=9; svCursor.Parent=svBase
        mkCorner(svCursor,5); mkStroke(svCursor,2,Color3.new(0.1,0.1,0.1),0)

        local rightPanel = Instance.new("Frame")
        rightPanel.BackgroundTransparency=1; rightPanel.Size=UDim2.new(1,-(sqSz+8),1,0)
        rightPanel.Position=UDim2.new(0,sqSz+8,0,0); rightPanel.ZIndex=4; rightPanel.Parent=mainArea

        local previewSwatch = Instance.new("Frame")
        previewSwatch.Size=UDim2.new(1,0,0,52); previewSwatch.BackgroundColor3=settings.colors[selType]
        previewSwatch.BorderSizePixel=0; previewSwatch.ZIndex=5; previewSwatch.Parent=rightPanel
        mkCorner(previewSwatch,6); mkStroke(previewSwatch,1,T.Stroke,0.3)
        local prevLbl=Instance.new("TextLabel"); prevLbl.BackgroundTransparency=1; prevLbl.Text="PREVIEW"
        prevLbl.Font=Enum.Font.GothamBold; prevLbl.TextSize=9; prevLbl.TextColor3=Color3.new(1,1,1)
        prevLbl.TextTransparency=0.45; prevLbl.Size=UDim2.new(1,0,1,0); prevLbl.ZIndex=6; prevLbl.Parent=previewSwatch

        local hexRow=Instance.new("Frame"); hexRow.Size=UDim2.new(1,0,0,26); hexRow.Position=UDim2.new(0,0,0,58)
        hexRow.BackgroundColor3=T.BgPanel; hexRow.BackgroundTransparency=0.15
        hexRow.BorderSizePixel=0; hexRow.ZIndex=5; hexRow.Parent=rightPanel
        mkCorner(hexRow,5); mkStroke(hexRow,1,T.Stroke,0.3)
        local hashLbl=Instance.new("TextLabel"); hashLbl.Size=UDim2.new(0,18,1,0); hashLbl.BackgroundTransparency=1
        hashLbl.Text="#"; hashLbl.TextColor3=T.TextSub; hashLbl.TextSize=12; hashLbl.Font=Enum.Font.GothamBold
        hashLbl.ZIndex=6; hashLbl.Parent=hexRow
        local hexBox=Instance.new("TextBox"); hexBox.Size=UDim2.new(1,-20,1,0); hexBox.Position=UDim2.new(0,20,0,0)
        hexBox.BackgroundTransparency=1; hexBox.TextColor3=T.TextMain; hexBox.TextSize=11
        hexBox.Font=Enum.Font.Code; hexBox.PlaceholderText="RRGGBB"; hexBox.PlaceholderColor3=T.TextMuted
        hexBox.Text=""; hexBox.ClearTextOnFocus=false; hexBox.ZIndex=6; hexBox.Parent=hexRow
        hexBox:SetAttribute("TextRole","main")

        local rgbReadouts = {}
        for i, nm in ipairs({"R","G","B"}) do
            local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,0,15)
            lbl.Position=UDim2.new(0,0,0,90+(i-1)*18); lbl.BackgroundTransparency=1
            lbl.Text=nm..": 0"; lbl.TextColor3=T.TextSub; lbl.TextSize=11; lbl.Font=Enum.Font.GothamBold
            lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5; lbl.Parent=rightPanel
            rgbReadouts[i]=lbl
        end

        local hueTrack=Instance.new("Frame"); hueTrack.Size=UDim2.new(1,0,0,16)
        hueTrack.BackgroundColor3=Color3.new(1,0,0); hueTrack.BorderSizePixel=0
        hueTrack.LayoutOrder=3; hueTrack.ZIndex=5; hueTrack.Parent=container
        mkCorner(hueTrack,4); mkStroke(hueTrack,1,T.Stroke,0.3)
        local hueGrad=Instance.new("UIGradient")
        hueGrad.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0/6,Color3.fromHSV(0/6,1,1)),
            ColorSequenceKeypoint.new(1/6,Color3.fromHSV(1/6,1,1)),
            ColorSequenceKeypoint.new(2/6,Color3.fromHSV(2/6,1,1)),
            ColorSequenceKeypoint.new(3/6,Color3.fromHSV(3/6,1,1)),
            ColorSequenceKeypoint.new(4/6,Color3.fromHSV(4/6,1,1)),
            ColorSequenceKeypoint.new(5/6,Color3.fromHSV(5/6,1,1)),
            ColorSequenceKeypoint.new(1,  Color3.fromHSV(1,  1,1)),
        }); hueGrad.Parent=hueTrack
        local hueCursor=Instance.new("Frame"); hueCursor.Size=UDim2.new(0,6,1,4)
        hueCursor.AnchorPoint=Vector2.new(0.5,0.5); hueCursor.Position=UDim2.new(curH,0,0.5,0)
        hueCursor.BackgroundColor3=Color3.new(1,1,1); hueCursor.BorderSizePixel=0; hueCursor.ZIndex=6; hueCursor.Parent=hueTrack
        mkCorner(hueCursor,3); mkStroke(hueCursor,1,T.Stroke,0)

        local rgbTracks,rgbCursors,rgbValLbls={},{},{}
        local rgbPureCol={Color3.new(1,0,0),Color3.new(0,1,0),Color3.new(0,0,1)}
        for i, nm in ipairs({"R","G","B"}) do
            local slot=Instance.new("Frame"); slot.BackgroundTransparency=1; slot.Size=UDim2.new(1,0,0,22)
            slot.LayoutOrder=3+i; slot.ZIndex=4; slot.Parent=container
            local nmLbl=Instance.new("TextLabel"); nmLbl.Size=UDim2.new(0,14,1,0); nmLbl.BackgroundTransparency=1
            nmLbl.Text=nm; nmLbl.TextColor3=T.TextSub; nmLbl.TextSize=11; nmLbl.Font=Enum.Font.GothamBold
            nmLbl.ZIndex=5; nmLbl.Parent=slot
            local track=Instance.new("Frame"); track.Size=UDim2.new(1,-52,0,12); track.Position=UDim2.new(0,18,0.5,-6)
            track.BackgroundColor3=Color3.new(0,0,0); track.BorderSizePixel=0; track.ZIndex=5; track.Parent=slot
            mkCorner(track,4); mkStroke(track,1,T.Stroke,0.3)
            local tg=Instance.new("UIGradient"); tg.Color=ColorSequence.new(Color3.new(0,0,0),rgbPureCol[i]); tg.Parent=track
            local cur=Instance.new("Frame"); cur.Size=UDim2.new(0,8,1,4); cur.AnchorPoint=Vector2.new(0.5,0.5)
            cur.Position=UDim2.new(0,0,0.5,0); cur.BackgroundColor3=Color3.new(1,1,1); cur.BorderSizePixel=0
            cur.ZIndex=6; cur.Parent=track; mkCorner(cur,4); mkStroke(cur,1,T.Stroke,0)
            local valLbl=Instance.new("TextLabel"); valLbl.Size=UDim2.new(0,30,1,0); valLbl.Position=UDim2.new(1,-30,0,0)
            valLbl.BackgroundTransparency=1; valLbl.Text="0"; valLbl.TextColor3=T.TextMain; valLbl.TextSize=11
            valLbl.Font=Enum.Font.Gotham; valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.ZIndex=5; valLbl.Parent=slot
            valLbl:SetAttribute("TextRole","main")
            rgbTracks[i]=track; rgbCursors[i]=cur; rgbValLbls[i]=valLbl
        end

        local applyBtn=Instance.new("TextButton"); applyBtn.Size=UDim2.new(1,0,0,30)
        applyBtn.BackgroundColor3=T.Accent; applyBtn.BackgroundTransparency=0.15; applyBtn.BorderSizePixel=0
        applyBtn.Text="✔  Применить и сохранить"; applyBtn.TextColor3=T.TextMain; applyBtn.TextSize=13
        applyBtn.Font=Enum.Font.GothamBold; applyBtn.LayoutOrder=7; applyBtn.ZIndex=5; applyBtn.Parent=container
        applyBtn:SetAttribute("TextRole","main"); mkCorner(applyBtn,6); mkStroke(applyBtn,1,T.Accent,0.35)
        if not isMobile then
            applyBtn.MouseEnter:Connect(function() TweenService:Create(applyBtn,TweenInfo.new(0.15),{BackgroundTransparency=0}):Play() end)
            applyBtn.MouseLeave:Connect(function() TweenService:Create(applyBtn,TweenInfo.new(0.15),{BackgroundTransparency=0.15}):Play() end)
        end

        updatePickerUI = function()
            local col=Color3.fromHSV(curH,curS,curV)
            svBase.BackgroundColor3=Color3.fromHSV(curH,1,1)
            svCursor.Position=UDim2.new(curS,0,1-curV,0)
            hueCursor.Position=UDim2.new(curH,0,0.5,0)
            previewSwatch.BackgroundColor3=col
            curR=math.floor(col.R*255+0.5); curG=math.floor(col.G*255+0.5); curB=math.floor(col.B*255+0.5)
            hexBox.Text=string.format("%02X%02X%02X",curR,curG,curB)
            rgbReadouts[1].Text="R: "..curR; rgbReadouts[2].Text="G: "..curG; rgbReadouts[3].Text="B: "..curB
            local vals={curR/255,curG/255,curB/255}
            for i=1,3 do rgbCursors[i].Position=UDim2.new(vals[i],0,0.5,0); rgbValLbls[i].Text=tostring(math.floor(vals[i]*255+0.5)) end
        end
        updatePickerUI()

        applyBtn.MouseButton1Click:Connect(function()
            settings.colors[selType]=Color3.fromHSV(curH,curS,curV)
            updateGuiColors(); saveColorSettings()
            createNotification("COLOR PICKER","Цвет применён!",2,74283928898866)
            TweenService:Create(applyBtn,TweenInfo.new(0.08),{BackgroundColor3=T.AccentGlow,BackgroundTransparency=0}):Play()
            task.delay(0.18,function() TweenService:Create(applyBtn,TweenInfo.new(0.2),{BackgroundColor3=T.Accent,BackgroundTransparency=0.15}):Play() end)
        end)

        local draggingSV,draggingHue,draggingRGB=false,false,0
        local c1=svBase.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then draggingSV=true end
        end)
        local c2=hueTrack.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then draggingHue=true end
        end)
        for i=1,3 do
            local ci=rgbTracks[i].InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then draggingRGB=i end
            end)
            table.insert(colorPickerConnections,ci)
        end
        table.insert(colorPickerConnections,c1); table.insert(colorPickerConnections,c2)

        local moveConn=UserInputService.InputChanged:Connect(function(inp)
            if inp.UserInputType~=Enum.UserInputType.MouseMovement and inp.UserInputType~=Enum.UserInputType.Touch then return end
            if draggingSV then
                local ap=svBase.AbsolutePosition; local as=svBase.AbsoluteSize
                curS=math.clamp((inp.Position.X-ap.X)/as.X,0,1)
                curV=1-math.clamp((inp.Position.Y-ap.Y)/as.Y,0,1); updatePickerUI()
            elseif draggingHue then
                local ap=hueTrack.AbsolutePosition; local as=hueTrack.AbsoluteSize
                curH=math.clamp((inp.Position.X-ap.X)/as.X,0,1); updatePickerUI()
            elseif draggingRGB>0 then
                local i=draggingRGB; local ap=rgbTracks[i].AbsolutePosition; local as=rgbTracks[i].AbsoluteSize
                local v=math.floor(math.clamp((inp.Position.X-ap.X)/as.X,0,1)*255+0.5)
                if i==1 then curR=v elseif i==2 then curG=v else curB=v end
                curH,curS,curV=Color3.toHSV(Color3.fromRGB(curR,curG,curB)); updatePickerUI()
            end
        end)
        table.insert(colorPickerConnections,moveConn)

        local endConn=UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                draggingSV=false; draggingHue=false; draggingRGB=0
            end
        end)
        table.insert(colorPickerConnections,endConn)

        hexBox.FocusLost:Connect(function(entered)
            if entered then
                local hex=hexBox.Text:gsub("[^%x]",""):upper()
                if #hex==6 then
                    local r=tonumber(hex:sub(1,2),16); local g=tonumber(hex:sub(3,4),16); local b=tonumber(hex:sub(5,6),16)
                    if r and g and b then curR,curG,curB=r,g,b; curH,curS,curV=Color3.toHSV(Color3.fromRGB(r,g,b)); updatePickerUI() end
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
        local function saveAndUpdate() saveSettings(); updateGuiColors(); showSettings() end

        createSectionHeader("Цветовой пикер", scrollingFrame)
        createColorPicker(scrollingFrame)

        createSectionHeader("Прозрачность", scrollingFrame)
        for _, t in ipairs({{"0%",0},{"10%",0.1},{"25%",0.25},{"50%",0.5},{"75%",0.75}}) do
            createButton(t[1], scrollingFrame, function()
                settings.transparency=t[2]; updateGuiColors(); saveColorSettings()
            end)
        end

        createSectionHeader("Сервер", scrollingFrame)
        createButton("Реджоин", scrollingFrame, function()
            local ok2,e=pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
            if not ok2 then createNotification("ERROR","Реджоин: "..tostring(e),5,7733968497) end
        end)
        createButton("Смена сервера", scrollingFrame, function()
            local ok2,e=pcall(function()
                local servers=HttpService:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
                ))
                if #servers.data>0 then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, servers.data[math.random(1,#servers.data)].id, player)
                else createNotification("ERROR","Нет серверов",5,7733968497) end
            end)
            if not ok2 then createNotification("ERROR",tostring(e),5,7733968497) end
        end)
        createButton("Скопировать ID сервера", scrollingFrame, function()
            local ok2,e=pcall(function() setclipboard(game.JobId); createNotification("SUCCESS","Скопировано!",3) end)
            if not ok2 then createNotification("ERROR",tostring(e),5,7733968497) end
        end)

        createSectionHeader("Защита", scrollingFrame)
        createButton("Анти-Бан / Анти-Кик", scrollingFrame, function()
            pcall(function()
                local mt=getrawmetatable(game); local old=mt.__namecall
                setreadonly(mt,false)
                mt.__namecall=newcclosure(function(self,...)
                    local m=getnamecallmethod()
                    if m=="Kick" or m=="kick" then createNotification("ANTI-KICK","Кик заблокирован",3,7733960981); return nil end
                    if m=="Ban"  or m=="ban"  then createNotification("ANTI-BAN", "Бан заблокирован", 3,7733960981); return nil end
                    return old(self,...)
                end)
                setreadonly(mt,true)
                createNotification("ЗАЩИТА","Анти-Бан/Кик включён",3,7733960981)
            end)
        end)

        createSectionHeader("Внешний вид", scrollingFrame)
        createButton("RGB Акцент: "..(settings.rgbAccent and "ВКЛ" or "ВЫКЛ"), scrollingFrame, function()
            settings.rgbAccent=not settings.rgbAccent; saveColorSettings(); updateGuiColors()
        end)
        createButton("RGB Обводка: "..(settings.rgbStroke and "ВКЛ" or "ВЫКЛ"), scrollingFrame, function()
            settings.rgbStroke=not settings.rgbStroke; saveColorSettings(); updateGuiColors()
        end)

        createSectionHeader("Действия", scrollingFrame)
        createButton("Применить и перезапустить", scrollingFrame, function()
            saveSettings()
            pcall(function()
                gui.screenGui:Destroy()
                loadstring(game:HttpGet("https://pastefy.app/QVzDuYQA/raw",true))()
            end)
        end)
        createButton("Закрыть GUI", scrollingFrame, function() gui.screenGui:Destroy() end)
    end

    -- ══════════════════════════════════════
    --  DRAGGING
    -- ══════════════════════════════════════
    local function MakeDraggable(frame, dragPart)
        dragPart = dragPart or frame
        local dragging, dragInput, mousePos, framePos
        dragPart.InputBegan:Connect(function(input)
            if not settings.locked and (
                input.UserInputType==Enum.UserInputType.MouseButton1 or
                input.UserInputType==Enum.UserInputType.Touch
            ) then
                dragging=true; mousePos=input.Position; framePos=frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState==Enum.UserInputState.End then dragging=false end
                end)
            end
        end)
        dragPart.InputChanged:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseMovement or
               input.UserInputType==Enum.UserInputType.Touch then
                dragInput=input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input==dragInput and dragging then
                local delta=input.Position-mousePos
                frame.Position=UDim2.new(framePos.X.Scale, framePos.X.Offset+delta.X,
                                         framePos.Y.Scale, framePos.Y.Offset+delta.Y)
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

            -- Специальные вкладки
            local specialOrder = {"Home","Stats","Settings","All Scripts","🎮 Games"}
            local specialFuncs = {
                Home            = function() recordTabClick("Home");       clearContent(); showHome();       updateGuiColors() end,
                Stats           = function() recordTabClick("Stats");      clearContent(); showStats();      updateGuiColors() end,
                Settings        = function() recordTabClick("Settings");   clearContent(); showSettings();   updateGuiColors() end,
                ["All Scripts"] = function() recordTabClick("All Scripts");clearContent(); showAllScripts(); updateGuiColors() end,
                ["🎮 Games"]    = function() recordTabClick("Games");      showGames();                      updateGuiColors() end,
            }
            for _, name in ipairs(specialOrder) do
                createButton(name, catScroll, specialFuncs[name], true)
            end

            -- Категории из base.lua (отсортированы)
            local sortedCats = {}
            for categoryName in pairs(categoryMap) do table.insert(sortedCats, categoryName) end
            table.sort(sortedCats)
            for _, categoryName in ipairs(sortedCats) do
                createButton(categoryName, catScroll, function()
                    recordTabClick(categoryName)
                    loadHacksFromCategory(categoryName)
                end, true)
            end

            -- Dragging
            MakeDraggable(mainFrame, headerFrame)
            MakeDraggable(reopenButton, reopenButton)

            -- Close / Reopen
            closeBtn.MouseButton1Click:Connect(function()
                finishCurrentSession()
                TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                    Size=UDim2.new(0,580,0,0), BackgroundTransparency=1
                }):Play()
                task.delay(0.25, function()
                    mainFrame.Visible=false
                    mainFrame.Size=UDim2.new(0,580,0,380)
                    mainFrame.BackgroundTransparency=settings.transparency
                    reopenButton.Visible=true
                    startSessionTimer()
                end)
            end)

            reopenButton.MouseButton1Click:Connect(function()
                mainFrame.Visible=true
                mainFrame.Size=UDim2.new(0,580,0,0)
                mainFrame.BackgroundTransparency=1
                reopenButton.Visible=false
                TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size=UDim2.new(0,580,0,380), BackgroundTransparency=settings.transparency
                }):Play()
            end)

            -- Intro анимация
            mainFrame.Size=UDim2.new(0,0,0,0); mainFrame.BackgroundTransparency=1
            TweenService:Create(mainFrame, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size=UDim2.new(0,580,0,380), BackgroundTransparency=settings.transparency
            }):Play()

            -- Показываем Home
            recordTabClick("Home")
            showHome()
            updateGuiColors()

            -- Подсвечиваем первую кнопку
            task.delay(0.1, function()
                local firstBtn = catScroll:FindFirstChildWhichIsA("TextButton")
                if firstBtn then
                    firstBtn:SetAttribute("Active",true)
                    TweenService:Create(firstBtn, TweenInfo.new(0.18), {
                        BackgroundColor3=T.Accent, BackgroundTransparency=0.35, TextColor3=T.TextMain
                    }):Play()
                end
            end)

            -- Автосохранение при выходе
            game:BindToClose(function()
                stopRgbLoop()
                finishCurrentSession()
            end)

            createNotification("MEGAHACK V2","Загружено  ·  "..platformName,3,74283928898866)
        end
    }
end
