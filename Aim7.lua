-- [[ RIVALS PREMIUM BRAINROT HUB v3.0 — MOBILE OPTIMIZED ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== HỆ THỐNG CẤU HÌNH (SETTINGS) ====================
local Config = {
    Aimbot = {
        Enabled = true,
        HardLock = true,                      -- Ghim cứng dính chặt không rung
        FOV = 200,                             
        Smoothness = 0.15,                     
        TargetPart = "Head",                  
        TeamCheck = false                     
    },
    ESP = {
        Enabled = true,        
        Names = true,          
        Distance = true,       
        Health = true,         
        MaxDistance = 300,                    -- Chỉ hiện ESP và AIM trong vòng 300m
        TeamCheck = false,                    
        Color = Color3.fromRGB(255, 0, 100) 
    }
}

local IsAiming = false
local MenuVisible = true
local IsMinimized = false
local TabFrames = {}

-- Tạo vòng tròn FOV (Drawing API)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Config.Aimbot.Enabled
FOVCircle.Filled = false
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.NumSides = 100
FOVCircle.Radius = Config.Aimbot.FOV

-- ==================== KHỞI TẠO INTERFACE MOBILE ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotHub_Mobile"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- NÚT MỞ MENU NỔI DÀNH CHO ĐIỆN THOẠI (Chạm để ẩn/hiện)
local MobileToggleBtn = Instance.new("TextButton")
MobileToggleBtn.Size = UDim2.new(0, 60, 0, 30)
MobileToggleBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
MobileToggleBtn.BackgroundColor3 = Color3.fromRGB(230, 30, 110)
MobileToggleBtn.Text = "MENU"
MobileToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MobileToggleBtn.Font = Enum.Font.SourceSansBold
MobileToggleBtn.TextSize = 13
MobileToggleBtn.Parent = ScreenGui
Instance.new("UICorner", MobileToggleBtn).CornerRadius = UDim.new(0, 6)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 460, 0, 280) -- Thu nhỏ size một chút để vừa màn hình điện thoại nằm ngang
MainFrame.Position = UDim2.new(0.25, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = MainFrame
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 9)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(230, 30, 110) 
UIStroke.Thickness = 1.5

-- HỆ THỐNG DI CHUYỂN BẢNG BẰNG CẢM ỨNG (TOUCH DRAG) KHÔNG BỊ ĐƠ
local dragToggle, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragToggle then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Thanh tiêu đề (TopBar)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 9)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Brainrot Hub — Distance Linked (Mobile)"
Title.TextColor3 = Color3.fromRGB(230, 230, 235)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Sidebar trái
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -36)
Sidebar.Position = UDim2.new(0, 0, 0, 36)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Khung chứa nội dung phải
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -130, 1, -44)
Container.Position = UDim2.new(0, 125, 0, 40)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- Xử lý click nút MENU nổi ẩn hiện
MobileToggleBtn.MouseButton1Click:Connect(function()
    MenuVisible = not MenuVisible
    MainFrame.Visible = MenuVisible
    if not MenuVisible then FOVCircle.Visible = false else FOVCircle.Visible = Config.Aimbot.Enabled end
end)

-- ==================== NÚT ẢO ĐÈ GIỮ ĐỂ AIMBOT TRÊN PHÔN ====================
local MobileAimBtn = Instance.new("TextButton")
MobileAimBtn.Size = UDim2.new(0, 65, 0, 65)
MobileAimBtn.Position = UDim2.new(0.8, 0, 0.4, 0) -- Vị trí lý tưởng bên góc phải màn hình gần cụm nút nhảy/bắn
MobileAimBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
MobileAimBtn.BackgroundTransparency = 0.2
MobileAimBtn.Text = "AIM"
MobileAimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MobileAimBtn.Font = Enum.Font.SourceSansBold
MobileAimBtn.TextSize = 16
MobileAimBtn.Parent = ScreenGui

Instance.new("UICorner", MobileAimBtn).CornerRadius = UDim.new(1, 0)
local AimStroke = Instance.new("UIStroke", MobileAimBtn)
AimStroke.Color = Color3.fromRGB(230, 30, 110)
AimStroke.Thickness = 2

-- Cơ chế đè giữ ngón tay vào nút để kích hoạt ngắm bắn liên tục
MobileAimBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsAiming = true
        MobileAimBtn.BackgroundColor3 = Color3.fromRGB(230, 30, 110)
    end
end)
MobileAimBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsAiming = false
        MobileAimBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    end
end)

-- ==================== HÀM DỰNG THÀNH PHẦN UI CẢM ỨNG ====================
local function CreateTab(tabName, order)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 105, 0, 32)
    TabBtn.Position = UDim2.new(0, 7, 0, 8 + (order * 38))
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.Font = Enum.Font.SourceSansSemibold
    TabBtn.TextSize = 12
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 5)

    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.CanvasSize = UDim2.new(0, 0, 1.8, 0)
    TabFrame.ScrollBarThickness = 2
    TabFrame.Visible = (order == 0)
    TabFrame.Parent = Container
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 5)
    UIList.Parent = TabFrame

    TabFrames[tabName] = TabFrame
    TabBtn.MouseButton1Click:Connect(function()
        for k, v in pairs(TabFrames) do v.Visible = (k == tabName) end
    end)
    return TabFrame
end

local function AddToggle(tabFrame, text, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -8, 0, 34)
    Row.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    Row.BorderSizePixel = 0
    Row.Parent = tabFrame
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 5)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 215)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 38, 0, 18)
    Switch.Position = UDim2.new(1, -46, 0, 8)
    Switch.Text = ""
    Switch.Parent = Row
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

    local State = default
    local function updateVisual()
        Switch.BackgroundColor3 = State and Color3.fromRGB(230, 30, 110) or Color3.fromRGB(60, 60, 65)
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
    Row.Size = UDim2.new(1, -8, 0, 44)
    Row.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    Row.BorderSizePixel = 0
    Row.Parent = tabFrame
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 5)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 215)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    ValueLabel.Position = UDim2.new(0.7, -10, 0, 2)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(230, 30, 110)
    ValueLabel.Font = Enum.Font.SourceSansBold
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Row

    local SliderBar = Instance.new("TextButton")
    SliderBar.Size = UDim2.new(1, -20, 0, 4)
    SliderBar.Position = UDim2.new(0, 10, 0, 28)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    SliderBar.Text = ""
    SliderBar.Parent = Row

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(230, 30, 110)
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

    -- ĐÃ TỐI ƯU THÊM PHẦN TOUCH ĐỂ ĐIỆN THOẠI KHÔNG BỊ TRƯỢT HUYỄN
    local sliding = false
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true updateSlider(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
end

-- Khởi tạo các Tab chức năng mẫu Mobile
local CombatTab = CreateTab("Ngắm Bắn (Main)", 0)
local ESPTab = CreateTab("Hiển Thị (ESP)", 1)

-- Cài đặt mục Combat
AddToggle(Combat
