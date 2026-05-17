-- Исходный текст (ваша конфигурация)
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
}]]

-- Функция для сортировки и выравнивания кода
local function sort_and_align(text)
    -- Изолируем то, что находится внутри блока categories = { ... }
    local pattern = "(categories%s*=%s*{)(.-)(})"
    local header, body, footer = text:match(pattern)
    
    if not body then 
        return "Ошибка: Блок categories не найден." 
    end

    local pairs_list = {}
    local max_key_len = 0

    -- Парсим каждую строку внутри блока
    for line in body:gmatch("[^\r\n]+") do
        -- Ищем ключ и значение (отсекаем пробелы и запятые)
        local key, val = line:match("^%s*([%w_]+)%s*=%s*(.-),?%s*$")
        if key and val then
            table.insert(pairs_list, {key = key, val = val})
            if #key > max_key_len then
                max_key_len = #key
            end
        end
    end

    -- Сортируем таблицу по алфавиту ключей (A-Z)
    table.sort(pairs_list, function(a, b)
        return a.key:lower() < b.key:lower()
    end)

    -- Собираем отформатированные строки с нужным количеством пробелов
    local formatted_lines = {}
    for _, pair in ipairs(pairs_list) do
        -- Высчитываем сколько пробелов нужно добавить после ключа для выравнивания
        local padding = string.rep(" ", max_key_len - #pair.key)
        table.insert(formatted_lines, string.format("        %s%s = %s,", pair.key, padding, pair.val))
    end

    -- Соединяем строки обратно в один блок
    local new_body = "\n" .. table.concat(formatted_lines, "\n") .. "\n    "
    
    -- Собираем весь исходный текст назад, заменив старый блок на новый
    local result = text:gsub(pattern, header .. new_body .. footer, 1)
    return result
end

-- Запуск и вывод результата
local clean_code = sort_and_align(source_code)
print(clean_code)
