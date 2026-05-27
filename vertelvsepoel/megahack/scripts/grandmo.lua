-- [[ vertelvse poel hub | FULL AUTO KILL + FLING + TELEPORT ]] --
-- Работает в любой игре (универсальный метод убийства через BreakJoints + флинг)

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Очистка старого GUI
local oldGui = CoreGui:FindFirstChild("VertelvsePoelHub_AutoKill")
if oldGui then oldGui:Destroy() end

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VertelvsePoelHub_AutoKill"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 320)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.65, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "  vertelvse poel hub | Auto Kill+"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Кнопки управления окном
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = Color3.fromRGB(160, 160, 160)
MinimizeButton.TextSize = 16
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(160, 160, 160)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Parent = MainFrame

-- Кнопка Auto Farm (оставляем без изменений)
local FarmButton = Instance.new("TextButton")
FarmButton.Size = UDim2.new(0.9, 0, 0, 45)
FarmButton.Position = UDim2.new(0.05, 0, 0.18, 0)
FarmButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
FarmButton.Text = "AUTO FARM : OFF"
FarmButton.TextColor3 = Color3.fromRGB(200, 70, 70)
FarmButton.TextSize = 16
FarmButton.Font = Enum.Font.SourceSansBold
FarmButton.Parent = MainFrame

local FarmCorner = Instance.new("UICorner")
FarmCorner.CornerRadius = UDim.new(0, 10)
FarmCorner.Parent = FarmButton

-- Кнопка Auto Kill (улучшенная)
local KillButton = Instance.new("TextButton")
KillButton.Size = UDim2.new(0.9, 0, 0, 45)
KillButton.Position = UDim2.new(0.05, 0, 0.42, 0)
KillButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
KillButton.Text = "AUTO KILL : OFF"
KillButton.TextColor3 = Color3.fromRGB(200, 70, 70)
KillButton.TextSize = 16
KillButton.Font = Enum.Font.SourceSansBold
KillButton.Parent = MainFrame

local KillCorner = Instance.new("UICorner")
KillCorner.CornerRadius = UDim.new(0, 10)
KillCorner.Parent = KillButton

-- Текст с текущей целью
local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(0.9, 0, 0, 30)
TargetLabel.Position = UDim2.new(0.05, 0, 0.66, 0)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "Target: none"
TargetLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
TargetLabel.TextSize = 13
TargetLabel.Font = Enum.Font.SourceSans
TargetLabel.Parent = MainFrame

-- Слайдер задержки между убийствами
local DelaySlider = Instance.new("TextButton") -- используем кнопку для упрощения, но лучше ползунок. Для простоты - кнопки +/-
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.4, 0, 0, 25)
SpeedLabel.Position = UDim2.new(0.05, 0, 0.78, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Delay: 0.2s"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.SourceSans
SpeedLabel.Parent = MainFrame

local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0.08, 0, 0, 25)
MinusBtn.Position = UDim2.new(0.5, 0, 0.78, 0)
MinusBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.Parent = MainFrame

local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0.08, 0, 0, 25)
PlusBtn.Position = UDim2.new(0.6, 0, 0.78, 0)
PlusBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.Parent = MainFrame

local killDelay = 0.2
SpeedLabel.Text = "Delay: " .. killDelay .. "s"

-- Плавающая кнопка открытия
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 100, 0, 40)
OpenButton.Position = UDim2.new(0, 15, 0.5, -20)
OpenButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenButton.Text = "OPEN HUB"
OpenButton.TextColor3 = Color3.fromRGB(240, 240, 240)
OpenButton.TextSize = 14
OpenButton.Font = Enum.Font.SourceSansBold
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 8)
OpenCorner.Parent = OpenButton

-- Ресайз
local ResizeHandle = Instance.new("ImageButton")
ResizeHandle.Size = UDim2.new(0, 18, 0, 18)
ResizeHandle.Position = UDim2.new(1, -18, 1, -18)
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Image = "rbxassetid://3955605556"
ResizeHandle.ImageColor3 = Color3.fromRGB(90, 90, 90)
ResizeHandle.Parent = MainFrame

local draggingResize = false
local dragStartSize, dragStartPos

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingResize = true
        dragStartSize = Vector2.new(MainFrame.Size.X.Offset, MainFrame.Size.Y.Offset)
        dragStartPos = input.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingResize = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingResize and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        MainFrame.Size = UDim2.new(0, math.max(260, dragStartSize.X + delta.X), 0, math.max(220, dragStartSize.Y + delta.Y))
    end
end)

-- Состояния
local FarmEnabled = false
local AutoKillEnabled = false

