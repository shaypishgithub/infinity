-- vertelvsepoel | Brookhaven RP - Modern GUI with Neon Black/White/Gray theme
-- All functions included, FPS counter, English UI

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- FPS Counter
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 100, 0, 30)
fpsLabel.Position = UDim2.new(1, -110, 0, 10)
fpsLabel.AnchorPoint = Vector2.new(1, 0)
fpsLabel.BackgroundTransparency = 0.5
fpsLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 14
fpsLabel.Text = "FPS: 0"
fpsLabel.BorderSizePixel = 0
fpsLabel.Parent = game:GetService("CoreGui")

local lastUpdate = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastUpdate >= 1 then
        fpsLabel.Text = "FPS: " .. frameCount
        frameCount = 0
        lastUpdate = now
    end
end)

-- Window
local Window = Rayfield:CreateWindow({
    Name = "vertelvsepoel | Brookhaven RP",
    LoadingTitle = "vertelvsepoel",
    LoadingSubtitle = "by vertelvsepoel",
    ConfigurationSaving = { Enabled = true, FolderName = "vertelvsepoel", FileName = "Settings" },
    Discord = { Enabled = false },
    KeySystem = false,
})

-- Tabs
local mainTab = Window:CreateTab("Functions", 4483362458)
local avatarTab = Window:CreateTab("Avatar", 4483362458)
local houseTab = Window:CreateTab("House", 4483362458)
local carTab = Window:CreateTab("Car", 4483362458)
local protectTab = Window:CreateTab("Protections", 4483362458)
local musicAllTab = Window:CreateTab("Music All", 4483362458)
local musicTab = Window:CreateTab("Music", 4483362458)
local trollTab = Window:CreateTab("Troll", 4483362458)
local attackTab = Window:CreateTab("Attack", 4483362458)
local scriptsTab = Window:CreateTab("Scripts", 4483362458)
local teleportsTab = Window:CreateTab("Teleports", 4483362458)
local rgbTab = Window:CreateTab("RGB", 4483362458)

-- ============================ MAIN FUNCTIONS ============================
mainTab:CreateSection("Movement")
mainTab:CreateSlider({ Name = "Walk Speed", Range = {16, 888}, Increment = 1, Suffix = "speed", CurrentValue = 16, Flag = "SpeedSlider", Callback = function(v)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
end })
mainTab:CreateSlider({ Name = "Jump Power", Range = {50, 500}, Increment = 1, Suffix = "power", CurrentValue = 50, Flag = "JumpSlider", Callback = function(v)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = v end
end })
mainTab:CreateSlider({ Name = "Gravity", Range = {0, 10000}, Increment = 1, Suffix = "gravity", CurrentValue = 196.2, Flag = "GravitySlider", Callback = function(v)
    Workspace.Gravity = v
end })
mainTab:CreateButton({ Name = "Reset Speed/Jump/Gravity", Callback = function()
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then
        c.Humanoid.WalkSpeed = 16
        c.Humanoid.JumpPower = 50
    end
    Workspace.Gravity = 196.2
end })

