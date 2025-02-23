local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local rs = game:GetService("ReplicatedStorage")

local Players = game:GetService("Players")

local player = Players.LocalPlayer

local character, humanoid, humanoidRootPart

player.CharacterAdded:Connect(function(c)
	character = c
	humanoid = character:WaitForChild("Humanoid")
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

local inputs = {}

local rolling = false

local keybinds = player.PlayerScripts:WaitForChild("Keybinds")

UserInputService.inputBegan:Connect(function(i, g)
	if (not g) then
		table.insert(inputs, {i, 0.3}) 
	end
end)

local actionable = true

rs.Events.valueChanged.OnClientEvent:Connect(function(name, value)
	if (name == "Actionable") then
		actionable = value
	end
end)

RunService.Stepped:Connect(function(t, dt)
	for i, v in pairs(inputs) do
		inputs[i][2] -= dt
		if (inputs[i][2] < 0) then
			table.remove(inputs, i)
		end
	end
	if (#inputs > 0 and actionable and inputs[1] ~= nil and humanoid:GetState() ~= Enum.HumanoidStateType.Dead) then
		local i = inputs[1][1]
		table.remove(inputs, 1)
		local kb = {}
		for i, v in pairs(keybinds:GetChildren()) do
			kb[v.Name] = v.Value
		end

		if (i.KeyCode == Enum.KeyCode.Unknown) then
			rs.Events.combatEvent:FireServer(i.UserInputType, kb)
		else
			rs.Events.combatEvent:FireServer(i.KeyCode.Name, kb)
		end
	end
end)