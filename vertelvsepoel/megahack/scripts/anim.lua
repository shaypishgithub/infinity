
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

_14.CharacterAdded:Connect(function(_a)
    _15=_a _16=_a:WaitForChild("Humanoid")_isR6=_16.RigType==Enum.HumanoidRigType.R6
    if _35_Ref then _35_Ref.Text=_isR6 and "GAZE EMOTES [R6]" or "GAZE EMOTES" end
    if _36_Ref then _36_Ref.Text=_isR6 and "Anim" or "Catalog" end
    if _37_Ref then _37_Ref.Visible=not _isR6 end
    if _isR6 and _39_Ref and _43_Ref then
        _39_Ref.Visible=true _43_Ref.Visible=false
        _36_Ref.BackgroundColor3=Color3.fromRGB(20,10,50)
        _37_Ref.BackgroundColor3=Color3.fromRGB(10,30,10)
    end
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

-- ════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ════════════════════════════════════════════

local function MakeCorner(_p,_r)
    local c=Instance.new("UICorner")c.CornerRadius=UDim.new(0,_r or 8)c.Parent=_p return c
end

-- Animated gradient stroke via UIGradient + UIStroke
local function MakeNeonStroke(_p, _thickness)
    local s=Instance.new("UIStroke")
    s.Thickness=_thickness or 1.5
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    s.Color=Color3.fromRGB(100,60,255)
    s.Parent=_p
    -- Animate hue
    local hue=0
    _9.RenderStepped:Connect(function(dt)
        hue=(hue+dt*0.4)%1
        s.Color=Color3.fromHSV(hue,0.8,1)
    end)
    return s
end

local function MakeShadowStroke(_p)
    local s=Instance.new("UIStroke")
    s.Thickness=1
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    s.Color=Color3.fromRGB(40,20,100)
    s.Parent=_p
    return s
end

local function PopIn(_a)
    local sc=Instance.new("UIScale")sc.Scale=0.4 sc.Parent=_a
    _11:Create(sc,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
end

-- Pulsing glow effect on a frame
local function PulseGlow(_frame, _col1, _col2)
    local s=Instance.new("UIStroke")
    s.Thickness=2
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    s.Color=_col1 or Color3.fromRGB(80,40,200)
    s.Parent=_frame
    local forward=true
    task.spawn(function()
        while _frame and _frame.Parent do
            local target=forward and (_col2 or Color3.fromRGB(0,180,255)) or (_col1 or Color3.fromRGB(80,40,200))
            _11:Create(s,TweenInfo.new(1.2,Enum.EasingStyle.Sine),{Color=target}):Play()
            forward=not forward
            task.wait(1.2)
        end
    end)
    return s
end

-- Scanline animation on a frame
local function AddScanline(_parent)
    local line=Instance.new("Frame")
    line.Size=UDim2.new(1,0,0,2)
    line.BackgroundColor3=Color3.fromRGB(255,255,255)
    line.BackgroundTransparency=0.92
    line.BorderSizePixel=0
    line.ZIndex=20
    line.Parent=_parent
    task.spawn(function()
        while line and line.Parent do
            line.Position=UDim2.new(0,0,0,0)
            _11:Create(line,TweenInfo.new(3,Enum.EasingStyle.Linear),{Position=UDim2.new(0,0,1,-2)}):Play()
            task.wait(3.1)
        end
    end)
end

-- ════════════════════════════════════════════
-- SERVICES & GUI ROOT
-- ════════════════════════════════════════════

local _25=_7.CoreGui

local _26=Instance.new("ScreenGui")
_26.Name="GazeEmoteGUI_VERTEL"
_26.Parent=_25
_26.Enabled=false
_26.DisplayOrder=999
_26.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

-- Main window
local _30=Instance.new("Frame")
_30.Size=UDim2.new(0,_4("X",490),0,_4("Y",460))
_30.Position=UDim2.new(0.5,-_4("X",340),0.5,-_4("Y",230))
_30.BackgroundColor3=Color3.fromRGB(8,8,14)
_30.BackgroundTransparency=0.05
_30.Active=true
_30.Draggable=true
_30.Parent=_26
MakeCorner(_30,12)
MakeNeonStroke(_30, 1.5)
AddScanline(_30)

-- Corner decorations (4 corners)
local function CornerDeco(_parent, _xA, _yA)
    local f=Instance.new("Frame")
    f.Size=UDim2.new(0,14,0,14)
    f.AnchorPoint=Vector2.new(_xA,_yA)
    f.Position=UDim2.new(_xA,_xA==0 and 6 or -6, _yA, _yA==0 and 6 or -6)
    f.BackgroundTransparency=1
    f.ZIndex=15
    f.Parent=_parent
    -- Two lines for L-shape
    local h=Instance.new("Frame")h.Size=UDim2.new(1,0,0,1)h.BackgroundColor3=Color3.fromRGB(120,60,255)h.BorderSizePixel=0 h.Parent=f
    local v=Instance.new("Frame")v.Size=UDim2.new(0,1,1,0)v.BackgroundColor3=Color3.fromRGB(120,60,255)v.BorderSizePixel=0 v.Parent=f
    -- Animate color
    local hue=_xA*0.3+_yA*0.5
    _9.RenderStepped:Connect(function(dt)
        hue=(hue+dt*0.5)%1
        local c=Color3.fromHSV(hue,0.9,1)
        h.BackgroundColor3=c v.BackgroundColor3=c
    end)
end
CornerDeco(_30,0,0) CornerDeco(_30,1,0) CornerDeco(_30,0,1) CornerDeco(_30,1,1)

-- Resize handle
local _31=Instance.new("TextButton")
_31.Size=UDim2.new(0,22,0,22)
_31.Position=UDim2.new(1,-22,1,-22)
_31.BackgroundTransparency=1
_31.Text="◢"
_31.TextColor3=Color3.fromRGB(80,40,180)
_31.TextSize=16
_31.ZIndex=12
_31.Parent=_30

local _32=false local _33 local _34
_31.InputBegan:Connect(function(_a)if _a.UserInputType==Enum.UserInputType.MouseButton1 or _a.UserInputType==Enum.UserInputType.Touch then _32=true _33=_a.Position _34=_30.AbsoluteSize end end)
_10.InputChanged:Connect(function(_a)if _32 and(_a.UserInputType==Enum.UserInputType.MouseMovement or _a.UserInputType==Enum.UserInputType.Touch)then local _b=_a.Position-_33 local _c=math.max(180,_34.X+_b.X)local _d=math.max(120,_34.Y+_b.Y)_30.Size=UDim2.new(0,_c,0,_d)end end)
_10.InputEnded:Connect(function(_a)if _a.UserInputType==Enum.UserInputType.MouseButton1 or _a.UserInputType==Enum.UserInputType.Touch then _32=false end end)

-- ════════════════════════════════════════════
-- HEADER
-- ════════════════════════════════════════════

local header=Instance.new("Frame")
header.Size=UDim2.new(1,0,0,_4("Y",42))
header.BackgroundColor3=Color3.fromRGB(10,8,20)
header.BorderSizePixel=0
header.ZIndex=5
header.Parent=_30
MakeCorner(header,12)

-- Bottom line of header (animated)
local headerLine=Instance.new("Frame")
headerLine.Size=UDim2.new(1,0,0,1)
headerLine.Position=UDim2.new(0,0,1,-1)
headerLine.BorderSizePixel=0
headerLine.ZIndex=6
headerLine.Parent=header
local lineHue=0
_9.RenderStepped:Connect(function(dt)
    lineHue=(lineHue+dt*0.6)%1
    headerLine.BackgroundColor3=Color3.fromHSV(lineHue,0.9,1)
end)

-- Brand: "vertelvsepoel" sub-label
local brandSub=Instance.new("TextLabel")
brandSub.Size=UDim2.new(0.6,0,0,_4("Y",12))
brandSub.Position=UDim2.new(0,_4("X",14),0,_4("Y",5))
brandSub.BackgroundTransparency=1
brandSub.Text="vertelvsepoel"
brandSub.TextColor3=Color3.fromRGB(100,60,220)
brandSub.Font=Enum.Font.GothamBold
brandSub.TextScaled=true
brandSub.TextXAlignment=Enum.TextXAlignment.Left
brandSub.ZIndex=6
brandSub.Parent=header
-- Animate color
local subHue=0.75
_9.RenderStepped:Connect(function(dt)
    subHue=(subHue+dt*0.3)%1
    brandSub.TextColor3=Color3.fromHSV(subHue,0.85,1)
end)

-- Main title
local _35=Instance.new("TextLabel")
_35_Ref=_35
_35.Size=UDim2.new(0.65,0,0,_4("Y",22))
_35.Position=UDim2.new(0,_4("X",14),0,_4("Y",16))
_35.BackgroundTransparency=1
_35.Text=_isR6 and "GAZE EMOTES [R6]" or "GAZE EMOTES"
_35.TextColor3=Color3.fromRGB(255,255,255)
_35.Font=Enum.Font.GothamBold
_35.TextScaled=true
_35.TextXAlignment=Enum.TextXAlignment.Left
_35.ZIndex=6
_35.Parent=header
-- Title neon pulse
local titleHue=0
_9.RenderStepped:Connect(function(dt)
    titleHue=(titleHue+dt*0.4)%1
    _35.TextColor3=Color3.fromHSV(titleHue,0.5,1)
end)

-- Rig badge
local rigBadge=Instance.new("TextLabel")
rigBadge.Size=UDim2.new(0,_4("X",42),0,_4("Y",18))
rigBadge.Position=UDim2.new(1,-_4("X",86),0.5,-_4("Y",9))
rigBadge.BackgroundColor3=Color3.fromRGB(18,10,40)
rigBadge.TextColor3=Color3.fromRGB(140,80,255)
rigBadge.Text=_isR6 and "R6" or "R15"
rigBadge.Font=Enum.Font.GothamBold
rigBadge.TextScaled=true
rigBadge.ZIndex=7
rigBadge.Parent=header
MakeCorner(rigBadge,4)
MakeShadowStroke(rigBadge)

-- Close / toggle button (X in header)
local closeBtn=Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,_4("X",26),0,_4("Y",26))
closeBtn.Position=UDim2.new(1,-_4("X",36),0.5,-_4("Y",13))
closeBtn.BackgroundColor3=Color3.fromRGB(40,10,20)
closeBtn.TextColor3=Color3.fromRGB(255,60,100)
closeBtn.Text="✕"
closeBtn.Font=Enum.Font.GothamBold
closeBtn.TextScaled=true
closeBtn.ZIndex=7
closeBtn.Parent=header
MakeCorner(closeBtn,13)
PulseGlow(closeBtn, Color3.fromRGB(200,20,60), Color3.fromRGB(255,80,120))
closeBtn.MouseButton1Click:Connect(function()
    _11:Create(_26,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{})
    _26.Enabled=false
end)

-- ════════════════════════════════════════════
-- TAB BUTTONS
-- ════════════════════════════════════════════

local tabRow=Instance.new("Frame")
tabRow.Size=UDim2.new(1,0,0,_4("Y",28))
tabRow.Position=UDim2.new(0,0,0,_4("Y",42))
tabRow.BackgroundColor3=Color3.fromRGB(8,6,18)
tabRow.BorderSizePixel=0
tabRow.ZIndex=5
tabRow.Parent=_30

local function MakeTab(_text, _xPos, _w, _activeCol, _inactiveCol)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(_w,0,1,-4)
    btn.Position=UDim2.new(_xPos,0,0,2)
    btn.BackgroundColor3=_inactiveCol or Color3.fromRGB(12,10,28)
    btn.TextColor3=Color3.fromRGB(160,130,255)
    btn.Text=_text
    btn.Font=Enum.Font.GothamBold
    btn.TextScaled=true
    btn.ZIndex=6
    btn.Parent=tabRow
    MakeCorner(btn,6)
    MakeShadowStroke(btn)
    return btn
end

local _36=MakeTab(_isR6 and "Anim" or "Catalog", 0.02, 0.28, Color3.fromRGB(20,10,55), Color3.fromRGB(16,10,40))
_36_Ref=_36
local _37=MakeTab("Saved", 0.32, 0.28, Color3.fromRGB(10,28,14), Color3.fromRGB(10,20,12))
_37_Ref=_37
_37.Visible=not _isR6

local tabLine=Instance.new("Frame")
tabLine.Size=UDim2.new(1,0,0,1)
tabLine.Position=UDim2.new(0,0,1,-1)
tabLine.BorderSizePixel=0
tabLine.ZIndex=6
tabLine.Parent=tabRow
local tlHue=0.6
_9.RenderStepped:Connect(function(dt)
    tlHue=(tlHue+dt*0.5)%1
    tabLine.BackgroundColor3=Color3.fromHSV(tlHue,0.9,0.7)
end)

-- ════════════════════════════════════════════
-- DIVIDER (vertical)
-- ════════════════════════════════════════════

local divY=_4("Y",70)
local _38=Instance.new("Frame")
_38.Size=UDim2.new(0,1,1,-divY)
_38.Position=UDim2.new(0.6,0,0,divY)
_38.BackgroundColor3=Color3.fromRGB(30,15,80)
_38.BorderSizePixel=0
_38.ZIndex=4
_38.Parent=_30
local divHue=0.75
_9.RenderStepped:Connect(function(dt)
    divHue=(divHue+dt*0.4)%1
    _38.BackgroundColor3=Color3.fromHSV(divHue,0.8,0.7)
end)

-- ════════════════════════════════════════════
-- CATALOG PANEL (left)
-- ════════════════════════════════════════════

local _39=Instance.new("Frame")
_39_Ref=_39
_39.Size=UDim2.new(0.6,-_4("X",10),1,-divY)
_39.Position=UDim2.new(0,_4("X",5),0,divY)
_39.BackgroundTransparency=1
_39.Visible=true
_39.ZIndex=3
_39.Parent=_30

-- Search box
local _40=Instance.new("TextBox")
_40.Size=UDim2.new(0.57,-_4("X",8),0,_4("Y",26))
_40.Position=UDim2.new(0,_4("X",6),0,_4("Y",4))
_40.PlaceholderText="Search emotes..."
_40.BackgroundColor3=Color3.fromRGB(10,8,22)
_40.BackgroundTransparency=0.2
_40.TextColor3=Color3.fromRGB(200,180,255)
_40.PlaceholderColor3=Color3.fromRGB(60,40,120)
_40.Font=Enum.Font.Gotham
_40.TextScaled=true
_40.ClearTextOnFocus=false
_40.Text=""
_40.ZIndex=4
_40.Parent=_39
MakeCorner(_40,6)
MakeShadowStroke(_40)

local _41=Instance.new("TextButton")
_41.Size=UDim2.new(0.22,-_4("X",4),0,_4("Y",26))
_41.Position=UDim2.new(0.57,_4("X",4),0,_4("Y",4))
_41.BackgroundColor3=Color3.fromRGB(10,20,70)
_41.BackgroundTransparency=0.1
_41.Text="Refresh"
_41.Font=Enum.Font.GothamBold
_41.TextScaled=true
_41.TextColor3=Color3.fromRGB(100,160,255)
_41.ZIndex=4
_41.Parent=_39
MakeCorner(_41,6)
PulseGlow(_41, Color3.fromRGB(20,40,150), Color3.fromRGB(40,80,255))

local _42=Instance.new("TextButton")
_42.Size=UDim2.new(0.21,-_4("X",4),0,_4("Y",26))
_42.Position=UDim2.new(0.79,_4("X",2),0,_4("Y",4))
_42.BackgroundColor3=Color3.fromRGB(20,10,50)
_42.BackgroundTransparency=0.2
_42.Text="Sort"
_42.Font=Enum.Font.GothamBold
_42.TextScaled=true
_42.TextColor3=Color3.fromRGB(160,100,255)
_42.ZIndex=4
_42.Parent=_39
MakeCorner(_42,6)
MakeShadowStroke(_42)

-- Emote grid scroll
local _64=Instance.new("ScrollingFrame")
_64.Size=UDim2.new(1,-_4("X",12),1,-_4("Y",62))
_64.Position=UDim2.new(0,_4("X",6),0,_4("Y",34))
_64.CanvasSize=UDim2.new(0,0,0,0)
_64.ScrollBarThickness=3
_64.ScrollBarImageColor3=Color3.fromRGB(80,40,180)
_64.BackgroundTransparency=1
_64.ZIndex=4
_64.Parent=_39

local _65=Instance.new("UIGridLayout",_64)
_65.CellSize=UDim2.new(0,_4("X",110),0,_4("Y",175))
_65.CellPadding=UDim2.new(0,_4("X",7),0,_4("Y",7))
_65.HorizontalAlignment=Enum.HorizontalAlignment.Center

local _66=Instance.new("TextLabel",_64)
_66.Size=UDim2.new(1,0,0,_4("Y",36))
_66.Position=UDim2.new(0,0,0.5,-_4("Y",18))
_66.BackgroundTransparency=1
_66.Text="Nothing found :3"
_66.TextColor3=Color3.fromRGB(80,50,160)
_66.Font=Enum.Font.GothamBold
_66.TextScaled=true
_66.Visible=false
_66.ZIndex=5

-- Page nav
local _67=Instance.new("TextButton",_39)
_67.Size=UDim2.new(0.38,-_4("X",4),0,_4("Y",28))
_67.Position=UDim2.new(0,_4("X",4),1,-_4("Y",32))
_67.BackgroundColor3=Color3.fromRGB(14,8,38)
_67.BackgroundTransparency=0.1
_67.Text="← Prev"
_67.Font=Enum.Font.GothamBold
_67.TextScaled=true
_67.TextColor3=Color3.fromRGB(140,80,255)
_67.ZIndex=4
MakeCorner(_67,6)
MakeShadowStroke(_67)

local _68=Instance.new("TextButton",_39)
_68.Size=UDim2.new(0.38,-_4("X",4),0,_4("Y",28))
_68.Position=UDim2.new(0.62,_4("X",2),1,-_4("Y",32))
_68.BackgroundColor3=Color3.fromRGB(14,8,38)
_68.BackgroundTransparency=0.1
_68.Text="Next →"
_68.Font=Enum.Font.GothamBold
_68.TextScaled=true
_68.TextColor3=Color3.fromRGB(140,80,255)
_68.ZIndex=4
MakeCorner(_68,6)
MakeShadowStroke(_68)

local _69=Instance.new("TextBox",_39)
_69.Size=UDim2.new(0.24,0,0,_4("Y",28))
_69.Position=UDim2.new(0.38,_4("X",2),1,-_4("Y",32))
_69.BackgroundTransparency=1
_69.Font=Enum.Font.Gotham
_69.TextScaled=true
_69.TextColor3=Color3.fromRGB(120,80,220)
_69.Text="1"
_69.ZIndex=4

local _70=Instance.new("TextLabel",_39)
_70.Size=UDim2.new(0.5,0,0,_4("Y",22))
_70.Position=UDim2.new(0.25,0,1,-_4("Y",60))
_70.BackgroundTransparency=1
_70.TextColor3=Color3.fromRGB(255,80,80)
_70.Font=Enum.Font.Gotham
_70.TextScaled=true
_70.Text=""
_70.Visible=false
_70.ZIndex=5

-- ════════════════════════════════════════════
-- SAVED PANEL (left alternate)
-- ════════════════════════════════════════════

local _43=Instance.new("Frame")
_43_Ref=_43
_43.Size=UDim2.new(0.6,-_4("X",10),1,-divY)
_43.Position=UDim2.new(0,_4("X",5),0,divY)
_43.BackgroundTransparency=1
_43.Visible=false
_43.ZIndex=3
_43.Parent=_30

local _44=Instance.new("TextBox")
_44.Size=UDim2.new(0.55,-_4("X",12),0,_4("Y",26))
_44.Position=UDim2.new(0,_4("X",6),0,_4("Y",4))
_44.PlaceholderText="Search saved..."
_44.BackgroundColor3=Color3.fromRGB(10,8,22)
_44.BackgroundTransparency=0.2
_44.TextColor3=Color3.fromRGB(150,255,180)
_44.PlaceholderColor3=Color3.fromRGB(40,100,60)
_44.Font=Enum.Font.Gotham
_44.TextScaled=true
_44.ClearTextOnFocus=false
_44.Text=""
_44.ZIndex=4
_44.Parent=_43
MakeCorner(_44,6)
MakeShadowStroke(_44)

local _44a=Instance.new("TextBox")
_44a.Size=UDim2.new(0.26,0,0,_4("Y",26))
_44a.Position=UDim2.new(0.55,_4("X",4),0,_4("Y",4))
_44a.PlaceholderText="Emote ID"
_44a.BackgroundColor3=Color3.fromRGB(10,8,22)
_44a.BackgroundTransparency=0.2
_44a.TextColor3=Color3.fromRGB(150,255,180)
_44a.PlaceholderColor3=Color3.fromRGB(40,80,60)
_44a.Font=Enum.Font.Gotham
_44a.TextScaled=true
_44a.ClearTextOnFocus=false
_44a.Text=""
_44a.ZIndex=4
_44a.Parent=_43
MakeCorner(_44a,6)
MakeShadowStroke(_44a)

local _44b=Instance.new("TextButton")
_44b.Size=UDim2.new(0.09,0,0,_4("Y",26))
_44b.Position=UDim2.new(0.91,_4("X",2),0,_4("Y",4))
_44b.BackgroundColor3=Color3.fromRGB(10,35,60)
_44b.BackgroundTransparency=0.1
_44b.Text="+"
_44b.Font=Enum.Font.GothamBold
_44b.TextScaled=true
_44b.TextColor3=Color3.fromRGB(80,200,255)
_44b.ZIndex=4
_44b.Parent=_43
MakeCorner(_44b,6)
PulseGlow(_44b, Color3.fromRGB(20,80,140), Color3.fromRGB(40,160,255))

local _45=Instance.new("ScrollingFrame")
_45.Size=UDim2.new(1,-_4("X",12),1,-_4("Y",38))
_45.Position=UDim2.new(0,_4("X",6),0,_4("Y",34))
_45.CanvasSize=UDim2.new(0,0,0,0)
_45.ScrollBarThickness=3
_45.ScrollBarImageColor3=Color3.fromRGB(40,160,100)
_45.BackgroundTransparency=1
_45.ZIndex=4
_45.Parent=_43

local _46=Instance.new("TextLabel")
_46.Size=UDim2.new(1,0,0,_4("Y",36))
_46.Position=UDim2.new(0,0,0.5,-_4("Y",18))
_46.BackgroundTransparency=1
_46.Text="No saved emotes yet"
_46.TextColor3=Color3.fromRGB(50,120,70)
_46.Font=Enum.Font.GothamBold
_46.TextScaled=true
_46.Visible=false
_46.Parent=_45
_46.ZIndex=5

local _47=Instance.new("UIGridLayout")
_47.CellSize=UDim2.new(0,_4("X",110),0,_4("Y",190))
_47.CellPadding=UDim2.new(0,_4("X",7),0,_4("Y",7))
_47.HorizontalAlignment=Enum.HorizontalAlignment.Center
_47.Parent=_45

-- ════════════════════════════════════════════
-- SETTINGS PANEL (right)
-- ════════════════════════════════════════════

local _48=Instance.new("Frame")
_48.Size=UDim2.new(0.4,-_4("X",8),1,-divY)
_48.Position=UDim2.new(0.6,_4("X",4),0,divY)
_48.BackgroundTransparency=1
_48.ZIndex=3
_48.Parent=_30

-- Settings header label
local _49=Instance.new("TextLabel")
_49.Size=UDim2.new(1,0,0,_4("Y",22))
_49.Position=UDim2.new(0,0,0,_4("Y",4))
_49.BackgroundTransparency=1
_49.Text="SETTINGS"
_49.TextColor3=Color3.fromRGB(100,60,200)
_49.Font=Enum.Font.GothamBold
_49.TextScaled=true
_49.ZIndex=4
_49.Parent=_48
-- Animate settings label color
local setHue=0.76
_9.RenderStepped:Connect(function(dt)
    setHue=(setHue+dt*0.35)%1
    _49.TextColor3=Color3.fromHSV(setHue,0.8,1)
end)

local _50=Instance.new("ScrollingFrame")
_50.Size=UDim2.new(1,-_4("X",8),1,-_4("Y",32))
_50.Position=UDim2.new(0,_4("X",4),0,_4("Y",26))
_50.BackgroundTransparency=1
_50.CanvasSize=UDim2.new(0,0,0,0)
_50.ScrollBarThickness=3
_50.ScrollBarImageColor3=Color3.fromRGB(80,40,160)
_50.ZIndex=4
_50.Parent=_48

local function _51()_50.CanvasPosition=Vector2.new(0,_50.CanvasPosition.Y)end
_50:GetPropertyChangedSignal("CanvasPosition"):Connect(_51)

local _52=Instance.new("UIListLayout",_50)
_52.Padding=UDim.new(0,6)
_52.FillDirection=Enum.FillDirection.Vertical
_52.SortOrder=Enum.SortOrder.LayoutOrder
_52:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    _50.CanvasSize=UDim2.new(0,0,0,_52.AbsoluteContentSize.Y+10)
end)

