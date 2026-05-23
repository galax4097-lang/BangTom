-- [[ RIVALS ULTRA HUB v1.2 - COPIED FROM TIKTOK ]]
-- Thử nghiệm cấu trúc giao diện và logic ngắm bắn

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== CẤU HÌNH BAN ĐẦU ====================
local Config = {
    Aimbot = {
        Enabled = true,
        Key = Enum.UserInputType.MouseButton2, -- Giữ chuột phải
        FOV = 250,                             -- Kích thước vòng tròn trong ảnh
        Smoothness = 0.1,                     -- Độ mượt khóa mục tiêu
        TargetPart = "Head"
    },
    ESP = {
        Enabled = true,
        Color = Color3.fromRGB(255, 0, 50)     -- Màu đỏ neon phát sáng giống video
    }
}

local IsAiming = false
local MenuVisible = true

-- ==================== [1] TẠO VÒNG TRÒN FOV GIỐNG VIDEO ====================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Config.Aimbot.Enabled
FOVCircle.Filled = false
FOVCircle.Thickness = 1.5 -- Viền mảnh chuẩn nét
FOVCircle.Color = Color3.fromRGB(255, 255, 255) -- Màu trắng tinh
FOVCircle.NumSides = 100 -- Độ bo tròn tối đa không bị răng cưa
FOVCircle.Radius = Config.Aimbot.FOV
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- ==================== [2] HỆ THỐNG MENU GUI BẬT TẮT ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsPremiumMenu"
ScreenGui.ResetOnSpawn = false
-- Cố gắng đưa vào CoreGui để không bị lỗi đè màn hình
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Khung Menu chính (Dark Mode)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 280)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Cho phép nắm tiêu đề kéo đi quanh màn hình
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Thanh Tiêu Đề
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "  RIVALS V.I.P MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Hàm tiện ích tạo Nút Bật/Tắt nhanh
local function AddToggle(text, pos, default, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 220, 0, 35)
    Button.Position = pos
    Button.Font = Enum.Font.SourceSansSemibold
    Button.TextSize = 14
    Button.BorderSizePixel = 0
    Button.Parent = MainFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button
    
    local state = default
    local function setVisual(s)
        if s then
            Button.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Xanh lá
            Button.Text = text .. ": BẬT"
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            Button.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Đỏ
            Button.Text = text .. ": TẮT"
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
    setVisual(state)
    
    Button.MouseButton1Click:Connect(function()
        state = not state
        setVisual(state)
        callback(state)
    end)
end

-- Hàm tiện ích tạo Ô Nhập Thông Số
local function AddTextBox(text, pos, default, callback)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 120, 0, 35)
    Label.Position = pos
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = MainFrame
    
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0, 80, 0, 28)
    Box.Position = pos + UDim2.new(0, 140, 0, 3)
    Box.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Box.Text = tostring(default)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.SourceSansBold
    Box.TextSize = 14
    Box.BorderSizePixel = 0
    Box.Parent = MainFrame
    
    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = Box
    
    Box.FocusLost:Connect(function()
        local num = tonumber(Box.Text)
        if num then callback(num) else Box.Text = tostring(default) end
    end)
end

-- Khởi tạo các phần tử điều khiển lên Menu
AddToggle("Chế độ Ngắm (Aimbot)", UDim2.new(0, 20, 0, 60), Config.Aimbot.Enabled, function(state)
    Config.Aimbot.Enabled = state
    FOVCircle.Visible = state
end)

AddToggle("Phát sáng nhân vật (ESP)", UDim2.new(0, 20, 0, 105), Config.ESP.Enabled, function(state)
    Config.ESP.Enabled = state
    if not state then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Highlight") and v.Name == "RivalsESP" then v:Destroy() end
        end
    end
end)

AddTextBox("Kích thước Vòng FOV", UDim2.new(0, 20, 0, 155), Config.Aimbot.FOV, function(val)
    Config.Aimbot.FOV = val
    FOVCircle.Radius = val
end)

AddTextBox("Độ mượt (Smooth)", UDim2.new(0, 20, 0, 200), Config.Aimbot.Smoothness, function(val)
    Config.Aimbot.Smoothness = val
end)

-- Phím tắt Ẩn / Hiện Menu nhanh
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert then
        MenuVisible = not MenuVisible
        MainFrame.Visible = MenuVisible
    end
end)


-- ==================== [3] LOGIC ESP PHÁT SÁNG NGƯỜI CHƠI ====================
local function ApplyHighlight(character)
    if not Config.ESP.Enabled then return end
    if character == LocalPlayer.Character then return end
    
    local highlight = character:FindFirstChild("RivalsESP")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "RivalsESP"
        highlight.FillColor = Config.ESP.Color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Viền trắng giống ảnh
        highlight.FillTransparency = 0.4
        highlight.OutlineTransparency = 0.1
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Thấy xuyên tường
        highlight.Parent = character
    end
end

-- ==================== [4] LOGIC TÌM ĐỊCH TRONG VÒNG TRÒN FOV ====================
local function GetClosestTarget()
    local CurrentTarget = nil
    local MaxDistance = Config.Aimbot.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local head = char:FindFirstChild(Config.Aimbot.TargetPart)
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            if head and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if distance < MaxDistance then
                        MaxDistance = distance
                        CurrentTarget = head
                    end
                end
            end
        end
    end
    return CurrentTarget
end

-- Nhận diện hành động nhấn chuột ngắm bắn
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Config.Aimbot.Key then IsAiming = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Config.Aimbot.Key then IsAiming = false end
end)


-- ==================== [5] VÒNG LẶP HỆ THỐNG (RENDER STEPPED) ====================
RunService.RenderStepped:Connect(function()
    -- Luôn giữ vòng tròn FOV ở giữa màn hình của bạn
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Xử lý khóa mục tiêu tự động
    if Config.Aimbot.Enabled and IsAiming then
        local target = GetClosestTarget()
        if target then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Aimbot.Smoothness)
        end
    end
    
    -- Xử lý quét đồ họa phát sáng nhân vật
    if Config.ESP.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                ApplyHighlight(player.Character)
            end
        end
    end
end)
