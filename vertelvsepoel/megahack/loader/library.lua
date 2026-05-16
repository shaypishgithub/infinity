local Library = {}

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local Theme = {
    Background = Color3.fromRGB(10,10,14),
    Surface = Color3.fromRGB(18,18,24),
    Surface2 = Color3.fromRGB(25,25,35),

    Accent = Color3.fromRGB(0,255,120),
    Accent2 = Color3.fromRGB(170,0,255),
    Warning = Color3.fromRGB(255,221,0),
    Danger = Color3.fromRGB(255,60,60),

    Text = Color3.fromRGB(255,255,255),
    SubText = Color3.fromRGB(170,170,180),

    Stroke = Color3.fromRGB(50,50,60)
}

local Config = {}
local Registry = {}

function Library:SaveConfig(Folder, File)
    if not isfolder(Folder) then
        makefolder(Folder)
    end

    writefile(
        Folder.."/"..File,
        HttpService:JSONEncode(Config)
    )
end

function Library:LoadConfig(Folder, File)
    if isfile(Folder.."/"..File) then
        local Data = HttpService:JSONDecode(
            readfile(Folder.."/"..File)
        )

        Config = Data
    end
end

function Library:SetAccent(v)
    Theme.Accent = v

    for _,obj in pairs(Registry) do
        if obj.Type == "Accent" then
            obj.Object.BackgroundColor3 = v
        end
    end
end

function Library:SetSecondAccent(v)
    Theme.Accent2 = v
end

function Library:SetWarning(v)
    Theme.Warning = v
end

function Library:SetDanger(v)
    Theme.Danger = v
end

function Library:SetBlur(State)
    if State then
        if not Lighting:FindFirstChild("MegaBlur") then
            local Blur = Instance.new("BlurEffect")
            Blur.Name = "MegaBlur"
            Blur.Size = 20
            Blur.Parent = Lighting
        end
    else
        if Lighting:FindFirstChild("MegaBlur") then
            Lighting.MegaBlur:Destroy()
        end
    end
end

function Library:Notify(Data)
    local Gui = Instance.new("ScreenGui")
    Gui.Parent = CoreGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0,260,0,70)
    Frame.Position = UDim2.new(1,-280,1,-100)
    Frame.BackgroundColor3 = Theme.Surface
    Frame.BorderSizePixel = 0
    Frame.Parent = Gui

    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,14)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Accent
    Stroke.Parent = Frame

    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.new(0,4,1,0)
    Accent.BackgroundColor3 = Theme.Accent
    Accent.BorderSizePixel = 0
    Accent.Parent = Frame

    Instance.new("UICorner", Accent).CornerRadius = UDim.new(0,12)

    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1,-20,0,25)
    Title.Position = UDim2.new(0,15,0,8)
    Title.Font = Enum.Font.GothamBlack
    Title.Text = Data.Title
    Title.TextColor3 = Theme.Text
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Frame

    local Desc = Instance.new("TextLabel")
    Desc.BackgroundTransparency = 1
    Desc.Size = UDim2.new(1,-20,0,25)
    Desc.Position = UDim2.new(0,15,0,32)
    Desc.Font = Enum.Font.Gotham
    Desc.Text = Data.Description
    Desc.TextColor3 = Theme.SubText
    Desc.TextSize = 12
    Desc.TextWrapped = true
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.Parent = Frame

    Frame.Position = UDim2.new(1,300,1,-100)

    TweenService:Create(
        Frame,
        TweenInfo.new(0.4,Enum.EasingStyle.Quint),
        {Position = UDim2.new(1,-280,1,-100)}
    ):Play()

    task.delay(Data.Time or 3,function()
        TweenService:Create(
            Frame,
            TweenInfo.new(0.4,Enum.EasingStyle.Quint),
            {Position = UDim2.new(1,300,1,-100)}
        ):Play()

        task.wait(.45)
        Gui:Destroy()
    end)
end

