-- ================================================================
--   GAZE EMOTES GUI  |  vertelvsepoel  |  B&W Neon Redesign
-- ================================================================

local _1=setmetatable({},{__index=function(_,k)local c=workspace.CurrentCamera local s=c and c.ViewportSize or Vector2.new(1920,1080)if k=="Width"then return s.X elseif k=="Height"then return s.Y elseif k=="Size"then return s end end})
local _2=game:GetService("UserInputService")
local _3=workspace.CurrentCamera.ViewportSize
local function _4(_a,_b)local _c=_2.TouchEnabled and not _2.KeyboardEnabled local _d,_e=1920,1080 local _f=_c and 2 or 1.5 if _a=="X"then return _b*(_3.X/_d)*_f elseif _a=="Y"then return _b*(_3.Y/_e)*_f end end
local function _5(_a,_b,_c)if type(_b)==_a then return _b end return _c end
local _6=_5("function",cloneref,function(...)return ... end)
local _7=setmetatable({},{__index=function(_,_a)return _6(game:GetService(_a))end})
local _8=_7.Players local _9=_7.RunService local _10=_7.UserInputService local _11=_7.TweenService local _12=_7.AvatarEditorService local _13=_7.HttpService
local _14=_8.LocalPlayer local _15=_14.Character or _14.CharacterAdded:Wait()local _16=_15:WaitForChild("Humanoid")local _isR6=_16.RigType==Enum.HumanoidRigType.R6 local _17=_15.PrimaryPart and _15.PrimaryPart.Position or Vector3.new()
local _35_Ref, _36_Ref, _37_Ref, _39_Ref, _43_Ref;

-- ================================================================
--  THEME: Black/White Neon  (vertelvsepoel)
-- ================================================================
local T = {
    BG_DEEP    = Color3.fromRGB(4,   4,   6),    -- almost black
    BG_PANEL   = Color3.fromRGB(9,   9,   12),
    BG_CARD    = Color3.fromRGB(14,  14,  18),
    BG_ELEM    = Color3.fromRGB(20,  20,  26),
    BG_HOVER   = Color3.fromRGB(30,  30,  38),

    NEON_WHITE = Color3.fromRGB(255, 255, 255),
    NEON_LGRAY = Color3.fromRGB(200, 200, 210),
    NEON_MGRAY = Color3.fromRGB(130, 130, 145),
    NEON_DGRAY = Color3.fromRGB(60,  60,  72),

    ACCENT_HI  = Color3.fromRGB(240, 240, 255),  -- near-white accent
    ACCENT_MID = Color3.fromRGB(160, 160, 180),
    ACCENT_DIM = Color3.fromRGB(80,  80,  100),

    STROKE_A   = Color3.fromRGB(255, 255, 255),
    STROKE_B   = Color3.fromRGB(90,  90,  110),

    TEXT_PRI   = Color3.fromRGB(240, 240, 248),
    TEXT_SEC   = Color3.fromRGB(160, 160, 175),
    TEXT_DIM   = Color3.fromRGB(80,  80,  95),

    PLAY_CLR   = Color3.fromRGB(220, 220, 235),
    SAVE_CLR   = Color3.fromRGB(50,  50,  65),
    REM_CLR    = Color3.fromRGB(40,  40,  50),
}

-- ================================================================
--  HELPERS
-- ================================================================
local function mkCorner(p, r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 6) c.Parent=p return c end
local function mkStroke(p, col, th) local s=Instance.new("UIStroke") s.Color=col or T.STROKE_B s.Thickness=th or 1 s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=p return s end
local function mkGrad(p, seq) local g=Instance.new("UIGradient") g.Color=seq g.Rotation=90 g.Parent=p return g end
local function popAnim(inst) local sc=Instance.new("UIScale") sc.Scale=0.88 sc.Parent=inst _11:Create(sc,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play() end

-- Animated neon stroke gradient (cycles black→gray→white→gray→black)
local function animStroke(frame, period)
    period = period or 3
    local stroke = mkStroke(frame, T.NEON_WHITE, 1.5)
    local hue = 0
    local conn
    conn = _9.RenderStepped:Connect(function(dt)
        if not frame or not frame.Parent then conn:Disconnect() return end
        hue = (hue + dt/period) % 1
        -- oscillate: 0→1→0 gives dim→bright→dim
        local v = math.abs(math.sin(hue * math.pi * 2))
        local bri = 55 + math.floor(v * 200)
        stroke.Color = Color3.fromRGB(bri, bri, bri + 15)
        stroke.Thickness = 1 + v * 0.8
    end)
    return stroke, conn
end

-- Gradient shimmer label (cycles white sheen across text)
local function shimmerLabel(lbl, period)
    period = period or 2.5
    local t = 0
    local conn
    conn = _9.RenderStepped:Connect(function(dt)
        if not lbl or not lbl.Parent then conn:Disconnect() return end
        t = (t + dt/period) % 1
        local v = 0.5 + 0.5 * math.sin(t * math.pi * 2)
        local r = math.floor(160 + v * 95)
        local g = math.floor(160 + v * 95)
        local b = math.floor(175 + v * 80)
        lbl.TextColor3 = Color3.fromRGB(r, g, b)
    end)
    return conn
end

-- ================================================================
--  DATA / SETTINGS
-- ================================================================
_14.CharacterAdded:Connect(function(_a)
    _15=_a _16=_a:WaitForChild("Humanoid")_isR6=_16.RigType==Enum.HumanoidRigType.R6
    if _35_Ref then _35_Ref.Text=_isR6 and "GAZE EMOTES  ·  vertelvsepoel" or "Gaze Emotes  ·  vertelvsepoel" end
    if _36_Ref then _36_Ref.Text=_isR6 and "Anim" or "Catalog" end
    if _37_Ref then _37_Ref.Visible=not _isR6 end
    if _isR6 and _39_Ref and _43_Ref then
        _39_Ref.Visible=true _43_Ref.Visible=false
    end
    _17=_15.PrimaryPart and _15.PrimaryPart.Position or Vector3.new()
end)

local _18={} _18["Stop Emote When Moving"]=true _18["Fade In"]=0.1 _18["Fade Out"]=0.1 _18["Weight"]=1
_18["Speed"]=1 _18["Time Position"]=0 _18["Freeze On Finish"]=false _18["Looped"]=true
_18["Stop Other Animations On Play"]=true _18["High Priority"]=true
local _19={} local _20="GazeEmotes_NewNEWN3WSaved.json"

local function _21()local _a,_b=pcall(function()if readfile and isfile and isfile(_20)then return _13:JSONDecode(readfile(_20))end return{}end)if _a and type(_b)=="table"then _19=_b else _19={}end for _c,_d in ipairs(_19)do if not _d.AnimationId then if _d.AssetId then _d.AnimationId="rbxassetid://"..tostring(_d.AssetId)else _d.AnimationId="rbxassetid://"..tostring(_d.Id)end end if _d.Favorite==nil then _d.Favorite=false end end end
local function _22()pcall(function()if writefile then writefile(_20,_13:JSONEncode(_19))end end)end
_21()

local _23=nil
local function _24(_a)
    if _23 then _23:Stop(_18["Fade Out"]) end
    local _b
    local _c,_d=pcall(function()return game:GetObjects("rbxassetid://"..tostring(_a))end)
    if _c and _d and #_d>0 then local _e=_d[1]if _e:IsA("Animation")then _b=_e.AnimationId else _b="rbxassetid://"..tostring(_a)end else _b="rbxassetid://"..tostring(_a)end
    local _e=Instance.new("Animation")_e.AnimationId=_b
    local _f=_16:LoadAnimation(_e)
    local _g=_18["High Priority"]and Enum.AnimationPriority.Action4 or Enum.AnimationPriority.Action
    _f.Priority=_g
    local _h=_18["Weight"]if _h==0 then _h=0.001 end
    if _18["Stop Other Animations On Play"]then for _i,_j in pairs(_16.Animator:GetPlayingAnimationTracks())do if _j.Priority~=_g then _j:Stop()end end end
    _f:Play(_18["Fade In"],_h,_18["Speed"])_23=_f
    _23.TimePosition=math.clamp(_18["Time Position"],0,1)*(_23.Length or 1)
    _23.Priority=_g _23.Looped=_18["Looped"]
    return _f
end

_9.RenderStepped:Connect(function()
    if _18["Looped"]and _23 and _23.IsPlaying then _23.Looped=_18["Looped"]end
    if _15:FindFirstChild("HumanoidRootPart")then
        local _a=_15.HumanoidRootPart
        if _18["Stop Emote When Moving"]and _23 and _23.IsPlaying then
            local _b=(_a.Position-_17).Magnitude>0.1
            local _c=_16 and _16:GetState()==Enum.HumanoidStateType.Jumping
            if _b or _c then _23:Stop(_18["Fade Out"])_23=nil end
        end
        _17=_a.Position
    end
end)

-- ================================================================
--  SCREEN GUI
-- ================================================================
local _25=_7.CoreGui
local _26=Instance.new("ScreenGui")
_26.Name="GazeEmoteGUI_vtp"
_26.Parent=_25
_26.Enabled=false
_26.DisplayOrder=999

-- ----------------------------------------------------------------
--  MAIN WINDOW
-- ----------------------------------------------------------------
local _30=Instance.new("Frame")
_30.Size=UDim2.new(0,_4("X",500),0,_4("Y",470))
_30.Position=UDim2.new(0.5,-_4("X",340),0.5,-_4("Y",235))
_30.BackgroundColor3=T.BG_DEEP
_30.BackgroundTransparency=0.04
_30.Active=true
_30.Draggable=true
_30.Parent=_26
mkCorner(_30, 12)
animStroke(_30, 4)

-- subtle inner gradient
mkGrad(_30, ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(18,18,24)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8,8,11)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(14,14,20)),
}))

