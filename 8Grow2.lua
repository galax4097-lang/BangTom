-- [[ AIRFLOW UI ULTIMATE UPDATE — GROW A GARDEN 2 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== DANH SÁCH 24 HẠT GIỐNG CHUẨN (TỪ ẢNH CHỤP) ====================
local SeedList = {
    "Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Apple", 
    "Bamboo", "Corn", "Cactus", "Pineapple", "Mushroom", "Green Bean", 
    "Banana", "Grape", "Coconut", "Mango", "Dragon Fruit", "Acorn", 
    "Cherry", "Sunflower", "Venus Fly Trap", "Pomegranate", "Poison Apple", "Moon Bloom"
}

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

local MenuVisible = true
local SpeedConnection = nil

-- ==================== KHỞI TẠO KHUNG MENU CHÍNH ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AirflowGardenHub_V3"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 540, 0, 360)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 16, 20) 
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(45, 40, 55)
MainStroke.Thickness = 1

-- Sidebar trang trí bên trái
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
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 500)
ContentScroll.ScrollBarThickness = 3
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(168, 85, 247)
ContentScroll.Parent = MainFrame

-- CHIA 2 CỘT CHỐNG LỖI ĐÈ KÍCH THƯỚC UI
local LeftColumn = Instance.new("Frame")
LeftColumn.Size = UDim2.new(0, 235, 1, 0)
LeftColumn.BackgroundTransparency = 1
LeftColumn.Parent = ContentScroll

local LeftLayout = Instance.new("UIListLayout")
LeftLayout.Padding = UDim.new(0, 10)
LeftLayout.Parent = LeftColumn

local RightColumn = Instance.new("Frame")
RightColumn.Size = UDim2.new(0, 235, 1, 0)
RightColumn.Position = UDim2.new(0, 245, 0, 0)
RightColumn.BackgroundTransparency = 1
RightColumn.Parent = ContentScroll

local RightLayout = Instance.new("UIListLayout")
RightLayout.Padding = UDim.new(0, 10)
RightLayout.Parent = RightColumn

-- ==================== HÀM TẠO KHUNG CARD CO GIÃN + CUỘN TRANG WEB ====================
local function CreateCollapsibleCard(parentColumn, titleText, expandedHeight)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, expandedHeight)
    Card.BackgroundColor3 = Color3.fromRGB(24, 22, 28)
    Card.BorderSizePixel = 0
    Card.ClipsDescendants = true
    Card.Parent = parentColumn
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Card).Color = Color3.fromRGB(38, 34, 44)

    -- Header
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

    -- Tích hợp tính năng cuộn chuột như trang web bên trong mỗi Card
    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, -10, 1, -40)
    Container.Position = UDim2.new(0, 5, 0, 38)
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.ScrollBarThickness = 2
    Container.ScrollBarImageColor3 = Color3.fromRGB(168, 85, 247)
    Container.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.Parent = Card

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 5)
    ListLayout.Parent = Container

    local IsExpanded = true
    ArrowBtn.MouseButton1Click:Connect(function()
        IsExpanded = not IsExpanded
        if IsExpanded then
            Card.Size = UDim2.new(1, 0, 0, expandedHeight)
            ArrowBtn.Text = "▲"
        else
            Card.Size = UDim2.new(1, 0, 0, 32)
            ArrowBtn.Text = "▼"
        end
    end)

    return Container
end

