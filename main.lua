-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local guiParent = gethui and gethui() or CoreGui

-- Clean up old GUI if it exists
if guiParent:FindFirstChild("SimpleFlyUI") then
    guiParent.SimpleFlyUI:Destroy()
end

-- Variables & Configurations
local flying = false
local speed = 50
local speedMultiplier = 3
local jumpPower = 50 
local spinning = false
local spinSpeed = 18000 
local invisible = false
local noclip = false -- Added Noclip state
local originalTransparencies = {}

local SelectedTargets = {}
local PlayerCheckboxes = {}
local FlingActive = false

local attachment, lv, ao

-- ===================== MAIN UI FRAME =====================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleFlyUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.fromOffset(380, 250)
MainFrame.Position = UDim2.new(0.5, -190, 0.18, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 18)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 3
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Color = Color3.fromRGB(255, 0, 0)
MainStroke.Transparency = 0.25

local Title = Instance.new("TextLabel", MainFrame)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 18, 0, 10)
Title.Size = UDim2.new(1, -60, 0, 34)
Title.Font = Enum.Font.FredokaOne
Title.Text = "Brco TOOLS"
Title.TextSize = 25
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextXAlignment = Enum.TextXAlignment.Left

local UIGradient = Instance.new("UIGradient", Title)
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 128, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
})

local SubTitle = Instance.new("TextLabel", MainFrame)
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.new(0, 18, 0, 40)
SubTitle.Size = UDim2.new(1, -20, 0, 20)
SubTitle.Font = Enum.Font.GothamBold
SubTitle.Text = "Press ( — ) To Minimize"
SubTitle.TextSize = 11
SubTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
SubTitle.TextXAlignment = Enum.TextXAlignment.Left

local HideButton = Instance.new("TextButton", MainFrame)
HideButton.Size = UDim2.fromOffset(30, 30)
HideButton.Position = UDim2.new(1, -45, 0, 15)
HideButton.BackgroundTransparency = 1
HideButton.Text = "—"
HideButton.TextColor3 = Color3.new(1, 1, 1)
HideButton.TextSize = 18
HideButton.Font = Enum.Font.GothamBold

-- ===================== LIST MENU (LEFT SIDE) =====================

local ListFrame = Instance.new("ScrollingFrame", MainFrame)
ListFrame.Position = UDim2.new(0, 18, 0, 70)
ListFrame.Size = UDim2.new(0, 110, 0, 165)
ListFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
ListFrame.ScrollBarThickness = 4
ListFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
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
    btn.Parent = ListFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Transparency = 0.6
    return btn, stroke
end

local FlyListButton, FlyListStroke = createListButton("Fly", 1)
local SpeedListButton, SpeedListStroke = createListButton("Speed", 2)
local JumpListButton, JumpListStroke = createListButton("Jump", 3)
local FlingListButton, FlingListStroke = createListButton("Fling", 4)
local SpinListButton, SpinListStroke = createListButton("Spin", 5)
local InvisListButton, InvisListStroke = createListButton("Invisible", 6)
local NoclipListButton, NoclipListStroke = createListButton("Noclip", 7) -- Added Noclip Button

-- ===================== CONTENT AREA (RIGHT SIDE) =====================

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Position = UDim2.new(0, 142, 0, 70)
ContentFrame.Size = UDim2.new(0, 220, 0, 165)
ContentFrame.BackgroundTransparency = 1

-- Fly Panel
local FlyPanel = Instance.new("Frame", ContentFrame)
FlyPanel.Size = UDim2.new(1, 0, 1, 0)
FlyPanel.BackgroundTransparency = 1

local Toggle = Instance.new("TextButton", FlyPanel)
Toggle.Size = UDim2.new(1, 0, 0, 46)
Toggle.Text = "Fly: OFF"
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 16
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Toggle.AutoButtonColor = false
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 12)
local ToggleStroke = Instance.new("UIStroke", Toggle)
ToggleStroke.Thickness = 2
ToggleStroke.Color = Color3.fromRGB(255, 0, 0)

