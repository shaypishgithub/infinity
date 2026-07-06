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
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Переменные состояния
local _G = _G or {}
_G.ESP_Enabled = false
_G.Hat_Enabled = false

local SelectedPlayer = nil
local Spectating = false

-- Таблицы эффектов
local ActiveESP = {}
local ActiveHats = {}

-- === ПЕРЕМЕННЫЕ ДЛЯ СКОРОСТИ И ПОЛЁТА ===
local DesiredWalkSpeed = 16          -- будет обновляться каждые 2 секунды
local FlyEnabled = false
local FlySpeed = 50                 -- базовая скорость полёта
local FlySpeedSlider = nil          -- ссылка на слайдер скорости полёта (для обновления)
local FlySpeedLabel = nil           -- текстовый лейбл текущей скорости полёта

-- Функция обновления списков игроков
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

-- Удаление ESP
local function RemoveESP(player)
    if ActiveESP[player] then
        if ActiveESP[player].Highlight then ActiveESP[player].Highlight:Destroy() end
        if ActiveESP[player].Billboard then ActiveESP[player].Billboard:Destroy() end
        if ActiveESP[player].Connection then ActiveESP[player].Connection:Disconnect() end
        ActiveESP[player] = nil
    end
end

-- Создание ESP
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

-- Удаление шляпы и имени
local function RemoveHatEffects(char)
    if not char then return end
    local oldObjects = {"ZandarHat", "ZandarAura", "ZandarName"}
    for _, name in ipairs(oldObjects) do
        local old = char:FindFirstChild(name)
        if old then old:Destroy() end
    end
end

-- Создание шляпы и имени
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

-- === ПОСТОЯННОЕ ОБНОВЛЕНИЕ СКОРОСТИ ===
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = DesiredWalkSpeed
            end
        end)
    end
end)

-- === СИСТЕМА ПОЛЁТА ===
local bodyVelocity = nil
local flyConnection = nil

local function startFly()
    if flyConnection then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end

    -- Создаём BodyVelocity для плавного полёта
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = char.HumanoidRootPart

    humanoid.PlatformStand = true  -- убирает анимации падения

    local camera = Workspace.CurrentCamera

    flyConnection = RunService.RenderStepped:Connect(function()
        if not FlyEnabled or not char.Parent or not bodyVelocity then
            stopFly()
            return
        end

        local moveDirection = Vector3.zero
        local verticalInput = 0

        -- Определяем направление движения
        if UserInputService.TouchEnabled then  -- мобильное устройство
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                moveDirection = humanoid.MoveDirection  -- уже относительно камеры на мобилках
            end
        else  -- ПК: WASD
            local forward = 0
            local strafe = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then forward = forward + 1 end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then forward = forward - 1 end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then strafe = strafe - 1 end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then strafe = strafe + 1 end

            if forward ~= 0 or strafe ~= 0 then
                local camCF = camera.CFrame
                moveDirection = (camCF.LookVector * forward + camCF.RightVector * strafe).Unit
            end
        end

        -- Вертикаль по наклону камеры
        local lookVector = camera.CFrame.LookVector
        verticalInput = lookVector.Y * 2  -- коэффициент чувствительности

        -- Итоговая скорость
        local velocity = moveDirection * FlySpeed
        velocity = velocity + Vector3.new(0, verticalInput * FlySpeed, 0)

        bodyVelocity.Velocity = velocity
    end)
end

local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
        end
    end)
end

-- Обработка клавиш +/- для скорости полёта
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Plus or input.KeyCode == Enum.KeyCode.KeypadPlus then
        FlySpeed = math.min(FlySpeed + 10, 500)
        if FlySpeedSlider then FlySpeedSlider:SetValue(FlySpeed) end
        if FlySpeedLabel then FlySpeedLabel.Text = "Fly Speed: " .. FlySpeed .. " stud/s" end
    elseif input.KeyCode == Enum.KeyCode.Minus or input.KeyCode == Enum.KeyCode.KeypadMinus then
        FlySpeed = math.max(FlySpeed - 10, 10)
        if FlySpeedSlider then FlySpeedSlider:SetValue(FlySpeed) end
        if FlySpeedLabel then FlySpeedLabel.Text = "Fly Speed: " .. FlySpeed .. " stud/s" end
    end
end)

-- === ИНТЕРФЕЙС ===

local MainTab = Window:AddTab("Main")
MainTab:AddSection("Player Modifiers")

-- Слайдер скорости (сохраняет значение для цикла)
MainTab:AddSlider("Speed", {Min=16, Max=500, Default=16, Suffix=" stud/s"}, function(v)
    DesiredWalkSpeed = v
end)

-- Ввод произвольной скорости (текстовое поле + кнопка)
MainTab:AddSection("Custom Speed")
local customSpeedInput = MainTab:AddTextbox("Speed value", "Enter any number", function(text)
    local num = tonumber(text)
    if num and num > 0 then
        DesiredWalkSpeed = num
        Window:Notify({
            Title = "Speed",
            Message = "Speed set to " .. num .. " stud/s",
            Type = "Success",
            Duration = 3,
        })
    else
        Window:Notify({
            Title = "Error",
            Message = "Invalid number",
            Type = "Error",
            Duration = 3,
        })
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

-- === СЕКЦИЯ ПОЛЁТА ===
MainTab:AddSection("Flight")

MainTab:AddToggle("Enable Fly", false, function(state)
    FlyEnabled = state
    if state then
        startFly()
    else
        stopFly()
    end
end)

-- Слайдер скорости полёта
FlySpeedSlider = MainTab:AddSlider("Fly Speed", {Min=10, Max=500, Default=50, Suffix=" stud/s"}, function(v)
    FlySpeed = v
    if FlySpeedLabel then FlySpeedLabel.Text = "Fly Speed: " .. v .. " stud/s" end
end)

-- Лейбл для отображения текущей скорости полёта
FlySpeedLabel = MainTab:AddLabel("Fly Speed: 50 stud/s")

-- Кнопки ±
MainTab:AddButton("+ Fly Speed", function()
    FlySpeed = math.min(FlySpeed + 10, 500)
    FlySpeedSlider:SetValue(FlySpeed)
    FlySpeedLabel.Text = "Fly Speed: " .. FlySpeed .. " stud/s"
end)

MainTab:AddButton("- Fly Speed", function()
    FlySpeed = math.max(FlySpeed - 10, 10)
    FlySpeedSlider:SetValue(FlySpeed)
    FlySpeedLabel.Text = "Fly Speed: " .. FlySpeed .. " stud/s"
end)

-- Вкладка Players (без изменений, но оставлена для полноты)
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

-- === ОБРАБОТЧИКИ СОБЫТИЙ ===

LocalPlayer.CharacterAdded:Connect(function(char)
    if _G.Hat_Enabled then
        task.wait(0.5)
        CreateHatEffects(char)
    end
    -- Если полёт был включен, перезапускаем его для нового персонажа
    if FlyEnabled then
        stopFly()
        task.wait(0.1)
        startFly()
    end
end)

Players.PlayerAdded:Connect(function(player)
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

task.spawn(function()
    while task.wait(3) do
        pcall(function()
            PlayerDropdown:Refresh(GetPlayerNames(), true)
        end)
    end
end)

Window:Notify({
    Title   = "Zandar UI",
    Message = "Script loaded successfully! Fly and speed features added.",
    Type    = "Success",
    Duration = 4,
})
