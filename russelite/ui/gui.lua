-- RussElite Main Interface - gui.lua (iOS 2026 Glass Edition)
local Gui = {}
local Database = nil

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local CONFIG = {
    Title = "RussElite",
    Version = "v2.2",
    TextColor = Color3.fromRGB(255, 255, 255),
    SecondaryText = Color3.fromRGB(180, 180, 180),
    Glass = Color3.fromRGB(18, 18, 18),
    StrokeColor = Color3.fromRGB(255, 255, 255),
    WindowSize = UDim2.new(0, 580, 0, 400),
    ToggleButtonSize = UDim2.new(0, 110, 0, 40),
    BorderRadius = 18,
    BaseURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/russelite/base/base.lua"
}

-- Safe Universal Container
local function GetSafeContainer()
    local sg = Instance.new("ScreenGui")
    sg.Name = "RussEliteHub"
    sg.ResetOnSpawn = false

    if gethui then
        sg.Parent = gethui()
    else
        local success = pcall(function() sg.Parent = CoreGui end)
        if not success then
            sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        end
    end
    return sg
end

local function tween(obj, props, dur)
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function applyGlassStyle(frame, radius, strokeTrans, bgTrans)
    frame.BackgroundColor3 = CONFIG.Glass
    frame.BackgroundTransparency = bgTrans or 0.25

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or CONFIG.BorderRadius)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.StrokeColor
    stroke.Transparency = strokeTrans or 0.85
    stroke.Thickness = 1.2
    stroke.Parent = frame
end

function Gui:CreateToggleButton()
    local btn = Instance.new("TextButton")
    btn.Name = "ToggleButton"
    btn.Size = CONFIG.ToggleButtonSize
    btn.Position = UDim2.new(0.95, -120, 0.08, 0)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = self.Container

    applyGlassStyle(btn, 20, 0.7, 0.2)

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 6)
    layout.Parent = btn

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 18, 0, 18)
    icon.BackgroundTransparency = 1
    icon.Text = ""
    icon.TextColor3 = CONFIG.TextColor
    icon.TextSize = 16
    icon.Font = Enum.Font.GothamBold
    icon.Parent = btn

    local label = Instance.new("TextLabel")
    label.Name = "BtnLabel"
    label.Size = UDim2.new(0, 60, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = "Открыть"
    label.TextColor3 = CONFIG.TextColor
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.Parent = btn

    return btn
end

function Gui:CreateMainWindow()
    local window = Instance.new("Frame")
    window.Name = "MainWindow"
    window.Size = CONFIG.WindowSize
    window.Position = UDim2.new(0.5, -290, 0.5, -200)
    window.Visible = false
    window.ClipsDescendants = true
    window.Parent = self.Container

    applyGlassStyle(window, CONFIG.BorderRadius, 0.8, 0.15)

    -- Header
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 42)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = window

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0.4, 0, 1, 0)
    titleText.Position = UDim2.new(0.04, 0, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = CONFIG.Title
    titleText.TextColor3 = CONFIG.TextColor
    titleText.TextSize = 18
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(0.95, -24, 0.2, 0)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = CONFIG.TextColor
    closeBtn.TextSize = 11
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    applyGlassStyle(closeBtn, 12, 0.85, 0.4)

    -- Content
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(0.92, 0, 1, -80)
    contentArea.Position = UDim2.new(0.04, 0, 0, 48)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = window

    local categoryScroll = Instance.new("ScrollingFrame")
    categoryScroll.Size = UDim2.new(1, 0, 1, 0)
    categoryScroll.BackgroundTransparency = 1
    categoryScroll.ScrollBarThickness = 2
    categoryScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    categoryScroll.Parent = contentArea

    local categoryGrid = Instance.new("UIGridLayout")
    categoryGrid.CellSize = UDim2.new(0, 120, 0, 90)
    categoryGrid.CellPadding = UDim2.new(0, 8, 0, 8)
    categoryGrid.Parent = categoryScroll

    -- Status Bar
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(0.92, 0, 0, 20)
    statusBar.Position = UDim2.new(0.04, 0, 1, -25)
    statusBar.Parent = window
    applyGlassStyle(statusBar, 6, 0.9, 0.5)

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -10, 1, 0)
    statusText.Position = UDim2.new(0, 5, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Готово"
    statusText.TextColor3 = CONFIG.SecondaryText
    statusText.TextSize = 10
    statusText.Font = Enum.Font.Gotham
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusBar

    return {
        Window = window,
        TitleBar = titleBar,
        CloseButton = closeBtn,
        CategoryScroll = categoryScroll,
        StatusText = statusText
    }
end

function Gui:ToggleWindow()
    local window = self.Elements.Window
    local btnLabel = self.Elements.ToggleButton:FindFirstChild("BtnLabel")

    if window.Visible then
        if btnLabel then btnLabel.Text = "Открыть" end
        tween(window, {Size = UDim2.new(0, 580, 0, 0), BackgroundTransparency = 1}, 0.2)
        task.wait(0.2)
        window.Visible = false
    else
        window.Visible = true
        if btnLabel then btnLabel.Text = "Закрыть" end
        window.Size = UDim2.new(0, 580, 0, 0)
        tween(window, {Size = CONFIG.WindowSize, BackgroundTransparency = 0.15}, 0.25)
    end
end

function Gui:MakeDraggable()
    local window = self.Elements.Window
    local titleBar = self.Elements.TitleBar
    local dragging, dragStart, startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Gui:Init()
    self.Container = GetSafeContainer()
    self.Elements = {}

    self.Elements.ToggleButton = self:CreateToggleButton()
    local parts = self:CreateMainWindow()
    for k, v in pairs(parts) do self.Elements[k] = v end

    self.Elements.ToggleButton.MouseButton1Click:Connect(function() self:ToggleWindow() end)
    self.Elements.CloseButton.MouseButton1Click:Connect(function() self:ToggleWindow() end)

    self:MakeDraggable()
end

Gui:Init()