local FlyHint = Instance.new("TextLabel", FlyPanel)
FlyHint.BackgroundTransparency = 1
FlyHint.Position = UDim2.new(0, 0, 0, 55)
FlyHint.Size = UDim2.new(1, 0, 0, 60)
FlyHint.Font = Enum.Font.Gotham
FlyHint.TextSize = 12
FlyHint.TextColor3 = Color3.fromRGB(190, 190, 190)
FlyHint.TextWrapped = true
FlyHint.TextXAlignment = Enum.TextXAlignment.Left
FlyHint.Text = "WASD to move, Space to go up, Left Ctrl to go down."

-- Speed Panel
local SpeedPanel = Instance.new("Frame", ContentFrame)
SpeedPanel.Size = UDim2.new(1, 0, 1, 0)
SpeedPanel.BackgroundTransparency = 1
SpeedPanel.Visible = false

local SpeedLabel = Instance.new("TextLabel", SpeedPanel)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextSize = 13
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Text = "Fly / Walk Speed"

local SpeedBox = Instance.new("TextBox", SpeedPanel)
SpeedBox.Size = UDim2.new(1, 0, 0, 38)
SpeedBox.Position = UDim2.new(0, 0, 0, 24)
SpeedBox.Text = tostring(speed)
SpeedBox.Font = Enum.Font.GothamBold
SpeedBox.TextSize = 15
SpeedBox.TextColor3 = Color3.new(1, 1, 1)
SpeedBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 12)
local SpeedStroke = Instance.new("UIStroke", SpeedBox)
SpeedStroke.Thickness = 1.5
SpeedStroke.Color = Color3.fromRGB(100, 100, 100)

-- Jump Panel
local JumpPanel = Instance.new("Frame", ContentFrame)
JumpPanel.Size = UDim2.new(1, 0, 1, 0)
JumpPanel.BackgroundTransparency = 1
JumpPanel.Visible = false

local JumpLabel = Instance.new("TextLabel", JumpPanel)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Size = UDim2.new(1, 0, 0, 20)
JumpLabel.Font = Enum.Font.GothamBold
JumpLabel.TextSize = 13
JumpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
JumpLabel.TextXAlignment = Enum.TextXAlignment.Left
JumpLabel.Text = "Jump Power"

local JumpBox = Instance.new("TextBox", JumpPanel)
JumpBox.Size = UDim2.new(1, -90, 0, 38)
JumpBox.Position = UDim2.new(0, 0, 0, 24)
JumpBox.Text = tostring(jumpPower)
JumpBox.Font = Enum.Font.GothamBold
JumpBox.TextSize = 15
JumpBox.TextColor3 = Color3.new(1, 1, 1)
JumpBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", JumpBox).CornerRadius = UDim.new(0, 12)

local JumpConfirm = Instance.new("TextButton", JumpPanel)
JumpConfirm.Size = UDim2.new(0, 80, 0, 38)
JumpConfirm.Position = UDim2.new(1, -80, 0, 24)
JumpConfirm.Text = "Apply"
JumpConfirm.Font = Enum.Font.GothamBold
JumpConfirm.TextSize = 13
JumpConfirm.TextColor3 = Color3.new(1, 1, 1)
JumpConfirm.BackgroundColor3 = Color3.fromRGB(0, 150, 130)
Instance.new("UICorner", JumpConfirm).CornerRadius = UDim.new(0, 12)

-- Spin Panel
local SpinPanel = Instance.new("Frame", ContentFrame)
SpinPanel.Size = UDim2.new(1, 0, 1, 0)
SpinPanel.BackgroundTransparency = 1
SpinPanel.Visible = false

