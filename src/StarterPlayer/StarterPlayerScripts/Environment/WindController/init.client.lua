local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local WIND_DIRECTION = script.Parent.WindDirection.Value


local WIND_SPEED = 80
local WIND_POWER = 0.5


local WindLines = require(script.WindLines)
local WindShake = require(script.WindShake)

WindLines:Init({
	Direction = WIND_DIRECTION;
	Speed = WIND_SPEED;
	Lifetime = 1.5;
	SpawnRate = 1000;
})

WindShake:Init()
WindShake:SetDefaultSettings({
	Speed = WIND_SPEED;
	Direction = WIND_DIRECTION;
	Power = WIND_POWER;
})

script.Parent.WindDirection.Changed:Connect(function()
	WIND_DIRECTION = script.Parent.WindDirection.Value
	WindLines:Init({
		Direction = WIND_DIRECTION;
		Speed = WIND_SPEED;
		Lifetime = 1.5;
		SpawnRate = 1000;
	})

	WindShake:Init()
	WindShake:SetDefaultSettings({
		Speed = WIND_SPEED;
		Direction = WIND_DIRECTION;
		Power = WIND_POWER;
	})
end)


