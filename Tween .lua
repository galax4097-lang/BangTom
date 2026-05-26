-- [[ TARGET PLAYER HUB - AUTOMATIC LIST ]] --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Tạo GUI Chính
local ScreenGui = Instance.new("ScreenGui")
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
ScreenGui.Name = "TargetPlayer_Hub"
ScreenGui.ResetOnSpawn = false

-- Khung Main Frame (Rộng hơn để chứa danh sách)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 260)
MainFrame.Position = UDim2.new(0.5, -190, 0.4, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Tiêu đề Hub
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Title.Text = "🎯 TARGET PLAYER HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BorderSizePixel = 0
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

--- ==========================================
--- PANEL TRÁI: ĐIỀU KHIỂN & TRẠNG THÁI
--- ==========================================
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 170, 0, 210)
LeftPanel.Position = UDim2.new(0, 10, 0, 45)
LeftPanel.BackgroundTransparency = 1
LeftPanel.Parent = MainFrame

-- Label hiển thị Target hiện tại
local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1, 0, 0, 30)
TargetLabel.Position = UDim2.new(0, 0, 0, 5)
TargetLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
TargetLabel.Text = "Target: Chưa chọn"
TargetLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
TargetLabel.Font = Enum.Font.GothamBold
TargetLabel.TextSize = 11
TargetLabel.Parent = LeftPanel
local TargetCorner = Instance.new("UICorner") TargetCorner.CornerRadius = UDim.new(0, 5) TargetCorner.Parent = TargetLabel

-- Ô nhập tốc độ bay
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(1, 0, 0, 30)
SpeedInput.Position = UDim2.new(0, 0, 0, 45)
SpeedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
SpeedInput.Text = "60"
SpeedInput.PlaceholderText = "Tốc độ bay (Mặc định: 60)"
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Font = Enum.Font.Gotham
SpeedInput.TextSize = 11
SpeedInput.Parent = LeftPanel
local SpeedCorner = Instance.new("UICorner") SpeedCorner.CornerRadius = UDim.new(0, 5) SpeedCorner.Parent = SpeedInput

-- Nút Tween TP
local TPButton = Instance.new("TextButton")
TPButton.Size = UDim2.new(1, 0, 0, 35)
TPButton.Position = UDim2.new(0, 0, 0, 85)
TPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
TPButton.Text = "⚡ TWEEN TP"
TPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TPButton.Font = Enum.Font.GothamBold
TPButton.TextSize = 12
TPButton.Parent = LeftPanel
local TPCorner = Instance.new("UICorner") TPCorner.CornerRadius = UDim.new(0, 5) TPCorner.Parent = TPButton

-- Nút Spectate (Xem lén)
local SpecButton = Instance.new("TextButton")
SpecButton.Size = UDim2.new(1, 0, 0, 35)
SpecButton.Position = UDim2.new(0, 0, 0, 130)
SpecButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
SpecButton.Text = "👁️ SPECTATE: OFF"
SpecButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpecButton.Font = Enum.Font.GothamBold
SpecButton.TextSize = 12
SpecButton.Parent = LeftPanel
local SpecCorner = Instance.new("UICorner") SpecCorner.CornerRadius = UDim.new(0, 5) SpecCorner.Parent = SpecButton

--- ==========================================
--- PANEL PHẢI: DANH SÁCH PLAYER (SCROLL)
--- ==========================================
local ListScroll = Instance.new("ScrollingFrame")
ListScroll.Size = UDim2.new(0, 180, 0, 200)
ListScroll.Position = UDim2.new(0, 190, 0, 50)
ListScroll.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
ListScroll.BorderSizePixel = 0
ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ListScroll.ScrollBarThickness = 6
ListScroll.Parent = MainFrame

local ListCorner = Instance.new("UICorner") ListCorner.CornerRadius = UDim.new(0, 8) ListCorner.Parent = ListScroll

