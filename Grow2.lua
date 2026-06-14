-- [[ RIVALS PREMIUM BRAINROT HUB v3.5 - GARDEN AUTOMATION & UTILITIES ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== HỆ THỐNG CẤU HÌNH (SETTINGS) ====================
local Config = {
    Automation = {
        AutoBuy = false,       -- Tự động mua hạt giống/vật phẩm
        AutoSell = false,      -- Tự động bán nông sản kiếm tiền
    },
    Character = {
        SpeedEnabled = false,  -- Bật/tắt tùy chỉnh tốc độ chạy
        WalkSpeed = 16         -- Tốc độ chạy mặc định
    },
    ESP = {
        Enabled = true,        
        Names = true,          
        Distance = true,       
        Health = true,         
        MaxDistance = 500,     
        Color = Color3.fromRGB(255, 0, 100) 
    }
}

local MenuVisible = true
local IsMinimized = false
local TabFrames = {}

-- ==================== TẠO GIAO DIỆN MENU SIDEBAR CHUẨN ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotHubGarden"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 9)
MainCorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(230, 30, 110) 
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 9)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Brainrot Hub — Grow a Garden 2 Edition"
Title.TextColor3 = Color3.fromRGB(230, 230, 235)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -45, 0, 2)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "[-]"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = TopBar

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -150, 1, -50)
Container.Position = UDim2.new(0, 145, 0, 45)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

MinimizeBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        Sidebar.Visible = false
        Container.Visible = false
        MainFrame.Size = UDim2.new(0, 520, 0, 40)
        MinimizeBtn.Text = "[+]"
    else
        MainFrame.Size = UDim2.new(0, 520, 0, 340)
        Sidebar.Visible = true
        Container.Visible = true
        MinimizeBtn.Text = "[-]"
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert then
        MenuVisible = not MenuVisible
        MainFrame.Visible = MenuVisible
    end
end)

-- ==================== HÀM DỰNG THÀNH PHẦN UI ====================
local function CreateTab(tabName, order)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 120, 0, 35)
    TabBtn.Position = UDim2.new(0, 10, 0, 10 + (order * 40))
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.Font = Enum.Font.SourceSansSemibold
    TabBtn.TextSize = 14
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.CanvasSize = UDim2.new(0, 0, 1.6, 0)
    TabFrame.ScrollBarThickness = 2
    TabFrame.Visible = (order == 0)
    TabFrame.Parent = Container
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 6)
    UIList.Parent = TabFrame

    TabFrames[tabName] = TabFrame
    TabBtn.MouseButton1Click:Connect(function()
        for k, v in pairs(TabFrames) do v.Visible = (k == tabName) end
    end)
    return TabFrame
end

local function AddToggle(tabFrame, text, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -10, 0, 38)
    Row.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    Row.BorderSizePixel = 0
    Row.Parent = tabFrame
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 215)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 42, 0, 20)
    Switch.Position = UDim2.new(1, -52, 0, 9)
    Switch.Text = ""
    Switch.Parent = Row
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

    local State = default
    local function updateVisual()
        Switch.BackgroundColor3 = State and Color3.fromRGB(230, 30, 110) or Color3.fromRGB(60, 60, 65)
    end
    updateVisual()

    Switch.MouseButton1Click:Connect(function()
        State = not State
        updateVisual()
        callback(State)
    end)
end

