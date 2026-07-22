-- RussElite Bootstrapper - loader.lua
-- Black aesthetic loading screen 

local Loader = {}

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Safe container
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
    Subtitle = "Loading...",
    TextColor = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(180, 180, 180),      -- grey accent
    Background = Color3.fromRGB(0, 0, 0),
    Glass = Color3.fromRGB(10, 10, 10),
    ScriptURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/ui/gui.lua"
}

function Loader:CreateLoadingUI()
    local container = GetSafeContainer()

    -- Background overlay (black)
    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = CONFIG.Background
    bg.BackgroundTransparency = 0.3
    bg.Parent = container

    -- Loading card (dark glass)
    local card = Instance.new("Frame")
    card.Name = "LoadingCard"
    card.Size = UDim2.new(0, 300, 0, 180)
    card.Position = UDim2.new(0.5, -150, 0.5, -90)
    card.BackgroundColor3 = CONFIG.Glass
    card.BackgroundTransparency = 0.15
    card.Parent = container

    -- Card border (thin dark stroke)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Transparency = 0.5
    stroke.Thickness = 1
    stroke.Parent = card

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = card

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = CONFIG.Title
    title.TextColor3 = CONFIG.TextColor
    title.TextSize = 28
    title.Font = Enum.Font.GothamBold
    title.Parent = card

    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 65)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = CONFIG.Subtitle
    subtitle.TextColor3 = CONFIG.TextColor
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextTransparency = 0.4
    subtitle.Parent = card

    -- Progress bar background
    local barBg = Instance.new("Frame")
    barBg.Name = "BarBg"
    barBg.Size = UDim2.new(0.8, 0, 0, 6)
    barBg.Position = UDim2.new(0.1, 0, 0, 105)
    barBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    barBg.BackgroundTransparency = 0.9
    barBg.Parent = card

    local barBgCorner = Instance.new("UICorner")
    barBgCorner.CornerRadius = UDim.new(1, 0)
    barBgCorner.Parent = barBg

    -- Progress fill
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = CONFIG.Accent
    fill.BackgroundTransparency = 0.2
    fill.Parent = barBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    -- Status text
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0, 125)
    status.BackgroundTransparency = 1
    status.Text = "Initializing..."
    status.TextColor3 = CONFIG.TextColor
    status.TextSize = 12
    status.Font = Enum.Font.Gotham
    status.TextTransparency = 0.5
    status.Parent = card

    return {
        Container = container,
        Card = card,
        Fill = fill,
        Status = status
    }
end

function Loader:Start(elements)
    local progress = TweenService:Create(
        elements.Fill,
        TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        { Size = UDim2.new(1, 0, 1, 0) }
    )

    local messages = {
        "Initializing systems...",
        "Loading modules...",
        "Preparing interface...",
        "Almost ready..."
    }
    for i, msg in ipairs(messages) do
        task.delay((i - 1) * 0.6, function()
            if elements.Status then
                elements.Status.Text = msg
            end
        end)
    end

    progress:Play()
    progress.Completed:Connect(function()
        elements.Status.Text = "Launching..."
        -- Load main script
        local ok, err = pcall(function()
            local scriptSource = game:HttpGet(CONFIG.ScriptURL)
            local f = loadstring(scriptSource)
            if f then f() end
        end)
        if not ok then
            warn("RussElite loader error:", err)
        end

        -- Force remove loader after a short delay
        task.delay(0.2, function()
            elements.Container:Destroy()
        end)
    end)
end

-- Run
local elements = Loader:CreateLoadingUI()
Loader:Start(elements)
