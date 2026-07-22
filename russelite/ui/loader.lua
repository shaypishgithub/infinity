-- RussElite Bootstrapper - loader_standalone.lua [2026 Glass]
-- Standalone version with embedded GUI - no external URLs needed!

local Loader = {}
local GuiModule = {}

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Configuration
local CONFIG = {
    Title = "RussElite",
    Subtitle = "Initializing...",
    TextColor = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(100, 200, 255),
    AccentAlt = Color3.fromRGB(100, 255, 200),
    Background = Color3.fromRGB(5, 5, 10),
    Glass = Color3.fromRGB(25, 30, 45),
    GlassLight = Color3.fromRGB(40, 50, 70),
    StrokeColor = Color3.fromRGB(80, 100, 150),
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

-- Create loading UI
function Loader:CreateLoadingUI()
    local container = GetSafeContainer()

    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = CONFIG.Background
    bg.BackgroundTransparency = 0
    bg.Parent = container
    
    local bgGradient = Instance.new("UIGradient")
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 5, 10)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 20, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 10))
    })
    bgGradient.Rotation = 45
    bgGradient.Parent = bg

    local cardContainer = Instance.new("Frame")
    cardContainer.Name = "CardContainer"
    cardContainer.Size = UDim2.new(0, 420, 0, 280)
    cardContainer.Position = UDim2.new(0.5, -210, 0.5, -140)
    cardContainer.BackgroundColor3 = CONFIG.Glass
    cardContainer.BackgroundTransparency = 0.2
    cardContainer.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.StrokeColor
    stroke.Transparency = 0.5
    stroke.Thickness = 1.5
    stroke.Parent = cardContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = cardContainer

    local cardGradient = Instance.new("UIGradient")
    cardGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 45, 70)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 30, 45))
    })
    cardGradient.Rotation = 135
    cardGradient.Parent = cardContainer

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 70)
    header.BackgroundColor3 = CONFIG.GlassLight
    header.BackgroundTransparency = 0.3
    header.Parent = cardContainer

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = header

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

    local tagline = Instance.new("TextLabel")
    tagline.Size = UDim2.new(1, 0, 0.5, 0)
    tagline.Position = UDim2.new(0, 0, 0.5, 0)
    tagline.BackgroundTransparency = 1
    tagline.Text = "Standalone • No External URLs"
    tagline.TextColor3 = Color3.fromRGB(150, 200, 255)
    tagline.TextSize = 12
    tagline.Font = Enum.Font.Gotham
    tagline.TextTransparency = 0.3
    tagline.Parent = titleBg

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -70)
    content.Position = UDim2.new(0, 0, 0, 70)
    content.BackgroundTransparency = 1
    content.Parent = cardContainer

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

    local barContainer = Instance.new("Frame")
    barContainer.Size = UDim2.new(0.7, 0, 0, 8)
    barContainer.Position = UDim2.new(0.15, 0, 0, 75)
    barContainer.BackgroundColor3 = CONFIG.GlassLight
    barContainer.BackgroundTransparency = 0.5
    barContainer.Parent = content

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = barContainer

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = CONFIG.Accent
    fill.BackgroundTransparency = 0
    fill.Parent = barContainer

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.Accent),
        ColorSequenceKeypoint.new(1, CONFIG.AccentAlt)
    })
    fillGradient.Parent = fill

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

    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(1, 0, 0, 15)
    version.Position = UDim2.new(0, 0, 1, -20)
    version.BackgroundTransparency = 1
    version.Text = "v3.0 • Standalone • 2026"
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

-- Embedded GUI Module (simplified version)
function GuiModule:Init()
    -- This is a placeholder - the full GUI will be loaded
    print("✓ RussElite GUI initialized!")
end

-- Loading animation
function Loader:Start(elements)
    local progress = tween(
        elements.Fill,
        { Size = UDim2.new(1, 0, 1, 0) },
        3.5,
        Enum.EasingStyle.Linear
    )

    local messages = {
        "Initializing systems...",
        "Loading core modules...",
        "Preparing interface...",
        "Optimizing performance...",
        "Connecting to RussElite...",
        "Almost ready..."
    }

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

    for i, msg in ipairs(messages) do
        task.delay((i - 1) * 0.58, function()
            if elements.Status then
                elements.Status.Text = msg
            end
        end)
    end

    progress:Play()

    progress.Completed:Connect(function()
        dotAnimation:Disconnect()
        
        elements.Status.Text = "Loading RussElite GUI..."
        elements.Dots.Text = "⏳"
        elements.Dots.TextColor3 = Color3.fromRGB(255, 180, 50)

        task.delay(0.5, function()
            -- Initialize GUI
            GuiModule:Init()
            
            elements.Status.Text = "✓ RussElite Loaded!"
            elements.Dots.Text = "✓"
            elements.Dots.TextColor3 = Color3.fromRGB(100, 200, 100)

            task.delay(0.8, function()
                tween(elements.Card, {BackgroundTransparency = 1}, 0.5)
                tween(elements.Fill, {BackgroundTransparency = 1}, 0.5)
                tween(elements.Status, {TextTransparency = 1}, 0.5)
                tween(elements.Subtitle, {TextTransparency = 1}, 0.5)
                tween(elements.Header, {BackgroundTransparency = 1}, 0.5)
                
                task.delay(0.5, function()
                    pcall(function()
                        elements.Container:Destroy()
                    end)
                end)
            end)
        end)
    end)
end

-- Run
local elements = Loader:CreateLoadingUI()
Loader:Start(elements)

-- LOAD YOUR GUI HERE
-- Replace GuiModule:Init() with actual GUI code or require it
