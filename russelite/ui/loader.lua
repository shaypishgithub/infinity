-- RussElite Imperial Bootstrapper - loader.lua
-- Imperial Russian Glassmorphism Loading Screen (English)

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
    GlassBg = Color3.fromRGB(15, 15, 22),
    GlassStroke = Color3.fromRGB(255, 255, 255),
    Shadow = Color3.fromRGB(0, 0, 0)
}

-- Configuration
local CONFIG = {
    Title = "RussElite",
    Subtitle = "Imperial Hub",
    ScriptURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/ui/gui.lua",
    LoadingDuration = 3
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
local function tween(obj, props, duration)
    local t = TweenService:Create(obj, TweenInfo.new(duration or 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- Apply glass effect
local function applyGlass(frame)
    -- Shadow
    local shadow = Instance.new("ImageLabel")
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
    
    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.GlassStroke
    stroke.Transparency = 0.6
    stroke.Thickness = 1.5
    stroke.Parent = frame
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = frame
    
    return shadow, stroke, corner
end

-- Create Imperial Russian Flag
local function createImperialFlag(parent)
    local flag = Instance.new("Frame")
    flag.Size = UDim2.new(1, 0, 0.4, 0)
    flag.Position = UDim2.new(0, 0, 0.3, 0)
    flag.BackgroundTransparency = 1
    flag.ZIndex = 5
    flag.Parent = parent
    
    -- Black stripe (top)
    local black = Instance.new("Frame")
    black.Size = UDim2.new(1, 0, 1/3, 0)
    black.Position = UDim2.new(0, 0, 0, 0)
    black.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    black.BorderSizePixel = 0
    black.ZIndex = 5
    black.Parent = flag
    
    -- Gold stripe (middle)
    local gold = Instance.new("Frame")
    gold.Size = UDim2.new(1, 0, 1/3, 0)
    gold.Position = UDim2.new(0, 0, 1/3, 0)
    gold.BackgroundColor3 = Color3.fromRGB(218, 165, 32)
    gold.BorderSizePixel = 0
    gold.ZIndex = 5
    gold.Parent = flag
    
    -- White stripe (bottom)
    local white = Instance.new("Frame")
    white.Size = UDim2.new(1, 0, 1/3, 0)
    white.Position = UDim2.new(0, 0, 2/3, 0)
    white.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    white.BorderSizePixel = 0
    white.ZIndex = 5
    white.Parent = flag
    
    -- Imperial Eagle emblem
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

-- Create loading screen
local function CreateLoadingScreen(container)
    -- Black overlay
    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = COLORS.ImperialBlack
    overlay.BackgroundTransparency = 0.3
    overlay.ZIndex = 1
    overlay.Parent = container
    
    -- Floating gold particles
    for i = 1, 25 do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
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
                local floatUp = tween(particle, {
                    Position = UDim2.new(math.random(), 0, math.random() - 0.1, 0),
                    BackgroundTransparency = 0.9
                }, math.random(20, 40) / 10, Enum.EasingStyle.Sine)
                
                task.wait(math.random(20, 40) / 10)
                
                particle.Position = UDim2.new(math.random(), 0, math.random() + 0.1, 0)
                particle.BackgroundTransparency = 0.5
            end
        end)()
    end
    
    -- Main loading card
    local card = Instance.new("Frame")
    card.Name = "LoadingCard"
    card.Size = UDim2.new(0, 380, 0, 280)
    card.Position = UDim2.new(0.5, -190, 0.5, -140)
    card.BackgroundColor3 = COLORS.GlassBg
    card.BackgroundTransparency = 0.2
    card.ZIndex = 10
    card.Parent = container
    
    applyGlass(card)
    
    -- Gold accent line on top
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0.8, 0, 0, 2)
    accent.Position = UDim2.new(0.1, 0, 0, 8)
    accent.BackgroundColor3 = COLORS.ImperialGold
    accent.BackgroundTransparency = 0.3
    accent.BorderSizePixel = 0
    accent.ZIndex = 12
    accent.Parent = card
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(1, 0)
    accentCorner.Parent = accent
    
    -- Imperial Emblem
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
    
    -- Progress bar background
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
    
    -- Status text
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, 0, 0, 20)
    statusText.Position = UDim2.new(0, 0, 0.78, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Loading..."
    statusText.TextColor3 = COLORS.ImperialWhite
    statusText.TextSize = 13
    statusText.Font = Enum.Font.Gotham
    statusText.TextTransparency = 0.4
    statusText.ZIndex = 12
    statusText.Parent = card
    
    -- Bottom imperial motto
    local bottomText = Instance.new("TextLabel")
    bottomText.Size = UDim2.new(1, 0, 0, 20)
    bottomText.Position = UDim2.new(0, 0, 0.87, 0)
    bottomText.BackgroundTransparency = 1
    bottomText.Text = "♛  God With Us  ♛"
    bottomText.TextColor3 = COLORS.ImperialGold
    bottomText.TextSize = 11
    bottomText.Font = Enum.Font.GothamBold
    bottomText.TextTransparency = 0.5
    bottomText.ZIndex = 12
    bottomText.Parent = card
    
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
    spinner.Rotation = 0
    spinner.Parent = card
    
    return {
        Container = container,
        Overlay = overlay,
        Card = card,
        ProgressFill = progressFill,
        StatusText = statusText,
        Title = title,
        Spinner = spinner,
        Emblem = emblem
    }
end

-- Load GUI script
local function LoadGUI()
    local success, result = pcall(function()
        local scriptSource = game:HttpGet(CONFIG.ScriptURL)
        local loadedFunction = loadstring(scriptSource)
        if loadedFunction then
            loadedFunction()
            return true
        end
        return false
    end)
    
    if not success then
        warn("Failed to load GUI:", result)
        return false
    end
    
    return result
end

-- Main initialization
local function Init()
    local container = GetSafeContainer()
    if not container then
        warn("Failed to create container")
        return
    end
    
    local elements = CreateLoadingScreen(container)
    
    -- Spinner rotation animation
    coroutine.wrap(function()
        while elements.Spinner and elements.Spinner.Parent do
            elements.Spinner.Rotation = elements.Spinner.Rotation + 5
            RunService.RenderStepped:Wait()
        end
    end)()
    
    -- Emblem pulse animation
    coroutine.wrap(function()
        while elements.Emblem and elements.Emblem.Parent do
            tween(elements.Emblem, {TextTransparency = 0.5}, 0.8)
            task.wait(0.8)
            tween(elements.Emblem, {TextTransparency = 0}, 0.8)
            task.wait(0.8)
        end
    end)()
    
    -- Progress bar animation
    local progressTween = tween(elements.ProgressFill, {
        Size = UDim2.new(1, 0, 1, 0)
    }, CONFIG.LoadingDuration)
    
    -- Status messages (English)
    local messages = {
        "Awakening the Empire...",
        "Loading modules...",
        "Establishing connection...",
        "Preparing interface...",
        "Imperial Hub is ready!"
    }
    
    for i, msg in ipairs(messages) do
        task.delay((i - 1) * (CONFIG.LoadingDuration / #messages), function()
            if elements.StatusText and elements.StatusText.Parent then
                elements.StatusText.Text = msg
            end
        end)
    end
    
    -- When progress completes
    progressTween.Completed:Connect(function()
        if elements.StatusText and elements.StatusText.Parent then
            elements.StatusText.Text = "Launching Imperial Hub..."
        end
        
        task.wait(0.3)
        
        -- Load GUI
        local guiLoaded = LoadGUI()
        
        if not guiLoaded then
            if elements.StatusText and elements.StatusText.Parent then
                elements.StatusText.Text = "Loading failed!"
                elements.StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
            task.wait(2)
        end
        
        -- Fade out animations
        tween(elements.Card, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 340, 0, 240),
            Position = UDim2.new(0.5, -170, 0.5, -130)
        }, 0.5)
        
        tween(elements.Overlay, {BackgroundTransparency = 1}, 0.6)
        tween(elements.Spinner, {TextTransparency = 1}, 0.3)
        tween(elements.Emblem, {TextTransparency = 1}, 0.3)
        
        task.wait(0.6)
        
        -- Destroy everything
        pcall(function()
            container:Destroy()
        end)
    end)
end

-- Start the Imperial Loading Screen
Init()
