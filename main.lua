print('LOADED!!!')
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local flying = false
local speed = 50
local speedMultiplier = 3
local jumpPower = 50 -- default Roblox jump power
local flingPower = 150 -- self-fling launch strength
local spinning = false
local spinSpeed = 180 -- degrees per second
local invisible = false
local originalTransparencies = {}

local character, humanoid, currentRoot
local attachment, lv, ao

local guiParent = gethui and gethui() or game:GetService("CoreGui")

pcall(function()
	local old = guiParent:FindFirstChild("SimpleFlyUI")
	if old then old:Destroy() end
end)

-- ===================== MAIN FRAME =====================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleFlyUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.fromOffset(380, 230)
MainFrame.Position = UDim2.new(0.5, -190, 0.18, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 1
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 18)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 3
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Color = Color3.fromRGB(0, 200, 180)
MainStroke.Transparency = 0.25

local Title = Instance.new("TextLabel", MainFrame)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 18, 0, 10)
Title.Size = UDim2.new(1, -60, 0, 34)
Title.Font = Enum.Font.FredokaOne
Title.Text = "Benjamin's TOOLS"
Title.TextSize = 25
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 2

local UIGradient = Instance.new("UIGradient", Title)
UIGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 150, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 200)),
})

local SubTitle = Instance.new("TextLabel", MainFrame)
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.new(0, 18, 0, 40)
SubTitle.Size = UDim2.new(1, -20, 0, 20)
SubTitle.Font = Enum.Font.GothamBold
SubTitle.Text = "Press ( — ) To Minimaze"
SubTitle.TextSize = 11
SubTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.ZIndex = 2

local HideButton = Instance.new("TextButton", MainFrame)
HideButton.Size = UDim2.fromOffset(30, 30)
HideButton.Position = UDim2.new(1, -45, 0, 15)
HideButton.BackgroundTransparency = 1
HideButton.Text = "—"
HideButton.TextColor3 = Color3.new(1, 1, 1)
HideButton.TextSize = 18
HideButton.Font = Enum.Font.GothamBold
HideButton.ZIndex = 3

-- ===================== LIST MENU (LEFT SIDE) =====================

local ListFrame = Instance.new("ScrollingFrame", MainFrame)
ListFrame.Position = UDim2.new(0, 18, 0, 70)
ListFrame.Size = UDim2.new(0, 110, 0, 145)
ListFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
ListFrame.ZIndex = 2
ListFrame.ScrollBarThickness = 4
ListFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 12)

local ListLayout = Instance.new("UIListLayout", ListFrame)
ListLayout.Padding = UDim.new(0, 6)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ListPadding = Instance.new("UIPadding", ListFrame)
ListPadding.PaddingTop = UDim.new(0, 6)
ListPadding.PaddingLeft = UDim.new(0, 6)
ListPadding.PaddingRight = UDim.new(0, 6)

local function createListButton(name, order)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.LayoutOrder = order
	btn.Text = name
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
	btn.AutoButtonColor = false
	btn.ZIndex = 3
	btn.Parent = ListFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
	local stroke = Instance.new("UIStroke", btn)
	stroke.Thickness = 1.5
	stroke.Color = Color3.fromRGB(0, 255, 200)
	stroke.Transparency = 0.6
	return btn, stroke
end

local FlyListButton, FlyListStroke = createListButton("Fly", 1)
local SpeedListButton, SpeedListStroke = createListButton("Speed", 2)
local JumpListButton, JumpListStroke = createListButton("Jump", 3)
local FlingListButton, FlingListStroke = createListButton("Fling", 4)
local SpinListButton, SpinListStroke = createListButton("Spin", 5)
local InvisListButton, InvisListStroke = createListButton("Invisible", 6)

-- ===================== CONTENT AREA (RIGHT SIDE) =====================

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Position = UDim2.new(0, 142, 0, 70)
ContentFrame.Size = UDim2.new(0, 220, 0, 145)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex = 2

