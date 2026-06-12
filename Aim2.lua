-- [[ ASYLUM LIFE PATIENT ESP & AIMBOT SYNC — v14.0 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== CẤU HÌNH ĐỒNG BỘ v14.0 ====================
local Config = {
    PatientESP = false,
    Aimbot = false,
    Color = Color3.fromRGB(255, 0, 120) -- Màu hồng Neon đặc trưng
}

local MenuVisible = true
local IsMinimized = false
local TabFrames = {}
local Highlights = {}
local AimbotHolding = false

-- ==================== GETHUI BYPASS (CHỐNG ẨN MENU) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AsylumLifeV14SyncHub"
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
  
 -- Tạo vòng tròn FOV (Drawing API)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Config.Aimbot.Enabled
FOVCircle.Filled = false
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.NumSides = 100
FOVCircle.Radius = Config.Aimbot.FOV
-- ==================== PREMIUM NEON GUI GIAO DIỆN HỒNG NEON ====================
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
Title.Text = "Asylum Life Hub — v14.0 ESP & Aimbot Sync"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.35, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.65, -45, 0.5, -10)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Hệ thống: Sẵn sàng"
StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 120)
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

-- ==================== CÀI ĐẶT CÁC TAB CHỨC NĂNG ====================
local EspTab = CreateTab("Nhìn Xuyên Tường", 0)
local AimbotTab = CreateTab("Tự Động Ngắm", 1)

AddToggle(EspTab, "Chỉ Hiện Bệnh Nhân (Patient ESP)", Config.PatientESP, function(s)
    Config.PatientESP = s
    if not s then
        -- Xóa sạch ESP khi tắt chức năng
        for player, highlight in pairs(Highlights) do
            if highlight then highlight:Destroy() end
            Highlights[player] = nil
        end
    end
end)

AddToggle(AimbotTab, "Kích Hoạt Tự Ngắm (Aimbot)", Config.Aimbot, function(s)
    Config.Aimbot = s
end)

-- ==================== ENGINE KHÓA VÀ LỌC MỤC TIÊU ĐỒNG BỘ ====================

-- Hàm kiểm tra xem người chơi có thuộc đội Bệnh nhân hay không
local function IsPatient(player)
    if player and player.Team then
        local teamName = string.lower(player.Team.Name)
        if string.find(teamName, "patient") or string.find(teamName, "bệnh nhân") or string.find(teamName, "inmate") then
            return true
        end
    end
    return false
end

-- Vòng lặp vẽ và kiểm tra Highlight ESP
task.spawn(function()
    while task.wait(0.5) do
        if Config.PatientESP then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and IsPatient(player) and player.Character then
                    if not Highlights[player] or not Highlights[player].Parent then
                        local highlight = Instance.new("Highlight")
                        highlight.FillColor = Config.Color
                        highlight.FillTransparency = 0.5
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.OutlineTransparency = 0
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.Parent = player.Character
                        Highlights[player] = highlight
                    end
                elseif Highlights[player] then
                    -- Nếu người chơi đổi đội hoặc không thỏa mãn điều kiện thì hủy ESP
                    Highlights[player]:Destroy()
                    Highlights[player] = nil
                end
            end
        end
    end
end)

-- Hàm tìm Bệnh nhân gần tâm chuột nhất dựa trên những người "đang dính ESP"
local function GetClosestTarget()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    -- LUẬT: Nếu không bật ESP, hoặc hệ thống ESP chưa gán thẻ cho ai -> Không thể khóa mục tiêu
    if not Config.PatientESP then return nil end

    for player, highlight in pairs(Highlights) do
        if player and player.Character and player.Character:FindFirstChild("Head") and highlight.Parent == player.Character then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- Lắng nghe sự kiện click chuột phải để bật Aimbot
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotHolding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotHolding = false
    end
end)

-- Vòng lặp Aimbot mượt mà khóa mục tiêu theo khung hình máy tính
RunService.RenderStepped:Connect(function()
    if Config.Aimbot and AimbotHolding and Config.PatientESP then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            -- Điều chỉnh góc Camera xoay thẳng vào vị trí Đầu (Head) của bệnh nhân đang bị ESP bám đuôi
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- Tự động dọn dẹp khi người chơi thoát
Players.PlayerRemoving:Connect(function(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
end)
