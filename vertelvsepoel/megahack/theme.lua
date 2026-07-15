return function(deps)
    local RunService = deps.RunService
    local HttpService = deps.HttpService
    local SafeFile = deps.SafeFile

    local ThemeColors = {
        VoidDeep = Color3.fromRGB(6, 6, 12), VoidMid = Color3.fromRGB(10, 10, 18), VoidLight = Color3.fromRGB(16, 16, 28),
        GlassDark = Color3.fromRGB(18, 18, 32), GlassMid = Color3.fromRGB(24, 24, 42), GlassLight = Color3.fromRGB(32, 32, 54),
        GlassHover = Color3.fromRGB(40, 40, 66), NeonPrimary = Color3.fromRGB(0, 200, 255), NeonSecondary = Color3.fromRGB(140, 80, 255),
        TextBright = Color3.fromRGB(245, 245, 255), TextNormal = Color3.fromRGB(200, 200, 220), TextDim = Color3.fromRGB(120, 120, 150),
        TextMuted = Color3.fromRGB(70, 70, 95), StrokeNeon = Color3.fromRGB(0, 180, 255), StrokeSubtle = Color3.fromRGB(40, 40, 70),
        Success = Color3.fromRGB(0, 255, 140), Warning = Color3.fromRGB(255, 200, 0), Error = Color3.fromRGB(255, 60, 80),
    }

    local Settings = {
        rgbMode = false, neonPulse = true, transparency = 0.05, unlockX = 0.5, unlockY = 0.5, accentHue = 0.52,
        colors = { accent = Color3.fromRGB(0, 200, 255), bg = Color3.fromRGB(6, 6, 12), text = Color3.fromRGB(245, 245, 255), stroke = Color3.fromRGB(0, 180, 255) }
    }

    local RGB_CONNS = {}

    local function loadSettings()
        pcall(function()
            local raw = SafeFile.read("MegaHack/settings_v3.json")
            if not raw then return end
            local data = HttpService:JSONDecode(raw)
            for k,v in pairs(data) do
                if type(v) ~= "table" then Settings[k] = v
                elseif k == "colors" then
                    for ck, cv in pairs(v) do
                        if type(cv) == "table" and #cv == 3 then Settings.colors[ck] = Color3.new(cv[1], cv[2], cv[3]) end
                    end
                end
            end
        end)
    end

    local function saveSettings()
        pcall(function()
            SafeFile.write("MegaHack/settings_v3.json", HttpService:JSONEncode({
                rgbMode=Settings.rgbMode, neonPulse=Settings.neonPulse, transparency=Settings.transparency,
                accentHue=Settings.accentHue, unlockX=Settings.unlockX, unlockY=Settings.unlockY,
                colors = {
                    accent={Settings.colors.accent.R, Settings.colors.accent.G, Settings.colors.accent.B},
                    bg={Settings.colors.bg.R, Settings.colors.bg.G, Settings.colors.bg.B},
                    text={Settings.colors.text.R, Settings.colors.text.G, Settings.colors.text.B},
                    stroke={Settings.colors.stroke.R, Settings.colors.stroke.G, Settings.colors.stroke.B}
                }
            }))
        end)
    end

    local function ApplyColors(guiRefs)
        if not guiRefs then return end
        local acc, bg, tx, st = Settings.colors.accent, Settings.colors.bg, Settings.colors.text, Settings.colors.stroke
        guiRefs.MainFrame.BackgroundColor3 = bg
        guiRefs.MainStroke.Color = st
        guiRefs.HeaderLine.BackgroundColor3 = st
        guiRefs.LogoGlow.BackgroundColor3 = acc
        guiRefs.LogoStroke.Color = acc
        guiRefs.VerBadge.BackgroundColor3 = acc
        guiRefs.ScriptScroll.ScrollBarImageColor3 = acc
        guiRefs.GamesPanel.ScrollBarImageColor3 = acc
        guiRefs.SidebarSep.BackgroundColor3 = st
        guiRefs.ReopenBtn.BackgroundColor3 = acc
        guiRefs.ReopenStroke.Color = acc
        guiRefs.ReopenGlow.BackgroundColor3 = acc
    end

    local function ClearRGB()
        for _,c in pairs(RGB_CONNS) do pcall(function() c:Disconnect() end) end
        RGB_CONNS = {}
    end

    local function StartRGB(guiRefs)
        ClearRGB()
        table.insert(RGB_CONNS, RunService.Heartbeat:Connect(function()
            local color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
            if not guiRefs then return end
            guiRefs.MainStroke.Color = color
            guiRefs.HeaderLine.BackgroundColor3 = color
            guiRefs.SidebarSep.BackgroundColor3 = color
            guiRefs.LogoGlow.BackgroundColor3 = color
            guiRefs.LogoStroke.Color = color
            guiRefs.VerBadge.BackgroundColor3 = color
            guiRefs.ScriptScroll.ScrollBarImageColor3 = color
            guiRefs.GamesPanel.ScrollBarImageColor3 = color
            guiRefs.ReopenBtn.BackgroundColor3 = color
            guiRefs.ReopenStroke.Color = color
        end))
    end

    loadSettings()

    return {
        ThemeColors = ThemeColors,
        Settings = Settings,
        saveSettings = saveSettings,
        ApplyColors = ApplyColors,
        StartRGB = StartRGB,
        ClearRGB = ClearRGB
    }
end
