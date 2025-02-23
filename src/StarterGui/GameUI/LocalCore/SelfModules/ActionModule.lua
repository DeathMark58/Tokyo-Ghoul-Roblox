-- Decompiled with the Synapse X Luau decompiler.

local v1 = {};
local l__ContextActionService__2 = game:GetService("ContextActionService");
local l__RunService__3 = game:GetService("RunService");
function MakeTag(p1, p2)
	local v4 = Instance.new("IntValue");
	v4.Name = p1;
	v4.Value = p2;
	v4.Parent = script.Parent.Parent.Tags;
	game.Debris:AddItem(v4, p2);
end;
function MakeSound(p3)
	local v5 = Instance.new("Sound");
	v5.Name = " ";
	v5.SoundId = "rbxassetid://" .. p3.SoundId;
	v5.EmitterSize = p3.EmitterSize;
	v5.PlaybackSpeed = (p3.PlaybackSpeed * 100 + math.random(-p3.SpeedInterval, p3.SpeedInterval)) / 100;
	v5.Volume = p3.Volume;
	v5.Parent = p3.Place;
	v5:Play();
	game.Debris:AddItem(v5, p3.Duration);
end;
local u1 = nil;
local u2 = {
	Grass = {
		Sounds = { 4085863021 }, 
		Volume = 0.125, 
		PlaybackSpeed = 1, 
		SpeedInterval = 20, 
		Duration = 2, 
		EmitterSize = 4
	}, 
	Slate = {
		Sounds = { 1201103066 }, 
		Volume = 0.2, 
		PlaybackSpeed = 0.7, 
		SpeedInterval = 5, 
		Duration = 2, 
		EmitterSize = 4
	}, 
	Sand = {
		Sounds = { 267882850 }, 
		Volume = 0.2, 
		PlaybackSpeed = 0.6, 
		SpeedInterval = 20, 
		Duration = 2, 
		EmitterSize = 4
	}, 
	Pebble = {
		Sounds = { 619083295 }, 
		Volume = 0.7, 
		PlaybackSpeed = 1, 
		SpeedInterval = 10, 
		Duration = 2, 
		EmitterSize = 4
	}, 
	Cobblestone = {
		Sounds = { 248493371 }, 
		Volume = 0.3, 
		PlaybackSpeed = 1, 
		SpeedInterval = 10, 
		Duration = 2, 
		EmitterSize = 4
	}, 
	Wood = {
		Sounds = { 1201103066 }, 
		Volume = 0.2, 
		PlaybackSpeed = 0.7, 
		SpeedInterval = 5, 
		Duration = 2, 
		EmitterSize = 4
	}, 
	WoodPlanks = {
		Sounds = { 1201103066 }, 
		Volume = 0.2, 
		PlaybackSpeed = 0.7, 
		SpeedInterval = 5, 
		Duration = 2, 
		EmitterSize = 4
	}, 
	Concrete = {
		Sounds = { 1201103066 }, 
		Volume = 0, 
		PlaybackSpeed = 0.7, 
		SpeedInterval = 5, 
		Duration = 2, 
		EmitterSize = 10
	}, 
	Plastic = {
		Sounds = { 1201103066 }, 
		Volume = 0, 
		PlaybackSpeed = 0.7, 
		SpeedInterval = 5, 
		Duration = 2, 
		EmitterSize = 10
	}, 
	SmoothPlastic = {
		Sounds = { 1201103066 }, 
		Volume = 0, 
		PlaybackSpeed = 0.7, 
		SpeedInterval = 5, 
		Duration = 2, 
		EmitterSize = 10
	}, 
	Neon = {
		Sounds = { 1201103066 }, 
		Volume = 0, 
		PlaybackSpeed = 0.7, 
		SpeedInterval = 5, 
		Duration = 2, 
		EmitterSize = 10
	}
};
function Step()
	local v6 = RaycastParams.new();
	v6.FilterDescendantsInstances = { u1 };
	v6.FilterType = Enum.RaycastFilterType.Blacklist;
	local v7 = workspace:Raycast(u1.HumanoidRootPart.Position, Vector3.new(0, -3.5, 0), v6);
	if v7 then
		local l__Name__8 = v7.Instance.Material.Name;
		MakeSound({
			SoundId = u2[l__Name__8].Sounds[math.random(1, #u2[l__Name__8].Sounds)], 
			Place = u1.HumanoidRootPart, 
			EmitterSize = u2[l__Name__8].EmitterSize, 
			Volume = u2[l__Name__8].Volume, 
			PlaybackSpeed = u2[l__Name__8].PlaybackSpeed, 
			SpeedInterval = u2[l__Name__8].SpeedInterval, 
			Duration = u2[l__Name__8].Duration
		});
	end;
end;
function CheckState()
	if u1 ~= nil then
		if u1.Humanoid.Health == 0 then

		else
			return;
		end;
	end;
	return false;
end;
local l__IsRunning__9 = script.Parent.Parent.IsRunning;
local u3 = nil;
function Crouching(p4)
	if 6 <= p4 then
		if u3.IsPlaying == false then
			u3:Play();
			return;
		end;
	end;
	if p4 < 4 then
		u3:AdjustSpeed(0);
		return;
	end;
	if 6 < p4 then
		u3:AdjustSpeed(1);
	end;
end;
function v1.RunAction(p5, p6)

end;
function v1.DashAction(p7, p8)

end;
local l__IsSliding__4 = script.Parent.Parent.IsSliding;
local u5 = nil;
local l__TweenService__6 = game:GetService("TweenService");
function v1.SlideAction(p9, p10)
	if CheckState() == false then
		return;
	end;
	u1 = p9;
	l__IsSliding__4.Value = true;
	u5 = p9.Humanoid:LoadAnimation(game.ReplicatedStorage.GameAssets.Animations.Sliding);
	u5:Play();
	local v10 = Instance.new("BodyVelocity");
	v10.MaxForce = Vector3.new(100000, 1, 100000);
	v10.Velocity = p9.HumanoidRootPart.CFrame.LookVector * 45;
	v10.Parent = p9.HumanoidRootPart;
	MakeTag("SlideCD", 2);
	l__TweenService__6:Create(v10, TweenInfo.new(0.5), {
		Velocity = Vector3.new(0, 0, 0)
	}):Play();
	game.Debris:AddItem(v10, 0.5);
	wait(0.5);
	u5:Stop();
end;
local l__IsCrouching__7 = script.Parent.Parent.IsCrouching;
local u8 = nil;
local u9 = nil;
function v1.CrouchAction(p11, p12)
	if CheckState() == false then
		return;
	end;
	if p12 ~= true then
		if p12 == false then
			MakeTag("CrouchCD", 1);
			l__IsCrouching__7.Value = false;
			u9:Disconnect();
			u8:Stop();
			u3:Stop();
			local l__Humanoid__11 = p11.Humanoid;
			l__Humanoid__11.WalkSpeed = l__Humanoid__11.WalkSpeed + 6;
			p11.Humanoid.JumpPower = 50;
		end;
		return;
	end;
	l__IsCrouching__7.Value = true;
	u8 = p11.Humanoid:LoadAnimation(game.ReplicatedStorage.GameAssets.Animations["Crouch Idle"]);
	u3 = p11.Humanoid:LoadAnimation(game.ReplicatedStorage.GameAssets.Animations.Crouching);
	u9 = p11.Humanoid.Running:Connect(Crouching);
	u8:Play();
	local l__Humanoid__12 = p11.Humanoid;
	l__Humanoid__12.WalkSpeed = l__Humanoid__12.WalkSpeed - 6;
	p11.Humanoid.JumpPower = 0;
end;
return v1;
