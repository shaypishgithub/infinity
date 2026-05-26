--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
--RELOAD GUI
if game.CoreGui:FindFirstChild("SysBroker") then
	game:GetService("StarterGui"):SetCore("SendNotification", {Title = "System Broken",Text = "GUI Already loaded, rejoin to re-execute",Duration = 5;})
	return
end
local version = 2
--VARIABLES
_G.AntiFlingToggled = false
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Light = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local mouse = plr:GetMouse()
local ScriptWhitelist = {}
local ForceWhitelist = {}
local TargetedPlayer = nil
local FlySpeed = 50
local PotionTool = nil
local SavedCheckpoint = nil
local MinesFolder = nil
local FreeEmotesEnabled = false
local CannonsFolders = {}

pcall(function()
	MinesFolder = game:GetService("Workspace").Landmines
	for i,v in pairs(game:GetService("Workspace"):GetChildren()) do
		if v.Name == "Cannons" then
			table.insert(CannonsFolders, v)
		end
	end
end)

--ФУНКЦИИ (без изменений)
_G.shield = function(id)
	if not table.find(ForceWhitelist,id) then
		table.insert(ForceWhitelist, id)
	end
end

local function RandomChar()
	local length = math.random(1,5)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

local function ChangeToggleColor(Button)
	led = Button.Ticket_Asset
	if led.ImageColor3 == Color3.fromRGB(255, 0, 0) then
		led.ImageColor3 = Color3.fromRGB(0, 255, 0)
	else
		led.ImageColor3 = Color3.fromRGB(255, 0, 0)
	end
end

local function GetPing()
	return (game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())/1000
end

local function GetPlayer(UserDisplay)
	if UserDisplay ~= "" then
        for i,v in pairs(Players:GetPlayers()) do
            if v.Name:lower():match(UserDisplay) or v.DisplayName:lower():match(UserDisplay) then
                return v
            end
        end
		return nil
	else
		return nil
    end
end

local function GetCharacter(Player)
	if Player.Character then
		return Player.Character
	end
end

local function GetRoot(Player)
	if GetCharacter(Player):FindFirstChild("HumanoidRootPart") then
		return GetCharacter(Player).HumanoidRootPart
	end
end

local function TeleportTO(posX,posY,posZ,player,method)
	pcall(function()
		if method == "safe" then
			task.spawn(function()
				for i = 1,30 do
					task.wait()
					GetRoot(plr).Velocity = Vector3.new(0,0,0)
					if player == "pos" then
						GetRoot(plr).CFrame = CFrame.new(posX,posY,posZ)
					else
						GetRoot(plr).CFrame = CFrame.new(GetRoot(player).Position)+Vector3.new(0,2,0)
					end
				end
			end)
		else
			GetRoot(plr).Velocity = Vector3.new(0,0,0)
			if player == "pos" then
				GetRoot(plr).CFrame = CFrame.new(posX,posY,posZ)
			else
				GetRoot(plr).CFrame = CFrame.new(GetRoot(player).Position)+Vector3.new(0,2,0)
			end
		end
	end)
end

local function PredictionTP(player,method)
	local root = GetRoot(player)
	local pos = root.Position
	local vel = root.Velocity
	GetRoot(plr).CFrame = CFrame.new((pos.X)+(vel.X)*(GetPing()*3.5),(pos.Y)+(vel.Y)*(GetPing()*2),(pos.Z)+(vel.Z)*(GetPing()*3.5))
	if method == "safe" then
		task.wait()
		GetRoot(plr).CFrame = CFrame.new(pos)
		task.wait()
		GetRoot(plr).CFrame = CFrame.new((pos.X)+(vel.X)*(GetPing()*3.5),(pos.Y)+(vel.Y)*(GetPing()*2),(pos.Z)+(vel.Z)*(GetPing()*3.5))
	end
end

local function Touch(x,root)
	pcall(function()
		x = x:FindFirstAncestorWhichIsA("Part")
		if x then
			if firetouchinterest then
				task.spawn(function()
					firetouchinterest(x, root, 1)
					task.wait()
					firetouchinterest(x, root, 0)
				end)
			end
		end
	end)
end

