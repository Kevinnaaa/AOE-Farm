--[[
    Sailor Piece - ALL IN ONE (RAYFIELD STYLE - MINIMIZE TO TEXT)
    AOE Farm + Anti AFK + Speed 50 + Jump 75 + FOV 100
    Permanent Stats | FPS/Ping/Time on Title Bar | Auto Bounty Display
    PC + Mobile Support | FIXED TOGGLES | RAID SYSTEM
--]]

repeat wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

-- Detect platform
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Permanent Settings
local PERMANENT = {
    Range = 30,
    WalkSpeed = 50,
    JumpPower = 75,
    FOV = 100
}

-- Toggle Settings
local Settings = {
    Farming = false,
    AntiAFK = true,
    Minimized = false,
    AutoRaid = false,
    AutoPullLever = true,
    AutoAttackBoss = true
}

local ScriptActive = true

-- FPS Tracking
local fpsCount, fps, lastFPSUpdate = 0, 0, tick()

-- Timer
local saniye, dakika, saat = 0, 0, 0

-- Bounty
local CurrentBounty = "Searching..."

-- Raid Variables
local RaidStatus = "Idle"
local BossTarget = nil
local LeverTarget = nil
local LastPullTime = 0

-- Clean up
if getgenv().SailorPieceLoaded then
    getgenv().SailorPieceLoaded = false
    if game.CoreGui:FindFirstChild("SailorPieceGUI") then
        game.CoreGui.SailorPieceGUI:Destroy()
    end
    if game.CoreGui:FindFirstChild("MinimizeText") then
        game.CoreGui.MinimizeText:Destroy()
    end
end
getgenv().SailorPieceLoaded = true

-- =============================================
-- BOUNTY SCANNER
-- =============================================
local function scanBounty()
    local bounty = nil
    
    pcall(function()
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("stats") or LocalPlayer:FindFirstChild("Data")
        if leaderstats then
            for _, stat in pairs(leaderstats:GetChildren()) do
                local name = string.lower(stat.Name)
                if string.find(name, "bounty") or string.find(name, "beli") then
                    if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                        bounty = tostring(stat.Value)
                        break
                    elseif stat:IsA("StringValue") then
                        bounty = stat.Value
                        break
                    end
                end
            end
        end
        
        if not bounty then
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                for _, child in pairs(playerGui:GetDescendants()) do
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        local text = child.Text or ""
                        local textLower = string.lower(text)
                        if string.find(textLower, "bounty") then
                            local number = string.match(text, "[%d,]+")
                            if number then
                                bounty = number
                                break
                            else
                                local clean = text:gsub("Bounty", ""):gsub("bounty", ""):gsub("%s*:%s*", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
                                if clean ~= "" then
                                    bounty = clean
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    return bounty
end

-- =============================================
-- RAID FUNCTIONS
-- =============================================
local function findMinotaurBoss()
    local boss = nil
    pcall(function()
        -- Search in various possible locations
        local folders = {"Bosses", "Enemies", "NPCs", "Mobs", "Raids"}
        local bossNames = {"Minotaur", "minotaur", "MINOTAUR", "MinotaurBoss", "Minotaur Boss"}
        
        for _, folderName in pairs(folders) do
            local folder = Workspace:FindFirstChild(folderName)
            if folder then
                for _, obj in pairs(folder:GetChildren()) do
                    if obj:IsA("Model") then
                        for _, name in pairs(bossNames) do
                            if string.find(string.lower(obj.Name), string.lower(name)) then
                                local humanoid = obj:FindFirstChild("Humanoid")
                                local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj:FindFirstChild("Torso")
                                if humanoid and humanoid.Health > 0 and rootPart then
                                    boss = {model = obj, humanoid = humanoid, rootPart = rootPart}
                                    return boss
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- Also search directly in workspace
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Model") then
                for _, name in pairs(bossNames) do
                    if string.find(string.lower(obj.Name), string.lower(name)) then
                        local humanoid = obj:FindFirstChild("Humanoid")
                        local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj:FindFirstChild("Torso")
                        if humanoid and humanoid.Health > 0 and rootPart then
                            boss = {model = obj, humanoid = humanoid, rootPart = rootPart}
                            return boss
                        end
                    end
                end
            end
        end
    end)
    return boss
end

local function findLever()
    local lever = nil
    pcall(function()
        local leverNames = {"Lever", "lever", "LEVER", "Switch", "Pull", "Handle"}
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then
                local parent = obj.Parent
                if parent then
                    for _, name in pairs(leverNames) do
                        if string.find(string.lower(parent.Name), string.lower(name)) then
                            lever = parent
                            return lever
                        end
                    end
                end
            end
        end
        
        -- Search for lever models
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("Part") then
                for _, name in pairs(leverNames) do
                    if string.find(string.lower(obj.Name), string.lower(name)) then
                        lever = obj
                        return lever
                    end
                end
            end
        end
    end)
    return lever
end

local function moveToTarget(targetPosition)
    local char = LocalPlayer.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    local distance = (root.Position - targetPosition).Magnitude
    
    if distance <= 15 then
        -- Close enough, move directly
        humanoid:MoveTo(targetPosition)
        return true
    else
        -- Use pathfinding for longer distances
        local path = PathfindingService:CreatePath()
        path:ComputeAsync(root.Position, targetPosition)
        
        if path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            for _, waypoint in pairs(waypoints) do
                if not Settings.AutoRaid then return false end
                humanoid:MoveTo(waypoint.Position)
                humanoid.MoveToFinished:Wait()
                task.wait()
            end
            return true
        else
            -- Fallback to direct movement
            humanoid:MoveTo(targetPosition)
            return true
        end
    end
end

local function attackTarget(targetRootPart)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Face the target
    root.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetRootPart.Position.X, root.Position.Y, targetRootPart.Position.Z))
    
    -- Attack
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local function pullLever(lever)
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local leverPosition
        if lever:IsA("Model") then
            leverPosition = lever:GetPivot().Position
        else
            leverPosition = lever.Position
        end
        
        -- Move to lever
        moveToTarget(leverPosition)
        task.wait(0.5)
        
        -- Pull the lever
        local prompt = lever:FindFirstChild("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
        end
        
        local clickDetector = lever:FindFirstChild("ClickDetector")
        if clickDetector then
            fireclickdetector(clickDetector)
        end
        
        -- Try clicking the lever
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        
        LastPullTime = tick()
    end)
