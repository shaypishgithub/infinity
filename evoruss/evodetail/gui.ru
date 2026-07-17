-- gui.ru (UI Layout & Logic)
-- Принимает: Env (функции), MainFrame (окно), ScreenGui (экран)
return function(Env, MainFrame, ScreenGui)
    local TS = Env.Services.TweenService
    local UIS = Env.Services.UserInputService
    local RS = Env.Services.RunService
    local T = Env.Theme
    
    -- Применяем 3D эффекты к главному окну
    Env.MakeNeon(MainFrame, T.Accent)
    Env.MakeShadow(MainFrame, 14)
    Env.MakeGlass(MainFrame)

    -- Переменные состояния
    local currentTab = "Home"
    local tabButtons = {}

    -- ================= ХЕДЕР =================
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundTransparency = 1
    header.ZIndex = 5
    header.Parent = MainFrame

    local title = Instance.new("TextLabel")
    title.Text = "EVORUSS // 2026"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = T.TextMain
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 6
    title.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.TextColor3 = T.TextMain
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 7)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.ZIndex = 10
    closeBtn.Parent = header
    Env.MakeRound(closeBtn, 8)
    Env.MakeNeon(closeBtn, Color3.fromRGB(255, 50, 50), 1)

    -- ================= САЙДБАР =================
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 155, 1, -50)
    sidebar.Position = UDim2.new(0, 0, 0, 50)
    sidebar.BackgroundTransparency = 0.9
    sidebar.BackgroundColor3 = T.BgDeep
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 3
    sidebar.Parent = MainFrame
    
    local sStroke = Instance.new("UIStroke")
    sStroke.Thickness = 1
    sStroke.Color = T.Accent
    sStroke.Transparency = 0.6
    sStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    sStroke.Parent = sidebar

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Padding = UDim.new(0, 4)
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Parent = sidebar
    Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0, 10)

    -- ================= КОНТЕНТ =================
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -165, 1, -60)
    contentFrame.Position = UDim2.new(0, 160, 0, 55)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ZIndex = 3
    contentFrame.Parent = MainFrame

    local contentScroll = Instance.new("ScrollingFrame")
    contentScroll.Size = UDim2.new(1, 0, 1, 0)
    contentScroll.BackgroundTransparency = 1
    contentScroll.ScrollBarThickness = 0
    contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentScroll.ZIndex = 4
    contentScroll.Parent = contentFrame
    Instance.new("UIPadding", contentScroll).PaddingTop = UDim.new(0, 10)
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentScroll
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentScroll.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)

    -- ================= ЛОГИКА ВКЛАДОК =================
    local function clearContent()
        for _, c in ipairs(contentScroll:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
    end

    local function highlightTab(tabName)
        for name, btn in pairs(tabButtons) do
            if name == tabName then
                TS:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2, TextColor3 = T.TextMain}):Play()
                Env.MakeNeon(btn, T.Accent, 1)
            else
                TS:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5, TextColor3 = T.TextSub}):Play()
                pcall(function() for _,s in ipairs(btn:GetChildren()) do if s:IsA("UIStroke") then s:Destroy() end end end)
            end
        end
    end

    local function switchTab(name)
        if name == currentTab then return end
        currentTab = name
        clearContent()
        highlightTab(name)

        if name == "Home" then
            -- Карточка FPS
            local fpsCard = Instance.new("Frame")
            fpsCard.Size = UDim2.new(1, 0, 0, 60)
            fpsCard.BackgroundColor3 = T.BgPanel
            fpsCard.BackgroundTransparency = 0.2
            fpsCard.BorderSizePixel = 0
            fpsCard.Parent = contentScroll
            Env.MakeRound(fpsCard, 12)
            Env.MakeNeon(fpsCard, T.Accent, 1)
            Env.MakeShadow(fpsCard, 6)
            
            local fpsLbl = Instance.new("TextLabel")
            fpsLbl.Text = "⚡ FPS: --"
            fpsLbl.Font = Enum.Font.GothamBold
            fpsLbl.TextSize = 16
            fpsLbl.TextColor3 = T.TextMain
            fpsLbl.BackgroundTransparency = 1
            fpsLbl.Size = UDim2.new(1, -20, 1, 0)
            fpsLbl.Position = UDim2.new(0, 15, 0, 0)
            fpsLbl.TextXAlignment = Enum.TextXAlignment.Left
            fpsLbl.ZIndex = 5
            fpsLbl.Parent = fpsCard

            local lt, fc = tick(), 0
            local conn; conn = RS.Heartbeat:Connect(function()
                fc = fc + 1
                if tick() - lt >= 1 then
                    fpsLbl.Text = "⚡ FPS: " .. fc
                    fc, lt = 0, tick()
                end
                if not fpsCard.Parent then conn:Disconnect() end
            end)

        else
            -- Заглушка для остальных вкладок
            local placeholder = Instance.new("TextLabel")
            placeholder.Text = "Executing " .. name .. "..."
            placeholder.Font = Enum.Font.GothamBold
            placeholder.TextSize = 16
            placeholder.TextColor3 = T.Accent
            placeholder.BackgroundTransparency = 1
            placeholder.Size = UDim2.new(1, 0, 0, 50)
            placeholder.Parent = contentScroll
            
            -- Попытка выполнить скрипт по названию вкладки
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/evoruss/evodetail/"..string.lower(string.gsub(name, " ", ""))..".lua", true))()
            end)
        end
    end

    -- ================= СОЗДАНИЕ КНОПОК =================
    local function createTab(name, icon, order)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 32)
        btn.BackgroundColor3 = T.BgDeep
        btn.BackgroundTransparency = 0.5
        btn.BorderSizePixel = 0
        btn.Text = "  " .. icon .. "  " .. name
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.TextColor3 = T.TextSub
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.LayoutOrder = order
        btn.Parent = sidebar
        Env.MakeRound(btn, 8)
        
        tabButtons[name] = btn

        btn.MouseButton1Click:Connect(function()
            switchTab(name)
        end)

        btn.MouseEnter:Connect(function()
            if currentTab ~= name then
                TS:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2, TextColor3 = T.TextMain}):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if currentTab ~= name then
                TS:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.5, TextColor3 = T.TextSub}):Play()
            end
        end)
    end

    -- Генерация кнопок
    createTab("Home", "🏠", 1)
    
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -20, 0, 1)
    sep.BackgroundColor3 = T.Accent
    sep.BackgroundTransparency = 0.7
    sep.BorderSizePixel = 0
    sep.LayoutOrder = 2
    sep.Parent = sidebar

    createTab("Universal", "📜", 3)
    createTab("Blox Fruits", "🍕", 4)
    createTab("Brookhaven", "🏡", 5)
    createTab("Arsenal", "🔫", 6)

    -- ================= УПРАВЛЕНИЕ ОКНОМ =================
    local function toggleGui()
        ScreenGui.Enabled = not ScreenGui.Enabled
        if ScreenGui.Enabled then
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            MainFrame.BackgroundTransparency = 1
            TS:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 650, 0, 450),
                BackgroundTransparency = 0.12
            }):Play()
        end
    end

    closeBtn.MouseButton1Click:Connect(toggleGui)
    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.RightShift then toggleGui() end
    end)

    -- Старт
    highlightTab("Home")
    switchTab("Home")
    toggleGui() -- Автоматически открываем при запуске
    
    print("[EVORUSS] GUI Loaded Successfully!")
end
