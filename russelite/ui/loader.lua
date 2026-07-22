-- RussElite Bootstrapper - loader.lua
-- 3D Glass Black iPhone Style (2026 Aesthetic)

local Loader = {}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local function GetSafeContainer()
    local success, result = pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "RussEliteLoader"
        sg.Parent = CoreGui
        return sg
    end)
    if not success then
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        local sg = Instance.new("ScreenGui")
        sg.Name = "RussEliteLoader"
        sg.Parent = playerGui
        return sg
    end
    return result
end

local CONFIG = {
    Title = "RussElite",
    Subtitle = "Загрузка системы...",
    TextColor = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(180, 180, 180),
    Background = Color3.fromRGB(8, 8, 8),
    GlassTop = Color3.fromRGB(25, 25, 25),
    GlassBottom = Color3.fromRGB(5, 5, 5),
    ScriptURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/ui/gui.lua"
}

local function apply3DGlass(frame)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = frame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.GlassTop),
        ColorSequenceKeypoint.new(1, CONFIG.GlassBottom)
    })
    gradient.Rotation = 90
    gradient.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.Transparency = 0.4
    stroke.Thickness = 1
    stroke.Parent = frame

    -- Блик сверху
    local highlight = Instance.new("Frame")
    highlight.Size = UDim2.new(1, 0, 0, 1)
    highlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    highlight.BackgroundTransparency = 0.85
    highlight.BorderSizePixel = 0
    highlight.Parent = frame
    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 20)
    hCorner.Parent = highlight
end

function Loader:CreateLoadingUI()
    local container = GetSafeContainer()

    -- Фон
    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = CONFIG.Background
    bg.Parent = container

    -- Свечение карточки
    local cardGlow = Instance.new("Frame")
    cardGlow.Size = UDim2.new(0, 340, 0, 220)
    cardGlow.Position = UDim2.new(0.5, -170, 0.5, -110)
    cardGlow.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    cardGlow.BackgroundTransparency = 0.9
    cardGlow.Parent = container
    Instance.new("UICorner", cardGlow).CornerRadius = UDim.new(0, 24)

    -- Карточка загрузки
    local card = Instance.new("Frame")
    card.Name = "LoadingCard"
    card.Size = UDim2.new(0, 320, 0, 200)
    card.Position = UDim2.new(0.5, -160, 0.5, -100)
    card.BackgroundColor3 = CONFIG.Background
    card.BackgroundTransparency = 0.05
    card.Parent = container
    apply3DGlass(card)

    -- Логотип / Текст
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = CONFIG.Title
    title.TextColor3 = CONFIG.TextColor
    title.TextSize = 32
    title.Font = Enum.Font.GothamBold
    title.Parent = card

    -- Подзаголовок
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 72)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = CONFIG.Subtitle
    subtitle.TextColor3 = CONFIG.TextColor
    subtitle.TextSize = 13
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.TextTransparency = 0.5
    subtitle.Parent = card

    -- Фон прогресс бара
    local barBg = Instance.new("Frame")
    barBg.Name = "BarBg"
    barBg.Size = UDim2.new(0.8, 0, 0, 6)
    barBg.Position = UDim2.new(0.1, 0, 0, 120)
    barBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    barBg.BackgroundTransparency = 0.9
    barBg.Parent = card
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    -- Заполнение (Белый светящийся)
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = CONFIG.TextColor
    fill.BackgroundTransparency = 0.2
    fill.Parent = barBg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    -- Статус
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0, 145)
    status.BackgroundTransparency = 1
    status.Text = "Инициализация..."
    status.TextColor3 = CONFIG.TextColor
    status.TextSize = 12
    status.Font = Enum.Font.Gotham
    status.TextTransparency = 0.6
    status.Parent = card

    return {
        Container = container,
        Card = card,
        CardGlow = cardGlow,
        Fill = fill,
        Status = status
    }
end

function Loader:Start(elements)
    -- Плавное появление
    elements.Card.Size = UDim2.new(0, 280, 0, 180)
    elements.CardGlow.Size = UDim2.new(0, 300, 0, 200)
    TweenService:Create(elements.Card, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = UDim2.new(0, 320, 0, 200)}):Play()
    TweenService:Create(elements.CardGlow, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = UDim2.new(0, 340, 0, 220)}):Play()

    local progress = TweenService:Create(
        elements.Fill,
        TweenInfo.new(2.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        { Size = UDim2.new(1, 0, 1, 0) }
    )

    local messages = {
        "Инициализация систем...",
        "Загрузка модулей...",
        "Подготовка интерфейса...",
        "Почти готово..."
    }
    for i, msg in ipairs(messages) do
        task.delay((i - 1) * 0.7, function()
            if elements.Status then elements.Status.Text = msg end
        end)
    end

    progress:Play()
    progress.Completed:Connect(function()
        elements.Status.Text = "Запуск..."
        elements.Status.TextTransparency = 0
        
        local ok, err = pcall(function()
            local scriptSource = game:HttpGet(CONFIG.ScriptURL)
            local f = loadstring(scriptSource)
            if f then f() end
        end)
        
        if not ok then
            warn("RussElite loader error:", err)
            elements.Status.Text = "Ошибка подключения!"
            elements.Status.TextColor3 = Color3.fromRGB(255, 80, 80)
            task.delay(3, function() elements.Container:Destroy() end)
            return
        end

        -- Плавное исчезновение
        TweenService:Create(elements.Card, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 280, 0, 180),
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(elements.CardGlow, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(elements.Container:FindFirstChild("Background"), TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()

        task.delay(0.5, function()
            elements.Container:Destroy()
        end)
    end)
end

local elements = Loader:CreateLoadingUI()
Loader:Start(elements)
