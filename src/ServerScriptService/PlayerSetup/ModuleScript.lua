local module = {}
local Players = game:GetService("Players")

local PhysicsService = game:GetService("PhysicsService")
local ragParts = script.Parent.RagdollParts:GetChildren()

function module:Setup(char: Model)
	assert(
		Players:GetPlayerFromCharacter(char) == nil,
		"Setting up ragdoll on player characters is already done automatically"
	)

	local humanoid = char:FindFirstChild("Humanoid")
	assert(humanoid, "Can only set-up ragdoll on R6 humanoid rigs")
	assert(humanoid.RigType == Enum.HumanoidRigType.R6, "Can only set-up ragdoll on R6 humanoid rigs")
	assert(humanoid.RootPart ~= nil, "No RootPart was found in the provided rig")
	assert(char:FindFirstChild("HumanoidRootPart"), "No HumanoidRootPart was found in the provided rig")
	
	for _, v: BasePart in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Anchored = false
			v:SetNetworkOwner(nil)
		end
	end

	-- Setup ragdoll
	char.Head.Size = Vector3.new(1, 1, 1)
	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false

	local clones = {}
	for _, v in ipairs(ragParts) do
		clones[v.Name] = v:Clone()
	end

	local folder1 = Instance.new("Folder")
	folder1.Name = "RagdollConstraints"
	for _, v in pairs(clones) do
		if v:IsA("Attachment") then
			v.Parent = char[v:GetAttribute("Parent")]
		elseif v:IsA("BallSocketConstraint") then
			v.Attachment0 = clones[v:GetAttribute("0")]
			v.Attachment1 = clones[v:GetAttribute("1")]
			v.Parent = folder1
		end
	end
	folder1.Parent = char

	local folder2 = Instance.new("Folder")
	folder2.Name = "Motors"
	local value
	for _, v in ipairs(char.Torso:GetChildren()) do
		if v:IsA("Motor6D") then
			value = Instance.new("ObjectValue")
			value.Value = v
			value.Parent = folder2
		end
	end
	folder2.Parent = folder1

	-- Ragdoll trigger
	local trigger = char:WaitForChild("Values").RagdollTrigger

	trigger.Changed:Connect(function(bool)
		if bool then
			module:Ragdoll(char)
		else
			module:Unragdoll(char)
		end
	end)
end

function module:Ragdoll(char: Model)
	char.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	char.Humanoid.AutoRotate = false
	for _, v in ipairs(char.RagdollConstraints.Motors:GetChildren()) do
		if (v) then
			v.Value.Enabled = false
		end
	end

	for _, v in ipairs(char:GetChildren()) do
		if v:IsA("BasePart") then
			v.CollisionGroup = "Ragdoll"
		end
	end

	char.HumanoidRootPart:ApplyAngularImpulse(Vector3.new(-90, 0, 0))
end

function module:Unragdoll(char: Model)
	char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	for _, v in ipairs(char.RagdollConstraints.Motors:GetChildren()) do
		if (v) then
			v.Value.Enabled = true
		end
	end

	for _, v in ipairs(char:GetChildren()) do
		if v:IsA("BasePart") then
			if (game.Players:GetPlayerFromCharacter(char)) then
				v.CollisionGroup = "Players"
			else
				v.CollisionGroup = "NPCS"
			end
		end
	end
	char.Humanoid.AutoRotate = true
end

return module
