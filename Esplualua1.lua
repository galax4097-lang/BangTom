local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Hủy GUI cũ để tránh trùng lặp
if CoreGui:FindFirstChild("EmergencyHamburgESP_v3") then
    CoreGui.EmergencyHamburgESP_v3:Destroy()
end

-- ================= CẤU HÌNH TRẠNG THÁI =================
local ESP_Enabled = true
local Max_Distance = 5000 
local ESP_Storage = {} -- Lưu trữ các UI để quản lý liên tục

-- ================= HÀM KIỂM TRA NGHỀ (TEAM) =================
local function GetPlayerRole(player)
    if not player.Team then return "Unknown" end
    local teamName = player.Team.Name:lower()
    
    if string.find(teamName, "police") or string.find(teamName, "sheriff") or string.find(teamName, "cảnh sát") then
        return "Police"
    elseif string.find(teamName, "civilian") or string.find(teamName, "dân") then
        return "Civilian"
    else
        return "Others"
    end
end

local function ShouldShowESP(targetPlayer)
    if targetPlayer == LocalPlayer then return false end
    
    local myRole = GetPlayerRole(LocalPlayer)
    local targetRole = GetPlayerRole(targetPlayer)
    
    if myRole == "Civilian" then
        return targetRole == "Police"
    elseif myRole == "Police" then
        return targetRole == "Civilian"
    end
    
    return false
end

-- Tìm mô hình chiếc xe (Vehicle Model) từ vị trí ghế ngồi
local function GetVehicleFromSeat(seat)
    local current = seat
    while current and current ~= workspace do
        -- Thường các xe trong Emergency Hamburg là một Model chứa DriveSeat hoặc có Body vỏ xe
        if current:IsA("Model") and (current:FindFirstChild("DriveSeat") or current:FindFirstChildOfClass("VehicleSeat") or current.Name:lower():find("car") or current.Name:lower():find("vehicle")) then
            return current
        end
        current = current.Parent
    end
    return seat.Parent -- Trả về folder cha trực tiếp nếu không quét được model chuẩn
end

-- ================= HÀM TẠO ESP TỐC ĐỘ CAO =================
local function CreateESP(player)
    if ESP_Storage[player] then return end

    local bbg = Instance.new("BillboardGui")
    bbg.Name = "ESP_Tag_v3"
    bbg.Size = UDim2.new(0, 220, 0, 60)
    bbg.AlwaysOnTop = true
    bbg.MaxDistance = math.huge
    bbg.Parent = CoreGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 14
    textLabel.Parent = bbg

    ESP_Storage[player] = {Gui = bbg, Label = textLabel}
end

local function RemoveESP(player)
    if ESP_Storage[player] then
        ESP_Storage[player].Gui:Destroy()
        ESP_Storage[player] = nil
    end
end

-- ================= VÒNG LẶP CẬP NHẬT XE & NGƯỜI DÙNG LIÊN TỤC =================
RunService.RenderStepped:Connect(function()
    if not ESP_Enabled then
        for p, data in pairs(ESP_Storage) do data.Gui.Enabled = false end
        return
    end

    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for _, player in ipairs(Players:GetPlayers()) do
        if ShouldShowESP(player) then
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if char and hum and hum.Health > 0 and myHrp then
                -- Kiểm tra xem mục tiêu có đang ngồi trên xe không
                local isInVehicle = false
                local targetPart = char:FindFirstChild("HumanoidRootPart") -- Mặc định khóa vào người
                local infoText = ""

                if hum.SeatPart and (hum.SeatPart:IsA("VehicleSeat") or hum.SeatPart:IsA("Seat")) then
                    isInVehicle = true
                    local vehicleModel = GetVehicleFromSeat(hum.SeatPart)
                    if vehicleModel then
                        targetPart = hum.SeatPart -- Khóa mục tiêu ESP vào ghế/xe
                        infoText = "🚘 [" .. vehicleModel.Name .. "]"
                    else
                        targetPart = hum.SeatPart
                        infoText = "🚘 [Trong Xe]"
                    end
                end

                if targetPart then
                    local dist = math.floor((myHrp.Position - targetPart.Position).Magnitude)

                    if dist <= Max_Distance then
                        if not ESP_Storage[player] then CreateESP(player) end
                        
                        local data = ESP_Storage[player]
                        data.Gui.Enabled = true
                        data.Gui.Adornee = targetPart -- Tự động bám theo Xe hoặc Người linh hoạt
                        
                        -- Phân màu chữ
                        local isPolice = (GetPlayerRole(player) == "Police")
                        local color = isPolice and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(255, 255, 255)
                        data.Label.TextColor3 = color

                        -- Tạo text hiển thị trạng thái Đi bộ hay Lên xe
                        if isInVehicle then
                            data.Label.Text = string.format(
                                "%s\nLái bởi: %s\nDis: %dm | HP: %d", 
                                infoText,
                                player.Name, 
                                dist, 
                                math.floor(hum.Health)
                            )
                        else
                            data.Label.Text = string.format(
                                "[%s]\nDis: %dm\nHP: %d/%d", 
                                player.Name, 
                                dist, 
                                math.floor(hum.Health), 
                                math.floor(hum.MaxHealth)
                            )
                        end
                    else
                        if ESP_Storage[player] then ESP_Storage[player].Gui.Enabled = false end
                    end
                end
            else
                if ESP_Storage[player] then ESP_Storage[player].Gui.Enabled = false end
            end
        else
            if ESP_Storage[player] then ESP_Storage[player].Gui.Enabled = false end
        end
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)

-- ================= GIAO DIỆN MENU (GUI) =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EmergencyHamburgESP_v3"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 180)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "EH SMART ESP V3 (VEHICLE FIX)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 210, 0, 35)
ToggleBtn.Position = UDim2.new(0, 20, 0, 45)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ToggleBtn.Text = "ESP MODE: ACTIVE"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    ESP_Enabled = not ESP_Enabled
    if ESP_Enabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        ToggleBtn.Text = "ESP MODE: ACTIVE"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        ToggleBtn.Text = "ESP MODE: DISABLED"
    end
end)

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, 0, 0, 20)
SliderLabel.Position = UDim2.new(0, 0, 0, 95)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Tầm quét: " .. Max_Distance .. " studs"
SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SliderLabel.Font = Enum.Font.SourceSans
SliderLabel.TextSize = 13
SliderLabel.Parent = MainFrame

local SliderBar = Instance.new("TextButton")
SliderBar.Size = UDim2.new(0, 210, 0, 8)
SliderBar.Position = UDim2.new(0, 20, 0, 125)
SliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
SliderBar.Text = ""
SliderBar.Parent = MainFrame

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(0, 4)
BarCorner.Parent = SliderBar

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(Max_Distance / 15000, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBar

local UserInputService = game:GetService("UserInputService")
local dragging = false

SliderBar.MouseButton1Down:Connect(function() dragging = true end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = input.Position.X
        local barLeftPos = SliderBar.AbsolutePosition.X
        local barWidth = SliderBar.AbsoluteSize.X
        
        local percentage = math.clamp((mousePos - barLeftPos) / barWidth, 0, 1)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        
        Max_Distance = math.floor(percentage * 15000)
        if Max_Distance > 14000 then
            SliderLabel.Text = "Tầm quét: Vô hạn (Toàn Map)"
            Max_Distance = 999999
        else
            SliderLabel.Text = "Tầm quét: " .. Max_Distance .. " studs"
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
