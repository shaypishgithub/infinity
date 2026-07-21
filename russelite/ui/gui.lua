--[[
    RussElite | gui.lua
    Стеклянный чёрный интерфейс (Glass / iPhone 2026 style)
    Белый текст, скруглённые углы, лёгкий блик, плавные анимации.

    Это ModuleScript. Он ничего не создаёт сам —
    его подключает loader.lua и вызывает GUI.new(...)
]]

local TweenService = game:GetService("TweenService")

local GUI = {}
GUI.__index = GUI

----------------------------------------------------------------
-- ЦВЕТОВАЯ ПАЛИТРА / GLASS STYLE
----------------------------------------------------------------
local PALETTE = {
    Glass       = Color3.fromRGB(18, 18, 22),   -- основной "стеклянный" фон
    GlassLight  = Color3.fromRGB(30, 30, 36),   -- вторичные панели
    Stroke      = Color3.fromRGB(255, 255, 255),-- тонкая белая окантовка
    Text        = Color3.fromRGB(255, 255, 255),
    SubText     = Color3.fromRGB(190, 190, 200),
    Accent      = Color3.fromRGB(255, 255, 255),
    Shadow      = Color3.fromRGB(0, 0, 0),
}

local FONT       = Enum.Font.GothamMedium
local FONT_BOLD  = Enum.Font.GothamBold

----------------------------------------------------------------
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
----------------------------------------------------------------

local function corner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function stroke(parent, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = PALETTE.Stroke
    s.Transparency = transparency or 0.85
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

-- Имитация "стекла": полупрозрачный фон + лёгкий градиент-блик сверху
local function glassify(frame, transparency)
    frame.BackgroundColor3 = PALETTE.Glass
    frame.BackgroundTransparency = transparency or 0.25

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255)),
    })
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.00, 0.85),
        NumberSequenceKeypoint.new(0.35, 0.97),
        NumberSequenceKeypoint.new(1.00, 1.00),
    })
    gradient.Rotation = 90
    gradient.Parent = frame

    return frame
end

local function makeLabel(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = props.Font or FONT
    l.Text = props.Text or ""
    l.TextColor3 = props.Color or PALETTE.Text
    l.TextSize = props.Size or 16
    l.TextXAlignment = props.Align or Enum.TextXAlignment.Left
    l.Size = props.SizeUD or UDim2.new(1, 0, 0, 20)
    l.Position = props.Pos or UDim2.new(0, 0, 0, 0)
    l.Name = props.Name or "Label"
    l.Parent = props.Parent
    return l
end

local function makeButton(props)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.BackgroundColor3 = PALETTE.GlassLight
    b.BackgroundTransparency = 0.15
    b.Font = FONT_BOLD
    b.Text = props.Text or ""
    b.TextColor3 = PALETTE.Text
    b.TextSize = props.TextSize or 18
    b.Size = props.Size
    b.Position = props.Pos
    b.AnchorPoint = props.Anchor or Vector2.new(0, 0)
    b.Name = props.Name or "Button"
    b.Parent = props.Parent
    corner(props.Radius or 12, b)
    stroke(b, 0.8)

    -- лёгкий hover/press фидбек, как в iOS
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 0.02}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play()
    end)
    b.MouseButton1Down:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.08), {Size = UDim2.new(props.Size.X.Scale, props.Size.X.Offset - 4, props.Size.Y.Scale, props.Size.Y.Offset - 4)}):Play()
    end)
    b.MouseButton1Up:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.08), {Size = props.Size}):Play()
    end)

    return b
end

