-- [[ DRAGON MENU I UNIVERSAL - v5.9 (BUILD A RING FARM) ]] --
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

if CoreGui:FindFirstChild("DragonMenuUniversal") then
    CoreGui:FindFirstChild("DragonMenuUniversal"):Destroy()
end

-- ================= HỆ THỐNG CẤU HÌNH =================
local Config = {
    AutoRoll = false,
    RollSpeed = 50, -- Mặc định 50%
    SelectedSeeds = {
        ["Common"] = false, ["Uncommon"] = false, ["Rare"] = false, ["Epic"] = false, ["Legendary"] = false,
        ["Secret"] = false, ["Prismatic"] = false, ["Divine"] = false, ["Exotic"] = false, ["Mythic"] = false
    }
}

-- ================= KHỞI TẠO UI (CHUẨN DRAGON MENU) =================
local DragonMenuUniversal = Instance.new("ScreenGui")
DragonMenuUniversal.Name = "DragonMenuUniversal"
DragonMenuUniversal.Parent = CoreGui
DragonMenuUniversal.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Khung chính (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = DragonMenuUniversal
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderColor3 = Color3.fromRGB(140, 50, 255) -- Viền tím neon đặc trưng
MainFrame.BorderSizePixel = 1.5
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 680, 0, 420)
MainFrame.Active = true
MainFrame.Draggable = true -- Giúp bạn có thể nắm đầu kéo Menu di chuyển

-- Bo góc khung chính
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainFrame

-- Tiêu đề Menu (Title)
local MenuTitle = Instance.new("TextLabel")
MenuTitle.Name = "MenuTitle"
MenuTitle.Parent = MainFrame
MenuTitle.BackgroundTransparency = 1
MenuTitle.Position = UDim2.new(0, 15, 0, 8)
MenuTitle.Size = UDim2.new(0, 400, 0, 30)
MenuTitle.Font = Enum.Font.GothamBold
MenuTitle.Text = "Dragon Menu l Universal - v5.9"
MenuTitle.TextColor3 = Color3.fromRGB(165, 90, 255)
MenuTitle.TextSize = 19
MenuTitle.TextXAlignment = Enum.TextXAlignment.Left

-- ================= SIDEBAR (DANH SÁCH TAB BÊN TRÁI) =================
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
Sidebar.BorderColor3 = Color3.fromRGB(40, 40, 45)
Sidebar.Position = UDim2.new(0, 12, 0, 45)
Sidebar.Size = UDim2.new(0, 160, 0, 360)

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 4)
SidebarCorner.Parent = Sidebar

local SidebarList = Instance.new("UIListLayout")
SidebarList.Parent = Sidebar
SidebarList.Padding = UDim.new(0, 6)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder

-- Hàm tạo các Tab giả lập giống trong hình
local function CreateTabBtn(name, isActive)
    local Btn = Instance.new("TextButton")
    Btn.Name = name .. "Tab"
    Btn.Parent = Sidebar
    Btn.BackgroundColor3 = isActive and Color3.fromRGB(22, 18, 30) or Color3.fromRGB(22, 22, 26)
    Btn.BorderColor3 = isActive and Color3.fromRGB(140, 50, 255) or Color3.fromRGB(45, 45, 50)
    Btn.BorderSizePixel = 1
    Btn.Size = UDim2.new(0, 145, 0, 38)
    Btn.Font = Enum.Font.GothamBold
    Btn.Text = name
    Btn.TextColor3 = isActive and Color3.fromRGB(200, 150, 255) or Color3.fromRGB(200, 200, 200)
    Btn.TextSize = 13
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = Btn
    
    -- Đẩy vị trí đệm trên cùng
    if name == "Main" then
        local Spacer = Instance.new("Frame")
        Spacer.Size = UDim2.new(0,10,0,4)
        Spacer.BackgroundTransparency = 1
        Spacer.Parent = Sidebar
        Spacer.LayoutOrder = 0
    end
end

CreateTabBtn("Main", false)
CreateTabBtn("Player", false)
CreateTabBtn("Visuals", false)
CreateTabBtn("Server", false)
CreateTabBtn("Settings", false)
CreateTabBtn("Build Ring", true) -- Tab này được chọn hoạt động

-- ================= KHU VỰC NỘI DUNG (CONTENT CONTAINER BÊN PHẢI) =================
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
ContentFrame.BorderColor3 = Color3.fromRGB(140, 50, 255)
ContentFrame.BorderSizePixel = 1
ContentFrame.Position = UDim2.new(0, 185, 0, 45)
ContentFrame.Size = UDim2.new(0, 480, 0, 360)

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 4)
ContentCorner.Parent = ContentFrame

-- Tiêu đề khu vực tính năng
local SectionTitle = Instance.new("TextLabel")
SectionTitle.Parent = ContentFrame
SectionTitle.BackgroundTransparency = 1
SectionTitle.Position = UDim2.new(0, 15, 0, 10)
SectionTitle.Size = UDim2.new(0, 300, 0, 25)
SectionTitle.Font = Enum.Font.GothamBold
SectionTitle.Text = "Build Ring Farm Controls"
SectionTitle.TextColor3 = Color3.fromRGB(180, 120, 255)
SectionTitle.TextSize = 16
SectionTitle.TextXAlignment = Enum.TextXAlignment.Left