-- Fly panel
local FlyPanel = Instance.new("Frame", ContentFrame)
FlyPanel.Size = UDim2.new(1, 0, 1, 0)
FlyPanel.BackgroundTransparency = 1
FlyPanel.ZIndex = 2

local Toggle = Instance.new("TextButton", FlyPanel)
Toggle.Size = UDim2.new(1, 0, 0, 46)
Toggle.Position = UDim2.new(0, 0, 0, 0)
Toggle.Text = "Fly: OFF"
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 16
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Toggle.AutoButtonColor = false
Toggle.ZIndex = 3
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 12)

local ToggleStroke = Instance.new("UIStroke", Toggle)
ToggleStroke.Thickness = 2
ToggleStroke.Color = Color3.fromRGB(0, 255, 200)
ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local FlyHint = Instance.new("TextLabel", FlyPanel)
FlyHint.BackgroundTransparency = 1
FlyHint.Position = UDim2.new(0, 0, 0, 55)
FlyHint.Size = UDim2.new(1, 0, 0, 60)
FlyHint.Font = Enum.Font.Gotham
FlyHint.TextSize = 12
FlyHint.TextColor3 = Color3.fromRGB(190, 190, 190)
FlyHint.TextWrapped = true
FlyHint.TextXAlignment = Enum.TextXAlignment.Left
FlyHint.TextYAlignment = Enum.TextYAlignment.Top
FlyHint.Text = "WASD to move, Space to go up, Left Ctrl to go down."
FlyHint.ZIndex = 3

-- Speed panel
local SpeedPanel = Instance.new("Frame", ContentFrame)
SpeedPanel.Size = UDim2.new(1, 0, 1, 0)
SpeedPanel.BackgroundTransparency = 1
SpeedPanel.Visible = false
SpeedPanel.ZIndex = 2

local SpeedLabel = Instance.new("TextLabel", SpeedPanel)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0, 0, 0, 0)
SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextSize = 13
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Text = "Fly / Walk Speed"
SpeedLabel.ZIndex = 3

local SpeedBox = Instance.new("TextBox", SpeedPanel)
SpeedBox.Size = UDim2.new(1, 0, 0, 38)
SpeedBox.Position = UDim2.new(0, 0, 0, 24)
SpeedBox.Text = tostring(speed)
SpeedBox.PlaceholderText = "Input Speed..."
SpeedBox.Font = Enum.Font.GothamBold
SpeedBox.TextSize = 15
SpeedBox.TextColor3 = Color3.new(1, 1, 1)
SpeedBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
SpeedBox.ZIndex = 3
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 12)

local SpeedStroke = Instance.new("UIStroke", SpeedBox)
SpeedStroke.Thickness = 1.5
SpeedStroke.Color = Color3.fromRGB(100, 100, 100)
SpeedStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Jump panel
local JumpPanel = Instance.new("Frame", ContentFrame)
JumpPanel.Size = UDim2.new(1, 0, 1, 0)
JumpPanel.BackgroundTransparency = 1
JumpPanel.Visible = false
JumpPanel.ZIndex = 2

local JumpLabel = Instance.new("TextLabel", JumpPanel)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Position = UDim2.new(0, 0, 0, 0)
JumpLabel.Size = UDim2.new(1, 0, 0, 20)
JumpLabel.Font = Enum.Font.GothamBold
JumpLabel.TextSize = 13
JumpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
JumpLabel.TextXAlignment = Enum.TextXAlignment.Left
JumpLabel.Text = "Jump Power"
JumpLabel.ZIndex = 3

local JumpBox = Instance.new("TextBox", JumpPanel)
JumpBox.Size = UDim2.new(1, -90, 0, 38)
JumpBox.Position = UDim2.new(0, 0, 0, 24)
JumpBox.Text = tostring(jumpPower)
JumpBox.PlaceholderText = "Input Jump Power..."
JumpBox.Font = Enum.Font.GothamBold
JumpBox.TextSize = 15
JumpBox.TextColor3 = Color3.new(1, 1, 1)
JumpBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
JumpBox.ZIndex = 3
Instance.new("UICorner", JumpBox).CornerRadius = UDim.new(0, 12)

