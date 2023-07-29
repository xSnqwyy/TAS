local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "Yuvnas TAS", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

local Tab = Window:MakeTab({
	Name = "Yuvnas TAS,
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "TAS"
})

Tab:AddButton({
	Name = "TAS",
	Callback = function(
script.Parent = game.Workspace
script.Name = "YuvnasTAS"

script.TASInitiator.Parent = game.ReplicatedFirst

script.TASRS.Parent = game.ReplicatedStorage

script.TASServer.Parent = game.ServerScriptService

script.TASUserInterface.Parent = game.StarterGui

if game.StarterPlayer.StarterCharacterScripts:FindFirstChild("Animate") then
	game.StarterPlayer.StarterCharacterScripts.Animate:Destroy()
end
script.ForkedScripts.Animate.Parent = game.StarterPlayer.StarterCharacterScripts

game.StarterPlayer.StarterPlayerScripts:WaitForChild("RbxCharacterSounds"):Destroy()
script.ForkedScripts.RbxCharacterSounds.Parent = game.StarterPlayer.StarterPlayerScripts

game.StarterPlayer.StarterPlayerScripts:WaitForChild("PlayerModule"):Destroy()
script.ForkedScripts.PlayerModule.Parent = game.StarterPlayer.StarterPlayerScripts

return true

-- TAS variables
local FrameAnims = {}
local LockAnimations = false

local Figure = script.Parent
local Torso = Figure:WaitForChild("Torso")
local RightShoulder = Torso:WaitForChild("Right Shoulder")
local LeftShoulder = Torso:WaitForChild("Left Shoulder")
local RightHip = Torso:WaitForChild("Right Hip")
local LeftHip = Torso:WaitForChild("Left Hip")
local Neck = Torso:WaitForChild("Neck")
local Humanoid = Figure:WaitForChild("Humanoid")
local pose = "Standing"

local currentAnim = ""
local currentAnimInstance = nil
local currentAnimTrack = nil
local currentAnimKeyframeHandler = nil
local currentAnimSpeed = 1.0
local animTable = {}
local animNames = { 
	idle = 	{	
				{ id = "http://www.roblox.com/asset/?id=180435571", weight = 9 },
				{ id = "http://www.roblox.com/asset/?id=180435792", weight = 1 }
			},
	walk = 	{ 	
				{ id = "http://www.roblox.com/asset/?id=180426354", weight = 10 } 
			}, 
	run = 	{
				{ id = "run.xml", weight = 10 } 
			}, 
	jump = 	{
				{ id = "http://www.roblox.com/asset/?id=125750702", weight = 10 } 
			}, 
	fall = 	{
				{ id = "http://www.roblox.com/asset/?id=180436148", weight = 10 } 
			}, 
	climb = {
				{ id = "http://www.roblox.com/asset/?id=180436334", weight = 10 } 
			}, 
	sit = 	{
				{ id = "http://www.roblox.com/asset/?id=178130996", weight = 10 } 
			},	
	toolnone = {
				{ id = "http://www.roblox.com/asset/?id=182393478", weight = 10 } 
			},
	toolslash = {
				{ id = "http://www.roblox.com/asset/?id=129967390", weight = 10 } 
--				{ id = "slash.xml", weight = 10 } 
			},
	toollunge = {
				{ id = "http://www.roblox.com/asset/?id=129967478", weight = 10 } 
			},
	wave = {
				{ id = "http://www.roblox.com/asset/?id=128777973", weight = 10 } 
			},
	point = {
				{ id = "http://www.roblox.com/asset/?id=128853357", weight = 10 } 
			},
	dance1 = {
				{ id = "http://www.roblox.com/asset/?id=182435998", weight = 10 }, 
				{ id = "http://www.roblox.com/asset/?id=182491037", weight = 10 }, 
				{ id = "http://www.roblox.com/asset/?id=182491065", weight = 10 } 
			},
	dance2 = {
				{ id = "http://www.roblox.com/asset/?id=182436842", weight = 10 }, 
				{ id = "http://www.roblox.com/asset/?id=182491248", weight = 10 }, 
				{ id = "http://www.roblox.com/asset/?id=182491277", weight = 10 } 
			},
	dance3 = {
				{ id = "http://www.roblox.com/asset/?id=182436935", weight = 10 }, 
				{ id = "http://www.roblox.com/asset/?id=182491368", weight = 10 }, 
				{ id = "http://www.roblox.com/asset/?id=182491423", weight = 10 } 
			},
	laugh = {
				{ id = "http://www.roblox.com/asset/?id=129423131", weight = 10 } 
			},
	cheer = {
				{ id = "http://www.roblox.com/asset/?id=129423030", weight = 10 } 
			},
}
local dances = {"dance1", "dance2", "dance3"}

-- Existence in this list signifies that it is an emote, the value indicates if it is a looping emote
local emoteNames = { wave = false, point = false, dance1 = true, dance2 = true, dance3 = true, laugh = false, cheer = false}

function configureAnimationSet(name, fileList)
	if (animTable[name] ~= nil) then
		for _, connection in pairs(animTable[name].connections) do
			connection:disconnect()
		end
	end
	animTable[name] = {}
	animTable[name].count = 0
	animTable[name].totalWeight = 0	
	animTable[name].connections = {}

	-- check for config values
	local config = script:FindFirstChild(name)
	if (config ~= nil) then
		table.insert(animTable[name].connections, config.ChildAdded:connect(function(child) configureAnimationSet(name, fileList) end))
		table.insert(animTable[name].connections, config.ChildRemoved:connect(function(child) configureAnimationSet(name, fileList) end))
		local idx = 1
		for _, childPart in pairs(config:GetChildren()) do
			if (childPart:IsA("Animation")) then
				table.insert(animTable[name].connections, childPart.Changed:connect(function(property) configureAnimationSet(name, fileList) end))
				animTable[name][idx] = {}
				animTable[name][idx].anim = childPart
				local weightObject = childPart:FindFirstChild("Weight")
				if (weightObject == nil) then
					animTable[name][idx].weight = 1
				else
					animTable[name][idx].weight = weightObject.Value
				end
				animTable[name].count = animTable[name].count + 1
				animTable[name].totalWeight = animTable[name].totalWeight + animTable[name][idx].weight
				idx = idx + 1
			end
		end
	end

	-- fallback to defaults
	if (animTable[name].count <= 0) then
		for idx, anim in pairs(fileList) do
			animTable[name][idx] = {}
			animTable[name][idx].anim = Instance.new("Animation")
			animTable[name][idx].anim.Name = name
			animTable[name][idx].anim.AnimationId = anim.id
			animTable[name][idx].weight = anim.weight
			animTable[name].count = animTable[name].count + 1
			animTable[name].totalWeight = animTable[name].totalWeight + anim.weight
		end
	end
end

-- Setup animation objects
function scriptChildModified(child)
	local fileList = animNames[child.Name]
	if (fileList ~= nil) then
		configureAnimationSet(child.Name, fileList)
	end	
end

script.ChildAdded:connect(scriptChildModified)
script.ChildRemoved:connect(scriptChildModified)


for name, fileList in pairs(animNames) do 
	configureAnimationSet(name, fileList)
end	

-- ANIMATION

-- declarations
local toolAnim = "None"
local toolAnimTime = 0

local jumpAnimTime = 0
local jumpAnimDuration = 0.3

local toolTransitionTime = 0.1
local fallTransitionTime = 0.3
local jumpMaxLimbVelocity = 0.75

-- functions

function stopAllAnimations()
	local oldAnim = currentAnim

	-- return to idle if finishing an emote
	if (emoteNames[oldAnim] ~= nil and emoteNames[oldAnim] == false) then
		oldAnim = "idle"
	end

	currentAnim = ""
	currentAnimInstance = nil
	if (currentAnimKeyframeHandler ~= nil) then
		currentAnimKeyframeHandler:disconnect()
	end

	if (currentAnimTrack ~= nil) then
		currentAnimTrack:Stop()
		currentAnimTrack:Destroy()
		currentAnimTrack = nil
	end
	return oldAnim
end

function setAnimationSpeed(speed)
	if speed ~= currentAnimSpeed then
		currentAnimSpeed = speed
		currentAnimTrack:AdjustSpeed(currentAnimSpeed)
	end
end

function keyFrameReachedFunc(frameName)
	if (frameName == "End") then

		local repeatAnim = currentAnim
		-- return to idle if finishing an emote
		if (emoteNames[repeatAnim] ~= nil and emoteNames[repeatAnim] == false) then
			repeatAnim = "idle"
		end
		
		local animSpeed = currentAnimSpeed
		playAnimation(repeatAnim, 0.0, Humanoid)
		setAnimationSpeed(animSpeed)
	end
end

-- Preload animations

local AnimToNumber = {
	['idle'] = 1,
	['walk'] = 2,
	['fall'] = 3,
	['jump'] = 4,
	['climb'] = 5,
	['sit'] = 6,
}

local NumberToAnim = {
	'idle',
	'walk',
	'fall',
	'jump',
	'climb',
	'sit'
}

function playAnimation(animName, transitionTime, humanoid, TASanim) 
	if LockAnimations and TASanim == false then
		return
	end
	
	table.insert(FrameAnims,{AnimToNumber[animName],transitionTime})
		
	local roll = math.random(1, animTable[animName].totalWeight) 
	local origRoll = roll
	local idx = 1
	while (roll > animTable[animName][idx].weight) do
		roll = roll - animTable[animName][idx].weight
		idx = idx + 1
	end

	local anim = animTable[animName][idx].anim

	-- switch animation		
	if (anim ~= currentAnimInstance) then
		
		if (currentAnimTrack ~= nil) then
			currentAnimTrack:Stop(transitionTime)
			currentAnimTrack:Destroy()
		end

		currentAnimSpeed = 1.0
	
		-- load it to the humanoid; get AnimationTrack
		currentAnimTrack = humanoid:LoadAnimation(anim)
		currentAnimTrack.Priority = Enum.AnimationPriority.Core
		 
		-- play the animation
		currentAnimTrack:Play(transitionTime)
		currentAnim = animName
		currentAnimInstance = anim

		-- set up keyframe name triggers
		if (currentAnimKeyframeHandler ~= nil) then
			currentAnimKeyframeHandler:disconnect()
		end
		currentAnimKeyframeHandler = currentAnimTrack.KeyframeReached:connect(keyFrameReachedFunc)
		
	end

end

game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
	FrameAnims = {}
	if (jumpAnimTime > 0) then
		jumpAnimTime = jumpAnimTime - deltaTime
	end
end)

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

local toolAnimName = ""
local toolAnimTrack = nil
local toolAnimInstance = nil
local currentToolAnimKeyframeHandler = nil

function toolKeyFrameReachedFunc(frameName)
	if (frameName == "End") then
		playToolAnimation(toolAnimName, 0.0, Humanoid)
	end
end

function playToolAnimation(animName, transitionTime, humanoid, priority)	 
		
		local roll = math.random(1, animTable[animName].totalWeight) 
		local origRoll = roll
		local idx = 1
		while (roll > animTable[animName][idx].weight) do
			roll = roll - animTable[animName][idx].weight
			idx = idx + 1
		end
		local anim = animTable[animName][idx].anim

		if (toolAnimInstance ~= anim) then
			
			if (toolAnimTrack ~= nil) then
				toolAnimTrack:Stop()
				toolAnimTrack:Destroy()
				transitionTime = 0
			end
					
			-- load it to the humanoid; get AnimationTrack
			toolAnimTrack = humanoid:LoadAnimation(anim)
			if priority then
				toolAnimTrack.Priority = priority
			end
			 
			-- play the animation
			toolAnimTrack:Play(transitionTime)
			toolAnimName = animName
			toolAnimInstance = anim

			currentToolAnimKeyframeHandler = toolAnimTrack.KeyframeReached:connect(toolKeyFrameReachedFunc)
		end
end

function stopToolAnimations()
	local oldAnim = toolAnimName

	if (currentToolAnimKeyframeHandler ~= nil) then
		currentToolAnimKeyframeHandler:disconnect()
	end

	toolAnimName = ""
	toolAnimInstance = nil
	if (toolAnimTrack ~= nil) then
		toolAnimTrack:Stop()
		toolAnimTrack:Destroy()
		toolAnimTrack = nil
	end


	return oldAnim
end

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------


function onRunning(speed)
	if speed > 0.01 then
		playAnimation("walk", 0.1, Humanoid)
		if currentAnimInstance and currentAnimInstance.AnimationId == "http://www.roblox.com/asset/?id=180426354" then
			setAnimationSpeed(speed / 14.5)
		end
		pose = "Running"
	else
		if emoteNames[currentAnim] == nil then
			playAnimation("idle", 0.1, Humanoid)
			pose = "Standing"
		end
	end
end

function onDied()
	pose = "Dead"
end

function onJumping()
	playAnimation("jump", 0.1, Humanoid)
	jumpAnimTime = jumpAnimDuration
	pose = "Jumping"
end

function onClimbing(speed)
	playAnimation("climb", 0.1, Humanoid)
	setAnimationSpeed(speed / 12.0)
	pose = "Climbing"
end

function onGettingUp()
	pose = "GettingUp"
end

function onFreeFall()
	if (jumpAnimTime <= 0) then
		playAnimation("fall", fallTransitionTime, Humanoid)
	end
	pose = "FreeFall"
end

function onFallingDown()
	pose = "FallingDown"
end

function onSeated()
	pose = "Seated"
end

function onPlatformStanding()
	pose = "PlatformStanding"
end

function onSwimming(speed)
	if speed > 0 then
		pose = "Running"
	else
		pose = "Standing"
	end
end

function getTool()	
	for _, kid in ipairs(Figure:GetChildren()) do
		if kid.className == "Tool" then return kid end
	end
	return nil
end

function getToolAnim(tool)
	for _, c in ipairs(tool:GetChildren()) do
		if c.Name == "toolanim" and c.className == "StringValue" then
			return c
		end
	end
	return nil
end

function animateTool()
	
	if (toolAnim == "None") then
		playToolAnimation("toolnone", toolTransitionTime, Humanoid, Enum.AnimationPriority.Idle)
		return
	end

	if (toolAnim == "Slash") then
		playToolAnimation("toolslash", 0, Humanoid, Enum.AnimationPriority.Action)
		return
	end

	if (toolAnim == "Lunge") then
		playToolAnimation("toollunge", 0, Humanoid, Enum.AnimationPriority.Action)
		return
	end
end

function moveSit()
	RightShoulder.MaxVelocity = 0.15
	LeftShoulder.MaxVelocity = 0.15
	RightShoulder:SetDesiredAngle(3.14 /2)
	LeftShoulder:SetDesiredAngle(-3.14 /2)
	RightHip:SetDesiredAngle(3.14 /2)
	LeftHip:SetDesiredAngle(-3.14 /2)
end

local lastTick = 0

function move(time)
	local amplitude = 1
	local frequency = 1
  	local deltaTime = time - lastTick
  	lastTick = time

	local climbFudge = 0
	local setAngles = false

	if (pose == "FreeFall" and jumpAnimTime <= 0) then
		playAnimation("fall", fallTransitionTime, Humanoid)
	elseif (pose == "Seated") then
		playAnimation("sit", 0.5, Humanoid)
		return
	elseif (pose == "Running") then
		playAnimation("walk", 0.1, Humanoid)
	elseif (pose == "Dead" or pose == "GettingUp" or pose == "FallingDown" or pose == "Seated" or pose == "PlatformStanding") then
		stopAllAnimations()
		amplitude = 0.1
		frequency = 1
		setAngles = true
	end

	if (setAngles) then
		local desiredAngle = amplitude * math.sin(time * frequency)

		RightShoulder:SetDesiredAngle(desiredAngle + climbFudge)
		LeftShoulder:SetDesiredAngle(desiredAngle - climbFudge)
		RightHip:SetDesiredAngle(-desiredAngle)
		LeftHip:SetDesiredAngle(-desiredAngle)
	end

	-- Tool Animation handling
	local tool = getTool()
	if tool and tool:FindFirstChild("Handle") then
	
		local animStringValueObject = getToolAnim(tool)

		if animStringValueObject then
			toolAnim = animStringValueObject.Value
			-- message recieved, delete StringValue
			animStringValueObject.Parent = nil
			toolAnimTime = time + .3
		end

		if time > toolAnimTime then
			toolAnimTime = 0
			toolAnim = "None"
		end

		animateTool()		
	else
		stopToolAnimations()
		toolAnim = "None"
		toolAnimInstance = nil
		toolAnimTime = 0
	end
end

-- connect events
Humanoid.Died:connect(onDied)
Humanoid.Running:connect(onRunning)
Humanoid.Jumping:connect(onJumping)
Humanoid.Climbing:connect(onClimbing)
Humanoid.GettingUp:connect(onGettingUp)
Humanoid.FreeFalling:connect(onFreeFall)
Humanoid.FallingDown:connect(onFallingDown)
Humanoid.Seated:connect(onSeated)
Humanoid.PlatformStanding:connect(onPlatformStanding)
Humanoid.Swimming:connect(onSwimming)

-- setup emote chat hook
game:GetService("Players").LocalPlayer.Chatted:connect(function(msg)
	local emote = ""
	if msg == "/e dance" then
		emote = dances[math.random(1, #dances)]
	elseif (string.sub(msg, 1, 3) == "/e ") then
		emote = string.sub(msg, 4)
	elseif (string.sub(msg, 1, 7) == "/emote ") then
		emote = string.sub(msg, 8)
	end
	
	if (pose == "Standing" and emoteNames[emote] ~= nil) then
		playAnimation(emote, 0.1, Humanoid)
	end

end)

local PoseToNumber = {
	['Standing'] = 1,
	['Jumping'] = 2,
	['Climbing'] = 3,
	['GettingUp'] = 4,
	['FreeFall'] = 5,
	['FallingDown'] = 6,
	['Seated'] = 7,
	['PlatformStanding'] = 8,
}

local NumberToPose = {
	'Standing',
	'Jumping',
	'Climbing',
	'GettingUp',
	'FreeFall',
	'FallingDown',
	'Seated',
	'PlatformStanding'
}
-- main program

game.ReplicatedStorage.TASRS.BindableFunctions.GetAnimation.OnInvoke = function(t,f)
	if currentAnimTrack ~= nil then
		return {
			PoseToNumber[pose] or 0,
			math.round(jumpAnimTime*1000)/1000,
			currentAnimSpeed,
			FrameAnims
		}
	end
	return nil
end

game.ReplicatedStorage.TASRS.BindableEvents.SetAnimation.Event:Connect(function(AnimData,testing,backtrack)
	if testing then
		for _,v in pairs(AnimData[4]) do
			playAnimation(NumberToAnim[v[1]],v[2],Humanoid,true)
		end
	elseif backtrack then
		for _,v in pairs(backtrack) do
			playAnimation(NumberToAnim[v[1]],v[2],Humanoid,true)
		end
	end
	pose = NumberToPose[AnimData[1]] or pose
	jumpAnimTime = AnimData[2]
	setAnimationSpeed(AnimData[3])
end)

game.ReplicatedStorage.TASRS.BindableEvents.LockAnimations.Event:Connect(function(lock)
	if lock then
		LockAnimations = true
	else
		LockAnimations = false
	end
end)

-- initialize to idle
playAnimation("idle", 0.1, Humanoid)
pose = "Standing"

while Figure.Parent ~= nil do
	local _, time = wait(0.1)
	move(time)
end

-- Roblox character sound script

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local AtomicBinding = require(script:WaitForChild("AtomicBinding"))

local function loadFlag(flag: string)
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled(flag)
	end)
	return success and result
end

local FFlagUserAtomicCharacterSoundsUnparent = loadFlag("UserAtomicCharacterSoundsUnparent")

local SOUND_DATA : { [string]: {[string]: any}} = {
	Climbing = {
		SoundId = "rbxasset://sounds/action_footsteps_plastic.mp3",
		Looped = true,
	},
	Died = {
		SoundId = "rbxasset://sounds/uuhhh.mp3",
	},
	FreeFalling = {
		SoundId = "rbxasset://sounds/action_falling.mp3",
		Looped = true,
	},
	GettingUp = {
		SoundId = "rbxasset://sounds/action_get_up.mp3",
	},
	Jumping = {
		SoundId = "rbxasset://sounds/action_jump.mp3",
	},
	Landing = {
		SoundId = "rbxasset://sounds/action_jump_land.mp3",
	},
	Running = {
		SoundId = "rbxasset://sounds/action_footsteps_plastic.mp3",
		Looped = true,
		Pitch = 1.85,
	},
	Splash = {
		SoundId = "rbxasset://sounds/impact_water.mp3",
	},
	Swimming = {
		SoundId = "rbxasset://sounds/action_swim.mp3",
		Looped = true,
		Pitch = 1.6,
	},
}

-- map a value from one range to another
local function map(x: number, inMin: number, inMax: number, outMin: number, outMax: number): number
	return (x - inMin)*(outMax - outMin)/(inMax - inMin) + outMin
end

local function playSound(sound: Sound)
	sound.TimePosition = 0
	sound.Playing = true
end

local function shallowCopy(t)
	local out = {}
	for k, v in pairs(t) do
		out[k] = v
	end
	return out
end

local function initializeSoundSystem(instances)
	local player = instances.player
	local humanoid = instances.humanoid
	local rootPart = instances.rootPart
	
	local sounds: {[string]: Sound} = {}

	-- initialize sounds
	for name: string, props: {[string]: any} in pairs(SOUND_DATA) do
		local sound: Sound = Instance.new("Sound") 
		sound.Name = name

		-- set default values
		sound.Archivable = false
		sound.RollOffMinDistance = 5
		sound.RollOffMaxDistance = 150
		sound.Volume = 0.65

		for propName, propValue: any in pairs(props) do
			sound[propName] = propValue
		end

		sound.Parent = rootPart
		sounds[name] = sound
	end

	local playingLoopedSounds: {[Sound]: boolean?} = {}

	local function stopPlayingLoopedSounds(except: Sound?)
		for sound in pairs(shallowCopy(playingLoopedSounds)) do
			if sound ~= except then
				sound.Playing = false
				playingLoopedSounds[sound] = nil
			end
		end
	end

	-- state transition callbacks.
	local stateTransitions: {[Enum.HumanoidStateType]: () -> ()} = {
		[Enum.HumanoidStateType.FallingDown] = function()
			stopPlayingLoopedSounds()
		end,

		[Enum.HumanoidStateType.GettingUp] = function()
			stopPlayingLoopedSounds()
			playSound(sounds.GettingUp)
		end,

		[Enum.HumanoidStateType.Jumping] = function()
			stopPlayingLoopedSounds()
			playSound(sounds.Jumping)
		end,

		[Enum.HumanoidStateType.Swimming] = function()
			local verticalSpeed = math.abs(rootPart.AssemblyLinearVelocity.Y)
			if verticalSpeed > 0.1 then
				sounds.Splash.Volume = math.clamp(map(verticalSpeed, 100, 350, 0.28, 1), 0, 1)
				playSound(sounds.Splash)
			end
			stopPlayingLoopedSounds(sounds.Swimming)
			sounds.Swimming.Playing = true
			playingLoopedSounds[sounds.Swimming] = true
		end,

		[Enum.HumanoidStateType.Freefall] = function()
			sounds.FreeFalling.Volume = 0
			stopPlayingLoopedSounds(sounds.FreeFalling)
			playingLoopedSounds[sounds.FreeFalling] = true
		end,

		[Enum.HumanoidStateType.Landed] = function()
			stopPlayingLoopedSounds()
			local verticalSpeed = math.abs(rootPart.AssemblyLinearVelocity.Y)
			if verticalSpeed > 75 then
				sounds.Landing.Volume = math.clamp(map(verticalSpeed, 50, 100, 0, 1), 0, 1)
				playSound(sounds.Landing)
			end
		end,

		[Enum.HumanoidStateType.Running] = function()
			stopPlayingLoopedSounds(sounds.Running)
			sounds.Running.Playing = true
			playingLoopedSounds[sounds.Running] = true
		end,

		[Enum.HumanoidStateType.Climbing] = function()
			local sound = sounds.Climbing
			if math.abs(rootPart.AssemblyLinearVelocity.Y) > 0.1 then
				sound.Playing = true
				stopPlayingLoopedSounds(sound)
			else
				stopPlayingLoopedSounds()
			end
			playingLoopedSounds[sound] = true
		end,

		[Enum.HumanoidStateType.Seated] = function()
			stopPlayingLoopedSounds()
		end,

		[Enum.HumanoidStateType.Dead] = function()
			stopPlayingLoopedSounds()
			playSound(sounds.Died)
		end,
	}

	-- updaters for looped sounds
	local loopedSoundUpdaters: {[Sound]: (number, Sound, Vector3) -> ()} = {
		[sounds.Climbing] = function(dt: number, sound: Sound, vel: Vector3)
			sound.Playing = vel.Magnitude > 0.1
		end,

		[sounds.FreeFalling] = function(dt: number, sound: Sound, vel: Vector3): ()
			if vel.Magnitude > 75 then
				sound.Volume = math.clamp(sound.Volume + 0.9*dt, 0, 1)
			else
				sound.Volume = 0
			end
		end,

		[sounds.Running] = function(dt: number, sound: Sound, vel: Vector3)
			sound.Playing = vel.Magnitude > 0.5 --and humanoid.MoveDirection.Magnitude > 0.5
		end,
	}

	-- state substitutions to avoid duplicating entries in the state table
	local stateRemap: {[Enum.HumanoidStateType]: Enum.HumanoidStateType} = {
		[Enum.HumanoidStateType.RunningNoPhysics] = Enum.HumanoidStateType.Running,
	}

	local activeState: Enum.HumanoidStateType = stateRemap[humanoid:GetState()] or humanoid:GetState()

	local stateChangedConn = humanoid.StateChanged:Connect(function(_, state)
		state = stateRemap[state] or state

		if state ~= activeState then
			local transitionFunc: () -> () = stateTransitions[state]

			if transitionFunc then
				transitionFunc()
			end

			activeState = state
		end
	end)

	local steppedConn = RunService.Stepped:Connect(function(_, worldDt: number)
		-- update looped sounds on stepped
		for sound in pairs(playingLoopedSounds) do
			local updater: (number, Sound, Vector3) -> () = loopedSoundUpdaters[sound]

			if updater then
				updater(worldDt, sound, rootPart.AssemblyLinearVelocity)
			end
		end
	end)

	local function terminate()
		stateChangedConn:Disconnect()
		steppedConn:Disconnect()

		if FFlagUserAtomicCharacterSoundsUnparent then
			-- Unparent all sounds and empty sounds table
			-- This is needed in order to support the case where initializeSoundSystem might be called more than once for the same player,
			-- which might happen in case player character is unparented and parented back on server and reset-children mechanism is active.
			for name: string, sound: Sound in pairs(sounds) do
				sound:Destroy()
			end
			table.clear(sounds)
		end
	end
	
	return terminate
end

local binding = AtomicBinding.new({
	humanoid = "Humanoid",
	rootPart = "HumanoidRootPart",
}, initializeSoundSystem)

local playerConnections = {}

local function characterAdded(character)
	binding:bindRoot(character)
end

local function characterRemoving(character)
	binding:unbindRoot(character)
end

local function playerAdded(player: Player)
	local connections = playerConnections[player]
	if not connections then
		connections = {}
		playerConnections[player] = connections
	end

	if player.Character then
		characterAdded(player.Character)
	end
	table.insert(connections, player.CharacterAdded:Connect(characterAdded))
	table.insert(connections, player.CharacterRemoving:Connect(characterRemoving))
end

local function playerRemoving(player: Player)
	local connections = playerConnections[player]
	if connections then
		for _, conn in ipairs(connections) do
			conn:Disconnect()
		end
		playerConnections[player] = nil
	end
	
	if player.Character then
		characterRemoving(player.Character)
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(playerAdded, player)
end
Players.PlayerAdded:Connect(playerAdded)
Players.PlayerRemoving:Connect(playerRemoving)

local ROOT_ALIAS = "root"

local function parsePath(pathStr)
	local pathArray = string.split(pathStr, "/")
	for idx = #pathArray, 1, -1 do
		if pathArray[idx] == "" then
			table.remove(pathArray, idx)
		end
	end
	return pathArray
end

local function isManifestResolved(resolvedManifest, manifestSizeTarget)
	local manifestSize = 0
	for _ in pairs(resolvedManifest) do
		manifestSize += 1
	end

	assert(manifestSize <= manifestSizeTarget, manifestSize)
	return manifestSize == manifestSizeTarget
end

local function unbindNodeDescend(node, resolvedManifest)
	if node.instance == nil then
		return -- Do not try to unbind nodes that are already unbound
	end

	node.instance = nil

	local connections = node.connections
	if connections then
		for _, conn in ipairs(connections) do
			conn:Disconnect()
		end
		table.clear(connections)
	end

	if resolvedManifest and node.alias then
		resolvedManifest[node.alias] = nil
	end

	local children = node.children
	if children then
		for _, childNode in pairs(children) do
			unbindNodeDescend(childNode, resolvedManifest)
		end
	end
end

local AtomicBinding = {}
AtomicBinding.__index = AtomicBinding

function AtomicBinding.new(manifest, boundFn)
	local dtorMap = {} -- { [root] -> dtor }
	local connections = {} -- { Connection, ... }
	local rootInstToRootNode = {} -- { [root] -> rootNode }
	local rootInstToManifest = {} -- { [root] -> { [alias] -> instance } }

	local parsedManifest = {} -- { [alias] = {Name, ...} }
	local manifestSizeTarget = 1 -- Add 1 because root isn't explicitly on the manifest	
	
	for alias, rawPath in pairs(manifest) do
		parsedManifest[alias] = parsePath(rawPath)
		manifestSizeTarget += 1
	end

	return setmetatable({
		_boundFn = boundFn,
		_parsedManifest = parsedManifest,
		_manifestSizeTarget = manifestSizeTarget,
		
		_dtorMap = dtorMap,
		_connections = connections,
		_rootInstToRootNode = rootInstToRootNode,
		_rootInstToManifest = rootInstToManifest,
	}, AtomicBinding)
end

function AtomicBinding:_startBoundFn(root, resolvedManifest)
	local boundFn = self._boundFn
	local dtorMap = self._dtorMap
	
	local oldDtor = dtorMap[root]
	if oldDtor then
		oldDtor()
		dtorMap[root] = nil
	end

	local dtor = boundFn(resolvedManifest)
	if dtor then
		dtorMap[root] = dtor
	end
end

function AtomicBinding:_stopBoundFn(root)
	local dtorMap = self._dtorMap
	
	local dtor = dtorMap[root]
	if dtor then
		dtor()
		dtorMap[root] = nil
	end
end

function AtomicBinding:bindRoot(root)
	debug.profilebegin("AtomicBinding:BindRoot")
	
	local parsedManifest = self._parsedManifest
	local rootInstToRootNode = self._rootInstToRootNode
	local rootInstToManifest = self._rootInstToManifest
	local manifestSizeTarget = self._manifestSizeTarget
	
	assert(rootInstToManifest[root] == nil)

	local resolvedManifest = {}
	rootInstToManifest[root] = resolvedManifest

	debug.profilebegin("BuildTree")

	local rootNode = {}
	rootNode.alias = ROOT_ALIAS
	rootNode.instance = root
	if next(parsedManifest) then
		-- No need to assign child data if there are no children
		rootNode.children = {}
		rootNode.connections = {}
	end

	rootInstToRootNode[root] = rootNode

	for alias, parsedPath in pairs(parsedManifest) do
		local parentNode = rootNode

		for idx, childName in ipairs(parsedPath) do
			local leaf = idx == #parsedPath
			local childNode = parentNode.children[childName] or {}

			if leaf then
				if childNode.alias ~= nil then
					error("Multiple aliases assigned to one instance")
				end

				childNode.alias = alias

			else
				childNode.children = childNode.children or {}
				childNode.connections = childNode.connections or {}
			end

			parentNode.children[childName] = childNode
			parentNode = childNode
		end
	end

	debug.profileend() -- BuildTree

	-- Recursively descend into the tree, resolving each node.
	-- Nodes start out as empty and instance-less; the resolving process discovers instances to map to nodes.
	local function processNode(node)
		local instance = assert(node.instance)

		local children = node.children
		local alias = node.alias
		local isLeaf = not children

		if alias then
			resolvedManifest[alias] = instance
		end

		if not isLeaf then
			local function processAddChild(childInstance)
				local childName = childInstance.Name
				local childNode = children[childName]
				if not childNode or childNode.instance ~= nil then
					return
				end

				childNode.instance = childInstance
				processNode(childNode)
			end

			local function processDeleteChild(childInstance)
				-- Instance deletion - Parent A detects that child B is being removed
				--    1. A removes B from `children`
				--    2. A traverses down from B,
				--       i.  Disconnecting inputs
				--       ii. Removing nodes from the resolved manifest
				--    3. stopBoundFn is called because we know the tree is no longer complete, or at least has to be refreshed
				-- 	  4. We search A for a replacement for B, and attempt to re-resolve using that replacement if it exists.
				-- To support the above sanely, processAddChild needs to avoid resolving nodes that are already resolved.

				local childName = childInstance.Name
				local childNode = children[childName]

				if not childNode then
					return -- There's no child node corresponding to the deleted instance, ignore
				end

				if childNode.instance ~= childInstance then
					return -- A child was removed with the same name as a node instance, ignore
				end

				self:_stopBoundFn(root) -- Happens before the tree is unbound so the manifest is still valid in the destructor.
				unbindNodeDescend(childNode, resolvedManifest) -- Unbind the tree

				assert(childNode.instance == nil) -- If this triggers, unbindNodeDescend failed

				-- Search for a replacement
				local replacementChild = instance:FindFirstChild(childName)
				if replacementChild then
					processAddChild(replacementChild)
				end
			end

			for _, child in ipairs(instance:GetChildren()) do
				processAddChild(child)
			end

			table.insert(node.connections, instance.ChildAdded:Connect(processAddChild))
			table.insert(node.connections, instance.ChildRemoved:Connect(processDeleteChild))
		end

		if isLeaf and isManifestResolved(resolvedManifest, manifestSizeTarget) then
			self:_startBoundFn(root, resolvedManifest)
		end
	end

	debug.profilebegin("ResolveTree")
	processNode(rootNode)
	debug.profileend() -- ResolveTree
	
	debug.profileend() -- AtomicBinding:BindRoot
end

function AtomicBinding:unbindRoot(root)
	local rootInstToRootNode = self._rootInstToRootNode
	local rootInstToManifest = self._rootInstToManifest
	
	self:_stopBoundFn(root)

	local rootNode = rootInstToRootNode[root]
	if rootNode then
		local resolvedManifest = assert(rootInstToManifest[root])
		unbindNodeDescend(rootNode, resolvedManifest)
		rootInstToRootNode[root] = nil
	end

	rootInstToManifest[root] = nil
end

function AtomicBinding:destroy()
	debug.profilebegin("AtomicBinding:destroy")

	for _, dtor in pairs(self._dtorMap) do
		dtor:destroy()
	end
	table.clear(self._dtorMap)

	for _, conn in ipairs(self._connections) do
		conn:Disconnect()
	end
	table.clear(self._connections)

	local rootInstToManifest = self._rootInstToManifest
	for rootInst, rootNode in pairs(self._rootInstToRootNode) do
		local resolvedManifest = assert(rootInstToManifest[rootInst])
		unbindNodeDescend(rootNode, resolvedManifest)
	end
	table.clear(self._rootInstToManifest)
	table.clear(self._rootInstToRootNode)

	debug.profileend()
end

return AtomicBinding

local PlayerModule = {}
PlayerModule.__index = PlayerModule

function PlayerModule.new()
	local self = setmetatable({},PlayerModule)
	self.cameras = require(script:WaitForChild("CameraModule"))
	self.controls = require(script:WaitForChild("ControlModule"))
	return self
end

function PlayerModule:GetCameras()
	return self.cameras
end

function PlayerModule:GetControls()
	return self.controls
end

function PlayerModule:GetClickToMoveController()
	return self.controls:GetClickToMoveController()
end

return PlayerModule.new()

local CameraModule = {}
CameraModule.__index = CameraModule

-- NOTICE: Player property names do not all match their StarterPlayer equivalents,
-- with the differences noted in the comments on the right
local PLAYER_CAMERA_PROPERTIES =
{
	"CameraMinZoomDistance",
	"CameraMaxZoomDistance",
	"CameraMode",
	"DevCameraOcclusionMode",
	"DevComputerCameraMode",			-- Corresponds to StarterPlayer.DevComputerCameraMovementMode
	"DevTouchCameraMode",				-- Corresponds to StarterPlayer.DevTouchCameraMovementMode
	
	-- Character movement mode
	"DevComputerMovementMode",
	"DevTouchMovementMode",
	"DevEnableMouseLock",				-- Corresponds to StarterPlayer.EnableMouseLockOption
}

local USER_GAME_SETTINGS_PROPERTIES =
{
	"ComputerCameraMovementMode",
	"ComputerMovementMode",
	"ControlMode",
	"GamepadCameraSensitivity",
	"MouseSensitivity",
	"RotationType",
	"TouchCameraMovementMode",
	"TouchMovementMode",
}

--[[ Roblox Services ]]--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterPlayer = game:GetService("StarterPlayer")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

-- Camera math utility library
local CameraUtils = require(script:WaitForChild("CameraUtils"))

-- Load Roblox Camera Controller Modules
local ClassicCamera = require(script:WaitForChild("ClassicCamera"))
local OrbitalCamera = require(script:WaitForChild("OrbitalCamera"))
local LegacyCamera = require(script:WaitForChild("LegacyCamera"))

-- Load Roblox Occlusion Modules
local Invisicam = require(script:WaitForChild("Invisicam"))
local Poppercam do
	local success, useNewPoppercam = pcall(UserSettings().IsUserFeatureEnabled, UserSettings(), "UserNewPoppercam4")
	if success and useNewPoppercam then
		Poppercam = require(script:WaitForChild("Poppercam"))
	else
		Poppercam = require(script:WaitForChild("Poppercam_Classic"))
	end
end

-- Load the near-field character transparency controller and the mouse lock "shift lock" controller
local TransparencyController = require(script:WaitForChild("TransparencyController"))
local MouseLockController = require(script:WaitForChild("MouseLockController"))

-- Table of camera controllers that have been instantiated. They are instantiated as they are used.
local instantiatedCameraControllers = {}
local instantiatedOcclusionModules = {}

-- Management of which options appear on the Roblox User Settings screen
do
	local PlayerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts")

	PlayerScripts:RegisterTouchCameraMovementMode(Enum.TouchCameraMovementMode.Default)
	PlayerScripts:RegisterTouchCameraMovementMode(Enum.TouchCameraMovementMode.Follow)
	PlayerScripts:RegisterTouchCameraMovementMode(Enum.TouchCameraMovementMode.Classic)

	PlayerScripts:RegisterComputerCameraMovementMode(Enum.ComputerCameraMovementMode.Default)
	PlayerScripts:RegisterComputerCameraMovementMode(Enum.ComputerCameraMovementMode.Follow)
	PlayerScripts:RegisterComputerCameraMovementMode(Enum.ComputerCameraMovementMode.Classic)
end


function CameraModule.new()
	local self = setmetatable({},CameraModule)
	
	-- Current active controller instances
	self.activeCameraController = nil
	self.activeOcclusionModule = nil
	self.activeTransparencyController = nil
	self.activeMouseLockController = nil
	
	self.currentComputerCameraMovementMode = nil
	
	-- Connections to events
	self.cameraSubjectChangedConn = nil
	self.cameraTypeChangedConn = nil
	
	-- Adds CharacterAdded and CharacterRemoving event handlers for all current players
	for _,player in pairs(Players:GetPlayers()) do
		self:OnPlayerAdded(player)
	end
	
	-- Adds CharacterAdded and CharacterRemoving event handlers for all players who join in the future
	Players.PlayerAdded:Connect(function(player)
		self:OnPlayerAdded(player)
	end)

	self.activeTransparencyController = TransparencyController.new()
	self.activeTransparencyController:Enable(true)
	
	--if not UserInputService.TouchEnabled then
		self.activeMouseLockController = MouseLockController.new()
		local toggleEvent = self.activeMouseLockController:GetBindableToggleEvent()
		if toggleEvent then
			toggleEvent:Connect(function()
				self:OnMouseLockToggled()
			end)
		end
	--end
	
	self:ActivateCameraController(self:GetCameraControlChoice())
	self:ActivateOcclusionModule(Players.LocalPlayer.DevCameraOcclusionMode)
	self:OnCurrentCameraChanged() -- Does initializations and makes first camera controller
	RunService:BindToRenderStep("cameraRenderUpdate", Enum.RenderPriority.Camera.Value, function(dt) self:Update(dt) end)
	
	-- Connect listeners to camera-related properties
	for _, propertyName in pairs(PLAYER_CAMERA_PROPERTIES) do
		Players.LocalPlayer:GetPropertyChangedSignal(propertyName):Connect(function()
			self:OnLocalPlayerCameraPropertyChanged(propertyName)
		end)
	end
	
	for _, propertyName in pairs(USER_GAME_SETTINGS_PROPERTIES) do
		UserGameSettings:GetPropertyChangedSignal(propertyName):Connect(function()
			self:OnUserGameSettingsPropertyChanged(propertyName)
		end)
	end
	game.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		self:OnCurrentCameraChanged()
	end)

	self.lastInputType = UserInputService:GetLastInputType()
	UserInputService.LastInputTypeChanged:Connect(function(newLastInputType)
		self.lastInputType = newLastInputType
	end)

	return self
end





function CameraModule:GetCameraMovementModeFromSettings()
	local cameraMode = Players.LocalPlayer.CameraMode

	-- Lock First Person trumps all other settings and forces ClassicCamera
	if cameraMode == Enum.CameraMode.LockFirstPerson then
		return CameraUtils.ConvertCameraModeEnumToStandard(Enum.ComputerCameraMovementMode.Classic)
	end

	local devMode, userMode
	if UserInputService.TouchEnabled then
		devMode = CameraUtils.ConvertCameraModeEnumToStandard(Players.LocalPlayer.DevTouchCameraMode)
		userMode = CameraUtils.ConvertCameraModeEnumToStandard(UserGameSettings.TouchCameraMovementMode)
	else
		devMode = CameraUtils.ConvertCameraModeEnumToStandard(Players.LocalPlayer.DevComputerCameraMode)
		userMode = CameraUtils.ConvertCameraModeEnumToStandard(UserGameSettings.ComputerCameraMovementMode)
	end	
	
	if devMode == Enum.DevComputerCameraMovementMode.UserChoice then
		-- Developer is allowing user choice, so user setting is respected
		return userMode
	end

	return devMode
end

function CameraModule:ActivateOcclusionModule( occlusionMode )
	local newModuleCreator = nil
	if occlusionMode == Enum.DevCameraOcclusionMode.Zoom then
		newModuleCreator = Poppercam
	elseif occlusionMode == Enum.DevCameraOcclusionMode.Invisicam then
		newModuleCreator = Invisicam
	else
		warn("CameraScript ActivateOcclusionModule called with unsupported mode")
		return
	end
	
	-- First check to see if there is actually a change. If the module being requested is already
	-- the currently-active solution then just make sure it's enabled and exit early
	if self.activeOcclusionModule and self.activeOcclusionModule:GetOcclusionMode() == occlusionMode then
		if not self.activeOcclusionModule:GetEnabled() then
			self.activeOcclusionModule:Enable(true)
		end
		return
	end
	
	-- Save a reference to the current active module (may be nil) so that we can disable it if
	-- we are successful in activating its replacement
	local prevOcclusionModule = self.activeOcclusionModule
	
	-- If there is no active module, see if the one we need has already been instantiated
	self.activeOcclusionModule = instantiatedOcclusionModules[newModuleCreator]
	
	-- If the module was not already instantiated and selected above, instantiate it
	if not self.activeOcclusionModule then
		self.activeOcclusionModule = newModuleCreator.new()
		if self.activeOcclusionModule then
			instantiatedOcclusionModules[newModuleCreator] = self.activeOcclusionModule
		end
	end
	
	-- If we were successful in either selecting or instantiating the module,
	-- enable it if it's not already the currently-active enabled module
	if self.activeOcclusionModule then
		local newModuleOcclusionMode = self.activeOcclusionModule:GetOcclusionMode()
		-- Sanity check that the module we selected or instantiated actually supports the desired occlusionMode
		if newModuleOcclusionMode ~= occlusionMode then
			warn("CameraScript ActivateOcclusionModule mismatch: ",self.activeOcclusionModule:GetOcclusionMode(),"~=",occlusionMode)
		end		
		
		-- Deactivate current module if there is one
		if prevOcclusionModule then
			-- Sanity check that current module is not being replaced by itself (that should have been handled above)
			if prevOcclusionModule ~= self.activeOcclusionModule then
				prevOcclusionModule:Enable(false)
			else
				warn("CameraScript ActivateOcclusionModule failure to detect already running correct module")
			end
		end
		
		-- Occlusion modules need to be initialized with information about characters and cameraSubject
		-- Invisicam needs the LocalPlayer's character
		-- Poppercam needs all player characters and the camera subject
		if occlusionMode == Enum.DevCameraOcclusionMode.Invisicam then
			-- Optimization to only send Invisicam what we know it needs
			if Players.LocalPlayer.Character then
				self.activeOcclusionModule:CharacterAdded(Players.LocalPlayer.Character, Players.LocalPlayer )
			end
		else
			-- When Poppercam is enabled, we send it all existing player characters for its raycast ignore list
			for _, player in pairs(Players:GetPlayers()) do
				if player and player.Character then
					self.activeOcclusionModule:CharacterAdded(player.Character, player)
				end
			end
			self.activeOcclusionModule:OnCameraSubjectChanged(game.Workspace.CurrentCamera.CameraSubject)
		end
		
		-- Activate new choice
		self.activeOcclusionModule:Enable(true)
	end
end

-- When supplied, legacyCameraType is used and cameraMovementMode is ignored (should be nil anyways)
-- Next, if userCameraCreator is passed in, that is used as the cameraCreator
function CameraModule:ActivateCameraController( cameraMovementMode, legacyCameraType )
	local newCameraCreator = nil
	
	if legacyCameraType~=nil then
		--[[ 
			This function has been passed a CameraType enum value. Some of these map to the use of
			the LegacyCamera module, the value "Custom" will be translated to a movementMode enum
			value based on Dev and User settings, and "Scriptable" will disable the camera controller.
		--]]
		
		if legacyCameraType == Enum.CameraType.Scriptable then
			if self.activeCameraController then
				self.activeCameraController:Enable(false)
				self.activeCameraController = nil				
				return
			end
		elseif legacyCameraType == Enum.CameraType.Custom then
			cameraMovementMode = self:GetCameraMovementModeFromSettings()
			
		elseif legacyCameraType == Enum.CameraType.Track then
			-- Note: The TrackCamera module was basically an older, less fully-featured
			-- version of ClassicCamera, no longer actively maintained, but it is re-implemented in
			-- case a game was dependent on its lack of ClassicCamera's extra functionality.
			cameraMovementMode = Enum.ComputerCameraMovementMode.Classic
			
		elseif legacyCameraType == Enum.CameraType.Follow then
			cameraMovementMode = Enum.ComputerCameraMovementMode.Follow
			
		elseif legacyCameraType == Enum.CameraType.Orbital then
			cameraMovementMode = Enum.ComputerCameraMovementMode.Orbital
			
		elseif legacyCameraType == Enum.CameraType.Attach or
			   legacyCameraType == Enum.CameraType.Watch or
			   legacyCameraType == Enum.CameraType.Fixed then
			newCameraCreator = LegacyCamera
		else
			warn("CameraScript encountered an unhandled Camera.CameraType value: ",legacyCameraType)			
		end		
	end
	
	if not newCameraCreator then		
		if cameraMovementMode == Enum.ComputerCameraMovementMode.Classic or
			cameraMovementMode == Enum.ComputerCameraMovementMode.Follow or
			cameraMovementMode == Enum.ComputerCameraMovementMode.Default then
			newCameraCreator = ClassicCamera
		elseif cameraMovementMode == Enum.ComputerCameraMovementMode.Orbital then
			newCameraCreator = OrbitalCamera
		else
			warn("ActivateCameraController did not select a module.")
			return
		end
	end
	
	-- Create the camera control module we need if it does not already exist in instantiatedCameraControllers
	local newCameraController = nil
	if not instantiatedCameraControllers[newCameraCreator] then
		newCameraController = newCameraCreator.new()
		instantiatedCameraControllers[newCameraCreator] = newCameraController
	else
		newCameraController = instantiatedCameraControllers[newCameraCreator]
	end
	
	-- If there is a controller active and it's not the one we need, disable it,
	-- if it is the one we need, make sure it's enabled
	if self.activeCameraController then
		if self.activeCameraController ~= newCameraController then
			self.activeCameraController:Enable(false)
			self.activeCameraController = newCameraController
			self.activeCameraController:Enable(true)		
		elseif not self.activeCameraController:GetEnabled() then
			self.activeCameraController:Enable(true)
		end		
	elseif newCameraController ~= nil then
		self.activeCameraController = newCameraController
		self.activeCameraController:Enable(true)		
	end
	
	if self.activeCameraController then
		if cameraMovementMode~=nil then
			self.activeCameraController:SetCameraMovementMode(cameraMovementMode)
		elseif legacyCameraType~=nil then
			-- Note that this is only called when legacyCameraType is not a type that
			-- was convertible to a ComputerCameraMovementMode value, i.e. really only applies to LegacyCamera
			self.activeCameraController:SetCameraType(legacyCameraType)
		end
	end
end

-- Note: The active transparency controller could be made to listen for this event itself.
function CameraModule:OnCameraSubjectChanged()
	if self.activeTransparencyController then
		self.activeTransparencyController:SetSubject(game.Workspace.CurrentCamera.CameraSubject)
	end
	
	if self.activeOcclusionModule then
		self.activeOcclusionModule:OnCameraSubjectChanged(game.Workspace.CurrentCamera.CameraSubject)
	end
end

function CameraModule:OnCameraTypeChanged(newCameraType)
	if newCameraType == Enum.CameraType.Scriptable then
		if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	end
	
	-- Forward the change to ActivateCameraController to handle
	self:ActivateCameraController(nil, newCameraType)	
end

-- Note: Called whenever workspace.CurrentCamera changes, but also on initialization of this script
function CameraModule:OnCurrentCameraChanged()
	local currentCamera = game.Workspace.CurrentCamera
	if not currentCamera then return end
	
	if self.cameraSubjectChangedConn then
		self.cameraSubjectChangedConn:Disconnect()
	end

	if self.cameraTypeChangedConn then
		self.cameraTypeChangedConn:Disconnect()
	end

	self.cameraSubjectChangedConn = currentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
		self:OnCameraSubjectChanged(currentCamera.CameraSubject)
	end)

	self.cameraTypeChangedConn = currentCamera:GetPropertyChangedSignal("CameraType"):Connect(function()
		self:OnCameraTypeChanged(currentCamera.CameraType)
	end)

	self:OnCameraSubjectChanged(currentCamera.CameraSubject)
	self:OnCameraTypeChanged(currentCamera.CameraType)
end

function CameraModule:OnLocalPlayerCameraPropertyChanged(propertyName)
	if propertyName == "CameraMode" then
		-- CameraMode is only used to turn on/off forcing the player into first person view. The
		-- Note: The case "Classic" is used for all other views and does not correspond only to the ClassicCamera module
		if Players.LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
			-- Locked in first person, use ClassicCamera which supports this
			if not self.activeCameraController or self.activeCameraController:GetModuleName() ~= "ClassicCamera" then
				self:ActivateCameraController(CameraUtils.ConvertCameraModeEnumToStandard(Enum.DevComputerCameraMovementMode.Classic))
			end
			
			if self.activeCameraController then
				self.activeCameraController:UpdateForDistancePropertyChange()
			end
		elseif Players.LocalPlayer.CameraMode == Enum.CameraMode.Classic then
			-- Not locked in first person view
			local cameraMovementMode =self: GetCameraMovementModeFromSettings()
			self:ActivateCameraController(CameraUtils.ConvertCameraModeEnumToStandard(cameraMovementMode))
		else
			warn("Unhandled value for property player.CameraMode: ",Players.LocalPlayer.CameraMode)
		end
	
	elseif propertyName == "DevComputerCameraMode" or 
		   propertyName == "DevTouchCameraMode" then
		local cameraMovementMode = self:GetCameraMovementModeFromSettings()
		self:ActivateCameraController(CameraUtils.ConvertCameraModeEnumToStandard(cameraMovementMode))
		
	elseif propertyName == "DevCameraOcclusionMode" then
		self:ActivateOcclusionModule(Players.LocalPlayer.DevCameraOcclusionMode)
		
	elseif propertyName == "CameraMinZoomDistance" or propertyName == "CameraMaxZoomDistance" then
		if self.activeCameraController then
			self.activeCameraController:UpdateForDistancePropertyChange()
		end
	elseif propertyName == "DevTouchMovementMode" then
		
	elseif propertyName == "DevComputerMovementMode" then
		
	elseif propertyName == "DevEnableMouseLock" then
		-- This is the enabling/disabling of "Shift Lock" mode, not LockFirstPerson (which is a CameraMode)
		
		-- Note: Enabling and disabling of MouseLock mode is normally only a publish-time choice made via
		-- the corresponding EnableMouseLockOption checkbox of StarterPlayer, and this script does not have
		-- support for changing the availability of MouseLock at runtime (this would require listening to
		-- Player.DevEnableMouseLock changes)
	end
end

function CameraModule:OnUserGameSettingsPropertyChanged(propertyName)
	
	if propertyName == 	"ComputerCameraMovementMode" then
		local cameraMovementMode = self:GetCameraMovementModeFromSettings()
		self:ActivateCameraController(CameraUtils.ConvertCameraModeEnumToStandard(cameraMovementMode))
	end
end



--[[	
	Main RenderStep Update. The camera controller and occlusion module both have opportunities
	to set and modify (respectively) the CFrame and Focus before it is set once on CurrentCamera.
	The camera and occlusion modules should only return CFrames, not set the CFrame property of
	CurrentCamera directly.	
--]]
function CameraModule:Update(dt)
	if self.activeCameraController then
		local newCameraCFrame, newCameraFocus = self.activeCameraController:Update(dt)
		self.activeCameraController:ApplyVRTransform()
		if self.activeOcclusionModule then
			newCameraCFrame, newCameraFocus = self.activeOcclusionModule:Update(dt, newCameraCFrame, newCameraFocus)
		end
		
		-- Here is where the new CFrame and Focus are set for this render frame
		game.Workspace.CurrentCamera.CFrame = newCameraCFrame
		game.Workspace.CurrentCamera.Focus = newCameraFocus
		
		-- Update to character local transparency as needed based on camera-to-subject distance
		if self.activeTransparencyController then
			self.activeTransparencyController:Update()
		end
	end
end

-- Formerly getCurrentCameraMode, this function resolves developer and user camera control settings to
-- decide which camera control module should be instantiated. The old method of converting redundant enum types
function CameraModule:GetCameraControlChoice()
	local player = Players.LocalPlayer
	
	if player then
		if self.lastInputType == Enum.UserInputType.Touch or UserInputService.TouchEnabled then
			-- Touch			
			if player.DevTouchCameraMode == Enum.DevTouchCameraMovementMode.UserChoice then
				return CameraUtils.ConvertCameraModeEnumToStandard( UserGameSettings.TouchCameraMovementMode )
			else
				return CameraUtils.ConvertCameraModeEnumToStandard( player.DevTouchCameraMode )
			end
		else
			-- Computer
			if player.DevComputerCameraMode == Enum.DevComputerCameraMovementMode.UserChoice then
				local computerMovementMode = CameraUtils.ConvertCameraModeEnumToStandard(UserGameSettings.ComputerCameraMovementMode)
				return CameraUtils.ConvertCameraModeEnumToStandard(computerMovementMode)
			else
				return CameraUtils.ConvertCameraModeEnumToStandard(player.DevComputerCameraMode)
			end
		end
	end
end


function CameraModule:OnCharacterAdded(char, player)
	if self.activeOcclusionModule then
		self.activeOcclusionModule:CharacterAdded(char, player)
	end
end

function CameraModule:OnCharacterRemoving(char, player)
	if self.activeOcclusionModule then
		self.activeOcclusionModule:CharacterRemoving(char, player)
	end
end

function CameraModule:OnPlayerAdded(player)
	player.CharacterAdded:Connect(function(char)
		self:OnCharacterAdded(char, player)
	end)
	player.CharacterRemoving:Connect(function(char)
		self:OnCharacterRemoving(char, player)
	end)
end

function CameraModule:OnMouseLockToggled()
	if self.activeMouseLockController then
		local mouseLocked = self.activeMouseLockController:GetIsMouseLocked()
		local mouseLockOffset = self.activeMouseLockController:GetMouseLockOffset()
		if self.activeCameraController then
			self.activeCameraController:SetIsMouseLocked(mouseLocked)
			self.activeCameraController:SetMouseLockOffset(mouseLockOffset)
		end
	end
end

return CameraModule.new()

-- HappaTAS Forked Script [lines 112-124]

--[[
	BaseCamera - Abstract base class for camera control modules
	2018 Camera Update - AllYourBlox
	
	Line 1274
--]]

--[[ Local Constants ]]--
local UNIT_Z = Vector3.new(0,0,1)
local X1_Y0_Z1 = Vector3.new(1,0,1)	--Note: not a unit vector, used for projecting onto XZ plane

local THUMBSTICK_DEADZONE = 0.2
local DEFAULT_DISTANCE = 12.5	-- Studs
local PORTRAIT_DEFAULT_DISTANCE = 25		-- Studs
local FIRST_PERSON_DISTANCE_THRESHOLD = 1.0 -- Below this value, snap into first person

local CAMERA_ACTION_PRIORITY = Enum.ContextActionPriority.Default.Value

-- Note: DotProduct check in CoordinateFrame::lookAt() prevents using values within about
-- 8.11 degrees of the +/- Y axis, that's why these limits are currently 80 degrees
local MIN_Y = math.rad(-80)
local MAX_Y = math.rad(80)

local TOUCH_ADJUST_AREA_UP = math.rad(30)
local TOUCH_ADJUST_AREA_DOWN = math.rad(-15)

local TOUCH_SENSITIVTY_ADJUST_MAX_Y = 2.1
local TOUCH_SENSITIVTY_ADJUST_MIN_Y = 0.5

local VR_ANGLE = math.rad(15)
local VR_LOW_INTENSITY_ROTATION = Vector2.new(math.rad(15), 0)
local VR_HIGH_INTENSITY_ROTATION = Vector2.new(math.rad(45), 0)
local VR_LOW_INTENSITY_REPEAT = 0.1
local VR_HIGH_INTENSITY_REPEAT = 0.4

local ZERO_VECTOR2 = Vector2.new(0,0)
local ZERO_VECTOR3 = Vector3.new(0,0,0)

local touchSensitivityFlagExists, touchSensitivityFlagEnabled = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserTouchSensitivityAdjust")
end)
local FFlagUserTouchSensitivityAdjust = touchSensitivityFlagExists and touchSensitivityFlagEnabled

