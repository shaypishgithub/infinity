-- russloader.ru (Loader Visuals)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Загружаем цвета если юзер их менял
local acc = Color3.fromRGB(0, 240, 255)
local bg = Color3.fromRGB(8, 8, 12)
pcall(function()
    if isfile and isfile("MegaHack/colorSettings.json") then
        local d = HttpService:JSONDecode(readfile("MegaHack/colorSettings.json"))
        if d.accentColor then acc = Color3.new(table.unpack(d.accentColor)) end
        if d.bgColor then bg = Color3.new(table.unpack(d.bgColor)) end
    end
end)

local function mkCorner(p, r) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 16) c.Parent = p return c end
local function mkNeon(p, col)
    local g = Instance.new("UIStroke") g.Thickness = 6 g.Color = col g.Transparency = 0.75 g.ApplyStrokeMode = Enum.ApplyStrokeMode.Border g.Parent = p
    local c = Instance.new("UIStroke") c.Thickness = 1.5 c.Color = col c.Transparency = 0 c.ApplyStrokeMode = Enum.ApplyStrokeMode.Border c.Parent = p
end
local function mkLabel(p, pr) local l = Instance.new("TextLabel") l.BackgroundTransparency = 1 l.BorderSizePixel = 0 for k,v in pairs(pr) do l[k]=v end l.Parent = p return l end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Evoruss_Loader"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
pcall(function() if syn then syn.protect_gui(screenGui) end screenGui.Parent = gethui and gethui() or CoreGui end) or (function() screenGui.Parent = playerGui end)()

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 340)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 40)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = bg
mainFrame.BackgroundTransparency = 1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mkCorner(mainFrame, 18)
mkNeon(mainFrame, acc)

local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 14, 1, 14)
shadow.Position = UDim2.new(0, 7, 0, 7)
shadow.BackgroundColor3 = Color3.new(0,0,0)
shadow.BackgroundTransparency = 1
shadow.ZIndex = 1
shadow.Parent = mainFrame
mkCorner(shadow, 18)

local glass = Instance.new("Frame")
glass.BackgroundColor3 = Color3.new(1,1,1) glass.BackgroundTransparency = 1 glass.Size = UDim2.new(1,0,0.5,0) glass.ZIndex = 3 glass.Parent = mainFrame
mkCorner(glass, 18)
local gg = Instance.new("UIGradient") gg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(0.4, 0.8), NumberSequenceKeypoint.new(1, 1.0)}) gg.Rotation = 90 gg.Parent = glass

-- 3D Текст
local tp = {Font = Enum.Font.GothamBold, TextSize = 36, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1,0,0,50), ZIndex = 5}
mkLabel(mainFrame, {Text = "EVORUSS", TextColor3 = Color3.new(acc.R*0.2, acc.G*0.2, acc.B*0.2), Position = UDim2.new(0,6,0,66), TextTransparency = 1, unpack(tp)})
mkLabel(mainFrame, {Text = "EVORUSS", TextColor3 = Color3.new(acc.R*0.5, acc.G*0.5, acc.B*0.5), Position = UDim2.new(0,4,0,64), TextTransparency = 1, unpack(tp)})
mkLabel(mainFrame, {Text = "EVORUSS", TextColor3 = Color3.new(acc.R*0.8, acc.G*0.8, acc.B*0.8), Position = UDim2.new(0,2,0,62), TextTransparency = 1, unpack(tp)})
local mainTxt = mkLabel(mainFrame, {Text = "EVORUSS", TextColor3 = Color3.fromRGB(220,225,240), Position = UDim2.new(0,0,0,60), TextTransparency = 1, unpack(tp)})

local statusLbl = mkLabel(mainFrame, {Text = "Connecting to nodes...", Font = Enum.Font.Code, TextSize = 13, TextColor3 = Color3.fromRGB(160,165,180), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1,-40,0,20), Position = UDim2.new(0,20,0,155), ZIndex = 5, TextTransparency = 1})

local track = Instance.new("Frame") track.BackgroundColor3 = Color3.fromRGB(15,15,20) track.Size = UDim2.new(1,-60,0,8) track.Position = UDim2.new(0,30,0,195) track.ZIndex = 5 track.Parent = mainFrame mkCorner(track, 4) mkNeon(track, acc)
local fill = Instance.new("Frame") fill.BackgroundColor3 = acc fill.Size = UDim2.new(0,0,1,0) fill.ZIndex = 6 fill.Parent = track mkCorner(fill, 4)
local pctLbl = mkLabel(mainFrame, {Text = "0%", Font = Enum.Font.GothamBold, TextSize = 28, TextColor3 = acc, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1,0,0,35), Position = UDim2.new(0,0,0,215), ZIndex = 5, TextTransparency = 1})

-- Анимация появления
TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5,0,0.5,0), BackgroundTransparency = 0.1}):Play()
TweenService:Create(shadow, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.5}):Play()
task.delay(0.3, function()
    for _,l in ipairs(mainFrame:GetChildren()) do 
        if l:IsA("TextLabel") then TweenService:Create(l, TweenInfo.new(0.4), {TextTransparency = (l.Text == "EVORUSS" and 0) or 0.3}):Play() end 
    end
end)

-- Логика прогресса
local startT, lastS = tick(), -1
local msgs = {[0]="Connecting...",[20]="Loading Modules...",[50]="Building 3D Interface...",[80]="Finalizing...",[100]="Complete."}
local pConn 
pConn = RunService.Heartbeat:Connect(function()
    local p = math.min((tick()-startT)/5, 1) local pi = math.floor(p*100)
    TweenService:Create(fill, TweenInfo.new(0.15), {Size = UDim2.new(p,0,1,0)}):Play()
    pctLbl.Text = tostring(pi).."%"
    for t,m in pairs(msgs) do if pi>=t and t>lastS then lastS=t statusLbl.Text=m end end
    mainTxt.TextTransparency = math.abs(math.sin(tick()*1.5))*0.15
    
    if p>=1 then
        pConn:Disconnect()
        task.delay(0.5, function()
            -- Анимация ухода
            TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}):Play()
            TweenService:Create(shadow, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}):Play()
            task.delay(0.6, function()
                screenGui:Destroy()
                -- ВЫЗОВ ВТОРОГО ФАЙЛА
                loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/evoruss/evodetail/russianempire.ru", true))()
            end)
        end)
    end
end)