local JumpStroke = Instance.new("UIStroke", JumpBox)
JumpStroke.Thickness = 1.5
JumpStroke.Color = Color3.fromRGB(100, 100, 100)
JumpStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local JumpConfirm = Instance.new("TextButton", JumpPanel)
JumpConfirm.Size = UDim2.new(0, 80, 0, 38)
JumpConfirm.Position = UDim2.new(1, -80, 0, 24)
JumpConfirm.Text = "Confirm"
JumpConfirm.Font = Enum.Font.GothamBold
JumpConfirm.TextSize = 13
JumpConfirm.TextColor3 = Color3.new(1, 1, 1)
JumpConfirm.BackgroundColor3 = Color3.fromRGB(0, 150, 130)
JumpConfirm.AutoButtonColor = false
JumpConfirm.ZIndex = 3
Instance.new("UICorner", JumpConfirm).CornerRadius = UDim.new(0, 12)

local JumpConfirmStroke = Instance.new("UIStroke", JumpConfirm)
JumpConfirmStroke.Thickness = 1.5
JumpConfirmStroke.Color = Color3.fromRGB(0, 255, 200)
JumpConfirmStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local JumpStatus = Instance.new("TextLabel", JumpPanel)
JumpStatus.BackgroundTransparency = 1
JumpStatus.Position = UDim2.new(0, 0, 0, 68)
JumpStatus.Size = UDim2.new(1, 0, 0, 20)
JumpStatus.Font = Enum.Font.Gotham
JumpStatus.TextSize = 12
JumpStatus.TextColor3 = Color3.fromRGB(0, 255, 200)
JumpStatus.TextXAlignment = Enum.TextXAlignment.Left
JumpStatus.Text = ""
JumpStatus.ZIndex = 3

-- Fling panel (self only)
local FlingPanel = Instance.new("Frame", ContentFrame)
FlingPanel.Size = UDim2.new(1, 0, 1, 0)
FlingPanel.BackgroundTransparency = 1
FlingPanel.Visible = false
FlingPanel.ZIndex = 2

local FlingLabel = Instance.new("TextLabel", FlingPanel)
FlingLabel.BackgroundTransparency = 1
FlingLabel.Position = UDim2.new(0, 0, 0, 0)
FlingLabel.Size = UDim2.new(1, 0, 0, 20)
FlingLabel.Font = Enum.Font.GothamBold
FlingLabel.TextSize = 13
FlingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FlingLabel.TextXAlignment = Enum.TextXAlignment.Left
FlingLabel.Text = "Fling Power"
FlingLabel.ZIndex = 3

local FlingBox = Instance.new("TextBox", FlingPanel)
FlingBox.Size = UDim2.new(1, 0, 0, 38)
FlingBox.Position = UDim2.new(0, 0, 0, 24)
FlingBox.Text = tostring(flingPower)
FlingBox.PlaceholderText = "Input Fling Power..."
FlingBox.Font = Enum.Font.GothamBold
FlingBox.TextSize = 15
FlingBox.TextColor3 = Color3.new(1, 1, 1)
FlingBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
FlingBox.ZIndex = 3
Instance.new("UICorner", FlingBox).CornerRadius = UDim.new(0, 12)

local FlingStroke = Instance.new("UIStroke", FlingBox)
FlingStroke.Thickness = 1.5
FlingStroke.Color = Color3.fromRGB(100, 100, 100)
FlingStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local FlingButton = Instance.new("TextButton", FlingPanel)
FlingButton.Size = UDim2.new(1, 0, 0, 40)
FlingButton.Position = UDim2.new(0, 0, 0, 70)
FlingButton.Text = "FLING MYSELF"
FlingButton.Font = Enum.Font.GothamBold
FlingButton.TextSize = 15
FlingButton.TextColor3 = Color3.new(1, 1, 1)
FlingButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
FlingButton.AutoButtonColor = false
FlingButton.ZIndex = 3
Instance.new("UICorner", FlingButton).CornerRadius = UDim.new(0, 12)

