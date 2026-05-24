-- Tạo Khung Giao Diện Cho Game Fisch
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Xóa Menu cũ nếu có để tránh trùng lặp khi chạy lại
if CoreGui:FindFirstChild("FischHub") then
    CoreGui.FischHub:Destroy()
end

-- Khởi tạo các biến trạng thái bật/tắt tính năng
_G.AutoShake = false
_G.AutoReel = false
_G.InstantReel = false

-- 1. Tạo ScreenGui chính
local FischGui = Instance.new("ScreenGui")
FischGui.Name = "FischHub"
FischGui.Parent = CoreGui
FischGui.ResetOnSpawn = false

-- 2. Tạo Bảng Menu To (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = FischGui
MainFrame.Size = UDim2.new(0, 450, 0, 320) -- Bảng to vừa phải
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160) -- Căn giữa màn hình
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25) -- Nền tối hiện đại
MainFrame.Active = true
MainFrame.Draggable = true -- Có thể giữ chuột để kéo di chuyển menu

-- Tạo viền tím dày dặn bằng UIStroke
local PurpleBorder = Instance.new("UIStroke")
PurpleBorder.Color = Color3.fromRGB(147, 51, 234) -- Màu tím neon
PurpleBorder.Thickness = 3
PurpleBorder.Parent = MainFrame

-- Bo góc nhẹ cho menu nhìn mượt hơn
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- 3. Tiêu đề Menu
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Title.Text = "FISCH HACK MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.SourceSansBold

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- 4. Vùng chứa các nút tính năng (Scrolling Frame)
local Container = Instance.new("ScrollingFrame")
Container.Name = "Container"
Container.Parent = MainFrame
Container.Size = UDim2.new(1, -20, 1, -65)
Container.Position = UDim2.new(0, 10, 0, 55)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 300)
Container.ScrollBarThickness = 4

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

-- Hàm tạo Nút Bật/Tắt (Toggle Button) nhanh
local function CreateToggle(name, defaultText, globalVar, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Parent = Container
    Button.Size = UDim2.new(1, -10, 0, 50)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Button.Text = defaultText .. " : OFF"
    Button.TextColor3 = Color3.fromRGB(239, 68, 68) -- Màu đỏ lúc tắt
    Button.TextSize = 16
    Button.Font = Enum.Font.SourceSansSemiBold
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button

    local ButtonBorder = Instance.new("UIStroke")
    ButtonBorder.Color = Color3.fromRGB(60, 60, 65)
    ButtonBorder.Thickness = 1
    ButtonBorder.Parent = Button

    Button.MouseButton1Click:Connect(function()
        _G[globalVar] = not _G[globalVar]
        if _G[globalVar] then
            Button.Text = defaultText .. " : ON"
            Button.TextColor3 = Color3.fromRGB(34, 197, 94) -- Màu xanh lúc bật
            ButtonBorder.Color = Color3.fromRGB(147, 51, 234) -- Viền nút đổi sang tím
        else
            Button.Text = defaultText .. " : OFF"
            Button.TextColor3 = Color3.fromRGB(239, 68, 68)
            ButtonBorder.Color = Color3.fromRGB(60, 60, 65)
        end
        if callback then callback(_G[globalVar]) end
    end)
end

-- 5. Khởi tạo 3 nút tính năng theo yêu cầu
CreateToggle("AutoShakeBtn", "Auto Shake", "AutoShake", function(state)
    print("Auto Shake đang:", state)
end)

CreateToggle("AutoReelBtn", "Auto Reel", "AutoReel", function(state)
    print("Auto Reel đang:", state)
end)

CreateToggle("InstantReelBtn", "Instant Reel", "InstantReel", function(state)
    print("Instant Reel đang:", state)
end)

-- ========================================================
-- VÙNG XỬ LÝ LOGIC NGẦM (Thực thi khi các nút được ON)
-- ========================================================

-- Vòng lặp cho Auto Shake
task.spawn(function()
    while task.wait() do
        if _G.AutoShake then
            -- Khi tính năng bật, đoạn code giả lập click hoặc gọi remote shake sẽ nằm ở đây
            -- Ví dụ: Bỏ qua minigame lắc bằng cách kích hoạt UI shake của game
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if PlayerGui then
                local shakeUI = PlayerGui:FindFirstChild("ShakeUI") -- Tên UI phụ thuộc vào game
                if shakeUI and shakeUI.Enabled then
                    -- Thực hiện tự động nhấn nút lắc tại đây
                end
            end
        end
    end
end)

-- Vòng lặp cho Auto Reel & Instant Reel
task.spawn(function()
    while task.wait() do
        if _G.AutoReel then
            -- Logic tự động quay dây (Reel) khi cá cắn câu
        end
        
        if _G.InstantReel then
            -- Logic kết thúc lượt câu ngay lập tức (nhận cá luôn)
        end
    end
end)
