-- maybemenu.lua
-- Точка входа. Загружает theme → gui → logic и запускает всё.

local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local Players            = game:GetService("Players")
local CoreGui            = game:GetService("CoreGui")
local RunService         = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService    = game:GetService("TeleportService")
local HttpService        = game:GetService("HttpService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 8)
if not playerGui then warn("[MH] PlayerGui not found"); return end

local isMobile    = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local platformName = isMobile and "Mobile" or "PC"

-- ══════════════════════════════════════
--  SAFE LOAD
-- ══════════════════════════════════════
local function safeLoad(url)
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(url .. "?v=" .. math.floor(tick()), true))()
    end)
    if ok and res ~= nil then return res end
    warn("[MH] safeLoad failed: " .. tostring(url) .. " | " .. tostring(res))
    return nil
end

-- ══════════════════════════════════════
--  BASE CONFIG
-- ══════════════════════════════════════
local BASE = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack"

local baseConfig = safeLoad(BASE .. "/base.lua")
if type(baseConfig) ~= "table" or not baseConfig.categories then
    warn("[MH] base.lua не загрузилась")
    return
end

local baseUrl     = baseConfig.baseUrl or (BASE .. "/base")
local categoryMap = baseConfig.categories

-- ══════════════════════════════════════
--  ПРЕДЗАГРУЗКА КАТЕГОРИЙ
-- ══════════════════════════════════════
local HubData = {}
for name, file in pairs(categoryMap) do
    local d = safeLoad(baseUrl .. "/" .. file)
    if type(d) == "table" and #d > 0 then
        HubData[name] = d
    end
end

-- ══════════════════════════════════════
--  ACCENT REGISTRY
-- ══════════════════════════════════════
local accentRegistry = {}
local function regA(obj, prop)
    table.insert(accentRegistry, {obj = obj, prop = prop or "BackgroundColor3"})
end

-- ══════════════════════════════════════
--  NOTIFICATION (определяем до theme/gui)
-- ══════════════════════════════════════
local createNotification

createNotification = function(title, body, duration, iconId)
    duration = duration or 3
    iconId   = iconId or 74283928898866

    local ng = Instance.new("ScreenGui")
    ng.Name = "MH_Notif"
    ng.ResetOnSpawn = false
    ng.DisplayOrder = 50
    pcall(function()
        if gethui then ng.Parent = gethui()
        else ng.Parent = playerGui end
    end)
    if not ng.Parent then ng.Parent = playerGui end

    local W = 250
    local wrap = Instance.new("Frame")
    wrap.Size                   = UDim2.new(0, W, 0, 68)
    wrap.Position               = UDim2.new(1, -(W+18), 0, 22)
    wrap.BackgroundTransparency = 1
    wrap.Parent                 = ng

    local bg = Instance.new("Frame")
    bg.Size                   = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3       = Color3.fromRGB(18, 18, 26)
    bg.BackgroundTransparency = 1
    bg.BorderSizePixel        = 0
    bg.Parent                 = wrap
    local bgC = Instance.new("UICorner"); bgC.CornerRadius = UDim.new(0,11); bgC.Parent = bg
    -- стеклянный бордер
    local bgS = Instance.new("UIStroke"); bgS.Thickness=1; bgS.Color=Color3.new(1,1,1); bgS.Transparency=1; bgS.Parent=bg
    -- блик
    local sh = Instance.new("Frame")
    sh.BackgroundColor3=Color3.new(1,1,1); sh.BackgroundTransparency=1
    sh.BorderSizePixel=0; sh.Size=UDim2.new(1,0,0.44,0); sh.ZIndex=2; sh.Parent=bg
    local shC = Instance.new("UICorner"); shC.CornerRadius=UDim.new(0,11); shC.Parent=sh
    local shG = Instance.new("UIGradient"); shG.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.5),NumberSequenceKeypoint.new(1,1)}); shG.Rotation=90; shG.Parent=sh

    -- Цветная полоска слева
    local bar = Instance.new("Frame")
    bar.Size=UDim2.new(0,3,0.65,0); bar.Position=UDim2.new(0,0,0.175,0)
    bar.BackgroundColor3=Color3.fromRGB(139,92,246); bar.BackgroundTransparency=1
    bar.BorderSizePixel=0; bar.ZIndex=3; bar.Parent=bg
    local barC = Instance.new("UICorner"); barC.CornerRadius=UDim.new(0,3); barC.Parent=bar

    -- Иконка
    local ico = Instance.new("ImageLabel")
    ico.Size=UDim2.new(0,28,0,28); ico.Position=UDim2.new(0,14,0.5,-14)
    ico.BackgroundTransparency=1; ico.Image="rbxassetid://"..tostring(iconId)
    ico.ImageTransparency=1; ico.ZIndex=3; ico.Parent=bg

    -- Заголовок
    local tl = Instance.new("TextLabel")
    tl.BackgroundTransparency=1; tl.Text=title
    tl.Font=Enum.Font.GothamBold; tl.TextSize=13; tl.TextColor3=Color3.fromRGB(230,230,238)
    tl.TextXAlignment=Enum.TextXAlignment.Left; tl.TextTransparency=1
    tl.Size=UDim2.new(1,-54,0,18); tl.Position=UDim2.new(0,50,0,12)
    tl.ZIndex=3; tl.Parent=bg

    -- Подзаголовок
    local sl = Instance.new("TextLabel")
    sl.BackgroundTransparency=1; sl.Text=tostring(body)
    sl.Font=Enum.Font.Gotham; sl.TextSize=11; sl.TextColor3=Color3.fromRGB(130,130,148)
    sl.TextXAlignment=Enum.TextXAlignment.Left; sl.TextTransparency=1; sl.TextWrapped=true
    sl.Size=UDim2.new(1,-54,0,30); sl.Position=UDim2.new(0,50,0,30)
    sl.ZIndex=3; sl.Parent=bg

    local ti_in  = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local ti_out = TweenInfo.new(0.28, Enum.EasingStyle.Sine,  Enum.EasingDirection.In)

    local function fadeIn()
        TweenService:Create(bg,  ti_in, {BackgroundTransparency=0.08}):Play()
        TweenService:Create(bgS, ti_in, {Transparency=0.75}):Play()
        TweenService:Create(sh,  ti_in, {BackgroundTransparency=0.90}):Play()
        TweenService:Create(bar, ti_in, {BackgroundTransparency=0}):Play()
        TweenService:Create(ico, ti_in, {ImageTransparency=0}):Play()
        TweenService:Create(tl,  ti_in, {TextTransparency=0}):Play()
        TweenService:Create(sl,  ti_in, {TextTransparency=0.08}):Play()
    end
    local function fadeOut()
        TweenService:Create(bg,  ti_out, {BackgroundTransparency=1}):Play()
        TweenService:Create(bgS, ti_out, {Transparency=1}):Play()
        TweenService:Create(sh,  ti_out, {BackgroundTransparency=1}):Play()
        TweenService:Create(bar, ti_out, {BackgroundTransparency=1}):Play()
        TweenService:Create(ico, ti_out, {ImageTransparency=1}):Play()
        TweenService:Create(tl,  ti_out, {TextTransparency=1}):Play()
        TweenService:Create(sl,  ti_out, {TextTransparency=1}):Play()
        task.delay(0.32, function() pcall(function() ng:Destroy() end) end)
    end

    fadeIn()
    task.delay(duration, fadeOut)
