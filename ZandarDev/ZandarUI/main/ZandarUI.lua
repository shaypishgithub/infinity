
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local Lighting         = game:GetService("Lighting")
local Debris           = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()
local Camera      = workspace.CurrentCamera



local T = {
    Background      = Color3.fromRGB(6,  6,  8),
    Surface         = Color3.fromRGB(16, 16, 20),
    SurfaceGlass    = Color3.fromRGB(28, 28, 34),
    SurfaceLight    = Color3.fromRGB(44, 44, 54),

    Border          = Color3.fromRGB(70,  70,  80),
    BorderGlow      = Color3.fromRGB(190, 190, 210),
    BorderHover     = Color3.fromRGB(225, 225, 240),

    Text            = Color3.fromRGB(235, 235, 245),
    TextMuted       = Color3.fromRGB(130, 130, 150),
    TextDisabled    = Color3.fromRGB(65,  65,  78),
    TextAccent      = Color3.fromRGB(200, 200, 215),

    Accent          = Color3.fromRGB(210, 210, 225),
    AccentBright    = Color3.fromRGB(255, 255, 255),
    AccentDim       = Color3.fromRGB(80,  80,  95),

    ToggleOff       = Color3.fromRGB(36,  36,  44),
    ToggleOn        = Color3.fromRGB(200, 200, 215),
    SliderFill      = Color3.fromRGB(200, 200, 215),
    InputBg         = Color3.fromRGB(11,  11,  15),

    Success         = Color3.fromRGB(160, 220, 170),
    Warning         = Color3.fromRGB(220, 200, 130),
    Error           = Color3.fromRGB(220, 120, 120),
    Info            = Color3.fromRGB(180, 180, 210),

    BlurSize        = 20,
}

-- ╔══════════════════════════════════════════════════════╗
-- ║                   UTILITY FUNCTIONS                  ║
-- ╚══════════════════════════════════════════════════════╝

local function Tween(obj, info, props)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function QuickTween(obj, t, props)
    return Tween(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
end

local function SmoothTween(obj, t, props)
    return Tween(obj, TweenInfo.new(t, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), props)
end

local function SpringTween(obj, t, props)
    return Tween(obj, TweenInfo.new(t, Enum.EasingStyle.Back, Enum.EasingDirection.Out), props)
end

local function ElasticTween(obj, t, props)
    return Tween(obj, TweenInfo.new(t, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), props)
end

local function AnimateShimmer(gradient, speed)
    speed = speed or 2.2
    task.spawn(function()
        while gradient and gradient.Parent do
            gradient.Offset = Vector2.new(-1, 0)
            local tw = Tween(gradient, TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Offset = Vector2.new(1, 0),
            })
            tw.Completed:Wait()
            task.wait(0.4)
        end
    end)
end

local function ShimmerText(label)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(140, 140, 155)),
        ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(140, 140, 155)),
    })
    g.Parent = label
    AnimateShimmer(g, 2.6)
    return g
end

local function MakeDraggable(frame, handle, boundsPadding, onDragStateChanged)
    handle = handle or frame
    boundsPadding = boundsPadding or 0
    local dragging = false
    local dragStart, startOffset
    local endConn
    local moved = false

    local function beginDrag(input)
        dragging     = true
        moved        = false
        dragStart    = input.Position
        startOffset  = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)

        if endConn then endConn:Disconnect() end
        endConn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                if onDragStateChanged then
                    task.defer(onDragStateChanged, moved)
                end
            end
        end)
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag(input)
        end
    end)

    local dragInput
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or input ~= dragInput then return end
        local delta = input.Position - dragStart
        if delta.Magnitude > 4 then moved = true end
        local newX  = startOffset.X + delta.X
        local newY  = startOffset.Y + delta.Y

        local cam = workspace.CurrentCamera
        if cam then
            local vp = cam.ViewportSize
            local hw, hh = frame.AbsoluteSize.X / 2, frame.AbsoluteSize.Y / 2
            newX = math.clamp(newX, hw + boundsPadding - vp.X * frame.Position.X.Scale, vp.X * (1 - frame.Position.X.Scale) - hw - boundsPadding)
            newY = math.clamp(newY, hh + boundsPadding - vp.Y * frame.Position.Y.Scale, vp.Y * (1 - frame.Position.Y.Scale) - hh - boundsPadding)
        end

        frame.Position = UDim2.new(frame.Position.X.Scale, newX, frame.Position.Y.Scale, newY)
    end)
end

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
    ripple.Position = UDim2.new(0, (Mouse and Mouse.X or mp.X) - mp.X, 0, (Mouse and Mouse.Y or mp.Y) - mp.Y)

    local maxSize = math.max(ms.X, ms.Y) * 2.8
    TweenService:Create(ripple, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1,
    }):Play()
    Debris:AddItem(ripple, 0.6)
end

