-- russloader.ru — Futuristic 3D Neon Loader
-- Path: shaypishgithub/infinity/evoruss/evodetail/russloader.ru

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==================== SAFE SETTINGS LOADER ====================
local playerColors = {
    accentColor = Color3.fromRGB(0, 240, 255), -- Neon Cyan по умолчанию
    bgColor = Color3.fromRGB(8, 8, 12),
    textColor = Color3.fromRGB(220, 225, 240),
}

pcall(function()
    if isfile and isfile("MegaHack/colorSettings.json") then
        local data = HttpService:JSONDecode(readfile("MegaHack/colorSettings.json"))
        if data.accentColor then playerColors.accentColor = Color3.new(table.unpack(data.accentColor)) end
        if data.bgColor then playerColors.bgColor = Color3.new(table.unpack(data.bgColor)) end
        if data.textColor then playerColors.textColor = Color3.new(table.unpack(data.textColor)) end
    end
end)

local acc = playerColors.accentColor
local bg = playerColors.bgColor

-- ==================== HELPERS ====================
local function mkCorner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 16)
    c.Parent = parent
    return c
end

-- Создает эффект НЕОНОВОГО СВЕЧЕНИЯ (Двойной обвод)
local function mkNeonGlow(parent, color, thickness)
    -- Внешний блюр (Свечение)
    local glow = Instance.new("UIStroke")
    glow.Thickness = (thickness or 1.5) + 5
    glow.Color = color
    glow.Transparency = 0.7
    glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    glow.Parent = parent
    -- Ядро (Яркая линия)
    local core = Instance.new("UIStroke")
    core.Thickness = thickness or 1.5
    core.Color = color
    core.Transparency = 0
    core.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    core.Parent = parent
    return glow, core
end

local function mkGrad(parent, kps, rot)
    local g = Instance.new("UIGradient")
    g.Transparency = NumberSequence.new(kps)
    g.Rotation = rot or 0
    g.Parent = parent
    return g
end

local function mkLabel(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel = 0
    for k, v in pairs(props) do l[k] = v end
    l.Parent = parent
    return l
end

-- ==================== SCREEN GUI SETUP ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Evoruss_Loader"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false

local guiParented = false
pcall(function() if syn and syn.protect_gui then syn.protect_gui(screenGui); screenGui.Parent = CoreGui; guiParented = true end end)
if not guiParented then pcall(function() screenGui.Parent = gethui and gethui() or CoreGui; guiParented = true end) end
if not guiParented then screenGui.Parent = playerGui end

-- ==================== 3D UI CONSTRUCTION ====================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "LoaderFrame"
mainFrame.BackgroundColor3 = bg
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 40) -- Начальная позиция (ниже центра)
mainFrame.Size = UDim2.new(0, 500, 0, 340)
mainFrame.ZIndex = 2
mainFrame.Parent = screenGui
mkCorner(mainFrame, 18)
mkNeonGlow(mainFrame, acc, 1.5)

-- 3D Тень окна (Смещенный черный квадрат сзади)
local shadow3D = Instance.new("Frame")
shadow3D.Size = UDim2.new(1, 14, 1, 14)
shadow3D.Position = UDim2.new(0, 7, 0, 7)
shadow3D.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow3D.BackgroundTransparency = 0.5
shadow3D.ZIndex = 1
shadow3D.Parent = mainFrame
mkCorner(shadow3D, 18)

-- Glass Sheen (Эффект стеклянного блика)
local glassSheen = Instance.new("Frame")
glassSheen.BackgroundColor3 = Color3.new(1, 1, 1)
glassSheen.BackgroundTransparency = 0.92
glassSheen.BorderSizePixel = 0
glassSheen.Size = UDim2.new(1, 0, 0.5, 0)
glassSheen.ZIndex = 3
glassSheen.Parent = mainFrame
mkCorner(glassSheen, 18)
mkGrad(glassSheen, {
    NumberSequenceKeypoint.new(0, 0.05),
    NumberSequenceKeypoint.new(0.4, 0.8),
    NumberSequenceKeypoint.new(1, 1.0)
}, 90)

