-- Khởi tạo Menu GUI Đọc Cấu Trúc Text Game (Mine A Mountain)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ValueInput = Instance.new("TextBox")
local EspToggle = Instance.new("TextButton")
local Credit = Instance.new("TextLabel")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "MineAMountain_EspFixedFinal"

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
Title.Text = "CRYSTAL ESP (MATCH TEXT)"
Title.TextColor3 = Color3.fromRGB(0, 255, 128)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13

ValueInput.Parent = MainFrame
ValueInput.PlaceholderText = "Set Min Value (Ví dụ: 10000)"
ValueInput.Text = ""
ValueInput.Position = UDim2.new(0.05, 0, 0.32, 0)
ValueInput.Size = UDim2.new(0.9, 0, 0, 30)
ValueInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ValueInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ValueInput.Font = Enum.Font.SourceSans
ValueInput.TextSize = 13

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
Credit.Text = "Tầm nhìn: 1000m | Mặc định: Hiện hết"
Credit.TextColor3 = Color3.fromRGB(120, 120, 120)
Credit.TextSize = 10
Credit.BackgroundTransparency = 1

-------------------------------------------------------------------------------
-- LOGIC BÓC TÁCH CHUỖI KÝ TỰ THEO ĐỊNH DẠNG TEXT CỦA GAME
-------------------------------------------------------------------------------

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local _G = _G or {}
_G.CrystalEspActive = false
local minPrice = 0
local MAX_DISTANCE = 1000

-- Hàm quy đổi chuỗi tiền thành số thực tế (Hỗ trợ cả dấu phẩy lẫn viết tắt K/M nếu có)
local function parsePrice(str)
    if not str then return 0 end
    str = string.upper(string.gsub(str, ",", "")) -- Xóa dấu phẩy
    
    local multiplier = 1
    if string.find(str, "K") then
        multiplier = 1000
        str = string.gsub(str, "K", "")
    elseif string.find(str, "M") then
        multiplier = 1000000
        str = string.gsub(str, "M", "")
    end
    
    return (tonumber(str) or 0) * multiplier
end

ValueInput:GetPropertyChangedSignal("Text"):Connect(function()
    if ValueInput.Text == "" then
        minPrice = 0
    else
        minPrice = parsePrice(ValueInput.Text) or 0
    end
end)

-- Hàm tìm kiếm trực tiếp Text hiển thị trên đầu viên đá quý
local function extractCrystalData(obj)
    for _, child in pairs(obj:GetDescendants()) do
        if child:IsA("TextLabel") and child.Visible == true then
            local text = child.Text
            -- Tìm kiếm ký tự $ đứng cuối dòng text hoặc sau dấu chấm tròn •
            local pricePart = string.match(text, "%$[%d%.,KkMm]+$") or string.match(text, "%$[%d%.,KkMm]+")
            if pricePart then
                local cleanPriceStr = string.gsub(pricePart, "%$", "")
                local finalValue = parsePrice(cleanPriceStr)
                if finalValue > 0 then
                    return finalValue, text
                end
            end
        end
    end
    return 0, nil
end

local espContainer = Instance.new("Folder")
espContainer.Name = "Perfect_Crystal_ESP_Holder"
espContainer.Parent = game:GetService("CoreGui")

local function updateESP()
    espContainer:ClearAllChildren()
    if not _G.CrystalEspActive then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local myPos = character.HumanoidRootPart.Position

    for _, obj in pairs(workspace:GetDescendants()) do
        -- Chỉ quét những Model/Part có chứa bảng tên BillboardGui hiển thị thông tin
        if (obj:IsA("Model") or obj:IsA("BasePart")) and obj:FindFirstChildOfClass("BillboardGui", true) then
            local checkPart = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
            
            if checkPart then
                local distance = (checkPart.Position - myPos).Magnitude
                
                -- Khống chế khoảng cách 1000m
                if distance <= MAX_DISTANCE then
                    local crystalPrice, fullText = extractCrystalData(obj)

                    -- Kiểm tra điều kiện lọc giá
                    if crystalPrice >= minPrice and crystalPrice > 0 then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "Tag"
                        billboard.AlwaysOnTop = true
                        billboard.Size = UDim2.new(0, 180, 0, 45)
                        billboard.Adornee = checkPart
                        billboard.Parent = espContainer

                        local label = Instance.new("TextLabel")
                        label.Parent = billboard
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        
                        -- Đồng bộ nội dung text hiển thị y hệt cấu trúc game kèm theo khoảng cách mét
                        label.Text = string.format("%s\n[%dm]", fullText, math.floor(distance))
                        label.TextColor3 = Color3.fromRGB(0, 255, 128)
                        label.Font = Enum.Font.SourceSansBold
                        label.TextSize = 12
                        label.TextStrokeTransparency = 0.2
                    end
                end
            end
        end
    end
end

-- Vòng lặp quét tối ưu làm mới mỗi 1.2 giây
task.spawn(function()
    while true do
        if _G.CrystalEspActive then
            pcall(updateESP)
        end
        task.wait(1.2)
    end
end)

-- Nút bấm nhận lệnh tức thì
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
