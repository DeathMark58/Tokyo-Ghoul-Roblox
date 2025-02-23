local serverStorage = game:GetService("ServerStorage")
local events = game:GetService("ReplicatedStorage").Events
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local changeEvent = ReplicatedStorage.Events.valueChanged

local function setupFolder(player)
	local folder = Instance.new("Folder")
	folder.Name = player.UserId
	folder.Parent = serverStorage
	
	for i,v in pairs(script.Default:GetChildren()) do
		local val = v:Clone()
		val.Parent = folder
		val.Value = v.Value

		local name = v.Name
		
		val.Changed:Connect(function(value)
			changeEvent:FireClient(player, name, value)
			
			local character = player.Character
		end)
	end
end

game:GetService('Players').PlayerAdded:Connect(function(player)
	setupFolder(player)
	
	player.CharacterAdded:Connect(function(character)
		if (serverStorage:FindFirstChild(player.UserId)) then
			for i, v in pairs(script.Default:GetChildren()) do
				if (v.Name ~= "Weapon") then
					serverStorage[player.UserId][v.Name].Value = v.Value
				end
			end
		else
			setupFolder(player)
		end
	end)
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
	serverStorage[player.UserId]:Destroy()
end)