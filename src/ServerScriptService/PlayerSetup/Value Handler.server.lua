local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local stuff = require(game:GetService("ServerScriptService").Stuff)
local hitboxes = require(game:GetService("ServerScriptService").RadiusHitbox)

local character = script.Parent

local player = Players:GetPlayerFromCharacter(character)

local values = stuff.GetValues(character)

local humanoid = character.Humanoid
local animator = humanoid:FindFirstChild("Animator")
if (not animator) then
	animator = Instance.new("Animator")
	animator.Parent = humanoid
end

local addCooldown = ReplicatedStorage.Events.addCooldown
local getCooldown = ReplicatedStorage.Events.getCooldown
local oldPosture = 0
local postureTick = 0

local oldTempo = 0
local tempoTick = 0

local holding = false

local susLoop = nil

if (not player) then
	local move = Vector3.new(0, 0, 0)
	local loop = RunService.Stepped:Connect(function(t, dt)
		if (values.CarryStatus.Value ~= 0) then
			return
		end
		character.HumanoidRootPart.CFrame += move * dt
	end)
	values.Movement.Changed:Connect(function(value)
		if (loop) then
			move = Vector3.new(0, 0, 0)
		end
		if (value ~= 0) then
			move =  value * values.MovementVector.Value
		end
		
		if (value == 1) then
			move = 48 * values.MovementVector.Value
		end
		
		if (value == 2) then
			move = 28 * character.PrimaryPart.CFrame.LookVector
		end
	end)
	
	humanoid.Died:Connect(function()
		task.wait(6)
		hitboxes.RemoveCharacter(character)
		character:Destroy()
	end)
	
	values.Suspended.Changed:Connect(function(value)
		if (susLoop) then
			susLoop:Disconnect()
		end
		if (value == 0) then
			return
		end
		
		local save = character.HumanoidRootPart.CFrame.Position.Y
		local humanoidRootPart = character.HumanoidRootPart
		
		local change = 0
		
		susLoop = RunService.Stepped:Connect(function(t, dt)
			change += (10 - change) * 0.1
			humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, save + change - humanoidRootPart.Position.Y, 0)
			--humanoidRootPart.CFrame += Vector3.new(0, change, 0)
			humanoidRootPart.AssemblyLinearVelocity = Vector3.new(humanoidRootPart.AssemblyLinearVelocity.X, 0, humanoidRootPart.AssemblyLinearVelocity.Z)
		end)
		task.delay(value - tick(), function()
			if (value == values.Suspended.Value) then
				values.Suspended.Value = 0
			end
		end)
	end)
else
	values.Suspended.Changed:Connect(function(value)
		if (value == 0) then
			return
		end
		task.delay(value - tick(), function()
			if (value == values.Suspended.Value) then
				values.Suspended.Value = 0
			end
		end)
	end)
	
	Players.PlayerRemoving:Connect(function(p)
		print(p.Name.."is leaving")
		if (p.UserId ~= player.UserId) then
			return
		end
		if (values.CarryStatus.Value == 2) then
			print("stop carrying")
			
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
	end)
end

values.Posture.Changed:Connect(function(value)
	if (oldPosture < value) then
		postureTick = tick() + 1
	end
	oldPosture = value
end)

values.Tempo.Changed:Connect(function(value)
	if (oldTempo < value) then
		tempoTick = tick() + 8
	end
	oldTempo = value
end)

values.Equipped.Changed:Connect(function(value)
	if (value) then
		stuff.PlaySound("Equip", character.HumanoidRootPart, 0)
	else
		stuff.PlaySound("Sheath", character.HumanoidRootPart, 0)
		if (values.Blocking.Value ~= 0) then
			values.Blocking.Value = 0
		end
	end
end)

values.Knocked.Changed:Connect(function(value)
	if (value ~= 0) then
		if (not values.RagdollTrigger.Value) then
			values.RagdollTrigger.Value = true
		end
		task.delay(5, function()
			if (values.Knocked.Value == value) then
				values.Knocked.Value = 0
			end
		end)
	else
		values.RagdollTrigger.Value = false
		if (character:FindFirstChild("Pickup")) then
			character.Pickup:Destroy()
		end
	end
end)

