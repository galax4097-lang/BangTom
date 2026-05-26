local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Build A Ring Farm [Custom Version]",
   LoadingTitle = "Đang tải Menu...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "GeminiHubConfigs",
      FileName = "CustomFarm"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = true
   },
   KeySystem = false -- Tắt hệ thống key cho tiện sử dụng [NO KEY]
})

---------------------------------------------------------------------------
-- TẠO CÁC DANH MỤC (TABS) BÊN TRÁI GIỐNG TRONG ẢNH
---------------------------------------------------------------------------
local FarmTab = Window:CreateTab("🌾 Farming", 4483362458) -- Mục Auto Farm
local UpgradeTab = Window:CreateTab("⚡ Upgrades", 4483362458) -- Mục Nâng cấp
local UtilityTab = Window:CreateTab("🛠️ Utilities", 4483362458) -- Mục Tiện ích

---------------------------------------------------------------------------
-- CHỨC NĂNG TRONG MỤC: FARMING
---------------------------------------------------------------------------
FarmTab:CreateSection("AUTO FARMING")

local AutoFarmToggle = FarmTab:CreateToggle({
   Name = "Auto Thu Hoạch / Auto Farm",
   CurrentValue = false,
   Flag = "ToggleAutoFarm",
   Callback = function(Value)
      _G.AutoFarm = Value
      while _G.AutoFarm do
         task.wait(0.5)
         -- Bạn chèn Code thực hiện hành động Farm ở đây
         -- Ví dụ: game:GetService("ReplicatedStorage").Remotes.Farm:FireServer()
         print("Đang tự động farm...")
      end
   end,
})

local AutoSellToggle = FarmTab:CreateToggle({
   Name = "Auto Bán Vật Phẩm (Auto Sell)",
   CurrentValue = false,
   Flag = "ToggleAutoSell",
   Callback = function(Value)
      _G.AutoSell = Value
      while _G.AutoSell do
         task.wait(1)
         -- Chèn Code tự động bán ở đây
         print("Đang tự động bán...")
      end
   end,
})

FarmTab:CreateSection("SEED MANAGEMENT")

local SeedDropdown = FarmTab:CreateDropdown({
   Name = "Chọn Loại Hạt Giống",
   Options = {"None", "Hành Hành", "Hạt Giống Void", "Papaya Seed"},
   CurrentOption = {"None"},
   MultipleOptions = false,
   Flag = "DropdownSeeds",
   Callback = function(Option)
      print("Đã chọn hạt giống: " .. Option[1])
   end,
})

---------------------------------------------------------------------------
-- CHỨC NĂNG TRONG MỤC: UPGRADES
---------------------------------------------------------------------------
UpgradeTab:CreateSection("TỰ ĐỘNG NÂNG CẤP")

local AutoUpgradeToggle = UpgradeTab:CreateToggle({
   Name = "Auto Nâng Cấp Tốc Độ",
   CurrentValue = false,
   Flag = "ToggleUpgradeSpeed",
   Callback = function(Value)
      _G.AutoUpgrade = Value
      while _G.AutoUpgrade do
         task.wait(2)
         print("Đang kiểm tra nâng cấp...")
      end
   end,
})

---------------------------------------------------------------------------
-- CHỨC NĂNG TRONG MỤC: UTILITIES (Tính năng người chơi)
---------------------------------------------------------------------------
UtilityTab:CreateSection("TÍNH NĂNG NGƯỜI CHƠI")

local SpeedSlider = UtilityTab:CreateSlider({
   Name = "Tốc độ chạy (Walkspeed)",
   Min = 16,
   Max = 150,
   DefaultValue = 16,
   Color = Color3.fromRGB(255, 255, 255),
   Increment = 1,
   ValueName = "Speed",
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end,
})

local JumpSlider = UtilityTab:CreateSlider({
   Name = "Sức nhảy (JumpPower)",
   Min = 50,
   Max = 300,
   DefaultValue = 50,
   Color = Color3.fromRGB(255, 255, 255),
   Increment = 1,
   ValueName = "Power",
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
   end,
})

Rayfield:Notify({
   Title = "Thành Công!",
   Content = "Menu đã được kích hoạt thành công.",
   Duration = 5,
   Image = 4483362458,
})