-- ════════════════════════════════════════════
-- SETTINGS UI BUILDERS
-- ════════════════════════════════════════════

function GetReal(_a)local _b,_c=pcall(function()return game:GetObjects("rbxassetid://"..tostring(_a))end)if _b and _c and #_c>0 then local _d=_c[1]if _d:IsA("Animation")and _d.AnimationId~=""then return tonumber(_d.AnimationId:match("%d+"))elseif _d:FindFirstChildOfClass("Animation")then local _e=_d:FindFirstChildOfClass("Animation")return tonumber(_e.AnimationId:match("%d+"))end end end

_44b.MouseButton1Click:Connect(function()local _a=tonumber(_44a.Text)if _a then local _b=false for _c,_d in ipairs(_19)do if _d.Id==_a then _b=true break end end if not _b then local _e=GetReal(_a)table.insert(_19,{Id=_a,AssetId=_a,Name="ID: ".._a,AnimationId="rbxassetid://"..tostring(_e or _a),Favorite=false})_22()_80()end end end)

_18._sliders={} _18._toggles={}

local function _53(_a,_b,_c,_d)
    _18[_a]=_d or _b
    local _e=Instance.new("Frame")
    _e.Size=UDim2.new(1,0,0,_4("Y",60))
    _e.BackgroundColor3=Color3.fromRGB(10,8,22)
    _e.BackgroundTransparency=0.3
    _e.Parent=_50
    MakeCorner(_e,6)
    MakeShadowStroke(_e)

    local _g=Instance.new("TextLabel")
    _g.Size=UDim2.new(0.55,0,0,_4("Y",18))
    _g.Position=UDim2.new(0,_4("X",8),0,_4("Y",4))
    _g.BackgroundTransparency=1
    _g.Text=string.format("%s: %.2f",_a,_18[_a])
    _g.TextColor3=Color3.fromRGB(180,140,255)
    _g.Font=Enum.Font.Gotham
    _g.TextScaled=true
    _g.TextXAlignment=Enum.TextXAlignment.Left
    _g.Parent=_e

    local _h=Instance.new("TextBox")
    _h.Size=UDim2.new(0.42,0,0,_4("Y",18))
    _h.Position=UDim2.new(0.57,0,0,_4("Y",4))
    _h.BackgroundColor3=Color3.fromRGB(14,10,30)
    _h.Text=tostring(_18[_a])
    _h.TextColor3=Color3.fromRGB(180,140,255)
    _h.Font=Enum.Font.Gotham
    _h.TextScaled=true
    _h.ClearTextOnFocus=false
    _h.Parent=_e
    MakeCorner(_h,4)

    -- Slider track
    local _i=Instance.new("Frame")
    _i.Size=UDim2.new(1,-_4("X",30),0,_4("Y",8))
    _i.Position=UDim2.new(0,_4("X",15),0,_4("Y",33))
    _i.BackgroundColor3=Color3.fromRGB(18,12,40)
    _i.Parent=_e
    MakeCorner(_i,4)

    local _j=Instance.new("Frame")
    _j.Size=UDim2.new(0,0,1,0)
    _j.BackgroundColor3=Color3.fromRGB(80,40,200)
    _j.Parent=_i
    MakeCorner(_j,4)
    -- animate fill color
    local fillHue=0.76
    _9.RenderStepped:Connect(function(dt)
        fillHue=(fillHue+dt*0.5)%1
        _j.BackgroundColor3=Color3.fromHSV(fillHue,0.9,1)
    end)

    local _k=Instance.new("Frame")
    _k.Size=UDim2.new(0,_4("X",16),0,_4("Y",16))
    _k.AnchorPoint=Vector2.new(0.5,0.5)
    _k.Position=UDim2.new(0,0,0.5,0)
    _k.BackgroundColor3=Color3.fromRGB(220,200,255)
    _k.Parent=_i
    MakeCorner(_k,10)
    MakeShadowStroke(_k)

    local function _l(_m)
        local _n=math.clamp(_m,0,1)
        _11:Create(_j,TweenInfo.new(0.12),{Size=UDim2.new(_n,0,1,0)}):Play()
        _11:Create(_k,TweenInfo.new(0.12),{Position=UDim2.new(_n,0,0.5,0)}):Play()
    end

    local function _o(_p)
        _18[_a]=math.clamp(_p,_b,_c)
        _g.Text=string.format("%s: %.2f",_a,_18[_a])
        _h.Text=tostring(_18[_a])
        local _q=(_18[_a]-_b)/(_c-_b)
        _l(_q)
        if _23 and _23.IsPlaying then
            if _a=="Speed"then _23:AdjustSpeed(_18["Speed"])
            elseif _a=="Weight"then local _r=_18["Weight"]if _r==0 then _r=0.001 end _23:AdjustWeight(_r)
            elseif _a=="Time Position"then if _23.Length>0 then _23.TimePosition=math.clamp(_p,0,1)*_23.Length end end
        end
    end

    local _s=false
    local function _t(_u)
        local _v=math.clamp((_u.Position.X-_i.AbsolutePosition.X)/_i.AbsoluteSize.X,0,1)
        local _w=math.floor((_b+(_c-_b)*_v)*100)/100
        _o(_w)
    end

    _i.InputBegan:Connect(function(_x)if _x.UserInputType==Enum.UserInputType.MouseButton1 or _x.UserInputType==Enum.UserInputType.Touch then _s=true _t(_x)end end)
    _k.InputBegan:Connect(function(_y)if _y.UserInputType==Enum.UserInputType.MouseButton1 or _y.UserInputType==Enum.UserInputType.Touch then _s=true _t(_y)end end)
    _10.InputChanged:Connect(function(_z)if _s and(_z.UserInputType==Enum.UserInputType.MouseMovement or _z.UserInputType==Enum.UserInputType.Touch)then _t(_z)end end)
    _10.InputEnded:Connect(function(_A)if _s and(_A.UserInputType==Enum.UserInputType.MouseButton1 or _A.UserInputType==Enum.UserInputType.Touch)then _s=false end end)
    _h.FocusLost:Connect(function(_B)if _B then local _C=tonumber(_h.Text)if _C then _o(_C)else _h.Text=tostring(_18[_a])end end end)
    _18._sliders[_a]=_o
    _o(_18[_a])
