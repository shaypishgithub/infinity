-- MEGAHACK V2 - SEPARATED CORE + NEW GUI
-- Core Functionality (Save as MegaHackCore.lua or load directly)

local Core = {}

local Services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    RunService = game:GetService("RunService"),
    MarketplaceService = game:GetService("MarketplaceService"),
    TeleportService = game:GetService("TeleportService"),
    HttpService = game:GetService("HttpService"),
    Lighting = game:GetService("Lighting"),
    Workspace = game:GetService("Workspace"),
    StarterGui = game:GetService("StarterGui")
}

local player = Services.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 5)

Core.Services = Services
Core.Player = player
Core.PlayerGui = playerGui

Core.isMobile = Services.UserInputService.TouchEnabled and not Services.UserInputService.KeyboardEnabled

-- Safe Load
Core.safeLoad = function(url)
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)
    if ok then return res or {} end
    warn("[MH Core] Failed to load:", url)
    return {}
end

-- Hub Data (same as before)
Core.HubData = {
    Brookhaven = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/brookhaven"),
    Evade = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/evade"),
    MM2 = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/MM2.lua"),
    MegaHack = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/megapizda"),
    Hacks = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/Hacks.lua"),
    Admins = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/admin"),
    Animations = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/animation"),
    FE = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/FE.lua"),
    RagdollEngine = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/ragdoll"),
    NaturalDisaster = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/NaturalDisaster.lua"),
    BloxFruit = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/BloxFruit.lua"),
    BladeBall = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/BladeBall.lua"),
    StealBrainRoot = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/StealBrainRoot.lua"),
    TowerOfHell = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/tower.lua"),
    AdoptMe = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/adoptme"),
    GrowGarden = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/GrowGarden.lua"),
    Night = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/Night.lua"),
    Weird = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/Weird.lua"),
    DuelsMVS = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/DuelsMVS.lua"),
    ViolenceDistrict = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/ViolenceDistrict.lua"),
    IKEA3008 = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/3008.lua"),
    Rivals = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/Rivals.lua"),
    FORSAKEN = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/FORSAKEN.lua"),
    LootUp = Core.safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/base/lootup.lua"),
}

-- Stats
Core.Stats = {totalHours = 0, sessions = 0, tabUsage = {}, mostUsedTab = "Home"}
function Core:LoadStats()
    pcall(function()
        if isfile("MegaHack/stats.json") then
            Core.Stats = Services.HttpService:JSONDecode(readfile("MegaHack/stats.json"))
        end
    end)
    Core.Stats.totalHours = Core.Stats.totalHours or 0
    Core.Stats.sessions = Core.Stats.sessions or 0
end

function Core:SaveStats()
    pcall(function()
        if not isfolder("MegaHack") then makefolder("MegaHack") end
        writefile("MegaHack/stats.json", Services.HttpService:JSONEncode(Core.Stats))
    end)
end

function Core:TrackTab(tabName)
    Core.Stats.tabUsage[tabName] = (Core.Stats.tabUsage[tabName] or 0) + 1
    local maxC, maxT = 0, "Home"
    for t, c in pairs(Core.Stats.tabUsage) do
        if c > maxC then maxC, maxT = c, t end
    end
    Core.Stats.mostUsedTab = maxT
    Core:SaveStats()
end

-- Notifications
function Core:Notify(title, subtitle, duration, icon)
    duration = duration or 3
    local gui = Instance.new("ScreenGui", Core.PlayerGui)
    gui.ResetOnSpawn = false
    gui.Name = "MH_Notif"

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 70)
    frame.Position = UDim2.new(1, -300, 0, 80)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local iconLbl = Instance.new("ImageLabel")
    iconLbl.Size = UDim2.new(0, 40, 0, 40)
    iconLbl.Position = UDim2.new(0, 15, 0.5, -20)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Image = icon and ("rbxassetid://" .. icon) or "rbxassetid://74283928898866"
    iconLbl.Parent = frame

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Text = title
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 15
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.Position = UDim2.new(0, 65, 0, 12)
    titleLbl.Size = UDim2.new(1, -80, 0, 20)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Parent = frame

    local subLbl = Instance.new("TextLabel")
    subLbl.Text = subtitle
    subLbl.Font = Enum.Font.Gotham
    subLbl.TextSize = 13
    subLbl.TextColor3 = Color3.fromRGB(180, 180, 190)
    subLbl.Position = UDim2.new(0, 65, 0, 35)
    subLbl.Size = UDim2.new(1, -80, 0, 20)
    subLbl.BackgroundTransparency = 1
    subLbl.Parent = frame

    -- Animation
    Services.TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -300, 0, 80)}):Play()
    task.delay(duration, function()
        Services.TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(1, 50, 0, 80)}):Play()
        task.delay(0.4, function() gui:Destroy() end)
    end)
end

-- Anti Ban
function Core:SetupAntiBan()
    local mt = getrawmetatable(game)
    if mt then
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method:lower():find("kick") or method:lower():find("ban") then
                Core:Notify("ANTI-BAN", "Blocked " .. method, 3)
                return
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end
end

-- Other utilities (coordinates, etc.)
function Core:SavePosition()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        local pos = root.Position
        local str = string.format("X:%.2f Y:%.2f Z:%.2f", pos.X, pos.Y, pos.Z)
        if not isfolder("MegaHack") then makefolder("MegaHack") end
        writefile("MegaHack/pos.txt", str)
        Core:Notify("SAVED", str, 4)
    end
end

function Core:TeleportToSaved()
    if isfile("MegaHack/pos.txt") then
        local data = readfile("MegaHack/pos.txt")
        local x,y,z = data:match("X:(%d+%.?%d*) Y:(%d+%.?%d*) Z:(%d+%.?%d*)")
        if x and y and z then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
            end
        end
    end
end

Core:LoadStats()
Core.Stats.sessions = Core.Stats.sessions + 1
Core:SaveStats()

task.spawn(function()
    while wait(60) do
        Core.Stats.totalHours = Core.Stats.totalHours + 1/60
        Core:SaveStats()
    end
end)

return Core