end

-- =============================================
-- GUI CREATION
-- =============================================
local GUI = Instance.new("ScreenGui")
GUI.Name = "SailorPieceGUI"
GUI.ResetOnSpawn = false
GUI.Parent = game.CoreGUI
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Adjust size for mobile
local mainWidth = 500
local mainHeight = 340
if isMobile then
    mainWidth = 380
    mainHeight = 260
end

-- Main Container
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, mainWidth, 0, mainHeight)
Main.Position = isMobile and UDim2.new(0.5, -mainWidth/2, 0.5, -mainHeight/2) or UDim2.new(0.5, -250, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = GUI

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = Main

-- Minimize Text Button (Script by Maryyy v1)
local MinimizeText = Instance.new("TextButton")
MinimizeText.Name = "MinimizeText"
MinimizeText.Size = UDim2.new(0, isMobile and 200 or 180, 0, isMobile and 50 or 40)
MinimizeText.Position = UDim2.new(0, 10, 0, isMobile and 140 or 80)
MinimizeText.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MinimizeText.BorderSizePixel = 0
MinimizeText.TextColor3 = Color3.fromRGB(255, 200, 100)
MinimizeText.Text = "📜 Script by Maryyy v1"
MinimizeText.Font = Enum.Font.GothamBold
MinimizeText.TextSize = isMobile and 16 or 14
MinimizeText.AutoButtonColor = false
MinimizeText.Visible = false
MinimizeText.Active = true
MinimizeText.ZIndex = 10
MinimizeText.Parent = GUI

local TextCorner = Instance.new("UICorner")
TextCorner.CornerRadius = UDim.new(0, 8)
TextCorner.Parent = MinimizeText

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

-- FPS
local FPSDisplay = Instance.new("TextLabel")
FPSDisplay.Size = UDim2.new(0, 55, 1, 0)
FPSDisplay.Position = UDim2.new(0, 8, 0, 0)
FPSDisplay.BackgroundTransparency = 1
FPSDisplay.TextColor3 = Color3.fromRGB(0, 255, 100)
FPSDisplay.Text = "FPS: --"
FPSDisplay.TextXAlignment = Enum.TextXAlignment.Left
FPSDisplay.Font = Enum.Font.GothamBold
FPSDisplay.TextSize = isMobile and 11 or 10
FPSDisplay.Parent = TitleBar

-- Ping
local PingDisplay = Instance.new("TextLabel")
PingDisplay.Size = UDim2.new(0, 65, 1, 0)
PingDisplay.Position = UDim2.new(0, 60, 0, 0)
PingDisplay.BackgroundTransparency = 1
PingDisplay.TextColor3 = Color3.fromRGB(100, 200, 255)
PingDisplay.Text = "Ping: --"
PingDisplay.TextXAlignment = Enum.TextXAlignment.Left
PingDisplay.Font = Enum.Font.GothamBold
PingDisplay.TextSize = isMobile and 11 or 10
PingDisplay.Parent = TitleBar

-- Time
local TimerDisplay = Instance.new("TextLabel")
TimerDisplay.Size = UDim2.new(0, 80, 1, 0)
TimerDisplay.Position = UDim2.new(0, 128, 0, 0)
TimerDisplay.BackgroundTransparency = 1
TimerDisplay.TextColor3 = Color3.fromRGB(255, 200, 0)
TimerDisplay.Text = "0:0:0"
TimerDisplay.TextXAlignment = Enum.TextXAlignment.Left
TimerDisplay.Font = Enum.Font.GothamBold
TimerDisplay.TextSize = isMobile and 11 or 10
TimerDisplay.Parent = TitleBar

-- Title
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -290, 1, 0)
TitleText.Position = UDim2.new(0, isMobile and 200 or 210, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Color3.fromRGB(180, 180, 180)
TitleText.Text = "Sailor Piece by Maryyy"
TitleText.TextXAlignment = Enum.TextXAlignment.Right
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = isMobile and 12 or 11
TitleText.Parent = TitleBar

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, isMobile and 32 or 28, 0, isMobile and 32 or 28)
MinBtn.Position = UDim2.new(1, isMobile and -38 or -33, 0, isMobile and 2 or 2)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MinBtn.BorderSizePixel = 0
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Text = "—"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = isMobile and 16 or 14
MinBtn.AutoButtonColor = false
MinBtn.Active = true
MinBtn.ZIndex = 10
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinBtn

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, 0, 1, isMobile and -36 or -32)
ContentContainer.Position = UDim2.new(0, 0, 0, isMobile and 36 or 32)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = Main

