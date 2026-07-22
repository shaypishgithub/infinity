-- RussElite Bootstrapper - loader.lua [2026 Modern Glass Design]
-- Beautiful loading screen with glass-morphism effect

local Loader = {}

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Configuration - 2026 Modern Glass Aesthetic
local CONFIG = {
    Title = "RussElite",
    Subtitle = "Initializing...",
    TextColor = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(100, 200, 255),         -- Modern blue
    AccentAlt = Color3.fromRGB(100, 255, 200),      -- Cyan
    Background = Color3.fromRGB(5, 5, 10),          -- Deep black
    Glass = Color3.fromRGB(25, 30, 45),             -- Dark glass
    GlassLight = Color3.fromRGB(40, 50, 70),        -- Light glass
    StrokeColor = Color3.fromRGB(80, 100, 150),    -- Glass border
    ScriptURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/ui/gui.lua"
}

-- Safe container
local function GetSafeContainer()
    local success, result = pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "RussEliteLoader2026"
        sg.Parent = CoreGui
        return sg
    end)
    if not success then
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        local sg = Instance.new("ScreenGui")
        sg.Name = "RussEliteLoader2026"
        sg.Parent = playerGui
        return sg
    end
    return result
end

-- Tween helper
local function tween(obj, props, dur, easing)
    local style = easing or Enum.EasingStyle.Quad
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.3, style, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- Create modern loading UI
function Loader:CreateLoadingUI()
    local container = GetSafeContainer()

    -- Full screen background with gradient
    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = CONFIG.Background
    bg.BackgroundTransparency = 0
    bg.Parent = container
    
    -- Animated gradient background
    local bgGradient = Instance.new("UIGradient")
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 5, 10)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 20, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 10))
    })
    bgGradient.Rotation = 45
    bgGradient.Parent = bg

    -- Glass card container with premium styling
    local cardContainer = Instance.new("Frame")
    cardContainer.Name = "CardContainer"
    cardContainer.Size = UDim2.new(0, 420, 0, 280)
    cardContainer.Position = UDim2.new(0.5, -210, 0.5, -140)
    cardContainer.BackgroundColor3 = CONFIG.Glass
    cardContainer.BackgroundTransparency = 0.2
    cardContainer.Parent = container

    -- Glass stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.StrokeColor
    stroke.Transparency = 0.5
    stroke.Thickness = 1.5
    stroke.Parent = cardContainer

    -- Corner radius for modern look
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = cardContainer

    -- Gradient overlay on card
    local cardGradient = Instance.new("UIGradient")
    cardGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 45, 70)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 30, 45))
    })
    cardGradient.Rotation = 135
    cardGradient.Parent = cardContainer

    -- Premium header area
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 70)
    header.BackgroundColor3 = CONFIG.GlassLight
    header.BackgroundTransparency = 0.3
    header.Parent = cardContainer

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = header

    -- Header gradient
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.Accent),
        ColorSequenceKeypoint.new(1, CONFIG.AccentAlt)
    })
    headerGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(1, 0.9)
    })
    headerGradient.Rotation = 45
    headerGradient.Parent = header

    -- Title with glow effect
    local titleBg = Instance.new("Frame")
    titleBg.Size = UDim2.new(1, 0, 1, 0)
    titleBg.BackgroundTransparency = 1
    titleBg.Parent = header

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0.5, 0)
    title.Position = UDim2.new(0, 0, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = CONFIG.Title
    title.TextColor3 = CONFIG.TextColor
    title.TextSize = 36
    title.Font = Enum.Font.GothamBold
    title.Parent = titleBg

    -- Tagline
    local tagline = Instance.new("TextLabel")
    tagline.Size = UDim2.new(1, 0, 0.5, 0)
    tagline.Position = UDim2.new(0, 0, 0.5, 0)
    tagline.BackgroundTransparency = 1
    tagline.Text = "Modern Glass Loading"
    tagline.TextColor3 = Color3.fromRGB(150, 200, 255)
    tagline.TextSize = 12
    tagline.Font = Enum.Font.Gotham
    tagline.TextTransparency = 0.3
    tagline.Parent = titleBg

    -- Content area
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -70)
    content.Position = UDim2.new(0, 0, 0, 70)
    content.BackgroundTransparency = 1
    content.Parent = cardContainer

    -- Subtitle text
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 30)
    subtitle.Position = UDim2.new(0, 0, 0, 25)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = CONFIG.Subtitle
    subtitle.TextColor3 = CONFIG.TextColor
    subtitle.TextSize = 16
    subtitle.Font = Enum.Font.GothamSemibold
    subtitle.Parent = content

    -- Progress bar background (modern glassmorphism)
    local barContainer = Instance.new("Frame")
    barContainer.Size = UDim2.new(0.7, 0, 0, 8)
    barContainer.Position = UDim2.new(0.15, 0, 0, 75)
    barContainer.BackgroundColor3 = CONFIG.GlassLight
    barContainer.BackgroundTransparency = 0.5
    barContainer.Parent = content

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = barContainer

    -- Progress fill with gradient
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = CONFIG.Accent
    fill.BackgroundTransparency = 0
    fill.Parent = barContainer

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    -- Fill gradient
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.Accent),
        ColorSequenceKeypoint.new(1, CONFIG.AccentAlt)
    })
    fillGradient.Parent = fill

    -- Status text
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, 0, 0, 25)
    status.Position = UDim2.new(0, 0, 0, 105)
    status.BackgroundTransparency = 1
    status.Text = "Initializing..."
    status.TextColor3 = Color3.fromRGB(150, 150, 180)
    status.TextSize = 12
    status.Font = Enum.Font.Gotham
    status.TextTransparency = 0.2
    status.Parent = content

    -- Loading dots animation
    local dotsContainer = Instance.new("TextLabel")
    dotsContainer.Name = "Dots"
    dotsContainer.Size = UDim2.new(1, 0, 0, 20)
    dotsContainer.Position = UDim2.new(0, 0, 0, 150)
    dotsContainer.BackgroundTransparency = 1
    dotsContainer.Text = "●"
    dotsContainer.TextColor3 = CONFIG.Accent
    dotsContainer.TextSize = 16
    dotsContainer.Font = Enum.Font.GothamBold
    dotsContainer.Parent = content

    -- Version info
    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(1, 0, 0, 15)
    version.Position = UDim2.new(0, 0, 1, -20)
    version.BackgroundTransparency = 1
    version.Text = "v3.0 • Glass Loader • 2026"
    version.TextColor3 = Color3.fromRGB(100, 120, 150)
    version.TextSize = 10
    version.Font = Enum.Font.Gotham
    version.TextTransparency = 0.5
    version.Parent = content

    return {
        Container = container,
        Card = cardContainer,
        Fill = fill,
        Status = status,
        Subtitle = subtitle,
        Dots = dotsContainer,
        Header = header
    }
