-- [[ TAXI BOSS PREMIUM BRAINROT HUB v3.5 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== HỆ THỐNG CẤU HÌNH (SETTINGS) ====================
local Config = {
    Farm = {
        AutoPassenger = false,   -- Tự động gom/nhận khách hàng
        AutoDropOff = false,     -- Tự động trả khách nhanh
    },
    Vehicle = {
        SpeedHack = false,       -- Bật/tắt hack tốc độ xe
        SpeedValue = 150,        -- Tốc độ mong muốn (càng cao càng bay)
        InfiniteNitro = false    -- Giả lập vô hạn Nitro/Boost
    }
}

local MenuVisible = true
local IsMinimized = false
local TabFrames = {}

-- Các tọa độ dịch chuyển nhanh phổ biến trong map Taxi Boss
local Locations = {
    ["Main Spawn (Trung Tâm)"] = Vector3.new(12, 5, -45),
    ["Cửa Hàng Mua Xe (Dealership)"] = Vector3.new(-240, 4, 180),
    ["Xưởng Độ Xe (Upgrade Shop)"] = Vector3.new(450, 6, -320),
    ["Khu Biệt Thự (Rich Area)"] = Vector3.new(800, 15, 600),
    ["Sân Bay (Airport)"] = Vector3.new(-900, 10, -800)
}

-- ==================== TẠO GIAO DIỆN MENU SIDEBAR CHUẨN NEON ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TaxiBossBrainrotHub"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 9)
MainCorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 120) -- Viền Hồng Neon cực rực rỡ
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Thanh tiêu đề (TopBar)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 9)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Taxi Boss Hub — Premium Driver Edition"
Title.TextColor3 = Color3.fromRGB(235, 235, 240)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Nút Thu nhỏ [-]
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -45, 0, 2)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "[-]"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = TopBar

-- Sidebar phân mục bên trái
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Khung chứa nội dung bên phải
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -150, 1, -50)
Container.Position = UDim2.new(0, 145, 0, 45)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- Hiệu ứng Thu nhỏ / Phóng to Menu GUI
MinimizeBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        Sidebar.Visible = false
        Container.Visible = false
        MainFrame.Size = UDim2.new(0, 520, 0, 40)
        MinimizeBtn.Text = "[+]"
    else
        MainFrame.Size = UDim2.new(0, 520, 0, 340)
        Sidebar.Visible = true
        Container.Visible = true
        MinimizeBtn.Text = "[-]"
    end
end)

-- Ẩn nhanh toàn bộ giao diện bằng nút RightControl hoặc Insert
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert then
        MenuVisible = not MenuVisible
        MainFrame.Visible = MenuVisible
    end
end)

-- ==================== HÀM TIỆN ÍCH DỰNG THÀNH PHẦN UI ====================
local function CreateTab(tabName, order)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 120, 0, 35)
    TabBtn.Position = UDim2.new(0, 10, 0, 10 + (order * 40))
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.Font = Enum.Font.SourceSansSemibold
    TabBtn.TextSize = 14
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.CanvasSize = UDim2.new(0, 0, 1.5, 0)
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
    Row.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
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
    local function updateVisual()
        Switch.BackgroundColor3 = State and Color3.fromRGB(255, 0, 120) or Color3.fromRGB(60, 60, 65)
    end
    updateVisual()

    Switch.MouseButton1Click:Connect(function()
        State = not State
        updateVisual()
        callback(State)
    end)
end

