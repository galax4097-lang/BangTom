-- Khởi tạo hoặc xóa menu cũ nếu đã chạy trước đó để tránh lỗi trùng giao diện
local oldGui = game.CoreGui:FindFirstChild("BuildARingFarmCustom")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BuildARingFarmCustom"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

---------------------------------------------------------------------------
-- 1. KHUNG CHÍNH CỦA MENU (MAIN FRAME)
---------------------------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 360)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(45, 45, 50)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

---------------------------------------------------------------------------
-- 2. THANH DANH MỤC BÊN TRÁI (SIDEBAR)
---------------------------------------------------------------------------
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 150, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 10)
SideCorner.Parent = SideBar

local GameTitle = Instance.new("TextLabel")
GameTitle.Size = UDim2.new(1, -10, 0, 40)
GameTitle.Position = UDim2.new(0, 12, 0, 10)
GameTitle.BackgroundTransparency = 1
GameTitle.Text = "Build A Ring Farm"
GameTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
GameTitle.TextSize = 14
GameTitle.Font = Enum.Font.SourceSansBold
GameTitle.TextXAlignment = Enum.TextXAlignment.Left
GameTitle.Parent = SideBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -10, 0, 15)
SubTitle.Position = UDim2.new(0, 12, 0, 25)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Created by Gemini [NO KEY]"
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitle.TextSize = 11
SubTitle.Font = Enum.Font.SourceSans
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = SideBar

local TabButtonsContainer = Instance.new("Frame")
TabButtonsContainer.Size = UDim2.new(1, 0, 1, -60)
TabButtonsContainer.Position = UDim2.new(0, 0, 0, 55)
TabButtonsContainer.BackgroundTransparency = 1
TabButtonsContainer.Parent = SideBar

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = TabButtonsContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

---------------------------------------------------------------------------
-- 3. NÚT ĐÓNG MENU (NÚT X ĐỎ)
---------------------------------------------------------------------------
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 26, 0, 26)
CloseButton.Position = UDim2.new(1, -36, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(210, 50, 50)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 14
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

---------------------------------------------------------------------------
-- 4. KHU VỰC HIỂN THỊ NỘI DUNG CHỨC NĂNG (PAGES CONTAINER)
---------------------------------------------------------------------------
local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -170, 1, -50)
PagesContainer.Position = UDim2.new(0, 160, 0, 40)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

local function CreatePage()
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    Page.Visible = false
    Page.Parent = PagesContainer
    
    local PageList = Instance.new("UIListLayout")
    PageList.Parent = Page
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    PageList.Padding = UDim.new(0, 10)
    
    return Page
end

local FarmingPage = CreatePage()
local UpgradesPage = CreatePage()
local UtilitiesPage = CreatePage()

local currentTab = nil
local function AddTab(name, pageTarget)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, -16, 0, 32)
    TabButton.Position = UDim2.new(0, 8, 0, 0)
    TabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    TabButton.BackgroundTransparency = 1
    TabButton.Text = "   " .. name
    TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabButton.TextSize = 13
    TabButton.Font = Enum.Font.SourceSansSemibold
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.Parent = TabButtonsContainer
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabButton
    
    TabButton.MouseButton1Click:Connect(function()
        if currentTab then
            currentTab.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
            currentTab.BackgroundTransparency = 1
            currentTab.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        FarmingPage.Visible = false
        UpgradesPage.Visible = false
        UtilitiesPage.Visible = false
        
        TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        TabButton.BackgroundTransparency = 0
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        pageTarget.Visible = true
        currentTab = TabButton
    end)
end

AddTab("🌾 Farming", FarmingPage)
AddTab("⚡ Upgrades", UpgradesPage)
AddTab("🛠️ Utilities", UtilitiesPage)

FarmingPage.Visible = true

---------------------------------------------------------------------------
-- 5. CÁC HÀM TẠO UI THÀNH PHẦN (COMPONENT BUILDERS)
---------------------------------------------------------------------------
local function CreateSection(titleText, parentPage)
    local SecLabel = Instance.new("TextLabel")
    SecLabel.Size = UDim2.new(1, 0, 0, 20)
    SecLabel.BackgroundTransparency = 1
    SecLabel.Text = titleText:upper()
    SecLabel.TextColor3 = Color3.fromRGB(130, 130, 140)
    SecLabel.TextSize = 12
    SecLabel.Font = Enum.Font.SourceSansBold
    SecLabel.TextXAlignment = Enum.TextXAlignment.Left
    SecLabel.Parent = parentPage
end