-- Sidebar
local sidebarWidth = isMobile and 130 or 140
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, sidebarWidth, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = ContentContainer

local SidebarBorder = Instance.new("Frame")
SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
SidebarBorder.Position = UDim2.new(1, 0, 0, 0)
SidebarBorder.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SidebarBorder.BorderSizePixel = 0
SidebarBorder.Parent = Sidebar

-- Sidebar Logo
local SidebarLogo = Instance.new("Frame")
SidebarLogo.Size = UDim2.new(1, 0, 0, isMobile and 40 or 45)
SidebarLogo.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SidebarLogo.BorderSizePixel = 0
SidebarLogo.Parent = Sidebar

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, -20, 0, 20)
LogoText.Position = UDim2.new(0, 10, 0, 5)
LogoText.BackgroundTransparency = 1
LogoText.TextColor3 = Color3.fromRGB(255, 200, 0)
LogoText.Text = "⚔️ SAILOR PIECE"
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = isMobile and 9 or 10
LogoText.Parent = SidebarLogo

local LogoSub = Instance.new("TextLabel")
LogoSub.Size = UDim2.new(1, -20, 0, 14)
LogoSub.Position = UDim2.new(0, 10, 0, 24)
LogoSub.BackgroundTransparency = 1
LogoSub.TextColor3 = Color3.fromRGB(120, 120, 120)
LogoSub.Text = "by QueezZy123"
LogoSub.TextXAlignment = Enum.TextXAlignment.Left
LogoSub.Font = Enum.Font.Gotham
LogoSub.TextSize = isMobile and 8 or 9
LogoSub.Parent = SidebarLogo

-- Tab System
local TabButtons = {}
local TabPages = {}

local function CreateTab(name, icon, index)
    local btnSize = isMobile and 26 or 30
    local btnFont = isMobile and 9 or 10
    local startY = isMobile and 46 or 52
    local spacing = isMobile and 30 or 34
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, btnSize)
    btn.Position = UDim2.new(0, 10, 0, startY + (index - 1) * spacing)
    btn.BackgroundColor3 = index == 1 and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(23, 23, 23)
    btn.BorderSizePixel = 0
    btn.TextColor3 = index == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    btn.Text = "  " .. icon .. "  " .. name
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = btnFont
    btn.AutoButtonColor = false
    btn.Active = true
    btn.ZIndex = 10
    btn.Parent = Sidebar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, -sidebarWidth, 1, 0)
    page.Position = UDim2.new(0, sidebarWidth, 0, 0)
    page.BackgroundTransparency = 1
    page.Visible = (index == 1)
    page.Parent = ContentContainer
    
    btn.Activated:Connect(function()
        for i = 1, #TabButtons do
            TabButtons[i].BackgroundColor3 = Color3.fromRGB(23, 23, 23)
            TabButtons[i].TextColor3 = Color3.fromRGB(150, 150, 150)
            TabPages[i].Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        page.Visible = true
    end)
    
    table.insert(TabButtons, btn)
    table.insert(TabPages, page)
    return page
end

