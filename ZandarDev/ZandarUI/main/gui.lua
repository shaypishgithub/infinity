-- Загрузка интерфейса ZandarUI
local ZandarUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/ZandarDev/ZandarUI/main/ZandarUI.lua"))()

local Window = ZandarUI.new({
    Title       = "Zandar UI",
    Subtitle    = "v1.0",
    ToggleKey   = Enum.KeyCode.RightShift,
})

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Переменные состояния
local _G = _G or {}
_G.ESP_Enabled = false
_G.Hat_Enabled = false
_G.FlyEnabled = false
_G.SpeedValue = 16

local SelectedPlayer = nil
local Spectating = false
local FlySpeed = 50

-- Таблицы для хранения эффектов
local ActiveESP = {}
local SpectateConnection = nil

-- ============================================
--               ФУНКЦИИ ПОЛЕТА
-- ============================================

local flyConnection = nil
local flyVelocity = nil
local flyGyro = nil

local function StartFly(speed)
    if flyConnection then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    
    -- Сохраняем оригинальные значения
    hum.PlatformStand = false
    
    -- Создаем LinearVelocity (современный аналог BodyVelocity)
    local success, err = pcall(function()
        flyVelocity = Instance.new("LinearVelocity")
        flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyVelocity.Attachment0 = root:FindFirstChild("FlyAttachment") or Instance.new("Attachment", root)
        flyVelocity.Attachment0.Name = "FlyAttachment"
        flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
        flyVelocity.Parent = root
        
        -- Gyro для стабилизации
        flyGyro = Instance.new("AlignOrientation")
        flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyGyro.Attachment0 = root:FindFirstChild("FlyAttachment")
        flyGyro.CFrame = Workspace.CurrentCamera.CFrame
        flyGyro.Mode = Enum.OrientationAlignmentMode.OneAttachment
        flyGyro.Parent = root
    end)
    
    -- Fallback на BodyVelocity если LinearVelocity не работает
    if not success then
        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyVelocity.Parent = root
        
        flyGyro = Instance.new("BodyGyro")
        flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyGyro.P = 9e4
        flyGyro.CFrame = Workspace.CurrentCamera.CFrame
        flyGyro.Parent = root
    end
    
    -- Подключаем обновление полета
    flyConnection = RunService.RenderStepped:Connect(function()
        if not _G.FlyEnabled or not LocalPlayer.Character then
            StopFly()
            return
        end
        
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            StopFly()
            return
        end
        
        local camera = Workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)
        
        -- Получаем направление камеры
        local cf = camera.CFrame
        local forward = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z).Unit
        local right = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z).Unit
        
        -- Управление WASD
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + forward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - forward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        -- Нормализуем и применяем скорость
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * speed
        end
        
        -- Применяем скорость
        if flyVelocity then
            if flyVelocity:IsA("LinearVelocity") then
                flyVelocity.Velocity = moveDirection
            else
                flyVelocity.Velocity = moveDirection
            end
        end
        
        -- Обновляем ориентацию
        if flyGyro then
            if flyGyro:IsA("AlignOrientation") then
                flyGyro.CFrame = cf
            else
                flyGyro.CFrame = cf
            end
        end
    end)
end

local function StopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    if flyVelocity then
        flyVelocity:Destroy()
        flyVelocity = nil
    end
    
    if flyGyro then
        flyGyro:Destroy()
        flyGyro = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
        local attachment = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("FlyAttachment")
        if attachment then attachment:Destroy() end
    end
end

-- ============================================
--           ФУНКЦИЯ СКОРОСТИ ХОДЬБЫ
-- ============================================

local function UpdateWalkSpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        if hum.WalkSpeed ~= _G.SpeedValue then
            hum.WalkSpeed = _G.SpeedValue
        end
    end
end

-- Авто-обновление скорости
task.spawn(function()
    while task.wait(0.5) do
        pcall(UpdateWalkSpeed)
    end
end)

-- ============================================
--         СПИСОК ИГРОКОВ ДЛЯ DROPDOWN
-- ============================================

local function GetPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            table.insert(names, p.Name)
        end
    end
    if #names == 0 then table.insert(names, "No players found") end
    return names
end

-- ============================================
--                 ESP ФУНКЦИИ
-- ============================================

local function RemoveESP(player)
    if ActiveESP[player] then
        if ActiveESP[player].Highlight then ActiveESP[player].Highlight:Destroy() end
        if ActiveESP[player].Billboard then ActiveESP[player].Billboard:Destroy() end
        if ActiveESP[player].Connection then ActiveESP[player].Connection:Disconnect() end
        ActiveESP[player] = nil
    end
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    RemoveESP(player)

    local char = player.Character
    if not char then return end
    local root = char:WaitForChild("HumanoidRootPart", 5)
    local head = char:WaitForChild("Head", 5)
    if not root or not head then return end

    local espData = {}

    -- Обводка
    local highlight = Instance.new("Highlight")
    highlight.Name = "ZandarESP"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.Adornee = char
    highlight.Parent = char
    espData.Highlight = highlight

    -- Текст
    local bgui = Instance.new("BillboardGui")
    bgui.Name = "ZandarESPText"
    bgui.Size = UDim2.new(0, 200, 0, 50)
    bgui.StudsOffset = Vector3.new(0, 3, 0)
    bgui.AlwaysOnTop = true
    bgui.Adornee = head
    bgui.Parent = char
    espData.Billboard = bgui

    local textLabel = Instance.new("TextLabel", bgui)
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 16
    textLabel.TextStrokeTransparency = 0.5

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

