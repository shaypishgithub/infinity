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
    },
    
    -- ─── Game icon PlaceIds ────────────────────────────────────────
    gameIcons = {
        Brookhaven = 10023132409,
        Evade = 9872472334,
        MM2 = 142823291,
        BloxFruit = 2753915549,
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
    },
    
    -- ─── Динамическая таблица для Image ID ──────────────────────────
    -- Сюда запишутся готовые ссылки на изображения после вызова функций
    imageIds = {},
}

-- ──────────────────────────────────────────────────────────────────
-- ФУНКЦИИ ДЛЯ РАБОТЫ С ИКОНКАМИ (МЕТОДЫ)
-- ──────────────────────────────────────────────────────────────────

-- Метод 1: Быстрый способ (Генерирует rbxthumb ссылку для UI)
-- Размер иконки можно передать вторым аргументом (по умолчанию 150x150)
function database:GetImageIdFast(categoryName, size)
    local placeId = self.gameIcons[categoryName]
    if not placeId then return nil end
    
    local imageSize = size or 150
    -- Возвращает готовый ID, который кушает любой ImageLabel.Image в Roblox
    return string.format("rbxthumb://type=Asset&id=%s&w=%d&h=%d", tostring(placeId), imageSize, imageSize)
end

-- Метод 2: Продвинутый способ через MarketplaceService (Получает оригинальный AssetID картинки)
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
        -- Возвращает иконку-заглушку Roblox, если у игры нет иконки или произошла ошибка запроса
        return "rbxasset://textures/ui/GuiImagePlaceholder.png" 
    end
end

-- Автоматически заполняем таблицу imageIds быстрыми ссылками при инициализации скрипта
for category, _ in pairs(database.gameIcons) do
    database.imageIds[category] = database:GetImageIdFast(category, 150)
end

return database
