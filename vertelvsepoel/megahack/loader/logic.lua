-- ============================================================================
-- logic.lua — логика главного меню, категории, настройки (без stroke)
-- ============================================================================
return function(deps)
    local TweenService       = deps.TweenService
    local UserInputService   = deps.UserInputService
    local Players            = deps.Players
    local RunService         = deps.RunService
    local TeleportService    = deps.TeleportService
    local HttpService        = deps.HttpService
    local player             = deps.player
    local platformName       = deps.platformName
    local T                  = deps.T
    local gui                = deps.gui
    local HubData            = deps.HubData
    local baseUrl            = deps.baseUrl
    local categoryMap        = deps.categoryMap
    local createNotification = deps.createNotification
    local safeLoad           = deps.safeLoad

    -- Алиасы gui
    local mainFrame      = gui.mainFrame
    local header         = gui.header
    local sidebar        = gui.sidebar
    local catScroll      = gui.catScroll
    local scrollingFrame = gui.scrollingFrame
    local closeBtn       = gui.closeBtn
    local reopenBtn      = gui.reopenButton
    local createButton   = gui.createButton
    local createLabel    = gui.createLabel
    local createSectionHeader = gui.createSectionHeader
    local mkCorner       = gui.mkCorner
    local mkStroke       = gui.mkStroke

    -- ---------- Состояние настроек ----------
    local rgbConnections = {}
    local colorPickerConnections = {}
    local settings = {
        locked = false,
        rgbAccent = false,
        transparency = 0.15,
        colors = {
            bgColor     = T.BgGlass,
            textColor   = T.TextLight,
            accentColor = T.Accent,
        }
    }

    local function saveSettings()
        createNotification("SETTINGS", "Settings saved", 2)
    end

    local function clearRgbConnections()
        for _, c in pairs(rgbConnections) do c:Disconnect() end
        rgbConnections = {}
    end

    -- ---------- Обновление цветов GUI ----------
    local function updateGuiColors()
        clearRgbConnections()
        local acc = settings.colors.accentColor
        local bg  = settings.colors.bgColor
        local txt = settings.colors.textColor

        T.Accent     = acc
        T.AccentGlow = Color3.new(math.min(acc.R * 1.25, 1), math.min(acc.G * 1.25, 1), math.min(acc.B * 1.25, 1))
        T.BgGlass    = bg
        T.BgSide     = Color3.new(math.min(bg.R + 0.025, 1), math.min(bg.G + 0.025, 1), math.min(bg.B + 0.04, 1))
        T.BgCard     = Color3.new(math.min(bg.R + 0.045, 1), math.min(bg.G + 0.045, 1), math.min(bg.B + 0.07, 1))
        T.BgHover    = Color3.new(math.min(bg.R + 0.08, 1), math.min(bg.G + 0.08, 1), math.min(bg.B + 0.12, 1))
        T.TextLight  = txt
        T.TextDim    = Color3.new(math.min(txt.R * 0.7, 1), math.min(txt.G * 0.7, 1), math.min(txt.B * 0.7, 1))
        T.Border     = Color3.new(math.min(bg.R + 0.12, 1), math.min(bg.G + 0.12, 1), math.min(bg.B + 0.18, 1))

        -- Обновление зарегистрированных акцентных объектов
        for _, entry in ipairs(deps.accentRegistry or {}) do
            if entry.obj and entry.obj.Parent then
                entry.obj[entry.prop] = acc
            end
        end

        mainFrame.BackgroundColor3 = bg
        mainFrame.BackgroundTransparency = settings.transparency
        header.BackgroundColor3 = bg
        sidebar.BackgroundColor3 = T.BgSide

        -- Обновляем все UIStroke и текст
        for _, obj in pairs(mainFrame:GetDescendants()) do
            if obj:IsA("UIStroke") then
                if settings.rgbAccent then
                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then conn:Disconnect() return end
                        obj.Color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
                    end)
                    table.insert(rgbConnections, conn)
                else
                    obj.Color = T.Border
                end
            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
                if settings.rgbAccent then
                    local conn
                    conn = RunService.Heartbeat:Connect(function()
                        if not obj:IsDescendantOf(mainFrame) then conn:Disconnect() return end
                        obj.TextColor3 = Color3.fromHSV((tick() % 5) / 5, 1, 1)
                    end)
                    table.insert(rgbConnections, conn)
                else
                    if obj:GetAttribute("TextRole") == "main" then
                        obj.TextColor3 = txt
                    end
                end
            end
        end

        -- Закрывающая кнопка отдельно
        local closeStroke = closeBtn:FindFirstChildOfClass("UIStroke")
        if closeStroke then
            if settings.rgbAccent then
                local conn
                conn = RunService.Heartbeat:Connect(function()
                    if not closeBtn:IsDescendantOf(mainFrame.Parent) then conn:Disconnect() return end
                    closeStroke.Color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
                end)
                table.insert(rgbConnections, conn)
            else
                closeStroke.Color = T.Border
            end
        end
    end

    -- ---------- Сохранение / загрузка цветовых настроек ----------
    local function saveColorSettings()
        pcall(function()
            if not isfolder("MegaHack") then makefolder("MegaHack") end
            local col = settings.colors
            local data = {
                bgColor     = { col.bgColor.R, col.bgColor.G, col.bgColor.B },
                textColor   = { col.textColor.R, col.textColor.G, col.textColor.B },
                accentColor = { col.accentColor.R, col.accentColor.G, col.accentColor.B },
                transparency = settings.transparency,
                rgbAccent    = settings.rgbAccent,
            }
            writefile("MegaHack/colorSettings.json", HttpService:JSONEncode(data))
        end)
    end

    local function loadColorSettings()
        pcall(function()
            if isfile("MegaHack/colorSettings.json") then
                local data = HttpService:JSONDecode(readfile("MegaHack/colorSettings.json"))
                if data.bgColor     then settings.colors.bgColor     = Color3.new(table.unpack(data.bgColor)) end
                if data.textColor   then settings.colors.textColor   = Color3.new(table.unpack(data.textColor)) end
                if data.accentColor then settings.colors.accentColor = Color3.new(table.unpack(data.accentColor)) end
                if data.transparency ~= nil then settings.transparency = data.transparency end
                if data.rgbAccent    ~= nil then settings.rgbAccent   = data.rgbAccent end
            end
        end)
    end

    -- ---------- Очистка контента ----------
    local function clearContent()
        for _, c in pairs(colorPickerConnections) do
            pcall(function() c:Disconnect() end)
        end
        colorPickerConnections = {}
        for _, child in ipairs(scrollingFrame:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end
    end

    -- ---------- Поиск скриптов (локально и на ScriptBlox) ----------
    local function searchScriptsByMegahack(query)
        local results = {}
        for catName, hacks in pairs(HubData) do
            if type(hacks) == "table" then
                for _, hack in ipairs(hacks) do
                    if type(hack) == "table" and hack[1] and string.find(string.lower(hack[1]), string.lower(query)) then
                        table.insert(results, { name = hack[1], category = catName, func = hack[2] })
                    end
                end
            end
        end
        return results
    end

    local function searchScriptsOnScriptBlox(query)
        local results = {}
        local ok, resp = pcall(function()
            return HttpService:GetAsync("https://scriptblox.com/api/script/search?q=" .. HttpService:UrlEncode(query))
        end)
        if ok then
            local data = HttpService:JSONDecode(resp)
            if data and data.result and data.result.scripts then
                for _, s in ipairs(data.result.scripts) do
                    table.insert(results, { name = s.title, category = "ScriptBlox", scriptId = s._id })
                end
            end
        end
        return results
    end

    -- ---------- Загрузка категории хаков ----------
    local function loadHacksFromCategory(categoryName)
        clearContent()
        local fileName = categoryMap[categoryName]
        if not fileName then
            createSectionHeader("Not Found", scrollingFrame)
            createLabel("Category missing: " .. categoryName, scrollingFrame)
            return
        end
        if not HubData[categoryName] then
            local data = safeLoad(baseUrl .. "/" .. fileName)
            if type(data) == "table" and #data > 0 then
                HubData[categoryName] = data
            else
                createSectionHeader("Error", scrollingFrame)
                createLabel("Failed to load " .. categoryName, scrollingFrame)
                return
            end
        end
        createSectionHeader(categoryName, scrollingFrame)
        for _, hack in ipairs(HubData[categoryName]) do
            if type(hack) == "table" and hack[1] and type(hack[2]) == "function" then
                createButton(hack[1], scrollingFrame, function()
                    local ok, err = pcall(hack[2])
                    if not ok then createNotification("ERROR", "Script error: " .. tostring(err), 5, 7733968497) end
                end)
            end
        end
    end

    -- ---------- Страница "Все скрипты" (поиск) ----------
    local function showAllScripts()
        clearContent()
        createSectionHeader("Search Scripts", scrollingFrame)

        local searchBox = Instance.new("TextBox")
        searchBox.Size = UDim2.new(1, 0, 0, 36)
        searchBox.BackgroundColor3 = T.BgCard
        searchBox.BackgroundTransparency = 0.2
        searchBox.TextColor3 = T.TextLight
        searchBox.PlaceholderText = "Search..."
        searchBox.PlaceholderColor3 = T.TextMuted
        searchBox.TextSize = 13
        searchBox.Text = ""
        searchBox.Font = Enum.Font.Gotham
        searchBox.ClearTextOnFocus = false
        searchBox.ZIndex = 4
        searchBox.Parent = scrollingFrame
        searchBox:SetAttribute("TextRole", "main")
        mkCorner(searchBox, 8)
        mkStroke(searchBox, 1, T.Border, 0.4)
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 12)
        pad.Parent = searchBox

        local resultsLabel = createLabel("Type to search...", scrollingFrame)
        resultsLabel.TextColor3 = T.TextMuted

        local function updateSearch(query)
            for _, child in ipairs(scrollingFrame:GetChildren()) do
                if child ~= searchBox and child ~= resultsLabel and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                    child:Destroy()
                end
            end
            if query == "" then resultsLabel.Text = "Type to search..."; return end
            resultsLabel.Text = "Searching..."
            local mh = searchScriptsByMegahack(query)
            local sb = searchScriptsOnScriptBlox(query)
            resultsLabel.Text = "Found " .. (#mh + #sb) .. " results"
            for _, r in ipairs(mh) do
                createButton(r.name .. "  [" .. r.category .. "]", scrollingFrame, function()
                    local ok, err = pcall(r.func)
                    if not ok then createNotification("ERROR", tostring(err), 5, 7733968497) end
                end)
            end
            for _, r in ipairs(sb) do
                createButton(r.name .. "  [ScriptBlox]", scrollingFrame, function()
                    createNotification("INFO", "ScriptBlox ID: " .. r.scriptId, 4)
                end)
            end
        end

        searchBox.FocusLost:Connect(function() updateSearch(searchBox.Text) end)
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            if #searchBox.Text >= 3 then
                task.delay(0.5, function() updateSearch(searchBox.Text) end)
            end
        end)
    end

    -- ---------- Домашняя страница (информация, FPS, соцсети) ----------
    local function showHome()
        clearContent()
        createSectionHeader("Overview", scrollingFrame)

        -- Карточка пользователя
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 100)
        card.BackgroundColor3 = T.BgCard
        card.BackgroundTransparency = 0.2
        card.BorderSizePixel = 0
        card.ZIndex = 4
        card.Parent = scrollingFrame
        mkCorner(card, 12)
        mkStroke(card, 1, T.Border, 0.4)

        local thumbOk, thumbUrl = pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
        end)
        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 64, 0, 64)
        avatar.Position = UDim2.new(0, 12, 0.5, -32)
        avatar.BackgroundColor3 = T.BgSide
        avatar.BackgroundTransparency = 0
        avatar.Image = thumbOk and thumbUrl or ""
        avatar.ZIndex = 5
        avatar.Parent = card
        mkCorner(avatar, 32)
        mkStroke(avatar, 2, T.Accent, 0.4)

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = player.Name
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 16
        nameLabel.TextColor3 = T.TextLight
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, -90, 0, 22)
        nameLabel.Position = UDim2.new(0, 88, 0, 14)
        nameLabel.ZIndex = 5
        nameLabel.Parent = card
        nameLabel:SetAttribute("TextRole", "main")

        local uidLabel = Instance.new("TextLabel")
        uidLabel.Text = "UserID: " .. player.UserId
        uidLabel.Font = Enum.Font.Gotham
        uidLabel.TextSize = 11
        uidLabel.TextColor3 = T.TextDim
        uidLabel.TextXAlignment = Enum.TextXAlignment.Left
        uidLabel.BackgroundTransparency = 1
        uidLabel.Size = UDim2.new(1, -90, 0, 16)
        uidLabel.Position = UDim2.new(0, 88, 0, 38)
        uidLabel.ZIndex = 5
        uidLabel.Parent = card

        local gameLabel = Instance.new("TextLabel")
        gameLabel.Text = "Game: " .. gui.gameName .. "  |  Place: " .. game.PlaceId
        gameLabel.Font = Enum.Font.Gotham
        gameLabel.TextSize = 10
        gameLabel.TextColor3 = T.TextMuted
        gameLabel.TextXAlignment = Enum.TextXAlignment.Left
        gameLabel.BackgroundTransparency = 1
        gameLabel.Size = UDim2.new(1, -90, 0, 14)
        gameLabel.Position = UDim2.new(0, 88, 0, 56)
        gameLabel.ZIndex = 5
        gameLabel.Parent = card

        local platformLabel = Instance.new("TextLabel")
        platformLabel.Text = platformName
        platformLabel.Font = Enum.Font.GothamBold
        platformLabel.TextSize = 10
        platformLabel.TextColor3 = T.AccentGlow
        platformLabel.TextXAlignment = Enum.TextXAlignment.Left
        platformLabel.BackgroundTransparency = 1
        platformLabel.Size = UDim2.new(0, 100, 0, 16)
        platformLabel.Position = UDim2.new(0, 88, 0, 74)
        platformLabel.ZIndex = 5
        platformLabel.Parent = card

        -- FPS счётчик
        local fpsCard = Instance.new("Frame")
        fpsCard.Size = UDim2.new(1, 0, 0, 36)
        fpsCard.BackgroundColor3 = T.BgCard
        fpsCard.BackgroundTransparency = 0.2
        fpsCard.BorderSizePixel = 0
        fpsCard.ZIndex = 4
        fpsCard.Parent = scrollingFrame
        mkCorner(fpsCard, 8)
        mkStroke(fpsCard, 1, T.Border, 0.4)

        local fpsLabel = Instance.new("TextLabel")
        fpsLabel.Text = "FPS: --"
        fpsLabel.Font = Enum.Font.Gotham
        fpsLabel.TextSize = 12
        fpsLabel.TextColor3 = T.TextLight
        fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
        fpsLabel.BackgroundTransparency = 1
        fpsLabel.Size = UDim2.new(1, 0, 1, 0)
        fpsLabel.ZIndex = 5
        fpsLabel.Parent = fpsCard
        fpsLabel:SetAttribute("TextRole", "main")

        local lastTime, frames = tick(), 0
        RunService.Heartbeat:Connect(function()
            frames = frames + 1
            local now = tick()
            if now - lastTime >= 1 then
                fpsLabel.Text = "FPS: " .. frames
                frames = 0
                lastTime = now
            end
        end)

        createSectionHeader("Social", scrollingFrame)
        createLabel("YouTube: @Vermax", scrollingFrame)
        createLabel("Telegram: t.me/vermax", scrollingFrame)
        createLabel("Discord: discord.gg/vermax", scrollingFrame)
    end

    -- ---------- Утилиты ----------
    local function checkFunctions()
        local list = {
            "getrawmetatable", "makefolder", "getscriptbytecode", "setthreadidentity", "request",
            "Drawing.Fonts", "iscclosure", "debug.setconstant", "lz4compress", "getscripts",
            "isfolder", "readfile", "writefile", "delfolder", "hookfunction", "getgc", "cloneref"
        }
        local avail, unavail = {}, {}
        for _, f in ipairs(list) do
            local exists = pcall(function() return _G[f] end)
            if exists then table.insert(avail, f) else table.insert(unavail, f) end
        end
        return avail, unavail
    end

    local function enableAntiKick()
        local mt = getrawmetatable(game)
        if mt then
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "Kick" or method == "kick" or method == "Ban" or method == "ban" then
                    createNotification("PROTECTION", "Blocked " .. method, 3, 7733960981)
                    return nil
                end
                return old and old(self, ...) or nil
            end)
            setreadonly(mt, true)
            createNotification("PROTECTION", "Anti-Kick/Anti-Ban active", 3, 7733960981)
        end
    end

    local function saveCoordinates()
        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local pos = root.Position
            local txt = string.format("X: %.2f, Y: %.2f, Z: %.2f", pos.X, pos.Y, pos.Z)
            if not isfolder("MegaHack") then makefolder("MegaHack") end
            writefile("MegaHack/coords.txt", txt)
            createNotification("COORDS", "Saved: " .. txt, 3, 7733960981)
        else
            createNotification("ERROR", "RootPart missing", 3, 7733968497)
        end
    end

    local function teleportToSaved()
        if isfile("MegaHack/coords.txt") then
            local txt = readfile("MegaHack/coords.txt")
            local x, y, z = txt:match("X: ([%d%.%-]+), Y: ([%d%.%-]+), Z: ([%d%.%-]+)")
            if x and y and z then
                local char = player.Character or player.CharacterAdded:Wait()
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
                    createNotification("TELEPORT", "Teleported", 3, 7733960981)
                end
            else
                createNotification("ERROR", "Invalid format", 3, 7733968497)
            end
        else
            createNotification("ERROR", "No saved coords", 3, 7733968497)
        end
    end

    -- ---------- Страница настроек ----------
    local function showSettings()
        clearContent()
        local function refresh()
            saveSettings()
            updateGuiColors()
            showSettings()
        end

        createSectionHeader("Color Picker", scrollingFrame)
        local picker = deps.theme.createColorPicker(scrollingFrame, settings)
        -- Сохраняем коннекты пикера для очистки
        for _, conn in pairs(deps.theme.colorPickerConnections or {}) do
            table.insert(colorPickerConnections, conn)
        end

        createSectionHeader("Transparency", scrollingFrame)
        for _, t in ipairs({ { "0%", 0 }, { "10%", 0.1 }, { "25%", 0.25 }, { "50%", 0.5 }, { "75%", 0.75 } }) do
            createButton(t[1], scrollingFrame, function()
                settings.transparency = t[2]
                refresh()
            end)
        end

        createSectionHeader("Server", scrollingFrame)
        createButton("Rejoin", scrollingFrame, function()
            pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
        end)
        createButton("Server Hop", scrollingFrame, function()
            pcall(function()
                local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                if #servers.data > 0 then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, servers.data[math.random(1, #servers.data)].id, player)
                else
                    createNotification("ERROR", "No servers", 4)
                end
            end)
        end)
        createButton("Copy Server ID", scrollingFrame, function()
            pcall(function() setclipboard(game.JobId); createNotification("COPIED", "Server ID copied", 2) end)
        end)

        createSectionHeader("Coordinates", scrollingFrame)
        createButton("Save Position", scrollingFrame, saveCoordinates)
        createButton("Teleport to Saved", scrollingFrame, teleportToSaved)

        createSectionHeader("Security", scrollingFrame)
        createButton("Enable Anti-Kick/Ban", scrollingFrame, enableAntiKick)
        createButton("Check Executor Funcs", scrollingFrame, function()
            local av, un = checkFunctions()
            createNotification("FUNCTIONS", "Available: " .. #av .. "/" .. (#av + #un), 5, 7733960981)
            print("=== AVAILABLE ===")
            for _, f in ipairs(av) do print("✓ " .. f) end
            print("=== UNAVAILABLE ===")
            for _, f in ipairs(un) do print("✗ " .. f) end
        end)

        createSectionHeader("Appearance", scrollingFrame)
        createButton(settings.locked and "Unlock GUI" or "Lock GUI", scrollingFrame, function()
            settings.locked = not settings.locked
            refresh()
        end)
        createButton("RGB Accents: " .. (settings.rgbAccent and "ON" or "OFF"), scrollingFrame, function()
            settings.rgbAccent = not settings.rgbAccent
            saveColorSettings()
            refresh()
        end)

        createSectionHeader("Actions", scrollingFrame)
        createButton("Apply & Restart", scrollingFrame, function()
            saveSettings()
            gui.screenGui:Destroy()
            loadstring(game:HttpGet("https://pastefy.app/QVzDuYQA/raw", true))()
        end)
        createButton("Close GUI", scrollingFrame, function()
            gui.screenGui:Destroy()
        end)
    end

    -- ---------- Перетаскивание окна ----------
    local function makeDraggable(frame, dragHandle)
        dragHandle = dragHandle or frame
        local dragging, dragInput, startPos, framePos
        dragHandle.InputBegan:Connect(function(input)
            if not settings.locked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                dragging = true
                startPos = input.Position
                framePos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        dragHandle.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - startPos
                frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
            end
        end)
    end

    -- ---------- Инициализация ----------
    return {
        init = function()
            loadColorSettings()
            updateGuiColors()

            -- Категории из карты
            local specialOrder = { "Home", "Settings", "All Scripts" }
            local specialFuncs = {
                Home = function() clearContent(); showHome(); updateGuiColors() end,
                Settings = function() clearContent(); showSettings(); updateGuiColors() end,
                ["All Scripts"] = function() clearContent(); showAllScripts(); updateGuiColors() end,
            }
            for _, name in ipairs(specialOrder) do
                createButton(name, catScroll, specialFuncs[name], true)
            end
            for catName in pairs(categoryMap) do
                createButton(catName, catScroll, function()
                    clearContent()
                    loadHacksFromCategory(catName)
                    updateGuiColors()
                end, true)
            end

            -- Перетаскивание
            makeDraggable(mainFrame, header)

            -- Закрытие / открытие
            closeBtn.MouseButton1Click:Connect(function()
                TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                    Size = UDim2.new(0, 520, 0, 0),
                    BackgroundTransparency = 1
                }):Play()
                task.delay(0.25, function()
                    mainFrame.Visible = false
                    mainFrame.Size = UDim2.new(0, 520, 0, 380)
                    mainFrame.BackgroundTransparency = settings.transparency
                    reopenBtn.Visible = true
                end)
            end)
            reopenBtn.MouseButton1Click:Connect(function()
                mainFrame.Visible = true
                mainFrame.Size = UDim2.new(0, 520, 0, 0)
                mainFrame.BackgroundTransparency = 1
                reopenBtn.Visible = false
                TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 520, 0, 380),
                    BackgroundTransparency = settings.transparency
                }):Play()
            end)

            -- Анимация появления
            mainFrame.Size = UDim2.new(0, 0, 0, 0)
            mainFrame.BackgroundTransparency = 1
            TweenService:Create(mainFrame, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 520, 0, 380),
                BackgroundTransparency = settings.transparency
            }):Play()

            showHome()
            updateGuiColors()

            -- Подсветить первую кнопку в sidebar
            task.delay(0.1, function()
                local first = catScroll:FindFirstChildWhichIsA("TextButton")
                if first then
                    first:SetAttribute("Active", true)
                    TweenService:Create(first, TweenInfo.new(0.15), { BackgroundColor3 = T.Accent, BackgroundTransparency = 0.3, TextColor3 = T.TextLight }):Play()
                    local ind = first:FindFirstChildOfClass("Frame")
                    if ind then TweenService:Create(ind, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play() end
                end
            end)

            createNotification("AURA v2", "Ready on " .. platformName, 3, 74283928898866)
        end
    }
end
