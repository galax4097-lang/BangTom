-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Trạng thái của công cụ xóa
local isEnabled = false
local connection = nil

-- Tạo giao diện (ScreenGui & Button)
local screenGui = script.Parent
screenGui.ResetOnSpawn = false

-- Nút bật/tắt menu
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 160, 0, 50)
toggleButton.Position = UDim2.new(0, 20, 0, 20)
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 16
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "Xóa khối: TẮT"
toggleButton.Parent = screenGui

-- Bo góc nút bấm cho đẹp
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = toggleButton

-- Hàm xử lý khi click vào khối để xóa
local function onClickDelete()
	if not isEnabled then return end
	
	-- Lấy đối tượng mà chuột đang trỏ vào
	local targetPart = mouse.Target
	
	-- Kiểm tra xem có phải là Part hợp lệ không (tránh xóa nhầm Terrain hoặc nhân vật Player)
	if targetPart and targetPart:IsA("BasePart") then
		-- Kiểm tra không xóa các bộ phận của nhân vật chơi
		if not targetPart:IsDescendantOf(player.Character) then
			targetPart:Destroy() -- Xóa khối khỏi map
		end
	end
end

-- Hàm bật/tắt tính năng xóa khối
local function toggleDeleteTool()
	isEnabled = not isEnabled
	
	if isEnabled then
		toggleButton.Text = "Xóa khối: BẬT"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 127) -- Đổi sang màu xanh
		
		-- Lắng nghe sự kiện click chuột trái
		connection = mouse.Button1Down:Connect(onClickDelete)
	else
		toggleButton.Text = "Xóa khối: TẮT"
		toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Trở về màu tối
		
		-- Ngắt kết nối sự kiện khi tắt
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end
end

-- Gắn sự kiện khi bấm nút Menu
toggleButton.MouseButton1Click:Connect(toggleDeleteTool)
