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

-- ФУНКЦИЯ ДЛЯ АВТОМАТИЧЕСКОЙ СОРТИРОВКИ И ПЕРЕБОРA (A-Z)
local function pairsByKeys(t)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, function(x, y) return x:lower() < y:lower() end) -- Сортировка без учета регистра
    local i = 0
    local iter = function ()
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter
end

-- Применяем автовыравниватель к категориям
data.sortedCategories = pairsByKeys

return data
