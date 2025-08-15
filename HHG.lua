local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local HAND_HOLD_TIME = 2
local BOARD_TOTAL_TIME = 5
local LOADING_TIME = BOARD_TOTAL_TIME - 0.5 -- 4.5s

local IMAGE_ID = "rbxassetid://121468019965670"

local function getLeftShoulder(char)
    local leftUpperArm = char:FindFirstChild("LeftUpperArm")
    if leftUpperArm then
        return leftUpperArm:FindFirstChild("LeftShoulder")
    end
    local torso = char:FindFirstChild("Torso")
    if torso then
        return torso:FindFirstChild("Left Shoulder")
    end
    return nil
end

local function createLoadingBar()
    local gui = Instance.new("ScreenGui")
    gui.Name = "LoadingGui"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = player:WaitForChild("PlayerGui")

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0.42, 0, 0.06, 0)
    container.Position = UDim2.new(0.29, 0, 0.7, 0) -- cao hơn
    container.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    container.BorderSizePixel = 0
    container.ZIndex = 10
    container.Parent = gui

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Thickness = 4
    stroke.Transparency = 0
    stroke.Parent = container

    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bar.BorderSizePixel = 0
    bar.ZIndex = 11
    bar.Parent = container

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.AnchorPoint = Vector2.new(0.5, 1)
    label.Position = UDim2.new(0.5, 0, 0, -8) -- chữ cao hơn thanh 8px
    label.Size = UDim2.new(1, 0, 0, 24)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 22
    label.Text = "Loading."
    label.ZIndex = 12
    label.Parent = container

    task.spawn(function()
        local dots = {".", "..", "..."}
        local i = 1
        while gui.Parent do
            label.Text = "Loading" .. dots[i]
            i = (i % #dots) + 1
            task.wait(0.3)
        end
    end)

    local fillTween = TweenService:Create(
        bar,
        TweenInfo.new(LOADING_TIME, Enum.EasingStyle.Linear),
        {Size = UDim2.new(1, 0, 1, 0)}
    )
    fillTween:Play()

    return gui, container, bar, label, stroke, fillTween
end

local function create3DModel()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local leftShoulder = getLeftShoulder(char)

    local part = Instance.new("Part")
    part.Size = Vector3.new(2, 1.5, 0.1)
    part.Anchored = true
    part.CanCollide = false
    part.Color = Color3.fromRGB(0, 0, 0)
    part.Parent = workspace

    local decal = Instance.new("Decal")
    decal.Texture = IMAGE_ID
    decal.Face = Enum.NormalId.Front
    decal.Parent = part

    local upOffset = Vector3.new(0, 0.1, 0)
    local forwardOffset = 1.8
    local tiltAngleX = math.rad(-30) -- nghiêng ra sau
    local tiltAngleZ = math.rad(0)   -- nghiêng ngang nhẹ

    local rsConn
    rsConn = RunService.RenderStepped:Connect(function()
        if part.Parent and hrp then
            local lv = hrp.CFrame.LookVector
            local flatLook = Vector3.new(lv.X, 0, lv.Z).Unit
            local targetPos = hrp.Position + upOffset + flatLook * forwardOffset
            part.CFrame = CFrame.new(targetPos, targetPos + flatLook)
                * CFrame.Angles(tiltAngleX, math.rad(180), tiltAngleZ)
        end
    end)

    if leftShoulder and leftShoulder:IsA("Motor6D") then
        local originalC0 = leftShoulder.C0
        TweenService:Create(
            leftShoulder,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {C0 = originalC0 * CFrame.Angles(math.rad(50), 0, 0)}
        ):Play()

        task.delay(HAND_HOLD_TIME, function()
            TweenService:Create(
                leftShoulder,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {C0 = originalC0}
            ):Play()
        end)
    end

    local gui, container, bar, label, stroke, fillTween = createLoadingBar()

    fillTween.Completed:Connect(function()
        TweenService:Create(label, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(container, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(bar, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
        TweenService:Create(part, TweenInfo.new(0.5), {Size = Vector3.new(0, 0, 0)}):Play()

        task.delay(0.5, function()
            if rsConn then rsConn:Disconnect() end
            if gui then gui:Destroy() end
            if part then part:Destroy() end
        end)
    end)
end

create3DModel()
