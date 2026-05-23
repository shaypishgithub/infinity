-- Загрузка предметов из каталога на персонажа
-- Описание: https://github.com/CatalizCS/Scripts

-- Получаем сервисы игры
local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local player = Players.LocalPlayer

-- Ваш список ID предметов из каталога
local itemsIDs = {
    126854635708461, -- Y2K-Cargo-Pants-w-Strap-Black
    85807724535090,  -- Choker-and-spiked-cuffs-Woman-3-0
    76407495358051,  -- kawaii-lashes
    140127383196216, -- Black-Steel-Horns-Of-Conquest
    90674521788365,  -- Black-Glasses
    134506208923733, -- black-neck-fur
    116930991247014, -- Black-Gothic-Void-Rusty-Halo-Crown
    132641613427329, -- Black-Dark-Devil-Wings
    17295937996,     -- Black-Puffer-Vest-Neck-Fur-Collar-3-0
    107447557799161, -- 2000s-punk-emo-stud-bracelet-stack
    93221904910049,  -- 3-0-gothic-spiked-belt-fur-skull-black
    18670125985,     -- Elite-Suspender-Waist-Straps-V3-Silver
    113299753922459, -- 3-0-kawaii-black-collar-w-giant-bell
}

-- Функция для загрузки и применения предметов
local function loadItems()
    -- Ждем появления персонажа
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    local character = player.Character
    local humanoid = character:WaitForChild("Humanoid")

    -- Создаем новую модель для загруженных предметов, чтобы не засорять персонаж
    local loadedItemsModel = Instance.new("Model")
    loadedItemsModel.Name = "LoadedCatalogItems"
    loadedItemsModel.Parent = character

    for _, itemId in ipairs(itemsIDs) do
        pcall(function()
            -- Загружаем модель предмета по его ID[reference:1]
            local loadedModel = InsertService:LoadAsset(itemId)
            if not loadedModel then 
                print("Не удалось загрузить предмет с ID:", itemId)
                return 
            end

            loadedModel.Parent = loadedItemsModel
            
            -- Ищем в загруженной модели аксессуар или одежду
            local accessory = loadedModel:FindFirstChildOfClass("Accessory")
            local shirt = loadedModel:FindFirstChildOfClass("Shirt")
            local pants = loadedModel:FindFirstChildOfClass("Pants")

            if accessory then
                -- Прикрепляем аксессуар к персонажу
                accessory.Parent = character
                local handle = accessory:FindFirstChildOfClass("Part") or accessory:FindFirstChildOfClass("MeshPart")
                if handle then
                    local weld = handle:FindFirstChildOfClass("Weld")
                    if weld then
                        -- Обновляем сварку, чтобы предмет правильно сидел на персонаже
                        weld.Part1 = handle
                        weld.Part0 = humanoid.RootPart
                    end
                end
                print("Аксессуар загружен:", itemId)
            elseif shirt then
                -- Если нашли футболку, просто наденем её
                shirt.Parent = character
                print("Футболка загружена:", itemId)
            elseif pants then
                -- Если нашли штаны, также наденем их
                pants.Parent = character
                print("Штаны загружены:", itemId)
            else
                -- Если ничего не нашли, возможно, это инструмент или другое. Просто удаляем его.
                print("Предмет с ID", itemId, "не является аксессуаром/одеждой и будет удалён.")
                loadedModel:Destroy()
            end
        end)
        wait(0.5) -- Небольшая задержка, чтобы не перегружать API
    end
    print("Загрузка предметов завершена!")
end

-- Запускаем загрузку
loadItems()
