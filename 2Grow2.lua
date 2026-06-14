local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Bảng Config để quản lý trạng thái khi bạn Click trên Menu
local Config = {
    AutoBuy = false,
    SelectedSeed = "Carrot", 
    AutoSell = false,
    WalkSpeed = 16,
    SpeedEnabled = false
}
local SeedList = {"Carrot", "Tomato", "Pumpkin", "Watermelon"}
-----------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MyGAGHub"
ScreenGui.Parent = game:GetService("CoreGui") -- Đưa vào CoreGui để không bị mất khi nhân vật reset

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 310)
MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 24) -- Màu xám tối chuẩn ảnh GAG Hub
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Thêm tính năng kéo giữ để di chuyển Menu trên màn hình
MainFrame.Active = true
MainFrame.Draggable = true