end

local function _54(_a)
    _18[_a]=_18[_a] or false
    local _b=Instance.new("Frame")
    _b.Size=UDim2.new(1,0,0,_4("Y",36))
    _b.BackgroundColor3=Color3.fromRGB(10,8,22)
    _b.BackgroundTransparency=0.3
    _b.Parent=_50
    MakeCorner(_b,6)
    MakeShadowStroke(_b)

    local _c=Instance.new("TextLabel")
    _c.Size=UDim2.new(1,-_4("X",72),1,0)
    _c.Position=UDim2.new(0,_4("X",8),0,0)
    _c.BackgroundTransparency=1
    _c.Text=_a
    _c.TextColor3=Color3.fromRGB(160,120,255)
    _c.Font=Enum.Font.Gotham
    _c.TextScaled=true
    _c.TextXAlignment=Enum.TextXAlignment.Left
    _c.Parent=_b

    local _d=Instance.new("TextButton")
    _d.Size=UDim2.new(0,_4("X",52),0,_4("Y",22))
    _d.Position=UDim2.new(1,-_4("X",60),0.5,-_4("Y",11))
    _d.TextColor3=Color3.new(1,1,1)
    _d.Font=Enum.Font.GothamBold
    _d.TextScaled=true
    _d.Parent=_b
    MakeCorner(_d,4)

    local function _e(_f)
        _d.Text=_f and "ON" or "OFF"
        _d.BackgroundColor3=_f and Color3.fromRGB(10,60,120) or Color3.fromRGB(60,10,30)
        _d.TextColor3=_f and Color3.fromRGB(80,200,255) or Color3.fromRGB(255,60,80)
        if _f then
            PulseGlow(_d, Color3.fromRGB(20,60,140), Color3.fromRGB(40,120,255))
        end
    end

    _d.MouseButton1Click:Connect(function()_18[_a]=not _18[_a]_e(_18[_a])end)
    _e(_18[_a])
    _18._toggles[_a]=_e