-- ----------------------------------------------------------------
--  HEADER BAR  "vertelvsepoel"
-- ----------------------------------------------------------------
local header = Instance.new("Frame")
header.Size=UDim2.new(1,0,0,_4("Y",48))
header.BackgroundColor3=T.BG_PANEL
header.BackgroundTransparency=0.3
header.Parent=_30
mkCorner(header,12)

-- header gradient
mkGrad(header, ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(22,22,30)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(10,10,14)),
}))
mkStroke(header, T.NEON_DGRAY, 0.5)

-- brand label
local brandLbl = Instance.new("TextLabel")
brandLbl.Size=UDim2.new(0.5,0,1,0)
brandLbl.Position=UDim2.new(0,_4("X",14),0,0)
brandLbl.BackgroundTransparency=1
brandLbl.Text="vertelvsepoel"
brandLbl.TextColor3=T.NEON_WHITE
brandLbl.Font=Enum.Font.GothamBold
brandLbl.TextScaled=true
brandLbl.TextXAlignment=Enum.TextXAlignment.Left
brandLbl.Parent=header
shimmerLabel(brandLbl, 2.8)

-- title label
local _35=Instance.new("TextLabel")
_35_Ref=_35
_35.Size=UDim2.new(0.5,-_4("X",14),1,0)
_35.Position=UDim2.new(0.5,0,0,0)
_35.BackgroundTransparency=1
_35.Text=_isR6 and "GAZE EMOTES" or "Gaze Emotes"
_35.TextColor3=T.TEXT_SEC
_35.Font=Enum.Font.GothamBold
_35.TextScaled=true
_35.TextXAlignment=Enum.TextXAlignment.Right
_35.Parent=header

-- decorative line under header
local hLine=Instance.new("Frame")
hLine.Size=UDim2.new(1,0,0,1)
hLine.Position=UDim2.new(0,0,0,_4("Y",48))
hLine.BackgroundColor3=T.NEON_WHITE
hLine.BackgroundTransparency=0.6
hLine.Parent=_30
mkGrad(hLine, ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,0,0)),
}))

-- ----------------------------------------------------------------
--  RESIZE HANDLE
-- ----------------------------------------------------------------
local _31=Instance.new("TextButton")
_31.Size=UDim2.new(0,22,0,22)
_31.Position=UDim2.new(1,-22,1,-22)
_31.BackgroundTransparency=1
_31.Text="◢"
_31.TextColor3=T.NEON_DGRAY
_31.TextSize=16
_31.ZIndex=10
_31.Parent=_30

local _32=false local _33 local _34
_31.InputBegan:Connect(function(_a)if _a.UserInputType==Enum.UserInputType.MouseButton1 or _a.UserInputType==Enum.UserInputType.Touch then _32=true _33=_a.Position _34=_30.AbsoluteSize end end)
_10.InputChanged:Connect(function(_a)if _32 and(_a.UserInputType==Enum.UserInputType.MouseMovement or _a.UserInputType==Enum.UserInputType.Touch)then local _b=_a.Position-_33 local _c=math.max(150,_34.X+_b.X)local _d=math.max(100,_34.Y+_b.Y)_30.Size=UDim2.new(0,_c,0,_d)end end)
_10.InputEnded:Connect(function(_a)if _a.UserInputType==Enum.UserInputType.MouseButton1 or _a.UserInputType==Enum.UserInputType.Touch then _32=false end end)

