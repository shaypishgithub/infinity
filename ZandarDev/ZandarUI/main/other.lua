-- ============================================
--      МОДУЛЬ ШЛЯПЫ, СПЕКТАТОРА, ТЕЛЕПОРТА
-- ============================================
local Hub = _G.ZandarHub
local Services = Hub.Services
local Players, RunService, Workspace, UserInputService, GuiService, LocalPlayer = unpack(Services)

-- СПИСОК ИГРОКОВ
local function GetPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then table.insert(names, p.Name) end end
    if #names == 0 then table.insert(names, "No players found") end
    return names
end

-- ШЛЯПА
local function RemoveHatEffects(char)
    if not char then return end
    for _, name in ipairs({"ZandarHat", "ZandarAura", "ZandarName"}) do local old = char:FindFirstChild(name) if old then old:Destroy() end end
end
local function CreateHatEffects(char)
    if not char or not Hub.States.Hat_Enabled then return end RemoveHatEffects(char)
    local head = char:WaitForChild("Head", 5) if not head then return end
    local hatPart = Instance.new("Part") hatPart.Name = "ZandarHat" hatPart.Size = Vector3.new(1, 0.4, 1)
    hatPart.CanCollide = false hatPart.Massless = true hatPart.Material = Enum.Material.SmoothPlastic hatPart.Parent = char
    local mesh = Instance.new("SpecialMesh", hatPart) mesh.MeshType = Enum.MeshType.FileMesh mesh.MeshId = "rbxassetid://1033714" mesh.Scale = Vector3.new(1.7, 1.1, 1.7)
    local weld = Instance.new("Weld", hatPart) weld.Part0 = hatPart weld.Part1 = head weld.C0 = CFrame.new(0, -1.15, 0)
    local bgui = Instance.new("BillboardGui") bgui.Name = "ZandarName" bgui.Parent = char bgui.Adornee = head bgui.Size = UDim2.new(0, 200, 0, 50) bgui.StudsOffset = Vector3.new(0, 3.5, 0) bgui.AlwaysOnTop = true
    local nameLabel = Instance.new("TextLabel", bgui) nameLabel.Size = UDim2.new(1, 0, 1, 0) nameLabel.BackgroundTransparency = 1 nameLabel.Text = "vertelevsepoel" nameLabel.Font = Enum.Font.GothamBold nameLabel.TextSize = 25 nameLabel.TextStrokeTransparency = 0.5
    local highlight = Instance.new("Highlight") highlight.Name = "ZandarAura" highlight.FillTransparency = 1 highlight.OutlineTransparency = 0 highlight.Adornee = char highlight.Parent = char
    local connection connection = RunService.RenderStepped:Connect(function()
        if not char.Parent or not hatPart.Parent or not Hub.States.Hat_Enabled then if connection then connection:Disconnect() end RemoveHatEffects(char) return end
        local wave = (math.sin(tick() * 2.5) + 1) / 2 local color = Color3.new(wave, wave, wave)
        hatPart.Color = color highlight.OutlineColor = color nameLabel.TextColor3 = color nameLabel.TextStrokeColor3 = Color3.new(1 - wave, 1 - wave, 1 - wave)
    end)
end

-- СПЕКТАТОР
local function StartSpectate(player)
    if Hub.Data.SpectateConnection then Hub.Data.SpectateConnection:Disconnect() Hub.Data.SpectateConnection = nil end
    local function SetCameraTarget()
        local camera = Workspace.CurrentCamera
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then camera.CameraSubject = player.Character.Humanoid
        else Hub.Functions.StopSpectate() end
    end
    SetCameraTarget()
    Hub.Data.SpectateConnection = player.CharacterAdded:Connect(function() task.wait(0.5) SetCameraTarget() end)
end
local function StopSpectate()
    if Hub.Data.SpectateConnection then Hub.Data.SpectateConnection:Disconnect() Hub.Data.SpectateConnection = nil end
    Hub.States.Spectating = false
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid end
end

-- ТЕЛЕПОРТ
local function TeleportToPlayer(player)
    if not player then Hub.UI.Window:Notify({ Title = "Error", Message = "No target selected!", Type = "Error", Duration = 3 }) return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then Hub.UI.Window:Notify({ Title = "Error", Message = "Target has no character!", Type = "Error", Duration = 3 }) return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then Hub.UI.Window:Notify({ Title = "Error", Message = "You have no character!", Type = "Error", Duration = 3 }) return end
    if Hub.States.FlyEnabled then Hub.States.FlyEnabled = false Hub.Functions.StopFly() if Hub.UI.FlyToggle then Hub.UI.FlyToggle:Set(false) end end
    if Hub.States.Spectating then Hub.Functions.StopSpectate() if Hub.UI.SpectateToggle then Hub.UI.SpectateToggle:Set(false) end end
    if Hub.States.FreeCamEnabled then Hub.States.FreeCamEnabled = false Hub.Functions.StopFreeCam() if Hub.UI.FreeCamToggle then Hub.UI.FreeCamToggle:Set(false) end end
    LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    Hub.UI.Window:Notify({ Title = "Teleport", Message = "Teleported to " .. player.Name, Type = "Success", Duration = 2 })
end

-- GOD MODE
local function ToggleGodMode(state)
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then if state then hum.MaxHealth = math.huge hum.Health = math.huge else hum.MaxHealth = 100 hum.Health = 100 end end
    end)
end

-- Регистрация функций
Hub.Functions.GetPlayerNames = GetPlayerNames
Hub.Functions.CreateHatEffects = CreateHatEffects
Hub.Functions.RemoveHatEffects = RemoveHatEffects
Hub.Functions.StartSpectate = StartSpectate
Hub.Functions.StopSpectate = StopSpectate
Hub.Functions.TeleportToPlayer = TeleportToPlayer
Hub.Functions.ToggleGodMode = ToggleGodMode
