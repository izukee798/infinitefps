local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
                                                                      
local Window = Rayfield:CreateWindow({
   Name = "Universal Script",
   LoadingTitle = "Script",
   LoadingSubtitle = "Izukee",
   Theme = "Default",
   ToggleUIKeybind = "K",
   ConfigurationSaving = {
      Enabled = true,
      FileName = "Test Hub"
   },
   KeySystem = false
})

local Tab = Window:CreateTab("Main", 4483362458)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Infinite Jump
local infiniteJumpEnabled = false
local jumpConnection = nil
while true do
  math.sin(48238)
end 
Tab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(state)
      infiniteJumpEnabled = state
      if infiniteJumpEnabled then
         if not jumpConnection then
            jumpConnection = UserInputService.JumpRequest:Connect(function()
               local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
               local humanoid = character:FindFirstChildOfClass("Humanoid")
               if humanoid then
                  humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
               end
            end)
         end
      else
         if jumpConnection then
            jumpConnection:Disconnect()
            jumpConnection = nil
         end
      end
   end
})

-- WalkSpeed Toggle + Slider
local humanoid = nil
local defaultSpeed = 16
local walkSpeedEnabled = false
local walkSpeedValue = defaultSpeed

local function updateWalkSpeed()
    if humanoid then
        if walkSpeedEnabled then
            humanoid.WalkSpeed = walkSpeedValue
        else
            humanoid.WalkSpeed = defaultSpeed
        end
    end
end

local function onCharacterAdded(char)
    humanoid = char:WaitForChild("Humanoid")
    updateWalkSpeed()
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

Tab:CreateToggle({
    Name = "Enable WalkSpeed",
    CurrentValue = false,
    Flag = "WalkSpeedToggle",
    Callback = function(state)
        walkSpeedEnabled = state
        updateWalkSpeed()
    end
})

Tab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 500},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = defaultSpeed,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        walkSpeedValue = Value
        updateWalkSpeed()
    end
})

-- Noclip Toggle
local noclipEnabled = false
local noclipConnection = nil

local function startNoclip()
    noclipEnabled = true
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    noclipConnection = RunService.Stepped:Connect(function()
        if noclipEnabled then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function stopNoclip()
    noclipEnabled = false
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

Tab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(value)
        if value then
            startNoclip()
        else
            stopNoclip()
        end
    end
})

-- Fly Toggle and blah blah blah
local flying = false
local flySpeed = 50
local bodyVelocity = nil
local bodyGyro = nil

local function startFly()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = hrp

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp

    flying = true
    if humanoid then
        humanoid.PlatformStand = true
    end

    RunService:BindToRenderStep("Fly", 301, function()
        if not flying then return end

        local camCF = workspace.CurrentCamera.CFrame
        local moveDir = Vector3.new()

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * flySpeed
        end

        bodyVelocity.Velocity = moveDir
        bodyGyro.CFrame = camCF
    end)
end

local function stopFly()
    flying = false
    RunService:UnbindFromRenderStep("Fly")
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end

    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

Tab:CreateToggle({
    Name = "Toggle Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(value)
        if value then
            startFly()
        else
            stopFly()
        end
    end
})

Tab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = flySpeed,
    Flag = "FlySpeed",
    Callback = function(value)
        flySpeed = value
    end
})

-- ESP Section with automatic refresh and adjusted box size

local ESPEnabled = false
local ESPObjects = {}

