-- gui.ru — Complete 2026 3D Glass System
local Gui = {}

-- Colors
local T = {
    BgDeep = Color3.fromRGB(8, 8, 12),
    BgGlass = Color3.fromRGB(15, 15, 22),
    BgPanel = Color3.fromRGB(20, 20, 30),
    Accent = Color3.fromRGB(0, 240, 255),
    AccentSec = Color3.fromRGB(255, 0, 229),
    TextMain = Color3.fromRGB(220, 225, 240),
    TextSub = Color3.fromRGB(120, 125, 150),
}

-- Helpers
local function mkCorner(p, r) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 12) c.Parent = p return c end
local function mkNeon(p, col, thick)
    pcall(function() p:FindFirstChildWhichIsA("UIStroke"):Destroy() end)
    local g = Instance.new("UIStroke") g.Thickness = (thick or 1.5)+5 g.Color = col g.Transparency = 0.75 g.ApplyStrokeMode = Enum.ApplyStrokeMode.Border g.Parent = p
    local c = Instance.new("UIStroke") c.Thickness = thick or 1.5 c.Color = col c.Transparency = 0 c.ApplyStrokeMode = Enum.ApplyStrokeMode.Border c.Parent = p
end
local function mkShadow(p, off)
    local s = Instance.new("Frame") s.Name = "Shadow3D" s.Size = UDim2.new(1, off or 10, 1, off or 10) s.Position = UDim2.new(0, (off or 10)/2, 0, (off or 10)/2) s.BackgroundColor3 = Color3.new(0,0,0) s.BackgroundTransparency = 0.5 s.ZIndex = p.ZIndex - 1 s.Parent = p.Parent mkCorner(s, 16)
end
local function mkGlass(p)
    local g = Instance.new("UIGradient") g.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(0,0,0)) g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.85), NumberSequenceKeypoint.new(0.4, 0.92), NumberSequenceKeypoint.new(1, 0.98)}) g.Rotation = 90 g.Parent = p
end

local screenGui, mainFrame, contentScroll, gamesScroll, sidebarLayout
local isOpen = false

