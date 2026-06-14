-- [[ BRAINROT HUB — DISTANCE LINKED SYSTEM CONFIG ]]
local Config = {
    Aimbot = true,               -- Bật/Tắt Tự Động Ngắm
    TeamCheck = false,           -- Né Đồng Đội (True là bật, False là tắt)
    FOVSize = 200,               -- Kích Thước Vòng Tròn FOV
    Smoothness = 0.15,           -- Độ Mượt Chế Độ Thường (Càng thấp càng ghim cứng, ví dụ: 0 là ghim chặt)
    TargetPart = "Head",         -- Bộ phận ngắm: "Head" (Đầu) hoặc "HumanoidRootPart" (Thân)
    
    -- Cấu hình liên kết với hệ thống ESP
    ESP_Enabled = true,
    MaxDistance = 300            -- Khoảng Cách ESP Tối Đa (m) - Chỉ ai trong tầm này mới bị Aim
}

-- [[ Các Dịch Vụ Hệ Thống ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ Khởi Tạo Vòng Tròn FOV Trực Quan ]]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 0, 127) -- Màu hồng neon giống giao diện Hub của bạn
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- [[ Hàm Kiểm Tra Điều Kiện ESP Trước Khi Cho Phép Aim ]]
local function hasActiveESP(targetPlayer)
    if not Config.ESP_Enabled then return false end
    if targetPlayer == LocalPlayer then return false end
    
    -- Kiểm tra điều kiện né đồng đội (Team Check)
    if Config.TeamCheck and targetPlayer.Team == LocalPlayer.Team then 
        return false 
    end
    
    local character = targetPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
        return false
    end
    
    -- Không aim người chơi đã chết
    if character.Humanoid.Health <= 0 then return false end
    
    -- KIỂM TRA KHOẢNG CÁCH ESP: Nếu vượt quá MaxDistance (Không hiển thị ESP) -> Không cho phép Aim
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if localRoot then
        local distance = (localRoot.Position - character.HumanoidRootPart.Position).Magnitude
        if distance > Config.MaxDistance then
            return false -- Mục tiêu nằm ngoài vùng ESP -> Loại bỏ khỏi danh sách ngắm
        end
    end
    
    return true
end

-- [[ Hàm Tìm Kiếm Mục Tiêu Hợp Lệ Trong Vùng FOV ]]
local function getClosestPlayerInFOV()
    local mousePos = UserInputService:GetMouseLocation()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if hasActiveESP(player) then
            local character = player.Character
            local targetPart = character:FindFirstChild(Config.TargetPart)
            
            if targetPart then
                -- Chuyển vị trí 3D của mục tiêu sang tọa độ 2D trên màn hình máy tính
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    -- Tính khoảng cách từ tâm chuột (tâm vòng FOV) đến mục tiêu trên màn hình
                    local distanceToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    -- Nếu mục tiêu nằm gọn trong vòng tròn FOV và là người gần tâm chuột nhất
                    if distanceToMouse <= Config.FOVSize and distanceToMouse < shortestDistance then
                        closestPlayer = character
                        shortestDistance = distanceToMouse
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- [[ Vòng Lặp Xử Lý Liên Tục (RenderStepped) ]]
RunService.RenderStepped:Connect(function()
    -- 1. Cập nhật vị trí và kích thước vòng tròn FOV di chuyển theo chuột
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = mousePos
    FOVCircle.Radius = Config.FOVSize
    FOVCircle.Visible = Config.Aimbot

    -- 2. Xử lý logic Tự Động Ngắm (Aimbot)
    if Config.Aimbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetCharacter = getClosestPlayerInFOV()
        
        if targetCharacter then
            local targetPart = targetCharacter:FindFirstChild(Config.TargetPart)
            if targetPart then
                -- Tính toán góc nhìn mới hướng thẳng vào mục tiêu (Đầu hoặc Thân)
                local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                
                -- Áp dụng độ mượt LERP (%)
                -- Ghim càng chặt khi giá trị Smoothness tiến về 0
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 - Config.Smoothness)
            end
        end
    end
end)
