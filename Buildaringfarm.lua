-- Tạo ScreenGui chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DragonMenuGui"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Khung chính (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Nền tối
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Cho phép kéo di chuyển menu

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Tiêu đề Menu (Title)
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 210, 0, 15)
Title.Size = UDim2.new(0, 380, 0, 30)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Dragon Menu | Universal - v5.9"
Title.TextColor3 = Color3.fromRGB(255, 0, 0) -- Màu chữ đỏ
Title.TextSize = 24
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Thanh menu bên cạnh (Sidebar Container)
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

-- Khung chứa nội dung bên phải (Content Frame)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
ContentFrame.Position = UDim2.new(0, 205, 0, 55)
ContentFrame.Size = UDim2.new(0, 385, 0, 335)
ContentFrame.BackgroundTransparency = 1 -- Ẩn nền chính để các tab tự hiển thị

---------------------------------------------------------
-- HÀM TẠO NÚT MENU (TABS)
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
	
	-- Viền đỏ cho nút giống trong hình
	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color3.fromRGB(255, 0, 0)
	UIStroke.Thickness = 1.2
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Parent = TabButton

	-- Tạo trang nội dung riêng cho Tab này
	local Page = Instance.new("ScrollingFrame")
	Page.Name = tabName .. "Page"
	Page.Parent = ContentFrame
	Page.Size = UDim2.new(1, 0, 1, 0)
	Page.BackgroundTransparency = 1
	Page.Visible = (order == 1) -- Chỉ hiển thị trang đầu tiên mặc định
	Page.ScrollBarThickness = 4
	Page.CanvasSize = UDim2.new(0, 0, 2, 0) -- Cuộn xuống nếu nhiều tính năng

	local PageLayout = Instance.new("UIListLayout")
	PageLayout.Parent = Page
	PageLayout.Padding = UDim.new(0, 10)

	-- Sự kiện chuyển đổi Tab khi Click
	TabButton.MouseButton1Click:Connect(function()
		for _, child in pairs(ContentFrame:GetChildren()) do
			if child:IsA("ScrollingFrame") then
				child.Visible = false
			end
		end
		Page.Visible = true
	end)

	return Page
end

---------------------------------------------------------
-- KHỞI TẠO CÁC TAB (GIỐNG TRONG HÌNH)
---------------------------------------------------------
local MainPage = CreateTab("Main", 1)
local PlayerPage = CreateTab("Player", 2)
local VisualsPage = CreateTab("Visuals", 3)
local ServerPage = CreateTab("Server", 4)
local SettingsPage = CreateTab("Settings", 5)

---------------------------------------------------------
-- HÀM TẠO TÍNH NĂNG (TOGGLES / SLIDERS MẪU)
---------------------------------------------------------
-- 1. Tạo Nút Bật/Tắt (Toggle)
local function AddToggle(parentPage, text, callback)
	local ToggleFrame = Instance.new("Frame")
	ToggleFrame.Size = UDim2.new(0, 360, 0, 40)
	ToggleFrame.BackgroundTransparency = 1
	ToggleFrame.Parent = parentPage

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0, 200, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.SourceSans
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextSize = 18
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = ToggleFrame

	local Switch = Instance.new("TextButton")
	Switch.Size = UDim2.new(0, 40, 0, 24)
	Switch.Position = UDim2.new(1, -50, 0.5, -12)
	Switch.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
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
		if toggled then
			Switch.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Đỏ khi bật
		else
			Switch.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Tối khi tắt
		end
		callback(toggled)
	end)
end

-- 2. Tạo Thanh Trượt (Slider)
local function AddSlider(parentPage, text, min, max, default, callback)
	local SliderFrame = Instance.new("Frame")
	SliderFrame.Size = UDim2.new(0, 360, 0, 50)
	SliderFrame.BackgroundTransparency = 1
	SliderFrame.Parent = parentPage

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0, 150, 0, 20)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.SourceSans
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
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

	-- Thanh trượt chính
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

	-- Thêm chức năng kéo cho Slider (Cơ bản)
	local UserInputService = game:GetService("UserInputService")
	local dragging = false

	SliderBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local mousePos = UserInputService:GetMouseLocation()
			local relativeX = mousePos.X - SliderBar.AbsolutePosition.X
			local percentage = math.clamp(relativeX / SliderBar.AbsoluteSize.X, 0, 1)
			
			SliderFill.Size = UDim2.new(percentage
