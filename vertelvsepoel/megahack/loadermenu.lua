═══════════════════════════════════════════════════════════════
--  loadermenu.lua — 3D Neon Glass Loading Screen v3
═══════════════════════════════════════════════════════════════

local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local RunService     = game:GetService("RunService")
local CoreGui        = game:GetService("CoreGui")
local HttpService    = game:GetService("HttpService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 5)

-- ═══ SAFE LOAD COLORS ═══
local playerColors = {
    accentColor = Color3.fromRGB(0, 220, 255),
    bgColor = Color3.fromRGB(6, 6, 14),
    textColor = Color3.fromRGB(240, 240, 255),
    strokeColor = Color3.fromRGB(30, 30, 60),
    transparency = 0.04,
    rgbAccent = false,
    rgbStroke = false,
}

pcall(function()
    if type(isfile) == "function" and isfile("MegaHack/colorSettings.json") then
        local raw = readfile("MegaHack/colorSettings.json")
        local data = HttpService:JSONDecode(raw)
        if data.accentColor then playerColors.accentColor = Color3.new(table.unpack(data.accentColor)) end
        if data.bgColor then playerColors.bgColor = Color3.new(table.unpack(data.bgColor)) end
        if data.textColor then playerColors.textColor = Color3.new(table.unpack(data.textColor)) end
        if data.strokeColor then playerColors.strokeColor = Color3.new(table.unpack(data.strokeColor)) end
        if data.transparency ~= nil then playerColors.transparency = data.transparency end
        if data.rgbAccent ~= nil then playerColors.rgbAccent = data.rgbAccent end
        if data.rgbStroke ~= nil then playerColors.rgbStroke = data.rgbStroke end
    end
end)

local acc = playerColors.accentColor
local bg  = playerColors.bgColor
local tx  = playerColors.textColor

local T = {
    BgBase = bg,
    BgBtn  = Color3.new(math.min(bg.R+0.06,1), math.min(bg.G+0.06,1), math.min(bg.B+0.08,1)),
    Accent = acc,
    TextMain = tx,
    White  = Color3.new(1, 1, 1),
    Shadow = Color3.fromRGB(0, 0, 8),
}

local CORNER = 16
local LOAD_TIME = 8

-- ═══ HELPERS ═══
local function mkCorner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or CORNER)
    c.Parent = parent
    return c
end

