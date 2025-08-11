-- // GUI Mini "Hutao Hub [Free]" - Fix draggable (PC + Mobile) //
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Hàm cho phép kéo frame (PC + Mobile)
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

-- Tạo ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "HutaoHubMiniGUI"

-- Frame chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 120)
MainFrame.Position = UDim2.new(0.4, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Tiêu đề
local Title = Instance.new("TextLabel")
Title.Text = "Hutao Hub [Free]"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Nút Toggle
local Toggle = Instance.new("TextButton")
Toggle.Text = "Auto Kill: OFF"
Toggle.Size = UDim2.new(1, -20, 0, 40)
Toggle.Position = UDim2.new(0, 10, 0, 40)
Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.Gotham
Toggle.TextSize = 14
Toggle.Parent = MainFrame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 8)
UICorner2.Parent = Toggle

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

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(1, 0)
UICorner3.Parent = HideBtn

-- Nút tròn ☪
local CircleBtn = Instance.new("TextButton")
CircleBtn.Text = "☪"
CircleBtn.Size = UDim2.new(0, 40, 0, 40)
CircleBtn.Position = UDim2.new(0.5, 0, 0.5, 0) -- Giữa màn hình
CircleBtn.AnchorPoint = Vector2.new(0.5, 0.5)
CircleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
CircleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CircleBtn.Font = Enum.Font.GothamBold
CircleBtn.TextSize = 20
CircleBtn.Visible = false
CircleBtn.Parent = ScreenGui

local UICorner4 = Instance.new("UICorner")
UICorner4.CornerRadius = UDim.new(1, 0)
UICorner4.Parent = CircleBtn

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

-- Script Auto Kill
local Active = false
local loopRunning = false

local function KillOnce()
    pcall(function()
        local localChar = Players.LocalPlayer.Character
        if not (localChar and localChar:FindFirstChild("HumanoidRootPart")) then return end
        local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
        if not survivorsFolder then return end
        for _, survivor in ipairs(survivorsFolder:GetChildren()) do
            if not Active then break end
            if survivor:IsA("Model") and survivor:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    localChar.HumanoidRootPart.CFrame = survivor.HumanoidRootPart.CFrame
                end)
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local remote = ReplicatedStorage:FindFirstChild("Modules")
                              and ReplicatedStorage.Modules:FindFirstChild("Network")
                              and ReplicatedStorage.Modules.Network:FindFirstChild("RemoteEvent")
                if remote and typeof(remote.FireServer) == "function" then
                    pcall(function() remote:FireServer("UseActorAbility", "Slash") end)
                end
                task.wait(0.05)
            end
        end
    end)
end

local function StartLoop()
    if loopRunning then return end
    loopRunning = true
    task.spawn(function()
        while Active do
            KillOnce()
            task.wait(0.15)
        end
        loopRunning = false
    end)
end

Toggle.MouseButton1Click:Connect(function()
    Active = not Active
    Toggle.Text = Active and "Auto Kill: ON" or "Auto Kill: OFF"
    if Active then StartLoop() end
end)
