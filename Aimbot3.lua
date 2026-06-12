-- [[ ASYLUM LIFE PATIENT ESP — v13.0 NEON BYPASS ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ==================== CẤU HÌNH TÍNH NĂNG ====================
local Config = {
    PatientESP = false,
    Color = Color3.fromRGB(255, 0, 120) -- Màu hồng Neon nhận diện bệnh nhân
}

local MenuVisible = true
local IsMinimized = false
local TabFrames = {}
local Highlights = {}

-- ==================== GETHUI BYPASS (CHỐNG ẨN MENU) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AsylumLifeV13Hub"
ScreenGui.ResetOnSpawn = false

local function ApplySafeParent()
    if gethui then 
        ScreenGui.Parent = gethui()
    else
        local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
        if success and coreGui then
            ScreenGui.Parent = coreGui
        else
            ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end
end
ApplySafeParent()

-- ==================== PREMIUM NEON GUI GIAO DIỆN QUEN THUỘC ====================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 320)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 120)
UIStroke.Thickness = 1.6
UIStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Asylum Life Hub — v13.0 Chỉ Hiện Bệnh Nhân"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.35, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.65, -45, 0.5, -10)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Patient ESP: ĐANG TẮT"
StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
StatusLabel.Font = Enum.Font.SourceSansItalic
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
StatusLabel.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -45, 0, 2)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "[-]"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = TopBar

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -155, 1, -55)
Container.Position = UDim2.new(0, 150, 0, 48)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

MinimizeBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        Sidebar.Visible = false; Container.Visible = false
        MainFrame.Size = UDim2.new(0, 520, 0, 40)
        MinimizeBtn.Text = "[+]"
    else
        MainFrame.Size = UDim2.new(0, 520, 0, 320)
        Sidebar.Visible = true; Container.Visible = true
        MinimizeBtn.Text = "[-]"
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert then
        MenuVisible = not MenuVisible
        MainFrame.Visible = MenuVisible
    end
end)

-- ==================== HÀM TẠO THÀNH PHẦN GUI ====================
local function CreateTab(tabName, order)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 120, 0, 35)
    TabBtn.Position = UDim2.new(0, 10, 0, 10 + (order * 40))
    TabBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.Font = Enum.Font.SourceSansSemibold
    TabBtn.TextSize = 14
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.CanvasSize = UDim2.new(0, 0, 1.2, 0)
    TabFrame.ScrollBarThickness = 2
    TabFrame.Visible = (order == 0)
    TabFrame.Parent = Container
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 6)
    UIList.Parent = TabFrame

    TabFrames[tabName] = TabFrame
    TabBtn.MouseButton1Click:Connect(function()
        for k, v in pairs(TabFrames) do v.Visible = (k == tabName) end
    end)
    return TabFrame
end

local function AddToggle(tabFrame, text, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -10, 0, 38)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Row.BorderSizePixel = 0
    Row.Parent = tabFrame
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 215)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 42, 0, 20)
    Switch.Position = UDim2.new(1, -52, 0, 9)
    Switch.Text = ""
    Switch.Parent = Row
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

    local State = default
    local function updateVisual() Switch.BackgroundColor3 = State and Color3.fromRGB(255, 0, 120) or Color3.fromRGB(60, 60, 65) end
    updateVisual()

    Switch.MouseButton1Click:Connect(function() State = not State updateVisual() callback(State) end)
end

-- ==================== CÀI ĐẶT TAB & CHỨC NĂNG ESP BIỆT LẬP ====================
local EspTab = CreateTab("Nhìn Xuyên Tường", 0)

AddToggle(EspTab, "Chỉ Hiện Bệnh Nhân (Patient ESP)", Config.PatientESP, function(s)
    Config.PatientESP = s
    if s then
        StatusLabel.Text = "Patient ESP: ĐANG BẬT"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
    else
        StatusLabel.Text = "Patient ESP: ĐANG TẮT"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        -- Xóa sạch ESP khi tắt chức năng
        for player, highlight in pairs(Highlights) do
            if highlight then highlight:Destroy() end
            Highlights[player] = nil
        end
    end
end)

-- ==================== ENGINE QUÉT VÀ LỌC ĐỘI NHÓM CHÍNH XÁC ====================

-- Hàm kiểm tra xem người chơi có phải là Bệnh nhân hay không
local function IsPatient(player)
    if player and player.Team then
        local teamName = string.lower(player.Team.Name)
        -- Quét các từ khóa liên quan tới Bệnh nhân/Tù nhân trong Asylum Life
        if string.find(teamName, "patient") or string.find(teamName, "bệnh nhân") or string.find(teamName, "inmate") then
            return true
        end
    end
    return false
end

-- Hàm áp dụng viền Highlight lên nhân vật
local function ApplyHighlight(player)
    if not Config.PatientESP then return end
    if player == LocalPlayer then return end -- Không tự bật lên chính mình
    
    local character = player.Character
    if character then
        -- Nếu đã là Bệnh nhân và chưa được tạo Highlight
        if IsPatient(player) then
            if not Highlights[player] or not Highlights[player].Parent then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Config.Color
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = character
                Highlights[player] = highlight
            end
        else
            -- Nếu đổi sang đội Cảnh sát/Bác sĩ -> Lập tức xóa bỏ viền ngay khung hình tiếp theo
            if Highlights[player] then
                Highlights[player]:Destroy()
                Highlights[player] = nil
            end
        end
    end
end

-- Vòng lặp tối ưu kiểm tra trạng thái toàn Server liên tục mỗi 0.5 giây
task.spawn(function()
    while task.wait(0.5) do
        if Config.PatientESP then
            for _, player in pairs(Players:GetPlayers()) do
                ApplyHighlight(player)
            end
        end
    end
end)

-- Lắng nghe khi người chơi hồi sinh hoặc đổi ngoại hình
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5) -- Chờ nhân vật tải xong hoàn toàn
        ApplyHighlight(player)
    end)
end)

-- Tự động dọn dẹp bộ nhớ khi có người rời server
Players.PlayerRemoving:Connect(function(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
end)

-- Thông báo nạp thành công hệ thống định vị bệnh nhân
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Asylum Life ESP",
        Text = "Đã khóa mục tiêu: Chỉ quét Bệnh Nhân!",
        Duration = 4
    })
end)
