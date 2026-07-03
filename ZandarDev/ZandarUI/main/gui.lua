local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Инициализация UI
local ZandarUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/ZandarDev/ZandarUI/main/ZandarUI.lua"
))()

local Window = ZandarUI.new({
    Title       = "Zandar Hub",
    Subtitle    = "v1.1",
    Theme       = "Dark",
    AccentColor = Color3.fromRGB(120, 80, 255),
    ToggleKey   = Enum.KeyCode.RightShift,
})

local MainTab = Window:AddTab("Main")
local VisualsTab = Window:AddTab("Visuals")

-- Переменные для отслеживания состояний
local SelectedPlayerName = ""
local ESPEnabled = false
local Spectating = false
local EspObjects = {}

-- === ФУНКЦИЯ ОБНОВЛЕНИЯ СПИСКА ИГРОКОВ ===
local function GetPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    return names
end

-- === ЭФФЕКТЫ ДЛЯ СЕБЯ (Zandar) ===
local function CreateSelfEffects(char)
    if not char then return end
    local head = char:WaitForChild("Head", 5)
    if not head then return end

    local oldObjects = {"EliteHat", "EliteAura", "EliteName"}
    for _, name in ipairs(oldObjects) do
        local old = char:FindFirstChild(name)
        if old then old:Destroy() end
    end

    local hatPart = Instance.new("Part")
    hatPart.Name = "EliteHat"
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
    bgui.Name = "EliteName"
    bgui.Parent = char
    bgui.Adornee = head
    bgui.Size = UDim2.new(0, 200, 0, 50)
    bgui.StudsOffset = Vector3.new(0, 3.5, 0)
    bgui.AlwaysOnTop = true

    local nameLabel = Instance.new("TextLabel", bgui)
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Zandar" -- Изменено на Zandar
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 25
    nameLabel.TextStrokeTransparency = 0.5

    local highlight = Instance.new("Highlight")
    highlight.Name = "EliteAura"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.Adornee = char
    highlight.Parent = char

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not char.Parent or not hatPart.Parent then
            connection:Disconnect()
            return
        end
        local wave = (math.sin(tick() * 2.5) + 1) / 2
        local color = Color3.new(wave, wave, wave)
        hatPart.Color = color
        highlight.OutlineColor = color
        nameLabel.TextColor3 = color
        nameLabel.TextStrokeColor3 = Color3.new(1-wave, 1-wave, 1-wave)
    end)
end

if LocalPlayer.Character then CreateSelfEffects(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(CreateSelfEffects)

-- === РЕАЛИЗАЦИЯ ESP ===
local function CreateESP(player)
    if player == LocalPlayer then return end

    local function setupCharacterEsp(char)
        if not char then return end
        local root = char:WaitForChild("HumanoidRootPart", 5)
        local head = char:WaitForChild("Head", 5)
        if not root or not head then return end

        if EspObjects[player.Name] then
            pcall(function() EspObjects[player.Name].BGui:Destroy() end)
            pcall(function() EspObjects[player.Name].Highlight:Destroy() end)
        end

        local bgui = Instance.new("BillboardGui")
        bgui.Name = "EspGui"
        bgui.AlwaysOnTop = true
        bgui.Size = UDim2.new(0, 200, 0, 50)
        bgui.StudsOffset = Vector3.new(0, 3, 0)
        bgui.Adornee = head
        bgui.Parent = char

        local textLabel = Instance.new("TextLabel", bgui)
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextSize = 18
        textLabel.TextColor3 = Color3.new(1, 1, 1)
        textLabel.TextStrokeTransparency = 0.2

        local highlight = Instance.new("Highlight")
        highlight.Name = "EspHighlight"
        highlight.FillTransparency = 1
        highlight.OutlineTransparency = 0
        highlight.OutlineColor = Color3.fromRGB(180, 180, 180) -- Серо-белый цвет ауры
        highlight.Adornee = char
        highlight.Parent = char

        EspObjects[player.Name] = {
            BGui = bgui,
            Highlight = highlight,
            Label = textLabel,
            Root = root
        }
        
        highlight.Enabled = ESPEnabled
        bgui.Enabled = ESPEnabled
    end

    if player.Character then setupCharacterEsp(player.Character) end
    player.CharacterAdded:Connect(setupCharacterEsp)
end

for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

Players.PlayerRemoving:Connect(function(player)
    if EspObjects[player.Name] then
        EspObjects[player.Name] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if not ESPEnabled then return end
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    for name, data in pairs(EspObjects) do
        if data.Root and data.Root.Parent and localRoot then
            local distance = math.floor((localRoot.Position - data.Root.Position).Magnitude)
            data.Label.Text = string.format("%s\n[%d m]", name, distance)
        end
    end
end)


-- === НАСТРОЙКА ВКЛАДОК И ФУНКЦИЙ UI ===

MainTab:AddSection("Target Control")

local PlayerDropdown = MainTab:AddDropdown("Select Player", GetPlayerNames(), function(v)
    SelectedPlayerName = v
    -- Если мы уже наблюдаем за кем-то и меняем цель в списке, обновляем фокус камеры
    if Spectating and SelectedPlayerName ~= "" then
        local targetPlayer = Players:FindFirstChild(SelectedPlayerName)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = targetPlayer.Character.Humanoid
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

MainTab:AddButton("Teleport to Player", function()
    if SelectedPlayerName ~= "" then
        local targetPlayer = Players:FindFirstChild(SelectedPlayerName)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local localChar = LocalPlayer.Character
            if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                localChar.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
            end
        end
    end
end)

MainTab:AddToggle("Spectate Player", false, function(state)
    Spectating = state
    if Spectating and SelectedPlayerName ~= "" then
        local targetPlayer = Players:FindFirstChild(SelectedPlayerName)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = targetPlayer.Character.Humanoid
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end
end)

MainTab:AddSeparator("Local Player")

MainTab:AddSlider("Speed", {Min=16, Max=500, Default=16, Suffix=" stud/s"}, function(v)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)

VisualsTab:AddSection("Render Options")

VisualsTab:AddToggle("Enable ESP", false, function(state)
    ESPEnabled = state
    for _, data in pairs(EspObjects) do
        if data.Highlight and data.BGui then
            data.Highlight.Enabled = state
            data.BGui.Enabled = state
        end
    end
end)

Window:Notify({
    Title   = "Loaded!",
    Message = "Zandar Hub Ready.",
    Type    = "Success",
    Duration = 4,
})
