-- ==========================================
-- DRAGON MENU HUB - BUILD A BOAT / RING FARM
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DragonRingFarmHub"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Khung chính (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Giữ chuột để di chuyển menu

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Tiêu đề Menu
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 210, 0, 15)
Title.Size = UDim2.new(0, 380, 0, 30)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Dragon Menu | Ring Farm Edition"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.TextSize = 24
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Sidebar (Thanh danh mục bên trái)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Sidebar.Position = UDim2.new(0, 10, 0, 10)
Sidebar.Size = UDim2.new(0, 180, 0, 380)
Sidebar.BorderSizePixel = 0

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 10)
SidebarCorner.Parent = Sidebar

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Sidebar
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local UIPadding = Instance.new("UIPadding")
UIPadding.Parent = Sidebar
UIPadding.PaddingTop = UDim.new(0, 10)

-- Khung chứa nội dung (Content Frame)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 205, 0, 55)
ContentFrame.Size = UDim2.new(0, 385, 0, 335)

---------------------------------------------------------
-- BIẾN ĐIỀU KHIỂN LOGIC (SETTINGS VÀ STATE)
---------------------------------------------------------
local _G = _G or {}
_G.AutoFarm = false
_G.RandomSpeed = false
_G.BaseDelay = 2 -- Thời gian chờ gốc (giây) giữa các vòng

---------------------------------------------------------
-- HÀM TẠO TAB NÚT
---------------------------------------------------------
local function CreateTab(tabName, order)
	local TabButton = Instance.new("TextButton")
	TabButton.Name = tabName .. "Tab"
	TabButton.Parent = Sidebar
	TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	TabButton.Size = UDim2.new(0, 160, 0, 40)
	TabButton.Font = Enum.Font.SourceSansBold
	TabButton.Text = tabName
	TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	TabButton.TextSize = 16
	TabButton.LayoutOrder = order
	
	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0, 8)
	ButtonCorner.Parent = TabButton
	
	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color3.fromRGB(255, 0, 0)
	UIStroke.Thickness = 1.2
	UIStroke.Parent = TabButton

	local Page = Instance.new("ScrollingFrame")
	Page.Name = tabName .. "Page"
	Page.Parent = ContentFrame
	Page.Size = UDim2.new(1, 0, 1, 0)
	Page.BackgroundTransparency = 1
	Page.Visible = (order == 1)
	Page.ScrollBarThickness = 4
	Page.CanvasSize = UDim2.new(0, 0, 2, 0)

	local PageLayout = Instance.new("UIListLayout")
	PageLayout.Parent = Page
	PageLayout.Padding = UDim.new(0, 12)

	TabButton.MouseButton1Click:Connect(function()
		for _, child in pairs(ContentFrame:GetChildren()) do
			if child:IsA("ScrollingFrame") then child.Visible = false end
		end
		Page.Visible = true
	end)

	return Page
end

-- Khởi tạo các Tab cần thiết
local FarmPage = CreateTab("Auto Farm", 1)
local TeleportPage = CreateTab("Teleports", 2)
local SettingsPage = CreateTab("Settings", 3)

---------------------------------------------------------
-- HÀM TẠO CÁC THÀNH PHẦN GIAO DIỆN (TOGGLE / SLIDER)
---------------------------------------------------------
local function AddToggle(parentPage, text, callback)
	local ToggleFrame = Instance.new("Frame")
	ToggleFrame.Size = UDim2.new(0, 360, 0, 40)
	ToggleFrame.BackgroundTransparency = 1
	ToggleFrame.Parent = parentPage

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0, 240, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.SourceSansSemibold
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(230, 230, 230)
	Label.TextSize = 18
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = ToggleFrame

	local Switch = Instance.new("TextButton")
	Switch.Size = UDim2.new(0, 45, 0, 24)
	Switch.Position = UDim2.new(1, -55, 0.5, -12)
	Switch.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Switch.Text = ""
	Switch.Parent = ToggleFrame
	
	local SwitchCorner = Instance.new("UICorner")
	SwitchCorner.CornerRadius = UDim.new(1, 0)
	SwitchCorner.Parent = Switch
	
	local SwitchStroke = Instance.new("UIStroke")
	SwitchStroke.Color = Color3.fromRGB(255, 0, 0)
	SwitchStroke.Parent = Switch

	local toggled = false
	Switch.MouseButton1Click:Connect(function()
		toggled = not toggled
		Switch.BackgroundColor3 = toggled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(30, 30, 30)
		callback(toggled)
	end)
end

local function AddSlider(parentPage, text, min, max, default, callback)
	local SliderFrame = Instance.new("Frame")
	SliderFrame.Size = UDim2.new(0, 360, 0, 50)
	SliderFrame.BackgroundTransparency = 1
	SliderFrame.Parent = parentPage

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0, 200, 0, 20)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.SourceSans
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(200, 200, 200)
	Label.TextSize = 16
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = SliderFrame

	local ValueLabel = Instance.new("TextLabel")
	ValueLabel.Size = UDim2.new(0, 50, 0, 20)
	ValueLabel.Position = UDim2.new(1, -60, 0, 0)
	ValueLabel.BackgroundTransparency = 1
	ValueLabel.Font = Enum.Font.SourceSansBold
	ValueLabel.Text = tostring(default)
	ValueLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
	ValueLabel.TextSize = 16
	ValueLabel.Parent = SliderFrame

	local SliderBar = Instance.new("TextButton")
	SliderBar.Size = UDim2.new(0, 340, 0, 6)
	SliderBar.Position = UDim2.new(0, 10, 0, 30)
	SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	SliderBar.Text = ""
	SliderBar.Parent = SliderFrame

	local SliderFill = Instance.new("Frame")
	SliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
	SliderFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	SliderFill.BorderSizePixel = 0
	SliderFill.Parent = SliderBar

	local UserInputService = game:GetService("UserInputService")
	local dragging = false

	SliderBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
	end)

	UserInputService.Input
