-- [[ ROBLOX PLAYER WATCH HUB - TIKTOK STYLE ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local TargetPlayer = nil -- Người chơi đang được xem

-- ==================== TẠO CÁC PHẦN TỬ GIAO DIỆN (GUI) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TikTokSpectateHub"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- 1. NÚT MỞ MENU (Màu xanh lá ở góc trái giống trong ảnh)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 100, 0, 45)
OpenBtn.Position = UDim2.new(0, 50, 0.6, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 210, 0) -- Màu xanh lá
OpenBtn.BorderSizePixel = 0
OpenBtn.Text = "เปิด" -- Chữ hiển thị (hoặc bạn đổi thành "Mở")
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.TextSize = 16
OpenBtn.Parent = ScreenGui

-- 2. KHUNG MENU CHÍNH (Bảng danh sách màu xám đen)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 300)
MainFrame.Position = UDim2.new(0.5, 0, 0.3, 0) -- Giữa màn hình giống ảnh
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35) -- Màu xám tối
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false -- Mặc định ẩn, bấm nút xanh mới hiện
MainFrame.Active = true
MainFrame.Draggable = true -- Cho phép di chuyển/kéo menu xung quanh màn hình
MainFrame.Parent = ScreenGui

-- Nút Tắt [X] màu đỏ ở góc menu
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 0, 0) -- Màu đỏ giống ảnh
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame

-- Khung danh sách chứa tên người chơi (Cuộn được nếu phòng đông)
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, -30)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 30)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.Parent = MainFrame

-- Bố cục tự động xếp dọc các nút tên người chơi
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.Parent = ScrollingFrame

-- ==================== SỰ KIỆN ĐÓNG / MỞ MENU ====================
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

-- ==================== LOGIC CẬP NHẬT DANH SÁCH NGƯỜI CHƠI ====================
local function RefreshList()
    -- Xóa các nút cũ để tạo lại mới
    for _, child in ipairs(ScrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    -- Thêm nút của chính mình để khi bấm vào có thể quay trở lại góc nhìn bản thân
    local MeBtn = Instance.new("TextButton")
    MeBtn.Size = UDim2.new(1, 0, 0, 40)
    MeBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 70) -- Màu khác biệt một chút
    MeBtn.BorderSizePixel = 0
    MeBtn.Text = "[ Tôi ] - Trở về"
    MeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MeBtn.Font = Enum.Font.SourceSansSemibold
    MeBtn.TextSize = 14
    MeBtn.Parent = ScrollingFrame
    
    MeBtn.MouseButton1Click:Connect(function()
        TargetPlayer = nil
    end)

    -- Quét và tạo nút cho tất cả người chơi khác trong server
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local PlayerBtn = Instance.new("TextButton")
            PlayerBtn.Size = UDim2.new(1, 0, 0, 40)
            PlayerBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- Màu nút xám nhạt hơn nền
            PlayerBtn.BorderSizePixel = 0
            PlayerBtn.Text = player.Name
            PlayerBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            PlayerBtn.Font = Enum.Font.SourceSans
            PlayerBtn.TextSize = 14
            PlayerBtn.Parent = ScrollingFrame
            
            -- Khi bấm vào tên một người chơi
            PlayerBtn.MouseButton1Click:Connect(function()
                TargetPlayer = player
            end)
        end
    end
    
    -- Tự động tính toán chiều dài vùng cuộn dựa trên số lượng nút người chơi
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

-- Tự động cập nhật danh sách mỗi khi có ai đó vào hoặc rời phòng
Players.PlayerAdded:Connect(RefreshList)
Players.PlayerRemoving:Connect(function(player)
    if TargetPlayer == player then TargetPlayer = nil end
    RefreshList()
end)
RefreshList() -- Chạy lần đầu tiên lúc kích hoạt script

-- ==================== VÒNG LẶP KHÓA CAMERA (XEM GÓC NHÌN) ====================
RunService.RenderStepped:Connect(function()
    if TargetPlayer and TargetPlayer.Character then
        local targetHumanoid = TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
        -- Đổi góc nhìn chính sang mục tiêu nhưng nhân vật của mình hoàn toàn không di chuyển
        if targetHumanoid and Camera.CameraSubject ~= targetHumanoid then
            Camera.CameraSubject = targetHumanoid
        end
    else
        -- Trả camera về lại nhân vật của mình khi không chọn ai hoặc người kia out game
        if LocalPlayer.Character then
            local myHumanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if myHumanoid and Camera.CameraSubject ~= myHumanoid then
                Camera.CameraSubject = myHumanoid
            end
        end
    end
end)