local infiniteJump = false
UserInputService.JumpRequest:Connect(function()
    if infiniteJump then
        local c = LocalPlayer.Character
        if c and c:FindFirstChild("Humanoid") then c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
mainTab:CreateToggle({ Name = "Infinite Jump", CurrentValue = false, Flag = "InfiniteJump", Callback = function(v) infiniteJump = v end })

mainTab:CreateButton({ Name = "Fly GUI (Universal)", Callback = function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Fly-gui-v3-30439"))()
end })

-- Headsit
mainTab:CreateSection("Headsit")
local headsitTarget = nil
local headsitActive = false
local function findPlayerByPartial(partial)
    partial = partial:lower()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Name:lower():sub(1, #partial) == partial then return p end
    end
    return nil
end
local function headsitOn(target)
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if not target.Character or not target.Character:FindFirstChild("Head") then return false end
    local head = target.Character.Head
    local root = c:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    root.CFrame = head.CFrame * CFrame.new(0, 2.2, 0)
    for _, w in pairs(root:GetChildren()) do if w:IsA("WeldConstraint") then w:Destroy() end end
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = head
    weld.Parent = root
    if h then h.Sit = true end
    return true
end
local function headsitOff()
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if root then for _, w in pairs(root:GetChildren()) do if w:IsA("WeldConstraint") then w:Destroy() end end end
    if h then h.Sit = false end
end
mainTab:CreateInput({ Name = "Player Name", PlaceholderText = "Enter name", RemoveTextAfterFocus = false, Callback = function(val)
    local found = findPlayerByPartial(val)
    if found then headsitTarget = found.Name end
end })
mainTab:CreateButton({ Name = "Toggle Headsit", Callback = function()
    if not headsitTarget then return end
    if not headsitActive then
        local t = Players:FindFirstChild(headsitTarget)
        if t and headsitOn(t) then headsitActive = true end
    else
        headsitOff()
        headsitActive = false
    end
end })

-- ============================ AVATAR ============================
avatarTab:CreateSection("Copy Avatar")
local copyTarget = nil
local function getPlayerNames()
    local t = {}
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(t, p.Name) end end
    return t
end
local playerDropdown = avatarTab:CreateDropdown({ Name = "Player List", Options = getPlayerNames(), CurrentOption = "", Flag = "AvatarPlayerList", Callback = function(opt) copyTarget = opt end })
avatarTab:CreateButton({ Name = "Refresh List", Callback = function() playerDropdown:SetOptions(getPlayerNames()) end })
avatarTab:CreateButton({ Name = "Copy Avatar", Callback = function()
    if not copyTarget then return end
    local tp = Players:FindFirstChild(copyTarget)
    if tp and tp.Character then
        local lc = LocalPlayer.Character
        local lh = lc and lc:FindFirstChildOfClass("Humanoid")
        local th = tp.Character:FindFirstChildOfClass("Humanoid")
        if lh and th then
            local ld = lh:GetAppliedDescription()
            for _, acc in ipairs(ld:GetAccessories(true)) do
                if acc.AssetId and tonumber(acc.AssetId) then
                    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Wear"):InvokeServer(tonumber(acc.AssetId))
                    task.wait(0.2)
                end
            end
            if tonumber(ld.Shirt) then ReplicatedStorage.Remotes.Wear:InvokeServer(tonumber(ld.Shirt)) task.wait(0.2) end
            if tonumber(ld.Pants) then ReplicatedStorage.Remotes.Wear:InvokeServer(tonumber(ld.Pants)) task.wait(0.2) end
            if tonumber(ld.Face) then ReplicatedStorage.Remotes.Wear:InvokeServer(tonumber(ld.Face)) task.wait(0.2) end
            local pd = th:GetAppliedDescription()
            local argsBody = { { pd.Torso, pd.RightArm, pd.LeftArm, pd.RightLeg, pd.LeftLeg, pd.Head } }
            ReplicatedStorage.Remotes.ChangeCharacterBody:InvokeServer(unpack(argsBody))
            task.wait(0.5)
            if tonumber(pd.Shirt) then ReplicatedStorage.Remotes.Wear:InvokeServer(tonumber(pd.Shirt)) task.wait(0.3) end
            if tonumber(pd.Pants) then ReplicatedStorage.Remotes.Wear:InvokeServer(tonumber(pd.Pants)) task.wait(0.3) end
            if tonumber(pd.Face) then ReplicatedStorage.Remotes.Wear:InvokeServer(tonumber(pd.Face)) task.wait(0.3) end
            for _, a in ipairs(pd:GetAccessories(true)) do
                if a.AssetId and tonumber(a.AssetId) then
                    ReplicatedStorage.Remotes.Wear:InvokeServer(tonumber(a.AssetId))
                    task.wait(0.3)
                end
            end
            local sc = tp.Character:FindFirstChild("Body Colors")
            if sc then ReplicatedStorage.Remotes.ChangeBodyColor:FireServer(tostring(sc.HeadColor)) task.wait(0.3) end
            if tonumber(pd.IdleAnimation) then ReplicatedStorage.Remotes.Wear:InvokeServer(tonumber(pd.IdleAnimation)) task.wait(0.3) end
            local bag = tp:FindFirstChild("PlayersBag")
            if bag then
                if bag:FindFirstChild("RPName") and bag.RPName.Value ~= "" then ReplicatedStorage.Remotes.RPNameText:FireServer("RolePlayName", bag.RPName.Value) end
                if bag:FindFirstChild("RPBio") and bag.RPBio.Value ~= "" then ReplicatedStorage.Remotes.RPNameText:FireServer("RolePlayBio", bag.RPBio.Value) end
                if bag:FindFirstChild("RPNameColor") then ReplicatedStorage.Remotes.RPNameColor:FireServer("PickingRPNameColor", bag.RPNameColor.Value) end
                if bag:FindFirstChild("RPBioColor") then ReplicatedStorage.Remotes.RPNameColor:FireServer("PickingRPBioColor", bag.RPBioColor.Value) end
            end
        end
    end
end })

avatarTab:CreateSection("3D Accessories")
local accessories = { "Gato de Manga", "Tung Saur", "Tralaleiro", "Monstro S.A", "Trenzinho", "Dino", "Pou idoso", "Coco/boxt@", "Coelho", "Hipopótamo" }
local accIds = { 124948425515124, 117098257036480, 99459753608381, 123609977175226, 80468697076178, 11941741105, 15742966010, 77013984520332, 71797333686800, 73215892129281 }
avatarTab:CreateDropdown({ Name = "Select Accessory", Options = accessories, CurrentOption = "", Flag = "AccDropdown", Callback = function(opt)
    for i, name in ipairs(accessories) do if name == opt then pcall(function() ReplicatedStorage.Remotes.Wear:InvokeServer(accIds[i]) end) break end end
end })
avatarTab:CreateButton({ Name = "Macaco Body", Callback = function()
    ReplicatedStorage.Remotes.ChangeCharacterBody:InvokeServer({79397492843080,128106725992124,129643681805465,121845409370294,124374125166137,133717899283546})
end })
avatarTab:CreateButton({ Name = "Mini Garanhao", Callback = function()
    ReplicatedStorage.Remotes.ChangeCharacterBody:InvokeServer({124355047456535,120507500641962,82273782655463,113625313757230,109182039511426,0})
end })
avatarTab:CreateButton({ Name = "Capybara", Callback = function()
    ReplicatedStorage.Remotes.ChangeCharacterBody:InvokeServer({98454038846291,93110795723782,131681603005543,107032747230578,129341990941517,109137349673343})
end })

-- ============================ HOUSE ============================
houseTab:CreateSection("House Functions")
local selectedHouse = nil
local function getHouses()
    local list = {}
    local lots = Workspace:FindFirstChild("001_Lots")
    if lots then for _, h in pairs(lots:GetChildren()) do if h.Name ~= "For Sale" and h:IsA("Model") then table.insert(list, h.Name) end end end
    return list
end
local houseDropdown = houseTab:CreateDropdown({ Name = "Select House", Options = getHouses(), CurrentOption = "", Flag = "HouseSelect", Callback = function(v) selectedHouse = v end })
houseTab:CreateButton({ Name = "Refresh Houses", Callback = function() houseDropdown:SetOptions(getHouses()) end })
houseTab:CreateButton({ Name = "Teleport to House", Callback = function()
    local h = Workspace["001_Lots"]:FindFirstChild(selectedHouse)
    if h and LocalPlayer.Character then LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(h.WorldPivot.Position) end
end })
houseTab:CreateButton({ Name = "Teleport to Safe", Callback = function()
    local h = Workspace["001_Lots"]:FindFirstChild(selectedHouse)
    if h and h:FindFirstChild("HousePickedByPlayer") and LocalPlayer.Character then
        local safe = h.HousePickedByPlayer.HouseModel:FindFirstChild("001_Safe")
        if safe then LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(safe.WorldPivot.Position) end
    end
end })
local doorNoClip = false
houseTab:CreateToggle({ Name = "Walk Through Door", CurrentValue = false, Flag = "NoClipDoor", Callback = function(state)
    doorNoClip = state
    local h = Workspace["001_Lots"]:FindFirstChild(selectedHouse)
    if h and h:FindFirstChild("HousePickedByPlayer") then
        local doors = h.HousePickedByPlayer.HouseModel:FindFirstChild("001_HouseDoors")
        if doors and doors:FindFirstChild("HouseDoorFront") then
            for _, part in ipairs(doors.HouseDoorFront:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = not state end end
        end
    end
end })
houseTab:CreateToggle({ Name = "Ring Doorbell", CurrentValue = false, Flag = "RingDoorbell", Callback = function(state)
    task.spawn(function()
        while state do
            local h = Workspace["001_Lots"]:FindFirstChild(selectedHouse)
            if h and h:FindFirstChild("HousePickedByPlayer") then
                local bell = h.HousePickedByPlayer.HouseModel:FindFirstChild("001_DoorBell")
                if bell and bell:FindFirstChild("TouchBell") then fireclickdetector(bell.TouchBell.ClickDetector) end
            end
            task.wait(0.5)
        end
    end)
end })
houseTab:CreateToggle({ Name = "Knock Door", CurrentValue = false, Flag = "KnockDoor", Callback = function(state)
    task.spawn(function()
        while state do
            local h = Workspace["001_Lots"]:FindFirstChild(selectedHouse)
            if h and h:FindFirstChild("HousePickedByPlayer") then
                local doors = h.HousePickedByPlayer.HouseModel:FindFirstChild("001_HouseDoors")
                if doors and doors:FindFirstChild("HouseDoorFront") and doors.HouseDoorFront:FindFirstChild("Knock") then
                    fireclickdetector(doors.HouseDoorFront.Knock.TouchBell.ClickDetector)
                end
            end
            task.wait(0.5)
        end
    end)
end })

houseTab:CreateSection("Quick Teleport to Houses")
local houseCoords = {
    ["House 1"] = Vector3.new(260.29,4.37,209.32), ["House 2"] = Vector3.new(234.49,4.37,228.00), ["House 3"] = Vector3.new(262.79,21.37,210.84),
    ["House 4"] = Vector3.new(229.60,21.37,225.40), ["House 5"] = Vector3.new(173.44,21.37,228.11), ["House 6"] = Vector3.new(-43,21,-137),
    ["House 7"] = Vector3.new(-40,36,-137), ["House 11"] = Vector3.new(-21,40,436), ["House 12"] = Vector3.new(155,37,433),
    ["House 13"] = Vector3.new(255,35,431), ["House 14"] = Vector3.new(254,38,394), ["House 15"] = Vector3.new(148,39,387),
    ["House 16"] = Vector3.new(-17,42,395), ["House 17"] = Vector3.new(-189,37,-247), ["House 18"] = Vector3.new(-354,37,-244),
    ["House 19"] = Vector3.new(-456,36,-245), ["House 20"] = Vector3.new(-453,38,-295), ["House 21"] = Vector3.new(-356,38,-294),
    ["House 22"] = Vector3.new(-187,37,-295), ["House 23"] = Vector3.new(-410,68,-447), ["House 24"] = Vector3.new(-348,69,-496),
    ["House 28"] = Vector3.new(-103,12,1087), ["House 29"] = Vector3.new(-730,6,808), ["House 30"] = Vector3.new(-245,7,822),
    ["House 31"] = Vector3.new(639,76,-361), ["House 32"] = Vector3.new(-908,6,-361), ["House 33"] = Vector3.new(-111,70,-417),
    ["House 34"] = Vector3.new(230,38,569), ["House 35"] = Vector3.new(-30,13,2209)
}
local houseNamesList = {}
for k,_ in pairs(houseCoords) do table.insert(houseNamesList, k) end
table.sort(houseNamesList)
houseTab:CreateDropdown({ Name = "Select House to Teleport", Options = houseNamesList, CurrentOption = "", Flag = "QuickHouse", Callback = function(opt)
    if LocalPlayer.Character then LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(houseCoords[opt]) end
end })

-- ============================ CAR ============================
carTab:CreateSection("Vehicle Functions")
local selectedCar = nil
local function getCars()
    local list = {}
    local vf = Workspace:FindFirstChild("Vehicles")
    if vf then for _, c in ipairs(vf:GetChildren()) do if c.Name:match("Car$") then table.insert(list, c.Name) end end end
    return list
end
local carDropdown = carTab:CreateDropdown({ Name = "Select Player Car", Options = getCars(), CurrentOption = "", Flag = "CarSelect", Callback = function(v) selectedCar = v end })
carTab:CreateButton({ Name = "Refresh Cars", Callback = function() carDropdown:SetOptions(getCars()) end })
carTab:CreateButton({ Name = "Destroy Selected Car", Callback = function()
    local vf = Workspace:FindFirstChild("Vehicles")
    local car = vf and vf:FindFirstChild(selectedCar)
    if car and LocalPlayer.Character then
        local seat = car:FindFirstChildWhichIsA("VehicleSeat", true)
        if seat and seat.Occupant == nil then
            local pos = LocalPlayer.Character.HumanoidRootPart.CFrame
            local hum = LocalPlayer.Character.Humanoid
            local fall = false
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                fall = true
            end
            seat:Sit(hum)
            task.wait(0.3)
            car:SetPrimaryPartCFrame(CFrame.new(0, -1000, 0))
            task.wait(0.5)
            LocalPlayer.Character.HumanoidRootPart.CFrame = pos
            if fall then hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true) end
            LocalPlayer.Character.Humanoid.Sit = false
        end
    end
end })
carTab:CreateButton({ Name = "Bring Selected Car", Callback = function()
    local vf = Workspace:FindFirstChild("Vehicles")
    local car = vf and vf:FindFirstChild(selectedCar)
    if car and LocalPlayer.Character then
        local seat = car:FindFirstChildWhichIsA("VehicleSeat", true)
        if seat and seat.Occupant == nil then
            local pos = LocalPlayer.Character.HumanoidRootPart.Position
            local hum = LocalPlayer.Character.Humanoid
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            seat:Sit(hum)
            task.wait(0.3)
            car:SetPrimaryPartCFrame(CFrame.new(pos + Vector3.new(5,0,5)))
            task.wait(0.5)
            hum.Sit = false
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        end
    end
end })
carTab:CreateButton({ Name = "Bring All Cars", Callback = function()
    local vf = Workspace:FindFirstChild("Vehicles")
    if not vf then return end
    local pos = LocalPlayer.Character.HumanoidRootPart.Position
    local hum = LocalPlayer.Character.Humanoid
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    for _, car in ipairs(vf:GetChildren()) do
        if car.Name:match("Car$") then
            local seat = car:FindFirstChildWhichIsA("VehicleSeat", true)
            if seat and seat.Occupant == nil then
                seat:Sit(hum)
                task.wait(0.2)
                car:SetPrimaryPartCFrame(CFrame.new(pos + Vector3.new(5,0,5)))
                task.wait(0.2)
                hum.Sit = false
            end
        end
    end
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
end })
carTab:CreateToggle({ Name = "Camera on Selected Car", CurrentValue = false, Flag = "CarCam", Callback = function(state)
    local vf = Workspace:FindFirstChild("Vehicles")
    local car = vf and vf:FindFirstChild(selectedCar)
    if car then
        local seat = car:FindFirstChildWhichIsA("VehicleSeat", true)
        if seat then Workspace.CurrentCamera.CameraSubject = state and seat or LocalPlayer.Character.Humanoid end
    end
end })

-- ============================ PROTECTIONS ============================
protectTab:CreateSection("Anti-Fling & Anti-Bug")
protectTab:CreateButton({ Name = "Anti-Fling (Irreversible)", Callback = function()
    RunService.Stepped:Connect(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                for _, part in pairs(p.Character:GetChildren()) do if part.Name == "HumanoidRootPart" then part.CanCollide = false end end
            end
        end
        for _, a in pairs(Workspace:GetChildren()) do if a:IsA("Accessory") and a:FindFirstChildWhichIsA("Part") then a:FindFirstChildWhichIsA("Part"):Destroy() end end
    end)
end })
protectTab:CreateButton({ Name = "Anti-Bug (Water etc)", Callback = function()
    local blacklist = {{Name="water", Class="Part"}}
    local function kill(obj) pcall(function() obj.Anchored = true obj.CanCollide = false obj:Destroy() end) end
    workspace.DescendantAdded:Connect(function(obj)
        for _, r in ipairs(blacklist) do if obj.Name == r.Name and obj.ClassName == r.Class then kill(obj) end end
    end)
    for _, obj in ipairs(workspace:GetDescendants()) do
        for _, r in ipairs(blacklist) do if obj.Name == r.Name and obj.ClassName == r.Class then kill(obj) end end
    end
    task.spawn(function()
        while task.wait(0.25) do
            for _, v in next, getnilinstances() do
                for _, r in ipairs(blacklist) do if v.Name == r.Name and v.ClassName == r.Class then kill(v) end end
            end
        end
    end)
end })

-- ============================ MUSIC ALL ============================
musicAllTab:CreateSection("Play Sound for Everyone")
local globalSoundId = ""
musicAllTab:CreateInput({ Name = "Sound ID", PlaceholderText = "Enter ID", RemoveTextAfterFocus = false, Callback = function(v) globalSoundId = tonumber(v) end })
local function playGlobalSound(id)
    local remote = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1Gu1nSound1s")
    if remote then remote:FireServer(Workspace, id, 1) end
    local s = Instance.new("Sound", Workspace)
    s.SoundId = "rbxassetid://" .. id
    s:Play()
    task.wait(3)
    s:Destroy()
end
musicAllTab:CreateButton({ Name = "Play", Callback = function() if globalSoundId then playGlobalSound(globalSoundId) end end })
local loopGlobal = false
musicAllTab:CreateToggle({ Name = "Loop", CurrentValue = false, Flag = "LoopGlobal", Callback = function(state)
    loopGlobal = state
    task.spawn(function() while loopGlobal do if globalSoundId then playGlobalSound(globalSoundId) end task.wait(1) end end)
end })

musicAllTab:CreateSection("Memes & Effects")
local memes = { "pankapakan", "Gemido ultra rápido", "vai g0z@?", "nao choraxxx", "G0z33iiii", "Hommmm", "gemido2", "sus sex", "Hentai wiaaaaan", "ai meu c*zinho slowed", "Loly gemiD0", "ai poison", "chegachega SUS", "uwu", "ai meu cuzin", "girl audio 2", "Hoo ze da manga", "ai alexandre de moraes", "haaii meme", "GoGogo gogogo", "Toma jack", "Toma jackV2", "Toma jack no sol quente", "ifood", "pelo geito ela ta querendo ram", "lula vai todo mundo", "coringa", "shoope", "quenojo", "sai dai lava prato", "se e loko numconpeça", "mita sequer que eu too uma", "Deita aqui eu mandei vc deitar sirens", "miau", "skibidi", "BIRULEIBI", "biseabesjnjkasnakjsndjkafb", "vai corinthians!!....", "my sigman", "mama", "OH MY GOD", "aahhh plankton meme", "CHINABOY", "PASTOR MIRIM E A LÍNGUA DOS ANJOS", "Sai d3sgraç@", "opa salve tudo bem?", "OLHA O CARRO DO DANONE", "Nãoooo, Nãoooo, Nãooo!!!!!", "UM PÉ DE SIRIGUELA KK", "e o carro da pamonha", "BOM DIAAAAAAAAAA", "ai-meu-chiclete", "posso te ligar ou tua mulher...", "Boa chi joga muito cara", "Oqueee meme", "kkk muito fei", "lula cade o ze gotinha", "morreu", "a-pia-ta-cheia-de-louca", "Mahito killSong", "Sucumba", "nem clicou o thurzin", "fiui OLHA MENSAGEM", "tooomeee", "risada de ladrao", "E o PIX nada ainda", "Vo nada vo nada", "Eli gosta", "um cavalo de tres pernas?", "voces sao um bado de fdp", "HAHA TROLEI ATÉ VOCÊ", "Calaboca Kenga", "alvincut", "e a risada faz como?", "voce deve se m@t4", "receba", "UUIIII", "sai", "risada boa dms", "vacilo perna de pau", "gomo gomo no!!!", "arroto", "iraaaa", "não fica se achando muito não", "WhatsApp notificaçaoV1", "WhatsApp notificaçaoV2", "SamsungV1", "SamsungV2", "Shiiii", "ai_tomaa miku", "Miku Miku", "kuru_kuru", "PM ROCAM", "cavalo!!", "deixa os garoto brinca", "flamengo", "sai do mei satnas", "namoral agora e a hora", "n pode me chutar pq seu celebro e burro", "vc ta fudido vou te pegar", "deley", "Tu e um beta", "Porfavor n tira eu nao", "Olá beleza vc pode me dá muitos", "Discord sus", "rojao apito", "off", "Kazuma kazuma", "sometourado", "Estouradoespad", "Alaku bommm", "busss", "Estourado wItb", "sla", "HA HA HA" }
local memeIds = { 122547522269143,128863565301778,116293771329297,94377077452021,93462644278510,133135656929513,92186909873950,128137573022197,88332347208779,71895544093312,119277017538197,115870718113313,77405864184828,76820720070248,130714479795369,84207358477461,106624090319571,107261471941570,120006672159037,103262503950995,132603645477541,100446887985203,97476487963273,133843750864059,94395705857835,136804576009416,84663543883498,8747441609,103440368630269,101232400175829,78442476709262,94889439372168,100291188941582,131804436682424,128771670035179,121569761604968,133106998846260,127012936767471,103431815659907,106850066985594,73349649774476,95982351322190,84403553163931,71153532555470,106973692977609,80870678096428,110493863773948,95825536480898,112804043442210,94951629392683,136579844511260,92911732806153,103211341252816,110707564387669,120092799810101,79241074803021,86012585992725,8872409975,98076927129047,128669424001766,7946300950,84428355313544,121668429878811,128319664118768,133065882609605,113831443375212,89093085290586,105012436535315,8164241439,8232773326,7021794555,86494561679259,88788640194373,140713372459057,100227426848009,94142662616215,73210569653520,121169949217007,127589011971759,106809680656199,137067472449625,140203378050178,136752451575091,101588606280167,107004225739474,18850631582,123767635061073,96579234730244,120566727202986,139770074770361,72812231495047,122465710753374,96161547081609,78871573440184,80291355054807,137774355552052,127944706557246,120677947987369,82284055473737,120214772725166,102906880476838,130233956349541,85321374020324,74235334504693,122662798976905,6549021381,1778829098,127954653962405,123592956882621,136179020015211,110796593805268,139841197791567,137478052262430,116672405522828,138236682866721 }
musicAllTab:CreateDropdown({ Name = "Select Meme", Options = memes, CurrentOption = "", Flag = "MemeDropdown", Callback = function(opt)
    for i, name in ipairs(memes) do if name == opt then playGlobalSound(memeIds[i]) break end end
end })

local effects = { "jumpscar", "n se preocupe", "eles estao todos mortos", "gritoestourado", "gritomedo", "Nukesiren", "nuclear sirenv2", "Alertescola", "Memealertsiren", "sirenv3", "Alarm estourAAAA...", "MegaMan Alarm", "Alarm bookhaven", "alet malaysia", "Risada", "Hahahah", "scream", "Terrified meme scream", "Sonic.exe Scream Effect", "Demon Scream", "SCP 096 Scream (raging)", "Nightmare Yelling Bursts", "HORROR SCREAM 07", "Female Scream Woman Screams", "Scream1", "Scream2", "scary maze scream", "SammyClassicSonicFan's Scream", "FNAF 2 Death Scream", "cod zombie scream", "Slendytubbies- CaveTubby Scream", "FNAF 2 Death Scream", "HORROR SCREAM 15", "Jumpscare Scream", "FNaF: Security Breach", "llllllll", "loud jumpscare", "fnaf", "Pinkamena Jumpscare 1", "Ennard Jumpscare 2", "a sla medo dino", "Backrooms Bacteria Pitfalls ", "error Infinite", "Screaming Meme", "Jumpscare - SCP CB", "mirror jumpscare", "PTLD 39 Jumpscare", "jumpscare:Play()", "mimic jumpscare", "DOORS Glitch Jumpscare Sound", "FNAS 4 Nightmare Mario", "Death House I Jumpscare Sound", "Shinky Jumpscare", "FNaTI Jumpscare Oblitus casa", "fnaf jumpscare loadmode" }
local effectIds = { 91784486966761,87041057113780,70605158718179,7520729342,113029085566978,9067330158,675587093,6607047008,8379374771,6766811806,93354528379052,1442382907,1526192493,7714172940,79191730206814,90096947219465,314568939,5853668794,146563959,2738830850,343430735,9125713501,9043345732,9114397912,1319496541,199978176,270145703,143942090,1572549161,8566359672,1482639185,5537531920,9043346574,6150329916,2050522547,5029269312,7236490488,6982454389,192334186,629526707,125506416092123,81325342128575,3893790326,107732411055226,97098997494905,80005164589425,5581462381,121519648044128,91998575878959,96377507894391,99804224106385,8151488745,123447772144411,18338717319,18911896588 }
musicAllTab:CreateDropdown({ Name = "Effects / Screamers", Options = effects, CurrentOption = "", Flag = "EffectDropdown", Callback = function(opt)
    for i, name in ipairs(effects) do if name == opt then playGlobalSound(effectIds[i]) break end end
end })

-- ============================ MUSIC (Radio/House/Car) ============================
musicTab:CreateSection("Play Music on Radio / House / Car")
local function playOnAll(id)
    local re = ReplicatedStorage:WaitForChild("RE")
    re:FindFirstChild("PlayerToolEvent"):FireServer("ToolMusicText", id)
    re:FindFirstChild("1Player1sHous1e"):FireServer("PickHouseMusicText", id)
    re:FindFirstChild("1Player1sCa1r"):FireServer("PickingCarMusicText", id)
    re:FindFirstChild("1NoMoto1rVehicle1s"):FireServer("PickingScooterMusicText", id)
end
musicTab:CreateInput({ Name = "Music ID", PlaceholderText = "Enter ID", Callback = function(v) if v ~= "" then playOnAll(tostring(v)) end end })
musicTab:CreateButton({ Name = "Stop All Music", Callback = function() playOnAll("") end })

musicTab:CreateSection("Forró")
local forro = { "forró ja cansou", "lenbro ate hoje", "escolha certa", "forró da rezenha", "forró dudu", "forró sao joao", "forró engraçado paia", "100% forro vaquejada", "PASTOR MIRIM E A LÍNGUA DOS ANJOS", "PARA NÃO ESQUECER QUEM SOMOS", "Uno zero", "Iate do neymar", "Batidao na aldeia" }
local forroIds = { 74812784884330,71531533552899,107088620814881,120973520531216,74404168179733,106364874935196,76524290482399,92295159623916,71153532555470,88937498361674,112959083808887,135738534706063,79953696595578 }
musicTab:CreateDropdown({ Name = "Forró", Options = forro, CurrentOption = "", Flag = "Forro", Callback = function(opt)
    for i, n in ipairs(forro) do if n == opt then playOnAll(forroIds[i]) break end end
end })

musicTab:CreateSection("Funk")
local funk = { "Deixa eu mandar meu passinho", "CVRL", "Empina na onda", "TOMA LÁ DA CÁ", "fuga na viatura", "funkphonk fumando verde", "moça sai da sacada.", "pre treino", "batida Brega Violino (Beat Brega Funk)", "Dança do Canguru (Pke Gaz1nh)", "MONTAGEM ARABIANA (Pke Gaz1nh)", "Manda o papo (NGI)", "Viver bem", "Faixa estronda", "Ritmo Pixelado", "Viagem Sonora", "Melodia Virtual", "Melodia Serena", "SENTA", "TUNG TUNG TUNG TUNG SAHUR PHONK BRASILEIRO", "crazy-lol", "V7", "UIUAH", "meta ritmo", "Brasil funk", "haha (NGI)", "DO PO" }
local funkIds = { 77741294709660,124244582950595,104621031886653,71590664026646,131891110268352,112143944982807,6093993662,136869502216760,99399643204701,86876136192157,78076624091098,132642647937688,82805460494325,121187736532042,93928823862203,79349174602261,139147474886402,97011217688307,124085422276732,120353876640055,106958630419629,80348640826643,82894376737849,110091098283354,116733221731811,122114766584918,114207745067816 }
musicTab:CreateDropdown({ Name = "Funk", Options = funk, CurrentOption = "", Flag = "Funk", Callback = function(opt)
    for i, n in ipairs(funk) do if n == opt then playOnAll(funkIds[i]) break end end
end })

musicTab:CreateSection("Phonk (many)")
local phonk = {}
for i = 1, 70 do phonk[i] = "Phonk " .. i end
local phonkIds = { 118507373399694,91502410121438,72720721570850,102333419023382,122871512353520,111668097052966,93786060174790,77501611905348,126887144190812,88033569921555,132436320685732,105832154444494,90323407842935,132245626038510,111995323199676,115016589376700,118740708757685,139435437308948,109189438638906,105126065014034,138487820505005,87968531262747,106317184644394,112068892721408,122852029094656,91760524161503,73140398421340,137962454483542,84733736048142,106322173003761,94604796823780,118063577904953,115567432786512,71304501822029,132218979961283,102708912256857,140642559093189,13530439660,87863924786534,133135085604736,97258811783169,92308400487695,88064647826500,92175624643620,108099943758978,109784877184952,114608169341947,111346133543699,77857496821844,123809083385992,81929101024622,74564219749776,118225359190317,115317874112657,96249826607044,88038595663211,124958445624871,88551699463723,82148953715595,118959437310311,126291069838831,122706595087279,122338822665007,96180057167470,74281337525581,86928685812280,116461681407294,109308273341422,125181345407169,71123357599630,86537505028256,134770548505933,137135395010424,70900514961735,110519906029322,91834632690710,98371771055411,98267810117949,117668905142866,103695219371872,123517126955383,102771149931910,127870227978818,130525387712209,97662362226511,125858109122379,139825057894568,139768056738146,92572896648274,98711199754623,130633105268814,87115976125426,82705137378395,79381341943021,105882833374061,139593870988593,73966367524216,133814632960968,132015050363205,129151948619922,114994598691121,103445348511856 }
musicTab:CreateDropdown({ Name = "Phonk", Options = phonk, CurrentOption = "", Flag = "Phonk", Callback = function(opt)
    local num = tonumber(opt:match("%d+"))
    if num and phonkIds[num] then playOnAll(phonkIds[num]) end
end })

-- ============================ TROLL ============================
trollTab:CreateSection("Kill / Pull")
local trollTarget = nil
local killMethod = "Sofá"
trollTab:CreateDropdown({ Name = "Player", Options = {}, CurrentOption = "", Flag = "TrollPlayer", Callback = function(opt) trollTarget = Players:FindFirstChild(opt) end })
trollTab:CreateDropdown({ Name = "Kill Method", Options = { "Sofá", "Ônibus" }, CurrentOption = "Sofá", Flag = "KillMethod", Callback = function(opt) killMethod = opt end })
local killActive = false
local killConn = nil
local function stopKill() killActive = false if killConn then killConn:Disconnect() killConn = nil end end
local function equipCouch()
    local bp = LocalPlayer.Backpack
    local couch = bp:FindFirstChild("Couch") or LocalPlayer.Character:FindFirstChild("Couch")
    if not couch then
        ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Too1l"):InvokeServer("PickingTools", "Couch")
        repeat task.wait() until bp:FindFirstChild("Couch")
        couch = bp.Couch
    end
    couch.Parent = LocalPlayer.Character
    return couch
end
trollTab:CreateButton({ Name = "Kill", Callback = function()
    if not trollTarget then return end
    stopKill()
    killActive = true
    if killMethod == "Sofá" then
        equipCouch()
        local origPos = LocalPlayer.Character.HumanoidRootPart.Position
        killConn = RunService.Heartbeat:Connect(function()
            if not killActive or not trollTarget.Character then return end
            local pos = trollTarget.Character.HumanoidRootPart.Position
            LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(pos) * CFrame.Angles(0, math.rad(Workspace.DistributedGameTime * 15000), 0))
            if trollTarget.Character.Humanoid.Sit then
                killActive = false
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(origPos)
            end
        end)
    elseif killMethod == "Ônibus" then
        local args = { "DeleteAllVehicles" }
        ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer(unpack(args))
        task.wait(0.5)
        ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer("PickingCar", "SchoolBus")
        task.wait(1)
        local bus = Workspace.Vehicles:FindFirstChild(LocalPlayer.Name .. "Car")
        if bus then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1171, 79, -1166)
            task.wait(0.5)
            LocalPlayer.Character.Humanoid.Sit = true
            killConn = RunService.Heartbeat:Connect(function()
                if not killActive or not trollTarget.Character then return end
                local pos = trollTarget.Character.HumanoidRootPart.Position
                bus:SetPrimaryPartCFrame(CFrame.new(pos) * CFrame.Angles(0, math.rad(Workspace.DistributedGameTime * 15000), 0))
            end)
        end
    end
end })
trollTab:CreateButton({ Name = "Pull (Sofá only)", Callback = function()
    if not trollTarget or killMethod ~= "Sofá" then return end
    stopKill()
    killActive = true
    equipCouch()
    local origPos = LocalPlayer.Character.HumanoidRootPart.Position
    killConn = RunService.Heartbeat:Connect(function()
        if not killActive or not trollTarget.Character then return end
        local pos = trollTarget.Character.HumanoidRootPart.Position
        LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(pos) * CFrame.Angles(0, math.rad(Workspace.DistributedGameTime * 15000), 0))
        if (LocalPlayer.Character.HumanoidRootPart.Position - pos).magnitude < 5 then
            killActive = false
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(origPos)
        end
    end)
end })
trollTab:CreateButton({ Name = "Stop Kill/Pull", Callback = stopKill })

