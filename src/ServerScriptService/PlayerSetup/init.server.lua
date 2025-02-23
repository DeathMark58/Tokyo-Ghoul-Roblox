local Players = game:GetService("Players")
local ts = game:GetService("TweenService")
local hitboxes = require(game:GetService("ServerScriptService").RadiusHitbox)

local PhysicsService = game:GetService("PhysicsService")
local module = require(script.ModuleScript)
local ragParts = script.RagdollParts:GetChildren()
local r6Client = script.R6RagdollClient

local MarketPlaceService = game:GetService("MarketplaceService")

for i, v in pairs(workspace:GetDescendants()) do
	if (v.ClassName == "Humanoid") then
		if (game:GetService("Players"):GetPlayerFromCharacter(v.Parent) == nil) then
			require(script.Parent.NPCManager)
			.Add(v.Parent)
		end
	end
end

local function spawnPlayer(plr, yeti)	
	if(yeti) then
		local PlayerAvatar = game:GetService("ServerStorage").StarterCharacter:Clone()
		PlayerAvatar.Parent = game:GetService("StarterPlayer")
		PlayerAvatar.Name = "StarterCharacter"
		plr:LoadCharacter() 
		PlayerAvatar:Destroy()
		plr.Character:WaitForChild("Head").Transparency = 0.99
	else
		plr:LoadCharacter()
	end
	
	local char = plr.Character
	
	script.Dialogue:Clone().Parent = plr
	
	local weaponName = game.ServerStorage:WaitForChild(plr.UserId).Weapon.Value
	local weapon = game.ReplicatedStorage.Weapons[weaponName]:Clone()
	
	local model = game.ReplicatedStorage.WeaponModels[weaponName]:Clone()
	model.Name = "weaponModel"
	model.Parent = char
	
	model.Unequip.Part0 = char:FindFirstChild("Torso")
	model.Unequip.Part1 = model.Handle
	model.Unequip.Enabled = true
	
	--[[
	local m6d = Instance.new("Motor6D")
	m6d.Parent = char["Right Arm"]
	m6d.Name = "RightGrip"
	m6d.Part0 = char["Right Arm"]
	m6d.Part1 = char.weaponModel.Handle
	m6d.C0 = CFrame.new(0,-1,0) * CFrame.Angles(math.rad(-90), 0, 0)
	m6d.C1 = CFrame.new(0,0,-1.75) * CFrame.Angles(math.rad(90), 0, 0)
	m6d.Enabled = false
	-]]
	
	local m6d = game:GetService("ReplicatedStorage").Grips[weaponName]:Clone()
	m6d.Name = "RightGrip"
	m6d.Parent = char["Right Arm"]
	m6d.Part0 = char["Right Arm"]
	m6d.Part1 = char.weaponModel.Handle
	m6d.Enabled = false
	
	if(yeti)then
		m6d.Parent = char.Model.LowerRArm
		m6d.Part0 = m6d.Parent
		m6d.C0 = CFrame.new(-1,0,1) * CFrame.Angles(math.rad(90), 0, 0)

	end
	
	local humanoid = char.Humanoid
	char.Head.Size = Vector3.new(1, 1, 1)
	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false

	local clones = {}
	for _, v in ipairs(ragParts) do
		clones[v.Name] = v:Clone()
	end
	
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency=1
	highlight.OutlineTransparency=1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = char

	local folder1 = Instance.new("Folder")
	folder1.Name = "RagdollConstraints"
	for _, v in pairs(clones) do
		if v:IsA("Attachment") then
			v.Parent = char[v:GetAttribute("Parent")]
		elseif v:IsA("BallSocketConstraint") then
			v.Attachment0 = clones[v:GetAttribute("0")]
			v.Attachment1 = clones[v:GetAttribute("1")]
			v.Parent = folder1
		end
	end
	folder1.Parent = char

	local folder2 = Instance.new("Folder")
	folder2.Name = "Motors"
	local value
	for _, v in ipairs(char.Torso:GetChildren()) do
		if v:IsA("Motor6D") then
			value = Instance.new("ObjectValue")
			value.Value = v
			value.Parent = folder2
		end
	end
	folder2.Parent = folder1

	-- Ragdoll trigger
	local trigger = game.ServerStorage:WaitForChild(plr.UserId).RagdollTrigger

	trigger.Changed:Connect(function(bool)
		if bool then
			module:Ragdoll(char)
		else
			module:Unragdoll(char)
		end
	end)

	r6Client:Clone().Parent = char
	
	local handler = script["Value Handler"]:Clone()
	handler.Parent = char
	handler.Enabled = true
	
	for i, v in pairs(char:GetChildren()) do
		if (v:IsA("BasePart")) then
			v.CollisionGroup = "Players"
		end
	end
	
	task.wait(0.1)
	
	hitboxes.AddCharacter(plr.Character)

	weapon.Parent = plr.Backpack
	
	--local mantra = game:GetService("ReplicatedStorage").Mantras["big yell"]:Clone()
	--mantra.Parent = plr.Backpack
	
	if (MarketPlaceService:UserOwnsGamePassAsync(plr.UserId, 129128227) and not yeti) then
		local fruit = game:GetService("ServerStorage").Items["Yeti Fruit"]:Clone()
		fruit.Parent = plr.Backpack
	end
	
	weapon.init:Fire()
	
	game.ReplicatedStorage.Events.npcAdded:FireClient(plr,require(script.Parent.NPCManager).GetList())
	
	char:WaitForChild("Humanoid").BreakJointsOnDeath = false
	char:WaitForChild("Humanoid").HealthChanged:Connect(function(old)
		if (old ~= 0 and char.Humanoid.Health <= 0) then
			local sound = game:GetService("ReplicatedFirst").Sounds.Death:Clone()
			sound.Parent = char.HumanoidRootPart
			sound:Play()
			game:GetService("Debris"):AddItem(sound, sound.TimeLength)
			module:Ragdoll(char)
			wait(1)
			for _, v in pairs(char:GetDescendants()) do
				if(v:IsA("BasePart")) then	
					local particle = game.ReplicatedStorage.Particles.Death.White:Clone()
					local particle2 = game.ReplicatedStorage.Particles.Death.Dust:Clone()
					particle.Rate = 55
					ts:Create(particle,TweenInfo.new(4,Enum.EasingStyle.Circular,Enum.EasingDirection.InOut),{Rate = 0}):Play()
					ts:Create(particle2,TweenInfo.new(4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Rate = 0}):Play()
					ts:Create(v,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Color = Color3.fromRGB(255,255,255)}):Play()
					ts:Create(v,TweenInfo.new(3,Enum.EasingStyle.Circular,Enum.EasingDirection.Out),{Transparency = 1}):Play()
					particle.Parent = v
					particle2.Parent = v
				elseif (v:IsA("MeshPart") or v:IsA("Part") or v:IsA("Decal")) then
					ts:Create(v,TweenInfo.new(3,Enum.EasingStyle.Circular,Enum.EasingDirection.Out),{Transparency = 1}):Play()
					--v:Destroy()
				end
			end
		end
	end)
	