values.RagdollTrigger.Changed:Connect(function(value)
	if (value) then
		holding = false
		values.Blocking.Value = 0
		values.Actionable.Value = false
	else
		if (humanoid.Health == 0) then
			values.RagdollTrigger.Value = true
			return
		end
		values.Actionable.Value = true
	end
end)

values.Stun.Changed:Connect(function(value)
	if (value == 0) then
		return
	end
	values.Actionable.Value = false
	task.delay(value - tick(), function()
		if (values.Stun.Value == value) then
			values.Stun.Value = 0
			if (values.Knocked.Value == 0) then	
				values.Actionable.Value = true
			end
		end
	end)
end)

RunService.Heartbeat:Connect(function(dt)
	if (tick() > postureTick) then
		values.Posture.Value = math.max(values.Posture.Value - 10 * dt, 0)
	end
	if (tick() > tempoTick) then
		values.Tempo.Value = math.max(values.Tempo.Value - 5 * dt, 0)
	end
end)

local blockAnim = stuff.LoadAnimation(ReplicatedFirst.Animations[values.Weapon.Value].Block, animator)
local parryAnim = stuff.LoadAnimation(ReplicatedFirst.Animations[values.Weapon.Value].Parry, animator)

values.Blocking.Changed:Connect(function(value)
	if (value ~= 0) then
		values.Sprinting.Value = false
	end
	if (value == 1) then
		parryAnim:Play()
	elseif (value == 2) then
		blockAnim:Play()
	else
		blockAnim:Stop()
		parryAnim:Stop()
	end
end)

function holdEvent(char, input, keybinds, began)
	if (char ~= character) then
		return
	end

	if (values.RagdollTrigger.Value or not values.Equipped.Value) then
		return
	end

	if (input == keybinds["Blocking"]) then
		if (began) then
			holding = true
			local function block()
				if (getCooldown:Invoke(character, "Parry")) then
					addCooldown:Fire(character, "Parry")
					values.Blocking.Value = 1
					task.delay(0.35, function()
						if (values.Blocking.Value == 1) then
							values.Blocking.Value = 2
						end
					end)
				else
					values.Blocking.Value = 2
				end
			end
			if (values.Actionable.Value) then
				block()
			else
				if (getCooldown:Invoke(character, "Parry")) then
					addCooldown:Fire(character, "Parry")
					values.Blocking.Value = 1
					task.delay(0.2, function()
						if (values.Blocking.Value == 1) then
							values.Blocking.Value = 0
						end
					end)
				end
				local check
				check = values.Actionable.Changed:Connect(function(value)
					if (values.Actionable.Value and holding) then
						block()
						check:Disconnect()
					end
				end)
			end
		else
			holding = false
			values.Blocking.Value = 0
			task.delay(0.1,function()
			end)
		end
	end
end

ReplicatedStorage.Events.holdEvent.OnServerEvent:Connect(function(player, input, keybinds, began)
	holdEvent(player.Character, input, keybinds, began)
end)

ReplicatedStorage.Events.npcHold.Event:Connect(function(character, input, keybinds, began)
	holdEvent(character, input, keybinds, began)
end)

character.DescendantAdded:Connect(function(child)
	if (child:IsA("Tool") and child:GetAttribute("Mantra")) then
		ReplicatedStorage.Events.castMantra:Fire(character, child.Name)
		wait()
		if (player) then
			child.Parent = player.Backpack
		end
		
		if (player.Backpack:FindFirstChild(values.Weapon.Value)) then
			player.Backpack:FindFirstChild(values.Weapon.Value).Parent = character
		end
	end
end)

local fallTick = 0

humanoid.StateChanged:Connect(function(old, new)
	if (new == Enum.HumanoidStateType.Landed or new == Enum.HumanoidStateType.Running) then
		if (character.HumanoidRootPart.Velocity.Y < -100 and tick() - fallTick > 0.2) then
			humanoid:TakeDamage((character.HumanoidRootPart.Velocity.Y + 80) * -0.4)
			fallTick = tick()
		end
	end
end)

values.Sliding.Changed:Connect(function(value)
	values.Actionable.Value = not value
end)