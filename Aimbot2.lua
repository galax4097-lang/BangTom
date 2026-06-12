-- [[ BRAINROT HUB — DISTANCE LINKED SYSTEM ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- --- HỆ THỐNG CẤU HÌNH TRẠNG THÁI (GLOBAL CONFIG) ---
getgenv().Config = {
    -- Tab: Ngắm Bắn
    Aimbot = false,
    GhimCung = false,
    AimbotTeamCheck = true,
    FOV = 500,
    Smoothness = 1,
    
    -- Tab: Hiển Thị
    Chams = false,
    MaxDistance = 300,
    ESPTeamCheck = true,
    ShowName = false,
    ShowDistance = false,
    ShowHealth = false
}

-- Vòng tròn FOV ngầm phục vụ Aimbot
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Visible = false

RunService.RenderStepped:Connect(function()
    FOVCircle.Radius = getgenv().Config.FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Visible = getgenv().Config.Aimbot
end)

-- --- HÀM LỌC MỤC TIÊU (CHỈ CHỌN BỆNH NHÂN) ---
local function isValidTarget(player, checkTeamSetting)
    if player == LocalPlayer then return false end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") then return false end
    if player.Character.Humanoid.Health <= 0 then return false end
    
    -- Nếu bật Team Check (Né đồng đội / Không hiện đồng đội)
    if checkTeamSetting and player.Team then
        local tName = player.Team.Name:lower()
        -- Nếu là Cảnh sát hoặc Bác sĩ/Y tá thì bỏ qua hoàn toàn
        if string.find(tName, "guard") or string.find(tName, "police") or string.find(tName, "cảnh") or 
           string.find(tName, "staff") or string.find(tName, "doc") or string.find(tName, "nurse") or string.find(tName, "y tá") then
            return false
        end
    end
    return true -- Mục tiêu hợp lệ (Bệnh nhân/Tù nhân)
end

-- --- KHỞI TẠO GIAO DIỆN CHUẨN (TABS SYSTEM) ---
local ScreenGui = Instance.new("ScreenGui")
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Khung chính của Menu
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 360)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB
