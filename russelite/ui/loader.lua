-- RussElite Bootstrapper - loader.lua
-- Premium Glass Morphism Loading Screen 2026
-- iPhone Aesthetic

local Loader = {}

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Premium Configuration
local CONFIG = {
    Title = "RussElite",
    Subtitle = "Premium Edition v3.0",
    
    -- Modern Color Palette
    TextColor = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(200, 200, 200),
    TextTertiary = Color3.fromRGB(150, 150, 150),
    
    -- Glass Effects
    GlassLight = Color3.fromRGB(25, 25, 25),
    GlassMedium = Color3.fromRGB(20, 20, 20),
    GlassDark = Color3.fromRGB(15, 15, 15),
    
    -- Accents
    PrimaryAccent = Color3.fromRGB(100, 200, 255),      -- Cyan Blue
    SecondaryAccent = Color3.fromRGB(150, 150, 150),    -- Grey
    SuccessAccent = Color3.fromRGB(100, 220, 140),      -- Green
    WarningAccent = Color3.fromRGB(255, 180, 100),      -- Orange
    
    -- Background
    BackgroundDark = Color3.fromRGB(5, 5, 8),           -- Almost Black
    GlassStroke = Color3.fromRGB(60, 60, 70),           -- Dark Blue-Grey
    
    -- Sizing
    BorderRadius = 20,
    
    -- Script URL
    ScriptURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/ui/gui.lua"
}

-- Safe Container
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

