local Core = {}

Core.Config = {
    AutoSave = true
}

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

Core.Player = {}
Core.Visuals = {}

function Core.LoadGame(Name)
    local Scripts = {
        BladeBall = "https://raw.githubusercontent.com/yourname/scripts/main/bladeball.lua",
        Brookhaven = "https://raw.githubusercontent.com/yourname/scripts/main/brookhaven.lua",
        MM2 = "https://raw.githubusercontent.com/yourname/scripts/main/mm2.lua",
        GrowGarden = "https://raw.githubusercontent.com/yourname/scripts/main/growgarden.lua"
    }

    if Scripts[Name] then
        loadstring(game:HttpGet(Scripts[Name]))()
    end
end

function Core.Player:SetWalkSpeed(Value)
    local Character = Player.Character
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = Value
    end
end

function Core.Player:SetJumpPower(Value)
    local Character = Player.Character
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.JumpPower = Value
    end
end

local InfiniteJumpEnabled = false

function Core.Player.InfiniteJump(State)
    InfiniteJumpEnabled = State
end

UIS.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local Character = Player.Character
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local NoclipEnabled = false

function Core.Player.Noclip(State)
    NoclipEnabled = State
end

RunService.Stepped:Connect(function()
    if NoclipEnabled then
        local Character = Player.Character
        if Character then
            for _,v in pairs(Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end
end)

local ESPEnabled = false
local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "MegaXESP"

function Core.Visuals.ESP(State)
    ESPEnabled = State

    if not State then
        ESPFolder:ClearAllChildren()
        return
    end

    for _,PlayerTarget in pairs(Players:GetPlayers()) do
        if PlayerTarget ~= Player then
            local Highlight = Instance.new("Highlight")
            Highlight.FillColor = Color3.fromRGB(170,0,255)
            Highlight.OutlineColor = Color3.fromRGB(255,255,255)
            Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

            if PlayerTarget.Character then
                Highlight.Parent = ESPFolder
                Highlight.Adornee = PlayerTarget.Character
            end
        end
    end
end

function Core.Visuals.FullBright(State)
    if State then
        Lighting.Brightness = 5
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = true
    end
end

local TracerFolder = Instance.new("Folder", game.CoreGui)
TracerFolder.Name = "MegaXTracers"

function Core.Visuals.Tracers(State)
    TracerFolder:ClearAllChildren()

    if not State then
        return
    end

    for _,Target in pairs(Players:GetPlayers()) do
        if Target ~= Player then
            local Line = Drawing.new("Line")
            Line.Color = Color3.fromRGB(255,221,0)
            Line.Thickness = 1.5
            Line.Transparency = 1

            RunService.RenderStepped:Connect(function()
                pcall(function()
                    local Root = Target.Character.HumanoidRootPart
                    local Pos, Visible = workspace.CurrentCamera:WorldToViewportPoint(Root.Position)

                    if Visible then
                        Line.Visible = true
                        Line.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                        Line.To = Vector2.new(Pos.X, Pos.Y)
                    else
                        Line.Visible = false
                    end
                end)
            end)
        end
    end
end

return Core
