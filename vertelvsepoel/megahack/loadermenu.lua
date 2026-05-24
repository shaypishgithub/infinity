-- ╔════════════════════════════════════════════╗
-- ║     VERTELEVSEPOEL GLASS LOADER GUI        ║
-- ║     Black & White Glassmorphism Style      ║
-- ╚════════════════════════════════════════════╝

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════
--           CONFIGURATION
-- ═══════════════════════════════════════
local LOAD_TIME = 10        -- seconds
local TITLE = "VERTELEVSEPOEL"
local SUBTITLE = "Loading system..."

-- ═══════════════════════════════════════
--           SCREEN GUI
-- ═══════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VertLoader"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

-- ═══════════════════════════════════════
--           BACKGROUND (DARK OVERLAY)
-- ═══════════════════════════════════════
local Background = Instance.new("Frame")
Background.Name = "Background"
Background.Size = UDim2.new(1, 0, 1, 0)
Background.Position = UDim2.new(0, 0, 0, 0)
Background.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
Background.BorderSizePixel = 0
Background.ZIndex = 1
Background.Parent = ScreenGui

-- Animated noise grain pattern using ImageLabel (subtle)
local GrainOverlay = Instance.new("Frame")
GrainOverlay.Size = UDim2.new(1, 0, 1, 0)
GrainOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GrainOverlay.BackgroundTransparency = 0.97
GrainOverlay.BorderSizePixel = 0
GrainOverlay.ZIndex = 2
GrainOverlay.Parent = Background

-- ═══════════════════════════════════════
--     DECORATIVE GLOW CIRCLES (BG)
-- ═══════════════════════════════════════
local function CreateGlowCircle(x, y, size, transparency, color)
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, size, 0, size)
    circle.Position = UDim2.new(x, -size/2, y, -size/2)
    circle.BackgroundColor3 = color
    circle.BackgroundTransparency = transparency
    circle.BorderSizePixel = 0
    circle.ZIndex = 2
    circle.Parent = Background

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = circle

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 200)),
    })
    gradient.Parent = circle
    return circle
end

local glow1 = CreateGlowCircle(0.2, 0.25, 350, 0.88, Color3.fromRGB(200, 200, 220))
local glow2 = CreateGlowCircle(0.8, 0.7, 280, 0.91, Color3.fromRGB(180, 180, 200))
local glow3 = CreateGlowCircle(0.5, 0.1, 200, 0.94, Color3.fromRGB(220, 220, 240))

-- Animate glows slowly
local t = 0
RunService.Heartbeat:Connect(function(dt)
    t = t + dt * 0.3
    glow1.Position = UDim2.new(0.2 + math.sin(t * 0.7) * 0.05, -175, 0.25 + math.cos(t * 0.5) * 0.05, -175)
    glow2.Position = UDim2.new(0.8 + math.cos(t * 0.6) * 0.04, -140, 0.7 + math.sin(t * 0.8) * 0.04, -140)
    glow3.Position = UDim2.new(0.5 + math.sin(t * 0.4) * 0.06, -100, 0.1 + math.cos(t * 0.9) * 0.03, -100)
end)

-- ═══════════════════════════════════════
--        MAIN GLASS CONTAINER
-- ═══════════════════════════════════════
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(0, 520, 0, 340)
Container.Position = UDim2.new(0.5, -260, 0.5, -170)
Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Container.BackgroundTransparency = 0.82
Container.BorderSizePixel = 0
Container.ZIndex = 5
Container.Parent = ScreenGui

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 22)
ContainerCorner.Parent = Container

-- Glass border stroke
local ContainerStroke = Instance.new("UIStroke")
ContainerStroke.Color = Color3.fromRGB(255, 255, 255)
ContainerStroke.Transparency = 0.6
ContainerStroke.Thickness = 1.5
ContainerStroke.Parent = Container

-- Inner glass sheen (top highlight)
local GlassSheen = Instance.new("Frame")
GlassSheen.Size = UDim2.new(0.9, 0, 0.45, 0)
GlassSheen.Position = UDim2.new(0.05, 0, 0.02, 0)
GlassSheen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GlassSheen.BackgroundTransparency = 0.88
GlassSheen.BorderSizePixel = 0
GlassSheen.ZIndex = 6
GlassSheen.Parent = Container

local SheenCorner = Instance.new("UICorner")
SheenCorner.CornerRadius = UDim.new(0, 16)
SheenCorner.Parent = GlassSheen

-- ═══════════════════════════════════════
--        3D SHADOW TITLE TEXT
-- ═══════════════════════════════════════

