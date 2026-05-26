-- [[ TARGET PLAYER HUB - CONTINUOUS AUTO FOLLOW ]] --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Tạo GUI Chính
local ScreenGui = Instance.new("ScreenGui")
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
ScreenGui.Name = "ContinuousTarget_Hub"
ScreenGui.ResetOnSpawn = false

-- Khung Main Frame
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
Title.Text = "🎯 TARGET AUTO FOLLOW HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BorderSizePixel = 0
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

--- PANEL TRÁI: ĐIỀU KHIỂN
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 170, 0, 210)
LeftPanel.Position = UDim2.new(0, 10, 0, 45)
LeftPanel.BackgroundTransparency = 1
LeftPanel.Parent = MainFrame

-- Label hiển thị Target
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
SpeedInput.PlaceholderText = "Tốc độ bám (Mặc định: 60)"
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Font = Enum.Font.Gotham
SpeedInput.TextSize = 11
SpeedInput.Parent = LeftPanel
local SpeedCorner = Instance.new("UICorner") SpeedCorner.CornerRadius = UDim.new(0, 5) SpeedCorner.Parent = SpeedInput

-- Nút Bật/Tắt Auto Follow liên tục
local FollowButton = Instance.new("TextButton")
FollowButton.Size = UDim2.new(1, 0, 0, 35)
FollowButton.Position = UDim2.new(0, 0, 0, 85)
FollowButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
FollowButton.Text = "🔄 START FOLLOW"
FollowButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FollowButton.Font = Enum.Font.GothamBold
FollowButton.TextSize = 12
FollowButton.Parent = LeftPanel
local FollowCorner = Instance.new("UICorner") FollowCorner.CornerRadius = UDim.new(0, 5) FollowCorner.Parent = FollowButton

-- Nút Spectate
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

--- PANEL PHẢI: DANH SÁCH PLAYER (SCROLL)
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
--- LOGIC XỬ LÝ CHỨC NĂNG BÁM ĐUÔI LIÊN TỤC
--- ==========================================
local selectedPlayer = nil
local currentTween = nil
local isFollowing = false
local isSpectating = false

-- Làm mới danh sách Player
local function refreshPlayerList()
    for _, child in ipairs(ListScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local PButton = Instance.new("TextButton")
            PButton.Size = UDim2.new(1, -10, 0, 30)
            PButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            PButton.Text = "  " .. player.DisplayName
            PButton.TextColor3 = Color3.fromRGB(230, 230, 230)
            PButton.TextXAlignment = Enum.TextXAlignment.Left
            PButton.Font = Enum.Font.Gotham
            PButton.TextSize = 11
            PButton.Parent = ListScroll
            local PCorner = Instance.new("UICorner") PCorner.CornerRadius = UDim.new(0, 4) PCorner.Parent = PButton

            PButton.MouseButton1Click:Connect(function()
                selectedPlayer = player
                TargetLabel.Text = "Target: " .. player.Name
                for _, btn in ipairs(ListScroll:GetChildren()) do
                    if btn:IsA("TextButton") then btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55) end
                end
                PButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
            end)
        end
    end
    ListScroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(player)
    if selectedPlayer == player then
        selectedPlayer = nil
        isFollowing = false
        TargetLabel.Text = "Target: Chưa chọn"
    end
    refreshPlayerList()
end)
refreshPlayerList()

-- LOGIC CHÍNH: VÒNG LẶP FOLLOW LIÊN TỤC (LOOP TWEEN)
FollowButton.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character
    local myRoot = character and character:FindFirstChild("HumanoidRootPart")
    
    -- Nếu đang bật thì bấm vào sẽ TẮT
    if isFollowing then
        isFollowing = false
        if currentTween then currentTween:Cancel() end
        if myRoot then myRoot.Anchored = false end
        FollowButton.Text = "🔄 START FOLLOW"
        FollowButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        return
    end

    -- Kiểm tra điều kiện trước khi bật
    if not selectedPlayer then 
        FollowButton.Text = "CHƯA CHỌN TARGET!"
        task.wait(1)
        FollowButton.Text = "🔄 START FOLLOW"
        return 
    end
    if not myRoot then return end

    -- BẬT CHẾ ĐỘ FOLLOW
    isFollowing = true
    FollowButton.Text = "🛑 STOP FOLLOW"
    FollowButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

    -- Chạy vòng lặp bám đuôi trong luồng phụ (thread mới) để không làm đơ game
    task.spawn(function()
        myRoot.Anchored = true -- Đóng băng vật lý để bay mượt

        while isFollowing and selectedPlayer and selectedPlayer.Character do
            local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            local currentCharacter = LocalPlayer.Character
            myRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")

            if targetRoot and myRoot then
                local distance = (targetRoot.Position - myRoot.Position).Magnitude
                local speed = tonumber(SpeedInput.Text) or 60

                -- Nếu mục tiêu ở xa (khoảng cách lớn hơn 3 mud), tiến hành bay đuổi theo
                if distance > 3 then
                    local duration = distance / speed
                    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                    
                    -- Điểm đến liên tục cập nhật theo vị trí mới của Target (cao hơn đầu 3 mud)
                    local targetCFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)

                    currentTween = TweenService:Create(myRoot, tweenInfo, {CFrame = targetCFrame})
                    currentTween:Play()
                    
                    -- Đợi lượt bay này hoàn thành (hoặc bị hủy giữa chừng) rồi mới lặp tiếp
                    currentTween.Completed:Wait() 
                else
                    -- Nếu đã ở sát bên cạnh, dính chặt lấy họ luôn
                    myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)
                    task.wait(0.05) -- Chờ cực ngắn để check tiếp tránh crash game
                end
            else
                task.wait(0.5) -- Chờ mục tiêu hồi sinh nếu họ bị chết
            end
        end

        -- Khi vòng lặp kết thúc (bấm Stop), nhả băng nhân vật ra
        isFollowing = false
        if myRoot then myRoot.Anchored = false end
        FollowButton.Text = "🔄 START FOLLOW"
        FollowButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    end)
end)

-- LOGIC: SPECTATE
SpecButton.MouseButton1Click:Connect(function()
    if not selectedPlayer or not selectedPlayer.Character then return end
    local targetHumanoid = selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
    local myHumanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

    if not targetHumanoid or not myHumanoid then return end

    if isSpectating then
        Camera.CameraSubject = myHumanoid
        isSpectating = false
        SpecButton.Text = "👁️ SPECTATE: OFF"
        SpecButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    else
        Camera.CameraSubject = targetHumanoid
        isSpectating = true
        SpecButton.Text = "👁️ SPECTATE: ON"
        SpecButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    end
end)
