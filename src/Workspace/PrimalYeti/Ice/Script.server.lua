local debris = game:GetService("Debris")
local spawned = false


script.Parent.Torso.ChildAdded:Connect(function(child)
	if(child:IsA("Sound")) then
		if(spawned) then
			child:Stop()
		else
			if(script.Parent.Humanoid.Health > 11) then
				child.SoundId = script.Break.SoundId
			else
				child.SoundId = script.Shatter.SoundId
			end
			child.Volume = 10
			local pitch = script.Break.PitchShiftSoundEffect:Clone()
			pitch.Parent = child
			pitch.Octave = math.random(1,1.7)
		end
	end
end)
script.Parent.Humanoid.HealthChanged:Connect(function()
	if(script.Parent.Humanoid.Health == 0 and not spawned) then
		spawned = true
		print("ice broke")
		task.delay(0.1, function()
			require(game:GetService("ServerScriptService").RadiusHitbox).RemoveCharacter(script.Parent)
			script.Parent.Humanoid:Destroy()
		end)
		debris:AddItem(script.Parent.Torso,3)
		task.delay(1,function()
			game:GetService("TweenService"):Create(workspace.Terrain.Clouds,TweenInfo.new(2.5,Enum.EasingStyle.Circular,Enum.EasingDirection.InOut),{Cover = 1, Density = 1}):Play()
			game:GetService("TweenService"):Create(game.Lighting.Atmosphere,TweenInfo.new(2.5,Enum.EasingStyle.Circular,Enum.EasingDirection.InOut),{Density = 0.75}):Play()
		end)
		task.delay(2,function()
			game:GetService("TweenService"):Create(script.Parent.HumanoidRootPart,TweenInfo.new(1.5,Enum.EasingStyle.Circular,Enum.EasingDirection.In),{Size = Vector3.new(59.135,1,60.259), Position = Vector3.new(script.Parent.HumanoidRootPart.Position.X, -150.537, script.Parent.HumanoidRootPart.Position.Z)}):Play()
			
			game.ReplicatedStorage.Events.bossSummon:FireAllClients()
			script.Bass:Play()
			script.Sound:Play()
			
			wait(2)

			local boss = game.ServerStorage.YetiBoss:Clone()
			boss.Parent = workspace.PrimalYeti
			boss:WaitForChild("HumanoidRootPart").CFrame = workspace.PrimalYeti.FakeYeti.HumanoidRootPart.CFrame
			workspace.PrimalYeti.FakeYeti:Destroy()
			
			wait(1)
			script.Parent.HumanoidRootPart:Destroy()
			game:GetService("TweenService"):Create(game.Lighting.Atmosphere,TweenInfo.new(1.5,Enum.EasingStyle.Circular,Enum.EasingDirection.InOut),{Density = 0.65}):Play()
		end)
	end
end)