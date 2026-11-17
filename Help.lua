local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local BLACK = Color3.fromRGB(15, 15, 15)
local WHITE = Color3.fromRGB(255, 255, 255)
local GRAY = Color3.fromRGB(80, 80, 80)
local DARK_GRAY = Color3.fromRGB(45, 45, 45)

local showStats = false
local currentFPS = 0
local currentPing = 0

local hudGui = Instance.new("ScreenGui")
hudGui.Name = "CC_HUD"
hudGui.ResetOnSpawn = false
hudGui.Parent = PlayerGui

local hudFrame = Instance.new("Frame")
hudFrame.Size = UDim2.fromOffset(100, 40)
hudFrame.Position = UDim2.new(0, 15, 0, 15)
hudFrame.BackgroundColor3 = BLACK
hudFrame.BackgroundTransparency = 0.3
hudFrame.BorderSizePixel = 0
hudFrame.Active = true
hudFrame.Visible = false
hudFrame.Parent = hudGui

local hudCorner = Instance.new("UICorner")
hudCorner.CornerRadius = UDim.new(0, 6)
hudCorner.Parent = hudFrame

local hudLabel = Instance.new("TextLabel")
hudLabel.Size = UDim2.new(1, -10, 1, 0)
hudLabel.Position = UDim2.new(0, 5, 0, 0)
hudLabel.BackgroundTransparency = 1
hudLabel.TextColor3 = WHITE
hudLabel.TextSize = 12
hudLabel.Font = Enum.Font.GothamBold
hudLabel.TextXAlignment = Enum.TextXAlignment.Center
hudLabel.TextYAlignment = Enum.TextYAlignment.Center
hudLabel.Text = "FPS: 0\nPing: 0 ms"
hudLabel.Parent = hudFrame

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CC_Menu"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(280, 150)
main.Position = UDim2.new(0.5, -140, 0.5, -75)
main.BackgroundColor3 = BLACK
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 6)
mainCorner.Parent = main

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = BLACK
topBar.BorderSizePixel = 0
topBar.Parent = main

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 2)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = WHITE
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = topBar
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    hudGui:Destroy()
end)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.fromOffset(30, 30)
minBtn.Position = UDim2.new(1, -65, 0, 2)
minBtn.BackgroundTransparency = 1
minBtn.Text = "—"
minBtn.TextColor3 = WHITE
minBtn.TextSize = 14
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = topBar

local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1, -10, 0, 25)
tabsFrame.Position = UDim2.new(0, 5, 0, 35)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = main

local function createTab(text, xOffset)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(0, 60, 1, 0)
    tab.Position = UDim2.new(0, xOffset, 0, 0)
    tab.BackgroundTransparency = 1
    tab.Text = text
    tab.TextColor3 = GRAY
    tab.TextSize = 12
    tab.Font = Enum.Font.GothamBold
    tab.Parent = tabsFrame
    return tab
end

local homeTab = createTab("Home", 5)
local visualTab = createTab("Visual", 70)
local miscTab = createTab("Misc", 135)
local configTab = createTab("Config", 200)

local line = Instance.new("Frame")
line.Size = UDim2.new(1, -10, 0, 1)
line.Position = UDim2.new(0, 5, 0, 60)
line.BackgroundColor3 = DARK_GRAY
line.BorderSizePixel = 0
line.Parent = main

local tabIndicator = Instance.new("Frame")
tabIndicator.Size = UDim2.new(0, 40, 0, 2)
tabIndicator.Position = UDim2.new(0, 15, 0, 59)
tabIndicator.BackgroundColor3 = WHITE
tabIndicator.BorderSizePixel = 0
tabIndicator.Parent = main

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -10, 1, -70)
contentFrame.Position = UDim2.new(0, 5, 0, 65)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = main

local function selectTab(tabBtn, container, xOffset)
    for _, t in ipairs({homeTab, visualTab, miscTab, configTab}) do
        t.TextColor3 = GRAY
    end
    tabBtn.TextColor3 = WHITE
    
    TweenService:Create(tabIndicator, TweenInfo.new(0.2), {Position = UDim2.new(0, xOffset, 0, 59)}):Play()
    
    for _, c in ipairs(contentFrame:GetChildren()) do
        if c:IsA("Frame") then
            c.Visible = false
        end
    end
    container.Visible = true