-- ----------------------------------------------------------------
--  TAB BUTTONS
-- ----------------------------------------------------------------
local tabBar=Instance.new("Frame")
tabBar.Size=UDim2.new(1,-_4("X",20),0,_4("Y",32))
tabBar.Position=UDim2.new(0,_4("X",10),0,_4("Y",54))
tabBar.BackgroundTransparency=1
tabBar.Parent=_30

local function mkTab(txt, xoff, w, active)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(w,0,1,0)
    btn.Position=UDim2.new(xoff,0,0,0)
    btn.BackgroundColor3=active and T.BG_ELEM or T.BG_CARD
    btn.BackgroundTransparency=0.1
    btn.Text=txt
    btn.TextColor3=active and T.NEON_WHITE or T.TEXT_SEC
    btn.Font=Enum.Font.GothamBold
    btn.TextScaled=true
    btn.Parent=tabBar
    mkCorner(btn,6)
    local st=mkStroke(btn, active and T.NEON_MGRAY or T.NEON_DGRAY, active and 1.2 or 0.7)
    return btn, st
end

local _36, _36Stroke = mkTab(_isR6 and "Animation" or "Catalog", 0, 0.32, true)
_36_Ref=_36
local _37, _37Stroke = mkTab("Saved", 0.34, 0.32, false)
_37_Ref=_37
_37.Visible=not _isR6

-- ----------------------------------------------------------------
--  DIVIDER (vertical)
-- ----------------------------------------------------------------
local _38=Instance.new("Frame")
_38.Size=UDim2.new(0,1,1,-_4("Y",96))
_38.Position=UDim2.new(0.62,0,0,_4("Y",96))
_38.BackgroundColor3=T.NEON_WHITE
_38.BackgroundTransparency=0.75
_38.Parent=_30
mkGrad(_38, ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,0,0)),
}))

-- ================================================================
--  CATALOG PANEL  (_39)
-- ================================================================
local _39=Instance.new("Frame")
_39_Ref=_39
_39.Size=UDim2.new(0.62,-_4("X",14),1,-_4("Y",96))
_39.Position=UDim2.new(0,_4("X",7),0,_4("Y",94))
_39.BackgroundTransparency=1
_39.Visible=true
_39.Parent=_30

-- Search box
local _40=Instance.new("TextBox")
_40.Size=UDim2.new(0.55,-_4("X",6),0,_4("Y",28))
_40.Position=UDim2.new(0,_4("X",4),0,0)
_40.PlaceholderText="  Search emotes..."
_40.BackgroundColor3=T.BG_ELEM
_40.BackgroundTransparency=0.2
_40.TextColor3=T.TEXT_PRI
_40.PlaceholderColor3=T.TEXT_DIM
_40.Font=Enum.Font.Gotham
_40.TextScaled=true
_40.ClearTextOnFocus=false
_40.Text=""
_40.Parent=_39
mkCorner(_40,6)
mkStroke(_40, T.NEON_DGRAY, 0.8)

local _41=Instance.new("TextButton")
_41.Size=UDim2.new(0.22,-_4("X",4),0,_4("Y",28))
_41.Position=UDim2.new(0.55,_4("X",4),0,0)
_41.BackgroundColor3=T.BG_ELEM
_41.BackgroundTransparency=0.1
_41.Text="↺ Refresh"
_41.Font=Enum.Font.GothamBold
_41.TextScaled=true
_41.TextColor3=T.NEON_LGRAY
_41.Parent=_39
mkCorner(_41,6)
mkStroke(_41, T.NEON_DGRAY, 0.8)

local _42=Instance.new("TextButton")
_42.Size=UDim2.new(0.23,-_4("X",4),0,_4("Y",28))
_42.Position=UDim2.new(0.77,_4("X",4),0,0)
_42.BackgroundColor3=T.BG_ELEM
_42.BackgroundTransparency=0.1
_42.Text="⇅ Sort"
_42.Font=Enum.Font.GothamBold
_42.TextScaled=true
_42.TextColor3=T.TEXT_SEC
_42.Parent=_39
mkCorner(_42,6)
mkStroke(_42, T.NEON_DGRAY, 0.8)

-- Scroll frame
local _64=Instance.new("ScrollingFrame")
_64.Size=UDim2.new(1,-_4("X",4),1,-_4("Y",76))
_64.Position=UDim2.new(0,_4("X",2),0,_4("Y",34))
_64.CanvasSize=UDim2.new(0,0,0,0)
_64.ScrollBarThickness=3
_64.ScrollBarImageColor3=T.NEON_MGRAY
_64.BackgroundTransparency=1
_64.Parent=_39

local _65=Instance.new("UIGridLayout",_64)
_65.CellSize=UDim2.new(0,_4("X",108),0,_4("Y",170))
_65.CellPadding=UDim2.new(0,_4("X",6),0,_4("Y",6))

local _66=Instance.new("TextLabel",_64)
_66.Size=UDim2.new(1,0,0,_4("Y",36))
_66.Position=UDim2.new(0,0,0.5,-_4("Y",18))
_66.BackgroundTransparency=1
_66.Text="— nothing here —"
_66.TextColor3=T.TEXT_DIM
_66.Font=Enum.Font.GothamBold
_66.TextScaled=true
_66.Visible=false

-- Pagination
local _67=Instance.new("TextButton",_39)
_67.Size=UDim2.new(0.38,-_4("X",4),0,_4("Y",28))
_67.Position=UDim2.new(0,_4("X",2),1,-_4("Y",32))
_67.BackgroundColor3=T.BG_ELEM
_67.BackgroundTransparency=0.2
_67.Text="← Prev"
_67.Font=Enum.Font.GothamBold
_67.TextScaled=true
_67.TextColor3=T.TEXT_SEC
mkCorner(_67,6)
mkStroke(_67, T.NEON_DGRAY, 0.7)

local _68=Instance.new("TextButton",_39)
_68.Size=UDim2.new(0.38,-_4("X",4),0,_4("Y",28))
_68.Position=UDim2.new(0.62,_4("X",2),1,-_4("Y",32))
_68.BackgroundColor3=T.BG_ELEM
_68.BackgroundTransparency=0.2
_68.Text="Next →"
_68.Font=Enum.Font.GothamBold
_68.TextScaled=true
_68.TextColor3=T.TEXT_SEC
mkCorner(_68,6)
mkStroke(_68, T.NEON_DGRAY, 0.7)

local _69=Instance.new("TextBox",_39)
_69.Size=UDim2.new(0.24,0,0,_4("Y",28))
_69.Position=UDim2.new(0.38,_4("X",2),1,-_4("Y",32))
_69.BackgroundColor3=T.BG_CARD
_69.BackgroundTransparency=0.3
_69.Font=Enum.Font.Gotham
_69.TextScaled=true
_69.TextColor3=T.NEON_LGRAY
_69.Text="1"
mkCorner(_69,6)
mkStroke(_69, T.NEON_DGRAY, 0.5)

