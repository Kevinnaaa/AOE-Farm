--[[
    Sailor Piece - ALL IN ONE (RAYFIELD STYLE)
    AOE Farm + Anti AFK + Speed/Jump/FOV + Stats Display
--]]

repeat wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

-- Settings
local Settings = {
    Farming = false,
    AutoClick = false,
    AntiAFK = true,
    Range = 30,
    WalkSpeed = 50,
    JumpPower = 75,
    FOV = 100,
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
-- RAYFIELD-STYLE GUI
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

-- Rounded corners effect
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = Main

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 6)
TitleCorner.Parent = TitleBar

-- Fix bottom corners
local TitleBottom = Instance.new("Frame")
TitleBottom.Size = UDim2.new(1, 0, 0, 6)
TitleBottom.Position = UDim2.new(0, 0, 1, -6)
TitleBottom.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBottom.BorderSizePixel = 0
TitleBottom.Parent = TitleBar

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
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinBtn

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -32)
Sidebar.Position = UDim2.new(0, 0, 0, 32)
Sidebar.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

-- Sidebar Border
local SidebarBorder = Instance.new("Frame")
SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
SidebarBorder.Position = UDim2.new(1, 0, 0, 0)
SidebarBorder.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SidebarBorder.BorderSizePixel = 0
SidebarBorder.Parent = Sidebar

-- Sidebar Logo/Info
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

-- Tab Buttons
local Tabs = {}
local TabNames = {"Farm", "Player", "Visuals", "Settings"}
local TabIcons = {"⚔️", "👤", "👁️", "⚙️"}
local TabPages = {}
local CurrentTab = 1

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
    btn.Parent = Sidebar
    btn.AutoButtonColor = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    -- Page Frame
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, -140, 1, -32)
    page.Position = UDim2.new(0, 140, 0, 32)
    page.BackgroundTransparency = 1
    page.Visible = (index == 1)
    page.Parent = Main
    
    btn.MouseButton1Click:Connect(function()
        for i, tab in pairs(Tabs) do
            tab.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
            tab.TextColor3 = Color3.fromRGB(150, 150, 150)
            TabPages[i].Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        page.Visible = true
        CurrentTab = index
    end)
    
    table.insert(Tabs, btn)
    table.insert(TabPages, page)
    return page
end

-- =============================================
-- SECTION CREATION HELPERS
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
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, -30, 0, 30)
    toggle.Position = UDim2.new(0, 15, 0, yPos)
    toggle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    toggle.BorderSizePixel = 0
    toggle.Parent = parent
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 4)
    toggleCorner.Parent = toggle
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Text = title
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.Parent = toggle
    
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 36, 0, 18)
    switch.Position = UDim2.new(1, -46, 0.5, -9)
    switch.BackgroundColor3 = default and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(50, 50, 50)
    switch.BorderSizePixel = 0
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.Parent = toggle
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = switch
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    
    local state = default
    
    switch.MouseButton1Click:Connect(function()
        state = not state
        switch.BackgroundColor3 = state and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(50, 50, 50)
        dot:TweenPosition(UDim2.new(state and 1 or 0, state and -16 or 2, 0.5, -7), "Out", "Quad", 0.15, true)
        callback(state)
    end)
    
    return toggle, switch, dot
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
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end)
    
    return btn
end

