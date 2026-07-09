-- Khởi tạo Menu GUI Tối Giản (Sửa lỗi lọc số có dấu phẩy)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ValueInput = Instance.new("TextBox")
local EspToggle = Instance.new("TextButton")
local Credit = Instance.new("TextLabel")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "MineAMountain_EspFinalFix"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.42, 0, 0.35, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 150)
MainFrame.Active = true
MainFrame.Selectable = true
MainFrame.Draggable = true 

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Title.Text = "CRYSTAL ESP (COMMA FIXED)"
Title.TextColor3 = Color3.fromRGB(0, 255, 128)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13

ValueInput.Parent = MainFrame
ValueInput.PlaceholderText = "Set Min Value (e.g. 50000)"
ValueInput.Text = ""
ValueInput.Position = UDim2.new(0.05, 0, 0.32, 0)
ValueInput.Size = UDim2.new(0.9, 0, 0, 30)
ValueInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ValueInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ValueInput.Font = Enum.Font.SourceSans
ValueInput.TextSize = 14

EspToggle.Parent = MainFrame
EspToggle.Text = "Crystals ESP: OFF"
EspToggle.Position = UDim2.new(0.05, 0, 0.58, 0)
EspToggle.Size = UDim2.new(0.9, 0, 0, 32)
EspToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
EspToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
EspToggle.Font = Enum.Font.SourceSansBold
EspToggle.TextSize = 14

Credit.Parent = MainFrame
Credit.Size = UDim2.new(1, 0, 0, 15)
Credit.Position = UDim2.new(0, 0, 0.85, 0)
Credit.Text = "Distance Limit: 1000 studs"
Credit.TextColor3 = Color3.fromRGB(120, 120, 120)
Credit.TextSize = 11
Credit.BackgroundTransparency = 1

-------------------------------------------------------------------------------
-- LOGIC XỬ LÝ ESP CHỐNG LỖI DẤU PHẨY (COMMA & COORD SCANNER)
-------------------------------------------------------------------------------

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local _G = _G or {}
_G.CrystalEspActive = false
local minPrice = 0
local MAX_DISTANCE = 1000

ValueInput:GetPropertyChangedSignal("Text"):Connect(function()
    -- Loại bỏ mọi dấu phẩy nếu người dùng vô tình nhập vào ô Set Value
    local cleanText = string.gsub(ValueInput.Text, ",", "")
    minPrice = tonumber(cleanText) or 0
end)

-- Hàm bóc tách giá trị cực mạnh: Loại bỏ dấu phẩy và ký tự lạ
local function getCrystalValue(obj)
    -- Quét qua tất cả TextLabel (bao gồm cả BillboardGui hiển thị giá trị như $147,801)
    for _, child in pairs(obj:GetDescendants()) do
        if child:IsA("TextLabel") then
            local text = child.Text
            if string.find(text, "%$") then
                -- Tìm chuỗi dạng $147,801 hoặc $505
                local priceStr = string.match(text, "%$[%d,]+")
                if priceStr then
                    -- Xóa bỏ dấu "$" và dấu "," để chuyển thành số thuần túy (147801)
                    local cleanNumStr = string.gsub(string.gsub(priceStr, "%$", ""), ",", "")
                    local finalNum = tonumber(cleanNumStr)
                    if finalNum then return finalNum end
                end
            end
        end
    end
    
    -- Thử quét các ValueBase nếu có
    for _, child in pairs(obj:GetDescendants()) do
        if child:IsA("ValueBase") and (string.find(string.lower(child.Name), "value") or string.find(string.lower(child.Name), "price")) then
            if type(child.Value) == "number" and child.Value > 5 then
                return child.Value
            end
        end
    end
    
    return 0
end

local espContainer = Instance.new("Folder")
espContainer.Name = "Final_Crystal_ESP_Holder"
espContainer.Parent = game:GetService("CoreGui")

local function updateESP()
    espContainer:ClearAllChildren()
    if not _G.CrystalEspActive then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local myPos = character.HumanoidRootPart.Position

    for _, obj in pairs(workspace:GetDescendants()) do
        -- Tìm kiếm diện rộng dựa trên sự tồn tại của bảng tên hoặc cấu trúc Mesh đá quý
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local isCrystal = false
            local checkPart = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
            
            if checkPart then
                local nameLower = string.lower(obj.Name)
                if string.find(nameLower, "crystal") or string.find(nameLower, "gem") or obj:FindFirstChild("Pickup") or obj:FindFirstChildOfClass("BillboardGui") then
                    isCrystal = true
                end
                
                if isCrystal then
                    local distance = (checkPart.Position - myPos).Magnitude
                    
                    if distance <= MAX_DISTANCE then
                        local crystalPrice = getCrystalValue(obj)

                        -- So sánh số tiền đã được làm sạch dấu phẩy
                        if crystalPrice >= minPrice and crystalPrice > 0 then
                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "Tag"
                            billboard.AlwaysOnTop = true
                            billboard.Size = UDim2.new(0, 150, 0, 40)
                            billboard.Adornee = checkPart
                            billboard.Parent = espContainer

                            local label = Instance.new("TextLabel")
                            label.Parent = billboard
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            
                            -- Hiển thị định dạng tiền đẹp mắt cùng khoảng cách
                            label.Text = string.format("%s\n[$%s] - %dm", obj.Name, string.format("%.0f", crystalPrice), math.floor(distance))
                            label.TextColor3 = Color3.fromRGB(0, 255, 128)
                            label.Font = Enum.Font.SourceSansBold
                            label.TextSize = 13
                            label.TextStrokeTransparency = 0.3
                        end
                    end
                end
            end
        end
    end
end

-- Vòng lặp quét mượt mà mỗi 1.2 giây để cập nhật nhạy hơn
task.spawn(function()
    while true do
        if _G.CrystalEspActive then
            pcall(updateESP)
        end
        task.wait(1.2)
    end
end)

-- Nút tương tác nhận lệnh ngay lập tức
EspToggle.MouseButton1Down:Connect(function()
    _G.CrystalEspActive = not _G.CrystalEspActive
    
    if _G.CrystalEspActive then
        EspToggle.Text = "Crystals ESP: ON"
        EspToggle.TextColor3 = Color3.fromRGB(0, 255, 0)
        pcall(updateESP)
    else
        EspToggle.Text = "Crystals ESP: OFF"
        EspToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        espContainer:ClearAllChildren()
    end
end)