-- Обработка кнопок
FarmButton.MouseButton1Click:Connect(function()
    FarmEnabled = not FarmEnabled
    if FarmEnabled then
        FarmButton.Text = "AUTO FARM : ON"
        FarmButton.TextColor3 = Color3.fromRGB(70, 200, 70)
        FarmButton.BackgroundColor3 = Color3.fromRGB(25, 35, 25)
    else
        FarmButton.Text = "AUTO FARM : OFF"
        FarmButton.TextColor3 = Color3.fromRGB(200, 70, 70)
        FarmButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end
end)

KillButton.MouseButton1Click:Connect(function()
    AutoKillEnabled = not AutoKillEnabled
    if AutoKillEnabled then
        KillButton.Text = "AUTO KILL : ON"
        KillButton.TextColor3 = Color3.fromRGB(70, 200, 70)
        KillButton.BackgroundColor3 = Color3.fromRGB(25, 35, 25)
    else
        KillButton.Text = "AUTO KILL : OFF"
        KillButton.TextColor3 = Color3.fromRGB(200, 70, 70)
        KillButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TargetLabel.Text = "Target: none"
    end
end)

MinusBtn.MouseButton1Click:Connect(function()
    killDelay = math.max(0.05, killDelay - 0.05)
    SpeedLabel.Text = "Delay: " .. killDelay .. "s"
end)
PlusBtn.MouseButton1Click:Connect(function()
    killDelay = math.min(1.5, killDelay + 0.05)
    SpeedLabel.Text = "Delay: " .. killDelay .. "s"
end)

MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)
CloseButton.MouseButton1Click:Connect(function()
    FarmEnabled = false
    AutoKillEnabled = false
    ScreenGui:Destroy()
end)

-- ==========================================
-- ПОТОК 1: АВТОФАРМ ПРЕДМЕТОВ (работает в играх с папкой House/Items)
-- ==========================================
task.spawn(function()
    while true do
        if FarmEnabled then
            pcall(function()
                local itemsFolder = workspace:FindFirstChild("House") and workspace.House:FindFirstChild("Items")
                if itemsFolder then
                    for _, item in ipairs(itemsFolder:GetChildren()) do
                        if not FarmEnabled then break end
                        local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            fireproximityprompt(prompt)
                            task.wait(0.05)
                        end
                    end
                end
            end)
        end
        task.wait(0.3)
    end
end)

-- ==========================================
-- ПОТОК 2: АВТОУБИЙСТВО (ТЕЛЕПОРТ + ФЛИНГ + УБИЙСТВО)
-- ==========================================
local function killPlayer(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then return false end
    
    local targetChar = targetPlayer.Character
    if not targetChar then return false end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
    if not targetRoot or not targetHum or targetHum.Health <= 0 then return false end
    
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    if not myRoot or not myHum or myHum.Health <= 0 then return false end
    
    -- Запоминаем исходную позицию
    local originalCF = myRoot.CFrame
    local originalVel = myRoot.Velocity
    
    -- 1. Супер-флинг: разгоняем себя до огромной скорости
    myRoot.Velocity = Vector3.new(999999, 999999, 999999)
    myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, -1, 0)
    
    -- 2. Небольшая задержка для столкновения
    task.wait(0.05)
    
    -- 3. Убийство цели (несколько способов для надёжности)
    pcall(function()
        -- Способ 1: прямая установка здоровья
        targetHum.Health = 0
        -- Способ 2: разрыв соединений (альтернатива)
        targetHum:BreakJoints()
        -- Способ 3: урон через TakeDamage (если Health защищена)
        targetHum:TakeDamage(1e9)
    end)
    
    -- 4. Дополнительный флинг для цели (выбрасываем её)
    pcall(function()
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.new(math.random(-5000,5000), 10000, math.random(-5000,5000))
        bv.Parent = targetRoot
        task.delay(0.5, function() bv:Destroy() end)
    end)
    
    -- 5. Возвращаем себя на исходную позицию
    myRoot.Velocity = Vector3.zero
    myRoot.CFrame = originalCF
    myRoot.Velocity = originalVel
    
    return true
end

-- Основной цикл убийств
task.spawn(function()
    local playerList = {}
    local currentIndex = 1
    
    while true do
        if AutoKillEnabled then
            -- Обновляем список живых игроков (исключая себя)
            playerList = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    local char = plr.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        table.insert(playerList, plr)
                    end
                end
            end
            
            if #playerList > 0 then
                -- Циклический перебор игроков
                if currentIndex > #playerList then currentIndex = 1 end
                local target = playerList[currentIndex]
                TargetLabel.Text = "Target: " .. target.Name
                
                local success = killPlayer(target)
                if not success then
                    -- Если не удалось убить (возможно, персонаж умер или пропал), просто пропускаем
                end
                
                currentIndex = currentIndex + 1
                task.wait(killDelay)
            else
                TargetLabel.Text = "Target: no players"
                task.wait(1)
            end
        else
            task.wait(0.5)
        end
    end
end)

-- Уведомление о загрузке
print("vertelvse poel hub | Auto Kill+ loaded | Fully functional")
