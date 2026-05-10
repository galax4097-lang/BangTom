local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ==========================================
-- LOGIC NHẢY CAO (BẰNG LỰC ĐẨY TỰ DO)
-- ==========================================
local jumpEnabled = false
-- Giả sử bạn có một Input (JumpInput) và Nút (JumpButton) trên GUI
-- JumpButton.MouseButton1Click:Connect(function() jumpEnabled = not jumpEnabled end)

UserInputService.JumpRequest:Connect(function()
    if jumpEnabled then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        
        -- Kiểm tra nếu nhân vật đang tồn tại và không ở trạng thái rơi tự do
        if hrp and humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
            -- Thay vì đổi JumpPower, ta đẩy Velocity của trục Y lên cao
            local jumpForce = 50 -- Bạn có thể thay bằng tonumber(JumpInput.Text)
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, jumpForce, hrp.AssemblyLinearVelocity.Z)
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ==========================================
-- LOGIC AIMBOT VỚI FOV (FIELD OF VIEW)
-- ==========================================
local aimbotEnabled = false
local fovRadius = 150 -- Độ rộng của vòng FOV

-- Tạo vòng tròn FOV bằng Drawing API
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Radius = fovRadius
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8

-- Cập nhật vị trí vòng FOV theo chuột
RunService.RenderStepped:Connect(function()
    local mouseLocation = UserInputService:GetMouseLocation()
    FOVCircle.Position = mouseLocation
    
    -- Nếu tắt Aimbot thì ẩn vòng FOV
    FOVCircle.Visible = aimbotEnabled 
end)

-- Hàm tìm người chơi gần tâm ngắm nhất (VÀ PHẢI NẰM TRONG FOV)
local function getClosestPlayerInFOV()
    local closestDist = fovRadius -- Chỉ xét những mục tiêu có khoảng cách nhỏ hơn Bán kính FOV
    local closestTarget = nil
    local mouseLocation = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            -- Bỏ qua nếu mục tiêu đã chết
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local head = player.Character.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (targetScreenPos - mouseLocation).Magnitude
                    
                    -- Nếu mục tiêu nằm trong vòng tròn và gần chuột nhất
                    if dist < closestDist then
                        closestDist = dist
                        closestTarget = head
                    end
                end
            end
        end
    end
    return closestTarget
end

-- Chạy Aimbot khi giữ Chuột Phải
RunService.RenderStepped:Connect(function()
    if aimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayerInFOV()
        if target then
            -- Mượt mà chuyển góc nhìn (Smoothing/Lerp) thay vì giật cục
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 0.5) -- Chỉ số 0.5 là độ mượt (Smoothness)
        end
    end
end)
