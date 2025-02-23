-- Decompiled with the Synapse X Luau decompiler.

local v1 = {};
local l__AreaList__1 = script.Parent.Parent.AreaList;
function v1.Analyze(p1)
	for v2, v3 in pairs(p1) do
		if v3.Name == "Ocean" then
			return l__AreaList__1["Open Sea"];
		end;
		if v3.Name == "OceanArea" then
			return l__AreaList__1["Open Sea"];
		end;
		if v3.Name == "MeteorArea" then
			return l__AreaList__1["Meteor Isle"];
		end;
		if v3.Name == "PeterArea" then
			return l__AreaList__1["The Peter Shrine"];
		end;
	end;
end;
return v1;
