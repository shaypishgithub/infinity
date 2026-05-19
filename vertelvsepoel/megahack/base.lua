-- ══════════════════════════════════════════════════════════════════
--  base.lua  —  Database manifest + game icon registry
--  NEW: gameIcons table maps categoryName → Roblox PlaceId
--       Used by the "Games" virtual tab for lazy-loaded thumbnails
-- ══════════════════════════════════════════════════════════════════
return {
    baseUrl = "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/vertelvsepoel/megahack/base",

    -- ─── Script categories ────────────────────────────────────────
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
    },

    -- ─── Game icon PlaceIds ────────────────────────────────────────
    --  These are used by the "Games" sidebar tab to show game thumbnails.
    --  Key  = exact categoryName from `categories` above
    --  Value = Roblox PlaceId (integer) for MarketplaceService thumbnail
    gameIcons = {
        Brookhaven       = 4924922222,
        Evade            = 9872472334,
        MM2              = 142823291,
        BloxFruit        = 2753915549,
        BladeBall        = 13772394625,
        TowerOfHell      = 1962086868,
        AdoptMe          = 920587237,
        GrowGarden       = 126884695524458,
        NaturalDisaster  = 189707,
        RagdollEngine    = 8127455541,
        IKEA3008         = 8605792859,
        Rivals           = 17625359962,
        FORSAKEN         = 12884727963,
        LootUp           = 16067784268,
        DuelsMVS         = 107370089,
        ViolenceDistrict = 4465734,
        Night            = 6516141723,
        StealBrainRoot   = 1538240503,
    },
}
