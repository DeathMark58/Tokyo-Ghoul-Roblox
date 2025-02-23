local values = script.Parent:WaitForChild("Values")
values.Equipped.Value = true

local keybinds = script.Parent:WaitForChild("Keybinds")

local kb = {}
for i, v in pairs(keybinds:GetChildren()) do
	kb[v.Name] = v.Value
end

local count = 0

game:GetService("RunService").Heartbeat:Connect(function(dt)
	count += dt

	if(count > 0.05) then
		values.Blocking.Value = 0
		game.ReplicatedStorage.Events.npcCombat:Fire(script.Parent, Enum.UserInputType.MouseButton1,kb)
		values.Blocking.Value = 1
	end
end)
