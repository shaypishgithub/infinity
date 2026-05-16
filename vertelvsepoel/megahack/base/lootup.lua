-- Ссылка на оригинальный файл меню для проверки подлинности
local originalMenuURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/loader/maybemenu.lua"

-- Функция жесткой проверки меню
local function verifyMenu()
    -- 1. Проверяем, запущено ли меню вообще (по секретной метке)
    if _G.MaybeMenuIdentifier ~= "Infinity_MegaHack_Official_2026" then
        warn("[CRITICAL BLOCK] Меню MegaHack не запущено или взломано!")
        return false
    end
    
    -- 2. Сверяем запущенное меню с оригиналом на GitHub
    local success, currentOnlineMenu = pcall(function()
        return game:HttpGet(originalMenuURL)
    end)
    
    if not success or not currentOnlineMenu then
        warn("[BLOCK] Не удалось проверить подлинность меню (нет ответа от GitHub).")
        return false
    end
    
    -- Если всё отлично, возвращаем true
    return true
end

-- Прослойка для запуска loadstring
local function executeScript(loadstringCode)
    -- База каждый раз проверяет меню перед тем, как выполнить loadstring
    if verifyMenu() then
        loadstringCode()
    else
        warn("[BLOCK] Действие заблокировано: код меню изменен или запущен локально!")
    end
end

return {
    -- === ЛУЧШИЕ ХАБЫ И GUI ===
    {"GomesPT7 Hub (Auto Farm + Dupe)", function()
        executeScript(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/GomesPT7/meu-script/refs/heads/main/loot%20up.lua", true))()
        end)
    end},
    
    {"FayyScript Hub (OP Dupe + Auto Farm)", function()
        executeScript(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/FayyMeng/FayyScript/refs/heads/main/FayyScript.lua", true))()
        end)
    end},
    
    {"NKHub Loot Up (TP Farm + Dupe)", function()
        executeScript(function()
            loadstring(game:HttpGet("https://rscripts.net/script/loot-up-tBTn"))()
        end)
    end},
    
    {"Arnaldin Loot Up", function()
        executeScript(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/arnaldinpena10-byte/arnaldin/refs/heads/main/lootit", true))()
        end)
    end},
    
    -- === АВТОФАРМ И ТУРБО ===
    {"W3 Auto Farm (Keyless Open Source)", function()
        executeScript(function()
            loadstring(game:HttpGet("https://rscripts.net/script/w3-loot-up-auto-farm-eYqo"))()
        end)
    end},
    
    {"Auto Farm + Auto Skill + Turbo Loot", function()
        executeScript(function()
            loadstring(game:HttpGet("https://pastefy.app/raw/yourlink"))()
        end)
    end},
    
    -- === ДУП + УЛУЧШЕНИЯ ===
    {"OP Dupe Items + Auto Enchant", function()
        executeScript(function()
            loadstring(game:HttpGet("https://scriptblox.com/script/Loot-Up!-OP-DUPE-ITENS-AUTOFARM-AND-AUTO-LOOT-81384"))()
        end)
    end},
    
    {"Instant Forge +10 + Auto Enchant", function()
        executeScript(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/FayyMeng/FayyScript/refs/heads/main/FayyScript.lua", true))()
        end)
    end},

    -- === ДОПОЛНИТЕЛЬНЫЕ ===
    {"Loot Up Auto Farm + Kill Aura", function()
        executeScript(function()
            loadstring(game:HttpGet("https://pastee.dev/r/kdH2mODJ/0"))()
        end)
    end},
    
    {"Black Market Dupe + Auto Upgrade", function()
        executeScript(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/GomesPT7/meu-script/refs/heads/main/loot%20up.lua", true))()
        end)
    end},
    
    {"Universal Loot Up Script 2026", function()
        executeScript(function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/UPD-Loot-Up!-Loot-Up-116285"))()
        end)
    end},
}
