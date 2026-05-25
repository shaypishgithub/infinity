-- ══════════════════════════════════════════════════════════════════
--  loader.lua  —  Стеклянный лоадер VERTELEVSEPOEL
--  UPDATED: читает colorSettings.json (цвета игрока из theme.lua)
--           нет чёрного оверлея за контуром
-- ══════════════════════════════════════════════════════════════════

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ─────────────────────────────────────────
--  ЗАГРУЗКА ЦВЕТОВ ИГРОКА (colorSettings.json)
-- ─────────────────────────────────────────
local playerColors = {
    accentColor  = Color3.fromRGB(150, 25, 25),
    bgColor      = Color3.fromRGB(10,  10,  14),
    textColor    = Color3.fromRGB(232, 232, 240),
    strokeColor  = Color3.fromRGB(38,  38,  52),
    transparency = 0.08,
    rgbAccent    = false,
    rgbStroke    = false,
}

pcall(function()
    if isfile and isfile("MegaHack/colorSettings.json") then
        local data = HttpService:JSONDecode(readfile("MegaHack/colorSettings.json"))
        if data.accentColor  then playerColors.accentColor  = Color3.new(table.unpack(data.accentColor))  end
        if data.bgColor      then playerColors.bgColor      = Color3.new(table.unpack(data.bgColor))      end
        if data.textColor    then playerColors.textColor    = Color3.new(table.unpack(data.textColor))    end
        if data.strokeColor  then playerColors.strokeColor  = Color3.new(table.unpack(data.strokeColor))  end
        if data.transparency ~= nil then playerColors.transparency = data.transparency end
        if data.rgbAccent    ~= nil then playerColors.rgbAccent    = data.rgbAccent    end
        if data.rgbStroke    ~= nil then playerColors.rgbStroke    = data.rgbStroke    end
    end
end)

-- ─────────────────────────────────────────
--  ПАЛИТРА (на основе цветов игрока)
-- ─────────────────────────────────────────
local function buildPalette(pc)
    local acc = pc.accentColor
    local bg  = pc.bgColor
    local tx  = pc.textColor
    local str = pc.strokeColor
    return {
        BgBase     = bg,
        BgSide     = Color3.new(math.min(bg.R+0.020,1), math.min(bg.G+0.020,1), math.min(bg.B+0.028,1)),
        BgPanel    = Color3.new(math.min(bg.R+0.043,1), math.min(bg.G+0.043,1), math.min(bg.B+0.060,1)),
        BgBtn      = Color3.new(math.min(bg.R+0.067,1), math.min(bg.G+0.067,1), math.min(bg.B+0.090,1)),
        Accent     = acc,
        AccentHov  = Color3.new(math.min(acc.R*1.22,1), math.min(acc.G*1.22,1), math.min(acc.B*1.22,1)),
        AccentGlow = Color3.new(math.min(acc.R*1.40,1), math.min(acc.G*1.40,1), math.min(acc.B*1.40,1)),
        TextMain   = tx,
        TextSub    = Color3.new(math.min(tx.R*0.64,1), math.min(tx.G*0.64,1), math.min(tx.B*0.64,1)),
        TextMuted  = Color3.new(math.min(tx.R*0.36,1), math.min(tx.G*0.36,1), math.min(tx.B*0.36,1)),
        Stroke     = str,
        White      = Color3.new(1, 1, 1),
    }
end

local T = buildPalette(playerColors)

local CORNER   = 14
local CORNER_S = 8
local LOAD_TIME = 10

-- ─────────────────────────────────────────
--  ХЕЛПЕРЫ
-- ─────────────────────────────────────────
local function mkCorner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or CORNER)
    c.Parent = parent
    return c
end

local function mkStroke(parent, thickness, color, alpha)
    local s = Instance.new("UIStroke")
    s.Thickness       = thickness or 1
    s.Color           = color or T.White
    s.Transparency    = alpha or 0.85
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function mkGradient(parent, keypoints, rotation)
    local g = Instance.new("UIGradient")
    g.Transparency = NumberSequence.new(keypoints)
    g.Rotation     = rotation or 0
    g.Parent       = parent
    return g
