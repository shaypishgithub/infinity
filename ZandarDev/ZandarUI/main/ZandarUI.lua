--[[
    ███████╗ █████╗ ███╗   ██╗██████╗  █████╗ ██████╗     ██╗   ██╗██╗
    ╚══███╔╝██╔══██╗████╗  ██║██╔══██╗██╔══██╗██╔══██╗    ██║   ██║██║
      ███╔╝ ███████║██╔██╗ ██║██║  ██║███████║██████╔╝    ██║   ██║██║
     ███╔╝  ██╔══██║██║╚██╗██║██║  ██║██╔══██║██╔══██╗    ██║   ██║██║
    ███████╗██║  ██║██║ ╚████║██████╔╝██║  ██║██║  ██║    ╚██████╔╝██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝     ╚═════╝ ╚═╝

    ZandarUI v1.0.0 — Glassmorphism GUI Library for Roblox
    Author  : Zandar
    GitHub  : https://github.com/ZandarDev/ZandarUI
    License : MIT

    USAGE:
        local ZandarUI = loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/ZandarDev/ZandarUI/main/ZandarUI.lua"
        ))()

        local Window = ZandarUI.new({
            Title       = "My Hub",
            Subtitle    = "v1.0",
            Theme       = "Dark",          -- "Dark" | "Light" | "Custom"
            AccentColor = Color3.fromRGB(120, 80, 255),
        })

        local Tab = Window:AddTab("Main", "rbxassetid://...")
        Tab:AddButton("Click Me", function() print("clicked") end)
        Tab:AddToggle("God Mode", false, function(v) print(v) end)
        Tab:AddSlider("Speed", { Min=16, Max=500, Default=16 }, function(v) print(v) end)
        Tab:AddTextBox("Player Name", "Enter name...", function(v) print(v) end)
        Tab:AddDropdown("Team", {"Red","Blue","Green"}, function(v) print(v) end)
        Tab:AddColorPicker("Color", Color3.new(1,0,0), function(v) print(v) end)
        Tab:AddLabel("Hello World!")
        Tab:AddSeparator()
]]

-- ╔══════════════════════════════════════════════════════╗
-- ║                  SERVICES & CORE                     ║
-- ╚══════════════════════════════════════════════════════╝

local Players            = game:GetService("Players")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local CoreGui            = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ╔══════════════════════════════════════════════════════╗
-- ║                   THEME PRESETS                      ║
-- ╚══════════════════════════════════════════════════════╝

local Themes = {
    Dark = {
        Background      = Color3.fromRGB(12, 12, 18),
        Surface         = Color3.fromRGB(20, 20, 30),
        SurfaceGlass    = Color3.fromRGB(25, 25, 40),
        Border          = Color3.fromRGB(60, 60, 90),
        BorderLight     = Color3.fromRGB(80, 80, 120),
        Accent          = Color3.fromRGB(120, 80, 255),
        AccentHover     = Color3.fromRGB(140, 100, 255),
        AccentDim       = Color3.fromRGB(60, 40, 128),
        Text            = Color3.fromRGB(240, 240, 255),
        TextMuted       = Color3.fromRGB(140, 140, 170),
        TextDisabled    = Color3.fromRGB(80, 80, 100),
        Success         = Color3.fromRGB(80, 220, 140),
        Warning         = Color3.fromRGB(255, 200, 60),
        Error           = Color3.fromRGB(255, 80, 80),
        TabActive       = Color3.fromRGB(30, 30, 50),
        TabInactive     = Color3.fromRGB(15, 15, 25),
        InputBg         = Color3.fromRGB(15, 15, 25),
        SliderFill      = Color3.fromRGB(120, 80, 255),
        ToggleOff       = Color3.fromRGB(50, 50, 70),
        ToggleOn        = Color3.fromRGB(120, 80, 255),
        Transparency    = 0.12,  -- glass panel bg transparency
        BlurSize        = 24,
    },
    Light = {
        Background      = Color3.fromRGB(230, 230, 245),
        Surface         = Color3.fromRGB(245, 245, 255),
        SurfaceGlass    = Color3.fromRGB(255, 255, 255),
        Border          = Color3.fromRGB(190, 190, 210),
        BorderLight     = Color3.fromRGB(210, 210, 230),
        Accent          = Color3.fromRGB(100, 60, 230),
        AccentHover     = Color3.fromRGB(120, 80, 255),
        AccentDim       = Color3.fromRGB(200, 185, 245),
        Text            = Color3.fromRGB(20, 20, 40),
        TextMuted       = Color3.fromRGB(90, 90, 120),
        TextDisabled    = Color3.fromRGB(150, 150, 170),
        Success         = Color3.fromRGB(30, 160, 90),
        Warning         = Color3.fromRGB(200, 140, 0),
        Error           = Color3.fromRGB(200, 40, 40),
        TabActive       = Color3.fromRGB(220, 215, 245),
        TabInactive     = Color3.fromRGB(235, 232, 250),
        InputBg         = Color3.fromRGB(240, 238, 255),
        SliderFill      = Color3.fromRGB(100, 60, 230),
        ToggleOff       = Color3.fromRGB(180, 180, 200),
        ToggleOn        = Color3.fromRGB(100, 60, 230),
        Transparency    = 0.25,
        BlurSize        = 20,
    },
}

-- ╔══════════════════════════════════════════════════════╗
-- ║                   UTILITY FUNCTIONS                  ║
-- ╚══════════════════════════════════════════════════════╝

local function Tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local function QuickTween(obj, t, props)
    Tween(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
end

local function SpringTween(obj, t, props)
    Tween(obj, TweenInfo.new(t, Enum.EasingStyle.Back, Enum.EasingDirection.Out), props)
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging   = true
            dragStart  = input.Position
            startPos   = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function RippleEffect(button, color)
    local ripple = Instance.new("Frame")
    ripple.Size             = UDim2.new(0, 0, 0, 0)
    ripple.AnchorPoint      = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = color or Color3.new(1,1,1)
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel  = 0
    ripple.ZIndex           = button.ZIndex + 5
    ripple.Parent           = button

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple

    local mp = button.AbsolutePosition
    local ms = button.AbsoluteSize
    local mouseX = Mouse.X - mp.X
    local mouseY = Mouse.Y - mp.Y
    ripple.Position = UDim2.new(0, mouseX, 0, mouseY)

    local maxSize = math.max(ms.X, ms.Y) * 2.5
    TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1,
    }):Play()
    game:GetService("Debris"):AddItem(ripple, 0.55)
