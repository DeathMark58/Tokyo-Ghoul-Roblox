local rs = game:GetService("ReplicatedStorage")
local events = rs.Events
local Debris = game:GetService("Debris")
local RadiusHitbox = require(game.ServerScriptService.RadiusHitbox)
local rf = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local stuff = require(script.Parent.Stuff)

local Animations = rf.Animations

local parried = Instance.new("BindableEvent")
local feint = Instance.new("BindableEvent")
local attacked = Instance.new("BindableEvent")

local addCooldown = rs.Events.addCooldown
local getCooldown = rs.Events.getCooldown

local setSprint = rs.Events.setSprint

setSprint.OnServerEvent:Connect(function(player, value)
	if (value) then
		if (ServerStorage[player.UserId].Crouching.Value) then
			ServerStorage[player.UserId].Crouching.Value = false
		end
	end
	ServerStorage[player.UserId].Sprinting.Value = value
end)

local function updateActionable(char, value)
	local folder = stuff.GetValues(char)
	local actionable = folder:FindFirstChild("Actionable")
	if (not actionable.Value and folder.Stun.Value ~= 0 and not folder.Knocked.Value) then
		return
	end
	actionable.Value = value
end

local function loadAnimation(animation, animator)
	local a = animator:LoadAnimation(animation)

	if (animation:GetAttribute("Priority")) then
		a.Priority = Enum.AnimationPriority[animation:GetAttribute("Priority")]
	end

	return a
end

local function particle(folderName, parent, deletion)
	stuff.SpawnParticle(folderName,parent,deletion)
end

local function attack(character, damage, stunDuration, postureDamage, animation, range, radius, windup, active, endlag, startsound, hitsound, sounddelay, feintable, armor, parriable, knockback, suspend)
	local plr = Players:GetPlayerFromCharacter(character)
	local folder

	if (plr) then
		folder = ServerStorage:FindFirstChild(plr.UserId)
	else
		folder = character.Values
	end

	folder.Actionable.Value = false
	folder.Attacking.Value = true

	folder.Sprinting.Value = false
	folder.Crouching.Value = false

	local weapon = require(game.ServerScriptService.WeaponStats)[folder.Weapon.Value]
	
	local attackAnimation
	if (animation) then
		attackAnimation = loadAnimation(animation, character.Humanoid.Animator)
		attackAnimation:Play(0,1,weapon["Animation Speed"])
	end

	local i = true

	local hitbox

	local sound = rf.Sounds:FindFirstChild(startsound):Clone()
	sound.Parent = character.HumanoidRootPart
	sound.PlaybackSpeed = ((math.random() * 2 - 1) * 0.1) + sound.PlaybackSpeed

	local cancel
	local interrupt
	local feinted = false

	interrupt = RunService.Stepped:Connect(function(t, dt)
		if (tick() < folder.Stun.Value and not armor) then
			if (attackAnimation) then
				attackAnimation:Stop(0) 
			end
			if (hitbox) then
				hitbox:stop()
			end
			sound:Destroy()
			i = false
			interrupt:Disconnect()
			if (cancel) then
				cancel:Disconnect()
			end
		end
	end)

	cancel = feint.Event:Connect(function(c)
		if (character == c and feintable and getCooldown:Invoke(character, "Feint")) then
			if (hitbox) then
				hitbox:stop()
			end
			i = false
			interrupt:Disconnect()
			cancel:Disconnect()
			feinted = true
			sound:Destroy()
			stuff.PlaySound("Feint", character.HumanoidRootPart, 0.1)
			addCooldown:Fire(character, "Feint")
			attackAnimation:Stop()
			if (folder.Movement.Value ~= 0) then
				folder.Movement.Value = 0
			end
			task.wait(0.1)
			folder.Attacking.Value = false
			folder.Actionable.Value = true
		end
	end)

	task.delay(sounddelay, function()
		if (sound) then
			sound:Play()
		end
	end)

	hitbox = RadiusHitbox.new(character.HumanoidRootPart.Position + (character.HumanoidRootPart.CFrame.LookVector * range), radius, character, windup)
	task.wait(windup)
	cancel:Disconnect()
	if (i) then

		local hit
		hit = hitbox.Hit:Connect(function(part)
			local victim = part.Parent
			local victimValues = stuff.GetValues(victim)
			if (part.Parent.Humanoid:GetAttribute("Prop")) then
				if (part.Parent.Humanoid:GetAttribute("Prop") == "Ice") then
					local point = rs.Particles.Point:Clone()
					point.Parent = workspace
					point.Position = hitbox._Position

					particle("Ice",point.Attachment,1)
					stuff.PlaySound(hitsound, part.Parent:FindFirstChild("Torso"), 0.1)
					Debris:AddItem(point, 1)
				end

				part.Parent.Humanoid:TakeDamage(damage)
				return
			end

			local result = stuff.Attack(part, damage, postureDamage, character, parriable)

			if (result == "Hit" or result == "Knocked") then
				stuff.PlaySound(hitsound, part, 0.1)
			end

			if (result == "Hit") then
				attacked:Fire(victim, character)
				stuff.Stun(part.Parent, stunDuration)
				if (knockback and knockback < 0) then
					victimValues.MovementVector.Value = character.HumanoidRootPart.CFrame.LookVector*-1
					victimValues.Movement.Value = knockback
					task.delay(0.4, function()
						victimValues.Movement.Value = 0
					end)
				end
				
				if (suspend and suspend > 0) then
					victimValues.Suspended.Value = tick() + suspend
				end
			end

		end)

		local update
		update = RunService.Stepped:Connect(function(t, dt)
			hitbox:setPosition(character.HumanoidRootPart.Position + (character.HumanoidRootPart.CFrame.LookVector * (range + folder.Movement.Value)))
		end)

		character:FindFirstChild("weaponModel").Blade.WeaponTrail.Enabled = true

		hitbox:start()

		task.wait(active)

		hitbox:stop()

		interrupt:Disconnect()
		update:Disconnect()

		character:FindFirstChild("weaponModel").Blade.WeaponTrail.Enabled = false

		task.wait(endlag)

		folder.Attacking.Value = false

		if (tick() > folder.Stun.Value) then
			folder.Actionable.Value = true
		end
	else
		task.wait(active + windup)

		folder.Attacking.Value = false
	end

