-- RussElite Bootstrapper - loader.lua
-- Futuristic Glassmorphism Loading Screen

local Loader = {}

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local CONFIG = {
    Title = "RussElite",
    Subtitle = "Loading Experience...",
    PrimaryColor = Color3.fromRGB(255, 255, 255),
    AccentColor = Color3.fromRGB(100, 180, 255),
    BackgroundTransparency = 0.85,
    GlassBackground = Color3.fromRGB(20, 20, 30),
    LoadingTime = 2.5,
    ScriptURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/ui/gui.lua"
}

-- Safe parent container
local function GetSafeContainer()
    local success, result = pcall(function()
        local coreGui = Instance.new("ScreenGui")
        coreGui.Name = "RussEliteLoader"
        coreGui.Parent = CoreGui
        return coreGui
    end)
    
    if not success then
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "RussEliteLoader"
        screenGui.Parent = playerGui
        return screenGui
    end
    
    return result
end

-- Create loading UI
function Loader:CreateLoadingUI()
    local container = GetSafeContainer()
    
    -- Main background overlay
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.6
    background.Parent = container
    
    -- Loading card
    local loadingCard = Instance.new("Frame")
    loadingCard.Name = "LoadingCard"
    loadingCard.Size = UDim2.new(0, 350, 0, 220)
    loadingCard.Position = UDim2.new(0.5, -175, 0.5, -110)
    loadingCard.BackgroundColor3 = CONFIG.GlassBackground
    loadingCard.BackgroundTransparency = CONFIG.BackgroundTransparency
    loadingCard.Parent = container
    
    -- Glass effect border
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Name = "CardStroke"
    cardStroke.Color = Color3.fromRGB(255, 255, 255)
    cardStroke.Transparency = 0.7
    cardStroke.Thickness = 1.5
    cardStroke.Parent = loadingCard
    
    -- Corner rounding
    local cardCorner = Instance.new("UICorner")
    cardCorner.Name = "CardCorner"
    cardCorner.CornerRadius = UDim.new(0, 16)
    cardCorner.Parent = loadingCard
    
    -- Drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 49, 49)
    shadow.Parent = loadingCard
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = CONFIG.Title
    title.TextColor3 = CONFIG.PrimaryColor
    title.TextSize = 32
    title.Font = Enum.Font.GothamBold
    title.TextTransparency = 0
    title.Parent = loadingCard
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 75)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = CONFIG.Subtitle
    subtitle.TextColor3 = CONFIG.PrimaryColor
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextTransparency = 0.3
    subtitle.Parent = loadingCard
    
    -- Progress bar background
    local progressBarBg = Instance.new("Frame")
    progressBarBg.Name = "ProgressBarBg"
    progressBarBg.Size = UDim2.new(0.8, 0, 0, 6)
    progressBarBg.Position = UDim2.new(0.1, 0, 0, 120)
    progressBarBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    progressBarBg.BackgroundTransparency = 0.85
    progressBarBg.Parent = loadingCard
    
    local progressBarBgCorner = Instance.new("UICorner")
    progressBarBgCorner.CornerRadius = UDim.new(1, 0)
    progressBarBgCorner.Parent = progressBarBg
    
    -- Progress bar fill
    local progressBarFill = Instance.new("Frame")
    progressBarFill.Name = "ProgressBarFill"
    progressBarFill.Size = UDim2.new(0, 0, 1, 0)
    progressBarFill.BackgroundColor3 = CONFIG.AccentColor
    progressBarFill.BackgroundTransparency = 0.2
    progressBarFill.Parent = progressBarBg
    
    local progressBarFillCorner = Instance.new("UICorner")
    progressBarFillCorner.CornerRadius = UDim.new(1, 0)
    progressBarFillCorner.Parent = progressBarFill
    
    -- Status text
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, 0, 0, 20)
    statusText.Position = UDim2.new(0, 0, 0, 140)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Initializing..."
    statusText.TextColor3 = CONFIG.PrimaryColor
    statusText.TextSize = 12
    statusText.Font = Enum.Font.Gotham
    statusText.TextTransparency = 0.5
    statusText.Parent = loadingCard
    
    -- Glow effect on progress bar
    local progressGlow = Instance.new("UIGradient")
    progressGlow.Name = "ProgressGlow"
    progressGlow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.AccentColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 220, 255))
    })
    progressGlow.Parent = progressBarFill
    
    return {
        Container = container,
        Card = loadingCard,
        ProgressBar = progressBarFill,
        StatusText = statusText,
        Title = title,
        Subtitle = subtitle
    }
end

-- Animate progress
function Loader:AnimateProgress(elements, callback)
    local progressTween = TweenService:Create(
        elements.ProgressBar,
        TweenInfo.new(CONFIG.LoadingTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        {Size = UDim2.new(1, 0, 1, 0)}
    )
    
    local statusMessages = {
        "Initializing systems...",
        "Loading modules...",
        "Establishing connection...",
        "Preparing interface...",
        "Almost ready..."
    }
    
    local currentMessage = 1
    local messageInterval = CONFIG.LoadingTime / #statusMessages
    
    for i = 1, #statusMessages do
        task.delay(messageInterval * (i - 1), function()
            elements.StatusText.Text = statusMessages[i]
        end)
    end
    
    progressTween:Play()
    
    progressTween.Completed:Connect(function()
        elements.StatusText.Text = "Complete!"
        task.wait(0.3)
        callback()
    end)
end

-- Fade out and cleanup
function Loader:FadeOut(elements, callback)
    local fadeTween = TweenService:Create(
        elements.Container,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1}
    )
    
    local cardFadeTween = TweenService:Create(
        elements.Card,
        TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1, Position = UDim2.new(0.5, -175, 0.5, -130)}
    )
    
    fadeTween:Play()
    cardFadeTween:Play()
    
    cardFadeTween.Completed:Connect(function()
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
            elements.StatusText.Text = "Error loading script!"
            elements.StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
            warn("RussElite Loader Error:", result)
        end
        
        -- Fade out loader
        Loader:FadeOut(elements)
    end)
end

-- Run
Init()
