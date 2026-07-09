-- Khởi tạo Library GUI tối ưu hóa lại sự kiện click
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
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "MineAMountainMenuV2"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.4, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 260)
MainFrame.Active = true
MainFrame.Selectable = true
MainFrame.Draggable = true 

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "MINE A MOUNTAIN ▾"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16

-- 1. Ô nhập giá trị lọc (Set Value)
ValueInput.Parent = MainFrame
ValueInput.PlaceholderText = "Set Value"
ValueInput.Text = ""
ValueInput.Position = UDim2.new(0.05, 0, 0.18, 0)
ValueInput.Size = UDim2.new(0.9, 0, 0, 30)
ValueInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ValueInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ValueInput.Font = Enum.Font.SourceSans
ValueInput.TextSize = 14

-- 2. Nút Find Best Cash
FindBestBtn.Parent = MainFrame
FindBestBtn.Text = "Find Best Cash"
FindBestBtn.Position = UDim2.new(0.05, 0, 0.32, 0)
FindBestBtn.Size = UDim2.new(0.9, 0, 0, 30)
FindBestBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FindBestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FindBestBtn.Font = Enum.Font.SourceSansBold

-- 3. Nút Anti Damage (Chống rơi núi)
AntiDamageBtn.Parent = MainFrame
AntiDamageBtn.Text = "Anti Damage: OFF"
AntiDamageBtn.Position = UDim2.new(0.05, 0, 0.46, 0)
AntiDamageBtn.Size = UDim2.new(0.9, 0, 0, 30)
AntiDamageBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
AntiDamageBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiDamageBtn.Font = Enum.Font.SourceSansBold

-- 4. Nút bật/tắt Crystals ESP
EspToggle.Parent = MainFrame
EspToggle.Text = "Crystals ESP: OFF"
EspToggle.Position = UDim2.new(0.05, 0, 0.60, 0)
EspToggle.Size = UDim2.new(0.9, 0, 0, 30)
EspToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
EspToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
EspToggle.Font = Enum.Font.SourceSansBold

-- 5. Nút Go Home
GoHomeBtn.Parent = MainFrame
GoHomeBtn.Text = "Go Home"
GoHomeBtn.Position = UDim2.new(0.05, 0, 0.74, 0)
GoHomeBtn.Size = UDim2.new(0.9, 0, 0, 30)
GoHomeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
GoHomeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GoHomeBtn.Font = Enum.Font.SourceSansBold

Credit.Parent = MainFrame
Credit.Size = UDim2.new(1, 0, 0, 20)
Credit.Position = UDim2.new(0, 0, 0.9, 0)
Credit.Text = "YouTube: Tora IsMe (Fixed)"
Credit.TextColor3 = Color3.fromRGB(150, 150, 150)
Credit.TextSize = 12
Credit.BackgroundTransparency = 1

-------------------------------------------------------------------------------
-- LOGIC & CHỨC NĂNG (ĐÃ SỬA LỖI KHÔNG CLICK ĐƯỢC)
-------------------------------------------------------------------------------

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:Service("RunService")

local _G = _G or {}
_G.EspEnabled = false
_G.AntiDamageEnabled = false
local minPrice = 0

-- Lắng nghe ô nhập giá trị
ValueInput:GetPropertyChangedSignal("Text"):Connect(function()
    minPrice = tonumber(ValueInput.Text) or 0
end)

-- Hàm tìm giá trị đá quý (Quét sâu hơn vào các Folder quặng của Map)
local function getCrystalValue(obj)
    local valueTag = obj:FindFirstChild("Price") or obj:FindFirstChild("Value") or obj:FindFirstChild("SellValue") or obj:FindFirstChild("Worth")
    if valueTag and valueTag:IsA("ValueBase") then
        return valueTag.Value
    end
    -- Lọc số từ tên vật phẩm nếu có
    local match = string.match(obj.Name, "%d+")
    return match and tonumber(match) or 0
end

-- Quản lý bộ khung ESP gắn vào đá quý
local espFolder = Instance.new("Folder")
espFolder.Name = "Active_Crystal_ESP"
espFolder.Parent = game:GetService("CoreGui")

local function updateESP()
    espFolder:ClearAllChildren()
    if not _G.EspEnabled then return end

    -- Quét trong workspace (tập trung vào các object phổ biến của dòng game simulator)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsA("Terrain") then
            local nameLower = string.lower(obj.Name)
            -- Nhận diện quặng/đá quý dựa trên tên hoặc cấu trúc đặc thù
            if string.find(nameLower, "crystal") or string.find(nameLower, "gem") or string.find(nameLower, "ore") or obj:FindFirstChild("Hitbox") then
                local crystalPrice = getCrystalValue(obj)

                if crystalPrice >= minPrice then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "ESP_Tag"
                    billboard.AlwaysOnTop = true
                    billboard.Size = UDim2.new(0, 100, 0, 40)
                    billboard.Adornee = obj
                    billboard.Parent = espFolder

                    local label = Instance.new("TextLabel")
                    label.Parent = billboard
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = obj.Name .. "\n[$" .. tostring(crystalPrice) .. "]"
                    label.TextColor3 = Color3.fromRGB(0, 255, 128)
                    label.Font = Enum.Font.SourceSansBold
                    label.TextSize = 14
                end
            end
        end
    end
end

-- Vòng lặp quét đá quý sau mỗi 2 giây để tránh bị giật lag máy
task.spawn(function()
    while true do
        pcall(updateESP)
        task.wait(2)
    end
end)

-- SỬA LỖI SỰ KIỆN: Đổi sang sử dụng thuộc tính .Activated (Nhạy hơn trên các bản Hack)
EspToggle.Activated:Connect(function()
    _G.EspEnabled = not _G.EspEnabled
    if _G.EspEnabled then
        EspToggle.Text = "Crystals ESP: ON"
        EspToggle.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        EspToggle.Text = "Crystals ESP: OFF"
        EspToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        espFolder:ClearAllChildren()
    end
end)

-- Tạo tấm sàn bảo vệ tàng hình chặn rơi tự do
local antiDropPlate = Instance.new("Part")
antiDropPlate.Size = Vector3.new(20, 1, 20)
antiDropPlate.Anchored = true
antiDropPlate.Transparency = 1
antiDropPlate.CanCollide = false

RunService.Heartbeat:Connect(function()
    if _G.AntiDamageEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        antiDropPlate.CanCollide = true
        antiDropPlate.Position = Vector3.new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z)
        if antiDropPlate.Parent ~= workspace then
            antiDropPlate.Parent = workspace
        end
    else
        antiDropPlate.CanCollide = false
        antiDropPlate.Parent = nil
    end
end)

AntiDamageBtn.Activated:Connect(function()
    _G.AntiDamageEnabled = not _G.AntiDamageEnabled
    if _G.AntiDamageEnabled then
        AntiDamageBtn.Text = "Anti Damage: ON"
        AntiDamageBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        AntiDamageBtn.Text = "Anti Damage: OFF"
        AntiDamageBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- Dịch chuyển tới cục đá quý đắt nhất
FindBestBtn.Activated:Connect(function()
    local highestValue = -1
    local targetCrystal = nil

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsA("Terrain") then
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "crystal") or string.find(nameLower, "gem") or string.find(nameLower, "ore") then
                local val = getCrystalValue(obj)
                if val > highestValue then
                    highestValue = val
                    targetCrystal = obj
                end
            end
        end
    end

    if targetCrystal and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = targetCrystal.CFrame + Vector3.new(0, 4, 0)
    end
end)

-- Về Base nhanh
GoHomeBtn.Activated:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0) 
    end
end)
