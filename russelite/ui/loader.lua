-- RussElite Imperial Bootstrapper - loader.lua
-- Imperial Russian Glassmorphism Loading Screen

local Loader = {}

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Imperial Colors
local COLORS = {
    ImperialGold = Color3.fromRGB(218, 165, 32),
    ImperialBlack = Color3.fromRGB(5, 5, 8),
    ImperialWhite = Color3.fromRGB(240, 240, 240),
    ImperialRed = Color3.fromRGB(180, 30, 30),
    GlassBg = Color3.fromRGB(15, 15, 22),
    GlassStroke = Color3.fromRGB(255, 255, 255),
    Shadow = Color3.fromRGB(0, 0, 0)
}

-- Configuration
local CONFIG = {
    Title = "RussElite",
    Subtitle = "Имперский Хаб",
    LoadingText = "Загрузка...",
    ScriptURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/ui/gui.lua",
    LoadingDuration = 3.5,
    GlassTransparency = 0.2,
    StrokeTransparency = 0.6,
    BorderRadius = 20
}

-- Safe container
local function GetSafeContainer()
    local success, result = pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "RussEliteLoader"
        sg.ResetOnSpawn = false
        sg.Parent = CoreGui
        return sg
    end)
    
    if not success then
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        local sg = Instance.new("ScreenGui")
        sg.Name = "RussEliteLoader"
        sg.ResetOnSpawn = false
        sg.Parent = playerGui
        return sg
    end
    
    return result
end

-- Tween helper
local function createTween(obj, props, duration, easing)
    return TweenService:Create(
        obj,
        TweenInfo.new(duration or 0.5, easing or Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props
    )
end

-- Apply glass effect
local function applyGlass(frame, customRadius)
    -- Deep shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = COLORS.Shadow
    shadow.ImageTransparency = 0.35
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 49, 49)
    shadow.ZIndex = 0
    shadow.Parent = frame
    
    -- Glass stroke
    local stroke = Instance.new("UIStroke")
    stroke.Name = "GlassStroke"
    stroke.Color = COLORS.GlassStroke
    stroke.Transparency = CONFIG.StrokeTransparency
    stroke.Thickness = 1.5
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = frame
    
    -- Inner glow gradient
    local gradient = Instance.new("UIGradient")
    gradient.Name = "GlassGradient"
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 200, 220)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.88),
        NumberSequenceKeypoint.new(0.5, 0.94),
        NumberSequenceKeypoint.new(1, 0.88)
    })
    gradient.Rotation = 135
    gradient.Parent = stroke
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.Name = "GlassCorner"
    corner.CornerRadius = UDim.new(0, customRadius or CONFIG.BorderRadius)
    corner.Parent = frame
    
    return shadow, stroke, gradient, corner
end

-- Create Russian Empire Flag
local function createImperialFlag(parent)
    local flag = Instance.new("Frame")
    flag.Name = "ImperialFlag"
    flag.Size = UDim2.new(1, 0, 0.4, 0)
    flag.Position = UDim2.new(0, 0, 0.3, 0)
    flag.BackgroundTransparency = 1
    flag.ZIndex = 5
    flag.Parent = parent
    
    local stripeHeight = 1/3
    
    -- Black stripe (top)
    local blackStripe = Instance.new("Frame")
    blackStripe.Size = UDim2.new(1, 0, stripeHeight, 0)
    blackStripe.Position = UDim2.new(0, 0, 0, 0)
    blackStripe.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blackStripe.BorderSizePixel = 0
    blackStripe.ZIndex = 5
    blackStripe.Parent = flag
    
    -- Gold stripe (middle)
    local goldStripe = Instance.new("Frame")
    goldStripe.Size = UDim2.new(1, 0, stripeHeight, 0)
    goldStripe.Position = UDim2.new(0, 0, stripeHeight, 0)
    goldStripe.BackgroundColor3 = Color3.fromRGB(218, 165, 32)
    goldStripe.BorderSizePixel = 0
    goldStripe.ZIndex = 5
    goldStripe.Parent = flag
    
    -- White stripe (bottom)
    local whiteStripe = Instance.new("Frame")
    whiteStripe.Size = UDim2.new(1, 0, stripeHeight, 0)
    whiteStripe.Position = UDim2.new(0, 0, stripeHeight * 2, 0)
    whiteStripe.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    whiteStripe.BorderSizePixel = 0
    whiteStripe.ZIndex = 5
    whiteStripe.Parent = flag
    
    -- Imperial Eagle (center)
    local eagle = Instance.new("TextLabel")
    eagle.Size = UDim2.new(0.5, 0, 0.8, 0)
    eagle.Position = UDim2.new(0.25, 0, 0.1, 0)
    eagle.BackgroundTransparency = 1
    eagle.Text = "👑"
    eagle.TextSize = 28
    eagle.Font = Enum.Font.GothamBold
    eagle.TextColor3 = Color3.fromRGB(255, 215, 0)
    eagle.ZIndex = 6
    eagle.Parent = flag
    
    return flag
