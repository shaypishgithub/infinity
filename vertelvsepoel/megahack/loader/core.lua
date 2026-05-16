-- core.lua
local Core = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

Core.T = {
    BgBase = Color3.fromRGB(10, 10, 14),
    BgSide = Color3.fromRGB(16, 16, 22),
    BgPanel = Color3.fromRGB(22, 22, 30),
    BgBtn = Color3.fromRGB(28, 28, 38),
    AccentGreen = Color3.fromRGB(0, 255, 100),
    AccentRed = Color3.fromRGB(255, 60, 80),
    AccentPurple = Color3.fromRGB(180, 80, 255),
    AccentYellow = Color3.fromRGB(255, 220, 60),
    TextMain = Color3.fromRGB(235, 235, 245),
    TextSub = Color3.fromRGB(160, 160, 175),
    Stroke = Color3.fromRGB(45, 45, 60),
}

Core.HubData = {
    Brookhaven = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/brookhaven", true))(),
    Evade = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/evade", true))(),
    MM2 = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/MM2.lua", true))(),
    MegaHack = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/megapizda", true))(),
    Hacks = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/Hacks.lua", true))(),
    Admins = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/admin", true))(),
    Animations = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/animation", true))(),
    FE = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/FE.lua", true))(),
    RagdollEngine = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/ragdoll", true))(),
    NaturalDisaster = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/NaturalDisaster.lua", true))(),
    BloxFruit = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/BloxFruit.lua", true))(),
    BladeBall = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/BladeBall.lua", true))(),
    StealBrainRoot = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/StealBrainRoot.lua", true))(),
    TowerOfHell = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/tower.lua", true))(),
    AdoptMe = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/adoptme", true))(),
    GrowGarden = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/GrowGarden.lua", true))(),
    Night = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/Night.lua", true))(),
    Weird = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/Weird.lua", true))(),
    DuelsMVS = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/DuelsMVS.lua", true))(),
    ViolenceDistrict = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/ViolenceDistrict.lua", true))(),
    IKEA3008 = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/3008.lua", true))(),
    Rivals = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/Rivals.lua", true))(),
    FORSAKEN = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/FORSAKEN.lua", true))(),
    LootUp = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/base/lootup.lua", true))(),
}

Core.stats = {totalHours = 0, sessions = 0, tabUsage = {}, mostUsedTab = "None"}
Core.settings = {
    locked = false,
    rgbAccent = false,
    rgbStroke = false,
    transparency = 0.05,
    colors = {
        bgColor = Core.T.BgBase,
        textColor = Core.T.TextMain,
        accentGreen = Core.T.AccentGreen,
        accentRed = Core.T.AccentRed,
        accentPurple = Core.T.AccentPurple,
        accentYellow = Core.T.AccentYellow,
    }
}

function Core:safeLoad(url)
    local ok, res = pcall(function() return loadstring(game:HttpGet(url, true))() end)
    return ok and res or {}
end

function Core:createNotification(title, subtitle, duration, iconId)
    local notifGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    notifGui.Name = "CoreNotif"
    notifGui.ResetOnSpawn = false

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 280, 0, 72)
    main.Position = UDim2.new(1, -300, 0, 40)
    main.BackgroundColor3 = Core.T.BgSide
    main.Parent = notifGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 36, 0, 36)
    icon.Position = UDim2.new(0, 16, 0.5, -18)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://" .. (iconId or "74283928898866")
    icon.Parent = main

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Text = title
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 14
    titleLbl.TextColor3 = Color3.fromRGB(255,255,255)
    titleLbl.Position = UDim2.new(0, 64, 0, 12)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Parent = main

    local subLbl = Instance.new("TextLabel")
    subLbl.Text = subtitle
    subLbl.Font = Enum.Font.Gotham
    subLbl.TextSize = 12
    subLbl.TextColor3 = Color3.fromRGB(180,180,190)
    subLbl.Position = UDim2.new(0, 64, 0, 34)
    subLbl.BackgroundTransparency = 1
    subLbl.Parent = main

    TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -300, 0, 40)}):Play()

    task.delay(duration or 3, function()
        TweenService:Create(main, TweenInfo.new(0.3), {Position = UDim2.new(1, 50, 0, 40)}):Play()
        task.delay(0.4, function() notifGui:Destroy() end)
    end)
end

function Core:loadStats()
    pcall(function()
        if isfile("MegaHack/stats.json") then
            Core.stats = HttpService:JSONDecode(readfile("MegaHack/stats.json"))
        end
    end)
end

function Core:saveStats()
    pcall(function()
        if not isfolder("MegaHack") then makefolder("MegaHack") end
        writefile("MegaHack/stats.json", HttpService:JSONEncode(Core.stats))
    end)
end

function Core:trackTab(tabName)
    Core.stats.tabUsage[tabName] = (Core.stats.tabUsage[tabName] or 0) + 1
    local maxTab, maxC = "None", 0
    for t, c in pairs(Core.stats.tabUsage) do
        if c > maxC then maxC, maxTab = c, t end
    end
    Core.stats.mostUsedTab = maxTab
    Core:saveStats()
end

function Core:setupAntiBan()
    local mt = getrawmetatable(game)
    if mt then
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method:lower() == "kick" or method:lower() == "ban" then
                Core:createNotification("PROTECTION", "Blocked " .. method, 3)
                return
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end
end

function Core:saveColorSettings()
    pcall(function()
        if not isfolder("MegaHack") then makefolder("MegaHack") end
        writefile("MegaHack/colors.json", HttpService:JSONEncode(Core.settings))
    end)
end

function Core:loadColorSettings()
    pcall(function()
        if isfile("MegaHack/colors.json") then
            local data = HttpService:JSONDecode(readfile("MegaHack/colors.json"))
            Core.settings = data
        end
    end)
end

return Core