local FlingButtonStroke = Instance.new("UIStroke", FlingButton)
FlingButtonStroke.Thickness = 2
FlingButtonStroke.Color = Color3.fromRGB(255, 100, 100)
FlingButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local FlingHint = Instance.new("TextLabel", FlingPanel)
FlingHint.BackgroundTransparency = 1
FlingHint.Position = UDim2.new(0, 0, 0, 115)
FlingHint.Size = UDim2.new(1, 0, 0, 30)
FlingHint.Font = Enum.Font.Gotham
FlingHint.TextSize = 11
FlingHint.TextColor3 = Color3.fromRGB(190, 190, 190)
FlingHint.TextWrapped = true
FlingHint.TextXAlignment = Enum.TextXAlignment.Left
FlingHint.Text = "Launches your own character into the air."
FlingHint.ZIndex = 3

-- Spin panel (self only)
local SpinPanel = Instance.new("Frame", ContentFrame)
SpinPanel.Size = UDim2.new(1, 0, 1, 0)
SpinPanel.BackgroundTransparency = 1
SpinPanel.Visible = false
SpinPanel.ZIndex = 2

local SpinToggle = Instance.new("TextButton", SpinPanel)
SpinToggle.Size = UDim2.new(1, 0, 0, 46)
SpinToggle.Position = UDim2.new(0, 0, 0, 0)
SpinToggle.Text = "Spin: OFF"
SpinToggle.Font = Enum.Font.GothamBold
SpinToggle.TextSize = 16
SpinToggle.TextColor3 = Color3.new(1, 1, 1)
SpinToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
SpinToggle.AutoButtonColor = false
SpinToggle.ZIndex = 3
Instance.new("UICorner", SpinToggle).CornerRadius = UDim.new(0, 12)

local SpinToggleStroke = Instance.new("UIStroke", SpinToggle)
SpinToggleStroke.Thickness = 2
SpinToggleStroke.Color = Color3.fromRGB(0, 255, 200)
SpinToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local SpinSpeedLabel = Instance.new("TextLabel", SpinPanel)
SpinSpeedLabel.BackgroundTransparency = 1
SpinSpeedLabel.Position = UDim2.new(0, 0, 0, 55)
SpinSpeedLabel.Size = UDim2.new(1, 0, 0, 18)
SpinSpeedLabel.Font = Enum.Font.GothamBold
SpinSpeedLabel.TextSize = 12
SpinSpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpinSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpinSpeedLabel.Text = "Spin Speed (deg/sec)"
SpinSpeedLabel.ZIndex = 3

local SpinSpeedBox = Instance.new("TextBox", SpinPanel)
SpinSpeedBox.Size = UDim2.new(1, 0, 0, 34)
SpinSpeedBox.Position = UDim2.new(0, 0, 0, 75)
SpinSpeedBox.Text = tostring(spinSpeed)
SpinSpeedBox.PlaceholderText = "Input Spin Speed..."
SpinSpeedBox.Font = Enum.Font.GothamBold
SpinSpeedBox.TextSize = 14
SpinSpeedBox.TextColor3 = Color3.new(1, 1, 1)
SpinSpeedBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
SpinSpeedBox.ZIndex = 3
Instance.new("UICorner", SpinSpeedBox).CornerRadius = UDim.new(0, 12)

local SpinSpeedStroke = Instance.new("UIStroke", SpinSpeedBox)
SpinSpeedStroke.Thickness = 1.5
SpinSpeedStroke.Color = Color3.fromRGB(100, 100, 100)
SpinSpeedStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Invisible panel (self only)
local InvisPanel = Instance.new("Frame", ContentFrame)
InvisPanel.Size = UDim2.new(1, 0, 1, 0)
InvisPanel.BackgroundTransparency = 1
InvisPanel.Visible = false
InvisPanel.ZIndex = 2

