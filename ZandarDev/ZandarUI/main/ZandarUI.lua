--[[
    vertelevse speek  v3.2
    ZandarUI v3.0 (монохром-стекло) + Watch / Follow / Teleport / Settings
    
    ИСПОЛЬЗОВАНИЕ:
        loadstring(game:HttpGet("URL_К_ЭТОМУ_ФАЙЛУ"))()
    
    Горячая клавиша: RightShift — показать/скрыть окно
]]

-- ╔══════════════════════════════════════════════════╗
-- ║              SERVICES                            ║
-- ╚══════════════════════════════════════════════════╝

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

-- ╔══════════════════════════════════════════════════╗
-- ║              ТЕМА (монохром стекло)              ║
-- ╚══════════════════════════════════════════════════╝

local T = {
    Background      = Color3.fromRGB(6,   6,   8),
    Surface         = Color3.fromRGB(16,  16,  20),
    SurfaceGlass    = Color3.fromRGB(28,  28,  34),
    SurfaceLight    = Color3.fromRGB(44,  44,  54),

    Border          = Color3.fromRGB(70,  70,  80),
    BorderGlow      = Color3.fromRGB(190, 190, 210),
    BorderHover     = Color3.fromRGB(225, 225, 240),

    Text            = Color3.fromRGB(235, 235, 245),
    TextMuted       = Color3.fromRGB(130, 130, 150),
    TextDisabled    = Color3.fromRGB(65,  65,  78),

    Accent          = Color3.fromRGB(210, 210, 225),
    AccentBright    = Color3.fromRGB(255, 255, 255),

    ToggleOff       = Color3.fromRGB(36,  36,  44),
    ToggleOn        = Color3.fromRGB(200, 200, 215),

    Success         = Color3.fromRGB(0,   210, 80),
    Warning         = Color3.fromRGB(220, 200, 130),
    Error           = Color3.fromRGB(220, 80,  80),
    Info            = Color3.fromRGB(60,  120, 255),

    BlurSize        = 16,
}

-- ╔══════════════════════════════════════════════════╗
-- ║              УТИЛИТЫ                             ║
-- ╚══════════════════════════════════════════════════╝

local function Tween(obj, info, props)
    local tw = TweenService:Create(obj, info, props); tw:Play(); return tw
end
local function QT(obj, t, props)
    return Tween(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
end
local function ST(obj, t, props)
    return Tween(obj, TweenInfo.new(t, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), props)
end
local function ET(obj, t, props)
    return Tween(obj, TweenInfo.new(t, Enum.EasingStyle.Back, Enum.EasingDirection.Out), props)
end

local function Shimmer(gradient, speed)
    speed = speed or 2.4
    task.spawn(function()
        while gradient and gradient.Parent do
            gradient.Offset = Vector2.new(-1, 0)
            local tw = Tween(gradient,
                TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { Offset = Vector2.new(1, 0) })
            tw.Completed:Wait()
            task.wait(0.3)
        end
    end)
end

local function ShimmerLabel(lbl)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(130, 130, 145)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(130, 130, 145)),
    })
    g.Parent = lbl
    Shimmer(g, 2.8)
    return g
end

local function Ripple(btn)
    local r = Instance.new("Frame")
    r.Size = UDim2.new(0,0,0,0)
    r.AnchorPoint = Vector2.new(0.5,0.5)
    r.BackgroundColor3 = Color3.new(1,1,1)
    r.BackgroundTransparency = 0.82
    r.BorderSizePixel = 0
    r.ZIndex = btn.ZIndex + 10
    r.Parent = btn
    Instance.new("UICorner", r).CornerRadius = UDim.new(1,0)
    local mp = btn.AbsolutePosition; local ms = btn.AbsoluteSize
    r.Position = UDim2.new(0, (Mouse and Mouse.X or mp.X) - mp.X,
                            0, (Mouse and Mouse.Y or mp.Y) - mp.Y)
    TweenService:Create(r, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.new(0, ms.X*2.8, 0, ms.X*2.8), BackgroundTransparency = 1 }):Play()
    Debris:AddItem(r, 0.55)
end

-- Draggable: anchor остаётся (0.5,0.5), двигаем только Offset
-- onRelease(didMove) — если didMove=false значит был клик, а не drag
local function MakeDraggable(frame, handle, pad, onRelease)
    handle = handle or frame; pad = pad or 0
    local dragging, moved = false, false
    local dragStart, startOffset, dragInput, endConn

    local function begin(inp)
        dragging = true; moved = false
        dragStart   = inp.Position
        startOffset = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
        if endConn then endConn:Disconnect() end
        endConn = inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then
                dragging = false
                if onRelease then task.defer(onRelease, moved) end
            end
        end)
    end

    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            begin(inp)
        end
    end)
    handle.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragInput = inp
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not dragging or inp ~= dragInput then return end
        local d = inp.Position - dragStart
        if d.Magnitude > 4 then moved = true end
        local nx = startOffset.X + d.X
        local ny = startOffset.Y + d.Y
        local vp = Camera and Camera.ViewportSize or Vector2.new(1280,720)
        local hw = frame.AbsoluteSize.X/2; local hh = frame.AbsoluteSize.Y/2
        nx = math.clamp(nx, hw+pad - vp.X*frame.Position.X.Scale, vp.X*(1-frame.Position.X.Scale)-hw-pad)
        ny = math.clamp(ny, hh+pad - vp.Y*frame.Position.Y.Scale, vp.Y*(1-frame.Position.Y.Scale)-hh-pad)
        frame.Position = UDim2.new(frame.Position.X.Scale, nx, frame.Position.Y.Scale, ny)
    end)
end