-- =============================================
-- UI HELPERS
-- =============================================
local function CreateSection(parent, title, yPos)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -30, 0, 20)
    section.Position = UDim2.new(0, 15, 0, yPos)
    section.BackgroundTransparency = 1
    section.Parent = parent
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, 0)
    line.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    line.BorderSizePixel = 0
    line.Parent = section
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 0, 16)
    text.Position = UDim2.new(0, 0, 0, 3)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(120, 120, 120)
    text.Text = title
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Font = Enum.Font.GothamBold
    text.TextSize = 9
    text.Parent = section
    
    return section
end

local function CreateToggle(parent, title, default, yPos, callback)
    local bgSize = isMobile and 34 or 30
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -30, 0, bgSize)
    bg.Position = UDim2.new(0, 15, 0, yPos)
    bg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    bg.BorderSizePixel = 0
    bg.Parent = parent
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 4)
    bgCorner.Parent = bg
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Text = title
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = isMobile and 10 or 11
    label.Parent = bg
    
    local state = default
    
    local switchSize = isMobile and 40 or 36
    local switchHeight = isMobile and 20 or 18
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, switchSize, 0, switchHeight)
    switch.Position = UDim2.new(1, isMobile and -52 or -46, 0.5, isMobile and -10 or -9)
    switch.BackgroundColor3 = state and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(50, 50, 50)
    switch.BorderSizePixel = 0
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.Active = true
    switch.ZIndex = 10
    switch.Parent = bg
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch
    
    local dotSize = isMobile and 16 or 14
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, dotSize, 0, dotSize)
    dot.Position = state and UDim2.new(1, isMobile and -18 or -16, 0.5, isMobile and -8 or -7) or UDim2.new(0, 2, 0.5, isMobile and -8 or -7)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = switch
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    
    local function toggleSwitch()
        state = not state
        switch.BackgroundColor3 = state and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(50, 50, 50)
        local targetPos = state and UDim2.new(1, isMobile and -18 or -16, 0.5, isMobile and -8 or -7) or UDim2.new(0, 2, 0.5, isMobile and -8 or -7)
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(dot, tweenInfo, {Position = targetPos})
        tween:Play()
        callback(state)
    end
    
    switch.Activated:Connect(toggleSwitch)
    
    return bg
end

local function CreateButton(parent, title, yPos, callback)
    local btnSize = isMobile and 36 or 32
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, btnSize)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = title
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = isMobile and 10 or 11
    btn.AutoButtonColor = false
    btn.Active = true
    btn.ZIndex = 10
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    btn.Activated:Connect(callback)
    
    return btn
end

local function CreateInfoLabel(parent, text, yPos, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 0, 18)
    label.Position = UDim2.new(0, 15, 0, yPos)
    label.BackgroundTransparency = 1
    label.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 10
    label.Parent = parent
    return label
end

-- =============================================
-- CREATE TABS
-- =============================================
local FarmPage = CreateTab("Farm", "⚔️", 1)
local RaidPage = CreateTab("Raid", "🏛️", 2)
local PlayerPage = CreateTab("Player", "👤", 3)
local SettingsPage = CreateTab("Settings", "⚙️", 4)

-- =============================================
-- FARM TAB
-- =============================================
CreateSection(FarmPage, "CONTROLS", 10)

local FarmStatus = Instance.new("TextLabel")
FarmStatus.Size = UDim2.new(1, -30, 0, 16)
FarmStatus.Position = UDim2.new(0, 15, 0, isMobile and 36 or 34)
FarmStatus.BackgroundTransparency = 1
FarmStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
FarmStatus.Text = "● Idle"
FarmStatus.TextXAlignment = Enum.TextXAlignment.Left
FarmStatus.Font = Enum.Font.Gotham
FarmStatus.TextSize = 10
FarmStatus.Parent = FarmPage

CreateToggle(FarmPage, "AOE Farming", false, isMobile and 58 or 54, function(state)
    Settings.Farming = state
    FarmStatus.Text = state and "● Farming" or "● Idle"
    FarmStatus.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(150, 150, 150)
end)

CreateToggle(FarmPage, "Anti-AFK", true, isMobile and 96 or 88, function(state)
    Settings.AntiAFK = state
end)

CreateSection(FarmPage, "INFO", isMobile and 138 or 130)

local BountyDisplay = Instance.new("TextLabel")
BountyDisplay.Size = UDim2.new(1, -30, 0, isMobile and 24 or 22)
BountyDisplay.Position = UDim2.new(0, 15, 0, isMobile and 162 or 154)
BountyDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
BountyDisplay.BorderSizePixel = 0
BountyDisplay.TextColor3 = Color3.fromRGB(255, 200, 0)
BountyDisplay.Text = "💰 Bounty: Searching..."
BountyDisplay.TextXAlignment = Enum.TextXAlignment.Left
BountyDisplay.Font = Enum.Font.GothamBold
BountyDisplay.TextSize = isMobile and 10 or 11
BountyDisplay.Parent = FarmPage