trollTab:CreateSection("Fling (Various Methods)")
local flingTarget = nil
local flingMethod = "Sofá"
trollTab:CreateDropdown({ Name = "Player for Fling", Options = {}, CurrentOption = "", Flag = "FlingPlayer", Callback = function(opt) flingTarget = Players:FindFirstChild(opt) end })
trollTab:CreateDropdown({ Name = "Fling Method", Options = { "Sofá", "Ônibus", "Bola", "Bola V2", "Barco", "Caminhão" }, CurrentOption = "Sofá", Flag = "FlingMethod", Callback = function(opt) flingMethod = opt end })
local flingActive = false
local flingConn = nil
local function stopFling()
    flingActive = false
    if flingConn then flingConn:Disconnect() flingConn = nil end
    local args = { "DeleteAllVehicles" }
    pcall(function() ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer(unpack(args)) end)
end
local function equipBall()
    local bp = LocalPlayer.Backpack
    local ball = bp:FindFirstChild("SoccerBall") or LocalPlayer.Character:FindFirstChild("SoccerBall")
    if not ball then
        ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Too1l"):InvokeServer("PickingTools", "SoccerBall")
        repeat task.wait() until bp:FindFirstChild("SoccerBall")
        ball = bp.SoccerBall
    end
    ball.Parent = LocalPlayer.Character
    return ball
