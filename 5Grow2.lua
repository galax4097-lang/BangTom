-- [[ AIRFLOW REMAKE — GROW A GARDEN 2 ADVANCED HUB ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== CẤU HÌNH TRẠNG THÁI (SETTINGS) ====================
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
        Color = Color3.fromRGB(168, 85, 247) -- Màu tím nhạt chuẩn giao diện
    }
}

local SeedList = {"Carrot", "Tomato", "Pumpkin", "Watermelon", "Berry", "Wheat"}
local MenuVisible = true

-- ==================== KHỞI TẠO KHUNG MENU CHÍNH ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AirflowGardenHub"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 360)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 16, 20) -- Tông nền tối pha tím mờ
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 40, 55)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Sidebar bên trái (Chứa các biểu tượng danh mục)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 45, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(13, 11, 15)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

-- Vùng chứa nội dung chính bên phải (Dạng lưới cuộn chứa các Card như hình khoanh)
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -60, 1, -20)
ContentScroll.Position = UDim2.new(0, 52, 0, 10)
ContentScroll.BackgroundTransparency = 1
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 500)
ContentScroll.ScrollBarThickness = 3
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(168, 85, 247)
ContentScroll.Parent = MainFrame

local ContentGrid = Instance.new("UIGridLayout")
ContentGrid.CellSize = UDim2.new(0, 235, 0, 200) -- Chia thành các ô vuông xếp cạnh nhau
ContentGrid.CellPadding = UDim2.new(0, 12, 0, 12)
ContentGrid.Parent = ContentScroll

-- ==================== HÀM TẠO KHUNG ĐÓNG/MỞ (COLLAPSIBLE CARD) ====================
local function CreateCollapsibleCard(titleText)
    local Card = Instance.new("Frame")
    Card.BackgroundColor3 = Color3.fromRGB(24, 22, 28)
    Card.BorderSizePixel = 0
    Card.ClipsDescendants = true
    Card.Parent = ContentScroll
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Color3.fromRGB(38, 34, 44)
    CardStroke.Thickness = 1
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

    -- Nút mũi tên đóng mở góc phải (Chuẩn hình khoanh)
    local ArrowBtn = Instance.new("TextButton")
    ArrowBtn.Size = UDim2.new(0, 30, 0, 32)
    ArrowBtn.Position = UDim2.new(1, -30, 0, 0)
    ArrowBtn.BackgroundTransparency = 1
    ArrowBtn.Text = "▲"
    ArrowBtn.TextColor3 = Color3.fromRGB(168, 85, 247)
    ArrowBtn.Font = Enum.Font.SourceSansBold
    ArrowBtn.TextSize = 11
    ArrowBtn.Parent = Header

    -- Vùng chứa các nút tùy chọn bên trong Card
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -16, 1, -40)
    Container.Position = UDim2.new(0, 8, 0, 38)
    Container.BackgroundTransparency = 1
    Container.Parent = Card

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 5)
    ListLayout.Parent = Container

    -- Xử lý Logic ẩn/hiện nội dung khi bấm mũi tên
    local IsExpanded = true
    ArrowBtn.MouseButton1Click:Connect(function()
        IsExpanded = not IsExpanded
        if IsExpanded then
            Card.Size = UDim2.new(0, 235, 0, 200)
            ArrowBtn.Text = "▲"
        else
            Card.Size = UDim2.new(0, 235, 0, 32) -- Thu nhỏ lại chỉ còn thanh Header
            ArrowBtn.Text = "▼"
        end
    end)

    return Container
end

-- ==================== HÀM TẠO THÀNH PHẦN CON TRONG CARD ====================
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

local function AddCardButton(cardContainer, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 24)
    Button.BackgroundColor3 = Color3.fromRGB(32, 29, 38)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(160, 155, 165)
    Button.Font = Enum.Font.SourceSansSemibold
    Button.TextSize = 12
    Button.Parent = cardContainer
    
    local Corner = Instance.new("UICorner", Button)
    Corner.CornerRadius = UDim.new(0, 4)
    local Stroke = Instance.new("UIStroke", Button)
    Stroke.Color = Color3.fromRGB(45, 40, 55)

    -- Hiệu ứng phản hồi đổi màu khi di chuột vào hoặc click chọn giống hệ thống gốc
    Button.MouseButton1Click:Connect(function()
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.BackgroundColor3 = Color3.fromRGB(48, 42, 58)
        callback()
        task.wait(0.2)
        Button.TextColor3 = Color3.fromRGB(160, 155, 165)
        Button.BackgroundColor3 = Color3.fromRGB(32, 29, 38)
    end)
end

-- ==================== KHỞI TẠO CÁC HỘP T