end

local function _55(_a,_b)
    local _c=Instance.new("Frame")
    _c.Size=UDim2.new(1,0,0,_4("Y",40))
    _c.BackgroundColor3=Color3.fromRGB(10,8,22)
    _c.BackgroundTransparency=0.3
    _c.Parent=_50
    MakeCorner(_c,6)

    local _d=Instance.new("TextButton")
    _d.Size=UDim2.new(1,-_4("X",16),1,-_4("Y",8))
    _d.Position=UDim2.new(0,_4("X",8),0,_4("Y",4))
    _d.BackgroundColor3=Color3.fromRGB(14,8,40)
    _d.BackgroundTransparency=0.1
    _d.Text=_a
    _d.TextColor3=Color3.fromRGB(180,130,255)
    _d.Font=Enum.Font.GothamBold
    _d.TextScaled=true
    _d.Parent=_c
    MakeCorner(_d,6)
    PulseGlow(_d, Color3.fromRGB(40,20,100), Color3.fromRGB(100,50,255))
    _d.MouseButton1Click:Connect(function()if typeof(_b)=="function"then _b()end end)
    return _d
end

function _18:EditSlider(_a,_b)local _c=self._sliders[_a]if _c then _c(_b)end end
function _18:EditToggle(_a,_b)local _c=self._toggles[_a]if _c then _18[_a]=_b _c(_b)end end

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

