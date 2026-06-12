-- [[ ASYLUM LIFE BRAINROT HUB — v19.0 PRECISION SYNC ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== HỆ THỐNG CẤU HÌNH ====================
local Config = {
    PatientESP = false,
    Aimbot = false,
    FOVRadius = 150,    -- Giá trị thanh kéo FOV
    Smoothness = 50,    -- Giá trị mượt (100% là cực cứng)
    ShowFOV = true,
    Color = Color3.fromRGB(255, 0, 120) -- Hồng Neon chuẩn ảnh mẫu
}

local MenuVisible = true
local IsMinimized = false
local TabFrames = {}
local Highlights = {}
local AimbotHolding = false

-- ==================== KHỞI TẠO UI (PARENT BYPASS) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotLinkedSystem_v19"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local function ApplySafeParent()
    local success, target = pcall(function() return gethui() end)
    if success and target then ScreenGui.Parent = target return end
    success, target = pcall(function() return game:GetService("CoreGui") end)
    if success and target then ScreenGui.Parent = target return end
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
ApplySafeParent()

-- Vẽ vòng tròn FOV bằng Frame (Bao chạy không bao giờ sập)
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
FOVStroke.Transparency = 0.5
FOVStroke.Parent = FOVFrame

-- ==================== THIẾT KẾ GIAO DIỆN CHUẨN HÌNH MẪU ====================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 340)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 5)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Config.Color
MainStroke.Thickness = 1.2
MainStroke.Parent = MainFrame

-- TopBar Tiêu Đề
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Brainrot Hub — Distance Linked System"
Title.TextColor3 = Color3.fromRGB(230, 230, 235)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Sidebar Cột Trái
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Vùng Chứa Nội Dung Phải
local Container = Instance.new("