end

local function CreateGlassFrame(parent, size, position, zindex)
    local frame = Instance.new("Frame")
    frame.Size              = size or UDim2.new(1, 0, 1, 0)
    frame.Position          = position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3  = Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = 0.88
    frame.BorderSizePixel   = 0
    frame.ZIndex            = zindex or 1
    frame.Parent            = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = frame

    return frame
end

local function CreateLabel(parent, text, size, weight, color, zindex)
    local lbl = Instance.new("TextLabel")
    lbl.Size                 = size or UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text                 = text or ""
    lbl.TextColor3           = color or Color3.new(1, 1, 1)
    lbl.TextSize             = 14
    lbl.Font                 = weight or Enum.Font.GothamMedium
    lbl.TextXAlignment       = Enum.TextXAlignment.Left
    lbl.ZIndex               = zindex or 2
    lbl.Parent               = parent
    return lbl
end

-- ╔══════════════════════════════════════════════════════╗
-- ║                   MAIN LIBRARY                       ║
-- ╚══════════════════════════════════════════════════════╝

local ZandarUI = {}
ZandarUI.__index = ZandarUI
ZandarUI.Version = "1.0.0"

-- ── Destroy all existing instances ──────────────────────
function ZandarUI.Destroy()
    if CoreGui:FindFirstChild("ZandarUI") then
        CoreGui:FindFirstChild("ZandarUI"):Destroy()
    end
end

