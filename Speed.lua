-- [[ TWEEN TP GUI HUB ]] --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Tạo GUI (Tự động nhận diện CoreGui hoặc PlayerGui)
local ScreenGui = Instance.new("ScreenGui")
pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
ScreenGui.Name = "TweenTP_Hub"
ScreenGui.ResetOnSpawn = false

-- Khung Menu Chính (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 200)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Bật kéo thả menu linh hoạt
MainFrame.Parent = ScreenGui

-- Bo góc cho Menu
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Tiêu đề Menu
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Title.Text = "TWEEN TP MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BorderSizePixel = 0
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Khung nhập tên Player (TextBox)
local NameInput = Instance.new("TextBox")
NameInput.Name = "NameInput"
NameInput.Size = UDim2.new(0, 210, 0, 35)
NameInput.Position = UDim2.new(0, 20, 0, 55)
NameInput.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
NameInput.Text = ""
NameInput.PlaceholderText = "Nhập tên viết tắt của Player..."
NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
NameInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
NameInput.Font = Enum.Font.Gotham
NameInput.TextSize = 12
NameInput.BorderSizePixel = 0
NameInput.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = NameInput

-- Khung nhập Tốc độ Bay (Speed Input)
local SpeedInput = Instance.new("TextBox")
SpeedInput.Name = "SpeedInput"
SpeedInput.Size = UDim2.new(0, 210, 0, 35)
SpeedInput.Position = UDim2.new(0, 20, 0, 100)
SpeedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
SpeedInput.Text = "60" -- Mặc định là tốc độ 60 (khá an toàn)
SpeedInput.PlaceholderText = "Tốc độ bay (Mặc định: 60)"
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Font = Enum.Font.Gotham
SpeedInput.TextSize = 12
SpeedInput.BorderSizePixel = 0
SpeedInput.Parent = MainFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedInput

-- Nút Kích Hoạt Tween TP (Button)
local TPButton = Instance.new("TextButton")
TPButton.Name = "TPButton"
TPButton.Size = UDim2.new(0, 210, 0, 40)
TPButton.Position = UDim2.new(0, 20, 0, 145)
TPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
TPButton.Text = "BẮT ĐẦU BAY"
TPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TPButton.Font = Enum.Font.GothamBold
TPButton.TextSize = 13
TPButton.BorderSizePixel = 0
TPButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = TPButton

--- ==========================================
--- LOGIC XỬ LÝ TWEEN TP
--- ==========================================

local currentTween = nil

-- Hàm tìm kiếm Player theo tên viết tắt
local function findTargetPlayer(name)
    name = name:lower()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Name:lower():sub(1, #name) == name then
            return player
        end
    end
    return nil
end

-- Hàm xử lý Tween di chuyển
local function tweenToTarget(targetPart, speed)
    local character = LocalPlayer.Character
    if not character then return end
    local myRoot = character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    -- Nếu đang bay cũ thì hủy đi để bay cái mới
    if currentTween then
        currentTween:Cancel()
    end

    -- Tính khoảng cách và thời gian dựa trên tốc độ
    local distance = (targetPart.Position - myRoot.Position).Magnitude
    local duration = distance / speed

    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear, -- Giữ tốc độ đều suốt quãng đường
        Enum.EasingDirection.Out
    )

    -- Đích đến sẽ cách nhân vật kia một khoảng nhỏ (ở trên đầu 2 mud) để tránh kẹt đất
    local targetCFrame = targetPart.CFrame * CFrame.new(0, 2, 0)

    currentTween = TweenService:Create(myRoot, tweenInfo, {CFrame = targetCFrame})
    currentTween:Play()
    
    -- Đổi màu nút khi đang bay
    TPButton.Text = "ĐANG BAY... (Bấm lại để dừng)"
    TPButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    
    currentTween.Completed:Connect(function()
        TPButton.Text = "BẮT ĐẦU BAY"
        TPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        currentTween = nil
    end)
end

-- Sự kiện khi bấm nút
TPButton.MouseButton1Click:Connect(function()
    -- Nếu đang bay mà bấm lại thì dừng
    if currentTween then
        currentTween:Cancel()
        TPButton.Text = "BẮT ĐẦU BAY"
        TPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        currentTween = nil
        return
    end

    local inputName = NameInput.Text
    local speed = tonumber(SpeedInput.Text) or 60

    if inputName == "" then
        TPButton.Text = "HÃY NHẬP TÊN TRƯỚC!"
        task.wait(1.5)
        TPButton.Text = "BẮT ĐẦU BAY"
        return
    end

    local targetPlayer = findTargetPlayer(inputName)
    if targetPlayer and targetPlayer.Character then
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            tweenToTarget(targetRoot, speed)
        else
            TPButton.Text = "KHÔNG TÌM THẤY ROOT PART!"
            task.wait(1.5)
            TPButton.Text = "BẮT ĐẦU BAY"
        end
    else
        TPButton.Text = "KHÔNG THẤY NGƯỜI CHƠI NÀY!"
        task.wait(1.5)
        TPButton.Text = "BẮT ĐẦU BAY"
    end
end)