local _70=Instance.new("TextLabel",_39)
_70.Size=UDim2.new(1,0,0,_4("Y",20))
_70.Position=UDim2.new(0,0,1,-_4("Y",56))
_70.BackgroundTransparency=1
_70.TextColor3=Color3.fromRGB(255,80,80)
_70.Font=Enum.Font.Gotham
_70.TextScaled=true
_70.Text=""
_70.Visible=false

-- ================================================================
--  SAVED PANEL  (_43)
-- ================================================================
local _43=Instance.new("Frame")
_43_Ref=_43
_43.Size=UDim2.new(0.62,-_4("X",14),1,-_4("Y",96))
_43.Position=UDim2.new(0,_4("X",7),0,_4("Y",94))
_43.BackgroundTransparency=1
_43.Visible=false
_43.Parent=_30

local _44=Instance.new("TextBox")
_44.Size=UDim2.new(0.55,-_4("X",6),0,_4("Y",28))
_44.Position=UDim2.new(0,_4("X",4),0,0)
_44.PlaceholderText="  Search saved..."
_44.BackgroundColor3=T.BG_ELEM
_44.BackgroundTransparency=0.2
_44.TextColor3=T.TEXT_PRI
_44.PlaceholderColor3=T.TEXT_DIM
_44.Font=Enum.Font.Gotham
_44.TextScaled=true
_44.ClearTextOnFocus=false
_44.Text=""
_44.Parent=_43
mkCorner(_44,6)
mkStroke(_44, T.NEON_DGRAY, 0.8)

local _44a=Instance.new("TextBox")
_44a.Size=UDim2.new(0.3,0,0,_4("Y",28))
_44a.Position=UDim2.new(0.57,-_4("X",4),0,0)
_44a.PlaceholderText="  Emote ID"
_44a.BackgroundColor3=T.BG_ELEM
_44a.BackgroundTransparency=0.2
_44a.TextColor3=T.TEXT_PRI
_44a.PlaceholderColor3=T.TEXT_DIM
_44a.Font=Enum.Font.Gotham
_44a.TextScaled=true
_44a.ClearTextOnFocus=false
_44a.Text=""
_44a.Parent=_43
mkCorner(_44a,6)
mkStroke(_44a, T.NEON_DGRAY, 0.8)

local _44b=Instance.new("TextButton")
_44b.Size=UDim2.new(0.12,0,0,_4("Y",28))
_44b.Position=UDim2.new(0.88,_4("X",2),0,0)
_44b.BackgroundColor3=T.BG_ELEM
_44b.BackgroundTransparency=0.1
_44b.Text="+"
_44b.Font=Enum.Font.GothamBold
_44b.TextScaled=true
_44b.TextColor3=T.NEON_WHITE
_44b.Parent=_43
mkCorner(_44b,6)
mkStroke(_44b, T.NEON_MGRAY, 1)

local _45=Instance.new("ScrollingFrame")
_45.Size=UDim2.new(1,-_4("X",4),1,-_4("Y",40))
_45.Position=UDim2.new(0,_4("X",2),0,_4("Y",34))
_45.CanvasSize=UDim2.new(0,0,0,0)
_45.ScrollBarThickness=3
_45.ScrollBarImageColor3=T.NEON_MGRAY
_45.BackgroundTransparency=1
_45.Parent=_43

local _46=Instance.new("TextLabel")
_46.Size=UDim2.new(1,0,0,_4("Y",36))
_46.Position=UDim2.new(0,0,0.5,-_4("Y",18))
_46.BackgroundTransparency=1
_46.Text="No saved emotes yet"
_46.TextColor3=T.TEXT_DIM
_46.Font=Enum.Font.GothamBold
_46.TextScaled=true
_46.Visible=false
_46.Parent=_45

local _47=Instance.new("UIGridLayout")
_47.CellSize=UDim2.new(0,_4("X",108),0,_4("Y",185))
_47.CellPadding=UDim2.new(0,_4("X",6),0,_4("Y",6))
_47.HorizontalAlignment=Enum.HorizontalAlignment.Center
_47.Parent=_45

-- ================================================================
--  SETTINGS PANEL (right side)
-- ================================================================
local _48=Instance.new("Frame")
_48.Size=UDim2.new(0.38,-_4("X",12),1,-_4("Y",96))
_48.Position=UDim2.new(0.62,_4("X",6),0,_4("Y",94))
_48.BackgroundTransparency=1
_48.Parent=_30

local settingsTitle=Instance.new("TextLabel")
settingsTitle.Size=UDim2.new(1,0,0,_4("Y",22))
settingsTitle.BackgroundTransparency=1
settingsTitle.Text="Settings"
settingsTitle.TextColor3=T.TEXT_DIM
settingsTitle.Font=Enum.Font.GothamBold
settingsTitle.TextScaled=true
settingsTitle.Parent=_48

local _50=Instance.new("ScrollingFrame")
_50.Size=UDim2.new(1,0,1,-_4("Y",28))
_50.Position=UDim2.new(0,0,0,_4("Y",24))
_50.BackgroundTransparency=1
_50.CanvasSize=UDim2.new(0,0,0,0)
_50.ScrollBarThickness=3
_50.ScrollBarImageColor3=T.NEON_DGRAY
_50.Parent=_48

local function _51()_50.CanvasPosition=Vector2.new(0,_50.CanvasPosition.Y)end
_50:GetPropertyChangedSignal("CanvasPosition"):Connect(_51)

local _52=Instance.new("UIListLayout",_50)
_52.Padding=UDim.new(0,5)
_52.FillDirection=Enum.FillDirection.Vertical
_52.SortOrder=Enum.SortOrder.LayoutOrder
_52:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()_50.CanvasSize=UDim2.new(0,0,0,_52.AbsoluteContentSize.Y+10)end)

-- ================================================================
--  GetReal helper
-- ================================================================
function GetReal(_a)
    local _b,_c=pcall(function()return game:GetObjects("rbxassetid://"..tostring(_a))end)
    if _b and _c and #_c>0 then local _d=_c[1]
        if _d:IsA("Animation")and _d.AnimationId~=""then return tonumber(_d.AnimationId:match("%d+"))
        elseif _d:FindFirstChildOfClass("Animation")then local _e=_d:FindFirstChildOfClass("Animation")return tonumber(_e.AnimationId:match("%d+"))end
    end
end

