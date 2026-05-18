-- ══════════════════════════════════════════════════════════════════
--  maybemenu.lua — ГЛАВНЫЙ ЗАГРУЗЧИК
-- ══════════════════════════════════════════════════════════════════

local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local Players            = game:GetService("Players")
local CoreGui            = game:GetService("CoreGui")
local RunService         = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService    = game:GetService("TeleportService")
local HttpService        = game:GetService("HttpService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 5)
if not playerGui then warn("[MH] PlayerGui not found!") return end

local isMobile    = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local platformName = isMobile and "Mobile" or "PC"

-- ══════════════════════════════════════
--  SAFE LOAD
-- ══════════════════════════════════════
local function safeLoad(url)
    local fullUrl = url .. "?t=" .. math.floor(tick())
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(fullUrl, true))()
    end)
    if ok and res then return res end
    warn("[MH] failed to load: " .. tostring(url) .. " | " .. tostring(res))
    return nil
end

-- ══════════════════════════════════════
--  BASE CONFIG
-- ══════════════════════════════════════
local BASE_ROOT = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack"

local baseConfig = safeLoad(BASE_ROOT .. "/base.lua")
if not baseConfig or not baseConfig.categories then
    warn("[MH] base.lua не загрузилась!")
    return
end

local baseUrl     = baseConfig.baseUrl or (BASE_ROOT .. "/base")
local categoryMap = baseConfig.categories or {}

local catNames = {}
for k in pairs(categoryMap) do table.insert(catNames, k) end
print("[MH] base.lua loaded. Категорий: " .. #catNames)

-- ══════════════════════════════════════
--  ПРЕДЗАГРУЗКА СКРИПТОВ
-- ══════════════════════════════════════
local HubData = {}
for categoryName, fileName in pairs(categoryMap) do
    local data = safeLoad(baseUrl .. "/" .. fileName)
    if type(data) == "table" and #data > 0 then
        HubData[categoryName] = data
        print("[MH] ✓ " .. categoryName .. " (" .. #data .. " scripts)")
    else
        warn("[MH] ✗ " .. categoryName)
    end
end

-- ══════════════════════════════════════
--  ACCENT REGISTRY
-- ══════════════════════════════════════
local accentRegistry = {}
local function regA(obj, prop)
    table.insert(accentRegistry, { obj = obj, prop = prop or "BackgroundColor3" })
end

-- ══════════════════════════════════════
--  THEME
-- ══════════════════════════════════════
local themeFactory = safeLoad(BASE_ROOT .. "/theme.lua")
if type(themeFactory) ~= "function" then warn("[MH] theme.lua ошибка") return end

local theme = themeFactory({
    TweenService       = TweenService,
    RunService         = RunService,
    HttpService        = HttpService,
    UserInputService   = UserInputService,
    playerGui          = playerGui,
    accentRegistry     = accentRegistry,
})
local T = theme.T

-- ══════════════════════════════════════
--  GUI
-- ══════════════════════════════════════
local guiFactory = safeLoad(BASE_ROOT .. "/gui.lua")
if type(guiFactory) ~= "function" then warn("[MH] gui.lua ошибка") return end

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
    isMobile           = isMobile,
    T                  = T,
    regA               = regA,
    accentRegistry     = accentRegistry,
    HubData            = HubData,
})

theme.setFrames(gui.mainFrame, gui.scrollingFrame)

-- ══════════════════════════════════════
--  NOTIFICATION
-- ══════════════════════════════════════
local createNotification

