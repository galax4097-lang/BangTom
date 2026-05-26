-- [[ TWEEN TP GUI HUB - FIXED TELEPORT BUG ]] --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Tạo GUI
local ScreenGui = Instance.new("ScreenGui")
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
ScreenGui.Name = "TweenTP_Hub_Fixed"
ScreenGui.ResetOnSpawn = false

-- Khung Menu Chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 200)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Tiêu đề Menu
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Title.Text = "TWEEN TP MENU (FIXED)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BorderSizePixel = 0
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Nhập tên Player
local NameInput = Instance.new("TextBox")
NameInput.Size = UDim2.new(0, 210, 0, 35)
NameInput.Position = UDim2.new(0, 20, 0, 55)
NameInput.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
NameInput.Text = ""
NameInput.PlaceholderText = "Nhập tên Player..."
NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
NameInput.Font = Enum.Font.Gotham
NameInput.TextSize = 12
NameInput.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = NameInput

-- Nhập Tốc độ Bay
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0, 210, 0, 35)
SpeedInput.Position = UDim2.new(0, 20, 0, 100)
SpeedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
SpeedInput.Text = "50" -- Để tốc độ 50-60 cho mượt, cao quá dễ bị phản tác dụng
SpeedInput.PlaceholderText = "Tốc độ bay (Mặc định: 50)"
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Font = Enum.Font.Gotham
SpeedInput.TextSize = 12
SpeedInput.Parent = MainFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedInput

-- Nút Kích Hoạt
local TPButton = Instance.new("TextButton")
TPButton.Size = UDim2.new(0, 210, 0, 40)
TPButton.Position = UDim2.new(0, 20, 0, 145)
TPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
TPButton.Text = "BẮT ĐẦU BAY"
TPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TPButton.Font = Enum.Font.GothamBold
TPButton.TextSize = 13
TPButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = TPButton

--- LOGIC XỬ LÝ
local currentTween = nil

local function findTargetPlayer(name)
    name = name:lower()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Name:lower():sub(1, #name) == name then
            return player
        end
    end
    return nil
end

local function tweenToTarget(targetPart, speed)
    local character = LocalPlayer.Character
    if not character then return end
    local myRoot = character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    if currentTween then currentTween:Cancel() end

    local distance = (targetPart.Position - myRoot.Position).Magnitude
    local duration = distance / speed

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local targetCFrame = targetPart.CFrame * CFrame.new(0, 3, 0) -- Bay đến vị trí trên đầu mục tiêu 3 mud để tránh kẹt đất

    -- [MẸO FIX]: Đóng băng nhân vật trước khi bay để ép game phải dùng Tween mượt mà
    myRoot.Anchored = true 

    currentTween = TweenService:Create(myRoot, tweenInfo, {CFrame = targetCFrame})
    currentTween:Play()
    
    TPButton.Text = "ĐANG BAY... (Bấm để dừng)"
    TPButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    
    currentTween.Completed:Connect(function()
        -- Khi bay tới nơi thì nhả băng ra để đi lại bình thường
        myRoot.Anchored = false 
        TPButton.Text = "BẮT ĐẦU BAY"
        TPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        currentTween = nil
    end)
end

TPButton.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character
    local myRoot = character and character:FindFirstChild("HumanoidRootPart")

    if currentTween then
        currentTween:Cancel()
        if myRoot then myRoot.Anchored = false end -- Nhả băng nếu bấm dừng giữa chừng
        TPButton.Text = "BẮT ĐẦU BAY"
        TPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        currentTween = nil
        return
    end

    local inputName = NameInput.Text
    local speed = tonumber(SpeedInput.Text) or 50

    if inputName == "" then return end

    local targetPlayer = findTargetPlayer(inputName)
    if targetPlayer and targetPlayer.Character then
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            tweenToTarget(targetRoot, speed)
        end
    end
end)
