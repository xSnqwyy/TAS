--[[

		Gui2Lua™
		10zOfficial
		Version 1.0.0

]]


-- Instances

local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TextLabel = Instance.new("TextLabel")
local KeyBox = Instance.new("TextBox")
local UICorner_2 = Instance.new("UICorner")
local Enter = Instance.new("TextButton")

-- Properties

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.new(0.164706, 0.164706, 0.164706)
Frame.BorderColor3 = Color3.new(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.360094458, 0, 0.210843369, 0)
Frame.Size = UDim2.new(0, 225, 0, 245)

UICorner.Parent = Frame

TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.new(0.101961, 0.101961, 0.101961)
TextLabel.BackgroundTransparency = 1
TextLabel.BorderColor3 = Color3.new(0, 0, 0)
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0.0533333346, 0, 0.0367346928, 0)
TextLabel.Size = UDim2.new(0, 200, 0, 50)
TextLabel.Font = Enum.Font.LuckiestGuy
TextLabel.Text = "Key System"
TextLabel.TextColor3 = Color3.new(1, 1, 1)
TextLabel.TextSize = 24

KeyBox.Name = "KeyBox"
KeyBox.Parent = Frame
KeyBox.BackgroundColor3 = Color3.new(0.290196, 0.290196, 0.290196)
KeyBox.BorderColor3 = Color3.new(0, 0, 0)
KeyBox.BorderSizePixel = 0
KeyBox.Position = UDim2.new(0.0533333346, 0, 0.294, 0)
KeyBox.Size = UDim2.new(0, 199, 0, 50)
KeyBox.Font = Enum.Font.LuckiestGuy
KeyBox.Text = "Enter the key here"
KeyBox.TextColor3 = Color3.new(1, 1, 1)
KeyBox.TextSize = 14

UICorner_2.Parent = KeyBox

Enter.Name = "Enter"
Enter.Parent = Frame
Enter.BackgroundColor3 = Color3.new(0.290196, 0.290196, 0.290196)
Enter.BorderColor3 = Color3.new(0, 0, 0)
Enter.BorderSizePixel = 0
Enter.Position = UDim2.new(0.0533333346, 0, 0.600000024, 0)
Enter.Size = UDim2.new(0, 200, 0, 50)
Enter.Font = Enum.Font.LuckiestGuy
Enter.Text = "Check Key"
Enter.TextColor3 = Color3.new(1, 1, 1)
Enter.TextSize = 14
Enter.MouseButton1Click:Connect(function()
	if KeyBox.Text == "BESTSCRIPT" then
		Frame.Visible = false
		wait(0.5)
		loadstring(game:HttpGet("https://raw.githubusercontent.com/xSnqwyy/TAS/main/TAS.lua"))()
	end
end)
