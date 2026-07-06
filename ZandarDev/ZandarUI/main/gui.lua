-- Загрузка интерфейса ZandarUI v3
local ZandarUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/ZandarDev/ZandarUI/main/ZandarUI.lua"))()

local Window = ZandarUI.new({
    Title       = "Zandar UI",
    Subtitle    = "v3.0.1 - Fixed",
    ToggleKey   = Enum.KeyCode.RightShift,
})

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Переменные состояния
local _G = _G or {}
_G.ESP_Enabled = false
_G.Hat_Enabled = false

local SelectedPlayerName = nil
local Spectating = false

-- Скорость и Fly конфигурация
local TargetSpeed = 16
local FlyEnabled = false
local FlySpeed = 50

-- Объекты физики для Fly
local FlyVelocity = nil
local FlyGyro = nil

-- Таблицы для хранения эффектов
local ActiveESP = {}

-- === ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ===

local function GetPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    if #names == 0 then table.insert(names, "No players found") end
    return names
end

local function RemoveESP(player)
    if ActiveESP[player] then
        if ActiveESP[player].Highlight then ActiveESP[player].Highlight:Destroy() end
        if ActiveESP[player].Billboard then ActiveESP[player].Billboard:Destroy() end
        if ActiveESP[player].Connection then ActiveESP[player].Connection:Disconnect() end
        ActiveESP[player] = nil
    end
end

local function CreateESP(player)
    if player == LocalPlayer or not _G.ESP_Enabled then return end
    RemoveESP(player)
    
    local char = player.Character
    if not char then return end
    
    local root = char:WaitForChild("HumanoidRootPart", 5)
    local head = char:WaitForChild("Head", 5)
    if not root or not head then return end

    local espData = {}
    local highlight = Instance.new("Highlight")
    highlight.Name = "ZandarESP"; highlight.FillTransparency = 1; highlight.OutlineTransparency = 0
    highlight.Adornee = char; highlight.Parent = char; espData.Highlight = highlight

    local bgui = Instance.new("BillboardGui")
    bgui.Name = "ZandarESPText"; bgui.Size = UDim2.new(0, 200, 0, 50)
    bgui.StudsOffset = Vector3.new(0, 3, 0); bgui.AlwaysOnTop = true; bgui.Adornee = head; bgui.Parent = char
    espData.Billboard = bgui

    local textLabel = Instance.new("TextLabel", bgui)
    textLabel.Size = UDim2.new(1, 0, 1, 0); textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold; textLabel.TextSize = 16; textLabel.TextStrokeTransparency = 0.5

    espData.Connection = RunService.RenderStepped:Connect(function()
        if not char.Parent or not root.Parent or not _G.ESP_Enabled then
            RemoveESP(player)
            return
        end
        local wave = (math.sin(tick() * 2.5) + 1) / 2
        local monoColor = Color3.new(wave, wave, wave)
        highlight.OutlineColor = monoColor
        textLabel.TextColor3 = monoColor
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local dist = math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
            textLabel.Text = string.format("%s [%d m]", player.Name, dist)
        else
            textLabel.Text = player.Name
        end
    end)
    ActiveESP[player] = espData
end

local function RemoveHatEffects(char)
    if not char then return end
    for _, name in ipairs({"ZandarHat", "ZandarAura", "ZandarName"}) do
        local old = char:FindFirstChild(name)
        if old then old:Destroy() end
    end
end

local function CreateHatEffects(char)
    if not char or not _G.Hat_Enabled then return end
    RemoveHatEffects(char)
    local head = char:WaitForChild("Head", 5)
    if not head then return end

    local hatPart = Instance.new("Part")
    hatPart.Name = "ZandarHat"; hatPart.Size = Vector3.new(1, 0.4, 1)
    hatPart.CanCollide = false; hatPart.Massless = true; hatPart.Material = Enum.Material.SmoothPlastic; hatPart.Parent = char

    local mesh = Instance.new("SpecialMesh", hatPart)
    mesh.MeshType = Enum.MeshType.FileMesh; mesh.MeshId = "rbxassetid://1033714"; mesh.Scale = Vector3.new(1.7, 1.1, 1.7)

    local weld = Instance.new("Weld", hatPart)
    weld.Part0 = hatPart; weld.Part1 = head; weld.C0 = CFrame.new(0, -1.15, 0)

    local bgui = Instance.new("BillboardGui")
    bgui.Name = "ZandarName"; bgui.Parent = char; bgui.Adornee = head
    bgui.Size = UDim2.new(0, 200, 0, 50); bgui.StudsOffset = Vector3.new(0, 3.5, 0); bgui.AlwaysOnTop = true

    local nameLabel = Instance.new("TextLabel", bgui)
    nameLabel.Size = UDim2.new(1, 0, 1, 0); nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "vertelevsepoel"; nameLabel.Font = Enum.Font.GothamBold; nameLabel.TextSize = 25; nameLabel.TextStrokeTransparency = 0.5

    local highlight = Instance.new("Highlight")
    highlight.Name = "ZandarAura"; highlight.FillTransparency = 1; highlight.OutlineTransparency = 0; highlight.Adornee = char; highlight.Parent = char

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not char.Parent or not hatPart.Parent or not _G.Hat_Enabled then
            connection:Disconnect()
            RemoveHatEffects(char)
            return
        end
        local wave = (math.sin(tick() * 2.5) + 1) / 2
        local color = Color3.new(wave, wave, wave)
        hatPart.Color = color
        highlight.OutlineColor = color
        nameLabel.TextColor3 = color
        nameLabel.TextStrokeColor3 = Color3.new(1 - wave, 1 - wave, 1 - wave)
    end)