local function CreateSlider(parent, title, min, max, default, yPos, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -30, 0, 55)
    frame.Position = UDim2.new(0, 15, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 4)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 18)
    label.Position = UDim2.new(0, 10, 0, 6)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Text = title .. ": " .. default
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 10
    label.Parent = frame
    
    -- Slider Track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 4)
    track.Position = UDim2.new(0, 10, 0, 32)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    track.BorderSizePixel = 0
    track.Parent = frame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 2)
    trackCorner.Parent = track
    
    -- Fill
    local percent = (default - min) / (max - min)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(percent, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fill
    
    -- Knob
    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(percent, -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Text = ""
    knob.AutoButtonColor = false
    knob.Parent = track
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local dragging = false
    
    local function updateSlider(input)
        local mousePos = UserInputService:GetMouseLocation()
        local trackPos = track.AbsolutePosition
        local trackSize = track.AbsoluteSize
        local relativeX = math.clamp(mousePos.X - trackPos.X, 0, trackSize.X)
        local newPercent = relativeX / trackSize.X
        local value = math.floor(min + (max - min) * newPercent)
        
        fill.Size = UDim2.new(newPercent, 0, 1, 0)
        knob.Position = UDim2.new(newPercent, -6, 0.5, -6)
        label.Text = title .. ": " .. value
        callback(value)
    end
    
    knob.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    track.MouseButton1Down:Connect(function()
        dragging = true
        updateSlider()
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider()
        end
    end)
    
    return frame
end

-- =============================================
-- CREATE TABS
-- =============================================
local FarmPage = CreateTab("Farm", "⚔️", 1)
local PlayerPage = CreateTab("Player", "👤", 2)
local VisualsPage = CreateTab("Visuals", "👁️", 3)
local SettingsPage = CreateTab("Settings", "⚙️", 4)

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

CreateSection(FarmPage, "TARGETING", 170)

CreateSlider(FarmPage, "Farm Range", 5, 100, 30, 200, function(value)
    Settings.Range = value
end)

-- NPC Counter
local NPCCount = Instance.new("TextLabel")
NPCCount.Size = UDim2.new(1, -30, 0, 14)
NPCCount.Position = UDim2.new(0, 15, 0, 260)
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

-- Stats Display
local PlayerStats = Instance.new("Frame")
PlayerStats.Size = UDim2.new(1, -30, 0, 80)
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

CreateButton(PlayerPage, "🔍 Scan Character Data", 158, function()
    StatsText.Text = "🔍 Scanning...\n"
    local found = {}
    
    pcall(function()
        -- Check leaderstats
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("stats") or LocalPlayer:FindFirstChild("Data")
        if leaderstats then
            table.insert(found, "📊 Stats:")
            for _, stat in pairs(leaderstats:GetChildren()) do
                if stat:IsA("IntValue") or stat:IsA("NumberValue") or stat:IsA("StringValue") then
                    table.insert(found, "  • " .. stat.Name .. ": " .. tostring(stat.Value))
                end
            end
        end
        
        -- Check PlayerGui
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, child in pairs(playerGui:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    local text = child.Text or ""
                    if string.find(text, "Bounty") or string.find(text, "Melee") or string.find(text, "Sword") 
                    or string.find(text, "Race") or string.find(text, "Level") or string.find(text, "Fruit")
                    or string.find(text, "Devil") or string.find(text, "Beli") then
                        -- Clean up text
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

CreateSection(PlayerPage, "HEALTH", 200)

-- Health Bar
local HealthBarBg = Instance.new("Frame")
HealthBarBg.Size = UDim2.new(1, -30, 0, 20)
HealthBarBg.Position = UDim2.new(0, 15, 0, 228)
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
-- VISUALS TAB
-- =============================================
CreateSection(VisualsPage, "MOVEMENT", 10)

CreateSlider(VisualsPage, "Walk Speed", 16, 100, 50, 38, function(value)
    Settings.WalkSpeed = value
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end)
end)

CreateSlider(VisualsPage, "Jump Power", 25, 200, 75, 96, function(value)
    Settings.JumpPower = value
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = value
        end
    end)
end)

CreateSection(VisualsPage, "CAMERA", 160)

CreateSlider(VisualsPage, "Field of View", 30, 120, 100, 188, function(value)
    Settings.FOV = value
    pcall(function()
        workspace.CurrentCamera.FieldOfView = value
    end)
end)

-- =============================================
-- SETTINGS TAB
-- =============================================
CreateSection(SettingsPage, "STATUS", 10)

-- FPS Display
local FPSDisplay = Instance.new("TextLabel")
FPSDisplay.Size = UDim2.new(1, -30, 0, 20)
FPSDisplay.Position = UDim2.new(0, 15, 0, 38)
FPSDisplay.BackgroundTransparency = 1
FPSDisplay.TextColor3 = Color3.fromRGB(0, 255, 100)
FPSDisplay.Text = "FPS: --"
FPSDisplay.TextXAlignment = Enum.TextXAlignment.Left
FPSDisplay.Font = Enum.Font.GothamBold
FPSDisplay.TextSize = 11
FPSDisplay.Parent = SettingsPage

-- Ping Display
local PingDisplay = Instance.new("TextLabel")
PingDisplay.Size = UDim2.new(1, -30, 0, 20)
PingDisplay.Position = UDim2.new(0, 15, 0, 58)
PingDisplay.BackgroundTransparency = 1
PingDisplay.TextColor3 = Color3.fromRGB(100, 200, 255)
PingDisplay.Text = "Ping: --ms"
PingDisplay.TextXAlignment = Enum.TextXAlignment.Left
PingDisplay.Font = Enum.Font.GothamBold
PingDisplay.TextSize = 11
PingDisplay.Parent = SettingsPage

-- Timer Display
local TimerDisplay = Instance.new("TextLabel")
TimerDisplay.Size = UDim2.new(1, -30, 0, 20)
TimerDisplay.Position = UDim2.new(0, 15, 0, 78)
TimerDisplay.BackgroundTransparency = 1
TimerDisplay.TextColor3 = Color3.fromRGB(255, 200, 0)
TimerDisplay.Text = "Runtime: 0:0:0"
TimerDisplay.TextXAlignment = Enum.TextXAlignment.Left
TimerDisplay.Font = Enum.Font.GothamBold
TimerDisplay.TextSize = 11
TimerDisplay.Parent = SettingsPage

CreateSection(SettingsPage, "ACTIONS", 110)

CreateButton(SettingsPage, "⚠️ Terminate Script", 138, function()
    ScriptActive = false
    Settings.Farming = false
    Settings.AutoClick = false
    GUI:Destroy()
end)

-- =============================================
-- MINIMIZE FUNCTIONALITY
-- =============================================
MinBtn.MouseButton1Click:Connect(function()
    Settings.Minimized = not Settings.Minimized
    if Settings.Minimized then
        Main.Size = UDim2.new(0, 500, 0, 32)
        MinBtn.Text = "□"
    else
        Main.Size = UDim2.new(0, 500, 0, 320)
        MinBtn.Text = "—"
    end
end)

-- Draggable
local dragging = false
local dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
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
                            if npcRoot and (root.Position - npcRoot.Position).Magnitude <= Settings.Range then
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

-- Apply Stats
task.spawn(function()
    while ScriptActive do
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local h = char:FindFirstChild("Humanoid")
                if h then
                    h.WalkSpeed = Settings.WalkSpeed
                    h.JumpPower = Settings.JumpPower
                end
            end
            workspace.CurrentCamera.FieldOfView = Settings.FOV
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
                                if dist <= Settings.Range then
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

print("✅ Sailor Piece - Rayfield Style GUI Loaded | by kibsss")
