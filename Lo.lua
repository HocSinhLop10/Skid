-- LINK_LOGIC.lua

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

-- trạng thái hiển thị
getgenv().ShowFPS = true
getgenv().ShowPing = true

-- tạo Drawing text
getgenv().FPSLabel = Drawing.new("Text")
getgenv().FPSLabel.Size = 16
getgenv().FPSLabel.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X - 100, 10)
getgenv().FPSLabel.Color = Color3.fromRGB(0, 255, 0)
getgenv().FPSLabel.Center = false
getgenv().FPSLabel.Outline = true
getgenv().FPSLabel.Visible = getgenv().ShowFPS

getgenv().PingLabel = Drawing.new("Text")
getgenv().PingLabel.Size = 16
getgenv().PingLabel.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X - 100, 30)
getgenv().PingLabel.Color = Color3.fromRGB(0, 255, 0)
getgenv().PingLabel.Center = false
getgenv().PingLabel.Outline = true
getgenv().PingLabel.Visible = getgenv().ShowPing

-- FPS Counter
local fpsCounter = 0
local fpsLastUpdate = tick()

RunService.RenderStepped:Connect(function()
    fpsCounter += 1
    if tick() - fpsLastUpdate >= 1 then
        -- FPS
        if getgenv().ShowFPS then
            getgenv().FPSLabel.Text = "FPS: " .. tostring(fpsCounter)
            getgenv().FPSLabel.Visible = true
        else
            getgenv().FPSLabel.Visible = false
        end

        -- Ping
        if getgenv().ShowPing then
            local pingStat = Stats.Network.ServerStatsItem["Data Ping"]
            local ping = pingStat and math.floor(pingStat:GetValue()) or 0
            getgenv().PingLabel.Text = "Ping: " .. ping .. " ms"

            if ping <= 60 then
                getgenv().PingLabel.Color = Color3.fromRGB(0, 255, 0)
            elseif ping <= 120 then
                getgenv().PingLabel.Color = Color3.fromRGB(255, 165, 0)
            else
                getgenv().PingLabel.Color = Color3.fromRGB(255, 0, 0)
            end

            getgenv().PingLabel.Visible = true
        else
            getgenv().PingLabel.Visible = false
        end

        fpsCounter = 0
        fpsLastUpdate = tick()
    end
end)
