local Player = game.Players.LocalPlayer
local Gui = Player:WaitForChild("PlayerGui")

-- Tạo GUI thông báo bị banned
local function showBannedMessage()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = Gui
    screenGui.Name = "BannedGui"
    
    local frame = Instance.new("Frame")
    frame.Parent = screenGui
    frame.Size = UDim2.new(0.5, 0, 0.3, 0)
    frame.Position = UDim2.new(0.25, 0, 0.35, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Nền đen
    frame.BorderSizePixel = 0
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "Anti-Ban & Bypass Anti-Cheats [On]"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.BackgroundTransparency = 1
    
    -- Chờ 0.1 giây rồi kick
    task.delay(0.1, function()
        Player:Kick("Warning if you repeat the offense you will be banned.")
    end)
end

-- Gọi hàm luôn (không cần nút)
showBannedMessage()