-- Shadow layer 1 (deepest, offset most)
local TitleShadow3 = Instance.new("TextLabel")
TitleShadow3.Size = UDim2.new(1, 0, 0, 80)
TitleShadow3.Position = UDim2.new(0, 6, 0, 46)
TitleShadow3.BackgroundTransparency = 1
TitleShadow3.Text = TITLE
TitleShadow3.TextColor3 = Color3.fromRGB(0, 0, 0)
TitleShadow3.TextTransparency = 0.82
TitleShadow3.TextSize = 48
TitleShadow3.Font = Enum.Font.GothamBold
TitleShadow3.ZIndex = 6
TitleShadow3.Parent = Container

-- Shadow layer 2
local TitleShadow2 = Instance.new("TextLabel")
TitleShadow2.Size = UDim2.new(1, 0, 0, 80)
TitleShadow2.Position = UDim2.new(0, 4, 0, 44)
TitleShadow2.BackgroundTransparency = 1
TitleShadow2.Text = TITLE
TitleShadow2.TextColor3 = Color3.fromRGB(50, 50, 60)
TitleShadow2.TextTransparency = 0.65
TitleShadow2.TextSize = 48
TitleShadow2.Font = Enum.Font.GothamBold
TitleShadow2.ZIndex = 7
TitleShadow2.Parent = Container

-- Shadow layer 3 (lightest)
local TitleShadow1 = Instance.new("TextLabel")
TitleShadow1.Size = UDim2.new(1, 0, 0, 80)
TitleShadow1.Position = UDim2.new(0, 2, 0, 42)
TitleShadow1.BackgroundTransparency = 1
TitleShadow1.Text = TITLE
TitleShadow1.TextColor3 = Color3.fromRGB(150, 150, 170)
TitleShadow1.TextTransparency = 0.45
TitleShadow1.TextSize = 48
TitleShadow1.Font = Enum.Font.GothamBold
TitleShadow1.ZIndex = 8
TitleShadow1.Parent = Container

-- MAIN TITLE (top layer — bright white)
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 80)
TitleLabel.Position = UDim2.new(0, 0, 0, 40)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = TITLE
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextTransparency = 0.0
TitleLabel.TextSize = 48
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.ZIndex = 9
TitleLabel.Parent = Container

-- Letter spacing gradient effect
local TitleGrad = Instance.new("UIGradient")
TitleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(200, 200, 210)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(200, 200, 210)),
})
TitleGrad.Parent = TitleLabel

-- Animate gradient sweep (shimmer)
local shimmerT = 0
RunService.Heartbeat:Connect(function(dt)
    shimmerT = shimmerT + dt * 0.4
    local offset = (math.sin(shimmerT) * 0.5)
    TitleGrad.Offset = Vector2.new(offset, 0)
end)

-- ═══════════════════════════════════════
--           DIVIDER LINE
-- ═══════════════════════════════════════
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0, 380, 0, 1)
Divider.Position = UDim2.new(0.5, -190, 0, 125)
Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Divider.BackgroundTransparency = 0.65
Divider.BorderSizePixel = 0
Divider.ZIndex = 9
Divider.Parent = Container

local DivGrad = Instance.new("UIGradient")
DivGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(255, 255, 255)),
})
DivGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.15, 0.3),
    NumberSequenceKeypoint.new(0.5, 0),
    NumberSequenceKeypoint.new(0.85, 0.3),
    NumberSequenceKeypoint.new(1, 1),
})
DivGrad.Parent = Divider

-- ═══════════════════════════════════════
--           STATUS TEXT
-- ═══════════════════════════════════════
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -40, 0, 30)
StatusLabel.Position = UDim2.new(0, 20, 0, 135)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = SUBTITLE
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 215)
StatusLabel.TextTransparency = 0.1
StatusLabel.TextSize = 15
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.ZIndex = 9
StatusLabel.Parent = Container

-- ═══════════════════════════════════════
--        PROGRESS BAR BACKGROUND
-- ═══════════════════════════════════════
local BarBg = Instance.new("Frame")
BarBg.Name = "BarBackground"
BarBg.Size = UDim2.new(0, 420, 0, 10)
BarBg.Position = UDim2.new(0.5, -210, 0, 185)
BarBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BarBg.BackgroundTransparency = 0.82
BarBg.BorderSizePixel = 0
BarBg.ZIndex = 9
BarBg.Parent = Container

local BarBgCorner = Instance.new("UICorner")
BarBgCorner.CornerRadius = UDim.new(1, 0)
BarBgCorner.Parent = BarBg

local BarBgStroke = Instance.new("UIStroke")
BarBgStroke.Color = Color3.fromRGB(255, 255, 255)
BarBgStroke.Transparency = 0.7
BarBgStroke.Thickness = 1
BarBgStroke.Parent = BarBg

