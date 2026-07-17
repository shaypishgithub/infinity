-- russianempire.ru (Environment Creator)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- 1. Безопасный GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Evoruss_2026"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false
screenGui.Enabled = false -- Скрыт по умолчанию

local ok = pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(screenGui) end
    screenGui.Parent = gethui and gethui() or CoreGui
end)
if not ok then screenGui.Parent = player:WaitForChild("PlayerGui") end

-- 2. Главный Фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 650, 0, 450)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
mainFrame.BackgroundTransparency = 0.12
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

-- 3. Базовые функции 2026 стиля (Будут переданы в gui.ru)
local Env = {}

function Env.MakeRound(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = parent
    return c
end

function Env.MakeNeon(parent, color)
    -- Удаляем старые обводки если есть
    pcall(function() for _,v in ipairs(parent:GetChildren()) do if v:IsA("UIStroke") then v:Destroy() end end end)
    -- Свечение
    local glow = Instance.new("UIStroke")
    glow.Thickness = 6
    glow.Color = color or Color3.fromRGB(0, 240, 255)
    glow.Transparency = 0.75
    glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    glow.Parent = parent
    -- Ядро
    local core = Instance.new("UIStroke")
    core.Thickness = 1.5
    core.Color = color or Color3.fromRGB(0, 240, 255)
    core.Transparency = 0
    core.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    core.Parent = parent
end

function Env.MakeShadow(parent, offset)
    if parent:FindFirstChild("Shadow3D") then parent:FindFirstChild("Shadow3D"):Destroy() end
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow3D"
    shadow.Size = UDim2.new(1, offset or 10, 1, offset or 10)
    shadow.Position = UDim2.new(0, (offset or 10)/2, 0, (offset or 10)/2)
    shadow.BackgroundColor3 = Color3.new(0,0,0)
    shadow.BackgroundTransparency = 0.6
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent.Parent
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 16)
end

function Env.MakeGlass(parent)
    local glass = Instance.new("Frame")
    glass.Name = "GlassEffect"
    glass.BackgroundColor3 = Color3.new(1,1,1)
    glass.BackgroundTransparency = 0.92
    glass.Size = UDim2.new(1, 0, 0.5, 0)
    glass.ZIndex = parent.ZIndex + 1
    glass.ClipsDescendants = true
    glass.Parent = parent
    Instance.new("UICorner", glass).CornerRadius = UDim.new(0, 16)
    
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(0,0,0))
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.4, 0.9),
        NumberSequenceKeypoint.new(1, 1.0)
    })
    grad.Rotation = 90
    grad.Parent = glass
end

-- 4. Цвета
Env.Theme = {
    BgDeep = Color3.fromRGB(8, 8, 12),
    BgPanel = Color3.fromRGB(20, 20, 30),
    Accent = Color3.fromRGB(0, 240, 255),
    AccentSec = Color3.fromRGB(255, 0, 229),
    TextMain = Color3.fromRGB(220, 225, 240),
    TextSub = Color3.fromRGB(120, 125, 150),
}

-- 5. Сервисы
Env.Services = {
    TweenService = TweenService,
    UserInputService = UserInputService,
    RunService = RunService,
    HttpService = HttpService,
    player = player
}

-- 6. Вызов GUI и передача среды
local success, err = pcall(function()
    local guiCode = game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/evoruss/evodetail/gui.ru", true)
    local guiFunc = loadstring(guiCode)
    guiFunc(Env, mainFrame, screenGui)
end)

if not success then
    warn("[EVORUSS] Failed to load GUI: "..tostring(err))
end
