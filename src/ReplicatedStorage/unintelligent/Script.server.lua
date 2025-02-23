local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local PathFindingService = game:GetService("PathfindingService")

local combat = ReplicatedStorage.Events.npcCombat
local hold = ReplicatedStorage.Events.npcHold

local radiusHitbox = require(ServerScriptService.RadiusHitbox)
local stuff = require(ServerScriptService.Stuff)

local target = nil

local character = script.Parent
local humanoid = character.Humanoid

local values = character:WaitForChild("Values")

values.Equipped.Value = true

local keybinds = {
	["Blocking"] = "F",
	["Carry"] = "V",
	["Critical"] = "R",
	["Crouch"] = "C",
	["Execute"] = "B",
	["Roll"] = "Q",
	["Sprint"] = "Left Control",
	["Vent"] = "G",
}

local aerialDebounce = true

local parryList = {}

local attackingDebounce = 0
local feintDebounce = 0

local getCooldown = ReplicatedStorage.Events.getCooldown

local moveback = false

local distance = math.huge

local canPathfind = true

task.wait(1)

RunService.Heartbeat:Connect(function(dt)
	local characterList = radiusHitbox.GetCharacterList()
	distance = math.huge
	for i, v in pairs(characterList) do
		if (v and v ~= character and v:FindFirstChild("Humanoid") and v.PrimaryPart and (v.PrimaryPart.Position - character.PrimaryPart.Position).Magnitude < distance and v.Humanoid.Health ~= 0) then
			target = v
			distance = (v.PrimaryPart.Position - character.PrimaryPart.Position).Magnitude
		end
	end
	
	if target and not values.RagdollTrigger.Value and values.CarryStatus.Value == 0 then
		local hitboxes = radiusHitbox.GetHitboxes()
		
		for i, v in pairs(hitboxes) do
			if (v.Ignore ~= character and (v.Ignore == target or v:check(character) and v.Windup ~= 0)) then
				if (not table.find(parryList, (v.Start + v.Windup))) then
					table.insert(parryList, v.Start + v.Windup)
					attackingDebounce = tick() + 0.5
					task.delay((v.Start + v.Windup) - tick() - 0.1, function()
						local chance = 1
						if (values.Actionable.Value) then
							chance = 0.9
						else
							chance = 0.7
						end
						if (math.random() < chance - (target.PrimaryPart.AssemblyLinearVelocity * Vector3.new(1, 0, 1)).Magnitude * 0.01) then
							hold:Fire(character, "F", keybinds, true)
							task.wait(0.3)
							hold:Fire(character, "F", keybinds, false)

							if (not getCooldown:Invoke(character, "Parry") and math.random() < 0.3) then
								combat:Fire(character, "Q", keybinds)
							end
							
							if (getCooldown:Invoke(character, "Parry") and math.random() < 0.1) then
								attackingDebounce = tick() + 1
								task.delay(0.5, function()
									combat:Fire(character, "R", keybinds)
								end)
							end
						end
						
						if (math.random() < 0.1) then
							combat:Fire(character, "Q", keybinds)
							moveback = true
						end
					end)
				end
			end
		end
		
		if (stuff.GetValues(target).Knocked.Value ~= 0) then
			if (distance < 10) then
				combat:Fire(character, "B", keybinds)
			end
		end
	
		if distance > 20 then
			moveback = false
			canPathfind = true
		else
			
			if distance > 15 and aerialDebounce then
				aerialDebounce = false
				task.delay(3, function()
					aerialDebounce = true
				end)
				humanoid.Jump = true
				task.wait(0.1)
				combat:Fire(character, Enum.UserInputType.MouseButton1, keybinds)
				return
			end
			
			if distance >= 7 then
				canPathfind = true
			end


			if distance < 7 then
				if (distance < 4) then
					humanoid:Move(-character.HumanoidRootPart.CFrame.LookVector)
				else
					humanoid:MoveTo(character.HumanoidRootPart.Position)
				end
			end
			
			if distance < 7 and attackingDebounce < tick() and values.Actionable.Value then
				canPathfind = false
				if (character.HumanoidRootPart.CFrame ~= target.PrimaryPart.CFrame) then
					character.HumanoidRootPart.CFrame = CFrame.lookAt(character.HumanoidRootPart.Position * Vector3.new(1, 0 ,1), target.PrimaryPart.Position * Vector3.new(1, 0 ,1)) + character.HumanoidRootPart.Position * Vector3.new(0, 1, 0)
				end
				if (math.random() < 0.1	) then
					hold:Fire(character, "C", keybinds, true)
					attackingDebounce = tick() + 0.5
					task.wait(0.1)
					combat:Fire(character, Enum.UserInputType.MouseButton1, keybinds)
					return
				end
				
				attackingDebounce = tick() + 0.1
				
				combat:Fire(character, Enum.UserInputType.MouseButton1, keybinds)
				if (math.random() < 0.2 and tick() > feintDebounce) then
					feintDebounce = tick() + 2
					attackingDebounce = tick() + 0.3
					task.wait(0.2)
					hold:Fire(character, Enum.UserInputType.MouseButton2, keybinds, true)
				end
				return
			end
		end
	end
end)

while true do
	if (target and canPathfind) then
		local path = PathFindingService:CreatePath({
			AgentRadius = 2
		})
		path:ComputeAsync(character.HumanoidRootPart.Position, target.PrimaryPart.Position)
		local waypoints = path:GetWaypoints()
		if (#waypoints > 1) then
			humanoid:MoveTo(waypoints[2].Position)
			humanoid.MoveToFinished:Wait()
		else 
			RunService.Heartbeat:Wait()
		end
	else
		RunService.Heartbeat:Wait()
	end
end