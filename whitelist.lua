local whitelist = {
  "kguinh",
  "Tembelhayvancook",
  "Yuvnas"
}

local plr = game.Players.LocalPlayer
local char = plr.Character
local hum = char:FindFirstChild("Humanoid")


for _, player in ipairs(whitelist) do
  if plr.Name == player then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xSnqwyy/TAS/refs/heads/main/R6Animation.lua"))()
  else
    error("you're not in white list")
  end
end
