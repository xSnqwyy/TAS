local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

local Window = Library.CreateLib("Yuvnas Hub | Murder Mystery 2", "Synapse")
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Main")

MainSection:NewButton("Fake Knife", "Troll Knife", function()
    local lp = game.Players.LocalPlayer
    local tool;local handle;local knife;
    local animation1 = Instance.new("Animation")
    animation1.AnimationId = "rbxassetid://2467567750"
    local animation2 = Instance.new("Animation")
    animation2.AnimationId = "rbxassetid://1957890538"
    local anims = {animation1,animation2}
    tool = Instance.new("Tool")
    tool.Name = "Fake Knife"
    tool.Grip = CFrame.new(0, -1.16999984, 0.0699999481, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    tool.GripForward = Vector3.new(-0, -0, -1)
    tool.GripPos = Vector3.new(0,-1.17,0.0699999)
    tool.GripRight = Vector3.new(1,0,0)
    tool.GripUp = Vector3.new(0,1,0)
    handle = Instance.new("Part")
    handle.Size = Vector3.new(0.310638815, 3.42103457, 1.08775854)
    handle.Name = "Handle"
    handle.Transparency = 1
    handle.Parent = tool
    tool.Parent = lp.Backpack
    knife=lp.Character:WaitForChild("KnifeDisplay")
    knife.Massless = true
    lp:GetMouse().Button1Down:Connect(function()
    if tool and  tool.Parent == lp.Character then
    local an = lp.Character.Humanoid:LoadAnimation(anims[math.random(1,2)])
    an:Play()
    end
    end)
    local aa = Instance.new("Attachment",handle)
    local ba = Instance.new("Attachment",knife)
    local hinge = Instance.new("HingeConstraint",knife)
    hinge.Attachment0=aa hinge.Attachment1=ba
    hinge.LimitsEnabled = true
    hinge.LowerAngle = 0
    hinge.Restitution = 0
    hinge.UpperAngle = 0
    lp.Character:WaitForChild"UpperTorso":FindFirstChild("Weld"):Destroy()
    game:GetService"RunService".Heartbeat:Connect(function()
    setsimulationradius(1/0,1/0)
    if tool.Parent == lp.Character then
    knife.CFrame = handle.CFrame
    else
    knife.CFrame = lp.Character:WaitForChild"UpperTorso".CFrame
    end
    end)
end)

local PlayerTab = Window:NewTab("Local Player")
local PlayerSection = PlayerTab:NewSection("Local Player")

PlayerSection:NewSlider("WalkSpeed", "Makes You Faster", 200, 16, function(s)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
end)

PlayerSection:NewSlider("JumpPower", "Makes High Jump", 200, 50, function(s)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = s 
end)

PlayerSection:NewButton("ESP", "Showing Players Location", function()
    --- Tut

local esp_settings = { ---- table for esp settings 
textsize = 8,
colour = 255,255,255
}

local gui = Instance.new("BillboardGui")
local esp = Instance.new("TextLabel",gui) ---- new instances to make the billboard gui and the textlabel



gui.Name = "Cracked esp"; ---- properties of the esp
gui.ResetOnSpawn = false
gui.AlwaysOnTop = true;
gui.LightInfluence = 0;
gui.Size = UDim2.new(1.75, 0, 1.75, 0);
esp.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
esp.Text = ""
esp.Size = UDim2.new(0.0001, 0.00001, 0.0001, 0.00001);
esp.BorderSizePixel = 4;
esp.BorderColor3 = Color3.new(esp_settings.colour)
esp.BorderSizePixel = 0
esp.Font = "LuckiestGuy"
esp.TextSize = esp_settings.textsize
esp.TextColor3 = Color3.fromRGB(esp_settings.colour) -- text colour

game:GetService("RunService").RenderStepped:Connect(function() ---- loops faster than a while loop :)
for i,v in pairs (game:GetService("Players"):GetPlayers()) do
    if v ~= game:GetService("Players").LocalPlayer and v.Character.Head:FindFirstChild("Cracked esp")==nil  then -- craeting checks for team check, local player etc
        esp.Text = "{"..v.Name.."}"
        gui:Clone().Parent = v.Character.Head
end
end
end)
end)
