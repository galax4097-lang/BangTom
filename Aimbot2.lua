-- [[ BRAINROT HUB - ADVANCED ESP & AIMBOT (ASYLUM LIFE) ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Cấu hình đồng bộ từ Menu GUI của bạn
getgenv().BrainrotConfig = {
    AimbotEnabled = true,
    ESPEnabled = true,
    FOVRadius = 500, -- Độ rộng vòng tròn FOV như trong ảnh
    Smoothness = 1 -- Độ mượt khóa mục tiêu (1% -> 100%, số càng nhỏ càng mượt/chậm)
}

-- Hàm kiểm tra nghề nghiệp (Chỉ nhắm vào Bệnh nhân)
local function isValidTarget(player)
    if player == LocalPlayer then return false end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") then 
        return false 
     honey
    if player.Character.Humanoid.Health <= 0 then return false end
    
    -- Kiểm tra Team / Nghề nghiệp trong Asylum Life
    -- Thường game quản lý qua player.Team hoặc player.TeamColor
    if player.Team then
        local teamName = player.Team.Name:lower()
        -- Chỉ chọn mục tiêu nếu là Bệnh nhân (Patient), bỏ qua Cảnh sát (Guard/Police) và Bác sĩ (Staff/Doctor/Nurse)
        if string.find(teamName, "patient") or string.find(teamName, "bệnh nhân") or string.find(teamName, "tù nhân") then
            return true
        end
    end
    return false
end

-- --- XỬ LÝ NÂNG CAO: ESP (Chỉ hiện Bệnh nhân) ---
local function createESP(player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 100) -- Màu hồng neon hợp với tông GUI của bạn
    Box.Thickness = 1.5
    Box.Filled = false

    local function updateESP()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if getgenv().BrainrotConfig.ESPEnabled and player.Parent and isValidTarget(player) then
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = character.HumanoidRootPart
                    local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    
                    if onScreen then
                        -- Tính toán kích thước Box dựa trên khoảng cách
                        local camPos = Camera.CFrame.Position
                        local distance = (camPos - rootPart.Position).Magnitude
                        local boxSize = math.clamp((2000 / distance) * 2, 10, 150)
                        
                        Box.Size = Vector2.new(boxSize, boxSize * 1.5)
                        Box.Position = Vector2.new(screenPos.X - Box.Size.X / 2, screenPos.Y - Box.Size.Y / 2)
                        Box.Visible = true
                        return
                    end
                end
            end
            Box.Visible = false
            if not player.Parent then
                Box:Remove()
                connection:Disconnect()
            end
        end)
    end
    coroutine.wrap(updateESP)()
end

-- Áp dụng ESP cho người chơi hiện tại và người mới vào phòng game
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then createESP(p) end
end
Players.PlayerAdded:Connect(createESP)


-- --- XỬ LÝ NÂNG CAO: AIMBOT DỰA TRÊN ESP (Chỉ Aim người dính ESP) ---
local function getClosestPatientToCursor()
    local closestPlayer = nil
    local shortestDistance = getgenv().BrainrotConfig.FOVRadius

    for _, player in ipairs(Players:GetPlayers()) do
        -- CHỈ AIM những ai thỏa mãn điều kiện ESP (Là Bệnh nhân)
        if isValidTarget(player) then
            local character = player.Character
            local rootPart = character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                -- Kiểm tra xem mục tiêu có nằm trong vòng tròn FOV không
                if distance < shortestDistance then
                    closestPlayer = character.HumanoidRootPart -- Khóa vào người (hoặc đổi thành Head nếu muốn bắn đầu)
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- Vòng lặp khóa mục tiêu khi bật Aimbot
RunService.RenderStepped:Connect(function()
    if getgenv().BrainrotConfig.AimbotEnabled then
        local target = getClosestPatientToCursor()
        if target then
            -- Tính toán mượt (Smoothness) để tâm không bị giật khựng, tránh bị hệ thống game phát hiện
            local targetPos = Camera:WorldToViewportPoint(target.Position)
            local mousePos = UserInputService:GetMouseLocation()
            local moveX = (targetPos.X - mousePos.X) * (getgenv().BrainrotConfig.Smoothness / 10)
            local moveY = (targetPos.Y - mousePos.Y) * (getgenv().BrainrotConfig.Smoothness / 10)
            
            -- Di chuyển camera nhẹ nhàng về phía mục tiêu có ESP
            mouse_moverel(moveX, moveY) -- Hoặc sử dụng Camera.CFrame tùy thuộc vào Executor của bạn
        end
    end
end)