local TOUCH_SENSITIVTY = Vector2.new(0.0045 * math.pi, 0.003375 * math.pi)
if FFlagUserTouchSensitivityAdjust then
	TOUCH_SENSITIVTY = Vector2.new(0.00945 * math.pi, 0.003375 * math.pi)
end
local MOUSE_SENSITIVITY = Vector2.new( 0.002 * math.pi, 0.0015 * math.pi )

local SEAT_OFFSET = Vector3.new(0,5,0)
local VR_SEAT_OFFSET = Vector3.new(0,4,0)
local HEAD_OFFSET = Vector3.new(0,1.5,0)
local R15_HEAD_OFFSET = Vector3.new(0, 1.5, 0)
local R15_HEAD_OFFSET_NO_SCALING = Vector3.new(0, 2, 0)
local HUMANOID_ROOT_PART_SIZE = Vector3.new(2, 2, 1)

local GAMEPAD_ZOOM_STEP_1 = 0
local GAMEPAD_ZOOM_STEP_2 = 10
local GAMEPAD_ZOOM_STEP_3 = 20

local PAN_SENSITIVITY = 20
local ZOOM_SENSITIVITY_CURVATURE = 0.5

local abs = math.abs
local sign = math.sign

local thirdGamepadZoomStepFlagExists, thirdGamepadZoomStepFlagEnabled = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserThirdGamepadZoomStep")
end)
local FFlagUserThirdGamepadZoomStep = thirdGamepadZoomStepFlagExists and thirdGamepadZoomStepFlagEnabled

local FFlagUserPointerActionsInPlayerScripts do
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserPointerActionsInPlayerScripts")
	end)
	FFlagUserPointerActionsInPlayerScripts = success and result
end

local FFlagUserNoMoreKeyboardPan do
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserNoMoreKeyboardPan")
	end)
	FFlagUserNoMoreKeyboardPan = success and result
end

local fixZoomIssuesFlagExists, fixZoomIssuesFlagEnabled = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFixZoomClampingIssues")
end)
local FFlagUserFixZoomClampingIssues = fixZoomIssuesFlagExists and fixZoomIssuesFlagEnabled

local Util = require(script.Parent:WaitForChild("CameraUtils"))
local ZoomController = require(script.Parent:WaitForChild("ZoomController"))

--[[ Roblox Services ]]--
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local VRService = game:GetService("VRService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

--[[ The Module ]]--
local BaseCamera = {}
BaseCamera.__index = BaseCamera

function BaseCamera.new()
	local self = setmetatable({}, BaseCamera)
	
	local BaseCameras = game.ReplicatedStorage:WaitForChild("TASRS"):WaitForChild("BaseCameras")
	
	BaseCameras.Value += 1
	
	if BaseCameras.Value == 1 then
		game.ReplicatedStorage.TASRS.BindableFunctions.GetZoom.OnInvoke = function()
			return self:GetCameraToSubjectDistance()
		end
		
		game.ReplicatedStorage.TASRS.BindableEvents.SetZoom.Event:Connect(function(dist)
			self:SetCameraToSubjectDistance(dist)
		end)
	end

	-- So that derived classes have access to this
	self.FIRST_PERSON_DISTANCE_THRESHOLD = FIRST_PERSON_DISTANCE_THRESHOLD

	self.cameraType = nil
	self.cameraMovementMode = nil

	local player = Players.LocalPlayer
	self.lastCameraTransform = nil
	self.rotateInput = ZERO_VECTOR2
	self.userPanningCamera = false
	self.lastUserPanCamera = tick()

	self.humanoidRootPart = nil
	self.humanoidCache = {}

	-- Subject and position on last update call
	self.lastSubject = nil
	self.lastSubjectPosition = Vector3.new(0,5,0)

	-- These subject distance members refer to the nominal camera-to-subject follow distance that the camera
	-- is trying to maintain, not the actual measured value.
	-- The default is updated when screen orientation or the min/max distances change,
	-- to be sure the default is always in range and appropriate for the orientation.
	self.defaultSubjectDistance = Util.Clamp(player.CameraMinZoomDistance, player.CameraMaxZoomDistance, DEFAULT_DISTANCE)
	self.currentSubjectDistance = Util.Clamp(player.CameraMinZoomDistance, player.CameraMaxZoomDistance, DEFAULT_DISTANCE)

	self.inFirstPerson = false
	self.inMouseLockedMode = false
	self.portraitMode = false
	self.isSmallTouchScreen = false

	-- Used by modules which want to reset the camera angle on respawn.
	self.resetCameraAngle = true

	self.enabled = false

	-- Input Event Connections
	self.inputBeganConn = nil
	self.inputChangedConn = nil
	self.inputEndedConn = nil

	self.startPos = nil
	self.lastPos = nil
	self.panBeginLook = nil

	self.panEnabled = true
	self.keyPanEnabled = true
	self.distanceChangeEnabled = true

	self.PlayerGui = nil

	self.cameraChangedConn = nil
	self.viewportSizeChangedConn = nil

	self.boundContextActions = {}

	-- VR Support
	self.shouldUseVRRotation = false
	self.VRRotationIntensityAvailable = false
	self.lastVRRotationIntensityCheckTime = 0
	self.lastVRRotationTime = 0
	self.vrRotateKeyCooldown = {}
	self.cameraTranslationConstraints = Vector3.new(1, 1, 1)
	self.humanoidJumpOrigin = nil
	self.trackingHumanoid = nil
	self.cameraFrozen = false
	self.subjectStateChangedConn = nil

	-- Gamepad support
	self.activeGamepad = nil
	self.gamepadPanningCamera = false
	self.lastThumbstickRotate = nil
	self.numOfSeconds = 0.7
	self.currentSpeed = 0
	self.maxSpeed = 6
	self.vrMaxSpeed = 4
	self.lastThumbstickPos = Vector2.new(0,0)
	self.ySensitivity = 0.65
	self.lastVelocity = nil
	self.gamepadConnectedConn = nil
	self.gamepadDisconnectedConn = nil
	self.currentZoomSpeed = 1.0
	self.L3ButtonDown = false
	self.dpadLeftDown = false
	self.dpadRightDown = false

	-- Touch input support
	self.isDynamicThumbstickEnabled = false
	self.fingerTouches = {}
	self.dynamicTouchInput = nil
	self.numUnsunkTouches = 0
	self.inputStartPositions = {}
	self.inputStartTimes = {}
	self.startingDiff = nil
	self.pinchBeginZoom = nil
	self.userPanningTheCamera = false
	self.touchActivateConn = nil

	-- Mouse locked formerly known as shift lock mode
	self.mouseLockOffset = ZERO_VECTOR3

	-- [[ NOTICE ]] --
	-- Initialization things used to always execute at game load time, but now these camera modules are instantiated
	-- when needed, so the code here may run well after the start of the game

	if player.Character then
		self:OnCharacterAdded(player.Character)
	end

	player.CharacterAdded:Connect(function(char)
		self:OnCharacterAdded(char)
	end)

	if self.cameraChangedConn then self.cameraChangedConn:Disconnect() end
	self.cameraChangedConn = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		self:OnCurrentCameraChanged()
	end)
	self:OnCurrentCameraChanged()

	if self.playerCameraModeChangeConn then self.playerCameraModeChangeConn:Disconnect() end
	self.playerCameraModeChangeConn = player:GetPropertyChangedSignal("CameraMode"):Connect(function()
		self:OnPlayerCameraPropertyChange()
	end)

	if self.minDistanceChangeConn then self.minDistanceChangeConn:Disconnect() end
	self.minDistanceChangeConn = player:GetPropertyChangedSignal("CameraMinZoomDistance"):Connect(function()
		self:OnPlayerCameraPropertyChange()
	end)

	if self.maxDistanceChangeConn then self.maxDistanceChangeConn:Disconnect() end
	self.maxDistanceChangeConn = player:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(function()
		self:OnPlayerCameraPropertyChange()
	end)

	if self.playerDevTouchMoveModeChangeConn then self.playerDevTouchMoveModeChangeConn:Disconnect() end
	self.playerDevTouchMoveModeChangeConn = player:GetPropertyChangedSignal("DevTouchMovementMode"):Connect(function()
		self:OnDevTouchMovementModeChanged()
	end)
	self:OnDevTouchMovementModeChanged() -- Init

	if self.gameSettingsTouchMoveMoveChangeConn then self.gameSettingsTouchMoveMoveChangeConn:Disconnect() end
	self.gameSettingsTouchMoveMoveChangeConn = UserGameSettings:GetPropertyChangedSignal("TouchMovementMode"):Connect(function()
		self:OnGameSettingsTouchMovementModeChanged()
	end)
	self:OnGameSettingsTouchMovementModeChanged() -- Init

	UserGameSettings:SetCameraYInvertVisible()
	UserGameSettings:SetGamepadCameraSensitivityVisible()

	self.hasGameLoaded = game:IsLoaded()
	if not self.hasGameLoaded then
		self.gameLoadedConn = game.Loaded:Connect(function()
			self.hasGameLoaded = true
			self.gameLoadedConn:Disconnect()
			self.gameLoadedConn = nil
		end)
	end

	if FFlagUserFixZoomClampingIssues then
		self:OnPlayerCameraPropertyChange()
	end

	return self
