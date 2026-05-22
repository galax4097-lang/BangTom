-- [[ PREMIUM HUB v1.0 - AIMBOT + ESP + FOV CIRCLE ]]
-- Mô phỏng chính xác giao diện video TikTok wombocombo.2

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- [[ CẤU HÌNH (SETTINGS) - Bạn có thể chỉnh sửa ở đây ]]
local Config = {
    -- Aimbot
    AimbotEnabled = true,
    AimKey = Enum.UserInputType.MouseButton2, -- Nhấn giữ chuột phải để ngắm
    TargetPart = "Head",                       -- Bộ phận ngắm vào (ví dụ: Head, Torso, HumanoidRootPart)
    FOV = 350,                                 -- Bán kính vòng tròn trường nhìn (tính bằng pixel)
    Smoothness = 0.15,                         -- Độ mượt khi di chuyển camera (từ 0.01 đến 1. Số càng nhỏ càng mượt và chậm)
    TeamCheck = false,                        -- Tắt nếu muốn nhắm cả đồng đội (Roblox Studio thường không có team mặc định)
    
    -- ESP (Chams/Highlighter)
    ESPEnabled = true,
    ESPColor = Color3.fromRGB(255, 0, 0),      -- Màu phát sáng (ví dụ: đỏ như máu)
    ESPFillTransparency = 0.5,                -- Độ trong suốt bên trong người chơi
    ESPOutlineTransparency = 0.1,             -- Độ trong suốt viền người chơi
    
    -- UI Giao diện
    FOVCircleColor = Color3.fromRGB(255, 255, 255),
    CrosshairColor = Color3.fromRGB(255, 255, 255),
    EliminatedTextColor = Color3.fromRGB(255, 215, 0), -- Vàng kim
}

local IsAiming = false
local CurrentElimText = nil -- Lưu trữ văn bản eliminated hiện tại để xóa

-- [[ 1. TẠO GIAO DIỆN UI PHẦN CỨNG ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsAimbotOverlay"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Vòng tròn FOV
local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "FOVCircle"
FOVFrame.Size = UDim2.new(0, Config.FOV, 0, Config.FOV)
FOVFrame.Position = UDim2.new(0.5, -Config.FOV/2, 0.5, -Config.FOV/2)
FOVFrame.BackgroundColor3 = Config.FOVCircleColor
FOVFrame.BackgroundTransparency = 1 -- Làm trong suốt bên trong
FOVFrame.BorderSizePixel = 2
FOVFrame.BorderColor3 = Config.FOVCircleColor -- Chỉ hiện viền trắng
FOVFrame.Parent = ScreenGui

local UICornerFOV = Instance.new("UICorner")
UICornerFOV.CornerRadius = UDim.new(1, 0) -- Bo góc thành hình tròn
UICornerFOV.Parent = FOVFrame

-- Tâm ngắm (Crosshair) - Chữ thập
local CrosshairHorizontal = Instance.new("Frame")
CrosshairHorizontal.Name = "CrosshairH"
CrosshairHorizontal.Size = UDim2.new(0, 30, 0, 2)
CrosshairHorizontal.Position = UDim2.new(0.5, -15, 0.5, -1)
CrosshairHorizontal.BackgroundColor3 = Config.CrosshairColor
CrosshairHorizontal.BorderSizePixel = 0
CrosshairHorizontal.Parent = ScreenGui

local CrosshairVertical = Instance.new("Frame")
CrosshairVertical.Name = "CrosshairV"
CrosshairVertical.Size = UDim2.new(0, 2, 0, 30)
CrosshairVertical.Position = UDim2.new(0.5, -1, 0.5, -15)
CrosshairVertical.BackgroundColor3 = Config.CrosshairColor
CrosshairVertical.BorderSizePixel = 0
CrosshairVertical.Parent = ScreenGui

-- Ping và thông tin Server (Mô phỏng)
local PingText = Instance.new("TextLabel")
PingText.Name = "PingInfo"
PingText.Size = UDim2.new(0, 200, 0, 20)
PingText.Position = UDim2.new(0.8, -100, 0.05, 0) -- Trên cùng bên phải
PingText.BackgroundTransparency = 1
PingText.Text = "Singapore 5fps 203ms" -- Giống video
PingText.TextColor3 = Color3.fromRGB(255, 255, 255)
PingText.Font = Enum.Font.SourceSans
PingText.TextSize = 14
PingText.TextXAlignment = Enum.TextXAlignment.Right
PingText.Parent = ScreenGui

-- [[ 2. HỆ THỐNG ESP (PHÁT SÁNG NGƯỜI CHƠI) ]]
local function ApplyESP(character)
    if not character:FindFirstChild("Highlight") then
        local Highlight = Instance.new("Highlight")
        Highlight.Parent = character
        Highlight.FillColor = Config.ESPColor
        Highlight.FillTransparency = Config.ESPFillTransparency
        Highlight.OutlineColor = Config.ESPColor
        Highlight.OutlineTransparency = Config.ESPOutlineTransparency
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Hiện xuyên tường
    end
end

local function RefreshESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                ApplyESP(player.Character)
            end
            player.CharacterAdded:Connect(function(char)
                task.wait(0.3) -- Chờ load nhân vật
                if Config.ESPEnabled then
                    ApplyESP(char)
                end
            end)
        end
    end
end

if Config.ESPEnabled then
    RefreshESP()
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            task.wait(0.3)
            if Config.ESPEnabled then
                ApplyESP(char)
            end
        end)
    end)
