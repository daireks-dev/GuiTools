--Imports:
local PreciseUDim2 = require(script.PreciseUDim2)

local GuiTools = {}

--Private Function: Finds the nearest container that affects GUI layout
local function GetValidGuiParent(parent: Instance): Instance
	if parent:IsA("GuiObject") or parent:IsA("ScreenGui") then
		return parent
	else
		local foundParent = parent:FindFirstAncestorWhichIsA("GuiObject")
		assert(foundParent, "No ancestor of type GuiObject could be found for " ..  tostring(parent))
		return foundParent
	end
end

--Public Function: Reparents GuiObjects without changing its current size and position 
function GuiTools.Reparent(guiObject: GuiObject, newParent: Instance)
	--Get Parents of type GuiObject or Nearest Ancestors of type GuiObject
	local originalParent = GetValidGuiParent(guiObject.Parent)
	local newParent = GetValidGuiParent(newParent)

	-- Convert to offset-only PreciseUDim2 based on current parent
	local newSize = PreciseUDim2.FromUDim2(guiObject.Size):ConvertToOffsetRelativeTo(originalParent)
	local newPosition = PreciseUDim2.FromUDim2(guiObject.Position):ConvertToOffsetRelativeTo(originalParent)

	guiObject.Size = newSize:ToUDim2()
	guiObject.Position = newPosition:ToUDim2()

	-- Save old absolute values
	local oldAbsSize = guiObject.AbsoluteSize
	local oldAbsPosition = guiObject.AbsolutePosition

	-- Reparent
	guiObject.Parent = newParent
	local newAbsSize = guiObject.AbsoluteSize
	local newAbsPosition = guiObject.AbsolutePosition

	-- Calculate deltas
	local deltaSize = oldAbsSize - newAbsSize
	local deltaPos = oldAbsPosition - newAbsPosition

	-- Add deltas to offset
	newSize = newSize + PreciseUDim2.new(0, deltaSize.X, 0, deltaSize.Y)
	newPosition = newPosition + PreciseUDim2.new(0, deltaPos.X, 0, deltaPos.Y)

	-- Convert to scale relative to new parent
	local finalSize = newSize:ConvertToScaleRelativeTo(newParent)
	local finalPos = newPosition:ConvertToScaleRelativeTo(newParent)

	-- Apply to guiObject
	guiObject.Size = finalSize:ToUDim2()
	guiObject.Position = finalPos:ToUDim2()
end

--Public Function: Sets anchor point without changing position (Credit: IDoLua on Roblox Devforum)
function GuiTools.SetAnchorPoint(guiObject, desiredAnchor)
	local parent = GetValidGuiParent(guiObject.parent)
	local parentSize = parent.AbsoluteSize

	local parentPosition = parent.AbsolutePosition
	local childSize = guiObject.AbsoluteSize
	local childPosition = guiObject.AbsolutePosition

	childPosition = childPosition - parentPosition

	local correctionOffsetX = childSize.X * desiredAnchor.X
	local correctionOffsetY = childSize.Y * desiredAnchor.Y

	local correctedUDim2 = UDim2.fromScale((childPosition.X + correctionOffsetX) / parentSize.X, (childPosition.Y + correctionOffsetY) / parentSize.Y)
	guiObject.AnchorPoint = desiredAnchor
	guiObject.Position = correctedUDim2
end

--Public Function: Positions the given GuiObject in the center of target. Does not change parent
function GuiTools.CenterOn(guiObject: GuiObject, targetGuiObject: GuiObject)
	local oldAnchor = guiObject.AnchorPoint
	GuiTools.SetAnchorPoint(guiObject, Vector2.new(0.5, 0.5))
	
	local oldParent = guiObject.Parent
	local tempParent = targetGuiObject
	
	GuiTools.Reparent(guiObject, tempParent)
	guiObject.Position = UDim2.new(0.5, 0, 0.5, 0)
	
	GuiTools.Reparent(guiObject, oldParent)
	GuiTools.SetAnchorPoint(guiObject, oldAnchor)
end

function GuiTools.GetAbsolutePosition(guiObject: GuiObject, rootFrame: GuiObject): Vector2
	local position = Vector2.zero
	local current = guiObject

	while current and current:IsA("GuiObject") and current ~= rootFrame do
		local parent = current.Parent
		local parentSize = parent:IsA("GuiObject") and parent.AbsoluteSize or current.Parent.AbsoluteSize

		-- Add the position offset relative to the parent
		position += Vector2.new(
			current.Position.X.Scale * parentSize.X + current.Position.X.Offset,
			current.Position.Y.Scale * parentSize.Y + current.Position.Y.Offset
		)

		-- Subtract the anchor point offset
		local anchorOffset = Vector2.new(
			current.AbsoluteSize.X * current.AnchorPoint.X,
			current.AbsoluteSize.Y * current.AnchorPoint.Y
		)

		position -= anchorOffset

		current = parent
	end

	return position
end

--Allows you to retrieve absolute pos/size data from gui in non-rendered settings.
--Root object represents the "ScreenGui" aka the container that holds all your GuiObjects
--"guiObject" is the object you want to retrieve the data for
function GuiTools.SimulateAbsolutes(guiObject: GuiObject, rootObject: GuiObject): (Vector2, Vector2)
	--Data Tracking:
	local order = {guiObject}
	local info = {
		[rootObject] = {
			["AbsolutePosition"] = Vector2.new(0,0),
			["AbsoluteSize"] = Vector2.new(1000, 1000), --Can be whatever fits for you
		}
	}

	--Determine GuiObject order:
	local parent: Instance = guiObject.Parent
	while parent ~= rootObject.Parent do
		table.insert(order, parent)
		parent = parent.Parent
	end

	--Ignore non-GuiObject instances:
	local filteredOrder = {}
	for index, instance: Instance in ipairs(order) do
		if instance:IsA("GuiObject") then
			table.insert(filteredOrder, instance)
		end
	end
	
	order = filteredOrder

	--Descend Chain, Calculating Absolute Pos + Size for each:
	for i = #order - 1, 1, -1 do
		local parentObject = order[i + 1]
		local currentObject = order[i]

		local parentAbsPosition = info[parentObject]["AbsolutePosition"]
		local parentAbsSize = info[parentObject]["AbsoluteSize"]

		local currentAbsSize = Vector2.new(
			currentObject.Size.X.Scale * parentAbsSize.X + currentObject.Size.X.Offset,
			currentObject.Size.Y.Scale * parentAbsSize.Y + currentObject.Size.Y.Offset
		)

		local currentPosition = Vector2.new(
			currentObject.Position.X.Scale * parentAbsSize.X + parentAbsPosition.X + currentObject.Position.X.Offset, 
			currentObject.Position.Y.Scale * parentAbsSize.Y + parentAbsPosition.Y + currentObject.Position.Y.Offset
		)

		local anchorOffset = Vector2.new(
			currentObject.AnchorPoint.X * currentAbsSize.X,
			currentObject.AnchorPoint.Y * currentAbsSize.Y
		)

		local currentAbsPosition = currentPosition - anchorOffset

		info[currentObject] = {
			["AbsolutePosition"] = currentAbsPosition,
			["AbsoluteSize"] = currentAbsSize
		}
	end

	return info[guiObject]["AbsolutePosition"], info[guiObject]["AbsoluteSize"]
end

return GuiTools
