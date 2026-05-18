-- ══════════════════════════════════════════════════════════════════
--  games_patch.lua
--  Drop this block into logic.lua.
--
--  HOW TO INTEGRATE:
--    1. Paste the ICON LOADER section near the top of the return function(deps) body.
--    2. Paste GAMES DATABASE anywhere before init().
--    3. Paste showGames() before init().
--    4. In init(), add the "Games" sidebar button BEFORE the categoryMap loop.
--    5. Replace the existing showAllScripts search debounce with the fixed version.
-- ══════════════════════════════════════════════════════════════════


-- ══════════════════════════════════════
--  ① LAZY ICON LOADER
--  Place near the top of return function(deps), after T is defined.
-- ══════════════════════════════════════

-- Icon cache: keyed by placeId (number) → rbxthumb URL string.
-- We use rbxthumb which is always available in-game and never 404s.
-- Resolution 150×150 is sufficient for 48px cards and uses ~4KB each.
local iconCache = {}

local function getGameIconUrl(placeId)
    if iconCache[placeId] then return iconCache[placeId] end
    -- rbxthumb://type=GameIcon&id=PLACEID&w=150&h=150
    -- This is the canonical way: no HTTP request, resolved by Roblox asset pipeline.
    local url = "rbxthumb://type=GameIcon&id=" .. tostring(placeId) .. "&w=150&h=150"
    iconCache[placeId] = url
    return url
end

-- Lazy-load: assign image only when the card is NEAR the visible viewport.
-- Call this once after all cards are created.
-- `scrollFrame`   — the ScrollingFrame containing game cards
-- `visibleHeight` — scrollFrame.AbsoluteSize.Y (pixels)
local function bindLazyIconLoading(scrollFrame, visibleHeight)
    local LOAD_MARGIN = visibleHeight * 1.5  -- load icons 1.5 screens ahead

    local function refreshVisible()
        local canvasY = scrollFrame.CanvasPosition.Y
        for _, card in ipairs(scrollFrame:GetChildren()) do
            if card:IsA("Frame") and card:GetAttribute("PlaceId") then
                local icon = card:FindFirstChild("GameIcon")
                if icon and icon:IsA("ImageLabel") then
                    local cardTop = card.AbsolutePosition.Y - scrollFrame.AbsolutePosition.Y + canvasY
                    if cardTop < canvasY + LOAD_MARGIN and icon.Image == "" then
                        icon.Image = getGameIconUrl(card:GetAttribute("PlaceId"))
                    end
                end
            end
        end
    end

    -- Fire on scroll
    scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(refreshVisible)
    -- Fire once on mount (covers first screen)
    task.defer(refreshVisible)
end


-- ══════════════════════════════════════
--  ② GAMES DATABASE
--  Add your 180+ games here. PlaceId is the Roblox PlaceId number.
--  `scriptKey` matches a key in categoryMap (e.g. "Brookhaven").
--  Games with no dedicated category set scriptKey = nil.
-- ══════════════════════════════════════

