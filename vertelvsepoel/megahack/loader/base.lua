local data = {
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

-- Функция автоматического выравнивания и сортировки
local function exportSortedTable(tbl)
    local keys = {}
    local maxKeyLen = 0
    
    -- Собираем ключи и ищем самый длинный для выравнивания
    for k in pairs(tbl.categories) do
        table.insert(keys, k)
        if #k > maxKeyLen then maxKeyLen = #k end
    end
    
    -- Сортируем ключи по алфавиту (A-Z)
    table.sort(keys)
    
    -- Собираем финальную строку
    local result = "return {\n"
    result = result .. string.format('    baseUrl = "%s",\n\n', tbl.baseUrl)
    result = result .. "    categories = {\n"
    
    for _, key in ipairs(keys) do
        local value = tbl.categories[key]
        -- Считаем сколько пробелов нужно для ровного столбца знаков "="
        local padding = string.rep(" ", maxKeyLen - #key) 
        result = result .. string.format('        %s%s = "%s",\n', key, padding, value)
    end
    
    result = result .. "    }\n}"
    return result
end

-- Выводим идеально выровненный и отсортированный результат в консоль
print(exportSortedTable(data))