end

local function attackCheck(folder)
	return folder.Actionable.Value and folder.Equipped.Value and not folder.Attacking.Value and folder.Blocking.Value == 0 and not folder.RagdollTrigger.Value and folder.Knocked.Value == 0 and folder.Stun.Value == 0 and folder.CarryStatus.Value ~= 1
end

local function actionCheck(folder)
	return folder.Actionable.Value and not folder.Attacking.Value and folder.Blocking.Value == 0 and not folder.RagdollTrigger.Value and folder.Knocked.Value == 0 and folder.Stun.Value == 0 and folder.CarryStatus.Value ~= 1
end

local function input(char, input, keybinds)
	local plr = Players:GetPlayerFromCharacter(char)
	local character = char
	local folder = stuff.GetValues(character)

	if (not character) then
		return
	end

	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid.Health == 0 then
		return
	end

	local animator = humanoid:FindFirstChild("Animator")
	if(not animator)then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local weapon = character:FindFirstChild("weaponModel")
	local weaponStats = require(game.ServerScriptService.WeaponStats)[folder.Weapon.Value]
	

	if(input == Enum.UserInputType.MouseButton1 and attackCheck(folder) and getCooldown:Invoke(char,"M1")) then
		if (folder.Crouching.Value and getCooldown:Invoke(char, "Uppercut")) then
			addCooldown:Fire(char, "Uppercut")
			local h = attacked.Event:Connect(function(victim, attacker)
				if (attacker ~= character) then
					return
				end
				stuff.GetValues(attacker).Suspended.Value = tick() + 2
			end)
			attack(character, weaponStats["Damage"], weaponStats["Stun"], weaponStats["Weight"] * 2, Animations[folder.Weapon.Value].Uppercut, weaponStats["Range"], weaponStats["Radius"], 0.6, 0.1, 0.35, "Swing", "Gore, Crushing and Gore, Slash", 0.1, true, false, true, 0, 2)
			h:Disconnect()
			return
		end
		if ((humanoid:GetState() == Enum.HumanoidStateType.Freefall or humanoid:GetState() == Enum.HumanoidStateType.Jumping) and folder.Suspended.Value == 0) then
			if(getCooldown:Invoke(char,"Aerial")) then
				folder.Movement.Value = 2
				task.delay(0.45,function()
					folder.Movement.Value = 0
				end)
				attack(character, weaponStats["Damage"], weaponStats["Stun"], weaponStats["Weight"], Animations[folder.Weapon.Value].Aerial, weaponStats["Range"], weaponStats["Radius"], weaponStats["Windup"], weaponStats["Active"], weaponStats["Endlag"], "Swing", "Gore, Slash and Slash", 0.1, true, false, true, 0, 0)
				addCooldown:Fire(char,"Aerial")
				return
			end
		end

		if (folder.Sprinting.Value and attackCheck(folder) and getCooldown:Invoke(char, "RunAttack")) then
			folder.Movement.Value = 3
			task.delay(0.35, function()
				folder.Movement.Value = 0
			end)
			attack(character, weaponStats["Damage"], weaponStats["Stun"], weaponStats["Weight"], Animations[folder.Weapon.Value].RunAttack, weaponStats["Range"], weaponStats["Radius"], weaponStats["Windup"], weaponStats["Active"], weaponStats["Endlag"], "Swing", "Gore, Slash and Slash", 0.1, true, false, true, 0, 0)
			addCooldown:Fire(char, "RunAttack")
			return
		end

		if(tick() - folder.LastM1.Value > weaponStats["Windup"] + weaponStats["Active"] + weaponStats["Endlag"] + 0.31 or folder.M1Combo.Value == 5) then
			folder.M1Combo.Value = 0
		end
		folder.M1Combo.Value += 1	

		folder.LastM1.Value = tick()

		if (folder.M1Combo.Value == 5) then
			attack(character, weaponStats["Damage"], weaponStats["Stun"], weaponStats["Weight"], Animations[folder.Weapon.Value]["Swing"..folder.M1Combo.Value], weaponStats["Range"], weaponStats["Radius"], weaponStats["Windup"], weaponStats["Active"], weaponStats["Endlag"], "Swing", "Gore, Blunt and Gore, Impact and Gore, Impact2", 0.1, true, false, true, -32, 0)
		else
			attack(character, weaponStats["Damage"], weaponStats["Stun"], weaponStats["Weight"], Animations[folder.Weapon.Value]["Swing"..folder.M1Combo.Value], weaponStats["Range"], weaponStats["Radius"], weaponStats["Windup"], weaponStats["Active"], weaponStats["Endlag"], "Swing", "Gore, Slash and Slash", 0.1, true, false, true, 0, 0)
		end


		if (folder.M1Combo.Value == 5) then
			addCooldown:Fire(char,"M1")
		end

		return
	end

	if (input == keybinds["Critical"] and attackCheck(folder) and getCooldown:Invoke(char, "Critical")) then
		attack(character, weaponStats["Damage"] * 1.5, weaponStats["Stun"], weaponStats["Weight"] * 3, Animations[folder.Weapon.Value].Critical, weaponStats["Range"], weaponStats["Radius"], weaponStats["Critical"]["Windup"], weaponStats["Critical"]["Active"], weaponStats["Critical"]["Endlag"], "Swing", "Gore, Slash and Gore, Crushing and Gore, Impact2 and Gore, Bone Breaks", 0.1, false, false, true, -32, 0)
		addCooldown:Fire(char, "Critical")
		return
	end

	if (input == keybinds["Roll"] and actionCheck(folder) and getCooldown:Invoke(char,"Roll")) then
		addCooldown:Fire(char,"Roll")

		local sound = rf.Sounds.LightRoll:Clone()
		sound.Parent = character.HumanoidRootPart
		sound.PlaybackSpeed = ((math.random() * 2 - 1) * 0.1) + 1
		sound:Play()
		Debris:AddItem(sound, 1)

		local particleAttatch = Instance.new("Attachment")
		particleAttatch.Position = Vector3.new(0,-3,0)
		particleAttatch.Parent = character.HumanoidRootPart
		local effect = game.ReplicatedStorage.Particles.Roll.Impact:Clone()
		effect.Parent = particleAttatch
		effect.Rate = 190
		Debris:AddItem(particleAttatch,2)

		local Ray = Ray.new(character.HumanoidRootPart.Position, Vector3.new(0, -10, 0))
		local FloorPart = workspace:FindPartOnRay(Ray, char)

		if(FloorPart ~= nil) then
			effect.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, FloorPart.Color),
				ColorSequenceKeypoint.new(1, FloorPart.Color)
			}
		end

		folder.Movement.Value = 1
		updateActionable(character, false)

		local rDirection = humanoid.MoveDirection
		local relative = humanoidRootPart.CFrame:vectorToObjectSpace(rDirection)
		local rollTrack = stuff.LoadAnimation("Base, Back Roll", animator)
		if (math.abs(relative.X) > 0.9) then
			if (relative.X > 0) then
				rollTrack = stuff.LoadAnimation("Base, Right Roll", animator)
			else
				rollTrack = animator:LoadAnimation(Animations.Base["Left Roll"])
			end
		end
		if (relative.Z > 0.9) then
			rollTrack = animator:LoadAnimation(Animations.Base["Forward Roll"])
		end
		if (rDirection.Magnitude < 0.1) then
			rDirection = (humanoidRootPart.CFrame.LookVector * Vector3.new(-1, 0, -1)).Unit
		end
		rollTrack:Play()

		folder.MovementVector.Value = rDirection

		local waiting = true

		local cancel
		cancel = feint.Event:Connect(function()
			if (getCooldown:Invoke(character,  "Roll Cancel")) then
				addCooldown:Fire(character, "Roll Cancel")
				effect.Rate = 0
				cancel:Disconnect()
				rollTrack:Stop()
				local cancelAnim = stuff.LoadAnimation(rf.Animations.Base["Roll Cancel"], animator)
				cancelAnim:Play()
				waiting = false
				task.wait(0.1)
				folder.Actionable.Value = true
				folder.MovementVector.Value = Vector3.new(0, 0, 0)
				task.wait(0.2)
				folder.Movement.Value = 0
			end
		end)

		task.wait(0.3)

		folder.Movement.Value = 0
		effect.Rate = 0

		task.wait(0.2)

		cancel:Disconnect()

		if (waiting) then
			updateActionable(character, true)
		end
	end

	if (input == "L") then
		--folder.RagdollTrigger.Value = not folder.RagdollTrigger.Value
	end

	if (input == keybinds["Carry"] and actionCheck(folder)) then
		if (folder.CarryStatus.Value == 0) then
			local hitbox = RadiusHitbox.new(character.HumanoidRootPart.CFrame.Position, 8, character, 0)

			local h
			h = hitbox.Hit:Connect(function(part)
				local victim = part.Parent
				local victimValues = stuff.GetValues(victim)
				if (victim.Humanoid.Health == 0) then
					return
				end
				if (victimValues.Knocked.Value ~= 0) then
					if (victimValues.CarryStatus.Value ~= 0) then
						return
					end
					victimValues.Knocked.Value = 0
					victimValues.CarryStatus.Value = 1
					folder.CarryStatus.Value = 2 

					victim.Humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)
					victim.Humanoid.PlatformStand = true
					victimValues.Invincible.Value = true

					for _,v in pairs(victim:GetChildren()) do
						if v:IsA("BasePart") then
							v.CollisionGroup = "Carried"
							v.Massless = true
							v:SetNetworkOwner(Players:GetPlayerFromCharacter(character))
						end
					end

					victim.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame - character.HumanoidRootPart.CFrame.LookVector * 2

					local weld = Instance.new("Motor6D")
					weld.Name = "CarryWeld"
					weld.Part0 = character.HumanoidRootPart
					weld.Part1 = victim.HumanoidRootPart
					weld.Parent = character.HumanoidRootPart

					loadAnimation(Animations.Base["Carry"], character.Humanoid.Animator):Play(0,1,0)
					loadAnimation(Animations.Base["Carried"], victim.Humanoid.Animator):Play(0,1,0)
					h:Disconnect()
				end
			end)

			hitbox:start()
			task.wait(0.03)
			hitbox:stop()
			return
		elseif (folder.CarryStatus.Value == 2) then
			local victim = humanoidRootPart:FindFirstChild("CarryWeld").Part1.Parent
			local victimValues = stuff.GetValues(victim)
			
			victimValues.CarryStatus.Value = 0
			folder.CarryStatus.Value = 0

			humanoidRootPart.CarryWeld:Destroy()

			victimValues.Invincible.Value = false

			victimValues.Knocked.Value = tick()

			for _,v in pairs(victim:GetChildren()) do
				if v:IsA("BasePart") then
					v.Massless = false
					v:SetNetworkOwner(Players:GetPlayerFromCharacter(victim))
				end
			end

			wait(0.03)

			victim.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + character.HumanoidRootPart.CFrame.LookVector * 4 + Vector3.new(0, 2, 0)

			victim.HumanoidRootPart.Velocity = character.HumanoidRootPart.Velocity + character.HumanoidRootPart.CFrame.LookVector * 70 + Vector3.new(0, 70, 0)


			for i,v in pairs (animator:GetPlayingAnimationTracks()) do
				if(v.Name == "Carry" or v.Name == "Carried") then
					v:Stop()
				end
			end

			for i,v in pairs (victim.Humanoid.Animator:GetPlayingAnimationTracks()) do
				if(v.Name == "Carry" or v.Name == "Carried") then
					v:Stop()
				end
			end
		end
	end

	if (input == keybinds["Execute"] and actionCheck(folder)) then
		local hitbox = RadiusHitbox.new(character.HumanoidRootPart.CFrame.Position, 8, character, 0)

		hitbox.Hit:Connect(function(part)
			local values = Players:GetPlayerFromCharacter(part.Parent)
			if (values) then
				values = ServerStorage[values.UserId]
			else
				values = part.Parent.Values
			end
			if (values.Knocked.Value ~= 0 and values.CarryStatus.Value == 0) then
				stuff.PlaySound("Grip and Gore, Blade", part.Parent.HumanoidRootPart, 0.1)
				print(part.Parent.Name.." was gripped")
				part.Parent.Humanoid.Health = 0
				if (part.Parent:FindFirstChild("Pickup")) then
					part.Parent.Pickup:Destroy()
				end
				
				humanoid.Health += 50
			end
		end)

		hitbox:start()

		task.delay(0.03, function()
			hitbox:stop()
		end)
	end
