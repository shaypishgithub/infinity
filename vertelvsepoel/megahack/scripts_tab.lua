return function(deps)
    local gui = deps.gui
    local ThemeColors = deps.ThemeColors
    local Settings = deps.Settings
    local HubData = deps.HubData
    local Categories = deps.Categories
    local BASE_URL = deps.BASE_URL
    local Notify = deps.Notify
    local safeLoad = deps.safeLoad
    local SetTab = deps.SetTab

    local MkGlassPanel, MkNeonText, MkNeonButton, CreateSectionHeader = gui.MkGlassPanel, gui.MkNeonText, gui.MkNeonButton, gui.CreateSectionHeader

    return function(ScriptScroll, categoryName)
        local scripts = HubData[categoryName]
        if not scripts or #scripts == 0 then
            local emptyCard = MkGlassPanel(ScriptScroll, UDim2.new(1, 0, 0, 80), nil, 4, 12, 0.15)
            MkNeonText(emptyCard, "📦", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 10), 28, ThemeColors.TextBright, 6)
            MkNeonText(emptyCard, "Loading scripts or empty", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 48), 12, ThemeColors.TextDim, 6)
            MkNeonButton(emptyCard, "Retry", UDim2.new(0, 80, 0, 28), UDim2.new(0.5, -40, 1, -36), function() SetTab(categoryName) end)
            return
        end

        CreateSectionHeader(categoryName .. " (" .. #scripts .. " scripts)", ScriptScroll)
        for i, scriptData in ipairs(scripts) do
            local scriptName = type(scriptData) == "table" and (scriptData.name or scriptData.Name or "Unnamed") or tostring(scriptData)
            local scriptDesc = type(scriptData) == "table" and (scriptData.desc or scriptData.description or "") or ""
            local scriptCode = type(scriptData) == "table" and (scriptData.script or scriptData.code or "") or ""
            local hasCode = scriptCode ~= ""

            local card = MkGlassPanel(ScriptScroll, UDim2.new(1, 0, 0, 58), nil, 4, 10, 0.12); card.LayoutOrder = i
            MkNeonText(card, scriptName, UDim2.new(1, -160, 0, 22), UDim2.new(0, 14, 0, 8), 13, ThemeColors.TextBright, 6)
            if scriptDesc ~= "" then MkNeonText(card, scriptDesc, UDim2.new(1, -160, 0, 16), UDim2.new(0, 14, 0, 32), 10, ThemeColors.TextMuted, 6) end

            MkNeonButton(card, hasCode and "Execute ▶" or "Load", UDim2.new(0, 80, 0, 28), UDim2.new(1, -94, 0.5, -14), function()
                if hasCode then
                    pcall(function()
                        local fn = loadstring(scriptCode)
                        if fn then fn(); Notify("Executed", scriptName, 2, "success")
                        else Notify("Error", "Compile failed", 3, "error") end
                    end)
                else
                    Notify("Loading", "Fetching...", 2, "info")
                    task.spawn(function()
                        local data = safeLoad(BASE_URL .. "/" .. (Categories[categoryName] or ""))
                        if type(data) == "table" and #data > 0 then HubData[categoryName] = data; SetTab(categoryName); Notify("Loaded", "Done!", 2, "success")
                        else Notify("Error", "Failed to load", 3, "error") end
                    end)
                end
            end, hasCode and ThemeColors.Success or ThemeColors.NeonPrimary, 8)

            if hasCode then
                MkNeonButton(card, "📋", UDim2.new(0, 32, 0, 28), UDim2.new(1, -134, 0.5, -14), function()
                    if setclipboard then pcall(setclipboard, scriptCode); Notify("Copied", "Copied!", 2, "success") end
                end, ThemeColors.GlassLight, 8)
            end
        end
    end
end
