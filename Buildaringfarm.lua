-- [[ BUILD A RING FARM: PREMIUM PURPLE HUB ]] --
-- Đảm bảo không bị trùng lặp giao diện cũ nếu chạy lại script
if game:GetService("CoreGui"):FindFirstChild("PurpleHub_BuildARing") then
    game:GetService("CoreGui"):FindFirstChild("PurpleHub_BuildARing"):Destroy()
end

-- ================= CẤU HÌNH HỆ THỐNG =================
local Config = {
    AutoRoll = false,
    SelectedSeeds = {
        ["Common"] = false, ["Uncommon"] = false, ["Rare"] = false,
        ["Epic"] = false, ["Legendary"] = false, ["Secret"] = false,
        ["Prismatic"] = false, ["Divine"] = false, ["Exotic"] = false,
        ["Mythic"] = false
    }
}

local SeedColors = {
    Common = Color3.fromRGB(150, 150, 150), Uncommon = Color3.fromRGB(50, 200, 50),
    Rare = Color3.fromRGB(50, 150, 255), Epic = Color3.fromRGB(150, 50, 255),
    Legendary = Color3.fromRGB(255, 150, 0), Secret = Color3.fromRGB(255, 50, 100),
    Prismatic = Color3.fromRGB(0, 255, 255), Divine = Color3.fromRGB(255, 215, 0),
    Exotic = Color3.fromRGB(255, 0, 255), Mythic = Color3.fromRGB(255, 255, 255)
}

-- ================= KHỞI TẠO GIAO DIỆN (UI) =================
local PurpleHub = Instance.new("ScreenGui")
PurpleHub.Name = "PurpleHub_BuildARing"
PurpleHub.Parent = game:GetService("CoreGui")
PurpleHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Khung chứa chính (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = PurpleHub
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 30) -- Nền tối huyền ảo
MainFrame.BorderColor3 = Color3.fromRGB(157, 0, 255) -- Viền Tím Neon
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 330, 0, 480)
MainFrame.Active = true
MainFrame.Draggable = true -- Cho phép kéo thả menu trên màn hình

-- Tiêu đề (Title)
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(35, 25, 50)
Title.BorderColor3 = Color3.fromRGB(157, 0, 255)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "PURPLE HUB - BUILD A RING"
Title.TextColor3 = Color3.fromRGB(200, 100, 255)
Title.TextSize = 16

-- Vùng cuộn chứa danh sách tính năng (Scrolling Frame)
local Container = Instance.new("ScrollingFrame")
Container.Name = "Container"
Container.Parent = MainFrame
Container.BackgroundBrightness = 0
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 10, 0, 50)
Container.Size = UDim2.new(1, -20, 1, -60)
Container.CanvasSize = UDim2.new(0, 0, 0, 560)
Container.ScrollBarThickness = 4
Container.ScrollBarImageColor3 = Color3.fromRGB(157, 0, 255)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- --- TÍNH NĂNG 1: NÚT BẬT/TẮT AUTO ROLL ---
local RollToggleBtn = Instance.new("TextButton")
RollToggleBtn.Name = "RollToggleBtn"
RollToggleBtn.Parent = Container
RollToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
RollToggleBtn.BorderColor3 = Color3.fromRGB(157, 0, 255)
RollToggleBtn.Size = UDim2.new(1, -5, 0, 45)
RollToggleBtn.Font = Enum.Font.GothamBold
RollToggleBtn.Text = "AUTO ROLL: OFF"
RollToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
RollToggleBtn.TextSize = 14

-- --- TIÊU ĐỀ KHU VỰC LỌC HẠT (FILTER SEEDS) ---
local FilterTitle = Instance.new("TextLabel")
FilterTitle.Name = "FilterTitle"
FilterTitle.Parent = Container
FilterTitle.BackgroundTransparency = 1
FilterTitle.Size = UDim2.new(1, 0, 0, 25)
FilterTitle.Font = Enum.Font.GothamBold
FilterTitle.Text = "--- DỪNG LẠI KHI ROLL TRÚNG: ---"
FilterTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
FilterTitle.TextSize = 12

