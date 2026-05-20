-- vertelvsepoel | Emotes Glass UI
-- Glassmorphism theme · Frosted panels · Hover effects

local _2=game:GetService("UserInputService")
local _3=workspace.CurrentCamera.ViewportSize
local function _4(_a,_b)local _c=_2.TouchEnabled and not _2.KeyboardEnabled local _d,_e=1920,1080 local _f=_c and 2 or 1.5 if _a=="X"then return _b*(_3.X/_d)*_f elseif _a=="Y"then return _b*(_3.Y/_e)*_f end end
local function _5(_a,_b,_c)if type(_b)==_a then return _b end return _c end
local _6=_5("function",cloneref,function(...)return ... end)
local _7=setmetatable({},{__index=function(_,_a)return _6(game:GetService(_a))end})
local _8=_7.Players local _9=_7.RunService local _10=_7.UserInputService local _11=_7.TweenService local _12=_7.AvatarEditorService local _13=_7.HttpService
local _14=_8.LocalPlayer local _15=_14.Character or _14.CharacterAdded:Wait()local _16=_15:WaitForChild("Humanoid")local _isR6=_16.RigType==Enum.HumanoidRigType.R6 local _17=_15.PrimaryPart and _15.PrimaryPart.Position or Vector3.new()
local _35_Ref,_36_Ref,_37_Ref,_39_Ref,_43_Ref

_14.CharacterAdded:Connect(function(_a)
    _15=_a _16=_a:WaitForChild("Humanoid")_isR6=_16.RigType==Enum.HumanoidRigType.R6
    if _35_Ref then _35_Ref.Text=_isR6 and "EMOTES [R6]" or "EMOTES" end
    if _36_Ref then _36_Ref.Text=_isR6 and "Animation" or "Catalog" end
    if _37_Ref then _37_Ref.Visible=not _isR6 end
    if _isR6 and _39_Ref and _43_Ref then _39_Ref.Visible=true _43_Ref.Visible=false end
    _17=_15.PrimaryPart and _15.PrimaryPart.Position or Vector3.new()
end)

local _18={} _18["Stop Emote When Moving"]=true _18["Fade In"]=0.1 _18["Fade Out"]=0.1 _18["Weight"]=1
_18["Speed"]=1 _18["Time Position"]=0 _18["Freeze On Finish"]=false _18["Looped"]=true _18["Stop Other Animations On Play"]=true _18["High Priority"]=true
local _19={} local _20="GazeEmotes_NewNEWN3WSaved.json"
local function _21()local _a,_b=pcall(function()if readfile and isfile and isfile(_20)then return _13:JSONDecode(readfile(_20))end return{}end)if _a and type(_b)=="table"then _19=_b else _19={}end for _c,_d in ipairs(_19)do if not _d.AnimationId then if _d.AssetId then _d.AnimationId="rbxassetid://"..tostring(_d.AssetId)else _d.AnimationId="rbxassetid://"..tostring(_d.Id)end end if _d.Favorite==nil then _d.Favorite=false end end end
local function _22()pcall(function()if writefile then writefile(_20,_13:JSONEncode(_19))end end)end
_21()
local _23=nil
local function _24(_a)if _23 then _23:Stop(_18["Fade Out"])end local _b
local _c,_d=pcall(function()return game:GetObjects("rbxassetid://"..tostring(_a))end)if _c and _d and #_d>0 then local _e=_d[1]if _e:IsA("Animation")then _b=_e.AnimationId else _b="rbxassetid://"..tostring(_a)end else _b="rbxassetid://"..tostring(_a)end local _e=Instance.new("Animation")_e.AnimationId=_b local _f=_16:LoadAnimation(_e)local _g=_18["High Priority"]and Enum.AnimationPriority.Action4 or Enum.AnimationPriority.Action _f.Priority=_g local _h=_18["Weight"]if _h==0 then _h=0.001 end if _18["Stop Other Animations On Play"]then for _i,_j in pairs(_16.Animator:GetPlayingAnimationTracks())do if _j.Priority~=_g then _j:Stop()end end end _f:Play(_18["Fade In"],_h,_18["Speed"])_23=_f _23.TimePosition=math.clamp(_18["Time Position"],0,1)*(_23.Length or 1)_23.Priority=_g _23.Looped=_18["Looped"]return _f end
_9.RenderStepped:Connect(function()if _18["Looped"]and _23 and _23.IsPlaying then _23.Looped=_18["Looped"]end if _15:FindFirstChild("HumanoidRootPart")then local _a=_15.HumanoidRootPart if _18["Stop Emote When Moving"]and _23 and _23.IsPlaying then local _b=(_a.Position-_17).Magnitude>0.1 local _c=_16 and _16:GetState()==Enum.HumanoidStateType.Jumping if _b or _c then _23:Stop(_18["Fade Out"])_23=nil end end _17=_a.Position end end)

-- ════════════════════════════════════
-- GLASS THEME CONSTANTS
-- ════════════════════════════════════

local C = {
    White       = Color3.fromRGB(255,255,255),
    PanelBg     = Color3.fromRGB(18,22,52),
    PanelBg2    = Color3.fromRGB(28,36,78),
    HeaderBg    = Color3.fromRGB(24,32,72),
    CardBg      = Color3.fromRGB(22,32,76),
    CardBgSaved = Color3.fromRGB(16,46,32),
    InputBg     = Color3.fromRGB(14,20,56),
    TextMain    = Color3.fromRGB(235,240,255),
    TextDim     = Color3.fromRGB(155,170,215),
    TextFaint   = Color3.fromRGB(90,105,160),
    AccentBlue  = Color3.fromRGB(110,170,255),
    AccentPurp  = Color3.fromRGB(160,130,255),
    Green       = Color3.fromRGB(90,235,150),
    Danger      = Color3.fromRGB(255,100,125),
    Gold        = Color3.fromRGB(255,218,58),
    StrokeWhite = Color3.fromRGB(200,215,255),
    StrokeGreen = Color3.fromRGB(100,230,160),
    StrokeBlue  = Color3.fromRGB(120,175,255),
}

-- ════════════════════════════════════
-- HELPERS
-- ════════════════════════════════════

local function Corner(_p,_r)
    local c=Instance.new("UICorner")c.CornerRadius=UDim.new(0,_r or 10)c.Parent=_p return c
end

local function Stroke(_p,_t,_col,_trans)
    local s=Instance.new("UIStroke")
    s.Thickness=_t or 1
    s.Color=_col or C.StrokeWhite
    s.Transparency=_trans or 0.5
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    s.Parent=_p return s
end

-- Top-edge gloss line on a panel
local function Gloss(_parent, _w, _offset)
    local g=Instance.new("Frame")
    g.Size=UDim2.new(_w or 0.85,0,0,1)
    g.Position=UDim2.new((1-(_w or 0.85))/2,0,0,_offset or 1)
    g.BackgroundColor3=C.White
    g.BackgroundTransparency=0.55
    g.BorderSizePixel=0
    g.ZIndex=(_parent.ZIndex or 1)+2
    g.Parent=_parent
