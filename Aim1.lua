-- [[ BRAINROT HUB — DISTANCE LINKED SYSTEM ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Hệ thống cấu hình
local Config = {
    Aimbot = false,
    Hardness = 15,       -- % Độ mượt chế độ thường
    FOVRadius = 200,     -- Kích thước vòng tròn FOV
    PatientESP = false,
    Color = Color3.fromRGB(255, 0, 120) -- Hồng Neon chuẩn mẫu
}

local MenuVisible = true
local TabFrames = {}
local Highlights = {}
local AimbotHolding = false

-- Khởi tạo UI bảo mật chống lỗi trên mọi Executor
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotHub_Official"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

pcall(function()
    if gethui then ScreenGui.Parent = gethui()
    else ScreenGui.Parent = game:GetService("CoreGui") end
end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Vẽ vòng tròn FOV nguyên bản của game (Bao chạy không bao giờ treo)
local FOVFrame = Instance.new("Frame")
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = false
FOVFrame.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Config.Color
FOVStroke.Thickness = 1
FOVStroke.Transparency = 0.3
FOVStroke.Parent = FOVFrame

-- ==================== THIẾT KẾ MENU 1:1 THEO MẪU ====================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 4)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Config.Color
MainStroke.Thickness = 1.2
MainStroke.Parent = MainFrame

-- Topbar tiêu đề
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Brainrot Hub — Distance Linked System"
Title.TextColor3 = Color3.fromRGB(235, 235, 240)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -40, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "[-]"
MinimizeBtn.TextColor3 = Color3.fromRGB(180, 180, 185)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 15
MinimizeBtn.Parent = TopBar

-- Cột chọn tab bên trái
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -38)
Sidebar.Position = UDim2.new(0, 0, 0, 38)
Sidebar.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Khung chứa các chức năng bên phải
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -150, 1, -55)
Container.Position = UDim2.new(0, 142, 0, 48)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- Phím ẩn/hiện Menu nhanh (Bấm phím Insert hoặc phím Right Control)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightControl then
        MenuVisible = not MenuVisible
        MainFrame.Visible = MenuVisible
    end
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MenuVisible = false
end)

-- ==================== CÁC THÀNH PHẦN GUI CHUẨN MẪU ====================
local function CreateTab(tabName, order)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -10, 0, 32)
    TabBtn.Position = UDim2.new(0, 5, 0, 8 + (order * 36))
    TabBtn.BackgroundColor3 = (order == 0) and Color3.fromRGB(22, 22, 26) or Color3.fromRGB(14, 14, 18)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = (order == 0) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 155)
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
    UIList.Padding = UDim.new(0, 14)
    UIList.Parent = TabFrame

    TabFrames[tabName] = {Frame = TabFrame, Button = TabBtn}
    TabBtn.MouseButton1Click:Connect(function()
        for k, v in pairs(TabFrames) do
            v.Frame.Visible = (k == tabName)
            v.Button.BackgroundColor3 = (k == tabName) and Color3.fromRGB(22, 22, 26) or Color3.fromRGB(14, 14, 18)
            v.Button.TextColor3 = (k == tabName) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 155)
        end
    end)
    return TabFrame
end

local function AddToggle(tabFrame, text, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -5, 0, 26)
    Row.BackgroundTransparency = 1
    Row.Parent = tabFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(215, 215, 220)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 36, 0, 17)
    Switch.Position = UDim2.new(1, -38, 0, 4)
    Switch.Text = ""
    Switch.Parent = Row
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

    local State = default
    local function updateVisual() Switch.BackgroundColor3 = State and Config.Color or Color3.fromRGB(45, 45, 50) end
    updateVisual()

    Switch.MouseButton1Click:Connect(function() State = not State updateVisual() callback(State) end)
end

local function AddSlider(tabFrame, text, min, max, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -5, 0, 42)
    Row.BackgroundTransparency = 1
    Row.Parent = tabFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 0, 18)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(215, 215, 220)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 18)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Config.Color
    ValueLabel.Font = Enum.Font.SourceSansBold
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Row

    local SliderBar = Instance.new("TextButton")
    SliderBar.Size = UDim2.new(1, 0, 0, 3)
    SliderBar.Position = UDim2.new(0, 0, 0, 26)
    SliderBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    SliderBar.BorderSizePixel = 0
    SliderBar.Text = ""
    SliderBar.Parent = Row

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Config.Color
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderBar

    local function updateSlider(input)
        local relX = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)
        local percentage = relX / SliderBar.AbsoluteSize.X
        local value = math.floor(min + (max - min) * percentage)
        ValueLabel.Text = tostring(value)
        Fill.Size = UDim2.new(percentage, 0, 1, 0)
        callback(value)
    end

    local sliding = false
    SliderBar.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true updateSlider(input) end 
    end)
    UserInputService.InputChanged:Connect(function(input) 
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end 
    end)
    UserInputService.InputEnded:Connect(function() sliding = false end)
end

-- ==================== KHỞI TẠO TAB & CHỨC NĂNG CHÍNH ====================
local AimTab = CreateTab("Ngắm Bắn (Main)", 0)
local EspTab = CreateTab("Hiển Thị (ESP)", 1)

-- Cài đặt Aimbot & Thanh kéo
AddToggle(AimTab, "Bật Tự Động Ngắm (Aimbot)", Config.Aimbot, function(s) Config.Aimbot = s end)
AddSlider(AimTab, "Kích Thước Vòng Tròn FOV", 10, 600, Config.FOVRadius, function(v) Config.FOVRadius = v end)
AddSlider(AimTab, "Độ Mượt Chế Độ Thường (%)", 1, 100, Config.Hardness, function(v) Config.Hardness = v v() end)

-- Cài đặt ESP Chỉ Hiện Bệnh Nhân
AddToggle(EspTab, "Chỉ Hiện Bệnh Nhân (Patient ESP)", Config.PatientESP, function(s)
    Config.PatientESP = s
    if not s then
        for p, hl in pairs(Highlights) do if hl then hl:Destroy() end end
        table.clear(Highlights)
    end
end)

-- BỘ LỌC ĐỘI NGHIÊM NGẶT (CHỈ GIỮ BỆNH NHÂN - LOẠI BỎ CẢNH SÁT & BÁC SĨ)
local function IsPatientOnly(player)
    if player and player.Team then
        local name = string.lower(player.Team.Name)
        -- Nếu là cảnh sát, bảo vệ, bác sĩ hoặc y tá thì loại bỏ ngay lập tức
        if name:find("police") or name:find("guard") or name:find("doctor") or name:find("nurse") or name:find("bác sĩ") or name:find("cảnh sát") or name:find("bảo vệ") then
            return false
        end
        -- Chỉ chấp nhận nếu thuộc đội bệnh nhân hoặc phạm nhân
        if name:find("patient") or name:find("bệnh nhân") or name:find("inmate") then
            return true