----------------------------------------------------------------
-- КОНСТРУКТОР ИНТЕРФЕЙСА
----------------------------------------------------------------
-- parent: куда вставлять (обычно PlayerGui)
function GUI.new(parent)
    local self = setmetatable({}, GUI)
    self._open = false

    ------------------------------------------------------------
    -- ScreenGui
    ------------------------------------------------------------
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RussElite"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = parent
    self.ScreenGui = screenGui

    ------------------------------------------------------------
    -- Плавающая кнопка Открыть/Закрыть (капсула, как iOS Dynamic Island)
    ------------------------------------------------------------
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.new(0, 150, 0, 44)
    toggleBtn.Position = UDim2.new(0.5, 0, 0, 16)
    toggleBtn.AnchorPoint = Vector2.new(0.5, 0)
    toggleBtn.AutoButtonColor = false
    toggleBtn.Font = FONT_BOLD
    toggleBtn.Text = "  ▶  Открыть плеер"
    toggleBtn.TextColor3 = PALETTE.Text
    toggleBtn.TextSize = 15
    toggleBtn.Parent = screenGui
    glassify(toggleBtn, 0.15)
    corner(22, toggleBtn)
    stroke(toggleBtn, 0.75)
    self.ToggleButton = toggleBtn

    ------------------------------------------------------------
    -- Главная панель плеера (стекло)
    ------------------------------------------------------------
    local main = Instance.new("Frame")
    main.Name = "PlayerFrame"
    main.Size = UDim2.new(0, 340, 0, 220)
    main.Position = UDim2.new(0.5, 0, 0, -260) -- спрятана над экраном
    main.AnchorPoint = Vector2.new(0.5, 0)
    main.Visible = true
    main.Parent = screenGui
    glassify(main, 0.2)
    corner(26, main)
    stroke(main, 0.7, 1.2)

    -- лёгкая тень под панелью
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = PALETTE.Shadow
    shadow.ImageTransparency = 0.55
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, 60, 1, 60)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 6)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.ZIndex = main.ZIndex - 1
    shadow.Parent = main

    self.Main = main

    ------------------------------------------------------------
    -- Заголовок
    ------------------------------------------------------------
    makeLabel({
        Parent = main,
        Name = "Title",
        Text = "RussElite Player",
        Font = FONT_BOLD,
        Size = 18,
        SizeUD = UDim2.new(1, -24, 0, 26),
        Pos = UDim2.new(0, 12, 0, 14),
    })

    local songLabel = makeLabel({
        Parent = main,
        Name = "SongName",
        Text = "Ничего не играет",
        Color = PALETTE.SubText,
        Size = 14,
        SizeUD = UDim2.new(1, -24, 0, 18),
        Pos = UDim2.new(0, 12, 0, 44),
    })
    self.SongLabel = songLabel

    ------------------------------------------------------------
    -- Полоса прогресса
    ------------------------------------------------------------
    local barBack = Instance.new("Frame")
    barBack.Name = "ProgressBack"
    barBack.BackgroundColor3 = PALETTE.GlassLight
    barBack.BackgroundTransparency = 0.2
    barBack.Size = UDim2.new(1, -24, 0, 6)
    barBack.Position = UDim2.new(0, 12, 0, 74)
    barBack.Parent = main
    corner(3, barBack)

    local barFill = Instance.new("Frame")
    barFill.Name = "ProgressFill"
    barFill.BackgroundColor3 = PALETTE.Accent
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.Parent = barBack
    corner(3, barFill)
    self.ProgressFill = barFill
    self.ProgressBack = barBack

    ------------------------------------------------------------
    -- Кнопки управления: Prev / Play-Pause / Next
    ------------------------------------------------------------
    local prevBtn = makeButton({
        Parent = main, Name = "PrevButton", Text = "⏮",
        Size = UDim2.new(0, 56, 0, 44),
        Pos = UDim2.new(0.5, -84, 0, 100),
        Anchor = Vector2.new(0.5, 0),
        TextSize = 20, Radius = 14,
    })

    local playBtn = makeButton({
        Parent = main, Name = "PlayButton", Text = "▶",
        Size = UDim2.new(0, 64, 0, 52),
        Pos = UDim2.new(0.5, 0, 0, 96),
        Anchor = Vector2.new(0.5, 0),
        TextSize = 22, Radius = 18,
    })

    local nextBtn = makeButton({
        Parent = main, Name = "NextButton", Text = "⏭",
        Size = UDim2.new(0, 56, 0, 44),
        Pos = UDim2.new(0.5, 84, 0, 100),
        Anchor = Vector2.new(0.5, 0),
        TextSize = 20, Radius = 14,
    })

    self.PrevButton = prevBtn
    self.PlayButton = playBtn
    self.NextButton = nextBtn

    ------------------------------------------------------------
    -- Громкость
    ------------------------------------------------------------
    makeLabel({
        Parent = main, Name = "VolumeLabel", Text = "Громкость",
        Color = PALETTE.SubText, Size = 12,
        SizeUD = UDim2.new(1, -24, 0, 14),
        Pos = UDim2.new(0, 12, 0, 168),
    })

    local volBack = Instance.new("Frame")
    volBack.Name = "VolumeBack"
    volBack.BackgroundColor3 = PALETTE.GlassLight
    volBack.BackgroundTransparency = 0.2
    volBack.Size = UDim2.new(1, -24, 0, 6)
    volBack.Position = UDim2.new(0, 12, 0, 188)
    volBack.Parent = main
    corner(3, volBack)

    local volFill = Instance.new("Frame")
    volFill.Name = "VolumeFill"
    volFill.BackgroundColor3 = PALETTE.Accent
    volFill.Size = UDim2.new(0.5, 0, 1, 0)
    volFill.Parent = volBack
    corner(3, volFill)

    self.VolumeFill = volFill
    self.VolumeBack = volBack

    ------------------------------------------------------------
    -- Открыть/закрыть с анимацией (iOS-подобный slide+fade)
    ------------------------------------------------------------
    function self:Open()
        if self._open then return end
        self._open = true
        self.ToggleButton.Text = "  ✕  Закрыть плеер"
        TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0, 76)
        }):Play()
    end

    function self:Close()
        if not self._open then return end
        self._open = false
        self.ToggleButton.Text = "  ▶  Открыть плеер"
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, 0, -260)
        }):Play()
    end

    function self:Toggle()
        if self._open then
            self:Close()
        else
            self:Open()
        end
    end

    toggleBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    return self
end

return GUI