end

-- Shimmer sweep on appear
local function Shimmer(_frame)
    local bar=Instance.new("Frame")
    bar.Size=UDim2.new(0,_4("X",80),1,0)
    bar.BackgroundColor3=C.White
    bar.BackgroundTransparency=0.8
    bar.BorderSizePixel=0
    bar.ZIndex=(_frame.ZIndex or 1)+3
    bar.Parent=_frame
    Corner(bar,8)
    bar.Position=UDim2.new(-0.4,0,0,0)
    _11:Create(bar,TweenInfo.new(0.7,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{Position=UDim2.new(1.4,0,0,0)}):Play()
    task.delay(0.75,function()if bar and bar.Parent then bar:Destroy()end end)
end

local function PopIn(_a)
    local sc=Instance.new("UIScale")sc.Scale=0.65 sc.Parent=_a
    _11:Create(sc,TweenInfo.new(0.26,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
    Shimmer(_a)
end

local function HoverFade(_btn,_hBg,_nBg,_hTrans,_nTrans)
    _hTrans=_hTrans or 0.4
    _nTrans=_nTrans or 0.55
    _btn.MouseEnter:Connect(function()
        _11:Create(_btn,TweenInfo.new(0.15),{BackgroundColor3=_hBg,BackgroundTransparency=_hTrans}):Play()
    end)
    _btn.MouseLeave:Connect(function()
        _11:Create(_btn,TweenInfo.new(0.15),{BackgroundColor3=_nBg,BackgroundTransparency=_nTrans}):Play()
    end)
end

-- ════════════════════════════════════
-- SCREEN GUI
-- ════════════════════════════════════

local _25=_7.CoreGui

local _26=Instance.new("ScreenGui")
_26.Name="EmoteGUI_Glass"
_26.Parent=_25
_26.Enabled=false
_26.DisplayOrder=999
_26.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

-- ════════════════════════════════════
-- MAIN WINDOW
-- ════════════════════════════════════

local W,H = _4("X",500), _4("Y",464)

local _30=Instance.new("Frame")
_30.Size=UDim2.new(0,W,0,H)
_30.Position=UDim2.new(0.5,-W/2,0.5,-H/2)
_30.BackgroundColor3=C.PanelBg
_30.BackgroundTransparency=0.22
_30.Active=true
_30.Draggable=true
_30.ZIndex=2
_30.ClipsDescendants=true
_30.Parent=_26
Corner(_30,16)
Stroke(_30,1.5,C.StrokeWhite,0.3)
Gloss(_30,0.9,1)

-- Resize handle
local _31=Instance.new("TextButton")
_31.Size=UDim2.new(0,20,0,20)
_31.Position=UDim2.new(1,-20,1,-20)
_31.BackgroundTransparency=1
_31.Text="◢"
_31.TextColor3=C.TextFaint
_31.TextTransparency=0.3
_31.TextSize=14
_31.ZIndex=12
_31.Parent=_30

local _32=false local _33 local _34
_31.InputBegan:Connect(function(_a)if _a.UserInputType==Enum.UserInputType.MouseButton1 or _a.UserInputType==Enum.UserInputType.Touch then _32=true _33=_a.Position _34=_30.AbsoluteSize end end)
_10.InputChanged:Connect(function(_a)if _32 and(_a.UserInputType==Enum.UserInputType.MouseMovement or _a.UserInputType==Enum.UserInputType.Touch)then local _b=_a.Position-_33 _30.Size=UDim2.new(0,math.max(220,_34.X+_b.X),0,math.max(160,_34.Y+_b.Y))end end)
_10.InputEnded:Connect(function(_a)if _a.UserInputType==Enum.UserInputType.MouseButton1 or _a.UserInputType==Enum.UserInputType.Touch then _32=false end end)

-- ════════════════════════════════════
-- HEADER
-- ════════════════════════════════════

local hdr=Instance.new("Frame")
hdr.Size=UDim2.new(1,0,0,_4("Y",52))
hdr.BackgroundColor3=C.HeaderBg
hdr.BackgroundTransparency=0.28
hdr.BorderSizePixel=0
hdr.ZIndex=4
hdr.Parent=_30
Corner(hdr,16)
Stroke(hdr,1,C.StrokeWhite,0.48)
Gloss(hdr,0.88,1)

-- Traffic-light dots
for i=1,3 do
    local dot=Instance.new("Frame")
    dot.Size=UDim2.new(0,7,0,7)
    dot.Position=UDim2.new(0,_4("X",12)+(i-1)*12,0.5,-3)
    dot.BackgroundColor3=i==1 and C.Danger or (i==2 and Color3.fromRGB(255,208,60) or C.Green)
    dot.BackgroundTransparency=0.15
    dot.BorderSizePixel=0
    dot.ZIndex=6
    dot.Parent=hdr
    Corner(dot,10)
end

-- Title
local _35=Instance.new("TextLabel")
_35_Ref=_35
_35.Size=UDim2.new(0.52,0,0,_4("Y",22))
_35.Position=UDim2.new(0,_4("X",52),0.5,-_4("Y",11))
_35.BackgroundTransparency=1
_35.Text=_isR6 and "EMOTES [R6]" or "EMOTES"
_35.TextColor3=C.TextMain
_35.Font=Enum.Font.GothamBold
_35.TextScaled=true
_35.TextXAlignment=Enum.TextXAlignment.Left
_35.ZIndex=5
_35.Parent=hdr

-- Watermark
local brand=Instance.new("TextLabel")
brand.Size=UDim2.new(0.32,0,0,_4("Y",11))
brand.Position=UDim2.new(0,_4("X",52),0,_4("Y",6))
brand.BackgroundTransparency=1
brand.Text="vertelvsepoel"
brand.TextColor3=C.TextFaint
brand.Font=Enum.Font.Gotham
brand.TextScaled=true
brand.TextXAlignment=Enum.TextXAlignment.Left
brand.TextTransparency=0.25
brand.ZIndex=5
brand.Parent=hdr

-- Rig badge
local rigFrame=Instance.new("Frame")
rigFrame.Size=UDim2.new(0,_4("X",34),0,_4("Y",20))
rigFrame.Position=UDim2.new(1,-_4("X",76),0.5,-_4("Y",10))
rigFrame.BackgroundColor3=C.AccentPurp
rigFrame.BackgroundTransparency=0.55
rigFrame.ZIndex=6
rigFrame.Parent=hdr
Corner(rigFrame,6)
Stroke(rigFrame,1,C.AccentPurp,0.25)
local rigTxt=Instance.new("TextLabel")
rigTxt.Size=UDim2.new(1,0,1,0)
rigTxt.BackgroundTransparency=1
rigTxt.Text=_isR6 and "R6" or "R15"
rigTxt.TextColor3=C.TextMain
rigTxt.Font=Enum.Font.GothamBold
rigTxt.TextScaled=true
rigTxt.ZIndex=7
rigTxt.Parent=rigFrame

-- Close button
local closeBtn=Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,_4("X",26),0,_4("Y",26))
closeBtn.Position=UDim2.new(1,-_4("X",36),0.5,-_4("Y",13))
closeBtn.BackgroundColor3=C.Danger
closeBtn.BackgroundTransparency=0.5
closeBtn.TextColor3=C.TextMain
closeBtn.Text="✕"
closeBtn.Font=Enum.Font.GothamBold
closeBtn.TextScaled=true
closeBtn.ZIndex=6
closeBtn.Parent=hdr
Corner(closeBtn,13)
Stroke(closeBtn,1,C.Danger,0.25)
HoverFade(closeBtn,C.Danger,C.Danger,0.2,0.5)
closeBtn.MouseButton1Click:Connect(function()
    _11:Create(_30,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{BackgroundTransparency=1}):Play()
    task.wait(0.22)
    _26.Enabled=false
    _30.BackgroundTransparency=0.22
end)

-- ════════════════════════════════════
-- TAB ROW
-- ════════════════════════════════════

local tabRow=Instance.new("Frame")
tabRow.Size=UDim2.new(1,-_4("X",18),0,_4("Y",30))
tabRow.Position=UDim2.new(0,_4("X",9),0,_4("Y",56))
tabRow.BackgroundTransparency=1
tabRow.ZIndex=4
tabRow.Parent=_30

local function MakeTab(_txt,_xp,_w)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(_w,-3,1,0)
    btn.Position=UDim2.new(_xp,1,0,0)
    btn.BackgroundColor3=C.PanelBg2
    btn.BackgroundTransparency=0.62
    btn.TextColor3=C.TextDim
    btn.Text=_txt
    btn.Font=Enum.Font.GothamBold
    btn.TextScaled=true
    btn.ZIndex=5
    btn.Parent=tabRow
    Corner(btn,8)
    Stroke(btn,1,C.StrokeWhite,0.55)
    HoverFade(btn,C.PanelBg2,C.PanelBg2,0.38,0.62)
    return btn
end

local _36=MakeTab(_isR6 and "Animation" or "Catalog",0,0.28)
_36_Ref=_36
_36.TextColor3=C.TextMain
_36.BackgroundTransparency=0.38

local _37=MakeTab("Saved",0.29,0.28)
_37_Ref=_37
_37.Visible=not _isR6

-- ════════════════════════════════════
-- VERTICAL DIVIDER
-- ════════════════════════════════════

local divY=_4("Y",92)
local _38=Instance.new("Frame")
_38.Size=UDim2.new(0,1,1,-divY-_4("Y",6))
_38.Position=UDim2.new(0.6,0,0,divY)
_38.BackgroundColor3=C.StrokeWhite
_38.BackgroundTransparency=0.7
_38.BorderSizePixel=0
_38.ZIndex=4
_38.Parent=_30

-- ════════════════════════════════════
-- CATALOG PANEL
-- ════════════════════════════════════

local _39=Instance.new("Frame")
_39_Ref=_39
_39.Size=UDim2.new(0.6,-_4("X",12),1,-divY-_4("Y",6))
_39.Position=UDim2.new(0,_4("X",6),0,divY)
_39.BackgroundTransparency=1
_39.Visible=true
_39.ZIndex=3
_39.Parent=_30

local function GlassInput(_par,_xp,_yp,_sw,_sh,_pholder,_tcol)
    local b=Instance.new("TextBox")
    b.Size=UDim2.new(_sw,0,0,_sh)
    b.Position=UDim2.new(_xp,0,0,_yp)
    b.BackgroundColor3=C.InputBg
    b.BackgroundTransparency=0.42
    b.TextColor3=_tcol or C.TextMain
    b.PlaceholderColor3=C.TextFaint
    b.PlaceholderText=_pholder or ""
    b.Font=Enum.Font.Gotham
    b.TextScaled=true
    b.ClearTextOnFocus=false
    b.Text=""
    b.ZIndex=5
    b.Parent=_par
    Corner(b,8)
    Stroke(b,1,C.StrokeWhite,0.52)
    return b
end

local function GlassBtn(_par,_xp,_yp,_sw,_sh,_txt,_bgCol,_txCol)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(_sw,0,0,_sh)
    btn.Position=UDim2.new(_xp,0,0,_yp)
    btn.BackgroundColor3=_bgCol or C.PanelBg2
    btn.BackgroundTransparency=0.52
    btn.TextColor3=_txCol or C.TextMain
    btn.Text=_txt
    btn.Font=Enum.Font.GothamBold
    btn.TextScaled=true
    btn.ZIndex=5
    btn.Parent=_par
    Corner(btn,8)
    Stroke(btn,1,_bgCol or C.StrokeWhite,0.35)
    HoverFade(btn,_bgCol or C.PanelBg2,_bgCol or C.PanelBg2,0.3,0.52)
    return btn
end

local _40=GlassInput(_39,0,_4("Y",3),0.58,_4("Y",26),"Search emotes...")
local _41=GlassBtn(_39,0.59,_4("Y",3),0.205,_4("Y",26),"Refresh",Color3.fromRGB(30,70,170),C.AccentBlue)
local _42=GlassBtn(_39,0.8,_4("Y",3),0.2,_4("Y",26),"Sort",Color3.fromRGB(55,40,130),C.AccentPurp)

local _64=Instance.new("ScrollingFrame")
_64.Size=UDim2.new(1,0,1,-_4("Y",58))
_64.Position=UDim2.new(0,0,0,_4("Y",33))
_64.CanvasSize=UDim2.new(0,0,0,0)
_64.ScrollBarThickness=3
_64.ScrollBarImageColor3=C.AccentBlue
_64.BackgroundTransparency=1
_64.ZIndex=4
_64.Parent=_39

local _65=Instance.new("UIGridLayout",_64)
_65.CellSize=UDim2.new(0,_4("X",108),0,_4("Y",168))
_65.CellPadding=UDim2.new(0,_4("X",6),0,_4("Y",6))
_65.HorizontalAlignment=Enum.HorizontalAlignment.Center

local _66=Instance.new("TextLabel",_64)
_66.Size=UDim2.new(1,0,0,_4("Y",36))
_66.Position=UDim2.new(0,0,0.5,-_4("Y",18))
_66.BackgroundTransparency=1
_66.Text="No results found"
_66.TextColor3=C.TextFaint
_66.Font=Enum.Font.GothamBold
_66.TextScaled=true
_66.Visible=false
_66.ZIndex=5

local _67=GlassBtn(_39,0,0,0.36,_4("Y",24),"← Prev",Color3.fromRGB(30,50,120),C.TextDim)
_67.AnchorPoint=Vector2.new(0,1)
_67.Position=UDim2.new(0,0,1,-2)

local _68=GlassBtn(_39,0.64,0,0.36,_4("Y",24),"Next →",Color3.fromRGB(30,50,120),C.TextDim)
_68.AnchorPoint=Vector2.new(0,1)
_68.Position=UDim2.new(0.64,0,1,-2)

local _69=Instance.new("TextBox",_39)
_69.Size=UDim2.new(0.26,0,0,_4("Y",24))
_69.AnchorPoint=Vector2.new(0,1)
_69.Position=UDim2.new(0.37,0,1,-2)
_69.BackgroundTransparency=1
_69.Font=Enum.Font.GothamBold
_69.TextScaled=true
_69.TextColor3=C.TextDim
_69.Text="1"
_69.ZIndex=5

local _70=Instance.new("TextLabel",_39)
_70.Size=UDim2.new(0.6,0,0,_4("Y",18))
_70.Position=UDim2.new(0.2,0,1,-_4("Y",52))
_70.BackgroundTransparency=1
_70.TextColor3=C.Danger
_70.Font=Enum.Font.Gotham
_70.TextScaled=true
_70.Text=""
_70.Visible=false
_70.ZIndex=5

-- ════════════════════════════════════
-- SAVED PANEL
-- ════════════════════════════════════

local _43=Instance.new("Frame")
_43_Ref=_43
_43.Size=UDim2.new(0.6,-_4("X",12),1,-divY-_4("Y",6))
_43.Position=UDim2.new(0,_4("X",6),0,divY)
_43.BackgroundTransparency=1
_43.Visible=false
_43.ZIndex=3
_43.Parent=_30

local _44=GlassInput(_43,0,_4("Y",3),0.52,_4("Y",26),"Search saved...",C.Green)
local _44a=GlassInput(_43,0.53,_4("Y",3),0.35,_4("Y",26),"Emote ID",C.TextDim)
local _44b=GlassBtn(_43,0.89,_4("Y",3),0.11,_4("Y",26),"+",Color3.fromRGB(20,100,60),C.Green)

local _45=Instance.new("ScrollingFrame")
_45.Size=UDim2.new(1,0,1,-_4("Y",36))
_45.Position=UDim2.new(0,0,0,_4("Y",33))
_45.CanvasSize=UDim2.new(0,0,0,0)
_45.ScrollBarThickness=3
_45.ScrollBarImageColor3=C.Green
_45.BackgroundTransparency=1
_45.ZIndex=4
_45.Parent=_43

local _46=Instance.new("TextLabel")
_46.Size=UDim2.new(1,0,0,_4("Y",36))
_46.Position=UDim2.new(0,0,0.5,-_4("Y",18))
_46.BackgroundTransparency=1
_46.Text="Nothing saved yet"
_46.TextColor3=C.TextFaint
_46.Font=Enum.Font.GothamBold
_46.TextScaled=true
_46.Visible=false
_46.Parent=_45
_46.ZIndex=5

local _47=Instance.new("UIGridLayout")
_47.CellSize=UDim2.new(0,_4("X",108),0,_4("Y",185))
_47.CellPadding=UDim2.new(0,_4("X",6),0,_4("Y",6))
_47.HorizontalAlignment=Enum.HorizontalAlignment.Center
_47.Parent=_45

-- ════════════════════════════════════
-- SETTINGS PANEL (right)
-- ════════════════════════════════════

local _48=Instance.new("Frame")
_48.Size=UDim2.new(0.4,-_4("X",8),1,-divY-_4("Y",6))
_48.Position=UDim2.new(0.6,_4("X",4),0,divY)
_48.BackgroundTransparency=1
_48.ZIndex=3
_48.Parent=_30

local setTitle=Instance.new("TextLabel")
setTitle.Size=UDim2.new(1,0,0,_4("Y",18))
setTitle.Position=UDim2.new(0,0,0,_4("Y",3))
setTitle.BackgroundTransparency=1
setTitle.Text="Settings"
setTitle.TextColor3=C.TextDim
setTitle.Font=Enum.Font.GothamBold
setTitle.TextScaled=true
setTitle.ZIndex=4
setTitle.Parent=_48

local _50=Instance.new("ScrollingFrame")
_50.Size=UDim2.new(1,-_4("X",4),1,-_4("Y",24))
_50.Position=UDim2.new(0,_4("X",2),0,_4("Y",22))
_50.BackgroundTransparency=1
_50.CanvasSize=UDim2.new(0,0,0,0)
_50.ScrollBarThickness=2
_50.ScrollBarImageColor3=C.AccentBlue
_50.ZIndex=4
_50.Parent=_48

local function _51()_50.CanvasPosition=Vector2.new(0,_50.CanvasPosition.Y)end
_50:GetPropertyChangedSignal("CanvasPosition"):Connect(_51)

local _52=Instance.new("UIListLayout",_50)
_52.Padding=UDim.new(0,4)
_52.FillDirection=Enum.FillDirection.Vertical
_52.SortOrder=Enum.SortOrder.LayoutOrder
_52:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    _50.CanvasSize=UDim2.new(0,0,0,_52.AbsoluteContentSize.Y+8)
end)

-- ════════════════════════════════════
-- SETTINGS BUILDERS
-- ════════════════════════════════════

function GetReal(_a)local _b,_c=pcall(function()return game:GetObjects("rbxassetid://"..tostring(_a))end)if _b and _c and #_c>0 then local _d=_c[1]if _d:IsA("Animation")and _d.AnimationId~=""then return tonumber(_d.AnimationId:match("%d+"))elseif _d:FindFirstChildOfClass("Animation")then local _e=_d:FindFirstChildOfClass("Animation")return tonumber(_e.AnimationId:match("%d+"))end end end

_44b.MouseButton1Click:Connect(function()local _a=tonumber(_44a.Text)if _a then local _b=false for _c,_d in ipairs(_19)do if _d.Id==_a then _b=true break end end if not _b then local _e=GetReal(_a)table.insert(_19,{Id=_a,AssetId=_a,Name="ID: ".._a,AnimationId="rbxassetid://"..tostring(_e or _a),Favorite=false})_22()_80()end end end)

_18._sliders={} _18._toggles={}

local function _53(_a,_b,_c,_d)
    _18[_a]=_d or _b
    local wrap=Instance.new("Frame")
    wrap.Size=UDim2.new(1,0,0,_4("Y",54))
    wrap.BackgroundColor3=C.PanelBg2
    wrap.BackgroundTransparency=0.42
    wrap.Parent=_50
    Corner(wrap,8)
    Stroke(wrap,1,C.StrokeWhite,0.58)

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(0.56,0,0,_4("Y",15))
    lbl.Position=UDim2.new(0,_4("X",6),0,_4("Y",3))
    lbl.BackgroundTransparency=1
    lbl.Text=string.format("%s: %.2f",_a,_18[_a])
    lbl.TextColor3=C.TextDim
    lbl.Font=Enum.Font.Gotham
    lbl.TextScaled=true
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Parent=wrap

    local inputBox=Instance.new("TextBox")
    inputBox.Size=UDim2.new(0.42,0,0,_4("Y",15))
    inputBox.Position=UDim2.new(0.57,0,0,_4("Y",3))
    inputBox.BackgroundColor3=C.InputBg
    inputBox.BackgroundTransparency=0.38
    inputBox.Text=tostring(_18[_a])
    inputBox.TextColor3=C.TextMain
    inputBox.Font=Enum.Font.Gotham
    inputBox.TextScaled=true
    inputBox.ClearTextOnFocus=false
    inputBox.Parent=wrap
    Corner(inputBox,5)
    Stroke(inputBox,1,C.StrokeBlue,0.48)

    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,-_4("X",18),0,_4("Y",6))
    track.Position=UDim2.new(0,_4("X",9),0,_4("Y",26))
    track.BackgroundColor3=C.InputBg
    track.BackgroundTransparency=0.3
    track.Parent=wrap
    Corner(track,3)

    local fill=Instance.new("Frame")
    fill.Size=UDim2.new(0,0,1,0)
    fill.BackgroundColor3=C.AccentBlue
    fill.BackgroundTransparency=0.2
    fill.Parent=track
    Corner(fill,3)

    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,_4("X",13),0,_4("Y",13))
    knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new(0,0,0.5,0)
    knob.BackgroundColor3=C.White
    knob.BackgroundTransparency=0.05
    knob.Parent=track
    Corner(knob,10)
    Stroke(knob,1,C.AccentBlue,0.2)

    local function setFill(_n)local n=math.clamp(_n,0,1)_11:Create(fill,TweenInfo.new(0.1),{Size=UDim2.new(n,0,1,0)}):Play()_11:Create(knob,TweenInfo.new(0.1),{Position=UDim2.new(n,0,0.5,0)}):Play()end
    local function setVal(_p)_18[_a]=math.clamp(_p,_b,_c)lbl.Text=string.format("%s: %.2f",_a,_18[_a])inputBox.Text=tostring(_18[_a])setFill((_18[_a]-_b)/(_c-_b))if _23 and _23.IsPlaying then if _a=="Speed"then _23:AdjustSpeed(_18["Speed"])elseif _a=="Weight"then local r=_18["Weight"]if r==0 then r=0.001 end _23:AdjustWeight(r)elseif _a=="Time Position"then if _23.Length>0 then _23.TimePosition=math.clamp(_p,0,1)*_23.Length end end end end
    local drag=false
    local function fromInput(_u)local v=math.clamp((_u.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)setVal(math.floor((_b+(_c-_b)*v)*100)/100)end
    track.InputBegan:Connect(function(_x)if _x.UserInputType==Enum.UserInputType.MouseButton1 or _x.UserInputType==Enum.UserInputType.Touch then drag=true fromInput(_x)end end)
    knob.InputBegan:Connect(function(_y)if _y.UserInputType==Enum.UserInputType.MouseButton1 or _y.UserInputType==Enum.UserInputType.Touch then drag=true fromInput(_y)end end)
    _10.InputChanged:Connect(function(_z)if drag and(_z.UserInputType==Enum.UserInputType.MouseMovement or _z.UserInputType==Enum.UserInputType.Touch)then fromInput(_z)end end)
    _10.InputEnded:Connect(function(_A)if drag and(_A.UserInputType==Enum.UserInputType.MouseButton1 or _A.UserInputType==Enum.UserInputType.Touch)then drag=false end end)
    inputBox.FocusLost:Connect(function(_B)if _B then local v=tonumber(inputBox.Text)if v then setVal(v)else inputBox.Text=tostring(_18[_a])end end end)
    _18._sliders[_a]=setVal
    setVal(_18[_a])
end

local function _54(_a)
    _18[_a]=_18[_a] or false
    local wrap=Instance.new("Frame")
    wrap.Size=UDim2.new(1,0,0,_4("Y",30))
    wrap.BackgroundColor3=C.PanelBg2
    wrap.BackgroundTransparency=0.42
    wrap.Parent=_50
    Corner(wrap,8)
    Stroke(wrap,1,C.StrokeWhite,0.58)

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-_4("X",62),1,0)
    lbl.Position=UDim2.new(0,_4("X",6),0,0)
    lbl.BackgroundTransparency=1
    lbl.Text=_a
    lbl.TextColor3=C.TextDim
    lbl.Font=Enum.Font.Gotham
    lbl.TextScaled=true
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Parent=wrap

    local tog=Instance.new("TextButton")
    tog.Size=UDim2.new(0,_4("X",44),0,_4("Y",18))
    tog.Position=UDim2.new(1,-_4("X",50),0.5,-_4("Y",9))
    tog.Font=Enum.Font.GothamBold
    tog.TextScaled=true
    tog.Parent=wrap
    Corner(tog,5)

    local function refresh(_f)
        tog.Text=_f and "ON" or "OFF"
        tog.BackgroundColor3=_f and Color3.fromRGB(30,100,190) or Color3.fromRGB(90,25,45)
        tog.BackgroundTransparency=0.38
        tog.TextColor3=_f and C.AccentBlue or C.Danger
    end

    tog.MouseButton1Click:Connect(function()_18[_a]=not _18[_a]refresh(_18[_a])end)
    refresh(_18[_a])
    _18._toggles[_a]=refresh
