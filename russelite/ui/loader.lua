-- RussElite Bootstrapper - loader.lua (iPhone Glass Loading Screen)
local Loader = {}

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

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

local CONFIG = {
    Title = "RussElite",
    Subtitle = "iOS Glass Edition 2026",
    TextColor = Color3.fromRGB(255, 255, 255),
    SecondaryText = Color3.fromRGB(160, 160, 160),
    Glass = Color3.fromRGB(15, 15, 15),
    StrokeColor = Color3.fromRGB(255, 255, 255),
    ScriptURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/ui/gui.lua"
}

function Loader:CreateLoadingUI()
    local container = GetSafeContainer()

    -- Glass Loading Card
    local card = Instance.new("Frame")
    card.Name = "LoadingCard"
    card.Size = UDim2.new(0, 320, 0, 190)
    card.Position = UDim2.new(0.5, -160, 0.5, -95)
    card.BackgroundColor3 = CONFIG.Glass
    card.BackgroundTransparency = 0.2
    card.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.StrokeColor
    stroke.Transparency = 0.85
    stroke.Thickness = 1.2
    stroke.Parent = card

    -- Apple Icon / Logo Accent
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, 0, 0, 30)
    logo.Position = UDim2.new(0, 0, 0, 20)
    logo.BackgroundTransparency = 1
    logo.Text = ""
    logo.TextColor3 = CONFIG.TextColor
    logo.TextSize = 26
    logo.Font = Enum.Font.GothamBold
    logo.Parent = card

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 52)
    title.BackgroundTransparency = 1
    title.Text = CONFIG.Title
    title.TextColor3 = CONFIG.TextColor
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Parent = card

    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 18)
    subtitle.Position = UDim2.new(0, 0, 0, 78)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = CONFIG.Subtitle
    subtitle.TextColor3 = CONFIG.SecondaryText
    subtitle.TextSize = 12
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = card

    -- Progress Bar Background
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0.8, 0, 0, 4)
    barBg.Position = UDim2.new(0.1, 0, 0, 118)
    barBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    barBg.BackgroundTransparency = 0.9
    barBg.Parent = card

    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    -- Progress Fill
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = CONFIG.TextColor
    fill.BackgroundTransparency = 0.1
    fill.Parent = barBg

    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    -- Status Text
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0, 134)
    status.BackgroundTransparency = 1
    status.Text = "Инициализация..."
    status.TextColor3 = CONFIG.SecondaryText
    status.TextSize = 11
    status.Font = Enum.Font.Gotham
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
        TweenInfo.new(2.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        { Size = UDim2.new(1, 0, 1, 0) }
    )

    local steps = {
        "Подключение к серверу...",
        "Загрузка конфигурации...",
        "Подготовка интерфейса...",
        "Запуск RussElite..."
    }

    for i, msg in ipairs(steps) do
        task.delay((i - 1) * 0.5, function()
            if elements.Status then elements.Status.Text = msg end
        end)
    end

    progress:Play()
    progress.Completed:Connect(function()
        local ok, err = pcall(function()
            local scriptSource = game:HttpGet(CONFIG.ScriptURL)
            local f = loadstring(scriptSource)
            if f then f() end
        end)
        
        if not ok then warn("RussElite Bootstrapper Error:", err) end

        TweenService:Create(elements.Card, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.delay(0.3, function()
            elements.Container:Destroy()
        end)
    end)
end

local elements = Loader:CreateLoadingUI()
Loader:Start(elements)