local function GlassFrame(parent, size, pos, r, z)
    local f = Instance.new("Frame")
    f.Size = size or UDim2.new(1,0,1,0)
    f.Position = pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3 = T.SurfaceGlass
    f.BackgroundTransparency = 0.38
    f.BorderSizePixel = 0
    f.ZIndex = z or 4
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, r or 10)
    local st = Instance.new("UIStroke")
    st.Color = T.Border; st.Transparency = 0.55; st.Thickness = 1
    st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    st.Parent = f
    return f, st
end

-- ╔══════════════════════════════════════════════════╗
-- ║              CORE GUI                            ║
-- ╚══════════════════════════════════════════════════╝

-- Снести старый экземпляр если есть
if CoreGui:FindFirstChild("SpeekUI") then CoreGui:FindFirstChild("SpeekUI"):Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "SpeekUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn   = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent         = CoreGui

-- Blur + overlay
local blur = Instance.new("BlurEffect"); blur.Size = 0; blur.Parent = Lighting
ST(blur, 0.5, { Size = T.BlurSize })

local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1,0,1,0)
Overlay.BackgroundColor3 = Color3.new(0,0,0)
Overlay.BackgroundTransparency = 1
Overlay.BorderSizePixel = 0
Overlay.ZIndex = 0
Overlay.Parent = ScreenGui
ST(Overlay, 0.5, { BackgroundTransparency = 0.6 })

-- Адаптивный размер окна
local function WinSize()
    local vp = Camera and Camera.ViewportSize or Vector2.new(1280,720)
    return math.floor(math.clamp(vp.X*0.52, 440, 620)),
           math.floor(math.clamp(vp.Y*0.62, 300, 440))
end
local WIN_W, WIN_H = WinSize()

-- ── Главное окно ─────────────────────────────────────
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
Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 18)

local winStroke = Instance.new("UIStroke")
winStroke.Color = T.BorderGlow; winStroke.Transparency = 0.55
winStroke.Thickness = 1.2; winStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
winStroke.Parent = Window

task.spawn(function()
    local up = true
    while Window.Parent do
        ST(winStroke, 2.4, { Transparency = up and 0.25 or 0.68 }); up = not up; task.wait(2.4)
    end
end)

ET(Window, 0.6, { Size = UDim2.new(0, WIN_W, 0, WIN_H) })

-- ── Хедер ────────────────────────────────────────────
local Header = Instance.new("Frame")
Header.Name             = "Header"
Header.Size             = UDim2.new(1,0,0,52)
Header.BackgroundColor3 = T.Surface
Header.BackgroundTransparency = 0.15
Header.BorderSizePixel  = 0
Header.ZIndex           = 3
Header.Parent           = Window
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 18)

-- Заглушка снизу хедера (срезает нижние скруглённые углы)
local hFix = Instance.new("Frame")
hFix.Size = UDim2.new(1,0,0,18); hFix.Position = UDim2.new(0,0,1,-18)
hFix.BackgroundColor3 = T.Surface; hFix.BackgroundTransparency = 0.15
hFix.BorderSizePixel = 0; hFix.ZIndex = 3; hFix.Parent = Header

-- Разделительная линия с shimmer
local hLine = Instance.new("Frame")
hLine.Size = UDim2.new(1,-20,0,1); hLine.Position = UDim2.new(0,10,1,-1)
hLine.BackgroundColor3 = T.Border; hLine.BackgroundTransparency = 0.35
hLine.BorderSizePixel = 0; hLine.ZIndex = 4; hLine.Parent = Header
ShimmerLabel(hLine)

-- Акцент-полоска слева
local aBar = Instance.new("Frame")
aBar.Size = UDim2.new(0,3,0,24); aBar.Position = UDim2.new(0,16,0.5,-12)
aBar.BackgroundColor3 = T.AccentBright; aBar.BorderSizePixel = 0; aBar.ZIndex = 5; aBar.Parent = Header
Instance.new("UICorner", aBar).CornerRadius = UDim.new(1,0)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(0,260,0,26); TitleLbl.Position = UDim2.new(0,28,0,7)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "◈  vertelevse speek"
TitleLbl.TextColor3 = T.AccentBright; TitleLbl.TextSize = 15
TitleLbl.Font = Enum.Font.GothamBold; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 5; TitleLbl.Parent = Header
ShimmerLabel(TitleLbl)

local SubLbl = Instance.new("TextLabel")
SubLbl.Size = UDim2.new(0,260,0,14); SubLbl.Position = UDim2.new(0,28,0,33)
SubLbl.BackgroundTransparency = 1; SubLbl.Text = "v3.2  •  Monochrome Glass"
SubLbl.TextColor3 = T.TextMuted; SubLbl.TextSize = 10
SubLbl.Font = Enum.Font.Gotham; SubLbl.TextXAlignment = Enum.TextXAlignment.Left
SubLbl.ZIndex = 5; SubLbl.Parent = Header

MakeDraggable(Window, Header)

-- Кнопка закрытия в хедере (X из двух баров)
local HClose = Instance.new("TextButton")
HClose.Size = UDim2.new(0,22,0,22); HClose.Position = UDim2.new(1,-14,0.5,-11)
HClose.AnchorPoint = Vector2.new(1,0); HClose.BackgroundColor3 = T.SurfaceGlass
HClose.BackgroundTransparency = 0.3; HClose.BorderSizePixel = 0
HClose.Text = ""; HClose.AutoButtonColor = false; HClose.ZIndex = 6
HClose.ClipsDescendants = true; HClose.Parent = Header
Instance.new("UICorner", HClose).CornerRadius = UDim.new(1,0)
local hcSt = Instance.new("UIStroke"); hcSt.Color = T.Border; hcSt.Transparency = 0.5; hcSt.Thickness = 1; hcSt.Parent = HClose
local function makeXBar(rot)
    local b = Instance.new("Frame")
    b.Size = UDim2.new(0,11,0,2); b.AnchorPoint = Vector2.new(0.5,0.5)
    b.Position = UDim2.new(0.5,0,0.5,0); b.Rotation = rot
    b.BackgroundColor3 = T.TextMuted; b.BorderSizePixel = 0; b.ZIndex = 7; b.Parent = HClose
    Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
    return b