-- ==================== CÁC THÀNH PHẦN ĐIỀU KHIỂN CHI TIẾT ====================
local function AddToggle(cardContainer, text, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -5, 0, 28)
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
    DropdownRow.Size = UDim2.new(1, -5, 0, 28)
    DropdownRow.BackgroundTransparency = 1
    DropdownRow.Parent = cardContainer

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.45, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(170, 165, 175)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = DropdownRow

    local MainBtn = Instance.new("TextButton")
    MainBtn.Size = UDim2.new(0, 115, 0, 22)
    MainBtn.Position = UDim2.new(1, -115, 0, 3)
    MainBtn.BackgroundColor3 = Color3.fromRGB(35, 32, 42)
    MainBtn.Text = default .. " ▼"
    MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainBtn.Font = Enum.Font.SourceSansSemibold
    MainBtn.TextSize = 11
    MainBtn.Parent = DropdownRow
    Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 4)

    -- Bảng chọn hạt giống có lướt chuột chống tràn
    local ListFrame = Instance.new("ScrollingFrame")
    ListFrame.Size = UDim2.new(0, 115, 0, 120) -- Giới hạn chiều cao vừa vặn 5 mục
    ListFrame.Position = UDim2.new(1, -115, 0, 26)
    ListFrame.BackgroundColor3 = Color3.fromRGB(28, 25, 34)
    ListFrame.Visible = false
    ListFrame.ZIndex = 10
    ListFrame.ScrollBarThickness = 2
    ListFrame.ScrollBarImageColor3 = Color3.fromRGB(168, 85, 247)
    ListFrame.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
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
        ItemBtn.Size = UDim2.new(1, -4, 0, 22)
        ItemBtn.BackgroundTransparency = 1
        ItemBtn.Text = name
        ItemBtn.TextColor3 = (name == default) and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(160, 155, 165)
        ItemBtn.Font = Enum.Font.SourceSans
        ItemBtn.TextSize = 11
        ItemBtn.ZIndex = 11
        ItemBtn.Parent = ListFrame

        ItemBtn.MouseButton1Click:Connect(function()
            Config.Automation.SelectedSeed = name
            MainBtn.Text = name .. " ▼"
            ListFrame.Visible = false
            callback(name)
            
            for _, b in ipairs(ListFrame:GetChildren()) do
                if b:IsA("TextButton") then
                    b.TextColor3 = (b.Text == name) and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(160, 155, 165)
                end
            end
        end)
    end
end

local function AddTextBox(cardContainer, text, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -5, 0, 28)
    Row.BackgroundTransparency = 1
    Row.Parent = cardContainer

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(170, 165, 175)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0, 55, 0, 20)
    Box.Position = UDim2.new(1, -57, 0, 4)
    Box.BackgroundColor3 = Color3.fromRGB(35, 32, 42)
    Box.Text = tostring(default)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.SourceSansBold
    Box.TextSize = 12
    Box.Parent = Row
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", Box).Color = Color3.fromRGB(50, 45, 60)

    Box.FocusLost:Connect(function()
        local num = tonumber(Box.Text) or default
        callback(num)
    end)
end

local function AddCardButton(cardContainer, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -5, 0, 26)
    Button.BackgroundColor3 = Color3.fromRGB(32, 29, 38)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(160, 155, 165)
    Button.Font = Enum.Font.SourceSansSemibold
    Button.TextSize = 12
    Button.Parent = cardContainer
    
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", Button).Color = Color3.fromRGB(45, 40, 55)

    Button.MouseButton1Click:Connect(function()
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        callback()
        task.wait(0.1)
        Button.TextColor3 = Color3.fromRGB(160, 155, 165)
    end)
end

-- ==================== KHỞI TẠO CÁC CARD TÍNH NĂNG CHUẨN XỊN ====================

-- Hộp Farm tự động (Chiều cao mở rộng cố định để lướt)
local FarmCard = CreateCollapsibleCard(LeftColumn, "Auto Farm", 115)
AddToggle(FarmCard, "Auto Buy Seeds", Config.Automation.AutoBuy, function(s) Config.Automation.AutoBuy = s end)
AddDropdown(FarmCard, "Seed Selected:", SeedList, Config.Automation.SelectedSeed, function(v) end)
AddToggle(FarmCard, "Auto Sell All Fruits", Config.Automation.AutoSell, function(s) Config.Automation.AutoSell = s end)

-- Hộp Dịch chuyển chuẩn hóa (Đã loại bỏ Guilds, sửa lỗi quét tọa độ)
local TeleportCard = CreateCollapsibleCard(RightColumn, "Teleports Hub", 150)

