--[[
    Nude Mod v2 – Автономный скрипт для обнажения персонажа
    Не требует внешних файлов, работает на любом исполнителе.
    GUI – стильная кнопка с анимацией.
--]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Настройки (можно менять)
local HOTKEY = Enum.KeyCode.U
local ENABLE_HOTKEY = true
local MANUAL_SKIN_COLOR = nil  -- укажи свой цвет, например Color3.fromRGB(255,200,150)

-- Глобальные переменные
local isActive = false
local originalClothing = {}  -- сохранённая одежда
local fakeBodyParts = {}      -- созданные голые части

-- Функция получения цвета кожи (из BodyColors или стандарт)
local function getSkinColor(character)
    if MANUAL_SKIN_COLOR then return MANUAL_SKIN_COLOR end
    local bodyColors = character:FindFirstChildOfClass("BodyColors")
    if bodyColors then
        return bodyColors.TorsoColor3 or Color3.fromRGB(255,204,153)
    end
    return Color3.fromRGB(255,204,153) -- стандартный светлый
end

-- Создать голые части тела (упрощённые, под R6)
local function createNudeBody(character)
    local parts = {}
    local skinColor = getSkinColor(character)
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if not torso then return end

    -- Позиции для R6
    local pos = {
        Torso    = CFrame.new(0,0,0),
        Head     = CFrame.new(0,1.5,0),
        LeftArm  = CFrame.new(-1.5,0,0),
        RightArm = CFrame.new(1.5,0,0),
        LeftLeg  = CFrame.new(-0.6,-1.5,0),
        RightLeg = CFrame.new(0.6,-1.5,0)
    }
    local sizes = {
        Torso    = Vector3.new(2,2,1),
        Head     = Vector3.new(2,1.5,1),
        LeftArm  = Vector3.new(1,2,1),
        RightArm = Vector3.new(1,2,1),
        LeftLeg  = Vector3.new(1,2,1),
        RightLeg = Vector3.new(1,2,1)
    }

    for name, offset in pairs(pos) do
        local part = Instance.new("Part")
        part.Name = name.."_Nude"
        part.Size = sizes[name]
        part.Color = skinColor
        part.Material = Enum.Material.SmoothPlastic
        part.CanCollide = false
        part.Anchored = false
        part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
        part.Parent = character

        local weld = Instance.new("Weld")
        weld.Part0 = torso
        weld.Part1 = part
        weld.C0 = offset
        weld.Parent = part

        table.insert(parts, part)
    end

    -- Меш для головы (чтобы был круглый)
    local head = character:FindFirstChild("Head_Nude")
    if head then
        local mesh = Instance.new("SpecialMesh", head)
        mesh.MeshType = Enum.MeshType.Head
        mesh.Scale = Vector3.new(1.25,1.25,1.25)
    end

    return parts
end

-- Удалить голые части
local function clearNudeBody()
    for _, part in ipairs(fakeBodyParts) do
        if part and part.Parent then pcall(part.Destroy, part) end
    end
    fakeBodyParts = {}
end

-- Удалить одежду и аксессуары (с сохранением)
local function removeClothing(character)
    originalClothing = {}
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") or child:IsA("Accessory") then
            table.insert(originalClothing, child)
        end
    end
    for _, item in ipairs(originalClothing) do
        item:Destroy()
    end
end

-- Восстановить одежду
local function restoreClothing(character)
    for _, item in ipairs(originalClothing) do
        item.Parent = character
    end
    originalClothing = {}
    clearNudeBody()
end

-- Переключить режим
local function toggle()
    local character = Player.Character
    if not character then return end

    isActive = not isActive
    if isActive then
        removeClothing(character)
        fakeBodyParts = createNudeBody(character)
        button.ImageColor3 = Color3.fromRGB(255,160,160)
        button.BackgroundColor3 = Color3.fromRGB(80,40,40)
    else
        restoreClothing(character)
        button.ImageColor3 = Color3.fromRGB(255,255,255)
        button.BackgroundColor3 = Color3.fromRGB(30,30,40)
    end
end

-- GUI – круглая кнопка с современным видом
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NudeModGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
-- Защита для некоторых экзекьюторов
if syn and syn.protect_gui then syn.protect_gui(screenGui) end
screenGui.Parent = game:GetService("CoreGui")

local button = Instance.new("ImageButton")
button.Size = UDim2.new(0, 65, 0, 65)
button.Position = UDim2.new(1, -85, 1, -85)
button.AnchorPoint = Vector2.new(1, 1)
button.BackgroundColor3 = Color3.fromRGB(30,30,40)
button.BackgroundTransparency = 0.15
button.Image = "rbxassetid://6026567605"  -- простая круглая иконка
button.ImageColor3 = Color3.fromRGB(255,255,255)
button.ImageTransparency = 0.1
button.BorderSizePixel = 0

-- Скругление и тень
local corner = Instance.new("UICorner", button)
corner.CornerRadius = UDim.new(1,0)

local shadow = Instance.new("UIShadow", button)
shadow.Color = Color3.fromRGB(0,0,0)
shadow.Offset = Vector2.new(0,2)
shadow.BlurRadius = 8

-- Анимации
local hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0})
local leaveTween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.15})

button.MouseEnter:Connect(function() hoverTween:Play() end)
button.MouseLeave:Connect(function() leaveTween:Play() end)
button.MouseButton1Click:Connect(toggle)

button.Parent = screenGui

-- Горячая клавиша
if ENABLE_HOTKEY then
    UIS.InputBegan:Connect(function(input, processed)
        if processed or not isActive then return end
        if input.KeyCode == HOTKEY then
            toggle()
        end
    end)
end

-- Обработка респавна
local function onCharacterAdded(character)
    task.wait(0.3)
    if isActive then
        removeClothing(character)
        clearNudeBody()
        fakeBodyParts = createNudeBody(character)
    end
end

Player.CharacterAdded:Connect(onCharacterAdded)
if Player.Character then onCharacterAdded(Player.Character) end
