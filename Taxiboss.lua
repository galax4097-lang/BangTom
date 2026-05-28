-- Khởi tạo thư viện Kavo UI bằng đường dẫn dự phòng ổn định
local success, KavoUi = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
end)

-- Nếu thư viện tải thành công, tiến hành dựng giao diện
if success and KavoUi then
    -- Tạo cửa sổ chính
    local Window = KavoUi.CreateLib("Taxi Boss Studio Hub 🚖", "Midnight")

    -- Lấy các dịch vụ mạng kết nối Client - Server
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TaxiEvent = ReplicatedStorage:WaitForChild("TaxiEvent")
    local Player = game.Players.LocalPlayer

    -- ==========================================
    -- TAB 1: MAIN FUNCTION (Dịch chuyển)
    -- ==========================================
    local MainTab = Window:NewTab("Main Hub")
    local MainSection = MainTab:NewSection("Chức Năng Dịch Chuyển")

    -- Nút Dịch Chuyển đến Garage 1
    MainSection:NewButton("Teleport to Garage 1", "Dịch chuyển xe và người đến Garage 1", function()
        -- Tọa độ giả định (Bạn có thể thay đổi số theo ý muốn)
        local TargetPosition = Vector3.new(150, 12, -300) 
        TaxiEvent:FireServer("Teleport", TargetPosition)
    end)

    -- Nút Dịch Chuyển đến Showroom
    MainSection:NewButton("Teleport to Showroom", "Dịch chuyển xe và người đến Showroom", function()
        -- Tọa độ giả định (Bạn có thể thay đổi số theo ý muốn)
        local TargetPosition = Vector3.new(-500, 15, 1200) 
        TaxiEvent:FireServer("Teleport", TargetPosition)
    end)

    -- ==========================================
    -- TAB 2: PLAYER SETTINGS (Chỉ số người chơi)
    -- ==========================================
    local PlayerTab = Window:NewTab("Player")
    local PlayerSection = PlayerTab:NewSection("Chỉnh Chỉ Số Nhân Vật")

    -- Thanh trượt thay đổi tốc độ chạy bộ
    PlayerSection:NewSlider("Walkspeed", "Thay đổi tốc độ chạy", 150, 16, function(value)
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = value
        end
    end)

    -- Thanh trượt thay đổi sức nhảy
    PlayerSection:NewSlider("Jump Power", "Thay đổi sức nhảy", 200, 50, function(value)
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.JumpPower = value
        end
    end)
else
    warn("Không thể tải được thư viện giao diện Kavo UI. Vui lòng kiểm tra lại kết nối mạng!")
end
