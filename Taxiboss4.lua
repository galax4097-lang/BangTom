-- [[ TAXI BOSS ULTIMATE LOCAL ZONE — v7.0 FIXXED ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ==================== CẤU HÌNH HỆ THỐNG V7.0 ====================
local Config = {
    Farm = {
        AutoPassenger = false,
        AutoDropOff = false,
        CurrentZone = nil,        -- Khu vực nhà hàng được chọn để cày
        ZoneKeywords = {},        -- Từ khóa nhận diện nhà hàng
    },
    Vehicle = {
        SpeedHack = false,
        SpeedValue = 150,
    }
}

local MenuVisible = true
local IsMinimized = false
local TabFrames = {}

-- Danh sách nhà hàng chuẩn theo ảnh chụp màn hình của bạn
local Establishments = {
    {Name = "Limoné Bistro (2.0★)", Keywords = {"limone", "bistro"}},
    {Name = "Sofia's Cafe (3.0★)", Keywords = {"sofia", "cafe"}},
    {Name = "Céfiro Jazz Club (3.5★)", Keywords = {"cefiro", "jazz"}},
    {Name = "Ronut's Donuts (3.6★)", Keywords = {"ronut", "donut"}},
    {Name = "MEGA Kebab (3.8★)", Keywords = {"mega", "kebab"}}
}

-- ==================== KHỞI TẠO GIAO DIỆN HỒNG NEON v7.0 ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TaxiBossV7ZoneHub"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 530, 0, 360)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
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
Title.Size = UDim2.new(0.55, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Taxi Boss Local Zone — v7.0 Siêu Chỉnh Chu"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.4, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.6, -45, 0.5, -10)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Chọn khu vực để bắt đầu..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
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
        MainFrame.Size = UDim2.new(0, 530, 0, 40)
        MinimizeBtn.Text = "[+]"
    else
        MainFrame.Size = UDim2.new(0, 530, 0, 360)
        Sidebar.Visible = true; Container.Visible = true
        MinimizeBtn.Text = "[-]"
    end
end)

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
    TabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
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
    TabFrame.ScrollBarThickness = 3
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

-- Tạo các Phân Mục Giao Diện
local FarmTab = CreateTab("Tự Động Cày", 0)
local ZoneTab = CreateTab("Chọn Nhà Hàng", 1)

AddToggle(FarmTab, "Bật Auto Đón Khách Khu Vực", Config.Farm.AutoPassenger, function(s) Config.Farm.AutoPassenger = s end)
AddToggle(FarmTab, "Bật Auto Trả Khách Siêu Tốc", Config.Farm.AutoDropOff, function(s) Config.Farm.AutoDropOff = s end)

-- Tải danh sách nhà hàng vào Tab Chọn Nhà Hàng (Nâng cấp chỉnh chu)
local ZoneButtons = {}
for _, zone in ipairs(Establishments) do
    local ZoneBtn = Instance.new("TextButton")
    ZoneBtn.Size = UDim2.new(1, -10, 0, 40)
    ZoneBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
    ZoneBtn.Text = "  " .. zone.Name
    ZoneBtn.TextColor3 = Color3.fromRGB(200, 200, 205)
    ZoneBtn.Font = Enum.Font.SourceSansSemibold
    ZoneBtn.TextSize = 14
    ZoneBtn.TextXAlignment = Enum.TextXAlignment.Left
    ZoneBtn.Parent = ZoneTab
    Instance.new("UICorner", ZoneBtn).CornerRadius = UDim.new(0, 6)
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 4, 1, 0)
    Indicator.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = ZoneBtn

    ZoneBtn.MouseButton1Click:Connect(function()
        -- Reset màu toàn bộ nút khác
        for _, btn in pairs(ZoneButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
            btn.TextColor3 = Color3.fromRGB(200, 200, 205)
            btn.Indicator.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        end
        -- Kích hoạt nút được chọn
        ZoneBtn.BackgroundColor3 = Color3.fromRGB(35, 20, 30)
        ZoneBtn.TextColor3 = Color3.fromRGB(255, 0, 120)
        Indicator.BackgroundColor3 = Color3.fromRGB(255, 0, 120)
        
        Config.Farm.CurrentZone = zone.Name
        Config.Farm.ZoneKeywords = zone.Keywords
        StatusLabel.Text = "Khu vực: " .. zone.Name
    end)
    ZoneButtons[zone.Name] = {Button = ZoneBtn, Indicator = Indicator}
end

-- ==================== THUẬT TOÁN ĐỊNH VỊ KHU VỰC CỐ ĐỊNH CODESYNC ====================

-- Hàm tìm kiếm mô hình tòa nhà nhà hàng mục tiêu trên map
local function FindTargetBuilding()
    if not Config.Farm.ZoneKeywords then return nil end
    
    -- Quét qua các khu vực kiến trúc phổ biến của Taxi Boss
    local roots = {workspace:FindFirstChild("Buildings"), workspace:FindFirstChild("Structures"), workspace}
    for _, root in pairs(roots) do
        if root then
            for _, v in ipairs(root:GetChildren()) do
                local nameLower = v.Name:lower()
                for _, kw in pairs(Config.Farm.ZoneKeywords) do
                    if nameLower:find(kw) then
                        -- Trả về Part trung tâm hoặc Model của tòa nhà
                        return v:IsA("Model") and (v.PrimaryPart or v:FindFirstChildOfClass("BasePart")) or v
                    end
                end
            end
        end
    end
    return nil
end

-- Hàm tìm kiếm NPC đứng ngay tại khu vực nhà hàng được chọn (Giới hạn bán kính)
local function FindLocalPassenger(buildingPart)
    if amateurs then return nil end
    local folders = {workspace:FindFirstChild("NPCs"), workspace:FindFirstChild("Customers"), workspace:FindFirstChild("Passengers")}
    
    for _, f in pairs(folders) do
        if f then
            for _, npc in ipairs(f:GetChildren()) do
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                if hrp and not npc:GetAttribute("Taken") then
                    -- Kiểm tra khoảng cách: Chỉ lấy NPC đứng gần nhà hàng trong phạm vi 120 stud
                    local distance = (hrp.Position - buildingPart.Position).Magnitude
                    if distance <= 120 then
                        -- Loại bỏ hoàn toàn các NPC bán xe, sửa xe ở gần đó
                        local nameL = npc.Name:lower()
                        if not nameL:find("dealer") and not nameL:find("mechanic") and not nameL:find("shop") then
                            return hrp
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- Tìm điểm Checkpoint trả khách do game chỉ định
local function FindDropOffZone()
    local mFolder = workspace:FindFirstChild("Missions") or workspace:FindFirstChild("ActiveMissions")
    if mFolder then
        local pMission = mFolder:FindFirstChild(LocalPlayer.Name)
        if pMission then
            return pMission:FindFirstChild("Destination") or pMission:FindFirstChildOfClass("BasePart")
        end
    end
    return nil
end

-- ==================== ENGINE PHÒNG CHỐNG LỖI VẬT LÝ VÀ CHẠY NGẦM v7.0 ====================
task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local hum = LocalPlayer.Character.Humanoid
                local seat = hum.SeatPart
                
                if seat and seat:IsA("VehicleSeat") then
                    
                    -- KIỂM TRA ĐIỀU KIỆN ĐÃ CHỌN KHU VỰC CHƯA
                    if not Config.Farm.CurrentZone then
                        StatusLabel.Text = "Lỗi: Hãy chọn 1 Nhà Hàng!"
                        return
                    end
                    
                    -- Lấy vị trí nhà hàng đã chọn làm gốc chống lật
                    local building = FindTargetBuilding()
                    if not building then
                        StatusLabel.Text = "Hệ thống: Đang quét tìm vị trí tòa nhà..."
                        return
                    end
                    
                    -- TÁC VỤ 1
