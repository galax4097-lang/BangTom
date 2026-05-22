-- [[ RIVALS BRAINROT PREMIUM HUB v2.0 - CUSTOM SIDEBAR UI ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== HỆ THỐNG CẤU HÌNH BIẾN TOÀN CỤC ====================
local Config = {
    Aimbot = { Enabled = true, Key = Enum.UserInputType.MouseButton2, FOV = 200, Smoothness = 0.12, TargetPart = "Head" },
    ESP = { Enabled = true, Names = true, Distance = true, Health = true, Color = Color3.fromRGB(255, 0, 100) }
}

local IsAiming = false
local MenuVisible = true
local IsMinimized = false
local ActiveTab = "Combat"
local TabFrames = {}

-- Vòng tròn FOV tâm ngắm (Drawing API)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Config.Aimbot.Enabled
FOVCircle.Filled = false
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.NumSides = 100
FOVCircle.Radius = Config.Aimbot.FOV

-- ==================== KHỞI TẠO GIAO DIỆN CHUẨN TRONG ẢNH ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotHubUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Khung chính của Menu
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Giữ thanh tiêu đề để kéo thả di chuyển bảng
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 9)
MainCorner.Parent = MainFrame

-- Viền phát sáng màu Hồng/Tím Neon giống ảnh minh họa
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(230, 30, 110)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Thanh tiêu đề phía trên (TopBar)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 9)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Brainrot Hub — Escape Tsunami"
Title.TextColor3 = Color3.fromRGB(230, 230, 235)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- NÚT THU NHỎ / PHÓNG TO (MINIMIZE BUTTON)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -45, 0, 2)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "[-]"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = TopBar

-- Thanh Menu bên trái (Sidebar)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Vùng hiển thị nội dung bên phải (Content Window)
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -150, 1, -50)
Container.Position = UDim2.new(0, 145, 0, 45)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- Xử lý Logic Thu nhỏ / Phóng to giao diện
MinimizeBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        Sidebar.Visible = false
        Container.Visible = false
        MainFrame.Size = UDim2.new(0, 520, 0, 40) -- Thu nhỏ thành 1 thanh ngang
        MinimizeBtn.Text = "[+]"
    else
        MainFrame.Size = UDim2.new(0, 520, 0, 340) -- Phóng to lại ban đầu
        Sidebar.Visible = true
        Container.Visible = true
        MinimizeBtn.Text = "[-]"
    end
end)

-- Phím tắt ẩn hoàn toàn Menu (Insert / RightControl)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert then
        MenuVisible = not MenuVisible
        MainFrame.Visible = MenuVisible
        if not MenuVisible then FOVCircle.Visible = false else FOVCircle.Visible = Config.Aimbot.Enabled end
    end
end)

-- ==================== HÀM TẠO THÀNH PHẦN GIAO DIỆN (UI BUILDER) ====================
local function CreateTab(tabName, order)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 120, 0, 35)
    TabBtn.Position = UDim2.new(0, 10, 0, 10 + (order * 40))
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.Font = Enum.Font.SourceSansSemibold
    TabBtn.TextSize = 14
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
    TabFrame.ScrollBarThickness = 3
    TabFrame.Visible = (order == 0)
    TabFrame.Parent = Container
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 8)
    UIList.Parent = TabFrame

    TabFrames[tabName] = TabFrame

    TabBtn.MouseButton1Click:Connect(function()
        for k, v in pairs(TabFrames) do v.Visible = (k == tabName) end
    end)
    return TabFrame
end

local function AddToggle(tabFrame, text, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -10, 0, 40)
    Row.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
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
    Switch.Size = UDim2.new(0, 45, 0, 22)
    Switch.Position = UDim2.new(1, -55, 0, 9)
    Switch.Text = ""
    Switch.Parent = Row
    local SwCorner = Instance.new("UICorner", Switch)
    SwCorner.CornerRadius = UDim.new(1, 0)

    local State = default
    local function updateVisual()
        Switch.BackgroundColor3 = State and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 65)
    end
    updateVisual()

    Switch.MouseButton1Click:Connect(function()
        State = not State
        updateVisual()
        callback(State)
    end)
end

