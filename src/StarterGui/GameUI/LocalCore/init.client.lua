-- Decompiled with the Synapse X Luau decompiler.

local l__LocalPlayer__1 = game.Players.LocalPlayer;
local l__Debris__2 = game:GetService("Debris");
script.Parent.DarkFrame.BackgroundTransparency = 0;
script.Parent.DarkFrame.UpFrame.BackgroundTransparency = 0;
local v3 = { Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.Backpack, Enum.CoreGuiType.Health };
for v4 = 1, #v3 do
	game.StarterGui:SetCoreGuiEnabled(v3[v4], false);
end;
local v5 = l__LocalPlayer__1.Character or l__LocalPlayer__1.CharacterAdded:wait(0.15);
v5:WaitForChild("Humanoid");
wait(1.25);
local v6 = { Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Ragdoll };
for v7 = 1, #v6 do
	v5.Humanoid:SetStateEnabled(v6[v7], false);
end;
local v8 = require(script.SelfModules.CheckPattern);
local l__TweenService__9 = game:GetService("TweenService");
local l__ContextActionService__10 = game:GetService("ContextActionService");
local l__RunService__11 = game:GetService("RunService");
local l__Backpack__12 = l__LocalPlayer__1.Backpack;
local v13 = Instance.new("PointLight");
v13.Brightness = 0.5;
v13.Range = 7;
v13.Parent = v5.HumanoidRootPart;
script.Parent.UpFrame.GameInfo.Age.Text = string.format("%s, %s", game.ReplicatedStorage.GameData.Season.Value, game.ReplicatedStorage.GameData.Age.Value);
local u1 = game.ReplicatedStorage.GameData.LocalData:WaitForChild(l__LocalPlayer__1.Name);
local u2 = script.Parent.Crosshair["-"];
local u3 = script.Parent.Shells["-"];
local function v14()
	local l__Value__15 = u1.CharInfo.FirstName.Value;
	local l__Value__16 = u1.CharInfo.LastName.Value;
	local l__Value__17 = u1.CharInfo.PlayerTitle.Value;
	local l__Value__18 = u1.CharInfo.Crosshair.Value;
	local l__Value__19 = u1.CharInfo.Shells.Value;
	if l__Value__17 == nil or l__Value__17 == "" then
		script.Parent.UpFrame.GameInfo.IGName.Text = string.format("%s %s", l__Value__15, l__Value__16);
	else
		script.Parent.UpFrame.GameInfo.IGName.Text = string.format("%s %s, %s", l__Value__15, l__Value__16, l__Value__17);
	end;
	if l__Value__18 ~= nil and l__Value__19 ~= nil then
		u2.Text = l__Value__18;
		u3.Text = l__Value__19;
		return;
	end;
	u2.Text = "0";
	u3.Text = "0";
end;
v14();
for v20, v21 in pairs(u1.CharInfo:GetChildren()) do
	v21.Changed:Connect(function()
		v14();
	end);
end;
wait(0.5);
l__TweenService__9:Create(script.Parent.DarkFrame, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
	BackgroundTransparency = 1
}):Play();
l__TweenService__9:Create(script.Parent.DarkFrame.UpFrame, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
	BackgroundTransparency = 1
}):Play();
local u4 = {};
local u5 = nil;
local function u6()
	local l__ClockTime__22 = game.Lighting.ClockTime;
	if not (l__ClockTime__22 >= 18) and not (l__ClockTime__22 <= 6) then
		return "Day";
	end;
	return "Night";
