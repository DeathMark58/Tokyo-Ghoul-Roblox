local ReplicatedStorage = game:GetService("ReplicatedStorage")

local colors =
{
		["Blocking"] = {Color3.fromRGB(255, 255, 0),Color3.fromRGB(255, 115, 0)},
		["Rolling"] = Color3.fromRGB(255,255,255),
		["Knocked"] = Color3.fromRGB(61, 7, 7),
		["Stun"] = Color3.fromRGB(0, 255, 255)
}

local stunned = false

ReplicatedStorage.Events.valueChanged.OnClientEvent:Connect(function(name, value)
	if (name ~= "Posture" and name ~= "Tempo") then
		--print(name.." changed to "..tostring(value))
	end
	
	local highlight = game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Highlight")
	if(colors[name] ~= nil) then
		if(typeof(value) == "number") then
			highlight.OutlineTransparency = 0
			
			if(name == "Blocking") then
				if(value ~= 0) then
					highlight.OutlineColor = colors[name][value]
				else
					highlight.OutlineTransparency = 1
				end
			else
				highlight.OutlineColor = colors[name]
			end
			
			if(name == "Stun") then
				if(value > 0) then
					highlight.OutlineColor = colors[name]
				else
					highlight.OutlineTransparency = 1
				end
			end

		else
			if(value) then
				highlight.OutlineTransparency = 0
				highlight.OutlineColor = colors[name]
			else
				highlight.OutlineTransparency = 1
			end
		end
	end
end)