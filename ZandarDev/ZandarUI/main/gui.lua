local ZandarUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/ZandarDev/ZandarUI/main/ZandarUI.lua"
))()

local Window = ZandarUI.new({
    Title       = "My Hub",
    Subtitle    = "v1.0",
    Theme       = "Dark",          -- "Dark" или "Light"
    AccentColor = Color3.fromRGB(120, 80, 255), -- твой цвет
    ToggleKey   = Enum.KeyCode.RightShift,
})

local Tab = Window:AddTab("Main")

Tab:AddSection("General")
Tab:AddButton("Teleport", function() print("tp!") end)
Tab:AddToggle("God Mode", false, function(v) print(v) end)
Tab:AddSlider("Speed", {Min=16, Max=500, Default=16, Suffix=" stud/s"}, function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
end)
Tab:AddDropdown("Team", {"Red","Blue","Green"}, function(v) print(v) end)
Tab:AddColorPicker("ESP Color", Color3.new(1,0,0), function(c) print(c) end)
Tab:AddTextBox("Player Name", "Enter name...", function(v) print(v) end)
Tab:AddSeparator("section")

Window:Notify({
    Title   = "Loaded!",
    Message = "Script ready.",
    Type    = "Success",  -- "Info" | "Success" | "Warning" | "Error"
    Duration = 4,
})