-- --- TÍNH NĂNG 1: THANH KÉO TỐC ĐỘ (SLIDER SPEED) ---
local SliderBox = Instance.new("Frame")
SliderBox.Parent = ContentFrame
SliderBox.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
SliderBox.BorderColor3 = Color3.fromRGB(140, 50, 255)
SliderBox.Position = UDim2.new(0, 15, 0, 45)
SliderBox.Size = UDim2.new(0, 450, 0, 45)

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Parent = SliderBox
SliderLabel.BackgroundTransparency = 1
SliderLabel.Position = UDim2.new(0, 10, 0, 4)
SliderLabel.Size = UDim2.new(0, 150, 0, 15)
SliderLabel.Font = Enum.Font.GothamSemibold
SliderLabel.Text = "Auto-Roll Speed"
SliderLabel.TextColor3 = Color3.fromRGB(150, 120, 220)
SliderLabel.TextSize = 12
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left

local MaxRateLabel = Instance.new("TextLabel")
MaxRateLabel.Parent = SliderBox
MaxRateLabel.BackgroundTransparency = 1
MaxRateLabel.Position = UDim2.new(1, -110, 0, 4)
MaxRateLabel.Size = UDim2.new(0, 100, 0, 15)
MaxRateLabel.Font = Enum.Font.GothamSemibold
MaxRateLabel.Text = "Max Rate"
MaxRateLabel.TextColor3 = Color3.fromRGB(140, 50, 255)
MaxRateLabel.TextSize = 11
MaxRateLabel.TextXAlignment = Enum.TextXAlignment.Right

local SliderRail = Instance.new("Frame")
SliderRail.Parent = SliderBox
SliderRail.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
SliderRail.BorderSizePixel = 0
SliderRail.Position = UDim2.new(0, 10, 0, 26)
SliderRail.Size = UDim2.new(0, 380, 0, 4)

local SliderFill = Instance.new("Frame")
SliderFill.Parent = SliderRail
SliderFill.BackgroundColor3 = Color3.fromRGB(140, 50, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Size = UDim2.new(0.5, 0, 1, 0) -- Mặc định 50%

local SliderButton = Instance.new("ImageButton")
SliderButton.Parent = SliderRail
SliderButton.BackgroundColor3 = Color3.fromRGB(180, 100, 255)
SliderButton.Position = UDim2.new(0.5, -6, 0, -5)
SliderButton.Size = UDim2.new(0, 12, 0, 14)
Instance.new("UICorner", SliderButton).CornerRadius = UDim.new(0, 3)

local SliderValueText = Instance.new("TextLabel")
SliderValueText.Parent = SliderBox
SliderValueText.BackgroundTransparency = 1
SliderValueText.Position = UDim2.new(1, -50, 0, 20)
SliderValueText.Size = UDim2.new(0, 40, 0, 15)
SliderValueText.Font = Enum.Font.GothamBold
SliderValueText.Text = "50"
SliderValueText.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderValueText.TextSize = 14

-- Xử lý Logic Kéo Slider bằng Chuột/Cảm ứng
local IsSliding = false
SliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsSliding = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsSliding = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if IsSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local MousePos = input.Position.X
        local RailLeft = SliderRail.AbsolutePosition.X
        local RailWidth = SliderRail.AbsoluteSize.X
        local Percentage = math.clamp((MousePos - RailLeft) / RailWidth, 0, 1)
        
        SliderButton.Position = UDim2.new(Percentage, -6, 0, -5)
        SliderFill.Size = UDim2.new(Percentage, 0, 1, 0)
        
        local RealValue = math.floor(Percentage * 100)
        SliderValueText.Text = tostring(RealValue)
        Config.RollSpeed = RealValue
    end
end)

-- --- TÍNH NĂNG 2: BẢNG LỌC HẠT GIỐNG (SEED FILTER) MÔ PHỎNG ĐÚNG HÌNH ---
local FilterBox = Instance.new("Frame")
FilterBox.Parent = ContentFrame
FilterBox.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
FilterBox.BorderColor3 = Color3.fromRGB(140, 50, 255)
FilterBox.Position = UDim2.new(0, 15, 0, 100)
FilterBox.Size = UDim2.new(0, 450, 0, 155)

local FilterLabel = Instance.new("TextLabel")
FilterLabel.Parent = FilterBox
FilterLabel.BackgroundTransparency = 1
FilterLabel.Position = UDim2.new(0, 0, 0, 5)
FilterLabel.Size = UDim2.new(1, 0, 0, 15)
FilterLabel.Font = Enum.Font.GothamBold
FilterLabel.Text = "Seed Filter (Auto-Stop on)"
FilterLabel.TextColor3 = Color3.fromRGB(165, 90, 255)
FilterLabel.TextSize = 13

