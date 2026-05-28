-- Siêu Script ESP Tối Ưu Cho Custom Rigs/Game Bắn Súng
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function createESP(player)
    -- Tránh tự làm ESP chính mình
    if player == LocalPlayer then return end

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 0) -- Màu đỏ cho địch
    Box.Thickness = 2
    Box.Transparency = 1
    Box.Filled = false

    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = Color3.fromRGB(255, 255, 255) -- Vạch dò màu trắng
    Tracer.Thickness = 1
    Tracer.Transparency = 0.8

    local function update()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            -- Tự động tìm kiếm Nhân vật kể cả khi game dùng Custom Rig hoặc hồi sinh
            local character = player.Character or workspace:FindFirstChild(player.Name) 
            if not character and workspace:FindFirstChild("Players") then
                character = workspace.Players:FindFirstChild(player.Name) -- Quét trong Folder Players của Workspace
            end

            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid
                if humanoid.Health > 0 then
                    local hrp = character.HumanoidRootPart
                    local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                    if onScreen then
                        -- Tính toán kích thước Box dựa trên khoảng cách
                        local scale = 1000 / hrpPos.Z
                        Box.Size = Vector2.new(2.5 * scale, 4.5 * scale)
                        Box.Position = Vector2.new(hrpPos.X - Box.Size.X / 2, hrpPos.Y - Box.Size.Y / 2)
                        Box.Visible = true

                        -- Vạch tuyến kẻ từ dưới màn hình lên nhân vật
                        Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        Tracer.To = Vector2.new(hrpPos.X, hrpPos.Y)
                        Tracer.Visible = true
                    else
                        Box.Visible = false
                        Tracer.Visible = false
                    end
                else
                    Box.Visible = false
                    Tracer.Visible = false
                end
            else
                Box.Visible = false
                Tracer.Visible = false
            end

            -- Dọn dẹp khi người chơi thoát
            if not player.Parent then
                Box:Remove()
                Tracer:Remove()
                connection:Disconnect()
            end
        end)
    end
    coroutine.wrap(update)()
end

-- Áp dụng cho người chơi hiện tại và người chơi mới vào phòng
for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end
Players.PlayerAdded:Connect(createESP)
