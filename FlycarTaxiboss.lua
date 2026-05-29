-- [[ TAXI BOSS FLY ENGINE BYPASS — v11.0 FIX HOÀN TOÀN ẨN MENU ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== CẤU HÌNH ĐỘNG CƠ v11.0 ====================
local Config = {
    Fly = {
        Enabled = false,
        Speed = 120,
    }
}

local MenuVisible = true
local IsMinimized = false
local TabFrames = {}

local BodyVelocityInstance = nil
local BodyGyroInstance = nil

-- ==================== GIẢI PHÁP SỬA LỖI ẨN MENU (GETHUI BYPASS) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TaxiBossV11BypassHub"
ScreenGui.ResetOnSpawn = false

-- Thuật toán tìm phân vùng hiển thị an toàn không thể bị chặn
local function ApplySafeParent()
    if gethui then 
        ScreenGui.Parent = gethui() -- Ưu tiên số 1 cho các Executor đời mới
    else
        local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
        if success and coreGui then
            ScreenGui.Parent = coreGui
        else
            ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") -- Phương án dự phòng cuối cùng
        end
    end
end
ApplySafeParent()

-- ==================== DỰNG GIAO DIỆN HỒNG NEON CHUẨN ĐẸP ====================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 320)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 120) -- Viền Neon đặc trưng
UIStroke.Thickness = 1.6
UIStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Taxi Boss Anti-Wobble Fly — v11.0 Fix GUI"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.35, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.65, -45, 0.5, -10)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Trạng thái: Đang tắt bay"
StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
StatusLabel.Font = Enum.Font.SourceSansItalic
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
StatusLabel.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -45, 0, 2)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "[-]"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = TopBar

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -155, 1, -55)
Container.Position = UDim2.new(0, 150, 0, 48)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

MinimizeBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        Sidebar.Visible = false; Container.Visible = false
        MainFrame.Size = UDim2.new(0, 520, 0, 40)
        MinimizeBtn.Text = "[+]"
    else
        MainFrame.Size = UDim2.new(0, 520, 0, 320)
        Sidebar.Visible = true; Container.Visible = true
        MinimizeBtn.Text = "[-]"
    end
end)

-- Phím tắt ẩn/hiện nhanh Menu bằng phím Right Control hoặc phím Insert
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert then
        MenuVisible = not MenuVisible
        MainFrame.Visible = MenuVisible
    end
end)

-- ==================== HÀM TẠO THÀNH PHẦN GUI ====================
local function CreateTab(tabName, order)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 120, 0, 35)
    TabBtn.Position = UDim2.new(0, 10, 0, 10 + (order * 40))
    TabBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.Font = Enum.Font.SourceSansSemibold
    TabBtn.TextSize = 14
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.CanvasSize = UDim2.new(0, 0, 1.2, 0)
    TabFrame.ScrollBarThickness = 2
    TabFrame.Visible = (order == 0)
    TabFrame.Parent = Container
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 6)
    UIList.Parent = TabFrame

    TabFrames[tabName] = TabFrame
    TabBtn.MouseButton1Click:Connect(function()
        for k, v in pairs(TabFrames) do v.Visible = (k == tabName) end
    end)
    return TabFrame
end

local function AddToggle(tabFrame, text, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -10, 0, 38)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Row.BorderSizePixel = 0
    Row.Parent = tabFrame
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 215)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 42, 0, 20)
    Switch.Position = UDim2.new(1, -52, 0, 9)
    Switch.Text = ""
    Switch.Parent = Row
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

    local State = default
    local function updateVisual() Switch.BackgroundColor3 = State and Color3.fromRGB(255, 0, 120) or Color3.fromRGB(60, 60, 65) end
    updateVisual()

    Switch.MouseButton1Click:Connect(function() State = not State updateVisual() callback(State) end)
end

