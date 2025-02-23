local Players = game:GetService('Players')
local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Debris = game:GetService('Debris')
local ServerStorage = game:GetService('ServerStorage')
local ReplicatedFirst = game:GetService('ReplicatedFirst')
------------------------------------------------------------------
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild('Humanoid')
local Animator = Humanoid:WaitForChild("Animator")
local HumanoidRootPart = Character:WaitForChild('HumanoidRootPart')
local sprintAnimation = Humanoid:LoadAnimation(script:WaitForChild("Sprint"))
sprintAnimation.Looped = true
sprintAnimation.Priority = Enum.AnimationPriority.Movement
local equippedAnim = Humanoid:LoadAnimation(ReplicatedFirst.Animations[ReplicatedStorage.Events.requestData:InvokeServer("Weapon")].Equipped)
equippedAnim.Looped = true
local crouchWalk = Humanoid:LoadAnimation(script:WaitForChild("CrouchWalk"))
crouchWalk.Priority = Enum.AnimationPriority.Movement
local crouchIdle = Humanoid:LoadAnimation(script:WaitForChild("CrouchIdle"))
crouchIdle.Priority = Enum.AnimationPriority.Idle
local ledge = Humanoid:LoadAnimation(ReplicatedFirst.Animations.Base.Ledge)
ledge.Priority = Enum.AnimationPriority.Action2
------------------------------------------------------------------
local rootJoint = HumanoidRootPart:WaitForChild("RootJoint")
local rootC0 = rootJoint.C0

local tiltAngle = 7
local tilt = CFrame.new()
------------------------------------------------------------------
local sprinting = false
local crouchSpeed = 8
local baseSpeed = 12
local sprintSpeed = 22
local stunnedSpeed = 4
Humanoid.WalkSpeed = baseSpeed

local stunned = false
local attacking = false
local dashing = false
local blocking = 0

local equipped = false
local tool = Player.Backpack:FindFirstChildOfClass("Tool")

local lastTick = tick()
local lastKey

local keybinds = Player.PlayerScripts:WaitForChild("Keybinds")

local jumpCooldown = 1

local setSprint = ReplicatedStorage.Events.setSprint

local humanoidState = Humanoid:GetState()

local climbed = false
local climbAnim = Animator:LoadAnimation(ReplicatedFirst.Animations.Base.Climb)
climbAnim.Priority = Enum.AnimationPriority.Action3
local climbLoop = nil
local space = false

local limbs = {Character["Right Arm"], Character["Left Arm"], Character["Right Leg"], Character["Left Leg"]}

local trails = {}

for _, v in ipairs(limbs) do
	local trail = ReplicatedStorage.Trail:Clone()
	trail.Enabled = false

	local attachment0 = Instance.new("Attachment")
	attachment0.CFrame = CFrame.new(0, -1, 0)
	attachment0.Parent = v
	local attachment1 = Instance.new("Attachment")
	attachment1.CFrame = CFrame.new(0, -0.6, 0)
	attachment1.Parent = v
	
	trail.Attachment0 = attachment0
	trail.Attachment1 = attachment1
	
	trail.Parent = v
	table.insert(trails, trail)
end

UserInputService.InputBegan:Connect(function(i, g)
	if (g) then
		return
	end
	if (i.KeyCode == Enum.KeyCode.Space and humanoidState == Enum.HumanoidStateType.Freefall) then
		space = true
	end
end)

function toggleEquip()
	if (sprinting) then
		sprintAnimation:Stop()
		equippedAnim:Stop()
	else
		if (ReplicatedStorage.Events.requestData:InvokeServer("Crouching")) then
			local kb = {}
			for i, v in pairs(keybinds:GetChildren()) do
				kb[v.Name] = v.Value
			end

			ReplicatedStorage.Events.combatEvent:FireServer(keybinds.Crouch.Value, kb)
		end
		crouchWalk:Stop()
		sprintAnimation:Play()
	end
	setSprint:FireServer(not sprinting)
end

local holdLoop = RunService.Stepped:Connect(function() end)
holdLoop:Disconnect()

local movementLoop = nil
local moveDirection = Vector3.new(0, 0, 0)

local susLoop = nil
local sliding = false
local slideVector = Vector3.new(0, 0, 0)

local speedBoost = 0

Humanoid.StateChanged:Connect(function(old, new)
	if (new == Enum.HumanoidStateType.Jumping and sliding) then
		sliding = false
		ReplicatedStorage.Events.setValue:FireServer("Sliding", false)
		ReplicatedStorage.Events.setValue:FireServer("Speedboost", tick() + 1)
	end
	humanoidState = new
end)

