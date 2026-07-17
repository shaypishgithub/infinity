-- russianempire.ru — Bootstrap
local Services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    HttpService = game:GetService("HttpService"),
    CoreGui = game:GetService("CoreGui")
}
Services.player = Services.Players.LocalPlayer

local guiModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/evoruss/evodetail/gui.ru", true))()
guiModule.Init(Services)
