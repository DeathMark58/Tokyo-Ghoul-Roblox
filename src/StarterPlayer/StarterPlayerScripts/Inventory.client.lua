local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = game:GetService("Players").LocalPlayer

local character, humanoid, humanoidRootPart

local hotbar, inventory, backpack, bars, emotes

local hotbarList = {}
local inventoryList = {}

local emoteList = game:GetService("ReplicatedFirst").Animations.Emotes:GetChildren()

local selected = nil
local dragging = false

local ended = Instance.new("BindableEvent")

local function addItem(item)
	local ui = ReplicatedStorage.Item:Clone()
	ui.Text = item.Name
	local h = true
	for i = 1, 10, 1 do
		if (hotbarList[tostring(i)] == nil) then
			hotbarList[tostring(i)] = item
			ui.Parent = hotbar:FindFirstChild(tostring(i))
			ui.Parent.Visible = true
			h = false
			break
		end
	end
	if (h) then
		table.insert(inventoryList, item)
		ui.Parent = inventory.Frame
	end

	ui.MouseButton1Down:Connect(function(x, y)
		if (dragging) then
			return
		end
		local xDif = ui.AbsolutePosition.X - UserInputService:GetMouseLocation().X
		local yDif = ui.AbsolutePosition.Y - UserInputService:GetMouseLocation().Y + 36
		local oldIndex = nil
		for i = 1, 10, 1 do
			if (item == hotbarList[tostring(i)]) then
				oldIndex = i % 10
			end
		end
		local drag
		if (inventory.Visible) then
			dragging = true
			ui.Parent = hotbar.Parent
			drag = RunService.RenderStepped:Connect(function(dt)
				local mouseLocation = UserInputService:GetMouseLocation()
				ui.Position = UDim2.new(0, mouseLocation.X + xDif, 0, mouseLocation.Y + yDif)
			end)
		end

		local e
		e = ended.Event:Connect(function()
			local function stop()
				ui.Position = UDim2.new(0, 0, 0, 0)
				dragging = false
			end
			
			e:Disconnect()
			if (dragging) then
				drag:Disconnect()
			end
			local l = UserInputService:GetMouseLocation()
			if (l.X == x and l.Y == y or not dragging) then
				for i, v in pairs(character:GetChildren()) do
					if (v:IsA("Tool")) then
						v.Parent = player.Backpack
					end
				end
				
				if (selected == oldIndex) then
					selected = nil
				else
					selected = oldIndex
					item.Parent = character
				end
				if (oldIndex) then
					ui.Parent = hotbar[tostring(oldIndex)]
				else
					hotbarList[tostring(oldIndex)] = nil
					table.insert(inventoryList, item)
					ui.Parent = inventory.Frame
				end
				stop()
				return
			end
			local objects = player.PlayerGui:GetGuiObjectsAtPosition(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y - 36)
			local index = nil
			for i, v in pairs(objects) do
				if (v.Parent == hotbar) then
					index = v.Name
					break
				end
			end

			if (table.find(objects, inventory)) then
				if selected == oldIndex then
					selected = nil
				end
				hotbarList[tostring(oldIndex)] = nil
				stop()
				table.insert(inventoryList, item)
				ui.Parent = inventory.Frame
				return
			end
			
			if (not index) then
				stop()
				if (oldIndex) then
					ui.Parent = hotbar[oldIndex]
				else
					ui.Parent = inventory.Frame
				end
				return
			end
			
			selected = index
			
			if (hotbar[index]:FindFirstChild("Item")) then
				hotbar[index]["Item"].Parent = hotbar[tostring(oldIndex)]
			end
			hotbarList[tostring(oldIndex)] = hotbarList[index]
			hotbarList[index] = item
			ui.Parent = hotbar[index]
			
			stop()
		end)
	end)
end

local function set(c)
	table.clear(inventoryList)
	table.clear(hotbarList)
	character = c
	humanoid = character:WaitForChild("Humanoid")
	humanoidRootPart = character.HumanoidRootPart
	
	dragging = false

	hotbar = player.PlayerGui:WaitForChild("ScreenGui").Hotbar
	bars = player.PlayerGui:WaitForChild("Bars")
	inventory = player.PlayerGui:WaitForChild("Modals").Inventory
	emotes = player.PlayerGui.Modals.ScrollingFrame
	backpack = player:WaitForChild("Backpack")
	
	for i, v in pairs(emoteList) do
		local ui = emotes.TextButton:Clone()
		ui.Text = v.Name
		ui.Visible = true
	end
	
	for i, v in pairs(hotbar:GetChildren()) do
		if (v:IsA("Frame")) then
			local label = ReplicatedStorage.TextLabel:Clone()
			label.Text = v.Name
			label.Parent = v
			v.Visible = false
		end
	end
	
	for i, v in pairs(backpack:GetChildren()) do
		if (v:IsA("Tool")) then
			addItem(v)
		end
	end
	
	backpack.ChildAdded:Connect(function(child)
		if (table.find(inventoryList, child)) then
			return
		end
		local index = nil
		for i = 1, 10, 1 do
			if (child == hotbarList[tostring(i)]) then
				return
			end
		end

		addItem(child)
	end)
end

player.CharacterAdded:Connect(function(c)
	set(c)
end)

UserInputService.InputBegan:Connect(function(i, g)
	if (g) then
		return
	end
	local input = i.KeyCode.Name
	
	if (input == "X") then
		emotes.Visible = true
		emotes.Position = UDim2.new(0, UserInputService:GetMouseLocation().X, 0, UserInputService:GetMouseLocation().Y)
	end
	
	if (input == "Tab") then
		inventory.Visible = not inventory.Visible
		bars.Enabled = not bars.Enabled
		if (inventory.Visible) then
			for i, v in pairs(hotbar:GetChildren()) do
				if (v:IsA("Frame")) then
					v.Visible = true
				end
			end
		else
			for i, v in pairs(hotbar:GetChildren()) do
				if (v:IsA("Frame") and not v:FindFirstChild("Item")) then
					v.Visible = false
				end
			end
		end
		
		return
	end

	local keys = {"One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Zero"}
	local index = table.find(keys, input)
	if (index) then
		for i, v in pairs(character:GetChildren()) do
			if (v:IsA("Tool")) then
				v.Parent = player.Backpack
			end
		end

		index = index % 10
		if (selected == index) then
			selected = nil
		else 
			if hotbarList[tostring(index)] then
				selected = index
				hotbarList[tostring(selected)].Parent = character
			else
				selected = nil
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(i, g)
	if (i.UserInputType == Enum.UserInputType.MouseButton1) then
		ended:Fire()
	end
	
	if (i.KeyCode.Name == "X") then
		emotes.Visible = false
	end
end)