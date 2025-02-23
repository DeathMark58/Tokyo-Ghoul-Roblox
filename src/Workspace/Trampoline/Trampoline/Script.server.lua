local defaultJumpPower = game:GetService("StarterPlayer").CharacterJumpPower
local debris = game:GetService("Debris")

script.Parent.Touched:connect(function(obj)
	local humanoid = obj.Parent:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		if(game:GetService("Players"):GetPlayerFromCharacter(humanoid.Parent)) then
			game:GetService("ServerStorage"):FindFirstChild(game:GetService("Players"):GetPlayerFromCharacter(humanoid.Parent).UserId):FindFirstChild("RagdollTrigger").Value = true
			task.delay(4, function()
				game:GetService("ServerStorage")[game:GetService("Players"):GetPlayerFromCharacter(humanoid.Parent).UserId].RagdollTrigger.Value = false
			end)
		else
			humanoid.Parent.Values.RagdollTrigger.Value = true
			task.delay(4, function()
				humanoid.Parent.Values.RagdollTrigger.Value = false
			end)
		end
		local bv = Instance.new("BodyVelocity",humanoid.Parent.HumanoidRootPart)
		bv.Velocity = Vector3.new(0,math.random(500,1000),0)
		bv.P = math.huge/100
		bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
		debris:AddItem(bv,0.08)
	end
end)