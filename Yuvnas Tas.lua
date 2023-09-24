local rootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
for i, v in pairs(game:GetService("Workspace").MilBase.CoinContainer["Coin_Server"]:GetChildren())
if v:IsA("Part") then
rootPart.CFrame = v.CFrame wait(0.2)
end
end
