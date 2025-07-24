--This is basically just UDim2 but retains decimal precision when converting between offset and scale
local PreciseUDim2 = {}
PreciseUDim2.__index = PreciseUDim2

--Constructors:
function PreciseUDim2.new(scaleX, offsetX, scaleY, offsetY)
	local obj =  setmetatable({}, PreciseUDim2)
	obj.X = {Scale = scaleX, Offset = offsetX}
	obj.Y = {Scale = scaleY, Offset = offsetY}
	return obj
end

function PreciseUDim2.FromUDim2(udim2: UDim2)
	return PreciseUDim2.new(udim2.X.Scale, udim2.X.Offset, udim2.Y.Scale, udim2.Y.Offset)
end

function PreciseUDim2:ToUDim2()
	return UDim2.new(self.X.Scale, self.X.Offset, self.Y.Scale, self.Y.Offset)
end

-- Operator Overloads:
function PreciseUDim2.__add(a, b)
	return PreciseUDim2.new(a.X.Scale + b.X.Scale, a.X.Offset + b.X.Offset, a.Y.Scale + b.Y.Scale, a.Y.Offset + b.Y.Offset)
end

function PreciseUDim2.__sub(a, b)
	return PreciseUDim2.new(a.X.Scale - b.X.Scale, a.X.Offset - b.X.Offset, a.Y.Scale - b.Y.Scale, a.Y.Offset - b.Y.Offset)
end

--Conversion:
function PreciseUDim2:ConvertToScaleRelativeTo(container: GuiObject)
	local scaleX = self.X.Scale + (self.X.Offset / container.AbsoluteSize.X)
	local scaleY = self.Y.Scale + (self.Y.Offset / container.AbsoluteSize.Y)

	return PreciseUDim2.new(scaleX, 0, scaleY, 0)
end

function PreciseUDim2:ConvertToOffsetRelativeTo(container: GuiObject)
	local offsetX = self.X.Scale * container.AbsoluteSize.X + self.X.Offset
	local offsetY = self.Y.Scale * container.AbsoluteSize.Y + self.Y.Offset

	return PreciseUDim2.new(0, offsetX, 0, offsetY)
end


return PreciseUDim2