local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = ListScroll
ListLayout.SortOrder = Enum.SortOrder.Name
ListLayout.Padding = UDim.new(0, 4)

--- ==========================================
--- LOGIC XỬ LÝ CHỨC NĂNG
--- ==========================================
local selectedPlayer = nil
local currentTween = nil
local isSpectating = false

-- Hàm cập nhật danh sách Player hiển thị trên Menu
local function refreshPlayerList()
    -- Xóa các nút cũ (trừ cái Layout)
    for _, child in ipairs(ListScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    -- Tạo nút mới cho từng Player đang online
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local PButton = Instance.new("TextButton")
            PButton.Size = UDim2.new(1, -10, 0, 30)
            PButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            PButton.Text = "  " .. player.DisplayName -- Hiển thị tên
            PButton.TextColor3 = Color3.fromRGB(230, 230, 230)
            PButton.TextXAlignment = Enum.TextXAlignment.Left
            PButton.Font = Enum.Font.Gotham
            PButton.TextSize = 11
            PButton.Parent = ListScroll

            local PCorner = Instance.new("UICorner") PCorner.CornerRadius = UDim.new(0, 4) PCorner.Parent = PButton

            -- Khi bấm vào tên player này
            PButton.MouseButton1Click:Connect(function()
                selectedPlayer = player
                TargetLabel.Text = "Target: " .. player.Name
                -- Highlight nút được chọn
                for _, btn in ipairs(ListScroll:GetChildren()) do
                    if btn:IsA("TextButton") then btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55) end
                end
                PButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
            end)
        end
    end
    -- Tự động tính toán lại độ dài thanh cuộn
    ListScroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end

-- Tự động cập nhật danh sách khi có người ra / vào game
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(player)
    if selectedPlayer == player then
        selectedPlayer = nil
        TargetLabel.Text = "Target: Chưa chọn"
        if isSpectating then
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            isSpectating = false
            SpecButton.Text = "👁️ SPECTATE: OFF"
        end
    end
    refreshPlayerList()
end)
refreshPlayerList() -- Chạy lần đầu tiên khi bật script

-- LOGIC: TWEEN TP
TPButton.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character
    local myRoot = character and character:FindFirstChild("HumanoidRootPart")

    if currentTween then
        currentTween:Cancel()
        if myRoot then myRoot.Anchored = false end
        TPButton.Text = "⚡ TWEEN TP"
        TPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        currentTween = nil
        return
    end

    if not selectedPlayer or not selectedPlayer.Character then return end
    local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not myRoot then return end

    local speed = tonumber(SpeedInput.Text) or 60
    local distance = (targetRoot.Position - myRoot.Position).Magnitude
    local duration = distance / speed

    myRoot.Anchored = true
    TPButton.Text = "🛑 BẤM ĐỂ DỪNG"
    TPButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    currentTween = TweenService:Create(myRoot, tweenInfo, {CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)})
    currentTween:Play()

    currentTween.Completed:Connect(function()
        if myRoot then myRoot.Anchored = false end
        TPButton.Text = "⚡ TWEEN TP"
        TPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        currentTween = nil
    end)
end)

-- LOGIC: SPECTATE (XEM LÉN CAMERA)
SpecButton.MouseButton1Click:Connect(function()
    if not selectedPlayer or not selectedPlayer.Character then return end
    local targetHumanoid = selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
    local myHumanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

    if not targetHumanoid or not myHumanoid then return end

    if isSpectating then
        -- Tắt Spectate, trả camera về bản thân
        Camera.CameraSubject = myHumanoid
        isSpectating = false
        SpecButton.Text = "👁️ SPECTATE: OFF"
        SpecButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    -- Thay đổi camera sang mục tiêu
    else
        Camera.CameraSubject = targetHumanoid
        isSpectating = true
        SpecButton.Text = "👁️ SPECTATE: ON"
        SpecButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    end
end)