-- ════════════════════════════════════════════
-- EMOTE CARD BUILDERS
-- ════════════════════════════════════════════

local _57={{Enum.CatalogSortType.Relevance,"Relevance"},{Enum.CatalogSortType.PriceHighToLow,"Price ↑"},{Enum.CatalogSortType.PriceLowToHigh,"Price ↓"},{Enum.CatalogSortType.MostFavorited,"Favorited"},{Enum.CatalogSortType.RecentlyCreated,"Recent"},{Enum.CatalogSortType.Bestselling,"Bestselling"}}
local _58=1 local _59="" local _60=nil local _61=1 local _TAB=1

local function _62(_a)
    if _isR6 then return {IsFinished=true,GetCurrentPage=function()return{{Id=115314801778772,Name="Dance If Youre The Best",AssetId=115314801778772}}end,AdvanceToNextPageAsync=function()end}end
    local _b=CatalogSearchParams.new()
    _b.SearchKeyword=_a or ""
    _b.CategoryFilter=Enum.CatalogCategoryFilter.None
    _b.SalesTypeFilter=Enum.SalesTypeFilter.All
    _b.AssetTypes={Enum.AvatarAssetType.EmoteAnimation}
    _b.IncludeOffSale=true
    _b.SortType=_57[_58][1]
    _b.Limit=10
    local _c,_d=pcall(function()return _12:SearchCatalog(_b)end)
    if not _c then return nil end
    return _d
