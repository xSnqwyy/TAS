--[[

		Gui2Lua™
		10zOfficial
		Version 1.0.0

]]


-- Instances

local TASGui = Instance.new("ScreenGui")
local TASFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TasButton = Instance.new("TextButton")
local UICorner_2 = Instance.new("UICorner")

-- Properties

TASGui.Name = "TASGui"
TASGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
TASGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

TASFrame.Name = "TASFrame"
TASFrame.Parent = TASGui
TASFrame.BackgroundColor3 = Color3.new(0.133333, 0.133333, 0.133333)
TASFrame.BorderColor3 = Color3.new(0, 0, 0)
TASFrame.BorderSizePixel = 0
TASFrame.Position = UDim2.new(0, 0, 0.694779098, 0)
TASFrame.Size = UDim2.new(0, 14, 0, 64)

UICorner.Parent = TASFrame

TasButton.Name = "TasButton"
TasButton.Parent = TASGui
TasButton.BackgroundColor3 = Color3.new(1, 1, 1)
TasButton.BorderColor3 = Color3.new(0, 0, 0)
TasButton.BorderSizePixel = 0
TasButton.Position = UDim2.new(0.00878293626, 0, 0.714859426, 0)
TasButton.Size = UDim2.new(0, 107, 0, 45)
TasButton.Font = Enum.Font.LuckiestGuy
TasButton.Text = "TAS"
TasButton.TextColor3 = Color3.new(0, 0, 0)
TasButton.TextSize = 20

UICorner_2.Parent = TasButton

-- Scripts

local function FHWXP_fake_script() -- TasButton.LocalScript 
	local script = Instance.new('LocalScript', TasButton)


end
coroutine.wrap(FHWXP_fake_script)()
local function HXAC_fake_script() -- TasButton.Script 
	local script = Instance.new('LocalScript', TasButton)
	TasButton.MouseButton1Down:connect(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/xSnqwyy/TAS/main/Yuvnas%20Tas.lua"))()
	end)
end
coroutine.wrap(HXAC_fake_script)()