local function AddSlider(tabFrame, text, min, max, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -10, 0, 48)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Row.BorderSizePixel = 0
    Row.Parent = tabFrame
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 0, 22)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 215)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 22)
    ValueLabel.Position = UDim2.new(0.7, -10, 0, 2)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default) .. " MPH"
    ValueLabel.TextColor3 = Color3.fromRGB(255, 0, 120)
    ValueLabel.Font = Enum.Font.SourceSansBold
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Row

    local SliderBar = Instance.new("TextButton")
    SliderBar.Size = UDim2.new(1, -20, 0, 4)
    SliderBar.Position = UDim2.new(0, 10, 0, 30)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    SliderBar.Text = ""
    SliderBar.Parent = Row

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 0, 120)
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderBar

    local function updateSlider(input)
        local totalWidth = SliderBar.AbsoluteSize.X
        local relX = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X, 0, totalWidth)
        local percentage = relX / totalWidth
        local value = math.floor(min + (max - min) * percentage)
        ValueLabel.Text = tostring(value) .. " MPH"
        Fill.Size = UDim2.new(percentage, 0, 1, 0)
        callback(value)
    end

    local sliding = false
    SliderBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true updateSlider(input) end end)
    UserInputService.InputChanged:Connect(function(input) if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
end

local MainTab = CreateTab("Động Cơ Bay", 0)

AddToggle(MainTab, "Kích Hoạt Bay Xe (Fly Car)", Config.Fly.Enabled, function(s) 
    Config.Fly.Enabled = s 
    if s then
        StatusLabel.Text = "Động cơ bay: KHÓA CỨNG"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
    else
        StatusLabel.Text = "Động cơ bay: ĐANG TẮT"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        if BodyVelocityInstance then BodyVelocityInstance:Destroy() BodyVelocityInstance = nil end
        if BodyGyroInstance then BodyGyroInstance:Destroy() BodyGyroInstance = nil end
    end
end)

AddSlider(MainTab, "Tốc Độ Bay Siêu Cấp", 40, 350, Config.Fly.Speed, function(v) 
    Config.Fly.Speed = v 
end)

-- ==================== ENGINE KHÓA VẬT LÝ VỮNG CHẮC (ANTI-WOBBLE) ====================

RunService.RenderStepped:Connect(function()
    if Config.Fly.Enabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat") then
            local seat = humanoid.SeatPart
            
            -- Khóa cứng vận tốc góc để triệt tiêu mọi chuyển động loảng choảng từ game gốc
            seat.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            
            if not BodyVelocityInstance or BodyVelocityInstance.Parent ~= seat then
                BodyVelocityInstance = Instance.new("BodyVelocity")
                BodyVelocityInstance.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                BodyVelocityInstance.Velocity = Vector3.new(0, 0, 0)
                BodyVelocityInstance.Parent = seat
            end
            
            if not BodyGyroInstance or BodyGyroInstance.Parent ~= seat then
                BodyGyroInstance = Instance.new("BodyGyro")
                BodyGyroInstance.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                BodyGyroInstance.P = 85000 -- Tăng lực siết góc nhìn chống giật lắc
                BodyGyroInstance.D = 120
                BodyGyroInstance.Parent = seat
            end
            
            -- Tính toán phím bấm di chuyển
            local direction = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0) -- Bay lên
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                direction = direction - Vector3.new(0, 1, 0) -- Hạ xuống
            end
            
            if direction.Magnitude > 0 then
                BodyVelocityInstance.Velocity = direction.Unit * Config.Fly.Speed
            else
                BodyVelocityInstance.Velocity = Vector3.new(0, 0, 0)
            end
            
            -- Đồng bộ hóa hướng đầu xe chuẩn xác theo hướng nhìn Camera (Y hệt Character Fly)
            local targetLook = Camera.CFrame.LookVector
            BodyGyroInstance.CFrame = CFrame.lookAt(seat.Position, seat.Position + targetLook)
            
        else
            if BodyVelocityInstance then BodyVelocityInstance:Destroy() BodyVelocityInstance = nil end
            if BodyGyroInstance then BodyGyroInstance:Destroy() BodyGyroInstance = nil end
        end
    end
end)

-- Thông báo nhỏ trong hộp thoại chat để kiểm tra hệ thống hoạt động
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Taxi Boss v11.0",
        Text = "Menu đã được nạp thành công!",
        Duration = 4
    })
end)