local _80
_44b.MouseButton1Click:Connect(function()
    local _a=tonumber(_44a.Text)
    if _a then local _b=false for _c,_d in ipairs(_19)do if _d.Id==_a then _b=true break end end
        if not _b then local _e=GetReal(_a)
            table.insert(_19,{Id=_a,AssetId=_a,Name="Custom: ".._a,AnimationId="rbxassetid://"..tostring(_e or _a),Favorite=false})
            _22()_80()
        end
    end
end)

-- ================================================================
--  SETTINGS WIDGETS
-- ================================================================
_18._sliders={} _18._toggles={}

local function _53(_a,_b,_c,_d)
    _18[_a]=_d or _b
    local cont=Instance.new("Frame")
    cont.Size=UDim2.new(1,0,0,_4("Y",58))
    cont.BackgroundColor3=T.BG_CARD
    cont.BackgroundTransparency=0.2
    cont.Parent=_50
    mkCorner(cont,6)
    mkStroke(cont, T.NEON_DGRAY, 0.6)

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-_4("X",8),0,_4("Y",16))
    lbl.Position=UDim2.new(0,_4("X",6),0,_4("Y",4))
    lbl.BackgroundTransparency=1
    lbl.Text=string.format("%s: %.2f",_a,_18[_a])
    lbl.TextColor3=T.TEXT_SEC
    lbl.Font=Enum.Font.Gotham
    lbl.TextScaled=true
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Parent=cont

    local tb=Instance.new("TextBox")
    tb.Size=UDim2.new(0.35,0,0,_4("Y",16))
    tb.Position=UDim2.new(0.65,0,0,_4("Y",4))
    tb.BackgroundColor3=T.BG_ELEM
    tb.BackgroundTransparency=0.1
    tb.Text=tostring(_18[_a])
    tb.TextColor3=T.NEON_WHITE
    tb.Font=Enum.Font.Gotham
    tb.TextScaled=true
    tb.ClearTextOnFocus=false
    tb.Parent=cont
    mkCorner(tb,4)

    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,-_4("X",12),0,_4("Y",8))
    track.Position=UDim2.new(0,_4("X",6),0,_4("Y",28))
    track.BackgroundColor3=T.BG_ELEM
    track.Parent=cont
    mkCorner(track,4)

    local fill=Instance.new("Frame")
    fill.Size=UDim2.new(0,0,1,0)
    fill.BackgroundColor3=T.NEON_WHITE
    fill.Parent=track
    mkCorner(fill,4)
    mkGrad(fill, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60,60,80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
    }))

    local thumb=Instance.new("Frame")
    thumb.Size=UDim2.new(0,_4("X",14),0,_4("Y",14))
    thumb.AnchorPoint=Vector2.new(0.5,0.5)
    thumb.Position=UDim2.new(0,0,0.5,0)
    thumb.BackgroundColor3=T.NEON_WHITE
    thumb.Parent=track
    mkCorner(thumb,10)
    mkStroke(thumb, T.BG_DEEP, 1.5)

    local function setFrac(n) local f=math.clamp(n,0,1)
        _11:Create(fill,TweenInfo.new(0.12),{Size=UDim2.new(f,0,1,0)}):Play()
        _11:Create(thumb,TweenInfo.new(0.12),{Position=UDim2.new(f,0,0.5,0)}):Play()
    end
    local function setVal(v) _18[_a]=math.clamp(v,_b,_c)
        lbl.Text=string.format("%s: %.2f",_a,_18[_a])
        tb.Text=tostring(_18[_a])
        setFrac((_18[_a]-_b)/(_c-_b))
        if _23 and _23.IsPlaying then
            if _a=="Speed"then _23:AdjustSpeed(_18["Speed"])
            elseif _a=="Weight"then local r=_18["Weight"]if r==0 then r=0.001 end _23:AdjustWeight(r)
            elseif _a=="Time Position"then if _23.Length>0 then _23.TimePosition=math.clamp(v,0,1)*_23.Length end end
        end
    end
    local drag=false
    local function fromInput(inp)
        local f=math.clamp((inp.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        setVal(math.floor((_b+(_c-_b)*f)*100)/100)
    end
    track.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true fromInput(i)end end)
    thumb.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true fromInput(i)end end)
    _10.InputChanged:Connect(function(i)if drag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then fromInput(i)end end)
    _10.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
    tb.FocusLost:Connect(function(enter)if enter then local n=tonumber(tb.Text)if n then setVal(n)else tb.Text=tostring(_18[_a])end end end)
    _18._sliders[_a]=setVal
    setVal(_18[_a])
end

local function _54(_a)
    _18[_a]=_18[_a] or false
    local cont=Instance.new("Frame")
    cont.Size=UDim2.new(1,0,0,_4("Y",36))
    cont.BackgroundColor3=T.BG_CARD
    cont.BackgroundTransparency=0.2
    cont.Parent=_50
    mkCorner(cont,6)
    mkStroke(cont, T.NEON_DGRAY, 0.6)

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-_4("X",56),1,0)
    lbl.Position=UDim2.new(0,_4("X",8),0,0)
    lbl.BackgroundTransparency=1
    lbl.Text=_a
    lbl.TextColor3=T.TEXT_SEC
    lbl.Font=Enum.Font.Gotham
    lbl.TextScaled=true
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Parent=cont

    local tog=Instance.new("TextButton")
    tog.Size=UDim2.new(0,_4("X",44),0,_4("Y",20))
    tog.Position=UDim2.new(1,-_4("X",50),0.5,-_4("Y",10))
    tog.TextColor3=T.NEON_WHITE
    tog.Font=Enum.Font.GothamBold
    tog.TextScaled=true
    tog.Parent=cont
    mkCorner(tog,4)

    local function setT(v)
        tog.Text=v and "ON" or "OFF"
        tog.BackgroundColor3=v and Color3.fromRGB(50,50,65) or Color3.fromRGB(30,30,38)
        local str=mkStroke(tog, v and T.NEON_LGRAY or T.NEON_DGRAY, v and 1 or 0.6)
    end
    tog.MouseButton1Click:Connect(function()_18[_a]=not _18[_a]setT(_18[_a])end)
    setT(_18[_a])
    _18._toggles[_a]=setT
end

function _18:EditSlider(_a,_b)local f=self._sliders[_a]if f then f(_b)end end
function _18:EditToggle(_a,_b)local f=self._toggles[_a]if f then _18[_a]=_b f(_b)end end

local function _55(_a,_b)
    local cont=Instance.new("Frame")
    cont.Size=UDim2.new(1,0,0,_4("Y",36))
    cont.BackgroundTransparency=1
    cont.Parent=_50

    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,1,0)
    btn.BackgroundColor3=T.BG_ELEM
    btn.BackgroundTransparency=0.1
    btn.Text=_a
    btn.TextColor3=T.TEXT_SEC
    btn.Font=Enum.Font.GothamBold
    btn.TextScaled=true
    btn.Parent=cont
    mkCorner(btn,6)
    mkStroke(btn, T.NEON_DGRAY, 0.7)
    btn.MouseButton1Click:Connect(function()if typeof(_b)=="function"then _b()end end)
    return btn