end

-- === ИНИЦИАЛИЗАЦИЯ ИНТЕРФЕЙСА ===

local MainTab = Window:AddTab("Main")
MainTab:AddSection("Speed Modifiers")

local SpeedSlider = MainTab:AddSlider("WalkSpeed", {Min=16, Max=500, Default=16, Suffix=" stud/s"}, function(v)
    TargetSpeed = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)

local SpeedBox = MainTab:AddTextBox("Custom Speed", "Enter exact speed...", function(text)
    local num = tonumber(text)
    if num then
        TargetSpeed = num
        SpeedSlider:Set(math.clamp(num, 16, 500))
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = num
        end
    end
end)

MainTab:AddSection("Flight Control (Fly)")

MainTab:AddToggle("Fly Mode", false, function(state)
    FlyEnabled = state
    if not state then
        if FlyVelocity then FlyVelocity:Destroy(); FlyVelocity = nil end
        if FlyGyro then FlyGyro:Destroy(); FlyGyro = nil end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.PlatformStand = false
        end
    end
end)

MainTab:AddSlider("Fly Speed", {Min=10, Max=300, Default=50, Suffix=" studs"}, function(v)
    FlySpeed = v
end)

MainTab:AddSection("Visuals")

MainTab:AddToggle("Conical Hat (vertelevsepoel)", false, function(state)
    _G.Hat_Enabled = state
    if state and LocalPlayer.Character then CreateHatEffects(LocalPlayer.Character) else RemoveHatEffects(LocalPlayer.Character) end
end)

local PlayersTab = Window:AddTab("Players")
PlayersTab:AddSection("Visuals")

PlayersTab:AddToggle("Player ESP (Mono)", false, function(state)
    _G.ESP_Enabled = state
    if state then
        for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
    else
        for p, _ in pairs(ActiveESP) do RemoveESP(p) end
    end
end)

PlayersTab:AddSection("Target Control")
local PlayerDropdown = PlayersTab:AddDropdown("Select Target", GetPlayerNames(), function(v)
    SelectedPlayerName = v
end)

PlayersTab:AddButton("Teleport to Target", function()
    if not SelectedPlayerName then return end
    local target = Players:FindFirstChild(SelectedPlayerName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
        end
    end
end)

local SpectateToggle
SpectateToggle = PlayersTab:AddToggle("Spectate Target", false, function(state)
    Spectating = state
end)

-- === ОСНОВНАЯ ЛОГИКА ===

-- 1. Цикл жесткого обновления WalkSpeed и контроля Спектатора
RunService.RenderStepped:Connect(function()
    -- Анти-ресет скорости
    if not FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = TargetSpeed
    end

    -- Стабильный спектатор без багов переспавна
    if Spectating and SelectedPlayerName then
        local target = Players:FindFirstChild(SelectedPlayerName)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = target.Character.Humanoid
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                Camera.CameraSubject = LocalPlayer.Character.Humanoid
            end
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and Camera.CameraSubject ~= LocalPlayer.Character.Humanoid then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end
end)

-- 2. Физический скованный Fly (без задержек камеры, жесткая стабилизация)
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not root or not humanoid then return end

    if FlyEnabled then
        humanoid.PlatformStand = true
        
        -- Инициализация жестких гироскопов, если их нет
        if not FlyVelocity or FlyVelocity.Parent ~= root then
            if FlyVelocity then FlyVelocity:Destroy() end
            FlyVelocity = Instance.new("BodyVelocity")
            FlyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            FlyVelocity.Velocity = Vector3.zero
            FlyVelocity.Parent = root
        end
        
        if not FlyGyro or FlyGyro.Parent ~= root then
            if FlyGyro then FlyGyro:Destroy() end
            FlyGyro = Instance.new("BodyGyro")
            FlyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            FlyGyro.CFrame = Camera.CFrame
            FlyGyro.Parent = root
        end

        -- Жестко заставляем персонажа смотреть туда, куда смотрит камера
        FlyGyro.CFrame = Camera.CFrame

        -- Движение
        local moveDirection = humanoid.MoveDirection
        if moveDirection.Magnitude > 0 then
            local localMove = root.CFrame:VectorToObjectSpace(moveDirection)
            local flightDirection = (Camera.CFrame.LookVector * -localMove.Z + Camera.CFrame.RightVector * localMove.X).Unit
            FlyVelocity.Velocity = flightDirection * FlySpeed
        else
            FlyVelocity.Velocity = Vector3.zero
        end
    end
end)

-- Авто-обновление ESP при переспавнах (для ВСЕХ игроков)
local function HookPlayer(player)
    player.CharacterAdded:Connect(function(char)
        if _G.ESP_Enabled then
            task.wait(0.5)
            CreateESP(player)
        end
    end)
    player.CharacterRemoving:Connect(function()
        RemoveESP(player)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do HookPlayer(p) end
Players.PlayerAdded:Connect(HookPlayer)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
    if SelectedPlayerName == player.Name then
        SelectedPlayerName = nil
    end
end)

-- Авто-обновление списка в дропдауне
task.spawn(function()
    while task.wait(3) do
        pcall(function() PlayerDropdown:Refresh(GetPlayerNames(), true) end)
    end
end)

Window:Notify({
    Title   = "Zandar UI",
    Message = "All systems fixed and optimized!",
    Type    = "Success",
    Duration = 4,
})
