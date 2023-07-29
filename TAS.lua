--[[

		Gui2Lua™
		10zOfficial
		Version 1.0.0

]]


-- Instances

local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TAS = Instance.new("TextButton")
local UICorner_2 = Instance.new("UICorner")

-- Properties

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.new(0.137255, 0.137255, 0.137255)
Frame.BorderColor3 = Color3.new(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0, 0, 0.698795199, 0)
Frame.Size = UDim2.new(0, 12, 0, 61)

UICorner.Parent = Frame

TAS.Name = "TAS"
TAS.Parent = Frame
TAS.BackgroundColor3 = Color3.new(1, 1, 1)
TAS.BorderColor3 = Color3.new(0, 0, 0)
TAS.BorderSizePixel = 0
TAS.Position = UDim2.new(0.15034993, 0, 0.0543132834, 0)
TAS.Size = UDim2.new(0, 126, 0, 50)
TAS.Font = Enum.Font.SourceSans
TAS.Text = "TAS"
TAS.TextColor3 = Color3.new(0, 0, 0)
TAS.TextSize = 14

UICorner_2.Parent = TAS
TAS.MouseButton1Down:connect(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/xSnqwyy/TAS/main/TAS.lua"))()
end)
