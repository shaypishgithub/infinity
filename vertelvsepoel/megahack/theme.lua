═══════════════════════════════════════════════════════════════
--  theme.lua — Neon Glass Color System v3
--  2026 Edition: Cyan-Magenta Neon Palette
═══════════════════════════════════════════════════════════════

return function(deps)
    local TweenService       = deps.TweenService
    local RunService         = deps.RunService
    local HttpService        = deps.HttpService
    local accentRegistry     = deps.accentRegistry
    local createNotification = deps.createNotification or function() end

    local mainFrame = nil

    -- ═══ 2026 NEON GLASS PALETTE ═══
    local T = {
        -- Dark deep space backgrounds
        BgDeep     = Color3.fromRGB(6, 6, 14),
        BgBase     = Color3.fromRGB(10, 10, 22),
        BgSide     = Color3.fromRGB(14, 14, 28),
        BgPanel    = Color3.fromRGB(18, 18, 36),
        BgCard     = Color3.fromRGB(22, 22, 44),
        BgBtn      = Color3.fromRGB(28, 28, 54),
        BgBtnHov   = Color3.fromRGB(36, 36, 68),
        
        -- Neon Cyan-Magenta Accent
        Accent     = Color3.fromRGB(0, 220, 255),
        AccentHov  = Color3.fromRGB(40, 240, 255),
        AccentGlow = Color3.fromRGB(100, 255, 255),
        Accent2    = Color3.fromRGB(200, 0, 255),    -- Secondary magenta
        Accent2Glow= Color3.fromRGB(230, 100, 255),
        
        -- Neon Stroke
        Stroke     = Color3.fromRGB(30, 30, 60),
        StrokeBrt  = Color3.fromRGB(0, 180, 220),
        StrokeGlow = Color3.fromRGB(0, 220, 255),
        
        -- Text
        TextMain   = Color3.fromRGB(240, 240, 255),
        TextSub    = Color3.fromRGB(160, 160, 190),
        TextMuted  = Color3.fromRGB(90, 90, 120),
        TextGlow   = Color3.fromRGB(0, 220, 255),
        
        -- Glass
        GlassTint  = Color3.fromRGB(20, 20, 50),
        GlassEdge  = Color3.fromRGB(60, 60, 120),
        
        -- 3D Shadow
        Shadow     = Color3.fromRGB(0, 0, 0),
        ShadowDeep = Color3.fromRGB(0, 0, 8),
    }

    local rgbConnections = {}

    local function clearRgbConnections()
        for _, c in pairs(rgbConnections) do
            pcall(function() c:Disconnect() end)
        end
        rgbConnections = {}
    end

    local function recalcDerived(acc, bg, tx, str)
        T.Accent     = acc
        T.AccentHov  = Color3.new(
            math.min(acc.R * 1.2 + 0.05, 1),
            math.min(acc.G * 1.1 + 0.04, 1),
            math.min(acc.B * 1.05 + 0.02, 1)
        )
        T.AccentGlow = Color3.new(
            math.min(acc.R * 1.5 + 0.1, 1),
            math.min(acc.G * 1.3 + 0.08, 1),
            math.min(acc.B * 1.15 + 0.04, 1)
        )
        T.BgBase     = bg
        T.BgSide     = Color3.new(math.min(bg.R + 0.016, 1), math.min(bg.G + 0.016, 1), math.min(bg.B + 0.024, 1))
        T.BgPanel    = Color3.new(math.min(bg.R + 0.032, 1), math.min(bg.G + 0.032, 1), math.min(bg.B + 0.055, 1))
        T.BgCard     = Color3.new(math.min(bg.R + 0.047, 1), math.min(bg.G + 0.047, 1), math.min(bg.B + 0.086, 1))
        T.BgBtn      = Color3.new(math.min(bg.R + 0.071, 1), math.min(bg.G + 0.071, 1), math.min(bg.B + 0.125, 1))
        T.BgBtnHov   = Color3.new(math.min(bg.R + 0.102, 1), math.min(bg.G + 0.102, 1), math.min(bg.B + 0.180, 1))
        T.TextMain   = tx
        T.TextSub    = Color3.new(tx.R * 0.66, tx.G * 0.66, tx.B * 0.74)
        T.TextMuted  = Color3.new(tx.R * 0.38, tx.G * 0.38, tx.B * 0.47)
        T.Stroke     = str
        T.StrokeBrt  = Color3.new(
            math.min(str.R * 1.5 + acc.R * 0.3, 1),
            math.min(str.G * 1.5 + acc.G * 0.3, 1),
            math.min(str.B * 1.5 + acc.B * 0.3, 1)
        )
    end

    local function updateGuiColors(settings)
        if not mainFrame then return end
        clearRgbConnections()

        local acc = settings.colors.accentColor
        local bg  = settings.colors.bgColor
        local tx  = settings.colors.textColor
        local str = settings.colors.strokeColor

        recalcDerived(acc, bg, tx, str)

        -- Update accent registry
        if accentRegistry then
            for _, entry in ipairs(accentRegistry) do
                if entry.obj and entry.obj.Parent then
                    pcall(function()
                        entry.obj[entry.prop or "BackgroundColor3"] = acc
                    end)
                end
            end
        end

        mainFrame.BackgroundColor3       = bg
        mainFrame.BackgroundTransparency = settings.transparency or 0.04

        -- Update 3D shadow layer
        local shadowLayer = mainFrame:FindFirstChild("_3DShadow")
        if shadowLayer then
            shadowLayer.BackgroundColor3 = T.ShadowDeep
        end

        -- Update neon border glow
        local neonBorder = mainFrame:FindFirstChild("_NeonBorder")
        if neonBorder then
            neonBorder.BackgroundColor3 = acc
        end

        -- Iterate all descendants
        for _, obj in pairs(mainFrame:GetDescendants()) do
            local name = obj.Name

            -- Skip special layers
            if name == "_3DShadow" or name == "_NeonBorder" or name == "_GlassSheen"
               or name == "_NeonGlowTop" or name == "_NeonGlowBottom"
               or name == "_DepthLayer" then
                continue
            end

            -- Skip close button
            local closeBtn = mainFrame:FindFirstChild("CloseBtn", true)
            if obj == closeBtn or (closeBtn and obj:IsDescendantOf(closeBtn)) then
                continue
            end

            if obj:IsA("UIStroke") then
                local parent = obj.Parent
                local whiteStrokeNames = {"HomeCard", "FpsCard", "PingCard", "ExecCard"}
                local isWhite = parent and table.find(whiteStrokeNames, parent.Name)
                
                if isWhite then
                    obj.Color = Color3.new(1, 1, 1)
                    obj.Transparency = 0.82
                elseif settings.rgbStroke then
                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then
                            conn:Disconnect()
                            return
                        end
                        obj.Color = Color3.fromHSV((tick() % 5) / 5, 0.9, 1)
                    end)
                    table.insert(rgbConnections, conn)
                else
                    obj.Color = T.StrokeBrt
                end

            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if settings.rgbAccent then
                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then
                            conn:Disconnect()
                            return
                        end
                        obj.TextColor3 = Color3.fromHSV((tick() % 5) / 5, 0.9, 1)
                    end)
                    table.insert(rgbConnections, conn)
                elseif obj:GetAttribute("TextRole") == "main" then
                    obj.TextColor3 = tx
                end

            elseif obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
                if name == "SidebarFrame" then
                    obj.BackgroundColor3 = T.BgSide
                elseif name == "GameCardBg" then
                    obj.BackgroundColor3 = T.BgCard
                elseif name == "HomeCard" or name == "FpsCard" or name == "PingCard" or name == "ExecCard" then
                    obj.BackgroundColor3 = T.BgCard
                elseif name == "AccentBar" or name == "NeonLine" then
                    obj.BackgroundColor3 = acc
                end
            end
        end
    end

    local function saveColorSettings(settings)
        pcall(function()
            if not isfolder("MegaHack") then makefolder("MegaHack") end
            local col = settings.colors
            writefile("MegaHack/colorSettings.json", HttpService:JSONEncode({
                bgColor      = {col.bgColor.R, col.bgColor.G, col.bgColor.B},
                textColor    = {col.textColor.R, col.textColor.G, col.textColor.B},
                strokeColor  = {col.strokeColor.R, col.strokeColor.G, col.strokeColor.B},
                accentColor  = {col.accentColor.R, col.accentColor.G, col.accentColor.B},
                transparency = settings.transparency,
                rgbAccent    = settings.rgbAccent,
                rgbStroke    = settings.rgbStroke,
            }))
        end)
    end

    local function loadColorSettings(settings)
        pcall(function()
            if not isfile("MegaHack/colorSettings.json") then return end
            local data = HttpService:JSONDecode(readfile("MegaHack/colorSettings.json"))
            if data.bgColor     then settings.colors.bgColor     = Color3.new(table.unpack(data.bgColor))     end
            if data.textColor   then settings.colors.textColor   = Color3.new(table.unpack(data.textColor))   end
            if data.strokeColor then settings.colors.strokeColor = Color3.new(table.unpack(data.strokeColor)) end
            if data.accentColor then settings.colors.accentColor = Color3.new(table.unpack(data.accentColor)) end
            if data.transparency ~= nil then settings.transparency = data.transparency end
            if data.rgbAccent   ~= nil then settings.rgbAccent   = data.rgbAccent     end
            if data.rgbStroke   ~= nil then settings.rgbStroke   = data.rgbStroke     end
        end)
    end

    return {
        T                   = T,
        updateGuiColors     = updateGuiColors,
        saveColorSettings   = saveColorSettings,
        loadColorSettings   = loadColorSettings,
        clearRgbConnections = clearRgbConnections,
        recalcDerived       = recalcDerived,

        setFrames = function(mf, sf)
            mainFrame = mf
        end,
    }
end