-- ── Constructor ─────────────────────────────────────────
function ZandarUI.new(config)
    ZandarUI.Destroy()

    config = config or {}
    local self = setmetatable({}, ZandarUI)

    -- Resolve theme
    local baseTheme = Themes[config.Theme] or Themes.Dark
    self.Theme = {}
    for k, v in pairs(baseTheme) do self.Theme[k] = v end

    -- Override accent if provided
    if config.AccentColor then
        self.Theme.Accent      = config.AccentColor
        self.Theme.SliderFill  = config.AccentColor
        self.Theme.ToggleOn    = config.AccentColor
        self.Theme.AccentHover = Color3.new(
            math.min(config.AccentColor.R * 1.15, 1),
            math.min(config.AccentColor.G * 1.15, 1),
            math.min(config.AccentColor.B * 1.15, 1)
        )
        self.Theme.AccentDim = Color3.new(
            config.AccentColor.R * 0.5,
            config.AccentColor.G * 0.5,
            config.AccentColor.B * 0.5
        )
    end

    -- Custom theme override
    if config.CustomTheme then
        for k, v in pairs(config.CustomTheme) do
            self.Theme[k] = v
        end
    end

    local T = self.Theme

    self._tabs    = {}
    self._active  = nil
    self._open    = true

    -- ── ScreenGui ───────────────────────────────────────
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name              = "ZandarUI"
    ScreenGui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn      = false
    ScreenGui.IgnoreGuiInset    = true
    ScreenGui.Parent            = CoreGui
    self._gui = ScreenGui

    -- ── Blur effect ─────────────────────────────────────
    local blur = Instance.new("BlurEffect")
    blur.Size   = 0
    blur.Parent = game:GetService("Lighting")
    self._blur  = blur
    QuickTween(blur, 0.4, { Size = T.BlurSize })

    -- ── Main Window ─────────────────────────────────────
    local WIN_W, WIN_H = 580, 400
    local Window = Instance.new("Frame")
    Window.Name                 = "Window"
    Window.Size                 = UDim2.new(0, WIN_W, 0, WIN_H)
    Window.Position             = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
    Window.BackgroundColor3     = T.Background
    Window.BackgroundTransparency = T.Transparency
    Window.BorderSizePixel      = 0
    Window.ClipsDescendants     = true
    Window.ZIndex               = 1
    Window.Parent               = ScreenGui
    self._window = Window

    -- rounded corners
    local winCorner = Instance.new("UICorner")
    winCorner.CornerRadius = UDim.new(0, 16)
    winCorner.Parent = Window

    -- outer glow border (using UIStroke)
    local winStroke = Instance.new("UIStroke")
    winStroke.Color          = T.Accent
    winStroke.Transparency   = 0.55
    winStroke.Thickness      = 1.5
    winStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    winStroke.Parent         = Window
    self._winStroke = winStroke

    -- Animate border glow
    local glowUp = true
    RunService.Heartbeat:Connect(function()
        if not ScreenGui.Parent then return end
        local t = glowUp and 0.35 or 0.75
        glowUp = not glowUp
        QuickTween(winStroke, 2.0, { Transparency = t })
        task.wait(2.0)
    end)

    -- entry animation
    Window.BackgroundTransparency = 1
    Window.Size = UDim2.new(0, WIN_W * 0.85, 0, WIN_H * 0.85)
    SpringTween(Window, 0.5, {
        BackgroundTransparency = T.Transparency,
        Size = UDim2.new(0, WIN_W, 0, WIN_H),
    })

    -- ── Header Bar ──────────────────────────────────────
    local Header = Instance.new("Frame")
    Header.Name                   = "Header"
    Header.Size                   = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3       = T.Surface
    Header.BackgroundTransparency = 0.3
    Header.BorderSizePixel        = 0
    Header.ZIndex                 = 3
    Header.Parent                 = Window

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = Header

    -- fix bottom corners of header
    local headerFix = Instance.new("Frame")
    headerFix.Size                   = UDim2.new(1, 0, 0, 16)
    headerFix.Position               = UDim2.new(0, 0, 1, -16)
    headerFix.BackgroundColor3       = T.Surface
    headerFix.BackgroundTransparency = 0.3
    headerFix.BorderSizePixel        = 0
    headerFix.ZIndex                 = 3
    headerFix.Parent                 = Header

    -- accent left bar
    local accentBar = Instance.new("Frame")
    accentBar.Size             = UDim2.new(0, 4, 0, 28)
    accentBar.Position         = UDim2.new(0, 14, 0.5, -14)
    accentBar.BackgroundColor3 = T.Accent
    accentBar.BorderSizePixel  = 0
    accentBar.ZIndex           = 5
    accentBar.Parent           = Header
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 2)

    -- title
    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size                 = UDim2.new(0, 220, 1, 0)
    TitleLbl.Position             = UDim2.new(0, 26, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text                 = config.Title or "ZandarUI"
    TitleLbl.TextColor3           = T.Text
    TitleLbl.TextSize             = 16
    TitleLbl.Font                 = Enum.Font.GothamBold
    TitleLbl.TextXAlignment       = Enum.TextXAlignment.Left
    TitleLbl.ZIndex               = 5
    TitleLbl.Parent               = Header

    -- subtitle
    local SubtitleLbl = Instance.new("TextLabel")
    SubtitleLbl.Size                 = UDim2.new(0, 160, 0, 16)
    SubtitleLbl.Position             = UDim2.new(0, 26, 1, -20)
    SubtitleLbl.BackgroundTransparency = 1
    SubtitleLbl.Text                 = config.Subtitle or "Powered by ZandarUI"
    SubtitleLbl.TextColor3           = T.TextMuted
    SubtitleLbl.TextSize             = 11
    SubtitleLbl.Font                 = Enum.Font.Gotham
    SubtitleLbl.TextXAlignment       = Enum.TextXAlignment.Left
    SubtitleLbl.ZIndex               = 5
    SubtitleLbl.Parent               = Header

    -- Close / Minimise buttons
    local function MakeCtrlBtn(icon, xOffset, color)
        local btn = Instance.new("TextButton")
        btn.Size                   = UDim2.new(0, 24, 0, 24)
        btn.Position               = UDim2.new(1, xOffset, 0.5, -12)
        btn.BackgroundColor3       = color
        btn.BackgroundTransparency = 0.4
        btn.BorderSizePixel        = 0
        btn.Text                   = icon
        btn.TextColor3             = T.Text
        btn.TextSize               = 13
        btn.Font                   = Enum.Font.GothamBold
        btn.ZIndex                 = 6
        btn.Parent                 = Header
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

        btn.MouseEnter:Connect(function()
            QuickTween(btn, 0.15, { BackgroundTransparency = 0.1 })
        end)
        btn.MouseLeave:Connect(function()
            QuickTween(btn, 0.15, { BackgroundTransparency = 0.4 })
        end)
        return btn
    end

    local CloseBtn = MakeCtrlBtn("✕", -12, Color3.fromRGB(255, 80, 80))
    local MinBtn   = MakeCtrlBtn("─", -42, Color3.fromRGB(255, 200, 60))

    CloseBtn.MouseButton1Click:Connect(function()
        RippleEffect(CloseBtn)
        QuickTween(Window, 0.35, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, WIN_W * 0.8, 0, WIN_H * 0.8),
        })
        QuickTween(blur, 0.35, { Size = 0 })
        task.delay(0.4, function()
            ScreenGui:Destroy()
            blur:Destroy()
        end)
    end)

    MinBtn.MouseButton1Click:Connect(function()
        RippleEffect(MinBtn)
        self._open = not self._open
        local targetH = self._open and WIN_H or 50
        SpringTween(Window, 0.4, { Size = UDim2.new(0, WIN_W, 0, targetH) })
    end)

    -- make draggable by header
    MakeDraggable(Window, Header)

    -- ── Tab Rail (left side) ─────────────────────────────
    local TabRail = Instance.new("Frame")
    TabRail.Name                   = "TabRail"
    TabRail.Size                   = UDim2.new(0, 140, 1, -50)
    TabRail.Position               = UDim2.new(0, 0, 0, 50)
    TabRail.BackgroundColor3       = T.Background
    TabRail.BackgroundTransparency = 0.15
    TabRail.BorderSizePixel        = 0
    TabRail.ZIndex                 = 2
    TabRail.Parent                 = Window

    local tabList = Instance.new("UIListLayout")
    tabList.Padding         = UDim.new(0, 4)
    tabList.SortOrder       = Enum.SortOrder.LayoutOrder
    tabList.Parent          = TabRail

    local tabPad = Instance.new("UIPadding")
    tabPad.PaddingTop    = UDim.new(0, 8)
    tabPad.PaddingLeft   = UDim.new(0, 8)
    tabPad.PaddingRight  = UDim.new(0, 8)
    tabPad.Parent        = TabRail

    -- vertical divider
    local railDiv = Instance.new("Frame")
    railDiv.Size             = UDim2.new(0, 1, 1, -50)
    railDiv.Position         = UDim2.new(0, 140, 0, 50)
    railDiv.BackgroundColor3 = T.Border
    railDiv.BackgroundTransparency = 0.5
    railDiv.BorderSizePixel  = 0
    railDiv.ZIndex           = 3
    railDiv.Parent           = Window

    -- ── Content Area ────────────────────────────────────
    local ContentArea = Instance.new("Frame")
    ContentArea.Name                   = "ContentArea"
    ContentArea.Size                   = UDim2.new(1, -142, 1, -52)
    ContentArea.Position               = UDim2.new(0, 142, 0, 52)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel        = 0
    ContentArea.ZIndex                 = 2
    ContentArea.Parent                 = Window
    self._content = ContentArea
    self._tabRail = TabRail

    -- ╔══════════════════════════════════════════════════╗
    -- ║                  TAB CLASS                       ║
    -- ╚══════════════════════════════════════════════════╝

    function self:AddTab(name, icon)
        local tabIndex = #self._tabs + 1

        -- Tab button in rail
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size                   = UDim2.new(1, 0, 0, 36)
        TabBtn.BackgroundColor3       = T.TabInactive
        TabBtn.BackgroundTransparency = 0.5
        TabBtn.BorderSizePixel        = 0
        TabBtn.Text                   = ""
        TabBtn.ZIndex                 = 4
        TabBtn.LayoutOrder            = tabIndex
        TabBtn.Parent                 = TabRail

        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)

        -- icon (if provided)
        if icon and icon ~= "" then
            local img = Instance.new("ImageLabel")
            img.Size                  = UDim2.new(0, 18, 0, 18)
            img.Position              = UDim2.new(0, 8, 0.5, -9)
            img.BackgroundTransparency = 1
            img.Image                 = icon
            img.ImageColor3           = T.TextMuted
            img.ZIndex                = 5
            img.Parent                = TabBtn
        end

        local TabName = Instance.new("TextLabel")
        TabName.Size                 = UDim2.new(1, icon and -30 or -10, 1, 0)
        TabName.Position             = UDim2.new(0, icon and 30 or 10, 0, 0)
        TabName.BackgroundTransparency = 1
        TabName.Text                 = name
        TabName.TextColor3           = T.TextMuted
        TabName.TextSize             = 13
        TabName.Font                 = Enum.Font.GothamMedium
        TabName.TextXAlignment       = Enum.TextXAlignment.Left
        TabName.ZIndex               = 5
        TabName.Parent               = TabBtn

        -- Active indicator
        local ActiveBar = Instance.new("Frame")
        ActiveBar.Size               = UDim2.new(0, 3, 0, 20)
        ActiveBar.Position           = UDim2.new(1, -3, 0.5, -10)
        ActiveBar.BackgroundColor3   = T.Accent
        ActiveBar.BackgroundTransparency = 1
        ActiveBar.BorderSizePixel    = 0
        ActiveBar.ZIndex             = 6
        ActiveBar.Parent             = TabBtn
        Instance.new("UICorner", ActiveBar).CornerRadius = UDim.new(0, 2)

        -- Content page
        local Page = Instance.new("ScrollingFrame")
        Page.Name                      = "Page_" .. name
        Page.Size                      = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency    = 1
        Page.BorderSizePixel           = 0
        Page.ScrollBarThickness        = 3
        Page.ScrollBarImageColor3      = T.Accent
        Page.CanvasSize                = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize       = Enum.AutomaticSize.Y
        Page.Visible                   = false
        Page.ZIndex                    = 3
        Page.Parent                    = ContentArea

        local pageList = Instance.new("UIListLayout")
        pageList.Padding     = UDim.new(0, 6)
        pageList.SortOrder   = Enum.SortOrder.LayoutOrder
        pageList.Parent      = Page

        local pagePad = Instance.new("UIPadding")
        pagePad.PaddingTop    = UDim.new(0, 10)
        pagePad.PaddingLeft   = UDim.new(0, 10)
        pagePad.PaddingRight  = UDim.new(0, 14)
        pagePad.PaddingBottom = UDim.new(0, 10)
        pagePad.Parent        = Page

        local Tab = { _page = Page, _order = 0, _theme = T, _gui = ScreenGui }

        local function SetActive(active)
            if active then
                QuickTween(TabBtn, 0.2, { BackgroundColor3 = T.TabActive, BackgroundTransparency = 0.1 })
                QuickTween(TabName, 0.2, { TextColor3 = T.Text })
                QuickTween(ActiveBar, 0.2, { BackgroundTransparency = 0 })
                Page.Visible = true
            else
                QuickTween(TabBtn, 0.2, { BackgroundColor3 = T.TabInactive, BackgroundTransparency = 0.5 })
                QuickTween(TabName, 0.2, { TextColor3 = T.TextMuted })
                QuickTween(ActiveBar, 0.2, { BackgroundTransparency = 1 })
                Page.Visible = false
            end
        end

        Tab._setActive = SetActive

        TabBtn.MouseButton1Click:Connect(function()
            RippleEffect(TabBtn, T.Accent)
            if self._active then self._active._setActive(false) end
            SetActive(true)
            self._active = Tab
        end)

        TabBtn.MouseEnter:Connect(function()
            if self._active ~= Tab then
                QuickTween(TabBtn, 0.15, { BackgroundTransparency = 0.25 })
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if self._active ~= Tab then
                QuickTween(TabBtn, 0.15, { BackgroundTransparency = 0.5 })
            end
        end)

        table.insert(self._tabs, Tab)

        -- Auto-select first tab
        if #self._tabs == 1 then
            SetActive(true)
            self._active = Tab
        end

        -- ── Helper to make a card frame ──────────────────
        local function MakeCard(h, layoutOrder)
            Tab._order = Tab._order + 1
            local card = Instance.new("Frame")
            card.Size                      = UDim2.new(1, 0, 0, h or 40)
            card.BackgroundColor3          = T.SurfaceGlass
            card.BackgroundTransparency    = 0.45
            card.BorderSizePixel           = 0
            card.ZIndex                    = 4
            card.LayoutOrder               = layoutOrder or Tab._order
            card.Parent                    = Page

            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

            local stroke = Instance.new("UIStroke")
            stroke.Color         = T.Border
            stroke.Transparency  = 0.6
            stroke.Thickness     = 1
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            stroke.Parent        = card

            return card
        end

        -- ╔══════════════════════════════════════════════╗
        -- ║               ELEMENT METHODS                ║
        -- ╚══════════════════════════════════════════════╝

        -- ── Label ────────────────────────────────────────
        function Tab:AddLabel(text, color)
            local card = MakeCard(36)
            local lbl  = Instance.new("TextLabel")
            lbl.Size                 = UDim2.new(1, -16, 1, 0)
            lbl.Position             = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text                 = text or ""
            lbl.TextColor3           = color or T.Text
            lbl.TextSize             = 13
            lbl.Font                 = Enum.Font.Gotham
            lbl.TextXAlignment       = Enum.TextXAlignment.Left
            lbl.ZIndex               = 5
            lbl.Parent               = card

            local api = {}
            function api:Set(t) lbl.Text = t end
            function api:SetColor(c) lbl.TextColor3 = c end
            return api
        end

        -- ── Separator ────────────────────────────────────
        function Tab:AddSeparator(label)
            Tab._order = Tab._order + 1
            local wrap = Instance.new("Frame")
            wrap.Size                   = UDim2.new(1, 0, 0, 24)
            wrap.BackgroundTransparency = 1
            wrap.BorderSizePixel        = 0
            wrap.ZIndex                 = 4
            wrap.LayoutOrder            = Tab._order
            wrap.Parent                 = Page

            local line = Instance.new("Frame")
            line.Size             = UDim2.new(1, -24, 0, 1)
            line.Position         = UDim2.new(0, 12, 0.5, 0)
            line.BackgroundColor3 = T.Border
            line.BackgroundTransparency = 0.4
            line.BorderSizePixel  = 0
            line.ZIndex           = 5
            line.Parent           = wrap

            if label then
                local lbl = Instance.new("TextLabel")
                lbl.Size                 = UDim2.new(0, 0, 1, 0)
                lbl.AutomaticSize        = Enum.AutomaticSize.X
                lbl.Position             = UDim2.new(0.5, 0, 0, 0)
                lbl.AnchorPoint          = Vector2.new(0.5, 0)
                lbl.BackgroundColor3     = T.Background
                lbl.BackgroundTransparency = 0
                lbl.Text                 = "  " .. label .. "  "
                lbl.TextColor3           = T.TextMuted
                lbl.TextSize             = 11
                lbl.Font                 = Enum.Font.Gotham
                lbl.ZIndex               = 6
                lbl.Parent               = wrap
            end
        end

        -- ── Button ───────────────────────────────────────
        function Tab:AddButton(text, callback, icon)
            local card = MakeCard(40)
            card.BackgroundTransparency = 0.35

            local btn = Instance.new("TextButton")
            btn.Size                   = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text                   = ""
            btn.ZIndex                 = 6
            btn.Parent                 = card

            if icon and icon ~= "" then
                local img = Instance.new("ImageLabel")
                img.Size               = UDim2.new(0, 18, 0, 18)
                img.Position           = UDim2.new(0, 10, 0.5, -9)
                img.BackgroundTransparency = 1
                img.Image              = icon
                img.ImageColor3        = T.Text
                img.ZIndex             = 7
                img.Parent             = card
            end

            local lbl = Instance.new("TextLabel")
            lbl.Size                 = UDim2.new(1, -20, 1, 0)
            lbl.Position             = UDim2.new(0, icon and 34 or 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text                 = text or "Button"
            lbl.TextColor3           = T.Text
            lbl.TextSize             = 13
            lbl.Font                 = Enum.Font.GothamMedium
            lbl.TextXAlignment       = Enum.TextXAlignment.Left
            lbl.ZIndex               = 5
            lbl.Parent               = card

            -- arrow hint
            local arrow = Instance.new("TextLabel")
            arrow.Size                 = UDim2.new(0, 20, 1, 0)
            arrow.Position             = UDim2.new(1, -22, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text                 = "›"
            arrow.TextColor3           = T.TextMuted
            arrow.TextSize             = 18
            arrow.Font                 = Enum.Font.GothamBold
            arrow.ZIndex               = 5
            arrow.Parent               = card

            btn.MouseEnter:Connect(function()
                QuickTween(card, 0.15, {
                    BackgroundColor3 = T.Accent,
                    BackgroundTransparency = 0.55,
                })
                QuickTween(arrow, 0.15, { TextColor3 = T.Text })
            end)
            btn.MouseLeave:Connect(function()
                QuickTween(card, 0.15, {
                    BackgroundColor3 = T.SurfaceGlass,
                    BackgroundTransparency = 0.35,
                })
                QuickTween(arrow, 0.15, { TextColor3 = T.TextMuted })
            end)
            btn.MouseButton1Click:Connect(function()
                RippleEffect(card, T.Accent)
                if callback then callback() end
            end)

            local api = {}
            function api:SetText(t) lbl.Text = t end
            function api:SetCallback(cb) callback = cb end
            return api
        end

        -- ── Toggle ───────────────────────────────────────
        function Tab:AddToggle(text, default, callback)
            local state = default or false
            local card  = MakeCard(44)

            local lbl = CreateLabel(card, text, UDim2.new(1, -70, 1, 0), Enum.Font.GothamMedium, T.Text, 5)
            lbl.Position = UDim2.new(0, 12, 0, 0)

            local track = Instance.new("Frame")
            track.Size                   = UDim2.new(0, 44, 0, 24)
            track.Position               = UDim2.new(1, -56, 0.5, -12)
            track.BackgroundColor3       = state and T.ToggleOn or T.ToggleOff
            track.BorderSizePixel        = 0
            track.ZIndex                 = 5
            track.Parent                 = card
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame")
            knob.Size             = UDim2.new(0, 18, 0, 18)
            knob.Position         = state and UDim2.new(0, 23, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            knob.BorderSizePixel  = 0
            knob.ZIndex           = 6
            knob.Parent           = track
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local btn = Instance.new("TextButton")
            btn.Size                   = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text                   = ""
            btn.ZIndex                 = 7
            btn.Parent                 = card

            btn.MouseButton1Click:Connect(function()
                state = not state
                QuickTween(track, 0.2, { BackgroundColor3 = state and T.ToggleOn or T.ToggleOff })
                QuickTween(knob, 0.2, { Position = state and UDim2.new(0, 23, 0.5, -9) or UDim2.new(0, 3, 0.5, -9) })
                if callback then callback(state) end
            end)

            local api = {}
            function api:Set(v)
                state = v
                QuickTween(track, 0.2, { BackgroundColor3 = state and T.ToggleOn or T.ToggleOff })
                QuickTween(knob, 0.2, { Position = state and UDim2.new(0, 23, 0.5, -9) or UDim2.new(0, 3, 0.5, -9) })
                if callback then callback(state) end
            end
            function api:Get() return state end
            return api
        end

        -- ── Slider ───────────────────────────────────────
        function Tab:AddSlider(text, options, callback)
            options = options or {}
            local min  = options.Min     or 0
            local max  = options.Max     or 100
            local def  = options.Default or min
            local suf  = options.Suffix  or ""
            local val  = def

            local card = MakeCard(58)

            local topRow = Instance.new("Frame")
            topRow.Size                   = UDim2.new(1, -24, 0, 22)
            topRow.Position               = UDim2.new(0, 12, 0, 8)
            topRow.BackgroundTransparency = 1
            topRow.ZIndex                 = 5
            topRow.Parent                 = card

            local lbl = CreateLabel(topRow, text, UDim2.new(0.7, 0, 1, 0), Enum.Font.GothamMedium, T.Text, 5)

            local valLbl = Instance.new("TextLabel")
            valLbl.Size                 = UDim2.new(0.3, 0, 1, 0)
            valLbl.Position             = UDim2.new(0.7, 0, 0, 0)
            valLbl.BackgroundTransparency = 1
            valLbl.Text                 = tostring(math.floor(val)) .. suf
            valLbl.TextColor3           = T.Accent
            valLbl.TextSize             = 13
            valLbl.Font                 = Enum.Font.GothamBold
            valLbl.TextXAlignment       = Enum.TextXAlignment.Right
            valLbl.ZIndex               = 5
            valLbl.Parent               = topRow

            -- track background
            local track = Instance.new("Frame")
            track.Size             = UDim2.new(1, -24, 0, 6)
            track.Position         = UDim2.new(0, 12, 0, 38)
            track.BackgroundColor3 = T.ToggleOff
            track.BorderSizePixel  = 0
            track.ZIndex           = 5
            track.Parent           = card
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            -- fill
            local pct  = (val - min) / (max - min)
            local fill = Instance.new("Frame")
            fill.Size             = UDim2.new(pct, 0, 1, 0)
            fill.BackgroundColor3 = T.SliderFill
            fill.BorderSizePixel  = 0
            fill.ZIndex           = 6
            fill.Parent           = track
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            -- thumb
            local thumb = Instance.new("Frame")
            thumb.Size             = UDim2.new(0, 14, 0, 14)
            thumb.Position         = UDim2.new(pct, -7, 0.5, -7)
            thumb.BackgroundColor3 = Color3.new(1, 1, 1)
            thumb.BorderSizePixel  = 0
            thumb.ZIndex           = 7
            thumb.Parent           = track
            Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

            local draggingSlider = false

            local function UpdateSlider(input)
                local rel    = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                rel          = math.clamp(rel, 0, 1)
                val          = math.floor(min + (max - min) * rel)
                QuickTween(fill,  0.05, { Size = UDim2.new(rel, 0, 1, 0) })
                QuickTween(thumb, 0.05, { Position = UDim2.new(rel, -7, 0.5, -7) })
                valLbl.Text = tostring(val) .. suf
                if callback then callback(val) end
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = true
                    UpdateSlider(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                end
            end)

            local api = {}
            function api:Set(v)
                val = math.clamp(v, min, max)
                local r = (val - min) / (max - min)
                QuickTween(fill,  0.1, { Size = UDim2.new(r, 0, 1, 0) })
                QuickTween(thumb, 0.1, { Position = UDim2.new(r, -7, 0.5, -7) })
                valLbl.Text = tostring(math.floor(val)) .. suf
                if callback then callback(val) end
            end
            function api:Get() return val end
            return api
        end

        -- ── TextBox ──────────────────────────────────────
        function Tab:AddTextBox(text, placeholder, callback)
            local card = MakeCard(58)

            local lbl = CreateLabel(card, text, UDim2.new(1, -16, 0, 20), Enum.Font.GothamMedium, T.Text, 5)
            lbl.Position = UDim2.new(0, 12, 0, 6)

            local inputBg = Instance.new("Frame")
            inputBg.Size             = UDim2.new(1, -24, 0, 26)
            inputBg.Position         = UDim2.new(0, 12, 0, 28)
            inputBg.BackgroundColor3 = T.InputBg
            inputBg.BackgroundTransparency = 0.3
            inputBg.BorderSizePixel  = 0
            inputBg.ZIndex           = 5
            inputBg.Parent           = card
            Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0, 7)

            local inputStroke = Instance.new("UIStroke")
            inputStroke.Color         = T.Border
            inputStroke.Transparency  = 0.5
            inputStroke.Thickness     = 1
            inputStroke.Parent        = inputBg

            local box = Instance.new("TextBox")
            box.Size                 = UDim2.new(1, -16, 1, 0)
            box.Position             = UDim2.new(0, 8, 0, 0)
            box.BackgroundTransparency = 1
            box.Text                 = ""
            box.PlaceholderText      = placeholder or "Type here..."
            box.PlaceholderColor3    = T.TextDisabled
            box.TextColor3           = T.Text
            box.TextSize             = 12
            box.Font                 = Enum.Font.Gotham
            box.TextXAlignment       = Enum.TextXAlignment.Left
            box.ClearTextOnFocus     = false
            box.ZIndex               = 6
            box.Parent               = inputBg

            box.Focused:Connect(function()
                QuickTween(inputStroke, 0.15, { Color = T.Accent, Transparency = 0 })
            end)
            box.FocusLost:Connect(function(enter)
                QuickTween(inputStroke, 0.15, { Color = T.Border, Transparency = 0.5 })
                if callback then callback(box.Text, enter) end
            end)

            local api = {}
            function api:Set(v) box.Text = v end
            function api:Get() return box.Text end
            return api
        end

        -- ── Dropdown ─────────────────────────────────────
        function Tab:AddDropdown(text, options, callback)
            local selected = options[1]
            local open     = false

            local card = MakeCard(44)
            card.ClipsDescendants = false

            local lbl = CreateLabel(card, text, UDim2.new(0.5, 0, 1, 0), Enum.Font.GothamMedium, T.Text, 5)
            lbl.Position = UDim2.new(0, 12, 0, 0)

            local selLbl = Instance.new("TextLabel")
            selLbl.Size                 = UDim2.new(0.4, -30, 1, 0)
            selLbl.Position             = UDim2.new(0.5, 0, 0, 0)
            selLbl.BackgroundTransparency = 1
            selLbl.Text                 = selected
            selLbl.TextColor3           = T.Accent
            selLbl.TextSize             = 13
            selLbl.Font                 = Enum.Font.GothamMedium
            selLbl.TextXAlignment       = Enum.TextXAlignment.Right
            selLbl.ZIndex               = 5
            selLbl.Parent               = card

            local arrow = Instance.new("TextLabel")
            arrow.Size                 = UDim2.new(0, 20, 1, 0)
            arrow.Position             = UDim2.new(1, -22, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text                 = "▾"
            arrow.TextColor3           = T.TextMuted
            arrow.TextSize             = 14
            arrow.Font                 = Enum.Font.GothamBold
            arrow.ZIndex               = 5
            arrow.Parent               = card

            local dropPanel = Instance.new("Frame")
            dropPanel.Size             = UDim2.new(1, 0, 0, 0)
            dropPanel.Position         = UDim2.new(0, 0, 1, 4)
            dropPanel.BackgroundColor3 = T.Surface
            dropPanel.BackgroundTransparency = 0.1
            dropPanel.BorderSizePixel  = 0
            dropPanel.ClipsDescendants = true
            dropPanel.ZIndex           = 20
            dropPanel.Parent           = card

            Instance.new("UICorner", dropPanel).CornerRadius = UDim.new(0, 10)

            local dStroke = Instance.new("UIStroke")
            dStroke.Color = T.Border; dStroke.Transparency = 0.4; dStroke.Thickness = 1
            dStroke.Parent = dropPanel

            local dList = Instance.new("UIListLayout")
            dList.Padding   = UDim.new(0, 2)
            dList.SortOrder = Enum.SortOrder.LayoutOrder
            dList.Parent    = dropPanel

            local dPad = Instance.new("UIPadding")
            dPad.PaddingTop = UDim.new(0,4); dPad.PaddingBottom = UDim.new(0,4)
            dPad.PaddingLeft = UDim.new(0,4); dPad.PaddingRight = UDim.new(0,4)
            dPad.Parent = dropPanel

            local targetH = #options * 32 + 8

            for i, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size                   = UDim2.new(1, 0, 0, 30)
                optBtn.BackgroundColor3       = T.SurfaceGlass
                optBtn.BackgroundTransparency = 0.5
                optBtn.BorderSizePixel        = 0
                optBtn.Text                   = opt
                optBtn.TextColor3             = T.Text
                optBtn.TextSize               = 13
                optBtn.Font                   = Enum.Font.Gotham
                optBtn.ZIndex                 = 21
                optBtn.LayoutOrder            = i
                optBtn.Parent                 = dropPanel
                Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 7)

                optBtn.MouseEnter:Connect(function()
                    QuickTween(optBtn, 0.1, { BackgroundColor3 = T.Accent, BackgroundTransparency = 0.4 })
                end)
                optBtn.MouseLeave:Connect(function()
                    QuickTween(optBtn, 0.1, { BackgroundColor3 = T.SurfaceGlass, BackgroundTransparency = 0.5 })
                end)
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    selLbl.Text = opt
                    open = false
                    QuickTween(dropPanel, 0.2, { Size = UDim2.new(1, 0, 0, 0) })
                    QuickTween(arrow, 0.2, { Rotation = 0 })
                    if callback then callback(opt) end
                end)
            end

            local togBtn = Instance.new("TextButton")
            togBtn.Size                   = UDim2.new(1, 0, 1, 0)
            togBtn.BackgroundTransparency = 1
            togBtn.Text                   = ""
            togBtn.ZIndex                 = 6
            togBtn.Parent                 = card

            togBtn.MouseButton1Click:Connect(function()
                open = not open
                QuickTween(dropPanel, 0.25, { Size = UDim2.new(1, 0, 0, open and targetH or 0) })
                QuickTween(arrow, 0.2, { Rotation = open and 180 or 0 })
            end)

            local api = {}
            function api:Set(v)
                for _, o in ipairs(options) do
                    if o == v then selected = v; selLbl.Text = v; if callback then callback(v) end; break end
                end
            end
            function api:Get() return selected end
            function api:Refresh(newOpts)
                -- rebuild options
                for _, c in ipairs(dropPanel:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                options = newOpts
                -- (rebuild code omitted for brevity — call AddDropdown again)
            end
            return api
        end

        -- ── ColorPicker ──────────────────────────────────
        function Tab:AddColorPicker(text, default, callback)
            local color   = default or Color3.new(1, 0, 0)
            local open    = false

            local card = MakeCard(44)
            card.ClipsDescendants = false

            local lbl = CreateLabel(card, text, UDim2.new(1, -70, 1, 0), Enum.Font.GothamMedium, T.Text, 5)
            lbl.Position = UDim2.new(0, 12, 0, 0)

            local preview = Instance.new("Frame")
            preview.Size             = UDim2.new(0, 24, 0, 24)
            preview.Position         = UDim2.new(1, -36, 0.5, -12)
            preview.BackgroundColor3 = color
            preview.BorderSizePixel  = 0
            preview.ZIndex           = 5
            preview.Parent           = card
            Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 6)

            -- simple hue strip picker panel
            local panel = Instance.new("Frame")
            panel.Size             = UDim2.new(1, 0, 0, 0)
            panel.Position         = UDim2.new(0, 0, 1, 4)
            panel.BackgroundColor3 = T.Surface
            panel.BackgroundTransparency = 0.1
            panel.BorderSizePixel  = 0
            panel.ClipsDescendants = true
            panel.ZIndex           = 20
            panel.Parent           = card
            Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

            local panelStroke = Instance.new("UIStroke")
            panelStroke.Color = T.Border; panelStroke.Transparency = 0.4; panelStroke.Thickness = 1
            panelStroke.Parent = panel

            -- Hue bar
            local hueBar = Instance.new("Frame")
            hueBar.Size             = UDim2.new(1, -20, 0, 16)
            hueBar.Position         = UDim2.new(0, 10, 0, 10)
            hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
            hueBar.BorderSizePixel  = 0
            hueBar.ZIndex           = 21
            hueBar.Parent           = panel
            Instance.new("UICorner", hueBar).CornerRadius = UDim.new(1, 0)

            -- Rainbow gradient
            local grad = Instance.new("UIGradient")
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,   Color3.fromHSV(0,   1, 1)),
                ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1,1)),
                ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1,1)),
                ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50,1,1)),
                ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1,1)),
                ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1,1)),
                ColorSequenceKeypoint.new(1,   Color3.fromHSV(1,   1,1)),
            })
            grad.Parent = hueBar

            local hueKnob = Instance.new("Frame")
            hueKnob.Size             = UDim2.new(0, 10, 1, 4)
            hueKnob.AnchorPoint      = Vector2.new(0.5, 0.5)
            hueKnob.Position         = UDim2.new(0, 0, 0.5, 0)
            hueKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            hueKnob.BorderSizePixel  = 0
            hueKnob.ZIndex           = 22
            hueKnob.Parent           = hueBar
            Instance.new("UICorner", hueKnob).CornerRadius = UDim.new(0, 3)

            -- Saturation label row
            local satLbl = Instance.new("TextLabel")
            satLbl.Size               = UDim2.new(1,-20,0,14)
            satLbl.Position           = UDim2.new(0,10,0,32)
            satLbl.BackgroundTransparency = 1
            satLbl.Text               = "Saturation / Brightness"
            satLbl.TextColor3         = T.TextMuted
            satLbl.TextSize           = 10
            satLbl.Font               = Enum.Font.Gotham
            satLbl.TextXAlignment     = Enum.TextXAlignment.Left
            satLbl.ZIndex             = 21
            satLbl.Parent             = panel

            local hue, sat, val2 = Color3.toHSV(color)
            local draggingHue = false

            local function UpdateColor()
                color = Color3.fromHSV(hue, sat, val2)
                preview.BackgroundColor3 = color
                if callback then callback(color) end
            end

            hueBar.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingHue = true
                    local rel = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                    hue = rel
                    hueKnob.Position = UDim2.new(rel, 0, 0.5, 0)
                    UpdateColor()
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if draggingHue and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                    hue = rel
                    hueKnob.Position = UDim2.new(rel, 0, 0.5, 0)
                    UpdateColor()
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false end
            end)

            local openBtn = Instance.new("TextButton")
            openBtn.Size                   = UDim2.new(1, 0, 1, 0)
            openBtn.BackgroundTransparency = 1
            openBtn.Text                   = ""
            openBtn.ZIndex                 = 6
            openBtn.Parent                 = card

            openBtn.MouseButton1Click:Connect(function()
                open = not open
                QuickTween(panel, 0.25, { Size = UDim2.new(1, 0, 0, open and 52 or 0) })
            end)

            local api = {}
            function api:Set(c)
                color = c; preview.BackgroundColor3 = c
                hue, sat, val2 = Color3.toHSV(c)
                hueKnob.Position = UDim2.new(hue, 0, 0.5, 0)
                if callback then callback(c) end
            end
            function api:Get() return color end
            return api
        end

        -- ── Section Header ───────────────────────────────
        function Tab:AddSection(title)
            Tab._order = Tab._order + 1
            local hdr = Instance.new("TextLabel")
            hdr.Size                 = UDim2.new(1, -12, 0, 26)
            hdr.BackgroundTransparency = 1
            hdr.Text                 = title or "Section"
            hdr.TextColor3           = T.Accent
            hdr.TextSize             = 11
            hdr.Font                 = Enum.Font.GothamBold
            hdr.TextXAlignment       = Enum.TextXAlignment.Left
            hdr.LayoutOrder          = Tab._order
            hdr.ZIndex               = 4
            hdr.Parent               = Page
            -- letter spacing via padding
            local p = Instance.new("UIPadding")
            p.PaddingLeft = UDim.new(0, 4)
            p.Parent = hdr
        end

        return Tab
    end

    -- ── Notification ─────────────────────────────────────
    function self:Notify(options)
        options = options or {}
        local title = options.Title   or "Notification"
        local msg   = options.Message or ""
        local dur   = options.Duration or 4
        local ntype = options.Type or "Info"  -- "Info"|"Success"|"Warning"|"Error"

        local colors = {
            Info    = T.Accent,
            Success = T.Success,
            Warning = T.Warning,
            Error   = T.Error,
        }
        local acol = colors[ntype] or T.Accent

        local W = 300

        -- find or create notification holder
        local holder = ScreenGui:FindFirstChild("Notifications")
        if not holder then
            holder = Instance.new("Frame")
            holder.Name                   = "Notifications"
            holder.Size                   = UDim2.new(0, W, 1, 0)
            holder.Position               = UDim2.new(1, -(W+16), 0, 0)
            holder.BackgroundTransparency = 1
            holder.BorderSizePixel        = 0
            holder.ZIndex                 = 100
            holder.Parent                 = ScreenGui

            local list = Instance.new("UIListLayout")
            list.VerticalAlignment = Enum.VerticalAlignment.Bottom
            list.Padding           = UDim.new(0, 8)
            list.SortOrder         = Enum.SortOrder.LayoutOrder
            list.Parent            = holder

            local pad = Instance.new("UIPadding")
            pad.PaddingBottom = UDim.new(0, 16)
            pad.Parent        = holder
        end

        local notif = Instance.new("Frame")
        notif.Size                   = UDim2.new(1, 0, 0, 70)
        notif.BackgroundColor3       = T.Surface
        notif.BackgroundTransparency = 0.15
        notif.BorderSizePixel        = 0
        notif.ZIndex                 = 101
        notif.ClipsDescendants       = true
        notif.Parent                 = holder
        Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 12)

        local nStroke = Instance.new("UIStroke")
        nStroke.Color = acol; nStroke.Transparency = 0.4; nStroke.Thickness = 1
        nStroke.Parent = notif

        local accent = Instance.new("Frame")
        accent.Size             = UDim2.new(0, 4, 1, 0)
        accent.BackgroundColor3 = acol
        accent.BorderSizePixel  = 0
        accent.ZIndex           = 102
        accent.Parent           = notif
        Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

        local tLbl = Instance.new("TextLabel")
        tLbl.Size                 = UDim2.new(1, -20, 0, 22)
        tLbl.Position             = UDim2.new(0, 14, 0, 8)
        tLbl.BackgroundTransparency = 1
        tLbl.Text                 = title
        tLbl.TextColor3           = T.Text
        tLbl.TextSize             = 13
        tLbl.Font                 = Enum.Font.GothamBold
        tLbl.TextXAlignment       = Enum.TextXAlignment.Left
        tLbl.ZIndex               = 102
        tLbl.Parent               = notif

        local mLbl = Instance.new("TextLabel")
        mLbl.Size                 = UDim2.new(1, -20, 0, 32)
        mLbl.Position             = UDim2.new(0, 14, 0, 30)
        mLbl.BackgroundTransparency = 1
        mLbl.Text                 = msg
        mLbl.TextColor3           = T.TextMuted
        mLbl.TextSize             = 12
        mLbl.Font                 = Enum.Font.Gotham
        mLbl.TextXAlignment       = Enum.TextXAlignment.Left
        mLbl.TextWrapped          = true
        mLbl.ZIndex               = 102
        mLbl.Parent               = notif

        -- progress bar
        local prog = Instance.new("Frame")
        prog.Size             = UDim2.new(1, 0, 0, 2)
        prog.Position         = UDim2.new(0, 0, 1, -2)
        prog.BackgroundColor3 = acol
        prog.BorderSizePixel  = 0
        prog.ZIndex           = 103
        prog.Parent           = notif

        -- slide in
        notif.Position = UDim2.new(1.1, 0, 0, 0)
        SpringTween(notif, 0.4, { Position = UDim2.new(0, 0, 0, 0) })
        TweenService:Create(prog, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 0, 2)
        }):Play()

        task.delay(dur, function()
            QuickTween(notif, 0.3, { Position = UDim2.new(1.1, 0, 0, 0) })
            task.delay(0.35, function() notif:Destroy() end)
        end)
    end

    -- ── SetTheme (runtime) ───────────────────────────────
    function self:SetAccent(color)
        self.Theme.Accent     = color
        self.Theme.SliderFill = color
        self.Theme.ToggleOn   = color
        winStroke.Color       = color
    end

    -- ── Keybind to toggle GUI ────────────────────────────
    local togKey = config.ToggleKey or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.KeyCode == togKey then
            self._open = not self._open
            QuickTween(Window, 0.35, { BackgroundTransparency = self._open and T.Transparency or 1 })
            if self._open then
                Window.Visible = true
                SpringTween(Window, 0.4, {
                    Size = UDim2.new(0, WIN_W, 0, WIN_H),
                })
            else
                QuickTween(Window, 0.3, {
                    Size = UDim2.new(0, WIN_W * 0.9, 0, WIN_H * 0.9),
                })
                task.delay(0.35, function() Window.Visible = false end)
            end
        end
    end)

    return self
end

return ZandarUI
