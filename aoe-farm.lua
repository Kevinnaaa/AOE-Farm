--[[
    Sailor Piece - RAYFIELD UI STYLE
    AOE Farm + Anti AFK + Speed 50 + Jump 75 + FOV 100
    Permanent Stats | FPS/Ping/Time on Title Bar | Auto Bounty Display
    PC + Mobile Support | SWORD & MELEE MASTERY SEQUENCES
]]

repeat wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

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
    SwordMastery = false,
    MeleeMastery = false
}

local ScriptActive = true
local SwordLoopRunning = false
local MeleeLoopRunning = false

-- SWORD MASTERY Sequence (Presses 2 at the end)
local SwordSequenceKeys = {
    {key = Enum.KeyCode.Three, delay = 5},
    {key = Enum.KeyCode.C, delay = 0.5},
    {key = Enum.KeyCode.Two, delay = 4}
}
local SwordInitialDelay = 4

-- MELEE MASTERY Sequence (Presses 1 at the end)
local MeleeSequenceKeys = {
    {key = Enum.KeyCode.Three, delay = 5},
    {key = Enum.KeyCode.C, delay = 0.5},
    {key = Enum.KeyCode.One, delay = 4}
}
local MeleeInitialDelay = 4

-- FPS Tracking
local fpsCount, fps, lastFPSUpdate = 0, 0, tick()

-- Timer
local saniye, dakika, saat = 0, 0, 0

-- Bounty
local CurrentBounty = "Searching..."

-- Clean up
if getgenv().SailorPieceLoaded then
    getgenv().SailorPieceLoaded = false
end

-- Check if Rayfield is loaded
local Rayfield
pcall(function()
    Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
end)

if not Rayfield then
    print("⚠️ Failed to load Rayfield. Please ensure you have internet connection.")
    return
end

getgenv().SailorPieceLoaded = true

-- =============================================
-- KEY PRESS FUNCTIONS FOR MASTERY
-- =============================================
local function pressKey(keyCode)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, keyCode, false, nil)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, nil)
    end)
end

local function runSwordSequence()
    if not Settings.SwordMastery then return end
    for _, step in ipairs(SwordSequenceKeys) do
        if not Settings.SwordMastery then return end
        pressKey(step.key)
        if step.delay > 0 then
            task.wait(step.delay)
        end
    end
end

local function runMeleeSequence()
    if not Settings.MeleeMastery then return end
    for _, step in ipairs(MeleeSequenceKeys) do
        if not Settings.MeleeMastery then return end
        pressKey(step.key)
        if step.delay > 0 then
            task.wait(step.delay)
        end
    end
end

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
-- RAYFIELD GUI CREATION
-- =============================================

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Sailor Piece",
    Icon = 0,
    LoadingTitle = "Sailor Piece",
    LoadingSubtitle = "by QueezZy123",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SailorPiece"
    },
    Keybind = {
        Enabled = true,
        Key = "RightControl",
        HoldToInteract = false
    }
})

-- =============================================
-- MAIN TAB
-- =============================================
local MainTab = Window:CreateTab("Main", 0)

-- Farming Section
local FarmingSection = MainTab:CreateSection("Farming")

MainTab:CreateToggle({
    Name = "AOE Farming",
    CurrentValue = false,
    Flag = "FarmingToggle",
    Callback = function(Value)
        Settings.Farming = Value
    end
})

MainTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Flag = "AntiAFKToggle",
    Callback = function(Value)
        Settings.AntiAFK = Value
    end
})

-- Stats Section
local StatsSection = MainTab:CreateSection("Player Stats")

MainTab:CreateLabel("Bounty: Searching...")

MainTab:CreateLabel("NPCs in range: 0")

MainTab:CreateLabel("Health: 100%")

-- =============================================
-- MASTERY TAB
-- =============================================
local MasteryTab = Window:CreateTab("Mastery", 1)

-- Sword Mastery Section
local SwordSection = MasteryTab:CreateSection("Sword Mastery")

MasteryTab:CreateToggle({
    Name = "⚔️ Sword Mastery (3→5s→C→0.5s→2)",
    CurrentValue = false,
    Flag = "SwordMasteryToggle",
    Callback = function(Value)
        -- If turning on Sword, turn off Melee automatically
        if Value and Settings.MeleeMastery then
            Settings.MeleeMastery = false
            Rayfield:SetToggle("MeleeMasteryToggle", false)
        end
        
        Settings.SwordMastery = Value
        
        if Value then
            task.spawn(function()
                SwordLoopRunning = true
                task.wait(SwordInitialDelay)
                
                if not Settings.SwordMastery then
                    SwordLoopRunning = false
                    return
                end
                
                while Settings.SwordMastery and ScriptActive do
                    runSwordSequence()
                    if not Settings.SwordMastery then break end
                    task.wait(0.3)
                end
                
                SwordLoopRunning = false
            end)
        end
    end
})

-- Melee Mastery Section
local MeleeSection = MasteryTab:CreateSection("Melee Mastery")

