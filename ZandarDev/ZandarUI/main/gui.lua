-- Загрузка интерфейса ZandarUI v3
local ZandarUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/ZandarDev/ZandarUI/main/ZandarUI.lua"))()

local Window = ZandarUI.new({
    Title       = "Zandar UI",
    Subtitle    = "v3.0.1 - Advanced",
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

local SelectedPlayer = nil
local Spectating = false

-- Скорость и Fly конфигурация
local TargetSpeed = 16
local FlyEnabled = false
local FlySpeed = 50

-- Таблицы для хранения эффектов
local ActiveESP = {}
local ActiveHats = {}

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
    if player == LocalPlayer then return end
    RemoveESP(player)
    local char = player.Character or player.CharacterAdded:Wait()
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

-- Слайдер скорости
local SpeedSlider = MainTab:AddSlider("WalkSpeed", {Min=16, Max=500, Default=16, Suffix=" stud/s"}, function(v)
    TargetSpeed = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)

-- TextBox для ввода абсолютно любого числового значения скорости
local SpeedBox = MainTab:AddTextBox("Custom Speed", "Enter exact speed (e.g. 1000)...", function(text)
    local num = tonumber(text)
    if num then
        TargetSpeed = num
        SpeedSlider:Set(math.clamp(num, 16, 500)) -- Визуально двигаем слайдер в его лимитах
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = num
        end
    end
end)

MainTab:AddSection("Flight Control (Fly)")

-- Переключатель полета (Fly)
MainTab:AddToggle("Fly Mode", false, function(state)
    FlyEnabled = state
end)

-- Слайдер скорости полета
MainTab:AddSlider("Fly Speed", {Min=10, Max=300, Default=50, Suffix=" studs"}, function(v)
    FlySpeed = v
end)

MainTab:AddSection("Visuals")

MainTab:AddToggle("Conical Hat (vertelevsepoel)", false, function(state)
    _G.Hat_Enabled = state
    if state and LocalPlayer.Character then CreateHatEffects(LocalPlayer.Character) else RemoveHatEffects(LocalPlayer.Character) end
end)

-- Вкладка Игроков
local PlayersTab = Window:AddTab("Players")
local VisualsSection = PlayersTab:AddSection("Visuals")

PlayersTab:AddToggle("Player ESP (Mono)", false, function(state)
    _G.ESP_Enabled = state
    if state then
        for _, p in ipairs(Players:GetPlayers()) do if p.Character then CreateESP(p) end end
    else
        for p, _ in pairs(ActiveESP) do RemoveESP(p) end
    end
end)

PlayersTab:AddSection("Target Control")
local PlayerDropdown = PlayersTab:AddDropdown("Select Target", GetPlayerNames(), function(v)
    SelectedPlayer = Players:FindFirstChild(v)
end)

PlayersTab:AddButton("Teleport to Target", function()
    if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
        end
    end
end)

PlayersTab:AddToggle("Spectate Target", false, function(state)
    Spectating = state
    local camera = Workspace.CurrentCamera
    if state and SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("Humanoid") then
        camera.CameraSubject = SelectedPlayer.Character.Humanoid
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end
end)

-- === ЦИКЛЫ И ОБРАБОТЧИКИ (ОСНОВНАЯ ЛОГИКА) ===

-- 1. Цикл жесткого обновления WalkSpeed каждые 2 секунды
task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            if not FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = TargetSpeed
            end
        end)
    end
end)

-- 2. Кроссплатформенный Флай (ПК WASD + Мобильный джойстик) без задержек по направлению камеры
task.spawn(function()
    local camera = Workspace.CurrentCamera
    
    RunService.RenderStepped:Connect(function(dt)
        local character = LocalPlayer.Character
        if not character then return end
        local root = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        if not root or not humanoid then return end

        if FlyEnabled then
            -- Выключаем стандартную физику падения
            humanoid.PlatformStand = true
            root.Velocity = Vector3.new(0, 0, 0)

            -- Получаем вектор направления движения из гуманоида (работает и для WASD, и для мобильного джойстика)
            local moveDirection = humanoid.MoveDirection
            
            -- Если игрок куда-то двигается
            if moveDirection.Magnitude > 0 then
                -- Рассчитываем движение относительно взгляда камеры (включая наклон вверх и вниз)
                local cameraCFrame = camera.CFrame
                local lookVector = cameraCFrame.LookVector
                local rightVector = cameraCFrame.RightVector
                
                -- Проекция направления джойстика/WASD на плоскость камеры
                -- Переводим MoveDirection обратно в локальные координаты относительно мира для точного следования за камерой
                local localMove = root.CFrame:VectorToObjectSpace(moveDirection)
                
                -- Итоговое направление полета с учетом наклона камеры
                local flightDirection = (lookVector * -localMove.Z + rightVector * localMove.X).Unit
                
                root.CFrame = root.CFrame + (flightDirection * FlySpeed * dt)
            else
                -- Если стоим на месте, удерживаем позицию в воздухе, обнуляя скорость
                root.Velocity = Vector3.zero
            end
        else
            -- Если флай выключен, возвращаем стандартное управление персонажем
            if humanoid.PlatformStand then
                humanoid.PlatformStand = false
            end
        end
    end)
end)

-- Отслеживание появления персонажа
LocalPlayer.CharacterAdded:Connect(function(char)
    if _G.Hat_Enabled then task.wait(0.5); CreateHatEffects(char) end
    if not FlyEnabled and char:WaitForChild("Humanoid", 5) then char.Humanoid.WalkSpeed = TargetSpeed end
end)

-- Обработка событий заходов и выходов игроков
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if _G.ESP_Enabled then task.wait(0.5); CreateESP(player) end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
    if SelectedPlayer == player then
        SelectedPlayer = nil
        if Spectating then Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid") end
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
    Message = "Script with Anti-Reset Speed & Crossplatform Fly loaded!",
    Type    = "Success",
    Duration = 4,
})