end;
local u7 = false;
local l__AreaSound__8 = script.AreaSound;
local u9 = {
	SoundInOut = 0.25, 
	WrapInOut = 0.25, 
	DescriptionInOut = 0.25
};
local l__AreaFrame__10 = script.Parent.UpFrame.AreaFrame;
local l__AreaDescription__11 = script.Parent.UpFrame.AreaDescription;
function MarkArea(p1)
	if p1 == nil then
		return;
	end;
	local v23 = require(p1);
	u4 = { string.upper(p1.Name), u6() };
	u5 = p1;
	u7 = true;
	l__TweenService__9:Create(l__AreaSound__8, TweenInfo.new(u9.SoundInOut), {
		Volume = 0
	}):Play();
	l__AreaFrame__10["-"].AreaText.Text = string.upper(p1.Name);
	l__AreaDescription__11.Text = v23.Description;
	l__TweenService__9:Create(l__AreaFrame__10.RightIcon, TweenInfo.new(u9.WrapInOut), {
		ImageTransparency = 0
	}):Play();
	l__TweenService__9:Create(l__AreaFrame__10.LeftIcon, TweenInfo.new(u9.WrapInOut), {
		ImageTransparency = 0
	}):Play();
	wait(0.25);
	l__AreaFrame__10["-"]:TweenSize(UDim2.new(0, 13.5 * #p1.Name, 0, 25), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.25, true, nil);
	l__AreaSound__8:Stop();
	l__AreaSound__8.SoundId = "rbxassetid://" .. v23.SoundSettings.SoundId[u4[2]];
	l__AreaSound__8.PlaybackSpeed = v23.SoundSettings.PlaybackSpeed[u4[2]];
	wait(0.5);
	l__AreaSound__8:Play();
	l__TweenService__9:Create(l__AreaSound__8, TweenInfo.new(u9.SoundInOut * 3), {
		Volume = v23.SoundSettings.Volume[u4[2]]
	}):Play();
	l__TweenService__9:Create(l__AreaDescription__11, TweenInfo.new(u9.DescriptionInOut), {
		TextTransparency = 0.1, 
		TextStrokeTransparency = 0.6
	}):Play();
	wait(5);
	l__AreaFrame__10["-"]:TweenSize(UDim2.new(0, -1, 0, 25), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.25, true, nil);
	l__TweenService__9:Create(l__AreaDescription__11, TweenInfo.new(u9.DescriptionInOut), {
		TextTransparency = 1, 
		TextStrokeTransparency = 1
	}):Play();
	wait(0.3);
	l__TweenService__9:Create(l__AreaFrame__10.RightIcon, TweenInfo.new(u9.WrapInOut), {
		ImageTransparency = 1
	}):Play();
	l__TweenService__9:Create(l__AreaFrame__10.LeftIcon, TweenInfo.new(u9.WrapInOut), {
		ImageTransparency = 1
	}):Play();
	u7 = false;
end;
local l__Leaderboard__12 = script.Parent.UpFrame.Leaderboard;
local function v24(p2, p3)
	local v25 = {};
	if p3 == "Removing" and l__Leaderboard__12.Players:FindFirstChild(p2.Name) then
		l__Leaderboard__12.Players[p2.Name]:Destroy();
	else
		for v26, v27 in pairs(game.Players:GetChildren()) do
			if l__Leaderboard__12.Players:FindFirstChild(v27.Name) == nil and v27 then
				local v28 = game.ReplicatedStorage.GameData.LocalData:WaitForChild(v27.Name) and nil;
				if v28 ~= nil then
					local v29 = l__Leaderboard__12.Players.PlayerName:Clone();
					v29.Name = v27.Name;
					local l__Value__30 = v28.CharInfo.FirstName.Value;
					local l__Value__31 = v28.CharInfo.LastName.Value;
					local l__Value__32 = v28.CharInfo.PlayerTitle.Value;
					if l__Value__32 == nil or l__Value__32 == "" then
						local v33 = string.format("%s %s", l__Value__30, l__Value__31);
					else
						v33 = string.format("%s %s, %s", l__Value__30, l__Value__31, l__Value__32);
					end;
					v29.Text = v33;
					v29.Parent = l__Leaderboard__12.Players;
					v29.Visible = true;
					v25[v27.Name] = v27;
				end;
			elseif l__Leaderboard__12.Players:FindFirstChild(v27.Name) and v27 then
				v25[v27.Name] = v27;
			end;
		end;
		for v34, v35 in pairs(l__Leaderboard__12.Players:GetChildren()) do
			if v35.Name ~= "PlayerName" and not v35:IsA("UIListLayout") and not v25[v35.Name] then
				v35:Destroy();
			end;
		end;
	end;
	local v36 = #l__Leaderboard__12.Players:GetChildren() - 2;
	local v37 = "Strangers";
	if v36 - 1 == 1 then
		v37 = "Stranger";
	end;
	script.Parent.UpFrame.Leaderboard.Size = UDim2.new(0, 150, 0, 25 * v36);
	script.Parent.UpFrame.Leaderboard.Strangers.Text = "(" .. v36 - 1 .. " " .. v37 .. ")";
end;
v24();
game.Players.PlayerAdded:Connect(v24, "Adding");
game.Players.PlayerRemoving:Connect(v24, "Removing");
workspace.ChildAdded:Connect(v24);
local u13 = {
	LastHp = v5.Humanoid.Health, 
	BaseHp = v5.Humanoid.MaxHealth
};
local u14 = script.Parent.MainFrame.GameBars.Health.Bar["-"];
v5.Humanoid.HealthChanged:connect(function()
	local v38 = v5.Humanoid.Health / u13.BaseHp;
	if v38 > 1 then
		v38 = 1;
	end;
	u14:TweenSize(UDim2.new(v38, 0, 1, 0), "Out", Enum.EasingStyle.Quad, 0.25, true, nil);
	u13.LastHp = v5.Humanoid.Health;
end);
local u15 = script.Parent.MainFrame.GameBars.Posture.Bar["-"];
v5:WaitForChild("Posture"):GetPropertyChangedSignal("Value"):Connect(function()
	local v39 = v5.Posture.Value / v5.Posture.MaxValue;
	if v39 > 1 then
		v39 = 1;
	end;
	u15:TweenSize(UDim2.new(v39, 0, 1, 0), "Out", Enum.EasingStyle.Quad, 0.25, true, nil);
end);
function MakeTap()
	local v40 = Instance.new("BoolValue");
	v40.Name = "RunTap";
	v40.Parent = script;
	game.Debris:AddItem(v40, 0.35);
end;
local u16 = { script.Parent.MainFrame.GameBars.Chains.Icons.Icon1, script.Parent.MainFrame.GameBars.Chains.Icons.Icon2, script.Parent.MainFrame.GameBars.Chains.Icons.Icon3, script.Parent.MainFrame.GameBars.Chains.Icons.Icon4 };
function FadeSymbol(p4, p5)
	coroutine.resume(coroutine.create(function()
		game:GetService("TweenService"):Create(u16[p4], TweenInfo.new(0.15), {
			ImageColor3 = Color3.new(0.5098039215686274, 0.5098039215686274, 0.5098039215686274)
		}):Play();
		wait(p5);
		game:GetService("TweenService"):Create(u16[p4], TweenInfo.new(0.15), {
			ImageColor3 = Color3.new(1, 1, 1)
		}):Play();
	end));
end;
local l__Tags__17 = script.Tags;
local l__IsCrouching__18 = script.IsCrouching;
local l__IsRunning__19 = script.IsRunning;
game:GetService("UserInputService").InputBegan:Connect(function(p6)
	local l__KeyCode__41 = p6.KeyCode;
	if game:GetService("UserInputService"):GetFocusedTextBox() then
		return;
	end;
	if l__KeyCode__41 == Enum.KeyCode.W then
		if script:FindFirstChild("RunTap") and l__Tags__17:FindFirstChild("RunCD") == nil and l__IsCrouching__18.Value == false then
			script.Action:FireServer({
				Context = "Run"
			});
			return;
		end;
		if script.IsRunning.Value == false then
			MakeTap();
			return;
		end;
	else
		if l__KeyCode__41 == Enum.KeyCode.C and l__IsRunning__19.Value == true and l__Tags__17:FindFirstChild("SlideCD") == nil then
			script.Action:FireServer({
				Context = "Slide"
			});
			return;
		end;
		if l__KeyCode__41 == Enum.KeyCode.C and l__IsRunning__19.Value == false and l__Tags__17:FindFirstChild("CrouchCD") == nil then
			script.Action:FireServer({
				Context = "Crouch"
			});
		end;
	end;
end);
game:GetService("UserInputService").InputEnded:Connect(function(p7)
	if p7.KeyCode == Enum.KeyCode.W and l__IsRunning__19.Value == true then
		script.Action:FireServer({
			Context = "Run"
		});
	end;
end);
for v42, v43 in pairs(u1.StatInfo:GetChildren()) do
	local u20 = script.Parent.SecondaryFrame[v43.Name].Bar["-"];
	v43.Changed:Connect(function(p8)
		local v44 = p8 / 100;
		u20:TweenSizeAndPosition(UDim2.new(1, 0, v44, 0), UDim2.new(0, 0, 1 - v44, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.25, true, nil);
	end);
end;
function CheckSurronding()

end;
local l__CurrentCamera__21 = workspace.CurrentCamera;
local function u22(p9)
	local v45 = game:GetService("UserInputService"):GetMouseLocation();
	local v46 = l__CurrentCamera__21:ViewportPointToRay(v45.X, v45.Y);
	return workspace:FindPartOnRayWithIgnoreList(Ray.new(v46.Origin, v46.Direction * 1000), p9);
end;
game:GetService("ReplicatedStorage").Remotes.GetMouse.OnClientInvoke = function()
	local v47, v48 = u22({ workspace.WorldData.Debris, v5 });
	return v48;
end;
game:GetService("ReplicatedStorage").Remotes.LocalEffect.OnClientEvent:Connect(function(p10, p11)
	if p10 == "FlameExplosion" then
		local v49 = game:GetService("ReplicatedStorage").GameAssets.SpellAssets.FlameExplosion:Clone();
		l__Debris__2:AddItem(v49, 3);
		v49.Position = p11;
		v49.Parent = workspace.WorldData.Debris;
		v49.Explosion:Emit(60);
		v49.Impact:Play();
		return;
	end;
	if p10 ~= "ThunderExplosion" then
		if p10 == "FrostExplosion" then
			local v50 = game:GetService("ReplicatedStorage").GameAssets.SpellAssets.FrostExplosion:Clone();
			v50.Position = p11;
			v50.Parent = workspace.WorldData.Debris;
			l__Debris__2:AddItem(v50, 3);
			v50.Impact:Play();
		end;
		return;
	end;
	local v51 = game:GetService("ReplicatedStorage").GameAssets.SpellAssets.ThunderExplosion:Clone();
	l__Debris__2:AddItem(v51, 3);
	v51.Position = p11;
	v51.Parent = workspace.WorldData.Debris;
	v51.Explosion:Emit(45);
	v51.Impact:Play();
end);
while true do
	wait(0.15);
	local v52 = v5.HumanoidRootPart.Position or Vector3.new(0, 0, 0);
	local v53 = v8.Analyze((workspace:FindPartsInRegion3(Region3.new(v52 + Vector3.new(-6, -6, -6), v52 + Vector3.new(6, 6, 6)), v5, 10)));
	if not (not v53) and string.upper(v53.Name) ~= u4[1] or u4[2] ~= u6() and u7 == false then
		MarkArea(v53 and u5);
	end;
	if v5.Parent == nil then
		break;
	end;
	if v5.Humanoid.Health == 0 then
		break;
	end;
end;
