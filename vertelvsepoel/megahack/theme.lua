-- ══════════════════════════════════════════════════════════════════
--  theme.lua  —  Цветовая система и Color Picker (исправленный)
--  ИСПРАВЛЕНО: mainFrame/scrollingFrame приходят через setFrames()
--              после создания gui, а не через deps сразу
-- ══════════════════════════════════════════════════════════════════
return function(deps)
    local TweenService     = deps.TweenService
    local RunService       = deps.RunService
    local HttpService      = deps.HttpService
    local UserInputService = deps.UserInputService
    local playerGui        = deps.playerGui
    local accentRegistry   = deps.accentRegistry
    local createNotification = deps.createNotification

    -- mainFrame и scrollingFrame придут позже через setFrames()
    local mainFrame, scrollingFrame

    -- ═══════════ ЦВЕТОВАЯ ТЕМА ═══════════
    local T = {
        BgBase    = Color3.fromRGB(11, 11, 15),
        BgSide    = Color3.fromRGB(16, 16, 22),
        BgPanel   = Color3.fromRGB(22, 22, 30),
        BgBtn     = Color3.fromRGB(28, 28, 38),
        BgBtnHov  = Color3.fromRGB(36, 36, 50),
        Accent    = Color3.fromRGB(150, 25, 25),
        AccentHov = Color3.fromRGB(185, 40, 40),
        AccentGlow= Color3.fromRGB(205, 55, 55),
        TextMain  = Color3.fromRGB(230, 230, 238),
        TextSub   = Color3.fromRGB(145, 145, 158),
        TextMuted = Color3.fromRGB(85,  85,  96),
        Stroke    = Color3.fromRGB(40, 40, 54),
        StrokeBrt = Color3.fromRGB(60, 60, 76),
        Separator = Color3.fromRGB(32, 32, 44),
    }

    local rgbConnections = {}

    local function clearRgbConnections()
        for _, c in pairs(rgbConnections) do
            pcall(function() c:Disconnect() end)
        end
        rgbConnections = {}
    end

    -- ═══════════ ОБНОВЛЕНИЕ ЦВЕТОВ ═══════════
    local function updateGuiColors(settings)
        -- Если frame ещё не установлен — выходим тихо
        if not mainFrame then return end

        clearRgbConnections()
        local acc = settings.colors.accentColor
        local bg  = settings.colors.bgColor
        local tx  = settings.colors.textColor

        T.Accent     = acc
        T.AccentHov  = Color3.new(math.min(acc.R*1.22,1), math.min(acc.G*1.22,1), math.min(acc.B*1.22,1))
        T.AccentGlow = Color3.new(math.min(acc.R*1.38,1), math.min(acc.G*1.38,1), math.min(acc.B*1.38,1))
        T.BgBase     = bg
        T.BgSide     = Color3.new(math.min(bg.R+0.020,1), math.min(bg.G+0.020,1), math.min(bg.B+0.028,1))
        T.BgPanel    = Color3.new(math.min(bg.R+0.043,1), math.min(bg.G+0.043,1), math.min(bg.B+0.060,1))
        T.BgBtn      = Color3.new(math.min(bg.R+0.067,1), math.min(bg.G+0.067,1), math.min(bg.B+0.090,1))
        T.BgBtnHov   = Color3.new(math.min(bg.R+0.098,1), math.min(bg.G+0.098,1), math.min(bg.B+0.137,1))
        T.TextMain   = tx

        -- Обновляем все зарегистрированные акценты
        for _, entry in ipairs(accentRegistry) do
            if entry.obj and entry.obj.Parent and entry.obj.Name ~= "CloseButton" then
                pcall(function()
                    entry.obj[entry.prop] = acc
                end)
            end
        end

        -- Основа интерфейса
        mainFrame.BackgroundColor3       = bg
        mainFrame.BackgroundTransparency = settings.transparency or 0.04

        -- Глубокий проход по всем потомкам
        for _, obj in pairs(mainFrame:GetDescendants()) do
            if obj.Name == "CloseButton" then continue end
            local closeBtnChild = mainFrame:FindFirstChild("CloseButton", true)
            if closeBtnChild and obj:IsDescendantOf(closeBtnChild) then continue end

            if obj:IsA("UIStroke") then
                if settings.rgbStroke then
                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then conn:Disconnect() return end
                        obj.Color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
                    end)
                    table.insert(rgbConnections, conn)
                else
                    if obj.Color ~= T.Accent then
                        obj.Color = Color3.new(
                            math.min(bg.R + 0.3, 1),
                            math.min(bg.G + 0.3, 1),
                            math.min(bg.B + 0.3, 1)
                        )
                    end
                end

            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if settings.rgbAccent then
                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then conn:Disconnect() return end
                        obj.TextColor3 = Color3.fromHSV((tick() % 5) / 5, 1, 1)
                    end)
                    table.insert(rgbConnections, conn)
                else
                    local role = obj:GetAttribute("TextRole")
                    if role == "main" then
                        obj.TextColor3 = tx
                    elseif obj.Name == "SectionHeader" or obj.TextColor3 == T.Accent then
                        obj.TextColor3 = acc
                    elseif obj:IsA("TextButton") and obj:GetAttribute("Active") then
                        obj.TextColor3 = acc
                    end
                end

            elseif obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
                if obj.Name == "SidebarFrame" then
                    obj.BackgroundColor3 = T.BgSide
                elseif obj.Name == "MainButton" or obj.BackgroundColor3 == T.BgPanel then
                    obj.BackgroundColor3 = T.BgPanel
                end
            end
        end
    end

    -- ═══════════ СОХРАНЕНИЕ / ЗАГРУЗКА ═══════════
    local function saveColorSettings(settings)
        pcall(function()
            if not isfolder("MegaHack") then makefolder("MegaHack") end
            local col  = settings.colors
            local data = {
                bgColor      = { col.bgColor.R,     col.bgColor.G,     col.bgColor.B     },
                textColor    = { col.textColor.R,   col.textColor.G,   col.textColor.B   },
                strokeColor  = { col.strokeColor.R, col.strokeColor.G, col.strokeColor.B },
                accentColor  = { col.accentColor.R, col.accentColor.G, col.accentColor.B },
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

    -- ═══════════ PUBLIC API ═══════════
    return {
        T                   = T,
        updateGuiColors     = updateGuiColors,
        saveColorSettings   = saveColorSettings,
        loadColorSettings   = loadColorSettings,
        clearRgbConnections = clearRgbConnections,

        -- НОВЫЙ МЕТОД: вызывается из maybemenu.lua после создания gui
        setFrames = function(mf, sf)
            mainFrame      = mf
            scrollingFrame = sf
        end,
    }
end