-- ═══════════════════════════════════════
--        PROGRESS BAR FILL
-- ═══════════════════════════════════════
local BarFill = Instance.new("Frame")
BarFill.Name = "BarFill"
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.Position = UDim2.new(0, 0, 0, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BarFill.BackgroundTransparency = 0.05
BarFill.BorderSizePixel = 0
BarFill.ZIndex = 10
BarFill.ClipsDescendants = false
BarFill.Parent = BarBg

local BarFillCorner = Instance.new("UICorner")
BarFillCorner.CornerRadius = UDim.new(1, 0)
BarFillCorner.Parent = BarFill

local BarGrad = Instance.new("UIGradient")
BarGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 180, 200)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 235)),
})
BarGrad.Parent = BarFill

-- Glimmer on bar (moving highlight)
local BarGlimmer = Instance.new("Frame")
BarGlimmer.Size = UDim2.new(0, 60, 1, 0)
BarGlimmer.Position = UDim2.new(-0.2, 0, 0, 0)
BarGlimmer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BarGlimmer.BackgroundTransparency = 0.6
BarGlimmer.BorderSizePixel = 0
BarGlimmer.ZIndex = 11
BarGlimmer.Parent = BarFill

local GlimmerCorner = Instance.new("UICorner")
GlimmerCorner.CornerRadius = UDim.new(1, 0)
GlimmerCorner.Parent = BarGlimmer

local GlimmerGrad = Instance.new("UIGradient")
GlimmerGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.4),
    NumberSequenceKeypoint.new(1, 1),
})
GlimmerGrad.Parent = BarGlimmer

-- ═══════════════════════════════════════
--           PERCENTAGE TEXT
-- ═══════════════════════════════════════
local PercentLabel = Instance.new("TextLabel")
PercentLabel.Size = UDim2.new(1, 0, 0, 36)
PercentLabel.Position = UDim2.new(0, 0, 0, 205)
PercentLabel.BackgroundTransparency = 1
PercentLabel.Text = "0%"
PercentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PercentLabel.TextTransparency = 0.05
PercentLabel.TextSize = 28
PercentLabel.Font = Enum.Font.GothamBold
PercentLabel.TextXAlignment = Enum.TextXAlignment.Center
PercentLabel.ZIndex = 9
PercentLabel.Parent = Container

-- ═══════════════════════════════════════
--         DETAIL DOTS (bottom)
-- ═══════════════════════════════════════
local DotsFrame = Instance.new("Frame")
DotsFrame.Size = UDim2.new(0, 60, 0, 12)
DotsFrame.Position = UDim2.new(0.5, -30, 0, 255)
DotsFrame.BackgroundTransparency = 1
DotsFrame.ZIndex = 9
DotsFrame.Parent = Container

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = DotsFrame

for i = 1, 3 do
    local dot = Instance.new("Frame")
    dot.Name = "Dot"..i
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BackgroundTransparency = 0.6
    dot.BorderSizePixel = 0
    dot.ZIndex = 9
    dot.Parent = DotsFrame

    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1, 0)
    dc.Parent = dot
end

-- Pulsing dots animation
local dotPulse = 0
RunService.Heartbeat:Connect(function(dt)
    dotPulse = dotPulse + dt
    for i = 1, 3 do
        local dot = DotsFrame:FindFirstChild("Dot"..i)
        if dot then
            local phase = math.sin(dotPulse * 2.5 + (i - 1) * 1.2)
            dot.BackgroundTransparency = 0.4 + (phase * 0.3)
        end
    end
end)

-- ═══════════════════════════════════════
--        VERSION / TAG LINE
-- ═══════════════════════════════════════
local TagLine = Instance.new("TextLabel")
TagLine.Size = UDim2.new(1, 0, 0, 24)
TagLine.Position = UDim2.new(0, 0, 0, 280)
TagLine.BackgroundTransparency = 1
TagLine.Text = "GLASS EDITION  •  v2.0"
TagLine.TextColor3 = Color3.fromRGB(180, 180, 200)
TagLine.TextTransparency = 0.35
TagLine.TextSize = 12
TagLine.Font = Enum.Font.Gotham
TagLine.TextXAlignment = Enum.TextXAlignment.Center
TagLine.LetterSpacing = 4
TagLine.ZIndex = 9
TagLine.Parent = Container