local InvisToggle = Instance.new("TextButton", InvisPanel)
InvisToggle.Size = UDim2.new(1, 0, 0, 46)
InvisToggle.Position = UDim2.new(0, 0, 0, 0)
InvisToggle.Text = "Invisible: OFF"
InvisToggle.Font = Enum.Font.GothamBold
InvisToggle.TextSize = 16
InvisToggle.TextColor3 = Color3.new(1, 1, 1)
InvisToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
InvisToggle.AutoButtonColor = false
InvisToggle.ZIndex = 3
Instance.new("UICorner", InvisToggle).CornerRadius = UDim.new(0, 12)

local InvisToggleStroke = Instance.new("UIStroke", InvisToggle)
InvisToggleStroke.Thickness = 2
InvisToggleStroke.Color = Color3.fromRGB(0, 255, 200)
InvisToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local InvisHint = Instance.new("TextLabel", InvisPanel)
InvisHint.BackgroundTransparency = 1
InvisHint.Position = UDim2.new(0, 0, 0, 55)
InvisHint.Size = UDim2.new(1, 0, 0, 60)
InvisHint.Font = Enum.Font.Gotham
InvisHint.TextSize = 12
InvisHint.TextColor3 = Color3.fromRGB(190, 190, 190)
InvisHint.TextWrapped = true
InvisHint.TextXAlignment = Enum.TextXAlignment.Left
InvisHint.TextYAlignment = Enum.TextYAlignment.Top
InvisHint.Text = "Hides your own character's parts and accessories client-side settings permitting."
InvisHint.ZIndex = 3

-- ===================== LIST SWITCHING LOGIC =====================

local panels = { Fly = FlyPanel, Speed = SpeedPanel, Jump = JumpPanel, Fling = FlingPanel, Spin = SpinPanel, Invisible = InvisPanel }
local listButtons = { Fly = FlyListButton, Speed = SpeedListButton, Jump = JumpListButton, Fling = FlingListButton, Spin = SpinListButton, Invisible = InvisListButton }
local listStrokes = { Fly = FlyListStroke, Speed = SpeedListStroke, Jump = JumpListStroke, Fling = FlingListStroke, Spin = SpinListStroke, Invisible = InvisListStroke }

local function selectTab(name)
	for key, panel in pairs(panels) do
		panel.Visible = (key == name)
		local btn = listButtons[key]
		local stroke = listStrokes[key]
		if key == name then
			btn.BackgroundColor3 = Color3.fromRGB(0, 90, 80)
			stroke.Transparency = 0
		else
			btn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
			stroke.Transparency = 0.6
		end
	end
end

FlyListButton.MouseButton1Click:Connect(function() selectTab("Fly") end)
SpeedListButton.MouseButton1Click:Connect(function() selectTab("Speed") end)
JumpListButton.MouseButton1Click:Connect(function() selectTab("Jump") end)
FlingListButton.MouseButton1Click:Connect(function() selectTab("Fling") end)
SpinListButton.MouseButton1Click:Connect(function() selectTab("Spin") end)
InvisListButton.MouseButton1Click:Connect(function() selectTab("Invisible") end)

selectTab("Fly") -- default tab shown on load

-- ===================== MINIMIZE BUTTON (UNCHANGED BEHAVIOR) =====================

local Mini = Instance.new("ImageButton", ScreenGui)
Mini.Visible = false
Mini.Active = true
Mini.Size = UDim2.fromOffset(50, 50)
Mini.Position = UDim2.new(0.5, -25, 0.05, 0)
Mini.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Mini.Image = "rbxassetid://3926307971"
Mini.ImageRectOffset = Vector2.new(324, 364)
Mini.ImageRectSize = Vector2.new(36, 36)
Mini.ImageColor3 = Color3.new(1, 1, 1)
Mini.ZIndex = 10
Instance.new("UICorner", Mini).CornerRadius = UDim.new(1, 0)

