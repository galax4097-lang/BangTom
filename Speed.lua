local Players = game:GetService("Players")
local CoreGui = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or Players.LocalPlayer:WaitForChild("PlayerGui")

local player = Players.LocalPlayer
local speedConnection -- Biến lưu trữ kết nối để ngắt khi tắt

-- ==========================================
-- 1. XÓA BẢNG CŨ NẾU CÓ
-- ==========================================
if CoreGui:FindFirstChild("OptimizedSpeedHub") then
    CoreGui.OptimizedSpeedHub:Destroy()
end

-- ==========================================
-- 2. TẠO GUI TỐI GIẢN (ÍT TỐN BỘ NHỚ)
-- ==========================================
local sg = Instance.new("ScreenGui")
sg.Name = "OptimizedSpeedHub"
sg.ResetOnSpawn = false
sg.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 130)
frame.Position = UDim2.new(0.5, -100, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
frame.Parent = sg
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "⚡ OPTIMIZED SPEED"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Parent = frame

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.4, 0, 0, 35)
speedInput.Position = UDim2.new(0.05, 0, 0.3, 0)
speedInput.Text = "50"
speedInput.Font = Enum.Font.Gotham
speedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Parent = frame
Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0, 5)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.45, 0, 0, 35)
toggleBtn.Position = UDim2.new(0.5, 0, 0.3, 0)
toggleBtn.Text = "BẬT"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 5)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.9, 0, 0, 30)
closeBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
closeBtn.Text = "ĐÓNG & RESET"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Parent = frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

-- ==========================================
-- 3. LOGIC TỐI ƯU HÓA (EVENT-DRIVEN)
-- ==========================================
local isEnabled = false

-- Hàm áp dụng tốc độ và giữ nó cố định
local function applySpeed(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    -- Ngắt kết nối cũ nếu có để tránh rò rỉ bộ nhớ (Memory Leak)
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end

    if isEnabled then
        local targetSpeed = tonumber(speedInput.Text) or 16
        humanoid.WalkSpeed = targetSpeed

        -- Chỉ kích hoạt khi game cố tình đổi lại tốc độ của bạn (Cực kỳ tối ưu)
        speedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if humanoid.WalkSpeed ~= targetSpeed and isEnabled then
                humanoid.WalkSpeed = targetSpeed
            end
        end)
    else
        humanoid.WalkSpeed = 16
    end
end

-- Xử lý nút Bật/Tắt
toggleBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    toggleBtn.Text = isEnabled and "TẮT" or "BẬT"
    toggleBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(200, 100, 0) or Color3.fromRGB(0, 150, 80)
    
    if player.Character then
        applySpeed(player.Character)
    end
end)

-- Tự động áp dụng lại tốc độ khi bạn chết và hồi sinh
player.CharacterAdded:Connect(function(newCharacter)
    if isEnabled then
        applySpeed(newCharacter)
    end
end)

-- Xử lý nút Đóng (Dọn dẹp bộ nhớ sạch sẽ)
closeBtn.MouseButton1Click:Connect(function()
    isEnabled = false
    if speedConnection then
        speedConnection:Disconnect()
    end
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16
    end
    sg:Destroy()
end)
