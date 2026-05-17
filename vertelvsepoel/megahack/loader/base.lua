-- Вставляй сюда свой грязный текст
local source_code = [[
return {
    baseUrl = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/base",


    categories = {
        Brookhaven       = "brookhaven.lua",
        Evade            = "evade.lua",
        MM2              = "mm2.lua",
        MegaHack         = "megapizda.lua",
        Hacks            = "hacks.lua",
        Admins           = "admin.lua",
        Animations       = "animation.lua",
        FE               = "fe.lua",
        RagdollEngine    = "ragdoll.lua",
        NaturalDisaster  = "naturaldisaster.lua",
        BloxFruit        = "bloxfruit.lua",
        BladeBall        = "bladeball.lua",
        StealBrainRoot   = "stealbrainroot.lua",
        TowerOfHell      = "tower.lua",
        AdoptMe          = "adoptme.lua",
        GrowGarden       = "growgarden.lua",
        Night            = "night.lua",
        Weird            = "weird.lua",
        DuelsMVS         = "duelsmvs.lua",
        ViolenceDistrict = "violencedistrict.lua",
        IKEA3008         = "3008.lua",
        Rivals           = "rivals.lua",
        FORSAKEN         = "forsaken.lua",
        LootUp           = "lootup.lua",
   
    }
}
]]

-- Функция для выравнивания и сортировки
local function sortAndAlignLua(text)
    -- Изолируем то, что находится внутри categories = { ... }
    local pattern = "(categories%s*=%s*{)(.-)(})"
    local header, body, footer = text:match(pattern)
    
    if not body then return "Ошибка: Блок categories не найден." end
    
    local lines = {}
    local max_key_len = 0
    
    -- Парсим строки, вытаскиваем ключ и значение
    for line in body:gmatch("[^\r\n]+") do
        local key, val = line:match("^%s*([%w_]+)%s*=%s*(.-),?%s*$")
        if key and val then
            table.insert(lines, {key = key, val = val})
            if #key > max_key_len then
                max_key_len = #key
            end
        end
    end
    
    -- Сортируем по алфавиту
    table.sort(lines, function(a, b)
        return a.key:lower() < b.key:lower()
    end)
    
    -- Собираем выровненные строки обратно
    local formatted_lines = {}
    for _, item in ipairs(lines) do
        -- Дописываем пробелы к ключу для выравнивания
        local padding = string.rep(" ", max_key_len - #item.key)
        table.insert(formatted_lines, string.format("        %s%s = %s,", item.key, padding, item.val))
    end
    
    -- Соединяем всё в кучу
    local new_body = "\n" .. table.concat(formatted_lines, "\n") .. "\n    "
    local result = text:gsub(pattern, header .. new_body .. footer)
    
    return result
end

-- Выводим готовый результат в консоль
print(sortAndAlignLua(source_code))