local MiniStroke = Instance.new("UIStroke", Mini)
MiniStroke.Color = Color3.fromRGB(0, 255, 200)
MiniStroke.Thickness = 2

local function setupDrag(gui)
	local dragging, dragStart, startPos
	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			local cam = workspace.CurrentCamera
			local screenSize = cam.ViewportSize
			local newX = startPos.X.Offset + delta.X
			local newY = startPos.Y.Offset + delta.Y
			newX = math.clamp(newX, 0, screenSize.X - gui.AbsoluteSize.X)
			newY = math.clamp(newY, 0, screenSize.Y - gui.AbsoluteSize.Y)
			gui.Position = UDim2.new(0, newX, 0, newY)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

setupDrag(MainFrame)
setupDrag(Mini)

HideButton.MouseButton1Click:Connect(function()
	local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Size = UDim2.fromOffset(0, 0) })
	tween:Play()
	tween.Completed:Wait()
	MainFrame.Visible = false
	Mini.Visible = true
	Mini.Position = UDim2.new(0, MainFrame.AbsolutePosition.X, 0, MainFrame.AbsolutePosition.Y)
	Mini.Size = UDim2.fromOffset(0, 0)
	TweenService:Create(Mini, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(50, 50) }):Play()
end)

Mini.MouseButton1Click:Connect(function()
	local tweenMini = TweenService:Create(Mini, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Size = UDim2.fromOffset(0, 0) })
	tweenMini:Play()
	tweenMini.Completed:Wait()
	Mini.Visible = false
	MainFrame.Visible = true
	MainFrame.Position = UDim2.new(0, Mini.AbsolutePosition.X, 0, Mini.AbsolutePosition.Y)
	MainFrame.Size = UDim2.fromOffset(0, 0)
	TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(380, 230) }):Play()
end)

-- ===================== FLY LOGIC (UNCHANGED) =====================

local function stopFly()
	flying = false
	if humanoid then humanoid.PlatformStand = false end
	if attachment then attachment:Destroy() end
	attachment, lv, ao, currentRoot = nil, nil, nil, nil
	Toggle.Text = "Fly: OFF"
end

local function startFly()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.SeatPart then
		currentRoot = humanoid.SeatPart
	else
		currentRoot = character:FindFirstChild("HumanoidRootPart")
	end

	if not currentRoot then return end
	if attachment then attachment:Destroy() end

	attachment = Instance.new("Attachment", currentRoot)
	lv = Instance.new("LinearVelocity", currentRoot)
	lv.Attachment0 = attachment
	lv.MaxForce = math.huge
	lv.VectorVelocity = Vector3.zero
	ao = Instance.new("AlignOrientation", currentRoot)
	ao.Attachment0 = attachment
	ao.MaxTorque = math.huge
	ao.Responsiveness = 200
	ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
	flying = true
	Toggle.Text = "Fly: ON"
end

Toggle.MouseButton1Click:Connect(function()
	if flying then stopFly() else startFly() end
end)

-- ===================== SPEED LOGIC (UNCHANGED) =====================

SpeedBox.FocusLost:Connect(function()
	speed = tonumber(SpeedBox.Text) or 50
	SpeedBox.Text = tostring(speed)
end)

-- ===================== JUMP LOGIC (NEW) =====================

local function applyJumpPower()
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	-- Works whether the game uses classic JumpPower or the newer JumpHeight property
	pcall(function()
		hum.UseJumpPower = true
		hum.JumpPower = jumpPower
	end)
end

local function confirmJumpPower()
	jumpPower = tonumber(JumpBox.Text) or jumpPower
	JumpBox.Text = tostring(jumpPower)
	applyJumpPower()
	JumpStatus.Text = "Applied: " .. tostring(jumpPower)
	task.delay(1.5, function()
		if JumpStatus.Text == "Applied: " .. tostring(jumpPower) then
			JumpStatus.Text = ""
		end
	end)
