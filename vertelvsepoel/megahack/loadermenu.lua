-- ══════════════════════════════════════════════════════════════════
--  loadermenu.lua  —  RussElite Modern Glass Loader
--  Черное стекло, красная волна "RussElite", блестящий прогресс-бар
-- ══════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Загружаем пользовательские цвета если они есть
local playerColors = {
    accentColor = Color3.fromRGB(150, 25, 25),
    bgColor = Color3.fromRGB(12, 12, 16),
    textColor = Color3.fromRGB(240, 240, 245),
}

pcall(function()
    if isfile("RussElite/colorSettings.json") then
        local data = HttpService:JSONDecode(readfile("RussElite/colorSettings.json"))
        if data.accentColor then playerColors.accentColor = Color3.new(table.unpack(data.accentColor)) end
        if data.bgColor then playerColors.bgColor = Color3.new(table.unpack(data.bgColor)) end
    end
end)

-- ════════════════════════════════════════════════════
--  УТИЛИТЫ СТЕКЛА
-- ════════════════════════════════════════════════════
local function mkCorner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 16)
    c.Parent = parent
    return c
end

local function mkStroke(parent, thickness, color, alpha)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 1
    s.Color = color or Color3.new(1, 1, 1)
    s.Transparency = alpha or 0.75
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function mkGlass(parent)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0.9, 0.9, 0.95))
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.80),
        NumberSequenceKeypoint.new(0.5, 0.90),
        NumberSequenceKeypoint.new(1, 0.96)
    })
    g.Rotation = 90
    g.Parent = parent
    return g
end

-- ════════════════════════════════════════════════════
--  СОЗДАНИЕ GUI
-- ════════════════════════════════════════════════════
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RussElite_Loader"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false

-- Защита
pcall(function()
    if get_hidden_gui then screenGui.Parent = get_hidden_gui()
    elseif gethui then screenGui.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(screenGui); screenGui.Parent = CoreGui
    else screenGui.Parent = CoreGui end
end)
if not screenGui.Parent then screenGui.Parent = CoreGui end

-- Главный фрейм (Черное стекло)
local mainFrame = Instance.new("Frame")
mainFrame.BackgroundColor3 = playerColors.bgColor
mainFrame.BackgroundTransparency = 0.03
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 30)
mainFrame.Size = UDim2.new(0, 420, 0, 280)
mainFrame.ZIndex = 2
mainFrame.Parent = screenGui
mkCorner(mainFrame, 18)
mkStroke(mainFrame, 1, Color3.new(1, 1, 1), 0.70)
mkGlass(mainFrame)

-- Верхняя акцентная полоска
local topBar = Instance.new("Frame")
topBar.BackgroundColor3 = playerColors.accentColor
topBar.BackgroundTransparency = 0.2
topBar.Size = UDim2.new(0.5, 0, 0, 2)
topBar.Position = UDim2.new(0.25, 0, 0, 0)
topBar.ZIndex = 10
topBar.Parent = mainFrame
mkCorner(topBar, 2)

-- ════════════════════════════════════════════════════
--  АНИМАЦИЯ ВОЛНЫ "RUSSELITE"
-- ════════════════════════════════════════════════════
local textContent = "RussElite"
local waveContainer = Instance.new("Frame")
waveContainer.BackgroundTransparency = 1
waveContainer.Size = UDim2.new(1, 0, 0, 50)
waveContainer.Position = UDim2.new(0, 0, 0, 60)
waveContainer.ZIndex = 5
waveContainer.Parent = mainFrame

-- UIListLayout для идеального расчета позиций букв без лагов
local textLayout = Instance.new("UIListLayout")
textLayout.FillDirection = Enum.FillDirection.Horizontal
textLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
textLayout.VerticalAlignment = Enum.VerticalAlignment.Center
textLayout.Padding = UDim.new(0, 0)
textLayout.Parent = waveContainer

local charObjects = {}

-- Тени (Создают эффект 3D)
local shadowContainer = waveContainer:Clone()
shadowContainer.ZIndex = 4
shadowContainer.Name = "Shadows"
shadowContainer.Parent = mainFrame
local shadowLayout = shadowContainer:FindFirstChildWhichIsA("UIListLayout")
if shadowLayout then
    shadowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    shadowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
end

