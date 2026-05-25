-- ══════════════════════════════════════════════════════════════════
--  loadermenu.lua  —  Лоадер VERTELEVSEPOEL
--  Совместим с Delta (PC + Mobile)
--  Читает colorSettings.json если есть, иначе дефолт
-- ══════════════════════════════════════════════════════════════════

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local CoreGui      = game:GetService("CoreGui")
local HttpService  = game:GetService("HttpService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ─────────────────────────────────────────
--  ЦВЕТА ИГРОКА (дефолт = красная тема)
-- ─────────────────────────────────────────
local playerColors = {
    accentColor  = Color3.fromRGB(150, 25,  25),
    bgColor      = Color3.fromRGB(10,  10,  14),
    textColor    = Color3.fromRGB(232, 232, 240),
    strokeColor  = Color3.fromRGB(38,  38,  52),
    transparency = 0.08,
    rgbAccent    = false,
    rgbStroke    = false,
}

-- Безопасная загрузка colorSettings.json (Delta совместимо)
pcall(function()
    local hasFile = (type(isfile) == "function") and isfile("MegaHack/colorSettings.json")
    if hasFile then
        local raw  = readfile("MegaHack/colorSettings.json")
        local data = HttpService:JSONDecode(raw)
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
--  ПАЛИТРА
-- ─────────────────────────────────────────
local acc = playerColors.accentColor
local bg  = playerColors.bgColor
local tx  = playerColors.textColor

local T = {
    BgBase    = bg,
    BgBtn     = Color3.new(math.min(bg.R+0.067,1), math.min(bg.G+0.067,1), math.min(bg.B+0.090,1)),
    Accent    = acc,
    AccentHov = Color3.new(math.min(acc.R*1.22,1), math.min(acc.G*1.22,1), math.min(acc.B*1.22,1)),
    TextMain  = tx,
    TextSub   = Color3.new(math.min(tx.R*0.64,1),  math.min(tx.G*0.64,1),  math.min(tx.B*0.64,1)),
    TextMuted = Color3.new(math.min(tx.R*0.36,1),  math.min(tx.G*0.36,1),  math.min(tx.B*0.36,1)),
    White     = Color3.new(1, 1, 1),
}

local CORNER    = 14
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
    s.Transparency    = alpha or 0.82
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function mkGrad(parent, kps, rot)
    local g = Instance.new("UIGradient")
    g.Transparency = NumberSequence.new(kps)
    g.Rotation     = rot or 0
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
--  SCREEN GUI — Delta-safe парент
-- ─────────────────────────────────────────
local screenGui = Instance.new("ScreenGui")
screenGui.Name            = "MegaHack_Loader"
screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset  = true
screenGui.ResetOnSpawn    = false

-- Delta не всегда имеет gethui/get_hidden_gui — пробуем всё
local guiParented = false
if not guiParented then
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(screenGui)
            screenGui.Parent = game.CoreGui
            guiParented = true
        end
    end)
end
if not guiParented then
    pcall(function()
        if gethui then
            screenGui.Parent = gethui()
            guiParented = true
        end
    end)
end
if not guiParented then
    pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
        guiParented = true
    end)
end
if not guiParented then
    screenGui.Parent = playerGui
end

-- ─────────────────────────────────────────
--  ГЛАВНЫЙ ФРЕЙМ (без оверлея — прозрачный фон)
-- ─────────────────────────────────────────
local mainFrame = Instance.new("Frame")
mainFrame.Name                   = "LoaderFrame"
mainFrame.BackgroundColor3       = T.BgBase
mainFrame.BackgroundTransparency = playerColors.transparency
mainFrame.BorderSizePixel        = 0
mainFrame.AnchorPoint            = Vector2.new(0.5, 0.5)
mainFrame.Position               = UDim2.new(0.5, 0, 0.5, 40)
mainFrame.Size                   = UDim2.new(0, 460, 0, 320)
mainFrame.ZIndex                 = 2
mainFrame.Parent                 = screenGui
mkCorner(mainFrame, CORNER)

local mainStroke = mkStroke(mainFrame, 1, T.White, 0.78)

-- Стеклянный блик сверху
local glassSheen = Instance.new("Frame")
glassSheen.BackgroundColor3       = T.White
glassSheen.BackgroundTransparency = 0.91
glassSheen.BorderSizePixel        = 0
glassSheen.Size                   = UDim2.new(1, 0, 0.5, 0)
glassSheen.ZIndex                 = 3
glassSheen.Parent                 = mainFrame
mkCorner(glassSheen, CORNER)
mkGrad(glassSheen, {
    NumberSequenceKeypoint.new(0,   0.10),
    NumberSequenceKeypoint.new(0.5, 0.75),
    NumberSequenceKeypoint.new(1,   1.00),
}, 90)

