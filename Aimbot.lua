-- Đặt LocalScript này vào StarterPlayerScripts hoặc StarterCharacterScripts trong Roblox Studio
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ==================== CẤU HÌNH BAN ĐẦU ====================
local Config = {
    AimbotEnabled = true,
    AimKey = Enum.UserInputType.MouseButton2,
    FOV = 150,
    Smoothness = 0.15,
    TargetPart = "Head",
    
    ESPEnabled = true,
    ESPColor = Color3.fromRGB(0, 255, 150), -- Đổi sang màu xanh Neon cho hợp tone GUI
    FillOpacity = 0.25,
    OutlineOpacity = 0.9
}

local IsAiming = false
local MenuVisible = true

-- ==================== TẠO GIAO DIỆN (GUI) PHẦN CỨNG ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CheatHubMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Khung chính của Menu
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 320)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Bo góc cho khung chính
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Thanh Tiêu đề (Dùng để kéo menu di chuyển)
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.Text = "  PREMIUM HUB v1.0"
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.Font = Enum.Font.SourceSansBold
TitleBar.TextSize = 16
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

-- Thêm tính năng Kéo thả (Drag) mượt mà cho Menu
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Hàm tạo Nút Bật/Tắt (Toggle Button)
local function CreateToggle(name, text, position, default, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(0, 220, 0, 35)
    Button.Position = position
    Button.Font = Enum.Font.SourceSansSemibold
    Button.TextSize = 15
    Button.BorderSizePixel = 0
    Button.Parent = MainFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button
    
    local function updateState(state)
        if state then
            Button.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Màu xanh lá khi bật
            Button.Text = text .. ": [ BẬT ]"
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            Button.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Màu đỏ khi tắt
            Button.Text = text .. ": [ TẮT ]"
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
    
    local state = default
    updateState(state)
    
    Button.MouseButton1Click:Connect(function()
        state = not state
        updateState(state)
        callback(state)
    end)
end

-- Hàm tạo Ô Nhập Số (TextBox)
local function CreateTextBox(name, text, position, default, callback)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 120, 0, 35)
    Label.Position = position
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = MainFrame
    
    local Box = Instance.new("TextBox")
    Box.Name = name
    Box.Size = UDim2.new(0, 90, 0, 30)
    Box.Position = position + UDim2.new(0, 130, 0, 2)
    Box.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Box.BorderSizePixel = 0
    Box.Text = tostring(default)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.SourceSansBold
    Box.TextSize = 14
    Box.Parent = MainFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Box
    
    Box.FocusLost:Connect(function(enterPressed)
        local val = tonumber(Box.Text)
        if val then
            callback(val)
        else
            Box.Text = tostring(default)
        end
    end)
end

-- Khởi tạo các thành phần điều khiển trên Menu
CreateToggle("AimbotToggle", "Chế độ Aimbot", UDim2.new(0, 20, 0, 60), Config.AimbotEnabled, function(state)
    Config.AimbotEnabled = state
end)

CreateToggle("ESPToggle", "Chế độ ESP Sáng", UDim2.new(0, 20, 0, 105), Config.ESPEnabled, function(state)
    Config.ESPEnabled = state
    if not state then
        -- Xóa sạch các highlight cũ nếu tắt ESP
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Highlight") and v.Name == "ESPHighlight" then
                v:Destroy()
            end
        end
    end
end)

CreateTextBox("FOVBox", "Bán kính FOV:", UDim2.new(0, 20, 0, 160), Config.FOV, function(val)
    Config.FOV = val
end)

CreateTextBox("SmoothBox", "Độ mượt (Aim):", UDim2.new(0, 20, 0, 210), Config.Smoothness, function(val)
    Config.Smoothness = val
end)

-- Hướng dẫn phím ẩn menu
local TipLabel = Instance.new("TextLabel")
TipLabel.Size = UDim2.new(1, 0, 0, 30)
TipLabel.Position = UDim2.new(0, 0, 1, -30)
TipLabel.BackgroundTransparency = 1
TipLabel.Text = "Nhấn [RightControl] hoặc [Insert] để ẩn/hiện"
TipLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
TipLabel.Font = Enum.Font.SourceSansItalic
TipLabel.TextSize = 13
TipLabel.Parent = MainFrame

-- Cơ chế ẩn/hiện bảng hack
UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert then
        MenuVisible = not MenuVisible
        MainFrame.Visible = MenuVisible
    end
end)


-- ==================== LOGIC HOẠT ĐỘNG CHÍNH (AIMBOT & ESP) ====================

local function GetClosestPlayerInFOV()
    local TargetPart = nil
    local ShortestDistance = Config.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local Character = player.Character
            local Target = Character:FindFirstChild(Config.TargetPart)
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")

            if Target and Humanoid and Humanoid.Health > 0 then
                local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Target.Position)
                if OnScreen then
                    local MousePosition = UserInputService:GetMouseLocation()
                    local Distance = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - MousePosition).Magnitude

                    if Distance < ShortestDistance then
                        ShortestDistance = Distance
                        TargetPart = Target
                    end
                end
            end
        end
    end
    return TargetPart
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Config.AimKey or input.KeyCode == Config.AimKey then
        IsAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Config.AimKey or input.KeyCode == Config.AimKey then
        IsAiming = false
    end
end)

RunService.RenderStepped:Connect(function()
    if Config.AimbotEnabled and IsAiming then
        local Target = GetClosestPlayerInFOV()
        if Target then
            local TargetCFrame = CFrame.new(Camera.CFrame.Position, Target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(TargetCFrame, Config.Smoothness)
        end
    end
end)

local function ApplyESP(character)
    if not Config.ESPEnabled then return end
    if not character:FindFirstChild("ESPHighlight") then
        local Highlight = Instance.new("Highlight")
        Highlight.Name = "ESPHighlight"
        Highlight.FillColor = Config.ESPColor
        Highlight.OutlineColor = Config.ESPColor
        Highlight.FillTransparency = Config.FillOpacity
        Highlight.OutlineTransparency = Config.OutlineOpacity
        Highlight.Adornee = character
        Highlight.Parent = character
    end
end

local function RefreshESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                ApplyESP(player.Character)
            end
            player.CharacterAdded:Connect(function(char)
                task.wait(0.3)
                ApplyESP(char)
            end)
        end
    end
end

-- Vòng lặp quét ESP liên tục phòng trường hợp đổi nút On/Off liên tục
task.spawn(function()
    while task.wait(1) do
        if Config.ESPEnabled then
            RefreshESP()
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        ApplyESP(char)
    end)
end)
