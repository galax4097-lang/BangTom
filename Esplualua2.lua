local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

-- Hủy GUI cũ né trùng lặp
if CoreGui:FindFirstChild("EHEsp_FinalFix") then
    CoreGui.EHEsp_FinalFix:Destroy()
end

-- ================= CẤU HÌNH TRẠNG THÁI =================
local ESP_Enabled = true
local Max_Distance = 5000 

local Active_Tags = {}
local Active_Highlights = {}

-- ================= HÀM PHÂN BIỆT ĐỘI (TEAM) =================
local function GetPlayerRole(player)
    if not player or not player.Team then return "Unknown" end
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

-- ================= HÀM TẠO / XÓA ESP ELEMENT =================
local function ApplyESPToTarget(object, id, text, color)
    -- 1. Tạo Thẻ chữ (BillboardGui)
    if not Active_Tags[id] then
        local bbg = Instance.new("BillboardGui")
        bbg.Name = "ESP_Tag"
        bbg.Size = UDim2.new(0, 200, 0, 50)
        bbg.AlwaysOnTop = true
        bbg.ExtentsOffset = Vector3.new(0, 3, 0)
        bbg.Parent = CoreGui

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 14
        label.Parent = bbg

        Active_Tags[id] = {Gui = bbg, Label = label}
    end
    
    local tag = Active_Tags[id]
    tag.Gui.Enabled = true
    tag.Gui.Adornee = object
    tag.Label.TextColor3 = color
    tag.Label.Text = text

    -- 2. Tạo Vòng viền (Highlight) riêng biệt
    if not Active_Highlights[id] then
        local hl = Instance.new("Highlight")
        hl.Name = "ESP_Highlight"
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 0.6
        hl.OutlineTransparency = 0
        hl.Parent = CoreGui
        Active_Highlights[id] = hl
    end
    
    local hl = Active_Highlights[id]
    hl.Enabled = true
    hl.Adornee = object
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
end

local function ClearESP(id)
    if Active_Tags[id] then
        Active_Tags[id].Gui.Enabled = false
    end
    if Active_Highlights[id] then
        Active_Highlights[id].Enabled = false
    end
end

-- Tìm xe trong Workspace dựa trên người đang lái (thường lưu ở thuộc tính hoặc tên của Ghế lái xe)
local function FindVehicleDrivenBy(player)
    -- Quét qua các vùng chứa xe phổ biến trong Emergency Hamburg
    local vehiclesFolder = Workspace:FindFirstChild("Vehicles") or Workspace:FindFirstChild("IngameVehicles") or Workspace
    for _, veh in ipairs(vehiclesFolder:GetChildren()) do
        if veh:IsA("Model") then
            local seat = veh:FindFirstChildOfClass("VehicleSeat") or veh:FindFirstChild("DriveSeat")
            if seat and seat:IsA("VehicleSeat") then
                -- Kiểm tra xem người ngồi lái có trùng với người chơi mục tiêu không
                if seat.Occupant and seat.Occupant.Parent and Players:GetPlayerFromCharacter(seat.Occupant.Parent) == player then
                    return veh
                end
            end
        end
    end
    return nil
end

-- ================= VÒNG LẶP LIÊN TỤC (RENDERSTEPPED) =================
RunService.RenderStepped:Connect(function()
    if not ESP_Enabled then
        for id, _ in pairs(Active_Tags) do ClearESP(id) end
        return
    end

    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end

    for _, player in ipairs(Players:GetPlayers()) do
        local id = player.UserId
        
        if ShouldShowESP(player) then
            local role = GetPlayerRole(player)
            local color = (role == "Police") and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(255, 255, 255)
            
            -- Bước 1: Thử quét xem người này có đang ở trên xe nào không
            local targetVehicle = FindVehicleDrivenBy(player)
            
            if targetVehicle then
                -- NẾU TRÊN XE: Chỉ hiện xe, ẩn hoàn toàn tag người
                local primary = targetVehicle.PrimaryPart or targetVehicle:FindFirstChildOfClass("VehicleSeat") or targetVehicle:FindFirstChildOfClass("Part")
                if primary then
                    local dist = math.floor((myHrp.Position - primary.Position).Magnitude)
                    if dist <= Max_Distance then
                        local text = string.format("[POLICE CAR]\nLái xe: %s\nDis: %dm", player.Name, dist)
                        ApplyESPToTarget(targetVehicle, id, text, color)
                    else
                        ClearESP(id)
                    end
                end
            else
                -- NẾU ĐI BỘ: Hiện ESP nhân vật như thường
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if hrp and hum and hum.Health > 0 then
                    local dist = math.floor((myHrp.Position - hrp.Position).Magnitude)
                    if dist <= Max_Distance then
                        local text = string.format("[%s]\nDis: %dm\nHP: %d/%d", player.Name, dist, math.floor(hum.Health), math.floor(hum.MaxHealth))
                        ApplyESPToTarget(char, id, text, color)
                    else
                        ClearESP(id)
                    end
                else
                    -- Không tìm thấy xe lẫn người (đang load hoặc đã chết hẳn) -> Clear
                    ClearESP(id)
                end
            end
        else
            -- Không thỏa điều kiện team -> Xóa tag
            ClearESP(id)
        end
    end
end)

-- Dọn dẹp hẳn bộ nhớ khi có người thoát hẳn server
Players.PlayerRemoving:Connect(function(player)
    local id = player.UserId
    if Active_Tags[id] then Active_Tags[id].Gui:Destroy() Active_Tags[id] = nil end
    if Active_Highlights[id] then Active_Highlights[id]:Destroy() Active_Highlights[id] = nil end
end)

-- ================= GIAO DIỆN MENU (GUI) =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EHEsp_FinalFix"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 180)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
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
Title.Text = "EH ESP V4 - VEHICLE SEPARATE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 210, 0, 35)
ToggleBtn.Position = UDim2.new(0, 20, 0, 45)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ToggleBtn.Text = "ESP: ON"
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
        ToggleBtn.Text = "ESP: ON"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        ToggleBtn.Text = "ESP: OFF"
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