local function GetPush()
	local TempPush = nil
	pcall(function()
		if plr.Backpack:FindFirstChild("Push") then
			PushTool = plr.Backpack.Push
			PushTool.Parent = plr.Character
			TempPush = PushTool
		end
		for i,v in pairs(Players:GetPlayers()) do
			if v.Character:FindFirstChild("Push") then
				TempPush = v.Character.Push
			end
		end
	end)
	return TempPush
end

local function CheckPotion()
	if plr.Backpack:FindFirstChild("potion") then
		PotionTool = plr.Backpack:FindFirstChild("potion")
		return true
	elseif plr.Character:FindFirstChild("potion") then
		PotionTool = plr.Character:FindFirstChild("potion")
		return true
	else
		return false
	end
end

local function Push(Target)
	local Push = GetPush()
	local FixTool = nil
	if Push ~= nil then
		local args = {[1] = Target.Character}
		GetPush().PushTool:FireServer(unpack(args))
	end
	if plr.Character:FindFirstChild("Push") then
		plr.Character.Push.Parent = plr.Backpack
	end
	if plr.Character:FindFirstChild("ModdedPush") then
		FixTool = plr.Character:FindFirstChild("ModdedPush")
		FixTool.Parent = plr.Backpack
		FixTool.Parent = plr.Character
	end
	if plr.Character:FindFirstChild("ClickTarget") then
		FixTool = plr.Character:FindFirstChild("ClickTarget")
		FixTool.Parent = plr.Backpack
		FixTool.Parent = plr.Character
	end
	if plr.Character:FindFirstChild("potion") then
		FixTool = plr.Character:FindFirstChild("potion")
		FixTool.Parent = plr.Backpack
		FixTool.Parent = plr.Character
	end
end

local function ToggleRagdoll(bool)
	pcall(function()
		plr.Character["Falling down"].Disabled = bool
		plr.Character["Swimming"].Disabled = bool
		plr.Character["StartRagdoll"].Disabled = bool
		plr.Character["Pushed"].Disabled = bool
		plr.Character["RagdollMe"].Disabled = bool
	end)
end

local function ToggleVoidProtection(bool)
	if bool then
		game.Workspace.FallenPartsDestroyHeight = 0/0
	else
		game.Workspace.FallenPartsDestroyHeight = -500
	end
end

local function PlayAnim(id,time,speed)
	pcall(function()
		plr.Character.Animate.Disabled = false
		local hum = plr.Character.Humanoid
		local animtrack = hum:GetPlayingAnimationTracks()
		for i,track in pairs(animtrack) do
			track:Stop()
		end
		plr.Character.Animate.Disabled = true
		local Anim = Instance.new("Animation")
		Anim.AnimationId = "rbxassetid://"..id
		local loadanim = hum:LoadAnimation(Anim)
		loadanim:Play()
		loadanim.TimePosition = time
		loadanim:AdjustSpeed(speed)
		loadanim.Stopped:Connect(function()
			plr.Character.Animate.Disabled = false
			for i, track in pairs (animtrack) do
        		track:Stop()
    		end
		end)
	end)
end

local function StopAnim()
	plr.Character.Animate.Disabled = false
    local animtrack = plr.Character.Humanoid:GetPlayingAnimationTracks()
    for i, track in pairs (animtrack) do
        track:Stop()
    end
end

local function SendNotify(title, message, duration)
	game:GetService("StarterGui"):SetCore("SendNotification", {Title = title,Text = message,Duration = duration;})
end

-- НОВЫЙ СТИЛЬ - ЧЕРНЫЙ НЕОН С АНИМАЦИЕЙ ПЕРЕЛИВА (КРАСНЫЙ)
local SysBroker = Instance.new("ScreenGui")
local Background = Instance.new("ImageLabel")
local TitleBarLabel = Instance.new("TextLabel")
local SectionList = Instance.new("Frame")
local Home_Section_Button = Instance.new("TextButton")
local Game_Section_Button = Instance.new("TextButton")
local Character_Section_Button = Instance.new("TextButton")
local Target_Section_Button = Instance.new("TextButton")
local Animations_Section_Button = Instance.new("TextButton")
local Misc_Section_Button = Instance.new("TextButton")
local Credits_Section_Button = Instance.new("TextButton")