local function mkStroke(parent, thickness, color, alpha)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 1
    s.Color = color or T.White
    s.Transparency = alpha or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function mkLabel(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel = 0
    for k, v in pairs(props) do l[k] = v end
    l.Parent = parent
    return l
end

-- ═══ SCREEN GUI ═══
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MegaHack_Loader"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false

local guiParented = false
pcall(function()
    if get_hidden_gui then screenGui.Parent = get_hidden_gui(); guiParented = true
    elseif gethui then screenGui.Parent = gethui(); guiParented = true
    elseif syn and syn.protect_gui then syn.protect_gui(screenGui); screenGui.Parent = CoreGui; guiParented = true
    else screenGui.Parent = CoreGui; guiParented = true end
end)
if not guiParented then screenGui.Parent = playerGui end

-- ═══ 3D SHADOW ═══
local shadow3D = Instance.new("Frame")
shadow3D.Name = "Shadow3D"
shadow3D.Size = UDim2.new(0, 480, 0, 340)
shadow3D.Position = UDim2.new(0.5, 2, 0.5, 8)
shadow3D.AnchorPoint = Vector2.new(0.5, 0.5)
shadow3D.BackgroundColor3 = T.Shadow
shadow3D.BackgroundTransparency = 0.4
shadow3D.BorderSizePixel = 0
shadow3D.ZIndex = 1
shadow3D.Parent = screenGui
mkCorner(shadow3D, CORNER)

-- ═══ NEON GLOW BORDER ═══
local neonGlow = Instance.new("Frame")
neonGlow.Name = "NeonGlow"
neonGlow.Size = UDim2.new(0, 490, 0, 350)
neonGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
neonGlow.AnchorPoint = Vector2.new(0.5, 0.5)
neonGlow.BackgroundColor3 = T.Accent
neonGlow.BackgroundTransparency = 0.8
neonGlow.BorderSizePixel = 0
neonGlow.ZIndex = 2
neonGlow.Parent = screenGui
mkCorner(neonGlow, CORNER + 5)

-- ═══ MAIN FRAME ═══
local mainFrame = Instance.new("Frame")
mainFrame.Name = "LoaderFrame"
mainFrame.BackgroundColor3 = T.BgBase
mainFrame.BackgroundTransparency = 1 -- Starts transparent for fade in
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Size = UDim2.new(0, 480, 0, 340)
mainFrame.ZIndex = 3
mainFrame.Parent = screenGui
mkCorner(mainFrame, CORNER)
mkStroke(mainFrame, 1, T.Accent, 0.4)

-- Glass Sheen
local glassSheen = Instance.new("Frame")
glassSheen.BackgroundColor3 = T.White
glassSheen.BackgroundTransparency = 1
glassSheen.BorderSizePixel = 0
glassSheen.Size = UDim2.new(1, 0, 0.5, 0)
glassSheen.ZIndex = 4
glassSheen.ClipsDescendants = true
glassSheen.Parent = mainFrame
mkCorner(glassSheen, CORNER)
local sheenGrad = Instance.new("UIGradient")
sheenGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.1),
    NumberSequenceKeypoint.new(0.5, 0.7),
    NumberSequenceKeypoint.new(1, 1.0),
})
sheenGrad.Rotation = 90
sheenGrad.Parent = glassSheen

-- Top Neon Bar
local topBar = Instance.new("Frame")
topBar.BackgroundColor3 = T.Accent
topBar.BackgroundTransparency = 0.1
topBar.BorderSizePixel = 0
topBar.Size = UDim2.new(0.6, 0, 0, 2)
topBar.Position = UDim2.new(0.2, 0, 0, 0)
topBar.ZIndex = 10
topBar.Parent = mainFrame
mkCorner(topBar, 1)

-- ═══ 3D TEXT VERTELEVSEPOEL ═══
local sh3 = mkLabel(mainFrame, {
    Text = "VERTELEVSEPOEL", Font = Enum.Font.GothamBold, TextSize = 34,
    TextColor3 = Color3.new(acc.R*0.2, acc.G*0.2, acc.B*0.2),
    TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1,0,0,50), Position = UDim2.new(0,6,0,75), ZIndex = 5, TextTransparency = 1,
})
local sh2 = mkLabel(mainFrame, {
    Text = "VERTELEVSEPOEL", Font = Enum.Font.GothamBold, TextSize = 34,
    TextColor3 = Color3.new(acc.R*0.5, acc.G*0.5, acc.B*0.5),
    TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1,0,0,50), Position = UDim2.new(0,4,0,73), ZIndex = 6, TextTransparency = 1,
})
local sh1 = mkLabel(mainFrame, {
    Text = "VERTELEVSEPOEL", Font = Enum.Font.GothamBold, TextSize = 34,
    TextColor3 = T.Accent,
    TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1,0,0,50), Position = UDim2.new(0,2,0,71), ZIndex = 7, TextTransparency = 1,
})
local mainText = mkLabel(mainFrame, {
    Text = "VERTELEVSEPOEL", Font = Enum.Font.GothamBold, TextSize = 34,
    TextColor3 = T.TextMain,
    TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1,0,0,50), Position = UDim2.new(0,0,0,70), ZIndex = 8, TextTransparency = 1,
})

-- Divider
local divLine = Instance.new("Frame")
divLine.BackgroundColor3 = T.Accent
divLine.BackgroundTransparency = 0.4
divLine.BorderSizePixel = 0
divLine.Size = UDim2.new(0.5, 0, 0, 1)
divLine.Position = UDim2.new(0.25, 0, 0, 132)
divLine.ZIndex = 8
divLine.Parent = mainFrame
mkCorner(divLine, 1)