-- --- TẠO DANH SÁCH CHECKBOX HẠT GIỐNG ---
for seedName, _ in pairs(Config.SelectedSeeds) do
    local SeedRow = Instance.new("Frame")
    SeedRow.Name = seedName .. "_Row"
    SeedRow.Parent = Container
    SeedRow.BackgroundColor3 = Color3.fromRGB(28, 22, 40)
    SeedRow.BorderSizePixel = 0
    SeedRow.Size = UDim2.new(1, -5, 0, 35)

    local SeedLabel = Instance.new("TextLabel")
    SeedLabel.Parent = SeedRow
    SeedLabel.BackgroundTransparency = 1
    SeedLabel.Position = UDim2.new(0, 10, 0, 0)
    SeedLabel.Size = UDim2.new(0.6, 0, 1, 0)
    SeedLabel.Font = Enum.Font.GothamSemibold
    SeedLabel.Text = "Hạt giống: " .. seedName
    SeedLabel.TextColor3 = SeedColors[seedName] or Color3.fromRGB(255, 255, 255)
    SeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SeedLabel.TextSize = 13

    local CheckBtn = Instance.new("TextButton")
    CheckBtn.Parent = SeedRow
    CheckBtn.BackgroundColor3 = Color3.fromRGB(40, 35, 55)
    CheckBtn.BorderColor3 = Color3.fromRGB(100, 50, 150)
    CheckBtn.Position = UDim2.new(0.8, 0, 0.15, 0)
    CheckBtn.Size = UDim2.new(0, 45, 0, 24)
    CheckBtn.Font = Enum.Font.GothamBold
    CheckBtn.Text = "Bỏ"
    CheckBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    CheckBtn.TextSize = 11

    CheckBtn.MouseButton1Click:Connect(function()
        Config.SelectedSeeds[seedName] = not Config.SelectedSeeds[seedName]
        if Config.SelectedSeeds[seedName] then
            CheckBtn.BackgroundColor3 = Color3.fromRGB(157, 0, 255)
            CheckBtn.Text = "GIỮ"
            CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            CheckBtn.BackgroundColor3 = Color3.fromRGB(40, 35, 55)
            CheckBtn.Text = "Bỏ"
            CheckBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end)
end

-- Xử lý sự kiện Bật/Tắt Auto Roll
RollToggleBtn.MouseButton1Click:Connect(function()
    Config.AutoRoll = not Config.AutoRoll
    if Config.AutoRoll then
        RollToggleBtn.Text = "AUTO ROLL: CHẠY SIÊU TỐC"
        RollToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        RollToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
    else
        RollToggleBtn.Text = "AUTO ROLL: OFF"
        RollToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        RollToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
    end
end)


-- ================= LOGIC CHỐNG BỎ LỠ & AUTO ROLL SIÊU TỐC =================

-- Hàm quét RAM màn hình tìm hạt mong muốn (Ngăn chặn việc bỏ lỡ)
local function isTargetSeedOnScreen()
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    for seedName, isChecked in pairs(Config.SelectedSeeds) do
        if isChecked then
            -- Quét nhanh qua toàn bộ TextLabel đang hiển thị trên giao diện game
            for _, v in pairs(playerGui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible and string.find(string.lower(v.Text), string.lower(seedName)) then
                    return true -- Ngay lập tức phát hiện ra hạt mong muốn!
                end
            end
        end
    end
    return false
end

-- Hàm giả lập Click chuột tốc độ cao vào nút Roll của Game
local function pressRollButton()
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    for _, v in pairs(playerGui:GetDescendants()) do
        -- Tự động nhận diện nút bấm có tên chứa chữ "roll" hoặc "spin"
        if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible and 
           (string.find(string.lower(v.Name), "roll") or string.find(string.lower(v.Text), "roll") or string.find(string.lower(v.Name), "spin")) then
            
            -- Kích hoạt tất cả các kết nối click chuột của nút để bỏ qua hoạt ảnh trễ
            local clicked = false
            if getconnections then
                for _, connection in pairs(getconnections(v.MouseButton1Click)) do connection:Fire() clicked = true end
                for _, connection in pairs(getconnections(v.MouseButton1Down)) do connection:Fire() clicked = true end
            end
            
            -- Phương án dự phòng nếu getconnections không khả dụng trên một số máy
            if not clicked then
                v:SimulateClick() -- Hoặc giả lập click thông thường tùy executor
            end
            break
        end
    end
end

-- Vòng lặp Core xử lý tốc độ cao (Luồng chạy ngầm không gây đứng game)
task.spawn(function()
    while task.wait() do -- Tối ưu hóa chu kỳ quét liên tục
        if Config.AutoRoll then
            -- BƯỚC 1: KIỂM TRA TRƯỚC (QUAN TRỌNG NHẤT)
            -- Nếu phát hiện thấy hạt hiếm đã chọn vừa xuất hiện, HỦY LỆNH CLICK NGAY LẬP TỨC
            if isTargetSeedOnScreen() then
                Config.AutoRoll = false
                
                -- Cập nhật lại giao diện Menu về trạng thái tắt
                RollToggleBtn.Text = "AUTO ROLL: OFF (ĐÃ TÌM THẤY HẠT!)"
                RollToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
                RollToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
                
                print("[Purple Hub] Tìm thấy hạt mục tiêu! Đã dừng khẩn cấp để bảo vệ hạt giống.")
            else
                -- BƯỚC 2: Nếu chưa ra, tiếp tục click roll cực nhanh không cooldown
                pressRollButton()
            end
        end
    end
end)
