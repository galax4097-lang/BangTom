--// Simple Aim Training GUI
--// Chỉ dùng để học UI và test trong game riêng

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local aimEnabled = false
local fov = 120
local smoothness = 0.08
local targetPart = "Head"

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 300, 0, 260)
frame.Position = UDim2.new(0.05,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "Aim Trainer GUI"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20

local toggle = Instance.new("TextButton")
toggle.Parent = frame
toggle.Size = UDim2.new(0.9,0,0,40)
toggle.Position = UDim2.new(0.05,0,0.22,0)
toggle.Text = "Aim Assist: OFF"
toggle.BackgroundColor3 = Color3.fromRGB(35,35,35)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Font = Enum.Font.Gotham

local info = Instance.new("TextLabel")
info.Parent = frame
info.Size = UDim2.new(0.9,0,0,80)
info.Position = UDim2.new(0.05,0,0.45,0)
info.BackgroundTransparency = 1
info.TextColor3 = Color3.new(1,1,1)
info.Font = Enum.Font.Gotham
info.TextSize = 14
info.TextWrapped = true
info.Text =
"FOV: "..fov..
"\nSmoothness: "..smoothness..
"\nTarget: "..targetPart

toggle.MouseButton1Click:Connect(function()
	aimEnabled = not aimEnabled
	
	if aimEnabled then
		toggle.Text = "Aim Assist: ON"
		toggle.BackgroundColor3 = Color3.fromRGB(0,170,100)
	else
		toggle.Text = "Aim Assist: OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(35,35,35)
	end
end)

-- Vòng FOV
local circle = Drawing.new("Circle")
circle.Visible = true
circle.Color = Color3.fromRGB(255,255,255)
circle.Thickness = 1
circle.Radius = fov
circle.Filled = false

RunService.RenderStepped:Connect(function()
	circle.Position = Vector2.new(mouse.X, mouse.Y + 36)

	if not aimEnabled then
		return
	end

	local closest
	local shortest = math.huge

	for _,v in pairs(Players:GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild(targetPart) then
			
			local part = v.Character[targetPart]
			local pos, visible = camera:WorldToViewportPoint(part.Position)

			if visible then
				local dist = (Vector2.new(pos.X,pos.Y) - Vector2.new(mouse.X,mouse.Y)).Magnitude

				if dist < shortest and dist < fov then
					shortest = dist
					closest = part
				end
			end
		end
	end

	if closest then
		local camPos = camera.CFrame.Position
		local newCF = CFrame.new(camPos, closest.Position)

		camera.CFrame = camera.CFrame:Lerp(newCF, smoothness)
	end
end)