-- Tạo nút gạt bật/tắt
local function CreateToggle(toggleName, parentPage, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parentPage
    
    local TFCorner = Instance.new("UICorner")
    TFCorner.CornerRadius = UDim.new(0, 6)
    TFCorner.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = toggleName
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSans
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 36, 0, 20)
    Switch.Position = UDim2.new(1, -48, 0.5, -10)
    Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    Switch.Text = ""
    Switch.Parent = ToggleFrame
    
    local SwCorner = Instance.new("UICorner")
    SwCorner.CornerRadius = UDim.new(1, 0)
    SwCorner.Parent = Switch
    
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 14, 0, 14)
    Circle.Position = UDim2.new(0, 3, 0.5, -7)
    Circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Circle.Parent = Switch
    
    local CirCorner = Instance.new("UICorner")
    CirCorner.CornerRadius = UDim.new(1, 0)
    CirCorner.Parent = Circle
    
    local state = false
    local connection
    
    -- Hàm cập nhật trạng thái UI trực quan
    local function updateUI()
        if state then
            Switch.BackgroundColor3 = Color3.fromRGB(0, 180, 90)
            Circle.Position = UDim2.new(1, -17, 0.5, -7)
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        else
            Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            Circle.Position = UDim2.new(0, 3, 0.5, -7)
            Circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        end
    end

    connection = Switch.MouseButton1Click:Connect(function()
        state = not state
        updateUI()
        task.spawn(function() callback(state, function(forceValue) 
            state = forceValue
            updateUI()
        end) end)
    end)
end

-- Tạo danh sách lựa chọn (Dropdown)
local _G_SelectedSeed = "None"
local function CreateDropdown(dropdownName, optionsList, parentPage)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, -10, 0, 40)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    DropdownFrame.Parent = parentPage
    
    local DFCorner = Instance.new("UICorner")
    DFCorner.CornerRadius = UDim.new(0, 6)
    DFCorner.Parent = DropdownFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 120, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = dropdownName
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSans
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = DropdownFrame
    
    local ChoiceBtn = Instance.new("TextButton")
    ChoiceBtn.Size = UDim2.new(1, -150, 0, 26)
    ChoiceBtn.Position = UDim2.new(0, 138, 0.5, -13)
    ChoiceBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    ChoiceBtn.Text = _G_SelectedSeed
    ChoiceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ChoiceBtn.Font = Enum.Font.SourceSans
    ChoiceBtn.TextSize = 13
    ChoiceBtn.Parent = DropdownFrame
    
    local CBCorner = Instance.new("UICorner")
    CBCorner.CornerRadius = UDim.new(0, 4)
    CBCorner.Parent = ChoiceBtn
    
    -- Khung chứa danh sách khi bấm xổ xuống
    local ListFrame = Instance.new("Frame")
    ListFrame.Size = UDim2.new(1, -150, 0, #optionsList * 25)
    ListFrame.Position = UDim2.new(0, 138, 1, 5)
    ListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    ListFrame.ZIndex = 5
    ListFrame.Visible = false
    ListFrame.Parent = DropdownFrame
    
    local LFList = Instance.new("UIListLayout")
    LFList.Parent = ListFrame
    
    for _, optName in pairs(optionsList) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 25)
        OptBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        OptBtn.Text = optName
        OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        OptBtn.Font = Enum.Font.SourceSans
        OptBtn.TextSize = 13
        OptBtn.ZIndex = 6
        OptBtn.Parent = ListFrame
        
        OptBtn.MouseButton1Click:Connect(function()
            _G_SelectedSeed = optName
            ChoiceBtn.Text = optName
            ListFrame.Visible = false
        end)
    end
    
    ChoiceBtn.MouseButton1Click:Connect(function()
        ListFrame.Visible = not ListFrame.Visible
    end)
end

---------------------------------------------------------------------------
-- 6. THIẾT LẬP CÁC TÍNH NĂNG CHI TIẾT
---------------------------------------------------------------------------

-- ==================== TAB 1: FARMING ====================
CreateSection("Auto Roll Seeds", FarmingPage)

-- Biến lưu tên hạt giống nhận được khi Roll thực tế (Bạn cần thay đổi để nhận diện từ game)
local function GetCurrentRolledSeed()
    -- Ghi chú: Ở đây sẽ là code check xem game vừa roll ra hạt gì.
    -- Ví dụ giả lập trả về ngẫu nhiên để test:
    local testSeeds = {"Hành hành", "Hạt giống Void", "Papaya Seed"}
    return testSeeds[math.random(1, #testSeeds)]
end

CreateToggle("Auto Roll Seeds", FarmingPage, function(isActive, setToggleUI)
    _G.AutoRoll = isActive
    while _G.AutoRoll do
        task.wait(0.5) -- Tốc độ roll
        
        -- Gọi lệnh Roll của Game ở đây. Ví dụ:
        -- game:GetService("ReplicatedStorage").Remotes.RollRemote
