-- File: Hutao.lua
-- Script chính với 2 hàm: Enable() và Disable()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local Hutao = {}
local button, title, gui
local cooldown = false

-- ================== Cooldown ==================
local function startCooldown()
    local label = button:FindFirstChild("TextLabel")
    cooldown = true
    button.Active = false
    label.Visible = true

    -- 20 giây đầu
    for i = 20, 6, -1 do
        label.Text = tostring(i)
        task.wait(1)
    end

    -- 5 giây cuối (mili giây)
    local startTime = tick()
    while tick() - startTime < 5 do
        local remaining = 5 - (tick() - startTime)
        label.Text = string.format("%.1f", remaining)
        task.wait(0.05)
    end

    -- Reset
    label.Visible = false
    button.Active = true
    cooldown = false
end

-- ================== Teleport logic ==================
local HAND_HOLD_TIME = 2
local BOARD_TOTAL_TIME = 5
local LOADING_TIME = BOARD_TOTAL_TIME - 0.5 -- 4.5s
local IMAGE_ID = "rbxassetid://121468019965670"

local DangerousKillers = {
    ["Jason"] = true,
    ["1x1x1x1"] = true,
    ["c00lkidd"] = true,
    ["Noli"] = true,
    ["JohnDoe"] = true,
    ["Quest666"] = true
}

local KillerModels = {
    ["Noob"] = true,
    ["Guest1337"] = true,
    ["Elliot"] = true,
    ["Shedletsky"] = true,
    ["TwoTime"] = true,
    ["007n7"] = true,
    ["Chance"] = true,
    ["Builderman"] = true,
    ["Taph"] = true,
    ["Dusekkar"] = true,
}

local function nearestKillerDistance(pos)
    local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
    if not killersFolder then return 0 end

    local minDist = math.huge
    for _, killer in ipairs(killersFolder:GetChildren()) do
        if DangerousKillers[killer.Name] then
            local hrp = killer:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (pos - hrp.Position).Magnitude
                if d < minDist then
                    minDist = d
                end
            end
        end
    end
    return minDist
end

local function nearestSurvivorDistance(pos)
    local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
    if not survivorsFolder then return math.huge end

    local minDist = math.huge
    for _, survivor in ipairs(survivorsFolder:GetChildren()) do
        local hrp = survivor:FindFirstChild("HumanoidRootPart")
        if hrp then
            local d = (pos - hrp.Position).Magnitude
            if d < minDist then
                minDist = d
            end
        end
    end
    return minDist
end

local function teleportSmart()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local mapFolder = workspace:FindFirstChild("Map")
        and workspace.Map:FindFirstChild("Ingame")
        and workspace.Map.Ingame:FindFirstChild("Map")
    if not mapFolder then return end

    local bestGen, bestScore = nil, -math.huge
    local mode = "Survivor"

    -- Nếu player là Killer model trong list thì đổi mode
    if KillerModels[character.Name] then
        mode = "Killer"
    end

    for _, gen in ipairs(mapFolder:GetChildren()) do
        if gen.Name == "Generator" and gen:FindFirstChild("Progress") then
            local genPos = gen:GetPivot().Position
            local score
            if mode == "Survivor" then
                -- chọn generator xa killers
                score = nearestKillerDistance(genPos)
            else
                -- chọn generator gần survivors
                score = -nearestSurvivorDistance(genPos)
            end

            if score > bestScore then
                bestScore = score
                bestGen = gen
            end
        end
    end

    if bestGen then
        local goalPos = (bestGen:GetPivot() * CFrame.new(0, 0, -3)).Position
        character:PivotTo(CFrame.new(goalPos + Vector3.new(0, 2, 0)))
        print(("✅ Teleported (%s mode) đến generator %s"):format(mode, bestGen.Name))
    else
        warn("⚠️ Không tìm thấy Generator để teleport.")
    end
end

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
    container.Position = UDim2.new(0.29, 0, 0.7, 0)
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
    label.Position = UDim2.new(0.5, 0, 0, -8)
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
    local tiltAngleX = math.rad(-30)

    local rsConn
    rsConn = RunService.RenderStepped:Connect(function()
        if part.Parent and hrp then
            local lv = hrp.CFrame.LookVector
            local flatLook = Vector3.new(lv.X, 0, lv.Z).Unit
            local targetPos = hrp.Position + upOffset + flatLook * forwardOffset
            part.CFrame = CFrame.new(targetPos, targetPos + flatLook)
                * CFrame.Angles(tiltAngleX, math.rad(180), 0)
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

    task.delay(LOADING_TIME, function()
        teleportSmart()
    end)

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

-- ================== Khởi tạo GUI ==================
local function createGui()
    gui = Instance.new("ScreenGui")
    gui.Name = "CoolGui"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    button = Instance.new("ImageButton")
    button.Name = "CoolButton"
    button.Size = UDim2.new(0, 74.5, 0, 75.2)
    button.Position = UDim2.new(0.58, 0, 0.535, 0)
    button.BackgroundTransparency = 1
    button.Image = "rbxassetid://102274458242775"
    button.ImageTransparency = 0.15
    button.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.FontSize = Enum.FontSize.Size18
    label.Visible = false
    label.ZIndex = 3
    label.TextStrokeTransparency = 0.5
    label.Parent = button

    title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 75, 0, 15)
    title.Position = UDim2.new(0.58, 0, 0.71, 0)
    title.BackgroundTransparency = 1
    title.Text = "HutaoGui"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.ZIndex = 5
    title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    title.TextStrokeTransparency = 0.2
    title.Parent = gui

    button.MouseButton1Click:Connect(function()
        if cooldown then return end
        create3DModel()
        startCooldown()
    end)
end

-- ================== Public APIs ==================
function Hutao.Enable()
    if not gui then
        createGui()
    else
        gui.Enabled = true
    end
end

function Hutao.Disable()
    if gui then
        gui.Enabled = false
    end
end

return Hutao
