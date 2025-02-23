--!nonstrict

local module = {}

function module.StartDialogue(text : string, character : Model, choices : {})
	local stop = Instance.new("BindableEvent")
	
	local playerGui = script.Parent:WaitForChild("PlayerGui")

	local dialogue = playerGui:FindFirstChild("Dialogue")
	
	if (dialogue.Enabled) then
		return
	end
	
	local model = character:Clone()
	
	for i, v in pairs(model:GetDescendants()) do
		if (v:IsA("Script")) then
			v:Destroy()
		end
	end
	
	local humanoidRootPart = model.PrimaryPart
	
	if (not humanoidRootPart) then
		warn("HumanoidRootPart not found")
	end
	
	playerGui.Bars.Enabled = false
	
	if (not dialogue) then
		warn("Dialogue not found")
	end

	model.Parent = workspace
	
	dialogue.Frame.ScrollingFrame.Text.Text = text
	dialogue.Frame:FindFirstChild("Name").Text = character.Name
	
	humanoidRootPart.Anchored = true
	humanoidRootPart.CFrame = CFrame.Angles(0, math.rad(22.5), 0)

	model.Parent = dialogue.Frame.ViewportFrame

	dialogue.Enabled = true
	if (not choices) then
		choices = {"..."}
	end
	for i = 1, #choices, 1 do
		local ui = dialogue.Frame.Choices.Choice:Clone()
		ui.Text = choices[i]
		ui.Visible = true
		ui.MouseButton1Click:Connect(function()
			model:Destroy()
			dialogue.Enabled = false
			for i, v in pairs(dialogue.Frame.Choices:GetChildren()) do
				if (v:IsA("TextButton") and v.Visible) then
					v:Destroy()
				end
			end
			playerGui.Bars.Enabled = true
			stop:Fire(choices[i])
		end)
		
		ui.Parent = dialogue.Frame.Choices
	end
	
	return stop.Event:Wait()
end

return module