local Game_Section = Instance.new("ScrollingFrame")
local AntiRagdoll_Button = Instance.new("TextButton")
local PotionFling_Button = Instance.new("TextButton")
local SpamMines_Button = Instance.new("TextButton")
local PushAura_Button = Instance.new("TextButton")

local Home_Section = Instance.new("ScrollingFrame")
local Welcome_Label = Instance.new("TextLabel")
local Announce_Label = Instance.new("TextLabel")

local Character_Section = Instance.new("ScrollingFrame")
local WalkSpeed_Button = Instance.new("TextButton")
local WalkSpeed_Input = Instance.new("TextBox")

local Target_Section = Instance.new("ScrollingFrame")
local TargetName_Input = Instance.new("TextBox")

local Animations_Section = Instance.new("ScrollingFrame")
local VampireAnim_Button = Instance.new("TextButton")

local Misc_Section = Instance.new("ScrollingFrame")
local AntiFling_Button = Instance.new("TextButton")

local Credits_Section = Instance.new("ScrollingFrame")
local Credits_Label = Instance.new("TextLabel")

-- Добавим скругления для всех основных элементов
local function ApplyNeonStyle(obj, cornerRadius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, cornerRadius or 8)
	corner.Parent = obj
	obj.BackgroundColor3 = Color3.fromRGB(25,25,25)
	if obj:IsA("TextButton") or obj:IsA("TextBox") then
		obj.BorderColor3 = Color3.fromRGB(255, 0, 0) -- КРАСНЫЙ ЦВЕТ РАМКИ
		obj.BorderSizePixel = 1
		obj.TextColor3 = Color3.fromRGB(220,220,220)
	end
end

-- Создание GUI с новым стилем
SysBroker.Name = "SysBroker"
SysBroker.Parent = game.CoreGui
SysBroker.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SysBroker.Enabled = true

Background.Name = "Background"
Background.Parent = SysBroker
Background.AnchorPoint = Vector2.new(0.5, 0.5)
Background.BackgroundColor3 = Color3.fromRGB(20,20,20)
Background.BorderColor3 = Color3.fromRGB(255, 0, 0)
Background.BorderSizePixel = 2
Background.Position = UDim2.new(0.5, 0, 0.5, 0)
Background.Size = UDim2.new(0, 500, 0, 350)
Background.ZIndex = 9
Background.Image = "rbxassetid://159991693"
Background.ImageColor3 = Color3.fromRGB(200, 0, 0)
Background.ImageTransparency = 0.85
Background.ScaleType = Enum.ScaleType.Tile
Background.SliceCenter = Rect.new(0, 256, 0, 256)
Background.TileSize = UDim2.new(0, 30, 0, 30)
Background.Active = true
Background.Draggable = true
Background.Visible = true

-- Скругление фона
local bgCorner = Instance.new("UICorner")
bgCorner.CornerRadius = UDim.new(0, 12)
bgCorner.Parent = Background

-- Градиент для перелива КРАСНЫЙ с анимацией
local bgGradient = Instance.new("UIGradient")
bgGradient.Rotation = 0
bgGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(20,20,20)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80,20,20)), -- Ярко красный оттенок
	ColorSequenceKeypoint.new(1, Color3.fromRGB(20,20,20))
}
bgGradient.Parent = Background

-- Анимация перелива ОПТИМИЗИРОВАННАЯ
task.spawn(function()
	while Background and Background.Parent do
		TweenService:Create(bgGradient, TweenInfo.new(3, Enum.EasingStyle.Linear), {Rotation = 360}):Play()
		task.wait(3)
	end
end)

TitleBarLabel.Name = "TitleBarLabel"
TitleBarLabel.Parent = Background
TitleBarLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitleBarLabel.BackgroundTransparency = 0.4
TitleBarLabel.BorderColor3 = Color3.fromRGB(255, 0, 0)
TitleBarLabel.BorderSizePixel = 1
TitleBarLabel.Size = UDim2.new(1, 0, 0, 30)
TitleBarLabel.Font = Enum.Font.Unknown
TitleBarLabel.Text = "____/SYSTEMBROKEN\\___"
TitleBarLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
TitleBarLabel.TextScaled = true
TitleBarLabel.TextSize = 14.000
TitleBarLabel.TextWrapped = true
TitleBarLabel.TextXAlignment = Enum.TextXAlignment.Left
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = TitleBarLabel

