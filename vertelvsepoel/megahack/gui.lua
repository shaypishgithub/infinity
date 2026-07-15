return function(deps)
    local TweenService = deps.TweenService
    local UserInputService = deps.UserInputService
    local CoreGui = deps.CoreGui
    local MarketplaceService = deps.MarketplaceService
    local playerGui = deps.playerGui
    local T = deps.T
    local ThemeColors = deps.ThemeColors
    local Settings = deps.Settings

    local TW = {
        Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        Slow = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        Spring = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    }

    local function Tw(obj, props, info)
        if not obj or not obj.Parent then return nil end
        return TweenService:Create(obj, info or TW.Normal, props)
    end

    local function MkCorner(parent, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 12)
        c.Parent = parent
        return c
    end

    local function MkStroke(parent, thick, color, trans, mode)
        local s = Instance.new("UIStroke")
        s.Thickness = thick or 1; s.Color = color or ThemeColors.StrokeNeon
        s.Transparency = trans or 0.3; s.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border
        s.Parent = parent
        return s
    end

    local function MkNeonGlow(parent, color, size)
        local glow = Instance.new("Frame")
        glow.Name = "NeonGlow"
        glow.Size = UDim2.new(1, size or 8, 1, size or 8)
        glow.Position = UDim2.new(0, -(size or 4), 0, -(size or 4))
        glow.BackgroundColor3 = color or ThemeColors.NeonPrimary
        glow.BackgroundTransparency = 0.75; glow.BorderSizePixel = 0
        glow.ZIndex = parent.ZIndex - 1; glow.Parent = parent.Parent
        MkCorner(glow, 16)
        return glow
    end

    local function MkGlassPanel(parent, size, pos, zIndex, radius, bgTrans)
        local f = Instance.new("Frame")
        f.Name = "GlassPanel"; f.Size = size or UDim2.new(1, 0, 1, 0)
        f.Position = pos or UDim2.new(0, 0, 0, 0)
        f.BackgroundColor3 = ThemeColors.GlassDark; f.BackgroundTransparency = bgTrans or 0.15
        f.BorderSizePixel = 0; f.ZIndex = zIndex or 4; f.Parent = parent
        MkCorner(f, radius or 14); MkStroke(f, 1, ThemeColors.StrokeNeon, 0.5)
        
        local sheen = Instance.new("Frame")
        sheen.Name = "GlassSheen"; sheen.Size = UDim2.new(1, 0, 0.45, 0)
        sheen.BackgroundColor3 = Color3.new(1, 1, 1); sheen.BackgroundTransparency = 0.92
        sheen.BorderSizePixel = 0; sheen.ZIndex = f.ZIndex + 1; sheen.Parent = f
        MkCorner(sheen, radius or 14)
        local grad = Instance.new("UIGradient")
        grad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(0.5, 0.7), NumberSequenceKeypoint.new(1, 1)})
        grad.Rotation = 90; grad.Parent = sheen
        return f
    end

    local function MkNeonText(parent, text, size, pos, fontSize, color, zIndex)
        local lbl = Instance.new("TextLabel")
        lbl.Size = size or UDim2.new(1, 0, 0, 20); lbl.Position = pos or UDim2.new(0, 0, 0, 0)
        lbl.BackgroundTransparency = 1; lbl.Text = text or ""
        lbl.Font = Enum.Font.GothamBold; lbl.TextSize = fontSize or 14
        lbl.TextColor3 = color or ThemeColors.TextBright; lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = zIndex or 6; lbl.Parent = parent
        return lbl
    end

    local function MkNeonButton(parent, text, size, pos, callback, accentColor, zIndex)
        local btn = Instance.new("TextButton")
        btn.Size = size or UDim2.new(0, 100, 0, 32); btn.Position = pos or UDim2.new(0, 0, 0, 0)
        btn.BackgroundColor3 = accentColor or ThemeColors.NeonPrimary; btn.BackgroundTransparency = 0.35
        btn.BorderSizePixel = 0; btn.Text = text or "Button"; btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12; btn.TextColor3 = Color3.new(1, 1, 1); btn.ZIndex = zIndex or 8; btn.Parent = parent
        MkCorner(btn, 8); MkStroke(btn, 1.5, accentColor or ThemeColors.NeonPrimary, 0.2)
        local glow = MkNeonGlow(btn, accentColor or ThemeColors.NeonPrimary, 6)
        btn.MouseEnter:Connect(function() Tw(btn, {BackgroundTransparency = 0.15}, TW.Fast):Play() Tw(glow, {BackgroundTransparency = 0.55}, TW.Fast):Play() end)
        btn.MouseLeave:Connect(function() Tw(btn, {BackgroundTransparency = 0.35}, TW.Fast):Play() Tw(glow, {BackgroundTransparency = 0.75}, TW.Fast):Play() end)
        if callback then btn.MouseButton1Click:Connect(callback) end
        return btn
    end

    local function CreateSectionHeader(text, parent)
        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 28); header.BackgroundTransparency = 1; header.ZIndex = 5; header.Parent = parent
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -12, 0, 20); lbl.Position = UDim2.new(0, 8, 0, 4)
        lbl.BackgroundTransparency = 1; lbl.Text = text:upper(); lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11; lbl.TextColor3 = Settings.colors.accent or ThemeColors.NeonPrimary
        lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 6; lbl.Parent = header
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, -16, 0, 1); line.Position = UDim2.new(0, 8, 1, -2)
        line.BackgroundColor3 = Settings.colors.accent or ThemeColors.NeonPrimary
        line.BackgroundTransparency = 0.6; line.BorderSizePixel = 0; line.ZIndex = 6; line.Parent = header
        MkCorner(line, 1)
        return header
    end

    -- === GUI CONSTRUCTION ===
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MegaHack_v3"; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true; ScreenGui.ResetOnSpawn = false
    pcall(function() if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end end)
    if not ScreenGui.Parent then ScreenGui.Parent = playerGui end

    local Shadow3D = Instance.new("Frame")
    Shadow3D.Name = "Shadow3D"; Shadow3D.Size = UDim2.new(0, 640, 0, 440)
    Shadow3D.Position = UDim2.new(Settings.unlockX, 8, Settings.unlockY, 8)
    Shadow3D.AnchorPoint = Vector2.new(0.5, 0.5); Shadow3D.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Shadow3D.BackgroundTransparency = 0.4; Shadow3D.BorderSizePixel = 0; Shadow3D.ZIndex = 1; Shadow3D.Parent = ScreenGui
    MkCorner(Shadow3D, 18)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"; MainFrame.Size = UDim2.new(0, 630, 0, 430)
    MainFrame.Position = UDim2.new(Settings.unlockX, 0, Settings.unlockY, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.BackgroundColor3 = Settings.colors.bg
    MainFrame.BackgroundTransparency = Settings.transparency; MainFrame.BorderSizePixel = 0
    MainFrame.ZIndex = 2; MainFrame.Parent = ScreenGui
    MkCorner(MainFrame, 16)
    local MainStroke = MkStroke(MainFrame, 1.5, Settings.colors.stroke, 0.4)

    local HeaderBg = Instance.new("Frame")
    HeaderBg.Name = "HeaderBg"; HeaderBg.Size = UDim2.new(1, 0, 0, 56)
    HeaderBg.BackgroundColor3 = ThemeColors.GlassMid; HeaderBg.BackgroundTransparency = 0.2
    HeaderBg.BorderSizePixel = 0; HeaderBg.ZIndex = 5; HeaderBg.Parent = MainFrame
    MkCorner(HeaderBg, 16)
    local HeaderLine = Instance.new("Frame")
    HeaderLine.Size = UDim2.new(1, -24, 0, 1); HeaderLine.Position = UDim2.new(0, 12, 1, -1)
    HeaderLine.BackgroundColor3 = Settings.colors.stroke; HeaderLine.BackgroundTransparency = 0.5
    HeaderLine.BorderSizePixel = 0; HeaderLine.ZIndex = 6; HeaderLine.Parent = HeaderBg

    local LogoGlow = Instance.new("ImageLabel")
    LogoGlow.Size = UDim2.new(0, 28, 0, 28); LogoGlow.Position = UDim2.new(0, 14, 0.5, -14)
    LogoGlow.BackgroundColor3 = Settings.colors.accent; LogoGlow.BackgroundTransparency = 0.5
    LogoGlow.Image = "rbxassetid://7072717762"; LogoGlow.ZIndex = 8; LogoGlow.Parent = HeaderBg
    MkCorner(LogoGlow, 14); local LogoStroke = MkStroke(LogoGlow, 2, Settings.colors.accent, 0.2)

    local VerBadge = Instance.new("Frame")
    VerBadge.Size = UDim2.new(0, 42, 0, 18); VerBadge.Position = UDim2.new(0, 160, 0.5, -9)
    VerBadge.BackgroundColor3 = Settings.colors.accent; VerBadge.BackgroundTransparency = 0.3
    VerBadge.BorderSizePixel = 0; VerBadge.ZIndex = 8; VerBadge.Parent = HeaderBg
    MkCorner(VerBadge, 6)

    local SidebarFrame = Instance.new("Frame")
    SidebarFrame.Size = UDim2.new(0, 155, 1, -64); SidebarFrame.Position = UDim2.new(0, 0, 0, 56)
    SidebarFrame.BackgroundTransparency = 1; SidebarFrame.ZIndex = 4; SidebarFrame.Parent = MainFrame
    local SidebarSep = Instance.new("Frame")
    SidebarSep.Size = UDim2.new(0, 1, 1, -20); SidebarSep.Position = UDim2.new(1, -1, 0, 10)
    SidebarSep.BackgroundColor3 = Settings.colors.stroke; SidebarSep.BackgroundTransparency = 0.6
    SidebarSep.BorderSizePixel = 0; SidebarSep.ZIndex = 5; SidebarSep.Parent = SidebarFrame

    local CatScroll = Instance.new("ScrollingFrame")
    CatScroll.BackgroundTransparency = 1; CatScroll.BorderSizePixel = 0
    CatScroll.Size = UDim2.new(1, -8, 1, -12); CatScroll.Position = UDim2.new(0, 4, 0, 6)
    CatScroll.CanvasSize = UDim2.new(0, 0, 0, 0); CatScroll.ScrollBarThickness = 0
    CatScroll.ZIndex = 6; CatScroll.Parent = SidebarFrame
    local CatLayout = Instance.new("UIListLayout")
    CatLayout.Padding = UDim.new(0, 3); CatLayout.SortOrder = Enum.SortOrder.LayoutOrder; CatLayout.Parent = CatScroll
    local CatPad = Instance.new("UIPadding")
    CatPad.PaddingLeft = UDim.new(0, 4); CatPad.PaddingRight = UDim.new(0, 4)
    CatPad.PaddingTop = UDim.new(0, 4); CatPad.PaddingBottom = UDim.new(0, 4); CatPad.Parent = CatScroll
    CatLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        CatScroll.CanvasSize = UDim2.new(0, 0, 0, CatLayout.AbsoluteContentSize.Y + 12)
    end)

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -163, 1, -68); ContentFrame.Position = UDim2.new(0, 159, 0, 60)
    ContentFrame.BackgroundTransparency = 1; ContentFrame.ZIndex = 4; ContentFrame.Parent = MainFrame

    local ScriptScroll = Instance.new("ScrollingFrame")
    ScriptScroll.BackgroundTransparency = 1; ScriptScroll.BorderSizePixel = 0
    ScriptScroll.Size = UDim2.new(1, 0, 1, 0); ScriptScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScriptScroll.ScrollBarThickness = 3; ScriptScroll.ScrollBarImageColor3 = Settings.colors.accent
    ScriptScroll.ZIndex = 5; ScriptScroll.Parent = ContentFrame
    local ScriptLayout = Instance.new("UIListLayout")
    ScriptLayout.Padding = UDim.new(0, 6); ScriptLayout.SortOrder = Enum.SortOrder.LayoutOrder; ScriptLayout.Parent = ScriptScroll
    local ScriptPad = Instance.new("UIPadding")
    ScriptPad.PaddingLeft = UDim.new(0, 4); ScriptPad.PaddingRight = UDim.new(0, 8)
    ScriptPad.PaddingTop = UDim.new(0, 4); ScriptPad.PaddingBottom = UDim.new(0, 8); ScriptPad.Parent = ScriptScroll
    ScriptLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScriptScroll.CanvasSize = UDim2.new(0, 0, 0, ScriptLayout.AbsoluteContentSize.Y + 16)
    end)

    local GamesPanel = Instance.new("ScrollingFrame")
    GamesPanel.BackgroundTransparency = 1; GamesPanel.BorderSizePixel = 0
    GamesPanel.Size = UDim2.new(1, 0, 1, 0); GamesPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
    GamesPanel.ScrollBarThickness = 3; GamesPanel.ScrollBarImageColor3 = Settings.colors.accent
    GamesPanel.Visible = false; GamesPanel.ZIndex = 5; GamesPanel.Parent = ContentFrame
    local GamesGrid = Instance.new("UIGridLayout")
    GamesGrid.CellSize = UDim2.new(0, 120, 0, 100); GamesGrid.CellPadding = UDim2.new(0, 8, 0, 8)
    GamesGrid.SortOrder = Enum.SortOrder.LayoutOrder; GamesGrid.Parent = GamesPanel
    local GamesPad = Instance.new("UIPadding")
    GamesPad.PaddingLeft = UDim.new(0, 4); GamesPad.PaddingTop = UDim.new(0, 4)
    GamesPad.PaddingRight = UDim.new(0, 4); GamesPad.PaddingBottom = UDim.new(0, 4); GamesPad.Parent = GamesPanel
    GamesGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        GamesPanel.CanvasSize = UDim2.new(0, 0, 0, GamesGrid.AbsoluteContentSize.Y + 12)
    end)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28); CloseBtn.Position = UDim2.new(1, -40, 0.5, -14)
    CloseBtn.BackgroundColor3 = ThemeColors.Error; CloseBtn.BackgroundTransparency = 0.4
    CloseBtn.BorderSizePixel = 0; CloseBtn.Text = "✕"; CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18; CloseBtn.TextColor3 = Color3.new(1, 1, 1); CloseBtn.ZIndex = 10; CloseBtn.Parent = HeaderBg
    MkCorner(CloseBtn, 14); MkStroke(CloseBtn, 1.5, ThemeColors.Error, 0.3)
    local CloseGlow = MkNeonGlow(CloseBtn, ThemeColors.Error, 4)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 28, 0, 28); MinBtn.Position = UDim2.new(1, -72, 0.5, -14)
    MinBtn.BackgroundColor3 = ThemeColors.GlassLight; MinBtn.BackgroundTransparency = 0.3
    MinBtn.BorderSizePixel = 0; MinBtn.Text = "—"; MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 18; MinBtn.TextColor3 = ThemeColors.TextNormal; MinBtn.ZIndex = 10; MinBtn.Parent = HeaderBg
    MkCorner(MinBtn, 14); MkStroke(MinBtn, 1, ThemeColors.StrokeSubtle, 0.5)

    local ReopenBtn = Instance.new("TextButton")
    ReopenBtn.Name = "ReopenBtn"; ReopenBtn.Size = UDim2.new(0, 44, 0, 44)
    ReopenBtn.Position = UDim2.new(0, 16, 0.5, -22)
    ReopenBtn.BackgroundColor3 = Settings.colors.accent; ReopenBtn.BackgroundTransparency = 0.25
    ReopenBtn.BorderSizePixel = 0; ReopenBtn.Text = "MH"; ReopenBtn.Font = Enum.Font.GothamBold
    ReopenBtn.TextSize = 14; ReopenBtn.TextColor3 = Color3.new(1, 1, 1); ReopenBtn.ZIndex = 50; ReopenBtn.Parent = ScreenGui
    MkCorner(ReopenBtn, 22); local ReopenStroke = MkStroke(ReopenBtn, 2, Settings.colors.accent, 0.2)
    local ReopenGlow = MkNeonGlow(ReopenBtn, Settings.colors.accent, 8)

    return {
        ScreenGui = ScreenGui, MainFrame = MainFrame, Shadow3D = Shadow3D, MainStroke = MainStroke,
        HeaderBg = HeaderBg, HeaderLine = HeaderLine, LogoGlow = LogoGlow, LogoStroke = LogoStroke, VerBadge = VerBadge,
        SidebarFrame = SidebarFrame, SidebarSep = SidebarSep, CatScroll = CatScroll, CatLayout = CatLayout,
        ContentFrame = ContentFrame, ScriptScroll = ScriptScroll, ScriptLayout = ScriptLayout,
        GamesPanel = GamesPanel, GamesGrid = GamesGrid,
        CloseBtn = CloseBtn, MinBtn = MinBtn, ReopenBtn = ReopenBtn, ReopenStroke = ReopenStroke, ReopenGlow = ReopenGlow,
        Tw = Tw, TW = TW, MkCorner = MkCorner, MkStroke = MkStroke, MkNeonGlow = MkNeonGlow,
        MkGlassPanel = MkGlassPanel, MkNeonText = MkNeonText, MkNeonButton = MkNeonButton, CreateSectionHeader = CreateSectionHeader
    }
end