end

local function mkLabel(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel        = 0
    for k, v in pairs(props) do l[k] = v end
    l.Parent = parent
    return l
end

-- ─────────────────────────────────────────
--  SCREEN GUI
-- ─────────────────────────────────────────
local screenGui = Instance.new("ScreenGui")
screenGui.Name            = "MegaHack_Loader"
screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset  = true
screenGui.ResetOnSpawn    = false
-- Полная прозрачность экрана — никакого чёрного фона за контуром
screenGui.BackgroundColor3       = Color3.new(0, 0, 0)
screenGui.BackgroundTransparency = 1

local function protectGui(g)
    local ok = pcall(function()
        if get_hidden_gui then
            g.Parent = get_hidden_gui()
        elseif gethui then
            g.Parent = gethui()
        else
            g.Parent = CoreGui
        end
    end)
    if not ok then
        pcall(function() g.Parent = CoreGui end)
        if not g.Parent then g.Parent = playerGui end
    end
end
protectGui(screenGui)

-- ─────────────────────────────────────────
--  ГЛАВНЫЙ СТЕКЛЯННЫЙ ФРЕЙМ
--  (нет оверлея — только фрейм, без чёрного поля)
-- ─────────────────────────────────────────
local mainFrame = Instance.new("Frame")
mainFrame.Name                   = "LoaderFrame"
mainFrame.BackgroundColor3       = T.BgBase
mainFrame.BackgroundTransparency = playerColors.transparency
mainFrame.BorderSizePixel        = 0
mainFrame.AnchorPoint            = Vector2.new(0.5, 0.5)
mainFrame.Position               = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Size                   = UDim2.new(0, 460, 0, 320)
mainFrame.ZIndex                 = 2
mainFrame.Parent                 = screenGui
mkCorner(mainFrame, CORNER)

-- Stroke: если rgbStroke — анимируем после создания всех объектов
local mainStroke = mkStroke(mainFrame, 1, T.White, 0.78)

-- верхний блик (стеклянный шейн)
local glassSheen = Instance.new("Frame")
glassSheen.Name                   = "GlassSheen"
glassSheen.BackgroundColor3       = T.White
glassSheen.BackgroundTransparency = 0.92
glassSheen.BorderSizePixel        = 0
glassSheen.Size                   = UDim2.new(1, 0, 0.50, 0)
glassSheen.Position               = UDim2.new(0, 0, 0, 0)
glassSheen.ZIndex                 = 3
glassSheen.Parent                 = mainFrame
mkCorner(glassSheen, CORNER)
mkGradient(glassSheen, {
    NumberSequenceKeypoint.new(0,   0.10),
    NumberSequenceKeypoint.new(0.5, 0.75),
    NumberSequenceKeypoint.new(1,   1.00),
}, 90)

-- ─────────────────────────────────────────
--  АКЦЕНТ-ПОЛОСКА (верх)
-- ─────────────────────────────────────────
local topAccentBar = Instance.new("Frame")
topAccentBar.Name                   = "TopAccentBar"
topAccentBar.BackgroundColor3       = T.Accent
topAccentBar.BackgroundTransparency = 0
topAccentBar.BorderSizePixel        = 0
topAccentBar.Size                   = UDim2.new(0.55, 0, 0, 2)
topAccentBar.Position               = UDim2.new(0.225, 0, 0, 0)
topAccentBar.ZIndex                 = 10
topAccentBar.Parent                 = mainFrame
mkCorner(topAccentBar, 2)

-- ─────────────────────────────────────────
--  3D ТЕКСТ VERTELEVSEPOEL
-- ─────────────────────────────────────────
local textShadow3 = mkLabel(mainFrame, {
    Text           = "VERTELEVSEPOEL",
    Font           = Enum.Font.GothamBold,
    TextSize       = 32,
    TextColor3     = Color3.new(T.Accent.R*0.4, T.Accent.G*0.4, T.Accent.B*0.4),
    TextXAlignment = Enum.TextXAlignment.Center,
    Size           = UDim2.new(1, 0, 0, 46),
    Position       = UDim2.new(0, 5, 0, 65),
    ZIndex         = 4,
})

local textShadow2 = mkLabel(mainFrame, {
    Text           = "VERTELEVSEPOEL",
    Font           = Enum.Font.GothamBold,
    TextSize       = 32,
    TextColor3     = Color3.new(T.Accent.R*0.67, T.Accent.G*0.67, T.Accent.B*0.67),
    TextXAlignment = Enum.TextXAlignment.Center,
    Size           = UDim2.new(1, 0, 0, 46),
    Position       = UDim2.new(0, 3, 0, 63),
    ZIndex         = 5,
})

local textShadow1 = mkLabel(mainFrame, {
    Text           = "VERTELEVSEPOEL",
    Font           = Enum.Font.GothamBold,
    TextSize       = 32,
    TextColor3     = T.AccentHov,
    TextXAlignment = Enum.TextXAlignment.Center,
    Size           = UDim2.new(1, 0, 0, 46),
    Position       = UDim2.new(0, 1.5, 0, 61.5),
    ZIndex         = 6,
})

local mainText = mkLabel(mainFrame, {
    Text           = "VERTELEVSEPOEL",
    Font           = Enum.Font.GothamBold,
    TextSize       = 32,
    TextColor3     = T.TextMain,
    TextXAlignment = Enum.TextXAlignment.Center,
    Size           = UDim2.new(1, 0, 0, 46),
    Position       = UDim2.new(0, 0, 0, 60),
    ZIndex         = 7,
})

-- ─────────────────────────────────────────
--  РАЗДЕЛИТЕЛЬ
-- ─────────────────────────────────────────
local divLine = Instance.new("Frame")
divLine.Name                   = "Divider"
divLine.BackgroundColor3       = T.Accent
divLine.BackgroundTransparency = 0.55
divLine.BorderSizePixel        = 0
divLine.Size                   = UDim2.new(0.50, 0, 0, 1)
divLine.Position               = UDim2.new(0.25, 0, 0, 118)
divLine.ZIndex                 = 7
divLine.Parent                 = mainFrame
mkCorner(divLine, 1)

-- ─────────────────────────────────────────
--  СТАТУС ТЕКСТ
-- ─────────────────────────────────────────
local statusLabel = mkLabel(mainFrame, {
    Text           = "Инициализация...",
    Font           = Enum.Font.Gotham,
    TextSize       = 13,
    TextColor3     = T.TextSub,
    TextXAlignment = Enum.TextXAlignment.Center,
    Size           = UDim2.new(1, -40, 0, 20),
    Position       = UDim2.new(0, 20, 0, 132),
    ZIndex         = 7,
})

-- ─────────────────────────────────────────
--  ПРОГРЕСС-БАР
-- ─────────────────────────────────────────
local progressTrack = Instance.new("Frame")
progressTrack.Name                   = "ProgressTrack"
progressTrack.BackgroundColor3       = T.BgBtn
progressTrack.BackgroundTransparency = 0
progressTrack.BorderSizePixel        = 0
progressTrack.Size                   = UDim2.new(1, -60, 0, 6)
progressTrack.Position               = UDim2.new(0, 30, 0, 170)
progressTrack.ZIndex                 = 7
progressTrack.Parent                 = mainFrame
mkCorner(progressTrack, 3)
mkStroke(progressTrack, 1, T.White, 0.92)

local progressFill = Instance.new("Frame")
progressFill.Name                   = "ProgressFill"
progressFill.BackgroundColor3       = T.Accent
progressFill.BackgroundTransparency = 0
progressFill.BorderSizePixel        = 0
progressFill.Size                   = UDim2.new(0, 0, 1, 0)
progressFill.Position               = UDim2.new(0, 0, 0, 0)
progressFill.ZIndex                 = 8
progressFill.Parent                 = progressTrack
mkCorner(progressFill, 3)

local progressSheen = Instance.new("Frame")
progressSheen.Name                   = "ProgressSheen"
progressSheen.BackgroundColor3       = T.White
progressSheen.BackgroundTransparency = 0.65
progressSheen.BorderSizePixel        = 0
progressSheen.Size                   = UDim2.new(1, 0, 0.5, 0)
progressSheen.Position               = UDim2.new(0, 0, 0, 0)
progressSheen.ZIndex                 = 9
progressSheen.Parent                 = progressFill
mkCorner(progressSheen, 2)

-- ─────────────────────────────────────────
--  ПРОЦЕНТ
-- ─────────────────────────────────────────
local percentLabel = mkLabel(mainFrame, {
    Text           = "0%",
    Font           = Enum.Font.GothamBold,
    TextSize       = 22,
    TextColor3     = T.Accent,
    TextXAlignment = Enum.TextXAlignment.Center,
    Size           = UDim2.new(1, 0, 0, 30),
    Position       = UDim2.new(0, 0, 0, 190),
    ZIndex         = 7,
})

-- ─────────────────────────────────────────
--  НИЖНЯЯ МЕТА-СТРОКА
-- ─────────────────────────────────────────
local metaLabel = mkLabel(mainFrame, {
    Text           = "MEGAHACK  •  v2.0  •  github / shaypishgithub",
    Font           = Enum.Font.Gotham,
    TextSize       = 11,
    TextColor3     = T.TextMuted,
    TextXAlignment = Enum.TextXAlignment.Center,
    Size           = UDim2.new(1, -40, 0, 16),
    Position       = UDim2.new(0, 20, 1, -28),
    ZIndex         = 7,
})

local bottomBar = Instance.new("Frame")
bottomBar.Name                   = "BottomBar"
bottomBar.BackgroundColor3       = T.Accent
bottomBar.BackgroundTransparency = 0.40
bottomBar.BorderSizePixel        = 0
bottomBar.Size                   = UDim2.new(0.38, 0, 0, 2)
bottomBar.Position               = UDim2.new(0.31, 0, 1, -3)
bottomBar.ZIndex                 = 7
bottomBar.Parent                 = mainFrame
mkCorner(bottomBar, 2)

-- ─────────────────────────────────────────
--  СООБЩЕНИЯ СТАТУСА
-- ─────────────────────────────────────────
local statusMessages = {
    [0]  = "Инициализация...",
    [10] = "Подключение к серверу...",
    [20] = "Загрузка модулей...",
    [35] = "Проверка среды...",
    [50] = "Загрузка скриптов...",
    [65] = "Применение патчей...",
    [80] = "Настройка интерфейса...",
    [90] = "Финальная инициализация...",
    [100]= "Готово!",
}

-- ─────────────────────────────────────────
--  АНИМАЦИЯ ПОЯВЛЕНИЯ
-- ─────────────────────────────────────────
mainFrame.Position               = UDim2.new(0.5, 0, 0.5, 30)
mainFrame.BackgroundTransparency = 1
textShadow3.TextTransparency     = 1
textShadow2.TextTransparency     = 1
textShadow1.TextTransparency     = 1
mainText.TextTransparency        = 1
statusLabel.TextTransparency     = 1
percentLabel.TextTransparency    = 1
metaLabel.TextTransparency       = 1

TweenService:Create(mainFrame, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Position               = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundTransparency = playerColors.transparency,
}):Play()