end

function BaseCamera:GetModuleName()
	return "BaseCamera"
end

function BaseCamera:OnCharacterAdded(char)
	self.resetCameraAngle = self.resetCameraAngle or self:GetEnabled()
	self.humanoidRootPart = nil
	if UserInputService.TouchEnabled then
		self.PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		for _, child in ipairs(char:GetChildren()) do
			if child:IsA("Tool") then
				self.isAToolEquipped = true
			end
		end
		char.ChildAdded:Connect(function(child)
			if child:IsA("Tool") then
				self.isAToolEquipped = true
			end
		end)
		char.ChildRemoved:Connect(function(child)
			if child:IsA("Tool") then
				self.isAToolEquipped = false
			end
		end)
	end
end

function BaseCamera:GetHumanoidRootPart()
	if not self.humanoidRootPart then
		local player = Players.LocalPlayer
		if player.Character then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				self.humanoidRootPart = humanoid.RootPart
			end
		end
	end
	return self.humanoidRootPart
end

function BaseCamera:GetBodyPartToFollow(humanoid, isDead)
	-- If the humanoid is dead, prefer the head part if one still exists as a sibling of the humanoid
	if humanoid:GetState() == Enum.HumanoidStateType.Dead then
		local character = humanoid.Parent
		if character and character:IsA("Model") then
			return character:FindFirstChild("Head") or humanoid.RootPart
		end
	end

	return humanoid.RootPart
end

function BaseCamera:GetSubjectPosition()
	local result = self.lastSubjectPosition
	local camera = game.Workspace.CurrentCamera
	local cameraSubject = camera and camera.CameraSubject

	if cameraSubject then
		if cameraSubject:IsA("Humanoid") then
			local humanoid = cameraSubject
			local humanoidIsDead = humanoid:GetState() == Enum.HumanoidStateType.Dead

			if VRService.VREnabled and humanoidIsDead and humanoid == self.lastSubject then
				result = self.lastSubjectPosition
			else
				local bodyPartToFollow = humanoid.RootPart

				-- If the humanoid is dead, prefer their head part as a follow target, if it exists
				if humanoidIsDead then
					if humanoid.Parent and humanoid.Parent:IsA("Model") then
						bodyPartToFollow = humanoid.Parent:FindFirstChild("Head") or bodyPartToFollow
					end
				end

				if bodyPartToFollow and bodyPartToFollow:IsA("BasePart") then
					local heightOffset
					if humanoid.RigType == Enum.HumanoidRigType.R15 then
						if humanoid.AutomaticScalingEnabled then
							heightOffset = R15_HEAD_OFFSET
							if bodyPartToFollow == humanoid.RootPart then
								local rootPartSizeOffset = (humanoid.RootPart.Size.Y/2) - (HUMANOID_ROOT_PART_SIZE.Y/2)
								heightOffset = heightOffset + Vector3.new(0, rootPartSizeOffset, 0)
							end
						else
							heightOffset = R15_HEAD_OFFSET_NO_SCALING
						end
					else
						heightOffset = HEAD_OFFSET
					end

					if humanoidIsDead then
						heightOffset = ZERO_VECTOR3
					end

					result = bodyPartToFollow.CFrame.p + bodyPartToFollow.CFrame:vectorToWorldSpace(heightOffset + humanoid.CameraOffset)
				end
			end

		elseif cameraSubject:IsA("VehicleSeat") then
			local offset = SEAT_OFFSET
			if VRService.VREnabled then
				offset = VR_SEAT_OFFSET
			end
			result = cameraSubject.CFrame.p + cameraSubject.CFrame:vectorToWorldSpace(offset)
		elseif cameraSubject:IsA("SkateboardPlatform") then
			result = cameraSubject.CFrame.p + SEAT_OFFSET
		elseif cameraSubject:IsA("BasePart") then
			result = cameraSubject.CFrame.p
		elseif cameraSubject:IsA("Model") then
			if cameraSubject.PrimaryPart then
				result = cameraSubject:GetPrimaryPartCFrame().p
			else
				result = cameraSubject:GetModelCFrame().p
			end
		end
	else
		-- cameraSubject is nil
		-- Note: Previous RootCamera did not have this else case and let self.lastSubject and self.lastSubjectPosition
		-- both get set to nil in the case of cameraSubject being nil. This function now exits here to preserve the
		-- last set valid values for these, as nil values are not handled cases
		return
	end

	self.lastSubject = cameraSubject
	self.lastSubjectPosition = result

	return result
end

function BaseCamera:UpdateDefaultSubjectDistance()
	local player = Players.LocalPlayer
	if self.portraitMode then
		self.defaultSubjectDistance = Util.Clamp(player.CameraMinZoomDistance, player.CameraMaxZoomDistance, PORTRAIT_DEFAULT_DISTANCE)
	else
		self.defaultSubjectDistance = Util.Clamp(player.CameraMinZoomDistance, player.CameraMaxZoomDistance, DEFAULT_DISTANCE)
	end
end

function BaseCamera:OnViewportSizeChanged()
	local camera = game.Workspace.CurrentCamera
	local size = camera.ViewportSize
	self.portraitMode = size.X < size.Y
	self.isSmallTouchScreen = UserInputService.TouchEnabled and (size.Y < 500 or size.X < 700)

	self:UpdateDefaultSubjectDistance()
end

-- Listener for changes to workspace.CurrentCamera
function BaseCamera:OnCurrentCameraChanged()
	if UserInputService.TouchEnabled then
		if self.viewportSizeChangedConn then
			self.viewportSizeChangedConn:Disconnect()
			self.viewportSizeChangedConn = nil
		end

		local newCamera = game.Workspace.CurrentCamera

		if newCamera then
			self:OnViewportSizeChanged()
			self.viewportSizeChangedConn = newCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				self:OnViewportSizeChanged()
			end)
		end
	end

	-- VR support additions
	if self.cameraSubjectChangedConn then
		self.cameraSubjectChangedConn:Disconnect()
		self.cameraSubjectChangedConn = nil
	end

	local camera = game.Workspace.CurrentCamera
	if camera then
		self.cameraSubjectChangedConn = camera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
			self:OnNewCameraSubject()
		end)
		self:OnNewCameraSubject()
	end
end

function BaseCamera:OnDynamicThumbstickEnabled()
	if UserInputService.TouchEnabled then
		self.isDynamicThumbstickEnabled = true
	end
end

function BaseCamera:OnDynamicThumbstickDisabled()
	self.isDynamicThumbstickEnabled = false
end

function BaseCamera:OnGameSettingsTouchMovementModeChanged()
	if Players.LocalPlayer.DevTouchMovementMode == Enum.DevTouchMovementMode.UserChoice then
		if (UserGameSettings.TouchMovementMode == Enum.TouchMovementMode.DynamicThumbstick
			or UserGameSettings.TouchMovementMode == Enum.TouchMovementMode.Default) then
			self:OnDynamicThumbstickEnabled()
		else
			self:OnDynamicThumbstickDisabled()
		end
	end
end

function BaseCamera:OnDevTouchMovementModeChanged()
	if Players.LocalPlayer.DevTouchMovementMode.Name == "DynamicThumbstick" then
		self:OnDynamicThumbstickEnabled()
	else
		self:OnGameSettingsTouchMovementModeChanged()
	end
end

function BaseCamera:OnPlayerCameraPropertyChange()
	-- This call forces re-evaluation of player.CameraMode and clamping to min/max distance which may have changed
	self:SetCameraToSubjectDistance(self.currentSubjectDistance)
end

function BaseCamera:GetCameraHeight()
	if VRService.VREnabled and not self.inFirstPerson then
		return math.sin(VR_ANGLE) * self.currentSubjectDistance
	end
	return 0
end

function BaseCamera:InputTranslationToCameraAngleChange(translationVector, sensitivity)
	local camera = game.Workspace.CurrentCamera
	if camera and camera.ViewportSize.X > 0 and camera.ViewportSize.Y > 0 and (camera.ViewportSize.Y > camera.ViewportSize.X) then
		-- Screen has portrait orientation, swap X and Y sensitivity
		return translationVector * Vector2.new( sensitivity.Y, sensitivity.X)
	end
	return translationVector * sensitivity
end

function BaseCamera:Enable(enable)
	if self.enabled ~= enable then
		self.enabled = enable
		if self.enabled then
			self:ConnectInputEvents()
			self:BindContextActions()

			if Players.LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
				self.currentSubjectDistance = 0.5
				if not self.inFirstPerson then
					self:EnterFirstPerson()
				end
			end
		else
			self:DisconnectInputEvents()
			self:UnbindContextActions()
			-- Clean up additional event listeners and reset a bunch of properties
			self:Cleanup()
		end
	end
end

function BaseCamera:GetEnabled()
	return self.enabled
end

function BaseCamera:OnInputBegan(input, processed)
	if input.UserInputType == Enum.UserInputType.Touch then
		self:OnTouchBegan(input, processed)
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		self:OnMouse2Down(input, processed)
	elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
		self:OnMouse3Down(input, processed)
	end
end

function BaseCamera:OnInputChanged(input, processed)
	if input.UserInputType == Enum.UserInputType.Touch then
		self:OnTouchChanged(input, processed)
	elseif input.UserInputType == Enum.UserInputType.MouseMovement then
		self:OnMouseMoved(input, processed)
	elseif input.UserInputType == Enum.UserInputType.MouseWheel and not FFlagUserPointerActionsInPlayerScripts then -- remove with FFlagUserPointerActionsInPlayerScripts
		self:OnMouseWheel(input, processed)
	end
end

function BaseCamera:OnInputEnded(input, processed)
	if input.UserInputType == Enum.UserInputType.Touch then
		self:OnTouchEnded(input, processed)
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		self:OnMouse2Up(input, processed)
	elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
		self:OnMouse3Up(input, processed)
	end
end

function BaseCamera:OnPointerAction(wheel, pan, pinch, processed)
	if processed then
		return
	end

	if pan.Magnitude > 0 then
		local inversionVector = Vector2.new(1, UserGameSettings:GetCameraYInvertValue())
		local rotateDelta = self:InputTranslationToCameraAngleChange(PAN_SENSITIVITY*pan, MOUSE_SENSITIVITY)*inversionVector
		self.rotateInput = self.rotateInput + rotateDelta
	end

	local zoom = self.currentSubjectDistance
	local zoomDelta = -(wheel + pinch)

	if abs(zoomDelta) > 0 then
		local newZoom
		if self.inFirstPerson and zoomDelta > 0 then
			newZoom = FIRST_PERSON_DISTANCE_THRESHOLD
		else
			newZoom = zoom + zoomDelta*(1 + zoom*ZOOM_SENSITIVITY_CURVATURE)
		end

		self:SetCameraToSubjectDistance(newZoom)
	end
end

function BaseCamera:ConnectInputEvents()
	if FFlagUserPointerActionsInPlayerScripts then
		self.pointerActionConn = UserInputService.PointerAction:Connect(function(wheel, pan, pinch, processed)
			self:OnPointerAction(wheel, pan, pinch, processed)
		end)
	end

	self.inputBeganConn = UserInputService.InputBegan:Connect(function(input, processed)
		self:OnInputBegan(input, processed)
	end)

	self.inputChangedConn = UserInputService.InputChanged:Connect(function(input, processed)
		self:OnInputChanged(input, processed)
	end)

	self.inputEndedConn = UserInputService.InputEnded:Connect(function(input, processed)
		self:OnInputEnded(input, processed)
	end)

	self.menuOpenedConn = GuiService.MenuOpened:connect(function()
		self:ResetInputStates()
	end)

	self.gamepadConnectedConn = UserInputService.GamepadDisconnected:connect(function(gamepadEnum)
		if self.activeGamepad ~= gamepadEnum then return end
		self.activeGamepad = nil
		self:AssignActivateGamepad()
	end)

	self.gamepadDisconnectedConn = UserInputService.GamepadConnected:connect(function(gamepadEnum)
		if self.activeGamepad == nil then
			self:AssignActivateGamepad()
		end
	end)

	self:AssignActivateGamepad()
	self:UpdateMouseBehavior()
end

function BaseCamera:BindContextActions()
	self:BindGamepadInputActions()
	self:BindKeyboardInputActions()
end

function BaseCamera:AssignActivateGamepad()
	local connectedGamepads = UserInputService:GetConnectedGamepads()
	if #connectedGamepads > 0 then
		for i = 1, #connectedGamepads do
			if self.activeGamepad == nil then
				self.activeGamepad = connectedGamepads[i]
			elseif connectedGamepads[i].Value < self.activeGamepad.Value then
				self.activeGamepad = connectedGamepads[i]
			end
		end
	end

	if self.activeGamepad == nil then -- nothing is connected, at least set up for gamepad1
		self.activeGamepad = Enum.UserInputType.Gamepad1
	end
end

function BaseCamera:DisconnectInputEvents()
	if self.inputBeganConn then
		self.inputBeganConn:Disconnect()
		self.inputBeganConn = nil
	end
	if self.inputChangedConn then
		self.inputChangedConn:Disconnect()
		self.inputChangedConn = nil
	end
	if self.inputEndedConn then
		self.inputEndedConn:Disconnect()
		self.inputEndedConn = nil
	end
end

function BaseCamera:UnbindContextActions()
	for i = 1, #self.boundContextActions do
		ContextActionService:UnbindAction(self.boundContextActions[i])
	end
	self.boundContextActions = {}
end

function BaseCamera:Cleanup()
	if FFlagUserPointerActionsInPlayerScripts and self.pointerActionConn then
		self.pointerActionConn:Disconnect()
		self.pointerActionConn = nil
	end
	if self.menuOpenedConn then
		self.menuOpenedConn:Disconnect()
		self.menuOpenedConn = nil
	end
	if self.mouseLockToggleConn then
		self.mouseLockToggleConn:Disconnect()
		self.mouseLockToggleConn = nil
	end
	if self.gamepadConnectedConn then
		self.gamepadConnectedConn:Disconnect()
		self.gamepadConnectedConn = nil
	end
	if self.gamepadDisconnectedConn then
		self.gamepadDisconnectedConn:Disconnect()
		self.gamepadDisconnectedConn = nil
	end
	if self.subjectStateChangedConn then
		self.subjectStateChangedConn:Disconnect()
		self.subjectStateChangedConn = nil
	end
	if self.viewportSizeChangedConn then
		self.viewportSizeChangedConn:Disconnect()
		self.viewportSizeChangedConn = nil
	end
	if self.touchActivateConn then
		self.touchActivateConn:Disconnect()
		self.touchActivateConn = nil
	end

	self.turningLeft = false
	self.turningRight = false
	self.lastCameraTransform = nil
	self.lastSubjectCFrame = nil
	self.userPanningTheCamera = false
	self.rotateInput = Vector2.new()
	self.gamepadPanningCamera = Vector2.new(0,0)

	-- Reset input states
	self.startPos = nil
	self.lastPos = nil
	self.panBeginLook = nil
	self.isRightMouseDown = false
	self.isMiddleMouseDown = false

	self.fingerTouches = {}
	self.dynamicTouchInput = nil
	self.numUnsunkTouches = 0

	self.startingDiff = nil
	self.pinchBeginZoom = nil

	-- Unlock mouse for example if right mouse button was being held down
	if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end

