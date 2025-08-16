-- File: Hutao.lua
-- Author: bạn và mình 😎
-- Mô tả: GUI Hutao teleport + cooldown + auto chọn generator

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local Hutao = {}
local gui, button, title
local cooldown = false

-- ================== Danh sách nhân vật ==================
local DangerousKillers = {
    ["Jason"] = true,
    ["1x1x1x1"] = true,
    ["c00lkidd"] = true,
    ["Noli"] = true,
    ["JohnDoe"] = true,
    ["Quest666"] = true
}

local SurvivorsList = {
    ["Noob"] = true,
    ["Guest1337"] = true,
    ["Elliot"] = true,
    ["Shedletsky"] = true,
    ["TwoTime"] = true,
    ["007n7"] = true,
    ["Chance"] = true,
    ["Builderman"] = true,
    ["Taph"] = true,
    ["Dusekkar"] = true
}

-- ================== Utility ==================
local function nearestDistanceToFolder(pos, folder, allowedNames)
    if not folder then return math.huge end
    local minDist = math.huge
    for _, obj in ipairs(folder:GetChildren()) do
        if allowedNames[obj.Name] then
            local hrp = obj:FindFirstChild("HumanoidRootPart")
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

-- ================== Teleport logic ==================
local function teleportToBestGenerator()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local mapFolder = workspace:FindFirstChild("Map")
        and workspace.Map:FindFirstChild("Ingame")
        and workspace.Map.Ingame:FindFirstChild("Map")
    if not mapFolder then return end

    local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
    local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")

    -- Xác định LocalPlayer là Killer hay Survivor
    local isKiller = DangerousKillers[player.Name] or false

    local bestGen, bestScore
    if isKiller then
        -- Killer: chọn generator gần Survivors nhất
        bestScore = math.huge
        for _, gen in ipairs(mapFolder:GetChildren()) do
            if gen.Name == "Generator" and gen:FindFirstChild("Progress") then
                local genPos = gen:GetPivot().Position
                local distToSurvivors = nearestDistanceToFolder(genPos, survivorsFolder, SurvivorsList)
                if distToSurvivors < bestScore then
                    bestScore = distToSurvivors
                    bestGen = gen
                end
            end
        end
    else
        -- Survivor: chọn generator xa Killers nhất
        bestScore = -math.huge
        for _, gen in ipairs(mapFolder:GetChildren()) do
            if gen.Name == "Generator" and gen:FindFirstChild("Progress") then
                local genPos = gen:GetPivot().Position
                local distToKillers = nearestDistanceToFolder(genPos, killersFolder, DangerousKillers)
                if distToKillers > bestScore then
                    bestScore = distToKillers
                    bestGen = gen
                end
            end
        end
    end

    if bestGen then
        local goalPos = (bestGen:GetPivot() * CFrame.new(0, 0, -3)).Position
        character:PivotTo(CFrame.new(goalPos + Vector3.new(0, 2, 0)))

        if isKiller then
            print(("😈 Killer teleport tới generator gần Survivors nhất (%.1f studs)"):format(bestScore))
        else
            print(("🛡️ Survivor teleport tới generator xa Killers nhất (%.1f studs)"):format(bestScore))
        end
    else
        warn("⚠️ Không tìm thấy Generator phù hợp để teleport.")
    end
end

-- ================== Cooldown ==================
local function startCooldown()
    local label = button:FindFirstChild("TextLabel")
    cooldown = true
    button.Active = false
    label.Visible = true

    for i = 20, 6, -1 do
        label.Text = tostring(i)
        task.wait(1)
    end

    local startTime = tick()
    while tick() - startTime < 5 do
        local remaining = 5 - (tick() - startTime)
        label.Text = string.format("%.1f", remaining)
        task.wait(0.05)
    end

    label.Visible = false
    button.Active = true
    cooldown = false
end

-- ================== Hiệu ứng 3D (placeholder) ==================
local function create3DModel()
    teleportToBestGenerator()
    -- Bạn có thể chèn thêm hiệu ứng 3D ở đây nếu muốn
end

-- ================== Tạo GUI ==================
local function createGui()
    gui = Instance.new("ScreenGui")
    gui.Name = "HutaoGui"
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

-- ================== Public API ==================
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
