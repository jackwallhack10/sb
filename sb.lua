local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fluent " .. Fluent.Version,
    SubTitle = "by dawid",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "crosshair" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

local highlights = {}
local drawingNameTags = {}
local drawingToolTags = {}

-- ESP and Visual helper functions unchanged (same as above) -------------
local function AddHighlightESP()
    for _, highlight in ipairs(highlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    highlights = {}

    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            local character = player.Character
            if not character:FindFirstChild("FluentHighlightESPBox") then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = character
                highlight.FillColor = Color3.new(1,1,1)
                highlight.OutlineColor = Color3.new(1,1,1)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Name = "FluentHighlightESPBox"
                highlight.Parent = character
                table.insert(highlights, highlight)
            end
        end
    end
end

local function RemoveHighlightESP()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            local character = player.Character
            local highlight = character:FindFirstChild("FluentHighlightESPBox")
            if highlight then
                highlight:Destroy()
            end
        end
    end
    highlights = {}
end

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")

local function RemoveNameEspDrawings()
    for plr, drawing in pairs(drawingNameTags) do
        if drawing and typeof(drawing.Remove) == "function" then
            drawing:Remove()
        elseif drawing and typeof(drawing.Destroy) == "function" then
            drawing:Destroy()
        elseif drawing then
            pcall(function() drawing.Visible = false end)
            pcall(function() drawing.Text = "" end)
            drawing = nil
        end
        drawingNameTags[plr] = nil
    end
end

local function RemoveToolEspDrawings()
    for plr, drawing in pairs(drawingToolTags) do
        if drawing and typeof(drawing.Remove) == "function" then
            drawing:Remove()
        elseif drawing and typeof(drawing.Destroy) == "function" then
            drawing:Destroy()
        elseif drawing then
            pcall(function() drawing.Visible = false end)
            pcall(function() drawing.Text = "" end)
            drawing = nil
        end
        drawingToolTags[plr] = nil
    end
end

local NameEspConnection
local ToolEspConnection

local function AddNameESP()
    RemoveNameEspDrawings()
    if NameEspConnection then NameEspConnection:Disconnect() end

    NameEspConnection = RunService.RenderStepped:Connect(function()
        Camera = workspace.CurrentCamera
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local yOffset = 3.2
                local posName, onScreenName = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, yOffset, 0))
                if not drawingNameTags[player] then
                    if Drawing then
                        local txt = Drawing.new("Text")
                        txt.Color = Color3.new(1, 1, 1)
                        txt.Size = 14
                        txt.Center = true
                        txt.Outline = true
                        txt.Font = 2
                        drawingNameTags[player] = txt
                    end
                end
                local drawingName = drawingNameTags[player]
                if drawingName then
                    if onScreenName and player.Character:FindFirstChild("Head") then
                        drawingName.Text = player.Name
                        drawingName.Position = Vector2.new(posName.X, posName.Y)
                        drawingName.Visible = true
                        drawingName.Color = Color3.new(1, 1, 1)
                    else
                        drawingName.Visible = false
                    end
                end
            else
                local drawingName = drawingNameTags[player]
                if drawingName then
                    if typeof(drawingName.Remove) == "function" then
                        drawingName:Remove()
                    elseif typeof(drawingName.Destroy) == "function" then
                        drawingName:Destroy()
                    else
                        pcall(function() drawingName.Visible = false end)
                        pcall(function() drawingName.Text = "" end)
                    end
                    drawingNameTags[player] = nil
                end
            end
        end
    end)
end

local function RemoveNameESP()
    if NameEspConnection then
        NameEspConnection:Disconnect()
        NameEspConnection = nil
    end
    RemoveNameEspDrawings()
end