local SpinToggle = Instance.new("TextButton", SpinPanel)
SpinToggle.Size = UDim2.new(1, 0, 0, 46)
SpinToggle.Text = "Spin: OFF"
SpinToggle.Font = Enum.Font.GothamBold
SpinToggle.TextSize = 16
SpinToggle.TextColor3 = Color3.new(1, 1, 1)
SpinToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", SpinToggle).CornerRadius = UDim.new(0, 12)
local SpinToggleStroke = Instance.new("UIStroke", SpinToggle)
SpinToggleStroke.Thickness = 2
SpinToggleStroke.Color = Color3.fromRGB(255, 0, 0)

local SpinSpeedBox = Instance.new("TextBox", SpinPanel)
SpinSpeedBox.Size = UDim2.new(1, 0, 0, 34)
SpinSpeedBox.Position = UDim2.new(0, 0, 0, 60)
SpinSpeedBox.Text = tostring(spinSpeed)
SpinSpeedBox.Font = Enum.Font.GothamBold
SpinSpeedBox.TextSize = 14
SpinSpeedBox.TextColor3 = Color3.new(1, 1, 1)
SpinSpeedBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", SpinSpeedBox).CornerRadius = UDim.new(0, 12)

-- Invisible Panel
local InvisPanel = Instance.new("Frame", ContentFrame)
InvisPanel.Size = UDim2.new(1, 0, 1, 0)
InvisPanel.BackgroundTransparency = 1
InvisPanel.Visible = false

local InvisToggle = Instance.new("TextButton", InvisPanel)
InvisToggle.Size = UDim2.new(1, 0, 0, 46)
InvisToggle.Text = "Invisible: OFF"
InvisToggle.Font = Enum.Font.GothamBold
InvisToggle.TextSize = 16
InvisToggle.TextColor3 = Color3.new(1, 1, 1)
InvisToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", InvisToggle).CornerRadius = UDim.new(0, 12)

-- Noclip Panel
local NoclipPanel = Instance.new("Frame", ContentFrame)
NoclipPanel.Size = UDim2.new(1, 0, 1, 0)
NoclipPanel.BackgroundTransparency = 1
NoclipPanel.Visible = false

local NoclipToggle = Instance.new("TextButton", NoclipPanel)
NoclipToggle.Size = UDim2.new(1, 0, 0, 46)
NoclipToggle.Text = "Noclip: OFF"
NoclipToggle.Font = Enum.Font.GothamBold
NoclipToggle.TextSize = 16
NoclipToggle.TextColor3 = Color3.new(1, 1, 1)
NoclipToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", NoclipToggle).CornerRadius = UDim.new(0, 12)
local NoclipToggleStroke = Instance.new("UIStroke", NoclipToggle)
NoclipToggleStroke.Thickness = 2
NoclipToggleStroke.Color = Color3.fromRGB(255, 0, 0)

local NoclipHint = Instance.new("TextLabel", NoclipPanel)
NoclipHint.BackgroundTransparency = 1
NoclipHint.Position = UDim2.new(0, 0, 0, 55)
NoclipHint.Size = UDim2.new(1, 0, 0, 60)
NoclipHint.Font = Enum.Font.Gotham
NoclipHint.TextSize = 12
NoclipHint.TextColor3 = Color3.fromRGB(190, 190, 190)
NoclipHint.TextWrapped = true
NoclipHint.TextXAlignment = Enum.TextXAlignment.Left
NoclipHint.Text = "Turn ON to pass cleanly through solid objects and walls."

-- ===================== ADVANCED MULTI-FLING PANEL =====================

local FlingPanel = Instance.new("Frame", ContentFrame)
FlingPanel.Size = UDim2.new(1, 0, 1, 0)
FlingPanel.BackgroundTransparency = 1
FlingPanel.Visible = false

