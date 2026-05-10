-- ==========================================
-- KHỞI TẠO MENU HUB CƠ BẢN & GIAO DIỆN
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Kiểm tra và xóa Hub cũ nếu đã tồn tại
local guiParent = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
if guiParent:FindFirstChild("MyGlowingHub") then
    guiParent.MyGlowingHub:Destroy()
end

-- Tạo giao diện chính (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MyGlowingHub"
ScreenGui.Parent = guiParent
ScreenGui.ResetOnSpawn = false -- Giữ GUI khi respawn

-- Khung bảng Menu chính (MainFrame)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 240) -- Tăng chiều cao một chút
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Màu nền tối hơn
MainFrame.BorderSizePixel = 0
MainFrame.Active = true -- Cần thiết cho kéo thả
MainFrame.Parent = ScreenGui

-- Bo góc cho MainFrame
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Tiêu đề Menu
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "🌟 SCRIPT HUB PHÁT SÁNG"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Gạch ngang phân cách trang trí
local Line = Instance.new("Frame")
Line.Size = UDim2.new(0.9, 0, 0, 2)
Line.Position = UDim2.new(0.05, 0, 0, 45)
Line.BackgroundColor3 = Color3.fromRGB(0, 255, 255) -- Màu Cyan phát sáng
Line.BorderSizePixel = 0
Line.Parent = MainFrame

-- ==========================================
-- TÍNH NĂNG KÉO THẢ (DRAGGABLE) MƯỢT MÀ
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
-- CÁC NÚT TÍNH NĂNG (BUTTONS) & LOGIC
-- ==========================================

-- Cấu hình màu sắc phát sáng
local GLOW_COLOR = Color3.fromRGB(0, 255, 255) -- Cyan (Xanh lơ) sáng
local ENABLED_COLOR = Color3.fromRGB(0, 200, 200)
local DISABLED_COLOR = Color3.fromRGB(60, 60, 60)

-- Hàm tạo nút chuẩn
local function createButton(text, yPos)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.85, 0, 0, 42)
    Button.Position = UDim2.new(0.075, 0, 0, yPos)
    Button.BackgroundColor3 = DISABLED_COLOR
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 16
    Button.AutoButtonColor = false
    Button.Parent = MainFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button
    
    return Button
end

local ESPButton = createButton("Bật ESP Phát Sáng (Xuyên Tường)", 65)
local SpeedButton = createButton("Bật Tốc Độ (Speed)", 125)

-- ------------------------------------------
-- 1. LOGIC ESP PHÁT SÁNG (GLOWING ESP)
-- ------------------------------------------
local espEnabled = false

-- Hàm áp dụng hiệu ứng phát sáng cho một nhân vật
local function applyGlow(character)
    -- Xóa hiệu ứng cũ nếu có
    if character:FindFirstChild("GlowEffect") then
        character.GlowEffect:Destroy()
    end

    -- Tạo đối tượng Highlight mới
    local highlight = Instance.new("Highlight")
    highlight.Name = "GlowEffect"
    
    -- CẤU HÌNH PHÁT SÁNG TẠI ĐÂY
    highlight.OutlineColor = GLOW_COLOR      -- Màu viền ngoài sắc nét
    highlight.OutlineTransparency = 0        -- Viền rõ nét hoàn toàn
    highlight.FillColor = GLOW_COLOR         -- Màu tô phía trong
    highlight.FillTransparency = 0.75        -- Tô trong suốt nhẹ để tạo hiệu ứng hào quang
    
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- CHÍNH: Nhìn xuyên tường
    highlight.Adornee = character
    highlight.Parent = character
end

-- Hàm bật/tắt toàn bộ ESP
local function toggleESP()
    espEnabled = not espEnabled
    
    -- Cập nhật GUI
    ESPButton.BackgroundColor3 = espEnabled and ENABLED_COLOR or DISABLED_COLOR
    ESPButton.Text = espEnabled and "Tắt ESP Phát Sáng" or "Bật ESP Phát Sáng (Xuyên Tường)"

    if espEnabled then
        -- Áp dụng cho người chơi hiện tại
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                applyGlow(player.Character)
            end
        end
        
        -- Lắng nghe người chơi mới spawn
        getgenv().ESPConnection = Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                if espEnabled then
                    task.wait(0.5) -- Chờ nhân vật tải xong
                    applyGlow(character)
                end
            end)
        end)
    else
        -- Tắt kết nối và xóa hiệu ứng
        if getgenv().ESPConnection then getgenv().ESPConnection:Disconnect() end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("GlowEffect") then
                player.Character.GlowEffect:Destroy()
            end
        end
    end
end

ESPButton.MouseButton1Click:Connect(toggleESP)

-- ------------------------------------------
-- 2. LOGIC TỐC ĐỘ (SPEED)
-- ------------------------------------------
local speedEnabled = false
local speedConnection
local WANTED_SPEED = 45 -- Bạn có thể chỉnh tốc độ tại đây

local function toggleSpeed()
    speedEnabled = not speedEnabled
    
    -- Cập nhật GUI
    SpeedButton.BackgroundColor3 = speedEnabled and ENABLED_COLOR or DISABLED_COLOR
    SpeedButton.Text = speedEnabled and "Tắt Tốc Độ" or "Bật Tốc Độ (Speed)"

    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end

    if speedEnabled then
        -- Bật và khóa tốc độ
        humanoid.WalkSpeed = WANTED_SPEED
        speedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if speedEnabled then
                humanoid.WalkSpeed = WANTED_SPEED
            end
        end)
    else
        -- Tắt và trả về mặc định
        if speedConnection then speedConnection:Disconnect() end
        humanoid.WalkSpeed = 16 -- Tốc độ mặc định của Roblox
    end
end

-- Reset tốc độ khi respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1)
    if speedEnabled then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = WANTED_SPEED
        end
    end
end)

SpeedButton.MouseButton1Click:Connect(toggleSpeed)

-- ==========================================
-- NÚT ĐÓNG MENU (CLOSE BUTTON)
-- ==========================================
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -40, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 85, 85) -- Màu đỏ
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 26
CloseButton.Parent = MainFrame

CloseButton.MouseButton1Click:Connect(function()
    -- Tắt các kết nối trước khi xóa GUI
    if getgenv().ESPConnection then getgenv().ESPConnection:Disconnect() end
    if speedConnection then speedConnection:Disconnect() end
    ScreenGui:Destroy()
end)
