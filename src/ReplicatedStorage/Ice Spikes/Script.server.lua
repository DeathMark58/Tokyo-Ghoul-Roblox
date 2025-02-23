local model = script.Parent

local hitbox = require(game:GetService("ServerScriptService").RadiusHitbox).new(model.PrimaryPart.Position, 20, nil, 0, false)

local stuff = require(game:GetService("ServerScriptService").Stuff)

function resizeModel(model,a)
	local base = model.PrimaryPart.Position
	for _,part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Position = base:Lerp(part.Position,a)
			part.Size *= a
		end
	end
end

local size = 0.1

hitbox.Hit:Connect(function(part)
	print(part)
	local character = part.Parent
	local values = stuff.GetValues(character)
	
	if (character:GetAttribute("Type") == "Boss") then
		return
	end
	
	local result = stuff.Attack(part, 10, 100, workspace.PrimalYeti:FindFirstChild("YetiBoss"), false)
	if (result == "Hit" or result == "Knocked") then
		character.HumanoidRootPart:SetNetworkOwner(nil)
		character.HumanoidRootPart:ApplyImpulse(Vector3.new(0, 300, 0))
		values.RagdollTrigger.Value = true
		
		task.delay(2, function()
			if (values.Knocked.Value == 0) then
				values.RagdollTrigger.Value = false
				character.HumanoidRootPart:SetNetworkOwner(game.Players:GetPlayerFromCharacter(character))
			end
		end)
	end
end)

hitbox:start()

local increase
increase = game:GetService("RunService").Heartbeat:Connect(function()
	hitbox:setPosition(model.PrimaryPart.Position)
	model:PivotTo(model.PrimaryPart.CFrame)
	resizeModel(model, size + 1)
	size *= 0.8
	if (size - 0.01 <= 0) then
		increase:Disconnect()
		hitbox:stop()
	end
end)

wait(3)

size = 0.05

local decrease
decrease = game:GetService("RunService").Heartbeat:Connect(function()
	resizeModel(model, 1 - size)
	size *= 1.1
	if (size - 0.01 >= 0.2) then
		decrease:Disconnect()
		model:Destroy()
	end
end)