end
local xb1 = makeXBar(45); local xb2 = makeXBar(-45)
HClose.MouseEnter:Connect(function()
    QT(HClose,0.15,{BackgroundColor3=Color3.fromRGB(60,20,20),BackgroundTransparency=0})
    QT(xb1,0.15,{BackgroundColor3=T.AccentBright}); QT(xb2,0.15,{BackgroundColor3=T.AccentBright})
end)
HClose.MouseLeave:Connect(function()
    QT(HClose,0.15,{BackgroundColor3=T.SurfaceGlass,BackgroundTransparency=0.3})
    QT(xb1,0.15,{BackgroundColor3=T.TextMuted}); QT(xb2,0.15,{BackgroundColor3=T.TextMuted})
end)

-- ── Рейл табов (слева) ────────────────────────────────
local RAIL_W = 130
local TabRail = Instance.new("Frame")
TabRail.Name = "TabRail"; TabRail.Size = UDim2.new(0,RAIL_W,1,-52)
TabRail.Position = UDim2.new(0,0,0,52)
TabRail.BackgroundColor3 = T.Background; TabRail.BackgroundTransparency = 0.1
TabRail.BorderSizePixel = 0; TabRail.ZIndex = 2; TabRail.Parent = Window

local tList = Instance.new("UIListLayout", TabRail)
tList.Padding = UDim.new(0,4); tList.SortOrder = Enum.SortOrder.LayoutOrder
local tPad = Instance.new("UIPadding", TabRail)
tPad.PaddingTop = UDim.new(0,10); tPad.PaddingLeft = UDim.new(0,6); tPad.PaddingRight = UDim.new(0,6)

local railDiv = Instance.new("Frame")
railDiv.Size = UDim2.new(0,1,1,-52); railDiv.Position = UDim2.new(0,RAIL_W,0,52)
railDiv.BackgroundColor3 = T.Border; railDiv.BackgroundTransparency = 0.4
railDiv.BorderSizePixel = 0; railDiv.ZIndex = 3; railDiv.Parent = Window

-- Контентная зона (правая часть)
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1,-(RAIL_W+2),1,-54)
ContentArea.Position = UDim2.new(0,RAIL_W+2,0,54)
ContentArea.BackgroundTransparency = 1; ContentArea.BorderSizePixel = 0
ContentArea.ZIndex = 2; ContentArea.Parent = Window

-- ── FAB (плавающая кнопка открытия/закрытия) ─────────
local FAB_S = 52
local Fab = Instance.new("TextButton")
Fab.Name = "Fab"; Fab.Size = UDim2.new(0,FAB_S,0,FAB_S)
Fab.AnchorPoint = Vector2.new(1,1); Fab.Position = UDim2.new(1,-20,1,-20)
Fab.BackgroundColor3 = T.Background; Fab.BackgroundTransparency = 0.05
Fab.BorderSizePixel = 0; Fab.Text = ""; Fab.AutoButtonColor = false
Fab.ClipsDescendants = true; Fab.ZIndex = 50; Fab.Parent = ScreenGui
Instance.new("UICorner", Fab).CornerRadius = UDim.new(1,0)

local fabSt = Instance.new("UIStroke"); fabSt.Color = T.BorderGlow
fabSt.Transparency = 0.3; fabSt.Thickness = 1.4; fabSt.Parent = Fab

task.spawn(function()
    local up = true
    while Fab.Parent do ST(fabSt,2,{Transparency=up and 0.12 or 0.55}); up=not up; task.wait(2) end
end)

local function makeFBar(y)
    local b = Instance.new("Frame"); b.Size = UDim2.new(0,18,0,2)
    b.AnchorPoint = Vector2.new(0.5,0.5); b.Position = UDim2.new(0.5,0,0.5,y)
    b.BackgroundColor3 = T.AccentBright; b.BorderSizePixel = 0; b.ZIndex = 52; b.Parent = Fab
    Instance.new("UICorner", b).CornerRadius = UDim.new(1,0); return b
end
local fb1 = makeFBar(-5); local fb2 = makeFBar(5)

local function SetFabX(isX)
    if isX then
        QT(fb1,0.25,{Position=UDim2.new(0.5,0,0.5,0),Rotation=45})
        QT(fb2,0.25,{Position=UDim2.new(0.5,0,0.5,0),Rotation=-45})
    else
        QT(fb1,0.25,{Position=UDim2.new(0.5,0,0.5,-5),Rotation=0})
        QT(fb2,0.25,{Position=UDim2.new(0.5,0,0.5,5),Rotation=0})
    end
end
SetFabX(true)

local fabHit = Instance.new("TextButton"); fabHit.Size = UDim2.new(1,0,1,0)
fabHit.BackgroundTransparency = 1; fabHit.Text = ""; fabHit.ZIndex = 53; fabHit.Parent = Fab
fabHit.MouseEnter:Connect(function() QT(Fab,0.15,{BackgroundTransparency=0}); QT(fabSt,0.15,{Transparency=0.05}) end)
fabHit.MouseLeave:Connect(function() QT(Fab,0.15,{BackgroundTransparency=0.05}) end)

-- Open/close логика
local guiOpen = true
local function SetOpen(open)
    guiOpen = open; SetFabX(open)
    if open then
        Window.Visible = true
        ET(Window,0.55,{Size=UDim2.new(0,WIN_W,0,WIN_H)})
        ST(Overlay,0.4,{BackgroundTransparency=0.6}); ST(blur,0.4,{Size=T.BlurSize})
    else
        QT(Window,0.28,{Size=UDim2.new(0,0,0,0)})
        ST(Overlay,0.35,{BackgroundTransparency=1}); ST(blur,0.35,{Size=0})
        task.delay(0.32, function() if not guiOpen then Window.Visible=false end end)
    end
