-- russianempire.ru — Central Orchestrator & Brain
-- Path: shaypishgithub/infinity/evoruss/evodetail/russianempire.ru

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local BASE_ROOT = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/evoruss/evodetail"

-- ==================== SAFE LOADER ====================
local function safeLoad(url)
    local fullUrl = url .. "?t=" .. math.floor(tick())
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(fullUrl, true))()
    end)
    if ok and res then return res end
    warn("[RussianEmpire] Failed to load: " .. tostring(url) .. " | " .. tostring(res))
    return nil
end

-- ==================== 1. LOAD DATABASE ====================
local baseConfig = safeLoad(BASE_ROOT .. "/base.lua")
if not baseConfig or not baseConfig.categories then
    warn("[RussianEmpire] Critical Error: base.lua failed to load!")
    return
end

local categoryMap = baseConfig.categories
local gameIcons = baseConfig.gameIcons
local baseUrl = baseConfig.baseUrl

-- Сортируем категории по алфавиту для красивого сайдбара
local sortedCats = {}
for k in pairs(categoryMap) do table.insert(sortedCats, k) end
table.sort(sortedCats)

-- ==================== 2. CREATE DEPS TABLE ====================
-- Это "кровеносная система" хаба. Все модули берут данные отсюда.
local deps = {
    TweenService = TweenService,
    UserInputService = UserInputService,
    Players = Players,
    CoreGui = CoreGui,
    RunService = RunService,
    HttpService = HttpService,
    player = player,
    categoryMap = sortedCats,
    gameIcons = gameIcons,
    HubData = {},
}

-- ==================== 3. INIT MODULES ====================
-- Theme (Создает цвета и функции CreateNeonStroke, CreateGlass, Create3DShadow)
local themeModule = safeLoad(BASE_ROOT .. "/theme.lua")
if themeModule then
    local theme = themeModule(deps)
    deps.T = theme.T
else
    warn("[RussianEmpire] Theme failed!")
    return
end

-- GUI (Создает окна и возвращает ссылки на них)
local guiModule = safeLoad(BASE_ROOT .. "/gui.lua")
if guiModule then
    local gui = guiModule(deps)
    deps.gui = gui
else
    warn("[RussianEmpire] GUI failed!")
    return
end

-- Статистика
local statsModule = safeLoad(BASE_ROOT .. "/stats.lua")
if statsModule then
    local stats = statsModule(deps)
    stats.init()
end

-- Вкладки
local homeModule = safeLoad(BASE_ROOT .. "/home.lua")
local home = homeModule and homeModule(deps) or { showHome = function() end }

local gamesModule = safeLoad(BASE_ROOT .. "/games.lua")
local games = gamesModule and gamesModule(deps) or { showGames = function() end }

local colorPickerModule = safeLoad(BASE_ROOT .. "/colorpicker.lua")
local colorPicker = colorPickerModule and colorPickerModule(deps) or { show = function() end }

-- ==================== 4. UI LOGIC (TAB SWITCHING) ====================
local gui = deps.gui
local currentTab = "Home"
local tabButtons = {}

local function clearContent()
    for _, c in ipairs(gui.scrollingFrame:GetChildren()) do 
        if c:IsA("Frame") and c.Name ~= "3DShadow" then c:Destroy() end 
    end
end

local function highlightActiveTab(tabName)
    for name, btn in pairs(tabButtons) do
        if name == tabName then
            -- Активная вкладка (Неоновый акцент)
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2, TextColor3 = deps.T.TextMain}):Play()
            pcall(function()
                for _,s in ipairs(btn:GetChildren()) do if s:IsA("UIStroke") then s:Destroy() end end
                deps.CreateNeonStroke(btn, deps.T.Accent, 1)
            end)
        else
            -- Неактивная вкладка
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5, TextColor3 = deps.T.TextSub}):Play()
            pcall(function()
                for _,s in ipairs(btn:GetChildren()) do if s:IsA("UIStroke") then s:Destroy() end end
            end)
        end
    end
end

