-- [[ RIVALS PREMIUM BRAINROT HUB v3.0 - DISTANCE LINKED AIM & ESP ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ HỆ THỐNG CẤU HÌNH GỐC ]]
local Config = {
    Aimbot = true,
    GhimCung = true,
    TeamCheck = false,
    FOVSize = 200,
    Smoothness = 15, -- Phần trăm (%)
    TargetPart = "Head", -- "Head" hoặc "HumanoidRootPart"
    
    ESP_Enabled = true,
    MaxDistance = 300,
    ESP_TeamCheck = false,
    ESP_Name = true,
    ESP_Distance = true,
    ESP_Health = true
}

-- [[ KHỞI TẠO CÁC DỊCH VỤ ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ TẠO VÒNG TRÒN FOV TRỰC QUAN ]]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(219, 48, 105)
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- ==========================================
-- [[ 🛠️ PHẦN THIẾT KẾ GIAO DIỆN (UI MENU) ]]
-- ==========================================

local BrainrotHub = Instance.new("ScreenGui")
BrainrotHub.Name = "BrainrotHub_DistanceSystem"
BrainrotHub.Parent = CoreGui
BrainrotHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Khung chính (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 360)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderColor3 = Color3.fromRGB(219, 48, 105)
MainFrame.BorderSizePixel = 1
MainFrame.Active = true
MainFrame.Draggable = true -- Cho phép kéo menu di chuyển trên màn hình
MainFrame.Parent = BrainrotHub

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainFrame

-- Thanh Tiêu Đề (Title Bar)
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 400, 0, 35)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Brainrot Hub — Distance Linked System"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

-- Nút Thu Nhỏ [-]
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "[-]"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Parent = MainFrame

-- Thanh Menu Bên Trái (Sidebar)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -45)
Sidebar.Position = UDim2.new(0, 10, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 4)
SideCorner.Parent = Sidebar

-- Vùng Chứa Nội Dung Bên Phải (Content)
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -160, 1, -45)
ContentFrame.Position = UDim2.new(0, 150, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local MainTabFrame = Instance.new("ScrollingFrame")
MainTabFrame.Size = UDim2.new(1, 0, 1, 0)
MainTabFrame.BackgroundTransparency = 1
MainTabFrame.CanvasSize = UDim2.new(0, 0, 1, 50)
MainTabFrame.ScrollBarThickness = 2
MainTabFrame.Parent = ContentFrame

local ESPTabFrame = Instance.new("ScrollingFrame")
ESPTabFrame.Size = UDim2.new(1, 0, 1, 0)
ESPTabFrame.BackgroundTransparency = 1
ESPTabFrame.CanvasSize = UDim2.new(0, 0, 1, 80)
ESPTabFrame.ScrollBarThickness = 2
ESPTabFrame.Visible = false
ESPTabFrame.Parent = ContentFrame

-- Bộ bố cục tự động sắp xếp nút
local MainLayout = Instance.new("UIListLayout")
MainLayout.Padding = UDim.new(0, 8)
MainLayout.Parent = MainTabFrame

local ESPLayout = Instance.new("UIListLayout")
ESPLayout.Padding = UDim.new(0, 8)
ESPLayout.Parent = ESPTabFrame

-- [[ HÀM TẠO NÚT BẤM TAB CHUYỂN ĐỔI ]]
local Tab1 = Instance.new("TextButton")
Tab1.Size = UDim2.new(1, -10, 0, 35)
Tab1.Position = UDim2.new(0, 5, 0, 5)
Tab1.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Tab1.Text = "Ngắm Bắn (Main)"
Tab1.TextColor3 = Color3.fromRGB(219, 48, 105)
Tab1.Font = Enum.Font.SourceSansBold
Tab1.TextSize = 13
Tab1.Parent = Sidebar
Instance.new("UICorner", Tab1).CornerRadius = UDim.new(0, 4)

local Tab2 = Instance.new("TextButton")
Tab2.Size = UDim2.new(1, -10, 0, 35)
Tab2.Position = UDim2.new(0, 5, 0, 45)
Tab2.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Tab2.Text = "Hiển Thị (ESP)"
Tab2.TextColor3 = Color3.fromRGB(200, 200, 200)
Tab2.Font = Enum.Font.SourceSansBold
Tab2.TextSize = 13
Tab2.Parent = Sidebar
Instance.new("UICorner", Tab2).CornerRadius = UDim.new(0, 4)

Tab1.MouseButton1Click:Connect(function()
    MainTabFrame.Visible = true
    ESPTabFrame.Visible = false
    Tab1.TextColor3 = Color3.fromRGB(219, 48, 105)
    Tab2.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

Tab2.MouseButton1Click:Connect(function()
    MainTabFrame.Visible = false
    ESPTabFrame.Visible = true
    Tab1.TextColor3 = Color3.fromRGB(200, 200, 200)
    Tab2.TextColor3 = Color3.fromRGB(219, 48, 105)
end)

-- Ẩn/Hiện Menu khi bấm nút [-]
local MenuMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    MenuMinimized = not MenuMinimized
    Sidebar.Visible = not MenuMinimized
    ContentFrame.Visible = not MenuMinimized
    MainFrame.Size = MenuMinimized and UDim2.new(0, 550, 0, 35) or UDim2.new(0, 550, 0, 360)
end)

-- [[ HÀM TẠO UI COMPONENT (TOGGLE & SLIDER) ]]
local function CreateToggle(name, parent, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 13
    Label.Font = Enum.Font.SourceSans
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 45, 0, 22)
    Switch.Position = UDim2.new(1, -55, 0.5, -11)
    Switch.BackgroundColor3 = default and Color3.fromRGB(219, 48, 105) or Color3.fromRGB(60, 60, 65)
    Switch.Text = ""
    Switch.Parent = Frame
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 11)
    
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = default and UDim2.new(1, -20, 0, 3) or UDim2.new(0, 4, 0, 3)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.Parent = Switch
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(0, 8)
    
    local state = default
    Switch.MouseButton1Click:Connect(function()
        state = not state
        Switch.BackgroundColor3 = state and Color3.fromRGB(219, 48, 105) or Color3.fromRGB(60, 60, 65)
        Circle.Position = state and UDim2.new(1, -20, 0, 3) or UDim2.new(0, 4, 0, 3)
        callback(state)
    end)
