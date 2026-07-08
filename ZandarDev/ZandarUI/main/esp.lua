-- ============================================
--                 МОДУЛЬ ESP
-- ============================================
local Hub = _G.ZandarHub
local Services = Hub.Services
local Players, RunService, Workspace, UserInputService, GuiService, LocalPlayer = unpack(Services)

local function RemoveESP(player)
    if Hub.Data.ActiveESP[player] then
        if Hub.Data.ActiveESP[player].Highlight then Hub.Data.ActiveESP[player].Highlight:Destroy() end
        if Hub.Data.ActiveESP[player].Billboard then Hub.Data.ActiveESP[player].Billboard:Destroy() end
        if Hub.Data.ActiveESP[player].Connection then Hub.Data.ActiveESP[player].Connection:Disconnect() end
        Hub.Data.ActiveESP[player] = nil
    end
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    RemoveESP(player)
    local char = player.Character if not char then return end
    local root = char:WaitForChild("HumanoidRootPart", 5) local head = char:WaitForChild("Head", 5)
    if not root or not head then return end

    local espData = {}
    local highlight = Instance.new("Highlight") highlight.Name = "ZandarESP" highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0 highlight.Adornee = char highlight.Parent = char espData.Highlight = highlight

    local bgui = Instance.new("BillboardGui") bgui.Name = "ZandarESPText" bgui.Size = UDim2.new(0, 200, 0, 50)
    bgui.StudsOffset = Vector3.new(0, 3, 0) bgui.AlwaysOnTop = true bgui.Adornee = head bgui.Parent = char espData.Billboard = bgui

    local textLabel = Instance.new("TextLabel", bgui) textLabel.Size = UDim2.new(1, 0, 1, 0) textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold textLabel.TextSize = 16 textLabel.TextStrokeTransparency = 0.5

    espData.Connection = RunService.RenderStepped:Connect(function()
        if not char.Parent or not root.Parent or not Hub.States.ESP_Enabled then RemoveESP(player) return end
        local wave = (math.sin(tick() * 2.5) + 1) / 2 local monoColor = Color3.new(wave, wave, wave)
        highlight.OutlineColor = monoColor textLabel.TextColor3 = monoColor
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local dist = math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
            textLabel.Text = string.format("%s [%d m]", player.Name, dist)
        else textLabel.Text = player.Name end
    end)
    Hub.Data.ActiveESP[player] = espData
end

-- Обработка событий игроков для ESP
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char) if Hub.States.ESP_Enabled then task.wait(0.5) CreateESP(player) end end)
end)
Players.PlayerRemoving:Connect(function(player) RemoveESP(player) end)

Hub.Functions.CreateESP = CreateESP
Hub.Functions.RemoveESP = RemoveESP