-- Advanced Tween Helper
local function tween(obj, props, dur, style)
    local easingStyle = style or Enum.EasingStyle.Quad
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.35, easingStyle, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- Create Premium Loading UI
function Loader:CreateLoadingUI()
    local container = GetSafeContainer()
    
    -- Background Overlay (Blurred dark effect)
    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = CONFIG.BackgroundDark
    bg.BackgroundTransparency = 0.1
    bg.ZIndex = 1
    bg.Parent = container
    
    -- Animated gradient effect
    local bgGradient = Instance.new("UIGradient")
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.BackgroundDark),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 15, 25)),
        ColorSequenceKeypoint.new(1, CONFIG.BackgroundDark),
    })
    bgGradient.Rotation = 45
    bgGradient.Transparency = NumberSequence.new(0.9)
    bgGradient.Parent = bg
    
    -- Loading Card (Premium Glass)
    local card = Instance.new("Frame")
    card.Name = "LoadingCard"
    card.Size = UDim2.new(0, 380, 0, 250)
    card.Position = UDim2.new(0.5, -190, 0.5, -125)
    card.BackgroundColor3 = CONFIG.GlassDark
    card.BackgroundTransparency = 0.15
    card.ZIndex = 2
    card.Parent = container
    
    -- Card Border Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.GlassStroke
    stroke.Transparency = 0.4
    stroke.Thickness = 2
    stroke.Parent = card
    
    -- Card Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    corner.Parent = card
    
    -- Card Gradient Overlay (subtle)
    local cardGradient = Instance.new("UIGradient")
    cardGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.PrimaryAccent),
        ColorSequenceKeypoint.new(1, CONFIG.GlassDark),
    })
    cardGradient.Rotation = 135
    cardGradient.Transparency = NumberSequence.new(0.92)
    cardGradient.Parent = card
    
    -- Top Accent Bar
    local topAccent = Instance.new("Frame")
    topAccent.Size = UDim2.new(1, 0, 0, 4)
    topAccent.BackgroundColor3 = CONFIG.PrimaryAccent
    topAccent.BackgroundTransparency = 0.3
    topAccent.Parent = card
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    accentCorner.Parent = topAccent
    
    -- Icon Container (Animated)
    local iconContainer = Instance.new("Frame")
    iconContainer.Size = UDim2.new(0, 80, 0, 80)
    iconContainer.Position = UDim2.new(0.5, -40, 0, 15)
    iconContainer.BackgroundColor3 = CONFIG.PrimaryAccent
    iconContainer.BackgroundTransparency = 0.2
    iconContainer.Parent = card
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(1, 0)
    iconCorner.Parent = iconContainer
    
    local iconStroke = Instance.new("UIStroke")
    iconStroke.Color = CONFIG.PrimaryAccent
    iconStroke.Transparency = 0.5
    iconStroke.Thickness = 1.5
    iconStroke.Parent = iconContainer
    
    -- Icon Text
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "◆"
    icon.TextColor3 = CONFIG.PrimaryAccent
    icon.TextSize = 44
    icon.Font = Enum.Font.GothamBold
    icon.Parent = iconContainer
    
    -- Icon Glow
    local iconGlow = Instance.new("Frame")
    iconGlow.Size = UDim2.new(1.4, 0, 1.4, 0)
    iconGlow.Position = UDim2.new(-0.2, 0, -0.2, 0)
    iconGlow.BackgroundColor3 = CONFIG.PrimaryAccent
    iconGlow.BackgroundTransparency = 0.85
    iconGlow.ZIndex = 0
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = iconGlow
    iconGlow.Parent = iconContainer
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 105)
    title.BackgroundTransparency = 1
    title.Text = CONFIG.Title
    title.TextColor3 = CONFIG.TextColor
    title.TextSize = 32
    title.Font = Enum.Font.GothamBold
    title.Parent = card
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 18)
    subtitle.Position = UDim2.new(0, 0, 0, 137)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = CONFIG.Subtitle
    subtitle.TextColor3 = CONFIG.TextTertiary
    subtitle.TextSize = 12
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextTransparency = 0.3
    subtitle.Parent = card
    
    -- Progress bar background
    local barBg = Instance.new("Frame")
    barBg.Name = "BarBg"
    barBg.Size = UDim2.new(0.75, 0, 0, 8)
    barBg.Position = UDim2.new(0.5, -0.75*190, 0, 170)
    barBg.BackgroundColor3 = CONFIG.GlassLight
    barBg.BackgroundTransparency = 0.4
    barBg.Parent = card
    
    local barBgCorner = Instance.new("UICorner")
    barBgCorner.CornerRadius = UDim.new(1, 0)
    barBgCorner.Parent = barBg
    
    local barBgStroke = Instance.new("UIStroke")
    barBgStroke.Color = CONFIG.GlassStroke
    barBgStroke.Transparency = 0.5
    barBgStroke.Thickness = 1
    barBgStroke.Parent = barBg
    
    -- Progress Fill (animated)
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = CONFIG.PrimaryAccent
    fill.BackgroundTransparency = 0.2
    fill.Parent = barBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    -- Fill Gradient
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 150, 255)),
        ColorSequenceKeypoint.new(1, CONFIG.PrimaryAccent),
    })
    fillGradient.Rotation = 90
    fillGradient.Parent = fill
    
    -- Status Text
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, 0, 0, 18)
    status.Position = UDim2.new(0, 0, 0, 195)
    status.BackgroundTransparency = 1
    status.Text = "Initializing..."
    status.TextColor3 = CONFIG.TextSecondary
    status.TextSize = 12
    status.Font = Enum.Font.Gotham
    status.TextTransparency = 0.2
    status.Parent = card
    
    -- Animated dots
    local dots = Instance.new("TextLabel")
    dots.Name = "Dots"
    dots.Size = UDim2.new(0.2, 0, 0, 18)
    dots.Position = UDim2.new(0.5, 40, 0, 195)
    dots.BackgroundTransparency = 1
    dots.Text = "●"
    dots.TextColor3 = CONFIG.PrimaryAccent
    dots.TextSize = 14
    dots.Font = Enum.Font.GothamBold
    dots.Parent = card
    
    -- Version Badge
    local versionBadge = Instance.new("Frame")
    versionBadge.Size = UDim2.new(0, 70, 0, 24)
    versionBadge.Position = UDim2.new(0.5, -35, 0, 220)
    versionBadge.BackgroundColor3 = CONFIG.PrimaryAccent
    versionBadge.BackgroundTransparency = 0.4
    versionBadge.Parent = card
    
    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 6)
    badgeCorner.Parent = versionBadge
    
    local versionText = Instance.new("TextLabel")
    versionText.Size = UDim2.new(1, 0, 1, 0)
    versionText.BackgroundTransparency = 1
    versionText.Text = "v3.0"
    versionText.TextColor3 = CONFIG.PrimaryAccent
    versionText.TextSize = 10
    versionText.Font = Enum.Font.GothamBold
    versionText.Parent = versionBadge
    
    return {
        Container = container,
        Card = card,
        Fill = fill,
        Status = status,
        IconContainer = iconContainer,
        IconGlow = iconGlow,
        Dots = dots,
        Background = bg
    }
