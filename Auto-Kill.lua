-- // GUI Mini "Hutao Hub [Free]" - Draggable + Always on Top //
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Hàm kéo frame (PC + Mobile)
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Tạo ScreenGui (luôn trên cùng)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "HutaoHubMiniGUI"
ScreenGui.Parent = CoreGui

-- Frame chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 120)
MainFrame.Position = UDim2.new(0.4, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Tiêu đề
local Title = Instance.new("TextLabel")
Title.Text = "Hutao Hub [Free]"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Nút Auto Kill
local Toggle = Instance.new("TextButton")
Toggle.Text = "Auto Kill: OFF"
Toggle.Size = UDim2.new(1, -20, 0, 40)
Toggle.Position = UDim2.new(0, 10, 0, 40)
Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.Gotham
Toggle.TextSize = 14
Toggle.Parent = MainFrame
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)

-- Nút X
local HideBtn = Instance.new("TextButton")
HideBtn.Text = "X"
HideBtn.Size = UDim2.new(0, 20, 0, 20)
HideBtn.Position = UDim2.new(1, -25, 0, 5)
HideBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
HideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HideBtn.Font = Enum.Font.GothamBold
HideBtn.TextSize = 12
HideBtn.Parent = MainFrame
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(1, 0)

-- Nút tròn ☪
local CircleBtn = Instance.new("TextButton")
CircleBtn.Text = "☪"
CircleBtn.Size = UDim2.new(0, 40, 0, 40)
CircleBtn.Position = UDim2.new(0.5, 0, 0.5, 0)
CircleBtn.AnchorPoint = Vector2.new(0.5, 0.5)
CircleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
CircleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CircleBtn.Font = Enum.Font.GothamBold
CircleBtn.TextSize = 20
CircleBtn.Visible = false
CircleBtn.Parent = ScreenGui
Instance.new("UICorner", CircleBtn).CornerRadius = UDim.new(1, 0)

-- Cho phép kéo
makeDraggable(MainFrame, Title)
makeDraggable(CircleBtn, CircleBtn)

-- Ẩn/hiện GUI
local lastPos = MainFrame.Position
HideBtn.MouseButton1Click:Connect(function()
    lastPos = MainFrame.Position
    MainFrame.Visible = false
    CircleBtn.Visible = true
end)
CircleBtn.MouseButton1Click:Connect(function()
    MainFrame.Position = lastPos
    MainFrame.Visible = true
    CircleBtn.Visible = false
end)

-- Auto Kill logic
local Active = false
local loopRunning = false
local CurrentTarget = nil

local function GetClosestSurvivor()
    local localChar = LocalPlayer.Character
    if not (localChar and localChar:FindFirstChild("HumanoidRootPart")) then return nil end
    local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
    if not survivorsFolder then return nil end

    local closest, minDist = nil, math.huge
    for _, survivor in ipairs(survivorsFolder:GetChildren()) do
        local humanoid = survivor:FindFirstChildOfClass("Humanoid")
        if survivor:IsA("Model") and survivor:FindFirstChild("HumanoidRootPart") and humanoid and humanoid.Health > 0 then
            local dist = (localChar.HumanoidRootPart.Position - survivor.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = survivor
            end
        end
    end
    return closest
end

local function KillTarget(target)
    pcall(function()
        if not target then return end
        local localChar = LocalPlayer.Character
        if not (localChar and localChar:FindFirstChild("HumanoidRootPart")) then return end
        localChar.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local remote = ReplicatedStorage:FindFirstChild("Modules")
                      and ReplicatedStorage.Modules:FindFirstChild("Network")
                      and ReplicatedStorage.Modules.Network:FindFirstChild("RemoteEvent")
        if remote and typeof(remote.FireServer) == "function" then
            remote:FireServer("UseActorAbility", "Slash")
        end
    end)
end

local function StartLoop()
    if loopRunning then return end
    loopRunning = true
    task.spawn(function()
        while Active do
            if not CurrentTarget or not CurrentTarget.Parent or not CurrentTarget:FindFirstChildOfClass("Humanoid") or CurrentTarget:FindFirstChildOfClass("Humanoid").Health <= 0 then
                CurrentTarget = GetClosestSurvivor()
            end
            if CurrentTarget then
                KillTarget(CurrentTarget)
            end
            task.wait(0.01)
        end
        loopRunning = false
    end)
end

Toggle.MouseButton1Click:Connect(function()
    Active = not Active
    Toggle.Text = Active and "Auto Kill: ON" or "Auto Kill: OFF"
    if Active then StartLoop() end
end)
