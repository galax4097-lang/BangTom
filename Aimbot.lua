-- =============================================================================
-- PREMIUM HUB v1.1 - AIMBOT + ESP + FOV CIRCLE
-- =============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== CẤU HÌNH (SETTINGS) ====================
local Config = {
    Aimbot = {
        Enabled = true,
        Key = Enum.UserInputType.MouseButton2, -- Nhấn giữ chuột phải
        FOV = 150,                            -- Bán kính vùng nhắm
        Smoothness = 0.15,                    -- Độ mượt (thấp = nhanh)
        TargetPart = "Head",                  -- Bộ phận nhắm
    },
    ESP = {
        Enabled = true,
        FillColor = Color3.fromRGB(255, 0, 80),   -- Màu bên trong
        OutlineColor = Color3.fromRGB(255, 255, 255), -- Màu viền
        FillTransparency = 0.5,
        OutlineTransparency = 0,
    }
}

local IsAiming = false
local MenuVisible = true

-- ==================== [NEW] TẠO VÒNG TRÒN FOV ====================
-- Sử dụng Drawing API (Chỉ hoạt động trên Executor)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Config.Aimbot.Enabled -- Ẩn/hiện theo Aimbot
FOVCircle.Filled = false                  -- Chỉ vẽ viền
FOVCircle.Thickness = 1                   -- Độ đậm viền
FOVCircle.Color = Color3.fromRGB(255, 255, 255) -- Màu trắng
FOVCircle.NumSides = 64                   -- Số cạnh (để vòng tròn mượt)
FOVCircle.Radius = Config.Aimbot.FOV       -- Bán kính
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) -- Giữa màn hình

-- ==================== [NEW] TỐI ƯU ESP (HIGHLIGHT STORAGE) ====================
local ESPStorage = workspace:FindFirstChild("ESP_Storage")
if not ESPStorage then
    ESPStorage = Instance.new("Folder")
    ESPStorage.Name = "ESP_Storage"
    ESPStorage.Parent = workspace
end

local function cleanESP()
    ESPStorage:ClearAllChildren()
end

local function applyESP(character)
    if not Config.ESP.Enabled then return end
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    -- Kiểm tra xem player này đã được highlight chưa
    local existing = ESPStorage:FindFirstChild("ESP_" .. character.Name)
    if not existing then
        local Highlight = Instance.new("Highlight")
        Highlight.Name = "ESP_" .. character.Name
        Highlight.Adornee = character -- Áp dụng lên nhân vật này
        Highlight.FillColor = Config.ESP.FillColor
        Highlight.OutlineColor = Config.ESP.OutlineColor
        Highlight.FillTransparency = Config.ESP.FillTransparency
        Highlight.OutlineTransparency = Config.ESP.OutlineTransparency
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Hiện xuyên tường
        Highlight.Parent = ESPStorage
    end
end

-- ==================== GUI (GIỮ NGUYÊN CẤU TRÚC) ====================
-- Chỉ cập nhật Logic xử lý trong nút bấm

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CheatHubMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") -- Dùng CoreGui để không bị mất khi chết

-- [Phần tạo Frame, TitleBar, Dragging giữ nguyên như code cũ của bạn]
-- (Để tiết kiệm không gian, tôi chỉ viết phần logic nút bấm)
-- ... [CODE TAO FRAME CHÍNH VÀ TITLEBAR] ...
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 320)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.Text = "  PREMIUM HUB v1.1"
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.Font = Enum.Font.SourceSansBold
TitleBar.TextSize = 16
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Parent = MainFrame
-- ... [TÍNH NĂNG DRAG GIỮ NGUYÊN] ...

-- Hàm tạo Nút Bật/Tắt (Toggle Button) - CHỈNH LẠI LOGIC
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
            Button.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            Button.Text = text .. ": [ BẬT ]"
        else
            Button.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
            Button.Text = text .. ": [ TẮT ]"
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

-- Hàm tạo Ô Nhập Số (TextBox) - CHỈNH LẠI LOGIC
local function CreateTextBox(name, text, position, default, callback)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 120, 0, 35)
    Label.Position = position
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 15
    Label.Parent = MainFrame
    local Box = Instance.new("TextBox")
    Box.Name = name
    Box.Size = UDim2.new(0, 90, 0, 30)
    Box.Position = position + UDim2.new(0, 130, 0, 2)
    Box.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Box.Text = tostring(default)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Parent = MainFrame
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Box
    
    Box.FocusLost:Connect(function()
        local val = tonumber(Box.Text)
        if val then callback(val) else Box.Text = tostring(default) end
    end)
end

-- ==================== LOGIC ĐIỀU KHIỂN GUI ====================
CreateToggle("AimbotToggle", "Chế độ Aimbot", UDim2.new(0, 20, 0, 60), Config.Aimbot.Enabled, function(state)
    Config.Aimbot.Enabled = state
    -- [NEW] Cập nhật hình tròn
    FOVCircle.Visible = state
end)

CreateToggle("ESPToggle", "Chế độ ESP Sáng", UDim2.new(0, 20, 0, 105), Config.ESP.Enabled, function(state)
    Config.ESP.Enabled = state
    -- [NEW] Xóa ngay ESP cũ khi tắt
    if not state then
        cleanESP()
    end
end)

CreateTextBox("FOVBox", "Bán kính FOV:", UDim2.new(0, 20, 0, 160), Config.Aimbot.FOV, function(val)
    Config.Aimbot.FOV = val
    -- [NEW] Cập nhật bán kính hình tròn FOV
    FOVCircle.Radius = val
end)

CreateTextBox("SmoothBox", "Độ mượt (Aim):", UDim2.new(0, 20, 0, 210), Config.Aimbot.Smoothness, function(val)
    Config.Aimbot.Smoothness = val
end)

-- Phím ẩn menu (RightControl/Insert)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert then
        MenuVisible = not MenuVisible
        MainFrame.Visible = MenuVisible
        FOVCircle.Visible = (MenuVisible and Config.Aimbot.Enabled) -- Ẩn cả vòng tròn khi ẩn menu
    end
end)

-- ==================== CORE LOGIC ====================

local function GetClosestPlayerInFOV()
    local TargetPart = nil
    local ShortestDistance = Config.Aimbot.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local Character = player.Character
            local Target = Character:FindFirstChild(Config.Aimbot.TargetPart)
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")

            -- Team Check (Optional: Thêm nếu muốn)
            -- if player.Team == LocalPlayer.Team then continue end

            if Target and Humanoid and Humanoid.Health > 0 then
                local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Target.Position)
                if OnScreen then
                    -- Lấy vị trí chuột thực tế từ Drawing API
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
    if input.UserInputType == Config.Aimbot.Key then IsAiming = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Config.Aimbot.Key then IsAiming = false end
end)

-- Vòng lặp cập nhật liên tục (Main Loop)
RunService.RenderStepped:Connect(function()
    -- [NEW] Cập nhật vị trí vòng tròn FOV theo tâm màn hình
    if FOVCircle.Visible then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end

    -- Logic Aimbot
    if Config.Aimbot.Enabled and IsAiming then
        local Target = GetClosestPlayerInFOV()
        if Target then
            local TargetCFrame = CFrame.new(Camera.CFrame.Position, Target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(TargetCFrame, Config.Aimbot.Smoothness)
        end
    end
    
    -- Logic ESP (Quét mỗi khung hình)
    if Config.ESP.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                applyESP(player.Character)
            end
        end
    end
end)
