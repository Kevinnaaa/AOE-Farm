--[[
    Sailor Piece - ALL IN ONE (RAYFIELD STYLE - FIXED)
    AOE Farm + Anti AFK + Speed 50 + Jump 75 + FOV 100
    Permanent Stats | Terminate Button
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

-- Permanent Settings (not changeable)
local PERMANENT = {
    Range = 30,
    WalkSpeed = 50,
    JumpPower = 75,
    FOV = 100
}

-- Toggle Settings
local Settings = {
    Farming = false,
    AutoClick = false,
    AntiAFK = true,
    ClickSpeed = 0.1,
    Minimized = false
}

local ScriptActive = true

-- FPS Tracking
local fpsCount, fps, lastFPSUpdate = 0, 0, tick()

-- Timer
local saniye, dakika, saat = 0, 0, 0

-- Clean up
if getgenv().SailorPieceLoaded then
    getgenv().SailorPieceLoaded = false
    if game.CoreGui:FindFirstChild("SailorPieceGUI") then
        game.CoreGui.SailorPieceGUI:Destroy()
    end
end
getgenv().SailorPieceLoaded = true

-- =============================================
-- GUI CREATION
-- =============================================
local GUI = Instance.new("ScreenGui")
GUI.Name = "SailorPieceGUI"
GUI.ResetOnSpawn = false
GUI.Parent = game.CoreGui
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Container
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 500, 0, 320)
Main.Position = UDim2.new(0.5, -250, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = GUI

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = Main

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Text = "sailor piece"
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 13
TitleText.Parent = TitleBar

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -35, 0, 1)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MinBtn.BorderSizePixel = 0
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Text = "—"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.AutoButtonColor = false
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinBtn

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, 0, 1, -32)
ContentContainer.Position = UDim2.new(0, 0, 0, 32)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = Main

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, 0)
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
SidebarLogo.Size = UDim2.new(1, 0, 0, 45)
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
LogoText.TextSize = 10
LogoText.Parent = SidebarLogo

local LogoSub = Instance.new("TextLabel")
LogoSub.Size = UDim2.new(1, -20, 0, 14)
LogoSub.Position = UDim2.new(0, 10, 0, 24)
LogoSub.BackgroundTransparency = 1
LogoSub.TextColor3 = Color3.fromRGB(120, 120, 120)
LogoSub.Text = "by kibsss"
LogoSub.TextXAlignment = Enum.TextXAlignment.Left
LogoSub.Font = Enum.Font.Gotham
LogoSub.TextSize = 9
LogoSub.Parent = SidebarLogo

-- Tab System
local TabButtons = {}
local TabPages = {}

local function CreateTab(name, icon, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, 52 + (index - 1) * 36)
    btn.BackgroundColor3 = index == 1 and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(23, 23, 23)
    btn.BorderSizePixel = 0
    btn.TextColor3 = index == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    btn.Text = "  " .. icon .. "  " .. name
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.Parent = Sidebar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, -140, 1, 0)
    page.Position = UDim2.new(0, 140, 0, 0)
    page.BackgroundTransparency = 1
    page.Visible = (index == 1)
    page.Parent = ContentContainer
    
    btn.MouseButton1Click:Connect(function()
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
    section.Size = UDim2.new(1, -30, 0, 24)
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
    text.Size = UDim2.new(1, 0, 0, 18)
    text.Position = UDim2.new(0, 0, 0, 4)
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
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -30, 0, 30)
    bg.Position = UDim2.new(0, 15, 0, yPos)
    bg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    bg.BorderSizePixel = 0
    bg.Parent = parent
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 4)
    bgCorner.Parent = bg
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Text = title
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.Parent = bg
    
    local state = default
    
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 36, 0, 18)
    switch.Position = UDim2.new(1, -46, 0.5, -9)
    switch.BackgroundColor3 = state and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(50, 50, 50)
    switch.BorderSizePixel = 0
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.Parent = bg
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = switch
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    
    switch.MouseButton1Click:Connect(function()
        state = not state
        switch.BackgroundColor3 = state and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(50, 50, 50)
        local targetPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(dot, tweenInfo, {Position = targetPos})
        tween:Play()
        callback(state)
    end)
    
    return bg
end