end

local function _55(_a,_b)
    local wrap=Instance.new("Frame")
    wrap.Size=UDim2.new(1,0,0,_4("Y",32))
    wrap.BackgroundColor3=C.PanelBg2
    wrap.BackgroundTransparency=0.42
    wrap.Parent=_50
    Corner(wrap,8)

    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,-_4("X",10),1,-_4("Y",6))
    btn.Position=UDim2.new(0,_4("X",5),0,_4("Y",3))
    btn.BackgroundColor3=Color3.fromRGB(40,60,150)
    btn.BackgroundTransparency=0.48
    btn.Text=_a
    btn.TextColor3=C.TextMain
    btn.Font=Enum.Font.GothamBold
    btn.TextScaled=true
    btn.Parent=wrap
    Corner(btn,6)
    Stroke(btn,1,C.StrokeBlue,0.38)
    HoverFade(btn,Color3.fromRGB(55,80,190),Color3.fromRGB(40,60,150),0.32,0.48)
    btn.MouseButton1Click:Connect(function()if typeof(_b)=="function"then _b()end end)
    return btn
end

function _18:EditSlider(_a,_b)local _c=self._sliders[_a]if _c then _c(_b)end end
function _18:EditToggle(_a,_b)local _c=self._toggles[_a]if _c then _18[_a]=_b _c(_b)end end

