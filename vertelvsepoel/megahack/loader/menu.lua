local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourname/megahack-ui/main/library.lua"))()

local Core = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourname/megahack-ui/main/core.lua"))()

local Window = Library:CreateWindow({
    Title = "MEGA X",
    Size = UDim2.new(0, 720, 0, 470),
    Theme = "Void",
    Acrylic = true,
    Draggable = true,
    KeySystem = false,
    SaveConfig = true,
    ConfigFolder = "MegaX",
    ConfigFile = "userprefs.json"
})

local Home = Window:CreateTab({
    Name = "Home",
    Icon = "rbxassetid://7734053495"
})

local Update = Window:CreateTab({
    Name = "Update",
    Icon = "rbxassetid://7733961821"
})

local Games = Window:CreateTab({
    Name = "Games",
    Icon = "rbxassetid://7733964640"
})

local Player = Window:CreateTab({
    Name = "Player",
    Icon = "rbxassetid://7734056608"
})

local Visuals = Window:CreateTab({
    Name = "Visuals",
    Icon = "rbxassetid://7734056672"
})

local Settings = Window:CreateTab({
    Name = "Settings",
    Icon = "rbxassetid://7734053495"
})

Home:CreateSection("WELCOME")

Home:CreateParagraph({
    Title = "MEGA X",
    Description = "New futuristic interface with separated architecture and config system."
})

Home:CreateButton({
    Name = "Copy Discord",
    Color = Color3.fromRGB(139,92,246),
    Callback = function()
        setclipboard("discord.gg/megax")
        Library:Notify({
            Title = "Copied",
            Description = "Discord copied",
            Time = 3
        })
    end
})

Update:CreateSection("LATEST CHANGES")

Update:CreateParagraph({
    Title = "UI REWORK",
    Description = [[
• Completely remade interface
• New fonts
• New animations
• Separated core and menu
• Added config system
• Added color themes
• Better optimization
• New notifications
]]
})

Settings:CreateSection("COLORS")

Settings:CreateColorPicker({
    Name = "Green Accent",
    Default = Color3.fromRGB(0,255,120),
    Callback = function(v)
        Library:SetAccent(v)
    end
})

Settings:CreateColorPicker({
    Name = "Purple Accent",
    Default = Color3.fromRGB(170,0,255),
    Callback = function(v)
        Library:SetSecondAccent(v)
    end
})

Settings:CreateColorPicker({
    Name = "Yellow Accent",
    Default = Color3.fromRGB(255,221,0),
    Callback = function(v)
        Library:SetWarning(v)
    end
})

Settings:CreateColorPicker({
    Name = "Red Accent",
    Default = Color3.fromRGB(255,60,60),
    Callback = function(v)
        Library:SetDanger(v)
    end
})

Settings:CreateToggle({
    Name = "Blur Background",
    Default = true,
    Callback = function(v)
        Library:SetBlur(v)
    end
})

Settings:CreateToggle({
    Name = "Save Config Automatically",
    Default = true,
    Callback = function(v)
        Core.Config.AutoSave = v
    end
})

Games:CreateSection("POPULAR")

Games:CreateButton({
    Name = "Blade Ball",
    Color = Color3.fromRGB(0,255,120),
    Callback = function()
        Core.LoadGame("BladeBall")
    end
})

Games:CreateButton({
    Name = "Brookhaven",
    Color = Color3.fromRGB(170,0,255),
    Callback = function()
        Core.LoadGame("Brookhaven")
    end
})

Games:CreateButton({
    Name = "MM2",
    Color = Color3.fromRGB(255,60,60),
    Callback = function()
        Core.LoadGame("MM2")
    end
})

Games:CreateButton({
    Name = "Grow Garden",
    Color = Color3.fromRGB(255,221,0),
    Callback = function()
        Core.LoadGame("GrowGarden")
    end
})

Player:CreateSection("LOCAL PLAYER")

Player:CreateSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 300,
    Default = 16,
    Color = Color3.fromRGB(0,255,120),
    Callback = function(v)
        Core.Player:SetWalkSpeed(v)
    end
})

Player:CreateSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 400,
    Default = 50,
    Color = Color3.fromRGB(170,0,255),
    Callback = function(v)
        Core.Player:SetJumpPower(v)
    end
})

Player:CreateToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(v)
        Core.Player.InfiniteJump(v)
    end
})

Player:CreateToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(v)
        Core.Player.Noclip(v)
    end
})

Visuals:CreateSection("VISUAL")

Visuals:CreateToggle({
    Name = "ESP",
    Default = false,
    Callback = function(v)
        Core.Visuals.ESP(v)
    end
})

Visuals:CreateToggle({
    Name = "FullBright",
    Default = false,
    Callback = function(v)
        Core.Visuals.FullBright(v)
    end
})

Visuals:CreateToggle({
    Name = "Player Tracers",
    Default = false,
    Callback = function(v)
        Core.Visuals.Tracers(v)
    end
})

Visuals:CreateSlider({
    Name = "FOV",
    Min = 70,
    Max = 140,
    Default = 70,
    Color = Color3.fromRGB(255,221,0),
    Callback = function(v)
        workspace.CurrentCamera.FieldOfView = v
    end
})

Library:Notify({
    Title = "MEGA X",
    Description = "Loaded successfully",
    Time = 5
})