end

MakeDraggable(Fab, fabHit, 6, function(moved)
    if not moved then Ripple(Fab); SetOpen(not guiOpen) end
end)
HClose.MouseButton1Click:Connect(function() Ripple(HClose); SetOpen(false) end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then SetOpen(not guiOpen) end
end)

if Camera then
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        WIN_W, WIN_H = WinSize()
        if guiOpen then QT(Window,0.25,{Size=UDim2.new(0,WIN_W,0,WIN_H)}) end
    end)
end

-- ╔══════════════════════════════════════════════════╗
-- ║         СТРОИТЕЛЬ ТАБОВ (вспомогательный)        ║
-- ╚══════════════════════════════════════════════════╝

local activeTab = nil
local tabIndex  = 0

local function AddTab(name)
    tabIndex = tabIndex + 1
    local idx = tabIndex

    -- Кнопка в рейле
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,34); btn.BackgroundColor3 = T.Surface
    btn.BackgroundTransparency = 0.65; btn.BorderSizePixel = 0
    btn.Text = name; btn.TextColor3 = T.TextMuted; btn.TextSize = 12
    btn.Font = Enum.Font.GothamMedium; btn.ZIndex = 4; btn.LayoutOrder = idx
    btn.AutoButtonColor = false; btn.Parent = TabRail
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,9)
    local btnSt = Instance.new("UIStroke"); btnSt.Color=T.Border; btnSt.Transparency=0.75; btnSt.Thickness=1; btnSt.Parent=btn

    local abar = Instance.new("Frame")
    abar.Size = UDim2.new(0,2,0,16); abar.Position = UDim2.new(0,0,0.5,-8)
    abar.BackgroundColor3 = T.AccentBright; abar.BackgroundTransparency = 1
    abar.BorderSizePixel = 0; abar.ZIndex = 6; abar.Parent = btn
    Instance.new("UICorner", abar).CornerRadius = UDim.new(1,0)

    -- Страница (ScrollingFrame) для этого таба
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1
    page.BorderSizePixel = 0; page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = T.Accent
    page.CanvasSize = UDim2.new(0,0,0,0); page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false; page.ZIndex = 3; page.Parent = ContentArea
    local pList = Instance.new("UIListLayout", page)
    pList.Padding = UDim.new(0,5); pList.SortOrder = Enum.SortOrder.LayoutOrder
    local pPad = Instance.new("UIPadding", page)
    pPad.PaddingTop=UDim.new(0,8); pPad.PaddingLeft=UDim.new(0,8)
    pPad.PaddingRight=UDim.new(0,10); pPad.PaddingBottom=UDim.new(0,8)

    local tab = { _page=page, _btn=btn, _order=0 }

    local function setActive(on)
        if on then
            QT(btn,0.2,{BackgroundColor3=T.SurfaceLight,BackgroundTransparency=0.2})
            QT(btn,0.2,{TextColor3=T.AccentBright})
            QT(abar,0.2,{BackgroundTransparency=0})
            QT(btnSt,0.2,{Color=T.BorderGlow,Transparency=0.4})
            page.Visible = true
        else
            QT(btn,0.2,{BackgroundColor3=T.Surface,BackgroundTransparency=0.65})
            QT(btn,0.2,{TextColor3=T.TextMuted})
            QT(abar,0.2,{BackgroundTransparency=1})
            QT(btnSt,0.2,{Color=T.Border,Transparency=0.75})
            page.Visible = false
        end
    end
    tab._setActive = setActive

    btn.MouseButton1Click:Connect(function()
        Ripple(btn)
        if activeTab then activeTab._setActive(false) end
        setActive(true); activeTab = tab
    end)
    btn.MouseEnter:Connect(function()
        if activeTab~=tab then QT(btn,0.15,{BackgroundTransparency=0.4}) end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab~=tab then QT(btn,0.15,{BackgroundTransparency=0.65}) end
    end)

    if tabIndex == 1 then setActive(true); activeTab = tab end

    -- Хелперы для вставки элементов
    function tab:Card(h)
        self._order = self._order+1
        local c,s = GlassFrame(page, UDim2.new(1,0,0,h or 42), UDim2.new(0,0,0,0), 10, 4)
        c.LayoutOrder = self._order; return c,s
    end

    function tab:Label(txt, color)
        self._order = self._order+1
        local l = Instance.new("TextLabel")
        l.Size=UDim2.new(1,-20,0,28); l.BackgroundTransparency=1
        l.Text=txt or ""; l.TextColor3=color or T.TextMuted; l.TextSize=11
        l.Font=Enum.Font.Gotham; l.TextXAlignment=Enum.TextXAlignment.Left
        l.ZIndex=5; l.LayoutOrder=self._order; l.Parent=page
        local pad=Instance.new("UIPadding",l); pad.PaddingLeft=UDim.new(0,4)
        return l
    end

    function tab:Section(txt)
        self._order = self._order+1
        local l = Instance.new("TextLabel")
        l.Size=UDim2.new(1,-12,0,22); l.BackgroundTransparency=1
        l.Text=(txt or ""):upper(); l.TextColor3=T.Accent; l.TextSize=10
        l.Font=Enum.Font.GothamBold; l.TextXAlignment=Enum.TextXAlignment.Left
        l.LayoutOrder=self._order; l.ZIndex=4; l.Parent=page
        local pad=Instance.new("UIPadding",l); pad.PaddingLeft=UDim.new(0,4)
        ShimmerLabel(l); return l
    end

    return tab