local function CreateButton(parent, title, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 32)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = title
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end)
    
    return btn
end

local function CreateInfoLabel(parent, text, yPos, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 0, 20)
    label.Position = UDim2.new(0, 15, 0, yPos)
    label.BackgroundTransparency = 1
    label.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.Parent = parent
    return label
end

-- =============================================
-- CREATE TABS
-- =============================================
local FarmPage = CreateTab("Farm", "⚔️", 1)
local PlayerPage = CreateTab("Player", "👤", 2)
local SettingsPage = CreateTab("Settings", "⚙️", 3)

-- =============================================
-- FARM TAB
-- =============================================
CreateSection(FarmPage, "MAIN", 10)

local FarmStatus = Instance.new("TextLabel")
FarmStatus.Size = UDim2.new(1, -30, 0, 18)
FarmStatus.Position = UDim2.new(0, 15, 0, 38)
FarmStatus.BackgroundTransparency = 1
FarmStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
FarmStatus.Text = "● Idle"
FarmStatus.TextXAlignment = Enum.TextXAlignment.Left
FarmStatus.Font = Enum.Font.Gotham
FarmStatus.TextSize = 10
FarmStatus.Parent = FarmPage

CreateToggle(FarmPage, "AOE Farming", false, 62, function(state)
    Settings.Farming = state
    FarmStatus.Text = state and "● Farming" or "● Idle"
    FarmStatus.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(150, 150, 150)
end)

CreateToggle(FarmPage, "Auto Click", false, 96, function(state)
    Settings.AutoClick = state
end)

CreateToggle(FarmPage, "Anti-AFK", true, 130, function(state)
    Settings.AntiAFK = state
end)

CreateSection(FarmPage, "STATS INFO", 170)

CreateInfoLabel(FarmPage, "Range: 30 (Fixed)", 198, Color3.fromRGB(255, 200, 0))
CreateInfoLabel(FarmPage, "Speed: 50 (Fixed)", 218, Color3.fromRGB(255, 200, 0))
CreateInfoLabel(FarmPage, "Jump: 75 (Fixed)", 238, Color3.fromRGB(255, 200, 0))
CreateInfoLabel(FarmPage, "FOV: 100 (Fixed)", 258, Color3.fromRGB(255, 200, 0))

-- NPC Counter (bottom of farm page)
local NPCCount = Instance.new("TextLabel")
NPCCount.Size = UDim2.new(1, -30, 0, 14)
NPCCount.Position = UDim2.new(0, 15, 0, 278)
NPCCount.BackgroundTransparency = 1
NPCCount.TextColor3 = Color3.fromRGB(120, 120, 120)
NPCCount.Text = "NPCs in range: 0"
NPCCount.TextXAlignment = Enum.TextXAlignment.Left
NPCCount.Font = Enum.Font.Gotham
NPCCount.TextSize = 9
NPCCount.Parent = FarmPage

-- =============================================
-- PLAYER TAB
-- =============================================
CreateSection(PlayerPage, "CHARACTER INFO", 10)

local PlayerName = Instance.new("TextLabel")
PlayerName.Size = UDim2.new(1, -30, 0, 20)
PlayerName.Position = UDim2.new(0, 15, 0, 38)
PlayerName.BackgroundTransparency = 1
PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerName.Text = "👤 " .. LocalPlayer.Name
PlayerName.TextXAlignment = Enum.TextXAlignment.Left
PlayerName.Font = Enum.Font.GothamBold
PlayerName.TextSize = 12
PlayerName.Parent = PlayerPage

local PlayerStats = Instance.new("Frame")
PlayerStats.Size = UDim2.new(1, -30, 0, 100)
PlayerStats.Position = UDim2.new(0, 15, 0, 68)
PlayerStats.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
PlayerStats.BorderSizePixel = 0
PlayerStats.Parent = PlayerPage

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 4)
StatsCorner.Parent = PlayerStats

local StatsText = Instance.new("TextLabel")
StatsText.Size = UDim2.new(1, -20, 1, -10)
StatsText.Position = UDim2.new(0, 10, 0, 5)
StatsText.BackgroundTransparency = 1
StatsText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsText.Text = "No data scanned yet..."
StatsText.TextXAlignment = Enum.TextXAlignment.Left
StatsText.TextYAlignment = Enum.TextYAlignment.Top
StatsText.Font = Enum.Font.Gotham
StatsText.TextSize = 10
StatsText.TextWrapped = true
StatsText.Parent = PlayerStats