local _56=_55("Reset Settings",function()end)
_54("Stop Emote When Moving") _54("Looped")
_53("Speed",0,5,_18["Speed"]) _53("Time Position",0,1,_18["Time Position"])
_53("Weight",0,1,_18["Weight"]) _53("Fade In",0,2,_18["Fade In"])
_53("Fade Out",0,2,_18["Fade Out"])
_54("Stop Other Animations On Play") _54("High Priority")

_56.MouseButton1Click:Connect(function()
    _18:EditToggle("Stop Emote When Moving",true)_18:EditToggle("Stop Other Animations On Play",true)_18:EditToggle("High Priority",true)
    _18:EditSlider("Fade In",0.1)_18:EditSlider("Fade Out",0.1)_18:EditSlider("Weight",1)_18:EditSlider("Speed",1)_18:EditSlider("Time Position",0)
    _18:EditToggle("Freeze On Finish",false)_18:EditToggle("Looped",true)
end)

-- ════════════════════════════════════
-- CATALOG CARD
-- ════════════════════════════════════

local _57={{Enum.CatalogSortType.Relevance,"Relevance"},{Enum.CatalogSortType.PriceHighToLow,"Price ↑"},{Enum.CatalogSortType.PriceLowToHigh,"Price ↓"},{Enum.CatalogSortType.MostFavorited,"Favorited"},{Enum.CatalogSortType.RecentlyCreated,"Recent"},{Enum.CatalogSortType.Bestselling,"Bestselling"}}
local _58=1 local _59="" local _60=nil local _61=1 local _TAB=1