ReplicatedStorage.Events.valueChanged.OnClientEvent:Connect(function(name, value)
	if (name == "Speedboost") then
		speedBoost = value
		for i, v in pairs(trails) do
			v.Enabled = true
		end
		task.delay(value - tick(), function()
			if (value == speedBoost) then
				for i, v in pairs(trails) do
					v.Enabled = false
				end
			end
		end)
		return
	end
	if (name == "Stun") then
		if (value == 0) then
			stunned = false
		else
			stunned = true
		end
		return
	end
	if (name == "Attacking") then
		attacking = value
	end
	if (name == "MovementVector") then
		moveDirection = value
		return
	end
	if (name == "Equipped") then
		if (value) then
			equipped = true
			if (sprinting) then
				wait(0.2)
				equippedAnim:Play()
			end
		else 
			equipped = false
			equippedAnim:Stop()
		end
		return
	end
	if (name == "Sprinting") then
		sprinting = value
		if (not value) then
			sprintAnimation:Stop()
		end
		return
	end
	if (name == "Blocking") then
		blocking = value
		return
	end
	if (name == "Movement") then
		if (value ~= 0) then
			dashing = true
			movementLoop = RunService.Stepped:Connect(function(t, dt)
				if (value < 0) then --kb
					HumanoidRootPart.CFrame += moveDirection * value * dt
				end
				if (value == 1) then --roll
					HumanoidRootPart.CFrame += moveDirection * 48 * dt
				end
				if (value == 2) then --aerial
					HumanoidRootPart.CFrame += HumanoidRootPart.CFrame.LookVector * 28 * dt
					HumanoidRootPart.AssemblyLinearVelocity *= Vector3.new(1,0.91,1)
				end
				if (value == 3) then --running atk
					HumanoidRootPart.CFrame += HumanoidRootPart.CFrame.LookVector * 20 * dt
					Character.Humanoid.WalkSpeed = 0
				end
			end)
		else
			if (movementLoop) then
				movementLoop:Disconnect()
			end
			dashing = false
		end
		return
	end
	if (name == "Suspended") then
		if (susLoop) then
			susLoop:Disconnect()
		end
		if (value == 0) then
			return
		end

		local save = Character.HumanoidRootPart.CFrame.Position.Y

		local change = 0

		susLoop = RunService.Stepped:Connect(function(t, dt)
			change += (10 - change) * 0.1
			HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, save + change - HumanoidRootPart.Position.Y, 0)
			--humanoidRootPart.CFrame += Vector3.new(0, change, 0)
			HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(HumanoidRootPart.AssemblyLinearVelocity.X, 0, HumanoidRootPart.AssemblyLinearVelocity.Z)
		end)
	end
	if (name == "Sliding") then
		sliding = value
		Humanoid.AutoRotate = not value
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input == lastKey and not sprinting  then
		local difference = tick() - lastTick
		if difference <= 1 then
			toggleEquip()
		end
		lastTick = tick()
	end
	if(input.KeyCode == Enum.KeyCode.W or  input.KeyCode == Enum.KeyCode.A  or  input.KeyCode == Enum.KeyCode.S  or  input.KeyCode == Enum.KeyCode.D) then
		lastKey = input
	end
	
	if (input.KeyCode.Name == keybinds.Sprint.Value and Humanoid.MoveDirection.Magnitude ~= 0) then
		toggleEquip()
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if sprinting then
		task.wait(0.1)
		if(Humanoid.MoveDirection.Magnitude == 0) then
			toggleEquip()
		end
	end
end)

Humanoid.StateChanged:Connect(function(o, n)
	if (n == Enum.HumanoidStateType.Jumping) then
		space = false
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		task.wait(jumpCooldown)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end
end)

