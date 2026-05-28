-- Tải thư viện giao diện Kavo UI (Đảm bảo máy tính có kết nối mạng)
local KavoUi = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = KavoUi.CreateLib("Taxi Boss Studio Hub 🚖", "Midnight")

-- Lấy dịch vụ mạng kết nối Client - Server
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TaxiEvent = ReplicatedStorage:WaitForChild("TaxiEvent")
local Player = game.Players.LocalPlayer

-- ==========================================
-- TAB 1: MAIN FUNCTION
-- ==========================================
local MainTab = Window:NewTab("Main Hub")
local MainSection = MainTab:NewSection("Chức Năng Chính")

-- Nút Dịch Chuyển đến Garage 1
MainSection:NewButton("Teleport to Garage 1", "Dịch chuyển xe và người đến Garage 1", function()
    -- Tọa độ ví dụ cho Garage 1 (Bạn có thể tự đổi số lại cho đúng vị trí game của bạn)
    local TargetPosition = Vector3.new(150, 12, -300) 
    TaxiEvent:FireServer("Teleport", TargetPosition)
end)

-- Nút Dịch Chuyển đến Showroom Xe
MainSection:NewButton("Teleport to Showroom", "Dịch chuyển xe và người đến Showroom", function()
    -- Tọa độ ví dụ cho Showroom
    local TargetPosition = Vector3.new(-500, 15, 1200) 
    TaxiEvent:FireServer("Teleport", TargetPosition)
end)

-- ==========================================
-- TAB 2: PLAYER SETTINGS
-- ==========================================
local PlayerTab = Window:NewTab("Player")
local PlayerSection = PlayerTab:NewSection("Chỉnh Chỉ Số Nhân Vật")

-- Thanh trượt thay đổi tốc độ chạy bộ của người chơi
PlayerSection:NewSlider("Walkspeed", "Thay đổi tốc độ chạy (Mặc định: 16)", 150, 16, function(value)
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = value
    end
end)

-- Thanh trượt thay đổi sức nhảy
PlayerSection:NewSlider("Jump Power", "Thay đổi sức nhảy (Mặc định: 50)", 200, 50, function(value)
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.JumpPower = value
    end
end)