end

rs.Events.combatEvent.OnServerEvent:Connect(function(plr, inputName, keybinds)
	input(plr.Character, inputName, keybinds)
end)

rs.Events.npcCombat.Event:Connect(function(char, inputName, keybinds)
	input(char, inputName, keybinds)
end)

function holdEvent(character, input, keybinds, began)
	local folder = stuff.GetValues(character)
	if (not character) then
		return
	end
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")

	if humanoid.Health == 0 then
		return
	end

	if (folder.Knocked.Value ~= 0) then
		return
	end

	if (input == Enum.UserInputType.MouseButton2) then
		feint:Fire(character)
		return
	end

	if (input == keybinds["Crouch"] and began) then
		if (folder.Sliding.Value) then
			for i, v in pairs(animator:GetPlayingAnimationTracks()) do
				if (v.Name == "Sliding") then
					v:Stop()
				end
			end
			folder.Sliding.Value = false
		else
			if (humanoid:GetState() ~= Enum.HumanoidStateType.Jumping and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall and folder.Sprinting.Value and actionCheck(folder)) then
				loadAnimation(Animations.Base.Sliding, animator):Play()
				folder.Sliding.Value = true
				folder.Crouching.Value = false
			else
				if (humanoid:GetState() == Enum.HumanoidStateType.Freefall and folder.Sprinting.Value) then
					return
				end
				folder.Crouching.Value = not folder.Crouching.Value
				if (folder.Crouching.Value) then
					folder.Sprinting.Value = false
				end
			end
		end
		return
	end

	if (input == keybinds["Vent"] and folder.Tempo.Value >= 50 and began) then
		folder.Tempo.Value -= 50	

		folder.Stun.Value = 0
		stuff.Stun(character, 0.3)

		particle("Vent", humanoidRootPart.RootAttachment, 1)

		local hitbox = RadiusHitbox.new(character.HumanoidRootPart.CFrame.Position, 9, character, 0)
		stuff.PlaySound("Vent", humanoidRootPart, 0)

		hitbox.Hit:Connect(function(part)
			local values = Players:GetPlayerFromCharacter(part.Parent)
			if (values) then
				values = ServerStorage[values.UserId]
			else
				values = part.Parent.Values
			end


			values.MovementVector.Value = CFrame.lookAt(part.Parent.HumanoidRootPart.Position, humanoidRootPart.Position).LookVector

			stuff.Stun(part.Parent, 0.1)
			values.Movement.Value = -48
			task.delay(0.3, function()
				values.Movement.Value = 0
			end)
		end)

		hitbox:start()

		task.delay(0.03, function()
			hitbox:stop()
		end)
		return
	end