for i = 1, #textContent do
    local char = string.sub(textContent, i, i)
    
    -- Тень
    local shadow = Instance.new("TextLabel")
    shadow.BackgroundTransparency = 1
    shadow.Text = char
    shadow.Font = Enum.Font.GothamBold
    shadow.TextSize = 36
    shadow.TextColor3 = Color3.new(0.1, 0, 0) -- Темно-красная тень
    shadow.TextTransparency = 0.5
    shadow.Size = UDim2.new(0, 30, 0, 40)
    shadow.Parent = shadowContainer
    
    -- Основная буква
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Text = char
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 36
    lbl.TextColor3 = Color3.fromRGB(255, 60, 60) -- Ярко красный
    lbl.Size = UDim2.new(0, 30, 0, 40)
    lbl.Parent = waveContainer
    
    table.insert(charObjects, { label = lbl, shadow = shadow, index = i })
end

-- Разделитель
local divLine = Instance.new("Frame")
divLine.BackgroundColor3 = playerColors.accentColor
divLine.BackgroundTransparency = 0.6
divLine.Size = UDim2.new(0.4, 0, 0, 1)
divLine.Position = UDim2.new(0.3, 0, 0, 125)
divLine.ZIndex = 5
divLine.Parent = mainFrame
mkCorner(divLine, 1)

-- ════════════════════════════════════════════════════
--  СТАТУС И ПРОГРЕСС БАР
-- ════════════════════════════════════════════════════
local statusLabel = Instance.new("TextLabel")
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Initializing..."
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
statusLabel.Size = UDim2.new(1, -40, 0, 20)
statusLabel.Position = UDim2.new(0, 20, 0, 140)
statusLabel.ZIndex = 5
statusLabel.Parent = mainFrame

-- Трек прогресса (Черный стеклянный)
local trackFrame = Instance.new("Frame")
trackFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
trackFrame.BackgroundTransparency = 0.1
trackFrame.Size = UDim2.new(1, -50, 0, 6)
trackFrame.Position = UDim2.new(0, 25, 0, 175)
trackFrame.ZIndex = 5
trackFrame.Parent = mainFrame
mkCorner(trackFrame, 3)
mkStroke(trackFrame, 1, Color3.new(1, 1, 1), 0.88)

-- Заполнение прогресса
local fillFrame = Instance.new("Frame")
fillFrame.BackgroundColor3 = playerColors.accentColor
fillFrame.BackgroundTransparency = 0.15
fillFrame.Size = UDim2.new(0, 0, 1, 0)
fillFrame.ZIndex = 6
fillFrame.Parent = trackFrame
mkCorner(fillFrame, 3)

-- Блеск на полоске загрузки (Анимированный градиент)
local shineGrad = Instance.new("UIGradient")
shineGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
    ColorSequenceKeypoint.new(0.4, playerColors.accentColor),
    ColorSequenceKeypoint.new(1, playerColors.accentColor)
})
shineGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.6),
    NumberSequenceKeypoint.new(0.4, 0),
    NumberSequenceKeypoint.new(1, 0)
})
shineGrad.Rotation = 0
shineGrad.Parent = fillFrame

-- Процент
local percentLabel = Instance.new("TextLabel")
percentLabel.BackgroundTransparency = 1
percentLabel.Text = "0%"
percentLabel.Font = Enum.Font.GothamBold
percentLabel.TextSize = 20
percentLabel.TextColor3 = playerColors.accentColor
percentLabel.Size = UDim2.new(1, 0, 0, 24)
percentLabel.Position = UDim2.new(0, 0, 0, 195)
percentLabel.ZIndex = 5
percentLabel.Parent = mainFrame

-- Подвал
local metaLabel = Instance.new("TextLabel")
metaLabel.BackgroundTransparency = 1
metaLabel.Text = "RUSSELITE • v3.0 • github / russelite"
metaLabel.Font = Enum.Font.Gotham
metaLabel.TextSize = 10
metaLabel.TextColor3 = Color3.fromRGB(80, 80, 100)
metaLabel.Size = UDim2.new(1, -40, 0, 16)
metaLabel.Position = UDim2.new(0, 20, 1, -26)
metaLabel.ZIndex = 5
metaLabel.Parent = mainFrame

-- Нижняя полоска
local bottomBar = Instance.new("Frame")
bottomBar.BackgroundColor3 = playerColors.accentColor
bottomBar.BackgroundTransparency = 0.3
bottomBar.Size = UDim2.new(0.35, 0, 0, 2)
bottomBar.Position = UDim2.new(0.325, 0, 1, -3)
bottomBar.ZIndex = 5
bottomBar.Parent = mainFrame
mkCorner(bottomBar, 2)