end

-- [[ 3. HỆ THỐNG AIMBOT & MÔ PHỎNG LOẠI BỎ ]]

-- Hàm tìm mục tiêu gần nhất trong FOV
local function GetClosestPlayerInFOV()
    local Target = nil
    local ShortestDistance = Config.FOV -- Khởi đầu bằng bán kính FOV

    for _, player in ipairs(Players:GetPlayers()) do
        -- Đảm bảo không nhắm vào bản thân, người chơi còn sống, cùng team (nếu bật), và có bộ phận đích
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            -- Team Check (Nếu bật)
            if Config.TeamCheck and player.Team == LocalPlayer.Team then continue end

            local Character = player.Character
            local HitPart = Character:FindFirstChild(Config.TargetPart)

            if HitPart then
                -- Chuyển vị trí 3D thế giới sang 2D màn hình
                local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(HitPart.Position)

                if OnScreen then
                    -- Tính khoảng cách từ tâm màn hình
                    local MousePosition = UserInputService:GetMouseLocation()
                    local Distance = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - MousePosition).Magnitude

                    if Distance < ShortestDistance then
                        ShortestDistance = Distance
                        Target = HitPart
                    end
                end
            end
        end
    end
    return Target
end

-- Hàm hiển thị văn bản loại bỏ mục tiêu (Mô phỏng)
local function ShowEliminatedText(name)
    if CurrentElimText then CurrentElimText:Destroy() end -- Xóa văn bản cũ nếu có

    local ElimText = Instance.new("TextLabel")
    ElimText.Name = "EliminatedNotification"
    ElimText.Size = UDim2.new(0, 400, 0, 50)
    ElimText.Position = UDim2.new(0.5, -200, 0.5, 50) -- Dưới tâm ngắm một chút
    ElimText.BackgroundTransparency = 1
    ElimText.Text = "Eliminated " .. name
    ElimText.TextColor3 = Config.EliminatedTextColor
    ElimText.Font = Enum.Font.SourceSansBold
    ElimText.TextSize = 30
    ElimText.Parent = ScreenGui
    CurrentElimText = ElimText
    
    task.wait(2.5) -- Hiển thị 2.5 giây
    if ElimText then ElimText:Destroy() end
end

-- Phát hiện cái chết của người chơi khác để hiển thị văn bản Eliminated
local function ConnectDiedEvents()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function(character)
                local humanoid = character:WaitForChild("Humanoid")
                humanoid.Died:Connect(function()
                    ShowEliminatedText(player.Name)
                end)
            end)
        end
    end
end
ConnectDiedEvents()
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            ShowEliminatedText(player.Name)
        end)
    end)
end)

-- [[ 4. XỬ LÝ ĐẦU VÀO VÀ CẬP NHẬT LIÊN TỤC ]]

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Config.AimKey then
        IsAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Config.AimKey then
        IsAiming = false
    end
end)

RunService.RenderStepped:Connect(function()
    -- Cập nhật vị trí vòng tròn FOV theo tâm màn hình (nếu thay đổi kích thước cửa sổ)
    FOVFrame.Position = UDim2.new(0.5, -Config.FOV/2, 0.5, -Config.FOV/2)

    -- Thực thi Aimbot
    if Config.AimbotEnabled and IsAiming then
        local Target = GetClosestPlayerInFOV()
        if Target then
            -- Tính toán CFrame đích đến (xoay camera hướng về mục tiêu)
            local TargetCFrame = CFrame.new(Camera.CFrame.Position, Target.Position)
            -- Làm mượt di chuyển camera đến mục tiêu (Smoothing)
            Camera.CFrame = Camera.CFrame:Lerp(TargetCFrame, Config.Smoothness)
        end
    end
end)
