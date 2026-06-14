-- [[ AIRFLOW UI FIXED — GROW A GARDEN 2 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== CẤU HÌNH TRẠNG THÁI ====================
local Config = {
    Automation = {
        AutoBuy = false,
        SelectedSeed = "Carrot",
        AutoSell = false,
    },
    Character = {
        SpeedEnabled = false,
        WalkSpeed = 16
    },
    ESP = {
        Enabled = false,
        MaxDistance = 600,
        Color = Color3.fromRGB(168, 85, 247)
    }
}

local SeedList = {"Carrot", "Tomato", "Pumpkin", "Watermelon", "Berry", "Wheat"}
local MenuVisible = true

-- ==================== KHỞI TẠO KHUNG MENU CHÍNH ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AirflowGardenHub_Fixed"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 540, 0, 350)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 16, 20) 
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 40, 55)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Sidebar bên trái (Chứa Icon biểu trưng)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 45, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(13, 11, 15)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

-- Khung cuộn nội dung chính bên phải
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -55, 1, -20)
ContentScroll.Position = UDim2.new(0, 50, 0, 10)
ContentScroll.BackgroundTransparency = 1
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 550)
ContentScroll.ScrollBarThickness = 2
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(168, 85, 247)
ContentScroll.Parent = MainFrame

-- CHIA 2 CỘT (TRÁI & PHẢI) ĐỂ CÁC CARD CO GIÃN ĐÚNG CƠ CHẾ
local LeftColumn = Instance.new("Frame")
LeftColumn.Size = UDim2.new(0, 235, 1, 0)
LeftColumn.Position = UDim2.new(0, 5, 0, 0)
LeftColumn.BackgroundTransparency = 1
LeftColumn.Parent = ContentScroll

local LeftLayout = Instance.new("UIListLayout")
LeftLayout.Padding = UDim.new(0, 10)
LeftLayout.Parent = LeftColumn

local RightColumn = Instance.new("Frame")
RightColumn.Size = UDim2.new(0, 235, 1, 0)
RightColumn.Position = UDim2.new(0, 250, 0, 0)
RightColumn.BackgroundTransparency = 1
RightColumn.Parent = ContentScroll

local RightLayout = Instance.new("UIListLayout")
RightLayout.Padding = UDim.new(0, 10)
RightLayout.Parent = RightColumn

-- ==================== HÀM TẠO KHUNG CO GIÃN HOÀN CHỈNH ====================
local function CreateCollapsibleCard(parentColumn, titleText, expandedHeight)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, expandedHeight) -- Chiều cao khi mở rộng công cụ
    Card.BackgroundColor3 = Color3.fromRGB(24, 22, 28)
    Card.BorderSizePixel = 0
    Card.ClipsDescendants = true
    Card.Parent = parentColumn
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Color3.fromRGB(38, 34, 44)
    CardStroke.Parent = Card

    -- Header của Card
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 32)
    Header.BackgroundColor3 = Color3.fromRGB(30, 27, 35)
    Header.BorderSizePixel = 0
    Header.Parent = Card

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.7, 0, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Color3.fromRGB(200, 190, 210)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local ArrowBtn = Instance.new("TextButton")
    ArrowBtn.Size = UDim2.new(0, 30, 0, 32)
    ArrowBtn.Position = UDim2.new(1, -30, 0, 0)
    ArrowBtn.BackgroundTransparency = 1
    ArrowBtn.Text = "▲"
    ArrowBtn.TextColor3 = Color3.fromRGB(168, 85, 247)
    ArrowBtn.Font = Enum.Font.SourceSansBold
    ArrowBtn.TextSize = 11
    ArrowBtn.Parent = Header

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -16, 1, -40)
    Container.Position = UDim2.new(0, 8, 0, 38)
    Container.BackgroundTransparency = 1
    Container.Parent = Card

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 5)
    ListLayout.Parent = Container

    -- CLICK XỬ LÝ CO GIÃN THẬT (Đã fix triệt để lỗi ép size)
    local IsExpanded = true
    ArrowBtn.MouseButton1Click:Connect(function()
        IsExpanded = not IsExpanded
        if IsExpanded then
            Card.Size = UDim2.new(1, 0, 0, expandedHeight)
            ArrowBtn.Text = "▲"
        else
            Card.Size = UDim2.new(1, 0, 0, 32) -- Thu nhỏ sát nút chỉ để lại thanh Header tiêu đề
            ArrowBtn.Text = "▼"
        end
    end)

    return Container