local function createESPForPlayer(player)
    if ESPObjects[player] then return end -- Already created

    local DrawingNew = Drawing.new

    local box = DrawingNew("Square")
    box.Color = Color3.new(1, 0, 0)
    box.Thickness = 1.5
    box.Filled = false
    box.Visible = false

    local healthBar = DrawingNew("Line")
    healthBar.Color = Color3.new(0, 1, 0)
    healthBar.Thickness = 3
    healthBar.Visible = false

    local distanceText = DrawingNew("Text")
    distanceText.Color = Color3.new(1, 1, 1)
    distanceText.Size = 14
    distanceText.Visible = false
    distanceText.Center = true
    distanceText.Outline = true

    local tracerLine = DrawingNew("Line")
    tracerLine.Color = Color3.new(1, 1, 1)
    tracerLine.Thickness = 1
    tracerLine.Visible = false

    local nameText = DrawingNew("Text")
    nameText.Color = Color3.new(1, 1, 1)
    nameText.Size = 16
    nameText.Visible = false
    nameText.Center = true
    nameText.Outline = true

    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        if not humanoid or not rootPart then return end

        RunService.RenderStepped:Connect(function()
            if not ESPEnabled then
                box.Visible = false
                healthBar.Visible = false
                distanceText.Visible = false
                tracerLine.Visible = false
                nameText.Visible = false
                return
            end
            if character and humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    -- Adjusted box size: height roughly 100 / distance, width about half height
                    local baseHeight = 100 / pos.Z
                    local boxSize = Vector2.new(baseHeight * 0.5, baseHeight)

                    box.Position = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
                    box.Size = boxSize
                    box.Visible = true

                    local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                    local healthBarHeight = boxSize.Y * healthPercent
                    local healthBarX = box.Position.X - 8
                    local healthBarTopY = box.Position.Y + (boxSize.Y - healthBarHeight)
                    local healthBarBottomY = box.Position.Y + boxSize.Y

                    healthBar.From = Vector2.new(healthBarX, healthBarBottomY)
                    healthBar.To = Vector2.new(healthBarX, healthBarTopY)
                    healthBar.Visible = true

                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                    distanceText.Position = Vector2.new(pos.X, box.Position.Y + box.Size.Y + 5)
                    distanceText.Text = string.format("%.1f studs", dist)
                    distanceText.Visible = true

                    local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    local boxBottomCenter = Vector2.new(pos.X, box.Position.Y + box.Size.Y)
                    tracerLine.From = screenBottom
                    tracerLine.To = boxBottomCenter
                    tracerLine.Visible = true

                    nameText.Position = Vector2.new(pos.X, box.Position.Y - 20)
                    nameText.Text = player.Name
                    nameText.Visible = true
                else
                    box.Visible = false
                    healthBar.Visible = false
                    distanceText.Visible = false
                    tracerLine.Visible = false
                    nameText.Visible = false
                end
            else
                box.Visible = false
                healthBar.Visible = false
                distanceText.Visible = false
                tracerLine.Visible = false
                nameText.Visible = false
            end
        end)
    end

    if player.Character then
        onCharacterAdded(player.Character)
    end

    player.CharacterAdded:Connect(onCharacterAdded)

    ESPObjects[player] = {
        Box = box,
        HealthBar = healthBar,
        DistanceText = distanceText,
        TracerLine = tracerLine,
        NameText = nameText,
    }
end

local function clearESP()
    for player, drawings in pairs(ESPObjects) do
        for _, drawingObj in pairs(drawings) do
            if drawingObj and drawingObj.Visible then
                drawingObj.Visible = false
                drawingObj:Remove()
            end
        end
    end
    ESPObjects = {}
end

local function setupESP()
    clearESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESPForPlayer(player)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if ESPEnabled and player ~= LocalPlayer then
        createESPForPlayer(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        local drawings = ESPObjects[player]
        for _, drawingObj in pairs(drawings) do
            if drawingObj then
                drawingObj.Visible = false
                drawingObj:Remove()
            end
        end
        ESPObjects[player] = nil
    end
end)

Tab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(state)
        ESPEnabled = state
        if ESPEnabled then
            setupESP()
            -- Auto refresh every 5 seconds to handle new players/characters
            spawn(function()
                while ESPEnabled do
                    wait(5)
                    setupESP()
                end
            end)
        else
            clearESP()
        end
    end
})


Tab:CreateToggle({
    Name = "Aimbot (Center Mass)",
    CurrentValue = false,
    Callback = function(state)
        AimbotEnabled = state
        if not state then
            RunService:UnbindFromRenderStep("Aimbot")
        end
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local AimbotEnabled = false
local AimbotFOV = 150

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = AimbotFOV
FOVCircle.NumSides = 64
FOVCircle.Visible = true

-- Update FOV Circle
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = AimbotFOV
end)

Tab:CreateSlider({
    Name = "FOV Radius",
    Range = {50, 400},
    Increment = 1,
    CurrentValue = AimbotFOV,
    Callback = function(val)
        AimbotFOV = val
    end
})

-- Aimbot logic: right mouse button hold locks camera to target's head
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then -- right click
        if AimbotEnabled then
            RunService:BindToRenderStep("Aimbot", 300, function()
                local target = getClosestPlayer()
                if target and target.Character and target.Character:FindFirstChild("Head") then
                    local headPos = target.Character.Head.Position
                    local cameraCFrame = Camera.CFrame
                    Camera.CFrame = CFrame.new(cameraCFrame.Position, headPos)
                end
            end)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then -- right click released
        RunService:UnbindFromRenderStep("Aimbot")
    end
end)

