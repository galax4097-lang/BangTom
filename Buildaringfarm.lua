-- ====================================================================
-- BUILD A RING FARM - UNIVERSAL AUTO FARM RING
-- Hỗ trợ các Executor hiện nay (Solara, Wave, Celery, Macsploit...)
-- ====================================================================

if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Cấu hình tùy chỉnh nâng cao
_G.AutoFarmRings = true
_G.DelayBetweenRings = 0.3 -- Thời gian chờ giữa mỗi vòng (giây). Có thể tăng lên nếu bị kick.

-- Hàm thực hiện Auto Farm
local function startRingFarm()
    while _G.AutoFarmRings do
        -- Tự động quét các tên thư mục phổ biến chứa Vòng trong Workspace
        local ringFolder = Workspace:FindFirstChild("Rings") 
            or Workspace:FindFirstChild("Stages") 
            or Workspace:FindFirstChild("RingFolder")
            or Workspace:FindFirstChild("AllRings")

        if ringFolder then
            local rings = ringFolder:GetChildren()
            
            -- Sắp xếp thứ tự các vòng từ 1 đến vòng cuối cùng (nếu tên vòng là số)
            table.sort(rings, function(a, b)
                local numA = tonumber(a.Name:match("%d+")) or 0
                local numB = tonumber(b.Name:match("%d+")) or 0
                return numA < numB
            end)

            -- Vòng lặp đi qua từng vòng một
            for _, ring in ipairs(rings) do
                if not _G.AutoFarmRings then break end
                
                -- Xác định Part cần chạm
                local touchPart = ring:IsA("BasePart") and ring or ring:FindFirstChildWhichIsA("BasePart")
                
                if touchPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    
                    -- MẸO: Sử dụng firetouchinterest để kích hoạt va chạm từ xa mà không cần dịch chuyển
                    if firetouchinterest then
                        firetouchinterest(hrp, touchPart, 0) -- Bắt đầu chạm
                        task.wait(0.02)
                        firetouchinterest(hrp, touchPart, 1) -- Thả chạm out
                    else
                        -- Phương án dự phòng nếu Executor cùi không hỗ trợ firetouchinterest
                        hrp.CFrame = touchPart.CFrame + Vector3.new(0, 2, 0)
                    end
                    
                    task.wait(_G.DelayBetweenRings)
                end
            end
            
            -- Sau khi đi hết các vòng, đợi nhân vật hồi sinh hoặc reset để nhận phần thưởng lượt mới
            task.wait(1)
        else
            -- Nếu game giấu thư mục vòng quá kỹ, script sẽ tự động tìm bất kỳ Part nào có tên chứa chữ "Ring"
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if _G.AutoFarmRings and obj:IsA("BasePart") and (obj.Name:lower():find("ring") or obj.Name:lower():find("stage")) then
                    if firetouchinterest and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 0)
                        task.wait(0.01)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 1)
                    end
                    task.wait(0.1)
                end
            end
            task.wait(2)
        end
    end
end

-- Thông báo kích hoạt thành công trên thanh F9 Console
print("[Dragon Hub]: Auto Ring Farm đã được kích hoạt thành công!")
task.spawn(startRingFarm)
