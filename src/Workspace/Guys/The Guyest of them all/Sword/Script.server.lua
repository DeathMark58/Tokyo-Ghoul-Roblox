local tool = script.Parent

local m6d
local char
local unequippedModel

local model = game.ReplicatedStorage.WeaponModels.Sword:Clone()
for _, v in pairs(model:GetChildren()) do
	if(v.Name ~= "Handle") then
		v.Parent = tool.Model
	else
		v.Parent = tool
	end
end
model:Destroy()

tool.Equipped:Connect(function()
	char = tool.Parent
	
	unequippedModel = char:FindFirstChild("unequipped"..tool.Name)
	for _, v in pairs(unequippedModel:GetChildren()) do
		if(not v:isA("ManualWeld") and v.Name ~= "Handle") then
			v.Transparency = 0.25
		end
	end
	
	local a:Weld = char:FindFirstChild("Right Arm"):WaitForChild("RightGrip")
	m6d = Instance.new("Motor6D")
	m6d.Parent = char:FindFirstChild("Right Arm")
	m6d.Name = "RightGrip"
	m6d.Part0 = a.Part0
	m6d.Part1 = a.Part1
	m6d.C0 = a.C0
	m6d.C1 = a.C1
	a:Destroy()
end)

tool.Unequipped:Connect(function()
	for _, v in pairs(unequippedModel:GetChildren()) do
		if(not v:isA("ManualWeld") and v.Name ~= "Handle") then
			v.Transparency = 0
		end
	end
	
	m6d:Destroy()
end)