end

-- ╔══════════════════════════════════════════════════╗
-- ║              STATE МОНИТОРИНГА                   ║
-- ╚══════════════════════════════════════════════════╝

local followTarget = nil
local followConn   = nil
local watchTarget  = nil

local function returnCam()
    local ch = LocalPlayer.Character
    if ch then
        local hm = ch:FindFirstChildOfClass("Humanoid")
        if hm then Camera.CameraSubject=hm; Camera.CameraType=Enum.CameraType.Custom end
    end
    watchTarget = nil
end

local function stopFollow()
    if followConn then followConn:Disconnect(); followConn=nil end
    followTarget = nil
end

-- ╔══════════════════════════════════════════════════╗
-- ║        ФУНКЦИЯ: карточка игрока                  ║
-- ╚══════════════════════════════════════════════════╝

-- Возвращает карточку + кнопку действия + зелёный dot
local function BuildPlayerCard(parent, player, btnText, zBase)
    zBase = zBase or 5
    local card = Instance.new("Frame")
    card.Name = player.Name
    card.Size = UDim2.new(1,0,0,54)
    card.BackgroundColor3 = T.SurfaceGlass
    card.BackgroundTransparency = 0.35
    card.BorderSizePixel = 0; card.ZIndex = zBase; card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,10)
    local cSt = Instance.new("UIStroke"); cSt.Color=T.Border; cSt.Transparency=0.55; cSt.Thickness=1; cSt.Parent=card

    -- Аватар
    local av = Instance.new("ImageLabel")
    av.Size=UDim2.new(0,38,0,38); av.Position=UDim2.new(0,7,0.5,-19)
    av.BackgroundColor3=T.Surface; av.BackgroundTransparency=0.3
    av.BorderSizePixel=0; av.ZIndex=zBase+1; av.Parent=card
    Instance.new("UICorner",av).CornerRadius=UDim.new(1,0)
    task.spawn(function()
        local ok,url = pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId,
                Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        end)
        if ok then av.Image=url end
    end)

    -- Имя / info
    local disp = Instance.new("TextLabel")
    disp.Size=UDim2.new(1,-155,0,18); disp.Position=UDim2.new(0,52,0,8)
    disp.BackgroundTransparency=1; disp.Text=player.DisplayName
    disp.TextColor3=T.AccentBright; disp.TextSize=13; disp.Font=Enum.Font.GothamBold
    disp.TextXAlignment=Enum.TextXAlignment.Left; disp.ZIndex=zBase+1; disp.Parent=card

    local info = Instance.new("TextLabel")
    info.Size=UDim2.new(1,-155,0,13); info.Position=UDim2.new(0,52,0,28)
    info.BackgroundTransparency=1; info.Text="@"..player.Name.."  •  "..player.UserId
    info.TextColor3=T.TextMuted; info.TextSize=10; info.Font=Enum.Font.Gotham
    info.TextXAlignment=Enum.TextXAlignment.Left; info.ZIndex=zBase+1; info.Parent=card

    -- Кнопка действия
    local actBtn = Instance.new("TextButton")
    actBtn.Size=UDim2.new(0,82,0,26); actBtn.Position=UDim2.new(1,-90,0.5,-13)
    actBtn.BackgroundColor3=T.Surface; actBtn.BackgroundTransparency=0.2
    actBtn.BorderSizePixel=0; actBtn.Text=btnText
    actBtn.TextColor3=T.AccentBright; actBtn.TextSize=11; actBtn.Font=Enum.Font.GothamBold
    actBtn.AutoButtonColor=false; actBtn.ZIndex=zBase+2; actBtn.Parent=card
    Instance.new("UICorner",actBtn).CornerRadius=UDim.new(0,7)
    local abSt=Instance.new("UIStroke"); abSt.Color=T.Border; abSt.Transparency=0.5; abSt.Thickness=1; abSt.Parent=actBtn

    actBtn.MouseEnter:Connect(function() QT(actBtn,0.12,{BackgroundTransparency=0}); QT(abSt,0.12,{Color=T.BorderGlow,Transparency=0.2}) end)
    actBtn.MouseLeave:Connect(function() QT(actBtn,0.12,{BackgroundTransparency=0.2}); QT(abSt,0.12,{Color=T.Border,Transparency=0.5}) end)

    -- Зелёный индикатор активности
    local dot = Instance.new("Frame")
    dot.Size=UDim2.new(0,7,0,7); dot.Position=UDim2.new(1,-10,0,4)
    dot.BackgroundColor3=T.Success; dot.Visible=false
    dot.BorderSizePixel=0; dot.ZIndex=zBase+3; dot.Parent=card
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)

    return card, actBtn, dot, cSt
end

-- ╔══════════════════════════════════════════════════╗
-- ║              ПОИСК (общий)                       ║
-- ╚══════════════════════════════════════════════════╝

