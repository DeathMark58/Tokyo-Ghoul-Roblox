local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local rs = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local screenGui = player.PlayerGui:WaitForChild("ScreenGui")

local mouseLockController = player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local keybinds = player.PlayerScripts:WaitForChild("Keybinds")

local current = nil

for i, v in pairs(keybinds:GetChildren()) do
	local bind = screenGui.Options.Content.Keybinds.Keybind:Clone()
	bind.Parent = screenGui.Options.Content.Keybinds
	bind.Text = v.Name
	bind.Bind.Text = v.Value
	bind.Visible = true
	bind.Bind.Activated:Connect(function(o, c)
		if (current == nil) then
			current = bind.Bind
			bind.Bind.Text = "..."
		end
	end)
end

screenGui.Options.Visible = false

screenGui.OptionsButton.Activated:Connect(function(o, c)
	screenGui.Options.Visible = not screenGui.Options.Visible
end)

UserInputService.InputBegan:Connect(function(i, g)
	if (not g) then
		if (current ~= nil) then
			current.Text = i.KeyCode.Name
			keybinds:FindFirstChild(current.Parent.Text).Value = current.Text
			if (current.Parent.Text == "Shift Lock") then
				mouseLockController.BoundKeys.Value = i.KeyCode.Name
			end
			current = nil
			return
		end
		if (i.KeyCode.Name == keybinds.Options.Value) then
			screenGui.Options.Visible = not screenGui.Options.Visible
		end
	end
end)

for i, v in pairs(screenGui.Options.Content:GetDescendants()) do
	if (v:GetAttribute("Type") == "On/Off") then
		v.Button.Activated:Connect(function(o, c)
			v.Button.Bool.Value = not v.Button.Bool.Value
			if (v.Button.Bool.Value) then
				v.Button.Text = "On"
			else
				v.Button.Text = "Off"
			end
		end)
		if (v.Name == "Wind") then
			player.PlayerScripts.Environment.WindController.Enabled = v.Button.Bool.Value
			player.PlayerScripts.Environment.RainScript.Enabled = v.Button.Bool.Value
		end
	end
end