-- ════════════════════════════════════════════════════
--  АНИМАЦИИ И ЛОГИКА ЗАГРУЗКИ
-- ════════════════════════════════════════════════════

-- Плавное появление
mainFrame.BackgroundTransparency = 1
statusLabel.TextTransparency = 1
percentLabel.TextTransparency = 1
metaLabel.TextTransparency = 1
shadowContainer.BackgroundTransparency = 1
for _, obj in ipairs(shadowContainer:GetChildren()) do if obj:IsA("TextLabel") then obj.TextTransparency = 1 end end
waveContainer.BackgroundTransparency = 1
for _, obj in ipairs(waveContainer:GetChildren()) do if obj:IsA("TextLabel") then obj.TextTransparency = 1 end end

TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundTransparency = 0.03
}):Play()

task.delay(0.2, function()
    TweenService:Create(shadowContainer, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
    for _, obj in ipairs(shadowContainer:GetChildren()) do 
        if obj:IsA("TextLabel") then TweenService:Create(obj, TweenInfo.new(0.4), {TextTransparency = 0.5}):Play() end 
    end
    TweenService:Create(waveContainer, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
    for _, obj in ipairs(waveContainer:GetChildren()) do 
        if obj:IsA("TextLabel") then TweenService:Create(obj, TweenInfo.new(0.4), {TextTransparency = 0}):Play() end 
    end
    task.delay(0.2, function()
        TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(percentLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(metaLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    end)
end)

-- Анимация волны и блеска
local waveSpeed = 3.5
local waveHeight = 6

local animConn = RunService.Heartbeat:Connect(function()
    local t = tick()
    
    -- Движение букв (Волна)
    for _, data in ipairs(charObjects) do
        local yOffset = math.sin(t * waveSpeed + (data.index - 1) * 0.6) * waveHeight
        data.label.Position = UDim2.new(0, 0, 0.5, yOffset - 20)
        data.shadow.Position = UDim2.new(0, 2, 0.5, yOffset - 18) -- Тень чуть со смещением
    end
    
    -- Движение блеска по полоске загрузки
    shineGrad.Offset = Vector2.new((t * 0.8) % 1.5 - 0.5, 0)
end)

-- Логика прогресса
local LOAD_TIME = 8
local startTime = tick()
local lastStatus = -1
local statusMessages = {
    [0] = "Initializing...",
    [10] = "Connecting to server...",
    [25] = "Loading modules...",
    [40] = "Checking environment...",
    [55] = "Loading scripts...",
    [70] = "Applying glass patches...",
    [85] = "Setting up interface...",
    [95] = "Finalizing...",
    [100] = "Complete!"
}

local progressConn
progressConn = RunService.Heartbeat:Connect(function()
    local pct = math.min((tick() - startTime) / LOAD_TIME, 1)
    local pctInt = math.floor(pct * 100)

    -- Обновляем полоску
    TweenService:Create(fillFrame, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
        Size = UDim2.new(pct, 0, 1, 0)
    }):Play()

    percentLabel.Text = tostring(pctInt) .. "%"

    -- Обновляем статус
    for threshold, msg in pairs(statusMessages) do
        if pctInt >= threshold and threshold > lastStatus then
            lastStatus = threshold
            statusLabel.Text = msg
        end
    end

    -- Завершение
    if pct >= 1 then
        progressConn:Disconnect()
        animConn:Disconnect()

        task.delay(0.4, function()
            -- Анимация исчезновения
            TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0.5, -20)
            }):Play()

            local function fadeOut(obj)
                if obj:IsA("TextLabel") or obj:IsA("ImageLabel") then
                    TweenService:Create(obj, TweenInfo.new(0.3), {TextTransparency = 1, ImageTransparency = 1}):Play()
                elseif obj:IsA("Frame") then
                    TweenService:Create(obj, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                end
            end

            for _, obj in ipairs(mainFrame:GetDescendants()) do
                pcall(fadeOut, obj)
            end

            task.delay(0.6, function()
                screenGui:Destroy()
                -- ЗАГРУЗКА ГЛАВНОГО МЕНЮ
                local ok, err = pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/maybemenu.lua", true))()
                end)
                if not ok then
                    warn("[RussElite Loader] Error loading main menu: " .. tostring(err))
                end
            end)
        end)
    end
end)