local function _62(_a)
    if _isR6 then return{IsFinished=true,GetCurrentPage=function()return{{Id=115314801778772,Name="Dance If Youre The Best",AssetId=115314801778772}}end,AdvanceToNextPageAsync=function()end}end
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

local function _63(_a)
    local card=Instance.new("Frame")
    card.Size=UDim2.new(0,_4("X",108),0,_4("Y",168))
    card.BackgroundColor3=C.CardBg
    card.BackgroundTransparency=0.3
    card.ZIndex=5
    Corner(card,12)
    Stroke(card,1,C.StrokeWhite,0.42)
    Gloss(card,0.78)

    local id=_a.AssetId or _a.Id

    local thumb=Instance.new("ImageLabel")
    thumb.Size=UDim2.new(1,-_4("X",8),0,_4("Y",80))
    thumb.Position=UDim2.new(0,_4("X",4),0,_4("Y",4))
    thumb.BackgroundColor3=Color3.fromRGB(12,18,50)
    thumb.BackgroundTransparency=0.25
    thumb.ScaleType=Enum.ScaleType.Fit
    pcall(function()thumb.Image="rbxthumb://type=Asset&id="..tonumber(id).."&w=150&h=150"end)
    thumb.ZIndex=6
    thumb.Parent=card
    Corner(thumb,8)
    Stroke(thumb,1,C.StrokeWhite,0.6)

    local nameLbl=Instance.new("TextLabel")
    nameLbl.Size=UDim2.new(1,-_4("X",8),0,_4("Y",26))
    nameLbl.Position=UDim2.new(0,_4("X",4),0,_4("Y",87))
    nameLbl.BackgroundTransparency=1
    nameLbl.Text=_a.Name or "Unknown"
    nameLbl.TextScaled=true
    nameLbl.TextWrapped=true
    nameLbl.Font=Enum.Font.GothamBold
    nameLbl.TextColor3=C.TextMain
    nameLbl.ZIndex=6
    nameLbl.Parent=card

    local linkBtn=Instance.new("TextButton")
    linkBtn.Size=UDim2.new(0,_4("X",24),0,_4("Y",18))
    linkBtn.Position=UDim2.new(1,-_4("X",28),0,_4("Y",4))
    linkBtn.BackgroundColor3=C.PanelBg2
    linkBtn.BackgroundTransparency=0.42
    linkBtn.Text="🔗"
    linkBtn.TextScaled=true
    linkBtn.Font=Enum.Font.GothamBold
    linkBtn.TextColor3=C.TextMain
    linkBtn.AutoButtonColor=false
    linkBtn.ZIndex=7
    linkBtn.Parent=card
    Corner(linkBtn,5)
    linkBtn.MouseButton1Click:Connect(function()
        setclipboard("https://www.roblox.com/catalog/"..tonumber(_a.Id))
        linkBtn.Text="✓"
        task.wait(0.7)
        linkBtn.Text="🔗"
    end)

    local playBtn=Instance.new("TextButton")
    playBtn.Size=UDim2.new(0.48,-_4("X",3),0,_4("Y",22))
    playBtn.Position=UDim2.new(0,_4("X",3),1,-_4("Y",25))
    playBtn.BackgroundColor3=Color3.fromRGB(20,90,50)
    playBtn.BackgroundTransparency=0.38
    playBtn.Text="Play"
    playBtn.Font=Enum.Font.GothamBold
    playBtn.TextScaled=true
    playBtn.TextColor3=C.Green
    playBtn.ZIndex=6
    playBtn.Parent=card
    Corner(playBtn,6)
    Stroke(playBtn,1,C.Green,0.38)
    HoverFade(playBtn,Color3.fromRGB(28,120,65),Color3.fromRGB(20,90,50),0.25,0.38)
    playBtn.MouseButton1Click:Connect(function()_24(id)end)

    local saveBtn=Instance.new("TextButton")
    saveBtn.Size=UDim2.new(0.48,-_4("X",3),0,_4("Y",22))
    saveBtn.Position=UDim2.new(0.52,_4("X",1),1,-_4("Y",25))
    saveBtn.BackgroundColor3=Color3.fromRGB(20,55,140)
    saveBtn.BackgroundTransparency=0.38
    saveBtn.Text="Save"
    saveBtn.Font=Enum.Font.GothamBold
    saveBtn.TextScaled=true
    saveBtn.TextColor3=C.AccentBlue
    saveBtn.ZIndex=6
    saveBtn.Parent=card
    Corner(saveBtn,6)
    Stroke(saveBtn,1,C.AccentBlue,0.38)
    HoverFade(saveBtn,Color3.fromRGB(28,72,180),Color3.fromRGB(20,55,140),0.25,0.38)
    saveBtn.MouseButton1Click:Connect(function()
        local found=false
        for _,v in ipairs(_19)do if v.Id==_a.Id then found=true break end end
        if not found then
            local real=GetReal(id)
            table.insert(_19,{Id=_a.Id,AssetId=id,Name=_a.Name or "Unknown",AnimationId="rbxassetid://"..tostring(real or id),Favorite=false})
            _22()
            saveBtn.Text="✓"
            saveBtn.TextColor3=C.Green
            task.wait(1)
            saveBtn.Text="Save"
            saveBtn.TextColor3=C.AccentBlue
        else
            saveBtn.Text="Exists"
            task.wait(0.7)
            saveBtn.Text="Save"
        end
    end)

    PopIn(card)
    return card
