-- ==========================================================================
-- ЖЕСТКАЯ ПРИВЯЗКА К ТВОЕМУ GITHUB (ПРОТИВ КРАЖИ И ПОЛНОГО КОПИРОВАНИЯ)
-- ==========================================================================
local myUsername = "shaypishgithub"
local myRepo     = "infinity"
local myBranch   = "main"

-- Функция проверки подлинности среды
local function isAuthorized()
    -- Проверка 1: Запрашиваем оригинальный файл твоего меню с твоего GitHub
    local success, content = pcall(function()
        return game:HttpGet(string.format("https://raw.githubusercontent.com/%s/%s/refs/heads/%s/vertelvsepoel/megahack/loader/maybemenu.lua", myUsername, myRepo, myBranch))
    end)
    
    -- Если твой репозиторий удален, переименован или недоступен — жесткий блок
    if not success or not content or #content < 100 then
        warn("[CRITICAL] Скрипт заблокирован: Оригинальный репозиторий автора недоступен.")
        return false
    end
    
    return true
end

-- Прослойка-контроллер для безопасного запуска
local function safeRun(loadstringCall)
    if isAuthorized() then
        loadstringCall()
    else
        print("-------------------------------------------------------")
        warn("[MEGAHACK BLOCK] ОБНАРУЖЕНА КРАЖА ИЛИ ИЗМЕНЕНИЕ ИСХОДНОГО КОДА!")
        print("Этот скрипт принадлежит: github.com/" .. myUsername)
        print("-------------------------------------------------------")
    end
end

return {
    {"Made by me MM2 (Custom)", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Ilikemen12/MadeByMe/main/MM2.lua"))() end)
    end},
    {"HoneyLua Hub", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ThatSick/HoneyLua/refs/heads/main/Loader.luau"))() end)
    end},
    {"HoneyLua (Pastefy Alternative)", function()
        safeRun(function() loadstring(game:HttpGet("https://pastefy.app/dbESII9x/raw"))() end)
    end},
    {"Universe Hub", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Dext9000/UniverseHub/main/Main.lua"))() end)
    end},
    {"Project WD (Best AutoFarm)", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EvoV2/ProjectWD/main/Main.lua"))() end)
    end},
    {"Coco Hub", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/MarsQQ/CocoHub/master/CocoHub.lua", true))() end)
    end},
    {"Vynixius MM2", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Vynixius/main/Loader.lua"))() end)
    end},
    {"Lumin.rest Hub - Best", function()
        safeRun(function() loadstring(game:HttpGet("https://lumin.rest/script"))() end)
    end},
    {"Vertex Hub (SmokingScripts)", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.smokingscripts.org/vertex.lua"))() end)
    end},
    {"Vertex Hub (New 2026)", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/vertex-peak/vertex/refs/heads/main/loadstring"))() end)
    end},
    {"Eclipse Hub", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Doggo-cryto/EclipseMM2/master/Script", true))() end)
    end},
    {"Revenge Hub", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Revenge-Hub-Roblox/Scripts/refs/heads/main/mm2.lua", true))() end)
    end},
    {"Peachy Hub (Junkie Dev)", function()
        safeRun(function() loadstring(game:HttpGet("https://api.junkie-development.de/api/v1/luascripts/public/d37435894c260e0200d7c0cee1c5a4aea45602edb3ee1fa3c37726e2fe857ad5/download"))() end)
    end},
    {"Forge Hub", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Skzuppy/forge-hub/main/loader.lua"))() end)
    end},
    {"YARHM", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Joystickplays/psychic-octo-invention/main/yarhm.lua", true))() end)
    end},
    {"Mars Hub", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/1andonlymars/MarsHub/main/MM2"))() end)
    end},
    {"Xenith Hub", function()
        safeRun(function() loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua"))() end)
    end},
    {"Ash Labs", function()
        safeRun(function() loadstring(game:HttpGet("https://ashlabs.me/api/game?name=Murder-Mystery-2.lua", true))() end)
    end},
    {"Thunder Hub (SnapSanix)", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Roman34296589/SnapSanixHUB/refs/heads/main/SnapSanixHUB.lua"))() end)
    end},
    {"SNT-HUB (Snowt-Team)", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Snowt-Team/SNT-HUB/refs/heads/main/MurderMystery2.txt"))() end)
    end},
    {"NoCapital2 AutoFarm", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/NoCapital2/MM2Autofarm/main/script"))() end)
    end},
    {"Phoenix MM2", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Relyz1993/Scripts/refs/heads/main/MurderMystery2.lua"))() end)
    end},
    {"Goiaba.lua Hub", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Goiabalua/Goiaba.lua-Hub/refs/heads/main/Loader.lua"))() end)
    end},
    {"Horizon Hub", function()
        safeRun(function() loadstring(game:HttpGet("https://pastefy.app/wwfom1bX/raw", true))() end)
    end},
    {"SolixHub", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua"))() end)
    end},
    {"Megahack AutoFarm", function()
        safeRun(function() loadstring(game:HttpGet("https://pastefy.app/RDJ2E5jq/raw", true))() end)
    end},
}
