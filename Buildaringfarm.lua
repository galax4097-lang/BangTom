local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Tạo Cửa Sổ Menu Chính
local Window = OrionLib:MakeWindow({
    Name = "Build A Ring Farm [Orion Version]", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "OrionCustomFarm",
    IntroText = "Đang Tải Menu..."
})

---------------------------------------------------------------------------
-- BIẾN TOÀN CỤC (KÈM DỮ LIỆU GIẢ LẬP ĐỂ KHÔNG BỊ LỖI CHỨC NĂNG)
---------------------------------------------------------------------------
_G.SelectedSeed = "None"
_G.AutoRoll = false
_G.AutoFertilizer = false
_G.WalkSpeedValue = 16
_G.SpeedActive = false

-- Hàm giả lập để lấy hạt giống vừa roll (Bạn có thể thay bằng code check thực tế của game)
local function GetCurrentRolledSeed()
    local testSeeds = {"None", "Hành hành", "Hạt giống Void", "Papaya Seed"}
    return testSeeds[math.random(1, #testSeeds)]
end

---------------------------------------------------------------------------
-- TAB 1: FARMING (QUẢN LÝ HẠT GIỐNG & ROLL)
---------------------------------------------------------------------------
local FarmTab = Window:MakeTab({
    Name = "🌾 Farming",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

FarmTab:AddSection({
    Name = "AUTO ROLL SEEDS"
})

-- Dropdown chọn hạt giống để dừng lại
FarmTab:AddDropdown({
    Name = "Chọn hạt giống muốn giữ lại:",
    Default = "None",
    Options = {"None", "Hành hành", "Hạt giống Void", "Papaya Seed"},
    Callback = function(Value)
        _G.SelectedSeed = Value
        print("Đã chọn hạt giống mục tiêu: " .. Value)
    end    
})

-- Nút gạt Auto Roll
local RollToggle = FarmTab:AddToggle({
    Name = "Tự Động Roll Hạt Giống (Auto Roll)",
    Default = false,
    Callback = function(Value)
        _G.AutoRoll = Value
        
        task.spawn(function()
            while _G.AutoRoll do
                task.wait(0.5) -- Tốc độ roll (0.5 giây/lần)
                
                -- Thực hiện hành động roll của game tại đây
                local rolled = GetCurrentRolledSeed()
                print("Bạn vừa Roll ra: " .. rolled)
                
                -- Nếu trúng hạt giống đã chọn ở Dropdown thì tự dừng
                if _G.SelectedSeed ~= "None" and rolled == _G.SelectedSeed then
                    OrionLib:MakeNotification({
                        Name = "Thành Công!",
                        Content = "🎉 Đã tìm thấy [" .. _G.SelectedSeed .. "]. Dừng Roll!",
                        Image = "rbxassetid://4483362458",
                        Duration = 5
                    })
                    _G.AutoRoll = false
                    -- Cập nhật lại nút gạt trên giao diện về trạng thái Tắt
                    OrionLib:ChangeToggle("Tự Động Roll Hạt Giống (Auto Roll)", false)
                    break
                end
            end
        end)
    end
})

---------------------------------------------------------------------------
-- TAB 2: UPGRADES (PHÂN BÓN & NÂNG CẤP)
---------------------------------------------------------------------------
local UpgradeTab = Window:MakeTab({
    Name = "⚡ Upgrades",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

UpgradeTab:AddSection({
    Name = "QUẢN LÝ PHÂN BÓN"
})

UpgradeTab:AddToggle({
    Name = "Tự Động Bón Phân (Auto Fertilizer)",
    Default = false,
    Callback = function(Value)
        _G.AutoFertilizer = Value
        task.spawn(function()
            while _G.AutoFertilizer do
                task.wait(1) -- Cách 1 giây bón một lần
                print("Đang tự động bón phân để tăng sản lượng hạt giống...")
                -- Chèn mã bón phân của game vào đây nếu có
            end
        end)
    end
})

---------------------------------------------------------------------------
-- TAB 3: UTILITIES (HỖ TRỢ NGƯỜI CHƠI & SỬA LỖI WALKSPEED)
---------------------------------------------------------------------------
local UtilTab = Window:MakeTab({
    Name = "🛠️ Utilities",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

UtilTab:AddSection({
    Name = "TÙY CHỈNH NHÂN VẬT"
})

UtilTab:AddToggle({
    Name = "Kích Hoạt Chạy Nhanh (WalkSpeed 100)",
    Default = false,
    Callback = function(Value)
        _G.SpeedActive = Value
        if Value then
            _G.WalkSpeedValue = 100
        else
            _G.WalkSpeedValue = 16
            -- Trả về tốc độ mặc định khi tắt
            pcall(function()
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end)
        end
    end
})

-- VÒNG LẶP CHẠY NGẦM ĐỂ KHÓA CHẶT TỐC ĐỘ CHẠY (SỬA LỖI KHÔNG HOẠT ĐỘNG)
task.spawn(function()
    while true do
        task.wait(0.1) -- Kiểm tra liên tục để ép tốc độ nhân vật không bị reset
        if _G.SpeedActive then
            pcall(function()
                local player = game.Players.LocalPlayer
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.WalkSpeed = _G.WalkSpeedValue
                end
            end)
        end
    end
end)

---------------------------------------------------------------------------
-- KHỞI CHẠY MENU
---------------------------------------------------------------------------
OrionLib:Init()
