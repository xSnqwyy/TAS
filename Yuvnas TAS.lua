local plr = game.Players.LocalPlayer --tells the script what plr is
local humanoid = plr.Character.Humanoid
local position = plr.Character.HumanoidRootPart.CFrame
wait(0.1)
humanoid:Destroy()
plr:ClearAllChildren() --clears all of the plr instance aka the local player
wait(5.25)
plr.Character.HumanoidRootPart.CFrame = position
    end
  end)