end
trollTab:CreateButton({ Name = "Start Fling with Selected Method", Callback = function()
    if not flingTarget then return end
    stopFling()
    flingActive = true
    if flingMethod == "Sofá" then
        equipCouch()
        local couch = LocalPlayer.Character:FindFirstChild("Couch")
        if couch and couch:IsA("BasePart") then couch.Anchored = false couch.CanCollide = true end
        local origPos = LocalPlayer.Character.HumanoidRootPart.Position
        flingConn = RunService.Heartbeat:Connect(function()
            if not flingActive or not flingTarget.Character then return end
            local pos = flingTarget.Character.HumanoidRootPart.Position
            LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(pos))
            if (LocalPlayer.Character.HumanoidRootPart.Position - pos).magnitude < 5 then
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Velocity = Vector3.new(math.random(-5,5), 50, math.random(-5,5)).Unit * 1e7
                bv.Parent = LocalPlayer.Character.HumanoidRootPart
                task.delay(1, function() bv:Destroy() end)
                flingActive = false
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(origPos)
            end
        end)
    elseif flingMethod == "Bola" or flingMethod == "Bola V2" then
        equipBall()
        ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("PlayerWantsToDeleteTool", "SoccerBall")
        task.wait(0.5)
        local ball = Workspace:FindFirstChild("WorkspaceCom") and Workspace.WorkspaceCom:FindFirstChild("001_SoccerBalls") and Workspace.WorkspaceCom["001_SoccerBalls"]:FindFirstChild("Soccer" .. LocalPlayer.Name)
        if ball then
            ball.Anchored = false
            ball.CanCollide = true
            flingConn = RunService.Heartbeat:Connect(function()
                if not flingActive or not flingTarget.Character then return end
                local hrp = flingTarget.Character.HumanoidRootPart
                ball.CFrame = CFrame.new(hrp.Position + Vector3.new(0,1,0))
                ball.AssemblyLinearVelocity = Vector3.new(9999, 9999, 9999)
                if (ball.Position - hrp.Position).magnitude < 4 then
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    bv.Velocity = Vector3.new(math.random(-5,5), 50, math.random(-5,5)).Unit * 1e6
                    bv.Parent = hrp
                    task.delay(0.3, function() bv:Destroy() end)
                end
            end)
        end
    elseif flingMethod == "Ônibus" or flingMethod == "Barco" or flingMethod == "Caminhão" then
        local vehicleType = flingMethod == "Ônibus" and "SchoolBus" or (flingMethod == "Barco" and "MilitaryBoatFree" or "Semi")
        local args = { "DeleteAllVehicles" }
        ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer(unpack(args))
        task.wait(0.5)
        ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer("PickingCar", vehicleType)
        task.wait(1)
        local veh = Workspace.Vehicles:FindFirstChild(LocalPlayer.Name .. "Car")
        if veh then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1171, 79, -1166)
            task.wait(0.5)
            LocalPlayer.Character.Humanoid.Sit = true
            flingConn = RunService.Heartbeat:Connect(function()
                if not flingActive or not flingTarget.Character then return end
                local pos = flingTarget.Character.HumanoidRootPart.Position + Vector3.new(math.random(-10,10), 0, math.random(-10,10))
                veh:SetPrimaryPartCFrame(CFrame.new(pos) * CFrame.Angles(0, math.rad(Workspace.DistributedGameTime * 15000), 0))
            end)
        end
    end
