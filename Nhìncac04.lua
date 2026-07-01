-- [[ EMERGENCY HAMBURG OPTIMIZED - WATCH HUB ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local TargetPlayer = nil
local CameraConnection = nil

-- ==================== TẠO GIAO DIỆN (GUI ĐÚNG KIỂU) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EHSpectateHub"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- 1. NÚT MỞ MENU
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 100, 0, 45)
OpenBtn.Position = UDim2.new(0, 50, 0.6, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 210, 0)
OpenBtn.BorderSizePixel = 0
OpenBtn.Text = "เปิด (Mở)"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.TextSize = 16
OpenBtn.Parent = ScreenGui

-- 2. KHUNG MENU CHÍNH
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 300)
MainFrame.Position = UDim2.new(0.5, -110, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, -30)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 30)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.Parent = ScrollingFrame

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

-- ==================== HỆ THỐNG SPECTATE NÂNG CAO ====================

local function StopSpectating()
    if CameraConnection then
        CameraConnection:Disconnect()
        CameraConnection = nil
    end
    -- Trả camera về trạng thái bình thường của Roblox
    Camera.CameraType = Enum.CameraType.Custom
    if LocalPlayer.Character then
        local myHumanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if myHumanoid then
            Camera.CameraSubject = myHumanoid
        end
    end
    TargetPlayer = nil
end

local function StartSpectating(player)
    StopSpectating() -- Xóa mục tiêu cũ nếu có
    TargetPlayer = player
    
    -- Sử dụng cơ chế cập nhật liên tục bám sát góc nhìn mục tiêu
    CameraConnection = RunService.RenderStepped:Connect(function()
        if TargetPlayer and TargetPlayer.Character then
            -- Tìm bộ phận gốc bất kể họ đang đi bộ hay ở trong xe
            local targetPart = TargetPlayer.Character:FindFirstChild("HumanoidRootPart") or TargetPlayer.Character:FindFirstChildOfClass("Part")
            local targetHumanoid = TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            if targetHumanoid then
                -- Ép hệ thống camera của game phải tập trung vào mục tiêu này
                Camera.CameraType = Enum.CameraType.Custom
                Camera.CameraSubject = targetHumanoid
            elseif targetPart then
                -- Dự phòng nếu nhân vật lỗi kết cấu cấu trúc (đang chuyển nghề nghiệp)
                Camera.CameraSubject = targetPart
            end
        else
            -- Nếu người chơi bị mất nhân vật tạm thời, quay về chính mình để tránh lỗi đứng màn hình
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            end
        end
    end)
end

-- ==================== XỬ LÝ DANH SÁCH NGƯỜI CHƠI ====================
local function RefreshList()
    for _, child in ipairs(ScrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    -- Nút trở về chính mình
    local MeBtn = Instance.new("TextButton")
    MeBtn.Size = UDim2.new(1, 0, 0, 40)
    MeBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 70)
    MeBtn.BorderSizePixel = 0
    MeBtn.Text = "[ Tôi ] - Quay Lại"
    MeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MeBtn.Font = Enum.Font.SourceSansSemibold
    MeBtn.TextSize = 14
    MeBtn.Parent = ScrollingFrame
    
    MeBtn.MouseButton1Click:Connect(function()
        StopSpectating()
    end)

    -- Đổ danh sách người chơi vào bảng
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local PlayerBtn = Instance.new("TextButton")
            PlayerBtn.Size = UDim2.new(1, 0, 0, 40)
            PlayerBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            PlayerBtn.BorderSizePixel = 0
            PlayerBtn.Text = player.Name
            PlayerBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            PlayerBtn.Font = Enum.Font.SourceSans
            PlayerBtn.TextSize = 14
            PlayerBtn.Parent = ScrollingFrame
            
            PlayerBtn.MouseButton1Click:Connect(function()
                StartSpectating(player)
            end)
        end
    end
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

-- Lắng nghe sự kiện để cập nhật menu liên tục
Players.PlayerAdded:Connect(RefreshList)
Players.PlayerRemoving:Connect(function(player)
    if TargetPlayer == player then StopSpectating() end
    RefreshList()
end)

-- Sửa lỗi khi chính bạn bị chết/đổi nghề nghiệp trong Emergency Hamburg thì không bị mất menu
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if not TargetPlayer then
        StopSpectating()
    end
end)

RefreshList()
