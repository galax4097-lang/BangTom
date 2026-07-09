-- Khởi tạo Menu GUI Tối Giản (Cập nhật giới hạn khoảng cách 1000 và Sửa giá trị)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ValueInput = Instance.new("TextBox")
local EspToggle = Instance.new("TextButton")
local Credit = Instance.new("TextLabel")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "MineAMountain_EspOptimized"

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
Title.Text = "CRYSTAL ESP (MAX 1000m)"
Title.TextColor3 = Color3.fromRGB(0, 255, 128)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14

ValueInput.Parent = MainFrame
ValueInput.PlaceholderText = "Set Min Value (e.g. 500)"
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
-- LOGIC XỬ LÝ ESP KHẢO SÁT KHOẢNG CÁCH & GIÁ TRỊ CHÍNH XÁC
-------------------------------------------------------------------------------

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local _G = _G or {}
_G.CrystalEspActive = false
local minPrice = 0
local MAX_DISTANCE = 1000 -- Giới hạn tầm nhìn ESP là 1000 studs

ValueInput:GetPropertyChangedSignal("Text"):Connect(function()
    minPrice = tonumber(ValueInput.Text) or 0
end)

-- Hàm bóc tách giá trị nâng cao dựa theo bảng text hiển thị của game trong ảnh
local function getCrystalValue(obj)
    -- Tìm các TextLabel nằm trong mô hình đá quý (thường dùng hiển thị số tiền như $505)
    for _, child in pairs(obj:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextBox") then
            local text = child.Text
            if string.find(text, "%$") then
                local priceStr = string.match(text, "%$%d+")
                if priceStr then
                    return tonumber(string.match(priceStr, "%d+")) or 0
                end
            end
        end
    end

    -- Tìm các Object giá trị ẩn nâng cao
    for _, child in pairs(obj:GetDescendants()) do
        if child:IsA("ValueBase") then
            local cName = string.lower(child.Name)
            if string.find(cName, "price") or string.find(cName, "value") or string.find(cName, "worth") then
                if type(child.Value) == "number" and child.Value > 5 then -- Bỏ qua các giá trị hệ thống quá thấp như 1, 2, 3, 4, 5
                    return child.Value
                end
            end
        end
    end
    
    return 0
end

local espContainer = Instance.new("Folder")
espContainer.Name = "Optimized_Crystal_ESP_Holder"
espContainer.Parent = game:GetService("CoreGui")

local function updateESP()
    espContainer:ClearAllChildren()
    if not _G.CrystalEspActive then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local myPos = character.HumanoidRootPart.Position

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsA("Terrain") then
            local nameLower = string.lower(obj.Name)
            
            -- Nhận diện các object đá quý đã lộ diện
            if string.find(nameLower, "crystal") or string.find(nameLower, "gem") or obj:FindFirstChild("Hitbox") or obj:FindFirstChild("Pickup") then
                
                -- Tính khoảng cách từ bạn đến viên đá
                local distance = (obj.Position - myPos).Magnitude
                
                -- ĐIỀU KIỆN 1: Chỉ xử lý nếu khoảng cách nhỏ hơn hoặc bằng 1000
                if distance <= MAX_DISTANCE then
                    local crystalPrice = getCrystalValue(obj)

                    -- ĐIỀU KIỆN 2: Lọc theo giá trị người dùng nhập (Set Value)
                    if crystalPrice >= minPrice and crystalPrice > 0 then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "Tag"
                        billboard.AlwaysOnTop = true
                        billboard.Size = UDim2.new(0, 140, 0, 40)
                        billboard.Adornee = obj
                        billboard.Parent = espContainer

                        local label = Instance.new("TextLabel")
                        label.Parent = billboard
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        
                        -- Hiển thị tên viên đá, giá trị thực tế và khoảng cách hiện tại
                        label.Text = string.format("%s\n[$%s] - %dm", obj.Name, tostring(crystalPrice), math.floor(distance))
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

-- Vòng lặp quét mượt mà mỗi 1.5 giây để cập nhật khoảng cách liên tục
task.spawn(function()
    while true do
        if _G.CrystalEspActive then
            pcall(updateESP)
        end
        task.wait(1.5)
    end
end)

-- Nút tương tác nhanh
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