end })
trollTab:CreateButton({ Name = "Stop Fling", Callback = stopFling })

trollTab:CreateSection("Fling All Players")
local flingAllActive = false
local flingAllConn = nil
trollTab:CreateButton({ Name = "Fling All (Ball)", Callback = function()
    if flingAllActive then return end
    flingAllActive = true
    equipBall()
    ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("PlayerWantsToDeleteTool", "SoccerBall")
    task.wait(0.5)
    local ball = Workspace:FindFirstChild("WorkspaceCom") and Workspace.WorkspaceCom:FindFirstChild("001_SoccerBalls") and Workspace.WorkspaceCom["001_SoccerBalls"]:FindFirstChild("Soccer" .. LocalPlayer.Name)
    if ball then
        ball.Anchored = false
        ball.CanCollide = true
        flingAllConn = RunService.Heartbeat:Connect(function()
            if not flingAllActive then return end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    ball.CFrame = CFrame.new(hrp.Position + Vector3.new(0,1,0))
                    ball.AssemblyLinearVelocity = Vector3.new(9999, 9999, 9999)
                    if (ball.Position - hrp.Position).magnitude < 4 then
                        local bv = Instance.new("BodyVelocity")
                        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                        bv.Velocity = Vector3.new(math.random(-5,5), 50, math.random(-5,5)).Unit * 1e6
                        bv.Parent = hrp
                        task.delay(0.3, function() bv:Destroy() end)
                    end
                end
            end
        end)
    end
end })
trollTab:CreateButton({ Name = "Stop All Fling", Callback = function()
    flingAllActive = false
    if flingAllConn then flingAllConn:Disconnect() flingAllConn = nil end
end })

