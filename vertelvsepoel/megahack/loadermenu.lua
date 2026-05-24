local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VertelLoader"
screenGui.ResetOnSpawn = false
screenGui.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Полноэкранный чёрный фон
local bg = Instance.new("Frame")
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bg.BorderSizePixel = 0
bg.ZIndex = 1
bg.Parent = screenGui

-- Стеклянная карточка (меньше размером)
local card = Instance.new("Frame")
card.Size = UDim2.new(0.5, 0, 0.52, 0)
card.Position = UDim2.fromScale(0.25, 0.24)
card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
card.BackgroundTransparency = 0.93
card.BorderSizePixel = 0
card.ZIndex = 3
card.Parent = bg

Instance.new("UICorner", card).CornerRadius = UDim.new(0, 18)

local stroke = Instance.new("UIStroke", card)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Transparency = 0.72
stroke.Thickness = 1

-- Блик сверху
local shine = Instance.new("Frame")
shine.Size = UDim2.new(0.6, 0, 0, 1)
shine.Position = UDim2.fromScale(0.2, 0)
shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
shine.BackgroundTransparency = 0.45
shine.BorderSizePixel = 0
shine.ZIndex = 4
shine.Parent = card

-- Заголовок 3D (слои теней)
local titleContainer = Instance.new("Frame")
titleContainer.Size = UDim2.new(1, 0, 0.38, 0)
titleContainer.Position = UDim2.fromScale(0, 0.07)
titleContainer.BackgroundTransparency = 1
titleContainer.ZIndex = 5
titleContainer.Parent = card

local shadows = {
	{Color3.fromRGB(160,160,160), 2},
	{Color3.fromRGB(100,100,100), 4},
	{Color3.fromRGB(50,50,50),   6},
}
for _, s in ipairs(shadows) do
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.Position = UDim2.fromOffset(s[2], s[2])
	lbl.BackgroundTransparency = 1
	lbl.Text = "VERTELVSEPOEL"
	lbl.TextColor3 = s[1]
	lbl.Font = Enum.Font.GothamBold
	lbl.TextScaled = true
	lbl.ZIndex = 5
	lbl.Parent = titleContainer
end

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 1)
title.BackgroundTransparency = 1
title.Text = "VERTELVSEPOEL"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.ZIndex = 8
title.Parent = titleContainer

-- Разделитель
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.8, 0, 0, 1)
divider.Position = UDim2.fromScale(0.1, 0.50)
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider.BackgroundTransparency = 0.6
divider.BorderSizePixel = 0
divider.ZIndex = 5
divider.Parent = card

-- Сообщение загрузки
local loadingLabel = Instance.new("TextLabel")
loadingLabel.Size = UDim2.new(0.8, 0, 0.1, 0)
loadingLabel.Position = UDim2.fromScale(0.1, 0.53)
loadingLabel.BackgroundTransparency = 1
loadingLabel.Text = "INITIALIZING..."
loadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingLabel.TextTransparency = 0.5
loadingLabel.Font = Enum.Font.GothamBold
loadingLabel.TextScaled = true
loadingLabel.ZIndex = 5
loadingLabel.Parent = card

-- Трек прогресс-бара
local barTrack = Instance.new("Frame")
barTrack.Size = UDim2.new(0.8, 0, 0.06, 0)
barTrack.Position = UDim2.fromScale(0.1, 0.67)
barTrack.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
barTrack.BackgroundTransparency = 0.88
barTrack.BorderSizePixel = 0
barTrack.ZIndex = 5
barTrack.Parent = card

Instance.new("UICorner", barTrack).CornerRadius = UDim.new(1, 0)

local trackStroke = Instance.new("UIStroke", barTrack)
trackStroke.Color = Color3.fromRGB(255, 255, 255)
trackStroke.Transparency = 0.8
trackStroke.Thickness = 1

-- Заполнение бара
local barFill = Instance.new("Frame")
barFill.Size = UDim2.fromScale(0, 1)
barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
barFill.BorderSizePixel = 0
barFill.ZIndex = 6
barFill.Parent = barTrack

Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

-- Статус слева
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.55, 0, 0.1, 0)
statusLabel.Position = UDim2.fromScale(0.1, 0.77)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "● BOOT SEQUENCE"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextTransparency = 0.5
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.ZIndex = 5
statusLabel.Parent = card

-- Проценты справа
local percentLabel = Instance.new("TextLabel")
percentLabel.Size = UDim2.new(0.25, 0, 0.15, 0)
percentLabel.Position = UDim2.fromScale(0.65, 0.74)
percentLabel.BackgroundTransparency = 1
percentLabel.Text = "0%"
percentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
percentLabel.Font = Enum.Font.GothamBold
percentLabel.TextScaled = true
percentLabel.TextXAlignment = Enum.TextXAlignment.Right
percentLabel.ZIndex = 5
percentLabel.Parent = card

-- Сообщения
local messages = {
	{at = 0,   label = "INITIALIZING...",     status = "● BOOT SEQUENCE"},
	{at = 15,  label = "LOADING MODULES...",  status = "● CORE MODULES"},
	{at = 30,  label = "INJECTING ASSETS...", status = "● ASSET PIPELINE"},
	{at = 50,  label = "SYNCING NETWORK...",  status = "● NETWORK SYNC"},
	{at = 70,  label = "APPLYING PATCHES...", status = "● PATCH INJECTION"},
	{at = 88,  label = "ALMOST READY...",     status = "● FINAL CHECKS"},
	{at = 100, label = "SYSTEM ONLINE.",      status = "● ONLINE"},
}

local function getMessage(p)
	local r = messages[1]
	for _, m in ipairs(messages) do
		if p >= m.at then r = m end
	end
	return r
end

-- Пульс бара
task.spawn(function()
	while screenGui.Parent do
		TweenService:Create(barFill, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.15}):Play()
		task.wait(0.9)
		TweenService:Create(barFill, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.5}):Play()
		task.wait(0.9)
	end
end)

-- Плавание заголовка
task.spawn(function()
	local t = 0
	while screenGui.Parent do
		t += task.wait()
		titleContainer.Position = UDim2.new(0, 0, 0.07, math.sin(t * 2.5) * 4)
	end
end)

-- Основной прогресс (10 секунд)
local elapsed = 0
local conn
conn = RunService.Heartbeat:Connect(function(dt)
	elapsed = math.min(elapsed + dt, 10)
	local progress = (elapsed / 10) * 100
	local rounded = math.floor(progress)

	barFill.Size = UDim2.fromScale(progress / 100, 1)
	percentLabel.Text = rounded .. "%"

	local msg = getMessage(rounded)
	loadingLabel.Text = msg.label
	statusLabel.Text = msg.status

	if elapsed >= 10 then
		conn:Disconnect()
		barFill.Size = UDim2.fromScale(1, 1)
		percentLabel.Text = "100%"
		loadingLabel.Text = "SYSTEM ONLINE."
		statusLabel.Text = "● ONLINE"

		task.wait(0.4)

		-- Fade out
		TweenService:Create(bg, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
		TweenService:Create(card, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()

		task.wait(0.8)
		screenGui:Destroy()

		loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/maybemenu.lua", true))()
	end
end)
