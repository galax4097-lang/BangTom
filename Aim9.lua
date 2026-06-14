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
local ContentFrame = Instance.new("Frame
