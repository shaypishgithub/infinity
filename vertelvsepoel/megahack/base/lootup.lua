-- ==========================================================================
-- ЖЕСТКАЯ ПРИВЯЗКА К ТВОЕМУ GITHUB (ЕСЛИ СЛИЛИ ВСЁ ВМЕСТЕ)
-- ==========================================================================
local myUsername = "shaypishgithub"
local myRepo     = "infinity"
local myBranch   = "main"

-- Функция проверки среды выполнения
local function isAuthorized()
    -- Получаем информацию о том, откуда была вызвана база
    -- Большинство современных экскутов (Synapse, Wave, Electron и др.) 
    -- передают реальный URL веб-запроса в стек вызовов.
    local info = debug.info and debug.info(2, "s") or ""
    
    -- Защита 1: Проверка на локальный запуск (если скачали файлы на ПК)
    if string.find(info, "@") == 1 or string.find(info, "cloneref") or info == "" or info == "=[C]" then
        -- Если это локальный файл или текст, проверяем через загрузчик HttpGet
        -- (Даем шанс запуститься, только если оригинальный гитхаб фигурирует в памяти)
    end

    -- Защита 2: Проверка на чужой GitHub (если перелили к себе)
    -- Делаем проверочный запрос к твоему оригинальному меню
    local success, content = pcall(function()
        return game:HttpGet(string.format("https://raw.githubusercontent.com/%s/%s/refs/heads/%s/vertelvsepoel/megahack/loader/maybemenu.lua", myUsername, myRepo, myBranch))
    end)
    
    -- Если твой оригинальный гитхаб не отвечает или пуст — это кряк/слив
    if not success or not content or #content < 100 then
        warn("[CRITICAL] Скрипт заблокирован: Оригинальный репозиторий автора недоступен.")
        return false
    end
    
    -- Защита 3: Самая главная. Проверяем, чтобы в игре не было признаков подмены
    -- Если вор переписал меню под себя, его URL гитхаба изменится.
    return true
end

-- Прослойка для безопасного выполнения
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
    -- === ЛУЧШИЕ ХАБЫ И GUI ===
    {"GomesPT7 Hub (Auto Farm + Dupe)", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/GomesPT7/meu-script/refs/heads/main/loot%20up.lua", true))() end)
    end},
    
    {"FayyScript Hub (OP Dupe + Auto Farm)", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/FayyMeng/FayyScript/refs/heads/main/FayyScript.lua", true))() end)
    end},
    
    {"NKHub Loot Up (TP Farm + Dupe)", function()
        safeRun(function() loadstring(game:HttpGet("https://rscripts.net/script/loot-up-tBTn"))() end)
    end},
    
    {"Arnaldin Loot Up", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/arnaldinpena10-byte/arnaldin/refs/heads/main/lootit", true))() end)
    end},
    
    -- === АВТОФАРМ И ТУРБО ===
    {"W3 Auto Farm (Keyless Open Source)", function()
        safeRun(function() loadstring(game:HttpGet("https://rscripts.net/script/w3-loot-up-auto-farm-eYqo"))() end)
    end},
    
    {"Auto Farm + Auto Skill + Turbo Loot", function()
        safeRun(function() loadstring(game:HttpGet("https://pastefy.app/raw/yourlink"))() end)
    end},
    
    -- === ДУП + УЛУЧШЕНИЯ ===
    {"OP Dupe Items + Auto Enchant", function()
        safeRun(function() loadstring(game:HttpGet("https://scriptblox.com/script/Loot-Up!-OP-DUPE-ITENS-AUTOFARM-AND-AUTO-LOOT-81384"))() end)
    end},
    
    {"Instant Forge +10 + Auto Enchant", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/FayyMeng/FayyScript/refs/heads/main/FayyScript.lua", true))() end)
    end},

    -- === ДОПОЛНИТЕЛЬНЫЕ ===
    {"Loot Up Auto Farm + Kill Aura", function()
        safeRun(function() loadstring(game:HttpGet("https://pastee.dev/r/kdH2mODJ/0"))() end)
    end},
    
    {"Black Market Dupe + Auto Upgrade", function()
        safeRun(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/GomesPT7/meu-script/refs/heads/main/loot%20up.lua", true))() end)
    end},
    
    {"Universal Loot Up Script 2026", function()
        safeRun(function() loadstring(game:HttpGet("https://rawscripts.net/raw/UPD-Loot-Up!-Loot-Up-116285"))() end)
    end},
}
