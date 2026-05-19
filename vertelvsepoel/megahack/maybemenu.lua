-- ══════════════════════════════════════════════════════════════════
--  maybemenu.lua  —  Main Loader  v2
--  Load order: base → HubData prefetch → theme → gui → notify → logic
--  NEW: gameIcons passed from base.lua → logic.lua (Games virtual tab)
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
--  SAFE LOAD  (cache-busted)
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
    warn("[MH] base.lua failed or damaged!")
    return
end

local baseUrl     = baseConfig.baseUrl or (BASE_ROOT .. "/base")
local categoryMap = baseConfig.categories or {}
local gameIcons   = baseConfig.gameIcons  or {}   -- NEW: PlaceId map for Games tab

local catNames = {}
for k in pairs(categoryMap) do table.insert(catNames, k) end
print("[MH] base.lua loaded. Categories: " .. #catNames .. " → " .. table.concat(catNames, ", "))

-- ══════════════════════════════════════
--  PREFETCH SCRIPT DATA
--  Loads all category .lua files in background.
--  Uses task.spawn so they load in parallel.
--  Yields a small gap between spawns to avoid
--  hammering the CDN on mobile.
-- ══════════════════════════════════════
local HubData = {}

local function prefetchAll()
    local threads = {}
    for categoryName, fileName in pairs(categoryMap) do
        local t = task.spawn(function()
            local data = safeLoad(baseUrl .. "/" .. fileName)
            if type(data) == "table" and #data > 0 then
                HubData[categoryName] = data
                print("[MH] ✓ " .. categoryName .. " (" .. #data .. " scripts)")
            else
                warn("[MH] ✗ " .. categoryName)
            end
        end)
        table.insert(threads, t)
        task.wait(0.02)  -- stagger spawns: 20ms gap each → no CDN burst
    end
end

prefetchAll()   -- non-blocking: runs in background while GUI builds

-- ══════════════════════════════════════
--  ACCENT REGISTRY
-- ══════════════════════════════════════
local accentRegistry = {}
local function regA(obj, prop)
    table.insert(accentRegistry, { obj = obj, prop = prop or "BackgroundColor3" })
end

-- ══════════════════════════════════════
--  NOTIFICATION  (forward declared)
-- ══════════════════════════════════════
local createNotification  -- defined below after T is available

-- ══════════════════════════════════════
--  THEME
-- ══════════════════════════════════════
local themeFactory = safeLoad(BASE_ROOT .. "/theme.lua")
if type(themeFactory) ~= "function" then
    warn("[MH] theme.lua failed or wrong format"); return
end

local theme = themeFactory({
    TweenService       = TweenService,
    RunService         = RunService,
    HttpService        = HttpService,
    UserInputService   = UserInputService,
    playerGui          = playerGui,
    accentRegistry     = accentRegistry,
    createNotification = function(...) return createNotification(...) end,
})
local T = theme.T

-- ══════════════════════════════════════
--  GUI
-- ══════════════════════════════════════
local guiFactory = safeLoad(BASE_ROOT .. "/gui.lua")
if type(guiFactory) ~= "function" then
    warn("[MH] gui.lua failed or wrong format"); return
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

-- Wire frames into theme AFTER gui creates them
theme.setFrames(gui.mainFrame, gui.scrollingFrame)

-- ══════════════════════════════════════
--  NOTIFICATION  (real implementation)
-- ══════════════════════════════════════
createNotification = function(title, subtitle, duration, iconId)
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name         = "MH_Notification"
    notifGui.ResetOnSpawn = false

    local function placeGui(g)
        local ok = pcall(function()
            if get_hidden_gui then g.Parent = get_hidden_gui()
            elseif gethui then g.Parent = gethui()
            else g.Parent = CoreGui end
        end)
        if not ok then g.Parent = CoreGui end
    end
    placeGui(notifGui)

    local W = 248
    local holder = Instance.new("Frame")
    holder.Size     = UDim2.new(0, W, 0, 66)
    holder.Position = UDim2.new(1, -(W+18), 0, 22)
    holder.BackgroundTransparency = 1
    holder.Parent   = notifGui

    local bg = Instance.new("Frame")
    bg.Size                   = UDim2.new(1,0,1,0)
    bg.BackgroundColor3       = T.BgSide
    bg.BackgroundTransparency = 1
    bg.Parent                 = holder
    local bgCorner = Instance.new("UICorner", bg)
    bgCorner.CornerRadius = UDim.new(0,11)

    local stroke = Instance.new("UIStroke", bg)
    stroke.Thickness    = 1
    stroke.Color        = T.Stroke
    stroke.Transparency = 1

    local bar = Instance.new("Frame", bg)
    bar.Size                   = UDim2.new(0,3,1,-16)
    bar.Position               = UDim2.new(0,0,0,8)
    bar.BackgroundColor3       = T.AccentGlow
    bar.BackgroundTransparency = 1
    bar.BorderSizePixel        = 0
    Instance.new("UICorner",bar).CornerRadius = UDim.new(0,4)

    local icon = Instance.new("ImageLabel", bg)
    icon.Size               = UDim2.new(0,26,0,26)
    icon.Position           = UDim2.new(0,12,0.5,-13)
    icon.BackgroundTransparency = 1
    icon.Image              = "rbxassetid://" .. tostring(iconId or 74283928898866)
    icon.ImageTransparency  = 1

    local mainTxt = Instance.new("TextLabel", bg)
    mainTxt.Text              = title
    mainTxt.Font              = Enum.Font.GothamBold
    mainTxt.TextColor3        = T.TextMain
    mainTxt.TextSize          = 13
    mainTxt.TextXAlignment    = Enum.TextXAlignment.Left
    mainTxt.Size              = UDim2.new(1,-52,0,18)
    mainTxt.Position          = UDim2.new(0,48,0,12)
    mainTxt.BackgroundTransparency = 1
    mainTxt.TextTransparency  = 1

    local subTxt = Instance.new("TextLabel", bg)
    subTxt.Text               = subtitle or ""
    subTxt.Font               = Enum.Font.Gotham
    subTxt.TextColor3         = T.TextSub
    subTxt.TextSize           = 11
    subTxt.TextXAlignment     = Enum.TextXAlignment.Left
    subTxt.Size               = UDim2.new(1,-52,0,14)
    subTxt.Position           = UDim2.new(0,48,0,33)
    subTxt.BackgroundTransparency = 1
    subTxt.TextTransparency   = 1

    -- Progress bar at bottom
    local progress = Instance.new("Frame", bg)
    progress.Size               = UDim2.new(1,0,0,2)
    progress.Position           = UDim2.new(0,0,1,-2)
    progress.BackgroundColor3   = T.Accent
    progress.BackgroundTransparency = 1
    progress.BorderSizePixel    = 0
    Instance.new("UICorner",progress).CornerRadius = UDim.new(1,0)

    local dur = duration or 3
    local ti_in  = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local ti_out = TweenInfo.new(0.28, Enum.EasingStyle.Sine,  Enum.EasingDirection.In)

    -- Fade in
    TweenService:Create(bg,       ti_in, {BackgroundTransparency=0.05}):Play()
    TweenService:Create(stroke,   ti_in, {Transparency=0.45}):Play()
    TweenService:Create(bar,      ti_in, {BackgroundTransparency=0}):Play()
    TweenService:Create(icon,     ti_in, {ImageTransparency=0}):Play()
    TweenService:Create(mainTxt,  ti_in, {TextTransparency=0}):Play()
    TweenService:Create(subTxt,   ti_in, {TextTransparency=0.08}):Play()
    TweenService:Create(progress, ti_in, {BackgroundTransparency=0.35}):Play()

    -- Progress shrink
    TweenService:Create(progress,
        TweenInfo.new(dur, Enum.EasingStyle.Linear),
        {Size=UDim2.new(0,0,0,2)}
    ):Play()

    -- Fade out
    task.delay(dur, function()
        TweenService:Create(bg,       ti_out, {BackgroundTransparency=1}):Play()
        TweenService:Create(stroke,   ti_out, {Transparency=1}):Play()
        TweenService:Create(bar,      ti_out, {BackgroundTransparency=1}):Play()
        TweenService:Create(icon,     ti_out, {ImageTransparency=1}):Play()
        TweenService:Create(mainTxt,  ti_out, {TextTransparency=1}):Play()
        TweenService:Create(subTxt,   ti_out, {TextTransparency=1}):Play()
        TweenService:Create(progress, ti_out, {BackgroundTransparency=1}):Play()
        task.delay(0.32, function() notifGui:Destroy() end)
    end)
end

-- Wire real notification back into gui
gui.setNotification(createNotification)

-- ══════════════════════════════════════
--  LOGIC
-- ══════════════════════════════════════
local logicFactory = safeLoad(BASE_ROOT .. "/logic.lua")
if type(logicFactory) ~= "function" then
    warn("[MH] logic.lua failed or wrong format"); return
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
    gameIcons          = gameIcons,       -- NEW: passed to logic for Games tab
    accentRegistry     = accentRegistry,
    createNotification = createNotification,
    safeLoad           = safeLoad,
})

-- ══════════════════════════════════════
--  LAUNCH
-- ══════════════════════════════════════
logic.init()