-- Возвращает рамку поиска + функцию фильтрации карточек
local function MakeSearchBar(parent, cardTable)
    local sbg = Instance.new("Frame")
    sbg.Size=UDim2.new(1,0,0,30); sbg.BackgroundColor3=T.Surface
    sbg.BackgroundTransparency=0.25; sbg.BorderSizePixel=0; sbg.ZIndex=5; sbg.Parent=parent
    Instance.new("UICorner",sbg).CornerRadius=UDim.new(0,8)
    local sbst=Instance.new("UIStroke"); sbst.Color=T.Border; sbst.Transparency=0.5; sbst.Thickness=1; sbst.Parent=sbg

    local icon=Instance.new("TextLabel")
    icon.Size=UDim2.new(0,24,1,0); icon.BackgroundTransparency=1; icon.Text="🔍"
    icon.TextSize=12; icon.ZIndex=6; icon.Parent=sbg

    local box=Instance.new("TextBox")
    box.Size=UDim2.new(1,-52,1,0); box.Position=UDim2.new(0,26,0,0)
    box.BackgroundTransparency=1; box.Text=""; box.PlaceholderText="Поиск игрока…"
    box.PlaceholderColor3=T.TextDisabled; box.TextColor3=T.AccentBright
    box.TextSize=11; box.Font=Enum.Font.Gotham; box.ClearTextOnFocus=false
    box.TextXAlignment=Enum.TextXAlignment.Left; box.ZIndex=6; box.Parent=sbg

    local clr=Instance.new("TextButton")
    clr.Size=UDim2.new(0,22,0,22); clr.Position=UDim2.new(1,-26,0.5,-11)
    clr.BackgroundColor3=T.SurfaceLight; clr.BorderSizePixel=0
    clr.Text="✕"; clr.TextColor3=T.TextMuted; clr.TextSize=10
    clr.Font=Enum.Font.GothamBold; clr.AutoButtonColor=false; clr.ZIndex=7
    clr.Visible=false; clr.Parent=sbg
    Instance.new("UICorner",clr).CornerRadius=UDim.new(1,0)

    box.Focused:Connect(function() QT(sbst,0.15,{Color=T.BorderGlow,Transparency=0.2}) end)
    box.FocusLost:Connect(function() QT(sbst,0.15,{Color=T.Border,Transparency=0.5}) end)

    local function doFilter()
        local q = box.Text:lower()
        for plr, card in pairs(cardTable) do
            if card and card.Parent then
                if q=="" then card.Visible=true
                else
                    local match = plr.Name:lower():find(q,1,true) or plr.DisplayName:lower():find(q,1,true)
                    card.Visible = match ~= nil
                end
            end
        end
    end
    box:GetPropertyChangedSignal("Text"):Connect(function()
        clr.Visible = box.Text~=""; doFilter()
    end)
    clr.MouseButton1Click:Connect(function() box.Text=""; clr.Visible=false; doFilter() end)

    return sbg, doFilter
end

-- ╔══════════════════════════════════════════════════╗
-- ║              ТАБ: WATCH                          ║
-- ╚══════════════════════════════════════════════════╝

local WatchTab = AddTab("👁 Watch")
local watchCards = {}

do
    local page = WatchTab._page

    -- Поиск
    WatchTab._order = WatchTab._order+1
    local sbg = Instance.new("Frame"); sbg.Size=UDim2.new(1,0,0,30)
    sbg.BackgroundTransparency=1; sbg.BorderSizePixel=0; sbg.ZIndex=5
    sbg.LayoutOrder=WatchTab._order; sbg.Parent=page
    local _, watchFilter = MakeSearchBar(sbg, watchCards)

    local function addWatchCard(player)
        if watchCards[player] or player==LocalPlayer then return end
        WatchTab._order = WatchTab._order+1
        local card, btn, dot = BuildPlayerCard(page, player, "Watch", 5)
        card.LayoutOrder = WatchTab._order
        watchCards[player] = card

        local function updateState()
            if watchTarget==player then
                btn.Text="Unwatch"; QT(btn,0.15,{BackgroundColor3=Color3.fromRGB(20,60,160)})
                dot.Visible=true; dot.BackgroundColor3=T.Info
            else
                btn.Text="Watch"; QT(btn,0.15,{BackgroundColor3=T.Surface})
                dot.Visible=false
            end
        end

        btn.MouseButton1Click:Connect(function()
            Ripple(btn)
            if watchTarget==player then
                returnCam(); updateState()
                -- сбросим иконку у всех
            else
                -- отменить старый watch
                if watchTarget and watchCards[watchTarget] then
                    local old = watchCards[watchTarget]
                    if old then
                        local ob = old:FindFirstChildOfClass("TextButton")
                        local od; for _,c in ipairs(old:GetChildren()) do
                            if c:IsA("Frame") and c.Size.X.Offset==7 then od=c; break end
                        end
                        if ob then ob.Text="Watch"; QT(ob,0.15,{BackgroundColor3=T.Surface}) end
                        if od then od.Visible=false end
                    end
                end
                local ch=player.Character
                if ch then
                    local hm=ch:FindFirstChildOfClass("Humanoid")
                    if hm then
                        Camera.CameraSubject=hm; Camera.CameraType=Enum.CameraType.Custom
                        watchTarget=player; updateState()
                    end
                end
            end
        end)
        updateState()
        watchFilter()
    end

    local function removeWatchCard(player)
        if watchCards[player] then watchCards[player]:Destroy(); watchCards[player]=nil end
        if watchTarget==player then returnCam() end
    end

    for _,p in ipairs(Players:GetPlayers()) do addWatchCard(p) end
    Players.PlayerAdded:Connect(addWatchCard)
    Players.PlayerRemoving:Connect(removeWatchCard)
end

-- ╔══════════════════════════════════════════════════╗
-- ║              ТАБ: FOLLOW                         ║
-- ╚══════════════════════════════════════════════════╝

local FollowTab = AddTab("🏃 Follow")
local followCards = {}