end

-- Create loading UI
function Loader:CreateLoadingUI()
    local container = GetSafeContainer()
    
    -- Full screen black overlay
    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = COLORS.ImperialBlack
    overlay.BackgroundTransparency = 0.3
    overlay.ZIndex = 1
    overlay.Parent = container
    
    -- Particle effect (stars/dust)
    for i = 1, 30 do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundColor3 = COLORS.ImperialGold
        particle.BackgroundTransparency = 0.5
        particle.BorderSizePixel = 0
        particle.ZIndex = 2
        particle.Parent = overlay
        
        local particleCorner = Instance.new("UICorner")
        particleCorner.CornerRadius = UDim.new(1, 0)
        particleCorner.Parent = particle
        
        -- Floating animation
        coroutine.wrap(function()
            while particle and particle.Parent do
                local floatUp = createTween(particle, {
                    Position = UDim2.new(math.random(), 0, math.random() - 0.1, 0),
                    BackgroundTransparency = 0.9
                }, math.random(20, 40) / 10, Enum.EasingStyle.Sine)
                floatUp:Play()
                floatUp.Completed:Wait()
                
                particle.Position = UDim2.new(math.random(), 0, math.random() + 0.1, 0)
                particle.BackgroundTransparency = 0.5
                
                createTween(particle, {
                    BackgroundTransparency = 0.5
                }, 0.5):Play()
            end
        end)()
    end
    
    -- Main loading card
    local card = Instance.new("Frame")
    card.Name = "LoadingCard"
    card.Size = UDim2.new(0, 380, 0, 280)
    card.Position = UDim2.new(0.5, -190, 0.5, -140)
    card.BackgroundColor3 = COLORS.GlassBg
    card.BackgroundTransparency = CONFIG.GlassTransparency
    card.ZIndex = 10
    card.Parent = container
    
    applyGlass(card)
    
    -- Gold accent line on top
    local topAccent = Instance.new("Frame")
    topAccent.Size = UDim2.new(0.8, 0, 0, 2)
    topAccent.Position = UDim2.new(0.1, 0, 0, 8)
    topAccent.BackgroundColor3 = COLORS.ImperialGold
    topAccent.BackgroundTransparency = 0.3
    topAccent.BorderSizePixel = 0
    topAccent.ZIndex = 12
    topAccent.Parent = card
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(1, 0)
    accentCorner.Parent = topAccent
    
    -- Imperial Eagle emblem (top)
    local emblem = Instance.new("TextLabel")
    emblem.Name = "Emblem"
    emblem.Size = UDim2.new(0, 60, 0, 60)
    emblem.Position = UDim2.new(0.5, -30, 0, 15)
    emblem.BackgroundTransparency = 1
    emblem.Text = "👑"
    emblem.TextSize = 40
    emblem.Font = Enum.Font.GothamBold
    emblem.ZIndex = 12
    emblem.Parent = card
    
    -- Imperial Flag inside card
    local flagContainer = Instance.new("Frame")
    flagContainer.Size = UDim2.new(0.6, 0, 0.15, 0)
    flagContainer.Position = UDim2.new(0.2, 0, 0.28, 0)
    flagContainer.BackgroundTransparency = 1
    flagContainer.ZIndex = 12
    flagContainer.Parent = card
    
    createImperialFlag(flagContainer)
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0.45, 0)
    title.BackgroundTransparency = 1
    title.Text = CONFIG.Title
    title.TextColor3 = COLORS.ImperialWhite
    title.TextSize = 32
    title.Font = Enum.Font.GothamBlack
    title.ZIndex = 12
    title.Parent = card
    
    -- Title glow effect
    local titleGlow = Instance.new("UIStroke")
    titleGlow.Color = COLORS.ImperialGold
    titleGlow.Transparency = 0.7
    titleGlow.Thickness = 1
    titleGlow.Parent = title
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0.6, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = CONFIG.Subtitle
    subtitle.TextColor3 = COLORS.ImperialGold
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.GothamBold
    subtitle.TextTransparency = 0.3
    subtitle.ZIndex = 12
    subtitle.Parent = card
    
    -- Progress bar background (glass)
    local progressBg = Instance.new("Frame")
    progressBg.Name = "ProgressBg"
    progressBg.Size = UDim2.new(0.75, 0, 0, 8)
    progressBg.Position = UDim2.new(0.125, 0, 0.72, 0)
    progressBg.BackgroundColor3 = COLORS.ImperialWhite
    progressBg.BackgroundTransparency = 0.85
    progressBg.ZIndex = 12
    progressBg.Parent = card
    
    local progressBgCorner = Instance.new("UICorner")
    progressBgCorner.CornerRadius = UDim.new(1, 0)
    progressBgCorner.Parent = progressBg
    
    -- Progress bar stroke
    local progressStroke = Instance.new("UIStroke")
    progressStroke.Color = COLORS.ImperialGold
    progressStroke.Transparency = 0.5
    progressStroke.Thickness = 1
    progressStroke.Parent = progressBg
    
    -- Progress fill (golden)
    local progressFill = Instance.new("Frame")
    progressFill.Name = "ProgressFill"
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = COLORS.ImperialGold
    progressFill.BackgroundTransparency = 0.2
    progressFill.ZIndex = 13
    progressFill.Parent = progressBg
    
    local progressFillCorner = Instance.new("UICorner")
    progressFillCorner.CornerRadius = UDim.new(1, 0)
    progressFillCorner.Parent = progressFill
    
    -- Progress fill gradient
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(218, 165, 32))
    })
    fillGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 0.3)
    })
    fillGradient.Parent = progressFill
    
    -- Glow effect on progress
    local progressGlow = Instance.new("Frame")
    progressGlow.Name = "ProgressGlow"
    progressGlow.Size = UDim2.new(1, 0, 0, 3)
    progressGlow.Position = UDim2.new(0, 0, 0.3, 0)
    progressGlow.BackgroundColor3 = COLORS.ImperialWhite
    progressGlow.BackgroundTransparency = 0.7
    progressGlow.BorderSizePixel = 0
    progressGlow.ZIndex = 14
    progressGlow.Parent = progressFill
    
    -- Status text
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, 0, 0, 20)
    statusText.Position = UDim2.new(0, 0, 0.78, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = CONFIG.LoadingText
    statusText.TextColor3 = COLORS.ImperialWhite
    statusText.TextSize = 13
    statusText.Font = Enum.Font.Gotham
    statusText.TextTransparency = 0.4
    statusText.ZIndex = 12
    statusText.Parent = card
    
    -- Bottom imperial decoration
    local bottomDeco = Instance.new("TextLabel")
    bottomDeco.Size = UDim2.new(1, 0, 0, 20)
    bottomDeco.Position = UDim2.new(0, 0, 0.87, 0)
    bottomDeco.BackgroundTransparency = 1
    bottomDeco.Text = "♛  Съ нами Богъ  ♛"
    bottomDeco.TextColor3 = COLORS.ImperialGold
    bottomDeco.TextSize = 11
    bottomDeco.Font = Enum.Font.GothamBold
    bottomDeco.TextTransparency = 0.5
    bottomDeco.ZIndex = 12
    bottomDeco.Parent = card
    
    -- Loading spinner (rotating crown)
    local spinner = Instance.new("TextLabel")
    spinner.Name = "Spinner"
    spinner.Size = UDim2.new(0, 30, 0, 30)
    spinner.Position = UDim2.new(0.5, -15, 0.93, -15)
    spinner.BackgroundTransparency = 1
    spinner.Text = "♛"
    spinner.TextColor3 = COLORS.ImperialGold
    spinner.TextSize = 20
    spinner.Font = Enum.Font.GothamBold
    spinner.TextTransparency = 0.3
    spinner.ZIndex = 12
    spinner.Parent = card
    
    -- Spinning animation
    coroutine.wrap(function()
        local angle = 0
        while spinner and spinner.Parent do
            angle = angle + 5
            spinner.Rotation = angle
            RunService.RenderStepped:Wait()
        end
    end)()
    
    return {
        Container = container,
        Overlay = overlay,
        Card = card,
        ProgressFill = progressFill,
        ProgressGlow = progressGlow,
        StatusText = statusText,
        Title = title,
        Spinner = spinner,
        Emblem = emblem
    }
end

-- Animate progress
function Loader:AnimateProgress(elements, callback)
    -- Progress bar animation
    local progressTween = createTween(
        elements.ProgressFill,
        { Size = UDim2.new(1, 0, 1, 0) },
        CONFIG.LoadingDuration,
        Enum.EasingStyle.Linear
    )
    
    -- Status messages in Russian Imperial style
    local messages = {
        "Пробуждение Империи...",
        "Загрузка модулей...",
        "Установка соединения...",
        "Подготовка интерфейса...",
        "Имперский Хаб готов!"
    }
    
    local msgInterval = CONFIG.LoadingDuration / #messages
    
    for i, msg in ipairs(messages) do
        task.delay(msgInterval * (i - 1), function()
            if elements.StatusText then
                elements.StatusText.Text = msg
                
                -- Fade in/out effect for text
                elements.StatusText.TextTransparency = 0.7
                createTween(elements.StatusText, { TextTransparency = 0.4 }, 0.3):Play()
            end
            
            -- Pulse the glow on progress
            if elements.ProgressGlow then
                elements.ProgressGlow.BackgroundTransparency = 0.4
                createTween(elements.ProgressGlow, { BackgroundTransparency = 0.8 }, 0.3):Play()
            end
        end)
    end
    
    -- Pulse emblem during loading
    coroutine.wrap(function()
        while elements.Emblem and elements.Emblem.Parent do
            createTween(elements.Emblem, { TextTransparency = 0.5 }, 0.8):Play()
            task.wait(0.8)
            createTween(elements.Emblem, { TextTransparency = 0 }, 0.8):Play()
            task.wait(0.8)
        end
    end)()
    
    progressTween:Play()
    
    progressTween.Completed:Connect(function()
        elements.StatusText.Text = "Запуск Имперского Хаба..."
        task.wait(0.3)
        callback()
    end)
end

-- Fade out and cleanup
function Loader:FadeOut(elements, callback)
    -- Fade overlay
    local overlayFade = createTween(elements.Overlay, {
        BackgroundTransparency = 1
    }, 0.6, Enum.EasingStyle.Quart)
    
    -- Fade and shrink card
    local cardFade = createTween(elements.Card, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 340, 0, 240),
        Position = UDim2.new(0.5, -170, 0.5, -130)
    }, 0.5, Enum.EasingStyle.Quart)
    
    -- Fade title
    local titleFade = createTween(elements.Title, {
        TextTransparency = 1
    }, 0.4)
    
    -- Fade spinner
    local spinnerFade = createTween(elements.Spinner, {
        TextTransparency = 1
    }, 0.3)
    
    overlayFade:Play()
    cardFade:Play()
    titleFade:Play()
    spinnerFade:Play()
    
    cardFade.Completed:Connect(function()
        -- Destroy everything
        elements.Container:Destroy()
        
        if callback then
            callback()
        end
    end)
end

-- Main execution
local function Init()
    local elements = Loader:CreateLoadingUI()
    
    -- Start progress animation
    Loader:AnimateProgress(elements, function()
        -- Load and execute main script
        local success, result = pcall(function()
            local mainScript = game:HttpGet(CONFIG.ScriptURL)
            local loadedFunction = loadstring(mainScript)
            if loadedFunction then
                loadedFunction()
            end
        end)
        
        if not success then
            elements.StatusText.Text = "Ошибка загрузки!"
            elements.StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
            warn("RussElite Imperial Loader Error:", result)
            task.wait(2)
        end
        
        -- Fade out loader
        Loader:FadeOut(elements)
    end)
end

-- Start the Imperial Loading Screen
Init()