-- Add toggle and slider for aimbottttttttttttttttt
Tab:CreateToggle({
    Name = "Aimbot ( FOR PC ONLY)",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(state)
        AimbotEnabled = state
        if not state then
            RunService:UnbindFromRenderStep("Aimbot")
        end
    end
})

Tab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {0, 500},
    Increment = 1,
    Suffix = "Radius",
    CurrentValue = AimbotFOV,
    Flag = "AimbotFOVSlider",
    Callback = function(value)
        AimbotFOV = value
    end
})

local UserInputService = game:GetService("UserInputService")

local antiAFKEnabled = false
local antiAFKConnection

Tab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFKToggle",
    Callback = function(state)
        antiAFKEnabled = state
        if antiAFKEnabled then
            antiAFKConnection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
                -- Simulate mouse movement or key press to prevent kick
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        else
            if antiAFKConnection then
                antiAFKConnection:Disconnect()
                antiAFKConnection = nil
            end
        end
    end
})


local HubTab = Window:CreateTab("Scripts", 4483362458)

-- Speed Hub X
HubTab:CreateButton({
    Name = "Speed Hub X",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
        end)
        if not success then
            Rayfield:Notify({ Title = "Script Execution Error", Content = tostring(err), Duration = 5 })
        end
    end
})

HubTab:CreateButton({
    Name = "Copy Speed Hub X Discord Invite",
    Callback = function()
        pcall(setclipboard, "https://discord.gg/speedhubx")
        Rayfield:Notify({ Title = "Copied to Clipboard", Content = "Discord invite link copied!", Duration = 3 })
    end
})

-- No Lag Hub
HubTab:CreateButton({
    Name = "No Lag Hub",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/NoLag-id/No-Lag-HUB/refs/heads/main/Loader/LoaderV1.lua"))()
        end)
        if not success then
            Rayfield:Notify({ Title = "Script Execution Error", Content = tostring(err), Duration = 5 })
        end
    end
})

HubTab:CreateButton({
    Name = "Copy No Lag Hub Discord Invite",
    Callback = function()
        pcall(setclipboard, "https://discord.gg/no-lag")
        Rayfield:Notify({ Title = "Copied to Clipboard", Content = "Discord invite link copied!", Duration = 3 })
    end
})

-- UB Hub (Key required)
HubTab:CreateButton({
    Name = "UB Hub (Key in Discord server)",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://gitlab.com/r_soft/main/-/raw/main/LoadUB.lua"))()
        end)
        if not success then
            Rayfield:Notify({ Title = "Script Execution Error", Content = tostring(err), Duration = 5 })
        end
    end
})

HubTab:CreateButton({
    Name = "Copy UB Hub Discord Invite",
    Callback = function()
        pcall(setclipboard, "https://discord.gg/PbrMAwZdSy")
        Rayfield:Notify({ Title = "Copied to Clipboard", Content = "Discord invite link copied!", Duration = 3 })
    end
})

HubTab:CreateButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

HubTab:CreateLabel("Idk what else to put here")
local SuggestionsTab = Window:CreateTab("Suggestions", 4483362458)

SuggestionsTab:CreateLabel("Got suggestions or want to chat? Add me on Discord:")

SuggestionsTab:CreateLabel("Discord: theshortestofthemall")

SuggestionsTab:CreateButton({
    Name = "Copy Discord Username",
    Callback = function()
        if setclipboard then
            setclipboard("theshortestofthemall")
            Rayfield:Notify({
                Title = "Copied!",
                Content = "Discord username copied to clipboard.",
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Clipboard not supported in your executor.",
                Duration = 3
            })
        end
    end
})

SuggestionsTab:CreateLabel("DM me for suggestions 🙂")