-- Акцент-полоска верх
local topBar = Instance.new("Frame")
topBar.BackgroundColor3 = T.Accent
topBar.BorderSizePixel  = 0
topBar.Size             = UDim2.new(0.55, 0, 0, 2)
topBar.Position         = UDim2.new(0.225, 0, 0, 0)
topBar.ZIndex           = 10
topBar.Parent           = mainFrame
mkCorner(topBar, 2)

-- ─────────────────────────────────────────
--  3D ТЕКСТ VERTELEVSEPOEL
-- ─────────────────────────────────────────
local sh3 = mkLabel(mainFrame, {
    Text = "VERTELEVSEPOEL", Font = Enum.Font.GothamBold, TextSize = 32,
    TextColor3 = Color3.new(acc.R*0.35, acc.G*0.35, acc.B*0.35),
    TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1,0,0,46), Position = UDim2.new(0,5,0,65), ZIndex = 4,
})
local sh2 = mkLabel(mainFrame, {
    Text = "VERTELEVSEPOEL", Font = Enum.Font.GothamBold, TextSize = 32,
    TextColor3 = Color3.new(acc.R*0.65, acc.G*0.65, acc.B*0.65),
    TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1,0,0,46), Position = UDim2.new(0,3,0,63), ZIndex = 5,
})
local sh1 = mkLabel(mainFrame, {
    Text = "VERTELEVSEPOEL", Font = Enum.Font.GothamBold, TextSize = 32,
    TextColor3 = T.AccentHov,
    TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1,0,0,46), Position = UDim2.new(0,1.5,0,61.5), ZIndex = 6,
})
local mainText = mkLabel(mainFrame, {
    Text = "VERTELEVSEPOEL", Font = Enum.Font.GothamBold, TextSize = 32,
    TextColor3 = T.TextMain,
    TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1,0,0,46), Position = UDim2.new(0,0,0,60), ZIndex = 7,
})

-- Разделитель
local divLine = Instance.new("Frame")
divLine.BackgroundColor3       = T.Accent
divLine.BackgroundTransparency = 0.55
divLine.BorderSizePixel        = 0
divLine.Size                   = UDim2.new(0.5, 0, 0, 1)
divLine.Position               = UDim2.new(0.25, 0, 0, 118)
divLine.ZIndex                 = 7
divLine.Parent                 = mainFrame
mkCorner(divLine, 1)

-- Статус
local statusLabel = mkLabel(mainFrame, {
    Text = "Инициализация...", Font = Enum.Font.Gotham, TextSize = 13,
    TextColor3 = T.TextSub, TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1,-40,0,20), Position = UDim2.new(0,20,0,132), ZIndex = 7,
})

-- Прогресс-бар трек
local progressTrack = Instance.new("Frame")
progressTrack.BackgroundColor3 = T.BgBtn
progressTrack.BorderSizePixel  = 0
progressTrack.Size             = UDim2.new(1,-60,0,6)
progressTrack.Position         = UDim2.new(0,30,0,170)
progressTrack.ZIndex           = 7
progressTrack.Parent           = mainFrame
mkCorner(progressTrack, 3)
mkStroke(progressTrack, 1, T.White, 0.92)

-- Прогресс-бар заливка
local progressFill = Instance.new("Frame")
progressFill.BackgroundColor3 = T.Accent
progressFill.BorderSizePixel  = 0
progressFill.Size             = UDim2.new(0, 0, 1, 0)
progressFill.ZIndex           = 8
progressFill.Parent           = progressTrack
mkCorner(progressFill, 3)

-- Блик на заливке
local progressSheen = Instance.new("Frame")
progressSheen.BackgroundColor3       = T.White
progressSheen.BackgroundTransparency = 0.65
progressSheen.BorderSizePixel        = 0
progressSheen.Size                   = UDim2.new(1,0,0.5,0)
progressSheen.ZIndex                 = 9
progressSheen.Parent                 = progressFill
mkCorner(progressSheen, 2)

-- Процент
local percentLabel = mkLabel(mainFrame, {
    Text = "0%", Font = Enum.Font.GothamBold, TextSize = 22,
    TextColor3 = T.Accent, TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1,0,0,30), Position = UDim2.new(0,0,0,190), ZIndex = 7,
})

-- Мета-строка
local metaLabel = mkLabel(mainFrame, {
    Text = "MEGAHACK  •  v2.0  •  github / shaypishgithub",
    Font = Enum.Font.Gotham, TextSize = 11,
    TextColor3 = T.TextMuted, TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1,-40,0,16), Position = UDim2.new(0,20,1,-28), ZIndex = 7,
})

