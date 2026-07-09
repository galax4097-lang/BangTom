-- Khởi tạo Menu GUI Tối Giản (Chỉ có ESP)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ValueInput = Instance.new("TextBox")
local EspToggle = Instance.new("TextButton")
local Credit = Instance.new("TextLabel")

-- Cấu hình vị trí và giao diện Menu
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "MineAMountain_EspOnly"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Màu nền tối gọn gàng
MainFrame.Position = UDim2.new(0.42, 0, 0.35, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 150) -- Thu nhỏ kích thước cho đỡ vướng màn hình
MainFrame.Active = true
MainFrame.Selectable = true
MainFrame.Draggable = true 

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Title.Text = "CRYSTAL ESP MENU"
Title.TextColor3 = Color3.fromRGB(0, 255, 128) -- Đổi chữ tiêu đề sang màu xanh neon
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 15

-- Ô nhập giá trị tối thiểu để lọc đá quý (Set Value)
ValueInput.Parent = MainFrame
ValueInput.PlaceholderText = "Set Min Value (e.g. 500)"
ValueInput.Text = ""
ValueInput.Position = UDim2.new(0.05, 0, 0.32, 0)
ValueInput.Size = UDim2.new(0.9, 0, 0, 30)
ValueInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ValueInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ValueInput.Font = Enum.Font.SourceSans
ValueInput.TextSize = 14

-- Nút Bật/Tắt ESP độc lập
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
Credit.Text = "Clean ESP Version"
Credit.TextColor3 = Color3.fromRGB(120, 120, 120)
Credit.TextSize = 11
Credit.BackgroundTransparency = 1

-------------------------------------------------------------------------------
-- LOGIC XỬ LÝ ESP ĐÁ QUÝ
-------------------------------------------------------------------------------

local _G = _G or {}
_G.CrystalEspActive = false
local minPrice = 0

-- Lắng nghe giá trị nhập vào ô lọc
ValueInput:GetPropertyChangedSignal("Text"):Connect(function()
    minPrice = tonumber(ValueInput.Text) or 0
end)

-- Hàm bóc tách giá trị (Value/Price) của đá quý
local function getCrystalValue(obj)
    local valueTag = obj:FindFirstChild("Price") or obj:FindFirstChild("Value") or obj:FindFirstChild("SellValue") or obj:FindFirstChild("Worth")
    if valueTag and valueTag:IsA("ValueBase") then
        return valueTag.Value
    end
    -- Lọc số từ tên nếu game lồng giá trị vào tên object
    local match = string.match(obj.Name, "%d+")
    return match and tonumber(match) or 0
end

-- Folder chứa các thẻ ESP để dễ dàng quản lý/xóa sạch khi tắt
local espContainer = Instance.new("Folder")
espContainer.Name = "Clean_Crystal_ESP_Holder"
espContainer.Parent = game:GetService("CoreGui")

local function updateESP()
    espContainer:ClearAllChildren()
    if not _G.CrystalEspActive then return end

    -- Quét toàn bộ các vật thể trong Workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsA("Terrain") then
            local nameLower = string.lower(obj.Name)
            
            -- Nhận diện dựa trên tên gọi phổ biến của đá quý/quặng trong Mine a Mountain
            if string.find(nameLower, "crystal") or string.find(nameLower, "gem") or string.find(nameLower, "ore") or obj:FindFirstChild("Hitbox") then
                local crystalPrice = getCrystalValue(obj)

                -- Lọc: Chỉ tạo ESP nếu giá trị cục đá bằng hoặc lớn hơn mức thiết lập
                if crystalPrice >= minPrice then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "Tag"
                    billboard.AlwaysOnTop = true
                    billboard.Size = UDim2.new(0, 120, 0, 40)
                    billboard.Adornee = obj
                    billboard.Parent = espContainer

                    local label = Instance.new("TextLabel")
                    label.Parent = billboard
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = obj.Name .. "\n[$" .. tostring(crystalPrice) .. "]"
                    label.TextColor3 = Color3.fromRGB(0, 255, 128) -- Màu xanh dạ quang
                    label.Font = Enum.Font.SourceSansBold
                    label.TextSize = 13
                    label.TextStrokeTransparency = 0.5 -- Thêm viền chữ cho dễ nhìn trong hang tối
                end
            end
        end
    end
end

-- Vòng lặp quét làm mới vị trí đá quý sau mỗi 1.5 giây
task.spawn(function()
    while true do
        if _G.CrystalEspActive then
            pcall(updateESP)
        end
        task.wait(1.5)
    end
end)

-- Xử lý nút bấm bằng phương thức tương tác trực tiếp
EspToggle.MouseButton1Down:Connect(function()
    _G.CrystalEspActive = not _G.CrystalEspActive
    
    if _G.CrystalEspActive then
        EspToggle.Text = "Crystals ESP: ON"
        EspToggle.TextColor3 = Color3.fromRGB(0, 255, 0) -- Đổi nút sang màu xanh lá
        pcall(updateESP) -- Chạy quét ngay lập tức khi bật
    else
        EspToggle.Text = "Crystals ESP: OFF"
        EspToggle.TextColor3 = Color3.fromRGB(255, 255, 255) -- Trả về màu trắng
        espContainer:ClearAllChildren() -- Xóa toàn bộ tag trên màn hình ngay lập tức
    end
end)
