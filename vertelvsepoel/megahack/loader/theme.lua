-- theme.lua · Glass Minimalism — Полная синхронизация всех элементов
return function(deps)
    local TweenService      = deps.TweenService
    local RunService        = deps.RunService
    local HttpService       = deps.HttpService
    local playerGui          = deps.playerGui
    local mainFrame         = deps.mainFrame
    local scrollingFrame    = deps.scrollingFrame
    local accentRegistry    = deps.accentRegistry
    local createNotification = deps.createNotification
    local UserInputService  = game:GetService("UserInputService")

    -- ═══════════ ЦВЕТОВАЯ ТЕМА (Дефолт) ═══════════
    local T = {
        BgBase    = Color3.fromRGB(11, 11, 15),
        BgSide    = Color3.fromRGB(16, 16, 22),
        BgPanel   = Color3.fromRGB(22, 22, 30),
        BgBtn     = Color3.fromRGB(28, 28, 38),
        Accent    = Color3.fromRGB(150, 25, 25),
        TextMain  = Color3.fromRGB(230, 230, 238),
        TextSub   = Color3.fromRGB(145, 145, 158),
    }

    local rgbConnections = {}

    local function regA(obj, prop)
        table.insert(accentRegistry, { obj = obj, prop = prop or "BackgroundColor3" })
    end

    local function clearRgbConnections()
        for _, c in pairs(rgbConnections) do
            pcall(function() c:Disconnect() end)
        end
        rgbConnections = {}
    end

    -- ═══════════ ГЛАВНАЯ ФУНКЦИЯ ОБНОВЛЕНИЯ (ИСПРАВЛЕНО) ═══════════
    local function updateGuiColors(settings)
        clearRgbConnections()
        local acc = settings.colors.accentColor
        local bg  = settings.colors.bgColor
        local tx  = settings.colors.textColor

        -- Математический пересчет вспомогательных цветов
        T.Accent  = acc
        T.BgBase  = bg
        T.BgSide  = Color3.new(math.min(bg.R+0.02,1), math.min(bg.G+0.02,1), math.min(bg.B+0.03,1))
        T.BgPanel = Color3.new(math.min(bg.R+0.04,1), math.min(bg.G+0.04,1), math.min(bg.B+0.06,1))
        T.BgBtn   = Color3.new(math.min(bg.R+0.07,1), math.min(bg.G+0.07,1), math.min(bg.B+0.09,1))
        T.TextMain = tx

        -- 1. Принудительное обновление зарегистрированных акцентов (кнопки, ползунки)
        for _, entry in ipairs(accentRegistry) do
            pcall(function()
                if entry.obj and entry.obj.Parent then
                    entry.obj[entry.prop] = acc
                end
            end)
        end

        -- 2. Обновление главного фрейма
        mainFrame.BackgroundColor3 = bg
        mainFrame.BackgroundTransparency = settings.transparency

        -- 3. Глобальный проход по всем потомкам
        for _, obj in pairs(mainFrame:GetDescendants()) do
            -- Игнорируем только системные кнопки (например, крестик закрытия, если нужно)
            if obj.Name == "CloseButton" then continue end
            
            -- ОБРАБОТКА ОБВОДОК (UIStroke)
            if obj:IsA("UIStroke") then
                if settings.rgbStroke then
                    local c; c = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(game) then c:Disconnect() return end
                        obj.Color = Color3.fromHSV((tick() % 5) / 5, 0.8, 1)
                    end)
                    table.insert(rgbConnections, c)
                else
                    -- Если обводка "яркая" или была акцентной — красим в акцент
                    if obj.Thickness > 1 or obj.Color:ToHex() ~= "000000" then
                         obj.Color = acc
                    else
                         obj.Color = Color3.new(bg.R+0.2, bg.G+0.2, bg.B+0.2)
                    end
                end

            -- ОБРАБОТКА ТЕКСТА
            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if settings.rgbAccent then
                    local c; c = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(game) then c:Disconnect() return end
                        obj.TextColor3 = Color3.fromHSV((tick() % 5) / 5, 0.8, 1)
                    end)
                    table.insert(rgbConnections, c)
                else
                    -- ЛОГИКА: Если текст был красным (или акцентным) — меняем на новый акцент
                    -- Если текст белый/серый — меняем на основной текст темы
                    local h, s, v = obj.TextColor3:ToHSV()
                    if s > 0.5 then -- Похоже на цветной акцент
                        obj.TextColor3 = acc
                    else
                        obj.TextColor3 = tx
                    end
                end

            -- ОБРАБОТКА ФОНОВ (Кнопки "All Scripts", "V1" и т.д.)
            elseif obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
                if obj.Name == "SidebarFrame" or obj.Name == "SideBar" then
                    obj.BackgroundColor3 = T.BgSide
                elseif obj.Name == "MainButton" or obj:GetAttribute("IsCard") then
                    obj.BackgroundColor3 = T.BgPanel
                end
                
                -- Если фон фрейма совпадает со старым цветом кнопок — обновляем
                if obj.BackgroundTransparency < 1 and obj.BackgroundColor3 ~= bg then
                    obj.BackgroundColor3 = T.BgBtn
                end
            end
        end
        
        -- Отдельно обновляем OpenButton (если она вне mainFrame)
        local screenGui = mainFrame.Parent
        local openBtn = screenGui:FindFirstChild("OpenButton", true)
        if openBtn then
            if openBtn:IsA("GuiObject") then openBtn.BackgroundColor3 = acc end
            local stroke = openBtn:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = acc end
        end
    end

    -- [Остальные функции: saveColorSettings, loadColorSettings, createColorPicker остаются без изменений]
    -- ... (вставь свой код сохранения и пикера сюда) ...

    -- ═══════════ СОХРАНЕНИЕ / ЗАГРУЗКА ═══════════
    local function saveColorSettings(settings)
        pcall(function()
            if not isfolder("MegaHack") then makefolder("MegaHack") end
            local col  = settings.colors
            local data = {
                bgColor      = { col.bgColor.R,     col.bgColor.G,     col.bgColor.B     },
                textColor    = { col.textColor.R,   col.textColor.G,   col.textColor.B   },
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
                if data.accentColor then settings.colors.accentColor = Color3.new(table.unpack(data.accentColor)) end
                if data.transparency ~= nil then settings.transparency = data.transparency end
                if data.rgbAccent    ~= nil then settings.rgbAccent    = data.rgbAccent     end
                if data.rgbStroke    ~= nil then settings.rgbStroke    = data.rgbStroke     end
            end
        end)
    end

    -- [Вставь сюда свою функцию createColorPicker из оригинального кода]

    return {
        T                   = T,
        regA                = regA,
        updateGuiColors     = updateGuiColors,
        createColorPicker   = createColorPicker,
        saveColorSettings   = saveColorSettings,
        loadColorSettings   = loadColorSettings,
        clearRgbConnections = clearRgbConnections,
    }
end
