-- AutoKillSurvivors.lua
if getgenv().AutoKillLoaded then return end
getgenv().AutoKillLoaded = true

if getgenv().ActiveAutoKillSurvivors == nil then
    getgenv().ActiveAutoKillSurvivors = false
end

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().ActiveAutoKillSurvivors then
            local localChar = game.Players.LocalPlayer.Character
            if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                for _, survivor in pairs(workspace.Players.Survivors:GetChildren()) do
                    if survivor:IsA("Model") and survivor:FindFirstChild("HumanoidRootPart") then
                        -- Dịch chuyển tới Survivor
                        localChar.HumanoidRootPart.CFrame = survivor.HumanoidRootPart.CFrame

                        -- Gửi sự kiện tấn công
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local RemoteEvent = ReplicatedStorage.Modules.Network:FindFirstChild("RemoteEvent")
                        if RemoteEvent then
                            RemoteEvent:FireServer("UseActorAbility", "Slash")
                        end
                    end
                end
            end
        end
    end
end)