-- ============================ ATTACK SERVER ============================
attackTab:CreateSection("Lag / Attacks")
attackTab:CreateButton({ Name = "Lag with Laptop", Callback = function()
    local laptop = Workspace:FindFirstChild("WorkspaceCom") and Workspace.WorkspaceCom:FindFirstChild("001_GiveTools") and Workspace.WorkspaceCom["001_GiveTools"]:FindFirstChild("Laptop")
    if laptop then
        for _ = 1, 999999 do
            LocalPlayer.Character.HumanoidRootPart.CFrame = laptop.CFrame
            fireclickdetector(laptop.ClickDetector)
            task.wait()
        end
    end
end })
attackTab:CreateButton({ Name = "Lag with Bomb", Callback = function()
    local bomb = Workspace:FindFirstChild("WorkspaceCom") and Workspace.WorkspaceCom:FindFirstChild("001_CriminalWeapons") and Workspace.WorkspaceCom["001_CriminalWeapons"]:FindFirstChild("GiveTools") and Workspace.WorkspaceCom["001_CriminalWeapons"]["GiveTools"]:FindFirstChild("Bomb")
    if bomb then
        for _ = 1, 999999 do
            LocalPlayer.Character.HumanoidRootPart.CFrame = bomb.CFrame
            fireclickdetector(bomb.ClickDetector)
            task.wait()
        end
    end
end })
attackTab:CreateButton({ Name = "Giant Joust Red N4zi (Dupe)", Callback = function()
    local tool = "JoustRed"
    local dupeAmt = 175
    local pick = ReplicatedStorage.RE:FindFirstChild("1Too1l")
    local oldCF = LocalPlayer.Character.HumanoidRootPart.CFrame
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(999999999, -490, 999999999)
    task.wait(0.2)
    LocalPlayer.Character.HumanoidRootPart.Anchored = true
    for _, t in pairs(LocalPlayer.Character:GetChildren()) do if t:IsA("Tool") and t.Name ~= tool then t.Parent = LocalPlayer.Backpack end end
    for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do if t:IsA("Tool") and t.Name ~= tool then t:Destroy() end end
    for i = 1, dupeAmt do
        pick:InvokeServer("PickingTools", tool)
        LocalPlayer.Backpack:WaitForChild(tool).Parent = LocalPlayer.Character
        task.wait()
        LocalPlayer.Character[tool]:FindFirstChild("Handle").Name = "HandleX"
        LocalPlayer.Character[tool].Parent = LocalPlayer.Backpack
        LocalPlayer.Backpack[tool].Parent = LocalPlayer.Character
        repeat task.wait() until LocalPlayer.Character:FindFirstChild(tool) == nil
    end
    LocalPlayer.Character.HumanoidRootPart.Anchored = false
    LocalPlayer.Character.HumanoidRootPart.CFrame = oldCF
end })