-- Status Label
local statusLabel = mkLabel(mainFrame, {
    Text = "Initializing...", Font = Enum.Font.Gotham, TextSize = 13,
    TextColor3 = T.TextMain, TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1,-40,0,20), Position = UDim2.new(0,20,0,146), ZIndex = 8, TextTransparency = 1,
})

-- Progress Bar Track with 3D
local trackShadow = Instance.new("Frame")
trackShadow.BackgroundColor3 = T.Shadow
trackShadow.BackgroundTransparency = 0.5
trackShadow.BorderSizePixel = 0
trackShadow.Size = UDim2.new(1,-56,0,8)
trackShadow.Position = UDim2.new(0,32,0,184)
trackShadow.ZIndex = 7
trackShadow.Parent = mainFrame
mkCorner(trackShadow, 4)

local progressTrack = Instance.new("Frame")
progressTrack.BackgroundColor3 = T.BgBtn
progressTrack.BackgroundTransparency = 0.2
progressTrack.BorderSizePixel = 0
progressTrack.Size = UDim2.new(1,-60,0,6)
progressTrack.Position = UDim2.new(0,30,0,182)
progressTrack.ZIndex = 8
progressTrack.Parent = mainFrame
mkCorner(progressTrack, 3)
mkStroke(progressTrack, 1, T.Accent, 0.3)

local progressFill = Instance.new("Frame")
progressFill.BackgroundColor3 = T.Accent
progressFill.BorderSizePixel = 0
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.ZIndex = 9
progressFill.Parent = progressTrack
mkCorner(progressFill, 3)

local progressSheen = Instance.new("Frame")
progressSheen.BackgroundColor3 = T.White
progressSheen.BackgroundTransparency = 0.6
progressSheen.BorderSizePixel = 0
progressSheen.Size = UDim2.new(1,0,0.5,0)
progressSheen.ZIndex = 10
progressSheen.Parent = progressFill
mkCorner(progressSheen, 3)

-- Percentage
local percentLabel = mkLabel(mainFrame, {
    Text = "0%", Font = Enum.Font.GothamBold, TextSize = 24,
    TextColor3 = T.Accent, TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1,0,0,30), Position = UDim2.new(0,0,0,200), ZIndex = 8, TextTransparency = 1,
})

-- Meta Info
local metaLabel = mkLabel(mainFrame, {
    Text = "MEGAHACK 2026 • v3.0 • github / shaypishgithub",
    Font = Enum.Font.Gotham, TextSize = 11,
    TextColor3 = Color3.fromRGB(90, 90, 120), TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.new(1,-40,0,16), Position = UDim2.new(0,20,1,-30), ZIndex = 8, TextTransparency = 1,
})

-- Bottom Neon Bar
local bottomBar = Instance.new("Frame")
bottomBar.BackgroundColor3 = T.Accent
bottomBar.BackgroundTransparency = 0.2
bottomBar.BorderSizePixel = 0
bottomBar.Size = UDim2.new(0.4,0,0,2)
bottomBar.Position = UDim2.new(0.3,0,1,-3)
bottomBar.ZIndex = 8
bottomBar.Parent = mainFrame
mkCorner(bottomBar, 1)

-- ═══ STATUS MESSAGES ═══
local statusMessages = {
    [0] = "Connecting to neon servers...",
    [10] = "Loading glass modules...",
    [20] = "Fetching 3D assets...",
    [35] = "Checking executor environment...",
    [50] = "Injecting script database...",
    [65] = "Applying visual patches...",
    [80] = "Building interface...",
    [90] = "Finalizing glow effects...",
    [100] = "Complete!",
}