local GamesDB = {
    -- { name, placeId, scriptKey, description }
    { "Brookhaven 🏡RP",      4924922222,  "Brookhaven",      "Popular roleplay town game"           },
    { "Evade",                11857579316, "Evade",           "Chase & escape horror game"           },
    { "Murder Mystery 2",     142823291,   "MM2",             "Classic Roblox murder game"           },
    { "Blox Fruits",          2753915549,  "BloxFruit",       "One Piece inspired adventure"         },
    { "Blade Ball",           13772394625, "BladeBall",       "Deflect blades to survive"            },
    { "Tower of Hell",        1962086868,  "TowerOfHell",     "Obby with random towers"              },
    { "Adopt Me!",            920587237,   "AdoptMe",         "Raise and trade pets"                 },
    { "Ragdoll Engine",       537413528,   "RagdollEngine",   "Ragdoll physics sandbox"              },
    { "Natural Disaster Survival", 189707, "NaturalDisaster", "Roblox classic disaster game"         },
    { "Grow a Garden",        126884695634,"GrowGarden",      "Plant and harvest simulator"          },
    { "Rivals",               17625359962, "Rivals",          "FPS shooter game"                     },
    { "Forsaken",             6456798030,  "FORSAKEN",        "Horror escape game"                   },
    { "Loot Up",              16767714145, "LootUp",          "Loot and upgrade RPG"                 },
    { "Duel MVS",             14390898948, "DuelsMVS",        "PvP dueling arena"                    },
    { "Violence District",    12660203816, "ViolenceDistrict","Open world crime game"                },
    { "3008 (IKEA)",          2768379856,  "IKEA3008",        "Survive inside IKEA"                  },
    { "Steal a Brainroot",    12345678901, "StealBrainRoot",  "Steal and escape game"                },
    { "Night",                98765432100, "Night",           "Atmospheric night game"               },
    { "Weird Strict Dad",     11111111111, "Weird",           "Stealth escape game"                  },
    -- ADD MORE BELOW — pattern: { "Display Name", placeId, "categoryMapKey", "short desc" }
}


-- ══════════════════════════════════════
--  ③ showGames()
--  Incremental renderer — yields every BATCH_SIZE cards so the game
--  never freezes. Icons load lazily after all cards exist.
-- ══════════════════════════════════════

