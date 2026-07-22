-- RussElite Bootstrapper - loader.lua
-- Glassmorphism Loading Screen

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
    Subtitle = "Империя скриптов",
    TextColor = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(200, 180, 100),
    ScriptURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/ui/gui.lua"
}

function Loader:CreateLoadingUI()
    local container = GetSafeContainer()
    
    -- Fullscreen black overlay
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.4
    overlay.Parent = container
    
    -- Main card with glass effect
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 340, 0, 200)
    card.Position = UDim2.new(0.5, -170, 0.5, -100)
    card.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    card.BackgroundTransparency = 0.25
    card.Parent = container
    
    -- Glass border
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.65
    stroke.Thickness = 1.5
    stroke.Parent = card
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = card
    
    -- Gradient overlay for glass effect
    local glassGradient = Instance.new("UIGradient")
    glassGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 200, 220)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 170))
    })
    glassGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(0.5, 0.9),
        NumberSequenceKeypoint.new(1, 0.85)
    })
    glassGradient.Rotation = 135
    glassGradient.Parent = card
    
    -- Drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 49, 49)
    shadow.ZIndex = 0
    shadow.Parent = card
    
    -- Russian Empire Flag on top
    local flagContainer = Instance.new("Frame")
    flagContainer.Size = UDim2.new(0, 60, 0, 40)
    flagContainer.Position = UDim2.new(0.5, -30, 0, -20)
    flagContainer.BackgroundTransparency = 1
    flagContainer.ZIndex = 5
    flagContainer.Parent = card
    
    -- Flag stripes
    local colors = {
        Color3.fromRGB(255, 255, 255), -- White
        Color3.fromRGB(0, 50, 160),    -- Blue
        Color3.fromRGB(200, 30, 30),   -- Red
    }
    
    for i, color in ipairs(colors) do
        local stripe = Instance.new("Frame")
        stripe.Size = UDim2.new(1, 0, 0.33, 0)
        stripe.Position = UDim2.new(0, 0, (i-1)/3, 0)
        stripe.BackgroundColor3 = color
        stripe.Parent = flagContainer
        
        local stripeCorner = Instance.new("UICorner")
        stripeCorner.CornerRadius = UDim.new(0, 3)
        stripeCorner.Parent = stripe
    end
    
    -- Flag border
    local flagStroke = Instance.new("UIStroke")
    flagStroke.Color = Color3.fromRGB(200, 180, 100)
    flagStroke.Transparency = 0.3
    flagStroke.Thickness = 1.5
    flagStroke.Parent = flagContainer
    
    local flagCorner = Instance.new("UICorner")
    flagCorner.CornerRadius = UDim.new(0, 4)
    flagCorner.Parent = flagContainer
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 35)
    title.BackgroundTransparency = 1
    title.Text = CONFIG.Title
    title.TextColor3 = CONFIG.TextColor
    title.TextSize = 30
    title.Font = Enum.Font.GothamBlack
    title.Parent = card
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 70)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = CONFIG.Subtitle
    subtitle.TextColor3 = CONFIG.Accent
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextTransparency = 0.3
    subtitle.Parent = card
    
    -- Progress bar background
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0.75, 0, 0, 8)
    barBg.Position = UDim2.new(0.125, 0, 0, 110)
    barBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    barBg.BackgroundTransparency = 0.8
    barBg.Parent = card
    
    local barBgCorner = Instance.new("UICorner")
    barBgCorner.CornerRadius = UDim.new(1, 0)
    barBgCorner.Parent = barBg
    
    -- Progress fill with gradient
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(200, 180, 100)
    fill.BackgroundTransparency = 0.2
    fill.Parent = barBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    -- Progress gradient
    local progressGradient = Instance.new("UIGradient")
    progressGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 150)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 160, 80))
    })
    progressGradient.Parent = fill
    
    -- Status text
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0, 135)
    status.BackgroundTransparency = 1
    status.Text = "Инициализация..."
    status.TextColor3 = CONFIG.TextColor
    status.TextSize = 12
    status.Font = Enum.Font.Gotham
    status.TextTransparency = 0.4
    status.Parent = card
    
    -- Loading dots animation
    local dots = Instance.new("TextLabel")
    dots.Size = UDim2.new(0, 30, 0, 15)
    dots.Position = UDim2.new(0.6, 0, 0, 137)
    dots.BackgroundTransparency = 1
    dots.Text = ""
    dots.TextColor3 = CONFIG.Accent
    dots.TextSize = 12
    dots.Font = Enum.Font.Gotham
    dots.Parent = card
    
    return {
        Container = container,
        Card = card,
        Fill = fill,
        Status = status,
        Dots = dots
    }
end

function Loader:Start(elements)
    -- Animate dots
    local dotStates = {".", "..", "..."}
    local dotIndex = 1
    local dotConnection
    dotConnection = RunService.Heartbeat:Connect(function()
        elements.Dots.Text = dotStates[dotIndex]
        dotIndex = dotIndex % 3 + 1
    end)
    
    -- Progress animation
    local progress = TweenService:Create(
        elements.Fill,
        TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        { Size = UDim2.new(1, 0, 1, 0) }
    )
    
    local messages = {
        "Инициализация систем...",
        "Загрузка модулей...",
        "Подключение к базе...",
        "Подготовка интерфейса..."
    }
    
    for i, msg in ipairs(messages) do
        task.delay((i - 1) * 0.6, function()
            elements.Status.Text = msg
        end)
    end
    
    progress:Play()
    progress.Completed:Connect(function()
        elements.Status.Text = "Запуск..."
        dotConnection:Disconnect()
        elements.Dots.Text = "✓"
        
        -- Load main script
        pcall(function()
            local scriptSource = game:HttpGet(CONFIG.ScriptURL)
            local f = loadstring(scriptSource)
            if f then f() end
        end)
        
        -- Fade out and destroy
        local fadeOut = TweenService:Create(
            elements.Card,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { BackgroundTransparency = 1, Position = UDim2.new(0.5, -170, 0.5, -130) }
        )
        
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            elements.Container:Destroy()
        end)
    end)
end

local elements = Loader:CreateLoadingUI()
Loader:Start(elements)
