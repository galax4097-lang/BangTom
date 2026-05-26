-- [[ BUILD A RING FARM: AUTO ROLL GUI ]] --
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bracket-dev/bracket-v1/main/library.lua"))()

-- Khởi tạo Menu chính
local Window = Library:CreateWindow({
    Name = "Build A Ring Farm - Auto Roll",
    Size = UDim2.fromOffset(320, 400),
    Color = Color3.fromRGB(0, 128, 255)
})

local Tab = Window:CreateTab("Main")
local Section = Tab:CreateSection("Auto Roll Options")

-- Danh sách cấu hình
local Config = {
    AutoRoll = false,
    SelectedSeeds = {}
}

-- Danh sách các loại Seed/Độ hiếm phổ biến trong game (Bạn có thể thêm bớt tùy ý)
local SeedList = {
    "Common", "Uncommon", "Rare", "Epic", "Legendary", 
    "Secret", "Prismatic", "Divine", "Exotic", "Mythic"
}

-- Tạo các Checkbox cho từng loại Seed trong Menu
for _, seedName in pairs(SeedList) do
    Config.SelectedSeeds[seedName] = false
    Section:CreateToggle({
        Name = "Stop at: " .. seedName,
        Flag = "Seed_" .. seedName,
        Callback = function(val)
            Config.SelectedSeeds[seedName] = val
        end
    })
end

-- Toggle kích hoạt Auto Roll
Section:CreateToggle({
    Name = "ENABLE AUTO ROLL",
    Flag = "AutoRollToggle",
    Callback = function(val)
        Config.AutoRoll = val
    end
})

-- Hàm kiểm tra xem Seed vừa roll ra có nằm trong danh sách được chọn không
local function checkRolledSeed()
    -- LƯU Ý: Đoạn này quét qua UI hiển thị kết quả Roll của game. 
    -- Script sẽ tìm các TextLabel chứa tên độ hiếm/tên hạt giống.
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    for seedName, isSelected in pairs(Config.SelectedSeeds) do
        if isSelected then
            -- Quét nhanh qua giao diện để tìm chữ tương ứng
            local matchFound = false
            for _, v in pairs(playerGui:GetDescendants()) do
                if v:IsA("TextLabel") and string.find(string.lower(v.Text), string.lower(seedName)) and v.Visible then
                    matchFound = true
                    break
                end
            end
            if matchFound then
                return true -- Tìm thấy seed mục tiêu, ra lệnh dừng
            end
        end
    end
    return false
end

-- Hàm kích hoạt nút Roll trong game nhanh nhất có thể
local function clickRollButton()
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    -- Tìm nút Roll dựa trên các tên phổ biến: "Roll", "Spin", "Gacha"
    for _, v in pairs(playerGui:GetDescendants()) do
        if (v:IsA("TextButton") or v:IsA("ImageButton")) and 
           (string.find(string.lower(v.Name), "roll") or string.find(string.lower(v.Text), "roll")) and 
           v.Visible then
            
            -- Giả lập click chuột (vượt qua cooldown hoạt ảnh nếu Client-sided)
            for _, connection in pairs(getconnections(v.MouseButton1Click)) do
                connection:Fire()
            end
            for _, connection in pairs(getconnections(v.MouseButton1Down)) do
                connection:Fire()
            end
            break
        end
    end
end

-- Vòng lặp chạy ngầm (Background Loop) tốc độ cao
task.spawn(function()
    while task.wait(0.01) do -- Giới hạn vòng lặp cực nhanh không gây crash (100 lần/giây)
        if Config.AutoRoll then
            -- 1. Kiểm tra xem kết quả hiện tại có phải hạt giống mình cần không
            if checkRolledSeed() then
                Config.AutoRoll = false
                -- Cập nhật lại UI tắt nút bấm
                Window:SetValue("AutoRollToggle", false)
                print("[Auto Roll] Đã tìm thấy hạt giống mục tiêu! Tự động dừng Roll.")
            else
                -- 2. Nếu không phải, tiếp tục bấm nút Roll
                clickRollButton()
            end
        end
    end
end)