local BountyCorner = Instance.new("UICorner")
BountyCorner.CornerRadius = UDim.new(0, 4)
BountyCorner.Parent = BountyDisplay

local NPCCount = Instance.new("TextLabel")
NPCCount.Size = UDim2.new(1, -30, 0, 14)
NPCCount.Position = UDim2.new(0, 15, 0, isMobile and 196 or 186)
NPCCount.BackgroundTransparency = 1
NPCCount.TextColor3 = Color3.fromRGB(140, 140, 140)
NPCCount.Text = "NPCs in range: 0"
NPCCount.TextXAlignment = Enum.TextXAlignment.Left
NPCCount.Font = Enum.Font.Gotham
NPCCount.TextSize = 9
NPCCount.Parent = FarmPage

-- =============================================
-- RAID TAB
-- =============================================
CreateSection(RaidPage, "MINOTAUR RAID", 10)

local RaidStatusDisplay = Instance.new("TextLabel")
RaidStatusDisplay.Size = UDim2.new(1, -30, 0, 36)
RaidStatusDisplay.Position = UDim2.new(0, 15, 0, 34)
RaidStatusDisplay.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
RaidStatusDisplay.BorderSizePixel = 0
RaidStatusDisplay.TextColor3 = Color3.fromRGB(255, 200, 0)
RaidStatusDisplay.Text = "🏛️ Status: Idle"
RaidStatusDisplay.TextXAlignment = Enum.TextXAlignment.Left
RaidStatusDisplay.Font = Enum.Font.GothamBold
RaidStatusDisplay.TextSize = isMobile and 10 or 11
RaidStatusDisplay.Parent = RaidPage

local RaidCorner = Instance.new("UICorner")
RaidCorner.CornerRadius = UDim.new(0, 4)
RaidCorner.Parent = RaidStatusDisplay

CreateToggle(RaidPage, "Auto Raid", false, 82, function(state)
    Settings.AutoRaid = state
    if state then
        RaidStatus = "Starting..."
        RaidStatusDisplay.Text = "🏛️ Status: Starting..."
        RaidStatusDisplay.TextColor3 = Color3.fromRGB(255, 200, 0)
    else
        RaidStatus = "Idle"
        RaidStatusDisplay.Text = "🏛️ Status: Idle"
        RaidStatusDisplay.TextColor3 = Color3.fromRGB(255, 200, 0)
    end
end)

CreateToggle(RaidPage, "Auto Pull Lever", true, 120, function(state)
    Settings.AutoPullLever = state
end)

CreateToggle(RaidPage, "Auto Attack Boss", true, 158, function(state)
    Settings.AutoAttackBoss = state
end)

CreateSection(RaidPage, "BOSS INFO", 200)

local BossHealth = Instance.new("TextLabel")
BossHealth.Size = UDim2.new(1, -30, 0, 18)
BossHealth.Position = UDim2.new(0, 15, 0, 224)
BossHealth.BackgroundTransparency = 1
BossHealth.TextColor3 = Color3.fromRGB(255, 100, 100)
BossHealth.Text = "👹 Boss: Not found"
BossHealth.TextXAlignment = Enum.TextXAlignment.Left
BossHealth.Font = Enum.Font.Gotham
BossHealth.TextSize = 10
BossHealth.Parent = RaidPage

local BossDistance = Instance.new("TextLabel")
BossDistance.Size = UDim2.new(1, -30, 0, 18)
BossDistance.Position = UDim2.new(0, 15, 0, 242)
BossDistance.BackgroundTransparency = 1
BossDistance.TextColor3 = Color3.fromRGB(200, 200, 200)
BossDistance.Text = "📏 Distance: N/A"
BossDistance.TextXAlignment = Enum.TextXAlignment.Left
BossDistance.Font = Enum.Font.Gotham
BossDistance.TextSize = 10
BossDistance.Parent = RaidPage

local LeverStatus = Instance.new("TextLabel")
LeverStatus.Size = UDim2.new(1, -30, 0, 18)
LeverStatus.Position = UDim2.new(0, 15, 0, 260)
LeverStatus.BackgroundTransparency = 1
LeverStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
LeverStatus.Text = "🔧 Lever: Searching..."
LeverStatus.TextXAlignment = Enum.TextXAlignment.Left
LeverStatus.Font = Enum.Font.Gotham
LeverStatus.TextSize = 10
LeverStatus.Parent = RaidPage

CreateSection(RaidPage, "CONTROLS", 290)

CreateButton(RaidPage, "🔄 Find & Pull Lever", 314, function()
    local lever = findLever()
    if lever then
        RaidStatus = "Pulling lever..."
        RaidStatusDisplay.Text = "🏛️ Status: Pulling lever..."
        pullLever(lever)
    else
        RaidStatus = "Lever not found"
        RaidStatusDisplay.Text = "🏛️ Status: Lever not found"
    end
end)

