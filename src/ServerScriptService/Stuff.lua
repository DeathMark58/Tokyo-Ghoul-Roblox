--!nonstrict

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Debris = game:GetService("Debris")

local stuff = {}

function stuff.SpawnParticle(folder : string | Folder, parent : Instance, deletion : number)
	if (typeof(folder) == "string") then
		for i, v in pairs(ReplicatedStorage.Particles[folder]:GetChildren()) do
			if (v:IsA("ParticleEmitter")) then
				local p = v:Clone()
				p.Parent = parent
				p:Emit(p:GetAttribute("Amount"))
				Debris:AddItem(p, deletion)
			end
		end
	else
		for i, v in pairs(folder:GetChildren()) do
			if (v:IsA("ParticeEmitter")) then
				local p = v:Clone()
				p.Parent = parent
				p:Emit(p:GetAttribute("Amount"))
				Debris:AddItem(p, deletion)
			end
		end
	end
end

function stuff.PlaySound(soundName : string, parent : Instance, r : number)
	local locations = string.split(soundName, " and ")
	for i, v in pairs(locations) do
		local location = string.split(v, ", ")
		local folder = ReplicatedFirst.Sounds:FindFirstChild(location[1])
		for i = 2, #location, 1 do
			folder = folder:FindFirstChild(location[i])
			if (not folder) then
				warn("Folder "..location[i].." not found")
			end
		end
		if (folder) then
			if (folder.ClassName == "Folder") then
				local sounds = folder:GetChildren()
				local sound = sounds[math.random(1, #sounds)]:Clone()
				sound.Parent = parent
				sound.PlaybackSpeed = ((math.random() * 2 - 1) * r) + sound.PlaybackSpeed
				sound:Play()
				Debris:AddItem(sound, sound.TimeLength)
			else
				local sound = folder:Clone()
				sound.Parent = parent
				sound.PlaybackSpeed = ((math.random() * 2 - 1) * r) + sound.PlaybackSpeed
				sound:Play()
				Debris:AddItem(sound, sound.TimeLength)
			end
		end
	end
end

function stuff.LoadAnimation(animation : string | Animation, animator : Animator)
	local anim = nil
	if (typeof(animation) == "string") then
		local location = string.split(animation, ", ")
		anim = ReplicatedFirst.Animations:FindFirstChild(location[1])
		for i = 2, #location, 1 do
			anim = anim:FindFirstChild(location[i])
		end
	elseif (animation:IsA("Animation")) then
		anim = animation
	end
	local track = animator:LoadAnimation(anim)

	if (anim:GetAttribute("Priority")) then
		track.Priority = Enum.AnimationPriority[anim:GetAttribute("Priority")]
	end

	return track
end

function stuff.GetValues(character : Model)
	local values = Players:GetPlayerFromCharacter(character)
	if (values) then
		values = ServerStorage[values.UserId]
	else
		values = character:WaitForChild("Values")
	end
	
	return values
end

function stuff.Stun(character : Model, duration)
	local values = stuff.GetValues(character)

	if (tick() + duration > values.Stun.Value) then
		values.Stun.Value = tick() + duration
	end
end

function stuff.Attack(part : BasePart, damage : number, postureDamage : number, attacker : Model, parriable : boolean)
	local character = part.Parent
	if (character and attacker) then
		local humanoidRootPart = character.HumanoidRootPart
		local humanoid = character.Humanoid
		local animator = humanoid:FindFirstChild("Animator")
		if (not animator) then
			animator = Instance.new("Animator")
			animator.Parent = humanoid
		end
		local values = stuff.GetValues(character)
		local attackerValues = stuff.GetValues(attacker)
		
		local attackerPlayer = Players:GetPlayerFromCharacter(attacker)
		
		local weaponModel = character:FindFirstChild("weaponModel")
		
		if (values.Invincible.Value) then
			return "Invincible"
		end

		if (values.Movement.Value == 1) then
			stuff.PlaySound("Dodge", humanoidRootPart, 0)
			return "Dodged"
		end
		
		if (values.Blocking.Value == 1 and parriable) then
			stuff.PlaySound("Parry", humanoidRootPart, 0.2)
			local attackerWeapon = attacker:FindFirstChild("WeaponModel")
			
			ReplicatedStorage.Events.skipCooldown:Fire(character, "Parry")
			
			local point = ReplicatedStorage.Particles.Point:Clone()
			point.Parent = workspace
			if (attackerWeapon and weaponModel) then
				point.CFrame = weaponModel.Blade.CFrame:Lerp(attackerWeapon.Blade.CFrame, 0.3)
			elseif (weaponModel) then
				point.CFrame = weaponModel.Blade.CFrame + humanoidRootPart.CFrame.LookVector
			end

			Debris:AddItem(point, 1)
			
			stuff.SpawnParticle("Parry", point.Attachment, 1)

			attackerValues.Posture.Value = math.min(attackerValues.Posture.Value + 30, 100)

			values.Posture.Value = math.max(values.Posture.Value - 30, 0)
			
			local parry = stuff.LoadAnimation(ReplicatedFirst.Animations[values.Weapon.Value]["DefenderParry"], animator)
			parry:Play()
			
			local parried = stuff.LoadAnimation(ReplicatedFirst.Animations[attackerValues.Weapon.Value]["Parried"], attacker.Humanoid.Animator)
			if (attacker:GetAttribute("Type") ~= "Boss") then
				parried:Play()
			end
			
			stuff.Stun(attacker, 0.6)
			
			return "Parried"
		end

		if (values.Blocking.Value ~= 0  and character.HumanoidRootPart.CFrame:vectorToObjectSpace(attacker.HumanoidRootPart.CFrame.LookVector).Z > -0.382) then
			values.Posture.Value += postureDamage
			if (values.Posture.Value > 100) then
				stuff.PlaySound("Block Break", humanoidRootPart, 0.1)
				stuff.SpawnParticle("Block Break", humanoidRootPart, 1)
				
				values.Posture.Value = 0
				stuff.Stun(character, 1.5)
				local animation = stuff.LoadAnimation(ReplicatedFirst.Animations.Base["Pain"..math.random(1, 3)], animator)
				animation:Play(0.1,1,0.5)
				
				humanoid.Health = math.max(humanoid.Health - damage * 1.5, 0.01)
				if (attackerPlayer) then
					ReplicatedStorage.Events.attacked:FireClient(attackerPlayer, character, humanoid.Health)
				end
				
				values.Blocking.Value = 0
				
				for i, v in pairs(animator:GetPlayingAnimationTracks()) do
					if (v.Name == "Block") then
						v:Stop()
					end
				end
				
				return "Block Broken"
			end

			stuff.PlaySound("Block", humanoidRootPart, 0.1)
			if (weaponModel) then
				stuff.SpawnParticle("Block", weaponModel.Blade, 1)
			else
				stuff.SpawnParticle("Block", humanoidRootPart, 1)
			end
			
			return "Blocked"
		end

		stuff.SpawnParticle("Hit", part, 1)
		
		if (values.CarryStatus.Value == 2) then
			values.CarryStatus.Value = 0

			local carried = character.HumanoidRootPart.CarryWeld.Part1.Parent
			local carriedValues = stuff.GetValues(carried)

			character.HumanoidRootPart.CarryWeld:Destroy()

			carriedValues.Invincible.Value = false
			carriedValues.CarryStatus.Value = 0
			carriedValues.Knocked.Value = tick()

			for _,v in pairs(carried:GetChildren()) do
				if v:IsA("BasePart") then
					v.Massless = false
					v:SetNetworkOwner(Players:GetPlayerFromCharacter(carried))
				end
			end

			wait(0.03)

			carried.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + character.HumanoidRootPart.CFrame.LookVector * 4 + Vector3.new(0, 2, 0)

			carried.HumanoidRootPart.Velocity = character.HumanoidRootPart.Velocity + character.HumanoidRootPart.CFrame.LookVector * 70 + Vector3.new(0, 70, 0)


			for i,v in pairs (character.Humanoid.Animator:GetPlayingAnimationTracks()) do
				if(v.Name == "Carry" or v.Name == "Carried") then
					v:Stop()
				end
			end

			for i,v in pairs (carried.Humanoid.Animator:GetPlayingAnimationTracks()) do
				if(v.Name == "Carry" or v.Name == "Carried") then
					v:Stop()
				end
			end
		end
		
		if (humanoid.Health - damage <= 0 or humanoid.Health == 0.01 and character:GetAttribute("Type") ~= "Boss") then
			humanoid.Health = 0.01
			if (values.Knocked.Value ~= 0) then
				values.Knocked.Value = tick()
				return "Knocked"
			end
			values.Knocked.Value = tick()
		else
			values.Tempo.Value = math.min(values.Tempo.Value + damage / 2, 100)
			attackerValues.Tempo.Value = math.min(attackerValues.Tempo.Value + damage, 100)
			local pain = stuff.LoadAnimation(ReplicatedFirst.Animations.Base["Pain"..math.random(1, 3)], animator)
			if (part.Parent and part.Parent:GetAttribute("Type") ~= "Boss") then
				pain:Play()
			end
			humanoid.Health -= damage
		end
		
		if (attackerPlayer) then
			ReplicatedStorage.Events.attacked:FireClient(attackerPlayer, character, humanoid.Health)
		end
		
		return "Hit"
	end
	return ""
end

return stuff