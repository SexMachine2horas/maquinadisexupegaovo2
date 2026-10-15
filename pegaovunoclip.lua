local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false
local function AddRGBBorder(obj, thickness)
    local stroke = Instance.new("UIStroke", obj)
    stroke.Thickness = thickness or 2
    stroke.Color = Color3.fromRGB(255,0,0)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Name = "DynamicStroke"
    if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextLabel") or obj:IsA("TextBox") then
        if not obj:FindFirstChild("UICorner") then
            local corner = Instance.new("UICorner", obj)
            corner.CornerRadius = UDim.new(0,10)
        end
    end
end
local function makeDraggable(frame)
    local dragging, dragInput, mousePos, framePos = false
    local function update(input)
        local delta = input.Position - mousePos
        frame.Position = UDim2.new(0, framePos.X.Offset + delta.X, 0, framePos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0,500,0,350)
mainFrame.Position = UDim2.new(0.5,-250,0.5,-175)
mainFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
mainFrame.BorderSizePixel = 0
AddRGBBorder(mainFrame)
makeDraggable(mainFrame)
mainFrame.Visible = false
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1,0,0,35)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundColor3 = Color3.fromRGB(60,60,60)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextScaled = true
title.Text = "Sam Scripts"
AddRGBBorder(title)
local tabFrame = Instance.new("Frame", mainFrame)
tabFrame.Size = UDim2.new(1,0,0,35)
tabFrame.Position = UDim2.new(0,0,0,35)
tabFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1,-20,1,-70)
contentFrame.Position = UDim2.new(0,10,0,70)
contentFrame.BackgroundTransparency = 1
local tabs = {"Player","Settings"}
local tabContents = {}
local activeTab
local function switchTab(name)
    for k,v in pairs(tabContents) do
        v.Visible = (k==name)
    end
    activeTab = name