function Gui.Init(S)
    local TS, UIS, RS = S.TweenService, S.UserInputService, S.RunService
    local player = S.player

    -- GUI Setup
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Evoruss_2026"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.Enabled = false
    pcall(function() if syn then syn.protect_gui(screenGui) end screenGui.Parent = gethui and gethui() or S.CoreGui end) or (function() screenGui.Parent = player:WaitForChild("PlayerGui") end)()

    -- Main Frame
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 650, 0, 450)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = T.BgGlass
    mainFrame.BackgroundTransparency = 0.12
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    mkCorner(mainFrame, 16)
    mkNeon(mainFrame, T.Accent, 1.5)
    mkShadow(mainFrame, 14)
    mkGlass(mainFrame)

    -- Header
    local header = Instance.new("Frame") header.Size = UDim2.new(1,0,0,45) header.BackgroundTransparency = 1 header.ZIndex = 5 header.Parent = mainFrame
    local title = Instance.new("TextLabel") title.Text = "EVORUSS // 2026" title.Font = Enum.Font.GothamBold title.TextSize = 18 title.TextColor3 = T.TextMain title.BackgroundTransparency = 1 title.Size = UDim2.new(0,200,1,0) title.Position = UDim2.new(0,20,0,0) title.TextXAlignment = Enum.TextXAlignment.Left title.ZIndex = 6 title.Parent = header
    
    local closeBtn = Instance.new("TextButton") closeBtn.Text = "✕" closeBtn.Font = Enum.Font.GothamBold closeBtn.TextSize = 18 closeBtn.TextColor3 = T.TextMain closeBtn.Size = UDim2.new(0,30,0,30) closeBtn.Position = UDim2.new(1,-40,0,7) closeBtn.BackgroundColor3 = Color3.fromRGB(255,50,50) closeBtn.BackgroundTransparency = 0.3 closeBtn.ZIndex = 10 closeBtn.Parent = header mkCorner(closeBtn, 8) mkNeon(closeBtn, Color3.fromRGB(255,50,50), 1)

    -- Sidebar
    local sidebar = Instance.new("Frame") sidebar.Size = UDim2.new(0,155,1,-50) sidebar.Position = UDim2.new(0,0,0,50) sidebar.BackgroundTransparency = 0.9 sidebar.BackgroundColor3 = T.BgDeep sidebar.BorderSizePixel = 0 sidebar.ZIndex = 3 sidebar.Parent = mainFrame
    local sStroke = Instance.new("UIStroke") sStroke.Thickness = 1 sStroke.Color = T.Accent sStroke.Transparency = 0.6 sStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border sStroke.Parent = sidebar
    
    sidebarLayout = Instance.new("UIListLayout") sidebarLayout.Padding = UDim.new(0,4) sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder sidebarLayout.Parent = sidebar
    Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0,10)

    -- Content Area
    local contentFrame = Instance.new("Frame") contentFrame.Size = UDim2.new(1,-165,1,-60) contentFrame.Position = UDim2.new(0,160,0,55) contentFrame.BackgroundTransparency = 1 contentFrame.ZIndex = 3 contentFrame.Parent = mainFrame

    contentScroll = Instance.new("ScrollingFrame") contentScroll.Size = UDim2.new(1,0,1,0) contentScroll.BackgroundTransparency = 1 contentScroll.ScrollBarThickness = 0 contentScroll.CanvasSize = UDim2.new(0,0,0,0) contentScroll.ZIndex = 4 contentScroll.Parent = contentFrame
    local cLayout = Instance.new("UIListLayout") cLayout.Padding = UDim.new(0,10) cLayout.SortOrder = Enum.SortOrder.LayoutOrder cLayout.Parent = contentScroll
    cLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() contentScroll.CanvasSize = UDim2.new(0,0,0,cLayout.AbsoluteContentSize.Y+20) end)

    gamesScroll = Instance.new("ScrollingFrame") gamesScroll.Size = UDim2.new(1,0,1,0) gamesScroll.BackgroundTransparency = 1 gamesScroll.ScrollBarThickness = 0 gamesScroll.CanvasSize = UDim2.new(0,0,0,0) gamesScroll.Visible = false gamesScroll.ZIndex = 4 gamesScroll.Parent = contentFrame
    local gGrid = Instance.new("UIGridLayout") gGrid.CellSize = UDim2.new(0,120,0,100) gGrid.CellPadding = UDim2.new(0,10,0,10) gGrid.SortOrder = Enum.SortOrder.LayoutOrder gGrid.Parent = gamesScroll

    -- Tab Logic
    local currentTab = "Home"
    local function clearContent() for _,c in ipairs(contentScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end end

    local function switchTab(name)
        if name == currentTab then return end
        currentTab = name
        clearContent()
        contentScroll.Visible = true gamesScroll.Visible = false

        if name == "Home" then
            -- FPS Card
            local fpsCard = Instance.new("Frame") fpsCard.Size = UDim2.new(1,0,0,60) fpsCard.BackgroundColor3 = T.BgPanel fpsCard.BackgroundTransparency = 0.2 fpsCard.BorderSizePixel = 0 fpsCard.Parent = contentScroll mkCorner(fpsCard, 12) mkNeon(fpsCard, T.Accent, 1) mkGlass(fpsCard) mkShadow(fpsCard, 6)
            local fpsLbl = Instance.new("TextLabel") fpsLbl.Text = "⚡ FPS: --" fpsLbl.Font = Enum.Font.GothamBold fpsLbl.TextSize = 16 fpsLbl.TextColor3 = T.TextMain fpsLbl.BackgroundTransparency = 1 fpsLbl.Size = UDim2.new(1,-20,1,0) fpsLbl.Position = UDim2.new(0,15,0,0) fpsLbl.TextXAlignment = Enum.TextXAlignment.Left fpsLbl.ZIndex = 5 fpsLbl.Parent = fpsCard
            local lt, fc = tick(), 0
            local conn; conn = RS.Heartbeat:Connect(function() fc = fc+1 if tick()-lt>=1 then fpsLbl.Text = "⚡ FPS: "..fc fc, lt = 0, tick() end if not fpsCard.Parent then conn:Disconnect() end end)
        elseif name == "Games" then
            contentScroll.Visible = false gamesScroll.Visible = true
            if #gamesScroll:GetChildren() == 1 then
                local games = {{"Blox Fruits", 135853221608210}, {"Brookhaven", 93652827298808}, {"Arsenal", 286090429}, {"Pet Sim X", 93652827298808}}
                for i, g in ipairs(games) do
                    local card = Instance.new("Frame") card.Size = UDim2.new(0,120,0,100) card.BackgroundColor3 = T.BgPanel card.BackgroundTransparency = 0.25 card.BorderSizePixel = 0 card.LayoutOrder = i card.Parent = gamesScroll mkCorner(card, 12) mkGlass(card)
                    local img = Instance.new("ImageLabel") img.Size = UDim2.new(1,-10,0,65) img.Position = UDim2.new(0,5,0,5) img.BackgroundTransparency = 1 img.Image = "rbxthumb://type=Asset&id="..g[2].."&w=150&h=150" img.Parent = card
                    local nm = Instance.new("TextLabel") nm.Text = g[1] nm.Font = Enum.Font.GothamBold nm.TextSize = 10 nm.TextColor3 = T.TextSub nm.BackgroundTransparency = 1 nm.Size = UDim2.new(1,-10,0,20) nm.Position = UDim2.new(0,5,1,-22) nm.TextTruncate = Enum.TextTruncate.AtEnd nm.Parent = card
                    
                    local btn = Instance.new("TextButton") btn.Size = UDim2.new(1,0,1,0) btn.BackgroundTransparency = 1 btn.Text = "" btn.ZIndex = 5 btn.Parent = card
                    btn.MouseEnter:Connect(function() TS:Create(card, TweenInfo.new(0.2), {BackgroundTransparency = 0.05}):Play() mkNeon(card, T.AccentSec, 1.5) end)
                    btn.MouseLeave:Connect(function() TS:Create(card, TweenInfo.new(0.2), {BackgroundTransparency = 0.25}):Play() mkNeon(card, T.Accent, 1) end)
                end
            end
        else
            -- Заглушка для других кнопок
            local placeholder = Instance.new("TextLabel") placeholder.Text = "Executing " .. name .. " script..." placeholder.Font = Enum.Font.GothamBold placeholder.TextSize = 16 placeholder.TextColor3 = T.Accent placeholder.BackgroundTransparency = 1 placeholder.Size = UDim2.new(1,0,0,50) placeholder.Parent = contentScroll
            pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/shaypishgithub/infinity/refs/heads/main/evoruss/evodetail/"..string.lower(name)..".lua", true))() end)
        end
    end

    local function createTab(name, icon, order)
        local btn = Instance.new("TextButton") btn.Size = UDim2.new(1,-10,0,32) btn.BackgroundColor3 = T.BgDeep btn.BackgroundTransparency = 0.5 btn.BorderSizePixel = 0 btn.Text = " "..icon.."  "..name btn.Font = Enum.Font.GothamBold btn.TextSize = 12 btn.TextColor3 = T.TextSub btn.TextXAlignment = Enum.TextXAlignment.Left btn.LayoutOrder = order btn.Parent = sidebar mkCorner(btn, 8)
        btn.MouseButton1Click:Connect(function() switchTab(name) end)
        btn.MouseEnter:Connect(function() if currentTab ~= name then TS:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2, TextColor3 = T.TextMain}):Play() end end)
        btn.MouseLeave:Connect(function() if currentTab ~= name then TS:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.5, TextColor3 = T.TextSub}):Play() end end)
        return btn
    end

    createTab("Home", "🏠", 1)
    createTab("Games", "🎮", 2)
    local sep = Instance.new("Frame") sep.Size = UDim2.new(1,-20,0,1) sep.BackgroundColor3 = T.Accent sep.BackgroundTransparency = 0.7 sep.BorderSizePixel = 0 sep.LayoutOrder = 3 sep.Parent = sidebar
    createTab("Universal", "📜", 4)
    createTab("Blox Fruits", "🍕", 5)
    createTab("Brookhaven", "🏠", 6)

    -- Open/Close
    closeBtn.MouseButton1Click:Connect(function() Gui.Toggle() end)
    UIS.InputBegan:Connect(function(i, gpe) if gpe then return end if i.KeyCode == Enum.KeyCode.RightShift then Gui.Toggle() end end)

    switchTab("Home")
    Gui.Toggle()
end

function Gui.Toggle()
    if not screenGui then return end
    isOpen = not isOpen
    screenGui.Enabled = isOpen
    if isOpen then
        mainFrame.Size = UDim2.new(0,0,0,0) mainFrame.BackgroundTransparency = 1
        TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0,650,0,450), BackgroundTransparency = 0.12}):Play()
    end
end

return Gui
