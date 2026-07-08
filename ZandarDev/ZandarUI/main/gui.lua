-- ============================================
--        ГЛАВНЫЙ ФАЙЛ СБОРКИ И ИНТЕРФЕЙСА
-- ============================================

-- Инициализация глобального хаба
_G.ZandarHub = _G.ZandarHub or {
    Services = {
        game:GetService("Players"),
        game:GetService("RunService"),
        game:GetService("Workspace"),
        game:GetService("UserInputService"),
        game:GetService("GuiService"),
        game:GetService("Players").LocalPlayer
    },
    Config = { SpeedValue = 16, FlySpeed = 50, FreeCamSpeed = 100 },
    States = { ESP_Enabled = false, Hat_Enabled = false, FlyEnabled = false, FreeCamEnabled = false, Spectating = false },
    UI = {}, -- Сюда GUI сохранит кнопки для доступа из других скриптов
    Functions = {}, -- Сюда другие модули сохранят свои функции
    Data = { ActiveESP = {}, SelectedPlayer = nil, SpectateConnection = nil }
}

-- Загрузка библиотеки UI
local ZandarUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/ZandarDev/ZandarUI/main/ZandarUI.lua"))()

-- Загрузка модулей (ОБЯЗАТЕЛЬНО ДО СОЗДАНИЯ ОКОН)
loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/ZandarDev/ZandarUI/main/fly.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/ZandarDev/ZandarUI/main/esp.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/ZandarDev/ZandarUI/main/other.lua"))()

local Hub = _G.ZandarHub
local LocalPlayer = Hub.Services[6]

-- Создание окна
local Window = ZandarUI.new({
    Title       = "Zandar UI",
    Subtitle    = "v2.0 Modular",
    ToggleKey   = Enum.KeyCode.RightShift,
})
Hub.UI.Window = Window -- Сохраняем окно для Notify в other.lua

-- ============================================
--              СОЗДАНИЕ ВКЛАДОК
-- ============================================

-- Вкладка Main
local MainTab = Window:AddTab("Main")
MainTab:AddSection("Player Modifiers")

MainTab:AddNumberInput("Walk Speed", 16, 1, 1000, function(v) Hub.Config.SpeedValue = v Hub.Functions.UpdateWalkSpeed() end)
MainTab:AddNumberInput("Fly Speed", 50, 1, 500, function(v) Hub.Config.FlySpeed = v end)

MainTab:AddToggle("God Mode", false, function(v) Hub.Functions.ToggleGodMode(v) end)

MainTab:AddSeparator("Movement")

local flyToggle = MainTab:AddToggle("Fly Mode (F key)", false, function(state)
    if state and Hub.States.FreeCamEnabled then Hub.States.FreeCamEnabled = false Hub.Functions.StopFreeCam() Hub.UI.FreeCamToggle:Set(false) end
    Hub.States.FlyEnabled = state
    if state then Hub.Functions.StartFly(Hub.Config.FlySpeed) Window:Notify({ Title = "Fly", Message = "Fly enabled!", Type = "Info", Duration = 2 })
    else Hub.Functions.StopFly() end
end)
Hub.UI.FlyToggle = flyToggle -- Сохраняем для обновления из fly.lua по клавише F

MainTab:AddSeparator("Visuals")

MainTab:AddToggle("Conical Hat", false, function(state)
    Hub.States.Hat_Enabled = state
    if state then if LocalPlayer.Character then Hub.Functions.CreateHatEffects(LocalPlayer.Character) end
    else Hub.Functions.RemoveHatEffects(LocalPlayer.Character) end
end)

-- Вкладка Players
local PlayersTab = Window:AddTab("Players")
PlayersTab:AddSection("Visuals")

PlayersTab:AddToggle("Player ESP (Mono)", false, function(state)
    Hub.States.ESP_Enabled = state
    if state then 
        for _, p in ipairs(Hub.Services[1]:GetPlayers()) do if p.Character then Hub.Functions.CreateESP(p) end end
        Window:Notify({ Title = "ESP", Message = "ESP enabled", Type = "Success", Duration = 2 })
    else
        for p, _ in pairs(Hub.Data.ActiveESP) do Hub.Functions.RemoveESP(p) end
    end
end)

PlayersTab:AddSection("Camera & Movement")

local freeCamToggle = PlayersTab:AddToggle("Free Cam (N key)", false, function(state)
    if state and Hub.States.FlyEnabled then Hub.States.FlyEnabled = false Hub.Functions.StopFly() Hub.UI.FlyToggle:Set(false) end
    Hub.States.FreeCamEnabled = state
    if state then Hub.Functions.StartFreeCam(Hub.Config.FreeCamSpeed) Window:Notify({ Title = "Free Cam", Message = "Camera detached!", Type = "Info", Duration = 2 })
    else Hub.Functions.StopFreeCam() end
end)
Hub.UI.FreeCamToggle = freeCamToggle

PlayersTab:AddSeparator("Target Control")

local PlayerDropdown = PlayersTab:AddDropdown("Select Target", Hub.Functions.GetPlayerNames(), function(v)
    if v == "No players found" then Hub.Data.SelectedPlayer = nil return end
    Hub.Data.SelectedPlayer = Hub.Services[1]:FindFirstChild(v)
    if Hub.Data.SelectedPlayer then Window:Notify({ Title = "Target", Message = "Selected: " .. v, Type = "Info", Duration = 2 }) end
end)

PlayersTab:AddButton("Refresh Player List", function() PlayerDropdown:Refresh(Hub.Functions.GetPlayerNames(), false) end)
PlayersTab:AddButton("Teleport to Target", function() Hub.Functions.TeleportToPlayer(Hub.Data.SelectedPlayer) end)

local spectateToggle = PlayersTab:AddToggle("Spectate Target", false, function(state)
    if not Hub.Data.SelectedPlayer or Hub.Data.SelectedPlayer.Name == "No players found" then
        Window:Notify({ Title = "Error", Message = "No target selected!", Type = "Error", Duration = 3 })
        spectateToggle:Set(false) return
    end
    Hub.States.Spectating = state
    if state then Hub.Functions.StartSpectate(Hub.Data.SelectedPlayer) else Hub.Functions.StopSpectate() end
end)
Hub.UI.SpectateToggle = spectateToggle

PlayersTab:AddButton("Stop Spectating", function()
    if Hub.States.Spectating then Hub.Functions.StopSpectate() spectateToggle:Set(false) end
end)

-- ============================================
--           ГЛОБАЛЬНЫЕ ОБРАБОТЧИКИ
-- ============================================

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if Hub.States.Hat_Enabled then Hub.Functions.CreateHatEffects(char) end
    if Hub.States.FlyEnabled then task.wait(0.5) Hub.Functions.StartFly(Hub.Config.FlySpeed) end
end)

-- Авто-обновление списка
task.spawn(function() while task.wait(5) do pcall(function() PlayerDropdown:Refresh(Hub.Functions.GetPlayerNames(), true) end) end end)

Window:Notify({ Title = "Zandar UI", Message = "Modules loaded! F=Fly, N=FreeCam", Type = "Success", Duration = 4 })