end

local function playerJoin(plr)
	local weapon = Instance.new("StringValue")
	weapon.Name = "weapon"
	weapon.Value = "Sword"
	weapon.Parent = plr

	print("spawning")
	spawnPlayer(plr,false)
end

game.ReplicatedStorage.Events.eatFruit.Event:Connect(function(character)
	character:FindFirstChild("Humanoid").Health = 0
	local player = Players:GetPlayerFromCharacter(character)
	local cframe = character:FindFirstChild("HumanoidRootPart").CFrame
	local velocity = character:FindFirstChild("HumanoidRootPart").Velocity
	spawnPlayer(Players:GetPlayerFromCharacter(character),true)
	player.Character:WaitForChild("HumanoidRootPart").CFrame = cframe + Vector3.new(0,character:FindFirstChild("Humanoid").HipHeight,0)
	player.Character:WaitForChild("HumanoidRootPart").Velocity = velocity
end)



Players.PlayerAdded:Connect(playerJoin)

game:GetService("Players").PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(character)
		local Humanoid = character:WaitForChild("Humanoid")
		local debounce = true
		character:WaitForChild("Humanoid").Died:Connect(function()
			print(plr.Name.." died")
			if (debounce) then
				debounce = false
				hitboxes.RemoveCharacter(plr.Character)
				task.delay(6, function()
					spawnPlayer(plr)
				end)
				local sound = game:GetService("ReplicatedFirst").Sounds.Death:Clone()
				sound.Parent = character.HumanoidRootPart
				sound:Play()
				game:GetService("Debris"):AddItem(sound, sound.TimeLength)
				module:Ragdoll(character)
				wait(1)
				for _, v in pairs(character:GetDescendants()) do
					if(v:IsA("BasePart")) then	
						local particle = game.ReplicatedStorage.Particles.Death.White:Clone()
						local particle2 = game.ReplicatedStorage.Particles.Death.Dust:Clone()
						particle.Rate = 55
						ts:Create(particle,TweenInfo.new(4,Enum.EasingStyle.Circular,Enum.EasingDirection.InOut),{Rate = 0}):Play()
						ts:Create(particle2,TweenInfo.new(4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Rate = 0}):Play()
						ts:Create(v,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{Color = Color3.fromRGB(255,255,255)}):Play()
						ts:Create(v,TweenInfo.new(3,Enum.EasingStyle.Circular,Enum.EasingDirection.Out),{Transparency = 1}):Play()
						particle.Parent = v
						particle2.Parent = v
					elseif (v:IsA("MeshPart") or v:IsA("Part") or v:IsA("Decal")) then
						ts:Create(v,TweenInfo.new(3,Enum.EasingStyle.Circular,Enum.EasingDirection.Out),{Transparency = 1}):Play()
						--v:Destroy()
					end
				end
			end
		end)
	end)
end)

