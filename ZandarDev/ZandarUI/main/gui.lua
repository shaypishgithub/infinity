-- Загрузка интерфейса ZandarUI
local ZandarUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/ZandarDev/ZandarUI/main/ZandarUI.lua"))()

local Window = ZandarUI.new({
    Title       = "Zandar UI",
    Subtitle    = "v1.0",
    Theme       = "Dark",
    AccentColor = Color3.fromRGB(120, 80, 255),
    ToggleKey   = Enum.KeyCode.RightShift,
})

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Переменные состояния (Флаги)
local _G = _G or {}
_G.ESP_Enabled = false
_G.Hat_Enabled = false

local SelectedPlayer = nil
local Spectating = false

-- Таблицы для хранения эффектов
local ActiveESP = {}
local ActiveHats = {}

-- === ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ===

-- Функция обновления списков игроков в выпадающих меню (Dropdown)
local function GetPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    if #names == 0 then table.insert(names, "No players found") end
    return names
end

-- Удаление ESP у конкретного игрока
local function RemoveESP(player)
    if ActiveESP[player] then
        if ActiveESP[player].Highlight then ActiveESP[player].Highlight:Destroy() end
        if ActiveESP[player].Billboard then ActiveESP[player].Billboard:Destroy() end
        if ActiveESP[player].Connection then ActiveESP[player].Connection:Disconnect() end
        ActiveESP[player] = nil
    end
end

-- Создание ESP (Ник, Дистанция, Черно-бело-серая обводка)
local function CreateESP(player)
    if player == LocalPlayer then return end
    RemoveESP(player)

    local char = player.Character
    if not char then return end
    local root = char:WaitForChild("HumanoidRootPart", 5)
    local head = char:WaitForChild("Head", 5)
    if not root or not head then return end

    local espData = {}

    -- Обводка (Highlight)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ZandarESP"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.Adornee = char
    highlight.Parent = char
    espData.Highlight = highlight

    -- Текст (BillboardGui)
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

    -- Цикл обновления цвета (Черно-бело-серый) и дистанции
    espData.Connection = RunService.RenderStepped:Connect(function()
        if not char.Parent or not root.Parent or not _G.ESP_Enabled then
            RemoveESP(player)
            return
        end

        local wave = (math.sin(tick() * 2.5) + 1) / 2
        local monoColor = Color3.new(wave, wave, wave) -- Перелив от черного к белому через серый

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

-- Удаление эффектов конической шляпы и ника vertelevsepoel
local function RemoveHatEffects(char)
    if not char then return end
    local oldObjects = {"ZandarHat", "ZandarAura", "ZandarName"}
    for _, name in ipairs(oldObjects) do
        local old = char:FindFirstChild(name)
        if old then old:Destroy() end
    end
end

-- Создание конической шляпы и ника (vertelevsepoel)
local function CreateHatEffects(char)
    if not char or not _G.Hat_Enabled then return end
    RemoveHatEffects(char)

    local head = char:WaitForChild("Head", 5)
    if not head then return end

    -- 1. Шляпа
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

    -- 2. Ник vertelevsepoel
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

    -- 3. Аура
    local highlight = Instance.new("Highlight")
    highlight.Name = "ZandarAura"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.Adornee = char
    highlight.Parent = char

    -- Цикл синхронного перелива
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

-- === СОЗДАНИЕ СТРАНИЦ И ФУНКЦИЙ ИНТЕРФЕЙСА ===

-- Вкладка Main (Основные функции и Твики персонажа)
local MainTab = Window:AddTab("Main")
MainTab:AddSection("Player Modifiers")

MainTab:AddSlider("Speed", {Min=16, Max=500, Default=16, Suffix=" stud/s"}, function(v)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)

MainTab:AddToggle("God Mode", false, function(v)
    print("God Mode Status: ", v)
end)

MainTab:AddSeparator("Visuals")

-- Отдельная функция для активации Conical Hat + переливающегося ника
MainTab:AddToggle("Conical Hat (vertelevsepoel)", false, function(state)
    _G.Hat_Enabled = state
    if state then
        if LocalPlayer.Character then CreateHatEffects(LocalPlayer.Character) end
    else
        RemoveHatEffects(LocalPlayer.Character)
    end
end)

-- Вкладка Players (Игроки, ESP, Телепорт, Слежка)
local PlayersTab = Window:AddTab("Players")
PlayersTab:AddSection("Visuals")

PlayersTab:AddToggle("Player ESP (Mono)", false, function(state)
    _G.ESP_Enabled = state
    if state then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then CreateESP(p) end
        end
    else
        for p, _ in pairs(ActiveESP) do RemoveESP(p) end
    end
end)

PlayersTab:AddSection("Target Control")

-- Выпадающий список игроков, который автоматически обновляется при открытии/нажатии
local PlayerDropdown = PlayersTab:AddDropdown("Select Target", GetPlayerNames(), function(v)
    SelectedPlayer = Players:FindFirstChild(v)
end)

-- Функции взаимодействия с выбранным игроком
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

-- === ОБРАБОТЧИКИ СОБЫТИЙ И АВТО-ОБНОВЛЕНИЕ ===

-- Отслеживание появления персонажа для применения эффектов шляпы
LocalPlayer.CharacterAdded:Connect(function(char)
    if _G.Hat_Enabled then
        task.wait(0.5)
        CreateHatEffects(char)
    end
end)

-- Обработка ESP для заходящих/выходящих игроков
Players.PlayerPlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if _G.ESP_Enabled then
            task.wait(0.5)
            CreateESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
    if SelectedPlayer == player then
        SelectedPlayer = nil
        if Spectating then
            Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
        end
    end
end)

-- Постоянное фоновое обновление списков игроков в Dropdown
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            PlayerDropdown:Refresh(GetPlayerNames(), true)
        end)
    end
end)

-- Уведомление о готовности
Window:Notify({
    Title   = "Zandar UI",
    Message = "Script loaded successfully!",
    Type    = "Success",
    Duration = 4,
})
