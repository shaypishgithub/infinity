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
--    АДАПТИВНЫЙ ПОЛЕТ (ПК + ТЕЛЕФОН)
-- ============================================

local flyConnection = nil
local flyVelocity = nil

local function StartFly(speed)
    if flyConnection then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    
    -- ВАЖНО: Не используем PlatformStand! Оставляем гуманоида активным, 
    -- чтобы он мог обрабатывать ввод с мобильного джойстика.
    hum.WalkSpeed = 0 -- Обнуляем скорость ходьбы, чтобы персонаж не "шагал"
    
    -- Создаем LinearVelocity
    local attachment = root:FindFirstChild("FlyAttachment") or Instance.new("Attachment", root)
    attachment.Name = "FlyAttachment"
    
    flyVelocity = Instance.new("LinearVelocity")
    flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyVelocity.Attachment0 = attachment
    flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    flyVelocity.Parent = root
    
    flyConnection = RunService.RenderStepped:Connect(function()
        if not _G.FlyEnabled or not LocalPlayer.Character then
            StopFly()
            return
        end
        
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humPart = LocalPlayer.Character:FindFirstChild("Humanoid")
        if not rootPart or not humPart then StopFly() return end
        
        -- Читаем MoveDirection (Это работает И для клавиатуры WASD, И для мобильного джойстика!)
        local moveDir = humPart.MoveDirection
        local camera = Workspace.CurrentCamera
        local cf = camera.CFrame
        
        -- Переводим направление движения в мировые координаты относительно камеры
        local worldMove = (cf.RightVector * moveDir.X) + (cf.LookVector * moveDir.Z)
        
        -- АДАПТИВНЫЙ ПОДЪЕМ/СПУСК ДЛЯ ТЕЛЕФОНА:
        -- Если наклонить камеру вверх (> 20 градусов) - летим вверх
        -- Если наклонить камеру вниз (< -20 градусов) - летим вниз
        local pitch = math.asin(math.clamp(-cf.LookVector.Y, -1, 1))
        if pitch > math.rad(20) then
            worldMove = worldMove + Vector3.new(0, 1, 0) * math.clamp((pitch - math.rad(20)) / math.rad(70), 0, 1)
        elseif pitch < -math.rad(20) then
            worldMove = worldMove - Vector3.new(0, 1, 0) * math.clamp((-pitch - math.rad(20)) / math.rad(70), 0, 1)
        end
        
        -- Управление для ПК (Space/Ctrl перебивают наклон камеры для точности)
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            worldMove = worldMove + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            worldMove = worldMove - Vector3.new(0, 1, 0)
        end
        
        -- Нормализуем и применяем скорость
        if worldMove.Magnitude > 0 then
            worldMove = worldMove.Unit * speed
        end
        
        flyVelocity.Velocity = worldMove
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
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = _G.SpeedValue -- Возвращаем скорость
        end
        local attachment = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("FlyAttachment")
        if attachment then attachment:Destroy() end
    end
end

-- ============================================
--           FREE CAM (NOCLIP CAMERA)
-- ============================================

local FreeCamActive = false
local FreeCamPart = nil
local FreeCamConnection = nil
local SavedTransparencies = {}

local function StartFreeCam()
    if FreeCamActive then return end
    FreeCamActive = true

    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    -- Делаем тело "пустым" (полупрозрачным) и замораживаем
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            SavedTransparencies[part] = part.LocalTransparencyModifier
            part.LocalTransparencyModifier = 0.7 -- Делаем полупрозрачным
            part.Anchored = true -- Замораживаем на месте
        end
    end
    hum.WalkSpeed = 0

    -- Создаем невидимую точку для камеры
    FreeCamPart = Instance.new("Part")
    FreeCamPart.Name = "ZandarFreeCamPart"
    FreeCamPart.Size = Vector3.new(1, 1, 1)
    FreeCamPart.Transparency = 1
    FreeCamPart.CanCollide = false
    FreeCamPart.Anchored = true
    FreeCamPart.CFrame = Workspace.CurrentCamera.CFrame
    FreeCamPart.Parent = Workspace

    -- Переносим камеру на эту точку (Так мы сохраняем вращение камеры пальцем на телефоне!)
    Workspace.CurrentCamera.CameraSubject = FreeCamPart

    FreeCamConnection = RunService.RenderStepped:Connect(function(delta)
        if not FreeCamActive or not FreeCamPart or not FreeCamPart.Parent then
            StopFreeCam()
            return
        end

        -- Используем MoveDirection для управления (Джойстик или WASD)
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local cf = Workspace.CurrentCamera.CFrame
            local worldMove = (cf.RightVector * moveDir.X) + (cf.LookVector * moveDir.Z)
            
            -- Подъем/спуск наклоном камеры
            local pitch = math.asin(math.clamp(-cf.LookVector.Y, -1, 1))
            if pitch > math.rad(20) then
                worldMove = worldMove + Vector3.new(0, 1, 0)
            elseif pitch < -math.rad(20) then
                worldMove = worldMove - Vector3.new(0, 1, 0)
            end

            -- ПК кнопки
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then worldMove = worldMove + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then worldMove = worldMove - Vector3.new(0, 1, 0) end

            if worldMove.Magnitude > 0 then
                worldMove = worldMove.Unit * (FlySpeed * 1.5) -- Скорость фрикама чуть быстрее
                -- Перемещаем точку (delta * 60 для независимости от ФПС)
                FreeCamPart.CFrame = FreeCamPart.CFrame + worldMove * (delta * 60)
            end
        end
    end)
end

local function StopFreeCam()
    FreeCamActive = false
    if FreeCamConnection then
        FreeCamConnection:Disconnect()
        FreeCamConnection = nil
    end
    if FreeCamPart then
        FreeCamPart:Destroy()
        FreeCamPart = nil
    end

    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        -- Возвращаем тело в нормальное состояние
        for part, trans in pairs(SavedTransparencies) do
            if part and part.Parent then
                part.LocalTransparencyModifier = trans
                part.Anchored = false
            end
        end
        SavedTransparencies = {}
        
        if hum then
            hum.WalkSpeed = _G.SpeedValue
            -- Возвращаем камеру в голову
            Workspace.CurrentCamera.CameraSubject = hum
        end
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
    local highlight = Instance.new("Highlight")
    highlight.Name = "ZandarESP"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.Adornee = char
    highlight.Parent = char
    espData.Highlight = highlight

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
    if SpectateConnection then SpectateConnection:Disconnect() SpectateConnection = nil end
    local function SetCameraTarget()
        local camera = Workspace.CurrentCamera
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = player.Character.Humanoid
        else
            StopSpectate()
        end
    end
    SetCameraTarget()
    SpectateConnection = player.CharacterAdded:Connect(function()
        task.wait(0.5)
        SetCameraTarget()
    end)
end

local function StopSpectate()
    if SpectateConnection then SpectateConnection:Disconnect() SpectateConnection = nil end
    Spectating = false
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
    end
end

-- ============================================
--           ТЕЛЕПОРТ ФУНКЦИЯ
-- ============================================

local function TeleportToPlayer(player)
    if not player then Window:Notify({ Title = "Error", Message = "No target selected!", Type = "Error", Duration = 3 }) return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then Window:Notify({ Title = "Error", Message = "Target has no character!", Type = "Error", Duration = 3 }) return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then Window:Notify({ Title = "Error", Message = "You have no character!", Type = "Error", Duration = 3 }) return end
    
    if _G.FlyEnabled then _G.FlyEnabled = false StopFly() end
    if Spectating then StopSpectate() end
    if FreeCamActive then StopFreeCam() freecamToggle:Set(false) end
    
    LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    Window:Notify({ Title = "Teleport", Message = "Teleported to " .. player.Name, Type = "Success", Duration = 2 })
end

-- ============================================
--           СОЗДАНИЕ ИНТЕРФЕЙСА
-- ============================================

local MainTab = Window:AddTab("Main")
MainTab:AddSection("Player Modifiers")

local speedInput = MainTab:AddNumberInput("Walk Speed", 16, 1, 1000, function(v)
    _G.SpeedValue = v
    pcall(UpdateWalkSpeed)
end)

local flySpeedInput = MainTab:AddNumberInput("Fly Speed", 50, 1, 500, function(v)
    FlySpeed = v
end)

MainTab:AddToggle("God Mode", false, function(v)
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            if v then hum.MaxHealth = math.huge hum.Health = math.huge
            else hum.MaxHealth = 100 hum.Health = 100 end
        end
    end)
end)