end

local function _63(_a)
    local _b=Instance.new("Frame")
    _b.Size=UDim2.new(0,_4("X",110),0,_4("Y",175))
    _b.BackgroundColor3=Color3.fromRGB(10,8,22)
    _b.BackgroundTransparency=0.15
    MakeCorner(_b,10)
    -- Animated neon border
    local cardStroke=Instance.new("UIStroke")
    cardStroke.Thickness=1
    cardStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    cardStroke.Color=Color3.fromRGB(60,30,150)
    cardStroke.Parent=_b
    local cHue=math.random()*1
    _9.RenderStepped:Connect(function(dt)
        cHue=(cHue+dt*0.4)%1
        cardStroke.Color=Color3.fromHSV(cHue,0.85,0.9)
    end)

    local _c=_a.AssetId or _a.Id

    local _d=Instance.new("ImageLabel")
    _d.Size=UDim2.new(1,-_4("X",10),0,_4("Y",82))
    _d.Position=UDim2.new(0,_4("X",5),0,_4("Y",5))
    _d.BackgroundColor3=Color3.fromRGB(14,10,30)
    _d.ScaleType=Enum.ScaleType.Fit
    pcall(function()_d.Image="rbxthumb://type=Asset&id="..tonumber(_c).."&w=150&h=150"end)
    _d.Parent=_b
    MakeCorner(_d,6)

    local _e=Instance.new("TextLabel")
    _e.Size=UDim2.new(1,-_4("X",10),0,_4("Y",26))
    _e.Position=UDim2.new(0,_4("X",5),0,_4("Y",91))
    _e.BackgroundTransparency=1
    _e.Text=_a.Name or "Unknown"
    _e.TextScaled=true
    _e.TextWrapped=true
    _e.Font=Enum.Font.GothamBold
    _e.TextColor3=Color3.fromRGB(200,170,255)
    _e.Parent=_b

    -- Link/copy button
    local _f=_a.Id
    local _g=Instance.new("TextButton")
    _g.Parent=_b
    _g.Size=UDim2.new(0,_4("X",32),0,_4("Y",22))
    _g.Position=UDim2.new(1,-_4("X",36),0,_4("Y",5))
    _g.BackgroundColor3=Color3.fromRGB(16,10,36)
    _g.BackgroundTransparency=0.2
    _g.Text="🔗"
    _g.Font=Enum.Font.GothamBold
    _g.TextScaled=true
    _g.TextColor3=Color3.fromRGB(255,255,255)
    _g.AutoButtonColor=false
    _g.ZIndex=2
    MakeCorner(_g,5)
    _g.MouseButton1Click:Connect(function()
        setclipboard("https://www.roblox.com/catalog/"..tonumber(_f))
        _g.Text="✓"
        _g.BackgroundColor3=Color3.fromRGB(10,60,30)
        task.wait(0.8)
        _g.Text="🔗"
        _g.BackgroundColor3=Color3.fromRGB(16,10,36)
    end)

    local _h=Instance.new("TextButton")
    _h.Size=UDim2.new(0.48,-_4("X",4),0,_4("Y",22))
    _h.Position=UDim2.new(0,_4("X",4),1,-_4("Y",26))
    _h.BackgroundColor3=Color3.fromRGB(8,40,20)
    _h.BackgroundTransparency=0.1
    _h.Text="Play"
    _h.Font=Enum.Font.GothamBold
    _h.TextScaled=true
    _h.TextColor3=Color3.fromRGB(80,255,140)
    _h.Parent=_b
    MakeCorner(_h,5)
    PulseGlow(_h, Color3.fromRGB(10,70,30), Color3.fromRGB(20,160,70))
    _h.MouseButton1Click:Connect(function()_24(_c)end)

    local _i=Instance.new("TextButton")
    _i.Size=UDim2.new(0.48,-_4("X",4),0,_4("Y",22))
    _i.Position=UDim2.new(0.52,_4("X",2),1,-_4("Y",26))
    _i.BackgroundColor3=Color3.fromRGB(8,16,50)
    _i.BackgroundTransparency=0.1
    _i.Text="Save"
    _i.Font=Enum.Font.GothamBold
    _i.TextScaled=true
    _i.TextColor3=Color3.fromRGB(100,160,255)
    _i.Parent=_b
    MakeCorner(_i,5)
    PulseGlow(_i, Color3.fromRGB(15,30,100), Color3.fromRGB(40,80,255))
    _i.MouseButton1Click:Connect(function()
        local _j=false
        for _k,_l in ipairs(_19)do if _l.Id==_a.Id then _j=true break end end
        if not _j then
            local _m=GetReal(_c)
            table.insert(_19,{Id=_a.Id,AssetId=_c,Name=_a.Name or "Unknown",AnimationId="rbxassetid://"..tostring(_m or _c),Favorite=false})
            _22()
            _i.Text="✓ Saved"
            _i.BackgroundColor3=Color3.fromRGB(8,50,30)
            _i.TextColor3=Color3.fromRGB(80,255,140)
            task.wait(1.2)
            _i.Text="Save"
            _i.BackgroundColor3=Color3.fromRGB(8,16,50)
            _i.TextColor3=Color3.fromRGB(100,160,255)
        else
            _i.Text="Exists"
            task.wait(0.7)
            _i.Text="Save"
        end
    end)

    PopIn(_b)
    return _b
end

-- ════════════════════════════════════════════
-- CATALOG LOGIC
-- ════════════════════════════════════════════

local function _71()
    _67.Visible=(_61>1)
    if _60 and typeof(_60.IsFinished)=="boolean"then
        _68.Visible=not _60.IsFinished
    else _68.Visible=true end
end