-- This is called when settings menu is opened
function BaseCamera:ResetInputStates()
	self.isRightMouseDown = false
	self.isMiddleMouseDown = false
	self:OnMousePanButtonReleased() -- this function doesn't seem to actually need parameters

	if UserInputService.TouchEnabled then
		--[[menu opening was causing serious touch issues
		this should disable all active touch events if
		they're active when menu opens.]]
		for inputObject in pairs(self.fingerTouches) do
			self.fingerTouches[inputObject] = nil
		end
		self.dynamicTouchInput = nil
		self.panBeginLook = nil
		self.startPos = nil
		self.lastPos = nil
		self.userPanningTheCamera = false
		self.startingDiff = nil
		self.pinchBeginZoom = nil
		self.numUnsunkTouches = 0
	end
end

function BaseCamera:GetGamepadPan(name, state, input)
	if input.UserInputType == self.activeGamepad and input.KeyCode == Enum.KeyCode.Thumbstick2 then
--		if self.L3ButtonDown then
--			-- L3 Thumbstick is depressed, right stick controls dolly in/out
--			if (input.Position.Y > THUMBSTICK_DEADZONE) then
--				self.currentZoomSpeed = 0.96
--			elseif (input.Position.Y < -THUMBSTICK_DEADZONE) then
--				self.currentZoomSpeed = 1.04
--			else
--				self.currentZoomSpeed = 1.00
--			end
--		else
			if state == Enum.UserInputState.Cancel then
				self.gamepadPanningCamera = ZERO_VECTOR2
				return
			end

			local inputVector = Vector2.new(input.Position.X, -input.Position.Y)
			if inputVector.magnitude > THUMBSTICK_DEADZONE then
				self.gamepadPanningCamera = Vector2.new(input.Position.X, -input.Position.Y)
			else
				self.gamepadPanningCamera = ZERO_VECTOR2
			end
		--end
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end

function BaseCamera:DoKeyboardPanTurn(name, state, input)
	if not self.hasGameLoaded and VRService.VREnabled then
		return Enum.ContextActionResult.Pass
	end

	if state == Enum.UserInputState.Cancel then
		self.turningLeft = false
		self.turningRight = false
		return Enum.ContextActionResult.Sink
	end

	if self.panBeginLook == nil and self.keyPanEnabled then
		if input.KeyCode == Enum.KeyCode.Left then
			self.turningLeft = state == Enum.UserInputState.Begin
		elseif input.KeyCode == Enum.KeyCode.Right then
			self.turningRight = state == Enum.UserInputState.Begin
		end
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end

function BaseCamera:DoPanRotateCamera(rotateAngle)
	local angle = Util.RotateVectorByAngleAndRound(self:GetCameraLookVector() * Vector3.new(1,0,1), rotateAngle, math.pi*0.25)
	if angle ~= 0 then
		self.rotateInput = self.rotateInput + Vector2.new(angle, 0)
		self.lastUserPanCamera = tick()
		self.lastCameraTransform = nil
	end
end

function BaseCamera:DoKeyboardPan(name, state, input)
	if FFlagUserNoMoreKeyboardPan or not self.hasGameLoaded and VRService.VREnabled then
		return Enum.ContextActionResult.Pass
	end

	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	if self.panBeginLook == nil and self.keyPanEnabled then
		if input.KeyCode == Enum.KeyCode.Comma then
			self:DoPanRotateCamera(-math.pi*0.1875)
		elseif input.KeyCode == Enum.KeyCode.Period then
			self:DoPanRotateCamera(math.pi*0.1875)
		elseif input.KeyCode == Enum.KeyCode.PageUp then
			self.rotateInput = self.rotateInput + Vector2.new(0,math.rad(15))
			self.lastCameraTransform = nil
		elseif input.KeyCode == Enum.KeyCode.PageDown then
			self.rotateInput = self.rotateInput + Vector2.new(0,math.rad(-15))
			self.lastCameraTransform = nil
		end
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end

function BaseCamera:DoGamepadZoom(name, state, input)
	if input.UserInputType == self.activeGamepad then
		if input.KeyCode == Enum.KeyCode.ButtonR3 then
			if state == Enum.UserInputState.Begin then
				if self.distanceChangeEnabled then
					local dist = self:GetCameraToSubjectDistance()
					if FFlagUserThirdGamepadZoomStep then
						if dist > (GAMEPAD_ZOOM_STEP_2 + GAMEPAD_ZOOM_STEP_3)/2 then
							self:SetCameraToSubjectDistance(GAMEPAD_ZOOM_STEP_2)
						elseif dist > (GAMEPAD_ZOOM_STEP_1 + GAMEPAD_ZOOM_STEP_2)/2 then
							self:SetCameraToSubjectDistance(GAMEPAD_ZOOM_STEP_1)
						else
							self:SetCameraToSubjectDistance(GAMEPAD_ZOOM_STEP_3)
						end
					else
						if dist > 0.5 then
							self:SetCameraToSubjectDistance(0)
						else
							self:SetCameraToSubjectDistance(10)
						end
					end
				end
			end
		elseif input.KeyCode == Enum.KeyCode.DPadLeft then
			self.dpadLeftDown = (state == Enum.UserInputState.Begin)
		elseif input.KeyCode == Enum.KeyCode.DPadRight then
			self.dpadRightDown = (state == Enum.UserInputState.Begin)
		end

		if self.dpadLeftDown then
			self.currentZoomSpeed = 1.04
		elseif self.dpadRightDown then
			self.currentZoomSpeed = 0.96
		else
			self.currentZoomSpeed = 1.00
		end
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
--	elseif input.UserInputType == self.activeGamepad and input.KeyCode == Enum.KeyCode.ButtonL3 then
--		if (state == Enum.UserInputState.Begin) then
--			self.L3ButtonDown = true
--		elseif (state == Enum.UserInputState.End) then
--			self.L3ButtonDown = false
--			self.currentZoomSpeed = 1.00
--		end
--	end
end

function BaseCamera:DoKeyboardZoom(name, state, input)
	if not self.hasGameLoaded and VRService.VREnabled then
		return Enum.ContextActionResult.Pass
	end

	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	if self.distanceChangeEnabled and Players.LocalPlayer.CameraMode ~= Enum.CameraMode.LockFirstPerson then
		if input.KeyCode == Enum.KeyCode.I then
			self:SetCameraToSubjectDistance( self.currentSubjectDistance - 5 )
		elseif input.KeyCode == Enum.KeyCode.O then
			self:SetCameraToSubjectDistance( self.currentSubjectDistance + 5 )
		end
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end

function BaseCamera:BindAction(actionName, actionFunc, createTouchButton, ...)
	table.insert(self.boundContextActions, actionName)
	ContextActionService:BindActionAtPriority(actionName, actionFunc, createTouchButton,
		CAMERA_ACTION_PRIORITY, ...)
end

function BaseCamera:BindGamepadInputActions()
	self:BindAction("BaseCameraGamepadPan", function(name, state, input) return self:GetGamepadPan(name, state, input) end,
		false, Enum.KeyCode.Thumbstick2)
	self:BindAction("BaseCameraGamepadZoom", function(name, state, input) return self:DoGamepadZoom(name, state, input) end,
		false, Enum.KeyCode.DPadLeft, Enum.KeyCode.DPadRight, Enum.KeyCode.ButtonR3)
end

function BaseCamera:BindKeyboardInputActions()
	self:BindAction("BaseCameraKeyboardPanArrowKeys", function(name, state, input) return self:DoKeyboardPanTurn(name, state, input) end,
		false, Enum.KeyCode.Left, Enum.KeyCode.Right)
	self:BindAction("BaseCameraKeyboardPan", function(name, state, input) return self:DoKeyboardPan(name, state, input) end,
		false, Enum.KeyCode.Comma, Enum.KeyCode.Period, Enum.KeyCode.PageUp, Enum.KeyCode.PageDown)
	self:BindAction("BaseCameraKeyboardZoom", function(name, state, input) return self:DoKeyboardZoom(name, state, input) end,
		false, Enum.KeyCode.I, Enum.KeyCode.O)
end

local function isInDynamicThumbstickArea(input)
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
	local touchFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
	local thumbstickFrame = touchFrame and touchFrame:FindFirstChild("DynamicThumbstickFrame")

	if not thumbstickFrame then
		return false
	end

	local frameCornerTopLeft = thumbstickFrame.AbsolutePosition
	local frameCornerBottomRight = frameCornerTopLeft + thumbstickFrame.AbsoluteSize
	if input.Position.X >= frameCornerTopLeft.X and input.Position.Y >= frameCornerTopLeft.Y then
		if input.Position.X <= frameCornerBottomRight.X and input.Position.Y <= frameCornerBottomRight.Y then
			return true
		end
	end

	return false
end

---Adjusts the camera Y touch Sensitivity when moving away from the center and in the TOUCH_SENSITIVTY_ADJUST_AREA
function BaseCamera:AdjustTouchSensitivity(delta, sensitivity)
	local cameraCFrame = game.Workspace.CurrentCamera and game.Workspace.CurrentCamera.CFrame
	if not cameraCFrame then
		return sensitivity
	end
	local currPitchAngle = cameraCFrame:ToEulerAnglesYXZ()

	local multiplierY = TOUCH_SENSITIVTY_ADJUST_MAX_Y
	if currPitchAngle > TOUCH_ADJUST_AREA_UP and delta.Y < 0 then
		local fractionAdjust = (currPitchAngle - TOUCH_ADJUST_AREA_UP)/(MAX_Y - TOUCH_ADJUST_AREA_UP)
		fractionAdjust = 1 - (1 - fractionAdjust)^3
		multiplierY = TOUCH_SENSITIVTY_ADJUST_MAX_Y - fractionAdjust * (
			TOUCH_SENSITIVTY_ADJUST_MAX_Y - TOUCH_SENSITIVTY_ADJUST_MIN_Y)
	elseif currPitchAngle < TOUCH_ADJUST_AREA_DOWN and delta.Y > 0 then
		local fractionAdjust = (currPitchAngle - TOUCH_ADJUST_AREA_DOWN)/(MIN_Y - TOUCH_ADJUST_AREA_DOWN)
		fractionAdjust = 1 - (1 - fractionAdjust)^3
		multiplierY = TOUCH_SENSITIVTY_ADJUST_MAX_Y - fractionAdjust * (
			TOUCH_SENSITIVTY_ADJUST_MAX_Y - TOUCH_SENSITIVTY_ADJUST_MIN_Y)
	end

	return Vector2.new(
		sensitivity.X,
		sensitivity.Y * multiplierY
	)
end

function BaseCamera:OnTouchBegan(input, processed)
	local canUseDynamicTouch = self.isDynamicThumbstickEnabled and not processed
	if canUseDynamicTouch then
		if self.dynamicTouchInput == nil and isInDynamicThumbstickArea(input) then
			-- First input in the dynamic thumbstick area should always be ignored for camera purposes
			-- Even if the dynamic thumbstick does not process it immediately
			self.dynamicTouchInput = input
			return
		end
		self.fingerTouches[input] = processed
		self.inputStartPositions[input] = input.Position
		self.inputStartTimes[input] = tick()
		self.numUnsunkTouches = self.numUnsunkTouches + 1
	end
end

function BaseCamera:OnTouchChanged(input, processed)
	if self.fingerTouches[input] == nil then
		if self.isDynamicThumbstickEnabled then
			return
		end
		self.fingerTouches[input] = processed
		if not processed then
			self.numUnsunkTouches = self.numUnsunkTouches + 1
		end
	end

	if self.numUnsunkTouches == 1 then
		if self.fingerTouches[input] == false then
			self.panBeginLook = self.panBeginLook or self:GetCameraLookVector()
			self.startPos = self.startPos or input.Position
			self.lastPos = self.lastPos or self.startPos
			self.userPanningTheCamera = true

			local delta = input.Position - self.lastPos
			delta = Vector2.new(delta.X, delta.Y * UserGameSettings:GetCameraYInvertValue())
			if self.panEnabled then
				local adjustedTouchSensitivity = TOUCH_SENSITIVTY
				if FFlagUserTouchSensitivityAdjust then
					self:AdjustTouchSensitivity(delta, TOUCH_SENSITIVTY)
				end

				local desiredXYVector = self:InputTranslationToCameraAngleChange(delta, adjustedTouchSensitivity)
				self.rotateInput = self.rotateInput + desiredXYVector
			end
			self.lastPos = input.Position
		end
	else
		self.panBeginLook = nil
		self.startPos = nil
		self.lastPos = nil
		self.userPanningTheCamera = false
	end
	if self.numUnsunkTouches == 2 then
		local unsunkTouches = {}
		for touch, wasSunk in pairs(self.fingerTouches) do
			if not wasSunk then
				table.insert(unsunkTouches, touch)
			end
		end
		if #unsunkTouches == 2 then
			local difference = (unsunkTouches[1].Position - unsunkTouches[2].Position).magnitude
			if self.startingDiff and self.pinchBeginZoom then
				local scale = difference / math.max(0.01, self.startingDiff)
				local clampedScale = Util.Clamp(0.1, 10, scale)
				if self.distanceChangeEnabled then
					self:SetCameraToSubjectDistance(self.pinchBeginZoom / clampedScale)
				end
			else
				self.startingDiff = difference
				self.pinchBeginZoom = self:GetCameraToSubjectDistance()
			end
		end
	else
		self.startingDiff = nil
		self.pinchBeginZoom = nil
	end
end

function BaseCamera:OnTouchEnded(input, processed)
	if input == self.dynamicTouchInput then
		self.dynamicTouchInput = nil
		return
	end

	if self.fingerTouches[input] == false then
		if self.numUnsunkTouches == 1 then
			self.panBeginLook = nil
			self.startPos = nil
			self.lastPos = nil
			self.userPanningTheCamera = false
		elseif self.numUnsunkTouches == 2 then
			self.startingDiff = nil
			self.pinchBeginZoom = nil
		end
	end

	if self.fingerTouches[input] ~= nil and self.fingerTouches[input] == false then
		self.numUnsunkTouches = self.numUnsunkTouches - 1
	end
	self.fingerTouches[input] = nil
	self.inputStartPositions[input] = nil
	self.inputStartTimes[input] = nil
end

function BaseCamera:OnMouse2Down(input, processed)
	if processed then return end

	self.isRightMouseDown = true
	self:OnMousePanButtonPressed(input, processed)
end

function BaseCamera:OnMouse2Up(input, processed)
	self.isRightMouseDown = false
	self:OnMousePanButtonReleased(input, processed)
end

function BaseCamera:OnMouse3Down(input, processed)
	if processed then return end

	self.isMiddleMouseDown = true
	self:OnMousePanButtonPressed(input, processed)
end

function BaseCamera:OnMouse3Up(input, processed)
	self.isMiddleMouseDown = false
	self:OnMousePanButtonReleased(input, processed)
end

function BaseCamera:OnMouseMoved(input, processed)
	if not self.hasGameLoaded and VRService.VREnabled then
		return
	end

	local inputDelta = input.Delta
	inputDelta = Vector2.new(inputDelta.X, inputDelta.Y * UserGameSettings:GetCameraYInvertValue())

	if self.panEnabled and ((self.startPos and self.lastPos and self.panBeginLook) or self.inFirstPerson or self.inMouseLockedMode) then
		local desiredXYVector = self:InputTranslationToCameraAngleChange(inputDelta,MOUSE_SENSITIVITY)
		self.rotateInput = self.rotateInput + desiredXYVector
	end

	if self.startPos and self.lastPos and self.panBeginLook then
		self.lastPos = self.lastPos + input.Delta
	end
end

function BaseCamera:OnMousePanButtonPressed(input, processed)
	if processed then return end
	self:UpdateMouseBehavior()
	self.panBeginLook = self.panBeginLook or self:GetCameraLookVector()
	self.startPos = self.startPos or input.Position
	self.lastPos = self.lastPos or self.startPos
	self.userPanningTheCamera = true
end

function BaseCamera:OnMousePanButtonReleased(input, processed)
	self:UpdateMouseBehavior()
	if not (self.isRightMouseDown or self.isMiddleMouseDown) then
		self.panBeginLook = nil
		self.startPos = nil
		self.lastPos = nil
		self.userPanningTheCamera = false
	end
end

function BaseCamera:OnMouseWheel(input, processed)  -- remove with FFlagUserPointerActionsInPlayerScripts
	if not self.hasGameLoaded and VRService.VREnabled then
		return
	end
	if not processed then
		if self.distanceChangeEnabled then
			local wheelInput = Util.Clamp(-1, 1, -input.Position.Z)

			local newDistance
			if self.inFirstPerson and wheelInput > 0 then
				newDistance = FIRST_PERSON_DISTANCE_THRESHOLD
			else
				-- The 0.156 and 1.7 values are the slope and intercept of a line that is replacing the old
				-- rk4Integrator function which was not being used as an integrator, only to get a delta as a function of distance,
				-- which was linear as it was being used. These constants preserve the status quo behavior.
				newDistance = self.currentSubjectDistance + 0.156 * self.currentSubjectDistance * wheelInput + 1.7 * math.sign(wheelInput)
			end

			self:SetCameraToSubjectDistance(newDistance)
		end
	end
end

function BaseCamera:UpdateMouseBehavior()
	-- first time transition to first person mode or mouse-locked third person
	if self.inFirstPerson or self.inMouseLockedMode then
		UserGameSettings.RotationType = Enum.RotationType.CameraRelative
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	else
		UserGameSettings.RotationType = Enum.RotationType.MovementRelative
		if self.isRightMouseDown or self.isMiddleMouseDown then
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	end
end

function BaseCamera:UpdateForDistancePropertyChange()
	-- Calling this setter with the current value will force checking that it is still
	-- in range after a change to the min/max distance limits
	self:SetCameraToSubjectDistance(self.currentSubjectDistance)
end

function BaseCamera:SetCameraToSubjectDistance(desiredSubjectDistance)
	local player = Players.LocalPlayer

	local lastSubjectDistance = self.currentSubjectDistance

	-- By default, camera modules will respect LockFirstPerson and override the currentSubjectDistance with 0
	-- regardless of what Player.CameraMinZoomDistance is set to, so that first person can be made
	-- available by the developer without needing to allow players to mousewheel dolly into first person.
	-- Some modules will override this function to remove or change first-person capability.
	if player.CameraMode == Enum.CameraMode.LockFirstPerson then
		self.currentSubjectDistance = 0.5
		if not self.inFirstPerson then
			self:EnterFirstPerson()
		end
	else
		local newSubjectDistance = Util.Clamp(player.CameraMinZoomDistance, player.CameraMaxZoomDistance, desiredSubjectDistance)
		if newSubjectDistance < FIRST_PERSON_DISTANCE_THRESHOLD then
			self.currentSubjectDistance = 0.5
			if not self.inFirstPerson then
				self:EnterFirstPerson()
			end
		else
			self.currentSubjectDistance = newSubjectDistance
			if self.inFirstPerson then
				self:LeaveFirstPerson()
			end
		end
	end

	-- Pass target distance and zoom direction to the zoom controller
	ZoomController.SetZoomParameters(self.currentSubjectDistance, math.sign(desiredSubjectDistance - lastSubjectDistance))

	-- Returned only for convenience to the caller to know the outcome
	return self.currentSubjectDistance
end

function BaseCamera:SetCameraType( cameraType )
	--Used by derived classes
	self.cameraType = cameraType
end

function BaseCamera:GetCameraType()
	return self.cameraType
end

-- Movement mode standardized to Enum.ComputerCameraMovementMode values
function BaseCamera:SetCameraMovementMode( cameraMovementMode )
	self.cameraMovementMode = cameraMovementMode
end

function BaseCamera:GetCameraMovementMode()
	return self.cameraMovementMode
end

function BaseCamera:SetIsMouseLocked(mouseLocked)
	self.inMouseLockedMode = mouseLocked
	self:UpdateMouseBehavior()
end

function BaseCamera:GetIsMouseLocked()
	return self.inMouseLockedMode
end

function BaseCamera:SetMouseLockOffset(offsetVector)
	self.mouseLockOffset = offsetVector
end

function BaseCamera:GetMouseLockOffset()
	return self.mouseLockOffset
end

function BaseCamera:InFirstPerson()
	return self.inFirstPerson
end

function BaseCamera:EnterFirstPerson()
	-- Overridden in ClassicCamera, the only module which supports FirstPerson
end

function BaseCamera:LeaveFirstPerson()
	-- Overridden in ClassicCamera, the only module which supports FirstPerson
end

-- Nominal distance, set by dollying in and out with the mouse wheel or equivalent, not measured distance
function BaseCamera:GetCameraToSubjectDistance()
	return self.currentSubjectDistance
end

-- Actual measured distance to the camera Focus point, which may be needed in special circumstances, but should
-- never be used as the starting point for updating the nominal camera-to-subject distance (self.currentSubjectDistance)
-- since that is a desired target value set only by mouse wheel (or equivalent) input, PopperCam, and clamped to min max camera distance
function BaseCamera:GetMeasuredDistanceToFocus()
	local camera = game.Workspace.CurrentCamera
	if camera then
		return (camera.CoordinateFrame.p - camera.Focus.p).magnitude
	end
	return nil
end

function BaseCamera:GetCameraLookVector()
	return game.Workspace.CurrentCamera and game.Workspace.CurrentCamera.CFrame.lookVector or UNIT_Z
end

-- Replacements for RootCamera:RotateCamera() which did not actually rotate the camera
-- suppliedLookVector is not normally passed in, it's used only by Watch camera
function BaseCamera:CalculateNewLookCFrame(suppliedLookVector)
	local currLookVector = suppliedLookVector or self:GetCameraLookVector()
	local currPitchAngle = math.asin(currLookVector.y)
	local yTheta = Util.Clamp(-MAX_Y + currPitchAngle, -MIN_Y + currPitchAngle, self.rotateInput.y)
	local constrainedRotateInput = Vector2.new(self.rotateInput.x, yTheta)
	local startCFrame = CFrame.new(ZERO_VECTOR3, currLookVector)
	local newLookCFrame = CFrame.Angles(0, -constrainedRotateInput.x, 0) * startCFrame * CFrame.Angles(-constrainedRotateInput.y,0,0)
	return newLookCFrame
end
function BaseCamera:CalculateNewLookVector(suppliedLookVector)
	local newLookCFrame = self:CalculateNewLookCFrame(suppliedLookVector)
	return newLookCFrame.lookVector
end

function BaseCamera:CalculateNewLookVectorVR()
	local subjectPosition = self:GetSubjectPosition()
	local vecToSubject = (subjectPosition - game.Workspace.CurrentCamera.CFrame.p)
	local currLookVector = (vecToSubject * X1_Y0_Z1).unit
	local vrRotateInput = Vector2.new(self.rotateInput.x, 0)
	local startCFrame = CFrame.new(ZERO_VECTOR3, currLookVector)
	local yawRotatedVector = (CFrame.Angles(0, -vrRotateInput.x, 0) * startCFrame * CFrame.Angles(-vrRotateInput.y,0,0)).lookVector
	return (yawRotatedVector * X1_Y0_Z1).unit
end

function BaseCamera:GetHumanoid()
	local player = Players.LocalPlayer
	local character = player and player.Character
	if character then
		local resultHumanoid = self.humanoidCache[player]
		if resultHumanoid and resultHumanoid.Parent == character then
			return resultHumanoid
		else
			self.humanoidCache[player] = nil -- Bust Old Cache
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				self.humanoidCache[player] = humanoid
			end
			return humanoid
		end
	end
	return nil
end

function BaseCamera:GetHumanoidPartToFollow(humanoid, humanoidStateType)
	if humanoidStateType == Enum.HumanoidStateType.Dead then
		local character = humanoid.Parent
		if character then
			return character:FindFirstChild("Head") or humanoid.Torso
		else
			return humanoid.Torso
		end
	else
		return humanoid.Torso
	end
end

function BaseCamera:UpdateGamepad()
	local gamepadPan = self.gamepadPanningCamera
	if gamepadPan and (self.hasGameLoaded or not VRService.VREnabled) then
		gamepadPan = Util.GamepadLinearToCurve(gamepadPan)
		local currentTime = tick()
		if gamepadPan.X ~= 0 or gamepadPan.Y ~= 0 then
			self.userPanningTheCamera = true
		elseif gamepadPan == ZERO_VECTOR2 then
			self.lastThumbstickRotate = nil
			if self.lastThumbstickPos == ZERO_VECTOR2 then
				self.currentSpeed = 0
			end
		end

		local finalConstant = 0

		if self.lastThumbstickRotate then
			if VRService.VREnabled then
				self.currentSpeed = self.vrMaxSpeed
			else
				local elapsedTime = (currentTime - self.lastThumbstickRotate) * 10
				self.currentSpeed = self.currentSpeed + (self.maxSpeed * ((elapsedTime*elapsedTime)/self.numOfSeconds))

				if self.currentSpeed > self.maxSpeed then self.currentSpeed = self.maxSpeed end

				if self.lastVelocity then
					local velocity = (gamepadPan - self.lastThumbstickPos)/(currentTime - self.lastThumbstickRotate)
					local velocityDeltaMag = (velocity - self.lastVelocity).magnitude

					if velocityDeltaMag > 12 then
						self.currentSpeed = self.currentSpeed * (20/velocityDeltaMag)
						if self.currentSpeed > self.maxSpeed then self.currentSpeed = self.maxSpeed end
					end
				end
			end

			finalConstant = UserGameSettings.GamepadCameraSensitivity * self.currentSpeed
			self.lastVelocity = (gamepadPan - self.lastThumbstickPos)/(currentTime - self.lastThumbstickRotate)
		end

		self.lastThumbstickPos = gamepadPan
		self.lastThumbstickRotate = currentTime

		return Vector2.new( gamepadPan.X * finalConstant, gamepadPan.Y * finalConstant * self.ySensitivity * UserGameSettings:GetCameraYInvertValue())
	end

	return ZERO_VECTOR2
end

-- [[ VR Support Section ]] --

function BaseCamera:ApplyVRTransform()
	if not VRService.VREnabled then
		return
	end

	--we only want this to happen in first person VR
	local rootJoint = self.humanoidRootPart and self.humanoidRootPart:FindFirstChild("RootJoint")
	if not rootJoint then
		return
	end

	local cameraSubject = game.Workspace.CurrentCamera.CameraSubject
	local isInVehicle = cameraSubject and cameraSubject:IsA("VehicleSeat")

	if self.inFirstPerson and not isInVehicle then
		local vrFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
		local vrRotation = vrFrame - vrFrame.p
		rootJoint.C0 = CFrame.new(vrRotation:vectorToObjectSpace(vrFrame.p)) * CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
	else
		rootJoint.C0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
	end
end

function BaseCamera:IsInFirstPerson()
	return self.inFirstPerson
end

function BaseCamera:ShouldUseVRRotation()
	if not VRService.VREnabled then
		return false
	end

	if not self.VRRotationIntensityAvailable and tick() - self.lastVRRotationIntensityCheckTime < 1 then
		return false
	end

	local success, vrRotationIntensity = pcall(function() return StarterGui:GetCore("VRRotationIntensity") end)
	self.VRRotationIntensityAvailable = success and vrRotationIntensity ~= nil
	self.lastVRRotationIntensityCheckTime = tick()

	self.shouldUseVRRotation = success and vrRotationIntensity ~= nil and vrRotationIntensity ~= "Smooth"

	return self.shouldUseVRRotation
end

function BaseCamera:GetVRRotationInput()
	local vrRotateSum = ZERO_VECTOR2
	local success, vrRotationIntensity = pcall(function() return StarterGui:GetCore("VRRotationIntensity") end)

	if not success then
		return
	end

	local vrGamepadRotation = self.GamepadPanningCamera or ZERO_VECTOR2
	local delayExpired = (tick() - self.lastVRRotationTime) >= self:GetRepeatDelayValue(vrRotationIntensity)

	if math.abs(vrGamepadRotation.x) >= self:GetActivateValue() then
		if (delayExpired or not self.vrRotateKeyCooldown[Enum.KeyCode.Thumbstick2]) then
			local sign = 1
			if vrGamepadRotation.x < 0 then
				sign = -1
			end
			vrRotateSum = vrRotateSum + self:GetRotateAmountValue(vrRotationIntensity) * sign
			self.vrRotateKeyCooldown[Enum.KeyCode.Thumbstick2] = true
		end
	elseif math.abs(vrGamepadRotation.x) < self:GetActivateValue() - 0.1 then
		self.vrRotateKeyCooldown[Enum.KeyCode.Thumbstick2] = nil
	end
	if self.turningLeft then
		if delayExpired or not self.vrRotateKeyCooldown[Enum.KeyCode.Left] then
			vrRotateSum = vrRotateSum - self:GetRotateAmountValue(vrRotationIntensity)
			self.vrRotateKeyCooldown[Enum.KeyCode.Left] = true
		end
	else
		self.vrRotateKeyCooldown[Enum.KeyCode.Left] = nil
	end
	if self.turningRight then
		if (delayExpired or not self.vrRotateKeyCooldown[Enum.KeyCode.Right]) then
			vrRotateSum = vrRotateSum + self:GetRotateAmountValue(vrRotationIntensity)
			self.vrRotateKeyCooldown[Enum.KeyCode.Right] = true
		end
	else
		self.vrRotateKeyCooldown[Enum.KeyCode.Right] = nil
	end

	if vrRotateSum ~= ZERO_VECTOR2 then
		self.lastVRRotationTime = tick()
	end

	return vrRotateSum
end

function BaseCamera:CancelCameraFreeze(keepConstraints)
	if not keepConstraints then
		self.cameraTranslationConstraints = Vector3.new(self.cameraTranslationConstraints.x, 1, self.cameraTranslationConstraints.z)
	end
	if self.cameraFrozen then
		self.trackingHumanoid = nil
		self.cameraFrozen = false
	end
end

function BaseCamera:StartCameraFreeze(subjectPosition, humanoidToTrack)
	if not self.cameraFrozen then
		self.humanoidJumpOrigin = subjectPosition
		self.trackingHumanoid = humanoidToTrack
		self.cameraTranslationConstraints = Vector3.new(self.cameraTranslationConstraints.x, 0, self.cameraTranslationConstraints.z)
		self.cameraFrozen = true
	end
end

function BaseCamera:OnNewCameraSubject()
	if self.subjectStateChangedConn then
		self.subjectStateChangedConn:Disconnect()
		self.subjectStateChangedConn = nil
	end

	local humanoid = workspace.CurrentCamera and workspace.CurrentCamera.CameraSubject
	if self.trackingHumanoid ~= humanoid then
		self:CancelCameraFreeze()
	end
	if humanoid and humanoid:IsA("Humanoid") then
		self.subjectStateChangedConn = humanoid.StateChanged:Connect(function(oldState, newState)
			if VRService.VREnabled and newState == Enum.HumanoidStateType.Jumping and not self.inFirstPerson then
				self:StartCameraFreeze(self:GetSubjectPosition(), humanoid)
			elseif newState ~= Enum.HumanoidStateType.Jumping and newState ~= Enum.HumanoidStateType.Freefall then
				self:CancelCameraFreeze(true)
			end
		end)
	end
end

function BaseCamera:GetVRFocus(subjectPosition, timeDelta)
	local lastFocus = self.LastCameraFocus or subjectPosition
	if not self.cameraFrozen then
		self.cameraTranslationConstraints = Vector3.new(self.cameraTranslationConstraints.x, math.min(1, self.cameraTranslationConstraints.y + 0.42 * timeDelta), self.cameraTranslationConstraints.z)
	end

	local newFocus
	if self.cameraFrozen and self.humanoidJumpOrigin and self.humanoidJumpOrigin.y > lastFocus.y then
		newFocus = CFrame.new(Vector3.new(subjectPosition.x, math.min(self.humanoidJumpOrigin.y, lastFocus.y + 5 * timeDelta), subjectPosition.z))
	else
		newFocus = CFrame.new(Vector3.new(subjectPosition.x, lastFocus.y, subjectPosition.z):lerp(subjectPosition, self.cameraTranslationConstraints.y))
	end

	if self.cameraFrozen then
		-- No longer in 3rd person
		if self.inFirstPerson then -- not VRService.VREnabled
			self:CancelCameraFreeze()
		end
		-- This case you jumped off a cliff and want to keep your character in view
		-- 0.5 is to fix floating point error when not jumping off cliffs
		if self.humanoidJumpOrigin and subjectPosition.y < (self.humanoidJumpOrigin.y - 0.5) then
			self:CancelCameraFreeze()
		end
	end

	return newFocus
end

function BaseCamera:GetRotateAmountValue(vrRotationIntensity)
	vrRotationIntensity = vrRotationIntensity or StarterGui:GetCore("VRRotationIntensity")
	if vrRotationIntensity then
		if vrRotationIntensity == "Low" then
			return VR_LOW_INTENSITY_ROTATION
		elseif vrRotationIntensity == "High" then
			return VR_HIGH_INTENSITY_ROTATION
		end
	end
	return ZERO_VECTOR2
end

function BaseCamera:GetRepeatDelayValue(vrRotationIntensity)
	vrRotationIntensity = vrRotationIntensity or StarterGui:GetCore("VRRotationIntensity")
	if vrRotationIntensity then
		if vrRotationIntensity == "Low" then
			return VR_LOW_INTENSITY_REPEAT
		elseif vrRotationIntensity == "High" then
			return VR_HIGH_INTENSITY_REPEAT
		end
	end
	return 0
end

function BaseCamera:Test()
	print("BaseCamera:Test()")
end

function BaseCamera:Update(dt)
	warn("BaseCamera:Update() This is a virtual function that should never be getting called.")
	return game.Workspace.CurrentCamera.CFrame, game.Workspace.CurrentCamera.Focus
end

return BaseCamera

--[[
	BaseOcclusion - Abstract base class for character occlusion control modules
	2018 Camera Update - AllYourBlox		
--]]

--[[ The Module ]]--
local BaseOcclusion = {}
BaseOcclusion.__index = BaseOcclusion
setmetatable(BaseOcclusion, { __call = function(_, ...) return BaseOcclusion.new(...) end})

function BaseOcclusion.new()
	local self = setmetatable({}, BaseOcclusion)
	return self
end

-- Called when character is added
function BaseOcclusion:CharacterAdded(char, player)
	
end

-- Called when character is about to be removed
function BaseOcclusion:CharacterRemoving(char, player)
	
end

function BaseOcclusion:OnCameraSubjectChanged(newSubject)
	
end

--[[ Derived classes are required to override and implement all of the following functions ]]--
function GetOcclusionMode()
	-- Must be overridden in derived classes to return an Enum.DevCameraOcclusionMode value
	warn("BaseOcclusion GetOcclusionMode must be overridden by derived classes")
	return nil
end

function BaseOcclusion:Enable(enabled)
	warn("BaseOcclusion Enable must be overridden by derived classes")
end

function BaseOcclusion:Update(dt, desiredCameraCFrame, desiredCameraFocus)
	warn("BaseOcclusion Update must be overridden by derived classes")
	return desiredCameraCFrame, desiredCameraFocus
end

return BaseOcclusion

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LocalPlayer = Players.LocalPlayer
end

local function waitForChildOfClass(parent, class)
	local child = parent:FindFirstChildOfClass(class)
	while not child or child.ClassName ~= class do
		child = parent.ChildAdded:Wait()
	end
	return child
end

local PlayerGui = waitForChildOfClass(LocalPlayer, "PlayerGui")

local TOAST_OPEN_SIZE = UDim2.new(0, 326, 0, 58)
local TOAST_CLOSED_SIZE = UDim2.new(0, 80, 0, 58)
local TOAST_BACKGROUND_COLOR = Color3.fromRGB(32, 32, 32)
local TOAST_BACKGROUND_TRANS = 0.4
local TOAST_FOREGROUND_COLOR = Color3.fromRGB(200, 200, 200)
local TOAST_FOREGROUND_TRANS = 0

-- Convenient syntax for creating a tree of instanes
local function create(className)
	return function(props)
		local inst = Instance.new(className)
		local parent = props.Parent
		props.Parent = nil
		for name, val in pairs(props) do
			if type(name) == "string" then
				inst[name] = val
			else
				val.Parent = inst
			end
		end
		-- Only set parent after all other properties are initialized
		inst.Parent = parent
		return inst
	end
end

local initialized = false

local uiRoot
local toast
local toastIcon
local toastUpperText
local toastLowerText

local function initializeUI()
	assert(not initialized)

	uiRoot = create("ScreenGui"){
		Name = "RbxCameraUI",
		AutoLocalize = false,
		Enabled = true,
		DisplayOrder = -1, -- Appears behind default developer UI
		IgnoreGuiInset = false,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

		create("ImageLabel"){
			Name = "Toast",
			Visible = false,
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0, 8),
			Size = TOAST_CLOSED_SIZE,
			Image = "rbxasset://textures/ui/Camera/CameraToast9Slice.png",
			ImageColor3 = TOAST_BACKGROUND_COLOR,
			ImageRectSize = Vector2.new(6, 6),
			ImageTransparency = 1,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(3, 3, 3, 3),
			ClipsDescendants = true,

			create("Frame"){
				Name = "IconBuffer",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(0, 80, 1, 0),

				create("ImageLabel"){
					Name = "Icon",
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, 48, 0, 48),
					ZIndex = 2,
					Image = "rbxasset://textures/ui/Camera/CameraToastIcon.png",
					ImageColor3 = TOAST_FOREGROUND_COLOR,
					ImageTransparency = 1,
				}
			},

			create("Frame"){
				Name = "TextBuffer",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 80, 0, 0),
				Size = UDim2.new(1, -80, 1, 0),
				ClipsDescendants = true,

				create("TextLabel"){
					Name = "Upper",
					AnchorPoint = Vector2.new(0, 1),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0.5, 0),
					Size = UDim2.new(1, 0, 0, 19),
					Font = Enum.Font.GothamSemibold,
					Text = "Camera control enabled",
					TextColor3 = TOAST_FOREGROUND_COLOR,
					TextTransparency = 1,
					TextSize = 19,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
				},

				create("TextLabel"){
					Name = "Lower",
					AnchorPoint = Vector2.new(0, 0),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0.5, 3),
					Size = UDim2.new(1, 0, 0, 15),
					Font = Enum.Font.Gotham,
					Text = "Right mouse button to toggle",
					TextColor3 = TOAST_FOREGROUND_COLOR,
					TextTransparency = 1,
					TextSize = 15,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
				},
			},
		},

		Parent = PlayerGui,
	}

	toast = uiRoot.Toast
	toastIcon = toast.IconBuffer.Icon
	toastUpperText = toast.TextBuffer.Upper
	toastLowerText = toast.TextBuffer.Lower

	initialized = true
end

local CameraUI = {}

do
	-- Instantaneously disable the toast or enable for opening later on. Used when switching camera modes.
	function CameraUI.setCameraModeToastEnabled(enabled)
		if not enabled and not initialized then
			return
		end

		if not initialized then
			initializeUI()
		end

		toast.Visible = enabled
		if not enabled then
			CameraUI.setCameraModeToastOpen(false)
		end
	end

	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	-- Tween the toast in or out. Toast must be enabled with setCameraModeToastEnabled.
	function CameraUI.setCameraModeToastOpen(open)
		assert(initialized)

		TweenService:Create(toast, tweenInfo, {
			Size = open and TOAST_OPEN_SIZE or TOAST_CLOSED_SIZE,
			ImageTransparency = open and TOAST_BACKGROUND_TRANS or 1,
		}):Play()

		TweenService:Create(toastIcon, tweenInfo, {
			ImageTransparency = open and TOAST_FOREGROUND_TRANS or 1,
		}):Play()

		TweenService:Create(toastUpperText, tweenInfo, {
			TextTransparency = open and TOAST_FOREGROUND_TRANS or 1,
		}):Play()

		TweenService:Create(toastLowerText, tweenInfo, {
			TextTransparency = open and TOAST_FOREGROUND_TRANS or 1,
		}):Play()
	end
end

return CameraUI

--[[
	CameraUtils - Math utility functions shared by multiple camera scripts
	2018 Camera Update - AllYourBlox		
--]]

local CameraUtils = {}

local function round(num)
	return math.floor(num + 0.5)
end

-- Note, arguments do not match the new math.clamp
-- Eventually we will replace these calls with math.clamp, but right now
-- this is safer as math.clamp is not tolerant of min>max
function CameraUtils.Clamp(low, high, val)
	return math.min(math.max(val, low), high)
end

-- From TransparencyController
function CameraUtils.Round(num, places)
	local decimalPivot = 10^places
	return math.floor(num * decimalPivot + 0.5) / decimalPivot
end

function CameraUtils.IsFinite(val)
	return val == val and val ~= math.huge and val ~= -math.huge
end

function CameraUtils.IsFiniteVector3(vec3)
	return CameraUtils.IsFinite(vec3.X) and CameraUtils.IsFinite(vec3.Y) and CameraUtils.IsFinite(vec3.Z)
end

-- Legacy implementation renamed
function CameraUtils.GetAngleBetweenXZVectors(v1, v2)
	return math.atan2(v2.X*v1.Z-v2.Z*v1.X, v2.X*v1.X+v2.Z*v1.Z)
end

function  CameraUtils.RotateVectorByAngleAndRound(camLook, rotateAngle, roundAmount)
	if camLook.Magnitude > 0 then
		camLook = camLook.unit
		local currAngle = math.atan2(camLook.z, camLook.x)
		local newAngle = round((math.atan2(camLook.z, camLook.x) + rotateAngle) / roundAmount) * roundAmount
		return newAngle - currAngle
	end
	return 0
end

-- K is a tunable parameter that changes the shape of the S-curve
-- the larger K is the more straight/linear the curve gets
local k = 0.35
local lowerK = 0.8
local function SCurveTranform(t)
	t = CameraUtils.Clamp(-1,1,t)
	if t >= 0 then
		return (k*t) / (k - t + 1)
	end
	return -((lowerK*-t) / (lowerK + t + 1))
end

local DEADZONE = 0.1
local function toSCurveSpace(t)
	return (1 + DEADZONE) * (2*math.abs(t) - 1) - DEADZONE
end

local function fromSCurveSpace(t)
	return t/2 + 0.5
end
	
function CameraUtils.GamepadLinearToCurve(thumbstickPosition)
	local function onAxis(axisValue)
		local sign = 1
		if axisValue < 0 then
			sign = -1
		end
		local point = fromSCurveSpace(SCurveTranform(toSCurveSpace(math.abs(axisValue))))
		point = point * sign
		return CameraUtils.Clamp(-1, 1, point)
	end
	return Vector2.new(onAxis(thumbstickPosition.x), onAxis(thumbstickPosition.y))
end

-- This function converts 4 different, redundant enumeration types to one standard so the values can be compared
function CameraUtils.ConvertCameraModeEnumToStandard( enumValue )
	
	if enumValue == Enum.TouchCameraMovementMode.Default then
		return Enum.ComputerCameraMovementMode.Follow
	end
	
	if enumValue == Enum.ComputerCameraMovementMode.Default then
		return Enum.ComputerCameraMovementMode.Classic
	end
	
	if enumValue == Enum.TouchCameraMovementMode.Classic or
		enumValue == Enum.DevTouchCameraMovementMode.Classic or
		enumValue == Enum.DevComputerCameraMovementMode.Classic or
		enumValue == Enum.ComputerCameraMovementMode.Classic then
		return Enum.ComputerCameraMovementMode.Classic
	end
	
	if enumValue == Enum.TouchCameraMovementMode.Follow or
		enumValue == Enum.DevTouchCameraMovementMode.Follow or
		enumValue == Enum.DevComputerCameraMovementMode.Follow or
		enumValue == Enum.ComputerCameraMovementMode.Follow then
		return Enum.ComputerCameraMovementMode.Follow
	end
	
	if enumValue == Enum.TouchCameraMovementMode.Orbital or
		enumValue == Enum.DevTouchCameraMovementMode.Orbital or
		enumValue == Enum.DevComputerCameraMovementMode.Orbital or
		enumValue == Enum.ComputerCameraMovementMode.Orbital then
		return Enum.ComputerCameraMovementMode.Orbital
	end
	
	-- Note: Only the Dev versions of the Enums have UserChoice as an option
	if enumValue == Enum.DevTouchCameraMovementMode.UserChoice or
		enumValue == Enum.DevComputerCameraMovementMode.UserChoice then
		return Enum.DevComputerCameraMovementMode.UserChoice
	end
	
	-- For any unmapped options return Classic camera
	return Enum.ComputerCameraMovementMode.Classic
end

return CameraUtils

--[[
	ClassicCamera - Classic Roblox camera control module
	2018 Camera Update - AllYourBlox

	Note: This module also handles camera control types Follow and Track, the
	latter of which is currently not distinguished from Classic
--]]

-- Local private variables and constants
local ZERO_VECTOR2 = Vector2.new(0,0)

local tweenAcceleration = math.rad(220)		--Radians/Second^2
local tweenSpeed = math.rad(0)				--Radians/Second
local tweenMaxSpeed = math.rad(250)			--Radians/Second
local TIME_BEFORE_AUTO_ROTATE = 2.0 		--Seconds, used when auto-aligning camera with vehicles

local INITIAL_CAMERA_ANGLE = CFrame.fromOrientation(math.rad(-15), 0, 0)

--[[ Services ]]--
local PlayersService = game:GetService('Players')
local VRService = game:GetService("VRService")

local Util = require(script.Parent:WaitForChild("CameraUtils"))

--[[ The Module ]]--
local BaseCamera = require(script.Parent:WaitForChild("BaseCamera"))
local ClassicCamera = setmetatable({}, BaseCamera)
ClassicCamera.__index = ClassicCamera

function ClassicCamera.new()
	local self = setmetatable(BaseCamera.new(), ClassicCamera)

	self.isFollowCamera = false
	self.lastUpdate = tick()

	return self
end

function ClassicCamera:GetModuleName()
	return "ClassicCamera"
end

-- Movement mode standardized to Enum.ComputerCameraMovementMode values
function ClassicCamera:SetCameraMovementMode( cameraMovementMode )
	BaseCamera.SetCameraMovementMode(self,cameraMovementMode)
	self.isFollowCamera = cameraMovementMode == Enum.ComputerCameraMovementMode.Follow
end

function ClassicCamera:Test()
	print("ClassicCamera:Test()")
end

function ClassicCamera:Update()
	local now = tick()
	local timeDelta = (now - self.lastUpdate)

	local camera = 	workspace.CurrentCamera
	local newCameraCFrame = camera.CFrame
	local newCameraFocus = camera.Focus
	local overrideCameraLookVector = nil
	if self.resetCameraAngle then
		local rootPart = self:GetHumanoidRootPart()
		if rootPart then
			overrideCameraLookVector = (rootPart.CFrame * INITIAL_CAMERA_ANGLE).lookVector
		else
			overrideCameraLookVector = INITIAL_CAMERA_ANGLE.lookVector
		end
		self.resetCameraAngle = false
	end

	local player = PlayersService.LocalPlayer
	local humanoid = self:GetHumanoid()
	local cameraSubject = camera.CameraSubject
	local isInVehicle = cameraSubject and cameraSubject:IsA('VehicleSeat')
	local isOnASkateboard = cameraSubject and cameraSubject:IsA('SkateboardPlatform')
	local isClimbing = humanoid and humanoid:GetState() == Enum.HumanoidStateType.Climbing

	if self.lastUpdate == nil or timeDelta > 1 then
		self.lastCameraTransform = nil
	end

	if self.lastUpdate then
		local gamepadRotation = self:UpdateGamepad()

		if self:ShouldUseVRRotation() then
			self.rotateInput = self.rotateInput + self:GetVRRotationInput()
		else
			-- Cap out the delta to 0.1 so we don't get some crazy things when we re-resume from
			local delta = math.min(0.1, timeDelta)

			if gamepadRotation ~= ZERO_VECTOR2 then
				self.rotateInput = self.rotateInput + (gamepadRotation * delta)
			end

			local angle = 0
			if not (isInVehicle or isOnASkateboard) then
				angle = angle + (self.turningLeft and -120 or 0)
				angle = angle + (self.turningRight and 120 or 0)
			end

			if angle ~= 0 then
				self.rotateInput = self.rotateInput +  Vector2.new(math.rad(angle * delta), 0)
			end
		end
	end

	-- Reset tween speed if user is panning
	if self.userPanningTheCamera then
		tweenSpeed = 0
		self.lastUserPanCamera = tick()
	end

	local userRecentlyPannedCamera = now - self.lastUserPanCamera < TIME_BEFORE_AUTO_ROTATE
	local subjectPosition = self:GetSubjectPosition()

	if subjectPosition and player and camera then
		local zoom = self:GetCameraToSubjectDistance()
		if zoom < 0.5 then
			zoom = 0.5
		end

		if self:GetIsMouseLocked() and not self:IsInFirstPerson() then
			-- We need to use the right vector of the camera after rotation, not before
			local newLookCFrame = self:CalculateNewLookCFrame(overrideCameraLookVector)

			local offset = self:GetMouseLockOffset()
			local cameraRelativeOffset = offset.X * newLookCFrame.rightVector + offset.Y * newLookCFrame.upVector + offset.Z * newLookCFrame.lookVector

			--offset can be NAN, NAN, NAN if newLookVector has only y component
			if Util.IsFiniteVector3(cameraRelativeOffset) then
				subjectPosition = subjectPosition + cameraRelativeOffset
			end
		else
			if not self.userPanningTheCamera and self.lastCameraTransform then

				local isInFirstPerson = self:IsInFirstPerson()

				if (isInVehicle or isOnASkateboard or (self.isFollowCamera and isClimbing)) and self.lastUpdate and humanoid and humanoid.Torso then
					if isInFirstPerson then
						if self.lastSubjectCFrame and (isInVehicle or isOnASkateboard) and cameraSubject:IsA('BasePart') then
							local y = -Util.GetAngleBetweenXZVectors(self.lastSubjectCFrame.lookVector, cameraSubject.CFrame.lookVector)
							if Util.IsFinite(y) then
								self.rotateInput = self.rotateInput + Vector2.new(y, 0)
							end
							tweenSpeed = 0
						end
					elseif not userRecentlyPannedCamera then
						local forwardVector = humanoid.Torso.CFrame.lookVector
						if isOnASkateboard then
							forwardVector = cameraSubject.CFrame.lookVector
						end

						tweenSpeed = Util.Clamp(0, tweenMaxSpeed, tweenSpeed + tweenAcceleration * timeDelta)

						local percent = Util.Clamp(0, 1, tweenSpeed * timeDelta)
						if self:IsInFirstPerson() and not (self.isFollowCamera and self.isClimbing) then
							percent = 1
						end

						local y = Util.GetAngleBetweenXZVectors(forwardVector, self:GetCameraLookVector())
						if Util.IsFinite(y) and math.abs(y) > 0.0001 then
							self.rotateInput = self.rotateInput + Vector2.new(y * percent, 0)
						end
					end

				elseif self.isFollowCamera and (not (isInFirstPerson or userRecentlyPannedCamera) and not VRService.VREnabled) then
					-- Logic that was unique to the old FollowCamera module
					local lastVec = -(self.lastCameraTransform.p - subjectPosition)

					local y = Util.GetAngleBetweenXZVectors(lastVec, self:GetCameraLookVector())

					-- This cutoff is to decide if the humanoid's angle of movement,
					-- relative to the camera's look vector, is enough that
					-- we want the camera to be following them. The point is to provide
					-- a sizable dead zone to allow more precise forward movements.
					local thetaCutoff = 0.4

					-- Check for NaNs
					if Util.IsFinite(y) and math.abs(y) > 0.0001 and math.abs(y) > thetaCutoff * timeDelta then
						self.rotateInput = self.rotateInput + Vector2.new(y, 0)
					end
				end
			end
		end

		if not self.isFollowCamera then
			local VREnabled = VRService.VREnabled

			if VREnabled then
				newCameraFocus = self:GetVRFocus(subjectPosition, timeDelta)
			else
				newCameraFocus = CFrame.new(subjectPosition)
			end

			local cameraFocusP = newCameraFocus.p
			if VREnabled and not self:IsInFirstPerson() then
				local cameraHeight = self:GetCameraHeight()
				local vecToSubject = (subjectPosition - camera.CFrame.p)
				local distToSubject = vecToSubject.magnitude

				-- Only move the camera if it exceeded a maximum distance to the subject in VR
				if distToSubject > zoom or self.rotateInput.x ~= 0 then
					local desiredDist = math.min(distToSubject, zoom)
					vecToSubject = self:CalculateNewLookVectorVR() * desiredDist
					local newPos = cameraFocusP - vecToSubject
					local desiredLookDir = camera.CFrame.lookVector
					if self.rotateInput.x ~= 0 then
						desiredLookDir = vecToSubject
					end
					local lookAt = Vector3.new(newPos.x + desiredLookDir.x, newPos.y, newPos.z + desiredLookDir.z)
					self.rotateInput = ZERO_VECTOR2

					newCameraCFrame = CFrame.new(newPos, lookAt) + Vector3.new(0, cameraHeight, 0)
				end
			else
				local newLookVector = self:CalculateNewLookVector(overrideCameraLookVector)
				self.rotateInput = ZERO_VECTOR2
				newCameraCFrame = CFrame.new(cameraFocusP - (zoom * newLookVector), cameraFocusP)
			end
		else -- is FollowCamera
			local newLookVector = self:CalculateNewLookVector(overrideCameraLookVector)
			self.rotateInput = ZERO_VECTOR2

			if VRService.VREnabled then
				newCameraFocus = self:GetVRFocus(subjectPosition, timeDelta)
			else
				newCameraFocus = CFrame.new(subjectPosition)
			end
			newCameraCFrame = CFrame.new(newCameraFocus.p - (zoom * newLookVector), newCameraFocus.p) + Vector3.new(0, self:GetCameraHeight(), 0)
		end

		self.lastCameraTransform = newCameraCFrame
		self.lastCameraFocus = newCameraFocus
		if (isInVehicle or isOnASkateboard) and cameraSubject:IsA('BasePart') then
			self.lastSubjectCFrame = cameraSubject.CFrame
		else
			self.lastSubjectCFrame = nil
		end
	end

	self.lastUpdate = now
	return newCameraCFrame, newCameraFocus