local function AddToolESP()
    RemoveToolEspDrawings()
    if ToolEspConnection then ToolEspConnection:Disconnect() end
    ToolEspConnection = RunService.RenderStepped:Connect(function()
        Camera = workspace.CurrentCamera
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local character = player.Character
                local head = character.Head
                local lowestY = math.huge
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        local y = part.Position.Y - part.Size.Y / 2
                        if y < lowestY then
                            lowestY = y
                        end
                    end
                end
                if lowestY == math.huge then lowestY = head.Position.Y - 3.2 end
                local posTool, onScreenTool = Camera:WorldToViewportPoint(Vector3.new(head.Position.X, lowestY, head.Position.Z))
                if not drawingToolTags[player] then
                    if Drawing then
                        local txt = Drawing.new("Text")
                        txt.Color = Color3.new(1, 1, 1)
                        txt.Size = 12
                        txt.Center = true
                        txt.Outline = true
                        txt.Font = 2
                        drawingToolTags[player] = txt
                    end
                end
                local drawingTool = drawingToolTags[player]
                if drawingTool then
                    if onScreenTool and player.Character:FindFirstChild("Head") then
                        local toolName = ""
                        local equippedTool = nil
                        for _, item in ipairs(character:GetChildren()) do
                            if item:IsA("Tool") then
                                equippedTool = item
                                break
                            end
                        end
                        if equippedTool then
                            toolName = equippedTool.Name
                        else
                            local backpack = player:FindFirstChildOfClass("Backpack")
                            if backpack then
                                for _, item in ipairs(backpack:GetChildren()) do
                                    if item:IsA("Tool") then
                                        toolName = item.Name
                                        break
                                    end
                                end
                            end
                        end
                        drawingTool.Text = toolName ~= "" and toolName or ""
                        drawingTool.Position = Vector2.new(posTool.X, posTool.Y + 7)
                        drawingTool.Visible = toolName ~= ""
                        drawingTool.Color = Color3.new(1, 1, 1)
                    else
                        drawingTool.Visible = false
                    end
                end
            else
                local drawingTool = drawingToolTags[player]
                if drawingTool then
                    if typeof(drawingTool.Remove) == "function" then
                        drawingTool:Remove()
                    elseif typeof(drawingTool.Destroy) == "function" then
                        drawingTool:Destroy()
                    else
                        pcall(function() drawingTool.Visible = false end)
                        pcall(function() drawingTool.Text = "" end)
                    end
                    drawingToolTags[player] = nil
                end
            end
        end
    end)
end

local function RemoveToolESP()
    if ToolEspConnection then
        ToolEspConnection:Disconnect()
        ToolEspConnection = nil
    end
    RemoveToolEspDrawings()
end

local function SetupHighlightCharAdded(player)
    return player.CharacterAdded:Connect(function()
        if Options.HighlightESP and Options.HighlightESP.Value then
            task.wait(0.5)
            AddHighlightESP()
        end
    end)
end

local function SetupNameCharAdded(player)
    return player.CharacterAdded:Connect(function()
        if Options.NameESP and Options.NameESP.Value then
            task.wait(0.5)
            AddNameESP()
        end
    end)
end

local function SetupToolCharAdded(player)
    return player.CharacterAdded:Connect(function()
        if Options.ToolESP and Options.ToolESP.Value then
            task.wait(0.5)
            AddToolESP()
        end
    end)
end

local HighlightToggle = Tabs.Visuals:AddToggle("HighlightESP", {
    Title = "Highlight ESP",
    Default = false
})

local NameEspToggle = Tabs.Visuals:AddToggle("NameESP", {
    Title = "Name ESP",
    Default = false
})

local ToolEspToggle = Tabs.Visuals:AddToggle("ToolESP", {
    Title = "Tool ESP",
    Default = false
})

-- ===== Sticky & Smooth Aimlock =====

local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Aimlock = false
local aimbotBindKey = Enum.KeyCode.RightAlt
local aimbotHold = true -- true: hold, false: toggle
local aimbotEnabled = false

local smoothness = 0.11 -- Lower is more smooth, but sticky feel comes from stickinessFactor
local stickinessRadius = 85 -- Pixels: within this range aim "sticks" hard to target
local stickinessStrength = 0.48 -- 0.0-1.0; Higher is stickier, lower is more slidey

local stickyTarget = nil
local lostTargetTimer = 0
local stickyTimeout = 0.22 -- seconds to keep sticking after going slightly out of range

-- Get closest head and also tell how far (screen dist)
local function getClosestHead()
    local mousePos = UserInputService:GetMouseLocation()
    local closestDist = math.huge
    local closestHead = nil

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestHead = head
                end
            end
        end
    end

    return closestHead, closestDist
end

