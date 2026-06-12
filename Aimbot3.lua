-- [[ BRAINROT HUB - FULL MENU GUI & LOGIC (ASYLUM LIFE) ]] --

-- 1. KHỞI TẠO FRAMEWORK ĐỒ HỌA (DRAWING & UI)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Trạng thái cấu hình mặc định (Đồng bộ với các nút trên GUI)
getgenv().AimbotEnabled = true
getgenv().NoRecoilEnabled = true -- Chế độ Ghim Cứng (Không Rung)
getgenv().TeamCheckEnabled = true
getgenv().FOVRadius = 500
getgenv().Smoothness = 1

-- Vòng tròn FOV hiển thị trên màn hình giống trong ảnh
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Radius = getgenv().FOVRadius
FOVCircle.Filled = false
FOVCircle.Visible = true

-- Vòng lặp cập nhật vị trí vòng tròn FOV theo tâm chuột
RunService.RenderStepped:Connect(function()
    FOVCircle.Radius = getgenv().FOVRadius
    FOVCircle.Position = UserInputService:GetMouseLocation()
end)

-- 2. HÀM KIỂM TRA MỤC TIÊU (CHỈ HIỂN THỊ VÀ AIM BỆNH NHÂN)
local function isValidTarget(player)
    if player == LocalPlayer then return false end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") then 
        return false 
    end
    if player.Character.Humanoid.Health <= 0 then return false end
    
    -- Logic lọc nghề nghiệp dành riêng cho Cảnh Sát đi tuần:
    if getgenv().TeamCheckEnabled and player.Team then
        local teamName = player.Team.Name:lower()
        -- Nếu là Cảnh sát hoặc Bác sĩ thì BỎ QUA (không hiện ESP, không Aim)
        if string.find(teamName, "guard") or string.find(teamName, "police") or string.find(teamName, "cảnh sát") or string.find(teamName, "staff") or string.find(teamName, "doctor") then
            return false
        end
    end
    return true -- Chỉ giữ lại Bệnh nhân/Tù nhân
end

-- 3. LOGIC ESP NÂNG CAO (CHỈ VẼ BOX LÊN BỆNH NHÂN)
local function createESP(player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 100) -- Màu hồng neon giống viền GUI của bạn
    Box.Thickness = 1.5
    Box.Filled = false

    local function updateESP()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            -- Nếu tắt nút Ghim Cứng/ESP trên giao diện thì ẩn đi
            if getgenv().NoRecoilEnabled and player.Parent and isValidTarget(player) then
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = character.HumanoidRootPart
                    local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    
                    if onScreen then
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

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then createESP(p) end
end
Players.PlayerAdded:Connect(createESP)

-- 4. LOGIC AIMBOT THEO ĐÚNG MỤC TIÊU CÓ ESP
local function getClosestPatientToCursor()
    local closestPlayer = nil
    local shortestDistance = getgenv().FOVRadius

    for _, player in ipairs(Players:GetPlayers()) do
        if isValidTarget(player) then
            local character = player.Character
            local rootPart = character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                if distance < shortestDistance then
                    closestPlayer = character.HumanoidRootPart
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if getgenv().AimbotEnabled then
        local target = getClosestPatientToCursor()
        if target then
            local targetPos = Camera:WorldToViewportPoint(target.Position)
            local mousePos = UserInputService:GetMouseLocation()
            
            -- Tính toán mượt dựa trên thanh Slider Độ Mượt (%) trên GUI
            local moveX = (targetPos.X - mousePos.X) * (getgenv().Smoothness / 10)
            local moveY = (targetPos.Y - mousePos.Y) * (getgenv().Smoothness / 10)
            
            if mouse_moverel then
                mouse_moverel(moveX, moveY)
            else
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            end
        end
    end
end)

-- 5. VẼ MENU GUI (Tái hiện lại y hệt thiết kế Brainrot Hub trong ảnh)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local FrameStroke = Instance.new("UIStroke")
local Title = Instance.new("TextLabel")
local SubTitle = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "BrainrotHub"

