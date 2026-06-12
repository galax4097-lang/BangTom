-- [[ ASYLUM LIFE ESP & AIMBOT SMART SYNC — v15.0 FOV UPDATE ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== CẤU HÌNH ĐỒNG BỘ v15.0 ====================
local Config = {
    PatientESP = false,
    Aimbot = false,
    FOVRadius = 150,    -- Mặc định phạm vi fov
    Hardness = 300,     -- Mặc định độ cứng ngắm (Tối đa 600)
    ShowFOV = true,     -- Hiện/Ẩn vòng tròn ngắm
    Color = Color3.fromRGB(255, 0, 120)
}

local MenuVisible = true
local IsMinimized = false
local TabFrames = {}
local Highlights = {}
local AimbotHolding = false

-- Vẽ vòng FOV an toàn (Tương thích cả PC và Mobile)
local FOVCircle = nil
pcall(function()
    if Drawing then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 1
        FOVCircle.Color = Color3.fromRGB(255, 0, 120)
        FOVCircle.Filled = false
        FOVCircle.Transparency = 0.6
        FOVCircle.Visible = false
    end
end)

-- ==================== GETHUI BYPASS (CHỐNG ẨN MENU) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AsylumLifeV15FovHub"
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

-- ==================== PREMIUM NEON GUI GIAO DIỆN HỒNG NEON ====================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 320)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 120)
UIStroke.Thickness = 1.6
UIStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0, 15,