local StatusLabel = Instance.new("TextLabel", FlingPanel)
StatusLabel.Size = UDim2.new(1, 0, 0, 16)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "0 target(s) selected"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local SelectionFrame = Instance.new("Frame", FlingPanel)
SelectionFrame.Position = UDim2.new(0, 0, 0, 20)
SelectionFrame.Size = UDim2.new(1, 0, 1, -65)
SelectionFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", SelectionFrame).CornerRadius = UDim.new(0, 8)

local PlayerScrollFrame = Instance.new("ScrollingFrame", SelectionFrame)
PlayerScrollFrame.Position = UDim2.new(0, 4, 0, 4)
PlayerScrollFrame.Size = UDim2.new(1, -8, 1, -8)
PlayerScrollFrame.BackgroundTransparency = 1
PlayerScrollFrame.ScrollBarThickness = 4
PlayerScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)

local ScrollLayout = Instance.new("UIListLayout", PlayerScrollFrame)
ScrollLayout.Padding = UDim.new(0, 4)
ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Action Control Buttons inside Fling tab
local StartButton = Instance.new("TextButton", FlingPanel)
StartButton.Position = UDim2.new(0, 0, 1, -40)
StartButton.Size = UDim2.new(0.5, -4, 0, 36)
StartButton.BackgroundColor3 = Color3.fromRGB(45, 180, 75)
StartButton.Text = "START FLING"
StartButton.TextColor3 = Color3.new(1, 1, 1)
StartButton.Font = Enum.Font.GothamBold
StartButton.TextSize = 11
Instance.new("UICorner", StartButton).CornerRadius = UDim.new(0, 6)

local StopButton = Instance.new("TextButton", FlingPanel)
StopButton.Position = UDim2.new(0.5, 4, 1, -40)
StopButton.Size = UDim2.new(0.5, -4, 0, 36)
StopButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
StopButton.Text = "STOP"
StopButton.TextColor3 = Color3.new(1, 1, 1)
StopButton.Font = Enum.Font.GothamBold
StopButton.TextSize = 11
Instance.new("UICorner", StopButton).CornerRadius = UDim.new(0, 6)

-- ===================== SELECTION UTILITIES =====================

local function CountSelectedTargets()
    local count = 0
    for _ in pairs(SelectedTargets) do count = count + 1 end
    return count
end

local function UpdateStatus()
    local count = CountSelectedTargets()
    if FlingActive then
        StatusLabel.Text = "Flinging " .. count .. " target(s)..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    else
        StatusLabel.Text = count .. " target(s) selected"
        StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    end
end

local function RefreshPlayerList()
    for _, child in pairs(PlayerScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    PlayerCheckboxes = {}

    local PlayerList = Players:GetPlayers()
    table.sort(PlayerList, function(a, b) return a.Name:lower() < b.Name:lower() end)

    for _, p in ipairs(PlayerList) do
        if p ~= Player then
            local PlayerEntry = Instance.new("Frame")
            PlayerEntry.Size = UDim2.new(1, 0, 0, 30)
            PlayerEntry.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            PlayerEntry.Parent = PlayerScrollFrame
            Instance.new("UICorner", PlayerEntry).CornerRadius = UDim.new(0, 6)

            local Checkbox = Instance.new("Frame", PlayerEntry)
            Checkbox.Size = UDim2.fromOffset(14, 14)
            Checkbox.Position = UDim2.new(0, 8, 0.5, -7)
            Checkbox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
            Instance.new("UICorner", Checkbox).CornerRadius = UDim.new(0, 4)

            local Checkmark = Instance.new("TextLabel", Checkbox)
            Checkmark.Size = UDim2.new(1, 0, 1, 0)
            Checkmark.BackgroundTransparency = 1
            Checkmark.Text = "✓"
            Checkmark.TextColor3 = Color3.fromRGB(255, 0, 0)
            Checkmark.TextSize = 11
            Checkmark.Font = Enum.Font.GothamBold
            Checkmark.Visible = SelectedTargets[p.Name] ~= nil

            local NameLabel = Instance.new("TextLabel", PlayerEntry)
            NameLabel.Size = UDim2.new(1, -35, 1, 0)
            NameLabel.Position = UDim2.new(0, 28, 0, 0)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = p.DisplayName
            NameLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
            NameLabel.TextSize = 11
            NameLabel.Font = Enum.Font.GothamMedium
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left

            local ClickArea = Instance.new("TextButton", PlayerEntry)
            ClickArea.Size = UDim2.new(1, 0, 1, 0)
            ClickArea.BackgroundTransparency = 1
            ClickArea.Text = ""

            ClickArea.MouseButton1Click:Connect(function()
                if SelectedTargets[p.Name] then
                    SelectedTargets[p.Name] = nil
                    Checkmark.Visible = false
                else
                    SelectedTargets[p.Name] = p
                    Checkmark.Visible = true
                end
                UpdateStatus()
            end)

            PlayerCheckboxes[p.Name] = { Checkmark = Checkmark }
        end
    end
    RunService.RenderStepped:Wait()
    PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ScrollLayout.AbsoluteContentSize.Y + 5)