local function switchTab(tabName)
    if tabName == currentTab then return end
    currentTab = tabName
    clearContent()
    
    gui.gamesPanel.Visible = false
    gui.scrollingFrame.Visible = true
    
    highlightActiveTab(tabName)

    if tabName == "Home" then
        home.showHome(gui.scrollingFrame)
    elseif tabName == "Games" then
        games.showGames({ 
            onCategoryClick = function(catName)
                -- Если кликнули на игру внутри вкладки Games, выполняем её скрипт
                local fileName = categoryMap[catName] or "universal.lua"
                pcall(function()
                    loadstring(game:HttpGet(baseUrl .. "/" .. fileName, true))()
                end)
            end
        })
    elseif tabName == "Settings" then
        colorPicker.show(gui.scrollingFrame, function(newColor)
            -- Callback при смене цвета в ColorPicker
            deps.T.Accent = newColor
            highlightActiveTab(currentTab)
        end)
    else
        -- Выполнение скрипта для конкретной игры
        local fileName = categoryMap[tabName] or "universal.lua"
        pcall(function()
            loadstring(game:HttpGet(baseUrl .. "/" .. fileName, true))()
        end)
    end
end

-- ==================== 5. BUILD SIDEBAR ====================
local function createTabButton(name, icon, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = deps.T.BgDeep
    btn.BackgroundTransparency = 0.5
    btn.BorderSizePixel = 0
    btn.Text = " " .. icon .. "  " .. name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = deps.T.TextSub
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order
    btn.Parent = gui.sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    tabButtons[name] = btn
    
    btn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
    
    -- Hover эффект
    btn.MouseEnter:Connect(function()
        if currentTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.3, TextColor3 = Color3.fromRGB(200, 200, 210)}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.5, TextColor3 = deps.T.TextSub}):Play()
        end
    end)
end

-- Создаем главные кнопки
createTabButton("Home", "🏠", 1)
createTabButton("Games", "🎮", 2)

-- Разделитель (Линия)
local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -20, 0, 1)
sep.BackgroundColor3 = deps.T.Accent
sep.BackgroundTransparency = 0.7
sep.BorderSizePixel = 0
sep.LayoutOrder = 3
sep.Parent = gui.sidebar

-- Создаем кнопки игр из base.lua
for i, catName in ipairs(sortedCats) do
    createTabButton(catName, "📁", i + 3)
end

-- Кнопка настроек в самом низу
createTabButton("Settings", "⚙️", 999)

-- ==================== 6. CLOSE & OPEN LOGIC ====================
gui.closeBtn.MouseButton1Click:Connect(function()
    -- 3D Анимация закрытия (сжатие)
    TweenService:Create(gui.mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    task.delay(0.4, function() gui.screenGui.Enabled = false end)
end)

-- Кнопка открывания по Right Shift
UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        if gui.screenGui.Enabled then
            gui.closeBtn.MouseButton1Click:Fire()
        else
            gui.screenGui.Enabled = true
            gui.mainFrame.Size = UDim2.new(0, 0, 0, 0)
            gui.mainFrame.BackgroundTransparency = 1
            -- 3D Анимация открытия (расширение)
            TweenService:Create(gui.mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 650, 0, 450),
                BackgroundTransparency = 0.15
            }):Play()
        end
    end
end)

-- ==================== 7. STARTUP ====================
-- Показываем Home по умолчанию
highlightActiveTab("Home")
home.showHome(gui.scrollingFrame)

-- Обновляем CanvasSize для скролла
local function updateCanvas()
    local y = gui.scrollLayout.AbsoluteContentSize.Y
    gui.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, y + 20)
end
gui.scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
updateCanvas()

-- ==================== 8. BACKGROUND SCRIPT PREFETCH ====================
-- Подгружаем скрипты игр в фоне, чтобы не было задержек при клике
task.spawn(function()
    for categoryName, fileName in pairs(categoryMap) do
        task.spawn(function()
            local data = safeLoad(baseUrl .. "/" .. fileName)
            if type(data) == "table" then
                deps.HubData[categoryName] = data
            end
        end)
        task.wait(0.05) -- Защита от Rate Limit
    end
end)