CreateButton(RaidPage, "⚔️ Attack Boss", 352, function()
    local boss = findMinotaurBoss()
    if boss then
        RaidStatus = "Attacking boss..."
        RaidStatusDisplay.Text = "🏛️ Status: Attacking boss..."
        BossTarget = boss
    else
        RaidStatus = "Boss not found"
        RaidStatusDisplay.Text = "🏛️ Status: Boss not found"
    end
end)

-- =============================================
-- PLAYER TAB
-- =============================================
CreateSection(PlayerPage, "CHARACTER INFO", 10)

local PlayerName = Instance.new("TextLabel")
PlayerName.Size = UDim2.new(1, -30, 0, 20)
PlayerName.Position = UDim2.new(0, 15, 0, 34)
PlayerName.BackgroundTransparency = 1
PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerName.Text = "👤 " .. LocalPlayer.Name
PlayerName.TextXAlignment = Enum.TextXAlignment.Left
PlayerName.Font = Enum.Font.GothamBold
PlayerName.TextSize = 12
PlayerName.Parent = PlayerPage

local PlayerBounty = Instance.new("Frame")
PlayerBounty.Size = UDim2.new(1, -30, 0, 40)
PlayerBounty.Position = UDim2.new(0, 15, 0, 60)
PlayerBounty.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
PlayerBounty.BorderSizePixel = 0
PlayerBounty.Parent = PlayerPage

local PlayerBountyCorner = Instance.new("UICorner")
PlayerBountyCorner.CornerRadius = UDim.new(0, 4)
PlayerBountyCorner.Parent = PlayerBounty

local PlayerBountyLabel = Instance.new("TextLabel")
PlayerBountyLabel.Size = UDim2.new(1, -20, 0, 14)
PlayerBountyLabel.Position = UDim2.new(0, 10, 0, 5)
PlayerBountyLabel.BackgroundTransparency = 1
PlayerBountyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
PlayerBountyLabel.Text = "BOUNTY"
PlayerBountyLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerBountyLabel.Font = Enum.Font.GothamBold
PlayerBountyLabel.TextSize = 8
PlayerBountyLabel.Parent = PlayerBounty

local PlayerBountyValue = Instance.new("TextLabel")
PlayerBountyValue.Size = UDim2.new(1, -20, 0, 18)
PlayerBountyValue.Position = UDim2.new(0, 10, 0, 18)
PlayerBountyValue.BackgroundTransparency = 1
PlayerBountyValue.TextColor3 = Color3.fromRGB(255, 200, 0)
PlayerBountyValue.Text = "Searching..."
PlayerBountyValue.TextXAlignment = Enum.TextXAlignment.Left
PlayerBountyValue.Font = Enum.Font.GothamBold
PlayerBountyValue.TextSize = 13
PlayerBountyValue.Parent = PlayerBounty

CreateSection(PlayerPage, "HEALTH", 112)

local HealthBarBg = Instance.new("Frame")
HealthBarBg.Size = UDim2.new(1, -30, 0, 20)
HealthBarBg.Position = UDim2.new(0, 15, 0, 136)
HealthBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
HealthBarBg.BorderSizePixel = 0
HealthBarBg.Parent = PlayerPage

local HealthBarCorner = Instance.new("UICorner")
HealthBarCorner.CornerRadius = UDim.new(0, 4)
HealthBarCorner.Parent = HealthBarBg

local HealthBar = Instance.new("Frame")
HealthBar.Size = UDim2.new(1, 0, 1, 0)
HealthBar.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
HealthBar.BorderSizePixel = 0
HealthBar.Parent = HealthBarBg

local HealthBarCorner2 = Instance.new("UICorner")
HealthBarCorner2.CornerRadius = UDim.new(0, 4)
HealthBarCorner2.Parent = HealthBar

local HealthText = Instance.new("TextLabel")
HealthText.Size = UDim2.new(1, 0, 1, 0)
HealthText.BackgroundTransparency = 1
HealthText.TextColor3 = Color3.fromRGB(255, 255, 255)
HealthText.Text = "100%"
HealthText.Font = Enum.Font.GothamBold
HealthText.TextSize = 10
HealthText.Parent = HealthBar

-- =============================================
-- SETTINGS TAB
-- =============================================
CreateSection(SettingsPage, "PERMANENT STATS", 10)

CreateInfoLabel(SettingsPage, "Farm Range: 30", 34, Color3.fromRGB(255, 200, 0))
CreateInfoLabel(SettingsPage, "Walk Speed: 50", 54, Color3.fromRGB(255, 200, 0))
CreateInfoLabel(SettingsPage, "Jump Power: 75", 74, Color3.fromRGB(255, 200, 0))
CreateInfoLabel(SettingsPage, "FOV: 100", 94, Color3.fromRGB(255, 200, 0))

