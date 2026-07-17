═══════════════════════════════════════════════════════════════
--  maybemenu.lua — Main Orchestrator v3 (2026 Edition)
--  Load order: base → Notifications → Theme → GUI → Logic
═══════════════════════════════════════════════════════════════

local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local Players            = game:GetService("Players")
local CoreGui            = game:GetService("CoreGui")
local RunService         = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService        = game:GetService("HttpService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 5)
if not playerGui then warn("[MH] PlayerGui not found!") return end

local isMobile     = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local platformName = isMobile and "📱 Mobile" or "💻 PC"

-- ═══ SAFE LOAD ═══
local function safeLoad(url)
    local fullUrl = url .. "?t=" .. math.floor(tick())
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(fullUrl, true))()
    end)
    if ok and res then return res end
    warn("[MH] failed to load: " .. tostring(url) .. " | " .. tostring(res))
    return nil
end

-- ═══ BASE CONFIG ═══
local BASE_ROOT = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack"

local baseConfig = safeLoad(BASE_ROOT .. "/base.lua")
if not baseConfig or not baseConfig.categories then
    warn("[MH] base.lua failed or damaged!")
    return
end

local baseUrl     = baseConfig.baseUrl or (BASE_ROOT .. "/base")
local categoryMap = baseConfig.categories or {}
local gameIcons   = baseConfig.gameIcons  or {}

-- ═══ PREFETCH SCRIPT DATA ═══
local HubData = {}
local function prefetchAll()
    for categoryName, fileName in pairs(categoryMap) do
        task.spawn(function()
            local data = safeLoad(baseUrl .. "/" .. fileName)
            if type(data) == "table" and #data > 0 then
                HubData[categoryName] = data
            end
        end)
        task.wait(0.02) -- Stagger to prevent CDN burst
    end
end
prefetchAll()

-- ═══ ACCENT REGISTRY ═══
local accentRegistry = {}
local function regA(obj, prop)
    table.insert(accentRegistry, { obj = obj, prop = prop or "BackgroundColor3" })
end

-- ═══ PLACEHOLDER NOTIFICATION ═══
local createNotification = function() end

-- ═══ LOAD NOTIFICATIONS ═══
local notifFactory = safeLoad(BASE_ROOT .. "/notifications.lua")
if type(notifFactory) == "function" then
    local notifMod = notifFactory({
        TweenService = TweenService,
        CoreGui      = CoreGui,
        T            = { 
            BgCard = Color3.fromRGB(18, 18, 36), 
            BgDeep = Color3.fromRGB(6, 6, 14),
            Accent = Color3.fromRGB(0, 220, 255),
            AccentGlow = Color3.fromRGB(100, 255, 255),
            TextMain = Color3.fromRGB(240, 240, 255),
            TextSub = Color3.fromRGB(160, 160, 190),
            StrokeBrt = Color3.fromRGB(0, 180, 220),
        }
    })
    if notifMod then
        createNotification = notifMod.createNotification
    end
end

-- ═══ LOAD THEME ═══
local themeFactory = safeLoad(BASE_ROOT .. "/theme.lua")
if type(themeFactory) ~= "function" then
    warn("[MH] theme.lua failed"); return
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

-- ═══ LOAD GUI ═══
local guiFactory = safeLoad(BASE_ROOT .. "/gui.lua")
if type(guiFactory) ~= "function" then
    warn("[MH] gui.lua failed"); return
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

-- ═══ LOAD LOGIC ═══
local logicFactory = safeLoad(BASE_ROOT .. "/logic.lua")
if type(logicFactory) == "function" then
    logicFactory({
        TweenService       = TweenService,
        UserInputService   = UserInputService,
        Players            = Players,
        RunService         = RunService,
        HttpService        = HttpService,
        player             = player,
        playerGui          = playerGui,
        platformName       = platformName,
        T                  = T,
        theme              = theme,
        gui                = gui,
        HubData            = HubData,
        baseUrl            = baseUrl,
        categoryMap        = categoryMap,
        gameIcons          = gameIcons,
        createNotification = createNotification,
        safeLoad           = safeLoad,
    })
else
    warn("[MH] logic.lua failed!")
end
