-- RussElite Bootstrapper - loader.lua (iOS 2026 Glass Edition)
local Loader = {}

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- Safe Universal Container
local function GetSafeContainer()
    local sg = Instance.new("ScreenGui")
    sg.Name = "RussEliteLoader"
    sg.ResetOnSpawn = false

    if gethui then
        sg.Parent = gethui()
    else
        local success = pcall(function() sg.Parent = CoreGui end)
        if not success then
            sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        end
    end
    return sg
end

local CONFIG = {
    Title = "RussElite",
    Subtitle = "iOS Glass Edition",
    ScriptURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/ui/gui.lua"
}

function Loader:CreateLoadingUI()
    local container = GetSafeContainer()

    local card = Instance.new("Frame")
    card.Name = "LoadingCard"
    card.Size = UDim2.new(0, 320, 0, 190)
    card.Position = UDim2.new(0.5, -160, 0.5, -95)
    card.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    card.BackgroundTransparency = 0.2
    card.Parent = container

    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 20)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.85
    stroke.Thickness = 1.2
    stroke.Parent = card

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, 0, 0, 30)
    logo.Position = UDim2.new(0, 0, 0, 18)
    logo.BackgroundTransparency = 1
    logo.Text = ""
    logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    logo.TextSize = 26
    logo.Font = Enum.Font.GothamBold
    logo.Parent = card

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = CONFIG.Title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Parent = card

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 18)
    subtitle.Position = UDim2.new(0, 0, 0, 76)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = CONFIG.Subtitle
    subtitle.TextColor3 = Color3.fromRGB(160, 160, 160)
    subtitle.TextSize = 12
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = card

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0.8, 0, 0, 4)
    barBg.Position = UDim2.new(0.1, 0, 0, 118)
    barBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    barBg.BackgroundTransparency = 0.9
    barBg.Parent = card

    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BackgroundTransparency = 0.1
    fill.Parent = barBg

    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 0, 130)
    status.BackgroundTransparency = 1
    status.Text = "Инициализация..."
    status.TextColor3 = Color3.fromRGB(180, 180, 180)
    status.TextSize = 11
    status.Font = Enum.Font.Gotham
    status.TextWrapped = true
    status.Parent = card

    return { Container = container, Card = card, Fill = fill, Status = status }
end

function Loader:Start(elements)
    local anim = TweenService:Create(
        elements.Fill,
        TweenInfo.new(1.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        { Size = UDim2.new(1, 0, 1, 0) }
    )

    elements.Status.Text = "Загрузка скрипта..."
    anim:Play()

    anim.Completed:Connect(function()
        elements.Status.Text = "Запрос к серверу..."
        
        local success, rawScript = pcall(function()
            return game:HttpGet(CONFIG.ScriptURL, true)
        end)

        if not success or not rawScript or rawScript == "" then
            elements.Status.Text = "❌ Ошибка HttpGet! Проверь ссылку."
            elements.Status.TextColor3 = Color3.fromRGB(255, 80, 80)
            return
        end

        elements.Status.Text = "Компиляция..."
        local func, err = loadstring(rawScript)

        if not func then
            elements.Status.Text = "❌ Ошибка синтаксиса GUI!"
            elements.Status.TextColor3 = Color3.fromRGB(255, 80, 80)
            warn("RussElite Compile Error:", err)
            return
        end

        elements.Status.Text = "Запуск интерфейса..."
        local runSuccess, runErr = pcall(func)

        if not runSuccess then
            elements.Status.Text = "❌ Ошибка исполнения!"
            elements.Status.TextColor3 = Color3.fromRGB(255, 80, 80)
            warn("RussElite Runtime Error:", runErr)
            return
        end

        -- Успешный запуск
        TweenService:Create(elements.Card, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.delay(0.3, function()
            elements.Container:Destroy()
        end)
    end)
end

local elements = Loader:CreateLoadingUI()
Loader:Start(elements)