end

-- ==================== THÀNH PHẦN ĐIỀU KHIỂN BÊN TRONG CARD ====================
local function AddToggle(cardContainer, text, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 28)
    Row.BackgroundTransparency = 1
    Row.Parent = cardContainer

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(170, 165, 175)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 34, 0, 16)
    Switch.Position = UDim2.new(1, -36, 0, 6)
    Switch.Text = ""
    Switch.Parent = Row
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

    local State = default
    local function update()
        Switch.BackgroundColor3 = State and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(55, 50, 65)
    end
    update()

    Switch.MouseButton1Click:Connect(function()
        State = not State
        update()
        callback(State)
    end)
end

local function AddDropdown(cardContainer, text, list, default, callback)
    local DropdownRow = Instance.new("Frame")
    DropdownRow.Size = UDim2.new(1, 0, 0, 28)
    DropdownRow.BackgroundTransparency = 1
    DropdownRow.Parent = cardContainer

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(170, 165, 175)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = DropdownRow

    local MainBtn = Instance.new("TextButton")
    MainBtn.Size = UDim2.new(0, 100, 0, 22)
    MainBtn.Position = UDim2.new(1, -100, 0, 3)
    MainBtn.BackgroundColor3 = Color3.fromRGB(35, 32, 42)
    MainBtn.Text = default .. " ▼"
    MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255) -- Chữ màu trắng kích hoạt
    MainBtn.Font = Enum.Font.SourceSansSemibold
    MainBtn.TextSize = 12
    MainBtn.Parent = DropdownRow
    Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 4)

    -- Tạo bảng chọn hạt giống bung nhỏ kế bên nút bấm
    local ListFrame = Instance.new("Frame")
    ListFrame.Size = UDim2.new(0, 100, 0, #list * 22)
    ListFrame.Position = UDim2.new(1, -100, 0, 26)
    ListFrame.BackgroundColor3 = Color3.fromRGB(28, 25, 34)
    ListFrame.Visible = false
    ListFrame.ZIndex = 5
    ListFrame.Parent = DropdownRow
    Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", ListFrame).Color = Color3.fromRGB(50, 45, 60)

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Parent = ListFrame

    MainBtn.MouseButton1Click:Connect(function()
        ListFrame.Visible = not ListFrame.Visible
    end)

    for _, name in ipairs(list) do
        local ItemBtn = Instance.new("TextButton")
        ItemBtn.Size = UDim2.new(1, 0, 0, 22)
        ItemBtn.BackgroundTransparency = 1
        ItemBtn.Text = name
        ItemBtn.TextColor3 = (name == default) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 145, 155)
        ItemBtn.Font = Enum.Font.SourceSans
        ItemBtn.TextSize = 12
        ItemBtn.ZIndex = 6
        ItemBtn.Parent = ListFrame

        ItemBtn.MouseButton1Click:Connect(function()
            Config.Automation.SelectedSeed = name
            MainBtn.Text = name .. " ▼"
            ListFrame.Visible = false
            callback(name)
            
            -- Cập nhật màu trắng sáng cho hạt giống được chọn
            for _, b in ipairs(ListFrame:GetChildren()) do
                if b:IsA("TextButton") then
                    b.TextColor3 = (b.Text == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 145, 155)
                end
            end
        end)
    end
end

local function AddCardButton(cardContainer, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 24)
    Button.BackgroundColor3 = Color3.fromRGB(32, 29, 38)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(160, 155, 165)
    Button.Font = Enum.Font.SourceSansSemibold
    Button.TextSize = 12
    Button.Parent = cardContainer
    
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)
    local Stroke = Instance.new("UIStroke", Button)
    Stroke.Color = Color3.fromRGB(45, 40, 55)

    Button.MouseButton1Click:Connect(function()
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        callback()
        task.wait(0.15)
        Button.TextColor3 = Color3.fromRGB(160, 155, 165)
    end)
