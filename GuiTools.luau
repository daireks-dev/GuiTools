--Imports:
local PreciseUDim2 = require(script.PreciseUDim2)

local GuiUtils = {}

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
function GuiUtils.Reparent(guiObject: GuiObject, newParent: Instance)
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
function GuiUtils.SetAnchorPoint(guiObject, desiredAnchor)
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
function GuiUtils.CenterOn(guiObject: GuiObject, targetGuiObject: GuiObject)
	local oldAnchor = guiObject.AnchorPoint
	GuiUtils.SetAnchorPoint(guiObject, Vector2.new(0.5, 0.5))
	
	local oldParent = guiObject.Parent
	local tempParent = targetGuiObject
	
	GuiUtils.Reparent(guiObject, tempParent)
	guiObject.Position = UDim2.new(0.5, 0, 0.5, 0)
	
	GuiUtils.Reparent(guiObject, oldParent)
	GuiUtils.SetAnchorPoint(guiObject, oldAnchor)
end

return GuiUtils