end

local function CreateSlider(name, parent, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 4)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 13
    Label.Font = Enum.Font.SourceSans
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    ValueLabel.Position = UDim2.new(1, -110, 0, 4)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(219, 48, 105)
    ValueLabel.TextSize = 13
    ValueLabel.Font = Enum.Font.SourceSansBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Frame
    
    local SliderBar = Instance.new("TextButton")
    SliderBar.Size = UDim2.new(1, -20, 0, 4)
    SliderBar.Position = UDim2.new(0, 10, 0, 32)
    SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    SliderBar.Text = ""
    SliderBar.Parent = Frame
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(219, 48, 105)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    
    local holding = false
    local function update()
        local mousePos = UserInputService:GetMouseLocation().X
        local barPos = SliderBar.AbsolutePosition.X
        local barWidth = SliderBar.AbsoluteSize.X
        local percentage = math.clamp((mousePos - barPos) / barWidth, 0, 1)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        local value = math.round(min + (max - min) * percentage)
        ValueLabel.Text = tostring(value)
        callback(value)
    end
    
    SliderBar.MouseButton1Down:Connect(function() holding = true update() end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then holding = false end end)
    UserInputService.InputChanged:Connect(function(input) if holding and input.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
end

-- [[ KHỞI TẠO CÁC NÚT ĐIỀU KHIỂN THEO ẢNH ]]

-- TAB MAIN
CreateToggle("Bật Tự Động Ngắm (Aimbot)", MainTabFrame, Config.Aimbot, function(v) Config.Aimbot = v end)
CreateToggle("Chế Độ Ghim Cứng (Không Rung)", MainTabFrame, Config.GhimCung, function(v) Config.GhimCung = v end)
CreateToggle("Né Đồng Đội (Team Check)", MainTabFrame, Config.TeamCheck, function(v) Config.TeamCheck = v end)
CreateToggle("Ngắm Vào Đầu (Tắt = Ngắm Thân)", MainTabFrame, true, function(v) Config.TargetPart = v and "Head" or "HumanoidRootPart" end)
CreateSlider("Kích Thước Vòng Tròn FOV", MainTabFrame, 10, 500, Config.FOVSize, function(v) Config.FOVSize = v end)
CreateSlider("Độ Mượt Chế Độ Thường (%)", MainTabFrame, 0, 100, Config.Smoothness, function(v) Config.Smoothness = v end)

-- TAB ESP
CreateToggle("Bật Phát Sáng Người (Chams)", ESPTabFrame, Config.ESP_Enabled, function(v) Config.ESP_Enabled = v end)
CreateToggle("Không Hiện Đồng Đội (Team Check)", ESPTabFrame, Config.ESP_TeamCheck, function(v) Config.ESP_TeamCheck = v end)
CreateToggle("Hiển Thị Tên Nhân Vật", ESPTabFrame, Config.ESP_Name, function(v) Config.ESP_Name = v end)
CreateToggle("Hiển Thị Khoảng Cách", ESPTabFrame, Config.ESP_Distance, function(v) Config.ESP_Distance = v end)
CreateToggle("Hiển Thị Chỉ Số Máu", ESPTabFrame, Config.ESP_Health, function(v) Config.ESP_Health = v end)
CreateSlider("Khoảng Cách ESP Tối Đa (m)", ESPTabFrame, 50, 1000, Config.MaxDistance, function(v) Config.MaxDistance = v end)


-- ==========================================
-- [[ ⚙️ PHẦN XỬ LÝ LOGIC (AIMBOT + ESP) ]]
-- ==========================================

-- Logic kiểm tra mục tiêu có hiển thị ESP hợp lệ không
local function hasActiveESP(targetPlayer)
    if targetPlayer == LocalPlayer then return false end
    if Config.ESP_TeamCheck and targetPlayer.Team == LocalPlayer.Team then return false end
    
    local character = targetPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then return false end
    if character.Humanoid.Health <= 0 then return false end
    
    -- Kiểm tra giới hạn khoảng cách tối đa của ESP
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if localRoot then
        local dist = (localRoot.Position - character.HumanoidRootPart.Position).Magnitude
        if dist > Config.MaxDistance then return false end -- Vượt quá khoảng cách ESP -> Hủy bỏ khóa ngắm
    end
    return true
end

-- Logic tìm kiếm người chơi gần tâm chuột nhất nằm trong vùng FOV và có ESP
local function getClosestPlayerInFOV()
    local mousePos = UserInputService:GetMouseLocation()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if hasActiveESP(player) then
            -- Kiểm tra thêm điều kiện TeamCheck của mục Aim riêng biệt
            if not (Config.TeamCheck and player.Team == LocalPlayer.Team) then
                local character = player.Character
                local part = character:FindFirstChild(Config.TargetPart)
                
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local distanceToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if distanceToMouse <= Config.FOVSize and distanceToMouse < shortestDistance then
                            closestPlayer = character
                            shortestDistance = distanceToMouse
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Quản lý hiệu ứng Chams (Phát Sáng)
local function applyChams(player)
    RunService.Heartbeat:Connect(function()
        local character = player.Character
        if character and hasActiveESP(player) and Config.ESP_Enabled then
            local highlight = character:FindFirstChild("BrainrotChams")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "BrainrotChams"
                highlight.FillColor = Color3.fromRGB(219, 48, 105)
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
                highlight.Parent = character
            end
        else
            if character and character:FindFirstChild("BrainrotChams") then
                character.BrainrotChams:Destroy()
            end
        end
    end)
end

for _, p in pairs(Players:GetPlayers()) do applyChams(p) end
Players.PlayerAdded:Connect(applyChams)

-- Vòng lặp cập nhật liên tục (Aimbot & FOV)
RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = mousePos
    FOVCircle.Radius = Config.FOVSize
    FOVCircle.Visible = Config.Aimbot

    if Config.Aimbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetChar = getClosestPlayerInFOV()
        if targetChar then
            local part = targetChar:FindFirstChild(Config.TargetPart)
            if part then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                
                if Config.GhimCung then
                    Camera.CFrame = targetCFrame -- Ghim cứng không rung lệch
                else
                    local smoothVal = math.clamp(Config.Smoothness / 100, 0.01, 1)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothVal) -- Di chuyển mượt theo % slider
                end
            end
        end
    end
end)
