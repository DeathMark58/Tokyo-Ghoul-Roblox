require(game:GetService("ServerScriptService").RadiusHitbox).AddCharacter(script.Parent)
require(game.ServerScriptService.NPCManager).Add(script.Parent)

local stuff = require(game.ServerScriptService.Stuff)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local roar = script.Parent.Humanoid.Animator:LoadAnimation(game.ReplicatedFirst.Animations.Boss.Roar)
roar:Play(0,1,1.35)

task.delay(2.5,function()
	stuff.SpawnParticle("Roar",script.Parent.Model.Headmodel.Mouth.Attachment,1.5)
end)

roar.Stopped:Wait()

wait(1)


local ps = game:GetService("PathfindingService")
local hitboxes = require(game.ServerScriptService.RadiusHitbox)
local char = script.Parent

local minDist = 35
local maxDist = 500

local target
local inRange = false

local turnPoint = game.ReplicatedStorage.Particles.Point:Clone()
turnPoint.Name = "TurnPoint"
turnPoint.Transparency = 1
turnPoint.Parent = script.Parent

char.HumanoidRootPart.AlignOrientation.Enabled = true
char.HumanoidRootPart.AlignOrientation.Attachment0 = char.HumanoidRootPart.RootAttachment
char.HumanoidRootPart.AlignOrientation.Attachment1 = turnPoint.Attachment

local attacking = false
local attacks = {"Fire","Kick","TripleStomp","OneStomp", "IceSlam"--[["Kick","Fire","TripleStomp"]]}
local lastAttack = tick()
local attackCd = 1.25


local function getPath(targetChar)
	local path = ps:CreatePath(
		{AgentRadius = 1, AgentHeight = 60, AgentCanJump = false}
	)
	path:ComputeAsync(char.HumanoidRootPart.Position, targetChar.HumanoidRootPart.Position)
	return path	
end

local function findAggro()
	local closestChar
	local closestDist = math.huge
	for i,v	in pairs (workspace:GetDescendants()) do
		if(v:IsA("Humanoid") and v.Parent.Parent.Name ~= "PrimalYeti" and v.Parent ~= script.Parent) then
			if((char.HumanoidRootPart.Position - v.Parent.HumanoidRootPart.Position).Magnitude < closestDist and (char.HumanoidRootPart.Position - v.Parent.HumanoidRootPart.Position).Magnitude < maxDist) then
				closestChar = v.Parent
				closestDist = (char.HumanoidRootPart.Position - v.Parent.HumanoidRootPart.Position).Magnitude
			end
		end
	end

	if closestChar then
		return closestChar
	else
		return nil
	end
end


local lastJump = tick()
target = findAggro()

char.Humanoid.Running:Connect(function(speed)
	if(speed>0) then
		task.delay(0.05,function()
			for i,v in pairs(char.Humanoid.Animator:GetPlayingAnimationTracks()) do
				lastAttack = tick()
				if(v.Name == "walk") then
					v.KeyframeReached:Connect(function(keyframeName)
						char.HumanoidRootPart.Footsteps["footstep0"..math.random(1,3)]:Play()
					end)
				end
			end
		end)
	end
end)


game:GetService("RunService").Heartbeat:Connect(function()
	local dist = (char.HumanoidRootPart.Position * Vector3.new(1,0,1) - target.HumanoidRootPart.Position * Vector3.new(1,0,1)).Magnitude
	if(dist < minDist and tick() - lastAttack > attackCd) then
		char.Humanoid.currentAttack.Value = attacks[math.random(1,table.getn(attacks))]
		lastAttack = tick()
	elseif(dist < minDist+5 and tick() - lastAttack>2) then
		char.Humanoid.currentAttack.Value = "Fire"	
		lastAttack = tick()
	end
	
	if(char.Humanoid.Health > 0) then
		target = findAggro()

		if(target) then
			turnPoint.CFrame = CFrame.new(char.HumanoidRootPart.Position + CFrame.new(char.HumanoidRootPart.Position,target.PrimaryPart.CFrame.Position).LookVector*-5)
			local path = getPath(target)
			for i, wp in pairs (path:GetWaypoints()) do
				if(dist > minDist) then
					char.Humanoid:MoveTo(wp.Position)
				end
			end
		end

		if(char.Humanoid.Health/char.Humanoid.MaxHealth < 0.06) then
			char.Humanoid.WalkSpeed=23
			attackCd=0.25
		end


		if(char.Humanoid.Health <= 0.01) then
			char.Humanoid.Health = 0
		end
	end
end)