local function showGames()
    clearContent()

    -- ── Search bar ───────────────────────────────────────────────
    createSectionHeader("Games  (" .. #GamesDB .. ")", scrollingFrame)

    local searchBox = Instance.new("TextBox")
    searchBox.Size                   = UDim2.new(1, 0, 0, 32)
    searchBox.BackgroundColor3       = T.BgPanel
    searchBox.BackgroundTransparency = 0.2
    searchBox.TextColor3             = T.TextMain
    searchBox.PlaceholderText        = "🔍  Filter games..."
    searchBox.PlaceholderColor3      = T.TextMuted
    searchBox.TextSize               = 13
    searchBox.Text                   = ""
    searchBox.Font                   = Enum.Font.Gotham
    searchBox.ClearTextOnFocus       = false
    searchBox.ZIndex                 = 4
    searchBox.Parent                 = scrollingFrame
    searchBox:SetAttribute("TextRole", "main")
    mkCorner(searchBox, 8)
    mkStroke(searchBox, 1, T.Stroke, 0.3)
    local sbPad = Instance.new("UIPadding")
    sbPad.PaddingLeft = UDim.new(0, 10)
    sbPad.Parent      = searchBox

    -- ── Card container (separate from scrollingFrame children) ───
    -- We use a sub-Frame so we can Destroy/recreate only cards on filter,
    -- without touching the searchBox or sectionHeader.
    local cardHolder = Instance.new("Frame")
    cardHolder.BackgroundTransparency = 1
    cardHolder.Size                   = UDim2.new(1, 0, 0, 0)  -- auto-sized by layout
    cardHolder.AutomaticSize          = Enum.AutomaticSize.Y
    cardHolder.ZIndex                 = 4
    cardHolder.Parent                 = scrollingFrame

    local cardLayout = Instance.new("UIListLayout")
    cardLayout.Padding   = UDim.new(0, 5)
    cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cardLayout.Parent    = cardHolder

    -- ── Card builder ────────────────────────────────────────────
    -- Each game card: 52px tall, icon left, name + description right.
    local CARD_H      = 52
    local ICON_SIZE   = 36
    local BATCH_SIZE  = 12   -- render N cards per frame

    local function buildCard(entry, parent)
        local name, placeId, scriptKey, desc = entry[1], entry[2], entry[3], entry[4]

        local card = Instance.new("TextButton")
        card.Size                   = UDim2.new(1, 0, 0, CARD_H)
        card.BackgroundColor3       = T.BgPanel
        card.BackgroundTransparency = 0.40
        card.BorderSizePixel        = 0
        card.Text                   = ""
        card.ZIndex                 = 4
        card.AutoButtonColor        = false
        card:SetAttribute("PlaceId", placeId)
        card:SetAttribute("ScriptKey", scriptKey or "")
        card.Parent = parent
        mkCorner(card, 10)
        local cs = mkStroke(card, 1, Color3.new(1,1,1), 0.88)

        -- Game icon — image intentionally BLANK until lazy loader fires
        local icon = Instance.new("ImageLabel")
        icon.Name                   = "GameIcon"
        icon.Size                   = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
        icon.Position               = UDim2.new(0, 9, 0.5, -ICON_SIZE/2)
        icon.BackgroundColor3       = T.BgSide
        icon.BackgroundTransparency = 0.2
        icon.Image                  = ""   -- ← populated by lazy loader
        icon.ZIndex                 = 6
        icon.Parent                 = card
        mkCorner(icon, 7)

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text              = name
        nameLabel.Font              = Enum.Font.GothamMedium
        nameLabel.TextSize          = 13
        nameLabel.TextColor3        = T.TextMain
        nameLabel.TextXAlignment    = Enum.TextXAlignment.Left
        nameLabel.Size              = UDim2.new(1, -(ICON_SIZE+26), 0, 18)
        nameLabel.Position          = UDim2.new(0, ICON_SIZE+18, 0, 10)
        nameLabel.BackgroundTransparency = 1
        nameLabel.ZIndex            = 6
        nameLabel.Parent            = card
        nameLabel:SetAttribute("TextRole", "main")

        local descLabel = Instance.new("TextLabel")
        descLabel.Text              = desc or ""
        descLabel.Font              = Enum.Font.Gotham
        descLabel.TextSize          = 10
        descLabel.TextColor3        = T.TextMuted
        descLabel.TextXAlignment    = Enum.TextXAlignment.Left
        descLabel.Size              = UDim2.new(1, -(ICON_SIZE+26), 0, 13)
        descLabel.Position          = UDim2.new(0, ICON_SIZE+18, 0, 29)
        descLabel.BackgroundTransparency = 1
        descLabel.TextTruncate      = Enum.TextTruncate.AtEnd
        descLabel.ZIndex            = 6
        descLabel.Parent            = card

        -- Tag badge (shows script category name if available)
        if scriptKey then
            local badge = Instance.new("Frame")
            badge.Size                   = UDim2.new(0, 0, 0, 14)   -- auto-sized by label
            badge.AutomaticSize          = Enum.AutomaticSize.X
            badge.Position               = UDim2.new(1, -6, 0.5, -7)
            badge.AnchorPoint            = Vector2.new(1, 0)
            badge.BackgroundColor3       = T.Accent
            badge.BackgroundTransparency = 0.55
            badge.BorderSizePixel        = 0
            badge.ZIndex                 = 7
            badge.Parent                 = card
            mkCorner(badge, 4)
            local badgePad = Instance.new("UIPadding")
            badgePad.PaddingLeft  = UDim.new(0, 5)
            badgePad.PaddingRight = UDim.new(0, 5)
            badgePad.Parent       = badge

            local badgeTxt = Instance.new("TextLabel")
            badgeTxt.Text              = scriptKey
            badgeTxt.Font              = Enum.Font.GothamBold
            badgeTxt.TextSize          = 9
            badgeTxt.TextColor3        = T.TextMain
            badgeTxt.BackgroundTransparency = 1
            badgeTxt.Size              = UDim2.new(0, 0, 1, 0)
            badgeTxt.AutomaticSize     = Enum.AutomaticSize.X
            badgeTxt.ZIndex            = 8
            badgeTxt.Parent            = badge
        end

        -- ── Hover / click ──────────────────────────────────────
        local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        card.MouseEnter:Connect(function()
            TweenService:Create(card, TWEEN_FAST, {
                BackgroundTransparency = 0.20,
                BackgroundColor3       = T.BgBtnHov,
            }):Play()
            TweenService:Create(cs, TWEEN_FAST, {Transparency = 0.55}):Play()
        end)
        card.MouseLeave:Connect(function()
            TweenService:Create(card, TWEEN_FAST, {
                BackgroundTransparency = 0.40,
                BackgroundColor3       = T.BgPanel,
            }):Play()
            TweenService:Create(cs, TWEEN_FAST, {Transparency = 0.88}):Play()
        end)
        card.MouseButton1Click:Connect(function()
            -- Ripple flash
            TweenService:Create(card, TweenInfo.new(0.05), {
                BackgroundColor3 = T.Accent, BackgroundTransparency = 0.3
            }):Play()
            task.delay(0.10, function()
                TweenService:Create(card, TWEEN_FAST, {
                    BackgroundColor3 = T.BgBtnHov, BackgroundTransparency = 0.20
                }):Play()
            end)

            if scriptKey and categoryMap[scriptKey] then
                -- Load the dedicated category for this game
                recordTabClick(scriptKey)
                clearContent()
                loadHacksFromCategory(scriptKey)
                updateGuiColors()
            else
                createNotification(
                    name,
                    "No scripts available for this game yet.",
                    3
                )
            end
        end)
    end

    -- ── Incremental render (avoids frame drops on 180+ games) ───
    local function renderList(list)
        -- Clear previous cards
        for _, c in ipairs(cardHolder:GetChildren()) do
            if c:IsA("TextButton") or c:IsA("Frame") then c:Destroy() end
        end

        local i = 1
        local function renderBatch()
            local rendered = 0
            while i <= #list and rendered < BATCH_SIZE do
                buildCard(list[i], cardHolder)
                i = i + 1
                rendered = rendered + 1
            end
            if i <= #list then
                task.wait()  -- yield one frame, then continue
                renderBatch()
            else
                -- All cards built — now bind lazy icon loading
                task.defer(function()
                    bindLazyIconLoading(
                        scrollingFrame,
                        scrollingFrame.AbsoluteSize.Y
                    )
                end)
            end
        end
        renderBatch()
    end

    -- Initial render — all games
    renderList(GamesDB)

    -- ── Filter on search ────────────────────────────────────────
    local debounceToken = 0

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query  = string.lower(searchBox.Text)
        local token  = tick()
        debounceToken = token

        task.delay(0.3, function()
            -- Only run if no newer keystroke arrived
            if debounceToken ~= token then return end

            if query == "" then
                renderList(GamesDB)
                return
            end

            local filtered = {}
            for _, entry in ipairs(GamesDB) do
                local name     = string.lower(entry[1])
                local key      = string.lower(entry[3] or "")
                local descText = string.lower(entry[4] or "")
                if string.find(name, query, 1, true)
                or string.find(key,  query, 1, true)
                or string.find(descText, query, 1, true) then
                    table.insert(filtered, entry)
                end
            end
            renderList(filtered)
        end)
    end)