-- Smoother mouse movement with proper rounding accumulation
local function smoothMove(deltaX, deltaY, smoothness)
    local steps = math.max(2, math.floor(math.clamp((math.abs(deltaX) + math.abs(deltaY)) * smoothness, 3, 32)))
    if steps == 0 then return end
    local stepX = deltaX / steps
    local stepY = deltaY / steps

    -- Accumulate fractional movement for perfect smoothness
    local accumX, accumY = 0, 0
    for i = 1, steps do
        accumX = accumX + stepX
        accumY = accumY + stepY
        local moveX = math.floor(accumX + 0.5)
        local moveY = math.floor(accumY + 0.5)
        accumX = accumX - moveX
        accumY = accumY - moveY
        if (moveX ~= 0 or moveY ~= 0) then
            if syn and syn.mousemoverel then
                syn.mousemoverel(moveX, moveY)
            elseif mousemoverel then
                mousemoverel(moveX, moveY)
            end
        end
        RunService.RenderStepped:Wait()
    end
end

-- Smart sticky aim: blends smoothly but "snaps" as you stay near the target
local function aimAtSticky(part, distToMouse)
    if part then
        local screenPoint = Camera:WorldToViewportPoint(part.Position)
        local mousePos = UserInputService:GetMouseLocation()
        local deltaX = screenPoint.X - mousePos.X
        local deltaY = screenPoint.Y - mousePos.Y

        local stickyStrength = 1
        if distToMouse < stickinessRadius then
            -- The closer we are, the more sticky we get, up to stickinessStrength
            stickyStrength = stickinessStrength + (1 - stickinessStrength)*(1 - distToMouse/stickinessRadius)
        end

        -- Lerp (stickyStrength = snappy, 1 = normal smooth)
        local stickyDeltaX = deltaX * stickyStrength
        local stickyDeltaY = deltaY * stickyStrength

        -- Move only if not extremely close
        if math.abs(deltaX) > 1 or math.abs(deltaY) > 1 then
            smoothMove(stickyDeltaX, stickyDeltaY, smoothness)
        end
    end
end

-- Aimbot loop function
local aimbotThread = nil
local function startAimbotLoop()
    if aimbotThread then return end
    
    aimbotThread = task.spawn(function()
        while Aimlock or (aimbotEnabled and not aimbotHold) do
            local head, dist = getClosestHead()

            -- Sticky logic: if we have a stickyTarget, check if still valid
            if stickyTarget and stickyTarget.Parent and stickyTarget:IsDescendantOf(workspace) then
                local screenPoint, visible = Camera:WorldToViewportPoint(stickyTarget.Position)
                if visible then
                    local mousePos = UserInputService:GetMouseLocation()
                    local stickyDist = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                    if stickyDist <= stickinessRadius or lostTargetTimer < stickyTimeout then
                        -- Stick!
                        aimAtSticky(stickyTarget, stickyDist)
                        if stickyDist > stickinessRadius then
                            lostTargetTimer = lostTargetTimer + 0.016
                        else
                            lostTargetTimer = 0
                        end
                    else
                        -- Loose sticky because out of range
                        stickyTarget = (head ~= stickyTarget and head) or nil
                        lostTargetTimer = 0
                    end
                else
                    -- Head not visible, break sticky
                    stickyTarget = (head ~= stickyTarget and head) or nil
                    lostTargetTimer = 0
                end
            else
                -- Acquire new target to stick to
                stickyTarget = head
                lostTargetTimer = 0
            end

            RunService.RenderStepped:Wait()
        end
        aimbotThread = nil
    end)
end

local function stopAimbotLoop()
    Aimlock = false
    stickyTarget = nil
    lostTargetTimer = 0
end

-- Fluent UI for aimbot options
local AimTab = Tabs.Aimbot

local AimbotToggle = AimTab:AddToggle("AimbotEnabled", {
    Title = "Aimbot",
    Default = false
})

local AimbotMode = AimTab:AddDropdown("AimbotMode", {
    Title = "Mode",
    Values = {"Hold", "Toggle"},
    Default = 1,
    Multi = false
})

local Keybind = AimTab:AddKeybind("AimbotKey", {
    Title = "Aimbot Key",
    Default = "RightAlt"
})

local inputDownConn, inputUpConn

