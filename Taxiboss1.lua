-- [[ TAXI BOSS ABSOLUTE FIX — v8.0 PERFECT CODESYNC ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ==================== CẤU HÌNH HỆ THỐNG v8.0 ====================
local Config = {
    Farm = {
        AutoPassenger = false,
        AutoDropOff = false,
        CurrentZone = nil,        
        ZoneKeywords = {},        
    },
    Vehicle = {
        SpeedHack = false,
        SpeedValue = 150,
    }
}

local MenuVisible = true
local IsMinimized = false
local TabFrames = {}
local ZoneCache = {} -- Bộ nhớ đệm lưu tọa độ nhà hàng tránh lag game

-- Danh sách nhà hàng chuẩn 100% theo ảnh menu của bạn
local Establishments = {
    {Name = "Limoné Bistro (2.0★)", Keywords = {"limone", "bistro"}},
    {Name = "Sofia's Cafe (3.0★)", Keywords = {"sofia", "cafe"}},
    {Name = "Céfiro Jazz Club (3.5★)", Keywords = {"cefiro", "jazz"}},
    {Name = "Ronut's Donuts (3.6★)", Keywords = {"ronut", "donut"}},
    {Name = "MEGA Kebab (3.8★)", Keywords = {"mega", "kebab"}}
}

-- ==================== KHỞI TẠO GIAO DIỆN PREMIUM NEON ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TaxiBossV8Absolute"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 530, 0, 360)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 120) -- Hồng Neon rực rỡ
UIStroke.Thickness = 1.6
UIStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.55, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Taxi Boss Absolute — v8.0 Fix Thả Trầm"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.4, 0, 0, 20)
StatusLabel.Position = UDim2.new(