end

-- ===================== TAB CONTROL SWITCHER =====================

local panels = { Fly = FlyPanel, Speed = SpeedPanel, Jump = JumpPanel, Fling = FlingPanel, Spin = SpinPanel, Invisible = InvisPanel, Noclip = NoclipPanel }
local listButtons = { Fly = FlyListButton, Speed = SpeedListButton, Jump = JumpListButton, Fling = FlingListButton, Spin = SpinListButton, Invisible = InvisListButton, Noclip = NoclipListButton }
local listStrokes = { Fly = FlyListStroke, Speed = SpeedListStroke, Jump = JumpListStroke, Fling = FlingListStroke, Spin = SpinListStroke, Invisible = InvisListStroke, Noclip = NoclipListStroke }

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
NoclipListButton.MouseButton1Click:Connect(function() selectTab("Noclip") end)
selectTab("Fly")

-- ===================== MINIMIZE / DRAG SETUP =====================

local Mini = Instance.new("ImageButton", ScreenGui)
Mini.Visible = false
Mini.Size = UDim2.fromOffset(50, 50)
Mini.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Mini.Image = "rbxassetid://3926307971"
Mini.ImageRectOffset = Vector2.new(324, 364)
Mini.ImageRectSize = Vector2.new(36, 36)
Instance.new("UICorner", Mini).CornerRadius = UDim.new(1, 0)
local MiniStroke = Instance.new("UIStroke", Mini)
MiniStroke.Color = Color3.fromRGB(255, 0, 0)
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
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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
    MainFrame.Visible = false
    Mini.Visible = true
    Mini.Position = MainFrame.Position
end)

Mini.MouseButton1Click:Connect(function()
    Mini.Visible = false
    MainFrame.Visible = true
    MainFrame.Position = Mini.Position
end)

-- ===================== ENGINE CORE MECHANICS =====================

-- Fly Logic
local function stopFly()
    flying = false
    local character = Player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.PlatformStand = false end
    if attachment then attachment:Destroy() end
    attachment, lv, ao = nil, nil, nil
    Toggle.Text = "Fly: OFF"
end

local function startFly()
    local character = Player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local currentRoot = humanoid and humanoid.SeatPart or character:FindFirstChild("HumanoidRootPart")

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

SpeedBox.FocusLost:Connect(function()
    speed = tonumber(SpeedBox.Text) or 50
    SpeedBox.Text = tostring(speed)
end)

JumpConfirm.MouseButton1Click:Connect(function()
    jumpPower = tonumber(JumpBox.Text) or jumpPower
    JumpBox.Text = tostring(jumpPower)
end)

SpinToggle.MouseButton1Click:Connect(function()
    spinning = not spinning
    SpinToggle.Text = spinning and "Spin: ON" or "Spin: OFF"
end)

