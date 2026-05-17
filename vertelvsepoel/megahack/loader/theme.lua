-- theme.lua
-- Цветовая тема, color picker, save/load настроек.
-- Возвращает функцию-фабрику. Получает deps, возвращает публичное API.

return function(deps)
    local TweenService       = deps.TweenService
    local RunService         = deps.RunService
    local HttpService        = deps.HttpService
    local UserInputService   = deps.UserInputService
    local accentRegistry     = deps.accentRegistry
    local getNotification    = deps.getNotification  -- функция, возвращает текущий createNotification

    -- ═══════════════════════════════
    --  БАЗОВАЯ ПАЛИТРА
    -- ═══════════════════════════════
    local T = {
        BgBase    = Color3.fromRGB(10, 10, 14),
        BgSide    = Color3.fromRGB(16, 16, 22),
        BgPanel   = Color3.fromRGB(22, 22, 30),
        BgBtn     = Color3.fromRGB(28, 28, 38),
        BgBtnHov  = Color3.fromRGB(36, 36, 50),
        Accent    = Color3.fromRGB(139, 92, 246),   -- фиолетовый по умолчанию
        AccentHov = Color3.fromRGB(167, 120, 255),
        AccentGlow= Color3.fromRGB(192, 150, 255),
        TextMain  = Color3.fromRGB(230, 230, 238),
        TextSub   = Color3.fromRGB(130, 130, 148),
        TextMuted = Color3.fromRGB(80, 80, 95),
        Separator = Color3.fromRGB(30, 30, 42),
    }

    local rgbConns = {}

    -- Пересчитать производные цвета из acc и bg
    local function deriveColors(acc, bg, tx)
        T.Accent     = acc
        T.AccentHov  = Color3.new(math.min(acc.R*1.2,1), math.min(acc.G*1.2,1), math.min(acc.B*1.2,1))
        T.AccentGlow = Color3.new(math.min(acc.R*1.38,1), math.min(acc.G*1.38,1), math.min(acc.B*1.38,1))
        T.BgBase     = bg
        T.BgSide     = Color3.new(math.min(bg.R+0.025,1), math.min(bg.G+0.025,1), math.min(bg.B+0.032,1))
        T.BgPanel    = Color3.new(math.min(bg.R+0.047,1), math.min(bg.G+0.047,1), math.min(bg.B+0.062,1))
        T.BgBtn      = Color3.new(math.min(bg.R+0.071,1), math.min(bg.G+0.071,1), math.min(bg.B+0.094,1))
        T.BgBtnHov   = Color3.new(math.min(bg.R+0.102,1), math.min(bg.G+0.102,1), math.min(bg.B+0.140,1))
        T.TextMain   = tx
        T.TextSub    = Color3.new(tx.R*0.56, tx.G*0.56, tx.B*0.56)
        T.TextMuted  = Color3.new(tx.R*0.33, tx.G*0.33, tx.B*0.33)
        T.Separator  = Color3.new(math.min(bg.R+0.013,1), math.min(bg.G+0.013,1), math.min(bg.B+0.018,1))
    end

    -- ═══════════════════════════════
    --  ПРИМЕНЕНИЕ ЦВЕТОВ К GUI
    -- ═══════════════════════════════
    local function clearRgb()
        for _, c in ipairs(rgbConns) do pcall(function() c:Disconnect() end) end
        rgbConns = {}
    end

    local function applyColors(settings, mainFrame)
        clearRgb()
        local acc = settings.colors.accentColor
        local bg  = settings.colors.bgColor
        local tx  = settings.colors.textColor
        deriveColors(acc, bg, tx)

        -- Обновляем accent registry
        for _, e in ipairs(accentRegistry) do
            if e.obj and e.obj.Parent then
                pcall(function() e.obj[e.prop] = acc end)
            end
        end

        -- Фон главного окна
        if mainFrame then
            mainFrame.BackgroundColor3       = bg
            mainFrame.BackgroundTransparency = settings.transparency
        end

        -- Проходим по всем потомкам mainFrame
        if mainFrame then
            for _, obj in ipairs(mainFrame:GetDescendants()) do
                -- Текст: только те, у кого TextRole="main"
                if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
                    if settings.rgbText then
                        local conn = RunService.Heartbeat:Connect(function()
                            if not obj or not obj.Parent then return end
                            obj.TextColor3 = Color3.fromHSV((tick() % 4) / 4, 0.85, 1)
                        end)
                        table.insert(rgbConns, conn)
                    else
                        if obj:GetAttribute("TextRole") == "main" then
                            obj.TextColor3 = tx
                        end
                    end
                end
                -- Accent-элементы (полоски, пипы) обновляются через registry выше
            end
        end
    end

    -- ═══════════════════════════════
    --  СОХРАНЕНИЕ / ЗАГРУЗКА
    -- ═══════════════════════════════
    local function saveColors(settings)
        pcall(function()
            if not isfolder("MegaHack") then makefolder("MegaHack") end
            local c = settings.colors
            writefile("MegaHack/colors.json", HttpService:JSONEncode({
                accentColor  = {c.accentColor.R,  c.accentColor.G,  c.accentColor.B},
                bgColor      = {c.bgColor.R,       c.bgColor.G,      c.bgColor.B},
                textColor    = {c.textColor.R,     c.textColor.G,    c.textColor.B},
                transparency = settings.transparency,
                rgbText      = settings.rgbText,
            }))
        end)
    end

    local function loadColors(settings)
        pcall(function()
            if not isfile("MegaHack/colors.json") then return end
            local d = HttpService:JSONDecode(readfile("MegaHack/colors.json"))
            local function col(t) return t and Color3.new(t[1], t[2], t[3]) end
            if d.accentColor  then settings.colors.accentColor  = col(d.accentColor)  end
            if d.bgColor      then settings.colors.bgColor      = col(d.bgColor)      end
            if d.textColor    then settings.colors.textColor    = col(d.textColor)    end
            if d.transparency ~= nil then settings.transparency = d.transparency      end
            if d.rgbText      ~= nil then settings.rgbText      = d.rgbText           end
        end)
    end

    -- ═══════════════════════════════
    --  COLOR PICKER WIDGET
    -- ═══════════════════════════════
    local function createColorPicker(parent, settings, onApply)
        local selType = "accentColor"
        local curH, curS, curV = Color3.toHSV(settings.colors.accentColor)
        local curR, curG, curB = 0, 0, 0

        local conns = {}  -- локальные соединения пикера

        local function syncHSV()
            local col = settings.colors[selType]
            curH, curS, curV = Color3.toHSV(col)
            curR = math.floor(col.R * 255 + 0.5)
            curG = math.floor(col.G * 255 + 0.5)
            curB = math.floor(col.B * 255 + 0.5)
        end
        syncHSV()

        -- Контейнер
        local container = Instance.new("Frame")
        container.BackgroundTransparency = 1
        container.Size   = UDim2.new(1, 0, 0, 10)
        container.ZIndex = 4
        container.Parent = parent

        local layout = Instance.new("UIListLayout")
        layout.Padding   = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent    = container
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 4)
        end)

        local function mk(cls, props, par)
            local o = Instance.new(cls)
            for k, v in pairs(props) do o[k] = v end
            o.Parent = par or container
            return o
        end
        local function corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 6); c.Parent=p end

        -- ── Переключатель типа цвета ──
        local typeRow = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,26), LayoutOrder=1})
        local trLayout = Instance.new("UIListLayout"); trLayout.FillDirection=Enum.FillDirection.Horizontal; trLayout.Padding=UDim.new(0,4); trLayout.SortOrder=Enum.SortOrder.LayoutOrder; trLayout.Parent=typeRow
        local typeItems = {{l="Accent",k="accentColor"},{l="BG",k="bgColor"},{l="Text",k="textColor"}}
        local typeBtns = {}
        local updateAll -- forward

        local function refreshTypeBtns(active)
            for _, td in ipairs(typeItems) do
                local b = typeBtns[td.k]
                if b then
                    if td.k == active then
                        b.BackgroundColor3 = T.Accent; b.BackgroundTransparency = 0.2; b.TextColor3 = T.TextMain
                    else
                        b.BackgroundColor3 = T.BgBtn; b.BackgroundTransparency = 0.4; b.TextColor3 = T.TextSub
                    end
                end
            end
        end

        for i, td in ipairs(typeItems) do
            local b = mk("TextButton", {
                Size = UDim2.new(1/3, -3, 1, 0),
                BackgroundColor3 = T.BgBtn, BackgroundTransparency = 0.4,
                BorderSizePixel = 0, Text = td.l, TextColor3 = T.TextSub,
                TextSize = 11, Font = Enum.Font.GothamBold, LayoutOrder = i, ZIndex = 5,
            }, typeRow)
            corner(b, 5)
            typeBtns[td.k] = b
            b.MouseButton1Click:Connect(function()
                selType = td.k; syncHSV(); refreshTypeBtns(selType)
                if updateAll then updateAll() end
            end)
        end
        refreshTypeBtns(selType)

        -- ── SV-квадрат ──
        local sqSz = 150
        local mainArea = mk("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,sqSz), LayoutOrder=2})

        local svBase = Instance.new("Frame")
        svBase.Size = UDim2.new(0,sqSz,0,sqSz); svBase.BackgroundColor3=Color3.fromHSV(curH,1,1)
        svBase.BorderSizePixel=0; svBase.ZIndex=5; svBase.Parent=mainArea
        corner(svBase, 6)

        local wOv = mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=6},svBase); corner(wOv,6)
        local wg = Instance.new("UIGradient"); wg.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}); wg.Parent=wOv
        local bOv = mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,ZIndex=7},svBase); corner(bOv,6)
        local bg2 = Instance.new("UIGradient"); bg2.Color=ColorSequence.new(Color3.new(0,0,0),Color3.new(0,0,0)); bg2.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}); bg2.Rotation=90; bg2.Parent=bOv

        local svDot = mk("Frame",{Size=UDim2.new(0,10,0,10),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(curS,0,1-curV,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=9},svBase)
        corner(svDot,5)
        local svRing = Instance.new("UIStroke"); svRing.Thickness=2; svRing.Color=Color3.new(0,0,0); svRing.Transparency=0.3; svRing.Parent=svDot

        -- Правая панель
        local rPanel = mk("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,-(sqSz+10),1,0),Position=UDim2.new(0,sqSz+10,0,0),ZIndex=4},mainArea)
        local rLayout = Instance.new("UIListLayout"); rLayout.Padding=UDim.new(0,6); rLayout.SortOrder=Enum.SortOrder.LayoutOrder; rLayout.Parent=rPanel
        rLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            rPanel.Size = UDim2.new(1,-(sqSz+10),0,rLayout.AbsoluteContentSize.Y)
        end)

        -- Preview
        local preview = mk("Frame",{BackgroundColor3=settings.colors[selType],BorderSizePixel=0,Size=UDim2.new(1,0,0,48),ZIndex=5,LayoutOrder=1},rPanel)
        corner(preview,8)
        local prevLbl = mk("TextLabel",{BackgroundTransparency=1,Text="PREVIEW",Font=Enum.Font.GothamBold,TextSize=9,TextColor3=Color3.new(1,1,1),TextTransparency=0.5,Size=UDim2.new(1,0,1,0),ZIndex=6},preview)

        -- Hex
        local hexRow = mk("Frame",{BackgroundColor3=T.BgPanel,BackgroundTransparency=0.2,BorderSizePixel=0,Size=UDim2.new(1,0,0,26),ZIndex=5,LayoutOrder=2},rPanel)
        corner(hexRow,6)
        mk("TextLabel",{BackgroundTransparency=1,Text="#",TextColor3=T.TextSub,TextSize=12,Font=Enum.Font.GothamBold,Size=UDim2.new(0,18,1,0),Position=UDim2.new(0,4,0,0),ZIndex=6},hexRow)
        local hexBox = mk("TextBox",{BackgroundTransparency=1,TextColor3=T.TextMain,TextSize=11,Font=Enum.Font.Code,PlaceholderText="RRGGBB",PlaceholderColor3=T.TextMuted,Text="",ClearTextOnFocus=false,Size=UDim2.new(1,-22,1,0),Position=UDim2.new(0,22,0,0),ZIndex=6},hexRow)
        hexBox:SetAttribute("TextRole","main")

        -- ── Hue slider ──
        local hueTrack = mk("Frame",{BackgroundColor3=Color3.new(1,0,0),BorderSizePixel=0,Size=UDim2.new(1,0,0,14),ZIndex=5,LayoutOrder=3})
        corner(hueTrack,4)
        local hg = Instance.new("UIGradient")
        hg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0/6,Color3.fromHSV(0/6,1,1)),ColorSequenceKeypoint.new(1/6,Color3.fromHSV(1/6,1,1)),ColorSequenceKeypoint.new(2/6,Color3.fromHSV(2/6,1,1)),ColorSequenceKeypoint.new(3/6,Color3.fromHSV(3/6,1,1)),ColorSequenceKeypoint.new(4/6,Color3.fromHSV(4/6,1,1)),ColorSequenceKeypoint.new(5/6,Color3.fromHSV(5/6,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1))})
        hg.Parent = hueTrack
        local hueDot = mk("Frame",{Size=UDim2.new(0,6,1,6),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(curH,0,0.5,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=6},hueTrack)
        corner(hueDot,3)

        -- ── RGB Sliders ──
        local rgbTracks,rgbDots = {},{}
        local chNames = {"R","G","B"}
        local chCols  = {Color3.new(1,0,0),Color3.new(0,1,0),Color3.new(0,0,1)}
        for i, nm in ipairs(chNames) do
            local slot = mk("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),ZIndex=4,LayoutOrder=3+i})
            mk("TextLabel",{BackgroundTransparency=1,Text=nm,TextColor3=T.TextSub,TextSize=11,Font=Enum.Font.GothamBold,Size=UDim2.new(0,14,1,0),ZIndex=5},slot)
            local tr = mk("Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Size=UDim2.new(1,-36,0,10),Position=UDim2.new(0,18,0.5,-5),ZIndex=5},slot)
            corner(tr,4)
            local tg2 = Instance.new("UIGradient"); tg2.Color=ColorSequence.new(Color3.new(0,0,0),chCols[i]); tg2.Parent=tr
            local dot = mk("Frame",{Size=UDim2.new(0,8,1,4),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=6},tr)
            corner(dot,4)
            local vl = mk("TextLabel",{BackgroundTransparency=1,Text="0",TextColor3=T.TextMain,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Right,Size=UDim2.new(0,28,1,0),Position=UDim2.new(1,-28,0,0),ZIndex=5},slot)
            vl:SetAttribute("TextRole","main")
            rgbTracks[i]=tr; rgbDots[i]=dot
        end

        -- ── Apply ──
        local applyBtn = mk("TextButton",{
            Size=UDim2.new(1,0,0,30),BackgroundColor3=T.Accent,BackgroundTransparency=0.2,
            BorderSizePixel=0,Text="Apply & Save",TextColor3=T.TextMain,TextSize=13,
            Font=Enum.Font.GothamBold,LayoutOrder=7,ZIndex=5,
        })
        applyBtn:SetAttribute("TextRole","main")
        corner(applyBtn,7)
        applyBtn.MouseEnter:Connect(function() TweenService:Create(applyBtn,TweenInfo.new(0.13),{BackgroundTransparency=0}):Play() end)
        applyBtn.MouseLeave:Connect(function() TweenService:Create(applyBtn,TweenInfo.new(0.13),{BackgroundTransparency=0.2}):Play() end)

        -- ── updateAll ──
        updateAll = function()
            local col = Color3.fromHSV(curH,curS,curV)
            svBase.BackgroundColor3 = Color3.fromHSV(curH,1,1)
            svDot.Position   = UDim2.new(curS,0,1-curV,0)
            hueDot.Position  = UDim2.new(curH,0,0.5,0)
            preview.BackgroundColor3 = col
            curR=math.floor(col.R*255+0.5); curG=math.floor(col.G*255+0.5); curB=math.floor(col.B*255+0.5)
            hexBox.Text = string.format("%02X%02X%02X",curR,curG,curB)
            local vals={curR/255,curG/255,curB/255}
            for i=1,3 do
                rgbDots[i].Position = UDim2.new(vals[i],0,0.5,0)
                -- update value labels
                local slot = rgbTracks[i].Parent
                for _,lbl in ipairs(slot:GetChildren()) do
                    if lbl:IsA("TextLabel") and lbl:GetAttribute("TextRole")=="main" then
                        lbl.Text = tostring(math.floor(vals[i]*255+0.5))
                    end
                end
            end
        end
        updateAll()

        applyBtn.MouseButton1Click:Connect(function()
            settings.colors[selType] = Color3.fromHSV(curH,curS,curV)
            if onApply then onApply() end
            TweenService:Create(applyBtn,TweenInfo.new(0.08),{BackgroundColor3=T.AccentGlow,BackgroundTransparency=0}):Play()
            task.delay(0.2,function() TweenService:Create(applyBtn,TweenInfo.new(0.2),{BackgroundColor3=T.Accent,BackgroundTransparency=0.2}):Play() end)
        end)

        -- ── Drag logic ──
        local dSV,dHue,dRGB = false,false,0

        local c1 = svBase.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dSV=true end
        end)
        local c2 = hueTrack.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dHue=true end
        end)
        table.insert(conns,c1); table.insert(conns,c2)
        for i2=1,3 do
            local ci = rgbTracks[i2].InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dRGB=i2 end
            end)
            table.insert(conns,ci)
        end

        local cMove = UserInputService.InputChanged:Connect(function(i)
            if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
            if dSV then
                local ap=svBase.AbsolutePosition; local as=svBase.AbsoluteSize
                curS=math.clamp((i.Position.X-ap.X)/as.X,0,1)
                curV=1-math.clamp((i.Position.Y-ap.Y)/as.Y,0,1)
                updateAll()
            elseif dHue then
                local ap=hueTrack.AbsolutePosition; local as=hueTrack.AbsoluteSize
                curH=math.clamp((i.Position.X-ap.X)/as.X,0,1); updateAll()
            elseif dRGB>0 then
                local tr=rgbTracks[dRGB]; local ap=tr.AbsolutePosition; local as=tr.AbsoluteSize
                local v=math.floor(math.clamp((i.Position.X-ap.X)/as.X,0,1)*255+0.5)
                if dRGB==1 then curR=v elseif dRGB==2 then curG=v else curB=v end
                curH,curS,curV=Color3.toHSV(Color3.fromRGB(curR,curG,curB)); updateAll()
            end
        end)
        local cEnd = UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dSV=false;dHue=false;dRGB=0 end
        end)
        table.insert(conns,cMove); table.insert(conns,cEnd)

        hexBox.FocusLost:Connect(function(enter)
            if not enter then return end
            local h=hexBox.Text:gsub("[^%x]",""):upper()
            if #h==6 then
                local r=tonumber(h:sub(1,2),16); local g=tonumber(h:sub(3,4),16); local b=tonumber(h:sub(5,6),16)
                if r and g and b then curR,curG,curB=r,g,b; curH,curS,curV=Color3.toHSV(Color3.fromRGB(r,g,b)); updateAll() end
            end
        end)

        -- Деструктор
        container.Destroying:Connect(function()
            for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        end)

        return container
    end

    -- ═══════════════════════════════
    --  PUBLIC API
    -- ═══════════════════════════════
    return {
        T               = T,
        applyColors     = applyColors,
        saveColors      = saveColors,
        loadColors      = loadColors,
        createColorPicker = createColorPicker,
        clearRgb        = clearRgb,
    }
end