local function SmartTeleport(locationKeyword)
    pcall(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local targetPart = nil
        local keyword = string.lower(locationKeyword)
        
        if keyword == "plot" then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == LocalPlayer.Name.."'s Plot" or (v.Name == "Plot" and v:FindFirstChild("Owner") and v.Owner.Value == LocalPlayer.Name) then
                    targetPart = v:FindFirstChild("Base") or v:FindFirstChildOfClass("BasePart") or v
                    break
                end
            end
        else
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("Model") then
                    local name = string.lower(v.Name)
                    if string.find(name, keyword) then
                        targetPart = v:IsA("BasePart") and v or v:FindFirstChildOfClass("BasePart") or v
                        break
                    end
                end
            end
        end
        
        if targetPart then
            hrp.CFrame = targetPart.CFrame + Vector3.new(0, 4, 0)
        end
    end)
end

AddCardButton(TeleportCard, "My Garden (Plot)", function() SmartTeleport("plot") end)
AddCardButton(TeleportCard, "Seeds Shop", function() SmartTeleport("seed") end)
AddCardButton(TeleportCard, "Gears Station", function() SmartTeleport("gear") end)
AddCardButton(TeleportCard, "Props & Items", function() SmartTeleport("prop") end)
AddCardButton(TeleportCard, "Sell Merchant", function() SmartTeleport("sell") end)

-- Hộp Tiện ích nâng cao (Sửa lỗi Tốc độ)
local UtilsCard = CreateCollapsibleCard(LeftColumn, "Utilities", 95)
AddToggle(UtilsCard, "Enable Custom Speed", Config.Character.SpeedEnabled, function(s) 
    Config.Character.SpeedEnabled = s 
end)
AddTextBox(UtilsCard, "Speed Value:", Config.Character.WalkSpeed, function(v) 
    Config.Character.WalkSpeed = v 
end)
AddToggle(UtilsCard, "Player ESP Locator", Config.ESP.Enabled, function(s) 
    Config.ESP.Enabled = s 
    if not s then 
        for _, v in ipairs(workspace:GetDescendants()) do 
            if v:IsA("Highlight") and v.Name == "AirflowEsp" then v:Destroy() end 
        end 
    end 
end)

-- ==================== TOÀN BỘ ENGINE CHẠY NGẦM KHÔNG LỖI ====================

-- Đóng mở bảng bằng phím Insert hoặc Right Control
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightControl then
        MenuVisible = not MenuVisible
        MainFrame.Visible = MenuVisible
    end
end)

-- Vòng lặp tối ưu cơ chế Auto Mua & Bán (Quét sâu các Remote ẩn của game)
task.spawn(function()
    while task.wait(0.8) do
        if Config.Automation.AutoBuy then
            pcall(function()
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local rName = string.lower(remote.Name)
                        if string.find(rName, "buy") or string.find(rName, "purchase") or string.find(rName, "seed") then
                            remote:FireServer(Config.Automation.SelectedSeed, 1)
                            remote:FireServer(Config.Automation.SelectedSeed)
                        end
                    end
                end
            end)
        end

        if Config.Automation.AutoSell then
            pcall(function()
                local sold = false
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") and (string.find(string.lower(remote.Name), "sell")) then
                        remote:FireServer()
                        sold = true
                    end
                end
                if not sold then
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v:IsA("BasePart") and string.find(string.lower(v.Name), "sell") then
                            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                firetouchinterest(hrp, v, 0)
                                task.wait(0.02)
                                firetouchinterest(hrp, v, 1)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Khóa tốc độ chạy tùy ý (Bypass chống anti-cheat cơ bản)
RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Config.Character.SpeedEnabled then
                hum.WalkSpeed = Config.Character.WalkSpeed
                if not SpeedConnection then
                    SpeedConnection = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                        if Config.Character.SpeedEnabled then
                            hum.WalkSpeed = Config.Character.WalkSpeed
                        end
                    end)
                end
            else
                if SpeedConnection then
                    SpeedConnection:Disconnect()
                    SpeedConnection = nil
                end
            end
        end
    end)

    -- Engine xử lý ESP định vị người chơi
    if Config.ESP.Enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") then
                local dist = (p.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                local oldHl = p.Character:FindFirstChild("AirflowEsp")

                if dist > Config.ESP.MaxDistance then 
                    if oldHl then oldHl:Destroy() end 
                    continue 
                end

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
