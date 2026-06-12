-- [[ ASYLUM LIFE HUB — v14.2 CLEAN & STRICT PATIENT ESP ONLY ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Cấu hình mặc định gọn gàng
local Config = {
    PatientESP = false,
    Aimbot = false,
    FOVRadius = 150,
    Color = Color3.fromRGB(255, 0, 120) -- Màu hồng Neon chuẩn gốc
}

local MenuVisible = true
local IsMinimized = false
local TabFrames = {}
local Highlights = {}
local AimbotHolding = false

-- ==================== KHỞI TẠO GUI GỐC v14 (CHỐNG TREO/SẬP) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AsylumLifeV14_2_Clean"
ScreenGui.ResetOnSpawn = false

pcall(function()
    if gethui then ScreenGui.Parent = gethui()
    else ScreenGui.Parent = game:GetService("CoreGui") end
end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Vòng tròn FOV dạng khung cơ bản (An toàn tuyệt đối cho mọi Executor)
local FOVFrame = Instance.new("Frame")
FOVFrame.Size = UDim2.new(0, Config.FOVRadius * 2, 0, Config.FOVRadius * 2)
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
FOVStroke.Transparency = 0.4
FOVStroke.Parent = FOVFrame

-- Khung chính Menu v14
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 320)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Config.Color
UIStroke.Thickness = 1.4
UIStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 6)

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
StatusLabel.Size = UDim2.new(0.3, 0, 1, 0)
StatusLabel.Position = UDim2.new(0.7, -45, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Hệ thống: Sẵn sàng"
StatusLabel.TextColor3 = Config.Color
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
MinimizeBtn.TextSize = 16
MinimizeBtn.Parent = TopBar

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -155, 1, -55)
Container.Position = UDim2.new(0, 150, 0, 48)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- Ẩn hiện nhanh bằng nút hoặc phím tắt
MinimizeBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    Sidebar.Visible = not IsMinimized
    Container.Visible = not IsMinimized
    MainFrame.Size = IsMinimized and UDim2.new(0, 520, 0, 40) or UDim2.new(0, 520, 0, 320)
    MinimizeBtn.Text = IsMinimized and "[+]" or "[-]"
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert then
        MenuVisible = not MenuVisible
        MainFrame.Visible = MenuVisible
    end
end)

-- ==================== HÀM TẠO TAB VÀ TOGGLE GỐC v14 ====================
local function CreateTab(tabName, order)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 120, 0, 32)
    TabBtn.Position = UDim2.new(0, 10, 0, 10 + (order * 38))
    TabBtn.BackgroundColor3 = (order == 0) and Color3.fromRGB(22, 22, 26) or Color3.fromRGB(16, 16, 20)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = (order == 0) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 165)
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
    UIList.Padding = UDim.new(0, 10)
    UIList.Parent = TabFrame

    TabFrames[tabName] = {Frame = TabFrame, Button = TabBtn}
    TabBtn.MouseButton1Click:Connect(function()
        for k, v in pairs(TabFrames) do
            v.Frame.Visible = (k == tabName)
            v.Button.BackgroundColor3 = (k == tabName) and Color3.fromRGB(22, 22, 26) or Color3.fromRGB(16, 16, 20)
            v.Button.TextColor3 = (k == tabName) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 165)
        end
    end)
    return TabFrame
end

local function AddToggle(tabFrame, text, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -5, 0, 32)
    Row.BackgroundTransparency = 1
    Row.Parent = tabFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 215)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 38, 0, 18)
    Switch.Position = UDim2.new(1, -42, 0, 7)
    Switch.Text = ""
    Switch.Parent = Row
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

    local State = default
    local function updateVisual() Switch.BackgroundColor3 = State and Config.Color or Color3.fromRGB(45, 45, 50) end
    updateVisual()

    Switch.MouseButton1Click:Connect(function() State = not State updateVisual() callback(State) end)
end

-- Khởi tạo chuẩn 2 Tab chính như ảnh v14
local EspTab = CreateTab("Nhìn Xuyên Tường", 0)
local AimTab = CreateTab("Tự Động Ngắm", 1)

AddToggle(EspTab, "Chỉ Hiện Bệnh Nhân (Patient ESP)", Config.PatientESP, function(s)
    Config.PatientESP = s
    if not s then
        for player, highlight in pairs(Highlights) do
            if highlight then highlight:Destroy() end
            Highlights[player] = nil
        end
    end
end)

AddToggle(AimTab, "Bật Tự Động Ngắm (Aimbot)", Config.Aimbot, function(s) Config.Aimbot = s end)

-- ==================== BỘ LỌC ĐỘI STRICT (LOẠI CẢNH SÁT & BÁC SĨ) ====================
local function IsStrictlyPatient(player)
    if player and player.Team then
        local teamName = string.lower(player.Team.Name)
        
        -- Kiên quyết loại bỏ Cảnh sát, Bảo vệ, Bác sĩ, Y tá khỏi danh sách tạo ESP
        if string.find(teamName, "police") or string.find(