end

function ClassicCamera:EnterFirstPerson()
	self.inFirstPerson = true
	self:UpdateMouseBehavior()
end

function ClassicCamera:LeaveFirstPerson()
	self.inFirstPerson = false
	self:UpdateMouseBehavior()
end

return ClassicCamera

--[[
	Invisicam - Occlusion module that makes objects occluding character view semi-transparent
	2018 Camera Update - AllYourBlox		
--]]

--[[ Camera Maths Utilities Library ]]--
local Util = require(script.Parent:WaitForChild("CameraUtils"))

--[[ Top Level Roblox Services ]]--
local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")

--[[ Constants ]]--
local ZERO_VECTOR3 = Vector3.new(0,0,0)
local USE_STACKING_TRANSPARENCY = true	-- Multiple items between the subject and camera get transparency values that add up to TARGET_TRANSPARENCY
local TARGET_TRANSPARENCY = 0.75 -- Classic Invisicam's Value, also used by new invisicam for parts hit by head and torso rays
local TARGET_TRANSPARENCY_PERIPHERAL = 0.5 -- Used by new SMART_CIRCLE mode for items not hit by head and torso rays

local MODE = {
	--CUSTOM = 1, 		-- Retired, unused
	LIMBS = 2, 			-- Track limbs
	MOVEMENT = 3, 		-- Track movement
	CORNERS = 4, 		-- Char model corners
	CIRCLE1 = 5, 		-- Circle of casts around character
	CIRCLE2 = 6, 		-- Circle of casts around character, camera relative
	LIMBMOVE = 7, 		-- LIMBS mode + MOVEMENT mode
	SMART_CIRCLE = 8, 	-- More sample points on and around character
	CHAR_OUTLINE = 9,	-- Dynamic outline around the character
}

local LIMB_TRACKING_SET = {
	-- Body parts common to R15 and R6
	['Head'] = true,
	
	-- Body parts unique to R6
	['Left Arm'] = true,
	['Right Arm'] = true,
	['Left Leg'] = true,
	['Right Leg'] = true,
	
	-- Body parts unique to R15
	['LeftLowerArm'] = true,
	['RightLowerArm'] = true,
	['LeftUpperLeg'] = true,
	['RightUpperLeg'] = true
}

local CORNER_FACTORS = {
	Vector3.new(1,1,-1),
	Vector3.new(1,-1,-1),
	Vector3.new(-1,-1,-1),
	Vector3.new(-1,1,-1)
}

local CIRCLE_CASTS = 10
local MOVE_CASTS = 3
local SMART_CIRCLE_CASTS = 24
local SMART_CIRCLE_INCREMENT = 2.0 * math.pi / SMART_CIRCLE_CASTS
local CHAR_OUTLINE_CASTS = 24

-- Used to sanitize user-supplied functions
local function AssertTypes(param, ...)
	local allowedTypes = {}
	local typeString = ''
	for _, typeName in pairs({...}) do
		allowedTypes[typeName] = true
		typeString = typeString .. (typeString == '' and '' or ' or ') .. typeName
	end
	local theType = type(param)
	assert(allowedTypes[theType], typeString .. " type expected, got: " .. theType)
end

-- Helper function for Determinant of 3x3, not in CameraUtils for performance reasons
local function Det3x3(a,b,c,d,e,f,g,h,i)
	return (a*(e*i-f*h)-b*(d*i-f*g)+c*(d*h-e*g))
end

-- Smart Circle mode needs the intersection of 2 rays that are known to be in the same plane
-- because they are generated from cross products with a common vector. This function is computing
-- that intersection, but it's actually the general solution for the point halfway between where
-- two skew lines come nearest to each other, which is more forgiving.
local function RayIntersection(p0, v0, p1, v1)
	local v2 = v0:Cross(v1)
	local d1 = p1.x - p0.x
	local d2 = p1.y - p0.y
	local d3 = p1.z - p0.z
	local denom = Det3x3(v0.x,-v1.x,v2.x,v0.y,-v1.y,v2.y,v0.z,-v1.z,v2.z)
	
	if (denom == 0) then
		return ZERO_VECTOR3 -- No solution (rays are parallel)
	end
	
	local t0 = Det3x3(d1,-v1.x,v2.x,d2,-v1.y,v2.y,d3,-v1.z,v2.z) / denom
	local t1 = Det3x3(v0.x,d1,v2.x,v0.y,d2,v2.y,v0.z,d3,v2.z) / denom
	local s0 = p0 + t0 * v0
	local s1 = p1 + t1 * v1
	local s = s0 + 0.5 * ( s1 - s0 )
	
	-- 0.25 studs is a threshold for deciding if the rays are
	-- close enough to be considered intersecting, found through testing 
	if (s1-s0).Magnitude < 0.25 then
		return s
	else
		return ZERO_VECTOR3
	end
end



--[[ The Module ]]--
local BaseOcclusion = require(script.Parent:WaitForChild("BaseOcclusion"))
local Invisicam = setmetatable({}, BaseOcclusion)
Invisicam.__index = Invisicam

function Invisicam.new()
	local self = setmetatable(BaseOcclusion.new(), Invisicam)
	
	self.char = nil
	self.humanoidRootPart = nil
	self.torsoPart = nil
	self.headPart = nil
	
	self.childAddedConn = nil
	self.childRemovedConn = nil
	
	self.behaviors = {} 	-- Map of modes to behavior fns
	self.behaviors[MODE.LIMBS] = self.LimbBehavior
	self.behaviors[MODE.MOVEMENT] = self.MoveBehavior
	self.behaviors[MODE.CORNERS] = self.CornerBehavior
	self.behaviors[MODE.CIRCLE1] = self.CircleBehavior
	self.behaviors[MODE.CIRCLE2] = self.CircleBehavior
	self.behaviors[MODE.LIMBMOVE] = self.LimbMoveBehavior
	self.behaviors[MODE.SMART_CIRCLE] = self.SmartCircleBehavior
	self.behaviors[MODE.CHAR_OUTLINE] = self.CharacterOutlineBehavior	
	
	self.mode = MODE.SMART_CIRCLE
	self.behaviorFunction = self.SmartCircleBehavior
	
	
	self.savedHits = {} 	-- Objects currently being faded in/out
	self.trackedLimbs = {}	-- Used in limb-tracking casting modes
		
	self.camera = game.Workspace.CurrentCamera

	self.enabled = false
	return self
end

function Invisicam:Enable(enable)
	self.enabled = enable
	
	if not enable then
		self:Cleanup()
	end
end

function Invisicam:GetOcclusionMode()
	return Enum.DevCameraOcclusionMode.Invisicam
end