end

local _56=_55("↺ Reset Settings",function()end)
_54("Stop Emote When Moving")
_54("Looped")
_53("Speed",0,5,_18["Speed"])
_53("Time Position",0,1,_18["Time Position"])
_53("Weight",0,1,_18["Weight"])
_53("Fade In",0,2,_18["Fade In"])
_53("Fade Out",0,2,_18["Fade Out"])
_54("Stop Other Animations On Play")
_54("High Priority")

_56.MouseButton1Click:Connect(function()
    _18:EditToggle("Stop Emote When Moving",true)
    _18:EditToggle("Stop Other Animations On Play",true)
    _18:EditToggle("High Priority",true)
    _18:EditSlider("Fade In",0.1)
    _18:EditSlider("Fade Out",0.1)
    _18:EditSlider("Weight",1)
    _18:EditSlider("Speed",1)
    _18:EditSlider("Time Position",0)
    _18:EditToggle("Freeze On Finish",false)
    _18:EditToggle("Looped",true)
end)

-- ================================================================
--  SORT CONFIG
-- ================================================================
local _57={{Enum.CatalogSortType.Relevance,"Relevance"},{Enum.CatalogSortType.PriceHighToLow,"Price ↓"},{Enum.CatalogSortType.PriceLowToHigh,"Price ↑"},{Enum.CatalogSortType.MostFavorited,"Favorited"},{Enum.CatalogSortType.RecentlyCreated,"Newest"},{Enum.CatalogSortType.Bestselling,"Bestselling"}}
local _58=1 local _59="" local _60=nil local _61=1 local _TAB=1

local function _62(_a)
    if _isR6 then return {IsFinished=true,GetCurrentPage=function()return{{Id=115314801778772,Name="Dance If Youre The Best",AssetId=115314801778772}}end,AdvanceToNextPageAsync=function()end}end
    local p=CatalogSearchParams.new()
    p.SearchKeyword=_a or ""
    p.CategoryFilter=Enum.CatalogCategoryFilter.None
    p.SalesTypeFilter=Enum.SalesTypeFilter.All
    p.AssetTypes={Enum.AvatarAssetType.EmoteAnimation}
    p.IncludeOffSale=true
    p.SortType=_57[_58][1]
    p.Limit=10
    local ok,res=pcall(function()return _12:SearchCatalog(p)end)
    if not ok then return nil end return res
end

-- ================================================================
--  CARD BUILDER: Catalog item
-- ================================================================
local function _63(_a)
    local card=Instance.new("Frame")
    card.Size=UDim2.new(0,_4("X",108),0,_4("Y",170))
    card.BackgroundColor3=T.BG_CARD
    card.BackgroundTransparency=0.05
    mkCorner(card,8)
    animStroke(card, 5 + math.random(0,3))

    local img=Instance.new("ImageLabel")
    img.Size=UDim2.new(1,-_4("X",8),0,_4("Y",80))
    img.Position=UDim2.new(0,_4("X",4),0,_4("Y",4))
    img.BackgroundColor3=T.BG_ELEM
    img.BackgroundTransparency=0.4
    img.ScaleType=Enum.ScaleType.Fit
    local _c=_a.AssetId or _a.Id
    pcall(function()img.Image="rbxthumb://type=Asset&id="..tonumber(_c).."&w=150&h=150"end)
    img.Parent=card
    mkCorner(img,6)

    local nameLbl=Instance.new("TextLabel")
    nameLbl.Size=UDim2.new(1,-_4("X",6),0,_4("Y",26))
    nameLbl.Position=UDim2.new(0,_4("X",3),0,_4("Y",88))
    nameLbl.BackgroundTransparency=1
    nameLbl.Text=_a.Name or "Unknown"
    nameLbl.TextScaled=true
    nameLbl.TextWrapped=true
    nameLbl.Font=Enum.Font.Gotham
    nameLbl.TextColor3=T.TEXT_PRI
    nameLbl.Parent=card

    -- link button
    local linkBtn=Instance.new("TextButton")
    linkBtn.Size=UDim2.new(0,_4("X",22),0,_4("Y",22))
    linkBtn.Position=UDim2.new(1,-_4("X",26),0,_4("Y",4))
    linkBtn.BackgroundColor3=T.BG_ELEM
    linkBtn.BackgroundTransparency=0.2
    linkBtn.Text="🔗"
    linkBtn.Font=Enum.Font.GothamBold
    linkBtn.TextScaled=true
    linkBtn.Parent=card
    mkCorner(linkBtn,5)
    local url="https://www.roblox.com/catalog/"..tonumber(_a.Id)
    linkBtn.MouseButton1Click:Connect(function()
        setclipboard(url)
        linkBtn.Text="✓"
        task.wait(0.8)
        linkBtn.Text="🔗"
    end)

    -- Play button
    local playBtn=Instance.new("TextButton")
    playBtn.Size=UDim2.new(0.5,-_4("X",5),0,_4("Y",22))
    playBtn.Position=UDim2.new(0,_4("X",3),1,-_4("Y",26))
    playBtn.BackgroundColor3=T.BG_ELEM
    playBtn.BackgroundTransparency=0.1
    playBtn.Text="▶ Play"
    playBtn.Font=Enum.Font.GothamBold
    playBtn.TextScaled=true
    playBtn.TextColor3=T.NEON_WHITE
    playBtn.Parent=card
    mkCorner(playBtn,5)
    mkStroke(playBtn, T.NEON_MGRAY, 0.8)
    playBtn.MouseButton1Click:Connect(function()_24(_c)end)

    -- Save button
    local saveBtn=Instance.new("TextButton")
    saveBtn.Size=UDim2.new(0.5,-_4("X",5),0,_4("Y",22))
    saveBtn.Position=UDim2.new(0.5,_4("X",2),1,-_4("Y",26))
    saveBtn.BackgroundColor3=T.BG_ELEM
    saveBtn.BackgroundTransparency=0.1
    saveBtn.Text="+ Save"
    saveBtn.Font=Enum.Font.GothamBold
    saveBtn.TextScaled=true
    saveBtn.TextColor3=T.TEXT_SEC
    saveBtn.Parent=card
    mkCorner(saveBtn,5)
    mkStroke(saveBtn, T.NEON_DGRAY, 0.7)
    saveBtn.MouseButton1Click:Connect(function()
        local dup=false
        for _,v in ipairs(_19)do if v.Id==_a.Id then dup=true break end end
        if not dup then
            local real=GetReal(_c)
            table.insert(_19,{Id=_a.Id,AssetId=_c,Name=_a.Name or "Unknown",AnimationId="rbxassetid://"..tostring(real or _c),Favorite=false})
            _22()
            saveBtn.Text="Saved ✓"
            saveBtn.TextColor3=T.NEON_WHITE
            task.wait(1.2)
            saveBtn.Text="+ Save"
            saveBtn.TextColor3=T.TEXT_SEC
        else
            saveBtn.Text="Already"
            task.wait(0.8)
            saveBtn.Text="+ Save"
        end
    end)

    popAnim(card)
    return card