SectionList.Name = "SectionList"
SectionList.Parent = Background
SectionList.BackgroundColor3 = Color3.fromRGB(15,15,15)
SectionList.BackgroundTransparency = 0.3
SectionList.BorderColor3 = Color3.fromRGB(255, 0, 0)
SectionList.BorderSizePixel = 1
SectionList.Position = UDim2.new(0, 0, 0, 30)
SectionList.Size = UDim2.new(0, 105, 0, 320)
local sectionCorner = Instance.new("UICorner")
sectionCorner.CornerRadius = UDim.new(0, 8)
sectionCorner.Parent = SectionList

-- Стилизация кнопок секций
local function styleSectionButton(btn)
	ApplyNeonStyle(btn, 6)
	btn.BackgroundColor3 = Color3.fromRGB(10,10,10)
	btn.BackgroundTransparency = 0.4
	btn.TextColor3 = Color3.fromRGB(255, 0, 0)
end

Home_Section_Button.Name = "Home_Section_Button"
Home_Section_Button.Parent = SectionList
Home_Section_Button.Position = UDim2.new(0, 0, 0, 25)
Home_Section_Button.Size = UDim2.new(0, 105, 0, 30)
Home_Section_Button.Font = Enum.Font.Oswald
Home_Section_Button.Text = "Home"
Home_Section_Button.TextScaled = true
Home_Section_Button.TextSize = 14.000
Home_Section_Button.TextWrapped = true
styleSectionButton(Home_Section_Button)

Game_Section_Button.Name = "Game_Section_Button"
Game_Section_Button.Parent = SectionList
Game_Section_Button.Position = UDim2.new(0, 0, 0, 65)
Game_Section_Button.Size = UDim2.new(0, 105, 0, 30)
Game_Section_Button.Font = Enum.Font.Oswald
Game_Section_Button.Text = "Game"
Game_Section_Button.TextScaled = true
styleSectionButton(Game_Section_Button)

Character_Section_Button.Name = "Character_Section_Button"
Character_Section_Button.Parent = SectionList
Character_Section_Button.Position = UDim2.new(0, 0, 0, 105)
Character_Section_Button.Size = UDim2.new(0, 105, 0, 30)
Character_Section_Button.Font = Enum.Font.Oswald
Character_Section_Button.Text = "Character"
Character_Section_Button.TextScaled = true
styleSectionButton(Character_Section_Button)

Target_Section_Button.Name = "Target_Section_Button"
Target_Section_Button.Parent = SectionList
Target_Section_Button.Position = UDim2.new(0, 0, 0, 145)
Target_Section_Button.Size = UDim2.new(0, 105, 0, 30)
Target_Section_Button.Font = Enum.Font.Oswald
Target_Section_Button.Text = "Target"
Target_Section_Button.TextScaled = true
styleSectionButton(Target_Section_Button)

Animations_Section_Button.Name = "Animations_Section_Button"
Animations_Section_Button.Parent = SectionList
Animations_Section_Button.Position = UDim2.new(0, 0, 0, 185)
Animations_Section_Button.Size = UDim2.new(0, 105, 0, 30)
Animations_Section_Button.Font = Enum.Font.Oswald
Animations_Section_Button.Text = "Animations"
Animations_Section_Button.TextScaled = true
styleSectionButton(Animations_Section_Button)

Misc_Section_Button.Name = "Misc_Section_Button"
Misc_Section_Button.Parent = SectionList
Misc_Section_Button.Position = UDim2.new(0, 0, 0, 225)
Misc_Section_Button.Size = UDim2.new(0, 105, 0, 30)
Misc_Section_Button.Font = Enum.Font.Oswald
Misc_Section_Button.Text = "Misc"
Misc_Section_Button.TextScaled = true
styleSectionButton(Misc_Section_Button)

Credits_Section_Button.Name = "Credits_Section_Button"
Credits_Section_Button.Parent = SectionList
Credits_Section_Button.Position = UDim2.new(0, 0, 0, 265)
Credits_Section_Button.Size = UDim2.new(0, 105, 0, 30)
Credits_Section_Button.Font = Enum.Font.Oswald
Credits_Section_Button.Text = "Credits"
Credits_Section_Button.TextScaled = true
styleSectionButton(Credits_Section_Button)