local _73_id=0
local function _73(_a)
    _73_id=_73_id+1
    local _myId=_73_id
    _69.Text="Loading..."
    for _b,_c in ipairs(_64:GetChildren())do if _c:IsA("Frame")then _c:Destroy()end end
    local _d=nil
    local _e,_f=pcall(function()return _a:GetCurrentPage()end)
    if _e then _d=_f else _69.Text="ERROR" return end
    if _myId~=_73_id then return end
    if _d and #_d>0 then
        _66.Visible=false
        local _myTAB=_TAB
        local _count=0
        for _g,_h in ipairs(_d)do
            if _TAB~=_myTAB or _myId~=_73_id then break end
            _63(_h).Parent=_64
            _count=_count+1
            if _count%2==0 then _9.RenderStepped:Wait()end
        end
    else _66.Visible=true end
    if _myId==_73_id then
        _64.CanvasSize=UDim2.new(0,0,0,_65.AbsoluteContentSize.Y+8)
        _69.Text=tostring(_61)
        _71()
    end
end

local function _74(_a)local _b=_62(_59)if not _b then return nil end for _c=2,_a do if _b.IsFinished then break end local _d,_e=pcall(function()_b:AdvanceToNextPageAsync()end)if not _d then break end end return _b end
local function _75(_a)_59=_a or ""_61=1 _69.Text="Loading..."_60=_62(_59)if _60 then _73(_60)end end

_41.MouseButton1Click:Connect(function()_75(_40.Text)end)
_40.FocusLost:Connect(function(_a)if _a then _75(_40.Text)end end)
_42.MouseButton1Click:Connect(function()_58=_58%#_57+1 _42.Text="Sort: ".._57[_58][2]_75(_59)end)

local function _76()if not _60 or _60.IsFinished then return end local _a,_b=pcall(function()_60:AdvanceToNextPageAsync()end)if _a then _61+=1 _73(_60)else local _c=_61+1 local _d=_74(_c)if _d then _60=_d _61=math.min(_c,_61+1)_73(_60)end end end
local function _77()if not _60 or _61<=1 then return end local _a,_b=pcall(function()_60:AdvanceToPreviousPageAsync()end)if _a then _61=math.max(1,_61-1)_73(_60)else local _c=math.max(1,_61-1)local _d=_74(_c)if _d then _60=_d _61=_c _73(_60)end end end

_68.MouseButton1Click:Connect(_76)
_67.MouseButton1Click:Connect(_77)

_10.InputBegan:Connect(function(_a,_b)if _b then return end if _a.UserInputType==Enum.UserInputType.Keyboard and _a.KeyCode==Enum.KeyCode.Right then _76()elseif _a.KeyCode==Enum.KeyCode.Left then _77()end end)

_69.FocusLost:Connect(function(_a)if not _a then return end local _b=_69.Text:gsub("%s+","")local _c=tonumber(_b:match("%d+"))if not _c or _c<1 then _70.Text="Invalid page"_70.Visible=true task.delay(2,function()if _70 then _70.Visible=false end end)_69.Text=tostring(_61)return end local _d=math.floor(_c)if _d==_61 then _69.Text=tostring(_61)return end _69.Text="Loading..."local _e,_f=pcall(function()return _74(_d)end)if not _e or not _f then _70.Text="Page not found"_70.Visible=true task.delay(2,function()if _70 then _70.Visible=false end end)_69.Text=tostring(_61)return end _60=_f _61=math.max(1,_d)_73(_60)end)

-- ════════════════════════════════════════════
-- SAVED CARD BUILDER
-- ════════════════════════════════════════════

local function _78(_a)
    local _b=Instance.new("Frame")
    _b.Size=UDim2.new(0,_4("X",110),0,_4("Y",190))
    _b.BackgroundColor3=Color3.fromRGB(8,14,10)
    _b.BackgroundTransparency=0.15
    MakeCorner(_b,10)
    local savedStroke=Instance.new("UIStroke")
    savedStroke.Thickness=1
    savedStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    savedStroke.Color=Color3.fromRGB(20,100,50)
    savedStroke.Parent=_b
    local sHue=0.4
    _9.RenderStepped:Connect(function(dt)
        sHue=(sHue+dt*0.35)%1
        savedStroke.Color=Color3.fromHSV(sHue,0.85,0.9)
    end)

    local _c=Instance.new("ImageLabel")
    _c.Size=UDim2.new(1,-_4("X",10),0,_4("Y",82))
    _c.Position=UDim2.new(0,_4("X",5),0,_4("Y",5))
    _c.BackgroundColor3=Color3.fromRGB(8,18,12)
    _c.ScaleType=Enum.ScaleType.Fit
    _c.Image="rbxthumb://type=Asset&id=11768914234&w=150&h=150"
    _c.Parent=_b
    MakeCorner(_c,6)

    local _d=Instance.new("TextLabel")
    _d.Size=UDim2.new(1,-_4("X",10),0,_4("Y",26))
    _d.Position=UDim2.new(0,_4("X",5),0,_4("Y",91))
    _d.BackgroundTransparency=1
    _d.Text=_a.Name or "Unknown"
    _d.TextScaled=true
    _d.TextWrapped=true
    _d.Font=Enum.Font.GothamBold
    _d.TextColor3=Color3.fromRGB(150,255,180)
    _d.Parent=_b

    -- Fav star
    local _h=Instance.new("TextButton")
    _h.Size=UDim2.new(0,_4("X",22),0,_4("Y",22))
    _h.Position=UDim2.new(1,-_4("X",26),0,_4("Y",5))
    _h.Text=_a.Favorite and "★" or "☆"
    _h.Font=Enum.Font.GothamBold
    _h.TextScaled=true
    _h.TextColor3=Color3.fromRGB(255,210,40)
    _h.BackgroundTransparency=1
    _h.ZIndex=3
    _h.Parent=_b
    _h.MouseButton1Click:Connect(function()_a.Favorite=not _a.Favorite _h.Text=_a.Favorite and "★" or "☆" _22()_80()end)

    -- Copy AnimId
    local _g=Instance.new("TextButton")
    _g.Size=UDim2.new(1,-_4("X",8),0,_4("Y",20))
    _g.Position=UDim2.new(0,_4("X",4),0,_4("Y",120))
    _g.BackgroundColor3=Color3.fromRGB(14,12,32)
    _g.BackgroundTransparency=0.1
    _g.Text="Copy ID"
    _g.Font=Enum.Font.GothamBold
    _g.TextScaled=true
    _g.TextColor3=Color3.fromRGB(180,140,255)
    _g.ZIndex=2
    _g.Parent=_b
    MakeCorner(_g,4)
    _g.MouseButton1Click:Connect(function()if setclipboard then setclipboard(_a.AnimationId:gsub("rbxassetid://",""))end _g.Text="Copied!"task.wait(0.7)_g.Text="Copy ID"end)

    local _e=Instance.new("TextButton")
    _e.Size=UDim2.new(0.48,-_4("X",4),0,_4("Y",22))
    _e.Position=UDim2.new(0,_4("X",4),1,-_4("Y",26))
    _e.BackgroundColor3=Color3.fromRGB(8,40,20)
    _e.BackgroundTransparency=0.1
    _e.Text="Play"
    _e.Font=Enum.Font.GothamBold
    _e.TextScaled=true
    _e.TextColor3=Color3.fromRGB(80,255,140)
    _e.Parent=_b
    MakeCorner(_e,5)
    PulseGlow(_e, Color3.fromRGB(10,70,30), Color3.fromRGB(20,160,70))
    _e.MouseButton1Click:Connect(function()_24(_a.Id)end)

    local _f=Instance.new("TextButton")
    _f.Size=UDim2.new(0.48,-_4("X",4),0,_4("Y",22))
    _f.Position=UDim2.new(0.52,_4("X",2),1,-_4("Y",26))
    _f.BackgroundColor3=Color3.fromRGB(40,8,8)
    _f.BackgroundTransparency=0.1
    _f.Text="Remove"
    _f.Font=Enum.Font.GothamBold
    _f.TextScaled=true
    _f.TextColor3=Color3.fromRGB(255,80,80)
    _f.Parent=_b
    MakeCorner(_f,5)
    PulseGlow(_f, Color3.fromRGB(80,10,10), Color3.fromRGB(200,30,30))
    _f.MouseButton1Click:Connect(function()for _i,_j in ipairs(_19)do if _j.Id==_a.Id then table.remove(_19,_i)_22()_80()break end end end)

    PopIn(_b)
    return _b
end

-- ════════════════════════════════════════════
-- SAVED LIST RENDER
-- ════════════════════════════════════════════

local _80_id=0
function _80()
    _80_id=_80_id+1
    local _myId=_80_id
    for _a,_b in ipairs(_45:GetChildren())do if _b:IsA("Frame")then _b:Destroy()end end
    local _c=(_44.Text or ""):lower()
    local _d={}
    for _e,_f in ipairs(_19)do
        if _c=="" or (_f.Name and _f.Name:lower():find(_c))then table.insert(_d,_f)end
    end
    table.sort(_d,function(_g,_h)if _g.Favorite~=_h.Favorite then return _g.Favorite else return false end end)
    if #_d>0 then
        _46.Visible=false
        local _myTAB=_TAB
        local _count=0
        for _i,_j in ipairs(_d)do
            if _TAB~=_myTAB or _myId~=_80_id then break end
            _78(_j).Parent=_45
            _count=_count+1
            if _count%25==0 then _9.RenderStepped:Wait()end
        end
    else _46.Visible=true end
    if _myId==_80_id then
        _45.CanvasSize=UDim2.new(0,0,0,_47.AbsoluteContentSize.Y+8)
    end
end

-- ════════════════════════════════════════════
-- TAB SWITCHING
-- ════════════════════════════════════════════

_36.MouseButton1Click:Connect(function()
    _TAB+=1
    _39.Visible=true _43.Visible=false
    _36.BackgroundColor3=Color3.fromRGB(20,10,55)
    _37.BackgroundColor3=Color3.fromRGB(10,20,12)
end)

_37.MouseButton1Click:Connect(function()
    _TAB+=1
    _39.Visible=false _43.Visible=true
    _36.BackgroundColor3=Color3.fromRGB(12,8,30)
    _37.BackgroundColor3=Color3.fromRGB(10,36,18)
    _80()
end)

_44:GetPropertyChangedSignal("Text"):Connect(_80)

-- ════════════════════════════════════════════
-- FOOTER BRAND LABEL
-- ════════════════════════════════════════════

local footer=Instance.new("TextLabel")
footer.Size=UDim2.new(1,0,0,_4("Y",16))
footer.Position=UDim2.new(0,0,1,-_4("Y",18))
footer.BackgroundTransparency=1
footer.Text="vertelvsepoel · gaze emotes v2"
footer.TextColor3=Color3.fromRGB(60,30,130)
footer.Font=Enum.Font.GothamBold
footer.TextScaled=true
footer.ZIndex=4
footer.Parent=_30
local footHue=0.75
_9.RenderStepped:Connect(function(dt)
    footHue=(footHue+dt*0.25)%1
    footer.TextColor3=Color3.fromHSV(footHue,0.8,0.7)
end)

-- ════════════════════════════════════════════
-- TOGGLE BUTTON (G key / on-screen)
-- ════════════════════════════════════════════

local _79=_26
local function _81()
    if _79.Enabled then
        _11:Create(_30,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0)})
        task.wait(0.2)
    end
    _79.Enabled=not _79.Enabled
    if _79.Enabled then
        _30.Size=UDim2.new(0,_4("X",490),0,_4("Y",460))
        _11:Create(_30,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,_4("X",490),0,_4("Y",460))})
    end
