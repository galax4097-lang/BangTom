-- Khởi tạo Library GUI đơn giản mô phỏng theo ảnh
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ValueInput = Instance.new("TextBox")
local FindBestBtn = Instance.new("TextButton")
local AntiDamageBtn = Instance.new("TextButton")
local EspToggle = Instance.new("TextButton")
local GoHomeBtn = Instance.new("TextButton")
local Credit = Instance.new("TextLabel")

-- Cấu hình thuộc tính giao diện (UI)
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "MineAMountainMenu"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.4, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 260)
MainFrame.Active = true
MainFrame.Draggable = true -- Có thể kéo di chuyển menu trên màn hình

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.Text = "MINE A MOUNTAIN ▾"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16

-- 1. Ô nhập giá trị lọc (Set Value)
ValueInput.Parent = MainFrame
ValueInput.PlaceholderText = "Set Value"
ValueInput.Text = ""
ValueInput.Position = UDim2.new(0.05, 0, 0.15, 0)
ValueInput.Size = UDim2.new(0.9, 0, 0, 30)
ValueInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ValueInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ValueInput.Font = Enum.Font.SourceSans

-- 2. Nút Find Best Cash
FindBestBtn.Parent = MainFrame
FindBestBtn.Text = "Find Best Cash"
FindBestBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
FindBestBtn.Size = UDim2.new(0.9, 0, 0, 30)
FindBestBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
FindBestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- 3. Nút Anti Damage (Chống rơi núi)
AntiDamageBtn.Parent = MainFrame
AntiDamageBtn.Text = "Anti Damage: OFF"
AntiDamageBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
AntiDamageBtn.Size = UDim2.new(0.9, 0, 0, 30)
AntiDamageBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
AntiDamageBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- 4. Nút bật/tắt Crystals ESP
EspToggle.Parent = MainFrame
EspToggle.Text = "Crystals ESP: OFF"
EspToggle.Position = UDim2.new(0.05, 0, 0.6, 0)
EspToggle.Size = UDim2.new(0.9, 0, 0, 30)
EspToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
EspToggle.TextColor3 = Color3.fromRGB(255, 255, 255)

-- 5. Nút Go Home
GoHomeBtn.Parent = MainFrame
GoHomeBtn.Text = "Go Home"
GoHomeBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
GoHomeBtn.Size = UDim2.new(0.9, 0, 0, 30)
GoHomeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
GoHomeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

Credit.Parent = MainFrame
Credit.Size = UDim2.new(1, 0, 0, 20)
Credit.Position = UDim2.new(0, 0, 0.9, 0)
Credit.Text = "YouTube: Tora IsMe (Remake)"
Credit.TextColor3 = Color3.fromRGB(150, 150, 150)
Credit.TextSize = 12
Credit.BackgroundTransparency = 1

-------------------------------------------------------------------------------
-- LOGIC & CHỨC NĂNG (SCRIPT)
-------------------------------------------------------------------------------

