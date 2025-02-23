local ReplicatedStorage = game:GetService("ReplicatedStorage")

local character = script.Parent

local particle = ReplicatedStorage.Particles.Breath:Clone()
particle.Parent = character.Head.FaceFrontAttachment
character.Head.FaceFrontAttachment.CFrame = CFrame.Angles(-90, 0, 0) + character.Head.FaceFrontAttachment.Position

--[[
particle.Enabled = false
while true do
	task.wait(2.5)
	particle.Enabled = true
	task.delay(0.4, function()
		particle.Enabled = false
	end)
end
-]]

while true do
	task.wait(2.5)
	particle:Emit(3)
end