-- ═══════════════════════════════════════
--        CORNER DECORATIONS
-- ═══════════════════════════════════════
local function MakeCornerDeco(xScale, yScale, xOff, yOff, rotX, rotY)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 20, 0, 20)
    f.Position = UDim2.new(xScale, xOff, yScale, yOff)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.ZIndex = 10
    f.Parent = Container

    -- Horizontal bar
    local h = Instance.new("Frame")
    h.Size = UDim2.new(0, 18, 0, 2)
    h.Position = UDim2.new(rotX, 0, rotY, 0)
    h.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    h.BackgroundTransparency = 0.5
    h.BorderSizePixel = 0
    h.ZIndex = 10
    h.Parent = f

    -- Vertical bar
    local v = Instance.new("Frame")
    v.Size = UDim2.new(0, 2, 0, 18)
    v.Position = UDim2.new(rotX, 0, rotY, 0)
    v.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    v.BackgroundTransparency = 0.5
    v.BorderSizePixel = 0
    v.ZIndex = 10
    v.Parent = f
end

MakeCornerDeco(0, 0, 12, 12, 0, 0)
MakeCornerDeco(1, 0, -32, 12, 0, 0)
MakeCornerDeco(0, 1, 12, -32, 0, 0)
MakeCornerDeco(1, 1, -32, -32, 0, 0)

-- ═══════════════════════════════════════
--         STATUS MESSAGES TABLE
-- ═══════════════════════════════════════
local statusMessages = {
    [0]  = "Initializing core systems...",
    [10] = "Loading assets...",
    [25] = "Connecting to services...",
    [40] = "Verifying integrity...",
    [55] = "Compiling scripts...",
    [70] = "Finalizing configuration...",
    [85] = "Almost ready...",
    [95] = "Launching...",
    [100] = "Complete!",
}

-- ═══════════════════════════════════════
--         ENTRY ANIMATION
-- ═══════════════════════════════════════
Container.Position = UDim2.new(0.5, -260, 0.6, -170)
Container.BackgroundTransparency = 1

local tweenInfo = TweenInfo.new(0.9, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

TweenService:Create(Container, tweenInfo, {
    Position = UDim2.new(0.5, -260, 0.5, -170),
    BackgroundTransparency = 0.82,
}):Play()

TitleLabel.TextTransparency = 1
TweenService:Create(TitleLabel, TweenInfo.new(1.2, Enum.EasingStyle.Quint), {
    TextTransparency = 0,
}):Play()

-- ═══════════════════════════════════════
--         GLIMMER LOOP ANIMATION
-- ═══════════════════════════════════════
local glimmerLooping = true
local function LoopGlimmer()
    while glimmerLooping do
        BarGlimmer.Position = UDim2.new(-0.15, 0, 0, 0)
        TweenService:Create(BarGlimmer, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Position = UDim2.new(1.1, 0, 0, 0),
        }):Play()
        task.wait(2.2)
    end
end
task.spawn(LoopGlimmer)

-- ═══════════════════════════════════════
--         MAIN LOADING LOOP
-- ═══════════════════════════════════════
local startTime = tick()

task.spawn(function()
    while true do
        local elapsed = tick() - startTime
        local progress = math.clamp(elapsed / LOAD_TIME, 0, 1)
        local percent = math.floor(progress * 100)

        -- Update bar fill
        TweenService:Create(BarFill, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
            Size = UDim2.new(progress, 0, 1, 0),
        }):Play()

        -- Update percent text
        PercentLabel.Text = percent .. "%"

        -- Update status message
        for threshold, msg in pairs(statusMessages) do
            if percent >= threshold then
                local best = 0
                local bestMsg = SUBTITLE
                for k, v in pairs(statusMessages) do
                    if k <= percent and k >= best then
                        best = k
                        bestMsg = v
                    end
                end
                StatusLabel.Text = bestMsg
                break
            end
        end

        if progress >= 1 then break end
        task.wait(0.05)
    end

    -- COMPLETE — exit animation
    glimmerLooping = false
    task.wait(0.5)

    -- Flash white
    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    flash.BackgroundTransparency = 1
    flash.BorderSizePixel = 0
    flash.ZIndex = 999
    flash.Parent = ScreenGui

    TweenService:Create(flash, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0,
    }):Play()
    task.wait(0.3)

    TweenService:Create(flash, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1,
    }):Play()
    task.wait(0.5)

    -- Fade out & destroy
    TweenService:Create(ScreenGui, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {}):Play()
    TweenService:Create(Container, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -260, 0.4, -170),
        BackgroundTransparency = 1,
    }):Play()
    TweenService:Create(Background, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
        BackgroundTransparency = 1,
    }):Play()
    task.wait(0.9)

    -- Execute the actual script
    ScreenGui:Destroy()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/maybemenu.lua", true))()
end)