char.Humanoid.currentAttack.Changed:Connect(function(attackName)
	local attackTrack = char.Humanoid.Animator:LoadAnimation(game.ReplicatedFirst.Animations.Boss[attackName])
	attackTrack.Priority = Enum.AnimationPriority.Action4
	attackTrack:Play(0.25,1,1.5)

	local points = {}
	if(attackName == "Fire") then

		stuff.PlaySound("Boss, MinigunStart", char.HumanoidRootPart, 0)

		for i,v in pairs (game.ReplicatedStorage.Particles.MinigunCharge:GetChildren()) do
			local particle = v:Clone()
			particle.Parent = char.Model["Gatling Gun"].Attachment
			game:GetService("Debris"):AddItem(particle,2)
		end

		for i = 1, 30 do

			local rayDirection = (char.HumanoidRootPart.CFrame.LookVector) * math.random(45,255) + Vector3.new(0,-155,0) + (char.HumanoidRootPart.CFrame.RightVector * math.random(-125,125))

			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = {script.Parent}
			raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
			raycastParams.IgnoreWater = true
			raycastParams.CollisionGroup = "Players"

			local raycastResult = workspace:Raycast(char.HumanoidRootPart.Position, rayDirection, raycastParams)

			if(raycastResult) then
				table.insert(points,raycastResult.Position)
			end
		end

	end
	if (attackName == "IceSlam") then
		ReplicatedStorage.Events.castMantra:Fire(char, "IceSlam")
	end

	if(attackName == "Kick") then
		stuff.PlaySound("Boss, HeavySwing", char["Left Leg"], 0)
	end

	attackTrack.KeyframeReached:Connect(function(keyframeName)
		lastAttack = tick()

		if(keyframeName == "hit") then
			if(attackName == "Fire") then
				for i,v in pairs(points) do
					if(i==1) then
						stuff.PlaySound("Boss, MinigunFire", char.HumanoidRootPart, 0)
					end
					task.delay(i*0.025,function()
						local bullet = game.ServerStorage.Assets.Bullet:Clone()
						bullet.Position = char.Model["Gatling Gun"].Attachment.WorldPosition
						bullet.CFrame = CFrame.new(bullet.Position,v)
						bullet.Parent = workspace
						game:GetService("TweenService"):Create(bullet,TweenInfo.new(.05),{Position = v}):Play()
						game:GetService("Debris"):AddItem(bullet,.15)
						task.delay(0.10,function()
							local hbox = hitboxes.new(bullet.Position,25,char)
							hbox:start()

							hbox.Hit:Connect(function(part)
								local result = stuff.Attack(part, 1, 4, script.Parent, true)
								if (result == "Hit" or result == "Knocked") then
									stuff.PlaySound("Slash", part, 0.1)
								end
							end)

							task.delay(0.25,function()
								hbox:stop()
							end)
						end)
					end)
				end
			else

				stuff.PlaySound("Boss, Vine boom sound effect", char["Left Leg"], 0)

				local hbox = hitboxes.new(char.HumanoidRootPart.Hitbox.WorldPosition,35,char)
				hbox:start()

				hbox.Hit:Connect(function(part)
					local result
					print(attackName)
					if (attackName == "Kick") then
						result = stuff.Attack(part, 20, 150, script.Parent, false)
					elseif (attackName == "TripleStomp" or attackName == "OneStomp") then
						result = stuff.Attack(part, 10, 80, script.Parent, true)
					end
					if (attackName == "Kick" and (result == "Hit" or result == "Knocked" or result == "Block Break")) then
						stuff.GetValues(part.Parent).RagdollTrigger.Value = true
						part.Parent.HumanoidRootPart:SetNetworkOwner(nil)
						part.Parent.HumanoidRootPart:ApplyImpulse(char.HumanoidRootPart.CFrame.LookVector * 1000 + Vector3.new(0, 1500, 0))
						task.delay(2, function()
							if (stuff.GetValues(part.Parent).Knocked.Value == 0) then
								stuff.GetValues(part.Parent).RagdollTrigger.Value = false
							end
							part.Parent.HumanoidRootPart:SetNetworkOwner(game.Players:GetPlayerFromCharacter(part.Parent))
						end)
					end
					if (result == "Hit" or result == "Knocked") then
						if (stuff.GetValues(part.Parent).Knocked.Value ~= 0) then
							if(attackName == "TripleStomp" or attackName == "OneStomp") then
								part.Parent.Humanoid.Health = 0
							end
						end
						if(attackName == "Kick") then
							stuff.PlaySound("Kick", part, 0.1)
						else
							stuff.PlaySound("Slash", part, 0.1)
						end
					end
				end)

				task.delay(0.25,function()
					hbox:stop()
				end)
			end
		end
	end)
end)
