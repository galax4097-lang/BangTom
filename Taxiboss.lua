-- Tải thư viện Kavo GUI
local KavoUi = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
-- Tạo cửa sổ Menu chính (Theme: Midnight - Đen huyền bí)
local Window = KavoUi.CreateLib("Taxi Boss Hub 🚖", "Midnight")

-- ==========================================
-- TAB 1: AUTO FARM (Tự động hóa)
-- ==========================================
local MainTab = Window:NewTab("Auto Farm")
local MainSection = MainTab:NewSection("Kiếm Tiền Tự Động")

MainSection:NewToggle("Auto Get Passengers", "Tự động nhận khách hàng gần nhất", function(state)
    if state then
        print("Đang bật: Auto Nhận Khách")
        -- Chèn code vòng lặp (while state do) để tìm và nhận khách tại đây
    else
        print("Đang tắt: Auto Nhận Khách")
    end
end)

MainSection:NewToggle("Auto Teleport Deliver", "Tự động dịch chuyển đến điểm trả khách", function(state)
    if state then
        print("Đang bật: Auto Trả Khách Siêu Tốc")
        -- Chèn code kiểm tra nếu có khách trên xe thì TP đến Destination
    else
        print("Đang tắt: Auto Trả Khách Siêu Tốc")
    end
end)

-- ==========================================
-- TAB 2: VEHICLE (Cấu hình Xe)
-- ==========================================
local VehicleTab = Window:NewTab("Vehicle")
local VehicleSection = VehicleTab:NewSection("Nâng Cấp Chỉ Số Xe")

VehicleSection:NewSlider("Vehicle Speed", "Chỉnh tốc độ tối đa của xe", 500, 100, function(value)
    print("Tốc độ xe đã chỉnh thành: " .. value)
    -- Mẹo: Bạn cần tìm thư mục xe của Player trong workspace và thay đổi MaxSpeed của Tuning/Chassis
end)

VehicleSection:NewToggle("Infinite Nitro", "Sử dụng Nitro vô hạn", function(state)
    if state then
        print("Đang bật: Vô hạn Nitro")
    else
        print("Đang tắt: Vô hạn Nitro")
    end
end)

-- ==========================================
-- TAB 3: PLAYER & TELEPORT (Người chơi)
-- ==========================================
local PlayerTab = Window:NewTab("Player")
local PlayerSection = PlayerTab:NewSection("Trợ Giúp Người Chơi")

PlayerSection:NewSlider("Walkspeed", "Chỉnh tốc độ chạy bộ", 250, 16, function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
end)

PlayerSection:NewButton("Teleport to Showroom", "Dịch chuyển đến cửa hàng bán xe", function()
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        -- Thay Vector3 dưới đây bằng tọa độ chính xác của Showroom trong game của bạn
        player.Character.HumanoidRootPart.CFrame = CFrame.new(100, 10, 200) 
    end
end)