end

rs.Events.holdEvent.OnServerEvent:Connect(function(Player, input, keybinds, began)
	holdEvent(Player.Character, input, keybinds, began)
end)

rs.Events.npcHold.Event:Connect(function(character, input, keybinds, began)
	holdEvent(character, input, keybinds, began)
end)

events.castMantra.Event:Connect(function(character, name)
	local values = stuff.GetValues(character)
	if (name == "big yell" and actionCheck(values)) then
		attack(character, 5, 0.2, 100, Animations.Mantra["Big Yell"], 0, 7, 0.6, 0.25, 0.2, "Small Roar", "Slash", 0.5, false, false, false, -10)
	end
	
	if (name == "Sand Kick" and actionCheck(values)) then
		attack(character, 5, 0.2, 100, Animations.Base.Pain1, 0, 7, 0.6, 0.25, 0.2, "Small Roar", "Pain, pain-generic", 0.5, false, false, false, -10)
	end
	
	if (name == "IceSlam") then
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.IgnoreWater = true
		params.FilterDescendantsInstances = {character}
		local result = workspace:Raycast(character.HumanoidRootPart.Position, Vector3.new(0, -100, 0), params)
		task.delay(1, function()
			for i = 1, 10, 1 do
				local spikes = rs["Ice Spikes"]:Clone()
				spikes.Parent = workspace
				local direction = math.rad(math.random() * 360)
				spikes.PrimaryPart.CFrame = CFrame.Angles(0, math.random() * math.rad(360), 0) + result.Position + Vector3.new(math.sin(direction), 0, math.cos(direction)) * math.random() * 20 + character.HumanoidRootPart.CFrame.LookVector * 10 + Vector3.new(0, -2, 0)
			end
		end)
	end
end)

events.setValue.OnServerEvent:Connect(function(player, name, value)
	local character = player.Character
	local humanoid = character.Humanoid
	local animator = humanoid.Animator
	local values = stuff.GetValues(character)
	
	values[name].Value = value
	
	if (name == "Sliding" and value == false) then
		for i, v in pairs(animator:GetPlayingAnimationTracks()) do
			if (v.Name == "Sliding") then
				v:Stop()
			end
		end
	end
end)