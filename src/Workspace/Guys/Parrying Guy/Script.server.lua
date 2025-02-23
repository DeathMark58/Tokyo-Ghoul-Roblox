local values = script.Parent:WaitForChild("Values")

values.Blocking.Value = 1

script.Parent.Humanoid:LoadAnimation(game:GetService("ReplicatedFirst").Animations.Sword.Block):Play()