-- ============================================
--           ЭФФЕКТЫ ШЛЯПЫ И НИКА
-- ============================================

local function RemoveHatEffects(char)
    if not char then return end
    local oldObjects = {"ZandarHat", "ZandarAura", "ZandarName"}
    for _, name in ipairs(oldObjects) do
        local old = char:FindFirstChild(name)
        if old then old:Destroy() end
    end
end

local function CreateHatEffects(char)
    if not char or not _G.Hat_Enabled then return end
    RemoveHatEffects(char)

    local head = char:WaitForChild("Head", 5)
    if not head then return end

    -- Шляпа
    local hatPart = Instance.new("Part")
    hatPart.Name = "ZandarHat"
    hatPart.Size = Vector3.new(1, 0.4, 1)
    hatPart.CanCollide = false
    hatPart.Massless = true
    hatPart.Material = Enum.Material.SmoothPlastic
    hatPart.Parent = char

    local mesh = Instance.new("SpecialMesh", hatPart)
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1033714"
    mesh.Scale = Vector3.new(1.7, 1.1, 1.7)

    local weld = Instance.new("Weld", hatPart)
    weld.Part0 = hatPart
    weld.Part1 = head
    weld.C0 = CFrame.new(0, -1.15, 0)

    -- Ник
    local bgui = Instance.new("BillboardGui")
    bgui.Name = "ZandarName"
    bgui.Parent = char
    bgui.Adornee = head
    bgui.Size = UDim2.new(0, 200, 0, 50)
    bgui.StudsOffset = Vector3.new(0, 3.5, 0)
    bgui.AlwaysOnTop = true

    local nameLabel = Instance.new("TextLabel", bgui)
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "vertelevsepoel"
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 25
    nameLabel.TextStrokeTransparency = 0.5

    -- Аура
    local highlight = Instance.new("Highlight")
    highlight.Name = "ZandarAura"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.Adornee = char
    highlight.Parent = char

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not char.Parent or not hatPart.Parent or not _G.Hat_Enabled then
            if connection then connection:Disconnect() end
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

-- ============================================
--           СПЕКТАТОР ФУНКЦИИ
-- ============================================

local function StartSpectate(player)
    if SpectateConnection then
        SpectateConnection:Disconnect()
        SpectateConnection = nil
    end
    
    local function SetCameraTarget()
        local camera = Workspace.CurrentCamera
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = player.Character.Humanoid
        else
            -- Если цель недоступна, возвращаем камеру себе
            StopSpectate()
        end
    end
    
    SetCameraTarget()
    
    -- Отслеживаем смену персонажа у цели
    SpectateConnection = player.CharacterAdded:Connect(function()
        task.wait(0.5)
        SetCameraTarget()
    end)
end

local function StopSpectate()
    if SpectateConnection then
        SpectateConnection:Disconnect()
        SpectateConnection = nil
    end
    
    Spectating = false
    local camera = Workspace.CurrentCamera
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        camera.CameraSubject = LocalPlayer.Character.Humanoid
    end
end

-- ============================================
--           ТЕЛЕПОРТ ФУНКЦИЯ
-- ============================================

local function TeleportToPlayer(player)
    if not player then
        Window:Notify({ Title = "Error", Message = "No target selected!", Type = "Error", Duration = 3 })
        return
    end
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        Window:Notify({ Title = "Error", Message = "Target has no character!", Type = "Error", Duration = 3 })
        return
    end
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Window:Notify({ Title = "Error", Message = "You have no character!", Type = "Error", Duration = 3 })
        return
    end
    
    -- Останавливаем полет если активен
    if _G.FlyEnabled then
        _G.FlyEnabled = false
        StopFly()
    end
    
    -- Останавливаем спектатор если активен
    if Spectating then
        StopSpectate()
    end
    
    -- Телепортируемся
    local targetRoot = player.Character.HumanoidRootPart
    local myRoot = LocalPlayer.Character.HumanoidRootPart
    myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
    
    Window:Notify({ Title = "Teleport", Message = "Teleported to " .. player.Name, Type = "Success", Duration = 2 })
end

-- ============================================
--           СОЗДАНИЕ ИНТЕРФЕЙСА
-- ============================================

-- Вкладка Main
local MainTab = Window:AddTab("Main")
MainTab:AddSection("Player Modifiers")

-- Числовое поле для скорости вместо слайдера
local speedInput = MainTab:AddNumberInput("Walk Speed", 16, 1, 1000, function(v)
    _G.SpeedValue = v
    pcall(UpdateWalkSpeed)
end)

