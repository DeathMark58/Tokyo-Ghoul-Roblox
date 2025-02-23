local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Animations = ReplicatedFirst.Animations

local baseAnims =
	Animations.Base

baseAnims.Pain1:SetAttribute("Priority", "Action3")
baseAnims.Pain2:SetAttribute("Priority", "Action3")
baseAnims.Pain3:SetAttribute("Priority", "Action3")

baseAnims["Back Roll"]:SetAttribute("Priority", "Action2")
baseAnims["Forward Roll"]:SetAttribute("Priority", "Action2")
baseAnims["Left Roll"]:SetAttribute("Priority", "Action2")
baseAnims["Right Roll"]:SetAttribute("Priority", "Action2")
baseAnims["Roll Cancel"]:SetAttribute("Priority", "Action3")


baseAnims["Carry"]:SetAttribute("Priority", "Action4")
baseAnims["Carried"]:SetAttribute("Priority", "Action4")

baseAnims["Sliding"]:SetAttribute("Priority", "Action4")

for i, v in pairs(Animations:GetChildren()) do
	if (v:GetAttribute("Type") == "Weapon") then
		v.DefenderParry:SetAttribute("Priority", "Action3")
		v.Parry:SetAttribute("Priority", "Action3")
		v.Block:SetAttribute("Priority", "Action2")
		v.Parried:SetAttribute("Priority", "Action3")
		v.Uppercut:SetAttribute("Priority", "Action4")
		
		v.Swing1:SetAttribute("Priority", "Action4")
		v.Swing2:SetAttribute("Priority", "Action4")
		v.Swing3:SetAttribute("Priority", "Action4")
		v.Swing4:SetAttribute("Priority", "Action4")
		v.Swing5:SetAttribute("Priority", "Action4")
		
		v.Aerial:SetAttribute("Priority", "Action4")
		v.RunAttack:SetAttribute("Priority", "Action4")
		
		v.Critical:SetAttribute("Priority", "Action4")
	end
	
end