--[[
    ███████╗ █████╗ ███╗   ██╗██████╗  █████╗ ██████╗     ██╗   ██╗██╗
    ╚══███╔╝██╔══██╗████╗  ██║██╔══██╗██╔══██╗██╔══██╗    ██║   ██║██║
      ███╔╝ ███████║██╔██╗ ██║██║  ██║███████║██████╔╝    ██║   ██║██║
     ███╔╝  ██╔══██║██║╚██╗██║██║  ██║██╔══██║██╔══██╗    ██║   ██║██║
    ███████╗██║  ██║██║ ╚████║██████╔╝██║  ██║██║  ██║    ╚██████╔╝██║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝     ╚═════╝ ╚═╝

    ZandarUI v2.0.0 — Monochrome Glass GUI Library for Roblox
    Author  : Zandar
    Style   : Black/White Glassmorphism

    USAGE:
        local ZandarUI = loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/ZandarDev/ZandarUI/main/ZandarUI.lua"
        ))()

        local Window = ZandarUI.new({
            Title       = "My Hub",
            Subtitle    = "v2.0",
            ToggleKey   = Enum.KeyCode.RightShift,
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
        Window:Notify({ Title="Hello", Message="Welcome!", Duration=4, Type="Info" })
]]

-- ╔══════════════════════════════════════════════════════╗
-- ║                  SERVICES & CORE                     ║
-- ╚══════════════════════════════════════════════════════╝

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ╔══════════════════════════════════════════════════════╗
-- ║             MONOCHROME GLASS THEME                   ║
-- ╚══════════════════════════════════════════════════════╝

local T = {
    -- Backgrounds
    Background      = Color3.fromRGB(8,  8,  10),   -- near-black base
    Surface         = Color3.fromRGB(18, 18, 22),   -- card surface
    SurfaceGlass    = Color3.fromRGB(30, 30, 36),   -- glass card
    SurfaceLight    = Color3.fromRGB(45, 45, 55),   -- hover states

    -- Borders
    Border          = Color3.fromRGB(70,  70,  80),
    BorderGlow      = Color3.fromRGB(180, 180, 200),
    BorderHover     = Color3.fromRGB(220, 220, 235),

    -- Text (silver → white gradient feel via separate labels)
    Text            = Color3.fromRGB(235, 235, 245),   -- near white
    TextMuted       = Color3.fromRGB(130, 130, 150),   -- silver-grey
    TextDisabled    = Color3.fromRGB(65,  65,  78),
    TextAccent      = Color3.fromRGB(200, 200, 215),   -- light silver for values

    -- Accents (white/silver only)
    Accent          = Color3.fromRGB(210, 210, 225),
    AccentBright    = Color3.fromRGB(255, 255, 255),
    AccentDim       = Color3.fromRGB(80,  80,  95),

    -- Controls
    ToggleOff       = Color3.fromRGB(38,  38,  46),
    ToggleOn        = Color3.fromRGB(200, 200, 215),
    SliderFill      = Color3.fromRGB(200, 200, 215),
    InputBg         = Color3.fromRGB(12,  12,  16),

    -- States
    Success         = Color3.fromRGB(160, 220, 170),
    Warning         = Color3.fromRGB(220, 200, 130),
    Error           = Color3.fromRGB(220, 120, 120),
    Info            = Color3.fromRGB(180, 180, 210),

    -- Glass
    Transparency    = 0.10,
    BlurSize        = 20,
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

local function SmoothTween(obj, t, props)
    Tween(obj, TweenInfo.new(t, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), props)
end

local function SpringTween(obj, t, props)
    Tween(obj, TweenInfo.new(t, Enum.EasingStyle.Back, Enum.EasingDirection.Out), props)
end

local function ElasticTween(obj, t, props)
    Tween(obj, TweenInfo.new(t, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), props)
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
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
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Ripple effect (white tint)
local function RippleEffect(button)
    local ripple = Instance.new("Frame")
    ripple.Size             = UDim2.new(0, 0, 0, 0)
    ripple.AnchorPoint      = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = Color3.new(1, 1, 1)
    ripple.BackgroundTransparency = 0.82
    ripple.BorderSizePixel  = 0
    ripple.ZIndex           = button.ZIndex + 10
    ripple.Parent           = button
    Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)

    local mp  = button.AbsolutePosition
    local ms  = button.AbsoluteSize
    ripple.Position = UDim2.new(0, Mouse.X - mp.X, 0, Mouse.Y - mp.Y)

    local maxSize = math.max(ms.X, ms.Y) * 2.8
    TweenService:Create(ripple, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1,
    }):Play()
    game:GetService("Debris"):AddItem(ripple, 0.6)
end

-- Glass card builder
local function MakeGlassFrame(parent, size, pos, radius, zindex)
    local f = Instance.new("Frame")
    f.Size             = size or UDim2.new(1, 0, 1, 0)
    f.Position         = pos  or UDim2.new(0, 0, 0, 0)
    f.BackgroundColor3 = T.SurfaceGlass
    f.BackgroundTransparency = 0.42
    f.BorderSizePixel  = 0
    f.ZIndex           = zindex or 4
    f.Parent           = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, radius or 12)

    local stroke = Instance.new("UIStroke")
    stroke.Color        = T.Border
    stroke.Transparency = 0.55
    stroke.Thickness    = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent       = f
    return f, stroke
end

local function CreateLabel(parent, text, size, pos, font, color, zindex)
    local lbl = Instance.new("TextLabel")
    lbl.Size                 = size or UDim2.new(1, 0, 0, 20)
    lbl.Position             = pos  or UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                 = text or ""
    lbl.TextColor3           = color or T.Text
    lbl.TextSize             = 13
    lbl.Font                 = font or Enum.Font.GothamMedium
    lbl.TextXAlignment       = Enum.TextXAlignment.Left
    lbl.ZIndex               = zindex or 5
    lbl.Parent               = parent
    return lbl
end

-- ╔══════════════════════════════════════════════════════╗
-- ║                   MAIN LIBRARY                       ║
-- ╚══════════════════════════════════════════════════════╝

local ZandarUI = {}
ZandarUI.__index = ZandarUI
ZandarUI.Version = "2.0.0"

function ZandarUI.Destroy()
    if CoreGui:FindFirstChild("ZandarUI") then CoreGui:FindFirstChild("ZandarUI"):Destroy() end
end