local Players = game:Service("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:Service("RunService")

local espEnabled = false
local antiDamageEnabled = false
local minPrice = 0

-- Cập nhật giá trị lọc khi người dùng nhập số vào ô Set Value
ValueInput:GetPropertyChangedSignal("Text"):Connect(function()
    minPrice = tonumber(ValueInput.Text) or 0
end)

-- Hàm tìm kiếm giá trị của đá quý (Thường nằm ở thuộc tính Price, Value hoặc tên object tùy cấu trúc game)
local function getCrystalValue(obj)
    local valueTag = obj:FindFirstChild("Price") or obj:FindFirstChild("Value") or obj:FindFirstChild("SellValue")
    if valueTag and valueTag:IsA("ValueBase") then
        return valueTag.Value
    end
    -- Thử lọc giá trị từ tên nếu game đặt tên kèm giá trị (Ví dụ: "Diamond_$500")
    local match = string.match(obj.Name, "%d+")
    return match and tonumber(match) or 0
end

-- Chức năng ESP Đá Quý nâng cao (Có lọc giá trị)
RunService.RenderStepped:Connect(function()
    -- Xóa các ESP cũ trước khi quét mới
    for _, oldEsp in pairs(game.CoreGui:GetChildren()) do
        if oldEsp.Name == "Crystal_ESP_Tag" then
            oldEsp:Destroy()
        end
    end

    if not espEnabled then return end

    -- Quét toàn bộ Workspace để tìm đá quý (Sửa lại đường dẫn "Ores" hoặc "Crystals" nếu game cập nhật cụ thể hơn)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "crystal") or string.find(string.lower(obj.Name), "gem") or obj:FindFirstChild("Hitbox")) then
            local crystalPrice = getCrystalValue(obj)

            -- Chỉ hiển thị ESP nếu giá trị đá quý LỚN HƠN HOẶC BẰNG giá trị trong ô "Set Value"
            if crystalPrice >= minPrice then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "Crystal_ESP_Tag"
                billboard.AlwaysOnTop = true
                billboard.Size = UDim2.new(0, 100, 0, 40)
                billboard.Adornee = obj
                billboard.Parent = game.CoreGui

                local label = Instance.new("TextLabel")
                label.Parent = billboard
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = string.format("%s\n[$%s]", obj.Name, crystalPrice)
                label.TextColor3 = Color3.fromRGB(0, 255, 128) -- Màu xanh lá cho nổi bật
                label.Font = Enum.Font.SourceSansBold
                label.TextSize = 14
            end
        end
    end
end)

-- Bật/tắt ESP
EspToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        EspToggle.Text = "Crystals ESP: ON"
        EspToggle.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        EspToggle.Text = "Crystals ESP: OFF"
        EspToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- Chức năng Anti Damage (Tạo nền tảng vô hình đỡ chân khi đứng trên núi, không lo bị rơi tự do)
local antiDropPlate = Instance.new("Part")
antiDropPlate.Size = Vector3.new(10, 1, 10)
antiDropPlate.Anchored = true
antiDropPlate.Transparency = 1
antiDropPlate.CanCollide = false

RunService.Heartbeat:Connect(function()
    if antiDamageEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        antiDropPlate.CanCollide = true
        -- Giữ tấm nền tảng luôn nằm ngay phía dưới chân nhân vật 3.5 stud
        antiDropPlate.Position = Vector3.new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z)
        if antiDropPlate.Parent ~= workspace then
            antiDropPlate.Parent = workspace
        end
    else
        antiDropPlate.CanCollide = false
        antiDropPlate.Parent = nil
    end
end)

-- Bật/tắt Anti Damage
AntiDamageBtn.MouseButton1Click:Connect(function()
    antiDamageEnabled = not antiDamageEnabled
    if antiDamageEnabled then
        AntiDamageBtn.Text = "Anti Damage: ON"
        AntiDamageBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        AntiDamageBtn.Text = "Anti Damage: OFF"
        AntiDamageBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- Chức năng Tìm cục đá có giá trị cao nhất hiện tại (Find Best Cash) và dịch chuyển nhẹ tới gần nó
FindBestBtn.MouseButton1Click:Connect(function()
    local highestValue = -1
    local targetCrystal = nil

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "crystal") or string.find(string.lower(obj.Name), "gem")) then
            local val = getCrystalValue(obj)
            if val > highestValue then
                highestValue = val
                targetCrystal = obj
            end
        end
    end

    if targetCrystal and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = targetCrystal.CFrame + Vector3.new(0, 3, 0)
    end
end)

-- Chức năng Go Home (Dịch chuyển về căn cứ)
GoHomeBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        -- Bạn có thể thay đổi Vector3 Tọa độ Spawn của Map nếu game có vị trí Base cố định khác
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 20, 0) 
    end
end)
