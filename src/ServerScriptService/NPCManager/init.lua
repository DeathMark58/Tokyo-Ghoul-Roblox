--!strict

local module = {}

local characterList = {}

function module.Add(character : Model)
	table.insert(characterList, character)
	if(not character:GetAttribute("Prop")) then
		local s = script.R6NPCRagdoll:Clone()
		s.Enabled = true
		s.Parent = character

		for _, child in pairs(character:GetDescendants()) do
			if (child:IsA("BasePart")) then
				child.CollisionGroup = "NPCS"
			end
		end
	end

	local manager = script.Parent.PlayerSetup["Value Handler"]:Clone()

	manager.Parent = character
	manager.Enabled = true

	local values = game.ServerScriptService.PlayerValues.Default:Clone()

	values.Name = "Values"
	values.Parent = character
	
	game.ReplicatedStorage.Events.npcAdded:FireAllClients(characterList)
end

function module.Remove(character : Model)
	local index = table.find(characterList, character, 1)
	if (index) then
		table.remove(characterList, index)
	end
	game.ReplicatedStorage.Events.npcAdded:FireAllClients(characterList)
end

function module.GetList()
	return characterList
end

return module