function ZandarUI.new(config)
    ZandarUI.Destroy()
    config = config or {}

    local self = setmetatable({}, ZandarUI)
    self._tabs   = {}
    self._active = nil
    self._open   = true

    -- ── ScreenGui ───────────────────────────────────────
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name           = "ZandarUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn   = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent         = CoreGui
    self._gui = ScreenGui

    -- ── Blur ────────────────────────────────────────────
    local blur = Instance.new("BlurEffect")
    blur.Size   = 0
    blur.Parent = game:GetService("Lighting")
    self._blur  = blur
    SmoothTween(blur, 0.5, { Size = T.BlurSize })

    -- ── Overlay dimmer ──────────────────────────────────
    local Overlay = Instance.new("Frame")
    Overlay.Size                   = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 1
    Overlay.BorderSizePixel        = 0
    Overlay.ZIndex                 = 0
    Overlay.Parent                 = ScreenGui
    SmoothTween(Overlay, 0.5, { BackgroundTransparency = 0.55 })

    -- ── Main Window ─────────────────────────────────────
    local WIN_W, WIN_H = 600, 420

    local Window = Instance.new("Frame")
    Window.Name             = "Window"
    Window.Size             = UDim2.new(0, 0, 0, 0)
    Window.Position         = UDim2.new(0.5, 0, 0.5, 0)
    Window.AnchorPoint      = Vector2.new(0.5, 0.5)
    Window.BackgroundColor3 = T.Background
    Window.BackgroundTransparency = 0.08
    Window.BorderSizePixel  = 0
    Window.ClipsDescendants = true
    Window.ZIndex           = 1
    Window.Parent           = ScreenGui
    self._window = Window

    Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 18)

    -- Outer glass stroke (animates brightness)
    local winStroke = Instance.new("UIStroke")
    winStroke.Color          = T.BorderGlow
    winStroke.Transparency   = 0.6
    winStroke.Thickness      = 1.2
    winStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    winStroke.Parent         = Window

    -- Subtle shimmer on stroke
    local shimmerUp = true
    RunService.Heartbeat:Connect(function()
        if not ScreenGui.Parent then return end
        local target = shimmerUp and 0.3 or 0.72
        shimmerUp = not shimmerUp
        SmoothTween(winStroke, 2.5, { Transparency = target })
        task.wait(2.5)
    end)

    -- OPEN ANIMATION — scale up from center with elastic bounce
    ElasticTween(Window, 0.65, {
        Size     = UDim2.new(0, WIN_W, 0, WIN_H),
        Position = UDim2.new(0.5, -WIN_W / 2, 0.5, -WIN_H / 2),
    })

    -- ── Header ──────────────────────────────────────────
    local Header = Instance.new("Frame")
    Header.Name             = "Header"
    Header.Size             = UDim2.new(1, 0, 0, 52)
    Header.BackgroundColor3 = T.Surface
    Header.BackgroundTransparency = 0.18
    Header.BorderSizePixel  = 0
    Header.ZIndex           = 3
    Header.Parent           = Window

    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 18)

    -- Fix bottom corners of header
    local headerFix = Instance.new("Frame")
    headerFix.Size             = UDim2.new(1, 0, 0, 18)
    headerFix.Position         = UDim2.new(0, 0, 1, -18)
    headerFix.BackgroundColor3 = T.Surface
    headerFix.BackgroundTransparency = 0.18
    headerFix.BorderSizePixel  = 0
    headerFix.ZIndex           = 3
    headerFix.Parent           = Header

    -- Bottom border line on header
    local headerLine = Instance.new("Frame")
    headerLine.Size             = UDim2.new(1, -20, 0, 1)
    headerLine.Position         = UDim2.new(0, 10, 1, -1)
    headerLine.BackgroundColor3 = T.Border
    headerLine.BackgroundTransparency = 0.35
    headerLine.BorderSizePixel  = 0
    headerLine.ZIndex           = 4
    headerLine.Parent           = Header

    -- Thin accent left bar (white)
    local accentBar = Instance.new("Frame")
    accentBar.Size             = UDim2.new(0, 3, 0, 24)
    accentBar.Position         = UDim2.new(0, 16, 0.5, -12)
    accentBar.BackgroundColor3 = T.AccentBright
    accentBar.BackgroundTransparency = 0.1
    accentBar.BorderSizePixel  = 0
    accentBar.ZIndex           = 5
    accentBar.Parent           = Header
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1, 0)

    -- Title (white)
    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size                 = UDim2.new(0, 240, 0, 26)
    TitleLbl.Position             = UDim2.new(0, 28, 0, 8)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text                 = config.Title or "ZandarUI"
    TitleLbl.TextColor3           = T.AccentBright
    TitleLbl.TextSize             = 15
    TitleLbl.Font                 = Enum.Font.GothamBold
    TitleLbl.TextXAlignment       = Enum.TextXAlignment.Left
    TitleLbl.ZIndex               = 5
    TitleLbl.Parent               = Header

    -- Subtitle (silver)
    local SubLbl = Instance.new("TextLabel")
    SubLbl.Size                 = UDim2.new(0, 240, 0, 14)
    SubLbl.Position             = UDim2.new(0, 28, 0, 34)
    SubLbl.BackgroundTransparency = 1
    SubLbl.Text                 = config.Subtitle or "Monochrome Glass"
    SubLbl.TextColor3           = T.TextMuted
    SubLbl.TextSize             = 10
    SubLbl.Font                 = Enum.Font.Gotham
    SubLbl.TextXAlignment       = Enum.TextXAlignment.Left
    SubLbl.ZIndex               = 5
    SubLbl.Parent               = Header

    -- ── Control Buttons (круглые) ────────────────────────
    local function MakeCtrlBtn(symbol, offsetX, hoverCol)
        local btn = Instance.new("TextButton")
        btn.Size             = UDim2.new(0, 22, 0, 22)
        btn.Position         = UDim2.new(1, offsetX, 0.5, -11)
        btn.BackgroundColor3 = T.SurfaceGlass
        btn.BackgroundTransparency = 0.35
        btn.BorderSizePixel  = 0
        btn.Text             = symbol
        btn.TextColor3       = T.TextMuted
        btn.TextSize         = 11
        btn.Font             = Enum.Font.GothamBold
        btn.ZIndex           = 6
        btn.Parent           = Header
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

        local stroke = Instance.new("UIStroke")
        stroke.Color       = T.Border
        stroke.Transparency = 0.5
        stroke.Thickness   = 1
        stroke.Parent      = btn

        btn.MouseEnter:Connect(function()
            QuickTween(btn, 0.15, { BackgroundColor3 = hoverCol, BackgroundTransparency = 0.0, TextColor3 = T.AccentBright })
            QuickTween(stroke, 0.15, { Color = T.AccentBright, Transparency = 0.3 })
        end)
        btn.MouseLeave:Connect(function()
            QuickTween(btn, 0.15, { BackgroundColor3 = T.SurfaceGlass, BackgroundTransparency = 0.35, TextColor3 = T.TextMuted })
            QuickTween(stroke, 0.15, { Color = T.Border, Transparency = 0.5 })
        end)
        return btn, stroke
    end

    local CloseBtn = MakeCtrlBtn("✕", -14, Color3.fromRGB(60, 30, 30))
    local MinBtn   = MakeCtrlBtn("−", -42, Color3.fromRGB(35, 35, 42))

    -- CLOSE — shrink to center & dissolve
    CloseBtn.MouseButton1Click:Connect(function()
        RippleEffect(CloseBtn)
        SmoothTween(blur, 0.4, { Size = 0 })
        SmoothTween(Overlay, 0.4, { BackgroundTransparency = 1 })
        QuickTween(Window, 0.35, {
            BackgroundTransparency = 1,
            Size     = UDim2.new(0, WIN_W * 0.6, 0, WIN_H * 0.6),
            Position = UDim2.new(0.5, -WIN_W * 0.3, 0.5, -WIN_H * 0.3),
        })
        task.delay(0.4, function()
            ScreenGui:Destroy()
            blur:Destroy()
        end)
    end)

    -- MINIMISE — collapse to header only, round pill
    MinBtn.MouseButton1Click:Connect(function()
        RippleEffect(MinBtn)
        self._open = not self._open
        if self._open then
            -- Expand back
            Window.ClipsDescendants = false
            task.wait(0.01)
            Window.ClipsDescendants = true
            SpringTween(Window, 0.45, {
                Size     = UDim2.new(0, WIN_W, 0, WIN_H),
                Position = UDim2.new(0.5, -WIN_W / 2, 0.5, -WIN_H / 2),
            })
            Instance.findFirstChildOfClass(Window, "UICorner").CornerRadius = UDim.new(0, 18)
        else
            -- Collapse to pill
            SpringTween(Window, 0.4, {
                Size     = UDim2.new(0, WIN_W, 0, 52),
                Position = UDim2.new(0.5, -WIN_W / 2, 0.5, -26),
            })
        end
    end)

    MakeDraggable(Window, Header)

    -- ── Tab Rail ────────────────────────────────────────
    local TabRail = Instance.new("Frame")
    TabRail.Name             = "TabRail"
    TabRail.Size             = UDim2.new(0, 148, 1, -52)
    TabRail.Position         = UDim2.new(0, 0, 0, 52)
    TabRail.BackgroundColor3 = T.Background
    TabRail.BackgroundTransparency = 0.05
    TabRail.BorderSizePixel  = 0
    TabRail.ZIndex           = 2
    TabRail.Parent           = Window
    self._tabRail = TabRail

    local tabList = Instance.new("UIListLayout")
    tabList.Padding   = UDim.new(0, 4)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Parent    = TabRail

    local tabPad = Instance.new("UIPadding")
    tabPad.PaddingTop   = UDim.new(0, 10)
    tabPad.PaddingLeft  = UDim.new(0, 8)
    tabPad.PaddingRight = UDim.new(0, 8)
    tabPad.Parent       = TabRail

    -- Divider
    local railDiv = Instance.new("Frame")
    railDiv.Size             = UDim2.new(0, 1, 1, -52)
    railDiv.Position         = UDim2.new(0, 148, 0, 52)
    railDiv.BackgroundColor3 = T.Border
    railDiv.BackgroundTransparency = 0.4
    railDiv.BorderSizePixel  = 0
    railDiv.ZIndex           = 3
    railDiv.Parent           = Window

    -- ── Content Area ────────────────────────────────────
    local ContentArea = Instance.new("Frame")
    ContentArea.Name             = "ContentArea"
    ContentArea.Size             = UDim2.new(1, -150, 1, -54)
    ContentArea.Position         = UDim2.new(0, 150, 0, 54)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel  = 0
    ContentArea.ZIndex           = 2
    ContentArea.Parent           = Window
    self._content = ContentArea

    -- ╔══════════════════════════════════════════════════╗
    -- ║                  TAB METHOD                      ║
    -- ╚══════════════════════════════════════════════════╝

    function self:AddTab(name, icon)
        local tabIndex = #self._tabs + 1

        -- Tab button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size             = UDim2.new(1, 0, 0, 36)
        TabBtn.BackgroundColor3 = T.Surface
        TabBtn.BackgroundTransparency = 0.65
        TabBtn.BorderSizePixel  = 0
        TabBtn.Text             = ""
        TabBtn.ZIndex           = 4
        TabBtn.LayoutOrder      = tabIndex
        TabBtn.Parent           = TabRail
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)

        local tabStroke = Instance.new("UIStroke")
        tabStroke.Color       = T.Border
        tabStroke.Transparency = 0.75
        tabStroke.Thickness   = 1
        tabStroke.Parent      = TabBtn

        if icon and icon ~= "" then
            local img = Instance.new("ImageLabel")
            img.Size             = UDim2.new(0, 16, 0, 16)
            img.Position         = UDim2.new(0, 8, 0.5, -8)
            img.BackgroundTransparency = 1
            img.Image            = icon
            img.ImageColor3      = T.TextMuted
            img.ZIndex           = 5
            img.Parent           = TabBtn
        end

        local TabName = Instance.new("TextLabel")
        TabName.Size             = UDim2.new(1, icon and -28 or -12, 1, 0)
        TabName.Position         = UDim2.new(0, icon and 28 or 10, 0, 0)
        TabName.BackgroundTransparency = 1
        TabName.Text             = name
        TabName.TextColor3       = T.TextMuted
        TabName.TextSize         = 12
        TabName.Font             = Enum.Font.GothamMedium
        TabName.TextXAlignment   = Enum.TextXAlignment.Left
        TabName.ZIndex           = 5
        TabName.Parent           = TabBtn

        -- Active left indicator bar
        local ActiveBar = Instance.new("Frame")
        ActiveBar.Size             = UDim2.new(0, 2, 0, 18)
        ActiveBar.Position         = UDim2.new(0, 0, 0.5, -9)
        ActiveBar.BackgroundColor3 = T.AccentBright
        ActiveBar.BackgroundTransparency = 1
        ActiveBar.BorderSizePixel  = 0
        ActiveBar.ZIndex           = 6
        ActiveBar.Parent           = TabBtn
        Instance.new("UICorner", ActiveBar).CornerRadius = UDim.new(1, 0)

        -- Page
        local Page = Instance.new("ScrollingFrame")
        Page.Name                  = "Page_" .. name
        Page.Size                  = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel       = 0
        Page.ScrollBarThickness    = 2
        Page.ScrollBarImageColor3  = T.Accent
        Page.CanvasSize            = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize   = Enum.AutomaticSize.Y
        Page.Visible               = false
        Page.ZIndex                = 3
        Page.Parent                = ContentArea

        local pageList = Instance.new("UIListLayout")
        pageList.Padding   = UDim.new(0, 5)
        pageList.SortOrder = Enum.SortOrder.LayoutOrder
        pageList.Parent    = Page

        local pagePad = Instance.new("UIPadding")
        pagePad.PaddingTop    = UDim.new(0, 10)
        pagePad.PaddingLeft   = UDim.new(0, 10)
        pagePad.PaddingRight  = UDim.new(0, 12)
        pagePad.PaddingBottom = UDim.new(0, 10)
        pagePad.Parent        = Page

        local Tab = { _page = Page, _order = 0 }

        local function SetActive(active)
            if active then
                QuickTween(TabBtn, 0.2, { BackgroundColor3 = T.SurfaceLight, BackgroundTransparency = 0.25 })
                QuickTween(TabName, 0.2, { TextColor3 = T.AccentBright })
                QuickTween(ActiveBar, 0.2, { BackgroundTransparency = 0 })
                QuickTween(tabStroke, 0.2, { Color = T.BorderGlow, Transparency = 0.45 })
                Page.Visible = true
            else
                QuickTween(TabBtn, 0.2, { BackgroundColor3 = T.Surface, BackgroundTransparency = 0.65 })
                QuickTween(TabName, 0.2, { TextColor3 = T.TextMuted })
                QuickTween(ActiveBar, 0.2, { BackgroundTransparency = 1 })
                QuickTween(tabStroke, 0.2, { Color = T.Border, Transparency = 0.75 })
                Page.Visible = false
            end
        end

        Tab._setActive = SetActive

        TabBtn.MouseButton1Click:Connect(function()
            RippleEffect(TabBtn)
            if self._active then self._active._setActive(false) end
            SetActive(true)
            self._active = Tab
        end)

        TabBtn.MouseEnter:Connect(function()
            if self._active ~= Tab then
                QuickTween(TabBtn, 0.15, { BackgroundTransparency = 0.45 })
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if self._active ~= Tab then
                QuickTween(TabBtn, 0.15, { BackgroundTransparency = 0.65 })
            end
        end)

        table.insert(self._tabs, Tab)
        if #self._tabs == 1 then
            SetActive(true)
            self._active = Tab
        end

        -- ── Card factory ─────────────────────────────────
        local function MakeCard(h)
            Tab._order = Tab._order + 1
            local card, stroke = MakeGlassFrame(
                Page,
                UDim2.new(1, 0, 0, h or 40),
                UDim2.new(0, 0, 0, 0),
                10, 4
            )
            card.LayoutOrder = Tab._order
            return card, stroke
        end

        -- ══════════════════════════════════════════════════
        --  ELEMENTS
        -- ══════════════════════════════════════════════════

        -- ── Label ────────────────────────────────────────
        function Tab:AddLabel(text, color)
            local card = MakeCard(36)
            local lbl  = Instance.new("TextLabel")
            lbl.Size             = UDim2.new(1, -16, 1, 0)
            lbl.Position         = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text             = text or ""
            lbl.TextColor3       = color or T.Text
            lbl.TextSize         = 13
            lbl.Font             = Enum.Font.Gotham
            lbl.TextXAlignment   = Enum.TextXAlignment.Left
            lbl.ZIndex           = 5
            lbl.Parent           = card
            local api = {}
            function api:Set(t) lbl.Text = t end
            function api:SetColor(c) lbl.TextColor3 = c end
            return api
        end

        -- ── Separator ────────────────────────────────────
        function Tab:AddSeparator(label)
            Tab._order = Tab._order + 1
            local wrap = Instance.new("Frame")
            wrap.Size             = UDim2.new(1, 0, 0, 22)
            wrap.BackgroundTransparency = 1
            wrap.BorderSizePixel  = 0
            wrap.ZIndex           = 4
            wrap.LayoutOrder      = Tab._order
            wrap.Parent           = Page

            local line = Instance.new("Frame")
            line.Size             = UDim2.new(1, -20, 0, 1)
            line.Position         = UDim2.new(0, 10, 0.5, 0)
            line.BackgroundColor3 = T.Border
            line.BackgroundTransparency = 0.35
            line.BorderSizePixel  = 0
            line.ZIndex           = 5
            line.Parent           = wrap

            -- Gradient on separator line
            local grad = Instance.new("UIGradient")
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                ColorSequenceKeypoint.new(0.3, Color3.fromRGB(180, 180, 200)),
                ColorSequenceKeypoint.new(0.7, Color3.fromRGB(180, 180, 200)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
            })
            grad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.2, 0.35),
                NumberSequenceKeypoint.new(0.8, 0.35),
                NumberSequenceKeypoint.new(1, 1),
            })
            grad.Parent = line

            if label then
                local bg = Instance.new("Frame")
                bg.Size             = UDim2.new(0, 0, 1, 0)
                bg.AutomaticSize    = Enum.AutomaticSize.X
                bg.Position         = UDim2.new(0.5, 0, 0, 0)
                bg.AnchorPoint      = Vector2.new(0.5, 0)
                bg.BackgroundColor3 = T.Background
                bg.BackgroundTransparency = 0
                bg.BorderSizePixel  = 0
                bg.ZIndex           = 6
                bg.Parent           = wrap

                local lbl = Instance.new("TextLabel")
                lbl.Size            = UDim2.new(0, 0, 1, 0)
                lbl.AutomaticSize   = Enum.AutomaticSize.X
                lbl.BackgroundTransparency = 1
                lbl.Text            = "  " .. label .. "  "
                lbl.TextColor3      = T.TextMuted
                lbl.TextSize        = 10
                lbl.Font            = Enum.Font.Gotham
                lbl.ZIndex          = 7
                lbl.Parent          = bg
            end
        end

        -- ── Section ──────────────────────────────────────
        function Tab:AddSection(title)
            Tab._order = Tab._order + 1
            local hdr = Instance.new("TextLabel")
            hdr.Size             = UDim2.new(1, -12, 0, 24)
            hdr.BackgroundTransparency = 1
            hdr.Text             = (title or "Section"):upper()
            hdr.TextColor3       = T.Accent
            hdr.TextSize         = 10
            hdr.Font             = Enum.Font.GothamBold
            hdr.TextXAlignment   = Enum.TextXAlignment.Left
            hdr.LayoutOrder      = Tab._order
            hdr.ZIndex           = 4
            hdr.Parent           = Page

            local pad = Instance.new("UIPadding")
            pad.PaddingLeft = UDim.new(0, 6)
            pad.Parent = hdr

            -- Letter-spacing gradient (white shimmer)
            local g = Instance.new("UIGradient")
            g.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 120, 140)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 220, 235)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 120, 140)),
            })
            g.Parent = hdr
        end

        -- ── Button (круглые края, ripple) ────────────────
        function Tab:AddButton(text, callback, icon)
            local card, stroke = MakeCard(40)
            card.BackgroundTransparency = 0.38

            -- Hover: full white border glow
            local btn = Instance.new("TextButton")
            btn.Size             = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text             = ""
            btn.ZIndex           = 6
            btn.Parent           = card

            if icon and icon ~= "" then
                local img = Instance.new("ImageLabel")
                img.Size             = UDim2.new(0, 16, 0, 16)
                img.Position         = UDim2.new(0, 10, 0.5, -8)
                img.BackgroundTransparency = 1
                img.Image            = icon
                img.ImageColor3      = T.Text
                img.ZIndex           = 7
                img.Parent           = card
            end

            local lbl = Instance.new("TextLabel")
            lbl.Size             = UDim2.new(1, -32, 1, 0)
            lbl.Position         = UDim2.new(0, icon and 32 or 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text             = text or "Button"
            lbl.TextColor3       = T.Text
            lbl.TextSize         = 13
            lbl.Font             = Enum.Font.GothamMedium
            lbl.TextXAlignment   = Enum.TextXAlignment.Left
            lbl.ZIndex           = 5
            lbl.Parent           = card

            -- Gradient shimmer on text (grey → white)
            local textGrad = Instance.new("UIGradient")
            textGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(175, 175, 190)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 240, 255)),
            })
            textGrad.Rotation = 90
            textGrad.Parent   = lbl

            local arrow = Instance.new("TextLabel")
            arrow.Size             = UDim2.new(0, 18, 1, 0)
            arrow.Position         = UDim2.new(1, -22, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text             = "›"
            arrow.TextColor3       = T.TextMuted
            arrow.TextSize         = 18
            arrow.Font             = Enum.Font.GothamBold
            arrow.ZIndex           = 5
            arrow.Parent           = card

            btn.MouseEnter:Connect(function()
                QuickTween(card, 0.18, { BackgroundColor3 = T.SurfaceLight, BackgroundTransparency = 0.18 })
                QuickTween(stroke, 0.18, { Color = T.BorderGlow, Transparency = 0.25 })
                QuickTween(arrow, 0.15, { TextColor3 = T.AccentBright, Position = UDim2.new(1, -18, 0, 0) })
            end)
            btn.MouseLeave:Connect(function()
                QuickTween(card, 0.18, { BackgroundColor3 = T.SurfaceGlass, BackgroundTransparency = 0.38 })
                QuickTween(stroke, 0.18, { Color = T.Border, Transparency = 0.55 })
                QuickTween(arrow, 0.15, { TextColor3 = T.TextMuted, Position = UDim2.new(1, -22, 0, 0) })
            end)
            btn.MouseButton1Click:Connect(function()
                RippleEffect(card)
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

            local lbl = CreateLabel(card, text,
                UDim2.new(1, -72, 1, 0), UDim2.new(0, 12, 0, 0),
                Enum.Font.GothamMedium, T.Text, 5)

            -- Shimmer on label text
            local lg = Instance.new("UIGradient")
            lg.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 160, 175)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 235, 245)),
            })
            lg.Rotation = 90
            lg.Parent   = lbl

            -- Track
            local track = Instance.new("Frame")
            track.Size             = UDim2.new(0, 42, 0, 22)
            track.Position         = UDim2.new(1, -54, 0.5, -11)
            track.BackgroundColor3 = state and T.ToggleOn or T.ToggleOff
            track.BorderSizePixel  = 0
            track.ZIndex           = 5
            track.Parent           = card
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local tStroke = Instance.new("UIStroke")
            tStroke.Color       = state and T.BorderGlow or T.Border
            tStroke.Transparency = state and 0.45 or 0.6
            tStroke.Thickness   = 1
            tStroke.Parent      = track

            -- Knob
            local knob = Instance.new("Frame")
            knob.Size             = UDim2.new(0, 16, 0, 16)
            knob.Position         = state and UDim2.new(0, 23, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            knob.BackgroundColor3 = state and T.AccentBright or T.TextMuted
            knob.BorderSizePixel  = 0
            knob.ZIndex           = 6
            knob.Parent           = track
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local btn = Instance.new("TextButton")
            btn.Size             = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text             = ""
            btn.ZIndex           = 7
            btn.Parent           = card

            local function Apply(v)
                state = v
                QuickTween(track, 0.22, { BackgroundColor3 = state and T.ToggleOn or T.ToggleOff })
                QuickTween(tStroke, 0.22, { Color = state and T.BorderGlow or T.Border, Transparency = state and 0.45 or 0.6 })
                QuickTween(knob, 0.22, { Position = state and UDim2.new(0, 23, 0.5, -8) or UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = state and T.AccentBright or T.TextMuted })
                if callback then callback(state) end
            end

            btn.MouseButton1Click:Connect(function() Apply(not state) end)

            local api = {}
            function api:Set(v) Apply(v) end
            function api:Get() return state end
            return api
        end

        -- ── Slider ───────────────────────────────────────
        function Tab:AddSlider(text, options, callback)
            options = options or {}
            local min = options.Min     or 0
            local max = options.Max     or 100
            local def = options.Default or min
            local suf = options.Suffix  or ""
            local val = def

            local card = MakeCard(58)

            local topRow = Instance.new("Frame")
            topRow.Size             = UDim2.new(1, -24, 0, 20)
            topRow.Position         = UDim2.new(0, 12, 0, 9)
            topRow.BackgroundTransparency = 1
            topRow.ZIndex           = 5
            topRow.Parent           = card

            local lbl = CreateLabel(topRow, text,
                UDim2.new(0.65, 0, 1, 0), UDim2.new(0, 0, 0, 0),
                Enum.Font.GothamMedium, T.Text, 5)

            -- Text gradient
            local sg = Instance.new("UIGradient")
            sg.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 150, 165)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 230, 245)),
            })
            sg.Rotation = 90
            sg.Parent   = lbl

            local valLbl = Instance.new("TextLabel")
            valLbl.Size             = UDim2.new(0.35, 0, 1, 0)
            valLbl.Position         = UDim2.new(0.65, 0, 0, 0)
            valLbl.BackgroundTransparency = 1
            valLbl.Text             = tostring(math.floor(val)) .. suf
            valLbl.TextColor3       = T.AccentBright
            valLbl.TextSize         = 13
            valLbl.Font             = Enum.Font.GothamBold
            valLbl.TextXAlignment   = Enum.TextXAlignment.Right
            valLbl.ZIndex           = 5
            valLbl.Parent           = topRow

            -- Track bg
            local track = Instance.new("Frame")
            track.Size             = UDim2.new(1, -24, 0, 4)
            track.Position         = UDim2.new(0, 12, 0, 40)
            track.BackgroundColor3 = T.ToggleOff
            track.BorderSizePixel  = 0
            track.ZIndex           = 5
            track.Parent           = card
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local pct  = (val - min) / (max - min)

            -- Fill (gradient grey → white)
            local fill = Instance.new("Frame")
            fill.Size             = UDim2.new(pct, 0, 1, 0)
            fill.BackgroundColor3 = T.SliderFill
            fill.BorderSizePixel  = 0
            fill.ZIndex           = 6
            fill.Parent           = track
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local fillGrad = Instance.new("UIGradient")
            fillGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(85, 85, 100)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 235)),
            })
            fillGrad.Parent = fill

            -- Thumb
            local thumb = Instance.new("Frame")
            thumb.Size             = UDim2.new(0, 13, 0, 13)
            thumb.Position         = UDim2.new(pct, -6, 0.5, -6)
            thumb.BackgroundColor3 = T.AccentBright
            thumb.BorderSizePixel  = 0
            thumb.ZIndex           = 7
            thumb.Parent           = track
            Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

            local dragging = false

            local function Update(input)
                local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                val = math.floor(min + (max - min) * rel)
                QuickTween(fill,  0.04, { Size = UDim2.new(rel, 0, 1, 0) })
                QuickTween(thumb, 0.04, { Position = UDim2.new(rel, -6, 0.5, -6) })
                valLbl.Text = tostring(val) .. suf
                if callback then callback(val) end
            end

            track.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    Update(inp)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then Update(inp) end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)

            local api = {}
            function api:Set(v)
                val = math.clamp(v, min, max)
                local r = (val - min) / (max - min)
                QuickTween(fill, 0.1, { Size = UDim2.new(r, 0, 1, 0) })
                QuickTween(thumb, 0.1, { Position = UDim2.new(r, -6, 0.5, -6) })
                valLbl.Text = tostring(math.floor(val)) .. suf
                if callback then callback(val) end
            end
            function api:Get() return val end
            return api
        end

        -- ── TextBox ──────────────────────────────────────
        function Tab:AddTextBox(text, placeholder, callback)
            local card = MakeCard(58)

            local lbl = CreateLabel(card, text,
                UDim2.new(1, -16, 0, 18), UDim2.new(0, 12, 0, 7),
                Enum.Font.GothamMedium, T.Text, 5)

            local inputBg = Instance.new("Frame")
            inputBg.Size             = UDim2.new(1, -24, 0, 25)
            inputBg.Position         = UDim2.new(0, 12, 0, 28)
            inputBg.BackgroundColor3 = T.InputBg
            inputBg.BackgroundTransparency = 0.2
            inputBg.BorderSizePixel  = 0
            inputBg.ZIndex           = 5
            inputBg.Parent           = card
            Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0, 7)

            local inputStroke = Instance.new("UIStroke")
            inputStroke.Color       = T.Border
            inputStroke.Transparency = 0.5
            inputStroke.Thickness   = 1
            inputStroke.Parent      = inputBg

            local box = Instance.new("TextBox")
            box.Size             = UDim2.new(1, -16, 1, 0)
            box.Position         = UDim2.new(0, 8, 0, 0)
            box.BackgroundTransparency = 1
            box.Text             = ""
            box.PlaceholderText  = placeholder or "Type here..."
            box.PlaceholderColor3 = T.TextDisabled
            box.TextColor3       = T.Text
            box.TextSize         = 12
            box.Font             = Enum.Font.Gotham
            box.TextXAlignment   = Enum.TextXAlignment.Left
            box.ClearTextOnFocus = false
            box.ZIndex           = 6
            box.Parent           = inputBg

            box.Focused:Connect(function()
                QuickTween(inputStroke, 0.15, { Color = T.BorderGlow, Transparency = 0.2 })
                QuickTween(inputBg, 0.15, { BackgroundColor3 = T.SurfaceGlass })
            end)
            box.FocusLost:Connect(function(enter)
                QuickTween(inputStroke, 0.15, { Color = T.Border, Transparency = 0.5 })
                QuickTween(inputBg, 0.15, { BackgroundColor3 = T.InputBg })
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

            local card, stroke = MakeCard(44)
            card.ClipsDescendants = false

            local lbl = CreateLabel(card, text,
                UDim2.new(0.5, 0, 1, 0), UDim2.new(0, 12, 0, 0),
                Enum.Font.GothamMedium, T.Text, 5)

            local lg2 = Instance.new("UIGradient")
            lg2.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(155, 155, 170)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 235, 245)),
            })
            lg2.Rotation = 90
            lg2.Parent   = lbl

            local selLbl = Instance.new("TextLabel")
            selLbl.Size             = UDim2.new(0.4, -28, 1, 0)
            selLbl.Position         = UDim2.new(0.5, 0, 0, 0)
            selLbl.BackgroundTransparency = 1
            selLbl.Text             = selected
            selLbl.TextColor3       = T.Accent
            selLbl.TextSize         = 13
            selLbl.Font             = Enum.Font.GothamMedium
            selLbl.TextXAlignment   = Enum.TextXAlignment.Right
            selLbl.ZIndex           = 5
            selLbl.Parent           = card

            local arrow = Instance.new("TextLabel")
            arrow.Size             = UDim2.new(0, 18, 1, 0)
            arrow.Position         = UDim2.new(1, -22, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text             = "▾"
            arrow.TextColor3       = T.TextMuted
            arrow.TextSize         = 14
            arrow.Font             = Enum.Font.GothamBold
            arrow.ZIndex           = 5
            arrow.Parent           = card

            local dropPanel = Instance.new("Frame")
            dropPanel.Size             = UDim2.new(1, 0, 0, 0)
            dropPanel.Position         = UDim2.new(0, 0, 1, 4)
            dropPanel.BackgroundColor3 = T.Surface
            dropPanel.BackgroundTransparency = 0.08
            dropPanel.BorderSizePixel  = 0
            dropPanel.ClipsDescendants = true
            dropPanel.ZIndex           = 20
            dropPanel.Parent           = card
            Instance.new("UICorner", dropPanel).CornerRadius = UDim.new(0, 10)

            local dpStroke = Instance.new("UIStroke")
            dpStroke.Color = T.Border; dpStroke.Transparency = 0.4; dpStroke.Thickness = 1
            dpStroke.Parent = dropPanel

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
                optBtn.Size             = UDim2.new(1, 0, 0, 30)
                optBtn.BackgroundColor3 = T.SurfaceGlass
                optBtn.BackgroundTransparency = 0.55
                optBtn.BorderSizePixel  = 0
                optBtn.Text             = opt
                optBtn.TextColor3       = T.Text
                optBtn.TextSize         = 12
                optBtn.Font             = Enum.Font.Gotham
                optBtn.ZIndex           = 21
                optBtn.LayoutOrder      = i
                optBtn.Parent           = dropPanel
                Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 7)

                optBtn.MouseEnter:Connect(function()
                    QuickTween(optBtn, 0.12, { BackgroundColor3 = T.SurfaceLight, BackgroundTransparency = 0.25, TextColor3 = T.AccentBright })
                end)
                optBtn.MouseLeave:Connect(function()
                    QuickTween(optBtn, 0.12, { BackgroundColor3 = T.SurfaceGlass, BackgroundTransparency = 0.55, TextColor3 = T.Text })
                end)
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    selLbl.Text = opt
                    open = false
                    QuickTween(dropPanel, 0.22, { Size = UDim2.new(1, 0, 0, 0) })
                    QuickTween(arrow, 0.2, { Rotation = 0 })
                    if callback then callback(opt) end
                end)
            end

            local togBtn = Instance.new("TextButton")
            togBtn.Size             = UDim2.new(1, 0, 1, 0)
            togBtn.BackgroundTransparency = 1
            togBtn.Text             = ""
            togBtn.ZIndex           = 6
            togBtn.Parent           = card

            togBtn.MouseButton1Click:Connect(function()
                open = not open
                QuickTween(dropPanel, 0.25, { Size = UDim2.new(1, 0, 0, open and targetH or 0) })
                QuickTween(arrow, 0.2, { Rotation = open and 180 or 0 })
                QuickTween(stroke, 0.2, { Color = open and T.BorderGlow or T.Border, Transparency = open and 0.3 or 0.55 })
            end)

            local api = {}
            function api:Set(v)
                for _, o in ipairs(options) do
                    if o == v then selected = v; selLbl.Text = v; if callback then callback(v) end; break end
                end
            end
            function api:Get() return selected end
            return api
        end

        -- ── ColorPicker ──────────────────────────────────
        function Tab:AddColorPicker(text, default, callback)
            local color = default or Color3.new(1, 0, 0)
            local open  = false

            local card = MakeCard(44)
            card.ClipsDescendants = false

            local lbl = CreateLabel(card, text,
                UDim2.new(1, -70, 1, 0), UDim2.new(0, 12, 0, 0),
                Enum.Font.GothamMedium, T.Text, 5)

            local preview = Instance.new("Frame")
            preview.Size             = UDim2.new(0, 22, 0, 22)
            preview.Position         = UDim2.new(1, -34, 0.5, -11)
            preview.BackgroundColor3 = color
            preview.BorderSizePixel  = 0
            preview.ZIndex           = 5
            preview.Parent           = card
            Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 6)

            local pvStroke = Instance.new("UIStroke")
            pvStroke.Color = T.Border; pvStroke.Transparency = 0.4; pvStroke.Thickness = 1
            pvStroke.Parent = preview

            local panel = Instance.new("Frame")
            panel.Size             = UDim2.new(1, 0, 0, 0)
            panel.Position         = UDim2.new(0, 0, 1, 4)
            panel.BackgroundColor3 = T.Surface
            panel.BackgroundTransparency = 0.08
            panel.BorderSizePixel  = 0
            panel.ClipsDescendants = true
            panel.ZIndex           = 20
            panel.Parent           = card
            Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

            local panStroke = Instance.new("UIStroke")
            panStroke.Color = T.Border; panStroke.Transparency = 0.4; panStroke.Thickness = 1
            panStroke.Parent = panel

            local hueBar = Instance.new("Frame")
            hueBar.Size             = UDim2.new(1, -20, 0, 14)
            hueBar.Position         = UDim2.new(0, 10, 0, 10)
            hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
            hueBar.BorderSizePixel  = 0
            hueBar.ZIndex           = 21
            hueBar.Parent           = panel
            Instance.new("UICorner", hueBar).CornerRadius = UDim.new(1, 0)

            local grad = Instance.new("UIGradient")
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,    1, 1)),
                ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
                ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
                ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50, 1, 1)),
                ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
                ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
                ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,    1, 1)),
            })
            grad.Parent = hueBar

            local hueKnob = Instance.new("Frame")
            hueKnob.Size             = UDim2.new(0, 9, 1, 4)
            hueKnob.AnchorPoint      = Vector2.new(0.5, 0.5)
            hueKnob.Position         = UDim2.new(0, 0, 0.5, 0)
            hueKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            hueKnob.BorderSizePixel  = 0
            hueKnob.ZIndex           = 22
            hueKnob.Parent           = hueBar
            Instance.new("UICorner", hueKnob).CornerRadius = UDim.new(0, 3)

            local hexLbl = Instance.new("TextLabel")
            hexLbl.Size             = UDim2.new(1, -20, 0, 14)
            hexLbl.Position         = UDim2.new(0, 10, 0, 30)
            hexLbl.BackgroundTransparency = 1
            hexLbl.Text             = "Hue slider"
            hexLbl.TextColor3       = T.TextMuted
            hexLbl.TextSize         = 10
            hexLbl.Font             = Enum.Font.Gotham
            hexLbl.TextXAlignment   = Enum.TextXAlignment.Left
            hexLbl.ZIndex           = 21
            hexLbl.Parent           = panel

            local hue, sat, val2 = Color3.toHSV(color)
            local draggingHue     = false

            local function UpdateColor()
                color = Color3.fromHSV(hue, sat, val2)
                preview.BackgroundColor3 = color
                if callback then callback(color) end
            end

            hueBar.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingHue = true
                    local rel = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                    hue = rel; hueKnob.Position = UDim2.new(rel, 0, 0.5, 0); UpdateColor()
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if draggingHue and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                    hue = rel; hueKnob.Position = UDim2.new(rel, 0, 0.5, 0); UpdateColor()
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false end
            end)

            local openBtn = Instance.new("TextButton")
            openBtn.Size             = UDim2.new(1, 0, 1, 0)
            openBtn.BackgroundTransparency = 1
            openBtn.Text             = ""
            openBtn.ZIndex           = 6
            openBtn.Parent           = card

            openBtn.MouseButton1Click:Connect(function()
                open = not open
                QuickTween(panel, 0.25, { Size = UDim2.new(1, 0, 0, open and 50 or 0) })
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

        return Tab
    end

    -- ╔══════════════════════════════════════════════════╗
    -- ║               NOTIFICATION                       ║
    -- ╚══════════════════════════════════════════════════╝

    function self:Notify(options)
        options = options or {}
        local title = options.Title   or "Notification"
        local msg   = options.Message or ""
        local dur   = options.Duration or 4
        local ntype = options.Type     or "Info"

        local ntypeColors = {
            Info    = T.Info,
            Success = T.Success,
            Warning = T.Warning,
            Error   = T.Error,
        }
        local acol = ntypeColors[ntype] or T.Info

        local W = 290
        local holder = ScreenGui:FindFirstChild("NotifHolder")
        if not holder then
            holder = Instance.new("Frame")
            holder.Name             = "NotifHolder"
            holder.Size             = UDim2.new(0, W, 1, 0)
            holder.Position         = UDim2.new(1, -(W + 14), 0, 0)
            holder.BackgroundTransparency = 1
            holder.BorderSizePixel  = 0
            holder.ZIndex           = 100
            holder.Parent           = ScreenGui

            local nList = Instance.new("UIListLayout")
            nList.VerticalAlignment = Enum.VerticalAlignment.Bottom
            nList.Padding           = UDim.new(0, 6)
            nList.SortOrder         = Enum.SortOrder.LayoutOrder
            nList.Parent            = holder

            local nPad = Instance.new("UIPadding")
            nPad.PaddingBottom = UDim.new(0, 14)
            nPad.Parent        = holder
        end

        local notif = Instance.new("Frame")
        notif.Size             = UDim2.new(1, 0, 0, 68)
        notif.BackgroundColor3 = T.Surface
        notif.BackgroundTransparency = 0.1
        notif.BorderSizePixel  = 0
        notif.ZIndex           = 101
        notif.ClipsDescendants = true
        notif.Parent           = holder
        Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 12)

        local nStroke = Instance.new("UIStroke")
        nStroke.Color = T.Border; nStroke.Transparency = 0.45; nStroke.Thickness = 1
        nStroke.Parent = notif

        -- Coloured left bar
        local accent = Instance.new("Frame")
        accent.Size             = UDim2.new(0, 3, 0.75, 0)
        accent.Position         = UDim2.new(0, 0, 0.125, 0)
        accent.BackgroundColor3 = acol
        accent.BorderSizePixel  = 0
        accent.ZIndex           = 102
        accent.Parent           = notif
        Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

        local tLbl = Instance.new("TextLabel")
        tLbl.Size             = UDim2.new(1, -20, 0, 20)
        tLbl.Position         = UDim2.new(0, 14, 0, 8)
        tLbl.BackgroundTransparency = 1
        tLbl.Text             = title
        tLbl.TextColor3       = T.AccentBright
        tLbl.TextSize         = 13
        tLbl.Font             = Enum.Font.GothamBold
        tLbl.TextXAlignment   = Enum.TextXAlignment.Left
        tLbl.ZIndex           = 102
        tLbl.Parent           = notif

        local mLbl = Instance.new("TextLabel")
        mLbl.Size             = UDim2.new(1, -20, 0, 30)
        mLbl.Position         = UDim2.new(0, 14, 0, 30)
        mLbl.BackgroundTransparency = 1
        mLbl.Text             = msg
        mLbl.TextColor3       = T.TextMuted
        mLbl.TextSize         = 11
        mLbl.Font             = Enum.Font.Gotham
        mLbl.TextXAlignment   = Enum.TextXAlignment.Left
        mLbl.TextWrapped      = true
        mLbl.ZIndex           = 102
        mLbl.Parent           = notif

        -- Progress bar (grey → white gradient)
        local prog = Instance.new("Frame")
        prog.Size             = UDim2.new(1, 0, 0, 2)
        prog.Position         = UDim2.new(0, 0, 1, -2)
        prog.BackgroundColor3 = T.Accent
        prog.BorderSizePixel  = 0
        prog.ZIndex           = 103
        prog.Parent           = notif

        local progGrad = Instance.new("UIGradient")
        progGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 90, 105)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(225, 225, 240)),
        })
        progGrad.Parent = prog

        -- Slide in from right
        notif.Position = UDim2.new(1.1, 0, 0, 0)
        SpringTween(notif, 0.4, { Position = UDim2.new(0, 0, 0, 0) })
        TweenService:Create(prog, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 0, 2),
        }):Play()

        task.delay(dur, function()
            QuickTween(notif, 0.28, { Position = UDim2.new(1.1, 0, 0, 0), BackgroundTransparency = 1 })
            task.delay(0.32, function() notif:Destroy() end)
        end)
    end

    -- ── Keybind toggle ──────────────────────────────────
    local togKey = config.ToggleKey or Enum.KeyCode.RightShift

    UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.KeyCode == togKey then
            self._open = not self._open
            if self._open then
                Window.Visible = true
                ElasticTween(Window, 0.55, {
                    Size     = UDim2.new(0, WIN_W, 0, WIN_H),
                    Position = UDim2.new(0.5, -WIN_W / 2, 0.5, -WIN_H / 2),
                })
                SmoothTween(Overlay, 0.4, { BackgroundTransparency = 0.55 })
                SmoothTween(blur, 0.4, { Size = T.BlurSize })
            else
                SmoothTween(Window, 0.32, {
                    Size     = UDim2.new(0, WIN_W * 0.88, 0, WIN_H * 0.88),
                    Position = UDim2.new(0.5, -WIN_W * 0.44, 0.5, -WIN_H * 0.44),
                })
                QuickTween(Window, 0.32, { BackgroundTransparency = 1 })
                SmoothTween(Overlay, 0.35, { BackgroundTransparency = 1 })
                SmoothTween(blur, 0.35, { Size = 0 })
                task.delay(0.35, function() Window.Visible = false end)
            end
        end
    end)

    return self
end

return ZandarUI