end

-- ==================== KHỞI TẠO CÁC HỘP PHÂN CHIA CARD (HÌNH KHOANH TRÒN) ====================

-- Cột trái: Hộp Auto Farm (Chiều cao mở rộng 110px)
local FarmCard = CreateCollapsibleCard(LeftColumn, "Auto Farm", 110)
AddToggle(FarmCard, "Auto Buy Seeds", Config.Automation.AutoBuy, function(s) Config.Automation.AutoBuy = s end)
AddDropdown(FarmCard, "Seed Type:", SeedList, Config.Automation.SelectedSeed, function(v) end)
AddToggle(FarmCard, "Auto Sell All Fruits", Config.Automation.AutoSell, function(s) Config.Automation.AutoSell = s end)

-- Cột phải: Hộp Teleports (Chiều cao mở rộng 195px)
local TeleportCard = CreateCollapsibleCard(RightColumn, "Teleports", 195)
local function TeleportTo(locationName)
    pcall(function()
        local targetPart = workspace:FindFirstChild(locationName, true) or workspace.Plots:FindFirstChild(LocalPlayer.Name.."'s Plot", true)
        if targetPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
        end
    end)
end
AddCardButton(TeleportCard, "My Garden", function() TeleportTo("Plot") end)
AddCardButton(TeleportCard, "Seeds Shop", function() TeleportTo("SeedShop") end)
AddCardButton(TeleportCard, "Gears Station", function() TeleportTo("GearShop") end)
AddCardButton(TeleportCard, "Props & Items", function() TeleportTo("Props") end)
AddCardButton(TeleportCard, "Guilds Area", function() TeleportTo("Guilds") end)
AddCardButton(TeleportCard, "Sell Merchant", function() TeleportTo("SellPart") end)

-- Cột trái phụ: Tiện ích bổ sung
local UtilsCard = CreateCollapsibleCard(LeftColumn, "Utilities", 90)
AddToggle(UtilsCard, "Hack Tốc Độ Chạy (60)", Config.Character.SpeedEnabled, function(s) Config.Character.SpeedEnabled = s end)
AddToggle(UtilsCard, "Bật Định Vị Người Chơi", Config.ESP.Enabled, function(s) Config.ESP.Enabled = s if not s then for _, v in ipairs(workspace:GetDescendants()) do if v:IsA("Highlight") and v.Name == "AirflowEsp" then v:Destroy() end end end end)

-- ==================== VÒNG LẶP ENGINE CHẠY TỰ ĐỘNG ====================
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightControl then
        MenuVisible = not MenuVisible
        MainFrame.Visible = MenuVisible
    end
end)

task.spawn(function()
    while task.wait(1) do
        if Config.Automation.AutoBuy then
            pcall(function()
                local buyRemote = ReplicatedStorage:FindFirstChild("BuyItem", true) or ReplicatedStorage:FindFirstChild("BuySeed", true)
                if buyRemote and buyRemote:IsA("RemoteEvent") then
                    buyRemote:FireServer(Config.Automation.SelectedSeed, 1)
                end
            end)
        end

        if Config.Automation.AutoSell then
            pcall(function()
                local sellRemote = ReplicatedStorage:FindFirstChild("SellEverything", true) or ReplicatedStorage:FindFirstChild("Sell", true)
                if sellRemote and sellRemote:IsA("RemoteEvent") then
                    sellRemote:FireServer()
                else
                    local sellPart = workspace:FindFirstChild("SellPart", true) or workspace:FindFirstChild("SellStation", true)
                    if sellPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, sellPart, 0)
                        task.wait(0.05)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, sellPart, 1)
                    end
                end
            end)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if Config.Character.SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 60
    end

    if Config.ESP.Enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                local dist = (p.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                local oldHl = p.Character:FindFirstChild("AirflowEsp")

                if dist > Config.ESP.MaxDistance then if oldHl then oldHl:Destroy() end continue end

                local hl = oldHl or Instance.new("Highlight")
                hl.Name = "AirflowEsp"
                hl.FillColor = Config.ESP.Color
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.5
                hl.Parent = p.Character
            end
        end
    end
end)
