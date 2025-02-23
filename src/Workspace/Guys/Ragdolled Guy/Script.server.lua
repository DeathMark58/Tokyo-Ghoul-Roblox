local trigger = script.Parent:WaitForChild("Values").RagdollTrigger
trigger.Value = true

require(game.ServerScriptService.PlayerSetup.ModuleScript):Ragdoll(script.Parent)