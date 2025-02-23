local rs = game:GetService("ReplicatedStorage")

local cooldowns = 
{
		["Roll"] = 1,
		["Parry"] = 1.2,
		["Block"] = 0.05,
		["Aerial"] = 1,
		["M1"] = 0.65,
		["RunAttack"] = 1,
		["Critical"] = 1,
		["Feint"] = 1.5,
		["Roll Cancel"] = 1.5,
		["Uppercut"] = 1,
}

local characters = {}
--[[
ex.
	["uzubrr"] = {
					["M1"] = os.tick()
					["Critical"] = os.tick()
				 },
	["Attacking Dummy"] = {
						  	["M1"] = os.tick()
						  }
--]]

rs.Events.addCooldown.Event:Connect(function(char, id)
	
	if(characters[char] == nil) then
		characters[char] = {}
	end
	characters[char][id] = tick()
end)

local function returnCooldown(char, id)
	if(characters[char] == nil or characters[char][id] == nil) then
		return true
	end
	
	if(tick() - characters[char][id] > cooldowns[id]) then
		return true
	else
		return false
	end
end

rs.Events.getCooldown.OnInvoke = returnCooldown

rs.Events.skipCooldown.Event:Connect(function(char, id)
	if(characters[char] == nil) then
		characters[char] = {}
	end
	characters[char][id] = 0	
end)