CreateSection(SettingsPage, "TERMINATE", 126)

CreateButton(SettingsPage, "⚠️ TERMINATE SCRIPT", 150, function()
    ScriptActive = false
    Settings.Farming = false
    Settings.AutoRaid = false
    GUI:Destroy()
end)

-- =============================================
-- MINIMIZE TO TEXT
-- =============================================
local function showMain()
    Main.Visible = true
    MinimizeText.Visible = false
    Settings.Minimized = false
end

local function showText()
    Main.Visible = false
    MinimizeText.Visible = true
    Settings.Minimized = true
end

MinBtn.Activated:Connect(showText)
MinimizeText.Activated:Connect(showMain)

-- Text button: tap to restore, drag to move
local textDragging = false
local textDragStart
local textStartPos
local textMoved = false

MinimizeText.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        textDragging = true
        textMoved = false
        textDragStart = input.Position
        textStartPos = MinimizeText.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if textDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - textDragStart
        if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then
            textMoved = true
        end
        MinimizeText.Position = UDim2.new(textStartPos.X.Scale, textStartPos.X.Offset + delta.X, textStartPos.Y.Scale, textStartPos.Y.Offset + delta.Y)
    end
end)

MinimizeText.InputEnded:Connect(function(input)
    if textDragging then
        if not textMoved then
            showMain()
        end
        textDragging = false
    end
end)

-- Main window draggable
local dragActive = false
local dragInput
local dragStart
local startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragActive = true
        dragStart = input.Position
        startPos = Main.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragActive = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

RunService.RenderStepped:Connect(function()
    if dragActive and dragInput then
        local delta = dragInput.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- =============================================
-- ANTI AFK
-- =============================================
LocalPlayer.Idled:connect(function()
    if Settings.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- =============================================
-- UPDATE LOOPS
-- =============================================

-- FPS
task.spawn(function()
    while ScriptActive do
        fpsCount = fpsCount + 1
        if tick() - lastFPSUpdate >= 0.5 then
            fps = math.floor(fpsCount / (tick() - lastFPSUpdate))
            fpsCount = 0
            lastFPSUpdate = tick()
            FPSDisplay.Text = "FPS: " .. fps
            FPSDisplay.TextColor3 = fps >= 50 and Color3.fromRGB(0, 255, 100) or (fps >= 25 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 80, 80))
        end
        task.wait()
    end
end)

-- Ping
task.spawn(function()
    while ScriptActive do
        pcall(function()
            local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            PingDisplay.Text = "Ping: " .. ping .. "ms"
            PingDisplay.TextColor3 = ping <= 80 and Color3.fromRGB(100, 200, 255) or (ping <= 150 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 100, 100))
        end)
        task.wait(1)
    end
end)

-- Timer
task.spawn(function()
    while ScriptActive do
        saniye = saniye + 1
        if saniye >= 60 then saniye = 0; dakika = dakika + 1 end
        if dakika >= 60 then dakika = 0; saat = saat + 1 end
        TimerDisplay.Text = saat .. ":" .. dakika .. ":" .. saniye
        task.wait(1)
    end
end)

-- Bounty
task.spawn(function()
    while ScriptActive do
        local bounty = scanBounty()
        if bounty then
            CurrentBounty = bounty
            BountyDisplay.Text = "💰 Bounty: " .. bounty
            PlayerBountyValue.Text = bounty
        else
            BountyDisplay.Text = "💰 Bounty: Not found"
            PlayerBountyValue.Text = "Not found"
        end
        task.wait(3)
    end
end)

-- Health
task.spawn(function()
    while ScriptActive do
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                local hp = char.Humanoid.Health
                local maxHP = char.Humanoid.MaxHealth
                local percent = hp / maxHP
                HealthBar.Size = UDim2.new(percent, 0, 1, 0)
                HealthText.Text = math.floor(percent * 100) .. "%"
                HealthBar.BackgroundColor3 = percent > 0.5 and Color3.fromRGB(60, 200, 60) or (percent > 0.25 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 50, 50))
            end
        end)
        task.wait(0.3)
    end
end)

-- NPC Counter
task.spawn(function()
    while ScriptActive do
        local count = 0
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char.HumanoidRootPart
                local npcFolder = Workspace:FindFirstChild("NPCs")
                if npcFolder then
                    for _, obj in pairs(npcFolder:GetChildren()) do
                        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                            local npcRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                            if npcRoot and (root.Position - npcRoot.Position).Magnitude <= PERMANENT.Range then
                                count = count + 1
                            end
                        end
                    end
                end
            end
        end)
        NPCCount.Text = "NPCs in range: " .. count
        task.wait(0.5)
    end