local function MakeGlassFrame(parent, size, pos, radius, zindex)
    local f = Instance.new("Frame")
    f.Size             = size or UDim2.new(1, 0, 1, 0)
    f.Position         = pos  or UDim2.new(0, 0, 0, 0)
    f.BackgroundColor3 = T.SurfaceGlass
    f.BackgroundTransparency = 0.4
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
ZandarUI.Version = "3.1.0"

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

    -- ── Blur + dim overlay ──────────────────────────────
    local blur = Instance.new("BlurEffect")
    blur.Size   = 0
    blur.Parent = Lighting
    self._blur  = blur
    SmoothTween(blur, 0.5, { Size = T.BlurSize })

    local Overlay = Instance.new("Frame")
    Overlay.Size             = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    Overlay.BackgroundTransparency = 1
    Overlay.BorderSizePixel  = 0
    Overlay.ZIndex           = 0
    Overlay.Parent           = ScreenGui
    SmoothTween(Overlay, 0.5, { BackgroundTransparency = 0.55 })

    -- ── Adaptive window size ─────────────────────────────
    local function GetWindowSize()
        local vp = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
        local w = math.clamp(vp.X * 0.55, 340, 600)
        local h = math.clamp(vp.Y * 0.62, 260, 420)
        return math.floor(w), math.floor(h)
    end
    local WIN_W, WIN_H = GetWindowSize()

    -- ── Main Window ──────────────────────────────────────
    local Window = Instance.new("Frame")
    Window.Name             = "Window"
    Window.AnchorPoint      = Vector2.new(0.5, 0.5)
    Window.Position         = UDim2.new(0.5, 0, 0.5, 0)
    Window.Size             = UDim2.new(0, 0, 0, 0)
    Window.BackgroundColor3 = T.Background
    Window.BackgroundTransparency = 0.06
    Window.BorderSizePixel  = 0
    Window.ClipsDescendants = true
    Window.ZIndex           = 2
    Window.Parent           = ScreenGui
    self._window = Window

    Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 18)

    local winStroke = Instance.new("UIStroke")
    winStroke.Color           = T.BorderGlow
    winStroke.Transparency    = 0.6
    winStroke.Thickness       = 1.2
    winStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    winStroke.Parent          = Window

    task.spawn(function()
        local up = true
        while Window.Parent do
            SmoothTween(winStroke, 2.4, { Transparency = up and 0.28 or 0.68 })
            up = not up
            task.wait(2.4)
        end
    end)

    ElasticTween(Window, 0.6, { Size = UDim2.new(0, WIN_W, 0, WIN_H) })

    -- ── Header ──────────────────────────────────────────
    local Header = Instance.new("Frame")
    Header.Name             = "Header"
    Header.Size             = UDim2.new(1, 0, 0, 52)
    Header.BackgroundColor3 = T.Surface
    Header.BackgroundTransparency = 0.15
    Header.BorderSizePixel  = 0
    Header.ZIndex           = 3
    Header.Parent           = Window
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 18)

    local headerFix = Instance.new("Frame")
    headerFix.Size             = UDim2.new(1, 0, 0, 18)
    headerFix.Position         = UDim2.new(0, 0, 1, -18)
    headerFix.BackgroundColor3 = T.Surface
    headerFix.BackgroundTransparency = 0.15
    headerFix.BorderSizePixel  = 0
    headerFix.ZIndex           = 3
    headerFix.Parent           = Header

    local headerLine = Instance.new("Frame")
    headerLine.Size             = UDim2.new(1, -20, 0, 1)
    headerLine.Position         = UDim2.new(0, 10, 1, -1)
    headerLine.BackgroundColor3 = T.Border
    headerLine.BackgroundTransparency = 0.35
    headerLine.BorderSizePixel  = 0
    headerLine.ZIndex           = 4
    headerLine.Parent           = Header
    ShimmerText(headerLine)

    local accentBar = Instance.new("Frame")
    accentBar.Size             = UDim2.new(0, 3, 0, 24)
    accentBar.Position         = UDim2.new(0, 16, 0.5, -12)
    accentBar.BackgroundColor3 = T.AccentBright
    accentBar.BorderSizePixel  = 0
    accentBar.ZIndex           = 5
    accentBar.Parent           = Header
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1, 0)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size             = UDim2.new(0, 240, 0, 26)
    TitleLbl.Position         = UDim2.new(0, 28, 0, 8)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text             = config.Title or "ZandarUI"
    TitleLbl.TextColor3       = T.AccentBright
    TitleLbl.TextSize         = 15
    TitleLbl.Font             = Enum.Font.GothamBold
    TitleLbl.TextXAlignment   = Enum.TextXAlignment.Left
    TitleLbl.ZIndex           = 5
    TitleLbl.Parent           = Header
    ShimmerText(TitleLbl)

    local SubLbl = Instance.new("TextLabel")
    SubLbl.Size             = UDim2.new(0, 240, 0, 14)
    SubLbl.Position         = UDim2.new(0, 28, 0, 34)
    SubLbl.BackgroundTransparency = 1
    SubLbl.Text             = config.Subtitle or "Monochrome Glass"
    SubLbl.TextColor3       = T.TextMuted
    SubLbl.TextSize         = 10
    SubLbl.Font             = Enum.Font.Gotham
    SubLbl.TextXAlignment   = Enum.TextXAlignment.Left
    SubLbl.ZIndex           = 5
    SubLbl.Parent           = Header

    MakeDraggable(Window, Header)

    -- ── Close button ────────────────────────────────────
    local HeaderClose = Instance.new("TextButton")
    HeaderClose.Size             = UDim2.new(0, 22, 0, 22)
    HeaderClose.Position         = UDim2.new(1, -14, 0.5, -11)
    HeaderClose.AnchorPoint      = Vector2.new(1, 0)
    HeaderClose.BackgroundColor3 = T.SurfaceGlass
    HeaderClose.BackgroundTransparency = 0.3
    HeaderClose.BorderSizePixel  = 0
    HeaderClose.Text             = ""
    HeaderClose.AutoButtonColor  = false
    HeaderClose.ZIndex           = 6
    HeaderClose.ClipsDescendants = true
    HeaderClose.Parent           = Header
    Instance.new("UICorner", HeaderClose).CornerRadius = UDim.new(1, 0)

    local hcStroke = Instance.new("UIStroke")
    hcStroke.Color = T.Border; hcStroke.Transparency = 0.5; hcStroke.Thickness = 1
    hcStroke.Parent = HeaderClose

    local hcBar1 = Instance.new("Frame")
    hcBar1.Size             = UDim2.new(0, 11, 0, 2)
    hcBar1.AnchorPoint      = Vector2.new(0.5, 0.5)
    hcBar1.Position         = UDim2.new(0.5, 0, 0.5, 0)
    hcBar1.Rotation         = 45
    hcBar1.BackgroundColor3 = T.TextMuted
    hcBar1.BorderSizePixel  = 0
    hcBar1.ZIndex           = 7
    hcBar1.Parent           = HeaderClose
    Instance.new("UICorner", hcBar1).CornerRadius = UDim.new(1, 0)

    local hcBar2 = hcBar1:Clone()
    hcBar2.Rotation = -45
    hcBar2.Parent   = HeaderClose

    HeaderClose.MouseEnter:Connect(function()
        QuickTween(HeaderClose, 0.15, { BackgroundColor3 = Color3.fromRGB(60, 30, 30), BackgroundTransparency = 0 })
        QuickTween(hcBar1, 0.15, { BackgroundColor3 = T.AccentBright })
        QuickTween(hcBar2, 0.15, { BackgroundColor3 = T.AccentBright })
    end)
    HeaderClose.MouseLeave:Connect(function()
        QuickTween(HeaderClose, 0.15, { BackgroundColor3 = T.SurfaceGlass, BackgroundTransparency = 0.3 })
        QuickTween(hcBar1, 0.15, { BackgroundColor3 = T.TextMuted })
        QuickTween(hcBar2, 0.15, { BackgroundColor3 = T.TextMuted })
    end)

    HeaderClose.MouseButton1Click:Connect(function()
        ZandarUI.Destroy()
        if blur and blur.Parent then blur:Destroy() end
    end)

    -- ── Tab Rail ──────────────────────────────────────────
    local RAIL_W = 140
    local TabRail = Instance.new("Frame")
    TabRail.Name             = "TabRail"
    TabRail.Size             = UDim2.new(0, RAIL_W, 1, -52)
    TabRail.Position         = UDim2.new(0, 0, 0, 52)
    TabRail.BackgroundColor3 = T.Background
    TabRail.BackgroundTransparency = 0.1
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

    local railDiv = Instance.new("Frame")
    railDiv.Size             = UDim2.new(0, 1, 1, -52)
    railDiv.Position         = UDim2.new(0, RAIL_W, 0, 52)
    railDiv.BackgroundColor3 = T.Border
    railDiv.BackgroundTransparency = 0.4
    railDiv.BorderSizePixel  = 0
    railDiv.ZIndex           = 3
    railDiv.Parent           = Window

    local ContentArea = Instance.new("Frame")
    ContentArea.Name             = "ContentArea"
    ContentArea.Size             = UDim2.new(1, -(RAIL_W + 2), 1, -54)
    ContentArea.Position         = UDim2.new(0, RAIL_W + 2, 0, 54)
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
        tabStroke.Color = T.Border; tabStroke.Transparency = 0.75; tabStroke.Thickness = 1
        tabStroke.Parent = TabBtn

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

        local ActiveBar = Instance.new("Frame")
        ActiveBar.Size             = UDim2.new(0, 2, 0, 18)
        ActiveBar.Position         = UDim2.new(0, 0, 0.5, -9)
        ActiveBar.BackgroundColor3 = T.AccentBright
        ActiveBar.BackgroundTransparency = 1
        ActiveBar.BorderSizePixel  = 0
        ActiveBar.ZIndex           = 6
        ActiveBar.Parent           = TabBtn
        Instance.new("UICorner", ActiveBar).CornerRadius = UDim.new(1, 0)

        local Page = Instance.new("ScrollingFrame")
        Page.Name                   = "Page_" .. name
        Page.Size                   = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel        = 0
        Page.ScrollBarThickness     = 2
        Page.ScrollBarImageColor3   = T.Accent
        Page.CanvasSize             = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize    = Enum.AutomaticSize.Y
        Page.Visible                = false
        Page.ZIndex                 = 3
        Page.Parent                 = ContentArea

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
            if self._active ~= Tab then QuickTween(TabBtn, 0.15, { BackgroundTransparency = 0.45 }) end
        end)
        TabBtn.MouseLeave:Connect(function()
            if self._active ~= Tab then QuickTween(TabBtn, 0.15, { BackgroundTransparency = 0.65 }) end
        end)

        table.insert(self._tabs, Tab)
        if #self._tabs == 1 then
            SetActive(true)
            self._active = Tab
        end

        local function MakeCard(h)
            Tab._order = Tab._order + 1
            local card, stroke = MakeGlassFrame(Page, UDim2.new(1, 0, 0, h or 40), UDim2.new(0, 0, 0, 0), 10, 4)
            card.LayoutOrder = Tab._order
            return card, stroke
        end

        -- ══════════════ ELEMENTS ══════════════

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

            local grad = Instance.new("UIGradient")
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                ColorSequenceKeypoint.new(0.3, Color3.fromRGB(190, 190, 210)),
                ColorSequenceKeypoint.new(0.7, Color3.fromRGB(190, 190, 210)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
            })
            grad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.2, 0.3),
                NumberSequenceKeypoint.new(0.8, 0.3),
                NumberSequenceKeypoint.new(1, 1),
            })
            grad.Parent = line
            AnimateShimmer(grad, 3)

            if label then
                local bg = Instance.new("Frame")
                bg.Size             = UDim2.new(0, 0, 1, 0)
                bg.AutomaticSize    = Enum.AutomaticSize.X
                bg.Position         = UDim2.new(0.5, 0, 0, 0)
                bg.AnchorPoint      = Vector2.new(0.5, 0)
                bg.BackgroundColor3 = T.Background
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
            ShimmerText(hdr)
        end

        function Tab:AddButton(text, callback, icon)
            local card, stroke = MakeCard(40)
            card.BackgroundTransparency = 0.38

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

        function Tab:AddToggle(text, default, callback)
            local state = default or false
            local card  = MakeCard(44)
            local lbl = CreateLabel(card, text, UDim2.new(1, -72, 1, 0), UDim2.new(0, 12, 0, 0), Enum.Font.GothamMedium, T.Text, 5)

            local track = Instance.new("Frame")
            track.Size             = UDim2.new(0, 42, 0, 22)
            track.Position         = UDim2.new(1, -54, 0.5, -11)
            track.BackgroundColor3 = state and T.ToggleOn or T.ToggleOff
            track.BorderSizePixel  = 0
            track.ZIndex           = 5
            track.Parent           = card
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local tStroke = Instance.new("UIStroke")
            tStroke.Color = state and T.BorderGlow or T.Border
            tStroke.Transparency = state and 0.45 or 0.6
            tStroke.Thickness = 1
            tStroke.Parent = track

            local knob = Instance.new("Frame")
            knob.Size             = UDim2.new(0, 16, 0, 16)
            knob.Position         = state and UDim2.new(0, 23, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            knob.BackgroundColor3 = state and T.AccentBright or T.TextMuted
            knob.BorderSizePixel  = 0
            knob.ZIndex           = 6
            knob.Parent           = track
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 7; btn.Parent = card

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

        function Tab:AddSlider(text, options, callback)
            options = options or {}
            local min = options.Min or 0
            local max = options.Max or 100
            local def = options.Default or min
            local suf = options.Suffix or ""
            local val = def

            local card = MakeCard(58)
            local topRow = Instance.new("Frame")
            topRow.Size = UDim2.new(1, -24, 0, 20); topRow.Position = UDim2.new(0, 12, 0, 9)
            topRow.BackgroundTransparency = 1; topRow.ZIndex = 5; topRow.Parent = card

            local lbl = CreateLabel(topRow, text, UDim2.new(0.65, 0, 1, 0), UDim2.new(0, 0, 0, 0), Enum.Font.GothamMedium, T.Text, 5)

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0.35, 0, 1, 0); valLbl.Position = UDim2.new(0.65, 0, 0, 0)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(math.floor(val)) .. suf
            valLbl.TextColor3 = T.AccentBright; valLbl.TextSize = 13; valLbl.Font = Enum.Font.GothamBold
            valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.ZIndex = 5; valLbl.Parent = topRow

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -24, 0, 4); track.Position = UDim2.new(0, 12, 0, 40)
            track.BackgroundColor3 = T.ToggleOff; track.BorderSizePixel = 0; track.ZIndex = 5; track.Parent = card
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local pct = (val - min) / (max - min)
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(pct, 0, 1, 0); fill.BackgroundColor3 = T.SliderFill
            fill.BorderSizePixel = 0; fill.ZIndex = 6; fill.Parent = track
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local fillGrad = Instance.new("UIGradient")
            fillGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(85, 85, 100)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 235)),
            })
            fillGrad.Parent = fill

            local thumb = Instance.new("Frame")
            thumb.Size = UDim2.new(0, 13, 0, 13); thumb.Position = UDim2.new(pct, -6, 0.5, -6)
            thumb.BackgroundColor3 = T.AccentBright; thumb.BorderSizePixel = 0; thumb.ZIndex = 7; thumb.Parent = track
            Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

            local dragging = false
            local function Update(input)
                local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                val = math.floor(min + (max - min) * rel)
                QuickTween(fill, 0.04, { Size = UDim2.new(rel, 0, 1, 0) })
                QuickTween(thumb, 0.04, { Position = UDim2.new(rel, -6, 0.5, -6) })
                valLbl.Text = tostring(val) .. suf
                if callback then callback(val) end
            end

            track.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = true; Update(inp)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then Update(inp) end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
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

        -- ══════════════ НОВЫЙ ЭЛЕМЕНТ: ЧИСЛОВОЕ ПОЛЕ ВВОДА ══════════════
        function Tab:AddNumberInput(text, default, min, max, callback)
            local val = default or min or 0
            min = min or 0
            max = max or 9999
            
            local card = MakeCard(58)
            local lbl = CreateLabel(card, text, UDim2.new(1, -16, 0, 18), UDim2.new(0, 12, 0, 7), Enum.Font.GothamMedium, T.Text, 5)

            local inputContainer = Instance.new("Frame")
            inputContainer.Size = UDim2.new(1, -24, 0, 25)
            inputContainer.Position = UDim2.new(0, 12, 0, 28)
            inputContainer.BackgroundTransparency = 1
            inputContainer.ZIndex = 5
            inputContainer.Parent = card

            -- Кнопка минус
            local minusBtn = Instance.new("TextButton")
            minusBtn.Size = UDim2.new(0, 25, 1, 0)
            minusBtn.Position = UDim2.new(0, 0, 0, 0)
            minusBtn.BackgroundColor3 = T.SurfaceGlass
            minusBtn.BackgroundTransparency = 0.3
            minusBtn.BorderSizePixel = 0
            minusBtn.Text = "-"
            minusBtn.TextColor3 = T.Text
            minusBtn.TextSize = 16
            minusBtn.Font = Enum.Font.GothamBold
            minusBtn.ZIndex = 6
            minusBtn.Parent = inputContainer
            Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 6)

            local minusStroke = Instance.new("UIStroke")
            minusStroke.Color = T.Border
            minusStroke.Transparency = 0.5
            minusStroke.Thickness = 1
            minusStroke.Parent = minusBtn

            -- Поле ввода
            local inputBg = Instance.new("Frame")
            inputBg.Size = UDim2.new(1, -52, 1, 0)
            inputBg.Position = UDim2.new(0, 26, 0, 0)
            inputBg.BackgroundColor3 = T.InputBg
            inputBg.BackgroundTransparency = 0.2
            inputBg.BorderSizePixel = 0
            inputBg.ZIndex = 5
            inputBg.Parent = inputContainer
            Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0, 6)

            local inputStroke = Instance.new("UIStroke")
            inputStroke.Color = T.Border
            inputStroke.Transparency = 0.5
            inputStroke.Thickness = 1
            inputStroke.Parent = inputBg

            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, -10, 1, 0)
            box.Position = UDim2.new(0, 5, 0, 0)
            box.BackgroundTransparency = 1
            box.Text = tostring(val)
            box.PlaceholderText = "0"
            box.PlaceholderColor3 = T.TextDisabled
            box.TextColor3 = T.AccentBright
            box.TextSize = 13
            box.Font = Enum.Font.GothamBold
            box.TextXAlignment = Enum.TextXAlignment.Center
            box.ClearTextOnFocus = false
            box.ZIndex = 6
            box.Parent = inputBg

            -- Кнопка плюс
            local plusBtn = Instance.new("TextButton")
            plusBtn.Size = UDim2.new(0, 25, 1, 0)
            plusBtn.Position = UDim2.new(1, -25, 0, 0)
            plusBtn.BackgroundColor3 = T.SurfaceGlass
            plusBtn.BackgroundTransparency = 0.3
            plusBtn.BorderSizePixel = 0
            plusBtn.Text = "+"
            plusBtn.TextColor3 = T.Text
            plusBtn.TextSize = 16
            plusBtn.Font = Enum.Font.GothamBold
            plusBtn.ZIndex = 6
            plusBtn.Parent = inputContainer
            Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 6)

            local plusStroke = Instance.new("UIStroke")
            plusStroke.Color = T.Border
            plusStroke.Transparency = 0.5
            plusStroke.Thickness = 1
            plusStroke.Parent = plusBtn

            local function ApplyValue(newVal)
                newVal = tonumber(newVal)
                if not newVal then newVal = min end
                newVal = math.clamp(math.floor(newVal), min, max)
                val = newVal
                box.Text = tostring(val)
                if callback then callback(val) end
            end

            minusBtn.MouseButton1Click:Connect(function()
                ApplyValue(val - 1)
                QuickTween(minusBtn, 0.1, { BackgroundColor3 = T.SurfaceLight })
                task.delay(0.1, function()
                    QuickTween(minusBtn, 0.1, { BackgroundColor3 = T.SurfaceGlass })
                end)
            end)

            plusBtn.MouseButton1Click:Connect(function()
                ApplyValue(val + 1)
                QuickTween(plusBtn, 0.1, { BackgroundColor3 = T.SurfaceLight })
                task.delay(0.1, function()
                    QuickTween(plusBtn, 0.1, { BackgroundColor3 = T.SurfaceGlass })
                end)
            end)

            box.Focused:Connect(function()
                QuickTween(inputStroke, 0.15, { Color = T.BorderGlow, Transparency = 0.2 })
            end)

            box.FocusLost:Connect(function(enter)
                QuickTween(inputStroke, 0.15, { Color = T.Border, Transparency = 0.5 })
                ApplyValue(box.Text)
            end)

            local api = {}
            function api:Set(v) ApplyValue(v) end
            function api:Get() return val end
            return api
        end

        function Tab:AddTextBox(text, placeholder, callback)
            local card = MakeCard(58)
            local lbl = CreateLabel(card, text, UDim2.new(1, -16, 0, 18), UDim2.new(0, 12, 0, 7), Enum.Font.GothamMedium, T.Text, 5)

            local inputBg = Instance.new("Frame")
            inputBg.Size = UDim2.new(1, -24, 0, 25); inputBg.Position = UDim2.new(0, 12, 0, 28)
            inputBg.BackgroundColor3 = T.InputBg; inputBg.BackgroundTransparency = 0.2
            inputBg.BorderSizePixel = 0; inputBg.ZIndex = 5; inputBg.Parent = card
            Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0, 7)

            local inputStroke = Instance.new("UIStroke")
            inputStroke.Color = T.Border; inputStroke.Transparency = 0.5; inputStroke.Thickness = 1
            inputStroke.Parent = inputBg

            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, -16, 1, 0); box.Position = UDim2.new(0, 8, 0, 0)
            box.BackgroundTransparency = 1; box.Text = ""
            box.PlaceholderText = placeholder or "Type here..."
            box.PlaceholderColor3 = T.TextDisabled; box.TextColor3 = T.Text; box.TextSize = 12
            box.Font = Enum.Font.Gotham; box.TextXAlignment = Enum.TextXAlignment.Left
            box.ClearTextOnFocus = false; box.ZIndex = 6; box.Parent = inputBg

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

        function Tab:AddDropdown(text, options, callback)
            local selected = options and options[1] or ""
            local isOpen = false
            local optionsList = options or {}
            local card, stroke = MakeCard(44)
            card.ClipsDescendants = false

            local lbl = CreateLabel(card, text, UDim2.new(0.5, 0, 1, 0), UDim2.new(0, 12, 0, 0), Enum.Font.GothamMedium, T.Text, 5)

            local selLbl = Instance.new("TextLabel")
            selLbl.Size = UDim2.new(0.4, -28, 1, 0); selLbl.Position = UDim2.new(0.5, 0, 0, 0)
            selLbl.BackgroundTransparency = 1; selLbl.Text = selected
            selLbl.TextColor3 = T.Accent; selLbl.TextSize = 13; selLbl.Font = Enum.Font.GothamMedium
            selLbl.TextXAlignment = Enum.TextXAlignment.Right; selLbl.ZIndex = 5; selLbl.Parent = card

            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 18, 1, 0); arrow.Position = UDim2.new(1, -22, 0, 0)
            arrow.BackgroundTransparency = 1; arrow.Text = "▾"; arrow.TextColor3 = T.TextMuted
            arrow.TextSize = 14; arrow.Font = Enum.Font.GothamBold; arrow.ZIndex = 5; arrow.Parent = card

            -- Панель dropdown с высоким z-index
            local dropPanel = Instance.new("Frame")
            dropPanel.Size = UDim2.new(1, 0, 0, 0)
            dropPanel.Position = UDim2.new(0, 0, 1, 4)
            dropPanel.BackgroundColor3 = T.Surface
            dropPanel.BackgroundTransparency = 0.05
            dropPanel.BorderSizePixel = 0
            dropPanel.ClipsDescendants = true
            dropPanel.ZIndex = 100
            dropPanel.Visible = false
            dropPanel.Parent = ScreenGui -- Прикрепляем к ScreenGui для правильного z-index
            Instance.new("UICorner", dropPanel).CornerRadius = UDim.new(0, 10)

            local dpStroke = Instance.new("UIStroke")
            dpStroke.Color = T.Border; dpStroke.Transparency = 0.3; dpStroke.Thickness = 1
            dpStroke.Parent = dropPanel

            local dList = Instance.new("UIListLayout")
            dList.Padding = UDim.new(0, 2); dList.SortOrder = Enum.SortOrder.LayoutOrder; dList.Parent = dropPanel

            local dPad = Instance.new("UIPadding")
            dPad.PaddingTop = UDim.new(0, 4); dPad.PaddingBottom = UDim.new(0, 4)
            dPad.PaddingLeft = UDim.new(0, 4); dPad.PaddingRight = UDim.new(0, 4)
            dPad.Parent = dropPanel

            local targetH = 0

            local function UpdateTargetHeight()
                targetH = #optionsList * 32 + 8
            end
            UpdateTargetHeight()

            local function CreateOptionButton(opt, index)
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 30)
                optBtn.BackgroundColor3 = T.SurfaceGlass
                optBtn.BackgroundTransparency = 0.55
                optBtn.BorderSizePixel = 0
                optBtn.Text = opt
                optBtn.TextColor3 = opt == selected and T.AccentBright or T.Text
                optBtn.TextSize = 12
                optBtn.Font = Enum.Font.Gotham
                optBtn.ZIndex = 101
                optBtn.LayoutOrder = index
                optBtn.Parent = dropPanel
                Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 7)

                optBtn.MouseEnter:Connect(function()
                    QuickTween(optBtn, 0.12, { BackgroundColor3 = T.SurfaceLight, BackgroundTransparency = 0.25, TextColor3 = T.AccentBright })
                end)
                optBtn.MouseLeave:Connect(function()
                    QuickTween(optBtn, 0.12, { BackgroundColor3 = T.SurfaceGlass, BackgroundTransparency = 0.55, TextColor3 = opt == selected and T.AccentBright or T.Text })
                end)
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    selLbl.Text = opt
                    isOpen = false
                    dropPanel.Visible = false
                    QuickTween(arrow, 0.2, { Rotation = 0 })
                    QuickTween(stroke, 0.2, { Color = T.Border, Transparency = 0.55 })
                    if callback then callback(opt) end
                    -- Обновляем цвета всех кнопок
                    for _, child in ipairs(dropPanel:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.TextColor3 = child.Text == selected and T.AccentBright or T.Text
                        end
                    end
                end)
                return optBtn
            end

            -- Создаем начальные кнопки
            for i, opt in ipairs(optionsList) do
                CreateOptionButton(opt, i)
            end

            local function PositionDropdown()
                if card and card.Parent then
                    local absPos = card.AbsolutePosition
                    local absSize = card.AbsoluteSize
                    dropPanel.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
                    dropPanel.Size = UDim2.new(0, absSize.X, 0, isOpen and targetH or 0)
                end
            end

            local togBtn = Instance.new("TextButton")
            togBtn.Size = UDim2.new(1, 0, 1, 0); togBtn.BackgroundTransparency = 1
            togBtn.Text = ""; togBtn.ZIndex = 6; togBtn.Parent = card

            togBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    PositionDropdown()
                    dropPanel.Visible = true
                    QuickTween(dropPanel, 0.25, { Size = UDim2.new(0, card.AbsoluteSize.X, 0, targetH) })
                    QuickTween(arrow, 0.2, { Rotation = 180 })
                    QuickTween(stroke, 0.2, { Color = T.BorderGlow, Transparency = 0.3 })
                else
                    QuickTween(dropPanel, 0.2, { Size = UDim2.new(0, card.AbsoluteSize.X, 0, 0) })
                    QuickTween(arrow, 0.2, { Rotation = 0 })
                    QuickTween(stroke, 0.2, { Color = T.Border, Transparency = 0.55 })
                    task.delay(0.2, function()
                        if not isOpen then dropPanel.Visible = false end
                    end)
                end
            end)

            -- Закрытие при клике вне dropdown
            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
                    local mousePos = input.Position
                    local panelPos = dropPanel.AbsolutePosition
                    local panelSize = dropPanel.AbsoluteSize
                    local cardPos = card.AbsolutePosition
                    local cardSize = card.AbsoluteSize
                    
                    local inPanel = mousePos.X >= panelPos.X and mousePos.X <= panelPos.X + panelSize.X
                                   and mousePos.Y >= panelPos.Y and mousePos.Y <= panelPos.Y + panelSize.Y
                    local inCard = mousePos.X >= cardPos.X and mousePos.X <= cardPos.X + cardSize.X
                                  and mousePos.Y >= cardPos.Y and mousePos.Y <= cardPos.Y + cardSize.Y
                    
                    if not inPanel and not inCard then
                        isOpen = false
                        QuickTween(dropPanel, 0.2, { Size = UDim2.new(0, card.AbsoluteSize.X, 0, 0) })
                        QuickTween(arrow, 0.2, { Rotation = 0 })
                        QuickTween(stroke, 0.2, { Color = T.Border, Transparency = 0.55 })
                        task.delay(0.2, function()
                            if not isOpen then dropPanel.Visible = false end
                        end)
                    end
                end
            end)

            -- Обновление позиции при скролле
            Page:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                if isOpen then PositionDropdown() end
            end)

            local api = {}
            
            function api:Refresh(newOptions, keepSelection)
                -- Удаляем старые кнопки
                for _, child in ipairs(dropPanel:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                optionsList = newOptions or optionsList
                UpdateTargetHeight()
                
                if not keepSelection or not table.find(optionsList, selected) then
                    selected = optionsList[1] or ""
                    selLbl.Text = selected
                end
                
                -- Создаем новые кнопки
                for i, opt in ipairs(optionsList) do
                    CreateOptionButton(opt, i)
                end
                
                -- Обновляем размер если открыт
                if isOpen then
                    PositionDropdown()
                    dropPanel.Size = UDim2.new(0, card.AbsoluteSize.X, 0, targetH)
                end
            end
            
            function api:Set(v)
                for _, o in ipairs(optionsList) do
                    if o == v then
                        selected = v
                        selLbl.Text = v
                        if callback then callback(v) end
                        -- Обновляем цвета кнопок
                        for _, child in ipairs(dropPanel:GetChildren()) do
                            if child:IsA("TextButton") then
                                child.TextColor3 = child.Text == selected and T.AccentBright or T.Text
                            end
                        end
                        break
                    end
                end
            end
            
            function api:Get() return selected end
            
            return api
        end

        function Tab:AddColorPicker(text, default, callback)
            local color = default or Color3.new(1, 0, 0)
            local open = false
            local card = MakeCard(44)
            card.ClipsDescendants = false

            local lbl = CreateLabel(card, text, UDim2.new(1, -70, 1, 0), UDim2.new(0, 12, 0, 0), Enum.Font.GothamMedium, T.Text, 5)

            local preview = Instance.new("Frame")
            preview.Size = UDim2.new(0, 22, 0, 22); preview.Position = UDim2.new(1, -34, 0.5, -11)
            preview.BackgroundColor3 = color; preview.BorderSizePixel = 0; preview.ZIndex = 5; preview.Parent = card
            Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 6)

            local pvStroke = Instance.new("UIStroke")
            pvStroke.Color = T.Border; pvStroke.Transparency = 0.4; pvStroke.Thickness = 1
            pvStroke.Parent = preview

            local panel = Instance.new("Frame")
            panel.Size = UDim2.new(1, 0, 0, 0); panel.Position = UDim2.new(0, 0, 1, 4)
            panel.BackgroundColor3 = T.Surface; panel.BackgroundTransparency = 0.08
            panel.BorderSizePixel = 0; panel.ClipsDescendants = true; panel.ZIndex = 100; panel.Parent = ScreenGui
            panel.Visible = false
            Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

            local panStroke = Instance.new("UIStroke")
            panStroke.Color = T.Border; panStroke.Transparency = 0.4; panStroke.Thickness = 1
            panStroke.Parent = panel

            local hueBar = Instance.new("Frame")
            hueBar.Size = UDim2.new(1, -20, 0, 14); hueBar.Position = UDim2.new(0, 10, 0, 10)
            hueBar.BackgroundColor3 = Color3.new(1, 1, 1); hueBar.BorderSizePixel = 0; hueBar.ZIndex = 101
            hueBar.Parent = panel
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
            hueKnob.Size = UDim2.new(0, 9, 1, 4); hueKnob.AnchorPoint = Vector2.new(0.5, 0.5)
            hueKnob.Position = UDim2.new(0, 0, 0.5, 0); hueKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            hueKnob.BorderSizePixel = 0; hueKnob.ZIndex = 102; hueKnob.Parent = hueBar
            Instance.new("UICorner", hueKnob).CornerRadius = UDim.new(0, 3)

            local hexLbl = Instance.new("TextLabel")
            hexLbl.Size = UDim2.new(1, -20, 0, 14); hexLbl.Position = UDim2.new(0, 10, 0, 30)
            hexLbl.BackgroundTransparency = 1; hexLbl.Text = "Hue slider"; hexLbl.TextColor3 = T.TextMuted
            hexLbl.TextSize = 10; hexLbl.Font = Enum.Font.Gotham; hexLbl.TextXAlignment = Enum.TextXAlignment.Left
            hexLbl.ZIndex = 101; hexLbl.Parent = panel

            local hue, sat, val2 = Color3.toHSV(color)
            local draggingHue = false

            local function UpdateColor()
                color = Color3.fromHSV(hue, 1, 1)
                preview.BackgroundColor3 = color
                hexLbl.Text = string.format("H: %.0f°", hue * 360)
            end

            UpdateColor()

            local function UpdateHue(input)
                local rel = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                hue = rel
                QuickTween(hueKnob, 0.04, { Position = UDim2.new(rel, 0, 0.5, 0) })
                UpdateColor()
                if callback then callback(color) end
            end

            hueBar.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    draggingHue = true; UpdateHue(inp)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if draggingHue and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then UpdateHue(inp) end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then draggingHue = false end
            end)

            local togBtn = Instance.new("TextButton")
            togBtn.Size = UDim2.new(1, 0, 1, 0); togBtn.BackgroundTransparency = 1
            togBtn.Text = ""; togBtn.ZIndex = 6; togBtn.Parent = card

            local function PositionPanel()
                if card and card.Parent then
                    local absPos = card.AbsolutePosition
                    local absSize = card.AbsoluteSize
                    panel.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
                    panel.Size = UDim2.new(0, absSize.X, 0, open and 55 or 0)
                end
            end

            togBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    PositionPanel()
                    panel.Visible = true
                    QuickTween(panel, 0.25, { Size = UDim2.new(0, card.AbsoluteSize.X, 0, 55) })
                    QuickTween(pvStroke, 0.2, { Color = T.BorderGlow, Transparency = 0.2 })
                else
                    QuickTween(panel, 0.2, { Size = UDim2.new(0, card.AbsoluteSize.X, 0, 0) })
                    QuickTween(pvStroke, 0.2, { Color = T.Border, Transparency = 0.4 })
                    task.delay(0.2, function()
                        if not open then panel.Visible = false end
                    end)
                end
            end)

            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and open then
                    local mousePos = input.Position
                    local panelPos = panel.AbsolutePosition
                    local panelSize = panel.AbsoluteSize
                    local cardPos = card.AbsolutePosition
                    local cardSize = card.AbsoluteSize
                    
                    local inPanel = mousePos.X >= panelPos.X and mousePos.X <= panelPos.X + panelSize.X
                                   and mousePos.Y >= panelPos.Y and mousePos.Y <= panelPos.Y + panelSize.Y
                    local inCard = mousePos.X >= cardPos.X and mousePos.X <= cardPos.X + cardSize.X
                                  and mousePos.Y >= cardPos.Y and mousePos.Y <= cardPos.Y + cardSize.Y
                    
                    if not inPanel and not inCard then
                        open = false
                        QuickTween(panel, 0.2, { Size = UDim2.new(0, card.AbsoluteSize.X, 0, 0) })
                        QuickTween(pvStroke, 0.2, { Color = T.Border, Transparency = 0.4 })
                        task.delay(0.2, function()
                            if not open then panel.Visible = false end
                        end)
                    end
                end
            end)

            local api = {}
            function api:Set(c) 
                color = c
                preview.BackgroundColor3 = color
                hue = Color3.toHSV(color)
                QuickTween(hueKnob, 0.1, { Position = UDim2.new(hue, 0, 0.5, 0) })
                if callback then callback(color) end
            end
            function api:Get() return color end
            return api
        end

        return Tab
    end

    -- ╔══════════════════════════════════════════════════╗
    -- ║                 NOTIFICATION SYSTEM               ║
    -- ╚══════════════════════════════════════════════════╝

    function self:Notify(config)
        config = config or {}
        local title = config.Title or "Notification"
        local message = config.Message or ""
        local duration = config.Duration or 3
        local notifType = config.Type or "Info"

        local typeColors = {
            Info = T.Info,
            Success = T.Success,
            Warning = T.Warning,
            Error = T.Error,
        }
        local typeColor = typeColors[notifType] or T.Info

        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(0, 280, 0, 0)
        notif.Position = UDim2.new(1, -20, 1, -20)
        notif.AnchorPoint = Vector2.new(1, 1)
        notif.BackgroundColor3 = T.Surface
        notif.BackgroundTransparency = 0.08
        notif.BorderSizePixel = 0
        notif.ZIndex = 200
        notif.Parent = ScreenGui
        Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 12)

        local nStroke = Instance.new("UIStroke")
        nStroke.Color = typeColor; nStroke.Transparency = 0.3; nStroke.Thickness = 1
        nStroke.Parent = notif

        local accentLine = Instance.new("Frame")
        accentLine.Size = UDim2.new(0, 3, 1, -16)
        accentLine.Position = UDim2.new(0, 8, 0, 8)
        accentLine.BackgroundColor3 = typeColor
        accentLine.BorderSizePixel = 0
        accentLine.ZIndex = 201
        accentLine.Parent = notif
        Instance.new("UICorner", accentLine).CornerRadius = UDim.new(1, 0)

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -30, 0, 20)
        titleLbl.Position = UDim2.new(0, 18, 0, 8)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = title
        titleLbl.TextColor3 = T.AccentBright
        titleLbl.TextSize = 13
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.ZIndex = 201
        titleLbl.Parent = notif

        local msgLbl = Instance.new("TextLabel")
        msgLbl.Size = UDim2.new(1, -30, 0, 16)
        msgLbl.Position = UDim2.new(0, 18, 0, 26)
        msgLbl.BackgroundTransparency = 1
        msgLbl.Text = message
        msgLbl.TextColor3 = T.TextMuted
        msgLbl.TextSize = 11
        msgLbl.Font = Enum.Font.Gotham
        msgLbl.TextXAlignment = Enum.TextXAlignment.Left
        msgLbl.TextWrapped = true
        msgLbl.ZIndex = 201
        msgLbl.Parent = notif

        -- Анимация появления
        local targetSize = UDim2.new(0, 280, 0, 50)
        QuickTween(notif, 0.4, { Size = targetSize })

        -- Авто-удаление
        task.delay(duration, function()
            if notif and notif.Parent then
                QuickTween(notif, 0.3, { BackgroundTransparency = 1 })
                QuickTween(nStroke, 0.3, { Transparency = 1 })
                task.delay(0.3, function()
                    if notif and notif.Parent then notif:Destroy() end
                end)
            end
        end)
    end

    -- ╔══════════════════════════════════════════════════╗
    -- ║                  TOGGLE KEYBIND                  ║
    -- ╚══════════════════════════════════════════════════╝

    if config.ToggleKey then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == config.ToggleKey then
                self._open = not self._open
                if self._open then
                    Window.Visible = true
                    ElasticTween(Window, 0.4, { Size = UDim2.new(0, WIN_W, 0, WIN_H) })
                    SmoothTween(Overlay, 0.3, { BackgroundTransparency = 0.55 })
                    SmoothTween(blur, 0.3, { Size = T.BlurSize })
                else
                    SmoothTween(Window, 0.3, { Size = UDim2.new(0, 0, 0, 0) })
                    SmoothTween(Overlay, 0.3, { BackgroundTransparency = 1 })
                    SmoothTween(blur, 0.3, { Size = 0 })
                    task.delay(0.3, function()
                        if not self._open then Window.Visible = false end
                    end)
                end
            end
        end)
    end

    return self
end

return ZandarUI