end

-- Start Loading Animation
function Loader:Start(elements)
    -- Fade in animation
    elements.Container.BackgroundTransparency = 1
    tween(elements.Container, {BackgroundTransparency = 0.1}, 0.5, Enum.EasingStyle.Quad)
    
    -- Card entrance animation
    elements.Card.Size = UDim2.new(0, 360, 0, 230)
    elements.Card.BackgroundTransparency = 1
    tween(elements.Card, {
        Size = UDim2.new(0, 380, 0, 250),
        BackgroundTransparency = 0.15
    }, 0.6, Enum.EasingStyle.Elastic)
    
    -- Progress animation
    local progress = TweenService:Create(
        elements.Fill,
        TweenInfo.new(3.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
        { Size = UDim2.new(1, 0, 1, 0) }
    )
    
    -- Animated status messages
    local messages = {
        "Initializing systems...",
        "Loading resources...",
        "Preparing interface...",
        "Optimizing performance...",
        "Almost ready..."
    }
    
    for i, msg in ipairs(messages) do
        task.delay((i - 1) * 0.6, function()
            if elements.Status then
                -- Fade out old text
                tween(elements.Status, {TextTransparency = 0.8}, 0.2)
                task.wait(0.1)
                
                -- Update text
                elements.Status.Text = msg
                
                -- Fade in new text
                elements.Status.TextTransparency = 0.8
                tween(elements.Status, {TextTransparency = 0.2}, 0.2)
            end
        end)
    end
    
    -- Icon pulsing animation
    local iconPulse = true
    local pulsing = RunService.Heartbeat:Connect(function()
        if iconPulse and elements.IconGlow then
            if math.fmod(tick() * 2, 2) < 1 then
                elements.IconGlow.BackgroundTransparency = 0.8
            else
                elements.IconGlow.BackgroundTransparency = 0.92
            end
        end
    end)
    
    -- Start progress
    progress:Play()
    
    progress.Completed:Connect(function()
        iconPulse = false
        pulsing:Disconnect()
        
        -- Final message
        elements.Status.Text = "Launching RussElite..."
        tween(elements.Status, {TextTransparency = 0.1}, 0.3)
        
        task.wait(0.5)
        
        -- Load main GUI script
        local ok, err = pcall(function()
            local scriptSource = game:HttpGet(CONFIG.ScriptURL)
            local f = loadstring(scriptSource)
            if f then
                f()
            end
        end)
        
        if not ok then
            warn("❌ RussElite loader error:", err)
            elements.Status.Text = "❌ Error loading script"
            elements.Status.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        -- Success animation
        elements.Status.Text = "✓ Loading complete!"
        elements.Status.TextColor3 = CONFIG.SuccessAccent
        
        -- Fade out loader
        task.delay(0.3, function()
            tween(elements.Card, {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 360, 0, 230)
            }, 0.5)
            tween(elements.Container, {BackgroundTransparency = 1}, 0.5)
            
            task.wait(0.6)
            elements.Container:Destroy()
        end)
    end)
end

-- Run Loader
local function Run()
    local elements = Loader:CreateLoadingUI()
    Loader:Start(elements)
end

-- Execute
Run()

print("🚀 RussElite Loader Started - Premium Glass Edition")
