local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local changeEvent = game:GetService("ReplicatedStorage").Events.valueChanged
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)

-- Makes hands interact with head better
local head = char:WaitForChild("Head")
head.Size = Vector3.new(1,1,1)

changeEvent.OnClientEvent:Connect(function(name, value)
	if (name == "RagdollTrigger") then
		if value then
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			hrp:ApplyAngularImpulse(Vector3.new(-90, 0, 0))
		else
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end
end)