MainTab:AddSeparator("Movement")

local flyToggle = MainTab:AddToggle("Fly Mode (F key)", false, function(state)
    _G.FlyEnabled = state
    if state then
        StartFly(FlySpeed)
        Window:Notify({ Title = "Fly", Message = "Fly enabled! Look up/down to fly vertically", Type = "Info", Duration = 3 })
    else
        StopFly()
    end
end)

MainTab:AddSeparator("Visuals")

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
        for _, p in ipairs(Players:GetPlayers()) do if p.Character then CreateESP(p) end end
    else
        for p, _ in pairs(ActiveESP) do RemoveESP(p) end
    end
end)

PlayersTab:AddSection("Camera")

-- FREE CAM TGGL
local freecamToggle = PlayersTab:AddToggle("Free Cam (Noclip)", false, function(state)
    if state then
        if _G.FlyEnabled then _G.FlyEnabled = false StopFly() flyToggle:Set(false) end
        StartFreeCam()
        Window:Notify({ Title = "Free Cam", Message = "Look up/down to fly vertically", Type = "Info", Duration = 3 })
    else
        StopFreeCam()
    end
end)

PlayersTab:AddSection("Target Control")

local PlayerDropdown = PlayersTab:AddDropdown("Select Target", GetPlayerNames(), function(v)
    if v == "No players found" then SelectedPlayer = nil return end
    SelectedPlayer = Players:FindFirstChild(v)
end)

