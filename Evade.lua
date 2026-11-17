local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local states = {
    respawn = false,
    revive = false,
    event = false,
    espNextbot = false,
    espPlayer = false
}

local espObjects = {}

task.spawn(function()
    while task.wait(1) do
        if states.respawn then
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not hum or hum.Health <= 0 then
                local respawnEvent = ReplicatedStorage:FindFirstChild("Events") 
                    and ReplicatedStorage.Events:FindFirstChild("Player") 
                    and ReplicatedStorage.Events.Player:FindFirstChild("ChangePlayerMode")
                if respawnEvent then
                    pcall(function() respawnEvent:FireServer(true) end)
                else
                    pcall(function() player:LoadCharacter() end)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if states.revive then
            pcall(function()
                if Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Settings") then
                    Workspace.Game.Settings:SetAttribute("ReviveTime", 2.2)
                end
            end)
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local action = string.lower(obj.ActionText or "")
                    if action:find("revive") or action:find("help") or action:find("heal") then
                        local promptPart = obj.Parent
                        if promptPart and promptPart:IsA("BasePart") then
                            if (hrp.Position - promptPart.Position).Magnitude < 15 then
                                pcall(function() fireproximityprompt(obj) end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if states.event then
            local collectables = Workspace:FindFirstChild("Collectables")
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if collectables and hrp then
                local closestToken = nil
                local shortestDist = math.huge
                for _, token in pairs(collectables:GetChildren()) do
                    if token.Name == "Token" and (token:IsA("Model") or token:IsA("BasePart")) then
                        local pos = token:IsA("Model") and token:GetPivot().Position or token.Position
                        local dist = (hrp.Position - pos).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closestToken = token
                        end
                    end
                end
                if closestToken then
                    local targetPos = closestToken:IsA("Model") and closestToken:GetPivot().Position or closestToken.Position
                    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
                end
            end
        end
    end
end)

local function createHighlight(instance, color)
    if espObjects[instance] then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "EvadeESP"
    highlight.Adornee = instance
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0
    highlight.Parent = instance
    espObjects[instance] = highlight
end

local function removeHighlights()
    for instance, highlight in pairs(espObjects) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    espObjects = {}
end

task.spawn(function()
    while task.wait(0.5) do
        if not states.espNextbot and not states.espPlayer then
            removeHighlights()
            continue
        end

        if states.espNextbot then
            local botFolder = Workspace:FindFirstChild("Players")
            if botFolder then
                for _, bot in pairs(botFolder:GetChildren()) do
                    if bot:IsA("Model") and not Players:FindFirstChild(bot.Name) then
                        createHighlight(bot, Color3.fromRGB(255, 0, 0))
                    end
                end
            end
        end

        if states.espPlayer then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    createHighlight(plr.Character, Color3.fromRGB(0, 255, 0))
                end
            end
        end
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "MainMenu"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(330, 280)
main.Position = UDim2.new(0.5, -165, 0.5, -140)
main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(55, 55, 55)
stroke.Thickness = 1
stroke.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
header.BorderSizePixel = 0
header.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.fromOffset(15, 0)
title.BackgroundTransparency = 1
title.Text = "EVADE"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(35, 35)
minimize.Position = UDim2.new(1, -78, 0, 3)
minimize.BackgroundTransparency = 1
minimize.Text = "—"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.TextSize = 22
minimize.Parent = header

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(35, 35)
close.Position = UDim2.new(1, -40, 0, 3)
close.BackgroundTransparency = 1
close.Text = "×"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 25
close.Parent = header

local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(0, 48)
content.Size = UDim2.new(1, 0, 1, -48)
content.BackgroundTransparency = 1
content.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = content

local function createToggle(name, stateKey)
    local enabled = false
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -24, 0, 43)
    row.BackgroundTransparency = 1
    row.Parent = content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(235, 235, 235)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(76, 29)
    button.Position = UDim2.new(1, -76, 0.5, -14)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.Text = "OFF"
    button.TextColor3 = Color3.fromRGB(170, 170, 170)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.AutoButtonColor = false
    button.Parent = row

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        states[stateKey] = enabled
        button.Text = enabled and "ON" or "OFF"
        button.BackgroundColor3 = enabled and Color3.fromRGB(235, 235, 235) or Color3.fromRGB(30, 30, 30)
        button.TextColor3 = enabled and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(170, 170, 170)
    end)
end

createToggle("Auto Respawn", "respawn")
createToggle("Auto Revive", "revive")
createToggle("Auto Event (Tokens)", "event")
createToggle("ESP Nextbot (Red)", "espNextbot")
createToggle("ESP Player (Green)", "espPlayer")

local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    main.Size = minimized and UDim2.fromOffset(330, 42) or UDim2.fromOffset(330, 280)
end)

close.MouseButton1Click:Connect(function()
    removeHighlights()
    gui:Destroy()
end)

local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
