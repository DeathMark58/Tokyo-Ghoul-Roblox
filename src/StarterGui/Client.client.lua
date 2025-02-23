local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera
local ts = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local defaultFOV = 80

local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

--afk
local movement = 0

local bosses = {}

game:GetService("ReplicatedStorage").Events.valueChanged.OnClientEvent:Connect(function(name, value)
	if (name == "Movement") then
		movement = value
	end
end)

local screenGui = player.PlayerGui:WaitForChild("Bars")

local effect = player.PlayerGui:WaitForChild("ScreenGui").Options.Content.Visuals["FOV Effect"].Button.Bool.Value

player.CharacterAdded:Connect(function(char)
	game.Lighting.ColorCorrection.Saturation = 0.2
	character = char
	screenGui = player.PlayerGui:WaitForChild("ScreenGui")
	bosses = {}
end)

player.PlayerGui:WaitForChild("ScreenGui").Options.Content.Visuals["FOV Effect"].Button.Bool.Changed:Connect(function(value)
	effect = value
end)

camera.CameraType = Enum.CameraType.Custom
camera.CameraSubject = character:WaitForChild("Humanoid")--.Parent.Head

player.CameraMaxZoomDistance = 20;
player.CameraMinZoomDistance = 5;

character:WaitForChild("Humanoid").HealthChanged:connect(function(old)
	if (old == 0 or character.Humanoid.Health ~= 0) then
		return
	end
	
end)

local diedDebounce = true
character:WaitForChild("Humanoid").Died:Connect(function()
	if(diedDebounce) then
		diedDebounce = false
		character.HumanoidRootPart.Velocity += Vector3.new(math.random(-15,15),math.random(-15,15),math.random(-15,15))
		local tween = ts:Create(game:GetService("Lighting").ColorCorrection,TweenInfo.new(6,Enum.EasingStyle.Circular,Enum.EasingDirection.Out),{Saturation = -1,Brightness = -.1})
		tween:Play()
		tween.Completed:Connect(function()
			game:GetService("Lighting").ColorCorrection.Saturation = 0.2
			game:GetService("Lighting").ColorCorrection.Brightness = 0.02
		end)
		local runService = game:GetService("RunService")
		camera.CameraType = Enum.CameraType.Scriptable

		local preCFrame = camera.CFrame
		local deathCam = ts:Create(camera,TweenInfo.new(5.841,Enum.EasingStyle.Circular,Enum.EasingDirection.Out),{FieldOfView = defaultFOV-45})
		deathCam:Play()

		deathCam.Completed:Connect(function()
			camera.FieldOfView = defaultFOV
		end)


		while game:GetService("RunService").RenderStepped:Wait() do
			local goal = CFrame.new(character.HumanoidRootPart.Position + Vector3.new(0, 15,-12*math.sign(character.HumanoidRootPart.Position.Z - preCFrame.Z)), character.HumanoidRootPart.Position)
			camera.CFrame = camera.CFrame:Lerp(goal, 0.1)
		end
	end
end)

local function Lerp(a, b, t)
	return a + (b - a) * t
end
local change = 0

local oldPosition = character:WaitForChild("HumanoidRootPart").CFrame.Position

local ts = game:GetService("TweenService")

local bars = {}

local function updateBars()
	for i,v in pairs (bosses) do
		if(bars[v] == nil) then
			local bar = game.ReplicatedStorage.UI.Bossbar:Clone()
			bar.Parent = screenGui.Bossbars
			bar.Name = v
			bar.TextLabel.Text = v
			
			ts:Create(bar.Bar,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{BackgroundTransparency=0}):Play()
			ts:Create(bar.Transition,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{BackgroundTransparency=0}):Play()
			ts:Create(bar.TextLabel,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{TextTransparency=0}):Play()
		end
	end
	
	for i,v in pairs(screenGui.Bossbars:GetChildren()) do
		if(v:IsA("Frame") and bars[v.Name] == nil) then
			bars[v.Name] = {}
			bars[v.Name][2] = 1

			local boss
			for _, value in pairs (workspace:GetDescendants()) do
				if(value.Name == v.Name) then
					boss = value
				end
			end

			bars[v.Name][1] = game:GetService("RunService").RenderStepped:Connect(function(dt)
				--print(v.Name .. "is at " .. boss.Humanoid.Health / boss.Humanoid.MaxHealth)
				bars[v.Name][2] += (boss.Humanoid.Health / boss.Humanoid.MaxHealth - bars[v.Name][2]) * 0.1
				screenGui.Bossbars:WaitForChild(v.Name).Bar.Size = UDim2.new(boss.Humanoid.Health / boss.Humanoid.MaxHealth, 0, 1, 0)
				screenGui.Bossbars:WaitForChild(v.Name).Transition.Size = UDim2.new(bars[v.Name][2], 0, 1, 0)
			end)
		end
	end

	print(bars)
end

local npcList = {}

game.ReplicatedStorage.Events.npcAdded.OnClientEvent:Connect(function(charList)
	npcList = charList
end)

game:GetService("RunService").RenderStepped:Connect(function(dt)
	if (effect) then
		camera.FieldOfView = defaultFOV + change
	else
		camera.FieldOfView = defaultFOV
	end
	
	change += math.round((character.HumanoidRootPart.AssemblyLinearVelocity.Magnitude + math.abs(math.sign(movement)) * 16) * 0.5 - change) * 0.1
	oldPosition = character.HumanoidRootPart.CFrame.Position
	
	for _,v in pairs (npcList) do
		if(v:GetAttribute("Type") == "Boss" and (character.HumanoidRootPart.Position*Vector3.new(1,0,1) - v.HumanoidRootPart.Position*Vector3.new(1,0,1)).Magnitude < 200 and table.find(bosses,v.Name) == nil) then
			table.insert(bosses,v.Name)
			print("enter"..v.Name)
			updateBars()
		elseif(table.find(bosses, v.Name) and (character.HumanoidRootPart.Position*Vector3.new(1,0,1) - v.HumanoidRootPart.Position*Vector3.new(1,0,1)).Magnitude > 200) then 
			table.remove(bosses,table.find(bosses,v.Name))
			print("removing"..v.Name)

			bars[v.Name][1]:Disconnect()
			bars[v.Name] = nil

			local bar = screenGui.Bossbars:WaitForChild(v.Name)
			game:GetService("Debris"):AddItem(bar,1)

			ts:Create(bar.Bar,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{BackgroundTransparency=1}):Play()
			ts:Create(bar.Transition,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{BackgroundTransparency=1}):Play()
			ts:Create(bar.TextLabel,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{TextTransparency=1}):Play()
		end
	end
end)