CreateButton(PlayerPage, "🔍 Scan Character Data", 178, function()
    StatsText.Text = "🔍 Scanning...\n"
    local found = {}
    
    pcall(function()
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("stats") or LocalPlayer:FindFirstChild("Data")
        if leaderstats then
            table.insert(found, "📊 Stats:")
            for _, stat in pairs(leaderstats:GetChildren()) do
                if stat:IsA("IntValue") or stat:IsA("NumberValue") or stat:IsA("StringValue") then
                    table.insert(found, "  • " .. stat.Name .. ": " .. tostring(stat.Value))
                end
            end
        end
        
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, child in pairs(playerGui:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    local text = child.Text or ""
                    if string.find(text, "Bounty") or string.find(text, "Melee") or string.find(text, "Sword") 
                    or string.find(text, "Race") or string.find(text, "Level") or string.find(text, "Fruit")
                    or string.find(text, "Devil") or string.find(text, "Beli") then
                        local clean = text:gsub("\n", " | "):gsub("%s+", " ")
                        if #clean < 60 then
                            table.insert(found, "📋 " .. clean)
                        end
                    end
                end
            end
        end
    end)
    
    if #found > 0 then
        StatsText.Text = table.concat(found, "\n")
    else
        StatsText.Text = "❌ No data found.\nOpen game menu & try again."
    end
end)

CreateSection(PlayerPage, "HEALTH", 220)

local HealthBarBg = Instance.new("Frame")
HealthBarBg.Size = UDim2.new(1, -30, 0, 20)
HealthBarBg.Position = UDim2.new(0, 15, 0, 248)
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
CreateSection(SettingsPage, "STATUS", 10)

local FPSDisplay = CreateInfoLabel(SettingsPage, "FPS: --", 38, Color3.fromRGB(0, 255, 100))
local PingDisplay = CreateInfoLabel(SettingsPage, "Ping: --ms", 58, Color3.fromRGB(100, 200, 255))
local TimerDisplay = CreateInfoLabel(SettingsPage, "Runtime: 0:0:0", 78, Color3.fromRGB(255, 200, 0))

CreateSection(SettingsPage, "PERMANENT STATS", 108)

CreateInfoLabel(SettingsPage, "Farm Range: 30", 136, Color3.fromRGB(255, 200, 0))
CreateInfoLabel(SettingsPage, "Walk Speed: 50", 156, Color3.fromRGB(255, 200, 0))
CreateInfoLabel(SettingsPage, "Jump Power: 75", 176, Color3.fromRGB(255, 200, 0))
CreateInfoLabel(SettingsPage, "FOV: 100", 196, Color3.fromRGB(255, 200, 0))

CreateSection(SettingsPage, "TERMINATE", 226)

CreateButton(SettingsPage, "⚠️ TERMINATE SCRIPT", 254, function()
    ScriptActive = false
    Settings.Farming = false
    Settings.AutoClick = false
    GUI:Destroy()
end)

-- =============================================
-- MINIMIZE
-- =============================================
local mainSize = UDim2.new(0, 500, 0, 320)
local minimizedSize = UDim2.new(0, 500, 0, 32)

MinBtn.MouseButton1Click:Connect(function()
    Settings.Minimized = not Settings.Minimized
    if Settings.Minimized then
        Main.Size = minimizedSize
        MinBtn.Text = "+"
    else
        Main.Size = mainSize
        MinBtn.Text = "—"
    end
end)

-- Draggable
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
        TimerDisplay.Text = "Runtime: " .. saat .. ":" .. dakika .. ":" .. saniye
        task.wait(1)
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

-- AOE Farm (Uses PERMANENT.Range)
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

-- Auto Click
task.spawn(function()
    while ScriptActive do
        if Settings.AutoClick then
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
        end
        task.wait(Settings.ClickSpeed)
    end
end)

print("✅ Sailor Piece GUI Loaded! | Range:30 | Speed:50 | Jump:75 | FOV:100")