end

-- ════════════════════════════════════
-- CATALOG LOGIC
-- ════════════════════════════════════

local function _71()
    _67.Visible=(_61>1)
    if _60 and typeof(_60.IsFinished)=="boolean" then _68.Visible=not _60.IsFinished else _68.Visible=true end
end

local _73_id=0
local function _73(_a)
    _73_id=_73_id+1
    local myId=_73_id
    _69.Text="..."
    for _,c in ipairs(_64:GetChildren())do if c:IsA("Frame")then c:Destroy()end end
    local data
    local ok,res=pcall(function()return _a:GetCurrentPage()end)
    if ok then data=res else _69.Text="ERR" return end
    if myId~=_73_id then return end
    if data and #data>0 then
        _66.Visible=false
        local myTAB=_TAB
        local count=0
        for _,h in ipairs(data)do
            if _TAB~=myTAB or myId~=_73_id then break end
            _63(h).Parent=_64
            count=count+1
            if count%2==0 then _9.RenderStepped:Wait()end
        end
    else _66.Visible=true end
    if myId==_73_id then
        _64.CanvasSize=UDim2.new(0,0,0,_65.AbsoluteContentSize.Y+8)
        _69.Text=tostring(_61)
        _71()
    end
end

local function _74(_a)local b=_62(_59)if not b then return nil end for i=2,_a do if b.IsFinished then break end local ok,_=pcall(function()b:AdvanceToNextPageAsync()end)if not ok then break end end return b end
local function _75(_a)_59=_a or ""_61=1 _69.Text="..."_60=_62(_59)if _60 then _73(_60)end end

