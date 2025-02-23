for i,v in pairs(script.Parent:GetDescendants()) do
	if(v:isA("StringValue")) then
		local sound = Instance.new("Sound",script)
		sound.SoundId = v.Value
		sound.Name = v.Name
	end
end