## `Reparent()`

* parameters: guiObject: GuiObject, parent: Instance
* returns: nil

Reparents GuiObjects without changing their current size and position

```lua
local GuiTools = require(path.to.GuiTools)

local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(0.3, 0.3)
frame.Position = UDim2.fromScale(0.4, 0.4)
frame.BackgroundColor3 = Color3.new(1, 0, 0)
frame.Parent = script.Parent

local newParent = Instance.new("ImageLabel")
newParent.Size = UDim2.fromScale(1, 1)
newParent.BackgroundTransparency = 0.5
newParent.Parent = script.Parent

GuiTools.Reparent(frame, newParent)
```

## `SetAnchorPoint()`

* parameters: guiObject: GuiObject, newAnchorPoint: Vector2
* returns: nil

Sets the AnchorPoint of GuiObject without changing its position

```lua
local GuiTools = require(path.to.GuiTools)

local imageButton = Instance.new("ImageButton")
imageButton.Size = UDim2.fromOffset(100, 50)
imageButton.Position = UDim2.fromScale(0.5, 0.5)
imageButton.AnchorPoint = Vector2.new(0, 0)
imageButton.BackgroundColor3 = Color3.new(0, 0.5, 1)
imageButton.Parent = script.Parent

local newAnchorPoint = Vector2.new(0.5, 0.5)
GuiTools.SetAnchorPoint(imageButton, newAnchorPoint)
```

## `CenterOn()`

* parameters: guiObject: GuiObject, targetGuiObject: GuiObject
* returns: nil

Positions the given GuiObject on the center of the targetGuiObject. **Does not change its parent

```lua
local GuiTools = require(path.to.GuiTools)

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(200, 100)
frame.Position = UDim2.fromScale(0.4, 0.4)
frame.BackgroundColor3 = Color3.new(0, 1, 0)
frame.Parent = script.Parent

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.fromOffset(100, 30)
textLabel.BackgroundColor3 = Color3.new(1, 1, 0)
textLabel.Text = "Centered!"
textLabel.Parent = script.Parent

GuiTools.CenterOn(textLabel, frame)
```
