-- Адрес твоего оригинального меню на GitHub
local menuURL = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/loader/maybemenu.lua"

-- Получаем ключ защиты прямо из твоего онлайн-меню
local success, menuCode = pcall(function() return game:HttpGet(menuURL) end)
local secureKey = success and menuCode and string.sub(menuCode, 1, 30) or nil

-- Функция динамической расшифровки (работает только в ОЗУ)
local function decrypt(b64)
    if not secureKey or #secureKey < 5 then return function() warn("[BLOCK] Меню изменено или удалено!") end end
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    b64 = string.gsub(b64, '[^'..b..'=]', '')
    local dec = b64:gsub('.', function(x)
        if x == '=' then return '' end
        local r, f = '', (b:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0') end
        return r
    end):gsub('%d%d%d%d%d%d%d%d', function(x)
        local n = 0
        for i = 1, 8 do n = n + (x:sub(i, i) == '1' and 2^(8-i) or 0) end
        return string.char(n)
    end)
    local res = {}
    for i = 1, #dec do
        local k = string.byte(secureKey, (i - 1) % #secureKey + 1)
        table.insert(res, string.char(bit32.bxor(string.byte(dec, i), k)))
    end
    return table.concat(res)
end

local function run(c, r)
    local s, url = pcall(decrypt, c)
    if s and url and string.find(url, "http") then
        if r then loadstring(game:HttpGet(url, true))() else loadstring(game:HttpGet(url))() end
    else
        warn("[ERROR] Не удалось авторизовать базу данных скриптов.")
    end
end

-- База возвращает зашифрованную таблицу. Теперь воровать здесь нечего.
return {
    -- === ЛУЧШИЕ ХАБЫ И GUI ===
    {"GomesPT7 Hub (Auto Farm + Dupe)", function() run("ExIXExIXHwcfWFlSVgEEDwUfVgcXCQIIDwUeAAgIFVQLAggMABMGAg==", true) end},
    {"FayyScript Hub (OP Dupe + Auto Farm)", function() run("ExIXExIXHwcfWFlSVgEEDwUfVgcXDQUdBg0RFkUGDAEGDQUWAAgIFVQRAwkGBwY=", true) end},
    {"NKHub Loot Up (TP Farm + Dupe)", function() run("ExIXEwwXCR4LXVVdBAcCBxZfBxsYVFFbWwMXEQID") end},
    {"Arnaldin Loot Up", function() run("ExIXExIXHwcfWFlSVgEEDwUfVgcXCQIdBg0RFkUGDAEGCUUNDgYCDwIKFlQRAwkGBwY=", true) end},
    
    -- === АВТОФАРМ И ТУРБО ===
    {"W3 Auto Farm (Keyless Open Source)", function() run("ExIXEwwXCR4LXVVdBAcCBxZfBxseBlFbWwI6Bw0UFlQXAg0N") end},
    {"Auto Farm + Auto Skill + Turbo Loot", function() run("ExIXEwYdBxoLXVVdFwIdCl9fXhkGAwEBAg==") end},
    
    -- === ДУП + УЛУЧШЕНИЯ ===
    {"OP Dupe Items + Auto Enchant", function() run("ExIXEwcHDAEcX1VdBAcdBwJfWwscBw0RFkUGDAEHAwwRFUUMAQYJCl8WDRcNCwoCDAUMCwsOAhZUBwkCBQUX") end},
    {"Instant Forge +10 + Auto Enchant", function() run("ExIXExIXHwcfWFlSVgEEDwUfVgcXDQUdBg0RFkUGDAEGDQUWAAgIFVQRAwkGBwY=", true) end},

    -- === ДОПОЛНИТЕЛЬНЫЕ ===
    {"Loot Up Auto Farm + Kill Aura", function() run("ExIXEwYdCBofFlNdWloHGw==") end},
    {"Black Market Dupe + Auto Upgrade", function() run("ExIXExIXHwcfWFlSVgEEDwUfVgcXCQIIDwUeAAgIFVQLAggMABMGAg==", true) end},
    {"Universal Loot Up Script 2026", function() run("ExIXEwwdBxoLXVVdBwIHBhZfBhseCg8ID0UWDAsGBEUfBAIDBQAMFA==") end},
}