end

JumpBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		confirmJumpPower()
	end
end)

JumpConfirm.MouseButton1Click:Connect(confirmJumpPower)

-- ===================== FLING LOGIC (SELF ONLY, NEW) =====================

local function selfFling()
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- Random horizontal direction + strong upward component
	local randomAngle = math.random() * math.pi * 2
	local direction = Vector3.new(math.cos(randomAngle), 0, math.sin(randomAngle))
	local launchVelocity = (direction * flingPower) + Vector3.new(0, flingPower * 1.2, 0)

	local flingAttachment = Instance.new("Attachment", root)
	local flingVelocity = Instance.new("LinearVelocity", root)
	flingVelocity.Attachment0 = flingAttachment
	flingVelocity.MaxForce = math.huge
	flingVelocity.VectorVelocity = launchVelocity

	-- Clean up shortly after so normal physics/fly/movement resumes
	task.delay(0.35, function()
		if flingVelocity then flingVelocity:Destroy() end
		if flingAttachment then flingAttachment:Destroy() end
	end)
end

FlingButton.MouseButton1Click:Connect(selfFling)

FlingBox.FocusLost:Connect(function()
	flingPower = tonumber(FlingBox.Text) or flingPower
	FlingBox.Text = tostring(flingPower)
end)

-- ===================== SPIN LOGIC (SELF ONLY, NEW) =====================

local function setSpin(state)
	spinning = state
	SpinToggle.Text = state and "Spin: ON" or "Spin: OFF"
end

SpinToggle.MouseButton1Click:Connect(function()
	setSpin(not spinning)
end)

SpinSpeedBox.FocusLost:Connect(function()
	spinSpeed = tonumber(SpinSpeedBox.Text) or spinSpeed
	SpinSpeedBox.Text = tostring(spinSpeed)
end)

-- ===================== INVISIBLE LOGIC (SELF ONLY, NEW) =====================

local function setInvisible(state)
	local char = player.Character
	if not char then return end

	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") or part:IsA("Decal") then
			if state then
				originalTransparencies[part] = part.Transparency
				part.Transparency = 1
			else
				part.Transparency = originalTransparencies[part] or 0
			end
		end
	end

	invisible = state
	InvisToggle.Text = state and "Invisible: ON" or "Invisible: OFF"
end

InvisToggle.MouseButton1Click:Connect(function()
	setInvisible(not invisible)
end)

-- ===================== PLAYER MODULE / MOVEMENT =====================

local PlayerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))
local Controls = PlayerModule:GetControls()

RunService.RenderStepped:Connect(function(dt)
	local t = tick()
	UIGradient.Offset = Vector2.new(math.sin(t * 2) * 1, 0)

	if spinning then
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root then
			root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed) * dt, 0)
		end
	end

	if flying and currentRoot and lv and ao then
		if not currentRoot.Parent then stopFly() return end

		-- PENDEKETSI DUDUK: Biar gak turun dari mobil
		if humanoid and humanoid.SeatPart then
			humanoid.PlatformStand = false
		else
			humanoid.PlatformStand = true
		end

		local cam = workspace.CurrentCamera
		local moveVector = Controls:GetMoveVector()
		local direction = (cam.CFrame.LookVector * -moveVector.Z) + (cam.CFrame.RightVector * moveVector.X)
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction += Vector3.new(0, -1, 0) end
		lv.VectorVelocity = (direction.Magnitude > 0) and (direction.Unit * (speed * speedMultiplier)) or Vector3.zero
		ao.CFrame = cam.CFrame
	end
end)

player.CharacterAdded:Connect(function()
	task.wait(1)
	applyJumpPower()
	if flying then startFly() end
	if invisible then
		originalTransparencies = {}
		setInvisible(true)
	end
end)

-- Apply jump power immediately if character already exists
applyJumpPower()