end

-- ══════════════════════════════════════
--  THEME
-- ══════════════════════════════════════
local themeFactory = safeLoad(BASE .. "/loader/theme.lua")
if type(themeFactory) ~= "function" then
    warn("[MH] theme.lua не загрузилась"); return
end

local theme = themeFactory({
    TweenService     = TweenService,
    RunService       = RunService,
    HttpService      = HttpService,
    UserInputService = UserInputService,
    accentRegistry   = accentRegistry,
    getNotification  = function() return createNotification end,
})

local T = theme.T

-- ══════════════════════════════════════
--  GUI
-- ══════════════════════════════════════
local guiFactory = safeLoad(BASE .. "/loader/gui.lua")
if type(guiFactory) ~= "function" then
    warn("[MH] gui.lua не загрузилась"); return
end

local gui = guiFactory({
    TweenService       = TweenService,
    UserInputService   = UserInputService,
    CoreGui            = CoreGui,
    MarketplaceService = MarketplaceService,
    T                  = T,
    regA               = regA,
    HubData            = HubData,
})

-- ══════════════════════════════════════
--  LOGIC
-- ══════════════════════════════════════
local logicFactory = safeLoad(BASE .. "/loader/logic.lua")
if type(logicFactory) ~= "function" then
    warn("[MH] logic.lua не загрузилась"); return
end

local logic = logicFactory({
    TweenService       = TweenService,
    UserInputService   = UserInputService,
    Players            = Players,
    RunService         = RunService,
    TeleportService    = TeleportService,
    HttpService        = HttpService,
    player             = player,
    playerGui          = playerGui,
    platformName       = platformName,
    T                  = T,
    gui                = gui,
    theme              = theme,
    HubData            = HubData,
    baseUrl            = baseUrl,
    categoryMap        = categoryMap,
    createNotification = createNotification,
    safeLoad           = safeLoad,
    accentRegistry     = accentRegistry,
})

-- ══════════════════════════════════════
--  СТАРТ
-- ══════════════════════════════════════
logic.init()
