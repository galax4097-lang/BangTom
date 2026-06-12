-- [[ ASYLUM LIFE HUB — v16.0 UI BRAINROT HOMAGE ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== CẤU HÌNH ĐỒNG BỘ CHUẨN ====================
local Config = {
    PatientESP = false,
    Aimbot = false,
    FOVRadius = 200,    -- Mặc định theo ảnh mẫu
    Hardness = 1,       -- Độ mượt/cứng ngắm
    ShowFOV = true,
    Color = Color3.fromRGB(255, 0, 120) -- Hồng Neon chuẩn
}

local MenuVisible = true
local TabFrames = {}
local Highlights = {}
local AimbotHolding = false

-- ==================== FOV CIRCLE SYSTEM ====================
local FOVCircle = nil
pcall(function()
    if Drawing then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 1
        FOVCircle.Color = Color3.fromRGB(255, 0, 120)
        FOVCircle.Filled = false
        FOVCircle.Transparency = 0.5
        FOVCircle.Visible = false
    end
end)

-- ==================== FIX LỖI KHÔNG HIỆN MENU (ANTI-BAN PARENT) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotLinkedSystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local function SafeParentUI()
    local success, target = pcall(function() return gethui() end)
    if success and target then
        ScreenGui.Parent = target
        return
    end
    success, target = pcall(function() return game:GetService("CoreGui") end)
    if success and target then
        ScreenGui.Parent = target
        return
    end
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
SafeParentUI()

-- ==================== GIAO DIỆN CHUẨN 1:1 THEO ẢNH MẪU ====================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 340)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18) -- Tối mờ cao cấp
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Tạo bo góc mượt cho khung chính
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 5)
MainCorner.Parent = MainFrame

-- Viền hồng Neon mỏng chuẩn ảnh mẫu
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 0, 120)
MainStroke.Thickness = 1.2
MainStroke.Parent = MainFrame

-- Thanh Tiêu Đề TopBar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 5)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Brainrot Hub — Distance Linked System"
Title.TextColor3 = Color3.fromRGB(230, 230, 235)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 2)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "[-]"
MinimizeBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 14
MinimizeBtn.Parent = TopBar

-- Hệ thống Kéo Thả Menu (Dành cho cả PC và Mobile)
local Dragging, DragInput, DragStart, StartPosition
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPosition = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then Dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        local Delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
    end
end)

-- Cột Danh Mục bên Trái (Sidebar)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Vùng chứa nội dung bên Phải
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -145, 1, -50)
Container.Position = UDim2.new(0, 138, 0, 42)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

MinimizeBtn.MouseButton1Click:Connect(function()
    MenuVisible = not MenuVisible
    Sidebar.Visible = MenuVisible
    Container.Visible = MenuVisible
    MainFrame.Size = MenuVisible and UDim2.new(0, 500, 0, 340) or UDim2.new(0, 500, 0, 35)
end)

-- Phím tắt ẩn hiện nhanh (Insert hoặc RightControl)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ==================== HÀM KHỞI TẠO TAB & ĐIỀU KHIỂN CHUẨN HÌNH MẪU ====================
local function CreateTab(tabName, order)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -15, 0, 32)
    TabBtn.Position = UDim2.new(0, 8, 0, 10 + (order * 38))
    TabBtn.BackgroundColor3 = order == 0 and Color3.fromRGB(22, 22, 28) or Color3.fromRGB(16, 16, 20)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = order == 0 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 170)
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.TextSize = 13
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabFrame.ScrollBarThickness = 0
    TabFrame.Visible = (order == 0)
    TabFrame.Parent = Container
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 12)
    UIList.Parent = TabFrame

    TabFrames[tabName] = {Frame = TabFrame, Button = TabBtn}
    
    TabBtn.MouseButton1Click:Connect(function()
        for k, v in pairs(TabFrames) do
            v.Frame.Visible = (k == tabName)
            v.Button.BackgroundColor3 = (k == tabName) and Color3.fromRGB(22, 22, 28) or Color3.fromRGB(16, 16, 20)
            v.Button.TextColor3 = (k == tabName) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 170)
        end
    end)
    return TabFrame
end

local function AddToggle(tabFrame, text, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -5, 0, 30)
    Row.BackgroundTransparency = 1
    Row.Parent = tabFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 205)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 36, 0, 18)
    Switch.Position = UDim2.new(1, -40, 0, 6)
    Switch.Text = ""
    Switch.Parent = Row
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

    local State = default
    local function updateVisual() 
        Switch.BackgroundColor3 = State and Color3.fromRGB(255, 0, 120) or Color3.fromRGB(45, 45, 50) 
    end
    updateVisual()

    Switch.MouseButton1Click:Connect(function() 
        State = not State 
        updateVisual() 
        callback(State) 
    end)
end

-- THÀNH PHẦN THANH KÉO (SLIDER) THIẾT KẾ GIỐNG 1:1 HÌNH ẢNH MẪU
local function AddSlider(tabFrame, text, min, max, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -5, 0, 45)
    Row.BackgroundTransparency = 1
    Row.Parent = tabFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 205)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(255, 0, 120) -- Số hiển thị màu hồng Neon
    ValueLabel.Font = Enum.Font.SourceSansBold
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Row

    -- Đường kẻ nền Slider (Màu xám tối)
    local SliderLine = Instance.new("TextButton")
    SliderLine.Size = UDim2.new(1, 0, 0, 4)
    SliderLine.Position = UDim2.new(0, 0, 0, 28)
    SliderLine.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    SliderLine.BorderSizePixel = 0
    SliderLine.Text = ""
    SliderLine.Parent = Row

    -- Thanh năng lượng hồng tự lấp đầy khi kéo (Không dùng nút tròn)
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 0, 120)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderLine

    local function updateSlider(input)
        local totalWidth = SliderLine.AbsoluteSize.X
        local relX = math.clamp(input.Position.X - SliderLine.AbsolutePosition.X, 0, totalWidth)
        local percentage = relX / totalWidth
        local value = math.floor(min + (max - min) * percentage)
        ValueLabel.Text = tostring(value)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        callback(value)
    end

    local sliding = false
    SliderLine.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            sliding = true 
            updateSlider(input) 
        end 
    end)
    UserInputService.Input
