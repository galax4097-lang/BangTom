-- [[ BRAINROT HUB V2 - SIÊU TỐI ƯU CHO EXECUTOR ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Cấu hình mặc định
getgenv().AimbotEnabled = true
getgenv().ESPEnabled = true
getgenv().TeamCheckEnabled = true
getgenv().FOVRadius = 300 -- Giới hạn vùng quét (pixel xung quanh tâm)

-- 1. HÀM KIỂM TRA MỤC TIÊU (LỌC NGHỀ NGHIỆP TRỰC TIẾP)
local function isValidTarget(player)
    if player == LocalPlayer then return false end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") then 
        return false 
    end
    if player.Character.Humanoid.Health <= 0 then return false end
    
    -- Tự động lọc: Bỏ qua Cảnh sát (Guard) và Bác sĩ (Doctor/Nurse/Staff)
    if getgenv().TeamCheckEnabled and player.Team then
        local tName = player.Team.Name:lower()
        if string.find(tName, "guard") or string.find(tName, "police") or string.find(tName, "cảnh") or string.find(tName, "staff") or string.find(tName, "doc") or string.find(tName, "nurse") then
            return false
        end
    end
    return true -- Chỉ nhắm vào Bệnh nhân (Patients)
end

-- 2. TẠO MENU GIAO DIỆN CHUẨN ROBLOX (KHÔNG BỊ CRASH)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")

-- Thêm vào CoreGui để hiển thị lên màn hình
pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

MainFrame.Size = UDim2.new(0, 320, 0, 220)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 100) -- Viền hồng của Brainrot Hub
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Title.Text = "BRAINROT HUB — ASYLUM LIFE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Hàm tạo nút bấm bật/tắt nhanh
local buttonCount = 0
local function makeToggle(text, default, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 280, 0, 35)
    Btn.Position = UDim2.new(0, 20, 0, 50 + (buttonCount * 45))
    Btn.BackgroundColor3 = default and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(45, 45, 50)
    Btn.Text = text .. (default and ": BẬT" or ": TẮT")
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 14
    Btn.Parent = MainFrame
    
    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(45, 45, 50)
        Btn.Text = text .. (state and ": BẬT" or ": TẮT")
        callback(state)
    end)
    buttonCount = buttonCount + 1
end

makeToggle("Tự Động Ngắm (Aimbot)", true, function(v) getgenv().AimbotEnabled = v end)
makeToggle("Hiện Khung (ESP Bệnh Nhân)", true, function(v) getgenv().ESPEnabled = v end)
makeToggle("Né Đồng Đội (Team Check)", true, function(v) getgenv().TeamCheckEnabled = v end)

-- 3. CƠ CHẾ QUÉT VÀ KHÓA CAMERA (AIMBOT AN TOÀN)
local function getClosestTarget()
    local closest = nil
    local maxDist = getgenv().FOVRadius
    local mousePos = UserInputService:GetMouseLocation()

    for _, p in ipairs(Players:GetPlayers()) do
        if isValidTarget(p) then
            local char = p.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos, onScreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < maxDist then
                        closest = char.HumanoidRootPart
                        maxDist = dist
                    end
                end
            end
        end
    end
    return closest
end

-- Vòng lặp chạy tính năng ngầm
RunService.RenderStepped:Connect(function()
    -- Xử lý Aimbot bằng cách đổi góc xoay Camera (Không lo lỗi kẹt chuột)
    if getgenv().AimbotEnabled then
        local target = getClosestTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    -- Xử lý ESP (Vẽ Highlight trực tiếp bằng tính năng gốc của Roblox)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local highlight = p.Character:FindFirstChild("BrainrotESP")
            if getgenv().ESPEnabled and isValidTarget(p) then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "BrainrotESP"
                    highlight.FillColor = Color3.fromRGB(255, 0, 100)
                    highlight.FillTransparency = 0.6
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.OutlineTransparency = 0
                    highlight.Parent = p.Character
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end)