do
    local page = FollowTab._page
    FollowTab._order = FollowTab._order+1
    local sbg = Instance.new("Frame"); sbg.Size=UDim2.new(1,0,0,30)
    sbg.BackgroundTransparency=1; sbg.BorderSizePixel=0; sbg.ZIndex=5
    sbg.LayoutOrder=FollowTab._order; sbg.Parent=page
    local _, followFilter = MakeSearchBar(sbg, followCards)

    local function addFollowCard(player)
        if followCards[player] or player==LocalPlayer then return end
        FollowTab._order = FollowTab._order+1
        local card, btn, dot = BuildPlayerCard(page, player, "Follow", 5)
        card.LayoutOrder = FollowTab._order
        followCards[player] = card

        local function updateState()
            if followTarget==player then
                btn.Text="Stop"; QT(btn,0.15,{BackgroundColor3=Color3.fromRGB(160,20,20)})
                dot.Visible=true; dot.BackgroundColor3=T.Success
            else
                btn.Text="Follow"; QT(btn,0.15,{BackgroundColor3=T.Surface})
                dot.Visible=false
            end
        end

        btn.MouseButton1Click:Connect(function()
            Ripple(btn)
            if followTarget==player then
                stopFollow(); updateState()
                -- очистить все карточки Follow
                for _, c in pairs(followCards) do
                    local ob=c:FindFirstChildOfClass("TextButton")
                    if ob and ob.Text=="Stop" then ob.Text="Follow"; QT(ob,0.15,{BackgroundColor3=T.Surface}) end
                    for _,ch in ipairs(c:GetChildren()) do
                        if ch:IsA("Frame") and ch.Size.X.Offset==7 then ch.Visible=false; break end
                    end
                end
            else
                -- стоп старый follow
                if followTarget and followCards[followTarget] then
                    local old=followCards[followTarget]
                    if old then
                        local ob=old:FindFirstChildOfClass("TextButton")
                        if ob then ob.Text="Follow"; QT(ob,0.15,{BackgroundColor3=T.Surface}) end
                        for _,c in ipairs(old:GetChildren()) do
                            if c:IsA("Frame") and c.Size.X.Offset==7 then c.Visible=false; break end
                        end
                    end
                end
                stopFollow()
                followTarget = player
                followConn = RunService.RenderStepped:Connect(function()
                    local tc=player.Character; if not tc then return end
                    local tr=tc:FindFirstChild("HumanoidRootPart"); if not tr then return end
                    local mc=LocalPlayer.Character; if not mc then return end
                    local mr=mc:FindFirstChild("HumanoidRootPart")
                    local hm=mc:FindFirstChildOfClass("Humanoid")
                    if mr and hm then hm:MoveTo(tr.Position+(mr.Position-tr.Position).Unit*5) end
                end)
                updateState()
            end
        end)
        updateState()
        followFilter()
    end

    local function removeFollowCard(player)
        if followCards[player] then followCards[player]:Destroy(); followCards[player]=nil end
        if followTarget==player then stopFollow() end
    end

    for _,p in ipairs(Players:GetPlayers()) do addFollowCard(p) end
    Players.PlayerAdded:Connect(addFollowCard)
    Players.PlayerRemoving:Connect(removeFollowCard)
end

-- ╔══════════════════════════════════════════════════╗
-- ║              ТАБ: TELEPORT                       ║
-- ╚══════════════════════════════════════════════════╝

local TpTab = AddTab("⚡ Teleport")
local tpCards = {}

do
    local page = TpTab._page
    TpTab._order = TpTab._order+1
    local sbg = Instance.new("Frame"); sbg.Size=UDim2.new(1,0,0,30)
    sbg.BackgroundTransparency=1; sbg.BorderSizePixel=0; sbg.ZIndex=5
    sbg.LayoutOrder=TpTab._order; sbg.Parent=page
    local _, tpFilter = MakeSearchBar(sbg, tpCards)

    local function addTpCard(player)
        if tpCards[player] or player==LocalPlayer then return end
        TpTab._order = TpTab._order+1
        local card, btn, _ = BuildPlayerCard(page, player, "⚡ TP", 5)
        card.LayoutOrder = TpTab._order
        tpCards[player] = card

        btn.MouseButton1Click:Connect(function()
            Ripple(btn)
            local tc=player.Character; if not tc then return end
            local tr=tc:FindFirstChild("HumanoidRootPart"); if not tr then return end
            local mc=LocalPlayer.Character; if not mc then return end
            local mr=mc:FindFirstChild("HumanoidRootPart"); if not mr then return end
            mr.CFrame = tr.CFrame * CFrame.new(3.5,0,0)
            btn.Text="✔ Done!"; QT(btn,0.1,{BackgroundColor3=Color3.fromRGB(10,130,50)})
            task.delay(1.5,function()
                btn.Text="⚡ TP"; QT(btn,0.15,{BackgroundColor3=T.Surface})
            end)
        end)
        tpFilter()
    end

    local function removeTpCard(player)
        if tpCards[player] then tpCards[player]:Destroy(); tpCards[player]=nil end
    end

    for _,p in ipairs(Players:GetPlayers()) do addTpCard(p) end
    Players.PlayerAdded:Connect(addTpCard)
    Players.PlayerRemoving:Connect(removeTpCard)
end

-- ╔══════════════════════════════════════════════════╗
-- ║              ТАБ: SETTINGS                       ║
-- ╚══════════════════════════════════════════════════╝

local SetTab = AddTab("⚙ Settings")

