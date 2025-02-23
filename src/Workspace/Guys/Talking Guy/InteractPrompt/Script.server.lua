script.Parent.Triggered:Connect(function(player)
	local dialogue = require(player:FindFirstChild("Dialogue"))
	local result = dialogue.StartDialogue("i like talking to random strangers", script.Parent.Parent, {"who asked", "ok"})
	if (result == "who asked") then
		dialogue.StartDialogue("i did", script.Parent.Parent)
	end
end)