-- Числовое поле для скорости полета
local flySpeedInput = MainTab:AddNumberInput("Fly Speed", 50, 1, 500, function(v)
    FlySpeed = v
    if _G.FlyEnabled and flyVelocity then
        -- Скорость обновится автоматически в следующем кадре
    end
end)

MainTab:AddToggle("God Mode", false, function(v)
    -- Заглушка для God Mode
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            if v then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            else
                hum.MaxHealth = 100
                hum.Health = 100
            end
        end
    end)
end)

MainTab:AddSeparator("Movement")

-- Тоггл полета
local flyToggle = MainTab:AddToggle("Fly Mode (F key)", false, function(state)
    _G.FlyEnabled = state
    if state then
        StartFly(FlySpeed)
        Window:Notify({ Title = "Fly", Message = "Fly enabled! WASD + Space/Ctrl", Type = "Info", Duration = 2 })
    else
        StopFly()
    end
end)

MainTab:AddSeparator("Visuals")

-- Тоггл шляпы
MainTab:AddToggle("Conical Hat (vertelevsepoel)", false, function(state)
    _G.Hat_Enabled = state
    if state then
        if LocalPlayer.Character then CreateHatEffects(LocalPlayer.Character) end
    else
        RemoveHatEffects(LocalPlayer.Character)
    end
end)

-- Вкладка Players
local PlayersTab = Window:AddTab("Players")
PlayersTab:AddSection("Visuals")

PlayersTab:AddToggle("Player ESP (Mono)", false, function(state)
    _G.ESP_Enabled = state
    if state then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then CreateESP(p) end
        end
        Window:Notify({ Title = "ESP", Message = "ESP enabled for all players", Type = "Success", Duration = 2 })
    else
        for p, _ in pairs(ActiveESP) do RemoveESP(p) end
    end
end)

PlayersTab:AddSection("Target Control")

-- Dropdown для выбора игрока
local PlayerDropdown = PlayersTab:AddDropdown("Select Target", GetPlayerNames(), function(v)
    if v == "No players found" then
        SelectedPlayer = nil
        return
    end
    SelectedPlayer = Players:FindFirstChild(v)
    if SelectedPlayer then
        Window:Notify({ Title = "Target", Message = "Selected: " .. v, Type = "Info", Duration = 2 })
    end
end)

-- Кнопка обновления списка игроков
PlayersTab:AddButton("Refresh Player List", function()
    PlayerDropdown:Refresh(GetPlayerNames(), false)
    Window:Notify({ Title = "Refresh", Message = "Player list updated", Type = "Info", Duration = 2 })
end)

-- Телепорт
PlayersTab:AddButton("Teleport to Target", function()
    TeleportToPlayer(SelectedPlayer)
end)

-- Тоггл спектатора
local spectateToggle = PlayersTab:AddToggle("Spectate Target", false, function(state)
    if not SelectedPlayer or SelectedPlayer.Name == "No players found" then
        Window:Notify({ Title = "Error", Message = "No target selected!", Type = "Error", Duration = 3 })
        spectateToggle:Set(false)
        return
    end
    
    Spectating = state
    if state then
        StartSpectate(SelectedPlayer)
        Window:Notify({ Title = "Spectate", Message = "Spectating: " .. SelectedPlayer.Name, Type = "Info", Duration = 2 })
    else
        StopSpectate()
    end
end)

-- Кнопка для принудительной остановки спектатора
PlayersTab:AddButton("Stop Spectating", function()
    if Spectating then
        StopSpectate()
        spectateToggle:Set(false)
        Window:Notify({ Title = "Spectate", Message = "Stopped spectating", Type = "Info", Duration = 2 })
    end
end)

-- ============================================
--           ОБРАБОТЧИКИ СОБЫТИЙ
-- ============================================

-- Шляпа при респавне
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if _G.Hat_Enabled then
        CreateHatEffects(char)
    end
    if _G.FlyEnabled then
        task.wait(0.5)
        StartFly(FlySpeed)
    end
end)

-- ESP для новых игроков
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if _G.ESP_Enabled then
            task.wait(0.5)
            CreateESP(player)
        end
    end)
end)

-- Удаление ESP при выходе
Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
    if SelectedPlayer == player then
        SelectedPlayer = nil
        if Spectating then
            StopSpectate()
            spectateToggle:Set(false)
        end
    end
end)

-- Авто-обновление списка игроков
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            PlayerDropdown:Refresh(GetPlayerNames(), true)
        end)
    end
end)

-- Клавиша F для полета
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        _G.FlyEnabled = not _G.FlyEnabled
        if _G.FlyEnabled then
            StartFly(FlySpeed)
            flyToggle:Set(true)
        else
            StopFly()
            flyToggle:Set(false)
        end
    end
end)

-- Уведомление о загрузке
Window:Notify({
    Title   = "Zandar UI",
    Message = "Loaded! F = Fly | WASD + Space/Ctrl to move",
    Type    = "Success",
    Duration = 4,
})

print("[Zandar UI] Loaded successfully!")
