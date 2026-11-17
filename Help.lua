if not Drawing then return end

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local fps, frames, last = 60, 0, os.clock()
local ping = -1
local pingAccum, pingCount = 0, 0
local pingEnabled = true
local fpsEnabled = true

local function newText(pos, color)
    local t = Drawing.new("Text")
    t.Size = 16
    t.Outline = true
    t.OutlineColor = Color3.new(0, 0, 0)
    t.Center = false
    t.Transparency = 1
    t.Visible = true
    t.Position = pos
    t.Color = color
    return t
end

local fpsText = newText(Vector2.new(15, 15), Color3.fromRGB(120, 255, 140))
local pingText = newText(Vector2.new(15, 35), Color3.fromRGB(255, 255, 255))

local function getPing()
    local ok, val = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if ok and val and val > 0 then
        pingAccum = pingAccum + val
        pingCount = pingCount + 1
        return true
    end
    return false
end

RunService.RenderStepped:Connect(function()
    frames = frames + 1
    local now = os.clock()

    if now - last >= 0.5 then
        local cur = frames / (now - last)
        fps = fps + (cur - fps) * 0.3
        frames = 0
        last = now

        if fpsEnabled then
            fpsText.Text = string.format("FPS: %d", math.floor(fps + 0.5))
            if fps < 30 then
                fpsText.Color = Color3.fromRGB(255, 80, 80)
            elseif fps < 60 then
                fpsText.Color = Color3.fromRGB(255, 210, 80)
            else
                fpsText.Color = Color3.fromRGB(120, 255, 140)
            end
            fpsText.Visible = true
        else
            fpsText.Visible = false
        end

        getPing()
        if pingCount > 0 then
            ping = math.floor(pingAccum / pingCount)
            pingAccum, pingCount = 0, 0
        end

        if pingEnabled then
            pingText.Text = string.format("Ping: %d ms", ping)
            if ping < 60 then
                pingText.Color = Color3.fromRGB(120, 255, 140)
            elseif ping < 120 then
                pingText.Color = Color3.fromRGB(255, 210, 80)
            else
                pingText.Color = Color3.fromRGB(255, 80, 80)
            end
            pingText.Visible = true
        else
            pingText.Visible = false
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        fpsEnabled = not fpsEnabled
    elseif input.KeyCode == Enum.KeyCode.F2 then
        pingEnabled = not pingEnabled
    end
end)