-- Khung Menu chính (Màu tối, bo viền hồng)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
MainFrame.Size = UDim2.new(0, 350, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true -- Cho phép bạn lấy chuột kéo menu đi chỗ khác khi chơi game

FrameStroke.Parent = MainFrame
FrameStroke.Color = Color3.fromRGB(255, 0, 100) -- Viền hồng giống ảnh
FrameStroke.Thickness = 1.5

-- Tiêu đề Menu
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Brainrot Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)

SubTitle.Parent = MainFrame
SubTitle.Position = UDim2.new(0, 10, 0, 35)
SubTitle.Size = UDim2.new(1, -20, 0, 15)
SubTitle.Text = "— Distance Linked System —"
SubTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
SubTitle.TextSize = 12
SubTitle.Font = Enum.Font.SourceSansItalic
SubTitle.BackgroundTransparency = 1

-- HÀM TẠO NÚT BẬT/TẮT (TOGGLE BUTTONS)
local function createToggle(name, labelText, defaultState, callback)
    local LayoutY = 60 + (#MainFrame:GetChildren() - 4) * 40
    
    local Label = Instance.new("TextLabel")
    Label.Parent = MainFrame
    Label.Position = UDim2.new(0, 15, 0, LayoutY)
    Label.Size = UDim2.new(0, 200, 0, 30)
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    
    local Button = Instance.new("TextButton")
    Button.Parent = Label
    Button.Position = UDim2.new(1, 40, 0, 3)
    Button.Size = UDim2.new(0, 50, 0, 24)
    Button.Text = defaultState and "BẬT" or "TẮT"
    Button.BackgroundColor3 = defaultState and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(40, 40, 45)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSansBold
    
    local enabled = defaultState
    Button.MouseButton1Click:Connect(function()
        enabled = not enabled
        Button.Text = enabled and "BẬT" or "TẮT"
        Button.BackgroundColor3 = enabled and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(40, 40, 45)
        callback(enabled)
    end)
end

-- Tạo các nút bấm liên kết trực tiếp với Logic lọc Bệnh nhân ở trên
createToggle("Aimbot", "Bật Tự Động Ngắm (Aimbot)", true, function(state)
    getgenv().AimbotEnabled = state
end)

createToggle("ESP", "Chế Độ Ghim Cứng (Không Rung/ESP)", true, function(state)
    getgenv().NoRecoilEnabled = state
end)

createToggle("TeamCheck", "Né Đồng Đội (Team Check)", true, function(state)
    getgenv().TeamCheckEnabled = state
end)

-- 6. TẠO THANH TRƯỢT FOV (SLIDER)
local FOVLabel = Instance.new("TextLabel")
FOVLabel.Parent = MainFrame
FOVLabel.Position = UDim2.new(0, 15, 0, 190)
FOVLabel.Size = UDim2.new(0, 200, 0, 20)
FOVLabel.Text = "Kích Thước Vòng Tròn FOV: " .. getgenv().FOVRadius
FOVLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
FOVLabel.TextSize = 13
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left
FOVLabel.BackgroundTransparency = 1

local FOVSlider = Instance.new("TextButton")
FOVSlider.Parent = FOVLabel
FOVSlider.Position = UDim2.new(0, 0, 1, 5)
FOVSlider.Size = UDim2.new(0, 320, 0, 10)
FOVSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
FOVSlider.Text = ""

local FOVBar = Instance.new("Frame")
FOVBar.Parent = FOVSlider
FOVBar.Size = UDim2.new(0, (getgenv().FOVRadius/800)*320, 1, 0)
FOVBar.BackgroundColor3 = Color3.fromRGB(255, 0, 100)

local draggingFOV = false
FOVSlider.MouseButton1Down:Connect(function() draggingFOV = true end)
UserInputService.InputEnded:Connect(function(input) if