-- Настройка фреймов секций (ScrollingFrames)
local function styleScrollFrame(frame)
	frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
	frame.BackgroundTransparency = 0.2
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame
	frame.BorderColor3 = Color3.fromRGB(255,0,0)
	frame.BorderSizePixel = 1
	frame.Size = UDim2.new(0, 395, 0, 320)
	frame.Position = UDim2.new(0, 105, 0, 30)
	frame.ZIndex = 10
	frame.ScrollBarThickness = 5
	frame.CanvasSize = UDim2.new(0, 0, 0, 500)
end

-- Привязка всех секций к основному окну Background
Home_Section.Parent = Background
Game_Section.Parent = Background
Character_Section.Parent = Background
Target_Section.Parent = Background
Animations_Section.Parent = Background
Misc_Section.Parent = Background
Credits_Section.Parent = Background

styleScrollFrame(Home_Section)
styleScrollFrame(Game_Section)
styleScrollFrame(Character_Section)
styleScrollFrame(Target_Section)
styleScrollFrame(Animations_Section)
styleScrollFrame(Misc_Section)
styleScrollFrame(Credits_Section)

-- По умолчанию открыта домашняя страница
Home_Section.Visible = true
Game_Section.Visible = false
Character_Section.Visible = false
Target_Section.Visible = false
Animations_Section.Visible = false
Misc_Section.Visible = false
Credits_Section.Visible = false

-- Функция для переключения категорий при нажатии (ИСПРАВЛЕНО)
local allSections = {
	[Home_Section_Button] = Home_Section,
	[Game_Section_Button] = Game_Section,
	[Character_Section_Button] = Character_Section,
	[Target_Section_Button] = Target_Section,
	[Animations_Section_Button] = Animations_Section,
	[Misc_Section_Button] = Misc_Section,
	[Credits_Section_Button] = Credits_Section
}

for button, section in pairs(allSections) do
	button.MouseButton1Click:Connect(function()
		-- Скрываем все секции
		for _, s in pairs(allSections) do
			s.Visible = false
		end
		-- Показываем только выбранную
		section.Visible = true
	end)
end

-- Сворачивание/Разворачивание GUI на кнопку B (ИСПРАВЛЕНО)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end
	if input.KeyCode == Enum.KeyCode.B then
		Background.Visible = not Background.Visible
	end
end)

-- Стилизация кнопок действий внутри категорий
local function styleActionButton(btn)
	ApplyNeonStyle(btn, 6)
	btn.BackgroundColor3 = Color3.fromRGB(25,25,25)
	btn.BackgroundTransparency = 0.3
	btn.TextColor3 = Color3.fromRGB(200,200,200)
	btn.BorderColor3 = Color3.fromRGB(255,0,0)
	btn.TextSize = 12
	
	local hover = btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(40,20,20)}):Play()
	end)
	local leave = btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3, BackgroundColor3 = Color3.fromRGB(25,25,25)}):Play()
	end)
	btn.Destroying:Connect(function()
		hover:Disconnect()
		leave:Disconnect()
	end)
end

-- Добавляем примеры кнопок в каждую секцию

-- HOME SECTION
Welcome_Label.Parent = Home_Section
Welcome_Label.Text = "ДОБРО ПОЖАЛОВАТЬ В SYSTEM BROKEN!"
Welcome_Label.TextScaled = true
Welcome_Label.BackgroundTransparency = 0.8
Welcome_Label.Size = UDim2.new(1, 0, 0, 50)
Welcome_Label.Position = UDim2.new(0, 0, 0, 10)
Welcome_Label.TextColor3 = Color3.fromRGB(255, 0, 0)

-- GAME SECTION
AntiRagdoll_Button.Parent = Game_Section
AntiRagdoll_Button.Name = "AntiRagdoll"
AntiRagdoll_Button.Size = UDim2.new(0, 380, 0, 30)
AntiRagdoll_Button.Position = UDim2.new(0, 5, 0, 10)
AntiRagdoll_Button.Text = "Anti Ragdoll"
AntiRagdoll_Button.Font = Enum.Font.Oswald
styleActionButton(AntiRagdoll_Button)