local function AddSlider(tabFrame, text, min, max, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -10, 0, 50)
    Row.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    Row.BorderSizePixel = 0
    Row.Parent = tabFrame
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 215)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 25)
    ValueLabel.Position = UDim2.new(0.7, -10, 0, 2)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
    ValueLabel.Font = Enum.Font.SourceSansBold
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Row

    local SliderBar = Instance.new("TextButton")
    SliderBar.Size = UDim2.new(1, -20, 0, 5)
    SliderBar.Position = UDim2.new(0, 10, 0, 32)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    SliderBar.Text = ""
    SliderBar.Parent = Row

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderBar

    local function updateSlider(input)
        local totalWidth = SliderBar.AbsoluteSize.X
        local relX = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X, 0, totalWidth)
        local percentage = relX / totalWidth
        local value = math.floor(min + (max - min) * percentage)
        ValueLabel.Text = tostring(value)
        Fill.Size = UDim2.new(percentage, 0, 1, 0)
        callback(value)
    end

    local sliding = false
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true updateSlider(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
end

-- TẠO CÁC DANH MỤC TRONG MENU TRÁI
local CombatTab = CreateTab("Ngắm Bắn (Main)", 0)
local ESPTab = CreateTab("Hiển Thị (ESP)", 1)

-- Điền chức năng vào tab Combat
AddToggle(CombatTab, "Bật Tự Động Ngắm (Aimbot)", Config.Aimbot.Enabled, function(s) Config.Aimbot.Enabled = s FOVCircle.Visible = s end)
AddSlider(CombatTab, "Kích Thước Vòng Tròn FOV", 50, 600, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v FOVCircle.Radius = v end)
AddSlider(CombatTab, "Độ Mượt (Smoothness %)", 1, 30, 12, function(v) Config.Aimbot.Smoothness = v / 100 end)

-- Điền chức năng vào tab ESP
AddToggle(ESPToggle, "Bật Phát Sáng Người (Chams)", Config.ESP.Enabled, function(s) Config.ESP.Enabled = s if not s then for _, v in ipairs(workspace:GetDescendants()) do if v:IsA("Highlight") and v.Name == "BrainrotESP" then v:Destroy() end end end end)
AddToggle(ESPToggle, "Hiển Thị Tên Nhân Vật", Config.ESP.Names, function(s) Config.ESP.Names = s end)
AddToggle(ESPToggle, "Hiển Thị Khoảng Cách", Config.ESP.Distance, function(s) Config.ESP.Distance = s end)
AddToggle(ESPToggle, "Hiển Thị Thanh Máu", Config.ESP.Health, function(s) Config.ESP.Health = s end)


-- ==================== HỆ THỐNG ESP TEXT SỬ DỤNG BILLBOARDGUI TRONG SUỐT ====================
local function ManageTextESP(player)
    if player == LocalPlayer then return end
    
    local function createGui(char)
        local head = char:WaitForChild("Head", 5)
        local hum = char:WaitForChild("Humanoid", 5)
        if not head or not hum then return end

        local bbg = head:FindFirstChild("RivalsESP_Text") or Instance.new("BillboardGui")
        bbg.Name = "RivalsESP_Text"
        bbg.Size = UDim2.new(0, 200, 0, 60)
        bbg.StudsOffset = Vector3.new(0, 2.5, 0)
        bbg.AlwaysOnTop = true
        bbg.Parent = head

        local ContainerList = bbg:FindFirstChild("Container") or Instance.new("Frame")
        ContainerList.Name = "Container"
        ContainerList.Size = UDim2.new(1, 0, 1, 0)
        ContainerList.BackgroundTransparency = 1
        ContainerList.Parent = bbg

        local layout = ContainerList:FindFirstChild("Layout") or Instance.new("UIListLayout")
        layout.Name = "Layout"
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Parent = ContainerList

        local NameTag = ContainerList:FindFirstChild("NameTag") or Instance.new("TextLabel")
        NameTag.Name = "NameTag"
        NameTag.Size = UDim2.new(1, 0, 0, 16)
        NameTag.BackgroundTransparency = 1
        NameTag.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameTag.Font = Enum.Font.SourceSansBold
        NameTag.TextSize = 14
        NameTag.Parent = ContainerList

        local InfoTag = ContainerList:FindFirstChild("InfoTag") or Instance.new("TextLabel")
        InfoTag.Name = "InfoTag"
        InfoTag.Size = UDim2.new(1, 0, 0, 16)
        InfoTag.BackgroundTransparency = 1
        InfoTag.TextColor3 = Color3.fromRGB(0, 255, 120) -- Màu xanh lá dạ quang cho thông số
        InfoTag.Font = Enum.Font.SourceSans
        InfoTag.TextSize = 13
        InfoTag.Parent = ContainerList

        -- Đồng bộ liên tục dữ liệu trạng thái
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not char:IsDescendantOf(workspace) or hum.Health <= 0 then
                bbg:Destroy()
                connection:Disconnect()
                return
            end

            NameTag.Visible = Config.ESP.Names
            NameTag.Text = player.Name

            local dist = math.floor((head.Position - Camera.CFrame.Position).Magnitude)
            local infoStr = ""
            if Config.ESP.Distance then infoStr = infoStr .. "[" .. dist .. "m] " end
            if Config.ESP.Health then infoStr = infoStr .. "HP: " .. math.floor(hum.Health) end
            
            InfoTag.Visible = (Config.ESP.Distance or Config.ESP.Health)
            InfoTag.Text = infoStr
        end)
    end

    if player.Character then createGui(player.Character) end
    player.CharacterAdded:Connect(createGui)
end

-- ==================== CORE FUNCTION: AIMBOT LOGIC ====================
local function GetClosestPlayer()
    local Target = nil
    local MaxDist = Config.Aimbot.FOV

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild(Config.Aimbot.TargetPart)
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local diff = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if diff < MaxDist then MaxDist = diff Target = head end
                end
            end
        end
    end
    return Target
end

UserInputService.InputBegan:Connect(function(i, p) if not p and i.StringObject == nil then if i.UserInputType == Config.Aimbot.Key then IsAiming = true end end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Config.Aimbot.Key then IsAiming = false end end)

-- ==================== MAIN LOOP VÀ KHỞI CHẠY KHÔNG GIAN GAME ====================
for _, p in ipairs(Players:GetPlayers()) do ManageTextESP(p) end
Players.PlayerAdded:Connect(ManageTextESP)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Thực thi khóa tâm ngắm
    if Config.Aimbot.Enabled and IsAiming then
        local t = GetClosestPlayer()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), Config.Aimbot.Smoothness)
        end
    end

    -- Thực thi phát sáng Chams nhân vật
    if Config.ESP.Enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                local hl = p.Character:FindFirstChild("BrainrotESP") or Instance.new("Highlight")
                hl.Name = "BrainrotESP"
                hl.FillColor = Config.ESP.Color
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.4
                hl.OutlineTransparency = 0.1
                hl.Parent = p.Character
            end
        end
    end
end)
