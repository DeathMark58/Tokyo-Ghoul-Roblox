local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local keybinds = script.Parent:WaitForChild("Keybinds")

local Players = game:GetService("Players")

local player = Players.LocalPlayer

local character, humanoid, humanoidRootPart


character = player.Character or player.CharacterAdded:Wait()
humanoid = character:WaitForChild("Humanoid")
humanoidRootPart = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(c)
	character = c
	humanoid = character:WaitForChild("Humanoid")
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

UserInputService.InputBegan:Connect(function(i, g)
	if (not g) then
		local kb = {}
		for i, v in pairs(keybinds:GetChildren()) do
			kb[v.Name] = v.Value
		end
		if (i.KeyCode == Enum.KeyCode.Unknown) then
			ReplicatedStorage.Events.holdEvent:FireServer(i.UserInputType, kb, true)
		else
			ReplicatedStorage.Events.holdEvent:FireServer(i.KeyCode.Name, kb, true)
		end
	end
end)

UserInputService.InputEnded:Connect(function(i, g)
	if (not g) then
		local kb = {}
		for i, v in pairs(keybinds:GetChildren()) do
			kb[v.Name] = v.Value
		end

		ReplicatedStorage.Events.holdEvent:FireServer(i.KeyCode.Name, kb, false)
	end
end)