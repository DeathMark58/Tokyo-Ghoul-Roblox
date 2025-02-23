local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local list = {}

local admins = {770672419,146206061}

Players.PlayerAdded:Connect(function(player)
	list[player] = player.Chatted:Connect(function(message)
		local arguments = string.split(message," ")
		local prefix = "!"
		if (arguments[1] == prefix.."weapon") then
			if (#arguments < 2) then
				return
			end
			local weapon = ""
			for i = 2, #arguments, 1 do
				weapon = weapon..arguments[i]
				if (i ~= #arguments) then
					weapon = weapon.." "
				end
			end
			ServerStorage[player.UserId].Weapon.Value = weapon
			player.Character.Humanoid.Health = 0
		end
		
		if (not table.find(admins, player.UserId)) then
			return
		end
		
		if (arguments[1] == prefix.."tp") then
			if (#arguments < 2) then
				return
			end
			
			local person = arguments[2]
			if (person == "me") then
				person = player.Character
			else
				person = workspace:FindFirstChild(arguments[2], true)
			end
			
			person.PrimaryPart.CFrame = workspace:FindFirstChild(arguments[3], true).PrimaryPart.CFrame
		end
		
		if (arguments[1] == prefix.."health") then
			local person = arguments[2]
			if (person == "me") then
				person = player.Character
			else
				person = workspace:FindFirstChild(arguments[2], true)
			end
			
			person.Humanoid.Health = arguments[3]
		end

		if (arguments[1] == prefix.."value") then
			local person = arguments[2]
			if (person == "me") then
				person = player.Character
			else
				person = workspace:FindFirstChild(arguments[2])
			end
			
			local value = require(game.ServerScriptService.Stuff).GetValues(person)[arguments[3]]
			
			if (value:IsA("BoolValue")) then
				value.Value = (arguments[4] == "true")
			else
				value.Value = arguments[4]
			end
		end

		if (arguments[1] == prefix.."spawn") then
			local name = ""
			for i = 2, #arguments, 1 do
				name = name..arguments[i]
			end
			local instance = game.ReplicatedStorage[name]:Clone()
			require(game.ServerScriptService.NPCManager).Add(instance)
			require(game.ServerScriptService.RadiusHitbox).AddCharacter(instance)
			instance.PrimaryPart.CFrame = player.Character.HumanoidRootPart.CFrame
			instance.Parent = workspace
		end

		if (arguments[1] == prefix.."mantra") then
			local name = ""
			for i = 2, #arguments, 1 do
				name = name..arguments[i]
				if i < #arguments then
					name = name.." "
				end
			end
			local mantra = game.ReplicatedStorage.Mantras[name]:Clone()
			mantra.Parent = player.Backpack
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	if (list[player]) then
		list[player]:Disconnect()
	end
end)