end

-- ================================================================
--  CARD BUILDER: Saved item
-- ================================================================
local function _78(_a)
    local card=Instance.new("Frame")
    card.Size=UDim2.new(0,_4("X",108),0,_4("Y",185))
    card.BackgroundColor3=T.BG_CARD
    card.BackgroundTransparency=0.05
    mkCorner(card,8)
    animStroke(card, 5 + math.random(0,4))

    local img=Instance.new("ImageLabel")
    img.Size=UDim2.new(1,-_4("X",8),0,_4("Y",80))
    img.Position=UDim2.new(0,_4("X",4),0,_4("Y",4))
    img.BackgroundColor3=T.BG_ELEM
    img.BackgroundTransparency=0.4
    img.ScaleType=Enum.ScaleType.Fit
    img.Image="rbxthumb://type=Asset&id=11768914234&w=150&h=150"
    img.Parent=card
    mkCorner(img,6)

    local nameLbl=Instance.new("TextLabel")
    nameLbl.Size=UDim2.new(1,-_4("X",6),0,_4("Y",24))
    nameLbl.Position=UDim2.new(0,_4("X",3),0,_4("Y",88))
    nameLbl.BackgroundTransparency=1
    nameLbl.Text=_a.Name or "Unknown"
    nameLbl.TextScaled=true
    nameLbl.TextWrapped=true
    nameLbl.Font=Enum.Font.Gotham
    nameLbl.TextColor3=T.TEXT_PRI
    nameLbl.Parent=card

    -- fav star
    local favBtn=Instance.new("TextButton")
    favBtn.Size=UDim2.new(0,_4("X",20),0,_4("Y",20))
    favBtn.Position=UDim2.new(1,-_4("X",24),0,_4("Y",4))
    favBtn.BackgroundTransparency=1
    favBtn.Text=_a.Favorite and "★" or "☆"
    favBtn.Font=Enum.Font.GothamBold
    favBtn.TextScaled=true
    favBtn.TextColor3=Color3.fromRGB(220,220,220)
    favBtn.Parent=card
    favBtn.MouseButton1Click:Connect(function()
        _a.Favorite=not _a.Favorite
        favBtn.Text=_a.Favorite and "★" or "☆"
        _22()_80()
    end)

    -- copy ID
    local copyBtn=Instance.new("TextButton")
    copyBtn.Size=UDim2.new(1,-_4("X",6),0,_4("Y",18))
    copyBtn.Position=UDim2.new(0,_4("X",3),0,_4("Y",116))
    copyBtn.BackgroundColor3=T.BG_ELEM
    copyBtn.BackgroundTransparency=0.2
    copyBtn.Text="Copy AnimID"
    copyBtn.Font=Enum.Font.Gotham
    copyBtn.TextScaled=true
    copyBtn.TextColor3=T.TEXT_DIM
    copyBtn.Parent=card
    mkCorner(copyBtn,4)
    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(_a.AnimationId:gsub("rbxassetid://",""))end
        copyBtn.Text="Copied ✓"
        task.wait(0.8)
        copyBtn.Text="Copy AnimID"
    end)

    -- Play
    local playBtn=Instance.new("TextButton")
    playBtn.Size=UDim2.new(0.5,-_4("X",5),0,_4("Y",22))
    playBtn.Position=UDim2.new(0,_4("X",3),1,-_4("Y",26))
    playBtn.BackgroundColor3=T.BG_ELEM
    playBtn.BackgroundTransparency=0.1
    playBtn.Text="▶ Play"
    playBtn.Font=Enum.Font.GothamBold
    playBtn.TextScaled=true
    playBtn.TextColor3=T.NEON_WHITE
    playBtn.Parent=card
    mkCorner(playBtn,5)
    mkStroke(playBtn, T.NEON_MGRAY, 0.8)
    playBtn.MouseButton1Click:Connect(function()_24(_a.Id)end)

    -- Remove
    local remBtn=Instance.new("TextButton")
    remBtn.Size=UDim2.new(0.5,-_4("X",5),0,_4("Y",22))
    remBtn.Position=UDim2.new(0.5,_4("X",2),1,-_4("Y",26))
    remBtn.BackgroundColor3=T.BG_ELEM
    remBtn.BackgroundTransparency=0.1
    remBtn.Text="✕ Remove"
    remBtn.Font=Enum.Font.GothamBold
    remBtn.TextScaled=true
    remBtn.TextColor3=Color3.fromRGB(180,80,80)
    remBtn.Parent=card
    mkCorner(remBtn,5)
    mkStroke(remBtn, Color3.fromRGB(80,40,40), 0.7)
    remBtn.MouseButton1Click:Connect(function()
        for i,v in ipairs(_19)do if v.Id==_a.Id then table.remove(_19,i)_22()_80()break end end
    end)

    popAnim(card)
    return card
end

-- ================================================================
--  PAGINATION HELPERS
-- ================================================================
local function _71()
    _67.Visible=(_61>1)
    if _60 and typeof(_60.IsFinished)=="boolean"then _68.Visible=not _60.IsFinished else _68.Visible=true end
end

local _73_id=0
local function _73(_a)
    _73_id=_73_id+1
    local myId=_73_id
    _69.Text="..."
    for _,c in ipairs(_64:GetChildren())do if c:IsA("Frame")then c:Destroy()end end
    local ok,pg=pcall(function()return _a:GetCurrentPage()end)
    if not ok then _69.Text="ERR" return end
    if myId~=_73_id then return end
    if pg and #pg>0 then
        _66.Visible=false
        local myTAB=_TAB local cnt=0
        for _,item in ipairs(pg)do
            if _TAB~=myTAB or myId~=_73_id then break end
            _63(item).Parent=_64
            cnt=cnt+1
            if cnt%2==0 then _9.RenderStepped:Wait()end
        end
    else _66.Visible=true end
    if myId==_73_id then
        _64.CanvasSize=UDim2.new(0,0,0,_65.AbsoluteContentSize.Y+8)
        _69.Text=tostring(_61)
        _71()
    end
end

