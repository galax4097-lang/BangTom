-- [[ GAG HUB REMAKE — GROW A GARDEN 2 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== HỆ THỐNG CẤU HÌNH (SETTINGS) ====================
local Config = {
    Automation = {
        AutoBuy = false,
        SelectedSeed = "Carrot", 
        AutoSell = false,
    },
    Character = {
        SpeedEnabled = false,
        WalkSpeed = 16
    },
    ESP = {
        Enabled = false,        
        Names = true,          
        Distance = true,       
        MaxDistance = 500,     
        Color = Color3.fromRGB(0, 255, 150) 
    }
}

local SeedList = {"Carrot", "Tomato", "Pumpkin", "Watermelon", "Berry", "Wheat"}
local MenuVisible = true
local IsMinimized = false
local TabButtons = {}
local TabFrames = {}

-- ==================== TẠO GIAO DIỆN CHUẨN GAG HUB ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GAG_Hub_Remake"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 310)
MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 24) -- Màu tối mờ chuẩn ảnh
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Thanh tiêu đề đầu (Header)
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "GAG Hub"
Title.TextColor3 = Color3.fromRGB(220, 220, 220)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Nút thu nhỏ / phóng to góc phải giống hệ thống gốc
local WindowControls = Instance.new("TextButton")
WindowControls.Size = UDim2.new(0, 40, 0, 35)
WindowControls.Position = UDim2.new(1, -45, 0, 0)
WindowControls.BackgroundTransparency = 1
WindowControls.Text = "—  🗖"
WindowControls.TextColor3 = Color3.fromRGB(180, 180, 180)
WindowControls.Font = Enum.Font.SourceSans
WindowControls.TextSize = 14
WindowControls.Parent = Header

-- Menu Sidebar trái
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -40)
Sidebar.Position = UDim2.new(0, 5, 0, 35)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 3)
SidebarLayout.Parent = Sidebar

-- Vùng chứa nội dung bên phải
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -140, 1, -45)
Container.Position = UDim2.new(0, 130, 0, 40)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- Xử lý thu nhỏ (Minimize) khi ấn nút góc phải
WindowControls.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        Sidebar.Visible = false
        Container.Visible = false
        MainFrame.Size = UDim2.new(0, 480, 0, 35)
    else
        MainFrame.Size = UDim2.new(0, 480, 0, 310)
        Sidebar.Visible = true
        Container.Visible = true
    end
end
