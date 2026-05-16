--[[ core.lua ]]--
local Core = {}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local function safeLoad(url)
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)
    if ok and res then return res end
    warn("[MH] failed to load: " .. tostring(url))
    return {}
end

Core.HubData = {
    Brookhaven = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/brookhaven"),
    Evade = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/evade"),
    MM2 = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/MM2.lua"),
    MegaHack = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/megapizda"),
    Hacks = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/Hacks.lua"),
    Admins = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/admin"),
    Animations = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/animation"),
    FE = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/FE.lua"),
    RagdollEngine = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/ragdoll"),
    NaturalDisaster = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/NaturalDisaster.lua"),
    BloxFruit = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/BloxFruit.lua"),
    BladeBall = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/BladeBall.lua"),
    StealBrainRoot = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/StealBrainRoot.lua"),
    TowerOfHell = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/tower.lua"),
    AdoptMe = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/adoptme"),
    GrowGarden = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/GrowGarden.lua"),
    Night = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/Night.lua"),
    Weird = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/Weird.lua"),
    DuelsMVS = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/DuelsMVS.lua"),
    ViolenceDistrict = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/ViolenceDistrict.lua"),
    IKEA3008 = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/3008.lua"),
    Rivals = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/Rivals.lua"),
    FORSAKEN = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/FORSAKEN.lua"),
    LootUp = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/base/lootup.lua"),
}

Core.PresetColors = {
    Green = Color3.fromRGB(0, 200, 100),
    Red = Color3.fromRGB(220, 40, 40),
    Purple = Color3.fromRGB(150, 50, 220),
    Yellow = Color3.fromRGB(230, 200, 0),
}

Core.Stats = { totalHours = 0, sessions = 0, tabUsage = {}, mostUsedTab = "None" }
Core.Settings = {
    locked = false,
    rgbAccent = false,
    rgbStroke = false,
    transparency = 0.04,
    presetAccent = "Green",
    colors = {
        bgColor = Color3.fromRGB(13, 13, 17),
        textColor = Color3.fromRGB(228, 228, 235),
        strokeColor = Color3.fromRGB(44, 44, 56),
        accentColor = Core.PresetColors.Green,
    }
}

function Core.LoadStats()
    pcall(function()
        if isfile("MegaHack/stats.json") then
            Core.Stats = HttpService:JSONDecode(readfile("MegaHack/stats.json"))
        end
    end)
    if not Core.Stats.totalHours then Core.Stats.totalHours = 0 end
    if not Core.Stats.sessions then Core.Stats.sessions = 0 end
    if not Core.Stats.tabUsage then Core.Stats.tabUsage = {} end
    if not Core.Stats.mostUsedTab then Core.Stats.mostUsedTab = "None" end
end

function Core.SaveStats()
    pcall(function()
        if not isfolder("MegaHack") then makefolder("MegaHack") end
        writefile("MegaHack/stats.json", HttpService:JSONEncode(Core.Stats))
    end)
end

function Core.TrackTab(tabName)
    Core.Stats.tabUsage[tabName] = (Core.Stats.tabUsage[tabName] or 0) + 1
    local maxCount, maxTab = 0, "None"
    for tab, count in pairs(Core.Stats.tabUsage) do
        if count > maxCount then maxCount = count; maxTab = tab end
    end
    Core.Stats.mostUsedTab = maxTab
    Core.SaveStats()
end

function Core.LoadColorSettings()
    pcall(function()
        if isfile("MegaHack/colorSettings.json") then
            local data = HttpService:JSONDecode(readfile("MegaHack/colorSettings.json"))
            if data.bgColor then Core.Settings.colors.bgColor = Color3.new(data.bgColor[1], data.bgColor[2], data.bgColor[3]) end
            if data.textColor then Core.Settings.colors.textColor = Color3.new(data.textColor[1], data.textColor[2], data.textColor[3]) end
            if data.strokeColor then Core.Settings.colors.strokeColor = Color3.new(data.strokeColor[1], data.strokeColor[2], data.strokeColor[3]) end
            if data.accentColor then Core.Settings.colors.accentColor = Color3.new(data.accentColor[1], data.accentColor[2], data.accentColor[3]) end
            if data.transparency ~= nil then Core.Settings.transparency = data.transparency end
            if data.rgbAccent ~= nil then Core.Settings.rgbAccent = data.rgbAccent end
            if data.rgbStroke ~= nil then Core.Settings.rgbStroke = data.rgbStroke end
            if data.presetAccent then Core.Settings.presetAccent = data.presetAccent end
        end
    end)
end

function Core.SaveColorSettings()
    pcall(function()
        if not isfolder("MegaHack") then makefolder("MegaHack") end
        local col = Core.Settings.colors
        local data = {
            bgColor = {col.bgColor.R, col.bgColor.G, col.bgColor.B},
            textColor = {col.textColor.R, col.textColor.G, col.textColor.B},
            strokeColor = {col.strokeColor.R, col.strokeColor.G, col.strokeColor.B},
            accentColor = {col.accentColor.R, col.accentColor.G, col.accentColor.B},
            transparency = Core.Settings.transparency,
            rgbAccent = Core.Settings.rgbAccent,
            rgbStroke = Core.Settings.rgbStroke,
            presetAccent = Core.Settings.presetAccent,
        }
        writefile("MegaHack/colorSettings.json", HttpService:JSONEncode(data))
    end)
