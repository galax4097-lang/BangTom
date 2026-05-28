-- [[ TAXI BOSS PREMIUM HUB v5.0 - ANTI-LAG & NPC FILTERED ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== HỆ THỐNG CẤU HÌNH BIẾN ====================
local Config = {
    Farm = {
        AutoPassenger = false,   
        AutoDropOff = false,     
        MaxStars = 5,             -- MẶC ĐỊNH: Nhận khách từ 1 đến 5 sao (Có thể chỉnh trên UI)
    },
    Vehicle = {
        SpeedHack = false,       
        SpeedValue = 160,        
    }
}

local MenuVisible = true
local IsMinimized = false
local TabFrames = {}

local Locations = {
    ["Main Spawn (Trung Tâm)"] = Vector3.new(12, 5, -45),
    ["Cửa Hàng Mua Xe (Dealership)"] = Vector3.new(-240, 4, 180),
    ["Xưởng Độ Xe (Upgrade Shop)"] = Vector3.new(450, 6, -320)
}

-- ==================== KHỞI TẠO GIAO DIỆN MENU NEON SANG TRỌNG ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TaxiBossV5Hub"
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

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 9)
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 120) -- Hồng Neon rực rỡ
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- TopBar Thanh Tiêu Đề
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 9)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Taxi Boss Premium — v5.0 Meticulous Edition"
Title.TextColor3 = Color3.fromRGB(235, 235, 240)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Trạng thái hệ thống thực thời
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.35, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.6, -40, 0.5, -10)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Hệ thống: Chờ lệnh..."
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
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
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -150, 1, -50)
Container.Position = UDim2.new(0, 145, 0, 45)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

MinimizeBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        Sidebar.Visible = false; Container.Visible = false
        MainFrame.Size = UDim2.new(0, 520, 0, 40)
        MinimizeBtn.Text = "[+]"
    else
        MainFrame.Size = UDim2.new(0, 520, 0, 340)
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
    SliderBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true updateSlider(input) end end)
    UserInputService.InputChanged:Connect(function(input) if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
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

-- Khởi tạo tab nội dung
local FarmTab = CreateTab("Tự Động Cày (Farm)", 0)
local VehicleTab = CreateTab("Độ Xe (Vehicle)", 1)
local TeleportTab = CreateTab("Dịch Chuyển", 2)

AddToggle(FarmTab, "Tự Động Đón Khách (Auto Pick)", Config.Farm.AutoPassenger, function(s) Config.Farm.AutoPassenger = s end)
AddSlider(FarmTab, "Số Sao Xe Có Thể Nhận", 1, 5, Config.Farm.MaxStars, function(v) Config.Farm.MaxStars = v end)
AddToggle(FarmTab, "Tự Động Trả Khách (Auto Drop)", Config.Farm.AutoDropOff, function(s) Config.Farm.AutoDropOff = s end)

AddToggle(VehicleTab, "Bật Hack Tốc Độ Xe", Config.Vehicle.SpeedHack, function(s) Config.Vehicle.SpeedHack = s end)
AddSlider(VehicleTab, "Tốc Độ Tối Đa", 50, 300, Config.Vehicle.SpeedValue, function(v) Config.Vehicle.SpeedValue = v end)

for locName, coords in pairs(Locations) do
    AddButton(TeleportTab, "Đến " .. locName, function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
                hum.SeatPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
                hum.SeatPart.CFrame = CFrame.new(coords + Vector3.new(0, 3, 0))
            else
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(coords)
            end
        end
    end)
end

-- ==================== CHỨC NĂNG PHÂN TÍCH SAO & LỌC NPC TRÁNH ĐỂ BÁN XE ====================

-- Hàm đọc số sao của khách hàng từ BillboardGui
local function GetPassengerStars(npcModel)
    local bbg = npcModel:FindFirstChildOfClass("BillboardGui")
    if bbg then
        for _, obj in ipairs(bbg:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local text = obj.Text
                local number = text:match("%d") -- Tìm số nguyên (Ví dụ: "3 Stars" hoặc "3★")
                if number then return tonumber(number) end
                
                -- Đo lường bằng cách đếm ký tự biểu tượng ngôi sao
                local _, countStar1 = text:gsub("⭐", "")
                if countStar1 > 0 then return countStar1 end
                local _, countStar2 = text:gsub("★", "")
                if countStar2 > 0 then return countStar2 end
            end
        end
    end
    return 1 -- Mặc định trả về khách 1 sao nếu không tìm thấy dữ liệu chữ công khai
end

-- Hàm tìm kiếm khách chuẩn trên phố
local function FindGenuineCustomer()
    local folders = {workspace:FindFirstChild("NPCs"), workspace:FindFirstChild("Customers"), workspace:FindFirstChild("Passengers")}
    local blacklist = {"dealer", "shop", "garage", "mechanic", "worker", "spawn", "leaderboard", "custom", "tycoon"}

    for _, folder in pairs(folders) do
        if folder then
            for _, npc in ipairs(folder:GetChildren()) do
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- Kiểm tra xem tên NPC hoặc thư mục cha có nằm trong danh sách đen không
                    local isBlacklisted = false
                    local nameLower = npc.Name:lower()
                    for _, word in pairs(blacklist) do
                        if nameLower:find(word) then isBlacklisted = true break end
                    end

                    if not isBlacklisted then
                        -- Phân tích số sao của khách hàng xem xe hiện tại có vừa tầm không
                        local starRating = GetPassengerStars(npc)
                        if starRating <= Config.Farm.MaxStars then
                            return hrp
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- Hàm tìm điểm checkpoint trả khách chính xác bằng liên kết điều hướng (Navigation Engine)
local function FindDropOffZone()
    -- Cách 1: Tìm vòng sáng nhiệm vụ cá nhân của người chơi tạo ra
    local missionFolder = workspace:FindFirstChild("Missions")
    if missionFolder then
        local pMission = missionFolder:FindFirstChild(LocalPlayer.Name)
        if pMission then
            local part = pMission:FindFirstChild("Destination") or pMission:FindFirstChildOfClass("BasePart")
            if part then return part end
        end
    end

    -- Cách 2: Quét các mục tiêu phát sáng hình tròn/trụ có bộ truyền va chạm mờ (Trigger Zone)
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("BasePart") and item.Transparency < 1 and item.CanCollide == false then
            if item.Name == "Destination" or item.Name == "DropOff" or item.Name == "TaxiDropOff" or item.Name == "GiveIn" then
                return item
            end
        end
    end
    return nil
end

-- ==================== HỆ THỐNG ENGINE CHẠY NGẦM AUTO FARM V5.0 ====================
task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local hum = LocalPlayer.Character.Humanoid
                local seat = hum.SeatPart
                
                if seat and seat:IsA("VehicleSeat") then
                    
                    -- HÀNH ĐỘNG 1: TỰ ĐỘNG ĐÓN KHÁCH THEO SAO SÀNG LỌC
                    if Config.Farm.AutoPassenger then
                        StatusLabel.Text = "Hệ thống: Đang quét khách hợp lệ..."
                        local customerRoot = FindGenuineCustomer()
                        if customerRoot then
                            StatusLabel.Text = "Hệ thống: Phát hiện! Đang đón khách..."
                            seat.AssemblyLinearVelocity = Vector3.new(0,0,0)
                            seat.AssemblyAngularVelocity = Vector3.new(0,0,0)
                            
                            -- Dịch chuyển xe ra phía sau vị trí khách đứng 3 stud để kích hoạt vùng đón khách
                            seat.CFrame = customerRoot.CFrame * CFrame.new(0, 0, 3)
                            task.wait(0.5) -- Chờ nửa giây để game nạp khách lên xe ổn định
                        end
                    end
                    
                    -- HÀNH ĐỘNG 2: TỰ ĐỘNG TRẢ KHÁCH (CHỐNG NGHẼN SERVER)
                    if Config.Farm.AutoDropOff then
                        StatusLabel.Text = "Hệ thống: Kiểm tra điểm đích..."
                        local dropZone = FindDropOffZone()
                        if dropZone then
                            StatusLabel.Text = "Hệ thống: Đến đích! Đang xử lý tiền..."
                            
                            -- Đóng băng hoàn toàn lực quán tính để xe đứng im tuyệt đối trong vòng tròn trả khách
                            seat.AssemblyLinearVelocity = Vector3.new(0,0,0)
                            seat.AssemblyAngularVelocity = Vector3.new(0,0,0)
                            
                            -- Khóa chặt CFrame xe trùng khớp với điểm đích
                            seat.CFrame = dropZone.CFrame + Vector3.new(0, 1.5, 0)
                            
                            -- [YẾU TỐ QUAN TRỌNG NHẤT]: Tạm dừng vòng lặp 2 giây để Server kịp xử lý thanh toán và xóa Checkpoint
                            task.wait(2.0)
                        end
                    end
                    
                else
                    if Config.Farm.AutoPassenger or Config.Farm.AutoDropOff then
                        StatusLabel.Text = "Hệ thống: Hãy ngồi lên xe Taxi!"
                    end
                end
            end
        end)
    end
end)

-- Vòng lặp tối ưu gia tốc xe (Speed Hack)
RunService.RenderStepped:Connect(function()
    if Config.Vehicle.SpeedHack and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
            local seat = hum.SeatPart
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                seat.AssemblyLinearVelocity = seat.CFrame.LookVector * Config.Vehicle.SpeedValue
            elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
                seat.AssemblyLinearVelocity = seat.CFrame.LookVector * -Config.Vehicle.SpeedValue
            end
        end
    end
end)