end
for i,tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton", tabFrame)
    btn.Size = UDim2.new(1/#tabs,0,1,0)
    btn.Position = UDim2.new((i-1)/#tabs,0,0,0)
    btn.Text = tabName
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    btn.TextColor3 = Color3.new(1,1,1)
    AddRGBBorder(btn)
    local content = Instance.new("Frame", contentFrame)
    content.Size = UDim2.new(1,0,1,0)
    content.BackgroundTransparency = 1
    content.Visible = false
    tabContents[tabName] = content
    btn.MouseButton1Click:Connect(function() switchTab(tabName) end)
end
switchTab("Player")
local function createButton(parent,text,callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,-10,0,35)
    btn.BackgroundColor3 = Color3.fromRGB(170,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Text = text
    AddRGBBorder(btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end
local function createToggleButton(parent,text,callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,-10,0,35)
    btn.BackgroundColor3 = Color3.fromRGB(170,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Text = text.." : OFF"
    AddRGBBorder(btn)
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text.." : "..(state and "ON" or "OFF")
        callback(state)
    end)
    return btn
end
local playerTab = tabContents["Player"]
local uiList = Instance.new("UIListLayout", playerTab)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0,5)
local noclip=false
local lockOn=false
local currentTarget=nil
local originalCanCollide = setmetatable({}, {__mode = "k"})
createToggleButton(playerTab,"Noclip (Player)",function(state)
    noclip = state
    if not state then
        for part, canCollide in pairs(originalCanCollide) do
            if part and part.Parent then
                part.CanCollide = canCollide
            end
            originalCanCollide[part] = nil
        end
    end
end)
local mountNoclip = false
createToggleButton(playerTab,"Noclip (Montarias/Tudo)",function(state)
    mountNoclip = state
    if not state then
        for part, canCollide in pairs(originalCanCollide) do
            if part and part.Parent then
                part.CanCollide = canCollide
            end
            originalCanCollide[part] = nil
        end
    end
end)
createToggleButton(playerTab,"Lock-On",function(state)
    lockOn = state
end)
local speedBox = Instance.new("TextBox", playerTab)
speedBox.Size = UDim2.new(1,-10,0,35)
speedBox.BackgroundColor3=Color3.fromRGB(70,70,70)
speedBox.TextColor3=Color3.new(1,1,1)
speedBox.PlaceholderText = "Insert your speed"
speedBox.Font = Enum.Font.GothamBold
speedBox.TextSize = 14
AddRGBBorder(speedBox)
speedBox.FocusLost:Connect(function(enter)
    if enter and tonumber(speedBox.Text) and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = math.clamp(tonumber(speedBox.Text),0,2000)
    end
end)
local tpBox = Instance.new("TextBox", playerTab)
tpBox.Size = UDim2.new(1,-10,0,35)
tpBox.BackgroundColor3=Color3.fromRGB(70,70,70)
tpBox.TextColor3=Color3.new(1,1,1)
tpBox.PlaceholderText = "Player name to teleport"
tpBox.Font = Enum.Font.GothamBold
tpBox.TextSize = 14
AddRGBBorder(tpBox)
createButton(playerTab,"Teleport",function()
    local p = game.Players:FindFirstChild(tpBox.Text)
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
    end
end)
RunService.Stepped:Connect(function()
    local char = player.Character
    if char then
        if noclip or mountNoclip then
            local partsToNoclip = {}
            for _,v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    partsToNoclip[v] = true
                end
            end
            if mountNoclip then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local seatPart = humanoid and humanoid.SeatPart
                if seatPart then
                    local seatModel = seatPart:FindFirstAncestorOfClass("Model")
                    if seatModel then
                        for _,v in ipairs(seatModel:GetDescendants()) do
                            if v:IsA("BasePart") then
                                partsToNoclip[v] = true
                            end
                        end
                    end
                end
                local connectedModels = {}
                for _,v in ipairs(char:GetDescendants()) do
                    if v:IsA("Motor6D") or v:IsA("Weld") or v:IsA("WeldConstraint") then
                        local p0 = v.Part0
                        local p1 = v.Part1
                        if p0 and p1 then
                            local model0 = p0:FindFirstAncestorOfClass("Model")
                            local model1 = p1:FindFirstAncestorOfClass("Model")
                            if model0 and model0 ~= char then connectedModels[model0] = true end
                            if model1 and model1 ~= char then connectedModels[model1] = true end
                        end
                    end
                end
                for model in pairs(connectedModels) do
                    for _,v in ipairs(model:GetDescendants()) do
                        if v:IsA("BasePart") then
                            partsToNoclip[v] = true
                        end
                    end
                end
            end
            for part in pairs(partsToNoclip) do
                if part and part.Parent then
                    if originalCanCollide[part] == nil then
                        originalCanCollide[part] = part.CanCollide
                    end
                    part.CanCollide = false
                end
            end
        end
        if lockOn then
            local hasWeapon = char:FindFirstChildOfClass("Tool")
            if hasWeapon then
                local closest,shortest=nil,math.huge
                for _,npc in ipairs(workspace:GetDescendants()) do
                    if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("Head") and npc.Humanoid.Health>0 and not game.Players:GetPlayerFromCharacter(npc) then
                        local d = (camera.CFrame.Position - npc.Head.Position).Magnitude
                        if d < shortest then closest,shortest = npc,d end
                    end
                end
                currentTarget = closest
                if currentTarget then
                    camera.CFrame = CFrame.new(camera.CFrame.Position,currentTarget.Head.Position)
                end
            end
        end
    end
end)
local settingsTab = tabContents["Settings"]
local uiListS = Instance.new("UIListLayout", settingsTab)
uiListS.SortOrder = Enum.SortOrder.LayoutOrder
uiListS.Padding = UDim.new(0,5)
local colorPalette={
    ["preto"]=Color3.fromRGB(0,0,0),["branco"]=Color3.fromRGB(255,255,255),
    ["azul"]=Color3.fromRGB(0,0,255),["vermelho"]=Color3.fromRGB(255,0,0),
    ["verde"]=Color3.fromRGB(0,255,0),["amarelo"]=Color3.fromRGB(255,255,0),
    ["roxo"]=Color3.fromRGB(128,0,128),["rosa"]=Color3.fromRGB(255,192,203),
    ["marrom"]=Color3.fromRGB(139,69,19),["ciano"]=Color3.fromRGB(0,255,255),
    ["cinza"]=Color3.fromRGB(128,128,128),["RGB"]="RGB"
}
local function createSettingInput(parent,labelText,placeholder,callback)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1,-10,0,25)
    label.Text=labelText
    label.BackgroundColor3=Color3.fromRGB(70,70,70)
    label.TextColor3=Color3.new(1,1,1)
    label.Font = Enum.Font.GothamBold
    label.TextSize=14
    AddRGBBorder(label)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(1,-10,0,35)
    box.BackgroundColor3=Color3.fromRGB(70,70,70)
    box.TextColor3=Color3.new(1,1,1)
    box.PlaceholderText = placeholder
    box.Font=Enum.Font.GothamBold
    box.TextSize=14
    AddRGBBorder(box)
    box.FocusLost:Connect(function(enter)
        if enter then callback(box.Text) end
    end)
end
createSettingInput(settingsTab,"Board Color:","Type color name",function(text)
    local c=colorPalette[text:lower()]
    if c == "RGB" then c = Color3.fromRGB(255,0,0) end
    if c then
        for _,s in pairs(gui:GetDescendants()) do
            if s:IsA("UIStroke") then s.Color=c end
        end
    end
end)
createSettingInput(settingsTab,"Font Color:","Type color name",function(text)
    local c=colorPalette[text:lower()]
    if c == "RGB" then c = Color3.fromRGB(255,0,0) end
    if c then
        for _,lbl in pairs(gui:GetDescendants()) do
            if lbl:IsA("TextLabel") or lbl:IsA("TextButton") or lbl:IsA("TextBox") then
                lbl.TextColor3 = c
            end
        end
    end
end)
createSettingInput(settingsTab,"Background Color:","Type color name",function(text)
    local c=colorPalette[text:lower()]
    if c == "RGB" then c = Color3.fromRGB(255,0,0) end
    if c then
        for _,f in pairs(gui:GetDescendants()) do
            if f:IsA("Frame") then f.BackgroundColor3=c end
        end
    end
end)
local function showWelcomeAnimation()
    task.wait(1)
    local welcomeLabel = Instance.new("TextLabel", gui)
    welcomeLabel.Size = UDim2.new(0,0,0,0)
    welcomeLabel.Position = UDim2.new(0.5,0,0.3,0)
    welcomeLabel.AnchorPoint = Vector2.new(0.5,0.5)
    welcomeLabel.BackgroundTransparency = 1
    welcomeLabel.TextColor3 = Color3.fromRGB(255,255,255)
    welcomeLabel.Font = Enum.Font.GothamBold
    welcomeLabel.TextSize = 36
    welcomeLabel.Text = ""
    welcomeLabel.TextTransparency = 1
    local message = "Welcome, "..player.Name.."!"
    local tweenIn = TweenService:Create(welcomeLabel,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,400,0,50),TextTransparency=0})
    tweenIn:Play()
    tweenIn.Completed:Wait()
    for i=1,#message do
        welcomeLabel.Text = message:sub(1,i)
        welcomeLabel.TextColor3 = Color3.fromHSV(i/#message,1,1)
        task.wait(0.05)
    end
    local tweenOut = TweenService:Create(welcomeLabel,TweenInfo.new(2,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{Size=UDim2.new(0,0,0,0),TextTransparency=1})
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        welcomeLabel:Destroy()
        local openBtn = Instance.new("TextButton", gui)
        openBtn.Size = UDim2.new(0,120,0,35)
        openBtn.Position = UDim2.new(0,20,0,20)
        openBtn.Text = "Sam Scripts"
        openBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        openBtn.TextColor3 = Color3.new(1,1,1)
        openBtn.Font = Enum.Font.GothamBold
        openBtn.TextSize = 18
        AddRGBBorder(openBtn)
        makeDraggable(openBtn)
        local panelVisible = false
        openBtn.MouseButton1Click:Connect(function()
            panelVisible = not panelVisible
            mainFrame.Visible = panelVisible
        end)
    end)
end
showWelcomeAnimation()