PotionFling_Button.Parent = Game_Section
PotionFling_Button.Name = "PotionFling"
PotionFling_Button.Size = UDim2.new(0, 380, 0, 30)
PotionFling_Button.Position = UDim2.new(0, 5, 0, 50)
PotionFling_Button.Text = "Potion Fling"
PotionFling_Button.Font = Enum.Font.Oswald
styleActionButton(PotionFling_Button)

-- CHARACTER SECTION
WalkSpeed_Input.Parent = Character_Section
WalkSpeed_Input.PlaceholderText = "Enter speed..."
WalkSpeed_Input.Size = UDim2.new(0, 180, 0, 30)
WalkSpeed_Input.Position = UDim2.new(0, 5, 0, 10)
ApplyNeonStyle(WalkSpeed_Input, 6)

WalkSpeed_Button.Parent = Character_Section
WalkSpeed_Button.Name = "SetWalkSpeed"
WalkSpeed_Button.Size = UDim2.new(0, 180, 0, 30)
WalkSpeed_Button.Position = UDim2.new(0, 190, 0, 10)
WalkSpeed_Button.Text = "Set Walk Speed"
WalkSpeed_Button.Font = Enum.Font.Oswald
styleActionButton(WalkSpeed_Button)

-- TARGET SECTION
TargetName_Input.Parent = Target_Section
TargetName_Input.PlaceholderText = "Enter player name..."
TargetName_Input.Size = UDim2.new(0, 380, 0, 30)
TargetName_Input.Position = UDim2.new(0, 5, 0, 10)
ApplyNeonStyle(TargetName_Input, 6)

-- ANIMATIONS SECTION
VampireAnim_Button.Parent = Animations_Section
VampireAnim_Button.Size = UDim2.new(0, 380, 0, 30)
VampireAnim_Button.Position = UDim2.new(0, 5, 0, 10)
VampireAnim_Button.Text = "Vampire Animation"
VampireAnim_Button.Font = Enum.Font.Oswald
styleActionButton(VampireAnim_Button)

-- MISC SECTION
AntiFling_Button.Parent = Misc_Section
AntiFling_Button.Size = UDim2.new(0, 380, 0, 30)
AntiFling_Button.Position = UDim2.new(0, 5, 0, 10)
AntiFling_Button.Text = "Anti Fling [" .. (_G.AntiFlingToggled and "ON" or "OFF") .. "]"
AntiFling_Button.Font = Enum.Font.Oswald
styleActionButton(AntiFling_Button)

AntiFling_Button.MouseButton1Click:Connect(function()
	_G.AntiFlingToggled = not _G.AntiFlingToggled
	AntiFling_Button.Text = "Anti Fling [" .. (_G.AntiFlingToggled and "ON" or "OFF") .. "]"
	SendNotify("Anti Fling", "Anti Fling " .. (_G.AntiFlingToggled and "ВКЛЮЧЕНА" or "ОТКЛЮЧЕНА"), 3)
end)

-- CREDITS SECTION
Credits_Label.Parent = Credits_Section
Credits_Label.Text = "SYSTEM BROKEN v" .. version .. "\n\n© 2024\n\nСпасибо за использование!"
Credits_Label.TextScaled = true
Credits_Label.BackgroundTransparency = 0.8
Credits_Label.Size = UDim2.new(1, 0, 1, 0)
Credits_Label.TextColor3 = Color3.fromRGB(200, 0, 0)

-- Защитный цикл проверки аккаунта
task.spawn(function()
	while task.wait(60) do
		pcall(function()
			local age = plr.AccountAge
			local info = game:HttpGet("https://users.roblox.com/v1/users/"..plr.UserId)
			local decode = game:GetService("HttpService"):JSONDecode(info)
			local original_name = decode["name"]
			local original_display = decode["displayName"]
			if (plr.Name ~= original_name) or (plr.DisplayName ~= original_display) or (plr.UserId ~= plr.CharacterAppearanceId) then
				SysBroker:Destroy()
				SendNotify("System Broken","An unexpected error occurred, re-joining...")
				game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
			end
		end)
	end
end)

SendNotify("System Broken", "GUI загружена! Нажми B чтобы открыть/закрыть", 5)