do
    local page = SetTab._page

    local function SetBtn(label, col, cb)
        SetTab._order = SetTab._order+1
        local c, st = GlassFrame(page, UDim2.new(1,0,0,40), nil, 10, 4)
        c.LayoutOrder = SetTab._order
        if col then c.BackgroundColor3=col; c.BackgroundTransparency=0.25 end

        local btn = Instance.new("TextButton")
        btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1
        btn.Text=label; btn.TextColor3=T.AccentBright; btn.TextSize=12
        btn.Font=Enum.Font.GothamBold; btn.ZIndex=6; btn.Parent=c

        btn.MouseEnter:Connect(function() QT(c,0.15,{BackgroundTransparency=0.1}); QT(st,0.15,{Color=T.BorderGlow,Transparency=0.3}) end)
        btn.MouseLeave:Connect(function() QT(c,0.15,{BackgroundTransparency=col and 0.25 or 0.38}); QT(st,0.15,{Color=T.Border,Transparency=0.55}) end)
        btn.MouseButton1Click:Connect(function() Ripple(c); if cb then cb() end end)
        return c
    end

    SetBtn("📷  Вернуть камеру к себе", Color3.fromRGB(10,30,80), function()
        returnCam()
        -- сбросить визуал Watch
        for _,c in pairs(watchCards) do
            local ob=c:FindFirstChildOfClass("TextButton")
            if ob and ob.Text=="Unwatch" then ob.Text="Watch"; QT(ob,0.15,{BackgroundColor3=T.Surface}) end
            for _,ch in ipairs(c:GetChildren()) do
                if ch:IsA("Frame") and ch.Size.X.Offset==7 then ch.Visible=false; break end
            end
        end
    end)

    SetBtn("⬛  Остановить слежку (Follow)", nil, function()
        if followTarget and followCards[followTarget] then
            local old=followCards[followTarget]
            local ob=old:FindFirstChildOfClass("TextButton")
            if ob then ob.Text="Follow"; QT(ob,0.15,{BackgroundColor3=T.Surface}) end
            for _,ch in ipairs(old:GetChildren()) do
                if ch:IsA("Frame") and ch.Size.X.Offset==7 then ch.Visible=false; break end
            end
        end
        stopFollow()
    end)

    SetTab:Section("Информация")

    SetTab._order = SetTab._order+1
    local infoCard = GlassFrame(page, UDim2.new(1,0,0,54), nil, 10, 4)
    infoCard.LayoutOrder = SetTab._order
    local il = Instance.new("TextLabel")
    il.Size=UDim2.new(1,-16,1,0); il.Position=UDim2.new(0,12,0,0)
    il.BackgroundTransparency=1; il.Text="◈  vertelevse speek  v3.2\nZandarUI Monochrome Glass"
    il.TextColor3=T.TextMuted; il.TextSize=11; il.Font=Enum.Font.Gotham
    il.TextXAlignment=Enum.TextXAlignment.Left; il.ZIndex=5; il.Parent=infoCard

    SetBtn("✕  Закрыть GUI", Color3.fromRGB(80,10,10), function()
        SetOpen(false)
    end)
end

-- ╔══════════════════════════════════════════════════╗
-- ║              УВЕДОМЛЕНИЕ: ДОБРО ПОЖАЛОВАТЬ       ║
-- ╚══════════════════════════════════════════════════╝

task.delay(0.8, function()
    -- Простое toast-уведомление (без внешней зависимости)
    local W = 280
    local holder = ScreenGui:FindFirstChild("NHolder")
    if not holder then
        holder = Instance.new("Frame")
        holder.Name="NHolder"; holder.Size=UDim2.new(0,W,1,0)
        holder.Position=UDim2.new(1,-(W+12),0,0)
        holder.BackgroundTransparency=1; holder.BorderSizePixel=0; holder.ZIndex=100
        holder.Parent=ScreenGui
        local nl=Instance.new("UIListLayout",holder)
        nl.VerticalAlignment=Enum.VerticalAlignment.Bottom
        nl.Padding=UDim.new(0,6); nl.SortOrder=Enum.SortOrder.LayoutOrder
        local np=Instance.new("UIPadding",holder); np.PaddingBottom=UDim.new(0,14)
    end

    local n=Instance.new("Frame")
    n.Size=UDim2.new(1,0,0,64); n.BackgroundColor3=T.Surface
    n.BackgroundTransparency=0.1; n.BorderSizePixel=0; n.ZIndex=101
    n.ClipsDescendants=true; n.Parent=holder
    Instance.new("UICorner",n).CornerRadius=UDim.new(0,12)
    local nst=Instance.new("UIStroke"); nst.Color=T.Border; nst.Transparency=0.4; nst.Thickness=1; nst.Parent=n

    local ac=Instance.new("Frame"); ac.Size=UDim2.new(0,3,0.7,0); ac.Position=UDim2.new(0,0,0.15,0)
    ac.BackgroundColor3=T.Success; ac.BorderSizePixel=0; ac.ZIndex=102; ac.Parent=n
    Instance.new("UICorner",ac).CornerRadius=UDim.new(1,0)

    local t1=Instance.new("TextLabel"); t1.Size=UDim2.new(1,-18,0,20); t1.Position=UDim2.new(0,14,0,8)
    t1.BackgroundTransparency=1; t1.Text="vertelevse speek v3.2"; t1.TextColor3=T.AccentBright
    t1.TextSize=13; t1.Font=Enum.Font.GothamBold; t1.TextXAlignment=Enum.TextXAlignment.Left
    t1.ZIndex=102; t1.Parent=n

    local t2=Instance.new("TextLabel"); t2.Size=UDim2.new(1,-18,0,26); t2.Position=UDim2.new(0,14,0,30)
    t2.BackgroundTransparency=1; t2.Text="Загружено успешно! [RightShift — скрыть]"
    t2.TextColor3=T.TextMuted; t2.TextSize=11; t2.Font=Enum.Font.Gotham
    t2.TextXAlignment=Enum.TextXAlignment.Left; t2.TextWrapped=true
    t2.ZIndex=102; t2.Parent=n

    local prog=Instance.new("Frame"); prog.Size=UDim2.new(1,0,0,2)
    prog.Position=UDim2.new(0,0,1,-2); prog.BackgroundColor3=T.Success
    prog.BorderSizePixel=0; prog.ZIndex=103; prog.Parent=n
    TweenService:Create(prog,TweenInfo.new(4,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,0,2)}):Play()

    n.Position=UDim2.new(1.1,0,0,0)
    ET(n,0.4,{Position=UDim2.new(0,0,0,0)})

    task.delay(4,function()
        QT(n,0.28,{Position=UDim2.new(1.1,0,0,0),BackgroundTransparency=1})
        task.delay(0.32,function() n:Destroy() end)
    end)
end)
