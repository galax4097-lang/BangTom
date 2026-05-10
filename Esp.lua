-- ==========================================
-- KHỞI TẠO DỊCH VỤ & BIẾN CƠ BẢN
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local guiParent = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
if guiParent:FindFirstChild("ApocRisingHub") then
    guiParent.ApocRisingHub:Destroy()
end

-- ==========================================
-- TẠO GIAO DIỆN (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApocRisingHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 320)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Thanh Tiêu đề (Top Bar)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 8)
TopBarCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "☣️ APOCALYPSE RISING HUB"
Title.TextColor3 = Color3.fromRGB(255, 85, 0)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Nút Thu Nhỏ / Phóng To
local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.new(0, 30, 0, 30)
MinButton.Position = UDim2.new(1, -70, 0, 5)
MinButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinButton.Text = "-"
MinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinButton.Font = Enum.Font.GothamBold
MinButton.TextSize = 20
MinButton.Parent = TopBar
Instance.new("UICorner", MinButton).CornerRadius = UDim.new(0, 6)

-- Nút Đóng
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.Parent = TopBar
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

-- Khung chứa nội dung (Content)
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -40)
Content.Position = UDim2.new(0, 0, 0, 40)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- ==========================================
-- LOGIC KÉO THẢ & THU NHỎ/PHÓNG TO
-- ==========================================
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local isMinimized = false
MinButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    MinButton.Text = isMinimized and "+" or "-"
    local targetSize = isMinimized and UDim2.new(0, 400, 0, 40) or UDim2.new(0, 400, 0, 320)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ==========================================
-- HÀM TẠO NÚT TÍNH NĂNG
-- ==========================================
local function createFeature(text, yPos, isInput)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.9, 0, 0, 45)
    Frame.Position = UDim2.new(0.05, 0, 0, yPos)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.Parent = Content
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0.05, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    if isInput then
        local TextBox = Instance.new("TextBox")
        TextBox.Size = UDim2.new(0.3, 0, 0.7, 0)
        TextBox.Position = UDim2.new(0.65, 0, 0.15, 0)
        TextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextBox.Font = Enum.Font.Gotham
        TextBox.Text = "50"
        TextBox.Parent = Frame
        Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 4)
        return TextBox
    else
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0.3, 0, 0.7, 0)
        Button.Position = UDim2.new(0.65, 0, 0.15, 0)
        Button.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        Button.Text = "OFF"
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Font = Enum.Font.GothamBold
        Button.Parent = Frame
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)
        return Button
    end
end

local JumpInput = createFeature("Tùy chỉnh Nhảy Cao (Jump Power)", 15, true)
local JumpButton = createFeature("Kích hoạt Nhảy Cao", 70, false)
local FlyCarButton = createFeature("Vehicle Fly (Bay xe - Nhấn E để bay)", 125, false)
local AimbotButton = createFeature("Aimbot (Giữ Chuột Phải)", 180, false)
local ESPButton = createFeature("ESP Phát Sáng (Glow)", 235, false)

-- ==========================================
-- LOGIC TÍNH NĂNG
-- ==========================================

-- 1. Nhảy Cao (JumpPower - Không ảnh hưởng Speed)
local jumpEnabled = false
JumpButton.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled
    JumpButton.Text = jumpEnabled and "ON" or "OFF"
    JumpButton.BackgroundColor3 = jumpEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(255, 85, 85)
    
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = jumpEnabled and tonumber(JumpInput.Text) or 50
    end
end)

-- 2. Vehicle Fly (Bay Xe)
local carFlyEnabled = false
local flyingCar = false
FlyCarButton.MouseButton1Click:Connect(function()
    carFlyEnabled = not carFlyEnabled
    FlyCarButton.Text = carFlyEnabled and "ON" or "OFF"
    FlyCarButton.BackgroundColor3 = carFlyEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(255, 85, 85)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.E and carFlyEnabled then
        flyingCar = not flyingCar
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        
        if humanoid and humanoid.SeatPart then
            local vehicle = humanoid.SeatPart:FindFirstAncestorOfClass("Model")
            local root = vehicle and vehicle.PrimaryPart or humanoid.SeatPart
            
            if flyingCar then
                -- Tạo lực bay
                local bv = Instance.new("BodyVelocity")
                bv.Name = "FlyVelocity"
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.Parent = root
                
                local bg = Instance.new("BodyGyro")
                bg.Name = "FlyGyro"
                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bg.CFrame = root.CFrame
                bg.Parent = root
                
                -- Điều khiển xe bay bằng WASD
                RunService:BindToRenderStep("VehicleFly", 1, function()
                    local speed = 100
                    local camCFrame = Camera.CFrame
                    local moveDir = Vector3.new(0,0,0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCFrame.RightVector end
                    
                    bv.Velocity = moveDir * speed
                    bg.CFrame = CFrame.new(root.Position, root.Position + camCFrame.LookVector)
                end)
            else
                -- Tắt bay
                RunService:UnbindFromRenderStep("VehicleFly")
                if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
                if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end
            end
        end
    end
end)

-- 3. Aimbot (Giữ Chuột Phải)
local aimbotEnabled = false
AimbotButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    AimbotButton.Text = aimbotEnabled and "ON" or "OFF"
    AimbotButton.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(255, 85, 85)
end)

local function getClosestPlayer()
    local closestDist = math.huge
    local closestTarget = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestTarget = player.Character.Head
                end
            end
        end
    end
    return closestTarget
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- 4. ESP Phát Sáng (Glowing ESP)
local espEnabled = false
local GLOW_COLOR = Color3.fromRGB(0, 255, 255)

local function applyESP(char)
    if not char:FindFirstChild("GlowESP") then
        local hl = Instance.new("Highlight")
        hl.Name = "GlowESP"
        hl.FillColor = GLOW_COLOR
        hl.OutlineColor = GLOW_COLOR
        hl.FillTransparency = 0.6
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
    end
end

ESPButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPButton.Text = espEnabled and "ON" or "OFF"
    ESPButton.BackgroundColor3 = espEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(255, 85, 85)
    
    if espEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then applyESP(p.Character) end
        end
        getgenv().ApocESP = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function(c) task.wait(0.5) applyESP(c) end)
        end)
    else
        if getgenv().ApocESP then getgenv().ApocESP:Disconnect() end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("GlowESP") then
                p.Character.GlowESP:Destroy()
            end
        end
    end
end)
