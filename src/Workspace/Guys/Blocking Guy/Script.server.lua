local values = script.Parent:WaitForChild("Values")

values.Blocking.Value = 2

script.Parent.Humanoid:LoadAnimation(game:GetService("ReplicatedFirst").Animations.Sword.Block):Play()

values.Stun.Changed:Connect(function(value)
	if (value == 0 and values.Blocking.Value ~= 2) then
		values.Blocking.Value = 2
	end
end)