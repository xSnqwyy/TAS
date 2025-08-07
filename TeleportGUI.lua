local plrs = game:GetService("Players")
local plr = game.Players.LocalPlayer
local tweenService = game:GetService("TweenService")

local tweenSpeed = 1.25

local function tpGUI()
	if plr:FindFirstChild("PlayerGui"):FindFirstChild("TeleportGui") then
		plr.PlayerGui:FindFirstChild("TeleportGui"):Destroy()
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "TeleportGui"

	local Frame = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local TextLabel = Instance.new("TextLabel")
	local KeyBox = Instance.new("TextBox")
	local UICorner_2 = Instance.new("UICorner")
	local Enter = Instance.new("TextButton")
	local UICorner_3 = Instance.new("UICorner")
	local PlayerList = Instance.new("ScrollingFrame")
	local UICorner_4 = Instance.new("UICorner")
	local UIListLayout = Instance.new("UIListLayout")

	ScreenGui.Parent = plr:WaitForChild("PlayerGui")
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	Frame.Parent = ScreenGui
	Frame.BackgroundColor3 = Color3.new(0.164, 0.164, 0.164)
	Frame.BorderSizePixel = 0
	Frame.Position = UDim2.new(0.36, 0, 0.21, 0)
	Frame.Size = UDim2.new(0, 225, 0, 370)
	Frame.Active = true
	Frame.Draggable = true
	UICorner.Parent = Frame

	TextLabel.Parent = Frame
	TextLabel.BackgroundTransparency = 1
	TextLabel.Position = UDim2.new(0.05, 0, 0.037, 0)
	TextLabel.Size = UDim2.new(0, 200, 0, 30)
	TextLabel.Font = Enum.Font.LuckiestGuy
	TextLabel.Text = "Teleport GUI"
	TextLabel.TextColor3 = Color3.new(1, 1, 1)
	TextLabel.TextSize = 24

	KeyBox.Name = "KeyBox"
	KeyBox.Parent = Frame
	KeyBox.BackgroundColor3 = Color3.new(0.29, 0.29, 0.29)
	KeyBox.BorderSizePixel = 0
	KeyBox.Position = UDim2.new(0.053, 0, 0.15, 0)
	KeyBox.Size = UDim2.new(0, 199, 0, 40)
	KeyBox.Font = Enum.Font.LuckiestGuy
	KeyBox.Text = "Enter Player Name"
	KeyBox.TextColor3 = Color3.new(1, 1, 1)
	KeyBox.TextSize = 14
	UICorner_2.Parent = KeyBox

	Enter.Name = "Enter"
	Enter.Parent = Frame
	Enter.BackgroundColor3 = Color3.new(0.29, 0.29, 0.29)
	Enter.BorderSizePixel = 0
	Enter.Position = UDim2.new(0.053, 0, 0.30, 0)
	Enter.Size = UDim2.new(0, 199, 0, 40)
	Enter.Font = Enum.Font.LuckiestGuy
	Enter.Text = "Teleport to Player"
	Enter.TextColor3 = Color3.new(1, 1, 1)
	Enter.TextSize = 14
	UICorner_3.Parent = Enter

	PlayerList.Name = "PlayerList"
	PlayerList.Parent = Frame
	PlayerList.BackgroundColor3 = Color3.new(0.164, 0.164, 0.164)
	PlayerList.BorderSizePixel = 0
	PlayerList.Position = UDim2.new(0.053, 0, 0.45, 0)
	PlayerList.Size = UDim2.new(0, 199, 0, 160)
	PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
	PlayerList.ScrollBarThickness = 6
	PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	PlayerList.ClipsDescendants = true
	UICorner_4.Parent = PlayerList

	UIListLayout.Parent = PlayerList
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 4)

	local function teleportTo(target)
		local myChar = plr.Character
		local targetChar = target.Character

		if myChar and targetChar and targetChar:FindFirstChild("HumanoidRootPart") and myChar:FindFirstChild("HumanoidRootPart") then
			local myHRP = myChar:WaitForChild("HumanoidRootPart")
			local targetHRP = targetChar:WaitForChild("HumanoidRootPart")

			local goalCFrame = CFrame.new(targetHRP.Position + Vector3.new(2, 0, 0))
			local tweenInfo = TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local tween = tweenService:Create(myHRP, tweenInfo, {CFrame = goalCFrame})

			tween:Play()
			print("Tweening to: " .. target.Name)
		else
			print("Teleport failed. Character or HumanoidRootPart missing.")
		end
	end

	Enter.MouseButton1Click:Connect(function()
		local input = KeyBox.Text:lower()
		for _, target in ipairs(plrs:GetPlayers()) do
			if target ~= plr and target.Name:lower():find(input) then
				teleportTo(target)
				return
			end
		end
		print("No matching player found.")
	end)

	local function refreshPlayerList()
		for _, child in ipairs(PlayerList:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		for _, player in ipairs(plrs:GetPlayers()) do
			if player ~= plr then
				local button = Instance.new("TextButton")
				button.Size = UDim2.new(1, 0, 0, 30)
				button.BackgroundColor3 = Color3.new(0.29, 0.29, 0.29)
				button.BorderSizePixel = 0
				button.Text = player.Name
				button.TextColor3 = Color3.new(1, 1, 1)
				button.Font = Enum.Font.LuckiestGuy
				button.TextSize = 14
				button.Parent = PlayerList

				local btnCorner = Instance.new("UICorner")
				btnCorner.Parent = button

				button.MouseButton1Click:Connect(function()
					KeyBox.Text = player.Name
					teleportTo(player)
				end)
			end
		end
	end

	refreshPlayerList()
	plrs.PlayerAdded:Connect(refreshPlayerList)
	plrs.PlayerRemoving:Connect(refreshPlayerList)
end

tpGUI()

plr.CharacterAdded:Connect(function()
	wait(1)
	tpGUI()
end)

while true do
	local users = {}
	for _, player in ipairs(plrs:GetPlayers()) do
		table.insert(users, player.Name)
	end
	print("The Player Count In Server: " .. #users)
	wait(5)
end