RunService.Stepped:Connect(function(t, dt)
	if(Humanoid.MoveDirection.Magnitude > 0) then
		local crouch = game.ReplicatedStorage.Events.requestData:InvokeServer("Crouching")
		
		if(sprinting) then
			Humanoid.WalkSpeed = sprintSpeed
		else
			Humanoid.WalkSpeed = baseSpeed
		end
		
		if (crouchWalk.IsPlaying) then
			Humanoid.WalkSpeed = crouchSpeed
		end
		
		if(attacking or stunned) then
			sprintAnimation:Stop()
			equippedAnim:Stop()
			Humanoid.WalkSpeed = baseSpeed
		end
		
		if (blocking ~= 0) then
			Humanoid.WalkSpeed = crouchSpeed
		end
		
		if (stunned) then
			Humanoid.WalkSpeed = stunnedSpeed
		end
		
		if (speedBoost - tick() > 0) then
			Humanoid.WalkSpeed += 10
		end
		
		if (dashing or sliding) then
			Humanoid.WalkSpeed = 0
		end
		
		if (equipped) then
			if (not equippedAnim.IsPlaying) then
				equippedAnim:Play()
			end
		else
			equippedAnim:Stop()
		end
		
		if (sprinting and not sprintAnimation.IsPlaying) then
			sprintAnimation:Play()
		end
		
		if (not crouchWalk.IsPlaying) then
			if (crouch) then
				crouchWalk:Play()
				if (sprinting) then
					sprintAnimation:Stop()
				end
			end
		else 
			if (not crouch) then
				crouchWalk:Stop()
				crouchIdle:Stop()
				if (sprinting) then
					sprintAnimation:Play()
				end
			end
		end
	else
		equippedAnim:Stop()
		sprintAnimation:Stop()
		crouchWalk:Stop()
		if (not crouchIdle.IsPlaying) then
			if (game.ReplicatedStorage.Events.requestData:InvokeServer("Crouching")) then
				crouchIdle:Play()
			end
		else
			if (not game.ReplicatedStorage.Events.requestData:InvokeServer("Crouching")) then
				crouchIdle:Stop()
			end
		end
	end
	
	if (space) then
		local params = OverlapParams.new()
		params.FilterDescendantsInstances = {Character}
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.CollisionGroup = "Players"
		if (holdLoop.Connected) then
			ReplicatedStorage.Events.setValue:FireServer("Actionable", true)
			Humanoid.AutoRotate = true
			holdLoop:Disconnect()
			ledge:Stop()
			HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 50, 0)
			space = false
			return
		else
			local head = workspace:GetPartBoundsInBox(CFrame.new(Character.Torso.Position + HumanoidRootPart.CFrame.LookVector), Vector3.new(1, 0.2, 1), params)
			local above = workspace:GetPartBoundsInBox(CFrame.new(Character.Head.Position + Vector3.new(0, 3, 0) + HumanoidRootPart.CFrame.LookVector), Vector3.new(1, 0.2, 1), params)
			
			if (#head > 0 and #above == 0) then
				if (holdLoop) then
					holdLoop:Disconnect()
				end
				rootJoint.C0 = CFrame.Angles(math.rad(90), math.rad(-180), 0)
				ledge:Play()
				Humanoid.AutoRotate = false
				space = false
				ReplicatedStorage.Events.setValue:FireServer("Actionable", false)
				local save = HumanoidRootPart.CFrame
				holdLoop = RunService.Stepped:Connect(function(t, dt)
					HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					HumanoidRootPart.CFrame = save
				end)
				return
			end
		end
	end
	
	if (humanoidState == Enum.HumanoidStateType.Freefall and HumanoidRootPart.CFrame:VectorToObjectSpace(Humanoid.MoveDirection).Z < 0 and not climbed and space) then
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {Character}
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.CollisionGroup = "Players"
		
		local result = workspace:Raycast(Character.Head.Position, HumanoidRootPart.CFrame.LookVector * 5, params)
		if (result and not climbed) then
			climbed = true
			climbAnim:Play()
			climbLoop = RunService.Stepped:Connect(function(t, dt)
				HumanoidRootPart.CFrame += Vector3.new(0, 40 * dt, 0)
				HumanoidRootPart.AssemblyLinearVelocity = Humanoid.MoveDirection
			end)
			
			task.delay(0.4, function()
				climbAnim:Stop()
				climbLoop:Disconnect()
				HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 30, 0)
			end)
		end
	end
	if (humanoidState == Enum.HumanoidStateType.Landed) then
		climbed = false
		if (climbLoop) then
			climbLoop:Disconnect()
		end
	end
	
	space = false
end)

RunService.Stepped:Connect(function(t, dt)
	slideVector *= 1 -  0.03 ^ (1 / (dt * 60))
	if (sliding) then
		if (slideVector.Magnitude < 0.1) then
			ReplicatedStorage.Events.setValue:FireServer("Sliding", false)
			return
		end
		HumanoidRootPart.CFrame += slideVector
		
		HumanoidRootPart.CFrame = CFrame.Angles(0, math.atan2(slideVector.X, slideVector.Z) + math.rad(180), 0) + HumanoidRootPart.Position
		rootJoint.C0 = CFrame.Angles(rootC0.Rotation.X - math.acos(slideVector.Y), rootC0.Rotation.Y, rootC0.Rotation.Z + math.rad(180))
		
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {Character}
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.CollisionGroup = "Players"

		local result = workspace:Raycast(Character.Torso.Position, Vector3.new(0, -6, 0), params)
		
		if (result) then
			local normal = result.Normal
			
			local frame = CFrame.Angles(0, math.atan2(normal.Z, normal.X), math.acos(normal.Y)):Inverse()
			
			slideVector += frame.RightVector * math.sin(math.acos(normal.Y)) * 0.08
		else
			ReplicatedStorage.Events.setValue:FireServer("Sliding", false)
		end
	else
		slideVector = Humanoid.MoveDirection * 0.8 + Vector3.new(0, -0.2, 0)
		
		if (holdLoop and holdLoop.Connected) then
			return
		end
		
		local MoveDirection = HumanoidRootPart.CFrame:VectorToObjectSpace(Humanoid.MoveDirection)
		tilt = tilt:Lerp(CFrame.Angles(math.rad(-MoveDirection.Z) * tiltAngle, math.rad(-MoveDirection.X) * tiltAngle, 0), 0.2 ^ (1 / (dt * 60)))
		rootJoint.C0 = rootC0 * tilt
	end
end)

climbAnim.KeyframeReached:Connect(function(name)
	if (name == "Sound") then
		local sound = ReplicatedFirst.Sounds.Movement.Climb:Clone()
		sound.Parent = HumanoidRootPart
		sound:Play()
	end
end)