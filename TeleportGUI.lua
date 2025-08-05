local plrs = game:GetService("Players")
local plr = game.Players.LocalPlayer
local tweenService = game:GetService("TweenService")
if _G.TeleportGuiCreated then return end
_G.TeleportGuiCreated = true

local function tpGUI()

  local ScreenGui = Instance.new("ScreenGui")
  local Frame = Instance.new("Frame")
  local UICorner = Instance.new("UICorner")
  local TextLabel = Instance.new("TextLabel")
  local KeyBox = Instance.new("TextBox")
  local UICorner_2 = Instance.new("UICorner")
  local Enter = Instance.new("TextButton")
  local UICorner_3 = Instance.new("UICorner")

  ScreenGui.Parent = plr:WaitForChild("PlayerGui")
  ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

  Frame.Parent = ScreenGui
  Frame.BackgroundColor3 = Color3.new(0.164, 0.164, 0.164)
  Frame.BorderSizePixel = 0
  Frame.Position = UDim2.new(0.360, 0, 0.210, 0)
  Frame.Size = UDim2.new(0, 225, 0, 245)
  Frame.Active = true
  Frame.Draggable = true
  UICorner.Parent = Frame

  TextLabel.Parent = Frame
  TextLabel.BackgroundTransparency = 1
  TextLabel.Position = UDim2.new(0.05, 0, 0.037, 0)
  TextLabel.Size = UDim2.new(0, 200, 0, 50)
  TextLabel.Font = Enum.Font.LuckiestGuy
  TextLabel.Text = "Teleport GUI"
  TextLabel.TextColor3 = Color3.new(1, 1, 1)
  TextLabel.TextSize = 24

  KeyBox.Name = "KeyBox"
  KeyBox.Parent = Frame
  KeyBox.BackgroundColor3 = Color3.new(0.29, 0.29, 0.29)
  KeyBox.BorderSizePixel = 0
  KeyBox.Position = UDim2.new(0.053, 0, 0.294, 0)
  KeyBox.Size = UDim2.new(0, 199, 0, 50)
  KeyBox.Font = Enum.Font.LuckiestGuy
  KeyBox.Text = "Enter Player Name"
  KeyBox.TextColor3 = Color3.new(1, 1, 1)
  KeyBox.TextSize = 14
  UICorner_2.Parent = KeyBox

  Enter.Name = "Enter"
  Enter.Parent = Frame
  Enter.BackgroundColor3 = Color3.new(0.29, 0.29, 0.29)
  Enter.BorderSizePixel = 0
  Enter.Position = UDim2.new(0.053, 0, 0.6, 0)
  Enter.Size = UDim2.new(0, 200, 0, 50)
  Enter.Font = Enum.Font.LuckiestGuy
  Enter.Text = "Teleport to Player"
  Enter.TextColor3 = Color3.new(1, 1, 1)
  Enter.TextSize = 14
  UICorner_3.Parent = Enter

  Enter.MouseButton1Click:Connect(function()
    local input = KeyBox.Text:lower()
    for _, target in ipairs(plrs:GetPlayers()) do
      if target ~= plr and target.Name:lower():find(input) then
        local myChar = plr.Character
        local targetChar = target.Character
        if myChar and targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
          myChar:MoveTo(targetChar.HumanoidRootPart.Position + Vector3.new(2, 0, 0))
          print("Teleported to: " .. target.Name)
        else
          print("Teleport failed. Character or HumanoidRootPart missing.")
        end
        return
      end
    end
    print("No matching player found.")
  end)
end

tpGUI()

while true do
  local users = {}
  for _, player in ipairs(plrs:GetPlayers()) do
    table.insert(users, player.Name)
  end
  print("The Player Count In Server: " .. #users)
  print("")
  wait(5)
end