-- ═══ ANIMATE IN ═══
task.delay(0.1, function()
    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = playerColors.transparency}):Play()
    TweenService:Create(shadow3D, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.4}):Play()
    TweenService:Create(neonGlow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.8}):Play()
    TweenService:Create(glassSheen, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.94}):Play()
    
    local delays = {0, 0.08, 0.16, 0.24}
    for i, lbl in ipairs({sh3, sh2, sh1, mainText}) do
        task.delay(delays[i], function()
            TweenService:Create(lbl, TweenInfo.new(0.4), {TextTransparency = i == 4 and 0 or 0.3}):Play()
        end)
    end
    task.delay(0.4, function()
        for _, l in ipairs({statusLabel, percentLabel, metaLabel}) do
            TweenService:Create(l, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        end
    end)
end)

-- ═══ RGB / PULSE EFFECTS ═══
local rgbConnections = {}

local function setAccentAll(color)
    percentLabel.TextColor3 = color
    topBar.BackgroundColor3 = color
    bottomBar.BackgroundColor3 = color
    progressFill.BackgroundColor3 = color
    divLine.BackgroundColor3 = color
    neonGlow.BackgroundColor3 = color
end

if playerColors.rgbStroke then
    table.insert(rgbConnections, RunService.Heartbeat:Connect(function()
        local c = Color3.fromHSV((tick() % 5) / 5, 0.9, 1)
        mkStroke.Color = c
        setAccentAll(c)
    end))
elseif playerColors.rgbAccent then
    table.insert(rgbConnections, RunService.Heartbeat:Connect(function()
        setAccentAll(Color3.fromHSV((tick() % 5) / 5, 0.9, 1))
    end))
else
    table.insert(rgbConnections, RunService.Heartbeat:Connect(function()
        local s = math.sin(tick() * 0.8)
        setAccentAll(Color3.new(
            math.min(acc.R + s * 0.05, 1),
            math.min(acc.G + s * 0.02, 1),
            math.min(acc.B + s * 0.02, 1)
        ))
        neonGlow.BackgroundTransparency = 0.75 + math.sin(tick() * 1.5) * 0.15
    end))
end

-- ═══ PROGRESS LOGIC ═══
local startTime = tick()
local lastStatus = -1
local progressConn

progressConn = RunService.Heartbeat:Connect(function()
    local pct = math.min((tick() - startTime) / LOAD_TIME, 1)
    local pctInt = math.floor(pct * 100)

    TweenService:Create(progressFill, TweenInfo.new(0.12, Enum.EasingStyle.Linear), {
        Size = UDim2.new(pct, 0, 1, 0)
    }):Play()

    percentLabel.Text = tostring(pctInt) .. "%"

    for threshold, msg in pairs(statusMessages) do
        if pctInt >= threshold and threshold > lastStatus then
            lastStatus = threshold
            statusLabel.Text = msg
        end
    end

    if pct >= 1 then
        progressConn:Disconnect()
        for _, c in ipairs(rgbConnections) do pcall(function() c:Disconnect() end) end

        percentLabel.TextColor3 = T.TextMain
        mainText.TextTransparency = 0
        setAccentAll(playerColors.accentColor)

        task.delay(0.4, function()
            -- Fade out everything
            TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            TweenService:Create(shadow3D, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            TweenService:Create(neonGlow, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            
            for _, obj in ipairs(mainFrame:GetDescendants()) do
                if obj:IsA("TextLabel") then
                    TweenService:Create(obj, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
                elseif obj:IsA("Frame") then
                    TweenService:Create(obj, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
                elseif obj:IsA("UIStroke") then
                    TweenService:Create(obj, TweenInfo.new(0.4), {Transparency = 1}):Play()
                end
            end

            task.delay(0.7, function()
                screenGui:Destroy()
                local ok, err = pcall(function()
                    loadstring(game:HttpGet(
                        "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/maybemenu.lua",
                        true
                    ))()
                end)
                if not ok then
                    warn("[MegaHack Loader] Error: " .. tostring(err))
                end
            end)
        end)
    end
end)
