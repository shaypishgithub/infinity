--// RussElite Bootstrapper
--// Renders a frosted glass loading screen and smoothly transitions into the main UI.

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local GuiTarget = LocalPlayer:FindFirstChildWhichIsA("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Animation Presets
local tweenInfoFast = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local tweenInfoSlow = TweenInfo.new(1.2, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)

-- Utility Function: Create Glass Element
local function createGlass(props)
    local element = Instance.new(props.ClassName)
    element.Name = props.Name or "Glass"
    element.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    element.BackgroundTransparency = props.BackgroundTransparency or 0.15
    element.Size = props.Size or UDim2.new(1, 0, 1, 0)
    element.Position = props.Position or UDim2.new(0, 0, 0, 0)
    element.AnchorPoint = props.AnchorPoint or Vector2.new(0, 0)
    element.BorderSizePixel = 0
    element.Parent = props.Parent or GuiTarget

    Instance.new("UICorner", element).CornerRadius = UDim.new(0, props.CornerRadius or 12)

    local stroke = Instance.new("UIStroke", element)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.85
    stroke.Thickness = 1

    if props.InnerShadow then
        local innerGlow = Instance.new("ImageLabel", element)
        innerGlow.Name = "InnerGlow"
        innerGlow.BackgroundTransparency = 1
        innerGlow.Size = UDim2.new(1, 0, 1, 0)
        innerGlow.Image = "rbxassetid://7669168585"
        innerGlow.ImageColor3 = Color3.fromRGB(255, 255, 255)
        innerGlow.ImageTransparency = 0.92
        innerGlow.ScaleType = Enum.ScaleType.Slice
        innerGlow.SliceCenter = Rect.new(100, 100, 100, 100)
    end

    return element
end

-- Build Loader UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RussEliteLoader"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = GuiTarget

local MainFrame = createGlass({
    Parent = ScreenGui,
    Size = UDim2.new(0, 350, 0, 200),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    CornerRadius = 20,
    InnerShadow = true
})

local Title = Instance.new("TextLabel", MainFrame)
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 20, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "RussElite"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 32
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

local Subtitle = Instance.new("TextLabel", MainFrame)
Subtitle.Name = "Subtitle"
Subtitle.Size = UDim2.new(1, -40, 0, 20)
Subtitle.Position = UDim2.new(0, 20, 0, 70)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Initializing modules..."
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 14
Subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

-- Progress Bar Frame
local BarBg = Instance.new("Frame", MainFrame)
BarBg.Name = "BarBackground"
BarBg.Size = UDim2.new(1, -40, 0, 6)
BarBg.Position = UDim2.new(0, 20, 0, 150)
BarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
BarBg.BackgroundTransparency = 0.5
BarBg.BorderSizePixel = 0
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

local BarFill = Instance.new("Frame", BarBg)
BarFill.Name = "Fill"
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BarFill.BackgroundTransparency = 0.1
BarFill.BorderSizePixel = 0
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

-- Simulate Loading & Tween Out
task.spawn(function()
    local fakeLoadSteps = {0.15, 0.4, 0.65, 0.85, 1.0}
    local statusTexts = {"Parsing UI layout...", "Loading dependencies...", "Securing environment...", "Finalizing...", "Done!"}

    for i = 1, #fakeLoadSteps do
        TweenService:Create(BarFill, TweenInfo.new(0.8, Enum.EasingStyle.Expo, Enum.EasingDirection.Out), {Size = UDim2.new(fakeLoadSteps[i], 0, 1, 0)}):Play()
        Subtitle.Text = statusTexts[i]
        task.wait(0.6)
    end

    task.wait(0.4)

    -- Fade out loader
    local fadeOut = TweenService:Create(MainFrame, tweenInfoSlow, {BackgroundTransparency = 1})
    fadeOut:Play()
    TweenService:Create(Title, tweenInfoSlow, {TextTransparency = 1}):Play()
    TweenService:Create(Subtitle, tweenInfoSlow, {TextTransparency = 1}):Play()
    TweenService:Create(BarBg, tweenInfoSlow, {BackgroundTransparency = 1}):Play()
    TweenService:Create(BarFill, tweenInfoSlow, {BackgroundTransparency = 1}):Play()

    fadeOut.Completed:Connect(function()
        ScreenGui:Destroy()
        -- Execute Main GUI
        loadstring(game:HttpGet('https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/ui/gui.lua'))()
    end)
end)
