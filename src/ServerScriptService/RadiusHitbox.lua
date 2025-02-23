--!strict

local visualize = false

local Hitboxes = {}
Hitboxes.__index = Hitboxes

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local CharacterList = {}

local hitboxList = {}

for i, v in pairs(Players:GetPlayers()) do
	table.insert(CharacterList, v.Character)
end

for i, v in pairs(workspace:GetDescendants()) do
	if (v.ClassName == "Humanoid") then
		table.insert(CharacterList, v.Parent)
	end
end

local visualizers = Instance.new("Folder")
visualizers.Name = "Visualizers"
visualizers.Parent = workspace

local Parameters = OverlapParams.new()

function Hitboxes.new(position : Vector3, radius : number, ignore : Model, windup : number)
	local self = setmetatable({}, Hitboxes)
	
	self._HitEvent = Instance.new("BindableEvent")
	self.Hit = self._HitEvent.Event
	
	self._Position = position
	self._Radius = radius
	self._Stepped = nil
	
	self.Windup = windup
	if (not windup) then
		self.Windup = 0
	end
	self.Start = tick()
	
	self.Ignore = ignore
	
	local list = table.clone(CharacterList)
	local index = table.find(CharacterList, ignore, 1)
	if (index) then
		table.remove(list, index)
	end
	
	self._List = list
	
	if (visualize) then
		local visual = Instance.new("Part")
		
		visual.CFrame = CFrame.new(position)
		visual.Size = Vector3.new(radius * 2, radius * 2, radius * 2)
		visual.CanCollide = false
		visual.Massless = true
		visual.BrickColor = BrickColor.new("Bright red")
		visual.Transparency = 1
		visual.Shape = Enum.PartType.Ball
		visual.Anchored = true
		visual.Parent = visualizers
		
		self._Visualizer = visual
	end
	
	table.insert(hitboxList, self)
	
	return self
end

function Hitboxes.AddCharacter(character : Model)
	local index = table.find(CharacterList, character, 1)
	if (index == nil) then
		print("adding "..character.Name)
		table.insert(CharacterList, character)
	else
		warn(character.Name.." is already in the list.")
	end
end

function Hitboxes.RemoveCharacter(character : Model)
	print("removing "..character.Name)
	local index = table.find(CharacterList, character, 1)
	if (index) then
		table.remove(CharacterList, index)
	end
end

function Hitboxes:setPosition(position : Vector3)
	self._Position = position
	if (visualize) then
		self._Visualizer.CFrame = CFrame.new(position)
	end
end

function Hitboxes.GetCharacterList()
	return CharacterList
end

function Hitboxes.GetHitboxes()
	return hitboxList
end

function Hitboxes:start()
	if (visualize) then
		self._Visualizer.Transparency = 0.9
	end
	self._Stepped = RunService.Stepped:Connect(function(t, dt)
		Parameters.FilterDescendantsInstances = self._List
		Parameters.FilterType = Enum.RaycastFilterType.Whitelist
		local parts = workspace:GetPartBoundsInRadius(self._Position, self._Radius, Parameters)
		local characterLimbs = {}
		for i, v in pairs(parts) do
			local index = table.find(self._List, v.Parent, 1)
			if (index and table.find({"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, v.Name)) then
				--table.remove(self._List, index)
				--self._HitEvent:Fire(v)
				if (not characterLimbs[v.Parent]) then
					characterLimbs[v.Parent] = {}
				end
				table.insert(characterLimbs[v.Parent], v)
			end
		end
		for i, v : any in pairs(characterLimbs) do
			local p = nil
			local magnitude = math.huge
			for _, part in pairs(v) do 
				if ((self._Position - part.Position).Magnitude < magnitude) then
					magnitude = (self._Position - part.Position).Magnitude
					p = part
				end
			end
			local index = table.find(self._List, p.Parent, 1)
			if (p and index) then
				table.remove(self._List, index)
				self._HitEvent:Fire(p)
			end
		end
	end)
end	

function Hitboxes:check(character : Model)
	Parameters.FilterDescendantsInstances = {character}
	Parameters.FilterType = Enum.RaycastFilterType.Whitelist
	local parts = workspace:GetPartBoundsInRadius(self._Position, self._Radius, Parameters)
	for i, v in pairs(parts) do
		if (table.find({"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, v.Name)) then
			return true
		end
	end
	return false
end

function Hitboxes:stop()
	if (self._Stepped ~= nil) then
		if (visualize) then
			self._Visualizer:Destroy()
		end
		self._Stepped:Disconnect()
		table.remove(hitboxList, table.find(hitboxList, self, 1))
	end
end

return Hitboxes
