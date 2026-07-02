local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Hủy GUI cũ nếu có trùng lặp
if CoreGui:FindFirstChild("EmergencyHamburgESP") then
    CoreGui.EmergencyHamburgESP:Destroy()
end

-- ================= CẤU HÌNH TRẠNG THÁI =================
local ESP_Enabled = true
local Max_Distance = 5000 -- Mặc định ban đầu (tăng giảm bằng slider)
local Team_Mode = "Auto" -- "Auto" sẽ tự động lọc theo yêu cầu của bạn

local Highlights = {}

-- ================= HÀM HỖ TRỢ PHÂN BIỆT TEAM =================
-- Lưu ý: Tên Team có thể thay đổi tùy thuộc vào bản cập nhật của Emergency Hamburg. 
-- Bạn có thể sửa lại chuỗi text bên dưới nếu game đổi tên Team.
local function GetPlayerRole(player)
    if not player.Team then return "Unknown" end
    local teamName = player.Team.Name:lower()
    
    if string.find(teamName, "police") or string.find(teamName, "sheriff") or string.find(teamName, "cảnh sát") then
        return "Police"
    elseif string.find(teamName, "civilian") or string.find(teamName, "dân") then
        return "Civilian"
    else
        return "Others" -- Các nghề cứu hỏa, cứu thương, rác, v.v.
    end
end

local function ShouldShowESP(targetPlayer)
    if targetPlayer == LocalPlayer then return false end
    
    local myRole = GetPlayerRole(LocalPlayer)
    local targetRole = GetPlayerRole(targetPlayer)
    
    -- Nếu tôi là Dân -> Chỉ hiện Cảnh sát
    if myRole == "Civilian" then
        return targetRole == "Police"
    -- Nếu tôi là Cảnh sát -> Chỉ hiện Dân (Ẩn đồng nghiệp & nghề khác)
    elseif myRole == "Police" then
        return targetRole == "Civilian"
    end
    
    -- Mặc định nếu bạn ở team khác (ví dụ Cứu hỏa), hiện cả 2 để không bị lỗi
    return targetRole == "Police" or targetRole == "Civilian"
end

-- ================= HÀM TẠO VÀ XÓA ESP =================
local function ApplyESP(player)
    if Highlights[player] then return end
    
    local function characterAdded(char)
        if not ESP_Enabled or not ShouldShowESP(player) then return end
        
        -- Kiểm tra khoảng cách
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if hrp and myHrp then
            local dist = (myHrp.Position - hrp.Position).Magnitude
            if dist > Max_Distance then return end
        end

        -- Tạo Highlight (Hiệu ứng viền xuyên tường bọc quanh người)
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Parent = CoreGui
        highlight.Adornee = char
        
        -- Đổi màu: Cảnh sát màu xanh dương, Dân màu trắng/đỏ tùy ý
        if GetPlayerRole(player) == "Police" then
            highlight.FillColor = Color3.fromRGB(0, 100, 255)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        else
            highlight.FillColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
        end
        
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        
        Highlights[player] = highlight
    end
    
    if player.Character then characterAdded(player.Character) end
    player.CharacterAdded:Connect(characterAdded)
end

local function RemoveESP(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
end

-- Làm mới toàn bộ ESP khi thay đổi cấu hình
local function RefreshESP()
    for p, _ in pairs(Highlights) do RemoveESP(p) end
    if not ESP_Enabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if ShouldShowESP(p) then ApplyESP(p) end
    end
end

-- Vòng lặp cập nhật khoảng cách theo thời gian thực
RunService.Heartbeat:Connect(function()
    if not ESP_Enabled then return end
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    for p, hl in pairs(Highlights) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and myHrp then
            local dist = (myHrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist > Max_Distance or not ShouldShowESP(p) then
                hl.Enabled = false
            else
                hl.Enabled = true
            end
        else
            if hl then hl.Enabled = false end
        end
    end
end)

Players.PlayerAdded:Connect(ApplyESP)
Players.PlayerRemoving:Connect(RemoveESP)
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(RefreshESP) -- Tự động đổi mục tiêu khi bạn đổi nghề

-- ================= TẠO GIAO DIỆN MENU (GUI) =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EmergencyHamburgESP"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 180)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Có thể giữ chuột để di chuyển Menu trên màn hình
MainFrame.Parent = ScreenGui

-- Bo góc Menu
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Tiêu đề Menu
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "EH ESP SMART MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Nút Bật/Tắt ESP
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 210, 0, 35)
ToggleBtn.Position = UDim2.new(0, 20, 0, 45)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ToggleBtn.Text = "ESP: ON (Smart Mode)"
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
        ToggleBtn.Text = "ESP: ON (Smart Mode)"
        RefreshESP()
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        ToggleBtn.Text = "ESP: OFF"
        for p, _ in pairs(Highlights) do RemoveESP(p) end
    end
end)

-- Nhãn Slider Khoảng cách
local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, 0, 0, 20)
SliderLabel.Position = UDim2.new(0, 0, 0, 95)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Tầm ESP: " .. Max_Distance .. " studs"
SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SliderLabel.Font = Enum.Font.SourceSans
SliderLabel.TextSize = 14
SliderLabel.Parent = MainFrame

-- Thanh Slider (Nền)
local SliderBar = Instance.new("TextButton")
SliderBar.Size = UDim2.new(0, 210, 0, 10)
SliderBar.Position = UDim2.new(0, 20, 0, 125)
SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
SliderBar.Text = ""
SliderBar.Parent = MainFrame

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(0, 4)
BarCorner.Parent = SliderBar

-- Nút trượt hoặc Phần hiển thị tiến trình kéo
local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(Max_Distance / 10000, 0, 1, 0) -- Giới hạn tối đa 10k studs (toàn bản đồ)
SliderFill.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBar

-- Xử lý kéo thả Slider bằng chuột hoặc ngón tay (cho mobile)
local UserInputService = game:GetService("UserInputService")
local dragging = false

SliderBar.MouseButton1Down:Connect(function()
    dragging = true
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = input.Position.X
        local barLeftPos = SliderBar.AbsolutePosition.X
        local barWidth = SliderBar.AbsoluteSize.X
        
        local percentage = math.clamp((mousePos - barLeftPos) / barWidth, 0, 1)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        
        -- Quy đổi phần trăm ra khoảng cách (0 đến 15000 studs - dư sức quét hết map EH)
        Max_Distance = math.floor(percentage * 15000)
        if Max_Distance > 14000 then
            SliderLabel.Text = "Tầm ESP: Vô hạn (Toàn Map)"
            Max_Distance = 999999
        else
            SliderLabel.Text = "Tầm ESP: " .. Max_Distance .. " studs"
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Khởi chạy quét lần đầu
RefreshESP()