attackTab:CreateSection("Tornado & Domains")
attackTab:CreateButton({ Name = "[OP] Tornado - Pirate Ship", Callback = function()
    local rs = ReplicatedStorage
    local player = LocalPlayer
    local char = player.Character
    local root = char.HumanoidRootPart
    root.CFrame = CFrame.new(1754, -2, 58)
    task.wait(0.5)
    rs.RE:FindFirstChild("1Ca1r"):FireServer("PickingBoat", "PirateFree")
    task.wait(1)
    local boat = Workspace.Vehicles:FindFirstChild(player.Name .. "Car")
    if boat then
        local seat = boat:FindFirstChild("Body") and boat.Body:FindFirstChild("VehicleSeat")
        if seat then
            repeat task.wait(0.1) root.CFrame = seat.CFrame * CFrame.new(0,1,0) until char.Humanoid.SeatPart == seat
            local way = { Vector3.new(-16,0,-47), Vector3.new(-110,0,-45), Vector3.new(16,0,-55) }
            local idx = 1
            RunService.Heartbeat:Connect(function(dt)
                if not boat.Parent then return end
                local target = way[idx+1] or way[1]
                local pos = boat.PrimaryPart.Position:Lerp(target, 0.05)
                boat:SetPrimaryPartCFrame(CFrame.new(pos) * CFrame.Angles(0, math.rad(Workspace.DistributedGameTime * 360), 0))
                if (pos - target).magnitude < 1 then idx = idx % #way + 1 end
            end)
        end
    end
end })
attackTab:CreateButton({ Name = "Cancel Tornado", Callback = function()
    ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer("DeleteAllVehicles")
end })