task.delay(0.2, function()
    TweenService:Create(textShadow3, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    task.delay(0.08, function()
        TweenService:Create(textShadow2, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    end)
    task.delay(0.16, function()
        TweenService:Create(textShadow1, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    end)
    task.delay(0.24, function()
        TweenService:Create(mainText, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    end)
    task.delay(0.4, function()
        TweenService:Create(statusLabel,  TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(percentLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(metaLabel,    TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    end)
end)

-- ─────────────────────────────────────────
--  RGB / ПУЛЬС АКЦЕНТА (учитывает настройки игрока)
-- ─────────────────────────────────────────
local rgbConnections = {}

if playerColors.rgbStroke then
    -- RGB stroke контура
    local conn = RunService.Heartbeat:Connect(function()
        mainStroke.Color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
        divLine.BackgroundColor3  = Color3.fromHSV((tick() % 5) / 5, 1, 1)
        topAccentBar.BackgroundColor3 = Color3.fromHSV((tick() % 5) / 5, 1, 1)
        bottomBar.BackgroundColor3    = Color3.fromHSV((tick() % 5) / 5, 1, 1)
        progressFill.BackgroundColor3 = Color3.fromHSV((tick() % 5) / 5, 1, 1)
    end)
    table.insert(rgbConnections, conn)
elseif playerColors.rgbAccent then
    -- RGB акцент (цвет акцента крутится по спектру)
    local conn = RunService.Heartbeat:Connect(function()
        local ac = Color3.fromHSV((tick() % 5) / 5, 1, 1)
        percentLabel.TextColor3       = ac
        topAccentBar.BackgroundColor3 = ac
        bottomBar.BackgroundColor3    = ac
        progressFill.BackgroundColor3 = ac
        divLine.BackgroundColor3      = ac
    end)
    table.insert(rgbConnections, conn)
else
    -- Мягкий пульс в цвете игрока (без RGB)
    local acc = playerColors.accentColor
    local conn = RunService.Heartbeat:Connect(function()
        local t  = tick()
        local r  = math.min(acc.R + math.sin(t * 0.8) * 0.05, 1)
        local g  = math.min(acc.G + math.sin(t * 0.8) * 0.02, 1)
        local b  = math.min(acc.B + math.sin(t * 0.8) * 0.02, 1)
        local ac = Color3.new(r, g, b)
        percentLabel.TextColor3       = ac
        topAccentBar.BackgroundColor3 = ac
        bottomBar.BackgroundColor3    = ac
        progressFill.BackgroundColor3 = ac
    end)
    table.insert(rgbConnections, conn)
end

-- Пульс текста
local pulseConn = RunService.Heartbeat:Connect(function()
    local t = tick()
    local a = 0.06 + math.abs(math.sin(t * 1.2)) * 0.10
    mainText.TextTransparency = a
end)

-- ─────────────────────────────────────────
--  ПРОГРЕСС: 10 СЕКУНД
-- ─────────────────────────────────────────
local startTime  = tick()
local lastStatus = -1
local progressConn

progressConn = RunService.Heartbeat:Connect(function()
    local elapsed = tick() - startTime
    local pct     = math.min(elapsed / LOAD_TIME, 1)
    local pctInt  = math.floor(pct * 100)

    TweenService:Create(progressFill,
        TweenInfo.new(0.12, Enum.EasingStyle.Linear),
        { Size = UDim2.new(pct, 0, 1, 0) }
    ):Play()

    percentLabel.Text = tostring(pctInt) .. "%"

    local newStatus = lastStatus
    for threshold, msg in pairs(statusMessages) do
        if pctInt >= threshold and threshold > newStatus then
            newStatus = threshold
            statusLabel.Text = msg
        end
    end
    lastStatus = newStatus

    if pct >= 1 then
        progressConn:Disconnect()
        pulseConn:Disconnect()
        for _, c in ipairs(rgbConnections) do pcall(function() c:Disconnect() end) end

        -- Финальный акцент-цвет игрока
        percentLabel.TextColor3       = T.TextMain
        mainText.TextTransparency     = 0
        progressFill.BackgroundColor3 = playerColors.accentColor
        topAccentBar.BackgroundColor3 = playerColors.accentColor
        bottomBar.BackgroundColor3    = playerColors.accentColor

        task.delay(0.4, function()
            TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
                Position               = UDim2.new(0.5, 0, 0.5, -20),
            }):Play()

            for _, obj in ipairs(mainFrame:GetDescendants()) do
                if obj:IsA("TextLabel") then
                    TweenService:Create(obj, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
                elseif obj:IsA("Frame") then
                    TweenService:Create(obj, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
                end
            end

            task.delay(0.7, function()
                screenGui:Destroy()

                -- ════ ЗАГРУЗКА ОСНОВНОГО СКРИПТА ════
                local ok, err = pcall(function()
                    loadstring(game:HttpGet(
                        "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/maybemenu.lua",
                        true
                    ))()
                end)

                if not ok then
                    warn("[MegaHack Loader] Ошибка загрузки: " .. tostring(err))
                end
            end)
        end)
    end
end)