local function AddSlider(tabFrame, text, min, max, default, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -10, 0, 48)
    Row.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    Row.BorderSizePixel = 0
    Row.Parent = tabFrame
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 0, 22)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 215)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 22)
    ValueLabel.Position = UDim2.new(0.7, -10, 0, 2)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(230, 30, 110)
    ValueLabel.Font = Enum.Font.SourceSansBold
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Row

    local SliderBar = Instance.new("TextButton")
    SliderBar.Size = UDim2.new(1, -20, 0, 4)
    SliderBar.Position = UDim2.new(0, 10, 0, 30)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    SliderBar.Text = ""
    SliderBar.Parent = Row

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(230, 30, 110)
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderBar

    local function updateSlider(input)
        local totalWidth = SliderBar.AbsoluteSize.X
        local relX = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X, 0, totalWidth)
        local percentage = relX / totalWidth
        local value = math.floor(min + (max - min) * percentage)
        ValueLabel.Text = tostring(value)
        Fill.Size = UDim2.new(percentage, 0, 1, 0)
        callback(value)
    end

    local sliding = false
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true updateSlider(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
end

-- ==================== KHỞI TẠO CÁC TAB CHỨC NĂNG ====================
local GardenTab = CreateTab("Nông Trại (Main)", 0)
local PlayerTab = CreateTab("Bản Thân & ESP", 1)

-- Cài đặt mục Tự động hóa Nông trại
AddToggle(GardenTab, "Tự Động Mua Hạt Giống (Auto Buy)", Config.Automation.AutoBuy, function(s) Config.Automation.AutoBuy = s end)
AddToggle(GardenTab, "Tự Động Bán Nông Sản (Auto Sell)", Config.Automation.AutoSell, function(s) Config.Automation.AutoSell = s end)

-- Cài đặt mục Nhân vật & ESP
AddToggle(PlayerTab, "Kích Hoạt Tùy Chỉnh Tốc Độ", Config.Character.SpeedEnabled, function(s) Config.Character.SpeedEnabled = s end)
AddSlider(PlayerTab, "Điều Chỉnh Tốc Độ (WalkSpeed)", 16, 150, Config.Character.WalkSpeed, function(v) Config.Character.WalkSpeed = v end)
AddToggle(PlayerTab, "Bật Định Vị Người Chơi (ESP)", Config.ESP.Enabled, function(s) Config.ESP.Enabled = s if not s then for _, v in ipairs(workspace:GetDescendants()) do if v:IsA("Highlight") and v.Name == "GardenESP" then v:Destroy() end end end end)
AddSlider(PlayerTab, "Khoảng Cách Định Vị Tối Đa (m)", 50, 1500, Config.ESP.MaxDistance, function(v) Config.ESP.MaxDistance = v end)

-- ==================== LOGIC GAMEPLAY: TỰ ĐỘNG MUA & BÁN NÔNG SẢN ====================
task.spawn(function()
    while task.wait(1) do
        -- Tính năng Tự Động Mua (Quét qua các hệ thống Remote Event mua hàng phổ biến của dòng game Garden)
        if Config.Automation.AutoBuy then
            pcall(function()
                -- Thay đổi tên Hạt giống / Item dựa theo ý muốn tại đây
                local shopRemote = ReplicatedStorage:FindFirstChild("BuyItem", true) or ReplicatedStorage:FindFirstChild("PurchasePrompt", true)
                if shopRemote and shopRemote:IsA("RemoteEvent") then
                    shopRemote:FireServer("Seeds", 1) -- Gửi tín hiệu mua hạt giống lên server
                end
            end)
        end
        
        -- Tính năng Tự Động Bán (Quét qua vị trí quầy bán nông sản tự động)
        if Config.Automation.AutoSell then
            pcall(function()
                local sellRemote = ReplicatedStorage:FindFirstChild("SellEverything", true) or ReplicatedStorage:FindFirstChild("SellItems", true) or ReplicatedStorage:FindFirstChild("Sell", true)
                if sellRemote and sellRemote:IsA("RemoteEvent") then
                    sellRemote:FireServer()
                else
                    -- Nếu game dùng phương thức chạm (Touch) vào hòm để bán hàng:
                    local sellPart = workspace:FindFirstChild("SellPart", true) or workspace:FindFirstChild("SellStation", true) or workspace:FindFirstChild("Merchant", true)
                    if sellPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, sellPart, 0)
                        task.wait(0.1)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, sellPart, 1)
                    end
                end
            end)
        end
    end
end)

