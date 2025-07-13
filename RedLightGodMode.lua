-- 🔁 Red Light Green Light God Mode [Link version]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Client = Players.LocalPlayer

local IsGreenLight = false
local LastRootPartCFrame = nil

-- ✅ Kiểm tra đèn đỏ
task.spawn(function()
    local gui = Client:WaitForChild("PlayerGui"):WaitForChild("ImpactFrames"):WaitForChild("TrafficLightEmpty")
    local GreenImage = ReplicatedStorage.Effects.Images.TrafficLights.GreenLight.Image

    ReplicatedStorage.Remotes.Effects.OnClientEvent:Connect(function(data)
        if data.EffectName == "TrafficLight" then
            IsGreenLight = data.GreenLight == true or gui.Image == GreenImage
            local Root = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
            LastRootPartCFrame = Root and Root.CFrame
        end
    end)
end)

-- ✅ Hook namecall
if not getgenv().RedLightGodModeHooked then
    getgenv().RedLightGodModeHooked = true

    local mt = getrawmetatable(game)
    setreadonly(mt, false)

    local old = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = { ... }

        if method == "FireServer" and self.Name == "rootCFrame" then
            if IsGreenLight == false and LastRootPartCFrame then
                args[1] = LastRootPartCFrame
                return old(self, unpack(args))
            end
        end

        return old(self, ...)
    end)

    setreadonly(mt, true)
end