PlayersTab:AddButton("Refresh Player List", function()
    PlayerDropdown:Refresh(GetPlayerNames(), false)
end)

PlayersTab:AddButton("Teleport to Target", function()
    TeleportToPlayer(SelectedPlayer)
end)

local spectateToggle = PlayersTab:AddToggle("Spectate Target", false, function(state)
    if not SelectedPlayer or SelectedPlayer.Name == "No players found" then
        Window:Notify({ Title = "Error", Message = "No target selected!", Type = "Error", Duration = 3 })
        spectateToggle:Set(false)
        return
    end
    Spectating = state
    if state then
        StartSpectate(SelectedPlayer)
    else
        StopSpectate()
    end
end)

PlayersTab:AddButton("Stop Spectating", function()
    if Spectating then
        StopSpectate()
        spectateToggle:Set(false)
    end
end)

-- ============================================
--           ОБРАБОТЧИКИ СОБЫТИЙ
-- ============================================

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    -- Сбрасываем состояния при респавне
    if FreeCamActive then StopFreeCam() freecamToggle:Set(false) end
    if Spectating then StopSpectate() spectateToggle:Set(false) end
    if _G.FlyEnabled then _G.FlyEnabled = false flyToggle:Set(false) end
    
    if _G.Hat_Enabled then CreateHatEffects(char) end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if _G.ESP_Enabled then task.wait(0.5) CreateESP(player) end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
    if SelectedPlayer == player then
        SelectedPlayer = nil
        if Spectating then StopSpectate() spectateToggle:Set(false) end
    end
end)

task.spawn(function()
    while task.wait(5) do
        pcall(function() PlayerDropdown:Refresh(GetPlayerNames(), true) end)
    end
end)

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

Window:Notify({
    Title   = "Zandar UI",
    Message = "Loaded! F = Fly. Mobile: Drag joystick & tilt camera up/down!",
    Type    = "Success",
    Duration = 5,
})

print("[Zandar UI] Loaded successfully!")