local function disconnectKeys()
    if inputDownConn then inputDownConn:Disconnect() end
    if inputUpConn then inputUpConn:Disconnect() end
    inputDownConn, inputUpConn = nil, nil
end

local function bindKeys()
    disconnectKeys()
    
    inputDownConn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == aimbotBindKey then
            if aimbotHold then
                Aimlock = true
                stickyTarget = nil
                lostTargetTimer = 0
                startAimbotLoop()
            else
                aimbotEnabled = not aimbotEnabled
                if aimbotEnabled then
                    startAimbotLoop()
                else
                    stopAimbotLoop()
                end
            end
        end
    end)
    
    inputUpConn = UserInputService.InputEnded:Connect(function(input, gp)
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == aimbotBindKey then
            if aimbotHold then
                stopAimbotLoop()
            end
        end
    end)
end

AimbotToggle:OnChanged(function(state)
    if state then
        if aimbotHold then
            bindKeys()
        else
            aimbotEnabled = true
            startAimbotLoop()
            bindKeys()
        end
    else
        stopAimbotLoop()
        disconnectKeys()
        aimbotEnabled = false
    end
end)

AimbotMode:OnChanged(function(mode)
    if mode == "Hold" then
        aimbotHold = true
        aimbotEnabled = false
        stopAimbotLoop()
    else
        aimbotHold = false
        stopAimbotLoop()
        if AimbotToggle.Value then
            aimbotEnabled = true
            startAimbotLoop()
        end
    end
    if AimbotToggle.Value then
        bindKeys()
    end
end)

Keybind:OnChanged(function(val)
    if typeof(val) == "EnumItem" and val.EnumType == Enum.KeyCode then
        aimbotBindKey = val
    elseif typeof(val) == "string" and Enum.KeyCode[val] then
        aimbotBindKey = Enum.KeyCode[val]
    end
    if AimbotToggle.Value then
        bindKeys()
    end
end)

-- ========== END REPLACEMENT ==========

local highlightCharConns = {}
local nameCharConns = {}
local toolCharConns = {}

HighlightToggle:OnChanged(function(state)
    if state then
        AddHighlightESP()
        if not highlightCharConns._playerAdded then
            highlightCharConns._playerAdded = Players.PlayerAdded:Connect(function(plr)
                highlightCharConns[plr] = SetupHighlightCharAdded(plr)
            end)
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= Players.LocalPlayer and not highlightCharConns[plr] then
                    highlightCharConns[plr] = SetupHighlightCharAdded(plr)
                end
            end
        end
    else
        RemoveHighlightESP()
        if highlightCharConns._playerAdded then
            highlightCharConns._playerAdded:Disconnect()
            highlightCharConns._playerAdded = nil
        end
        for plr, conn in pairs(highlightCharConns) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
            highlightCharConns[plr] = nil
        end
    end
end)

NameEspToggle:OnChanged(function(state)
    if state then
        AddNameESP()
        if not nameCharConns._playerAdded then
            nameCharConns._playerAdded = Players.PlayerAdded:Connect(function(plr)
                nameCharConns[plr] = SetupNameCharAdded(plr)
            end)
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= Players.LocalPlayer and not nameCharConns[plr] then
                    nameCharConns[plr] = SetupNameCharAdded(plr)
                end
            end
        end
    else
        RemoveNameESP()
        if nameCharConns._playerAdded then
            nameCharConns._playerAdded:Disconnect()
            nameCharConns._playerAdded = nil
        end
        for plr, conn in pairs(nameCharConns) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
            nameCharConns[plr] = nil
        end
    end
end)

ToolEspToggle:OnChanged(function(state)
    if state then
        AddToolESP()
        if not toolCharConns._playerAdded then
            toolCharConns._playerAdded = Players.PlayerAdded:Connect(function(plr)
                toolCharConns[plr] = SetupToolCharAdded(plr)
            end)
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= Players.LocalPlayer and not toolCharConns[plr] then
                    toolCharConns[plr] = SetupToolCharAdded(plr)
                end
            end
        end
    else
        RemoveToolESP()
        if toolCharConns._playerAdded then
            toolCharConns._playerAdded:Disconnect()
            toolCharConns._playerAdded = nil
        end
        for plr, conn in pairs(toolCharConns) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
            toolCharConns[plr] = nil
        end
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