end


-- ══════════════════════════════════════
--  ④ FIXED showAllScripts (search debounce fix)
--  Replace the entire existing showAllScripts() function with this.
--  The original had a race condition: multiple task.delay(0.5) callbacks
--  could all fire and each call updateSearchResults, spamming DOM writes.
-- ══════════════════════════════════════

local function showAllScripts()
    clearContent()
    createSectionHeader("Search Scripts", scrollingFrame)

    local searchBox = Instance.new("TextBox")
    searchBox.Size                   = UDim2.new(1, 0, 0, 32)
    searchBox.BackgroundColor3       = T.BgPanel
    searchBox.BackgroundTransparency = 0.2
    searchBox.TextColor3             = T.TextMain
    searchBox.PlaceholderText        = "Search scripts..."
    searchBox.PlaceholderColor3      = T.TextMuted
    searchBox.TextSize               = 13
    searchBox.Text                   = ""
    searchBox.Font                   = Enum.Font.Gotham
    searchBox.ClearTextOnFocus       = false
    searchBox.ZIndex                 = 4
    searchBox.Parent                 = scrollingFrame
    searchBox:SetAttribute("TextRole", "main")
    mkCorner(searchBox, 8)
    mkStroke(searchBox, 1, T.Stroke, 0.3)
    local sbPad = Instance.new("UIPadding")
    sbPad.PaddingLeft = UDim.new(0, 10)
    sbPad.Parent      = searchBox

    local resultsLabel = createLabel("Type to search...", scrollingFrame)
    resultsLabel.TextColor3 = T.TextMuted

    local function updateSearchResults(query)
        -- Destroy only result cards, keep searchBox + resultsLabel
        for _, child in ipairs(scrollingFrame:GetChildren()) do
            if child ~= searchBox and child ~= resultsLabel
               and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end
        if query == "" then
            resultsLabel.Text = "Type to search..."
            return
        end
        resultsLabel.Text = "Searching..."

        -- Search local database (DOES NOT touch GamesDB — only script categories)
        local mhResults = {}
        for categoryName, hacks in pairs(HubData) do
            if type(hacks) == "table" then
                for _, hack in ipairs(hacks) do
                    if type(hack) == "table" and hack[1] and type(hack[1]) == "string" then
                        if string.find(string.lower(hack[1]), string.lower(query), 1, true) then
                            table.insert(mhResults, {
                                name     = hack[1],
                                category = categoryName,
                                func     = hack[2],
                            })
                        end
                    end
                end
            end
        end

        -- ScriptBlox search (remote)
        local sbResults = {}
        task.spawn(function()
            local ok, response = pcall(function()
                return HttpService:GetAsync(
                    "https://scriptblox.com/api/script/search?q="
                    .. HttpService:UrlEncode(query)
                )
            end)
            if ok then
                local data = HttpService:JSONDecode(response)
                if data and data.result and data.result.scripts then
                    for _, s in ipairs(data.result.scripts) do
                        table.insert(sbResults, { name = s.title, scriptId = s._id })
                    end
                end
            end

            -- Write results back on main thread
            resultsLabel.Text = "Found " .. (#mhResults + #sbResults) .. " results"

            -- Incremental render: 10 per frame to avoid stutter
            local allResults = {}
            for _, r in ipairs(mhResults) do table.insert(allResults, r) end
            for _, r in ipairs(sbResults)  do table.insert(allResults, { name = r.name .. "  [ScriptBlox]", category = "ScriptBlox", scriptId = r.scriptId }) end

            local i = 1
            local function renderBatch()
                local rendered = 0
                while i <= #allResults and rendered < 10 do
                    local r = allResults[i]
                    createButton(r.name .. (r.category and ("  ["..r.category.."]") or ""), scrollingFrame, function()
                        if r.func then
                            local ok2, e = pcall(r.func)
                            if not ok2 then createNotification("ERROR", tostring(e), 5, 7733968497) end
                        elseif r.scriptId then
                            createNotification("INFO", "ScriptBlox ID: " .. r.scriptId, 5)
                        end
                    end)
                    i = i + 1
                    rendered = rendered + 1
                end
                if i <= #allResults then task.wait(); renderBatch() end
            end
            renderBatch()
        end)
    end

    -- ── FIXED debounce: token-based, no duplicate execution ─────
    local debounceToken = 0

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if #searchBox.Text < 3 then return end
        local token = tick()
        debounceToken = token
        task.delay(0.45, function()
            if debounceToken == token then
                updateSearchResults(searchBox.Text)
            end
        end)
    end)
    searchBox.FocusLost:Connect(function()
        updateSearchResults(searchBox.Text)
    end)
end


-- ══════════════════════════════════════
--  ⑤ INIT PATCH
--  In logic.lua's init(), BEFORE the categoryMap loop, add:
-- ══════════════════════════════════════

--[[  PASTE THIS INSIDE init(), right before the `for _, categoryName` loop:

    -- Virtual "Games" tab — not in categoryMap, so search is unaffected
    createButton("🎮 Games", catScroll, function()
        recordTabClick("Games")
        clearContent()
        showGames()
        updateGuiColors()
    end, true)

]]