-- Khung lưới chia 2 cột cho các Hạt Giống
local GridFrame = Instance.new("Frame")
GridFrame.Parent = FilterBox
GridFrame.BackgroundTransparency = 1
GridFrame.Position = UDim2.new(0, 15, 0, 25)
GridFrame.Size = UDim2.new(0, 420, 0, 110)

local UIGrid = Instance.new("UIGridLayout")
UIGrid.Parent = GridFrame
UIGrid.CellPadding = UDim2.new(0, 20, 0, 4)
UIGrid.CellSize = UDim2.new(0, 190, 0, 18)
UIGrid.SortOrder = Enum.SortOrder.LayoutOrder

-- Sắp xếp thứ tự hạt giống theo đúng ảnh hiển thị
local SeedOrder = {
    "Common", "Secret",
    "Uncommon", "Prismatic",
    "Rare", "Divine",
    "Epic", "Exotic",
    "Legendary", "Mythic"
}

for index, seedName in ipairs(SeedOrder) do
    local ItemRow = Instance.new("Frame")
    ItemRow.BackgroundTransparency = 1
    ItemRow.LayoutOrder = index
    ItemRow.Parent = GridFrame
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Parent = ItemRow
    NameLabel.BackgroundTransparency = 1
    NameLabel.Size = UDim2.new(0, 120, 1, 0)
    NameLabel.Font = Enum.Font.GothamSemibold
    NameLabel.Text = seedName
    NameLabel.TextColor3 = Color3.fromRGB(150, 120, 200)
    NameLabel.TextSize = 13
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local CheckBox = Instance.new("TextButton")
    CheckBox.Parent = ItemRow
    CheckBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    CheckBox.BorderColor3 = Color3.fromRGB(140, 50, 255)
    CheckBox.Position = UDim2.new(1, -22, 0, 0)
    CheckBox.Size = UDim2.new(0, 18, 0, 18)
    CheckBox.Font = Enum.Font.GothamBold
    CheckBox.Text = ""
    CheckBox.TextColor3 = Color3.fromRGB(200, 100, 255)
    CheckBox.TextSize = 11
    Instance.new("UICorner", CheckBox).CornerRadius = UDim.new(0, 3)
    
    CheckBox.MouseButton1Click:Connect(function()
        Config.SelectedSeeds[seedName] = not Config.SelectedSeeds[seedName]
        if Config.SelectedSeeds[seedName] then
            CheckBox.Text = "X"
            CheckBox.BackgroundColor3 = Color3.fromRGB(60, 30, 90)
        else
            CheckBox.Text = ""
            CheckBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        end
    end)
end

-- Thêm ghi chú nhỏ bên dưới bảng lọc hạt giống giống hệt ảnh mẫu
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = FilterBox
InfoLabel.BackgroundTransparency = 1
InfoLabel.Position = UDim2.new(0, 15, 1, -18)
InfoLabel.Size = UDim2.new(0, 420, 0, 15)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Text = "Script will automatically stop rolling once a checked seed is found."
InfoLabel.TextColor3 = Color3.fromRGB(130, 80, 200)
InfoLabel.TextSize = 10
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

-- --- TÍNH NĂNG 3: NÚT BẬT/TẮT CHÍNH (ENABLE AUTO ROLL) ---
local ToggleBox = Instance.new("Frame")
ToggleBox.Parent = ContentFrame
ToggleBox.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
ToggleBox.BorderColor3 = Color3.fromRGB(140, 50, 255)
ToggleBox.Position = UDim2.new(0, 15, 0, 265)
ToggleBox.Size = UDim2.new(0, 450, 0, 40)

local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Parent = ToggleBox
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
ToggleLabel.Size = UDim2.new(0, 200, 1, 0)
ToggleLabel.Font = Enum.Font.GothamBold
ToggleLabel.Text = "Enable Auto Roll"
ToggleLabel.TextColor3 = Color3.fromRGB(180, 150, 220)
ToggleLabel.TextSize = 13
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

local SwitchBtn = Instance.new("TextButton")
SwitchBtn.Parent = ToggleBox
SwitchBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 50)
SwitchBtn.BorderColor3 = Color3.fromRGB(140, 50, 255)
SwitchBtn.Position = UDim2.new(1, -70, 0, 8)
SwitchBtn.Size = UDim2.new(0, 60, 0, 24)
SwitchBtn.Font = Enum.Font.GothamBold
SwitchBtn.Text = "Off"
SwitchBtn.TextColor3 = Color3.fromRGB(180, 150, 220)
SwitchBtn.TextSize = 12
Instance.new("UICorner", SwitchBtn).CornerRadius = UDim.new(0, 12)

-- --- TÍNH NĂNG 4: HIỂN THỊ TRẠNG THÁI (STATUS SYSTEM) ---
local StatusBox = Instance.new("Frame")
StatusBox.Parent = ContentFrame
StatusBox.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
StatusBox.BorderColor3 = Color3.fromRGB(140, 50, 255)
StatusBox.Position = UDim2.new(0, 15, 0, 312)
StatusBox.Size = UDim2.new(0, 450, 0, 35)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = StatusBox
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 10
