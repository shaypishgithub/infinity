local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local Players         = game:GetService("Players")
local CoreGui         = game:GetService("CoreGui")
local RunService      = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local HttpService     = game:GetService("HttpService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 5)
if not playerGui then warn("[MH] PlayerGui not found!") return end

local isMobile    = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local platformName= isMobile and "Mobile" or "PC"

-- ══════════════════════════════════════
--  SAFE LOAD
-- ══════════════════════════════════════
local function safeLoad(url)
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)
    if ok and res then return res end
    warn("[MH] failed to load: " .. tostring(url))
    return nil
end

-- ══════════════════════════════════════
--  BASE CONFIG
-- ══════════════════════════════════════
local BASE_ROOT = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack"

local baseConfig  = safeLoad(BASE_ROOT .. "/loader/base.lua") or {}
local baseUrl     = baseConfig.baseUrl or (BASE_ROOT .. "/base")
local categoryMap = baseConfig.categories or {}

-- ══════════════════════════════════════
--  SCRIPT CACHE  (предзагрузка для счётчика)
-- ══════════════════════════════════════
local HubData = {}
for categoryName, fileName in pairs(categoryMap) do
    local data = safeLoad(baseUrl .. "/" .. fileName)
    if type(data) == "table" and #data > 0 then
        HubData[categoryName] = data
    end
end

-- ══════════════════════════════════════
--  ACCENT REGISTRY  (shared между gui и logic)
-- ══════════════════════════════════════
local accentRegistry = {}
local function regA(obj, prop)
    table.insert(accentRegistry, { obj = obj, prop = prop or "BackgroundColor3" })
end

-- ══════════════════════════════════════
--  THEME
-- ══════════════════════════════════════
local themeFactory = safeLoad(BASE_ROOT .. "/loader/theme.lua")
if type(themeFactory) ~= "function" then
    warn("[MH] theme.lua failed or wrong format")
    return
end

local createNotification  -- forward-declared, нужна теме

local theme = themeFactory({
    TweenService       = TweenService,
    RunService         = RunService,
    HttpService        = HttpService,
    playerGui          = playerGui,
    accentRegistry     = accentRegistry,
    createNotification = function(...) return createNotification(...) end,
})

local T = theme.T

-- ══════════════════════════════════════
--  GUI  (визуал — меняй только этот файл для нового стиля)
-- ══════════════════════════════════════
local guiFactory = safeLoad(BASE_ROOT .. "/loader/gui.lua")
if type(guiFactory) ~= "function" then
    warn("[MH] gui.lua failed or wrong format")
    return
end

local gui = guiFactory({
    TweenService       = TweenService,
    UserInputService   = UserInputService,
    Players            = Players,
    CoreGui            = CoreGui,
    RunService         = RunService,
    MarketplaceService = MarketplaceService,
    HttpService        = HttpService,
    playerGui          = playerGui,
    platformName       = platformName,
    T                  = T,
    regA               = regA,
    accentRegistry     = accentRegistry,
    HubData            = HubData,
    createNotification = function(...) return createNotification(...) end,
})

-- ══════════════════════════════════════
--  NOTIFICATION  (определяем после gui, чтобы использовать T)
-- ══════════════════════════════════════
createNotification = function(title, subtitle, duration, iconId)
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "MH_Notification"
    notificationGui.Parent = playerGui
    notificationGui.ResetOnSpawn = false

    local notifW = 240
    local mainF = Instance.new("Frame")
    mainF.Size = UDim2.new(0, notifW, 0, 64)
    mainF.Position = UDim2.new(1, -(notifW + 16), 0, 24)
    mainF.BackgroundTransparency = 1
    mainF.Parent = notificationGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = T.BgSide
    bg.BackgroundTransparency = 1
    bg.Parent = mainF
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1; stroke.Color = T.Stroke; stroke.Transparency = 1
    stroke.Parent = bg

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, -16)
    bar.Position = UDim2.new(0, 0, 0, 8)
    bar.BackgroundColor3 = T.AccentGlow
    bar.BackgroundTransparency = 1
    bar.BorderSizePixel = 0
    bar.Parent = bg
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 28, 0, 28)
    icon.Position = UDim2.new(0, 12, 0.5, -14)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://" .. tostring(iconId or 74283928898866)
    icon.ImageTransparency = 1
    icon.Parent = bg

    local mainText = Instance.new("TextLabel")
    mainText.Text = title
    mainText.Font = Enum.Font.GothamBold
    mainText.TextColor3 = T.TextMain
    mainText.TextSize = 13
    mainText.TextXAlignment = Enum.TextXAlignment.Left
    mainText.Size = UDim2.new(1, -56, 0, 18)
    mainText.Position = UDim2.new(0, 50, 0, 12)
    mainText.BackgroundTransparency = 1
    mainText.TextTransparency = 1
    mainText.Parent = bg

    local subText = Instance.new("TextLabel")
    subText.Text = subtitle
    subText.Font = Enum.Font.Gotham
    subText.TextColor3 = T.TextSub
    subText.TextSize = 11
    subText.TextXAlignment = Enum.TextXAlignment.Left
    subText.Size = UDim2.new(1, -56, 0, 14)
    subText.Position = UDim2.new(0, 50, 0, 32)
    subText.BackgroundTransparency = 1
    subText.TextTransparency = 1
    subText.Parent = bg

    local function fadeIn()
        local ti = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        TweenService:Create(bg,       ti, {BackgroundTransparency = 0}):Play()
        TweenService:Create(stroke,   ti, {Transparency = 0.4}):Play()
        TweenService:Create(bar,      ti, {BackgroundTransparency = 0}):Play()
        TweenService:Create(mainText, ti, {TextTransparency = 0}):Play()
        TweenService:Create(subText,  ti, {TextTransparency = 0.1}):Play()
        TweenService:Create(icon,     ti, {ImageTransparency = 0}):Play()
    end
    local function fadeOut()
        local ti = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        TweenService:Create(bg,       ti, {BackgroundTransparency = 1}):Play()
        TweenService:Create(stroke,   ti, {Transparency = 1}):Play()
        TweenService:Create(bar,      ti, {BackgroundTransparency = 1}):Play()
        TweenService:Create(mainText, ti, {TextTransparency = 1}):Play()
        TweenService:Create(subText,  ti, {TextTransparency = 1}):Play()
        TweenService:Create(icon,     ti, {ImageTransparency = 1}):Play()
        task.delay(0.35, function() notificationGui:Destroy() end)
    end

    fadeIn()
    task.delay(duration, fadeOut)
end

-- передаём реальную функцию в тему и gui
theme.createNotification = createNotification
gui.setNotification(createNotification)

-- ══════════════════════════════════════
--  LOGIC  (Home, Settings, поиск, загрузка категорий)
-- ══════════════════════════════════════
local logicFactory = safeLoad(BASE_ROOT .. "/loader/logic.lua")
if type(logicFactory) ~= "function" then
    warn("[MH] logic.lua failed or wrong format")
    return
end

local logic = logicFactory({
    TweenService       = TweenService,
    UserInputService   = UserInputService,
    Players            = Players,
    RunService         = RunService,
    TeleportService    = TeleportService,
    HttpService        = HttpService,
    MarketplaceService = MarketplaceService,
    player             = player,
    playerGui          = playerGui,
    platformName       = platformName,
    T                  = T,
    gui                = gui,
    HubData            = HubData,
    baseUrl            = baseUrl,
    categoryMap        = categoryMap,
    createNotification = createNotification,
    safeLoad           = safeLoad,
})

-- ══════════════════════════════════════
--  ЗАПУСК
-- ══════════════════════════════════════
logic.init()
