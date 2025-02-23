script.Parent.Activated:Connect(function()
	game.ReplicatedStorage.Events.eatFruit:Fire(script.Parent.Parent)
end)