end

local homeContainer = Instance.new("Frame")
homeContainer.Size = UDim2.new(1, 0, 1, 0)
homeContainer.BackgroundTransparency = 1
homeContainer.Parent = contentFrame

local visualContainer = Instance.new("Frame")
visualContainer.Size = UDim2.new(1, 0, 1, 0)
visualContainer.BackgroundTransparency = 1
visualContainer.Visible = false
visualContainer.Parent = contentFrame

local miscContainer = Instance.new("Frame")
miscContainer.Size = UDim2.new(1, 0, 1, 0)
miscContainer.BackgroundTransparency = 1
miscContainer.Visible = false
miscContainer.Parent = contentFrame

local configContainer = Instance.new("Frame")
configContainer.Size = UDim2.new(1, 0, 1, 0)
configContainer.BackgroundTransparency = 1
configContainer.Visible = false
configContainer.Parent = contentFrame

homeTab.MouseButton1Click:Connect(function() selectTab(homeTab, homeContainer, 15) end)
visualTab.MouseButton1Click:Connect(function() selectTab(visualTab, visualContainer, 80) end)
miscTab.MouseButton1Click:Connect(function() selectTab(miscTab, miscContainer, 145) end)
configTab.MouseButton1Click:Connect(function() selectTab(configTab, configContainer, 210) end)

local function createToggle(parent, name, defaultState, callback, yOffset)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 30)
    row.Position = UDim2.new(0, 0, 0, yOffset)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = WHITE
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.fromOffset(34, 18)
    toggleBg.Position = UDim2.new(1, -34, 0.5, -9)
    toggleBg.BackgroundColor3 = defaultState and WHITE or DARK_GRAY
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = row
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = toggleBg

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 14)
    knob.Position = defaultState and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = defaultState and BLACK or WHITE
    knob.BorderSizePixel = 0
    knob.Parent = toggleBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.Parent = row

    local state = defaultState
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    local function setState(newState)
        state = newState
        if state then
            TweenService:Create(toggleBg, tweenInfo, {BackgroundColor3 = WHITE}):Play()
            TweenService:Create(knob, tweenInfo, {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = BLACK}):Play()
        else
            TweenService:Create(toggleBg, tweenInfo, {BackgroundColor3 = DARK_GRAY}):Play()
            TweenService:Create(knob, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = WHITE}):Play()
        end
        if callback then callback(state) end
    end

    clickArea.MouseButton1Click:Connect(function()
        setState(not state)
    end)
end

createToggle(homeContainer, "fps+ping", false, function(state)
    showStats = state
    hudFrame.Visible = state
end, 10)

local frames = 0
local lastTime = tick()

RunService.RenderStepped:Connect(function()
    frames = frames + 1
    if tick() - lastTime >= 1 then
        currentFPS = frames
        frames = 0
        lastTime = tick()
    end
end)

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            currentPing = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
    end
end)

RunService.RenderStepped:Connect(function()
    if showStats then
        hudLabel.Text = "FPS: " .. currentFPS .. "\nPing: " .. currentPing .. " ms"
    end
end)

local dragging = false
local dragStart = nil
local startPos = nil

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local hudDragging = false
local hudDragStart = nil
local hudStartPos = nil

hudFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        hudDragging = true
        hudDragStart = input.Position
        hudStartPos = hudFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if hudDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - hudDragStart
        hudFrame.Position = UDim2.new(hudStartPos.X.Scale, hudStartPos.X.Offset + delta.X, hudStartPos.Y.Scale, hudStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        hudDragging = false
    end
end)

local isMinimized = false
local originalSize = UDim2.fromOffset(280, 150)
local minimizedSize = UDim2.fromOffset(280, 35)

minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(main, TweenInfo.new(0.2), {Size = minimizedSize}):Play()
        minBtn.Text = "+"
        tabsFrame.Visible = false
        line.Visible = false
        tabIndicator.Visible = false
        contentFrame.Visible = false
    else
        TweenService:Create(main, TweenInfo.new(0.2), {Size = originalSize}):Play()
        minBtn.Text = "—"
        tabsFrame.Visible = true
        line.Visible = true
        tabIndicator.Visible = true
        contentFrame.Visible = true
    end
end)
