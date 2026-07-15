return function(deps)
    local gui = deps.gui
    local ThemeColors = deps.ThemeColors
    local Settings = deps.Settings
    local GameIcons = deps.GameIcons
    local sortedCats = deps.sortedCats
    local SetTab = deps.SetTab

    local MkGlassPanel = gui.MkGlassPanel

    return function(GamesPanel)
        task.spawn(function()
            for idx, catName in ipairs(sortedCats) do
                local placeId = GameIcons[catName]
                local card = MkGlassPanel(GamesPanel, nil, nil, 4, 10, 0.15)
                card.Size = UDim2.new(0, 120, 0, 100)
                
                local iconFrame = Instance.new("Frame"); iconFrame.Size = UDim2.new(1, -12, 0, 60); iconFrame.Position = UDim2.new(0, 6, 0, 6)
                iconFrame.BackgroundColor3 = ThemeColors.GlassMid; iconFrame.BackgroundTransparency = 0.3
                iconFrame.BorderSizePixel = 0; iconFrame.ZIndex = 5; iconFrame.Parent = card; gui.MkCorner(iconFrame, 8)
                
                local thumb = Instance.new("ImageLabel"); thumb.Size = UDim2.new(1, -2, 1, -2); thumb.Position = UDim2.new(0, 1, 0, 1)
                thumb.BackgroundColor3 = Color3.new(0,0,0); thumb.BackgroundTransparency = 1; thumb.ZIndex = 6; thumb.Parent = iconFrame; gui.MkCorner(thumb, 7)
                
                if placeId and placeId ~= 0 then
                    task.spawn(function()
                        local url = string.format("rbxthumb://type=Asset&id=%s&w=150&h=150", tostring(placeId))
                        if thumb and thumb.Parent then thumb.Image = url; gui.Tw(thumb, {ImageTransparency = 0}, gui.TW.Slow):Play() end
                    end)
                end
                
                local nameLabel = Instance.new("TextLabel"); nameLabel.Size = UDim2.new(1, -8, 0, 24); nameLabel.Position = UDim2.new(0, 4, 1, -26)
                nameLabel.BackgroundTransparency = 1; nameLabel.Text = catName; nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 10; nameLabel.TextColor3 = ThemeColors.TextNormal; nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                nameLabel.ZIndex = 6; nameLabel.Parent = card
                
                local clickBtn = Instance.new("TextButton"); clickBtn.Size = UDim2.new(1, 0, 1, 0)
                clickBtn.BackgroundTransparency = 1; clickBtn.Text = ""; clickBtn.ZIndex = 10; clickBtn.Parent = card
                clickBtn.MouseEnter:Connect(function() gui.Tw(card, {BackgroundTransparency = 0.05}, gui.TW.Fast):Play() end)
                clickBtn.MouseLeave:Connect(function() gui.Tw(card, {BackgroundTransparency = 0.15}, gui.TW.Fast):Play() end)
                clickBtn.MouseButton1Click:Connect(function() SetTab(catName) end)
                
                if idx % 6 == 0 then task.wait() end
            end
        end)
    end
end