local function _74(_a)
    local p=_62(_59)if not p then return nil end
    for i=2,_a do if p.IsFinished then break end local ok,_=pcall(function()p:AdvanceToNextPageAsync()end)if not ok then break end end
    return p
end

local function _75(_a)_59=_a or ""_61=1 _69.Text="..."_60=_62(_59)if _60 then _73(_60)end end
_41.MouseButton1Click:Connect(function()_75(_40.Text)end)
_40.FocusLost:Connect(function(e)if e then _75(_40.Text)end end)
_42.MouseButton1Click:Connect(function()_58=_58%#_57+1 _42.Text="⇅ ".._57[_58][2]_75(_59)end)

local function _76()
    if not _60 or _60.IsFinished then return end
    local ok=pcall(function()_60:AdvanceToNextPageAsync()end)
    if ok then _61+=1 _73(_60)else local p=_74(_61+1)if p then _60=p _61=math.min(_61+1,_61+1)_73(_60)end end
end
local function _77()
    if not _60 or _61<=1 then return end
    local ok=pcall(function()_60:AdvanceToPreviousPageAsync()end)
    if ok then _61=math.max(1,_61-1)_73(_60)else local p=_74(math.max(1,_61-1))if p then _60=p _61=math.max(1,_61-1)_73(_60)end end
end

_68.MouseButton1Click:Connect(_76)
_67.MouseButton1Click:Connect(_77)
_10.InputBegan:Connect(function(i,g)if g then return end if i.UserInputType==Enum.UserInputType.Keyboard then if i.KeyCode==Enum.KeyCode.Right then _76()elseif i.KeyCode==Enum.KeyCode.Left then _77()end end end)

_69.FocusLost:Connect(function(e)
    if not e then return end
    local n=tonumber(_69.Text:match("%d+"))
    if not n or n<1 then _69.Text=tostring(_61)return end
    local pg=math.floor(n)if pg==_61 then _69.Text=tostring(_61)return end
    _69.Text="..."
    local ok,res=pcall(function()return _74(pg)end)
    if not ok or not res then _69.Text=tostring(_61)return end
    _60=res _61=math.max(1,pg)_73(_60)
end)

-- ================================================================
--  SAVED PANEL REFRESH
-- ================================================================
local _80_id=0
function _80()
    _80_id=_80_id+1
    local myId=_80_id
    for _,c in ipairs(_45:GetChildren())do if c:IsA("Frame")then c:Destroy()end end
    local q=(_44.Text or ""):lower()
    local filtered={}
    for _,v in ipairs(_19)do if q==""or(v.Name and v.Name:lower():find(q))then table.insert(filtered,v)end end
    table.sort(filtered,function(a,b)if a.Favorite~=b.Favorite then return a.Favorite else return false end end)
    if #filtered>0 then
        _46.Visible=false
        local myTAB=_TAB local cnt=0
        for _,item in ipairs(filtered)do
            if _TAB~=myTAB or myId~=_80_id then break end
            _78(item).Parent=_45
            cnt=cnt+1
            if cnt%25==0 then _9.RenderStepped:Wait()end
        end
    else _46.Visible=true end
    if myId==_80_id then _45.CanvasSize=UDim2.new(0,0,0,_47.AbsoluteContentSize.Y+8)end
end

-- ================================================================
--  TAB SWITCHING
-- ================================================================
_36.MouseButton1Click:Connect(function()
    _TAB+=1 _39.Visible=true _43.Visible=false
    _36.TextColor3=T.NEON_WHITE _36.BackgroundColor3=T.BG_ELEM
    _37.TextColor3=T.TEXT_SEC  _37.BackgroundColor3=T.BG_CARD
    mkStroke(_36, T.NEON_MGRAY, 1.2)
    mkStroke(_37, T.NEON_DGRAY, 0.7)
end)
_37.MouseButton1Click:Connect(function()
    _TAB+=1 _39.Visible=false _43.Visible=true
    _37.TextColor3=T.NEON_WHITE _37.BackgroundColor3=T.BG_ELEM
    _36.TextColor3=T.TEXT_SEC  _36.BackgroundColor3=T.BG_CARD
    mkStroke(_37, T.NEON_MGRAY, 1.2)
    mkStroke(_36, T.NEON_DGRAY, 0.7)
    _80()
end)
_44:GetPropertyChangedSignal("Text"):Connect(_80)

-- ================================================================
--  TOGGLE BUTTON  "G" (neon style)
-- ================================================================
_75("")
local _79=_26
local function _81()_79.Enabled=not _79.Enabled end

local togGui=Instance.new("ScreenGui")
togGui.Name="GazeToggle_vtp"
togGui.ResetOnSpawn=false
togGui.Parent=_25
togGui.Enabled=true

local togBtn=Instance.new("TextButton")
togBtn.Parent=togGui
togBtn.Text="G"
togBtn.Font=Enum.Font.GothamBold
togBtn.TextScaled=true
togBtn.Size=UDim2.new(0,50,0,50)
togBtn.Position=UDim2.new(0,18,0.5,-50)
togBtn.AnchorPoint=Vector2.new(0,0.5)
togBtn.BackgroundColor3=T.BG_DEEP
togBtn.BackgroundTransparency=0.05
togBtn.TextColor3=T.NEON_WHITE
togBtn.Active=true
pcall(function()togBtn.Draggable=true end)
mkCorner(togBtn,14)
animStroke(togBtn, 2.5)

local _84=Instance.new("UIAspectRatioConstraint")
_84.Parent=togBtn
_84.AspectRatio=1

togBtn.MouseButton1Click:Connect(_81)
_10.InputBegan:Connect(function(i,g)
    if g then return end
    if i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode==Enum.KeyCode.G then _81()end
end)

_26.Enabled=true
_80()

-- ================================================================
--  NO-COLLISION (unchanged)
-- ================================================================
task.spawn(function()
    local RunService=game:GetService("RunService")
    local Players=game.Players
    local player=Players.LocalPlayer
    local function setupCollision(character)
        local hrp=character:WaitForChild("HumanoidRootPart")
        local bodyParts={}
        hrp.CanCollide=true
        local function addPart(part)if part:IsA("BasePart")and part~=hrp then table.insert(bodyParts,part)end end
        for _,p in pairs(character:GetDescendants())do addPart(p)end
        local dc=character.DescendantAdded:Connect(addPart)
        local hc
        hc=RunService.Heartbeat:Connect(function()
            if not character or not character.Parent then hc:Disconnect()dc:Disconnect()return end
            for i=1,#bodyParts do local p=bodyParts[i]if p and p.Parent then p.CanCollide=false end end
        end)
    end
    if player.Character then setupCollision(player.Character)end
    player.CharacterAdded:Connect(setupCollision)
end)
