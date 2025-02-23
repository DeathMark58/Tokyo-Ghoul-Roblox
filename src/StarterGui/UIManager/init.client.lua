local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local rs = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local screenGui = player.PlayerGui:WaitForChild("Bars")

local mouseLockController = player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(c)
	character = c
	humanoid = character:WaitForChild("Humanoid")
	screenGui = player.PlayerGui:WaitForChild("Bars")
end)

local keybinds = player.PlayerScripts:WaitForChild("Keybinds")

local current = nil

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

RunService.Heartbeat:Wait()

StarterGui:SetCore("ResetButtonCallback", false)

local t = 1
local p = 0

local posture = 0

local maxPosture = 100

local tempo = 0

rs.Events.valueChanged.OnClientEvent:Connect(function(name, value)
	if (name == "Posture") then
		posture = value
	end
	if (name == "MaxPosture") then
		maxPosture = value
	end
	if (name == "Tempo") then
		tempo = value
	end
end)

RunService.RenderStepped:Connect(function(dt)
	t += (humanoid.Health / humanoid.MaxHealth - t) * 0.1
	screenGui.HealthBar.Bar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
	screenGui.HealthBar.Transition.Size = UDim2.new(t, 0, 1, 0)
	
	screenGui.PostureBar.Bar.Size = UDim2.new(p, 0, 1, 0)
	p += (posture / maxPosture - p) * 0.2
	
	screenGui.TempoBar.Bar.Size = UDim2.new(tempo / 100, 0, 1, 0)
end)


local shake = require(script.CameraShaker)
game.ReplicatedStorage.Events.bossSummon.OnClientEvent:Connect(function()
	local camera = workspace.CurrentCamera
	local camShake = shake.new(Enum.RenderPriority.Last.Value, function(shakeCf)
		camera.CFrame = camera.CFrame * shakeCf
	end)

	camShake:Start()

	game.ReplicatedFirst.Sounds.Earthquake:Play()
	-- Sustained shake:

	task.delay(0.5,function()
		camShake:ShakeSustain(shake.Presets.Earthquake)
	end)

	task.delay(4,function()
		camShake:StopSustained(1)
	end)

	task.delay(4.5,function()
		game.ReplicatedFirst.Sounds.Roar:Play()
	end)
	
	task.delay(4.8,function()
		camShake:Start()
		camShake:ShakeSustain(shake.Presets.Explosion)
	end)
	task.delay(6,function()
		camShake:StopSustained(1)
	end)
end)
