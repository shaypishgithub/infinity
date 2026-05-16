-- theme.lua (Module)
return function(deps)
    -- deps – таблица с зависимостями:
    --   TweenService, RunService, HttpService, playerGui,
    --   mainFrame, scrollingFrame, accentRegistry (общий реестр)
    
    local TweenService = deps.TweenService
    local RunService = deps.RunService
    local HttpService = deps.HttpService
    local playerGui = deps.playerGui
    local mainFrame = deps.mainFrame
    local scrollingFrame = deps.scrollingFrame
    local accentRegistry = deps.accentRegistry

    -- ═══════════ ЦВЕТОВАЯ ТЕМА ═══════════
    local T = {
        BgBase    = Color3.fromRGB(13, 13, 17),
        BgSide    = Color3.fromRGB(19, 19, 25),
        BgPanel   = Color3.fromRGB(24, 24, 32),
        BgBtn     = Color3.fromRGB(30, 30, 40),
        BgBtnHov  = Color3.fromRGB(38, 38, 52),
        Accent    = Color3.fromRGB(155, 28, 28),
        AccentHov = Color3.fromRGB(190, 42, 42),
        AccentGlow= Color3.fromRGB(200, 50, 50),
        TextMain  = Color3.fromRGB(228, 228, 235),
        TextSub   = Color3.fromRGB(140, 140, 152),
        TextMuted = Color3.fromRGB(90, 90, 100),
        Stroke    = Color3.fromRGB(44, 44, 56),
        StrokeBrt = Color3.fromRGB(68, 68, 82),
        Separator = Color3.fromRGB(35, 35, 46),
    }

    local rgbConnections = {}
    local colorPickerConnections = {}

    -- Вспомогательная функция для быстрого добавления в accentRegistry
    local function regA(obj, prop)
        table.insert(accentRegistry, { obj = obj, prop = prop or "BackgroundColor3" })
    end

    -- ===================== УВЕДОМЛЕНИЕ (локальное, чтобы не зависеть от главного) =====================
    local function createNotification(title, subtitle, duration, iconId)
        -- ... (можно скопировать функцию из главного скрипта или использовать глобальную,
        --      но лучше передать её через deps, чтобы избежать дублирования)
        -- В этом примере я просто оставлю заглушку – для работы color picker'а она нужна.
        -- Рекомендую передать её из главного скрипта: deps.createNotification
        return deps.createNotification(title, subtitle, duration, iconId)
    end

    -- ===================== ОБНОВЛЕНИЕ ЦВЕТОВ =====================
    local function updateGuiColors(settings)
        clearRgbConnections()
        local acc = settings.colors.accentColor
        local bg  = settings.colors.bgColor
        local tx  = settings.colors.textColor

        T.Accent     = acc
        T.AccentHov  = Color3.new(math.min(acc.R*1.22,1), math.min(acc.G*1.22,1), math.min(acc.B*1.22,1))
        T.AccentGlow = Color3.new(math.min(acc.R*1.35,1), math.min(acc.G*1.35,1), math.min(acc.B*1.35,1))
        T.BgBase     = bg
        T.BgSide     = Color3.new(math.min(bg.R+0.024,1), math.min(bg.G+0.024,1), math.min(bg.B+0.031,1))
        T.BgPanel    = Color3.new(math.min(bg.R+0.043,1), math.min(bg.G+0.043,1), math.min(bg.B+0.059,1))
        T.BgBtn      = Color3.new(math.min(bg.R+0.067,1), math.min(bg.G+0.067,1), math.min(bg.B+0.090,1))
        T.BgBtnHov   = Color3.new(math.min(bg.R+0.098,1), math.min(bg.G+0.098,1), math.min(bg.B+0.137,1))
        T.TextMain   = tx

        for _, entry in ipairs(accentRegistry) do
            if entry.obj and entry.obj.Parent then
                entry.obj[entry.prop] = acc
            end
        end

        mainFrame.BackgroundColor3       = bg
        mainFrame.BackgroundTransparency = settings.transparency
        -- ... обновить остальные статические элементы (header, sidebar и т.д.)
        -- Для этого нужно иметь ссылки на них; можно передать через deps.

        -- Проход по потомкам mainFrame для stroke и текста
        for _, obj in pairs(mainFrame:GetDescendants()) do
            -- ... (код из оригинального updateGuiColors)
        end
    end

    -- ===================== ВИДЖЕТ ВЫБОРА ЦВЕТА =====================
    local function createColorPicker(parent, settings)
        -- ... (полная реализация color picker'а, использующая T, scrollingFrame,
        --      createNotification, TweenService и т.д.)
        -- Возвращает контейнер или ничего, главное – добавляет в parent.
    end

    -- ===================== СОХРАНЕНИЕ / ЗАГРУЗКА =====================
    local function saveColorSettings(settings)
        pcall(function()
            if not isfolder("MegaHack") then makefolder("MegaHack") end
            local col = settings.colors
            local data = {
                bgColor     = { col.bgColor.R, col.bgColor.G, col.bgColor.B },
                textColor   = { col.textColor.R, col.textColor.G, col.textColor.B },
                strokeColor = { col.strokeColor.R, col.strokeColor.G, col.strokeColor.B },
                accentColor = { col.accentColor.R, col.accentColor.G, col.accentColor.B },
                transparency = settings.transparency,
                rgbAccent    = settings.rgbAccent,
                rgbStroke    = settings.rgbStroke,
            }
            writefile("MegaHack/colorSettings.json", HttpService:JSONEncode(data))
        end)
    end

    local function loadColorSettings(settings)
        pcall(function()
            if isfile("MegaHack/colorSettings.json") then
                local data = HttpService:JSONDecode(readfile("MegaHack/colorSettings.json"))
                if data.bgColor then settings.colors.bgColor = Color3.new(data.bgColor[1], data.bgColor[2], data.bgColor[3]) end
                if data.textColor then settings.colors.textColor = Color3.new(data.textColor[1], data.textColor[2], data.textColor[3]) end
                if data.strokeColor then settings.colors.strokeColor = Color3.new(data.strokeColor[1], data.strokeColor[2], data.strokeColor[3]) end
                if data.accentColor then settings.colors.accentColor = Color3.new(data.accentColor[1], data.accentColor[2], data.accentColor[3]) end
                if data.transparency ~= nil then settings.transparency = data.transparency end
                if data.rgbAccent ~= nil then settings.rgbAccent = data.rgbAccent end
                if data.rgbStroke ~= nil then settings.rgbStroke = data.rgbStroke end
            end
        end)
    end

    -- Очистка RGB-соединений
    function clearRgbConnections()
        for _, c in pairs(rgbConnections) do c:Disconnect() end
        rgbConnections = {}
    end

    -- Возвращаем публичный API модуля
    return {
        T = T,
        regA = regA,
        updateGuiColors = updateGuiColors,
        createColorPicker = createColorPicker,
        saveColorSettings = saveColorSettings,
        loadColorSettings = loadColorSettings,
        clearRgbConnections = clearRgbConnections,
        createNotification = createNotification, -- если нужно
    }
end