end

local _82=Instance.new("ScreenGui")
_82.Name="ToggleButtonGui_Vertel"
_82.ResetOnSpawn=false
_82.Parent=_25
_82.Enabled=true

local _83=Instance.new("TextButton")
_83.Parent=_82
_83.Text="G"
_83.Font=Enum.Font.GothamBold
_83.TextScaled=true
_83.Size=UDim2.new(0,48,0,48)
_83.Position=UDim2.new(0,18,0.5,-50)
_83.AnchorPoint=Vector2.new(0,0.5)
_83.BackgroundColor3=Color3.fromRGB(8,6,20)
_83.BackgroundTransparency=0.05
_83.TextColor3=Color3.fromRGB(160,100,255)
_83.Active=true
pcall(function()_83.Draggable=true end)
MakeCorner(_83,12)
PulseGlow(_83, Color3.fromRGB(60,20,160), Color3.fromRGB(120,50,255))

-- Animate button text color
local btnHue=0.76
_9.RenderStepped:Connect(function(dt)
    btnHue=(btnHue+dt*0.5)%1
    _83.TextColor3=Color3.fromHSV(btnHue,0.9,1)
end)

local _84=Instance.new("UIAspectRatioConstraint")
_84.Parent=_83
_84.AspectRatio=1

_83.MouseButton1Click:Connect(_81)
_10.InputBegan:Connect(function(_a,_b)
    if _b then return end
    if _a.UserInputType==Enum.UserInputType.Keyboard and _a.KeyCode==Enum.KeyCode.G then
        _81()
    end
end)

_26.Enabled=true
_80()
_75("")

-- ════════════════════════════════════════════
-- NO-COLLISION TASK (original logic preserved)
-- ════════════════════════════════════════════

task.spawn(function()
    local RunService=game:GetService("RunService")
    local Players=game.Players
    local player=Players.LocalPlayer

    local function setupCollision(character)
        local hrp=character:WaitForChild("HumanoidRootPart")
        local bodyParts={}
        hrp.CanCollide=true
        local function addPart(part)
            if part:IsA("BasePart")and part~=hrp then
                table.insert(bodyParts,part)
            end
        end
        for _,part in pairs(character:GetDescendants())do addPart(part)end
        local descendantConnection=character.DescendantAdded:Connect(addPart)
        local heartbeatConnection
        heartbeatConnection=RunService.Heartbeat:Connect(function()
            if not character or not character.Parent then
                heartbeatConnection:Disconnect()
                descendantConnection:Disconnect()
                return
            end
            for i=1,#bodyParts do
                local p=bodyParts[i]
                if p and p.Parent then p.CanCollide=false end
            end
        end)
    end

    if player.Character then setupCollision(player.Character)end
    player.CharacterAdded:Connect(setupCollision)
end)
