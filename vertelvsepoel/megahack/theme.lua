-- ══════════════════════════════════════════════════════════════════
--  theme.lua  —  Color system, RGB effects, save/load
--  FIXED: полностью совместим с logic.lua / gui.lua
-- ══════════════════════════════════════════════════════════════════
return function(deps)
    local TweenService       = deps.TweenService
    local RunService         = deps.RunService
    local HttpService        = deps.HttpService
    local UserInputService   = deps.UserInputService
    local playerGui          = deps.playerGui
    local accentRegistry     = deps.accentRegistry  -- таблица {obj, prop}
    local createNotification = deps.createNotification or function() end

    local mainFrame, scrollingFrame

    -- ═══════════ DEFAULT COLOR PALETTE ═══════════
    local T = {
        BgBase     = Color3.fromRGB(10,  10,  14),
        BgSide     = Color3.fromRGB(15,  15,  21),
        BgPanel    = Color3.fromRGB(21,  21,  29),
        BgBtn      = Color3.fromRGB(27,  27,  37),
        BgBtnHov   = Color3.fromRGB(35,  35,  49),
        Accent     = Color3.fromRGB(150, 25,  25),
        AccentHov  = Color3.fromRGB(185, 40,  40),
        AccentGlow = Color3.fromRGB(210, 60,  60),
        TextMain   = Color3.fromRGB(232, 232, 240),
        TextSub    = Color3.fromRGB(148, 148, 160),
        TextMuted  = Color3.fromRGB(82,  82,  96),
        Stroke     = Color3.fromRGB(38,  38,  52),
        StrokeBrt  = Color3.fromRGB(58,  58,  74),
        Separator  = Color3.fromRGB(30,  30,  42),
    }

    local rgbConnections = {}

    local function clearRgbConnections()
        for _, c in pairs(rgbConnections) do
            pcall(function() c:Disconnect() end)
        end
        rgbConnections = {}
    end

    -- ═══════════ APPLY COLORS TO GUI ═══════════
    local function updateGuiColors(settings)
        if not mainFrame then return end
        clearRgbConnections()

        local acc = settings.colors.accentColor
        local bg  = settings.colors.bgColor
        local tx  = settings.colors.textColor
        local str = settings.colors.strokeColor

        T.Accent     = acc
        T.AccentHov  = Color3.new(math.min(acc.R*1.22,1), math.min(acc.G*1.22,1), math.min(acc.B*1.22,1))
        T.AccentGlow = Color3.new(math.min(acc.R*1.40,1), math.min(acc.G*1.40,1), math.min(acc.B*1.40,1))
        T.BgBase     = bg
        T.BgSide     = Color3.new(math.min(bg.R+0.020,1), math.min(bg.G+0.020,1), math.min(bg.B+0.028,1))
        T.BgPanel    = Color3.new(math.min(bg.R+0.043,1), math.min(bg.G+0.043,1), math.min(bg.B+0.060,1))
        T.BgBtn      = Color3.new(math.min(bg.R+0.067,1), math.min(bg.G+0.067,1), math.min(bg.B+0.090,1))
        T.BgBtnHov   = Color3.new(math.min(bg.R+0.098,1), math.min(bg.G+0.098,1), math.min(bg.B+0.137,1))
        T.TextMain   = tx
        T.Stroke     = str

        -- Accent registry flush
        if accentRegistry then
            for _, entry in ipairs(accentRegistry) do
                if entry.obj and entry.obj.Parent then
                    local prop = entry.prop or "BackgroundColor3"
                    pcall(function() entry.obj[prop] = acc end)
                end
            end
        end

        mainFrame.BackgroundColor3       = bg
        mainFrame.BackgroundTransparency = settings.transparency or 0.04

        for _, obj in pairs(mainFrame:GetDescendants()) do
            -- Пропускаем CloseButton и его детей
            if obj.Name == "CloseBtn" then continue end
            local cb = mainFrame:FindFirstChild("CloseBtn", true)
            if cb and obj:IsDescendantOf(cb) then continue end

            if obj:IsA("UIStroke") then
                if settings.rgbStroke then
                    local conn; conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then conn:Disconnect(); return end
                        obj.Color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
                    end)
                    table.insert(rgbConnections, conn)
                else
                    obj.Color = str
                end

            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if settings.rgbAccent then
                    local conn; conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then conn:Disconnect(); return end
                        obj.TextColor3 = Color3.fromHSV((tick() % 5) / 5, 1, 1)
                    end)
                    table.insert(rgbConnections, conn)
                else
                    local role = obj:GetAttribute("TextRole")
                    if role == "main" then
                        obj.TextColor3 = tx
                    end
                end

            elseif obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
                if obj.Name == "SidebarFrame" then
                    obj.BackgroundColor3 = T.BgSide
                elseif obj.Name == "GameCardBg" then
                    obj.BackgroundColor3 = T.BgPanel
                end
            end
        end
    end

    -- ═══════════ PERSIST ═══════════
    local function saveColorSettings(settings)
        pcall(function()
            if not isfolder("MegaHack") then makefolder("MegaHack") end
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

    local function loadColorSettings(settings)
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

    -- ═══════════ PUBLIC API ═══════════
    return {
        T                   = T,
        updateGuiColors     = updateGuiColors,
        saveColorSettings   = saveColorSettings,
        loadColorSettings   = loadColorSettings,
        clearRgbConnections = clearRgbConnections,

        -- ОБЯЗАТЕЛЬНО вызвать до updateGuiColors!
        setFrames = function(mf, sf)
            mainFrame      = mf
            scrollingFrame = sf
        end,
    }
end
