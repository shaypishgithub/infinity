local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VertelLoader"
screenGui.ResetOnSpawn = false
screenGui.BackgroundTransparency = 1
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Glass card (centered, no black bg behind it)
local card = Instance.new("Frame")
card.Size = UDim2.fromScale(0.5, 0.42)
card.Position = UDim2.fromScale(0.25, 0.29)
card.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
card.BackgroundTransparency = 0.3
card.BorderSizePixel = 0
card.ZIndex = 1
card.Parent = screenGui

Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke", card)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Transparency = 0.7
stroke.Thickness = 1

-- Title (3D layered)
local titleFrame = Instance.new("Frame")
titleFrame.Size = UDim2.new(1, 0, 0.44, 0)
titleFrame.Position = UDim2.fromScale(0, 0.05)
titleFrame.BackgroundTransparency = 1
titleFrame.ZIndex = 2
titleFrame.Parent = card

local shadowOffsets = {
	{Color3.fromRGB(160,160,160), 4},
	{Color3.fromRGB(100,100,100), 3},
	{Color3.fromRGB(60,60,60),   2},
}
for _, d in ipairs(shadowOffsets) do
	local s = Instance.new("TextLabel")
	s.Size = UDim2.fromScale(1, 1)
	s.Position = UDim2.fromOffset(d[2], d[2])
	s.BackgroundTransparency = 1
	s.Text = "VERTELVSEPOEL"
	s.TextColor3 = d[1]
	s.Font = Enum.Font.GothamBold
	s.TextScaled = true
	s.ZIndex = 2
	s.Parent = titleFrame
end

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.fromScale(1, 1)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "VERTELVSEPOEL"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true
titleLabel.ZIndex = 4
titleLabel.Parent = titleFrame

-- Divider
local div = Instance.new("Frame")
div.Size = UDim2.new(0.8, 0, 0, 1)
div.Position = UDim2.fromScale(0.1, 0.52)
div.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
div.BackgroundTransparency = 0.6
div.BorderSizePixel = 0
div.ZIndex = 2
div.Parent = card

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.8, 0, 0.12, 0)
statusLabel.Position = UDim2.fromScale(0.1, 0.55)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "INITIALIZING..."
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextTransparency = 0.5
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true
statusLabel.ZIndex = 2
statusLabel.Parent = card

-- Bar track
local track = Instance.new("Frame")
track.Size = UDim2.new(0.8, 0, 0.1, 0)
track.Position = UDim2.fromScale(0.1, 0.70)
track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
track.BackgroundTransparency = 0.88
track.BorderSizePixel = 0
track.ZIndex = 2
track.Parent = card
Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(0, 1)
fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fill.BorderSizePixel = 0
fill.ZIndex = 3
fill.Parent = track
Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

-- Percent
local pctLabel = Instance.new("TextLabel")
pctLabel.Size = UDim2.new(0.8, 0, 0.14, 0)
pctLabel.Position = UDim2.fromScale(0.1, 0.82)
pctLabel.BackgroundTransparency = 1
pctLabel.Text = "0%"
pctLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
pctLabel.Font = Enum.Font.GothamBold
pctLabel.TextScaled = true
pctLabel.TextXAlignment = Enum.TextXAlignment.Right
pctLabel.ZIndex = 2
pctLabel.Parent = card

-- Messages
local msgs = {
	{0,  "INITIALIZING..."},
	{15, "LOADING MODULES..."},
	{35, "INJECTING ASSETS..."},
	{55, "SYNCING NETWORK..."},
	{75, "APPLYING PATCHES..."},
	{90, "FINALIZING..."},
	{100,"SYSTEM ONLINE."},
}

local function getMsg(p)
	local r = msgs[1][2]
	for _, m in ipairs(msgs) do
		if p >= m[1] then r = m[2] end
	end
	return r
end

-- Float animation
task.spawn(function()
	local t = 0
	while screenGui.Parent do
		t += task.wait()
		titleFrame.Position = UDim2.new(0, 0, 0.05, math.sin(t * 2.5) * 4)
	end
end)

-- Bar glow pulse
task.spawn(function()
	while screenGui.Parent do
		TweenService:Create(fill, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.0}):Play()
		task.wait(0.9)
		TweenService:Create(fill, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.4}):Play()
		task.wait(0.9)
	end
end)

-- Progress (10 sec)
local elapsed, conn = 0, nil
conn = RunService.Heartbeat:Connect(function(dt)
	elapsed = math.min(elapsed + dt, 10)
	local p = (elapsed / 10) * 100
	local r = math.floor(p)

	fill.Size = UDim2.fromScale(p / 100, 1)
	pctLabel.Text = r .. "%"
	statusLabel.Text = getMsg(r)

	if elapsed >= 10 then
		conn:Disconnect()
		fill.Size = UDim2.fromScale(1, 1)
		pctLabel.Text = "100%"
		statusLabel.Text = "SYSTEM ONLINE."

		task.wait(0.5)
		TweenService:Create(card, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.8), {Transparency = 1}):Play()
		task.wait(0.9)
		screenGui:Destroy()

		loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/maybemenu.lua", true))()
	end
end)