-- Top Neon Line
local topBar = Instance.new("Frame")
topBar.BackgroundColor3 = acc
topBar.BorderSizePixel = 0
topBar.Size = UDim2.new(0.6, 0, 0, 2)
topBar.Position = UDim2.new(0.2, 0, 0, 0)
topBar.ZIndex = 10
topBar.Parent = mainFrame
mkCorner(topBar, 2)

-- ==================== 3D TEXT EFFECT ====================
local txtProps = {
    Font = Enum.Font.GothamBold, TextSize = 36,
    TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1, 0, 0, 50), ZIndex = 5,
}

-- Тень 3 (Самая дальняя и темная)
mkLabel(mainFrame, { Text = "EVORUSS", TextColor3 = Color3.new(acc.R*0.2, acc.G*0.2, acc.B*0.2), Position = UDim2.new(0, 6, 0, 66), unpack(txtProps) })
-- Тень 2
mkLabel(mainFrame, { Text = "EVORUSS", TextColor3 = Color3.new(acc.R*0.5, acc.G*0.5, acc.B*0.5), Position = UDim2.new(0, 4, 0, 64), unpack(txtProps) })
-- Тень 1 (Ближе)
mkLabel(mainFrame, { Text = "EVORUSS", TextColor3 = Color3.new(acc.R*0.8, acc.G*0.8, acc.B*0.8), Position = UDim2.new(0, 2, 0, 62), unpack(txtProps) })
-- Основной текст
local mainText = mkLabel(mainFrame, { Text = "EVORUSS", TextColor3 = playerColors.textColor, Position = UDim2.new(0, 0, 0, 60), unpack(txtProps) })

-- Подзаголовок
local subText = mkLabel(mainFrame, {
    Text = "NEURAL NETWORK INTERFACE", Font = Enum.Font.Gotham, TextSize = 12,
    TextColor3 = Color3.new(acc.R, acc.G, acc.B), TextTransparency = 0.3,
    TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 110), ZIndex = 5,
})

-- Разделитель
local divLine = Instance.new("Frame")
divLine.BackgroundColor3 = acc
divLine.BackgroundTransparency = 0.4
divLine.BorderSizePixel = 0
divLine.Size = UDim2.new(0.4, 0, 0, 1)
divLine.Position = UDim2.new(0.3, 0, 0, 140)
divLine.ZIndex = 5
divLine.Parent = mainFrame
mkCorner(divLine, 1)

-- Статус
local statusLabel = mkLabel(mainFrame, {
    Text = "Initializing...", Font = Enum.Font.Code, TextSize = 13,
    TextColor3 = Color3.fromRGB(160, 165, 180), TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1, -40, 0, 20), Position = UDim2.new(0, 20, 0, 155), ZIndex = 5,
})

-- ==================== PROGRESS BAR ====================
local progressTrack = Instance.new("Frame")
progressTrack.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
progressTrack.BorderSizePixel = 0
progressTrack.Size = UDim2.new(1, -60, 0, 8)
progressTrack.Position = UDim2.new(0, 30, 0, 195)
progressTrack.ZIndex = 5
progressTrack.Parent = mainFrame
mkCorner(progressTrack, 4)
mkNeonGlow(progressTrack, acc, 1)

local progressFill = Instance.new("Frame")
progressFill.BackgroundColor3 = acc
progressFill.BorderSizePixel = 0
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.ZIndex = 6
progressFill.Parent = progressTrack
mkCorner(progressFill, 4)

-- Блик на прогрессе
local progressSheen = Instance.new("Frame")
progressSheen.BackgroundColor3 = Color3.new(1, 1, 1)
progressSheen.BackgroundTransparency = 0.6
progressSheen.BorderSizePixel = 0
progressSheen.Size = UDim2.new(1, 0, 0.45, 0)
progressSheen.ZIndex = 7
progressSheen.Parent = progressFill
mkCorner(progressSheen, 3)

-- Процент
local percentLabel = mkLabel(mainFrame, {
    Text = "0%", Font = Enum.Font.GothamBold, TextSize = 28,
    TextColor3 = acc, TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1, 0, 0, 35), Position = UDim2.new(0, 0, 0, 215), ZIndex = 5,
})

