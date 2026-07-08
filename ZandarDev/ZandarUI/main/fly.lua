-- ============================================
--               МОДУЛЬ ПОЛЕТА И FREECAM
-- ============================================
local Hub = _G.ZandarHub
local Services = Hub.Services
local Players, RunService, Workspace, UserInputService, GuiService, LocalPlayer = unpack(Services)

-- УНИВЕРСАЛЬНАЯ СИСТЕМА ВВОДА (ПК + ТЕЛЕФОН)
local touchState = {
    left = { id = nil, start = nil, current = nil },
    right = { id = nil, start = nil, current = nil }
}

UserInputService.TouchStarted:Connect(function(touch, gpe)
    if GuiService:GetGuiObjectAtPosition(touch.Position) then return end
    local vp = Workspace.CurrentCamera.ViewportSize
    if touch.Position.X < vp.X * 0.5 then
        touchState.left.id = touch.Id; touchState.left.start = touch.Position; touchState.left.current = touch.Position
    else
        touchState.right.id = touch.Id; touchState.right.start = touch.Position; touchState.right.current = touch.Position
    end
end)

UserInputService.TouchMoved:Connect(function(touch)
    if touch.Id == touchState.left.id then touchState.left.current = touch.Position
    elseif touch.Id == touchState.right.id then touchState.right.current = touch.Position end
end)

UserInputService.TouchEnded:Connect(function(touch)
    if touch.Id == touchState.left.id then touchState.left = {id=nil,start=nil,current=nil}
    elseif touch.Id == touchState.right.id then touchState.right = {id=nil,start=nil,current=nil} end
end)

local function GetMovementDirection(cameraCFrame)
    local moveDir = Vector3.new(0, 0, 0)
    local cf = cameraCFrame
    local forward = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z).Unit
    local right = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z).Unit

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + forward end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - forward end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - right end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + right end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

    if touchState.left.start and touchState.left.current then
        local delta = touchState.left.current - touchState.left.start
        if delta.Magnitude > 20 then
            local normDelta = delta.Unit
            moveDir = moveDir + (right * normDelta.X) - (forward * normDelta.Y)
        end
    end

    if touchState.right.start and touchState.right.current then
        local deltaY = touchState.right.start.Y - touchState.right.current.Y
        if math.abs(deltaY) > 30 then moveDir = moveDir + Vector3.new(0, math.clamp(deltaY / 50, -1, 1), 0) end
    end

    if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
    return moveDir
end

-- ЛОКАЛЬНЫЕ ПЕРЕМЕННЫЕ ПОЛЕТА
local flyConnection = nil
local flyVelocity = nil

local function StartFly(speed)
    if flyConnection then return end
    local char = LocalPlayer.Character if not char then return end
    local hum = char:FindFirstChild("Humanoid") local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    
    hum.AutoRotate = false; hum.WalkSpeed = 0
    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyVelocity.Velocity = Vector3.new(0, 0, 0); flyVelocity.Parent = root
    
    flyConnection = RunService.RenderStepped:Connect(function()
        if not Hub.States.FlyEnabled or not LocalPlayer.Character then Hub.Functions.StopFly() return end
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if not rootPart or not hum then Hub.Functions.StopFly() return end
        
        local moveDir = GetMovementDirection(Workspace.CurrentCamera.CFrame)
        if moveDir.Magnitude > 0 and not UserInputService.TouchEnabled then
            rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + Vector3.new(moveDir.X, 0, moveDir.Z))
        end
        flyVelocity.Velocity = moveDir * speed
    end)
end

local function StopFly()
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.AutoRotate = true; hum.WalkSpeed = Hub.Config.SpeedValue end
    end
end

-- ЛОКАЛЬНЫЕ ПЕРЕМЕННЫЕ FREECAM
local freeCamConnection = nil; local freeCamPart = nil; local freeCamVelocity = nil

local function StartFreeCam(speed)
    if freeCamConnection then return end
    local char = LocalPlayer.Character if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    root.Anchored = true; hum.AutoRotate = false
    freeCamPart = Instance.new("Part") freeCamPart.Name = "FreeCamPart" freeCamPart.Size = Vector3.new(1,1,1)
    freeCamPart.Transparency = 1; freeCamPart.CanCollide = false; freeCamPart.Massless = true; freeCamPart.Anchored = false
    freeCamPart.CFrame = Workspace.CurrentCamera.CFrame; freeCamPart.Parent = Workspace
    
    freeCamVelocity = Instance.new("BodyVelocity") freeCamVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    freeCamVelocity.Velocity = Vector3.new(0,0,0); freeCamVelocity.Parent = freeCamPart
    
    Workspace.CurrentCamera.CameraSubject = freeCamPart; Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    
    freeCamConnection = RunService.RenderStepped:Connect(function()
        if not Hub.States.FreeCamEnabled or not freeCamPart or not freeCamPart.Parent then Hub.Functions.StopFreeCam() return end
        local moveDir = GetMovementDirection(Workspace.CurrentCamera.CFrame)
        freeCamVelocity.Velocity = moveDir * speed
    end)
end

local function StopFreeCam()
    if freeCamConnection then freeCamConnection:Disconnect() freeCamConnection = nil end
    if freeCamVelocity then freeCamVelocity:Destroy() freeCamVelocity = nil end
    if freeCamPart then freeCamPart:Destroy() freeCamPart = nil end
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart") local hum = char:FindFirstChild("Humanoid")
        if root then root.Anchored = false end
        if hum then hum.AutoRotate = true; Workspace.CurrentCamera.CameraSubject = hum; Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end
    end
end

local function UpdateWalkSpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        if hum.WalkSpeed ~= Hub.Config.SpeedValue then hum.WalkSpeed = Hub.Config.SpeedValue end
    end
end

task.spawn(function() while task.wait(0.5) do pcall(UpdateWalkSpeed) end end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        Hub.States.FlyEnabled = not Hub.States.FlyEnabled
        if Hub.States.FlyEnabled then
            if Hub.States.FreeCamEnabled then Hub.States.FreeCamEnabled = false; Hub.Functions.StopFreeCam() if Hub.UI.FreeCamToggle then Hub.UI.FreeCamToggle:Set(false) end end
            Hub.Functions.StartFly(Hub.Config.FlySpeed) if Hub.UI.FlyToggle then Hub.UI.FlyToggle:Set(true) end
        else Hub.Functions.StopFly() if Hub.UI.FlyToggle then Hub.UI.FlyToggle:Set(false) end end
    end
    if input.KeyCode == Enum.KeyCode.N then
        Hub.States.FreeCamEnabled = not Hub.States.FreeCamEnabled
        if Hub.States.FreeCamEnabled then
            if Hub.States.FlyEnabled then Hub.States.FlyEnabled = false; Hub.Functions.StopFly() if Hub.UI.FlyToggle then Hub.UI.FlyToggle:Set(false) end end
            Hub.Functions.StartFreeCam(Hub.Config.FreeCamSpeed) if Hub.UI.FreeCamToggle then Hub.UI.FreeCamToggle:Set(true) end
        else Hub.Functions.StopFreeCam() if Hub.UI.FreeCamToggle then Hub.UI.FreeCamToggle:Set(false) end end
    end
end)

-- Регистрация функций в глобальную таблицу
Hub.Functions.StartFly = StartFly
Hub.Functions.StopFly = StopFly
Hub.Functions.StartFreeCam = StartFreeCam
Hub.Functions.StopFreeCam = StopFreeCam
Hub.Functions.UpdateWalkSpeed = UpdateWalkSpeed
