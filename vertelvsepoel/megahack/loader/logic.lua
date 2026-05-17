-- logic.lua
-- Вся логика: Home, Settings, Search, категории, drag, open/close.
-- Получает deps+gui, возвращает { init = function() }

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
    local theme              = deps.theme

    -- Алиасы
    local mainFrame         = gui.mainFrame
    local headerFrame       = gui.headerFrame
    local headerPatch       = gui.headerPatch
    local sidebarFrame      = gui.sidebarFrame
    local sidebarPatch      = gui.sidebarPatch
    local sidebarBLCorner   = gui.sidebarBLCorner
    local catScroll         = gui.catScroll
    local scrollingFrame    = gui.scrollingFrame
    local closeBtn          = gui.closeBtn
    local reopenButton      = gui.reopenButton
    local createButton      = gui.createButton
    local createLabel       = gui.createLabel
    local createSectionHeader = gui.createSectionHeader
    local mkCorner          = gui.mkCorner

    -- ═══════════════════════════════
    --  НАСТРОЙКИ
    -- ═══════════════════════════════
    local settings = {
        locked      = false,
        rgbText     = false,
        transparency = 0.06,
        colors = {
            accentColor = T.Accent,
            bgColor     = T.BgBase,
            textColor   = T.TextMain,
        },
    }

    -- ═══════════════════════════════
    --  ПРИМЕНЕНИЕ ЦВЕТОВ
    -- ═══════════════════════════════
    local function applyAll()
        theme.applyColors(settings, mainFrame)

        -- Обновляем цвета фреймов вручную (они вне mainFrame или патчи)
        headerFrame.BackgroundColor3       = T.BgSide
        headerFrame.BackgroundTransparency = 0.08
        headerPatch.BackgroundColor3       = T.BgSide
        headerPatch.BackgroundTransparency = 0.08
        sidebarFrame.BackgroundColor3      = T.BgSide
        sidebarFrame.BackgroundTransparency = 0.12
        sidebarPatch.BackgroundColor3      = T.BgSide
        sidebarPatch.BackgroundTransparency = 0.12
        sidebarBLCorner.BackgroundColor3   = T.BgSide
        sidebarBLCorner.BackgroundTransparency = 0.12
    end

    -- ═══════════════════════════════
    --  ОЧИСТКА КОНТЕНТА
    -- ═══════════════════════════════
    local function clearContent()
        for _, ch in ipairs(scrollingFrame:GetChildren()) do
            if not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then
                ch:Destroy()
            end
        end
    end

    -- ═══════════════════════════════
    --  ПОИСК
    -- ═══════════════════════════════
    local function searchLocal(q)
        local res = {}
        for cat, hacks in pairs(HubData) do
            if type(hacks) == "table" then
                for _, h in ipairs(hacks) do
                    if type(h) == "table" and type(h[1]) == "string" then
                        if h[1]:lower():find(q:lower(), 1, true) then
                            table.insert(res, {name=h[1], cat=cat, fn=h[2]})
                        end
                    end
                end
            end
        end
        return res
    end

    local function searchScriptblox(q)
        local res = {}
        pcall(function()
            local raw = HttpService:GetAsync("https://scriptblox.com/api/script/search?q=" .. HttpService:UrlEncode(q))
            local d = HttpService:JSONDecode(raw)
            if d and d.result and d.result.scripts then
                for _, s in ipairs(d.result.scripts) do
                    table.insert(res, {name=s.title, cat="ScriptBlox", id=s._id})
                end
            end
        end)
        return res
    end

    -- ═══════════════════════════════
    --  ЗАГРУЗКА КАТЕГОРИИ
    -- ═══════════════════════════════
    local function loadCategory(name)
        clearContent()
        local file = categoryMap[name]
        if not file then
            createSectionHeader("Не найдено", scrollingFrame)
            createLabel("⚠ Нет в base.lua: " .. name, scrollingFrame)
            return
        end
        if not HubData[name] then
            local data = safeLoad(baseUrl .. "/" .. file)
            if type(data) == "table" and #data > 0 then
                HubData[name] = data
            else
                createSectionHeader("Ошибка загрузки", scrollingFrame)
                createLabel("⚠ Пустой или битый файл: " .. name, scrollingFrame)
                return
            end
        end
        createSectionHeader(name, scrollingFrame)
        for _, h in ipairs(HubData[name]) do
            if type(h) == "table" and type(h[1]) == "string" and type(h[2]) == "function" then
                createButton(h[1], scrollingFrame, function()
                    local ok, err = pcall(h[2])
                    if not ok then
                        createNotification("ОШИБКА", tostring(err):sub(1, 80), 5, 7733968497)
                    end
                end)
            end
        end
        applyAll()
    end

    -- ═══════════════════════════════
    --  HOME
    -- ═══════════════════════════════
    local function showHome()
        clearContent()
        createSectionHeader("Обзор", scrollingFrame)

        -- Карточка игрока
        local card = Instance.new("Frame")
        card.Size                   = UDim2.new(1, 0, 0, 96)
        card.BackgroundColor3       = T.BgPanel
        card.BackgroundTransparency = 0.18
        card.BorderSizePixel        = 0
        card.ZIndex                 = 4
        card.Parent                 = scrollingFrame
        mkCorner(card, 10)

        -- Блик стекла
        local sh = Instance.new("Frame")
        sh.BackgroundColor3 = Color3.new(1,1,1); sh.BackgroundTransparency = 0.93
        sh.BorderSizePixel = 0; sh.Size = UDim2.new(1,0,0.45,0); sh.ZIndex = 5; sh.Parent = card
        mkCorner(sh, 10)

        -- Акцент-полоска слева
        local accent = Instance.new("Frame")
        accent.BackgroundColor3 = T.Accent; accent.BorderSizePixel = 0
        accent.Size = UDim2.new(0,3,0.6,0); accent.Position = UDim2.new(0,0,0.2,0)
        accent.ZIndex = 5; accent.Parent = card
        mkCorner(accent, 2)

        local ok2, thumb = pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
        end)
        local ava = Instance.new("ImageLabel")
        ava.Size = UDim2.new(0,64,0,64); ava.Position = UDim2.new(0,14,0.5,-32)
        ava.BackgroundColor3 = T.BgSide; ava.Image = ok2 and thumb or ""
        ava.ZIndex = 5; ava.Parent = card
        mkCorner(ava, 32)
        local ring = Instance.new("UIStroke"); ring.Thickness=2; ring.Color=T.Accent; ring.Transparency=0.3; ring.Parent=ava

        local function infoLbl(txt, y, size, col)
            local l = Instance.new("TextLabel")
            l.BackgroundTransparency=1; l.Text=txt; l.Font=size and Enum.Font.GothamBold or Enum.Font.Gotham
            l.TextSize=size or 11; l.TextColor3=col or T.TextSub; l.TextXAlignment=Enum.TextXAlignment.Left
            l.Size=UDim2.new(1,-92,0,18); l.Position=UDim2.new(0,88,0,y); l.ZIndex=5; l.Parent=card
        end
        infoLbl(player.Name, 14, 15, T.TextMain)
        infoLbl("UserID: "..player.UserId, 34)
        infoLbl("Game: "..gui.gameName, 52)
        infoLbl("Platform: "..platformName.."  ·  PlaceId: "..game.PlaceId, 70)

        -- FPS
        local fpsCard = Instance.new("Frame")
        fpsCard.Size=UDim2.new(1,0,0,34); fpsCard.BackgroundColor3=T.BgPanel
        fpsCard.BackgroundTransparency=0.22; fpsCard.BorderSizePixel=0; fpsCard.ZIndex=4; fpsCard.Parent=scrollingFrame
        mkCorner(fpsCard,9)

        local fpsLbl = Instance.new("TextLabel")
        fpsLbl.BackgroundTransparency=1; fpsLbl.Text="FPS: —"
        fpsLbl.Font=Enum.Font.GothamBold; fpsLbl.TextSize=12; fpsLbl.TextColor3=T.TextMain
        fpsLbl.TextXAlignment=Enum.TextXAlignment.Left; fpsLbl.Size=UDim2.new(1,-16,1,0)
        fpsLbl.Position=UDim2.new(0,16,0,0); fpsLbl.ZIndex=5; fpsLbl.Parent=fpsCard
        fpsLbl:SetAttribute("TextRole","main")

        local fpsCount, fpsLast = 0, tick()
        local fpsCon = RunService.Heartbeat:Connect(function()
            fpsCount += 1
            local now = tick()
            if now - fpsLast >= 1 then
                if fpsLbl and fpsLbl.Parent then
                    fpsLbl.Text = "FPS: "..fpsCount.."  ·  Ping: "..math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()).." ms"
                end
                fpsCount = 0; fpsLast = now
            end
        end)
        fpsCard.Destroying:Connect(function() fpsCon:Disconnect() end)

        createSectionHeader("Ссылки", scrollingFrame)
        createLabel("YouTube  ·  youtube.com/@Vermax", scrollingFrame)
        createLabel("Telegram  ·  t.me/@vermax", scrollingFrame)
        createLabel("Discord  ·  discord.gg/vermax", scrollingFrame)

        applyAll()
    end

    -- ═══════════════════════════════
    --  ALL SCRIPTS / SEARCH
    -- ═══════════════════════════════
    local function showAllScripts()
        clearContent()
        createSectionHeader("Поиск скриптов", scrollingFrame)

        local searchBox = Instance.new("TextBox")
        searchBox.Size                   = UDim2.new(1, 0, 0, 34)
        searchBox.BackgroundColor3       = T.BgPanel
        searchBox.BackgroundTransparency = 0.18
        searchBox.TextColor3             = T.TextMain
        searchBox.PlaceholderText        = "Поиск..."
        searchBox.PlaceholderColor3      = T.TextMuted
        searchBox.TextSize               = 13
        searchBox.Text                   = ""
        searchBox.Font                   = Enum.Font.Gotham
        searchBox.ClearTextOnFocus       = false
        searchBox.ZIndex                 = 4
        searchBox.Parent                 = scrollingFrame
        searchBox:SetAttribute("TextRole","main")
        mkCorner(searchBox, 8)
        local sPad = Instance.new("UIPadding"); sPad.PaddingLeft=UDim.new(0,12); sPad.Parent=searchBox

        local statusLbl = createLabel("Введите минимум 3 символа...", scrollingFrame)
        statusLbl.TextColor3 = T.TextMuted

        local function runSearch(q)
            for _, ch in ipairs(scrollingFrame:GetChildren()) do
                if ch ~= searchBox and ch ~= statusLbl and not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then
                    ch:Destroy()
                end
            end
            if q == "" then statusLbl.Text = "Введите минимум 3 символа..."; return end
            statusLbl.Text = "Поиск..."
            local loc = searchLocal(q)
            local sb  = searchScriptblox(q)
            statusLbl.Text = "Найдено: "..(#loc+#sb).." результатов"
            for _, r in ipairs(loc) do
                createButton(r.name.."  ["..r.cat.."]", scrollingFrame, function()
                    local ok, e = pcall(r.fn)
                    if not ok then createNotification("ОШИБКА",tostring(e):sub(1,80),5,7733968497) end
                end)
            end
            for _, r in ipairs(sb) do
                createButton(r.name.."  [ScriptBlox]", scrollingFrame, function()
                    createNotification("ScriptBlox","ID: "..r.id,4)
                end)
            end
            applyAll()
        end

        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            if #searchBox.Text >= 3 then
                task.delay(0.4, function()
                    if #searchBox.Text >= 3 then runSearch(searchBox.Text) end
                end)
            else
                for _, ch in ipairs(scrollingFrame:GetChildren()) do
                    if ch ~= searchBox and ch ~= statusLbl and not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then ch:Destroy() end
                end
                statusLbl.Text = "Введите минимум 3 символа..."
            end
        end)
    end

    -- ═══════════════════════════════
    --  UTILITIES
    -- ═══════════════════════════════
    local function savePos()
        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then createNotification("ОШИБКА","Нет HumanoidRootPart",3,7733968497); return end
        local p = root.Position
        local txt = string.format("%.3f,%.3f,%.3f", p.X, p.Y, p.Z)
        pcall(function()
            if not isfolder("MegaHack") then makefolder("MegaHack") end
            writefile("MegaHack/pos.txt", txt)
        end)
        createNotification("СОХРАНЕНО", txt, 4)
    end

    local function loadPos()
        pcall(function()
            if not isfile("MegaHack/pos.txt") then createNotification("ОШИБКА","Нет сохранённых координат",3,7733968497); return end
            local t = readfile("MegaHack/pos.txt")
            local x,y,z = t:match("([^,]+),([^,]+),([^,]+)")
            local char = player.Character or player.CharacterAdded:Wait()
            local root = char:FindFirstChild("HumanoidRootPart")
            if root and x then
                root.CFrame = CFrame.new(tonumber(x),tonumber(y),tonumber(z))
                createNotification("ТЕЛЕПОРТ","Перемещён в "..t,3)
            end
        end)
    end

    local function antiBanKick()
        pcall(function()
            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local m = getnamecallmethod()
                if m == "Kick" or m == "kick" or m == "Ban" or m == "ban" then
                    createNotification("ЗАЩИТА","Попытка кика/бана заблокирована",3); return nil
                end
                return old(self, ...)
            end)
            setreadonly(mt, true)
        end)
        createNotification("ЗАЩИТА","Anti-Kick / Anti-Ban активен",3)
    end

    local function checkFuncs()
        local list = {"getrawmetatable","makefolder","setthreadidentity","readfile","writefile",
            "loadstring","hookfunction","newcclosure","getgenv","getrenv","gethui","getsenv",
            "getconnections","getinstances","getnilinstances","getloadedmodules","cloneref",
            "request","WebSocket.connect","Drawing.new","isfolder","isfile","setclipboard",
            "identifyexecutor","setreadonly","isreadonly","compareinstances"}
        local ok_, bad = {}, {}
        for _, f in ipairs(list) do
            local s = pcall(function()
                if f:find("%.") then
                    local t = f:split("%."); local o = _G
                    for _, p in ipairs(t) do o = o[p]; if not o then error() end end
                else
                    if not _G[f] then error() end
                end
            end)
            if s then table.insert(ok_,f) else table.insert(bad,f) end
        end
        createNotification("ФУНКЦИИ","Доступно: "..#ok_.."   Нет: "..#bad,5)
        print("=== ЕСТЬ ==="); for _,f in ipairs(ok_)  do print("✓ "..f) end
        print("=== НЕТ ===");  for _,f in ipairs(bad)  do print("✗ "..f) end
    end

    -- ═══════════════════════════════
    --  SETTINGS
    -- ═══════════════════════════════
    local function showSettings()
        clearContent()

        local function redraw() showSettings() end

        createSectionHeader("Цвет интерфейса", scrollingFrame)
        theme.createColorPicker(scrollingFrame, settings, function()
            applyAll()
            theme.saveColors(settings)
            createNotification("ЦВЕТ","Применено и сохранено!",2)
        end)

        createSectionHeader("Прозрачность", scrollingFrame)
        for _, t2 in ipairs({{"Нет", 0.06},{"10%",0.1},{"25%",0.25},{"50%",0.5},{"75%",0.75}}) do
            createButton(t2[1], scrollingFrame, function()
                settings.transparency = t2[2]; applyAll()
                createNotification("ПРОЗРАЧНОСТЬ",t2[1],2)
            end)
        end

        createSectionHeader("RGB текст", scrollingFrame)
        createButton("RGB текст: "..(settings.rgbText and "ВКЛ" or "ВЫКЛ"), scrollingFrame, function()
            settings.rgbText = not settings.rgbText
            theme.saveColors(settings); applyAll(); redraw()
        end)

        createSectionHeader("Сервер", scrollingFrame)
        createButton("Реджоин", scrollingFrame, function()
            pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
        end)
        createButton("Хоп на другой сервер", scrollingFrame, function()
            pcall(function()
                local servers = HttpService:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
                if servers.data and #servers.data > 0 then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, servers.data[math.random(1,#servers.data)].id, player)
                else createNotification("ОШИБКА","Серверов нет",3,7733968497) end
            end)
        end)
        createButton("Копировать Job ID", scrollingFrame, function()
            pcall(function() setclipboard(game.JobId); createNotification("СКОПИРОВАНО",game.JobId:sub(1,20).."…",3) end)
        end)

        createSectionHeader("Координаты", scrollingFrame)
        createButton("Сохранить позицию",    scrollingFrame, savePos)
        createButton("Телепорт на позицию",  scrollingFrame, loadPos)

        createSectionHeader("Безопасность", scrollingFrame)
        createButton("Anti-Kick / Anti-Ban", scrollingFrame, antiBanKick)
        createButton("Проверить функции",    scrollingFrame, checkFuncs)

        createSectionHeader("GUI", scrollingFrame)
        createButton((settings.locked and "Разблокировать" or "Заблокировать").." перетаскивание", scrollingFrame, function()
            settings.locked = not settings.locked; redraw()
        end)
        createButton("Закрыть GUI", scrollingFrame, function()
            gui.screenGui:Destroy()
        end)

        applyAll()
    end

    -- ═══════════════════════════════
    --  DRAGGING
    -- ═══════════════════════════════
    local function makeDraggable(frame, handle)
        handle = handle or frame
        local drag, inp, mPos, fPos = false, nil, nil, nil
        handle.InputBegan:Connect(function(i)
            if settings.locked then return end
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = true; mPos = i.Position; fPos = frame.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then drag = false end
                end)
            end
        end)
        handle.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then inp = i end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if i == inp and drag and mPos then
                local d = i.Position - mPos
                frame.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset+d.X, fPos.Y.Scale, fPos.Y.Offset+d.Y)
            end
        end)
    end

    -- ═══════════════════════════════
    --  INIT
    -- ═══════════════════════════════
    return {
        init = function()
            -- Загружаем сохранённые цвета
            theme.loadColors(settings)
            applyAll()

            -- Sidebar: основные вкладки
            local tabs = {
                {"🏠  Home",        function() showHome() end},
                {"🔍  Поиск",       function() showAllScripts() end},
                {"⚙  Настройки",   function() showSettings() end},
            }
            for _, tab in ipairs(tabs) do
                createButton(tab[1], catScroll, tab[2], true)
            end

            -- Sidebar: категории из base.lua
            local catNames = {}
            for name in pairs(categoryMap) do table.insert(catNames, name) end
            table.sort(catNames)
            for _, name in ipairs(catNames) do
                createButton(name, catScroll, function()
                    loadCategory(name)
                end, true)
            end

            -- Drag
            makeDraggable(mainFrame, headerFrame)
            makeDraggable(reopenButton, reopenButton)

            -- Close / Reopen
            closeBtn.MouseButton1Click:Connect(function()
                TweenService:Create(mainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quint), {
                    Size = UDim2.new(0, 600, 0, 0), BackgroundTransparency = 1
                }):Play()
                task.delay(0.28, function()
                    mainFrame.Visible = false
                    mainFrame.Size    = UDim2.new(0, 600, 0, 390)
                    mainFrame.BackgroundTransparency = settings.transparency
                    reopenButton.Visible = true
                end)
            end)

            reopenButton.MouseButton1Click:Connect(function()
                mainFrame.Visible = true
                mainFrame.Size    = UDim2.new(0, 600, 0, 0)
                mainFrame.BackgroundTransparency = 1
                reopenButton.Visible = false
                TweenService:Create(mainFrame, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 600, 0, 390), BackgroundTransparency = settings.transparency
                }):Play()
            end)

            -- Открытие
            mainFrame.Size                   = UDim2.new(0, 600, 0, 0)
            mainFrame.BackgroundTransparency = 1
            TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 600, 0, 390), BackgroundTransparency = settings.transparency
            }):Play()

            -- Дефолтная вкладка
            showHome()

            -- Подсветить первую кнопку
            task.delay(0.05, function()
                local first = catScroll:FindFirstChildWhichIsA("TextButton")
                if first then
                    first:SetAttribute("Active", true)
                    TweenService:Create(first, TweenInfo.new(0.15), {
                        BackgroundColor3=T.Accent, BackgroundTransparency=0.68, TextColor3=T.TextMain
                    }):Play()
                    local s = first:FindFirstChildWhichIsA("Frame")
                    if s and s.Name ~= "_Sheen" then
                        TweenService:Create(s, TweenInfo.new(0.15), {BackgroundTransparency=0}):Play()
                    end
                end
            end)

            createNotification("MEGAHACK v2.0","Загружен  ·  "..platformName,3,74283928898866)
        end
    }
end