end

function Core.ApplyPresetAccent(name)
    if Core.PresetColors[name] then
        Core.Settings.colors.accentColor = Core.PresetColors[name]
        Core.Settings.presetAccent = name
    end
end

function Core.GetGameName()
    local ok, name = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId).Name end)
    return ok and name or "Unknown Game"
end

function Core.CountScripts()
    local count = 0
    for _, cat in pairs(Core.HubData) do
        if type(cat) == "table" then count = count + #cat end
    end
    return count
end

function Core.SearchScriptsByMegahack(query)
    local results = {}
    for categoryName, hacks in pairs(Core.HubData) do
        if type(hacks) == "table" then
            for _, hack in ipairs(hacks) do
                if type(hack) == "table" and hack[1] and type(hack[1]) == "string" then
                    if string.find(string.lower(hack[1]), string.lower(query)) or string.find(string.lower(categoryName), "megahack") then
                        table.insert(results, {name = hack[1], category = categoryName, func = hack[2]})
                    end
                end
            end
        end
    end
    return results
end

function Core.SearchScriptsOnScriptBlox(query)
    local results = {}
    local success, response = pcall(function()
        return HttpService:GetAsync("https://scriptblox.com/api/script/search?q=" .. HttpService:UrlEncode(query))
    end)
    if success then
        local data = HttpService:JSONDecode(response)
        if data and data.result and data.result.scripts then
            for _, script in ipairs(data.result.scripts) do
                table.insert(results, {name = script.title, category = "ScriptBlox", scriptId = script._id})
            end
        end
    end
    return results
end

function Core.CheckFunctions()
    local functionsToCheck = {
        "getrawmetatable","makefolder","getscriptbytecode","setthreadidentity","delfile","request",
        "Drawing.Fonts","isscriptable","iscclosure","debug.setconstant","debug.getprotos","lz4compress",
        "getscripts","isfolder","sethiddenproperty","getthreadidentity","readfile","getscriptclosure",
        "delfolder","setscriptable","Drawing.new","debug.getupvalues","hookmetamethod","debug.getproto",
        "getrunningscripts","checkcaller","debug.setupvalue","setrawmetatable","gethiddenproperty","writefile",
        "setrenderproperty","getnamecallmethod","isfile","fireclickdetector","getnilinstances","getcustomasset",
        "islclosure","loadstring","cache.iscached","cache.invalidate","cloneref","cache.replace","getgc",
        "compareinstances","base64_encode","getrenv","hookfunction","debug.getupvalue","setreadonly",
        "getloadedmodules","debug.getinfo","fireproximityprompt","WebSocket.connect","listfiles","gethui",
        "isreadonly","getrenderproperty","lz4decompress","appendfile","loadfile","getinstances","isexecutorclosure",
        "getcallbackvalue","getfunctionhash","replicatesignal","cleardrawcache","decompile","filtergc",
        "identifyexecutor","getscripthash","firesignal","firetouchinterest","debug.setstack","isrenderobj",
        "getcallingscript","debug.getstack","getsenv","clonefunction","debug.getconstant","getgenv","newcclosure",
        "base64_decode","debug.getconstants","getconnections","restorefunction"
    }
    local available, unavailable = {}, {}
    for _, funcName in ipairs(functionsToCheck) do
        local s = pcall(function()
            if funcName:find("%.") then
                local parts = funcName:split("%.")
                local obj = _G
                for i, p in ipairs(parts) do
                    if i == #parts then
                        if obj[p] ~= nil then return true end
                    else
                        obj = obj[p]
                        if obj == nil then return false end
                    end
                end
            else
                return _G[funcName] ~= nil
            end
        end)
        if s then table.insert(available, funcName) else table.insert(unavailable, funcName) end
    end
    return available, unavailable
end

function Core.SetupAntiBanKick(notificationCallback)
    local mt = getrawmetatable(game)
    if mt then
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" or method == "kick" then
                if notificationCallback then notificationCallback("ANTI-KICK", "Kick attempt blocked", 3, 7733960981) end
                return nil
            end
            if method == "Ban" or method == "ban" then
                if notificationCallback then notificationCallback("ANTI-BAN", "Ban attempt blocked", 3, 7733960981) end
                return nil
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end
    if notificationCallback then notificationCallback("PROTECTION", "Anti-Ban/Anti-Kick enabled", 3, 7733960981) end
end

function Core.SaveCoordinates()
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local pos = rootPart.Position
        local txt = string.format("X: %.2f, Y: %.2f, Z: %.2f", pos.X, pos.Y, pos.Z)
        if not isfolder("MegaHack") then makefolder("MegaHack") end
        writefile("MegaHack/coordinates.txt", txt)
        return txt
    else
        return nil, "No HumanoidRootPart found"
    end
end

function Core.TeleportToCoordinates()
    if isfile("MegaHack/coordinates.txt") then
        local txt = readfile("MegaHack/coordinates.txt")
        local x, y, z = txt:match("X: ([%d%.]+), Y: ([%d%.]+), Z: ([%d%.]+)")
        if x and y and z then
            local character = player.Character or player.CharacterAdded:Wait()
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
                return true
            end
        end
    end
    return false
end

Core.OnNotification = nil

return Core