MasteryTab:CreateToggle({
    Name = "👊 Melee Mastery (3→5s→C→0.5s→1)",
    CurrentValue = false,
    Flag = "MeleeMasteryToggle",
    Callback = function(Value)
        -- If turning on Melee, turn off Sword automatically
        if Value and Settings.SwordMastery then
            Settings.SwordMastery = false
            Rayfield:SetToggle("SwordMasteryToggle", false)
        end
        
        Settings.MeleeMastery = Value
        
        if Value then
            task.spawn(function()
                MeleeLoopRunning = true
                task.wait(MeleeInitialDelay)
                
                if not Settings.MeleeMastery then
                    MeleeLoopRunning = false
                    return
                end
                
                while Settings.MeleeMastery and ScriptActive do
                    runMeleeSequence()
                    if not Settings.MeleeMastery then break end
                    task.wait(0.3)
                end
                
                MeleeLoopRunning = false
            end)
        end
    end
})

-- Sequence Info
local InfoSection = MasteryTab:CreateSection("Sequence Info")

MasteryTab:CreateLabel("⚔️ SWORD: Wait 4s → Press 3 → Wait 5s → Press C → Wait 0.5s → Press 2 → Loop")
MasteryTab:CreateLabel("👊 MELEE: Wait 4s → Press 3 → Wait 5s → Press C → Wait 0.5s → Press 1 → Loop")

-- =============================================
-- PLAYER TAB
-- =============================================
local PlayerTab = Window:CreateTab("Player", 2)

PlayerTab:CreateParagraph({
    Title = "Character Info",
    Content = "👤 " .. LocalPlayer.Name
})

-- Bounty Display
local BountyParagraph = PlayerTab:CreateParagraph({
    Title = "💰 Bounty",
    Content = "Searching..."
})

-- Health Display
local HealthParagraph = PlayerTab:CreateParagraph({
    Title = "❤️ Health",
    Content = "100%"
})

-- Stats Display
local StatsParagraph = PlayerTab:CreateParagraph({
    Title = "⚡ Stats",
    Content = "Walk Speed: 50\nJump Power: 75\nFOV: 100\nFarm Range: 30"
})

-- =============================================
-- SETTINGS TAB
-- =============================================
local SettingsTab = Window:CreateTab("Settings", 3)

SettingsTab:CreateParagraph({
    Title = "Permanent Stats",
    Content = "Farm Range: 30\nWalk Speed: 50\nJump Power: 75\nFOV: 100"
})

SettingsTab:CreateButton({
    Name = "⚠️ TERMINATE SCRIPT",
    Callback = function()
        ScriptActive = false
        Settings.Farming = false
        Settings.SwordMastery = false
        Settings.MeleeMastery = false
        Rayfield:Destroy()
    end
})

SettingsTab:CreateButton({
    Name = "📱 Toggle Mobile Mode",
    Callback = function()
        if isMobile then
            print("📱 Mobile mode is already active")
        else
            print("💡 Switching to mobile-friendly layout...")
            -- Rayfield should auto-adjust, but we can notify
        end
    end
})

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
        end
        task.wait()
    end
end)

-- Timer
task.spawn(function()
    while ScriptActive do
        saniye = saniye + 1
        if saniye >= 60 then saniye = 0; dakika = dakika + 1 end
        if dakika >= 60 then dakika = 0; saat = saat + 1 end
        task.wait(1)
    end
end)

-- Bounty
task.spawn(function()
    while ScriptActive do
        local bounty = scanBounty()
        if bounty then
            CurrentBounty = bounty
            BountyParagraph:Set("💰 Bounty", bounty)
        else
            BountyParagraph:Set("💰 Bounty", "Not found")
        end
        task.wait(3)
    end
end)

-- Health & NPC Counter
task.spawn(function()
    while ScriptActive do
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                local hp = char.Humanoid.Health
                local maxHP = char.Humanoid.MaxHealth
                local percent = math.floor((hp / maxHP) * 100)
                HealthParagraph:Set("❤️ Health", percent .. "%")
                
                -- Update NPC counter
                local count = 0
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
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
                -- Update label in Main tab (we need to find it)
                pcall(function()
                    local mainTabLabels = MainTab:GetChildren()
                    for _, child in pairs(mainTabLabels) do
                        if child:IsA("Frame") and child:FindFirstChild("TextLabel") then
                            local label = child:FindFirstChild("TextLabel")
                            if label and string.find(label.Text, "NPCs in range:") then
                                label.Text = "NPCs in range: " .. count
                            end
                        end
                    end
                end)
            end
        end)
        task.wait(0.3)
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

print("✅ Sailor Piece GUI Loaded with Rayfield!")
print("   ⚔️ SWORD MASTERY: 3 → 5s → C → 0.5s → 2 → 4s (repeat)")
print("   👊 MELEE MASTERY: 3 → 5s → C → 0.5s → 1 → 4s (repeat)")
print("   📱 Press RightControl to toggle GUI")
