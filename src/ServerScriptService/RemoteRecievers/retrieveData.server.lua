local rf = game:GetService("ReplicatedStorage").Events.requestData

rf.OnServerInvoke = function(plr, tagName)
	local dataFolder = game:GetService("ServerStorage"):FindFirstChild(plr.UserId)
	local tag = dataFolder:FindFirstChild(tagName)
	
	local output = tag.Value
	return output
end

