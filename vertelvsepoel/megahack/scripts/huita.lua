--[[
    Avatar Loader – массовая загрузка одежды и аксессуаров по ID
    Работает на любом современном executor'е (Synapse X, Krnl, Fluxus и др.)
--]]

local Players = game:GetService("Players")
local Marketplace = game:GetService("MarketplaceService")
local InsertService = game:GetService("InsertService")
local Player = Players.LocalPlayer

-- Список ID (из сообщения Mish)
local items = {
    {id = 126854635708461, name = "Y2K-Cargo-Pants-w-Strap-Black"},
    {id = 85807724535090,   name = "Choker-and-spiked-cuffs-Woman-3-0"},
    {id = 76407495358051,   name = "kawaii-lashes"},
    {id = 140127383196216,  name = "Black-Steel-Horns-Of-Conquest"},
    {id = 90674521788365,   name = "Black-Glasses"},
    {id = 134506208923733,  name = "black-neck-fur"},
    {id = 116930991247014,  name = "Black-Gothic-Void-Rusty-Halo-Crown"},
    {id = 132641613427329,  name = "Black-Dark-Devil-Wings"},
    {id = 17295937996,      name = "Black-Puffer-Vest-Neck-Fur-Collar-3-0"},
    {id = 107447557799161,  name = "2000s-punk-emo-stud-bracelet-stack"},
    {id = 93221904910049,   name = "3-0-gothic-spiked-belt-fur-skull-black"},
    {id = 18670125985,      name = "Elite-Suspender-Waist-Straps-V3-Silver"},
    {id = 113299753922459,  name = "3-0-kawaii-black-collar-w-giant-bell"},
}

-- Функция для вывода сообщений (можно заменить на GUI)
local function log(msg)
    print("[AvatarLoader] " .. msg)
end

-- Определяем тип предмета по ID
local function getAssetType(assetId)
    local success, info = pcall(function()
        return Marketplace:GetProductInfoAsync(assetId, Enum.InfoType.Asset)
    end)
    if success then
        return info.AssetTypeId
    else
        return nil
    end
end

-- Загружаем и применяем все предметы
local function applyItemsToCharacter()
    local character = Player.Character
    if not character then
        log("Персонаж не найден, ждём...")
        Player.CharacterAdded:Wait()
        character = Player.Character
    end

    local humanoid = character:WaitForChild("Humanoid")
    local description = Instance.new("HumanoidDescription")

    -- Счётчики для прогресса
    local total = #items
    local completed = 0

    for _, item in ipairs(items) do
        local assetId = item.id
        local assetTypeId = getAssetType(assetId)

        if not assetTypeId then
            log("Не удалось определить тип предмета " .. assetId .. " (" .. item.name .. ") – пропускаем")
            completed = completed + 1
            goto continue
        end

        -- Типы из Roblox API:
        -- 8 = Hat (аксессуар), 41 = Hair, 42 = Face, 43 = Neck, 44 = Shoulders,
        -- 45 = Front, 46 = Back, 47 = Waist, 11 = Shirt, 12 = Pants
        if assetTypeId == 11 then
            description.Shirt = assetId
            log("Shirt: " .. assetId .. " (" .. item.name .. ")")
        elseif assetTypeId == 12 then
            description.Pants = assetId
            log("Pants: " .. assetId .. " (" .. item.name .. ")")
        elseif assetTypeId == 8 or assetTypeId == 41 or assetTypeId == 42 or assetTypeId == 43 or
               assetTypeId == 44 or assetTypeId == 45 or assetTypeId == 46 or assetTypeId == 47 then
            -- Аксессуар – добавляем в список
            local current = description:GetAccessories()
            table.insert(current, assetId)
            description:SetAccessories(current)
            log("Accessory: " .. assetId .. " (" .. item.name .. ")")
        else
            log("Неизвестный тип (" .. assetTypeId .. ") у " .. assetId .. " – пропускаем")
        end

        completed = completed + 1
        if completed % 3 == 0 or completed == total then
            log(string.format("Прогресс: %d / %d", completed, total))
        end

        ::continue::
        task.wait() -- небольшая задержка, чтобы не флудить API
    end

    -- Применяем описание к персонажу
    humanoid:ApplyDescription(description)
    log("Одежда и аксессуары успешно нанесены!")
end

-- Запускаем
local success, err = pcall(applyItemsToCharacter)
if not success then
    warn("Ошибка: " .. tostring(err))
    log("Возможно, превышен лимит запросов. Попробуйте перезапустить скрипт.")
end