end)

-- Raid Status Update
task.spawn(function()
    while ScriptActive do
        if Settings.AutoRaid then
            pcall(function()
                -- Update boss info
                local boss = findMinotaurBoss()
                if boss then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local dist = math.floor((char.HumanoidRootPart.Position - boss.rootPart.Position).Magnitude)
                        local hp = math.floor((boss.humanoid.Health / boss.humanoid.MaxHealth) * 100)
                        BossHealth.Text = "👹 Boss: Minotaur | HP: " .. hp .. "%"
                        BossDistance.Text = "📏 Distance: " .. dist .. "m"
                        
                        if hp <= 0 then
                            BossHealth.Text = "👹 Boss: Defeated! ✅"
                            BossHealth.TextColor3 = Color3.fromRGB(100, 255, 100)
                        else
                            BossHealth.TextColor3 = Color3.fromRGB(255, 100, 100)
                        end
                    end
                else
                    BossHealth.Text = "👹 Boss: Not found"
                    BossDistance.Text = "📏 Distance: N/A"
                end
                
                -- Update lever info
                local lever = findLever()
                if lever then
                    LeverStatus.Text = "🔧 Lever: Found ✅"
                    LeverStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
                else
                    LeverStatus.Text = "🔧 Lever: Not found"
                    LeverStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
            end)
        end
        task.wait(1)
    end
end)

-- Apply Permanent Stats
task.spawn(function()
    while ScriptActive do
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local h = char:FindFirstChild("Humanoid")
                if h then
                    h.WalkSpeed = PERMANENT.WalkSpeed
                    h.JumpPower = PERMANENT.JumpPower
                end
            end
            workspace.CurrentCamera.FieldOfView = PERMANENT.FOV
        end)
        task.wait(0.5)
    end
end)

-- AOE Farm
task.spawn(function()
    while ScriptActive do
        if Settings.Farming then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                local npcs = {}
                local npcFolder = Workspace:FindFirstChild("NPCs")
                if npcFolder then
                    for _, obj in pairs(npcFolder:GetChildren()) do
                        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                            local npcRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                            if npcRoot then
                                local dist = (root.Position - npcRoot.Position).Magnitude
                                if dist <= PERMANENT.Range then
                                    table.insert(npcs, {root = npcRoot, dist = dist})
                                end
                            end
                        end
                    end
                end
                table.sort(npcs, function(a, b) return a.dist < b.dist end)
                
                for _, npc in pairs(npcs) do
                    root.CFrame = CFrame.lookAt(root.Position, Vector3.new(npc.root.Position.X, root.Position.Y, npc.root.Position.Z))
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end)
        end
        task.wait(0.15)
    end
end)

-- Auto Raid System
task.spawn(function()
    while ScriptActive do
        if Settings.AutoRaid then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                -- Step 1: Find and pull lever if enabled
                if Settings.AutoPullLever and tick() - LastPullTime > 5 then
                    local lever = findLever()
                    if lever then
                        RaidStatus = "Pulling lever..."
                        RaidStatusDisplay.Text = "🏛️ Status: Pulling lever..."
                        pullLever(lever)
                        RaidStatus = "Lever pulled"
                        RaidStatusDisplay.Text = "🏛️ Status: Lever pulled ✅"
                        task.wait(2)
                    end
                end
                
                -- Step 2: Find and attack boss if enabled
                if Settings.AutoAttackBoss then
                    local boss = findMinotaurBoss()
                    if boss and boss.humanoid.Health > 0 then
                        RaidStatus = "Moving to boss..."
                        RaidStatusDisplay.Text = "🏛️ Status: Moving to boss..."
                        
                        -- Move to boss
                        moveToTarget(boss.rootPart.Position)
                        
                        -- Attack boss
                        if (root.Position - boss.rootPart.Position).Magnitude <= 15 then
                            RaidStatus = "Attacking boss!"
                            RaidStatusDisplay.Text = "🏛️ Status: Attacking boss! ⚔️"
                            RaidStatusDisplay.TextColor3 = Color3.fromRGB(255, 100, 100)
                            
                            for i = 1, 10 do
                                if not Settings.AutoRaid then break end
                                if boss.humanoid.Health <= 0 then break end
                                attackTarget(boss.rootPart)
                                task.wait(0.3)
                            end
                        end
                    else
                        RaidStatus = "Waiting for boss..."
                        RaidStatusDisplay.Text = "🏛️ Status: Waiting for boss..."
                        RaidStatusDisplay.TextColor3 = Color3.fromRGB(255, 200, 0)
                    end
                end
            end)
        end
        task.wait(2)
    end
end)

print("✅ Sailor Piece GUI Loaded! | Raid System | Text Minimize | PC + Mobile | Auto Bounty")
