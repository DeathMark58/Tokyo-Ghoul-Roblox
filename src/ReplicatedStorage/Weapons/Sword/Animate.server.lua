local tool = script.Parent

tool.init.Event:Wait()

local player = tool.Parent.Parent
local char = player.Character
local model = char:FindFirstChild("weaponModel")
local equipAnim = char:WaitForChild("Humanoid"):LoadAnimation(tool.Animations.Equip)
equipAnim.Priority = Enum.AnimationPriority.Action2
local idleAnim = char:WaitForChild("Humanoid"):LoadAnimation(tool.Animations.Idle)
idleAnim.Priority = Enum.AnimationPriority.Idle
idleAnim.Looped = true

local rightGrip
for _, v in pairs(char:GetDescendants()) do
	if(v.Name == "RightGrip") then
		rightGrip = v
	end
end


local unequipWeld = model.Unequip

local equipped = false

local function update()
	wait(0)
	game.ServerStorage:FindFirstChild(player.UserId):FindFirstChild("Equipped").Value = equipped
end


local function drawSword()
	
	if(equipped) then -- change weld to be animatable
		rightGrip.Enabled = true
		unequipWeld.Enabled = false
		equipAnim:Play(0.1,1,1.15)
	else -- putting back sword
		idleAnim:Stop()
		equipAnim:Play(0.1,1,-1.15) --plays in reverse
	end
	
	update()
	
	equipAnim.Stopped:Wait()
	--after animation finished
	
	if(equipped) then
		idleAnim:Play()
	else
		rightGrip.Enabled = false
		unequipWeld.Enabled = true
	end
end


tool.Equipped:Connect(function()
	equipped = true
	drawSword()
end)

tool.Unequipped:Connect(function()
	equipped = false
	drawSword()
end)