-- ==================== HỆ THỐNG ESP TEXT CHỮ TRÊN ĐẦU ====================
local function ManageTextESP(player)
    if player == LocalPlayer then return end
    
    local function createGui(char)
        local head = char:WaitForChild("Head", 5)
        local hum = char:WaitForChild("Humanoid", 5)
        if not head or not hum then return end

        local bbg = head:FindFirstChild("GardenESP_Text") or Instance.new("BillboardGui")
        bbg.Name = "GardenESP_Text"
        bbg.Size = UDim2.new(0, 200, 0, 60)
        bbg.StudsOffset = Vector3.new(0, 3, 0)
        bbg.AlwaysOnTop = true
        bbg.Parent = head

        local ContainerList = bbg:FindFirstChild("Container") or Instance.new("Frame")
        ContainerList.Name = "Container"
        ContainerList.Size = UDim2.new(1, 0, 1, 0)
        ContainerList.BackgroundTransparency = 1
        ContainerList.Parent = bbg

        local layout = ContainerList:FindFirstChild("Layout") or Instance.new("UIListLayout")
        layout.Name = "Layout"
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Parent = ContainerList

        local NameTag = ContainerList:FindFirstChild("NameTag") or Instance.new("TextLabel")
        NameTag.Name = "NameTag"
        NameTag.Size = UDim2.new(1, 0, 0, 16)
        NameTag.BackgroundTransparency = 1
        NameTag.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameTag.Font = Enum.Font.SourceSansBold
        NameTag.TextSize = 14
        NameTag.Parent = ContainerList

        local InfoTag = ContainerList:FindFirstChild("InfoTag") or Instance.new("TextLabel")
        InfoTag.Name = "InfoTag"
        InfoTag.Size = UDim2.new(1, 0, 0, 16)
        InfoTag.BackgroundTransparency = 1
        InfoTag.TextColor3 = Color3.fromRGB(0, 255, 150) 
        InfoTag.Font = Enum.Font.SourceSans
        InfoTag.TextSize = 13
        InfoTag.Parent = ContainerList

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not char:IsDescendantOf(workspace) or hum.Health <= 0 then
                bbg:Destroy()
                connection:Disconnect()
                return
            end

            local dist = math.floor((head.Position - Camera.CFrame.Position).Magnitude)

            -- Điều kiện ẩn hiển thị chữ định vị
            if not Config.ESP.Enabled or dist > Config.ESP.MaxDistance then
                NameTag.Visible = false
                InfoTag.Visible = false
                return
            end

            NameTag.Visible = Config.ESP.Names
            NameTag.Text = player.Name

            local infoStr = ""
            if Config.ESP.Distance then infoStr = infoStr .. "[" .. dist .. "m] " end
            if Config.ESP.Health then infoStr = infoStr .. "HP: " .. math.floor(hum.Health) end
            
            InfoTag.Visible = (Config.ESP.Distance or Config.ESP.Health)
            InfoTag.Text = infoStr
        end)
    end

    if player.Character then createGui(player.Character) end
    player.CharacterAdded:Connect(createGui)
end

for _, p in ipairs(Players:GetPlayers()) do ManageTextESP(p) end
Players.PlayerAdded:Connect(ManageTextESP)

-- ==================== VÒNG LẶP RENDER TICK (TỐC ĐỘ & PHÁT SÁNG CHAMS) ====================
RunService.RenderStepped:Connect(function()
    -- Thực thi ép/chỉnh tốc độ chạy WalkSpeed liên tục
    if Config.Character.SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.Character.WalkSpeed
    end

    -- Thực thi xử lý hiệu ứng phát sáng Chams
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            
            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            local oldHl = p.Character:FindFirstChild("GardenESP")

            -- Nếu tắt tính năng hoặc quá khoảng cách quy định thì gỡ phát sáng ngay lập tức
            if not Config.ESP.Enabled or dist > Config.ESP.MaxDistance then
                if oldHl then oldHl:Destroy() end
                continue
            end

            -- Áp dụng Highlight phát sáng xuyên tường
            local hl = oldHl or Instance.new("Highlight")
            hl.Name = "GardenESP"
            hl.FillColor = Config.ESP.Color
            hl.OutlineColor = Color3.fromRGB(255, 255, 255) 
            hl.FillTransparency = 0.4
            hl.OutlineTransparency = 0.1
            hl.Parent = p.Character
        end
    end
end)