createNotification = function(title, subtitle, duration, iconId)
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name         = "MH_Notification"
    notifGui.Parent       = playerGui
    notifGui.ResetOnSpawn = false

    local W = 240
    local holder = Instance.new("Frame")
    holder.Size                   = UDim2.new(0, W, 0, 64)
    holder.Position               = UDim2.new(1, -(W + 16), 0, 24)
    holder.BackgroundTransparency = 1
    holder.Parent                 = notifGui

    local bg = Instance.new("Frame")
    bg.Size                   = UDim2.new(1,0,1,0)
    bg.BackgroundColor3       = T.BgSide
    bg.BackgroundTransparency = 1
    bg.Parent                 = holder
    local bgC = Instance.new("UICorner"); bgC.CornerRadius = UDim.new(0,10); bgC.Parent = bg

    local stroke = Instance.new("UIStroke")
    stroke.Thickness=1; stroke.Color=T.Stroke; stroke.Transparency=1; stroke.Parent=bg

    local bar = Instance.new("Frame")
    bar.Size=UDim2.new(0,3,1,-16); bar.Position=UDim2.new(0,0,0,8)
    bar.BackgroundColor3=T.AccentGlow; bar.BackgroundTransparency=1; bar.BorderSizePixel=0; bar.Parent=bg
    local barC = Instance.new("UICorner"); barC.CornerRadius=UDim.new(0,4); barC.Parent=bar

    local icon = Instance.new("ImageLabel")
    icon.Size=UDim2.new(0,28,0,28); icon.Position=UDim2.new(0,12,0.5,-14)
    icon.BackgroundTransparency=1; icon.Image="rbxassetid://"..tostring(iconId or 74283928898866)
    icon.ImageTransparency=1; icon.Parent=bg

    local mainTxt = Instance.new("TextLabel")
    mainTxt.Text=title; mainTxt.Font=Enum.Font.GothamBold; mainTxt.TextColor3=T.TextMain
    mainTxt.TextSize=13; mainTxt.TextXAlignment=Enum.TextXAlignment.Left
    mainTxt.Size=UDim2.new(1,-56,0,18); mainTxt.Position=UDim2.new(0,50,0,12)
    mainTxt.BackgroundTransparency=1; mainTxt.TextTransparency=1; mainTxt.Parent=bg

    local subTxt = Instance.new("TextLabel")
    subTxt.Text=subtitle or ""; subTxt.Font=Enum.Font.Gotham; subTxt.TextColor3=T.TextSub
    subTxt.TextSize=11; subTxt.TextXAlignment=Enum.TextXAlignment.Left
    subTxt.Size=UDim2.new(1,-56,0,14); subTxt.Position=UDim2.new(0,50,0,32)
    subTxt.BackgroundTransparency=1; subTxt.TextTransparency=1; subTxt.Parent=bg

    local ti_in  = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local ti_out = TweenInfo.new(0.30, Enum.EasingStyle.Sine,  Enum.EasingDirection.In)

    TweenService:Create(bg,      ti_in, {BackgroundTransparency=0}):Play()
    TweenService:Create(stroke,  ti_in, {Transparency=0.4}):Play()
    TweenService:Create(bar,     ti_in, {BackgroundTransparency=0}):Play()
    TweenService:Create(mainTxt, ti_in, {TextTransparency=0}):Play()
    TweenService:Create(subTxt,  ti_in, {TextTransparency=0.1}):Play()
    TweenService:Create(icon,    ti_in, {ImageTransparency=0}):Play()

    task.delay(duration or 3, function()
        TweenService:Create(bg,      ti_out,{BackgroundTransparency=1}):Play()
        TweenService:Create(stroke,  ti_out,{Transparency=1}):Play()
        TweenService:Create(bar,     ti_out,{BackgroundTransparency=1}):Play()
        TweenService:Create(mainTxt, ti_out,{TextTransparency=1}):Play()
        TweenService:Create(subTxt,  ti_out,{TextTransparency=1}):Play()
        TweenService:Create(icon,    ti_out,{ImageTransparency=1}):Play()
        task.delay(0.35, function() notifGui:Destroy() end)
    end)
end

gui.setNotification(createNotification)

-- ══════════════════════════════════════
--  LOGIC
-- ══════════════════════════════════════
local logicFactory = safeLoad(BASE_ROOT .. "/logic.lua")
if type(logicFactory) ~= "function" then warn("[MH] logic.lua ошибка") return end

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
    isMobile           = isMobile,
    T                  = T,
    gui                = gui,
    HubData            = HubData,
    baseUrl            = baseUrl,
    categoryMap        = categoryMap,
    accentRegistry     = accentRegistry,
    createNotification = createNotification,
    safeLoad           = safeLoad,
})

logic.init()
