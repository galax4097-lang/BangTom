-- [[ ASYLUM LIFE PATIENT ESP & AIMBOT — v17.0 FIX MENU HOÀN TOÀN ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== CẤU HÌNH HỆ THỐNG v17.0 ====================
local Config = {
    PatientESP = false,
    Aimbot = false,
    FOVRadius = 200,    -- Giá trị mặc định theo ảnh mẫu
    Hardness = 1,       -- Tốc độ mượt/cứng ngắm mặc định
    ShowFOV = true,
    Color = Color3.fromRGB(255, 0, 120) -- Hồng Neon chuẩn mẫu
}

local MenuVisible = true
local IsMinimized = false
local TabFrames = {}
local Highlights = {}
local AimbotHolding = false

-- Vẽ vòng tròn FOV bằng Drawing (Bọc trong pcall bảo vệ)
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

-- ==================== GIỮ NGUYÊN GỐC KHỞI CHẠY v14 (BAO HIỆN MENU) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AsylumLifeV17FixedHub"
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

-- ==================== GIỮ VỊ TRÍ VÀ KHUNG GỐC v14 ====================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 320)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0) -- Giữ nguyên tọa độ hiển thị của v14
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Giữ cơ chế kéo thả gốc v14 cực kỳ nhẹ và không lỗi
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 120)
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
Title.Text = "Brainrot Hub — Distance Linked System (Fixed)"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

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

-- Cơ chế Ẩn/Hiện bằng nút thu nhỏ
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

-- Cơ chế ẩn hiện toàn bộ bằng phím tắt v14
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert then
        MenuVisible = not MenuVisible
        MainFrame.Visible = MenuVisible
    end
end)

-- ==================== HÀM TẠO THÀNH PHẦN GUI THEO THIẾT KẾ MỚI ====================
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
    local function updateVisual() Switch.BackgroundColor3 = State and Color3.fromRGB(255, 0, 120) or Color3.fromRGB(45, 45, 50) end
    updateVisual()

    Switch.MouseButton1Click:Connect(function() State = not State updateVisual() callback(State) end)
end

-- THANH KÉO (SLIDER) PHẲNG — HIỂN THỊ MÀU HỒNG ĐẦY LÊN KHI KÉO CHUỘT
local function AddSlider(tabFrame, text, min, max, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -5, 0, 45)
    Row.BackgroundTransparency = 1
    Row.Parent = tabFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 215)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(255, 0, 120)
    ValueLabel.Font = Enum.Font.SourceSansBold
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Row

    local SliderBar = Instance.new("TextButton")
    SliderBar.Size = UDim2.new(1, 0, 0, 4)
    SliderBar.Position = UDim2.new(0, 0, 0, 26)
    SliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    SliderBar.BorderSizePixel = 0
    SliderBar.Text = ""
    SliderBar.Parent = Row

    local