attackTab:CreateButton({ Name = "Domain Expansion (Attack All)", Callback = function()
    _G.Dominio = true
    local esfera = Instance.new("Part")
    esfera.Shape = Enum.PartType.Ball
    esfera.Size = Vector3.new(300,300,300)
    esfera.Position = LocalPlayer.Character.HumanoidRootPart.Position
    esfera.Anchored = true
    esfera.CanCollide = false
    esfera.Material = Enum.Material.ForceField
    esfera.Transparency = 0.3
    esfera.Color = Color3.fromRGB(0,0,0)
    esfera.Parent = workspace
    local ps = Instance.new("ParticleEmitter", esfera)
    ps.Texture = "rbxassetid://243660364"
    ps.Color = ColorSequence.new(Color3.fromRGB(0,153,255))
    ps.Rate = 1000
    local som = Instance.new("Sound", esfera)
    som.SoundId = "rbxassetid://1843527678"
    som.Volume = 2
    som.Looped = true
    som:Play()
    task.spawn(function()
        while _G.Dominio do
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local remote = ReplicatedStorage.RE:FindFirstChild("1Gu1n")
                    if remote then
                        remote:FireServer(p.Character.HumanoidRootPart, p.Character.HumanoidRootPart, Vector3.new(1e14,1e14,1e14), p.Character.HumanoidRootPart.Position, nil, nil, 0, 0, {false}, {25, Vector3.new(100,100,100), BrickColor.new(29), 0.25, Enum.Material.SmoothPlastic, 0.25}, true, false)
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end })
attackTab:CreateButton({ Name = "Cancel Domain", Callback = function()
    _G.Dominio = false
    for _, v in pairs(workspace:GetChildren()) do if v:IsA("Part") and v.Size == Vector3.new(300,300,300) then v:Destroy() end end
end })

attackTab:CreateButton({ Name = "Sharingan (Attack)", Callback = function()
    _G.Sharingan = true
    local esfera = Instance.new("Part")
    esfera.Shape = Enum.PartType.Ball
    esfera.Size = Vector3.new(300,300,300)
    esfera.Position = LocalPlayer.Character.HumanoidRootPart.Position
    esfera.Anchored = true
    esfera.CanCollide = false
    esfera.Material = Enum.Material.ForceField
    esfera.Transparency = 0.3
    esfera.Color = Color3.fromRGB(0,0,0)
    esfera.Parent = workspace
    local luz = Instance.new("PointLight", esfera)
    luz.Color = Color3.fromRGB(255,0,0)
    luz.Brightness = 10
    luz.Range = 300
    task.spawn(function()
        while _G.Sharingan do
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local remote = ReplicatedStorage.RE:FindFirstChild("1Gu1n")
                    if remote then
                        remote:FireServer(p.Character.HumanoidRootPart, p.Character.HumanoidRootPart, Vector3.new(1e14,1e14,1e14), p.Character.HumanoidRootPart.Position, nil, nil, 0, 0, {false}, {25, Vector3.new(100,100,100), BrickColor.new(29), 0.25, Enum.Material.SmoothPlastic, 0.25}, true, false)
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end })
attackTab:CreateButton({ Name = "Cancel Sharingan", Callback = function()
    _G.Sharingan = false
    for _, v in pairs(workspace:GetChildren()) do if v:IsA("Part") and v.Size == Vector3.new(300,300,300) then v:Destroy() end end
end })

attackTab:CreateButton({ Name = "Skybox FE (Animation)", Callback = function()
    local args = { { 100839513065432 } }
    ReplicatedStorage.Remotes.ChangeCharacterBody:InvokeServer(unpack(args))
    local hum = LocalPlayer.Character.Humanoid
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://101852027997337"
    local track = hum:LoadAnimation(anim)
    track:Play()
    task.wait(0.5)
    local plank = Instance.new("Animation")
    plank.AnimationId = "rbxassetid://3695333486"
    local pTrack = hum:LoadAnimation(plank)
    pTrack:Play()
end })
attackTab:CreateButton({ Name = "Reset Skybox", Callback = function()
    ReplicatedStorage.Remotes.ResetCharacterAppearance:FireServer()
    task.wait(0.3)
    LocalPlayer.Character.Humanoid.Health = 0
end })

-- ============================ SCRIPTS ============================
scriptsTab:CreateSection("Universal Scripts")
scriptsTab:CreateButton({ Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end })
scriptsTab:CreateButton({ Name = "Reverso", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/0Ben1/fe./main/L"))() end })
scriptsTab:CreateButton({ Name = "Rochips", Callback = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-rochips-universal-18294"))() end })
scriptsTab:CreateButton({ Name = "System FPS", Callback = function() loadstring(game:HttpGet("https://pastefy.app/V3NtNvZx/raw"))() end })
scriptsTab:CreateButton({ Name = "FE Jerk Off Hub Matrix", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ExploitFin/AquaMatrix/refs/heads/AquaMatrix/AquaMatrix"))() end })
scriptsTab:CreateButton({ Name = "TP Tool", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/err0r129/KptHadesBlair/main/Bao.lua"))() end })
scriptsTab:CreateSection("Brookhaven Specific")
scriptsTab:CreateButton({ Name = "System Brook", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/H20CalibreYT/SystemBroken/main/script"))() end })
scriptsTab:CreateButton({ Name = "Sander X", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/kigredns/SanderXV4.2.2/refs/heads/main/New.lua"))() end })
scriptsTab:CreateButton({ Name = "RD4", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/M1ZZ001/BrookhavenR4D/main/Brookhaven%20R4D%20Script"))() end })

-- ============================ TELEPORTS ============================
teleportsTab:CreateSection("Teleport to Locations")
local locs = {
    ["Morro"] = Vector3.new(-348.64,65.94,-458.08), ["Plaza"] = Vector3.new(-26.17,3.48,-0.93), ["Bank"] = Vector3.new(1.99,3.32,236.65),
    ["Hospital"] = Vector3.new(-303.2,3.40,13.74), ["City Hall"] = Vector3.new(-354.65,7.32,-102.16), ["Farm"] = Vector3.new(-766.41,2.92,-61.10),
    ["Market"] = Vector3.new(16.31,3.32,-107.07), ["Mall"] = Vector3.new(151.05,3.52,-190.64), ["Airport"] = Vector3.new(290.23,4.32,42.57),
    ["Hotel"] = Vector3.new(159.10,3.32,164.97), ["Beach 1"] = Vector3.new(55.69,2.94,-1403.60), ["Beach 2"] = Vector3.new(42.39,2.94,1336.14)
}
local locNames = {}
for k,_ in pairs(locs) do table.insert(locNames, k) end
table.sort(locNames)
teleportsTab:CreateDropdown({ Name = "Select Location", Options = locNames, CurrentOption = "", Flag = "TeleLoc", Callback = function(opt)
    if LocalPlayer.Character then LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(locs[opt]) end
end })

-- ============================ RGB ============================
rgbTab:CreateSection("RGB Effects")
local rgbSpeedVal = 1
rgbTab:CreateSlider({ Name = "RGB Speed", Range = {1,5}, Increment = 1, CurrentValue = 3, Flag = "RGBSpeed", Callback = function(v) rgbSpeedVal = v end })
local function rainbow() return Color3.fromHSV((tick() * rgbSpeedVal % 5)/5, 1, 1) end
local function fireNameColor(c) local ev = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1RPNam1eColo1r"); if ev then ev:FireServer("PickingRPNameColor", c) end end
local function fireBioColor(c) local ev = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1RPNam1eColo1r"); if ev then ev:FireServer("PickingRPBioColor", c) end end
rgbTab:CreateToggle({ Name = "RGB Name", CurrentValue = false, Flag = "NameRGB", Callback = function(s) task.spawn(function() while s do fireNameColor(rainbow()) task.wait(0.1) end end) end })
rgbTab:CreateToggle({ Name = "RGB Bio", CurrentValue = false, Flag = "BioRGB", Callback = function(s) task.spawn(function() while s do fireBioColor(rainbow()) task.wait(0.1) end end) end })
rgbTab:CreateToggle({ Name = "RGB Body", CurrentValue = false, Flag = "BodyRGB", Callback = function(s) task.spawn(function() while s do local rem = ReplicatedStorage:FindFirstChild("Remotes"); if rem and rem:FindFirstChild("ChangeBodyColor") then rem.ChangeBodyColor:FireServer(BrickColor.new(rainbow())) end task.wait(0.1) end end) end })
rgbTab:CreateToggle({ Name = "RGB Hair", CurrentValue = false, Flag = "HairRGB", Callback = function(s) task.spawn(function() while s do local ev = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1Max1y"); if ev then ev:FireServer("ChangeHairColor2", rainbow()) end task.wait(0.5) end end) end })
rgbTab:CreateToggle({ Name = "RGB House", CurrentValue = false, Flag = "HouseRGB", Callback = function(s) task.spawn(function() while s do local ev = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1Player1sHous1e"); if ev then ev:FireServer("ColorPickHouse", rainbow()) end task.wait(0.1) end end) end })
rgbTab:CreateToggle({ Name = "RGB Car (Premium)", CurrentValue = false, Flag = "CarRGB", Callback = function(s) task.spawn(function() while s do local ev = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1Player1sCa1r"); if ev then ev:FireServer("PickingCarColor", rainbow()) end task.wait(0.05) end end) end })
rgbTab:CreateToggle({ Name = "RGB Bike", CurrentValue = false, Flag = "BikeRGB", Callback = function(s) task.spawn(function() while s do local ev = ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1Player1sCa1r"); if ev then ev:FireServer("NoMotorColor", rainbow()) end task.wait(0.1) end end) end })
rgbTab:CreateToggle({ Name = "RGB Radio", CurrentValue = false, Flag = "RadioRGB", Callback = function(s) task.spawn(function() while s do local gui = LocalPlayer:FindFirstChild("PlayerGui"); if gui then local props = gui:FindFirstChild("ToolGui") and gui.ToolGui:FindFirstChild("ToolSettings") and gui.ToolGui.ToolSettings:FindFirstChild("Settings") and gui.ToolGui.ToolSettings.Settings:FindFirstChild("PropsColor"); if props and props:FindFirstChild("SetColor") then props.SetColor:FireServer(rainbow()) end end task.wait(0.05) end end) end })

-- Player list updates
local function updatePlayerLists()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(names, p.Name) end end
    pcall(function() trollTab:GetFlag("TrollPlayer"):SetOptions(names) end)
    pcall(function() trollTab:GetFlag("FlingPlayer"):SetOptions(names) end)
    pcall(function() avatarTab:GetFlag("AvatarPlayerList"):SetOptions(names) end)
end
Players.PlayerAdded:Connect(updatePlayerLists)
Players.PlayerRemoving:Connect(updatePlayerLists)
updatePlayerLists()

-- Reset headsit on respawn
LocalPlayer.CharacterAdded:Connect(function()
    if headsitActive then headsitOff() headsitActive = false end
end)

print("vertelvsepoel | Script loaded successfully")
