-- ══════════════════════════════════════════════════════════════════
-- base.lua — Database manifest + game icon registry + Image ID Generator
-- ══════════════════════════════════════════════════════════════════

local database = {
    baseUrl = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/base",
    
    -- ─── Script categories ────────────────────────────────────────
   categories = {
    Brookhaven = "brookhaven.lua",
    Evade = "evade.lua",
    MM2 = "mm2.lua",
    MegaHack = "megapizda.lua",
    Hacks = "hacks.lua",
    Admins = "admin.lua",
    Animations = "animation.lua",
    FE = "fe.lua",
    RagdollEngine = "ragdoll.lua",
    NaturalDisaster = "naturaldisaster.lua",
    BloxFruit = "bloxfruit.lua",
    BladeBall = "bladeball.lua",
    StealBrainRoot = "stealbrainroot.lua",
    TowerOfHell = "tower.lua",
    AdoptMe = "adoptme.lua",
    GrowGarden = "growgarden.lua",
    Night = "night.lua",
    Weird = "weird.lua",
    DuelsMVS = "duelsmvs.lua",
    ViolenceDistrict = "violencedistrict.lua",
    IKEA3008 = "3008.lua",
    Rivals = "rivals.lua",
    FORSAKEN = "forsaken.lua",
    LootUp = "lootup.lua",
    Vertelevsepoel = "vertelevsepoel.lua",
    PetSimulatorX = "petsimx.lua",

    -- ==================== НОВЫЕ КАТЕГОРИИ ====================

    Arsenal = "arsenal.lua",
    PhantomForces = "phantomforces.lua",
    DaHood = "dahood.lua",
    BedWars = "bedwars.lua",
    Jailbreak = "jailbreak.lua",
    Doors = "doors.lua",
    KingLegacy = "kinglegacy.lua",
    AnimeDefenders = "animedefenders.lua",
    SolRNG = "solsrng.lua",
    Fisch = "fisch.lua",
    DressToImpress = "dresstoimpress.lua",
    RoyaleHigh = "royalehigh.lua",
    StrongestBattlegrounds = "strongestbattlegrounds.lua",
    CombatWarriors = "combatwarriors.lua",
    MuscleLegends = "musclelegends.lua",
    DragonAdventures = "dragonadventures.lua",
    PetSimulator99 = "petsim99.lua",
    MurderMystery2 = "mm2.lua",           -- уже есть, но для ясности
    CounterBlox = "counterblox.lua",
    Banana = "banana.lua",
    DandysWorld = "dandysworld.lua",
    Pressure = "pressure.lua",
    Regretevator = "regretevator.lua",
    BladeBall = "bladeball.lua",          -- уже есть
    BrookhavenRP = "brookhaven.lua",      -- уже есть
        
    Universal = "universal.lua",
    ScriptsHub = "scripthub.lua",
    Tycoons = "tycoons.lua",
    Simulator = "simulator.lua",
    Horror = "horror.lua",
    Fighting = "fighting.lua",
    Obby = "obby.lua",
    RPG = "rpg.lua",
    Racing = "racing.lua",
    PrisonLife = "prisonlife.lua",
    Frontlines = "frontlines.lua",
    Specter = "specter.lua",
    VibeStation = "vibestation.lua",
    Interliminality = "interliminality.lua",
    BreakIn2 = "breakin2.lua",
    SkibidiToilet = "skibiditoilet.lua",
    GrimaceShake = "grimaceshake.lua",   -- мемные
},
    -- ─── Game icon PlaceIds ────────────────────────────────────────
    gameIcons = {
        Brookhaven = 93652827298808,
        Evade = 9872472334,
        MM2 = 142823291,
        BloxFruit = 135853221608210,
        BladeBall = 13772394625,
        TowerOfHell = 1962086868,
        AdoptMe = 121696858921601,
        GrowGarden = 136490021973475,
        NaturalDisaster = 189707,
        RagdollEngine = 8127455541,
        IKEA3008 = 8605792859,
        Rivals = 17625359962,
        FORSAKEN = 12884727963,
        LootUp = 16067784268,
        DuelsMVS = 107370089,
        ViolenceDistrict = 4465734,
        Night = 6516141723,
        StealBrainRoot = 1538240503,
        Admins = 135286097425026,
        MegaHack = 74418885847818,
        Animations = 92241142143654,
        Vertelevsepoel = 104146829885606,
        PetSimulatorX = 93652827298808,
    },
    
    -- ─── Динамическая таблица для Image ID ──────────────────────────
    imageIds = {},
}

-- ──────────────────────────────────────────────────────────────────
-- ФУНКЦИИ ДЛЯ РАБОТЫ С ИКОНКАМИ (МЕТОДЫ)
-- ──────────────────────────────────────────────────────────────────

function database:GetImageIdFast(categoryName, size)
    local placeId = self.gameIcons[categoryName]
    if not placeId then return nil end
    
    local imageSize = size or 150
    return string.format("rbxthumb://type=Asset&id=%s&w=%d&h=%d", tostring(placeId), imageSize, imageSize)
end

local MarketplaceService = game:GetService("MarketplaceService")
function database:GetOriginalAssetId(categoryName)
    local placeId = self.gameIcons[categoryName]
    if not placeId then return nil end
    
    local success, assetInfo = pcall(function()
        return MarketplaceService:GetProductInfo(placeId, Enum.InfoType.Asset)
    end)
    
    if success and assetInfo and assetInfo.IconImageAssetId then
        return "rbxassetid://" .. tostring(assetInfo.IconImageAssetId)
    else
        return "rbxasset://textures/ui/GuiImagePlaceholder.png" 
    end
end

-- Автоматически заполняем таблицу imageIds быстрыми ссылками
for category, _ in pairs(database.gameIcons) do
    database.imageIds[category] = database:GetImageIdFast(category, 150)
end

return database
