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
    if gpe or GuiService:GetGuiObjectAtPosition(touch.Position) then return end
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
    local forward = cf.LookVector
    local right = cf.RightVector

    -- Управление ПК
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + forward end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - forward end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - right end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + right end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

    -- Мобильный джойстик (Левая часть экрана)
    if touchState.left.start and touchState.left.current then
        local delta = touchState.left.current - touchState.left.start
        if delta.Magnitude > 10 then
            local normDelta = delta.Unit
            moveDir = moveDir + (right * normDelta.X) - (forward * normDelta.Y)
        end
    end

    -- Мобильный взлет/вниз (Правая часть экрана)
    if touchState.right.start and touchState.right.current then
        local deltaY = touchState.right.start.Y - touchState.right.current.Y
        if math.abs(deltaY) > 20 then 
            moveDir = moveDir + Vector3.new(0, math.clamp(deltaY / 50, -1, 1), 0) 
        end
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
    
    hum.AutoRotate = false
    hum.WalkSpeed = 0
    
    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyVelocity.Parent = root
    
    flyConnection = RunService.RenderStepped:Connect(function()
        if not Hub.States.FlyEnabled or not LocalPlayer.Character then Hub.Functions.StopFly() return end
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then Hub.Functions.StopFly() return end
        
        local camera = Workspace.CurrentCamera
        local moveDir = GetMovementDirection(camera.CFrame)
        
        -- Поворачиваем персонажа по направлению камеры во время полета
        if moveDir.Magnitude > 0 then
            rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z))
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
        if hum then 
            hum.AutoRotate = true 
            hum.WalkSpeed = Hub.Config.SpeedValue or 16
        end
    end
end

-- ЛОКАЛЬНЫЕ ПЕРЕМЕННЫЕ FREECAM
local freeCamConnection = nil
local freeCamCFrame = CFrame.new()

local function StartFreeCam(speed)
    if freeCamConnection then return end
    local char = LocalPlayer.Character if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    root.Anchored = true
    freeCamCFrame = Workspace.CurrentCamera.CFrame
    Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    
    freeCamConnection = RunService.RenderStepped:Connect(function()
        if not Hub.States.FreeCamEnabled then Hub.Functions.StopFreeCam() return end
        
        local camera = Workspace.CurrentCamera
        local moveDir = GetMovementDirection(camera.CFrame)
        
        -- Свободная камера без уродливых невидимых парт
        freeCamCFrame = freeCamCFrame + (moveDir * (speed * RunService.RenderStepped:Wait()))
        
        -- Позволяем игроку вращать камеру мышкой/тачем, сохраняя движение
        local _, _, _, m00, m01, m02, m10, m11, m12, m20, m21, m22 = camera.CFrame:Components()
        camera.CFrame = CFrame.new(freeCamCFrame.Position.X, freeCamCFrame.Position.Y, freeCamCFrame.Position.Z, m00, m01, m02, m10, m11, m12, m20, m21, m22)
    end)
end

local function StopFreeCam()
    if freeCamConnection then freeCamConnection:Disconnect() freeCamConnection = nil end
    Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if root then root.Anchored = false end
        if hum then 
            Workspace.CurrentCamera.CameraSubject = hum
        end
    end
end

-- Исправленное обновление скорости (не ломает полет)
local function UpdateWalkSpeed()
    if Hub.States.FlyEnabled or Hub.States.FreeCamEnabled then return end -- Игнорируем проверку, если летим
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        local targetSpeed = Hub.Config.SpeedValue or 16
        if hum.WalkSpeed ~= targetSpeed then hum.WalkSpeed = targetSpeed end
    end
end

task.spawn(function() 
    while task.wait(0.5) do 
        pcall(UpdateWalkSpeed) 
    end 
end)

-- Хендлер кнопок (ПК)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        Hub.States.FlyEnabled = not Hub.States.FlyEnabled
        if Hub.States.FlyEnabled then
            if Hub.States.FreeCamEnabled then Hub.States.FreeCamEnabled = false; Hub.Functions.StopFreeCam() if Hub.UI.FreeCamToggle then Hub.UI.FreeCamToggle:Set(false) end end
            Hub.Functions.StartFly(Hub.Config.FlySpeed or 50) if Hub.UI.FlyToggle then Hub.UI.FlyToggle:Set(true) end
        else Hub.Functions.StopFly() if Hub.UI.FlyToggle then Hub.UI.FlyToggle:Set(false) end end
    end
    if input.KeyCode == Enum.KeyCode.N then
        Hub.States.FreeCamEnabled = not Hub.States.FreeCamEnabled
        if Hub.States.FreeCamEnabled then
            if Hub.States.FlyEnabled then Hub.States.FlyEnabled = false; Hub.Functions.StopFly() if Hub.UI.FlyToggle then Hub.UI.FlyToggle:Set(false) end end
            Hub.Functions.StartFreeCam(Hub.Config.FreeCamSpeed or 50) if Hub.UI.FreeCamToggle then Hub.UI.FreeCamToggle:Set(true) end
        else Hub.Functions.StopFreeCam() if Hub.UI.FreeCamToggle then Hub.UI.FreeCamToggle:Set(false) end end
    end
end)

-- Регистрация функций в глобальную таблицу
Hub.Functions.StartFly = StartFly
Hub.Functions.StopFly = StopFly
Hub.Functions.StartFreeCam = StartFreeCam
Hub.Functions.StopFreeCam = StopFreeCam
Hub.Functions.UpdateWalkSpeed = UpdateWalkSpeed