-- Нижняя акцент-полоска
local bottomBar = Instance.new("Frame")
bottomBar.BackgroundColor3       = T.Accent
bottomBar.BackgroundTransparency = 0.40
bottomBar.BorderSizePixel        = 0
bottomBar.Size                   = UDim2.new(0.38,0,0,2)
bottomBar.Position               = UDim2.new(0.31,0,1,-3)
bottomBar.ZIndex                 = 7
bottomBar.Parent                 = mainFrame
mkCorner(bottomBar, 2)

-- ─────────────────────────────────────────
--  СТАТУС СООБЩЕНИЯ
-- ─────────────────────────────────────────
local statusMessages = {
    [0]   = "Инициализация...",
    [10]  = "Подключение к серверу...",
    [20]  = "Загрузка модулей...",
    [35]  = "Проверка среды...",
    [50]  = "Загрузка скриптов...",
    [65]  = "Применение патчей...",
    [80]  = "Настройка интерфейса...",
    [90]  = "Финальная инициализация...",
    [100] = "Готово!",
}

-- ─────────────────────────────────────────
--  АНИМАЦИЯ ПОЯВЛЕНИЯ
-- ─────────────────────────────────────────
mainFrame.BackgroundTransparency = 1
for _, l in ipairs({sh3, sh2, sh1, mainText, statusLabel, percentLabel, metaLabel}) do
    l.TextTransparency = 1
end

TweenService:Create(mainFrame, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Position               = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundTransparency = playerColors.transparency,
}):Play()

task.delay(0.2, function()
    local delays = {0, 0.08, 0.16, 0.24}
    local labels = {sh3, sh2, sh1, mainText}
    for i, lbl in ipairs(labels) do
        task.delay(delays[i], function()
            TweenService:Create(lbl, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
        end)
    end
    task.delay(0.4, function()
        TweenService:Create(statusLabel,  TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(percentLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(metaLabel,    TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    end)
end)

-- ─────────────────────────────────────────
--  RGB / ПУЛЬС
-- ─────────────────────────────────────────
local rgbConnections = {}

local function setAccentAll(color)
    percentLabel.TextColor3   = color
    topBar.BackgroundColor3   = color
    bottomBar.BackgroundColor3 = color
    progressFill.BackgroundColor3 = color
    divLine.BackgroundColor3  = color
end

if playerColors.rgbStroke then
    table.insert(rgbConnections, RunService.Heartbeat:Connect(function()
        local c = Color3.fromHSV((tick() % 5) / 5, 1, 1)
        mainStroke.Color = c
        setAccentAll(c)
    end))
elseif playerColors.rgbAccent then
    table.insert(rgbConnections, RunService.Heartbeat:Connect(function()
        setAccentAll(Color3.fromHSV((tick() % 5) / 5, 1, 1))
    end))
else
    -- Мягкий пульс в цвете акцента игрока
    table.insert(rgbConnections, RunService.Heartbeat:Connect(function()
        local s = math.sin(tick() * 0.8)
        setAccentAll(Color3.new(
            math.min(acc.R + s * 0.05, 1),
            math.min(acc.G + s * 0.02, 1),
            math.min(acc.B + s * 0.02, 1)
        ))
    end))
end

-- Пульс основного текста
local pulseConn = RunService.Heartbeat:Connect(function()
    mainText.TextTransparency = 0.06 + math.abs(math.sin(tick() * 1.2)) * 0.10
end)

-- ─────────────────────────────────────────
--  ПРОГРЕСС ЛОГИКА
-- ─────────────────────────────────────────
local startTime  = tick()
local lastStatus = -1
local progressConn

progressConn = RunService.Heartbeat:Connect(function()
    local pct    = math.min((tick() - startTime) / LOAD_TIME, 1)
    local pctInt = math.floor(pct * 100)

    TweenService:Create(progressFill,
        TweenInfo.new(0.12, Enum.EasingStyle.Linear),
        { Size = UDim2.new(pct, 0, 1, 0) }
    ):Play()

    percentLabel.Text = tostring(pctInt) .. "%"

    for threshold, msg in pairs(statusMessages) do
        if pctInt >= threshold and threshold > lastStatus then
            lastStatus = threshold
            statusLabel.Text = msg
        end
    end

    if pct >= 1 then
        progressConn:Disconnect()
        pulseConn:Disconnect()
        for _, c in ipairs(rgbConnections) do pcall(function() c:Disconnect() end) end

        percentLabel.TextColor3 = T.TextMain
        mainText.TextTransparency = 0
        setAccentAll(playerColors.accentColor)

        task.delay(0.4, function()
            TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0.5, -20),
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

                local ok, err = pcall(function()
                    loadstring(game:HttpGet(
                        "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/maybemenu.lua",
                        true
                    ))()
                end)
                if not ok then
                    warn("[MegaHack Loader] Ошибка: " .. tostring(err))
                end
            end)
        end)
    end
end)