_41.MouseButton1Click:Connect(function()_75(_40.Text)end)
_40.FocusLost:Connect(function(e)if e then _75(_40.Text)end end)
_42.MouseButton1Click:Connect(function()_58=_58%#_57+1 _42.Text="Sort: ".._57[_58][2]_75(_59)end)

local function _76()if not _60 or _60.IsFinished then return end local ok,_=pcall(function()_60:AdvanceToNextPageAsync()end)if ok then _61+=1 _73(_60)else local pg=_61+1 local nb=_74(pg)if nb then _60=nb _61=math.min(pg,_61+1)_73(_60)end end end
local function _77()if not _60 or _61<=1 then return end local ok,_=pcall(function()_60:AdvanceToPreviousPageAsync()end)if ok then _61=math.max(1,_61-1)_73(_60)else local pg=math.max(1,_61-1)local nb=_74(pg)if nb then _60=nb _61=pg _73(_60)end end end

_68.MouseButton1Click:Connect(_76)
_67.MouseButton1Click:Connect(_77)
_10.InputBegan:Connect(function(_a,_b)if _b then return end if _a.UserInputType==Enum.UserInputType.Keyboard and _a.KeyCode==Enum.KeyCode.Right then _76()elseif _a.KeyCode==Enum.KeyCode.Left then _77()end end)
_69.FocusLost:Connect(function(e)if not e then return end local s=_69.Text:gsub("%s+","")local n=tonumber(s:match("%d+"))if not n or n<1 then _70.Text="Invalid"_70.Visible=true task.delay(2,function()if _70 then _70.Visible=false end end)_69.Text=tostring(_61)return end local pg=math.floor(n)if pg==_61 then _69.Text=tostring(_61)return end _69.Text="..."local ok,nb=pcall(function()return _74(pg)end)if not ok or not nb then _70.Text="Not found"_70.Visible=true task.delay(2,function()if _70 then _70.Visible=false end end)_69.Text=tostring(_61)return end _60=nb _61=math.max(1,pg)_73(_60)end)

-- ════════════════════════════════════
-- SAVED CARD
-- ════════════════════════════════════

local function _78(_a)
    local card=Instance.new("Frame")
    card.Size=UDim2.new(0,_4("X",108),0,_4("Y",185))
    card.BackgroundColor3=C.CardBgSaved
    card.BackgroundTransparency=0.3
    card.ZIndex=5
    Corner(card,12)
    Stroke(card,1,C.StrokeGreen,0.42)
    Gloss(card,0.78)

    local thumb=Instance.new("ImageLabel")
    thumb.Size=UDim2.new(1,-_4("X",8),0,_4("Y",80))
    thumb.Position=UDim2.new(0,_4("X",4),0,_4("Y",4))
    thumb.BackgroundColor3=Color3.fromRGB(8,24,16)
    thumb.BackgroundTransparency=0.22
    thumb.ScaleType=Enum.ScaleType.Fit
    thumb.Image="rbxthumb://type=Asset&id=11768914234&w=150&h=150"
    thumb.ZIndex=6
    thumb.Parent=card
    Corner(thumb,8)

    local nameLbl=Instance.new("TextLabel")
    nameLbl.Size=UDim2.new(1,-_4("X",8),0,_4("Y",22))
    nameLbl.Position=UDim2.new(0,_4("X",4),0,_4("Y",87))
    nameLbl.BackgroundTransparency=1
    nameLbl.Text=_a.Name or "Unknown"
    nameLbl.TextScaled=true
    nameLbl.TextWrapped=true
    nameLbl.Font=Enum.Font.GothamBold
    nameLbl.TextColor3=C.Green
    nameLbl.ZIndex=6
    nameLbl.Parent=card

    local star=Instance.new("TextButton")
    star.Size=UDim2.new(0,_4("X",20),0,_4("Y",20))
    star.Position=UDim2.new(1,-_4("X",24),0,_4("Y",4))
    star.Text=_a.Favorite and "★" or "☆"
    star.Font=Enum.Font.GothamBold
    star.TextScaled=true
    star.TextColor3=C.Gold
    star.BackgroundTransparency=1
    star.ZIndex=7
    star.Parent=card
    star.MouseButton1Click:Connect(function()_a.Favorite=not _a.Favorite star.Text=_a.Favorite and "★" or "☆" _22()_80()end)

    local copyBtn=Instance.new("TextButton")
    copyBtn.Size=UDim2.new(1,-_4("X",8),0,_4("Y",17))
    copyBtn.Position=UDim2.new(0,_4("X",4),0,_4("Y",113))
    copyBtn.BackgroundColor3=C.PanelBg2
    copyBtn.BackgroundTransparency=0.42
    copyBtn.Text="Copy ID"
    copyBtn.Font=Enum.Font.GothamBold
    copyBtn.TextScaled=true
    copyBtn.TextColor3=C.TextDim
    copyBtn.ZIndex=6
    copyBtn.Parent=card
    Corner(copyBtn,5)
    Stroke(copyBtn,1,C.StrokeWhite,0.55)
    copyBtn.MouseButton1Click:Connect(function()if setclipboard then setclipboard(_a.AnimationId:gsub("rbxassetid://",""))end copyBtn.Text="Copied!"task.wait(0.7)copyBtn.Text="Copy ID"end)

    local playBtn=Instance.new("TextButton")
    playBtn.Size=UDim2.new(0.48,-_4("X",3),0,_4("Y",22))
    playBtn.Position=UDim2.new(0,_4("X",3),1,-_4("Y",25))
    playBtn.BackgroundColor3=Color3.fromRGB(20,90,50)
    playBtn.BackgroundTransparency=0.38
    playBtn.Text="Play"
    playBtn.Font=Enum.Font.GothamBold
    playBtn.TextScaled=true
    playBtn.TextColor3=C.Green
    playBtn.ZIndex=6
    playBtn.Parent=card
    Corner(playBtn,6)
    Stroke(playBtn,1,C.Green,0.38)
    HoverFade(playBtn,Color3.fromRGB(28,120,65),Color3.fromRGB(20,90,50),0.25,0.38)
    playBtn.MouseButton1Click:Connect(function()_24(_a.Id)end)

    local rmBtn=Instance.new("TextButton")
    rmBtn.Size=UDim2.new(0.48,-_4("X",3),0,_4("Y",22))
    rmBtn.Position=UDim2.new(0.52,_4("X",1),1,-_4("Y",25))
    rmBtn.BackgroundColor3=Color3.fromRGB(90,20,32)
    rmBtn.BackgroundTransparency=0.38
    rmBtn.Text="Remove"
    rmBtn.Font=Enum.Font.GothamBold
    rmBtn.TextScaled=true
    rmBtn.TextColor3=C.Danger
    rmBtn.ZIndex=6
    rmBtn.Parent=card
    Corner(rmBtn,6)
    Stroke(rmBtn,1,C.Danger,0.42)
    HoverFade(rmBtn,Color3.fromRGB(130,28,42),Color3.fromRGB(90,20,32),0.25,0.38)
    rmBtn.MouseButton1Click:Connect(function()for i,v in ipairs(_19)do if v.Id==_a.Id then table.remove(_19,i)_22()_80()break end end end)

    PopIn(card)
    return card
end

-- ════════════════════════════════════
-- SAVED RENDER
-- ════════════════════════════════════

local _80_id=0
function _80()
    _80_id=_80_id+1
    local myId=_80_id
    for _,c in ipairs(_45:GetChildren())do if c:IsA("Frame")then c:Destroy()end end
    local q=(_44.Text or ""):lower()
    local filtered={}
    for _,v in ipairs(_19)do if q=="" or(v.Name and v.Name:lower():find(q))then table.insert(filtered,v)end end
    table.sort(filtered,function(a,b)if a.Favorite~=b.Favorite then return a.Favorite else return false end end)
    if #filtered>0 then
        _46.Visible=false
        local myTAB=_TAB
        local count=0
        for _,v in ipairs(filtered)do
            if _TAB~=myTAB or myId~=_80_id then break end
            _78(v).Parent=_45
            count=count+1
            if count%25==0 then _9.RenderStepped:Wait()end
        end
    else _46.Visible=true end
    if myId==_80_id then _45.CanvasSize=UDim2.new(0,0,0,_47.AbsoluteContentSize.Y+8)end
end

-- ════════════════════════════════════
-- TAB SWITCHING
-- ════════════════════════════════════

local function SetTab(toCatalog)
    _TAB+=1
    _39.Visible=toCatalog
    _43.Visible=not toCatalog
    _36.BackgroundTransparency=toCatalog and 0.38 or 0.62
    _36.TextColor3=toCatalog and C.TextMain or C.TextDim
    _37.BackgroundTransparency=toCatalog and 0.62 or 0.38
    _37.TextColor3=toCatalog and C.TextDim or C.TextMain
    if not toCatalog then _80()end
end

_36.MouseButton1Click:Connect(function()SetTab(true)end)
_37.MouseButton1Click:Connect(function()SetTab(false)end)
_44:GetPropertyChangedSignal("Text"):Connect(_80)

-- ════════════════════════════════════
-- FOOTER
-- ════════════════════════════════════

local footer=Instance.new("TextLabel")
footer.Size=UDim2.new(1,0,0,_4("Y",13))
footer.Position=UDim2.new(0,0,1,-_4("Y",15))
footer.BackgroundTransparency=1
footer.Text="vertelvsepoel"
footer.TextColor3=C.TextFaint
footer.TextTransparency=0.35
footer.Font=Enum.Font.Gotham
footer.TextScaled=true
footer.ZIndex=4
footer.Parent=_30

-- ════════════════════════════════════
-- TOGGLE BUTTON (G key)
-- ════════════════════════════════════

local _79=_26
local function _81()
    if _79.Enabled then
        _11:Create(_30,TweenInfo.new(0.18,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{BackgroundTransparency=1}):Play()
        task.wait(0.2)
    end
    _79.Enabled=not _79.Enabled
    if _79.Enabled then
        _30.BackgroundTransparency=0.22
        local sc=Instance.new("UIScale")sc.Scale=0.88 sc.Parent=_30
        _11:Create(sc,TweenInfo.new(0.24,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
        task.delay(0.28,function()if sc and sc.Parent then sc:Destroy()end end)
        Shimmer(_30)
    end
end

local _82=Instance.new("ScreenGui")
_82.Name="ToggleGui_Glass"
_82.ResetOnSpawn=false
_82.Parent=_25
_82.Enabled=true

local tBtn=Instance.new("TextButton")
tBtn.Parent=_82
tBtn.Text="✦"
tBtn.Font=Enum.Font.GothamBold
tBtn.TextScaled=true
tBtn.Size=UDim2.new(0,46,0,46)
tBtn.Position=UDim2.new(0,16,0.5,-46)
tBtn.AnchorPoint=Vector2.new(0,0.5)
tBtn.BackgroundColor3=C.PanelBg
tBtn.BackgroundTransparency=0.22
tBtn.TextColor3=C.TextMain
tBtn.Active=true
pcall(function()tBtn.Draggable=true end)
Corner(tBtn,12)
Stroke(tBtn,1.5,C.StrokeWhite,0.3)
Gloss(tBtn,0.65)

-- Subtle toggle button shimmer on hover
tBtn.MouseEnter:Connect(function()Shimmer(tBtn)end)

local _84=Instance.new("UIAspectRatioConstraint")
_84.Parent=tBtn
_84.AspectRatio=1

tBtn.MouseButton1Click:Connect(_81)
_10.InputBegan:Connect(function(_a,_b)
    if _b then return end
    if _a.UserInputType==Enum.UserInputType.Keyboard and _a.KeyCode==Enum.KeyCode.G then _81()end
end)

_26.Enabled=true
_80()
_75("")

-- ════════════════════════════════════
-- NO-COLLISION
-- ════════════════════════════════════

task.spawn(function()
    local RS=game:GetService("RunService")
    local pl=_8.LocalPlayer
    local function setup(ch)
        local hrp=ch:WaitForChild("HumanoidRootPart")
        local parts={}
        hrp.CanCollide=true
        local function add(p)if p:IsA("BasePart")and p~=hrp then table.insert(parts,p)end end
        for _,p in pairs(ch:GetDescendants())do add(p)end
        local dc=ch.DescendantAdded:Connect(add)
        local hc
        hc=RS.Heartbeat:Connect(function()
            if not ch or not ch.Parent then hc:Disconnect()dc:Disconnect()return end
            for i=1,#parts do local p=parts[i]if p and p.Parent then p.CanCollide=false end end
        end)
    end
    if pl.Character then setup(pl.Character)end
    pl.CharacterAdded:Connect(setup)
end)
