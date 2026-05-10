-- ==========================================
-- KHỞI TẠO MENU HUB CƠ BẢN
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Kiểm tra và xóa Hub cũ nếu đã tồn tại (để tránh bị trùng lặp khi chạy nhiều lần)
local guiParent = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
if guiParent:FindFirstChild("MyCustomHub") then
    guiParent.MyCustomHub:Destroy()
end

-- Tạo giao diện chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MyCustomHub"
ScreenGui.Parent = guiParent

-- Tạo khung bảng Menu (MainFrame)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 220)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Tiêu đề Menu
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🔥 SCRIPT HUB HOÀN THIỆN"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Dấu gạch ngang phân cách
local Line = Instance.new("Frame")
Line.Size = UDim2.new(0.9, 0, 0, 2)
Line.Position = UDim2.new(0.05, 0, 0, 40)
Line.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
Line.BorderSizePixel = 0
Line.Parent = MainFrame

-- ==========================================
-- TÍNH NĂNG KÉO THẢ (DRAGGABLE)
-- ==========================================
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- ==========================================
-- CÁC NÚT TÍNH NĂNG (BUTTONS)
-- ==========================================

-- Hàm tạo nút chuẩn
local function createButton(text, yPos)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.85, 0, 0, 40)
    Button.Position = UDim2.new(0.075, 0, 0, yPos)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 15
    Button.AutoButtonColor = false
    Button.Parent = MainFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button
    
    return Button
end

local ESPButton = createButton("Bật ESP (Xuyên Tường)", 60)
local SpeedButton = createButton("Bật WalkSpeed (Đi Nhanh)", 115)

-- ==========================================
-- LOGIC TÍNH NĂNG (ESP & SPEED)
-- ==========================================

-- 1. Logic ESP
local espEnabled = false

local function toggleESP()
    espEnabled = not espEnabled
    -- Đổi màu nút khi bật/tắt
    ESPButton.BackgroundColor3 = espEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(50, 50, 50)
    ESPButton.Text = espEnabled and "Tắt ESP" or "Bật ESP (Xuyên Tường)"

    if espEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESPHighlight"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Parent = player.Character
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("ESPHighlight") then
                player.Character.ESPHighlight:Destroy()
            end
        end
    end
end

ESPButton.MouseButton1Click:Connect(toggleESP)

-- 2. Logic Speed (Khóa WalkSpeed)
local speedEnabled = false
local speedConnection

local function toggleSpeed()
    speedEnabled = not speedEnabled
    SpeedButton.BackgroundColor3 = speedEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(50, 50, 50)
    SpeedButton.Text = speedEnabled and "Tắt WalkSpeed" or "Bật WalkSpeed (Đi Nhanh)"

    if speedEnabled then
        getgenv().WalkSpeedValue = 40 -- Tốc độ tùy chỉnh
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue
            -- Khóa tốc độ liên tục để chống game reset lại
            speedConnection = LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue
            end)
        end
    else
        if speedConnection then speedConnection:Disconnect() end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16 -- Trả về mặc định
        end
    end
end

SpeedButton.MouseButton1Click:Connect(toggleSpeed)

-- Nút đóng Menu
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 85, 85)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.Parent = MainFrame

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
