return function(deps)
    local TweenService       = deps.TweenService
    local RunService         = deps.RunService
    local HttpService        = deps.HttpService
    local UserInputService   = deps.UserInputService
    local playerGui          = deps.playerGui
    local accentRegistry     = deps.accentRegistry
    local createNotification = deps.createNotification or function() end

    local mainFrame, scrollingFrame

    local T = {
        BgBase     = Color3.fromRGB(8,   8,  12),
        BgSide     = Color3.fromRGB(12,  12,  18),
        BgPanel    = Color3.fromRGB(18,  18,  26),
        BgBtn      = Color3.fromRGB(24,  24,  34),
        BgBtnHov   = Color3.fromRGB(32,  32,  46),
        Accent     = Color3.fromRGB(150, 25,  25),
        AccentHov  = Color3.fromRGB(185, 40,  40),
        AccentGlow = Color3.fromRGB(210, 60,  60),
        TextMain   = Color3.fromRGB(240, 240, 245),
        TextSub    = Color3.fromRGB(155, 155, 168),
        TextMuted  = Color3.fromRGB(85,  85,  100),
        Stroke     = Color3.fromRGB(40,  40,  55),
        StrokeBrt  = Color3.fromRGB(60,  60,  78),
        Separator  = Color3.fromRGB(32,  32,  46),
    }

    local rgbConnections = {}

    local function clearRgbConnections()
        for _, c in pairs(rgbConnections) do pcall(function() c:Disconnect() end) end
        rgbConnections = {}
    end

    local function updateGuiColors(settings)
        if not mainFrame then return end
        clearRgbConnections()

        local acc = settings.colors.accentColor
        local bg  = settings.colors.bgColor
        local tx  = settings.colors.textColor
        local str = settings.colors.strokeColor

        T.Accent = acc
        T.AccentHov = Color3.new(math.min(acc.R*1.22,1), math.min(acc.G*1.22,1), math.min(acc.B*1.22,1))
        T.AccentGlow = Color3.new(math.min(acc.R*1.40,1), math.min(acc.G*1.40,1), math.min(acc.B*1.40,1))
        T.BgBase = bg
        T.BgSide = Color3.new(math.min(bg.R+0.020,1), math.min(bg.G+0.020,1), math.min(bg.B+0.028,1))
        T.BgPanel = Color3.new(math.min(bg.R+0.043,1), math.min(bg.G+0.043,1), math.min(bg.B+0.060,1))
        T.BgBtn = Color3.new(math.min(bg.R+0.067,1), math.min(bg.G+0.067,1), math.min(bg.B+0.090,1))
        T.BgBtnHov = Color3.new(math.min(bg.R+0.098,1), math.min(bg.G+0.098,1), math.min(bg.B+0.137,1))
        T.TextMain = tx
        T.Stroke = str

        if accentRegistry then
            for _, entry in ipairs(accentRegistry) do
                if entry.obj and entry.obj.Parent then
                    pcall(function() entry.obj[entry.prop or "BackgroundColor3"] = acc end)
                end
            end
        end

        mainFrame.BackgroundColor3 = bg
        mainFrame.BackgroundTransparency = settings.transparency or 0.04
        
        -- Optimized Glass Gradient Update instead of extra frames
        local glassGrad = mainFrame:FindFirstChildOfClass("UIGradient")
        if glassGrad then
            glassGrad.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(0.95,0.95,1))
            glassGrad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.82),
                NumberSequenceKeypoint.new(0.5, 0.88),
                NumberSequenceKeypoint.new(1, 0.94)
            })
        end

        local closeBtnObj = mainFrame:FindFirstChild("CloseBtn", true)
        for _, obj in pairs(mainFrame:GetDescendants()) do
            if obj == closeBtnObj or (closeBtnObj and obj:IsDescendantOf(closeBtnObj)) then continue end
            if obj:IsA("UIStroke") then
                local p = obj.Parent
                local isWhite = p and table.find({"HomeCard","FpsCard","PingCard","ExecCard"}, p.Name)
                if isWhite then obj.Color = Color3.new(1,1,1); obj.Transparency = 0.80
                else
                    if settings.rgbStroke then
                        local conn; conn = RunService.Heartbeat:Connect(function()
                            if not obj:IsDescendantOf(mainFrame) then conn:Disconnect(); return end
                            obj.Color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
                        end)
                        table.insert(rgbConnections, conn)
                    else obj.Color = str end
                end
            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if settings.rgbAccent then
                    local conn; conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then conn:Disconnect(); return end
                        obj.TextColor3 = Color3.fromHSV((tick() % 5) / 5, 1, 1)
                    end)
                    table.insert(rgbConnections, conn)
                else
                    if obj:GetAttribute("TextRole") == "main" then obj.TextColor3 = tx end
                end
            elseif obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
                local name = obj.Name
                if name == "SidebarFrame" then obj.BackgroundColor3 = T.BgSide
                elseif name == "GameCardBg" or name == "HomeCard" or name == "FpsCard" or name == "PingCard" or name == "ExecCard" then
                    obj.BackgroundColor3 = T.BgPanel
                elseif name == "PlatBadge" then obj.BackgroundColor3 = acc
                end
            end
        end
    end

    local function saveColorSettings(settings)
        pcall(function()
            if not isfolder("RussElite") then makefolder("RussElite") end
            local col = settings.colors
            writefile("RussElite/colorSettings.json", HttpService:JSONEncode({
                bgColor = {col.bgColor.R, col.bgColor.G, col.bgColor.B},
                textColor = {col.textColor.R, col.textColor.G, col.textColor.B},
                strokeColor = {col.strokeColor.R, col.strokeColor.G, col.strokeColor.B},
                accentColor = {col.accentColor.R, col.accentColor.G, col.accentColor.B},
                transparency = settings.transparency, rgbAccent = settings.rgbAccent, rgbStroke = settings.rgbStroke,
            }))
        end)
    end

    local function loadColorSettings(settings)
        pcall(function()
            if not isfile("RussElite/colorSettings.json") then return end
            local data = HttpService:JSONDecode(readfile("RussElite/colorSettings.json"))
            if data.bgColor then settings.colors.bgColor = Color3.new(table.unpack(data.bgColor)) end
            if data.textColor then settings.colors.textColor = Color3.new(table.unpack(data.textColor)) end
            if data.strokeColor then settings.colors.strokeColor = Color3.new(table.unpack(data.strokeColor)) end
            if data.accentColor then settings.colors.accentColor = Color3.new(table.unpack(data.accentColor)) end
            if data.transparency ~= nil then settings.transparency = data.transparency end
            if data.rgbAccent ~= nil then settings.rgbAccent = data.rgbAccent end
            if data.rgbStroke ~= nil then settings.rgbStroke = data.rgbStroke end
        end)
    end

    return {
        T = T, updateGuiColors = updateGuiColors, saveColorSettings = saveColorSettings, loadColorSettings = loadColorSettings, clearRgbConnections = clearRgbConnections,
        setFrames = function(mf, sf) mainFrame = mf; scrollingFrame = sf end,
    }
end