-- Мета информация
local metaLabel = mkLabel(mainFrame, {
    Text = "EVORUSS // v2.0 // github.com/shaypishgithub",
    Font = Enum.Font.Gotham, TextSize = 10,
    TextColor3 = Color3.fromRGB(60, 65, 80), TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1, -40, 0, 16), Position = UDim2.new(0, 20, 1, -28), ZIndex = 5,
})

-- Bottom Neon Line
local bottomBar = Instance.new("Frame")
bottomBar.BackgroundColor3 = acc
bottomBar.BackgroundTransparency = 0.35
bottomBar.BorderSizePixel = 0
bottomBar.Size = UDim2.new(0.4, 0, 0, 2)
bottomBar.Position = UDim2.new(0.3, 0, 1, -3)
bottomBar.ZIndex = 5
bottomBar.Parent = mainFrame
mkCorner(bottomBar, 2)

-- ==================== ANIMATIONS & LOGIC ====================
local LOAD_TIME = 8 -- Секунд на загрузку
local statusMessages = {
    [0] = "Connecting to Evoruss nodes...",
    [15] = "Decrypting neural modules...",
    [35] = "Bypassing environment...",
    [55] = "Loading 3D Glass assets...",
    [75] = "Compiling interface...",
    [90] = "Finalizing system...",
    [100] = "Connection established."
}

-- Fade In
mainFrame.BackgroundTransparency = 1
shadow3D.BackgroundTransparency = 1
for _, l in ipairs(mainFrame:GetChildren()) do
    if l:IsA("TextLabel") then l.TextTransparency = 1 end
    if l:IsA("UIStroke") then l.Transparency = 1 end
end

TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundTransparency = 0.1
}):Play()
TweenService:Create(shadow3D, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5}):Play()

task.delay(0.3, function()
    for _, l in ipairs(mainFrame:GetChildren()) do
        if l:IsA("TextLabel") then TweenService:Create(l, TweenInfo.new(0.4), {TextTransparency = l == subText and 0.3 or 0}):Play() end
        if l:IsA("UIStroke") then TweenService:Create(l, TweenInfo.new(0.4), {Transparency = l.Thickness > 3 and 0.7 or 0}):Play() end
    end
end)

-- Pulse & Progress Loop
local startTime = tick()
local lastStatus = -1
local pulseConn, progressConn

pulseConn = RunService.Heartbeat:Connect(function()
    -- Пульсация текста
    mainText.TextTransparency = math.abs(math.sin(tick() * 1.5)) * 0.15
    -- Пульсация неона
    local pulse = math.sin(tick() * 2) * 0.15
    topBar.BackgroundTransparency = 0.2 + pulse
    bottomBar.BackgroundTransparency = 0.35 + pulse
end)

progressConn = RunService.Heartbeat:Connect(function()
    local pct = math.min((tick() - startTime) / LOAD_TIME, 1)
    local pctInt = math.floor(pct * 100)

    TweenService:Create(progressFill, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
        Size = UDim2.new(pct, 0, 1, 0)
    }):Play()

    percentLabel.Text = tostring(pctInt) .. "%"

    for threshold, msg in pairs(statusMessages) do
        if pctInt >= threshold and threshold > lastStatus then
            lastStatus = threshold
            statusLabel.Text = msg
        end
    end

    if pct >= 1 then
        -- ЗАВЕРШЕНИЕ ЗАГРУЗКИ
        progressConn:Disconnect()
        pulseConn:Disconnect()

        task.delay(0.5, function()
            -- 3D Анимация ухода (Сжатие в центр)
            TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
            TweenService:Create(shadow3D, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()

            for _, obj in ipairs(mainFrame:GetDescendants()) do
                if obj:IsA("TextLabel") then
                    TweenService:Create(obj, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                end
            end

            task.delay(0.6, function()
                screenGui:Destroy()
                -- ЗАПУСК ГЛАВНОГО МЕНЮ
                local ok, err = pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/evoruss/evodetail/maybemenu.lua", true))()
                end)
                if not ok then
                    warn("[Evoruss Loader] Failed to load main menu: " .. tostring(err))
                end
            end)
        end)
    end
end)