local function AddSlider(tabFrame, text, min, max, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -10, 0, 48)
    Row.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
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
    ValueLabel.Text = tostring(default)
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
        ValueLabel.Text = tostring(value)
        Fill.Size = UDim2.new(percentage, 0, 1, 0)
        callback(value)
    end

    local sliding = false
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true updateSlider(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
end

local function AddButton(tabFrame, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(240, 240, 245)
    Btn.Font = Enum.Font.SourceSansSemibold
    Btn.TextSize = 14
    Btn.Parent = tabFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    Btn.MouseButton1Click:Connect(callback)
end

-- ==================== KHỞI TẠO CÁC PHÂN MỤC MENU TÍNH NĂNG ====================
local FarmTab = CreateTab("Tự Động Cày (Farm)", 0)
local VehicleTab = CreateTab("Độ Xe (Vehicle)", 1)
local TeleportTab = CreateTab("Dịch Chuyển", 2)

-- Cài đặt mục Farm
AddToggle(FarmTab, "Tự Động Nhận Khách (Auto Pick Customer)", Config.Farm.AutoPassenger, function(s) Config.Farm.AutoPassenger = s end)
AddToggle(FarmTab, "Tự Động Trả Khách (Auto Drop Off)", Config.Farm.AutoDropOff, function(s) Config.Farm.AutoDropOff = s end)

-- Cài đặt mục Độ Xe Siêu Tốc
AddToggle(VehicleTab, "Bật Hack Tốc Độ Xe (Car Speed)", Config.Vehicle.SpeedHack, function(s) Config.Vehicle.SpeedHack = s end)
AddSlider(VehicleTab, "Thiết Lập Tốc Độ Xe", 50, 300, Config.Vehicle.SpeedValue, function(v) Config.Vehicle.SpeedValue = v end)
AddToggle(VehicleTab, "Vô Hạn Bình Nitro (Inf Nitro)", Config.Vehicle.InfiniteNitro, function(s) Config.Vehicle.InfiniteNitro = s end)

-- Cài đặt mục Dịch Chuyển Nhanh (Fast Travel)
for locName, coords in pairs(Locations) do
    AddButton(TeleportTab, "Đến " .. locName, function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Kiểm tra xem người chơi có đang ngồi trong xe không để dịch chuyển cả xe đi theo
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
                hum.SeatPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hum.SeatPart.CFrame = CFrame.new(coords + Vector3.new(0, 4, 0))
            else
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(coords)
            end
        end
    end)
end

-- ==================== LOGIC XỬ LÝ CHÍNH TRONG GAME TAXI BOSS ====================

-- Vòng lặp tối ưu hóa vận tốc xe (Car Speed Hack)
RunService.RenderStepped:Connect(function()
    if Config.Vehicle.SpeedHack and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
            local seat = hum.SeatPart
            -- Nếu người chơi đang nhấn ga tiến (W) hoặc lùi (S), bổ sung vận tốc cực đại
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                seat.AssemblyLinearVelocity = seat.CFrame.LookVector * Config.Vehicle.SpeedValue
            elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
                seat.AssemblyLinearVelocity = seat.CFrame.LookVector * -Config.Vehicle.SpeedValue
            end
        end
    end
end)

-- Khung tác vụ chạy ngầm xử lý hệ thống cày tiền tự động (Auto Farm Engine Simulation)
task.spawn(function()
    while task.wait(0.5) do
        if Config.Farm.AutoPassenger then
            -- Mẹo tối ưu hóa Taxi Boss: Tự động gửi tín hiệu nhận/tìm khách hàng gần nhất về hệ thống game
            pcall(function()
                -- Quy trình quét các NPC đang vẫy taxi trên đường để dịch chuyển hoặc kích hoạt nạp khách
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj:GetAttribute("Passenger") or obj.Name:find("Customer") then
                        local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                        if root and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            -- Dịch chuyển xe đến vị trí khách đứng để đón trong 0.1 giây rồi chạy tiếp
                            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                            if hum and hum.SeatPart then
                                hum.SeatPart.CFrame = root.CFrame * CFrame.new(0, 0, 3)
                                task.wait(0.2)
                                break
                            end
                        end
                    end
                end
            end)
        end

        if Config.Farm.AutoDropOff then
            -- Mẹo tối ưu hóa: Quét các checkpoint trả hàng (vùng phát sáng màu vàng/xanh trên bản đồ)
            pcall(function()
                local destinations = workspace:FindFirstChild("Destinations") or workspace:FindFirstChild("DropOffs")
                if destinations then
                    for _, zone in ipairs(destinations:GetChildren()) do
                        if zone:IsA("BasePart") and zone.Transparency < 1 then
                            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                            if hum and hum.SeatPart then
                                hum.SeatPart.CFrame = zone.CFrame
                                task.wait(0.2)
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end)
