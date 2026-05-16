-- Адрес оригинального меню, которое должно быть запущено
local officialMenuURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/loader/maybemenu.lua"

-- Функция проверки
local function isMenuValid()
    -- 1. Проверяем наличие ключа в памяти
    if _G.MegaHackOwnerKey ~= "Infinity_MegaHack_Official_2026" then
        warn("[BLOCK] База заблокирована: секретный ключ меню отсутствует или неверен.")
        return false
    end

    -- 2. Защита от подмены: проверяем, откуда исполнитель (executor) загрузил меню.
    -- Большинство современных экскутов пишут источник в функции getfenv или через отладку.
    -- Дополнительно проверяем, чтобы база не работала, если кто-то пытается подделать окружение.
    local scriptInfo = debug.info and debug.info(2, "s") or ""
    if string.find(scriptInfo, "ScreenGui") or string.find(scriptInfo, "PlayerGui") then
        -- Если меню пытаются запустить как обычный локальный GUI скрипт в обход загрузчика
        warn("[BLOCK] Попытка обхода защиты!")
        return false
    end

    return true
end

-- Прослойка для безопасного запуска loadstring
local function safeExecute(targetFunction)
    if isMenuValid() then
        targetFunction()
    else
        -- Если проверка не прошла, выводим ошибку в F9 и ничего не запускаем
        print("--------------------------------------------------")
        warn("[CRITICAL] МЕНЮ СКОПИРОВАНО ИЛИ ИЗМЕНЕНО!")
        warn("[INFO] Пожалуйста, используйте официальную версию:")
        print(officialMenuURL)
        print("--------------------------------------------------")
    end
end

return {
    -- === ЛУЧШИЕ ХАБЫ И GUI ===
    {"GomesPT7 Hub (Auto Farm + Dupe)", function()
        safeExecute(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/GomesPT7/meu-script/refs/heads/main/loot%20up.lua", true))()
        end)
    end},
    
    {"FayyScript Hub (OP Dupe + Auto Farm)", function()
        safeExecute(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/FayyMeng/FayyScript/refs/heads/main/FayyScript.lua", true))()
        end)
    end},
    
    {"NKHub Loot Up (TP Farm + Dupe)", function()
        safeExecute(function()
            loadstring(game:HttpGet("https://rscripts.net/script/loot-up-tBTn"))()
        end)
    end},
    
    {"Arnaldin Loot Up", function()
        safeExecute(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/arnaldinpena10-byte/arnaldin/refs/heads/main/lootit", true))()
        end)
    end},
    
    -- === АВТОФАРМ И ТУРБО ===
    {"W3 Auto Farm (Keyless Open Source)", function()
        safeExecute(function()
            loadstring(game:HttpGet("https://rscripts.net/script/w3-loot-up-auto-farm-eYqo"))()
        end)
    end},
    
    {"Auto Farm + Auto Skill + Turbo Loot", function()
        safeExecute(function()
            loadstring(game:HttpGet("https://pastefy.app/raw/yourlink"))()
        end)
    end},
    
    -- === ДУП + УЛУЧШЕНИЯ ===
    {"OP Dupe Items + Auto Enchant", function()
        safeExecute(function()
            loadstring(game:HttpGet("https://scriptblox.com/script/Loot-Up!-OP-DUPE-ITENS-AUTOFARM-AND-AUTO-LOOT-81384"))()
        end)
    end},
    
    {"Instant Forge +10 + Auto Enchant", function()
        safeExecute(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/FayyMeng/FayyScript/refs/heads/main/FayyScript.lua", true))()
        end)
    end},

    -- === ДОПОЛНИТЕЛЬНЫЕ ===
    {"Loot Up Auto Farm + Kill Aura", function()
        safeExecute(function()
            loadstring(game:HttpGet("https://pastee.dev/r/kdH2mODJ/0"))()
        end)
    end},
    
    {"Black Market Dupe + Auto Upgrade", function()
        safeExecute(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/GomesPT7/meu-script/refs/heads/main/loot%20up.lua", true))()
        end)
    end},
    
    {"Universal Loot Up Script 2026", function()
        safeExecute(function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/UPD-Loot-Up!-Loot-Up-116285"))()
        end)
    end},
}
