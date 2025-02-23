
local Rain = require(script.Rain)

Rain:SetColor(Color3.fromRGB(script.Color.Value.x, script.Color.Value.y, script.Color.Value.z))
Rain:SetDirection(script.Parent.WindDirection.Value)

script.Parent.WindDirection.Changed:Connect(function()
	Rain:SetDirection(script.Parent.WindDirection.Value)
end)

Rain:SetTransparency(script.Transparency.Value)
Rain:SetSpeedRatio(script.SpeedRatio.Value)
Rain:SetIntensityRatio(script.IntensityRatio.Value)
Rain:SetLightInfluence(script.LightInfluence.Value)
Rain:SetLightEmission(script.LightEmission.Value)

Rain:SetVolume(script.Volume.Value)

Rain:SetSoundId(script.SoundId.Value)
Rain:SetStraightTexture(script.StraightTexture.Value)
Rain:SetTopDownTexture(script.TopDownTexture.Value)
Rain:SetSplashTexture(script.SplashTexture.Value)

local threshold = script.TransparencyThreshold.Value
if script.TransparencyConstraint.Value and script.CanCollideConstraint.Value then
	Rain:SetCollisionMode(
		Rain.CollisionMode.Function,
		function(p)
			return p.Transparency <= threshold and p.CanCollide
		end
	)
elseif script.TransparencyConstraint.Value then
	Rain:SetCollisionMode(
		Rain.CollisionMode.Function,
		function(p)
			return p.Transparency <= threshold
		end
	)
elseif script.CanCollideConstraint.Value then
	Rain:SetCollisionMode(
		Rain.CollisionMode.Function,
		function(p)
			return p.CanCollide
		end
	)
end

Rain:Enable()