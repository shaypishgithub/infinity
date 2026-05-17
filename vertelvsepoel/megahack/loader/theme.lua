-- theme.lua  ·  Glass Minimalism — Total Sync Edition
-- Исправлено: Применение ко всем кнопкам (Open Button, Sidebar, Tabs)
return function(deps)
    local TweenService      = deps.TweenService
    local RunService        = deps.RunService
    local HttpService       = deps.HttpService
    local playerGui         = deps.playerGui
    local mainFrame         = deps.mainFrame
    local accentRegistry    = deps.accentRegistry
    local createNotification = deps.createNotification
    local UserInputService   = game:GetService("UserInputService")

    -- ═══════════ ЦВЕТОВАЯ ТЕМА ═══════════
    local T = {
        BgBase    = Color3.fromRGB(11, 11, 15),
        BgSide    = Color3.fromRGB(16, 16, 22),
        BgPanel   = Color3.fromRGB(22, 22, 30),
        BgBtn     = Color3.fromRGB(28, 28, 38),
        BgBtnHov  = Color3.fromRGB(36, 36, 50),
        Accent    = Color3.fromRGB(150, 25, 25),
        AccentHov = Color3.fromRGB(185, 40, 40),
        TextMain  = Color3.fromRGB(230, 230, 238),
        TextSub   = Color3.fromRGB(145, 145, 158),
        Stroke    = Color3.fromRGB(40, 40, 54),
    }

    local rgbConnections = {}

    local function regA(obj, prop)
        table.insert(accentRegistry, { obj = obj, prop = prop or "BackgroundColor3" })
    end

    local function clearRgbConnections()
        for _, c in pairs(rgbConnections) do
            pcall(function() c:Disconnect() end)
        end
        rgbConnections = {}
    end

    -- ═══════════ ОБНОВЛЕНИЕ ЦВЕТОВ ═══════════
    local function updateGuiColors(settings)
        clearRgbConnections()
        local acc = settings.colors.accentColor
        local bg  = settings.colors.bgColor
        local tx  = settings.colors.textColor

        -- Расчет вспомогательных оттенков
        T.Accent = acc
        T.BgBase = bg
        T.BgSide = Color3.new(math.min(bg.R+0.02,1), math.min(bg.G+0.02,1), math.min(bg.B+0.03,1))
        T.BgPanel = Color3.new(math.min(bg.R+0.05,1), math.min(bg.G+0.05,1), math.min(bg.B+0.07,1))
        T.TextMain = tx

        -- 1. Обновляем все зарегистрированные акценты (включая Open Button)
        for _, entry in ipairs(accentRegistry) do
            pcall(function()
                if entry.obj and entry.obj:IsA("GuiObject") then
                    entry.obj[entry.prop] = acc
                end
            end)
        end

        -- 2. Функция для рекурсивной покраски
        local function applyToHierarchy(root)
            for _, obj in pairs(root:GetDescendants()) do
                -- Пропускаем кнопку закрытия
                if obj.Name == "CloseButton" then continue end

                -- Обводки (UIStroke)
                if obj:IsA("UIStroke") then
                    if settings.rgbStroke then
                        local c = RunService.Heartbeat:Connect(function()
                            obj.Color = Color3.fromHSV((tick() % 5) / 5, 0.8, 1)
                        end)
                        table.insert(rgbConnections, c)
                    else
                        -- Если обводка была акцентной — меняем на новый акцент
                        if obj:GetAttribute("IsAccent") or obj.Color == Color3.fromRGB(150, 25, 25) then
                            obj.Color = acc
                        else
                            obj.Color = Color3.new(math.min(bg.R+0.2, 1), math.min(bg.G+0.2, 1), math.min(bg.B+0.2, 1))
                        end
                    end

                -- Текст
                elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    if settings.rgbAccent and (obj:GetAttribute("TextRole") == "main" or obj.TextColor3 == Color3.fromRGB(150, 25, 25)) then
                        local c = RunService.Heartbeat:Connect(function()
                            obj.TextColor3 = Color3.fromHSV((tick() % 5) / 5, 0.8, 1)
                        end)
                        table.insert(rgbConnections, c)
                    else
                        -- Логика смены цвета текста
                        if obj.Name == "SectionHeader" or obj:GetAttribute("IsAccent") or obj.TextColor3 == Color3.fromRGB(150, 25, 25) then
                            obj.TextColor3 = acc
                        elseif obj:IsA("TextButton") and obj:GetAttribute("Active") then
                            obj.TextColor3 = acc
                        else
                            obj.TextColor3 = tx
                        end
                    end

                -- Фоны панелей и кнопок
                elseif obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
                    if obj.Name == "SidebarFrame" then
                        obj.BackgroundColor3 = T.BgSide
                    elseif obj:GetAttribute("IsPanel") or obj.BackgroundColor3 == Color3.fromRGB(22, 22, 30) then
                        obj.BackgroundColor3 = T.BgPanel
                    elseif obj.Name == "AccentLine" then
                        obj.BackgroundColor3 = acc
                    end
                end
            end
        end

        -- Применяем ко всему GUI (чтобы найти Open Button и прочее вне MainFrame)
        applyToHierarchy(mainFrame)
        if mainFrame.Parent:FindFirstChild("OpenButton") then
            applyToHierarchy(mainFrame.Parent.OpenButton)
        end
        
        -- Обновляем сам MainFrame
        mainFrame.BackgroundColor3 = bg
        mainFrame.BackgroundTransparency = settings.transparency
    end

    -- ═══════════ СОХРАНЕНИЕ / ЗАГРУЗКА ═══════════
    local function saveColorSettings(settings)
        pcall(function()
            if not isfolder("MegaHack") then makefolder("MegaHack") end
            local col = settings.colors
            local data = {
                bgColor      = { col.bgColor.R,     col.bgColor.G,     col.bgColor.B     },
                textColor    = { col.textColor.R,   col.textColor.G,   col.textColor.B   },
                accentColor  = { col.accentColor.R, col.accentColor.G, col.accentColor.B },
                transparency = settings.transparency,
                rgbAccent    = settings.rgbAccent,
                rgbStroke    = settings.rgbStroke,
            }
            writefile("MegaHack/colorSettings.json", HttpService:JSONEncode(data))
        end)
    end

    local function loadColorSettings(settings)
        pcall(function()
            if isfile("MegaHack/colorSettings.json") then
                local data = HttpService:JSONDecode(readfile("MegaHack/colorSettings.json"))
                settings.colors.bgColor     = Color3.new(table.unpack(data.bgColor))
                settings.colors.textColor   = Color3.new(table.unpack(data.textColor))
                settings.colors.accentColor = Color3.new(table.unpack(data.accentColor))
                settings.transparency       = data.transparency or 0.1
                settings.rgbAccent          = data.rgbAccent or false
                settings.rgbStroke          = data.rgbStroke or false
            end
        end)
    end

    -- ═══════════ COLOR PICKER (UI Logic) ═══════════
    local function createColorPicker(parent, settings)
        local selType = "bgColor"
        local curH, curS, curV = Color3.toHSV(settings.colors.bgColor)
        local updatePickerUI 

        local container = Instance.new("Frame")
        container.BackgroundTransparency = 1
        container.Size = UDim2.new(1, 0, 0, 350)
        container.Parent = parent

        local layout = Instance.new("UIListLayout", container)
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        -- [ Кнопки выбора типа ]
        local typeRow = Instance.new("Frame", container)
        typeRow.Size = UDim2.new(1, 0, 0, 30)
        typeRow.BackgroundTransparency = 1
        
        local trl = Instance.new("UIListLayout", typeRow)
        trl.FillDirection = Enum.FillDirection.Horizontal
        trl.Padding = UDim.new(0, 5)

        local btns = {}
        for i, info in ipairs({{"bgColor", "BG"}, {"textColor", "TEXT"}, {"accentColor", "ACCENT"}}) do
            local b = Instance.new("TextButton", typeRow)
            b.Size = UDim2.new(0, 65, 1, 0)
            b.Text = info[2]
            b.Font = Enum.Font.GothamBold
            b.TextSize = 10
            b.BackgroundColor3 = (info[1] == selType) and acc or T.BgBtn
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            
            b.MouseButton1Click:Connect(function()
                selType = info[1]
                curH, curS, curV = Color3.toHSV(settings.colors[selType])
                updatePickerUI()
            end)
        end

        -- [ SV Pad ]
        local svBase = Instance.new("Frame", container)
        svBase.Size = UDim2.new(1, 0, 0, 120)
        Instance.new("UICorner", svBase)
        
        local svCursor = Instance.new("Frame", svBase)
        svCursor.Size = UDim2.new(0, 8, 0, 8)
        svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
        svCursor.BackgroundColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", svCursor).CornerRadius = UDim.new(1, 0)

        -- [ Hue Slider ]
        local hueTrack = Instance.new("Frame", container)
        hueTrack.Size = UDim2.new(1, 0, 0, 15)
        local hg = Instance.new("UIGradient", hueTrack)
        hg.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0,1,1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5,1,1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(1,1,1))
        })
        Instance.new("UICorner", hueTrack)

        -- [ Apply Button ]
        local apply = Instance.new("TextButton", container)
        apply.Size = UDim2.new(1, 0, 0, 35)
        apply.Text = "APPLY CHANGES"
        apply.Font = Enum.Font.GothamBold
        apply.BackgroundColor3 = T.Accent
        apply.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", apply)

        updatePickerUI = function()
            svBase.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
            svCursor.Position = UDim2.new(curS, 0, 1-curV, 0)
            apply.BackgroundColor3 = Color3.fromHSV(curH, curS, curV)
        end

        -- Драг логика (упрощенная)
        local isDragging = false
        svBase.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end end)
        
        RunService.RenderStepped:Connect(function()
            if isDragging then
                local pos = UserInputService:GetMouseLocation() - svBase.AbsolutePosition - Vector2.new(0, 36)
                curS = math.clamp(pos.X / svBase.AbsoluteSize.X, 0, 1)
                curV = 1 - math.clamp(pos.Y / svBase.AbsoluteSize.Y, 0, 1)
                updatePickerUI()
            end
        end)

        apply.MouseButton1Click:Connect(function()
            settings.colors[selType] = Color3.fromHSV(curH, curS, curV)
            updateGuiColors(settings)
            saveColorSettings(settings)
            createNotification("THEME", "Settings synchronized!", 2)
        end)

        return container
    end

    return {
        T = T,
        regA = regA,
        updateGuiColors = updateGuiColors,
        createColorPicker = createColorPicker,
        saveColorSettings = saveColorSettings,
        loadColorSettings = loadColorSettings,
        clearRgbConnections = clearRgbConnections,
    }
end

