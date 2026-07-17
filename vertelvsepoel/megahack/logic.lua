═══════════════════════════════════════════════════════════════
--  logic.lua — Full Logic Layer v3 (STABLE)
═══════════════════════════════════════════════════════════════

local BASE_RAW = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/"

return function(deps)
    local TweenService       = deps.TweenService
    local UserInputService   = deps.UserInputService
    local RunService         = deps.RunService
    local HttpService        = deps.HttpService
    local T                  = deps.T
    local gui                = deps.gui
    local HubData            = deps.HubData
    local categoryMap        = deps.categoryMap
    local gameIcons          = deps.gameIcons or {}
    local createNotification = deps.createNotification
    local safeLoad           = deps.safeLoad

    local mainFrame           = gui.mainFrame
    local scrollingFrame      = gui.scrollingFrame
    local gamesPanel          = gui.gamesPanel
    local closeBtn            = gui.closeBtn
    local reopenButton        = gui.reopenButton
    local catScroll           = gui.catScroll
    local createButton        = gui.createButton
    local createLabel         = gui.createLabel
    local createSectionHeader = gui.createSectionHeader
    local mkGlassCard         = gui.mkGlassCard
    local mkCorner            = gui.mkCorner
    local mkStroke            = gui.mkStroke

    local function loadSubmodule(name)
        local ok, result = pcall(function()
            return loadstring(game:HttpGet(BASE_RAW .. name .. "?t=" .. math.floor(tick()), true))()
        end)
        if ok and type(result) == "function" then return result end
        return nil
    end

    -- ИСПРАВЛЕНО: Используем local вместо let
    local settings = {
        locked = false, rgbAccent = false, rgbStroke = false, transparency = 0.04,
        colors = {
            bgColor = T.BgBase, textColor = T.TextMain,
            strokeColor = T.Stroke, accentColor = T.Accent,
        }
    }

    local currentTab       = "Home"
    local currentCategory  = nil
    local catButtons       = {}
    local colorPickerOpen  = false
    local colorPickerFrame = nil

    local function clearContent()
        for _, child in ipairs(scrollingFrame:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end
    end

    -- ИСПРАВЛЕНО: Правильная инициализация модулей
    local StatsModule = loadSubmodule("stats.lua")
    if StatsModule then StatsModule = StatsModule({ RunService = RunService, HttpService = HttpService, player = deps.player, createNotification = createNotification }) end
    if StatsModule then StatsModule.init() end

    local HomeModuleFactory = loadSubmodule("home.lua")
    local HomeModule = HomeModuleFactory and HomeModuleFactory({ RunService = RunService, Players = deps.Players, T = T, gui = gui, player = deps.player, platformName = deps.platformName }) or { showHome = function() end }

    local GamesModuleFactory = loadSubmodule("games.lua")
    local GamesModule = GamesModuleFactory and GamesModuleFactory({ TweenService = TweenService, RunService = RunService, T = T, gui = gui, categoryMap = categoryMap, gameIcons = gameIcons }) or { showGames = function() end, reset = function() end }

    -- ИСПРАВЛЕНО: Инициализация ColorPicker
    local ColorPickerModule = nil
    local CPFactory = loadSubmodule("colorpicker.lua")
    if CPFactory then
        ColorPickerModule = CPFactory({
            TweenService = TweenService, UserInputService = UserInputService,
            RunService = RunService, T = T, gui = gui, settings = settings,
            updateGuiColors = function() if deps.theme and deps.theme.updateGuiColors then deps.theme.updateGuiColors(settings) end end,
            saveColorSettings = function()
                pcall(function()
                    if not isfolder("MegaHack") then makefolder("MegaHack") end
                    local col = settings.colors
                    writefile("MegaHack/colorSettings.json", HttpService:JSONEncode({
                        bgColor={col.bgColor.R,col.bgColor.G,col.bgColor.B}, textColor={col.textColor.R,col.textColor.G,col.textColor.B},
                        strokeColor={col.strokeColor.R,col.strokeColor.G,col.strokeColor.B}, accentColor={col.accentColor.R,col.accentColor.G,col.accentColor.B},
                        transparency=settings.transparency, rgbAccent=settings.rgbAccent, rgbStroke=settings.rgbStroke,
                    }))
                end)
            end,
            createNotification = createNotification
        })
    end

    local function loadColorSettings()
        pcall(function()
            if not isfile("MegaHack/colorSettings.json") then return end
            local data = HttpService:JSONDecode(readfile("MegaHack/colorSettings.json"))
            if data.bgColor then settings.colors.bgColor = Color3.new(table.unpack(data.bgColor)) end
            if data.textColor then settings.colors.textColor = Color3.new(table.unpack(data.textColor)) end
            if data.strokeColor then settings.colors.strokeColor = Color3.new(table.unpack(data.strokeColor)) end
            if data.accentColor then settings.colors.accentColor = Color3.new(table.unpack(data.accentColor)) end
            if data.transparency ~= nil then settings.transparency = data.transparency end
            if data.rgbAccent ~= nil then settings.rgbAccent = data.rgbAccent end
            if data.rgbStroke ~= nil then settings.rgbStroke = data.rgbStroke end
        end)
    end
    loadColorSettings()

    local theme = deps.theme
    if theme and theme.loadColorSettings then theme.loadColorSettings(settings) end
    if theme and theme.updateGuiColors then theme.updateGuiColors(settings) end

    -- SIDEBAR
    local specialTabs = { { name = "⌂ Home", key = "Home" }, { name = "⊞ Games", key = "Games" }, { name = "♦ Settings", key = "Settings" } }

    local function createCatButton(name, isSpecial, order)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = T.BgBtn
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 0
        btn.Text = "  " .. name
        btn.TextColor3 = T.TextSub
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.LayoutOrder = order
        btn.ZIndex = 5
        btn.Parent = catScroll
        mkCorner(btn, 8)

        local hoverStroke = Instance.new("UIStroke")
        hoverStroke.Thickness = 1
        hoverStroke.Color = T.Accent
        hoverStroke.Transparency = 1
        hoverStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        hoverStroke.Parent = btn

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 3, 1, -8)
        indicator.Position = UDim2.new(0, 4, 0, 4)
        indicator.BackgroundColor3 = T.Accent
        indicator.BackgroundTransparency = 1
        indicator.BorderSizePixel = 0
        indicator.ZIndex = 6
        indicator.Parent = btn
        mkCorner(indicator, 2)

        btn.MouseButton1Click:Connect(function()
            if isSpecial then switchTab(name) else switchToCategory(name) end
        end)

        catButtons[name] = { btn = btn, hoverStroke = hoverStroke, indicator = indicator }
    end

    for i, tab in ipairs(specialTabs) do createCatButton(tab.name, true, i) end
    
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -8, 0, 1)
    sep.BackgroundColor3 = T.StrokeBrt
    sep.BackgroundTransparency = 0.6
    sep.BorderSizePixel = 0
    sep.LayoutOrder = #specialTabs + 1
    sep.ZIndex = 5
    sep.Parent = catScroll

    local sortedCats = {}
    for catName in pairs(categoryMap) do table.insert(sortedCats, catName) end
    table.sort(sortedCats)
    for i, catName in ipairs(sortedCats) do createCatButton(catName, false, #specialTabs + 1 + i) end

    local function highlightButton(name)
        for btnName, data in pairs(catButtons) do
            if btnName == name then
                TweenService:Create(data.btn, TweenInfo.new(0.2), { BackgroundTransparency = 0.05, BackgroundColor3 = T.BgCard }):Play()
                TweenService:Create(data.hoverStroke, TweenInfo.new(0.2), { Transparency = 0.3 }):Play()
                TweenService:Create(data.indicator, TweenInfo.new(0.2), { BackgroundTransparency = 0.1 }):Play()
                data.btn.TextColor3 = T.TextMain
            else
                TweenService:Create(data.btn, TweenInfo.new(0.2), { BackgroundTransparency = 0.3, BackgroundColor3 = T.BgBtn }):Play()
                TweenService:Create(data.hoverStroke, TweenInfo.new(0.2), { Transparency = 1 }):Play()
                TweenService:Create(data.indicator, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
                data.btn.TextColor3 = T.TextSub
            end
        end
    end

    function switchTab(name)
        currentTab = name
        currentCategory = nil
        highlightButton(name)
        scrollingFrame.Visible = true
        gamesPanel.Visible = false
        if GamesModule then GamesModule.reset() end
        clearContent()

        if name == "Home" then
            HomeModule.showHome(scrollingFrame)
        elseif name == "Games" then
            scrollingFrame.Visible = false
            gamesPanel.Visible = true
            GamesModule.showGames({ onCategoryClick = function(catName) switchToCategory(catName) end })
        elseif name == "Settings" then
            buildSettingsTab()
        end
        if StatsModule then StatsModule.recordTabClick(name) end
    end

    function switchToCategory(name)
        currentTab = nil
        currentCategory = name
        highlightButton(name)
        scrollingFrame.Visible = true
        gamesPanel.Visible = false
        if GamesModule then GamesModule.reset() end
        clearContent()
        createSectionHeader(name, scrollingFrame)

        local scripts = HubData[name]
        if not scripts or #scripts == 0 then
            createLabel("No scripts loaded yet.", scrollingFrame)
            return
        end

        for i, scriptData in ipairs(scripts) do
            local scriptName = type(scriptData) == "table" and scriptData.name or tostring(scriptData)
            local scriptContent = type(scriptData) == "table" and scriptData.script or scriptData
            
            createButton(scriptName, scrollingFrame, function()
                createNotification("EXECUTING", "Running: " .. scriptName, 2)
                pcall(function()
                    local fn = loadstring(scriptContent)
                    if fn then fn() else createNotification("ERROR", "Failed to compile.", 3) end
                end)
            end)
        end
        if StatsModule then StatsModule.recordTabClick(name) end
    end

    function buildSettingsTab()
        createSectionHeader("Interface", scrollingFrame)
        
        local transCard = mkGlassCard(scrollingFrame, UDim2.new(1, 0, 0, 50), nil, T.BgCard, 0.15, 4, 12)
        local transLabel = Instance.new("TextLabel")
        transLabel.BackgroundTransparency = 1
        transLabel.Text = "Background Transparency"
        transLabel.Font = Enum.Font.GothamBold
        transLabel.TextColor3 = T.TextMain
        transLabel.TextSize = 12
        transLabel.Size = UDim2.new(0.5, 0, 1, 0)
        transLabel.Position = UDim2.new(0, 12, 0, 0)
        transLabel.ZIndex = 6
        transLabel.Parent = transCard
        transLabel:SetAttribute("TextRole", "main")

        local transVal = Instance.new("TextLabel")
        transVal.BackgroundTransparency = 1
        transVal.Text = math.floor(settings.transparency * 100) .. "%"
        transVal.Font = Enum.Font.GothamBold
        transVal.TextColor3 = T.Accent
        transVal.TextSize = 12
        transVal.Size = UDim2.new(0, 50, 1, 0)
        transVal.Position = UDim2.new(1, -60, 0, 0)
        transVal.ZIndex = 6
        transVal.Parent = transCard

        local transSlider = Instance.new("TextButton")
        transSlider.Size = UDim2.new(0.3, 0, 0, 20)
        transSlider.Position = UDim2.new(0.55, 0, 0.5, -10)
        transSlider.BackgroundColor3 = T.BgDeep
        transSlider.BackgroundTransparency = 0.2
        transSlider.Text = ""
        transSlider.ZIndex = 7
        transSlider.Parent = transCard
        mkCorner(transSlider, 10)
        mkStroke(transSlider, 1, T.StrokeBrt, 0.5)

        local transFill = Instance.new("Frame")
        transFill.Size = UDim2.new(settings.transparency, 0, 1, 0)
        transFill.BackgroundColor3 = T.Accent
        transFill.BackgroundTransparency = 0.3
        transFill.BorderSizePixel = 0
        transFill.ZIndex = 8
        transFill.Parent = transSlider
        mkCorner(transFill, 10)

        local transDragging = false
        transSlider.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then transDragging = true end end)
        local function updateTrans(input)
            if not transDragging then return end
            local relX = math.clamp((input.Position.X - transSlider.AbsolutePosition.X) / transSlider.AbsoluteSize.X, 0, 0.8)
            settings.transparency = relX
            transFill.Size = UDim2.new(relX, 0, 1, 0)
            transVal.Text = math.floor(relX * 100) .. "%"
            if theme and theme.updateGuiColors then theme.updateGuiColors(settings) end
        end
        transSlider.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then updateTrans(input) end end)
        UserInputService.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then updateTrans(input) end end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then transDragging = false end end)

        createSectionHeader("Effects", scrollingFrame)
        
        local function createToggle(text, state, callback)
            local row = mkGlassCard(scrollingFrame, UDim2.new(1, 0, 0, 40), nil, T.BgCard, 0.15, 4, 10)
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextColor3 = T.TextMain
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Size = UDim2.new(1, -60, 1, 0)
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.ZIndex = 6
            lbl.Parent = row
            lbl:SetAttribute("TextRole", "main")

            local toggleBg = Instance.new("Frame")
            toggleBg.Size = UDim2.new(0, 40, 0, 22)
            toggleBg.Position = UDim2.new(1, -52, 0.5, -11)
            toggleBg.BackgroundColor3 = T.BgDeep
            toggleBg.BackgroundTransparency = 0.2
            toggleBg.ZIndex = 7
            toggleBg.Parent = row
            mkCorner(toggleBg, 11)

            local toggleCircle = Instance.new("Frame")
            toggleCircle.Size = UDim2.new(0, 18, 0, 18)
            toggleCircle.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            toggleCircle.BackgroundColor3 = state and T.Accent or T.TextMuted
            toggleCircle.BorderSizePixel = 0
            toggleCircle.ZIndex = 8
            toggleCircle.Parent = toggleBg
            mkCorner(toggleCircle, 9)

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = 9
            btn.Parent = row

            btn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(toggleCircle, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
                    Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                    BackgroundColor3 = state and T.Accent or T.TextMuted
                }):Play()
                callback(state)
            end)
        end

        createToggle("RGB Accent Text", settings.rgbAccent, function(val)
            settings.rgbAccent = val
            if theme and theme.updateGuiColors then theme.updateGuiColors(settings) end
        end)

        createToggle("RGB Stroke Glow", settings.rgbStroke, function(val)
            settings.rgbStroke = val
            if theme and theme.updateGuiColors then theme.updateGuiColors(settings) end
        end)

        createSectionHeader("Customize", scrollingFrame)
        
        createButton("✦  Open Color Picker", scrollingFrame, function()
            if colorPickerOpen then return end
            colorPickerOpen = true
            colorPickerFrame = mkGlassCard(scrollingFrame, UDim2.new(1, 0, 0, 360), nil, T.BgPanel, 0.05, 10, 14)
            
            if ColorPickerModule and ColorPickerModule.createColorPicker then
                ColorPickerModule.createColorPicker(colorPickerFrame, {})
            end
            
            local closeCp = Instance.new("TextButton")
            closeCp.Size = UDim2.new(1, 0, 0, 30)
            closeCp.Position = UDim2.new(0, 0, 1, -30)
            closeCp.BackgroundColor3 = T.BgBtn
            closeCp.BackgroundTransparency = 0.2
            closeCp.Text = "CLOSE PICKER"
            closeCp.TextColor3 = T.TextMain
            closeCp.Font = Enum.Font.GothamBold
            closeCp.TextSize = 11
            closeCp.ZIndex = 20
            closeCp.Parent = colorPickerFrame
            mkCorner(closeCp, 8)
            closeCp:SetAttribute("TextRole", "main")
            
            closeCp.MouseButton1Click:Connect(function()
                if colorPickerFrame then colorPickerFrame:Destroy() end
                colorPickerFrame = nil
                colorPickerOpen = false
            end)
        end)

        createSectionHeader("Your Stats", scrollingFrame)
        if StatsModule then
            local data = StatsModule.getData()
            local statsCard = mkGlassCard(scrollingFrame, UDim2.new(1, 0, 0, 80), nil, T.BgCard, 0.12, 4, 12)
            local statsTexts = {
                "⏱ Total Time: " .. StatsModule.formatTime(data.totalSeconds),
                "🔄 Sessions: " .. (data.totalSessions or 0),
                "🔥 Streak: " .. (data.streak or 0) .. " days"
            }
            for i, txt in ipairs(statsTexts) do
                local l = Instance.new("TextLabel")
                l.BackgroundTransparency = 1
                l.Text = txt
                l.Font = Enum.Font.GothamBold
                l.TextColor3 = T.TextSub
                l.TextSize = 12
                l.TextXAlignment = Enum.TextXAlignment.Left
                l.Size = UDim2.new(1, -16, 0, 20)
                l.Position = UDim2.new(0, 12, 0, (i-1)*24)
                l.ZIndex = 6
                l.Parent = statsCard
            end
        end
    end

    -- CLOSE / REOPEN
    local guiOpen = true
    closeBtn.MouseButton1Click:Connect(function()
        guiOpen = false
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        task.delay(0.3, function()
            mainFrame.Visible = false
            reopenButton.Visible = true
        end)
    end)

    reopenButton.MouseButton1Click:Connect(function()
        if guiOpen then return end
        guiOpen = true
        reopenButton.Visible = false
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 620, 0, 420), Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.LeftControl then
            if guiOpen then closeBtn.MouseButton1Click:Fire() else reopenButton.MouseButton1Click:Fire() end
        end
    end)

    switchTab("Home")
    createNotification("MEGAHACK 2026", "Loaded successfully!", 3)
    return {}
end