end

-- Animate loading sequence
function Loader:Start(elements)
    -- Progress tween
    local progress = tween(
        elements.Fill,
        { Size = UDim2.new(1, 0, 1, 0) },
        3,
        Enum.EasingStyle.Linear
    )

    -- Loading messages
    local messages = {
        "Initializing systems...",
        "Loading core modules...",
        "Preparing interface...",
        "Optimizing performance...",
        "Almost ready..."
    }

    -- Animated dots
    local dotAnimation = RunService.Heartbeat:Connect(function()
        local dots = elements.Dots.Text
        if dots == "●" then
            elements.Dots.Text = "● ●"
        elseif dots == "● ●" then
            elements.Dots.Text = "● ● ●"
        else
            elements.Dots.Text = "●"
        end
    end)

    -- Update status messages
    for i, msg in ipairs(messages) do
        task.delay((i - 1) * 0.6, function()
            if elements.Status then
                elements.Status.Text = msg
            end
        end)
    end

    progress:Play()

    progress.Completed:Connect(function()
        dotAnimation:Disconnect()
        
        elements.Status.Text = "Launching RussElite..."
        elements.Dots.Text = "✓"
        elements.Dots.TextColor3 = Color3.fromRGB(100, 200, 100)

        -- Smooth fade out
        task.delay(0.5, function()
            tween(elements.Card, {BackgroundTransparency = 1}, 0.4)
            tween(elements.Fill, {BackgroundTransparency = 1}, 0.4)
            tween(elements.Status, {TextTransparency = 1}, 0.4)
            tween(elements.Subtitle, {TextTransparency = 1}, 0.4)
            
            task.delay(0.4, function()
                -- Load main GUI
                local ok, err = pcall(function()
                    local scriptSource = game:HttpGet(CONFIG.ScriptURL)
                    local f = loadstring(scriptSource)
                    if f then 
                        f() 
                    end
                end)

                if not ok then
                    warn("RussElite loader error:", err)
                end

                -- Remove loader
                task.delay(0.1, function()
                    elements.Container:Destroy()
                end)
            end)
        end)
    end)
end

-- Run loader
local elements = Loader:CreateLoadingUI()
Loader:Start(elements)
