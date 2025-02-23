local character = script.Parent
local humanoid = character.Humanoid

local healthTick = 0
local oldHealth = humanoid.Health

humanoid.HealthChanged:Connect(function(health)
	if (health - oldHealth > 0) then
		return
	end
	healthTick = tick()
	oldHealth = humanoid.Health
end)

local count = 0;

game:GetService("RunService").Stepped:Connect(function(t, dt)
	count += dt
	if (humanoid.Health < humanoid.MaxHealth and tick() > healthTick + 5) then
		humanoid.Health = math.min(humanoid.Health + 1 * dt, humanoid.MaxHealth)
	end

	if(character:WaitForChild("HumanoidRootPart").Position.Y < -150*2) then
		character:WaitForChild("HumanoidRootPart").Anchored = true
		humanoid.Health = 0
	end
end)