SpinSpeedBox.FocusLost:Connect(function()
    spinSpeed = tonumber(SpinSpeedBox.Text) or spinSpeed
    SpinSpeedBox.Text = tostring(spinSpeed)
end)

-- Invisible Logic
local function setInvisible(state)
    local char = Player.Character
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
InvisToggle.MouseButton1Click:Connect(function() setInvisible(not invisible) end)

-- Noclip Toggle Logic
NoclipToggle.MouseButton1Click:Connect(function()
    noclip = not noclip
    NoclipToggle.Text = noclip and "Noclip: ON" or "Noclip: OFF"
end)

-- ===================== BENSON MULTI-TARGET FLING IMPLEMENTATION =====================

local function SkidFling(TargetPlayer)
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end
    
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart or TCharacter:FindFirstChild("HumanoidRootPart")
    
    if Character and Humanoid and RootPart and Humanoid.Health > 0 and TRootPart then
        local OldPos = RootPart.CFrame
        local NoclipConnection = RunService.Stepped:Connect(function()
            if Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
        
        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.zero
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        
        local TimeToWait = 1.5
        local Time = tick()
        
        repeat
            if RootPart and TRootPart then
                RootPart.CFrame = TRootPart.CFrame * CFrame.new(math.random(-1, 1) * 0.2, 0, math.random(-1, 1) * 0.2)
                RootPart.Velocity = Vector3.new(500000, 500000, 500000)
                RootPart.RotVelocity = Vector3.new(500000, 500000, 500000)
            end
            task.wait()
        until Time + TimeToWait < tick() or not FlingActive or Humanoid.Health <= 0 or not TRootPart.Parent
        
        if NoclipConnection then NoclipConnection:Disconnect() end
        BV:Destroy()
        
        if Humanoid.Health > 0 and OldPos then
            RootPart.CFrame = OldPos
            RootPart.Velocity = Vector3.zero
            RootPart.RotVelocity = Vector3.zero
        end
    end
end

local function StartFling()
    if FlingActive then return end
    if CountSelectedTargets() == 0 then return end
    
    FlingActive = true
    UpdateStatus()
    
    task.spawn(function()
        while FlingActive do
            local validTargets = {}
            for name, p in pairs(SelectedTargets) do
                if p and p.Parent then
                    table.insert(validTargets, p)
                else
                    SelectedTargets[name] = nil
                end
            end
            
            if #validTargets == 0 then
                FlingActive = false
                break
            end
            
            for _, target in ipairs(validTargets) do
                if FlingActive then
                    SkidFling(target)
                    task.wait(0.1)
                else break end
            end
            UpdateStatus()
            task.wait(0.2)
        end
        UpdateStatus()
    end)
end

local function StopFling()
    FlingActive = false
    UpdateStatus()
end

StartButton.MouseButton1Click:Connect(StartFling)
StopButton.MouseButton1Click:Connect(StopFling)

-- ===================== RUNTIME UPDATES & LOOPS =====================

local PlayerModule = require(Player.PlayerScripts:WaitForChild("PlayerModule"))
local Controls = PlayerModule:GetControls()

RunService.RenderStepped:Connect(function(dt)
    local t = tick()
    UIGradient.Offset = Vector2.new(math.sin(t * 2) * 1, 0)
    
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = jumpPower
        if not flying and not FlingActive then
            hum.WalkSpeed = speed
        end
    end

    -- Persistent Noclip Logic
    if noclip and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    if spinning and not FlingActive and root then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed) * dt, 0)
    end

    if flying and root and lv and ao and not FlingActive then
        if hum and hum.SeatPart then
            hum.PlatformStand = false
        else
            if hum then hum.PlatformStand = true end
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

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(function(p)
    if SelectedTargets[p.Name] then SelectedTargets[p.Name] = nil end
    RefreshPlayerList()
    UpdateStatus()
end)

Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if flying then startFly() end
    if invisible then originalTransparencies = {}; setInvisible(true) end
end)

RefreshPlayerList()
UpdateStatus()
