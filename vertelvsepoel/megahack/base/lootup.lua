-- Ссылка на оригинальный файл меню
local officialMenuURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/loader/maybemenu.lua"

-- Проверяем оригинальный репозиторий ОДИН раз при запуске базы
local isVerified = false
local success, response = pcall(function()
    return game:HttpGet(officialMenuURL)
end)

-- Если в ответе Гитхаба есть код (например, ключевые слова твоего меню)
if success and response and string.find(response, "function") then
    isVerified = true
else
    warn("[CRITICAL BLOCK] База не смогла подтвердить оригинальный репозиторий MegaHack!")
    return {} -- Возвращаем пустоту, полностью блокируя интерфейс читера
end

-- Если проверка пройдена, отдаем рабочую базу скриптов
return {
    -- === ЛУЧШИЕ ХАБЫ И GUI ===
    {"GomesPT7 Hub (Auto Farm + Dupe)", function()
        if not isVerified then return end
        loadstring(game:HttpGet("https://raw.githubusercontent.com/GomesPT7/meu-script/refs/heads/main/loot%20up.lua", true))()
    end},
    
    {"FayyScript Hub (OP Dupe + Auto Farm)", function()
        if not isVerified then return end
        loadstring(game:HttpGet("https://raw.githubusercontent.com/FayyMeng/FayyScript/refs/heads/main/FayyScript.lua", true))()
    end},
    
    {"NKHub Loot Up (TP Farm + Dupe)", function()
        if not isVerified then return end
        loadstring(game:HttpGet("https://rscripts.net/script/loot-up-tBTn"))()
    end},
    
    {"Arnaldin Loot Up", function()
        if not isVerified then return end
        loadstring(game:HttpGet("https://raw.githubusercontent.com/arnaldinpena10-byte/arnaldin/refs/heads/main/lootit", true))()
    end},
    
    -- === АВТОФАРМ И ТУРБО ===
    {"W3 Auto Farm (Keyless Open Source)", function()
        if not isVerified then return end
        loadstring(game:HttpGet("https://rscripts.net/script/w3-loot-up-auto-farm-eYqo"))()
    end},
    
    {"Auto Farm + Auto Skill + Turbo Loot", function()
        if not isVerified then return end
        loadstring(game:HttpGet("https://pastefy.app/raw/yourlink"))()
    end},
    
    -- === ДУП + УЛУЧШЕНИЯ ===
    {"OP Dupe Items + Auto Enchant", function()
        if not isVerified then return end
        loadstring(game:HttpGet("https://scriptblox.com/script/Loot-Up!-OP-DUPE-ITENS-AUTOFARM-AND-AUTO-LOOT-81384"))()
    end},
    
    {"Instant Forge +10 + Auto Enchant", function()
        if not isVerified then return end
        loadstring(game:HttpGet("https://raw.githubusercontent.com/FayyMeng/FayyScript/refs/heads/main/FayyScript.lua", true))()
    end},

    -- === ДОПОЛНИТЕЛЬНЫЕ ===
    {"Loot Up Auto Farm + Kill Aura", function()
        if not isVerified then return end
        loadstring(game:HttpGet("https://pastee.dev/r/kdH2mODJ/0"))()
    end},
    
    {"Black Market Dupe + Auto Upgrade", function()
        if not isVerified then return end
        loadstring(game:HttpGet("https://raw.githubusercontent.com/GomesPT7/meu-script/refs/heads/main/loot%20up.lua", true))()
    end},
    
    {"Universal Loot Up Script 2026", function()
        if not isVerified then return end
        loadstring(game:HttpGet("https://rawscripts.net/raw/UPD-Loot-Up!-Loot-Up-116285"))()
    end},
}