function Library:CreateWindow(Data)
    local Window = {}

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main = Instance.new("Frame")
    Main.Size = Data.Size or UDim2.new(0,700,0,450)
    Main.Position = UDim2.new(.5,-350,.5,-225)
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui

    Instance.new("UICorner",Main).CornerRadius = UDim.new(0,18)

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Stroke
    MainStroke.Parent = Main

    local Top = Instance.new("Frame")
    Top.Size = UDim2.new(1,0,0,50)
    Top.BackgroundColor3 = Theme.Surface
    Top.BorderSizePixel = 0
    Top.Parent = Main

    Instance.new("UICorner",Top).CornerRadius = UDim.new(0,18)

    local Fix = Instance.new("Frame")
    Fix.Size = UDim2.new(1,0,0,18)
    Fix.Position = UDim2.new(0,0,1,-18)
    Fix.BackgroundColor3 = Theme.Surface
    Fix.BorderSizePixel = 0
    Fix.Parent = Top

    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0,18,0,0)
    Title.Size = UDim2.new(1,0,1,0)
    Title.Font = Enum.Font.GothamBlack
    Title.Text = Data.Title or "WINDOW"
    Title.TextColor3 = Theme.Text
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Top

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0,170,1,-50)
    Sidebar.Position = UDim2.new(0,0,0,50)
    Sidebar.BackgroundColor3 = Theme.Surface
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main

    local Tabs = Instance.new("ScrollingFrame")
    Tabs.Size = UDim2.new(1,0,1,0)
    Tabs.BackgroundTransparency = 1
    Tabs.BorderSizePixel = 0
    Tabs.CanvasSize = UDim2.new(0,0,0,0)
    Tabs.ScrollBarThickness = 0
    Tabs.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0,6)
    TabLayout.Parent = Tabs

    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0,12)
    Padding.PaddingLeft = UDim.new(0,10)
    Padding.PaddingRight = UDim.new(0,10)
    Padding.Parent = Tabs

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1,-180,1,-60)
    Content.Position = UDim2.new(0,175,0,55)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    local Dragging
    local DragInput
    local DragStart
    local StartPos

    Top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Top.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart

            Main.Position = UDim2.new(
                StartPos.X.Scale,
                StartPos.X.Offset + Delta.X,
                StartPos.Y.Scale,
                StartPos.Y.Offset + Delta.Y
            )
        end
    end)

    function Window:CreateTab(Data2)
        local Tab = {}

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1,0,0,40)
        Button.BackgroundColor3 = Theme.Surface2
        Button.BorderSizePixel = 0
        Button.Text = ""
        Button.Parent = Tabs

        Instance.new("UICorner",Button).CornerRadius = UDim.new(0,12)

        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color = Theme.Stroke
        BtnStroke.Parent = Button

        local Icon = Instance.new("ImageLabel")
        Icon.Size = UDim2.new(0,18,0,18)
        Icon.Position = UDim2.new(0,14,.5,-9)
        Icon.BackgroundTransparency = 1
        Icon.Image = Data2.Icon or ""
        Icon.Parent = Button

        local Txt = Instance.new("TextLabel")
        Txt.BackgroundTransparency = 1
        Txt.Position = UDim2.new(0,42,0,0)
        Txt.Size = UDim2.new(1,-42,1,0)
        Txt.Font = Enum.Font.GothamBold
        Txt.Text = Data2.Name
        Txt.TextColor3 = Theme.Text
        Txt.TextSize = 13
        Txt.TextXAlignment = Enum.TextXAlignment.Left
        Txt.Parent = Button

        local Page = Instance.new("ScrollingFrame")
        Page.Visible = false
        Page.Size = UDim2.new(1,0,1,0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 3
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.Parent = Content

        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0,8)
        Layout.Parent = Page

        local Pad = Instance.new("UIPadding")
        Pad.PaddingTop = UDim.new(0,4)
        Pad.PaddingLeft = UDim.new(0,4)
        Pad.PaddingRight = UDim.new(0,4)
        Pad.Parent = Page

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y+15)
        end)

        Button.MouseButton1Click:Connect(function()
            for _,v in pairs(Content:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end

            Page.Visible = true
        end)

        function Tab:CreateSection(Text)
            local Label = Instance.new("TextLabel")
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.new(1,0,0,20)
            Label.Font = Enum.Font.GothamBlack
            Label.Text = Text
            Label.TextColor3 = Theme.Accent
            Label.TextSize = 15
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Page
        end

        function Tab:CreateParagraph(Data3)
            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1,0,0,80)
            Holder.BackgroundColor3 = Theme.Surface
            Holder.BorderSizePixel = 0
            Holder.Parent = Page

            Instance.new("UICorner",Holder).CornerRadius = UDim.new(0,14)

            local Stroke = Instance.new("UIStroke")
            Stroke.Color = Theme.Stroke
            Stroke.Parent = Holder

            local Title2 = Instance.new("TextLabel")
            Title2.BackgroundTransparency = 1
            Title2.Position = UDim2.new(0,14,0,10)
            Title2.Size = UDim2.new(1,-20,0,20)
            Title2.Font = Enum.Font.GothamBold
            Title2.Text = Data3.Title
            Title2.TextColor3 = Theme.Text
            Title2.TextSize = 14
            Title2.TextXAlignment = Enum.TextXAlignment.Left
            Title2.Parent = Holder

            local Desc2 = Instance.new("TextLabel")
            Desc2.BackgroundTransparency = 1
            Desc2.Position = UDim2.new(0,14,0,34)
            Desc2.Size = UDim2.new(1,-20,1,-40)
            Desc2.Font = Enum.Font.Gotham
            Desc2.Text = Data3.Description
            Desc2.TextColor3 = Theme.SubText
            Desc2.TextSize = 12
            Desc2.TextWrapped = true
            Desc2.TextXAlignment = Enum.TextXAlignment.Left
            Desc2.TextYAlignment = Enum.TextYAlignment.Top
            Desc2.Parent = Holder
        end

        function Tab:CreateButton(Data4)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1,0,0,42)
            Btn.BackgroundColor3 = Data4.Color or Theme.Accent
            Btn.BorderSizePixel = 0
            Btn.Text = ""
            Btn.Parent = Page

            table.insert(Registry,{
                Type = "Accent",
                Object = Btn
            })

            Instance.new("UICorner",Btn).CornerRadius = UDim.new(0,12)

            local Txt2 = Instance.new("TextLabel")
            Txt2.BackgroundTransparency = 1
            Txt2.Size = UDim2.new(1,0,1,0)
            Txt2.Font = Enum.Font.GothamBold
            Txt2.Text = Data4.Name
            Txt2.TextColor3 = Color3.new(1,1,1)
            Txt2.TextSize = 13
            Txt2.Parent = Btn

            Btn.MouseButton1Click:Connect(function()
                TweenService:Create(
                    Btn,
                    TweenInfo.new(.15),
                    {Size = UDim2.new(1,-4,0,38)}
                ):Play()

                task.wait(.15)

                TweenService:Create(
                    Btn,
                    TweenInfo.new(.15),
                    {Size = UDim2.new(1,0,0,42)}
                ):Play()

                pcall(Data4.Callback)
            end)
        end

        return Tab
    end

    return Window
end

return Library
