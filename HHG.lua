local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local IMAGE_ID = "rbxassetid://121468019965670"

local function getRightShoulder(char)
    -- Nếu là R15
    local rightUpperArm = char:FindFirstChild("RightUpperArm")
    if rightUpperArm then
        return rightUpperArm:FindFirstChild("RightShoulder")
    end
    -- Nếu là R6
    local torso = char:FindFirstChild("Torso")
    if torso then
        return torso:FindFirstChild("Right Shoulder")
    end
    return nil
end

local function create3DModel()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local rightShoulder = getRightShoulder(char)

    -- Tạo bảng 3D
    local part = Instance.new("Part")
    part.Size = Vector3.new(2, 1.5, 0.2)
    part.Anchored = true
    part.CanCollide = false
    part.Color = Color3.fromRGB(0, 0, 0)
    part.Parent = workspace

    local decal = Instance.new("Decal")
    decal.Texture = IMAGE_ID
    decal.Face = Enum.NormalId.Front
    decal.Parent = part

    -- Vị trí bảng
    local upOffset = Vector3.new(0, 1.3, 0)
    local forwardOffset = 2

    RunService.RenderStepped:Connect(function()
        if part.Parent and hrp then
            local flatLook = Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z).Unit
            local targetPos = hrp.Position + upOffset + flatLook * forwardOffset
            part.CFrame = CFrame.new(targetPos, targetPos + flatLook) * CFrame.Angles(0, math.rad(180), 0)
        end
    end)

    -- Điều khiển tay
    if rightShoulder and rightShoulder:IsA("Motor6D") then
        local originalC0 = rightShoulder.C0

        -- Giơ tay cao hơn và hướng ra trước
        local pushTween = TweenService:Create(
            rightShoulder,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {C0 = originalC0 * CFrame.Angles(math.rad(60), math.rad(0), math.rad(0))}
        )
        pushTween:Play()

        -- Khi GUI bắt đầu thu nhỏ (sau 4.5s) → thu tay về
        task.delay(4.5, function()
            local backTween = TweenService:Create(
                rightShoulder,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {C0 = originalC0}
            )
            backTween:Play()

            -- Đồng thời thu nhỏ bảng
            if part.Parent then
                local tween = TweenService:Create(
                    part,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    {Size = Vector3.new(0, 0, 0)}
                )
                tween:Play()
                tween.Completed:Connect(function()
                    part:Destroy()
                end)
            end
        end)
    else
        warn("Không tìm thấy khớp tay phải để điều khiển!")
    end
end

create3DModel()