--[[ Module functions ]]--
function Invisicam:LimbBehavior(castPoints)
	for limb, _ in pairs(self.trackedLimbs) do
		castPoints[#castPoints + 1] = limb.Position
	end
end

function Invisicam:MoveBehavior(castPoints)
	for i = 1, MOVE_CASTS do
		local position, velocity = self.humanoidRootPart.Position, self.humanoidRootPart.Velocity
		local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude / 2
		local offsetVector = (i - 1) * self.humanoidRootPart.CFrame.lookVector * horizontalSpeed
		castPoints[#castPoints + 1] = position + offsetVector
	end
end

function Invisicam:CornerBehavior(castPoints)
	local cframe = self.humanoidRootPart.CFrame
	local centerPoint = cframe.p
	local rotation = cframe - centerPoint
	local halfSize = self.char:GetExtentsSize() / 2 --NOTE: Doesn't update w/ limb animations
	castPoints[#castPoints + 1] = centerPoint
	for i = 1, #CORNER_FACTORS do
		castPoints[#castPoints + 1] = centerPoint + (rotation * (halfSize * CORNER_FACTORS[i]))
	end
end

function Invisicam:CircleBehavior(castPoints)
	local cframe = nil
	if self.mode == MODE.CIRCLE1 then
		cframe = self.humanoidRootPart.CFrame
	else
		local camCFrame = self.camera.CoordinateFrame
		cframe = camCFrame - camCFrame.p + self.humanoidRootPart.Position
	end
	castPoints[#castPoints + 1] = cframe.p
	for i = 0, CIRCLE_CASTS - 1 do
		local angle = (2 * math.pi / CIRCLE_CASTS) * i
		local offset = 3 * Vector3.new(math.cos(angle), math.sin(angle), 0)
		castPoints[#castPoints + 1] = cframe * offset
	end
end	

function Invisicam:LimbMoveBehavior(castPoints)
	self:LimbBehavior(castPoints)
	self:MoveBehavior(castPoints)
end

function Invisicam:CharacterOutlineBehavior(castPoints)
	local torsoUp = self.torsoPart.CFrame.upVector.unit
	local torsoRight = self.torsoPart.CFrame.rightVector.unit
	
	-- Torso cross of points for interior coverage
	castPoints[#castPoints + 1] = self.torsoPart.CFrame.p
	castPoints[#castPoints + 1] = self.torsoPart.CFrame.p + torsoUp
	castPoints[#castPoints + 1] = self.torsoPart.CFrame.p - torsoUp
	castPoints[#castPoints + 1] = self.torsoPart.CFrame.p + torsoRight
	castPoints[#castPoints + 1] = self.torsoPart.CFrame.p - torsoRight
	if self.headPart then
		castPoints[#castPoints + 1] = self.headPart.CFrame.p
	end
	
	local cframe = CFrame.new(ZERO_VECTOR3,Vector3.new(self.camera.CoordinateFrame.lookVector.X,0,self.camera.CoordinateFrame.lookVector.Z))
	local centerPoint = (self.torsoPart and self.torsoPart.Position or self.humanoidRootPart.Position)
	
	local partsWhitelist = {self.torsoPart}
	if self.headPart then
		partsWhitelist[#partsWhitelist + 1] = self.headPart
	end
	
	for i = 1, CHAR_OUTLINE_CASTS do
		local angle = (2 * math.pi * i / CHAR_OUTLINE_CASTS)
		local offset = cframe * (3 * Vector3.new(math.cos(angle), math.sin(angle), 0))
		
		offset = Vector3.new(offset.X, math.max(offset.Y, -2.25), offset.Z)	
		
		local ray = Ray.new(centerPoint + offset, -3 * offset)
		local hit, hitPoint = game.Workspace:FindPartOnRayWithWhitelist(ray, partsWhitelist, false, false)
		
		if hit then
			-- Use hit point as the cast point, but nudge it slightly inside the character so that bumping up against
			-- walls is less likely to cause a transparency glitch
			castPoints[#castPoints + 1] = hitPoint + 0.2 * (centerPoint - hitPoint).unit
		end
	end
end

function Invisicam:SmartCircleBehavior(castPoints)
	local torsoUp = self.torsoPart.CFrame.upVector.unit
	local torsoRight = self.torsoPart.CFrame.rightVector.unit
	
	-- SMART_CIRCLE mode includes rays to head and 5 to the torso.
	-- Hands, arms, legs and feet are not included since they
	-- are not canCollide and can therefore go inside of parts
	castPoints[#castPoints + 1] = self.torsoPart.CFrame.p
	castPoints[#castPoints + 1] = self.torsoPart.CFrame.p + torsoUp
	castPoints[#castPoints + 1] = self.torsoPart.CFrame.p - torsoUp
	castPoints[#castPoints + 1] = self.torsoPart.CFrame.p + torsoRight
	castPoints[#castPoints + 1] = self.torsoPart.CFrame.p - torsoRight
	if self.headPart then
		castPoints[#castPoints + 1] = self.headPart.CFrame.p
	end
	
	local cameraOrientation = self.camera.CFrame - self.camera.CFrame.p
	local torsoPoint = Vector3.new(0,0.5,0) + (self.torsoPart and self.torsoPart.Position or self.humanoidRootPart.Position)
	local radius = 2.5
	
	-- This loop first calculates points in a circle of radius 2.5 around the torso of the character, in the
	-- plane orthogonal to the camera's lookVector. Each point is then raycast to, to determine if it is within
	-- the free space surrounding the player (not inside anything). Two iterations are done to adjust points that
	-- are inside parts, to try to move them to valid locations that are still on their camera ray, so that the
	-- circle remains circular from the camera's perspective, but does not cast rays into walls or parts that are
	-- behind, below or beside the character and not really obstructing view of the character. This minimizes
	-- the undesirable situation where the character walks up to an exterior wall and it is made invisible even
	-- though it is behind the character.
	for i = 1, SMART_CIRCLE_CASTS do
		local angle = SMART_CIRCLE_INCREMENT * i - 0.5 * math.pi
		local offset = radius * Vector3.new(math.cos(angle), math.sin(angle), 0)
		local circlePoint = torsoPoint + cameraOrientation * offset		
		 
		-- Vector from camera to point on the circle being tested		
		local vp = circlePoint - self.camera.CFrame.p
		
		local ray = Ray.new(torsoPoint, circlePoint - torsoPoint)
		local hit, hp, hitNormal = game.Workspace:FindPartOnRayWithIgnoreList(ray, {self.char}, false, false )
		local castPoint = circlePoint
				
		if hit then
			local hprime = hp + 0.1 * hitNormal.unit -- Slightly offset hit point from the hit surface
			local v0 = hprime - torsoPoint -- Vector from torso to offset hit point
			local d0 = v0.magnitude
			
			local perp = (v0:Cross(vp)).unit

			-- Vector from the offset hit point, along the hit surface
			local v1 = (perp:Cross(hitNormal)).unit
			
			-- Vector from camera to offset hit
			local vprime = (hprime - self.camera.CFrame.p).unit
			
			-- This dot product checks to see if the vector along the hit surface would hit the correct
			-- side of the invisicam cone, or if it would cross the camera look vector and hit the wrong side
			if ( v0.unit:Dot(-v1) < v0.unit:Dot(vprime)) then
				castPoint = RayIntersection(hprime, v1, circlePoint, vp)
				
				if castPoint.Magnitude > 0 then
					local ray = Ray.new(hprime, castPoint - hprime)
					local hit, hitPoint, hitNormal = game.Workspace:FindPartOnRayWithIgnoreList(ray, {self.char}, false, false )
					
					if hit then
						local hprime2 = hitPoint + 0.1 * hitNormal.unit
						castPoint = hprime2
					end
				else
					castPoint = hprime
				end
			else
				castPoint = hprime
			end
			
			local ray = Ray.new(torsoPoint, (castPoint - torsoPoint))
			local hit, hitPoint, hitNormal = game.Workspace:FindPartOnRayWithIgnoreList(ray, {self.char}, false, false )
	
			if hit then
				local castPoint2 = hitPoint - 0.1 * (castPoint - torsoPoint).unit
				castPoint = castPoint2	
			end
		end
		
		castPoints[#castPoints + 1] = castPoint
	end
end

function Invisicam:CheckTorsoReference()
	if self.char then
		self.torsoPart = self.char:FindFirstChild("Torso")
		if not self.torsoPart then
			self.torsoPart = self.char:FindFirstChild("UpperTorso")
			if not self.torsoPart then
				self.torsoPart = self.char:FindFirstChild("HumanoidRootPart")
			end
		end
		
		self.headPart = self.char:FindFirstChild("Head")
	end
end

function Invisicam:CharacterAdded(char, player)
	-- We only want the LocalPlayer's character
	if player~=PlayersService.LocalPlayer then return end
	
	if self.childAddedConn then
		self.childAddedConn:Disconnect()
		self.childAddedConn = nil
	end
	if self.childRemovedConn then
		self.childRemovedConn:Disconnect()
		self.childRemovedConn = nil
	end

	self.char = char
	
	self.trackedLimbs = {}
	local function childAdded(child)
		if child:IsA("BasePart") then
			if LIMB_TRACKING_SET[child.Name] then
				self.trackedLimbs[child] = true
			end

			if (child.Name == "Torso" or child.Name == "UpperTorso") then
				self.torsoPart = child
			end

			if (child.Name == "Head") then
				self.headPart = child
			end			
		end
	end
	
	local function childRemoved(child)
		self.trackedLimbs[child] = nil
		
		-- If removed/replaced part is 'Torso' or 'UpperTorso' double check that we still have a TorsoPart to use
		self:CheckTorsoReference()
	end	
	
	self.childAddedConn = char.ChildAdded:Connect(childAdded)
	self.childRemovedConn = char.ChildRemoved:Connect(childRemoved)
	for _, child in pairs(self.char:GetChildren()) do
		childAdded(child)
	end
end

function Invisicam:SetMode(newMode)
	AssertTypes(newMode, 'number')
	for modeName, modeNum in pairs(MODE) do
		if modeNum == newMode then
			self.mode = newMode
			self.behaviorFunction = self.behaviors[self.mode]
			return
		end
	end
	error("Invalid mode number")
end

function Invisicam:GetObscuredParts()
	return self.savedHits
end

-- Want to turn off Invisicam? Be sure to call this after.
function Invisicam:Cleanup()
	for hit, originalFade in pairs(self.savedHits) do
		hit.LocalTransparencyModifier = originalFade
	end
end

function Invisicam:Update(dt, desiredCameraCFrame, desiredCameraFocus)
	
	-- Bail if there is no Character
	if not self.enabled or not self.char then
		return desiredCameraCFrame, desiredCameraFocus		
	end

	self.camera = game.Workspace.CurrentCamera
	
	-- TODO: Move this to a GetHumanoidRootPart helper, probably combine with CheckTorsoReference
	-- Make sure we still have a HumanoidRootPart
	if not self.humanoidRootPart then
		local humanoid = self.char:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.RootPart then
			self.humanoidRootPart = humanoid.RootPart
		else
			-- Not set up with Humanoid? Try and see if there's one in the Character at all:
			self.humanoidRootPart = self.char:FindFirstChild("HumanoidRootPart")
			if not self.humanoidRootPart then
				-- Bail out, since we're relying on HumanoidRootPart existing
				return desiredCameraCFrame, desiredCameraFocus
			end
		end
		
		-- TODO: Replace this with something more sensible
		local ancestryChangedConn
		ancestryChangedConn = self.humanoidRootPart.AncestryChanged:Connect(function(child, parent)
			if child == self.humanoidRootPart and not parent then 
				self.humanoidRootPart = nil
				if ancestryChangedConn and ancestryChangedConn.Connected then
					ancestryChangedConn:Disconnect()
					ancestryChangedConn = nil
				end
			end
		end)
	end
	
	if not self.torsoPart then
		self:CheckTorsoReference()
		if not self.torsoPart then
			-- Bail out, since we're relying on Torso existing, should never happen since we fall back to using HumanoidRootPart as torso
			return desiredCameraCFrame, desiredCameraFocus
		end
	end

	-- Make a list of world points to raycast to
	local castPoints = {}
	self.behaviorFunction(self, castPoints)
	
	-- Cast to get a list of objects between the camera and the cast points
	local currentHits = {}
	local ignoreList = {self.char}
	local function add(hit)
		currentHits[hit] = true
		if not self.savedHits[hit] then
			self.savedHits[hit] = hit.LocalTransparencyModifier
		end
	end
	
	local hitParts
	local hitPartCount = 0
	
	-- Hash table to treat head-ray-hit parts differently than the rest of the hit parts hit by other rays
	-- head/torso ray hit parts will be more transparent than peripheral parts when USE_STACKING_TRANSPARENCY is enabled
	local headTorsoRayHitParts = {}	
	local partIsTouchingCamera = {}
	
	local perPartTransparencyHeadTorsoHits = TARGET_TRANSPARENCY
	local perPartTransparencyOtherHits = TARGET_TRANSPARENCY
	
	if USE_STACKING_TRANSPARENCY then
	
		-- This first call uses head and torso rays to find out how many parts are stacked up
		-- for the purpose of calculating required per-part transparency
		local headPoint = self.headPart and self.headPart.CFrame.p or castPoints[1]
		local torsoPoint = self.torsoPart and self.torsoPart.CFrame.p or castPoints[2]
		hitParts = self.camera:GetPartsObscuringTarget({headPoint, torsoPoint}, ignoreList)
		
		-- Count how many things the sample rays passed through, including decals. This should only
		-- count decals facing the camera, but GetPartsObscuringTarget does not return surface normals,
		-- so my compromise for now is to just let any decal increase the part count by 1. Only one
		-- decal per part will be considered.
		for i = 1, #hitParts do
			local hitPart = hitParts[i]
			hitPartCount = hitPartCount + 1 -- count the part itself
			headTorsoRayHitParts[hitPart] = true
			for _, child in pairs(hitPart:GetChildren()) do
				if child:IsA('Decal') or child:IsA('Texture') then
					hitPartCount = hitPartCount + 1 -- count first decal hit, then break
					break
				end
			end
		end
		
		if (hitPartCount > 0) then
			perPartTransparencyHeadTorsoHits = math.pow( ((0.5 * TARGET_TRANSPARENCY) + (0.5 * TARGET_TRANSPARENCY / hitPartCount)), 1 / hitPartCount )
			perPartTransparencyOtherHits = math.pow( ((0.5 * TARGET_TRANSPARENCY_PERIPHERAL) + (0.5 * TARGET_TRANSPARENCY_PERIPHERAL / hitPartCount)), 1 / hitPartCount )
		end
	end
	
	-- Now get all the parts hit by all the rays
	hitParts = self.camera:GetPartsObscuringTarget(castPoints, ignoreList)
	
	local partTargetTransparency = {}
	
	-- Include decals and textures
	for i = 1, #hitParts do
		local hitPart = hitParts[i]
		
		partTargetTransparency[hitPart] =headTorsoRayHitParts[hitPart] and perPartTransparencyHeadTorsoHits or perPartTransparencyOtherHits

		-- If the part is not already as transparent or more transparent than what invisicam requires, add it to the list of
		-- parts to be modified by invisicam
		if hitPart.Transparency < partTargetTransparency[hitPart] then
			add(hitPart)
		end
		
		-- Check all decals and textures on the part
		for _, child in pairs(hitPart:GetChildren()) do
			if child:IsA('Decal') or child:IsA('Texture') then
				if (child.Transparency < partTargetTransparency[hitPart]) then
					partTargetTransparency[child] = partTargetTransparency[hitPart]
					add(child)
				end
			end
		end
	end
	
	-- Invisibilize objects that are in the way, restore those that aren't anymore
	for hitPart, originalLTM in pairs(self.savedHits) do
		if currentHits[hitPart] then
			-- LocalTransparencyModifier gets whatever value is required to print the part's total transparency to equal perPartTransparency			
			hitPart.LocalTransparencyModifier = (hitPart.Transparency < 1) and ((partTargetTransparency[hitPart] - hitPart.Transparency) / (1.0 - hitPart.Transparency)) or 0
		else -- Restore original pre-invisicam value of LTM
			hitPart.LocalTransparencyModifier = originalLTM
			self.savedHits[hitPart] = nil
		end
	end
	
	-- Invisicam does not change the camera values
	return desiredCameraCFrame, desiredCameraFocus
end

return Invisicam

--[[
	LegacyCamera - Implements legacy controller types: Attach, Fixed, Watch
	2018 Camera Update - AllYourBlox		
--]]

-- Local private variables and constants
local UNIT_X = Vector3.new(1,0,0)
local UNIT_Y = Vector3.new(0,1,0)
local UNIT_Z = Vector3.new(0,0,1)
local X1_Y0_Z1 = Vector3.new(1,0,1)	--Note: not a unit vector, used for projecting onto XZ plane
local ZERO_VECTOR3 = Vector3.new(0,0,0)
local ZERO_VECTOR2 = Vector2.new(0,0)

local VR_PITCH_FRACTION = 0.25
local tweenAcceleration = math.rad(220)		--Radians/Second^2
local tweenSpeed = math.rad(0)				--Radians/Second
local tweenMaxSpeed = math.rad(250)			--Radians/Second
local TIME_BEFORE_AUTO_ROTATE = 2.0 		--Seconds, used when auto-aligning camera with vehicles
local PORTRAIT_OFFSET = Vector3.new(0,-3,0)

local Util = require(script.Parent:WaitForChild("CameraUtils"))

--[[ Services ]]--
local PlayersService = game:GetService('Players')
local VRService = game:GetService("VRService")

--[[ The Module ]]--
local BaseCamera = require(script.Parent:WaitForChild("BaseCamera"))
local LegacyCamera = setmetatable({}, BaseCamera)
LegacyCamera.__index = LegacyCamera

function LegacyCamera.new()
	local self = setmetatable(BaseCamera.new(), LegacyCamera)
	
	self.cameraType = Enum.CameraType.Fixed
	self.lastUpdate = tick()	
	self.lastDistanceToSubject = nil
	
	return self
end

function LegacyCamera:GetModuleName()
	return "LegacyCamera"
end

function LegacyCamera:Test()
	print("LegacyCamera:Test()")
end

--[[ Functions overridden from BaseCamera ]]--
function LegacyCamera:SetCameraToSubjectDistance(desiredSubjectDistance)
	return BaseCamera.SetCameraToSubjectDistance(self,desiredSubjectDistance)
end

function LegacyCamera:Update(dt)
	
	-- Cannot update until cameraType has been set
	if not self.cameraType then return end	
	
	local now = tick()
	local timeDelta = (now - self.lastUpdate)
	local camera = 	workspace.CurrentCamera
	local newCameraCFrame = camera.CFrame
	local newCameraFocus = camera.Focus
	local player = PlayersService.LocalPlayer
	local humanoid = self:GetHumanoid()
	local cameraSubject = camera and camera.CameraSubject
	local isInVehicle = cameraSubject and cameraSubject:IsA('VehicleSeat')
	local isOnASkateboard = cameraSubject and cameraSubject:IsA('SkateboardPlatform')
	local isClimbing = humanoid and humanoid:GetState() == Enum.HumanoidStateType.Climbing
	
	if self.lastUpdate == nil or timeDelta > 1 then
		self.lastDistanceToSubject = nil
	end
	local subjectPosition = self:GetSubjectPosition()	
	
	if self.cameraType == Enum.CameraType.Fixed then
		if self.lastUpdate then
			-- Cap out the delta to 0.1 so we don't get some crazy things when we re-resume from
			local delta = math.min(0.1, now - self.lastUpdate)
			local gamepadRotation = self:UpdateGamepad()		
			self.rotateInput = self.rotateInput + (gamepadRotation * delta)
		end		
		
		if subjectPosition and player and camera then
			local distanceToSubject = self:GetCameraToSubjectDistance()
			local newLookVector = self:CalculateNewLookVector()
			self.rotateInput = ZERO_VECTOR2
			
			newCameraFocus = camera.Focus -- Fixed camera does not change focus
			newCameraCFrame = CFrame.new(camera.CFrame.p, camera.CFrame.p + (distanceToSubject * newLookVector))
		end
	elseif self.cameraType == Enum.CameraType.Attach then
		if subjectPosition and camera then
			local distanceToSubject = self:GetCameraToSubjectDistance()
			local humanoid = self:GetHumanoid()
			if self.lastUpdate and humanoid and humanoid.RootPart then
				
				-- Cap out the delta to 0.1 so we don't get some crazy things when we re-resume from
				local delta = math.min(0.1, now - self.lastUpdate)
				local gamepadRotation = self:UpdateGamepad()
				self.rotateInput = self.rotateInput + (gamepadRotation * delta)		
				
				local forwardVector = humanoid.RootPart.CFrame.lookVector

				local y = Util.GetAngleBetweenXZVectors(forwardVector, self:GetCameraLookVector())
				if Util.IsFinite(y) then
					-- Preserve vertical rotation from user input
					self.rotateInput = Vector2.new(y, self.rotateInput.Y)
				end
			end

			local newLookVector = self:CalculateNewLookVector()
			self.rotateInput = ZERO_VECTOR2

			newCameraFocus = CFrame.new(subjectPosition)
			newCameraCFrame = CFrame.new(subjectPosition - (distanceToSubject * newLookVector), subjectPosition)
		end
	elseif self.cameraType == Enum.CameraType.Watch then
		if subjectPosition and player and camera then
			local cameraLook = nil

			local humanoid = self:GetHumanoid()
			if humanoid and humanoid.RootPart then
				local diffVector = subjectPosition - camera.CFrame.p
				cameraLook = diffVector.unit

				if self.lastDistanceToSubject and self.lastDistanceToSubject == self:GetCameraToSubjectDistance() then
					-- Don't clobber the zoom if they zoomed the camera
					local newDistanceToSubject = diffVector.magnitude
					self:SetCameraToSubjectDistance(newDistanceToSubject)
				end
			end
			
			local distanceToSubject = self:GetCameraToSubjectDistance()
			local newLookVector = self:CalculateNewLookVector(cameraLook)
			self.rotateInput = ZERO_VECTOR2
			
			newCameraFocus = CFrame.new(subjectPosition)
			newCameraCFrame = CFrame.new(subjectPosition - (distanceToSubject * newLookVector), subjectPosition)

			self.lastDistanceToSubject = distanceToSubject
		end
	else
		-- Unsupported type, return current values unchanged
		return camera.CFrame, camera.Focus
	end
	
	self.lastUpdate = now
	return newCameraCFrame, newCameraFocus
end

return LegacyCamera

-- HappaTAS Forked Script

--[[
	MouseLockController - Replacement for ShiftLockController, manages use of mouse-locked mode
	2018 Camera Update - AllYourBlox
	
	mobile support added by gAOREK
--]]

--[[ Constants ]]--
local DEFAULT_MOUSE_LOCK_CURSOR = "rbxasset://textures/MouseLockedCursor.png"

local MOUSE_LOCK_ICON_ON = "rbxassetid://4109432113"
local MOUSE_LOCK_ICON_OFF = "rbxassetid://4109426420"

local CONTEXT_ACTION_NAME = "MouseLockSwitchAction"
local MOUSELOCK_ACTION_PRIORITY = Enum.ContextActionPriority.Default.Value

local Util = require(script.Parent:WaitForChild("CameraUtils"))

--[[ Services ]]--
local PlayersService = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Settings = UserSettings()	-- ignore warning
local GameSettings = Settings.GameSettings
local Mouse = PlayersService.LocalPlayer:GetMouse()

--[[ Variables ]]

--[[ The Module ]]--
local MouseLockController = {}
MouseLockController.__index = MouseLockController

function MouseLockController.new()
	local self = setmetatable({}, MouseLockController)

	self.isMouseLocked = false
	self.savedMouseCursor = nil
	self.boundKeys = {Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift} -- defaults

	self.mouseLockToggledEvent = Instance.new("BindableEvent")
	
	local boundKeysObj = script:FindFirstChild("BoundKeys")
	if (not boundKeysObj) or (not boundKeysObj:IsA("StringValue")) then
		-- If object with correct name was found, but it's not a StringValue, destroy and replace
		if boundKeysObj then
			boundKeysObj:Destroy()
		end

		boundKeysObj = Instance.new("StringValue")
		boundKeysObj.Name = "BoundKeys"
		boundKeysObj.Value = "LeftShift,RightShift"
		boundKeysObj.Parent = script
	end

	if boundKeysObj then
		boundKeysObj.Changed:Connect(function(value)
			self:OnBoundKeysObjectChanged(value)
		end)
		self:OnBoundKeysObjectChanged(boundKeysObj.Value) -- Initial setup call
	end

	-- Watch for changes to user's ControlMode and ComputerMovementMode settings and update the feature availability accordingly
	GameSettings.Changed:Connect(function(property)
		if property == "ControlMode" or property == "ComputerMovementMode" then
			self:UpdateMouseLockAvailability()
		end
	end)

	-- Watch for changes to DevEnableMouseLock and update the feature availability accordingly
	PlayersService.LocalPlayer:GetPropertyChangedSignal("DevEnableMouseLock"):Connect(function()
		self:UpdateMouseLockAvailability()
	end)

	-- Watch for changes to DevEnableMouseLock and update the feature availability accordingly
	PlayersService.LocalPlayer:GetPropertyChangedSignal("DevComputerMovementMode"):Connect(function()
		self:UpdateMouseLockAvailability()
	end)

	self:UpdateMouseLockAvailability()

	return self
end

function MouseLockController:GetIsMouseLocked()
	return self.isMouseLocked
end

function MouseLockController:GetBindableToggleEvent()
	return self.mouseLockToggledEvent.Event
end

function MouseLockController:GetMouseLockOffset()
	local offsetValueObj = script:FindFirstChild("CameraOffset")
	if offsetValueObj and offsetValueObj:IsA("Vector3Value") then
		return offsetValueObj.Value
	else
		-- If CameraOffset object was found but not correct type, destroy
		if offsetValueObj then
			offsetValueObj:Destroy()
		end
		offsetValueObj = Instance.new("Vector3Value")
		offsetValueObj.Name = "CameraOffset"
		offsetValueObj.Value = Vector3.new(1.75,0,0) -- Legacy Default Value
		offsetValueObj.Parent = script
	end

	if offsetValueObj and offsetValueObj.Value then
		return offsetValueObj.Value
	end

	return Vector3.new(1.75,0,0)
end

function MouseLockController:UpdateMouseLockAvailability()
	local devAllowsMouseLock = PlayersService.LocalPlayer.DevEnableMouseLock
	local devMovementModeIsScriptable = PlayersService.LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.Scriptable
	local userHasMouseLockModeEnabled = GameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch
	local userHasClickToMoveEnabled =  GameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove
	local MouseLockAvailable = devAllowsMouseLock and userHasMouseLockModeEnabled and not userHasClickToMoveEnabled and not devMovementModeIsScriptable

	if MouseLockAvailable~=self.enabled then
		self:EnableMouseLock(MouseLockAvailable)
	end
end

function MouseLockController:OnBoundKeysObjectChanged(newValue)
	self.boundKeys = {} -- Overriding defaults, note: possibly with nothing at all if boundKeysObj.Value is "" or contains invalid values
	for token in string.gmatch(newValue,"[^%s,]+") do
		for keyCode, keyEnum in pairs(Enum.KeyCode:GetEnumItems()) do
			if token == keyEnum.Name then
				self.boundKeys[#self.boundKeys+1] = keyEnum
				break
			end
		end
	end
	self:UnbindContextActions()
	self:BindContextActions()
end

--[[ Local Functions ]]--
function MouseLockController:OnMouseLockToggled(BypassScriptable)
	local c = workspace.CurrentCamera.CFrame
	if BypassScriptable then workspace.CurrentCamera.CameraType = "Custom" end
	self.isMouseLocked = not self.isMouseLocked

	if self.isMouseLocked then
		local cursorImageValueObj = script:FindFirstChild("CursorImage")
		if cursorImageValueObj and cursorImageValueObj:IsA("StringValue") and cursorImageValueObj.Value then
			self.savedMouseCursor = Mouse.Icon
			Mouse.Icon = cursorImageValueObj.Value
		else
			if cursorImageValueObj then
				cursorImageValueObj:Destroy()
			end
			cursorImageValueObj = Instance.new("StringValue")
			cursorImageValueObj.Name = "CursorImage"
			cursorImageValueObj.Value = DEFAULT_MOUSE_LOCK_CURSOR
			cursorImageValueObj.Parent = script
			self.savedMouseCursor = Mouse.Icon
			Mouse.Icon = DEFAULT_MOUSE_LOCK_CURSOR
		end
	else
		if self.savedMouseCursor then
			Mouse.Icon = self.savedMouseCursor
			self.savedMouseCursor = nil
		end
	end
	
	self.mouseLockToggledEvent:Fire()
	if BypassScriptable then
		game:GetService("RunService").Heartbeat:Wait()
		workspace.CurrentCamera.CameraType = "Scriptable"
	end
end

local LockShiftlock = false
function MouseLockController:DoMouseLockSwitch(name, state, input,BypassScriptable,IsScripted)
	if (state == Enum.UserInputState.Begin or UserInputService.TouchEnabled) and (not LockShiftlock or IsScripted) then
		self:OnMouseLockToggled(BypassScriptable)
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end

local MSL = false
function MouseLockController:BindContextActions()
	game.ReplicatedStorage.TASRS.MouseLockControllers.Value += 1
	if game.ReplicatedStorage.TASRS.MouseLockControllers.Value == 1 then
		game.ReplicatedStorage.TASRS.BindableEvents.ShiftlockSwitch.Event:Connect(function(BypassScriptable)
			if BypassScriptable then
				self:DoMouseLockSwitch('e',Enum.UserInputState.Begin,nil,true,true) 
			else
				self:DoMouseLockSwitch('e',Enum.UserInputState.Begin,nil,false,true)
			end
		end)
		game.ReplicatedStorage.TASRS.BindableEvents.LockShiftlock.Event:Connect(function(lock)
			LockShiftlock = lock
		end)
	end
	if (UserInputService.TouchEnabled) and (not MSL) and game.Workspace.HappaTAS.AddMobileShiftlock.Value then
		self.shiftLock = false

		local sg = Instance.new("ScreenGui",PlayersService.LocalPlayer.PlayerGui)
		sg.Name = "MobileShiftLock"
		sg.ResetOnSpawn = false

		local button = 	Instance.new("ImageButton",sg)
		button.Name = "ShiftLockButton"
		button.Position = UDim2.new(.8,-55,0.75,-55)
		button.Size = UDim2.new(0,65,0,65)
		button.Image = 	MOUSE_LOCK_ICON_OFF

		button.BackgroundTransparency = 1

		button.MouseButton1Click:Connect(function()
			self.shiftLock = not self.shiftLock
			button.Image = self.shiftLock and MOUSE_LOCK_ICON_ON or MOUSE_LOCK_ICON_OFF
			return self:DoMouseLockSwitch()
		end)

		self.actionGui = sg
		self.actionButton = button
		MSL = true
	else
		ContextActionService:BindActionAtPriority(CONTEXT_ACTION_NAME, function(name, state, input) 
			return self:DoMouseLockSwitch( name, state, input,workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable) 
		end, false, MOUSELOCK_ACTION_PRIORITY, unpack(self.boundKeys))
	end
end

function MouseLockController:UnbindContextActions()
	ContextActionService:UnbindAction(CONTEXT_ACTION_NAME)
end

function MouseLockController:IsMouseLocked()
	return self.enabled and self.isMouseLocked
end

function MouseLockController:EnableMouseLock(enable)
	if enable~=self.enabled then

		self.enabled = enable

		if self.enabled then
			-- Enabling the mode
			self:BindContextActions()
		else
			-- Disabling
			-- Restore mouse cursor
			if Mouse.Icon~="" then
				Mouse.Icon = ""
			end

			self:UnbindContextActions()

			-- If the mode is disabled while being used, fire the event to toggle it off
			if self.isMouseLocked then
				self.mouseLockToggledEvent:Fire()
			end

			self.isMouseLocked = false
		end

	end
end

return MouseLockController

--[[
	OrbitalCamera - Spherical coordinates control camera for top-down games
	2018 Camera Update - AllYourBlox
--]]

-- Local private variables and constants
local UNIT_X = Vector3.new(1,0,0)
local UNIT_Y = Vector3.new(0,1,0)
local UNIT_Z = Vector3.new(0,0,1)
local X1_Y0_Z1 = Vector3.new(1,0,1)	--Note: not a unit vector, used for projecting onto XZ plane
local ZERO_VECTOR3 = Vector3.new(0,0,0)
local ZERO_VECTOR2 = Vector2.new(0,0)
local TAU = 2 * math.pi

local VR_PITCH_FRACTION = 0.25
local tweenAcceleration = math.rad(220)		--Radians/Second^2
local tweenSpeed = math.rad(0)				--Radians/Second
local tweenMaxSpeed = math.rad(250)			--Radians/Second
local TIME_BEFORE_AUTO_ROTATE = 2.0 		--Seconds, used when auto-aligning camera with vehicles
local PORTRAIT_OFFSET = Vector3.new(0,-3,0)

--[[ Gamepad Support ]]--
local THUMBSTICK_DEADZONE = 0.2

-- Do not edit these values, they are not the developer-set limits, they are limits
-- to the values the camera system equations can correctly handle
local MIN_ALLOWED_ELEVATION_DEG = -80
local MAX_ALLOWED_ELEVATION_DEG = 80

local externalProperties = {}
externalProperties["InitialDistance"] 	= 25
externalProperties["MinDistance"] 		= 10
externalProperties["MaxDistance"] 		= 100
externalProperties["InitialElevation"] 	= 35
externalProperties["MinElevation"] 		= 35
externalProperties["MaxElevation"] 		= 35
externalProperties["ReferenceAzimuth"] 	= -45	-- Angle around the Y axis where the camera starts. -45 offsets the camera in the -X and +Z directions equally
externalProperties["CWAzimuthTravel"] 	= 90	-- How many degrees the camera is allowed to rotate from the reference position, CW as seen from above
externalProperties["CCWAzimuthTravel"] 	= 90	-- How many degrees the camera is allowed to rotate from the reference position, CCW as seen from above
externalProperties["UseAzimuthLimits"] 	= false -- Full rotation around Y axis available by default

local Util = require(script.Parent:WaitForChild("CameraUtils"))

--[[ Services ]]--
local PlayersService = game:GetService('Players')
local VRService = game:GetService("VRService")

--[[ Utility functions specific to OrbitalCamera ]]--
local function GetValueObject(name, defaultValue)
	local valueObj = script:FindFirstChild(name)
	if valueObj then
		return valueObj.Value
	end
	return defaultValue
end

--[[ The Module ]]--
local BaseCamera = require(script.Parent:WaitForChild("BaseCamera"))
local OrbitalCamera = setmetatable({}, BaseCamera)
OrbitalCamera.__index = OrbitalCamera


function OrbitalCamera.new()
	local self = setmetatable(BaseCamera.new(), OrbitalCamera)

	self.lastUpdate = tick()

	-- OrbitalCamera-specific members
	self.changedSignalConnections = {}
	self.refAzimuthRad = nil
	self.curAzimuthRad = nil
	self.minAzimuthAbsoluteRad = nil
	self.maxAzimuthAbsoluteRad = nil
	self.useAzimuthLimits = nil
	self.curElevationRad = nil
	self.minElevationRad = nil
	self.maxElevationRad = nil
	self.curDistance = nil
	self.minDistance = nil
	self.maxDistance = nil

	-- Gamepad
	self.r3ButtonDown = false
	self.l3ButtonDown = false
	self.gamepadDollySpeedMultiplier = 1

	self.lastUserPanCamera = tick()

	self.externalProperties = {}
	self.externalProperties["InitialDistance"] 	= 25
	self.externalProperties["MinDistance"] 		= 10
	self.externalProperties["MaxDistance"] 		= 100
	self.externalProperties["InitialElevation"] 	= 35
	self.externalProperties["MinElevation"] 		= 35
	self.externalProperties["MaxElevation"] 		= 35
	self.externalProperties["ReferenceAzimuth"] 	= -45	-- Angle around the Y axis where the camera starts. -45 offsets the camera in the -X and +Z directions equally
	self.externalProperties["CWAzimuthTravel"] 	= 90	-- How many degrees the camera is allowed to rotate from the reference position, CW as seen from above
	self.externalProperties["CCWAzimuthTravel"] 	= 90	-- How many degrees the camera is allowed to rotate from the reference position, CCW as seen from above
	self.externalProperties["UseAzimuthLimits"] 	= false -- Full rotation around Y axis available by default
	self:LoadNumberValueParameters()

	return self
end

function OrbitalCamera:LoadOrCreateNumberValueParameter(name, valueType, updateFunction)
	local valueObj = script:FindFirstChild(name)

	if valueObj and valueObj:isA(valueType) then
		-- Value object exists and is the correct type, use its value
		self.externalProperties[name] = valueObj.Value
	elseif self.externalProperties[name] ~= nil then
		-- Create missing (or replace incorrectly-typed) valueObject with default value
		valueObj = Instance.new(valueType)
		valueObj.Name = name
		valueObj.Parent = script
		valueObj.Value = self.externalProperties[name]
	else
		print("externalProperties table has no entry for ",name)
		return
	end

	if updateFunction then
		if self.changedSignalConnections[name] then
			self.changedSignalConnections[name]:Disconnect()
		end
		self.changedSignalConnections[name] = valueObj.Changed:Connect(function(newValue)
			self.externalProperties[name] = newValue
			updateFunction(self)
		end)
	end
end

function OrbitalCamera:SetAndBoundsCheckAzimuthValues()
	self.minAzimuthAbsoluteRad = math.rad(self.externalProperties["ReferenceAzimuth"]) - math.abs(math.rad(self.externalProperties["CWAzimuthTravel"]))
	self.maxAzimuthAbsoluteRad = math.rad(self.externalProperties["ReferenceAzimuth"]) + math.abs(math.rad(self.externalProperties["CCWAzimuthTravel"]))
	self.useAzimuthLimits = self.externalProperties["UseAzimuthLimits"]
	if self.useAzimuthLimits then
		self.curAzimuthRad = math.max(self.curAzimuthRad, self.minAzimuthAbsoluteRad)
		self.curAzimuthRad = math.min(self.curAzimuthRad, self.maxAzimuthAbsoluteRad)
	end
end

function OrbitalCamera:SetAndBoundsCheckElevationValues()
	-- These degree values are the direct user input values. It is deliberate that they are
	-- ranged checked only against the extremes, and not against each other. Any time one
	-- is changed, both of the internal values in radians are recalculated. This allows for
	-- A developer to change the values in any order and for the end results to be that the
	-- internal values adjust to match intent as best as possible.
	local minElevationDeg = math.max(self.externalProperties["MinElevation"], MIN_ALLOWED_ELEVATION_DEG)
	local maxElevationDeg = math.min(self.externalProperties["MaxElevation"], MAX_ALLOWED_ELEVATION_DEG)

	-- Set internal values in radians
	self.minElevationRad = math.rad(math.min(minElevationDeg, maxElevationDeg))
	self.maxElevationRad = math.rad(math.max(minElevationDeg, maxElevationDeg))
	self.curElevationRad = math.max(self.curElevationRad, self.minElevationRad)
	self.curElevationRad = math.min(self.curElevationRad, self.maxElevationRad)
end

function OrbitalCamera:SetAndBoundsCheckDistanceValues()
	self.minDistance = self.externalProperties["MinDistance"]
	self.maxDistance = self.externalProperties["MaxDistance"]
	self.curDistance = math.max(self.curDistance, self.minDistance)
	self.curDistance = math.min(self.curDistance, self.maxDistance)
end

-- This loads from, or lazily creates, NumberValue objects for exposed parameters
function OrbitalCamera:LoadNumberValueParameters()
	-- These initial values do not require change listeners since they are read only once
	self:LoadOrCreateNumberValueParameter("InitialElevation", "NumberValue", nil)
	self:LoadOrCreateNumberValueParameter("InitialDistance", "NumberValue", nil)

	-- Note: ReferenceAzimuth is also used as an initial value, but needs a change listener because it is used in the calculation of the limits
	self:LoadOrCreateNumberValueParameter("ReferenceAzimuth", "NumberValue", self.SetAndBoundsCheckAzimuthValue)
	self:LoadOrCreateNumberValueParameter("CWAzimuthTravel", "NumberValue", self.SetAndBoundsCheckAzimuthValues)
	self:LoadOrCreateNumberValueParameter("CCWAzimuthTravel", "NumberValue", self.SetAndBoundsCheckAzimuthValues)
	self:LoadOrCreateNumberValueParameter("MinElevation", "NumberValue", self.SetAndBoundsCheckElevationValues)
	self:LoadOrCreateNumberValueParameter("MaxElevation", "NumberValue", self.SetAndBoundsCheckElevationValues)
	self:LoadOrCreateNumberValueParameter("MinDistance", "NumberValue", self.SetAndBoundsCheckDistanceValues)
	self:LoadOrCreateNumberValueParameter("MaxDistance", "NumberValue", self.SetAndBoundsCheckDistanceValues)
	self:LoadOrCreateNumberValueParameter("UseAzimuthLimits", "BoolValue", self.SetAndBoundsCheckAzimuthValues)

	-- Internal values set (in radians, from degrees), plus sanitization
	self.curAzimuthRad = math.rad(self.externalProperties["ReferenceAzimuth"])
	self.curElevationRad = math.rad(self.externalProperties["InitialElevation"])
	self.curDistance = self.externalProperties["InitialDistance"]

	self:SetAndBoundsCheckAzimuthValues()
	self:SetAndBoundsCheckElevationValues()
	self:SetAndBoundsCheckDistanceValues()
end

function OrbitalCamera:GetModuleName()
	return "OrbitalCamera"
end

function OrbitalCamera:SetInitialOrientation(humanoid)
	if not humanoid or not humanoid.RootPart then
		warn("OrbitalCamera could not set initial orientation due to missing humanoid")
		return
	end
	local newDesiredLook = (humanoid.RootPart.CFrame.lookVector - Vector3.new(0,0.23,0)).unit
	local horizontalShift = Util.GetAngleBetweenXZVectors(newDesiredLook, self:GetCameraLookVector())
	local vertShift = math.asin(self:GetCameraLookVector().y) - math.asin(newDesiredLook.y)
	if not Util.IsFinite(horizontalShift) then
		horizontalShift = 0
	end
	if not Util.IsFinite(vertShift) then
		vertShift = 0
	end
	self.rotateInput = Vector2.new(horizontalShift, vertShift)
end

--[[ Functions of BaseCamera that are overridden by OrbitalCamera ]]--
function OrbitalCamera:GetCameraToSubjectDistance()
	return self.curDistance
end

function OrbitalCamera:SetCameraToSubjectDistance(desiredSubjectDistance)
	print("OrbitalCamera SetCameraToSubjectDistance ",desiredSubjectDistance)
	local player = PlayersService.LocalPlayer
	if player then
		self.currentSubjectDistance = Util.Clamp(self.minDistance, self.maxDistance, desiredSubjectDistance)

		-- OrbitalCamera is not allowed to go into the first-person range
		self.currentSubjectDistance = math.max(self.currentSubjectDistance, self.FIRST_PERSON_DISTANCE_THRESHOLD)
	end
	self.inFirstPerson = false
	self:UpdateMouseBehavior()
	return self.currentSubjectDistance
end

function OrbitalCamera:CalculateNewLookVector(suppliedLookVector, xyRotateVector)
	local currLookVector = suppliedLookVector or self:GetCameraLookVector()
	local currPitchAngle = math.asin(currLookVector.y)
	local yTheta = Util.Clamp(currPitchAngle - math.rad(MAX_ALLOWED_ELEVATION_DEG), currPitchAngle - math.rad(MIN_ALLOWED_ELEVATION_DEG), xyRotateVector.y)
	local constrainedRotateInput = Vector2.new(xyRotateVector.x, yTheta)
	local startCFrame = CFrame.new(ZERO_VECTOR3, currLookVector)
	local newLookVector = (CFrame.Angles(0, -constrainedRotateInput.x, 0) * startCFrame * CFrame.Angles(-constrainedRotateInput.y,0,0)).lookVector
	return newLookVector
end

function OrbitalCamera:GetGamepadPan(name, state, input)
	if input.UserInputType == self.activeGamepad and input.KeyCode == Enum.KeyCode.Thumbstick2 then
		if self.r3ButtonDown or self.l3ButtonDown then
		-- R3 or L3 Thumbstick is depressed, right stick controls dolly in/out
			if (input.Position.Y > THUMBSTICK_DEADZONE) then
				self.gamepadDollySpeedMultiplier = 0.96
			elseif (input.Position.Y < -THUMBSTICK_DEADZONE) then
				self.gamepadDollySpeedMultiplier = 1.04
			else
				self.gamepadDollySpeedMultiplier = 1.00
			end
		else
			if state == Enum.UserInputState.Cancel then
				self.gamepadPanningCamera = ZERO_VECTOR2
				return
			end

			local inputVector = Vector2.new(input.Position.X, -input.Position.Y)
			if inputVector.magnitude > THUMBSTICK_DEADZONE then
				self.gamepadPanningCamera = Vector2.new(input.Position.X, -input.Position.Y)
			else
				self.gamepadPanningCamera = ZERO_VECTOR2
			end
		end
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end

function OrbitalCamera:DoGamepadZoom(name, state, input)
	if input.UserInputType == self.activeGamepad and (input.KeyCode == Enum.KeyCode.ButtonR3 or input.KeyCode == Enum.KeyCode.ButtonL3) then
		if (state == Enum.UserInputState.Begin) then
			self.r3ButtonDown = input.KeyCode == Enum.KeyCode.ButtonR3
			self.l3ButtonDown = input.KeyCode == Enum.KeyCode.ButtonL3
		elseif (state == Enum.UserInputState.End) then
			if (input.KeyCode == Enum.KeyCode.ButtonR3) then
				self.r3ButtonDown = false
			elseif (input.KeyCode == Enum.KeyCode.ButtonL3) then
				self.l3ButtonDown = false
			end
			if (not self.r3ButtonDown) and (not self.l3ButtonDown) then
				self.gamepadDollySpeedMultiplier = 1.00
			end
		end
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end

function OrbitalCamera:BindGamepadInputActions()
	self:BindAction("OrbitalCamGamepadPan", function(name, state, input) return self:GetGamepadPan(name, state, input) end,
		false, Enum.KeyCode.Thumbstick2)
	self:BindAction("OrbitalCamGamepadZoom", function(name, state, input) return self:DoGamepadZoom(name, state, input) end,
		false, Enum.KeyCode.ButtonR3, Enum.KeyCode.ButtonL3)
end


-- [[ Update ]]--
function OrbitalCamera:Update(dt)
	local now = tick()
	local timeDelta = (now - self.lastUpdate)
	local userPanningTheCamera = (self.UserPanningTheCamera == true)
	local camera = 	workspace.CurrentCamera
	local newCameraCFrame = camera.CFrame
	local newCameraFocus = camera.Focus
	local player = PlayersService.LocalPlayer
	local humanoid = self:GetHumanoid()
	local cameraSubject = camera and camera.CameraSubject
	local isInVehicle = cameraSubject and cameraSubject:IsA('VehicleSeat')
	local isOnASkateboard = cameraSubject and cameraSubject:IsA('SkateboardPlatform')

	if self.lastUpdate == nil or timeDelta > 1 then
		self.lastCameraTransform = nil
	end

	if self.lastUpdate then
		local gamepadRotation = self:UpdateGamepad()

		if self:ShouldUseVRRotation() then
			self.RotateInput = self.RotateInput + self:GetVRRotationInput()
		else
			-- Cap out the delta to 0.1 so we don't get some crazy things when we re-resume from
			local delta = math.min(0.1, timeDelta)

			if gamepadRotation ~= ZERO_VECTOR2 then
				userPanningTheCamera = true
				self.rotateInput = self.rotateInput + (gamepadRotation * delta)
			end

			local angle = 0
			if not (isInVehicle or isOnASkateboard) then
				angle = angle + (self.TurningLeft and -120 or 0)
				angle = angle + (self.TurningRight and 120 or 0)
			end

			if angle ~= 0 then
				self.rotateInput = self.rotateInput +  Vector2.new(math.rad(angle * delta), 0)
				userPanningTheCamera = true
			end
		end
	end

	-- Reset tween speed if user is panning
	if userPanningTheCamera then
		tweenSpeed = 0
		self.lastUserPanCamera = tick()
	end

	local userRecentlyPannedCamera = now - self.lastUserPanCamera < TIME_BEFORE_AUTO_ROTATE
	local subjectPosition = self:GetSubjectPosition()

	if subjectPosition and player and camera then

		-- Process any dollying being done by gamepad
		-- TODO: Move this
		if self.gamepadDollySpeedMultiplier ~= 1 then
			self:SetCameraToSubjectDistance(self.currentSubjectDistance * self.gamepadDollySpeedMultiplier)
		end

		local VREnabled = VRService.VREnabled
		newCameraFocus = VREnabled and self:GetVRFocus(subjectPosition, timeDelta) or CFrame.new(subjectPosition)

		local cameraFocusP = newCameraFocus.p
		if VREnabled and not self:IsInFirstPerson() then
			local cameraHeight = self:GetCameraHeight()
			local vecToSubject = (subjectPosition - camera.CFrame.p)
			local distToSubject = vecToSubject.magnitude

			-- Only move the camera if it exceeded a maximum distance to the subject in VR
			if distToSubject > self.currentSubjectDistance or self.rotateInput.x ~= 0 then
				local desiredDist = math.min(distToSubject, self.currentSubjectDistance)

				-- Note that CalculateNewLookVector is overridden from BaseCamera
				vecToSubject = self:CalculateNewLookVector(vecToSubject.unit * X1_Y0_Z1, Vector2.new(self.rotateInput.x, 0)) * desiredDist

				local newPos = cameraFocusP - vecToSubject
				local desiredLookDir = camera.CFrame.lookVector
				if self.rotateInput.x ~= 0 then
					desiredLookDir = vecToSubject
				end
				local lookAt = Vector3.new(newPos.x + desiredLookDir.x, newPos.y, newPos.z + desiredLookDir.z)
				self.RotateInput = ZERO_VECTOR2

				newCameraCFrame = CFrame.new(newPos, lookAt) + Vector3.new(0, cameraHeight, 0)
			end
		else
			-- self.RotateInput is a Vector2 of mouse movement deltas since last update
			self.curAzimuthRad = self.curAzimuthRad - self.rotateInput.x

			if self.useAzimuthLimits then
				self.curAzimuthRad = Util.Clamp(self.minAzimuthAbsoluteRad, self.maxAzimuthAbsoluteRad, self.curAzimuthRad)
			else
				self.curAzimuthRad = (self.curAzimuthRad ~= 0) and (math.sign(self.curAzimuthRad) * (math.abs(self.curAzimuthRad) % TAU)) or 0
			end

			self.curElevationRad = Util.Clamp(self.minElevationRad, self.maxElevationRad, self.curElevationRad + self.rotateInput.y)

			local cameraPosVector = self.currentSubjectDistance * ( CFrame.fromEulerAnglesYXZ( -self.curElevationRad, self.curAzimuthRad, 0 ) * UNIT_Z )
			local camPos = subjectPosition + cameraPosVector

			newCameraCFrame = CFrame.new(camPos, subjectPosition)

			self.rotateInput = ZERO_VECTOR2
		end

		self.lastCameraTransform = newCameraCFrame
		self.lastCameraFocus = newCameraFocus
		if (isInVehicle or isOnASkateboard) and cameraSubject:IsA('BasePart') then
			self.lastSubjectCFrame = cameraSubject.CFrame
		else
			self.lastSubjectCFrame = nil
		end
	end

	self.lastUpdate = now
	return newCameraCFrame, newCameraFocus
end

return OrbitalCamera

--[[
	Poppercam - Occlusion module that brings the camera closer to the subject when objects are blocking the view.
--]]

local ZoomController =  require(script.Parent:WaitForChild("ZoomController"))

local TransformExtrapolator = {} do
	TransformExtrapolator.__index = TransformExtrapolator

	local CF_IDENTITY = CFrame.new()

	local function cframeToAxis(cframe)
		local axis, angle = cframe:toAxisAngle()
		return axis*angle
	end

	local function axisToCFrame(axis)
		local angle = axis.magnitude
		if angle > 1e-5 then
			return CFrame.fromAxisAngle(axis, angle)
		end
		return CF_IDENTITY
	end

	local function extractRotation(cf)
		local _, _, _, xx, yx, zx, xy, yy, zy, xz, yz, zz = cf:components()
		return CFrame.new(0, 0, 0, xx, yx, zx, xy, yy, zy, xz, yz, zz)
	end

	function TransformExtrapolator.new()
		return setmetatable({
			lastCFrame = nil,
		}, TransformExtrapolator)
	end

	function TransformExtrapolator:Step(dt, currentCFrame)
		local lastCFrame = self.lastCFrame or currentCFrame
		self.lastCFrame = currentCFrame

		local currentPos = currentCFrame.p
		local currentRot = extractRotation(currentCFrame)

		local lastPos = lastCFrame.p
		local lastRot = extractRotation(lastCFrame)

		-- Estimate velocities from the delta between now and the last frame
		-- This estimation can be a little noisy.
		local dp = (currentPos - lastPos)/dt
		local dr = cframeToAxis(currentRot*lastRot:inverse())/dt

		local function extrapolate(t)
			local p = dp*t + currentPos
			local r = axisToCFrame(dr*t)*currentRot
			return r + p
		end

		return {
			extrapolate = extrapolate,
			posVelocity = dp,
			rotVelocity = dr,
		}
	end

	function TransformExtrapolator:Reset()
		self.lastCFrame = nil
	end
end

--[[ The Module ]]--
local BaseOcclusion = require(script.Parent:WaitForChild("BaseOcclusion"))
local Poppercam = setmetatable({}, BaseOcclusion)
Poppercam.__index = Poppercam

function Poppercam.new()
	local self = setmetatable(BaseOcclusion.new(), Poppercam)
	self.focusExtrapolator = TransformExtrapolator.new()
	return self
end

function Poppercam:GetOcclusionMode()
	return Enum.DevCameraOcclusionMode.Zoom
end

function Poppercam:Enable(enable)
	self.focusExtrapolator:Reset()
end

function Poppercam:Update(renderDt, desiredCameraCFrame, desiredCameraFocus, cameraController)
	local rotatedFocus = CFrame.new(desiredCameraFocus.p, desiredCameraCFrame.p)*CFrame.new(
		0, 0, 0,
		-1, 0, 0,
		0, 1, 0,
		0, 0, -1
	)
	local extrapolation = self.focusExtrapolator:Step(renderDt, rotatedFocus)
	local zoom = ZoomController.Update(renderDt, rotatedFocus, extrapolation)
	return rotatedFocus*CFrame.new(0, 0, zoom), desiredCameraFocus
end

-- Called when character is added
function Poppercam:CharacterAdded(character, player)
end

-- Called when character is about to be removed
function Poppercam:CharacterRemoving(character, player)
end

function Poppercam:OnCameraSubjectChanged(newSubject)
end

return Poppercam

--[[
	Poppercam - Occlusion module that brings the camera closer to the subject when objects are blocking the view
	Refactored for 2018 Camera Update but functionality is unchanged - AllYourBlox		
--]]

--[[ Camera Maths Utilities Library ]]--
local Util = require(script.Parent:WaitForChild("CameraUtils"))

local PlayersService = game:GetService("Players")
local POP_RESTORE_RATE = 0.3
local MIN_CAMERA_ZOOM = 0.5
local VALID_SUBJECTS = {
	'Humanoid',
	'VehicleSeat',
	'SkateboardPlatform',
}

local portraitPopperFixFlagExists, portraitPopperFixFlagEnabled = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserPortraitPopperFix")
end)
local FFlagUserPortraitPopperFix = portraitPopperFixFlagExists and portraitPopperFixFlagEnabled


--[[ The Module ]]--
local BaseOcclusion = require(script.Parent:WaitForChild("BaseOcclusion"))
local Poppercam = setmetatable({}, BaseOcclusion)
Poppercam.__index = Poppercam

function Poppercam.new()
	local self = setmetatable(BaseOcclusion.new(), Poppercam)
	
	self.camera = nil
	self.cameraSubjectChangeConn = nil
	
	self.subjectPart = nil
	
	self.playerCharacters = {} 	-- For ignoring in raycasts
	self.vehicleParts = {} 		-- Also just for ignoring
	
	self.lastPopAmount = 0
	self.lastZoomLevel = 0
	self.popperEnabled = false
	
	return self
end

function Poppercam:GetOcclusionMode()
	return Enum.DevCameraOcclusionMode.Zoom
end

function Poppercam:Enable(enable)
	
end

-- Called when character is added
function Poppercam:CharacterAdded(char, player)
	self.playerCharacters[player] = char
end

-- Called when character is about to be removed
function Poppercam:CharacterRemoving(char, player)
	self.playerCharacters[player] = nil
end

function Poppercam:Update(dt, desiredCameraCFrame, desiredCameraFocus)
	if self.popperEnabled then
		self.camera = game.Workspace.CurrentCamera
		local newCameraCFrame = desiredCameraCFrame
		local focusPoint = desiredCameraFocus.p

		if FFlagUserPortraitPopperFix and self.subjectPart then
			focusPoint = self.subjectPart.CFrame.p
		end

		local ignoreList = {}
		for _, character in pairs(self.playerCharacters) do
			ignoreList[#ignoreList + 1] = character
		end
		for i = 1, #self.vehicleParts do
			ignoreList[#ignoreList + 1] = self.vehicleParts[i]
		end
		
		-- Get largest cutoff distance
		-- Note that the camera CFrame must be set here, because the current implementation of GetLargestCutoffDistance
		-- uses the current camera CFrame directly (it cannot yet be passed the desiredCameraCFrame).
		local prevCameraCFrame = self.camera.CFrame
		self.camera.CFrame = desiredCameraCFrame
		self.camera.Focus = desiredCameraFocus
		local largest = self.camera:GetLargestCutoffDistance(ignoreList)

		-- Then check if the player zoomed since the last frame,
		-- and if so, reset our pop history so we stop tweening
		local zoomLevel = (desiredCameraCFrame.p - focusPoint).Magnitude
		if math.abs(zoomLevel - self.lastZoomLevel) > 0.001 then
			self.lastPopAmount = 0
		end
		
		-- Finally, zoom the camera in (pop) by that most-cut-off amount, or the last pop amount if that's more
		local popAmount = largest
		if self.lastPopAmount > popAmount then
			popAmount = self.lastPopAmount
		end

		if popAmount > 0 then
			newCameraCFrame = desiredCameraCFrame + (desiredCameraCFrame.lookVector * popAmount)
			self.lastPopAmount = popAmount - POP_RESTORE_RATE -- Shrink it for the next frame
			if self.lastPopAmount < 0 then
				self.lastPopAmount = 0
			end
		end

		self.lastZoomLevel = zoomLevel
		
		-- Stop shift lock being able to see through walls by manipulating Camera focus inside the wall
--		if EnabledCamera and EnabledCamera:GetShiftLock() and not EnabledCamera:IsInFirstPerson() then
--			if EnabledCamera:GetCameraActualZoom() < 1 then
--				local subjectPosition = EnabledCamera.lastSubjectPosition 
--				if subjectPosition then
--					Camera.Focus = CFrame_new(subjectPosition)
--					Camera.CFrame = CFrame_new(subjectPosition - MIN_CAMERA_ZOOM*EnabledCamera:GetCameraLook(), subjectPosition)
--				end
--			end
--		end
		return newCameraCFrame, desiredCameraFocus
	end
	
	-- Return unchanged values
	return desiredCameraCFrame, desiredCameraFocus
end

function Poppercam:OnCameraSubjectChanged(newSubject)
	self.vehicleParts = {}

	self.lastPopAmount = 0

	if newSubject then
		-- Determine if we should be popping at all
		self.popperEnabled = false
		for _, subjectType in pairs(VALID_SUBJECTS) do
			if newSubject:IsA(subjectType) then
				self.popperEnabled = true
				break
			end
		end

		-- Get all parts of the vehicle the player is controlling
		if newSubject:IsA('VehicleSeat') then
			self.vehicleParts = newSubject:GetConnectedParts(true)
		end
	
		if FFlagUserPortraitPopperFix then
			if newSubject:IsA("BasePart") then
				self.subjectPart = newSubject
			elseif newSubject:IsA("Model") then
				if newSubject.PrimaryPart then
					self.subjectPart = newSubject.PrimaryPart
				else
					-- Model has no PrimaryPart set, just use first BasePart
					-- we can find as better-than-nothing solution (can still fail)
					for _, child in pairs(newSubject:GetChildren()) do
						if child:IsA("BasePart") then
							self.subjectPart = child
							break
						end
					end	
				end
			elseif newSubject:IsA("Humanoid") then
				self.subjectPart = newSubject.RootPart
  			end
  		end
  	end
end

return Poppercam

--[[
	TransparencyController - Manages transparency of player character at close camera-to-subject distances
	2018 Camera Update - AllYourBlox		
--]]

local MAX_TWEEN_RATE = 2.8 -- per second

local Util = require(script.Parent:WaitForChild("CameraUtils"))

--[[ The Module ]]--
local TransparencyController = {}
TransparencyController.__index = TransparencyController

function TransparencyController.new()
	local self = setmetatable({}, TransparencyController)
	
	self.lastUpdate = tick()
	self.transparencyDirty = false
	self.enabled = false
	self.lastTransparency = nil

	self.descendantAddedConn, self.descendantRemovingConn = nil, nil
	self.toolDescendantAddedConns = {}
	self.toolDescendantRemovingConns = {}
	self.cachedParts = {}
	
	return self
end


function TransparencyController:HasToolAncestor(object)
	if object.Parent == nil then return false end
	return object.Parent:IsA('Tool') or self:HasToolAncestor(object.Parent)
end

function TransparencyController:IsValidPartToModify(part)
	if part:IsA('BasePart') or part:IsA('Decal') then
		return not self:HasToolAncestor(part)
	end
	return false
end

function TransparencyController:CachePartsRecursive(object)
	if object then
		if self:IsValidPartToModify(object) then
			self.cachedParts[object] = true
			self.transparencyDirty = true
		end
		for _, child in pairs(object:GetChildren()) do
			self:CachePartsRecursive(child)
		end
	end
end

function TransparencyController:TeardownTransparency()
	for child, _ in pairs(self.cachedParts) do
		child.LocalTransparencyModifier = 0
	end
	self.cachedParts = {}
	self.transparencyDirty = true
	self.lastTransparency = nil

	if self.descendantAddedConn then
		self.descendantAddedConn:disconnect()
		self.descendantAddedConn = nil
	end
	if self.descendantRemovingConn then
		self.descendantRemovingConn:disconnect()
		self.descendantRemovingConn = nil
	end
	for object, conn in pairs(self.toolDescendantAddedConns) do
		conn:Disconnect()
		self.toolDescendantAddedConns[object] = nil
	end
	for object, conn in pairs(self.toolDescendantRemovingConns) do
		conn:Disconnect()
		self.toolDescendantRemovingConns[object] = nil
	end
end

function TransparencyController:SetupTransparency(character)
	self:TeardownTransparency()

	if self.descendantAddedConn then self.descendantAddedConn:disconnect() end
	self.descendantAddedConn = character.DescendantAdded:Connect(function(object)
		-- This is a part we want to invisify
		if self:IsValidPartToModify(object) then
			self.cachedParts[object] = true
			self.transparencyDirty = true
		-- There is now a tool under the character
		elseif object:IsA('Tool') then
			if self.toolDescendantAddedConns[object] then self.toolDescendantAddedConns[object]:Disconnect() end
			self.toolDescendantAddedConns[object] = object.DescendantAdded:Connect(function(toolChild)
				self.cachedParts[toolChild] = nil
				if toolChild:IsA('BasePart') or toolChild:IsA('Decal') then
					-- Reset the transparency
					toolChild.LocalTransparencyModifier = 0
				end
			end)
			if self.toolDescendantRemovingConns[object] then self.toolDescendantRemovingConns[object]:disconnect() end
			self.toolDescendantRemovingConns[object] = object.DescendantRemoving:Connect(function(formerToolChild)
				wait() -- wait for new parent
				if character and formerToolChild and formerToolChild:IsDescendantOf(character) then
					if self:IsValidPartToModify(formerToolChild) then
						self.cachedParts[formerToolChild] = true
						self.transparencyDirty = true
					end
				end
			end)
		end
	end)
	if self.descendantRemovingConn then self.descendantRemovingConn:disconnect() end
	self.descendantRemovingConn = character.DescendantRemoving:connect(function(object)
		if self.cachedParts[object] then
			self.cachedParts[object] = nil
			-- Reset the transparency
			object.LocalTransparencyModifier = 0
		end
	end)
	self:CachePartsRecursive(character)
end


function TransparencyController:Enable(enable)
	if self.enabled ~= enable then
		self.enabled = enable
		self:Update()
	end
end

function TransparencyController:SetSubject(subject)
	local character = nil
	if subject and subject:IsA("Humanoid") then
		character = subject.Parent
	end
	if subject and subject:IsA("VehicleSeat") and subject.Occupant then
		character = subject.Occupant.Parent
	end
	if character then
		self:SetupTransparency(character)
	else
		self:TeardownTransparency()
	end
end

function TransparencyController:Update()
	local instant = false
	local now = tick()
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		local transparency = 0
		if not self.enabled then
			instant = true
		else
			local distance = (currentCamera.Focus.p - currentCamera.CoordinateFrame.p).magnitude
			transparency = (distance<2) and (1.0-(distance-0.5)/1.5) or 0 --(7 - distance) / 5
			if transparency < 0.5 then
				transparency = 0
			end

			if self.lastTransparency then
				local deltaTransparency = transparency - self.lastTransparency
				
				-- Don't tween transparency if it is instant or your character was fully invisible last frame
				if not instant and transparency < 1 and self.lastTransparency < 0.95 then
					local maxDelta = MAX_TWEEN_RATE * (now - self.lastUpdate)
					deltaTransparency = Util.Clamp(-maxDelta, maxDelta, deltaTransparency)
				end
				transparency = self.lastTransparency + deltaTransparency
			else
				self.transparencyDirty = true
			end

			transparency = Util.Clamp(0, 1, Util.Round(transparency, 2))
		end

		if self.transparencyDirty or self.lastTransparency ~= transparency then
			for child, _ in pairs(self.cachedParts) do
				child.LocalTransparencyModifier = transparency
			end
			self.transparencyDirty = false
			self.lastTransparency = transparency
		end
	end
	self.lastUpdate = now
end

return TransparencyController

-- HappaTAS Forked Script

-- Zoom
-- Controls the distance between the focus and the camera.
local SpringRemoved
game.ReplicatedStorage.TASRS.BindableEvents.RemoveZoomSpring.Event:Connect(function()
	SpringRemoved = true
	game:GetService("RunService").Heartbeat:Wait()
	SpringRemoved = false
end)

local ZOOM_STIFFNESS = 4.5
local ZOOM_DEFAULT = 12.5
local ZOOM_ACCELERATION = 0.0375

local MIN_FOCUS_DIST = .5
local DIST_OPAQUE = 1

local Popper = require(script:WaitForChild("Popper"))

local clamp = math.clamp
local exp = math.exp
local min = math.min
local max = math.max
local pi = math.pi

local cameraMinZoomDistance, cameraMaxZoomDistance do
	local Player = game:GetService("Players").LocalPlayer

	local function updateBounds()
		cameraMinZoomDistance = Player.CameraMinZoomDistance
		cameraMaxZoomDistance = Player.CameraMaxZoomDistance
	end

	updateBounds()

	Player:GetPropertyChangedSignal("CameraMinZoomDistance"):Connect(updateBounds)
	Player:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(updateBounds)
end

local ConstrainedSpring = {} do
	ConstrainedSpring.__index = ConstrainedSpring

	function ConstrainedSpring.new(freq, x, minValue, maxValue)
		x = clamp(x, minValue, maxValue)
		return setmetatable({
			freq = freq, -- Undamped frequency (Hz)
			x = x, -- Current position
			v = 0, -- Current velocity
			minValue = minValue, -- Minimum bound
			maxValue = maxValue, -- Maximum bound
			goal = x, -- Goal position
		}, ConstrainedSpring)
	end

	function ConstrainedSpring:Step(dt)
		local freq = self.freq*2*pi -- Convert from Hz to rad/s
		if SpringRemoved then freq *= 1000000 end
		local x = self.x
		local v = self.v
		local minValue = self.minValue
		local maxValue = self.maxValue
		local goal = self.goal

		-- Solve the spring ODE for position and velocity after time t, assuming critical damping:
		--   2*f*x'[t] + x''[t] = f^2*(g - x[t])
		-- Knowns are x[0] and x'[0].
		-- Solve for x[t] and x'[t].

		local offset = goal - x
		local step = freq*dt
		local decay = exp(-step)

		local x1 = goal + (v*dt - offset*(step + 1))*decay
		local v1 = ((offset*freq - v)*step + v)*decay

		-- Constrain
		if x1 < minValue then
			x1 = minValue
			v1 = 0
		elseif x1 > maxValue then
			x1 = maxValue
			v1 = 0
		end

		self.x = x1
		self.v = v1

		return x1
	end
end

local zoomSpring = ConstrainedSpring.new(ZOOM_STIFFNESS, ZOOM_DEFAULT, MIN_FOCUS_DIST, cameraMaxZoomDistance)

local function stepTargetZoom(z, dz, zoomMin, zoomMax)
	z = clamp(z + dz*(1 + z*ZOOM_ACCELERATION), zoomMin, zoomMax)
	if z < DIST_OPAQUE then
		z = dz <= 0 and zoomMin or DIST_OPAQUE
	end
	return z
end

local zoomDelta = 0

local Zoom = {} do
	function Zoom.Update(renderDt, focus, extrapolation)
		local poppedZoom = math.huge

		if zoomSpring.goal > DIST_OPAQUE then
			-- Make a pessimistic estimate of zoom distance for this step without accounting for poppercam
			local maxPossibleZoom = max(
				zoomSpring.x,
				stepTargetZoom(zoomSpring.goal, zoomDelta, cameraMinZoomDistance, cameraMaxZoomDistance)
			)

			-- Run the Popper algorithm on the feasible zoom range, [MIN_FOCUS_DIST, maxPossibleZoom]
			poppedZoom = Popper(
				focus*CFrame.new(0, 0, MIN_FOCUS_DIST),
				maxPossibleZoom - MIN_FOCUS_DIST,
				extrapolation
			) + MIN_FOCUS_DIST
		end

		zoomSpring.minValue = MIN_FOCUS_DIST
		zoomSpring.maxValue = min(cameraMaxZoomDistance, poppedZoom)

		return zoomSpring:Step(renderDt)
	end

	function Zoom.SetZoomParameters(targetZoom, newZoomDelta)
		zoomSpring.goal = targetZoom
		zoomDelta = newZoomDelta
	end
end

return Zoom

--------------------------------------------------------------------------------
-- Popper.lua
-- Prevents your camera from clipping through walls.
--------------------------------------------------------------------------------

local Players = game:GetService('Players')

local FFlagUserPoppercamLooseOpacityThreshold do
	local success, enabled = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserPoppercamLooseOpacityThreshold")
	end)
	FFlagUserPoppercamLooseOpacityThreshold = success and enabled
end

local camera = game.Workspace.CurrentCamera

local min = math.min
local tan = math.tan
local rad = math.rad
local inf = math.huge
local ray = Ray.new

local function getTotalTransparency(part)
	return 1 - (1 - part.Transparency)*(1 - part.LocalTransparencyModifier)
end

local function eraseFromEnd(t, toSize)
	for i = #t, toSize + 1, -1 do
		t[i] = nil
	end
end

local nearPlaneZ, projX, projY do
	local function updateProjection()
		local fov = rad(camera.FieldOfView)
		local view = camera.ViewportSize
		local ar = view.X/view.Y

		projY = 2*tan(fov/2)
		projX = ar*projY
	end

	camera:GetPropertyChangedSignal('FieldOfView'):Connect(updateProjection)
	camera:GetPropertyChangedSignal('ViewportSize'):Connect(updateProjection)

	updateProjection()

	nearPlaneZ = camera.NearPlaneZ
	camera:GetPropertyChangedSignal('NearPlaneZ'):Connect(function()
		nearPlaneZ = camera.NearPlaneZ
	end)
end

local blacklist = {} do
	local charMap = {}

	local function refreshIgnoreList()
		local n = 1
		blacklist = {}
		for _, character in pairs(charMap) do
			blacklist[n] = character
			n = n + 1
		end
	end

	local function playerAdded(player)
		local function characterAdded(character)
			charMap[player] = character
			refreshIgnoreList()
		end
		local function characterRemoving()
			charMap[player] = nil
			refreshIgnoreList()
		end

		player.CharacterAdded:Connect(characterAdded)
		player.CharacterRemoving:Connect(characterRemoving)
		if player.Character then
			characterAdded(player.Character)
		end
	end

	local function playerRemoving(player)
		charMap[player] = nil
		refreshIgnoreList()
	end

	Players.PlayerAdded:Connect(playerAdded)
	Players.PlayerRemoving:Connect(playerRemoving)

	for _, player in ipairs(Players:GetPlayers()) do
		playerAdded(player)
	end
	refreshIgnoreList()
end

--------------------------------------------------------------------------------------------
-- Popper uses the level geometry find an upper bound on subject-to-camera distance.
--
-- Hard limits are applied immediately and unconditionally. They're generally caused
-- when level geometry intersects with the near plane (with exceptions, see below).
--
-- Soft limits are only applied under certain conditions.
-- They're caused when level geometry occludes the subject without actually intersecting
-- with the near plane at the target distance.
--
-- Soft limits can be promoted to hard limits and hard limits can be demoted to soft limits.
-- We usually don't want the latter to happen.
--
-- A soft limit will be promoted to a hard limit if an obstruction
-- lies between the current and target camera positions.
--------------------------------------------------------------------------------------------

local subjectRoot
local subjectPart

camera:GetPropertyChangedSignal('CameraSubject'):Connect(function()
	local subject = camera.CameraSubject
	if subject:IsA('Humanoid') then
		subjectPart = subject.RootPart
	elseif subject:IsA('BasePart') then
		subjectPart = subject
	else
		subjectPart = nil
	end
end)

local function canOcclude(part)
	-- Occluders must be:
	-- 1. Opaque
	-- 2. Interactable
	-- 3. Not in the same assembly as the subject

	if FFlagUserPoppercamLooseOpacityThreshold then
		return
			getTotalTransparency(part) < 0.25 and
			part.CanCollide and
			subjectRoot ~= (part:GetRootPart() or part) and
			not part:IsA('TrussPart')
	else
		return
			part.Transparency < 0.95 and
			part.CanCollide and
			subjectRoot ~= (part:GetRootPart() or part)
	end
end

-- Offsets for the volume visibility test
local SCAN_SAMPLE_OFFSETS = {
	Vector2.new( 0.4, 0.0),
	Vector2.new(-0.4, 0.0),
	Vector2.new( 0.0,-0.4),
	Vector2.new( 0.0, 0.4),
	Vector2.new( 0.0, 0.2),
}

--------------------------------------------------------------------------------
-- Piercing raycasts

local function getCollisionPoint(origin, dir)
	local originalSize = #blacklist
	repeat
		local hitPart, hitPoint = workspace:FindPartOnRayWithIgnoreList(
			ray(origin, dir), blacklist, false, true
		)

		if hitPart then
			if hitPart.CanCollide then
				eraseFromEnd(blacklist, originalSize)
				return hitPoint, true
			end
			blacklist[#blacklist + 1] = hitPart
		end
	until not hitPart

	eraseFromEnd(blacklist, originalSize)
	return origin + dir, false
end

--------------------------------------------------------------------------------

local function queryPoint(origin, unitDir, dist, lastPos)
	debug.profilebegin('queryPoint')

	local originalSize = #blacklist

	dist = dist + nearPlaneZ
	local target = origin + unitDir*dist

	local softLimit = inf
	local hardLimit = inf
	local movingOrigin = origin

	repeat
		local entryPart, entryPos = workspace:FindPartOnRayWithIgnoreList(ray(movingOrigin, target - movingOrigin), blacklist, false, true)

		if entryPart then
			if canOcclude(entryPart) then
				local wl = {entryPart}
				local exitPart = workspace:FindPartOnRayWithWhitelist(ray(target, entryPos - target), wl, true)

				local lim = (entryPos - origin).Magnitude

				if exitPart then
					local promote = false
					if lastPos then
						promote =
							workspace:FindPartOnRayWithWhitelist(ray(lastPos, target - lastPos), wl, true) or
							workspace:FindPartOnRayWithWhitelist(ray(target, lastPos - target), wl, true)
					end

					if promote then
						-- Ostensibly a soft limit, but the camera has passed through it in the last frame, so promote to a hard limit.
						hardLimit = lim
					elseif dist < softLimit then
						-- Trivial soft limit
						softLimit = lim
					end
				else
					-- Trivial hard limit
					hardLimit = lim
				end
			end

			blacklist[#blacklist + 1] = entryPart
			movingOrigin = entryPos - unitDir*1e-3
		end
	until hardLimit < inf or not entryPart

	eraseFromEnd(blacklist, originalSize)

	debug.profileend()
	return softLimit - nearPlaneZ, hardLimit - nearPlaneZ
end

local function queryViewport(focus, dist)
	debug.profilebegin('queryViewport')

	local fP =  focus.p
	local fX =  focus.rightVector
	local fY =  focus.upVector
	local fZ = -focus.lookVector

	local viewport = camera.ViewportSize

	local hardBoxLimit = inf
	local softBoxLimit = inf

	-- Center the viewport on the PoI, sweep points on the edge towards the target, and take the minimum limits
	for viewX = 0, 1 do
		local worldX = fX*((viewX - 0.5)*projX)

		for viewY = 0, 1 do
			local worldY = fY*((viewY - 0.5)*projY)

			local origin = fP + nearPlaneZ*(worldX + worldY)
			local lastPos = camera:ViewportPointToRay(
				viewport.x*viewX,
				viewport.y*viewY
			).Origin

			local softPointLimit, hardPointLimit = queryPoint(origin, fZ, dist, lastPos)

			if hardPointLimit < hardBoxLimit then
				hardBoxLimit = hardPointLimit
			end
			if softPointLimit < softBoxLimit then
				softBoxLimit = softPointLimit
			end
		end
	end
	debug.profileend()

	return softBoxLimit, hardBoxLimit
end

local function testPromotion(focus, dist, focusExtrapolation)
	debug.profilebegin('testPromotion')

	local fP = focus.p
	local fX = focus.rightVector
	local fY = focus.upVector
	local fZ = -focus.lookVector

	do
		-- Dead reckoning the camera rotation and focus
		debug.profilebegin('extrapolate')

		local SAMPLE_DT = 0.0625
		local SAMPLE_MAX_T = 1.25

		local maxDist = (getCollisionPoint(fP, focusExtrapolation.posVelocity*SAMPLE_MAX_T) - fP).Magnitude
		-- Metric that decides how many samples to take
		local combinedSpeed = focusExtrapolation.posVelocity.magnitude

		for dt = 0, min(SAMPLE_MAX_T, focusExtrapolation.rotVelocity.magnitude + maxDist/combinedSpeed), SAMPLE_DT do
			local cfDt = focusExtrapolation.extrapolate(dt) -- Extrapolated CFrame at time dt

			if queryPoint(cfDt.p, -cfDt.lookVector, dist) >= dist then
				return false
			end
		end

		debug.profileend()
	end

	do
		-- Test screen-space offsets from the focus for the presence of soft limits
		debug.profilebegin('testOffsets')

		for _, offset in ipairs(SCAN_SAMPLE_OFFSETS) do
			local scaledOffset = offset
			local pos, isHit = getCollisionPoint(fP, fX*scaledOffset.x + fY*scaledOffset.y)
			if queryPoint(pos, (fP + fZ*dist - pos).Unit, dist) == inf then
				return false
			end
		end

		debug.profileend()
	end

	debug.profileend()
	return true
end

local function Popper(focus, targetDist, focusExtrapolation)
	debug.profilebegin('popper')

	subjectRoot = subjectPart and subjectPart:GetRootPart() or subjectPart

	local dist = targetDist
	local soft, hard = queryViewport(focus, targetDist)
	if hard < dist then
		dist = hard
	end
	if soft < dist and testPromotion(focus, targetDist, focusExtrapolation) then
		dist = soft
	end

	subjectRoot = nil

	debug.profileend()
	return dist
end

return Popper

local controls = {
	{"Spectate","1"},
	{"Create","2"},
	{"Test","3"},
	{"Pause","Left Click"},
	{"Unpause","Left Click"},
	{"Forward","T"},
	{"Back","R"},
	{"Forward 1 Frame","G"},
	{"Back 1 Frame","F"},
	{"Unpause 1 Frame","V"},
	{"Return","E"},
	{"Look Around","L"},
	{"Optimize TAS","Q"},
	{"Delete TAS","Backspace"},
	{"Menu","M"}
}

local settingz = {
	{"Lock Camera (Paused)",1},
	{"Lock Camera (Test)",1},
	{"Show Stats (Spectate)",1},
	{"Show Stats (Create)",1},
	{"Show Stats (Test)",1},
	{"Stats Text Size",11},
	{"Restart When Testing",1}
}

local ds = game:GetService("DataStoreService"):GetDataStore("TASData")

local RS = game.ReplicatedStorage:WaitForChild("TASRS")
local MenuEvents = RS.RemoteEvents.MenuEvents
local Initiator = RS.RemoteEvents.Initiator
local SaveLoad = RS.RemoteFunctions.SaveLoad

local LastSlotID = 0
local PlayerSaves = {}

-- this has nothing to do with tas i just really hate auto jump it can die
game.StarterPlayer.AutoJumpEnabled = false -- :>

game.Players.PlayerAdded:Connect(function(p)
	PlayerSaves[p.UserId] = {}
	local data
	local GotData
	local s,e = pcall(function()
		data = ds:GetAsync(p.UserId.."_PlayerData")
	end)
	if e then
		Initiator:FireClient(p,"PlayerDataLoadFailed")
	else
		GotData = true
	end
	
	local TASfolder = Instance.new("Folder",p)
	TASfolder.Name = "TAS"
	
	local Controls = Instance.new("Folder",TASfolder)
	Controls.Name = "Controls"
	local Settings = Instance.new("Folder",TASfolder)
	Settings.Name = "Settings"
	local Saves = Instance.new("Folder",TASfolder)
	Saves.Name = "Saves"
	
	for i,control in pairs(controls) do
		local V = Instance.new("StringValue",Controls)
		V.Name = control[1]
		if data and data.controls[control[1]] then
			V.Value = data.controls[control[1]]
		else
			V.Value = control[2]
		end
	end
	
	for i,setting in pairs(settingz) do
		local V = Instance.new("IntValue",Settings)
		V.Name = setting[1]
		if data and data.settings[setting[1]] then
			V.Value = data.settings[setting[1]]
		else
			V.Value = setting[2]
		end
	end
	
	if data then
		for i,slot in pairs(data.saves) do
			local V = Instance.new("StringValue",Saves)
			V.Name = slot[1]
			V.Value = slot[2]
		end
		if data.LastSlotID then
			LastSlotID = data.LastSlotID
			local LSID = Instance.new("IntValue",TASfolder)
			LSID.Name = "LastSlotID"
			LSID.Value = data.LastSlotID
		end
	end
	
	if GotData then
		local LoadSuccess = Instance.new("BoolValue",TASfolder)
		LoadSuccess.Name = "LoadSuccess"
	end
	Initiator:FireClient(p,"PlayerDataLoaded")
end)

function save(p)
	PlayerSaves[p.UserId] = nil
	if p.TAS:FindFirstChild("SaveRepeatPreventer") then
		repeat wait(.1) until p:FindFirstChild("SavedTAS")
	elseif p.TAS:FindFirstChild("LoadSuccess") then
		local SaveRepeatPreventer = Instance.new("BoolValue",p.TAS)
		SaveRepeatPreventer.Name = "SaveRepeatPreventer"
		
		local data = {}
		data.LastSlotID = LastSlotID
		data.controls = {}
		data.settings = {}
		data.saves = {}
		for i,v in pairs(p.TAS.Controls:GetChildren()) do
			data.controls[v.Name] = v.Value
		end
		for i,v in pairs(p.TAS.Settings:GetChildren()) do
			data.settings[v.Name] = v.Value
		end
		for i,v in pairs(p.TAS.Saves:GetChildren()) do
			table.insert(data.saves,{v.Name,v.Value})
		end
		
		ds:SetAsync(p.UserId.."_PlayerData",data)
		local saved = Instance.new("BoolValue",p)
		saved.Name = "SavedTAS"
	end
end

game.Players.PlayerRemoving:Connect(save)
game:BindToClose(function()
	for i,p in pairs(game.Players:GetChildren()) do
		save(p)
	end
end)

MenuEvents.OnServerEvent:Connect(function(p,action,v1,v2)
	if action == "SetControl" then
		p.TAS.Controls[v1].Value = v2
	elseif action == "SetSetting" then
		p.TAS.Settings[v1].Value = v2
	elseif action == "AddSlot" then
		local Slot = Instance.new("StringValue",p.TAS.Saves)
		Slot.Name = v1
		LastSlotID = v1
	elseif action == "RenameSlot" then
		p.TAS.Saves[v1].Value = v2
	elseif action == "DeleteSlot" then
		p.TAS.Saves[v1]:Destroy()
	elseif action == "PromptModelPurchase" then
		game.MarketplaceService:PromptPurchase(p,10211275704)
	end
end)

SaveLoad.OnServerInvoke = function(p,action,id,TAS)
	if action == "AddToSave" then
		if #PlayerSaves[p.UserId] > 0 then
			table.move(TAS,1,#TAS,#PlayerSaves[p.UserId]+1,PlayerSaves[p.UserId])
		else
			PlayerSaves[p.UserId] = TAS
		end
		return true
	end
	if action == "Save" then
		local s,e = pcall(function()
			ds:SetAsync(p.UserId.."-"..id,PlayerSaves[p.UserId])
		end)
		PlayerSaves[p.UserId] = {}
		return s
	elseif action == "Load" then
		local loaded
		local s,e = pcall(function()
			loaded = ds:GetAsync(p.UserId.."-"..id)
		end)
		if e or loaded == nil then
			return {}
		end
		return s,loaded
	end
end

local uis = game:GetService("UserInputService")
if uis.KeyboardEnabled == false then
	game:GetService("RunService").RenderStepped:Wait()
	script.Parent:Destroy()
	wait(100000000000000000) -- L mobile players
end

local TASinitiator = game.ReplicatedFirst.TASInitiator
local LoadSuccess = false
while TASinitiator.Ready.Value == false do
	wait(.1)
end
if TASinitiator.Failed.Value == false then
	LoadSuccess = true
end

local p = game.Players.LocalPlayer
local MenuEvents = game.ReplicatedStorage.TASRS.RemoteEvents.MenuEvents
local SaveLoad = game.ReplicatedStorage.TASRS.RemoteFunctions.SaveLoad
local GetTAS = game.ReplicatedStorage.TASRS.BindableFunctions.GetTAS
local SetTAS = game.ReplicatedStorage.TASRS.BindableEvents.SetTAS
local Inputs = require(script.Parent.Inputs)
local ToKey = Inputs.ToKey
local FromKey = Inputs.FromKey
local WaitInputConnection = nil
local ChangingInput = nil

local MainUI = script.Parent
local JoinMessage = MainUI.JoinMessage
local menu = MainUI.MainMenu
local ControlsFrame = menu.ControlsFrame
local SettingsFrame = menu.SettingsFrame
local SavesFrame = menu.SavesFrame

local ts = game.TweenService
local JoinTween = ts:Create(JoinMessage,TweenInfo.new(1,Enum.EasingStyle.Quad),{Position = UDim2.new(0,10,1,-10)})
local ReverseJoinTween = ts:Create(JoinMessage,TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position = UDim2.new(0,10,1,150)})
	
local Controls = p.TAS.Controls
local Settings = p.TAS.Settings
local Saves = p.TAS.Saves

for _,v in pairs(Controls:GetChildren()) do
	local ControlBlock = script.ControlTemp:Clone()
	ControlBlock.Name = v.Name
	ControlBlock.N.Text = v.Name
	ControlBlock.Key.Text = v.Value
	ControlBlock.Parent = ControlsFrame.List
	ControlBlock.Key.MouseButton1Down:Connect(function()
		if ChangingInput then
			WaitInputConnection:Disconnect()
			ControlsFrame.List[ChangingInput].Key.Text = p.TAS.Controls[ChangingInput].Value
		end
		ControlBlock.Key.Text = "Press Any Key"
		ChangingInput = ControlBlock.Name
		game:GetService("RunService").RenderStepped:Wait()
		WaitInputConnection = uis.InputBegan:Connect(function(inp,proc)
			if proc and inp.UserInputType == Enum.UserInputType.Keyboard then return end
			local input
			if inp.UserInputType == Enum.UserInputType.Keyboard then
				input = inp.KeyCode
			elseif inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.MouseButton2 or inp.UserInputType == Enum.UserInputType.MouseButton3 then
				input = inp.UserInputType
			end
			
			if FromKey[input] then
				ControlBlock.Key.Text = FromKey[input]
				MenuEvents:FireServer("SetControl",ChangingInput,FromKey[input])
				WaitInputConnection:Disconnect()
				ChangingInput = nil
			end
		end)
	end)
end

for _,v in pairs(Settings:GetChildren()) do
	local setting = SettingsFrame.List[v.Name]
	if setting:FindFirstChild("Switch") then
		local tween1 = ts:Create(setting.Switch.Switcher,TweenInfo.new(.4),{Position = UDim2.new(.5,0,0,0),BackgroundColor3 = Color3.fromRGB(75,75,75)})
		local tween2 = ts:Create(setting.Switch.Switcher,TweenInfo.new(.4),{Position = UDim2.new(0,0,0,0),BackgroundColor3 = Color3.fromRGB(255,255,255)})
		if v.Value == 1 then
			tween1:Play()
		end
		local on = v.Value
		setting.Switch.MouseButton1Click:Connect(function()
			if on == 0 then on = 1 else on = 0 end
			if on == 1 then
				tween1:Play()
				MenuEvents:FireServer("SetSetting",v.Name,on)
			else
				tween2:Play()
				MenuEvents:FireServer("SetSetting",v.Name,on)
			end
		end)
	elseif setting:FindFirstChild("Input") then
		local inp = setting.Input
		inp.Text = v.Value
		inp.FocusLost:Connect(function()
			if tonumber(inp.Text) then
				MenuEvents:FireServer("SetSetting",v.Name,tonumber(inp.Text))
			else
				inp.Text = v.Value
			end
		end)
	end
end

function SetStatsSize(TextSize)
	for _,v in pairs({script.Parent.SpectateStats,script.Parent.CreateStats,script.Parent.TestStats}) do
		v.Size = UDim2.new(0,240*TextSize/11,0,(#v:GetChildren()-2)*18*TextSize/11)
		for _,x in pairs(v:GetChildren()) do
			if x:IsA("TextLabel") then
				x.Size = UDim2.new(1,0,0,18*TextSize/11)
				x.TextSize = TextSize
			end
		end
	end
end

SetStatsSize(Settings['Stats Text Size'].Value)
Settings['Stats Text Size'].Changed:Connect(function(v)
	SetStatsSize(v)
end)

local LastSlotID = 0
local slots = 0
local cooldown = 0
local TAS,DataUsage

function SetStatus(text,fade)
	local status = script.Parent.SaveLoadStatus:Clone()
	script.Parent.SaveLoadStatus:Destroy()
	status.TextTransparency = 0
	status.Text = text
	status.Parent = script.Parent
	if fade then
		wait(2)
		for i = 0,1.05,.05 do
			wait(.05)
			status.TextTransparency = i
		end
	end
end

function SetCooldown()
	spawn(function()
		cooldown = 10
		for i = 9,0,-1 do
			wait(1)
			cooldown = i
		end
	end)
end

function SplitTable(t)
	local result = {}
	for i = 1,#t,5000 do
		local section = {}
		table.move(t,i,i+4999,1,section)
		table.insert(result,section)
	end
	return result
end

function SetupSlot(Slot)
	Slot.Name = LastSlotID
	while string.len(Slot.Name) < 6 do
		Slot.Name = "0"..Slot.Name
	end
	Slot.ID.Value = LastSlotID
	Slot.Parent = SavesFrame.List
	slots += 1
	SavesFrame.Slots.Text = "Slots: "..slots.."/30"
	if slots >= 30 then 
		SavesFrame.List.AddSlot.Visible = false
	end
	Slot.N.FocusLost:Connect(function()
		MenuEvents:FireServer("RenameSlot",Slot.ID.Value,Slot.N.Text)
	end)
	Slot.Buttons.Delete.MouseButton1Click:Connect(function()
		MenuEvents:FireServer("DeleteSlot",Slot.ID.Value)
		Slot:Destroy()
		slots -= 1
		SavesFrame.Slots.Text = "Slots: "..slots.."/30"
		SavesFrame.List.AddSlot.Visible = true
	end)
	Slot.Buttons.Save.MouseButton1Click:Connect(function()
		if DataUsage <= 4000000 then
			if cooldown == 0 then
				SetStatus("Saving...",false)
				SetCooldown()
				local splits = SplitTable(TAS)
				for i,v in pairs(splits) do
					print('sending')
					SaveLoad:InvokeServer("AddToSave",nil,v)
				end
				if SaveLoad:InvokeServer("Save",Slot.ID.Value) then
					SetStatus("Save Success!",true)
				else
					SetStatus("Save Failed.",true)
				end
			else
				SetStatus("Please wait "..cooldown.." seconds before saving/loading.",true)
			end
		else
			SetStatus("TAS size too large to save.",true)
		end
	end)
	Slot.Buttons.Load.MouseButton1Click:Connect(function()
		if cooldown == 0 then
			SetStatus("Loading...",false)
			SetCooldown()
			local Success,LoadedTAS = SaveLoad:InvokeServer("Load",Slot.ID.Value)
			if Success then
				SetTAS:Fire(LoadedTAS)
				TAS = LoadedTAS
				DataUsage = #game.HttpService:JSONEncode(TAS)
				SavesFrame.Data.Text = "Data Usage: "..math.round(DataUsage/10000)/100 .."/4MB"
				SetStatus("Load Success!",true)
			else
				SetStatus("Load Failed.",true)
			end
		else
			SetStatus("Please wait "..cooldown.." seconds before saving/loading.",true)
		end
	end)
end

for _,v in pairs(Saves:GetChildren()) do
	LastSlotID = tonumber(v.Name)
	local Slot = script.SlotTemp:Clone()
	Slot.N.Text = v.Value
	SetupSlot(Slot)
end

if p.TAS:FindFirstChild("LastSlotID") then
	LastSlotID = p.TAS.LastSlotID.Value 
end

SavesFrame.List.AddSlot.MouseButton1Click:Connect(function()
	if slots < 30 then
		LastSlotID += 1
		MenuEvents:FireServer("AddSlot",LastSlotID)
		local Slot = script.SlotTemp:Clone()
		SetupSlot(Slot)
	end
end)

menu.Title.Text = "HappaTAS "..game.ReplicatedStorage.TASRS.Version.Value
JoinMessage.Title.Text = "HappaTAS "..game.ReplicatedStorage.TASRS.Version.Value.." Loaded"
JoinMessage.M.Text = Controls["Menu"].Value.." - Main Menu"
if LoadSuccess == false then
	JoinMessage.Size = UDim2.new(0,280,0,110)
	JoinMessage.FailureMessage.Visible = true
end
JoinTween:Play()
JoinMessage.Close.MouseButton1Down:Connect(function()
	ReverseJoinTween:Play()
end)

game:GetService("UserInputService").InputBegan:Connect(function(inp,proc)
	if proc then return end
	if inp.KeyCode == ToKey[Controls["Menu"].Value] or inp.UserInputType == ToKey[Controls["Menu"].Value] then
		menu.Visible = not menu.Visible
		if menu.Visible and menu.SavesFrame.Visible then
			TAS = GetTAS:Invoke()
			DataUsage = #game.HttpService:JSONEncode(TAS)
			SavesFrame.Data.Text = "Data Usage: "..math.round(DataUsage/10000)/100 .."/4MB"
		end
	end
end)

local function tab(TabName)
	menu.ControlsToggle.BackgroundTransparency = .75
	menu.SettingsToggle.BackgroundTransparency = .75
	menu.SavesToggle.BackgroundTransparency = .75
	menu.HelpToggle.BackgroundTransparency = .75
	menu.MoreToggle.BackgroundTransparency = .75
	menu.ControlsFrame.Visible = false
	menu.SettingsFrame.Visible = false
	menu.SavesFrame.Visible = false
	menu.HelpFrame.Visible = false
	menu.MoreFrame.Visible = false
	menu[TabName.."Toggle"].BackgroundTransparency = .5
	menu[TabName.."Frame"].Visible = true
end

menu.ControlsToggle.MouseButton1Click:Connect(function() 
	tab("Controls")
end)
menu.SettingsToggle.MouseButton1Click:Connect(function() 
	tab("Settings")
end)
menu.SavesToggle.MouseButton1Click:Connect(function() 
	tab("Saves")
	TAS = GetTAS:Invoke()
	DataUsage = #game.HttpService:JSONEncode(TAS)
	SavesFrame.Data.Text = "Data Usage: "..math.round(DataUsage/10000)/100 .."/4MB"
end)
menu.HelpToggle.MouseButton1Click:Connect(function() 
	tab("Help")
end)
menu.MoreToggle.MouseButton1Click:Connect(function()
	tab("More")
end)

menu.MoreFrame.List['1Model'].MouseButton1Click:Connect(function()
	MenuEvents:FireServer("PromptModelPurchase")
end)

local hf = menu.HelpFrame.List
local SelectedHelp = "00"
for i,v in pairs(hf:GetChildren()) do
	if v:IsA("TextButton") then
		v.MouseButton1Click:Connect(function()
			if SelectedHelp ~= v.Name then
				if SelectedHelp ~= "00" then
					hf[SelectedHelp].Expansion.Visible = false
					hf[SelectedHelp].Expand.Text = "+"
					hf[SelectedHelp.."Spacer"]:Destroy()
				end
				SelectedHelp = v.Name
				hf[SelectedHelp].Expansion.Visible = true
				hf[SelectedHelp].Expand.Text = "-"
				local spacer = hf.Spacer:Clone()
				spacer.Parent = hf
				spacer.Name = SelectedHelp.."Spacer"
				spacer.Size = UDim2.new(0,0,0,hf[SelectedHelp].Expansion.Size.Y.Offset-8)
			else
				hf[SelectedHelp].Expansion.Visible = false
				hf[SelectedHelp].Expand.Text = "+"
				hf[SelectedHelp.."Spacer"]:Destroy()
				SelectedHelp = "00"
			end
		end)
	end
end

local uis = game:GetService("UserInputService")
if uis.KeyboardEnabled == false then
	wait(100000000000000000) -- L mobile players
end

local TASinitiator = game.ReplicatedFirst.TASInitiator
while TASinitiator.Ready.Value == false do
	wait(.1)
end

local p = game.Players.LocalPlayer
local cam = workspace.CurrentCamera
local rs = game:GetService("RunService")
local mouse = game.Players.LocalPlayer:GetMouse()
local ToKey = require(script.Parent.Inputs).ToKey
local Controls = p.TAS.Controls
local Settings = p.TAS.Settings
local SetStats = require(script.SetStats)

local ReplicatedStorage = game.ReplicatedStorage:WaitForChild("TASRS")

local BindableEvents = ReplicatedStorage.BindableEvents
local ShiftlockSwitch = BindableEvents.ShiftlockSwitch -- MouseLockController line 191
local LockShiftlock = BindableEvents.LockShiftlock -- MouseLockController line 198
local SetTAS = BindableEvents.SetTAS -- fires from MenuManager
local SetZoom = BindableEvents.SetZoom -- BaseCamera line 121
local RemoveZoomSpring = BindableEvents.RemoveZoomSpring -- ZoomController line 6
local SetAnimation = BindableEvents.SetAnimation -- Animate line 585
local LockAnimations = BindableEvents.LockAnimations -- Animate line 600

local BindableFunctions = ReplicatedStorage.BindableFunctions
local GetTAS = BindableFunctions.GetTAS -- fires from MenuManager
local GetAnim = BindableFunctions.GetAnimation -- Animate line 573
local GetZoom = BindableFunctions.GetZoom -- BaseCamera line 117

local data = {}
local mode = 1
p:SetAttribute("Mode",1)
local frame = 1
local paused = true
local back = false
local forw = false
local LastPause = 1
local FirstFrameRecord = false

--Character physics standardizing sync.
for index, obj in pairs(p.Character:GetChildren()) do
	if obj:IsA("Accessory") then
		for i, o in pairs(obj:GetDescendants()) do
			if o:IsA("BasePart") then
				o.Massless = true
			end
		end
	end
end

function r(n,decimal)
	return math.round(n*decimal)/decimal
end

function SetCam() -- retuns wether the camera cframe should change or not. This also affects player transparency and zoom. See loadpos function
	return (mode == 3 and Settings["Lock Camera (Test)"].Value == 1) or (mode == 2 and Settings["Lock Camera (Paused)"].Value == 1)
end

function SetTransparency(transparency)
	p.Character.Head.face.LocalTransparencyModifier = transparency
	for i,v in pairs(p.Character:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.LocalTransparencyModifier = transparency
		end
		if v:IsA("Accessory") then
			v.Handle.LocalTransparencyModifier = transparency
		end
	end
end

local SS = require(script.SetStats)
function SetStats(m,FrameData,FrameTime,frame)
	if Settings["Show Stats ("..m..")"].Value == 1 then
		if m == "Spectate" then
			SS.Spectate(FrameTime,GetCameraZoom())
		elseif m == "Create" then
			SS.Create(paused,frame,FrameData)
		elseif m == "Test" then
			SS.Test(frame,FrameData,FrameTime)
		end
	else
		SS.Hide()
	end
end

-- event and functions recieve between lines 110 and 120 in BaseCamera

function GetCameraZoom()
	return GetZoom:Invoke()
end

function SetCameraZoom(zoom,static)
	if static then RemoveZoomSpring:Fire() end
	SetZoom:Fire(zoom)
end

function Vector3ToTable(V)
	return {r(V.X,1000),r(V.Y,1000),r(V.Z,1000)}
end
function TableToVector3(t)
	return Vector3.new(unpack(t))
end

function CFrameToTable(C)
	local components = {C:GetComponents()}
	for i,v in pairs(components) do
		components[i] = r(v,1000)
	end
	return components
end
function TableToCFrame(t)
	return CFrame.new(unpack(t))
end

function ReCam(FrameData)
	if mode == 2 and paused then 
		cam.CameraType = Enum.CameraType.Scriptable
	end
	cam.CFrame = TableToCFrame(FrameData[4])

	local IsShiftLock
	if mouse.Icon == 'rbxasset://textures/MouseLockedCursor.png' then
		IsShiftLock = 1
	else
		IsShiftLock = 0
	end
	if IsShiftLock ~= data[frame][5] then
		ShiftlockSwitch:Fire(mode ~= 3)
	end
	
	SetCameraZoom(FrameData[8],mode == 2)
end

--[[
	loadpos
	called when moving forward/back
	when in test
	when you switch to create
	when you unpause (removes the character anchor, and set camera cframe. sets the camera zoom)
	when you pause
	when you unpause 1 frame (+features)
	after the unpause 1 frame
	when returning
]]

function loadpos(FrameData,unpausing,backtrack)
	if FrameData == nil then return end
	local c = p.Character
	
	if not unpausing then
		anchor(mode ~= 3)
		c.HumanoidRootPart.CFrame = TableToCFrame(FrameData[1])
		if SetCam() then
			ReCam(FrameData)
		end
	else -- when unpausing
		if SetCam() then
			SetCameraZoom(FrameData[8],true)
		end
		LastPause = frame
	end
	
	if SetCam() then
		SetTransparency(FrameData[6])
	else
		cam.CameraType = "Custom"
	end
	
	c.HumanoidRootPart.AssemblyLinearVelocity = TableToVector3(FrameData[2][1])
	c.HumanoidRootPart.AssemblyAngularVelocity = TableToVector3(FrameData[2][2])
	
	p.Character.Humanoid:ChangeState(FrameData[3])
	
	local BacktrackAnim = nil
	if backtrack and frame > 1 then
		for i = frame,1,-1 do
			if #data[i][7][4] > 0 then
				BacktrackAnim = data[i][7][4]
				break
			end
		end
	end
	
	SetAnimation:Fire(FrameData[7],mode == 3,BacktrackAnim)
end

function anchor(value)
	p.Character.HumanoidRootPart.Anchored = value
end

function unpause(e) -- job: remove all previous frames
	if paused or e then
		for i = frame+1,#data do
			table.remove(data,#data)
		end
	end
end

function charload(char)
	local h = char:WaitForChild("Humanoid")
	h.Died:Connect(function()
		--unpause()
		mode = 1
		table.remove(data,#data)
		--rs.Heartbeat:Wait()
		--rs.RenderStepped:Wait()
		p:SetAttribute("Mode",1)
	end)
end

function CheckInput(inp,control)
	return inp.KeyCode == ToKey[Controls[control].Value] or inp.UserInputType == ToKey[Controls[control].Value]
end

-- this script isnt supposed to have gui but whatever
local ConfirmDelete,ConfirmOptimize = false,false
function SetStatus(text)
	local status = script.Parent.SaveLoadStatus:Clone()
	script.Parent.SaveLoadStatus:Destroy()
	status.TextTransparency = 0
	status.Text = text
	status.Parent = script.Parent
	for i = 0,1.05,.05 do
		wait(.05)
		status.TextTransparency = i
	end
end

function ToTime(t)
	local secs = t-(t-t%60)
	local mins = (t-t%60)/60
	
	if string.len(string.split(secs,'.')[1]) < 2 then secs = "0"..secs end
	
	return mins..":"..secs
end

if p.Character then charload(p.Character) end
p.CharacterAdded:Connect(charload)

rs.RenderStepped:Connect(function()
	if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and mode == 2 then
		local c = p.Character
		local IsShiftLock
		if mouse.Icon == 'rbxasset://textures/MouseLockedCursor.png' then
			IsShiftLock = 1
		else
			IsShiftLock = 0
		end
		local tab =
			{
				nil, -- cframe of root [stepped]
				{Vector3ToTable(c.HumanoidRootPart.AssemblyLinearVelocity),Vector3ToTable(c.HumanoidRootPart.AssemblyAngularVelocity)},
				nil, -- humanoidstatetype [stepped]
				CFrameToTable(cam.CFrame),
				IsShiftLock,
				r(c.Head.LocalTransparencyModifier,1000),
				nil, -- animation info {pose, jumpanimtime, currentanimspeed, frameanims}
				r(GetCameraZoom(),1000),
				nil, -- frame time [heartbeat]
				nil -- total time [heartbeat]
			}
		if FirstFrameRecord and c.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
			data[#data] = tab
		elseif not paused and c.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
			table.insert(data,tab)
		end
	end
	SetTransparency(p.Character.Head.LocalTransparencyModifier)
end)

rs.Stepped:Connect(function()
	if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and mode == 2 and ((not paused) or FirstFrameRecord) and p.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
		local c = p.Character
		data[#data][1] = CFrameToTable(c.HumanoidRootPart.CFrame)
		data[#data][3] = c.Humanoid:GetState().Value
		data[#data][7] = GetAnim:Invoke()
	end
end)

rs.Heartbeat:Connect(function(t)
	if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
		if mode == 1 then
			SetStats("Spectate",nil,t)
		end
		if mode == 2 then
			if paused and not FirstFrameRecord then
				if #data > 1 and back and frame > 1 then 
					frame -= 1 
					loadpos(data[frame],false,true)
				end
				if frame < #data and forw then 
					frame += 1 
					loadpos(data[frame],false,true)
				end
			else
				data[#data][9] = r(t,1000000)
				if #data > 1 then
					data[#data][10] = r(data[#data-1][10] + t,1000000)
				else
					data[#data][10] = r(t,1000000)
				end
				frame = #data
			end
			SetStats("Create",data[frame],paused,frame)
		elseif mode == 3 and data[frame] then
			loadpos(data[frame])
			SetStats("Test",data[frame],t,frame)
			frame += 1
		elseif mode == 3 and #data > 1 then
			mode,frame = 1,1
			cam.CameraType = "Custom"
			LockShiftlock:Fire(false)
			LockAnimations:Fire(false)
			SetStatus("TAS Completed [Time: "..ToTime(data[#data][10]).."]")
			if (mouse.Icon == 'rbxasset://textures/MouseLockedCursor.png') ~= (uis.MouseBehavior == Enum.MouseBehavior.LockCenter) then
				ShiftlockSwitch:Fire()
			end
			--rs.Heartbeat:Wait()
			--rs.RenderStepped:Wait()
			p:SetAttribute("Mode",1)
		end
	end
end)

local function enablespectate()
	mode,frame = 1,1
	anchor(false)
	cam.CameraType = "Custom"
	LockShiftlock:Fire(false)
	LockAnimations:Fire(false)
	--rs.Heartbeat:Wait()
	--rs.RenderStepped:Wait()
	p:SetAttribute("Mode",1)
end

p:GetAttributeChangedSignal("On"):Connect(function()
	if p:GetAttribute("On") == true and mode == 2 and frame == 0 then
		enablespectate()
	end
end)

uis.InputBegan:Connect(function(inp,proc)
	if proc then return end
	
	if CheckInput(inp,"Spectate") then
		enablespectate()
	end
	
	if CheckInput(inp,"Create") then
		if p:GetAttribute("On") == false then
			p:SetAttribute("Mode",2)
			frame = #data
			mode = 2 
			paused = true
			loadpos(data[#data])
			anchor(true)
			LockShiftlock:Fire(false)
			LockAnimations:Fire(true)
		else
			game.StarterGui:SetCore("ChatMakeSystemMessage",{
				Text = "[WARNING]: You must be in the start box to start creating a TAS.";
				Color = Color3.fromRGB(255, 0, 0);
				Font = Enum.Font.Gotham;
				FontSize = Enum.FontSize.Size8;
			})
		end
	end
	
	if CheckInput(inp,"Test") then
		LockShiftlock:Fire(true)
		LockAnimations:Fire(true)
		cam.CameraType = "Custom"
		mode = 3
		if Settings['Restart When Testing'].Value == 1 then
			frame = 1
		end
		rs.Heartbeat:Wait()
		rs.RenderStepped:Wait()
		p:SetAttribute("Mode",3)
	end
	
	if CheckInput(inp,"Unpause") and mode == 2 and paused then
		LockAnimations:Fire(false)
		if SetCam() and cam.CameraType == Enum.CameraType.Custom and #data > 0 then
			ReCam(data[#data])
		end
		cam.CameraType = "Custom"
		unpause(true)
		loadpos(data[#data],true)
		anchor(false)
		loadpos(data[#data],true)
		FirstFrameRecord = true
		rs.Heartbeat:Wait()
		rs.RenderStepped:Wait()
		cam.CameraType = "Custom"
		paused = false
		FirstFrameRecord = false
		return
	end
	
	if CheckInput(inp,"Pause") and mode == 2 and not paused then
		LockAnimations:Fire(true)
		paused = true
		loadpos(data[#data])
	end
	
	if CheckInput(inp,"Unpause 1 Frame") and mode == 2 and paused and (not data[#data] or data[#data][3] ~= Enum.HumanoidStateType.Landed.Value) then
		LockAnimations:Fire(false)
		if SetCam() and cam.CameraType == Enum.CameraType.Custom and #data > 0 then
			ReCam(data[#data])
		end
		cam.CameraType = "Custom"
		unpause(true)
		if data[1] then
			loadpos(data[#data],true)
		end
		anchor(false)
		if data[1] then
			loadpos(data[#data],true)
		end
		paused = true
		FirstFrameRecord = true
		rs.Heartbeat:Wait()
		rs.RenderStepped:Wait()
		cam.CameraType = "Custom"
		paused = false
		FirstFrameRecord = false
		rs.RenderStepped:Wait()
		LockAnimations:Fire(true)
		paused = true
		loadpos(data[#data])
	end
	
	if CheckInput(inp,"Return") and mode == 2 and data[2] then
		frame = LastPause
		unpause(true)
		paused = true
		loadpos(data[frame],false,true)
	end
	
	if CheckInput(inp,"Back 1 Frame") and mode == 2 and #data > 1 and frame > 1 then
		frame -= 1
		paused = true
		loadpos(data[frame],false,true)
	end
	
	if CheckInput(inp,"Forward 1 Frame") and mode == 2 and frame < #data then
		frame += 1
		paused = true
		loadpos(data[frame],false,true)
	end
	
	if CheckInput(inp,"Back") and mode == 2 then
		back,paused = true,true
	end
	
	if CheckInput(inp,"Forward") and mode == 2 then 
		forw,paused = true,true
	end
	
	if CheckInput(inp,"Delete TAS") then
		if p:GetAttribute("On") == false then
			if ConfirmDelete then
				data = {}
				LastPause = 1
				frame = 0
				SetStatus("TAS Deleted")
			else
				ConfirmDelete = true
				SetStatus("Delete TAS? ["..Controls["Delete TAS"].Value.."] To Confirm")
				ConfirmDelete = false
			end
		else
			game.StarterGui:SetCore("ChatMakeSystemMessage",{
				Text = "[WARNING]: You must be in the start box to delete a TAS.";
				Color = Color3.fromRGB(255, 0, 0);
				Font = Enum.Font.Gotham;
				FontSize = Enum.FontSize.Size8;
			})
		end
		
	end
	
	if CheckInput(inp,"Optimize TAS") then
		if mode == 1 then
			local NewData = {}
			if ConfirmOptimize then
				local prev
				for x,v in pairs(data) do
					local values = v[4]
					local SameCount = 0
					if prev then
						for y,z in pairs(values) do
							if prev[y] == z then
								SameCount += 1
							end
						end
					end
					prev = values
					if SameCount < 12 or #v[7][4] > 0 then
						table.insert(NewData,v)
						if #NewData > 1 then
							NewData[#NewData][10] = r(NewData[#NewData-1][10] + v[9],1000000)
						else
							NewData[#NewData][10] = r(v[9],1000000)
						end
					end
				end
				data = NewData
				SetStatus("TAS Optimized")
			else
				ConfirmOptimize = true
				SetStatus("Optimize TAS? ["..Controls["Optimize TAS"].Value.."] To Confirm")
				ConfirmOptimize = false
			end
		else
			SetStatus("Switch to spectate to optimize TAS")
		end
	end
	
	if CheckInput(inp,"Look Around") and mode == 2 and paused and Settings["Lock Camera (Paused)"].Value == 1 then
		if cam.CameraType == Enum.CameraType.Custom then
			if #data > 0 then
				ReCam(data[frame])
			end
		else
			cam.CameraType = Enum.CameraType.Custom
		end
	end
end)

uis.InputEnded:Connect(function(inp,proc)
	if proc then return end
	if CheckInput(inp,"Back") then back = false end
	if CheckInput(inp,"Forward") then forw = false end
end)

GetTAS.OnInvoke = function()
	return data
end
SetTAS.Event:Connect(function(LoadedTAS)
	data = LoadedTAS
end)

Settings['Lock Camera (Paused)'].Changed:Connect(function(value)
	if paused then
		loadpos(data[frame])
	end
end)

local SetStats = {}

local SpectateStats = script.Parent.Parent.SpectateStats
local CreateStats = script.Parent.Parent.CreateStats
local TestStats = script.Parent.Parent.TestStats

local LiveTime = 0

function r(n,decimal)
	return math.round(n*decimal)/decimal
end
function TableToCFrame(t)
	if t then
		return CFrame.new(unpack(t))
	else
		return CFrame.new(0,0,0)
	end
end

function ToTime(t)
	local secs = t-(t-t%60)
	local mins = (t-t%60)/60

	if string.len(string.split(secs,'.')[1]) < 2 then secs = "0"..secs end

	return mins..":"..secs
end

local NumberToState = {
	['0'] = "FallingDown",
	['8'] = "Running",
	['10'] = "RunningNoPhysics",
	['12'] = "Climbing",
	['11'] = "StrafingNoPhysics",
	['1'] = "Ragdoll",
	['2'] = "GettingUp",
	['3'] = "Jumping",
	['7'] = "Landed",
	['6'] = "Flying",
	['5'] = "Freefall",
	['13'] = "Seated",
	['14'] = "PlatformStanding",
	['15'] = "Dead",
	['4'] = "Swimming",
	['16'] = "Physics",
	['18'] = "None"
}

SetStats.Hide = function()
	SpectateStats.Visible = false
	CreateStats.Visible = false
	TestStats.Visible = false
end

SetStats.Spectate = function(FrameTime,zoom)
	local root = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
	SpectateStats.Visible = true
	CreateStats.Visible = false
	TestStats.Visible = false
	local CAX,CAY,CAZ = workspace.CurrentCamera.CFrame:ToEulerAnglesYXZ()
	SpectateStats['1'].Text = " Frame Time: "..r(FrameTime,1000000)
	SpectateStats['2'].Text = " Root Position: "..r(root.Position.X,1000)..", "..r(root.Position.Y,1000)..", "..r(root.Position.Z,1000)
	SpectateStats['3'].Text = " Root Rotation: "..r(root.Orientation.X,1000)..", "..r(root.Orientation.Y,1000)..", "..r(root.Orientation.Z,1000)
	SpectateStats['4'].Text = " Root Linear Velocity: "..r(root.AssemblyLinearVelocity.X,1000)..", "..r(root.AssemblyLinearVelocity.Y,1000)..", "..r(root.AssemblyLinearVelocity.Z,1000)
	SpectateStats['5'].Text = " Root Angular Velocity: "..r(root.AssemblyAngularVelocity.X,1000)..", "..r(root.AssemblyAngularVelocity.Y,1000)..", "..r(root.AssemblyAngularVelocity.Z,1000)
	SpectateStats['6'].Text = " Camera Rotation: "..r(math.deg(CAX),1000)..", "..r(math.deg(CAY),1000)..", "..r(math.deg(CAZ),1000)
	SpectateStats['7'].Text = " Humanoid State: "..root.Parent:WaitForChild("Humanoid"):GetState().Name
	SpectateStats['8'].Text = " Zoom: "..r(zoom,1000)
end

SetStats.Create = function(paused,frame,FrameData)
	SpectateStats.Visible = false
	CreateStats.Visible = true
	TestStats.Visible = false
	if paused then
		CreateStats.BackgroundTransparency = 0 
	else 
		CreateStats.BackgroundTransparency = .2 
	end
	CreateStats['1'].Text = " Frame: "..frame
	if FrameData and FrameData[9] and NumberToState[tostring(FrameData[3])] then
		local X,Y,Z = TableToCFrame(FrameData[1]):GetComponents()
		local AX,AY,AZ = TableToCFrame(FrameData[1]):ToEulerAnglesYXZ()
		local CAX,CAY,CAZ = TableToCFrame(FrameData[4]):ToEulerAnglesYXZ()
		CreateStats['2'].Text = " Frame Time: "..FrameData[9]
		CreateStats['3'].Text = " Total Time: "..ToTime(FrameData[10])
		CreateStats['4'].Text = " Root Position: "..r(X,1000)..", "..r(Y,1000)..", "..r(Z,1000)
		CreateStats['5'].Text = " Root Rotation: "..r(math.deg(AX),1000)..", "..r(math.deg(AY),1000)..", "..r(math.deg(AZ),1000)
		CreateStats['6'].Text = " Root Linear Velocity: "..FrameData[2][1][1]..", "..FrameData[2][1][2]..", "..FrameData[2][1][3]
		CreateStats['7'].Text = " Root Angular Velocity: "..FrameData[2][2][1]..", "..FrameData[2][2][2]..", "..FrameData[2][2][3]
		CreateStats['8'].Text = " Camera Rotation: "..r(math.deg(CAX),1000)..", "..r(math.deg(CAY),1000)..", "..r(math.deg(CAZ),1000)
		CreateStats['9'].Text = " Humanoid State: "..NumberToState[tostring(FrameData[3])]
		CreateStats['91'].Text = " Zoom: "..FrameData[8]
	else
		local root = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
		local CAX,CAY,CAZ = workspace.CurrentCamera.CFrame:ToEulerAnglesYXZ()
		CreateStats['2'].Text = " Frame Time: 0"
		CreateStats['3'].Text = " Total Time: 0"
		CreateStats['4'].Text = " Root Position: "..r(root.Position.X,1000)..", "..r(root.Position.Y,1000)..", "..r(root.Position.Z,1000)
		CreateStats['5'].Text = " Root Rotation: "..r(root.Orientation.X,1000)..", "..r(root.Orientation.Y,1000)..", "..r(root.Orientation.Z,1000)
		CreateStats['6'].Text = " Root Linear Velocity: "..r(root.AssemblyLinearVelocity.X,1000)..", "..r(root.AssemblyLinearVelocity.Y,1000)..", "..r(root.AssemblyLinearVelocity.Z,1000)
		CreateStats['7'].Text = " Root Angular Velocity: "..r(root.AssemblyAngularVelocity.X,1000)..", "..r(root.AssemblyAngularVelocity.Y,1000)..", "..r(root.AssemblyAngularVelocity.Z,1000)
		CreateStats['8'].Text = " Camera Rotation: "..r(math.deg(CAX),1000)..", "..r(math.deg(CAY),1000)..", "..r(math.deg(CAZ),1000)
		CreateStats['9'].Text = " Humanoid State: "..root.Parent:WaitForChild("Humanoid"):GetState().Name
		CreateStats['91'].Text = " Zoom: "..r(game.ReplicatedStorage.TASRS.BindableFunctions.GetZoom:Invoke(),1000)
	end
end

SetStats.Test = function(frame,FrameData,FrameTime)
	if frame == 1 then
		LiveTime = 0
	end
	LiveTime += FrameTime
	SpectateStats.Visible = false
	CreateStats.Visible = false
	TestStats.Visible = true
	TestStats['1'].Text = " Frame: "..frame
	TestStats['2'].Text = " Frame Time: "..FrameData[9]
	TestStats['3'].Text = " Live Frame Time: "..r(FrameTime,1000000)
	TestStats['4'].Text = " Total Time: "..ToTime(FrameData[10])
	TestStats['5'].Text = " Live Total Time: "..ToTime(r(LiveTime,1000000))
	TestStats['6'].Text = " Frame Time Difference: "..r(FrameTime-FrameData[9],1000000)
	TestStats['7'].Text = " Total Time Difference: "..r(LiveTime-FrameData[10],1000000)
end

return SetStats

local keys = {}

keys['ToKey'] = {
	["A"] = Enum.KeyCode.A,
	["B"] = Enum.KeyCode.B,
	["C"] = Enum.KeyCode.C,
	["D"] = Enum.KeyCode.D,
	["E"] = Enum.KeyCode.E,
	["F"] = Enum.KeyCode.F,
	["G"] = Enum.KeyCode.G,
	["H"] = Enum.KeyCode.H,
	["I"] = Enum.KeyCode.I,
	["J"] = Enum.KeyCode.J,
	["K"] = Enum.KeyCode.K,
	["L"] = Enum.KeyCode.L,
	["M"] = Enum.KeyCode.M,
	["N"] = Enum.KeyCode.N,
	["O"] = Enum.KeyCode.O,
	["P"] = Enum.KeyCode.P,
	["Q"] = Enum.KeyCode.Q,
	["R"] = Enum.KeyCode.R,
	["S"] = Enum.KeyCode.S,
	["T"] = Enum.KeyCode.T,
	["U"] = Enum.KeyCode.U,
	["V"] = Enum.KeyCode.V,
	["W"] = Enum.KeyCode.W,
	["X"] = Enum.KeyCode.X,
	["Y"] = Enum.KeyCode.Y,
	["Z"] = Enum.KeyCode.Z,
	["1"] = Enum.KeyCode.One,
	["2"] = Enum.KeyCode.Two,
	["3"] = Enum.KeyCode.Three,
	["4"] = Enum.KeyCode.Four,
	["5"] = Enum.KeyCode.Five,
	["6"] = Enum.KeyCode.Six,
	["7"] = Enum.KeyCode.Seven,
	["8"] = Enum.KeyCode.Eight,
	["9"] = Enum.KeyCode.Nine,
	["0"] = Enum.KeyCode.Zero,
	["Return"] = Enum.KeyCode.Return,
	["Backspace"] = Enum.KeyCode.Backspace,
	["Delete"] = Enum.KeyCode.Delete,
	["-"] = Enum.KeyCode.Minus,
	["="] = Enum.KeyCode.Equals,
	["'"] = Enum.KeyCode.Quote,
	["/"] = Enum.KeyCode.Slash,
	["\\"] = Enum.KeyCode.BackSlash,
	[";"] = Enum.KeyCode.Semicolon,
	[","] = Enum.KeyCode.Comma,
	["."] = Enum.KeyCode.Period,
	["["] = Enum.KeyCode.LeftBracket,
	["]"] = Enum.KeyCode.RightBracket,
	["LeftControl"] = Enum.KeyCode.LeftControl,
	["RightControl"] = Enum.KeyCode.RightControl,
	["Tab"] = Enum.KeyCode.Tab,
	["Left Click"] = Enum.UserInputType.MouseButton1,
	["Right Click"] = Enum.UserInputType.MouseButton2,
	["Scroll Click"] = Enum.UserInputType.MouseButton3,
}

keys['FromKey'] = {
	[Enum.KeyCode.A] = "A",
	[Enum.KeyCode.B] = "B",
	[Enum.KeyCode.C] = "C",
	[Enum.KeyCode.D] = "D",
	[Enum.KeyCode.E] = "E",
	[Enum.KeyCode.F] = "F",
	[Enum.KeyCode.G] = "G",
	[Enum.KeyCode.H] = "H",
	[Enum.KeyCode.I] = "I",
	[Enum.KeyCode.J] = "J",
	[Enum.KeyCode.K] = "K",
	[Enum.KeyCode.L] = "L",
	[Enum.KeyCode.M] = "M",
	[Enum.KeyCode.N] = "N",
	[Enum.KeyCode.O] = "O",
	[Enum.KeyCode.P] = "P",
	[Enum.KeyCode.Q] = "Q",
	[Enum.KeyCode.R] = "R",
	[Enum.KeyCode.S] = "S",
	[Enum.KeyCode.T] = "T",
	[Enum.KeyCode.U] = "U",
	[Enum.KeyCode.V] = "V",
	[Enum.KeyCode.W] = "W",
	[Enum.KeyCode.X] = "X",
	[Enum.KeyCode.Y] = "Y",
	[Enum.KeyCode.Z] = "Z",
	[Enum.KeyCode.One] = "1",
	[Enum.KeyCode.Two] = "2",
	[Enum.KeyCode.Three] = "3",
	[Enum.KeyCode.Four] = "4",
	[Enum.KeyCode.Five] = "5",
	[Enum.KeyCode.Six] = "6",
	[Enum.KeyCode.Seven] = "7",
	[Enum.KeyCode.Eight] = "8",
	[Enum.KeyCode.Nine] = "9",
	[Enum.KeyCode.Zero] = "10",
	[Enum.KeyCode.Return] = "Return",
	[Enum.KeyCode.Backspace] = "Backspace",
	[Enum.KeyCode.Delete] = "Delete",
	[Enum.KeyCode.Minus] = "-",
	[Enum.KeyCode.Equals] = "=",
	[Enum.KeyCode.Quote] = "'",
	[Enum.KeyCode.Slash] = "/",
	[Enum.KeyCode.BackSlash] = "\\",
	[Enum.KeyCode.Semicolon] = ";",
	[Enum.KeyCode.Comma] = ",",
	[Enum.KeyCode.Period] = ".",
	[Enum.KeyCode.LeftBracket] = "[",
	[Enum.KeyCode.RightBracket] = "]",
	[Enum.KeyCode.LeftControl] = "LeftControl",
	[Enum.KeyCode.RightControl] = "RightControl",
	[Enum.KeyCode.Tab] = "Tab",
	[Enum.UserInputType.MouseButton1] = "Left Click",
	[Enum.UserInputType.MouseButton2] = "Right Click",
	[Enum.UserInputType.MouseButton3] = "Scroll Click",
}

return keys)
      		print("Loaded TAS")
  	end    
