local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")

if (workspace:FindFirstChild("Ambience")) then
	return
end

local ambience = ReplicatedFirst.Sounds.Ambience.Ambience:Clone()

ambience.Parent = workspace

ambience.Looped = true
ambience.Volume = 0

ambience:Play()

RunService.Heartbeat:Connect(function(dt)
	if (ambience.Volume < 10) then
		ambience.Volume += 0.1
	end
end)