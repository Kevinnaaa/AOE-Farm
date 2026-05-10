--[[
    Sailor Piece - ALL IN ONE (TABBED VERSION)
    AOE Farm + Anti AFK (VirtualUser PC/Mobile) + Speed 50 + Jump 75 + FOV 100
    FPS & Ping Display + Timer | Character Info | No Hotkeys
--]]

-- Anti-AFK initialization
repeat wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local Farming = false
local AutoClick = false
local ScriptActive = true
local AntiAFKEnabled = true
local Minimized = false
local Range = 30
local WalkSpeed = 50
local JumpPower = 75
local FOV = 100
local ClickSpeed = 0.1

-- FPS Tracking
local fpsCount = 0
local fps = 0
local lastFPSUpdate = tick()

-- Timer
local saniye = 0
local dakika = 0
local saat = 0

-- Character Data Cache
local charData = "No data found"

-- Clean up old instance if exists
if getgenv().AntiAfkExecuted then
    getgenv().AntiAfkExecuted = false
    getgenv().zamanbaslaticisi = false
    if game.CoreGui:FindFirstChild("AntiAFKGUI") then
        game.CoreGui.AntiAFKGUI:Destroy()
    end
end
getgenv().AntiAfkExecuted = true
getgenv().zamanbaslaticisi = true

-- =============================================
-- GUI CREATION
-- =============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AllInOne"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- DRAGGABLE MINIMIZE BUTTON
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 50, 0, 50)
MinBtn.Position = UDim2.new(0, 10, 0, 80)
MinBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MinBtn.BorderSizePixel = 0
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Text = "⚔️"
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 22
MinBtn.Active = true
MinBtn.Draggable = true
MinBtn.Parent = ScreenGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 340)
MainFrame.Position = UDim2.new(0, 65, 0, 80)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderText = Instance.new("TextLabel")
HeaderText.Size = UDim2.new(0.6, 0, 1, 0)
HeaderText.Position = UDim2.new(0, 12, 0, 0)
HeaderText.BackgroundTransparency = 1
HeaderText.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderText.Text = "⚔️ SAILOR PIECE"
HeaderText.TextXAlignment = Enum.TextXAlignment.Left
HeaderText.Font = Enum.Font.SourceSansBold
HeaderText.TextSize = 14
HeaderText.Parent = Header

local DashBtn = Instance.new("TextButton")
DashBtn.Size = UDim2.new(0, 28, 0, 28)
DashBtn.Position = UDim2.new(1, -32, 0, 4)
DashBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
DashBtn.BorderSizePixel = 0
DashBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DashBtn.Text = "—"
DashBtn.Font = Enum.Font.SourceSansBold
DashBtn.TextSize = 14
DashBtn.Parent = Header

-- Stats Bar (Always visible)
local StatsBar = Instance.new("Frame")
StatsBar.Size = UDim2.new(1, 0, 0, 30)
StatsBar.Position = UDim2.new(0, 0, 0, 35)
StatsBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
StatsBar.BorderSizePixel = 0
StatsBar.Parent = MainFrame

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(0.33, -5, 0, 14)
FPSLabel.Position = UDim2.new(0, 8, 0, 2)
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
FPSLabel.Text = "FPS: --"
FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
FPSLabel.Font = Enum.Font.SourceSansBold
FPSLabel.TextSize = 10
FPSLabel.Parent = StatsBar

local PingLabel = Instance.new("TextLabel")
PingLabel.Size = UDim2.new(0.33, -5, 0, 14)
PingLabel.Position = UDim2.new(0.33, 5, 0, 2)
PingLabel.BackgroundTransparency = 1
PingLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
PingLabel.Text = "Ping: --ms"
PingLabel.TextXAlignment = Enum.TextXAlignment.Center
PingLabel.Font = Enum.Font.SourceSansBold
PingLabel.TextSize = 10
PingLabel.Parent = StatsBar

local TimerLabel = Instance.new("TextLabel")
TimerLabel.Size = UDim2.new(0.33, -5, 0, 14)
TimerLabel.Position = UDim2.new(0.66, 0, 0, 2)
TimerLabel.BackgroundTransparency = 1
TimerLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
TimerLabel.Text = "0:0:0"
TimerLabel.TextXAlignment = Enum.TextXAlignment.Right
TimerLabel.Font = Enum.Font.SourceSansBold
TimerLabel.TextSize = 10
TimerLabel.Parent = StatsBar

local AFKStatusLabel = Instance.new("TextLabel")
AFKStatusLabel.Size = UDim2.new(1, -10, 0, 12)
AFKStatusLabel.Position = UDim2.new(0, 5, 0, 17)
AFKStatusLabel.BackgroundTransparency = 1
AFKStatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
AFKStatusLabel.Text = "Anti-AFK Active"
AFKStatusLabel.TextXAlignment = Enum.TextXAlignment.Center
AFKStatusLabel.Font = Enum.Font.SourceSans
AFKStatusLabel.TextSize = 9
AFKStatusLabel.Parent = StatsBar

-- =============================================
-- TAB BUTTONS
-- =============================================
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 28)
TabBar.Position = UDim2.new(0, 0, 0, 65)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local Tab1 = Instance.new("TextButton")
Tab1.Size = UDim2.new(0.33, -1, 1, 0)
Tab1.Position = UDim2.new(0, 0, 0, 0)
Tab1.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Tab1.BorderSizePixel = 0
Tab1.TextColor3 = Color3.fromRGB(255, 255, 255)
Tab1.Text = "FARM"
Tab1.Font = Enum.Font.SourceSansBold
Tab1.TextSize = 11
Tab1.Parent = TabBar

local Tab2 = Instance.new("TextButton")
Tab2.Size = UDim2.new(0.33, -1, 1, 0)
Tab2.Position = UDim2.new(0.33, 1, 0, 0)
Tab2.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Tab2.BorderSizePixel = 0
Tab2.TextColor3 = Color3.fromRGB(150, 150, 150)
Tab2.Text = "CHARACTER"
Tab2.Font = Enum.Font.SourceSansBold
Tab2.TextSize = 9
Tab2.Parent = TabBar

local Tab3 = Instance.new("TextButton")
Tab3.Size = UDim2.new(0.34, -1, 1, 0)
Tab3.Position = UDim2.new(0.66, 1, 0, 0)
Tab3.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Tab3.BorderSizePixel = 0
Tab3.TextColor3 = Color3.fromRGB(150, 150, 150)
Tab3.Text = "SETTINGS"
Tab3.Font = Enum.Font.SourceSansBold
Tab3.TextSize = 9
Tab3.Parent = TabBar

-- =============================================
-- TAB 1: FARM CONTENT
-- =============================================
local FarmTab = Instance.new("Frame")
FarmTab.Size = UDim2.new(1, 0, 1, -93)
FarmTab.Position = UDim2.new(0, 0, 0, 93)
FarmTab.BackgroundTransparency = 1
FarmTab.Visible = true
FarmTab.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 18)
StatusLabel.Position = UDim2.new(0, 10, 0, 8)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.Text = "● Ready"
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 11
StatusLabel.Parent = FarmTab

local NPCCounterLabel = Instance.new("TextLabel")
NPCCounterLabel.Size = UDim2.new(1, -20, 0, 14)
NPCCounterLabel.Position = UDim2.new(0, 10, 0, 28)
NPCCounterLabel.BackgroundTransparency = 1
NPCCounterLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
NPCCounterLabel.Text = "NPCs in range: 0"
NPCCounterLabel.TextXAlignment = Enum.TextXAlignment.Left
NPCCounterLabel.Font = Enum.Font.SourceSans
NPCCounterLabel.TextSize = 9
NPCCounterLabel.Parent = FarmTab

local Div1 = Instance.new("Frame")
Div1.Size = UDim2.new(1, -20, 0, 1)
Div1.Position = UDim2.new(0, 10, 0, 48)
Div1.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Div1.BorderSizePixel = 0
Div1.Parent = FarmTab

local ControlsLabel = Instance.new("TextLabel")
ControlsLabel.Size = UDim2.new(1, -20, 0, 16)
ControlsLabel.Position = UDim2.new(0, 10, 0, 54)
ControlsLabel.BackgroundTransparency = 1
ControlsLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
ControlsLabel.Text = "CONTROLS"
ControlsLabel.TextXAlignment = Enum.TextXAlignment.Left
ControlsLabel.Font = Enum.Font.SourceSansBold
ControlsLabel.TextSize = 9
ControlsLabel.Parent = FarmTab

local FarmBtn = Instance.new("TextButton")
FarmBtn.Size = UDim2.new(1, -20, 0, 34)
FarmBtn.Position = UDim2.new(0, 10, 0, 73)
FarmBtn.BackgroundColor3 = Color3.fromRGB(30, 130, 30)
FarmBtn.BorderSizePixel = 0
FarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmBtn.Text = "▶ START FARMING"
FarmBtn.Font = Enum.Font.SourceSansBold
FarmBtn.TextSize = 13
FarmBtn.Parent = FarmTab

local AutoClickBtn = Instance.new("TextButton")
AutoClickBtn.Size = UDim2.new(1, -20, 0, 28)
AutoClickBtn.Position = UDim2.new(0, 10, 0, 112)
AutoClickBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 130)
AutoClickBtn.BorderSizePixel = 0
AutoClickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoClickBtn.Text = "🖱 Auto Click: OFF"
AutoClickBtn.Font = Enum.Font.SourceSans
AutoClickBtn.TextSize = 12
AutoClickBtn.Parent = FarmTab

local AFKBtn = Instance.new("TextButton")
AFKBtn.Size = UDim2.new(1, -20, 0, 28)
AFKBtn.Position = UDim2.new(0, 10, 0, 145)
AFKBtn.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
AFKBtn.BorderSizePixel = 0
AFKBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AFKBtn.Text = "🔄 Anti AFK: ON"
AFKBtn.Font = Enum.Font.SourceSans
AFKBtn.TextSize = 12
AFKBtn.Parent = FarmTab

local InfoRow = Instance.new("Frame")
InfoRow.Size = UDim2.new(1, -20, 0, 18)
InfoRow.Position = UDim2.new(0, 10, 0, 180)
InfoRow.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
InfoRow.BorderSizePixel = 0
InfoRow.Parent = FarmTab

local SpeedInfo = Instance.new("TextLabel")
SpeedInfo.Size = UDim2.new(0.33, -5, 1, 0)
SpeedInfo.Position = UDim2.new(0, 5, 0, 0)
SpeedInfo.BackgroundTransparency = 1
SpeedInfo.TextColor3 = Color3.fromRGB(255, 200, 0)
SpeedInfo.Text = "S:"..WalkSpeed
SpeedInfo.Font = Enum.Font.SourceSans
SpeedInfo.TextSize = 10
SpeedInfo.Parent = InfoRow

local JumpInfo = Instance.new("TextLabel")
JumpInfo.Size = UDim2.new(0.33, -5, 1, 0)
JumpInfo.Position = UDim2.new(0.33, 5, 0, 0)
JumpInfo.BackgroundTransparency = 1
JumpInfo.TextColor3 = Color3.fromRGB(255, 200, 0)
JumpInfo.Text = "J:"..JumpPower
JumpInfo.TextXAlignment = Enum.TextXAlignment.Center
JumpInfo.Font = Enum.Font.SourceSans
JumpInfo.TextSize = 10
JumpInfo.Parent = InfoRow

local RangeInfo = Instance.new("TextLabel")
RangeInfo.Size = UDim2.new(0.33, -5, 1, 0)
RangeInfo.Position = UDim2.new(0.66, 0, 0, 0)
RangeInfo.BackgroundTransparency = 1
RangeInfo.TextColor3 = Color3.fromRGB(255, 200, 0)
RangeInfo.Text = "R:"..Range
RangeInfo.TextXAlignment = Enum.TextXAlignment.Right
RangeInfo.Font = Enum.Font.SourceSans
RangeInfo.TextSize = 10
RangeInfo.Parent = InfoRow

local TermBtn = Instance.new("TextButton")
TermBtn.Size = UDim2.new(1, -20, 0, 24)
TermBtn.Position = UDim2.new(0, 10, 0, 207)
TermBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
TermBtn.BorderSizePixel = 0
TermBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
TermBtn.Text = "⏏ TERMINATE"
TermBtn.Font = Enum.Font.SourceSansBold
TermBtn.TextSize = 11
TermBtn.Parent = FarmTab

-- =============================================
-- TAB 2: CHARACTER INFO CONTENT
-- =============================================
local CharTab = Instance.new("Frame")
CharTab.Size = UDim2.new(1, 0, 1, -93)
CharTab.Position = UDim2.new(0, 0, 0, 93)
CharTab.BackgroundTransparency = 1
CharTab.Visible = false
CharTab.Parent = MainFrame

local CharHeader = Instance.new("Frame")
CharHeader.Size = UDim2.new(1, -20, 0, 30)
CharHeader.Position = UDim2.new(0, 10, 0, 8)
CharHeader.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
CharHeader.BorderSizePixel = 0
CharHeader.Parent = CharTab

local CharHeaderLabel = Instance.new("TextLabel")
CharHeaderLabel.Size = UDim2.new(1, 0, 1, 0)
CharHeaderLabel.BackgroundTransparency = 1
CharHeaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CharHeaderLabel.Text = "👤 CHARACTER INFO"
CharHeaderLabel.Font = Enum.Font.SourceSansBold
CharHeaderLabel.TextSize = 12
CharHeaderLabel.Parent = CharHeader

-- Character Data Display
local CharDataLabel = Instance.new("TextLabel")
CharDataLabel.Size = UDim2.new(1, -20, 1, -60)
CharDataLabel.Position = UDim2.new(0, 10, 0, 48)
CharDataLabel.BackgroundTransparency = 1
CharDataLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CharDataLabel.Text = "No data found.\nUse scanner to find info."
CharDataLabel.TextXAlignment = Enum.TextXAlignment.Left
CharDataLabel.TextYAlignment = Enum.TextYAlignment.Top
CharDataLabel.Font = Enum.Font.SourceSans
CharDataLabel.TextSize = 11
CharDataLabel.TextWrapped = true
CharDataLabel.Parent = CharTab

-- Scanner Button
local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(1, -20, 0, 28)
ScanBtn.Position = UDim2.new(0, 10, 0, 207)
ScanBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 20)
ScanBtn.BorderSizePixel = 0
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Text = "🔍 SCAN DATA"
ScanBtn.Font = Enum.Font.SourceSansBold
ScanBtn.TextSize = 12
ScanBtn.Parent = CharTab

-- =============================================
-- TAB 3: SETTINGS CONTENT
-- =============================================
local SettingsTab = Instance.new("Frame")
SettingsTab.Size = UDim2.new(1, 0, 1, -93)
SettingsTab.Position = UDim2.new(0, 0, 0, 93)
SettingsTab.BackgroundTransparency = 1
SettingsTab.Visible = false
SettingsTab.Parent = MainFrame

local SettingsHeader = Instance.new("Frame")
SettingsHeader.Size = UDim2.new(1, -20, 0, 30)
SettingsHeader.Position = UDim2.new(0, 10, 0, 8)
SettingsHeader.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SettingsHeader.BorderSizePixel = 0
SettingsHeader.Parent = SettingsTab

local SettingsHeaderLabel = Instance.new("TextLabel")
SettingsHeaderLabel.Size = UDim2.new(1, 0, 1, 0)
SettingsHeaderLabel.BackgroundTransparency = 1
SettingsHeaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsHeaderLabel.Text = "⚙️ SETTINGS"
SettingsHeaderLabel.Font = Enum.Font.SourceSansBold
SettingsHeaderLabel.TextSize = 12
SettingsHeaderLabel.Parent = SettingsHeader

-- Range Control
local RangeLabel = Instance.new("TextLabel")
RangeLabel.Size = UDim2.new(1, -20, 0, 16)
RangeLabel.Position = UDim2.new(0, 10, 0, 50)
RangeLabel.BackgroundTransparency = 1
RangeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
RangeLabel.Text = "Farm Range: " .. Range
RangeLabel.TextXAlignment = Enum.TextXAlignment.Left
RangeLabel.Font = Enum.Font.SourceSans
RangeLabel.TextSize = 10
RangeLabel.Parent = SettingsTab

local RangeDecrease = Instance.new("TextButton")
RangeDecrease.Size = UDim2.new(0, 22, 0, 22)
RangeDecrease.Position = UDim2.new(0, 10, 0, 68)
RangeDecrease.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
RangeDecrease.BorderSizePixel = 0
RangeDecrease.TextColor3 = Color3.fromRGB(255, 255, 255)
RangeDecrease.Text = "-"
RangeDecrease.Font = Enum.Font.SourceSansBold
RangeDecrease.TextSize = 14
RangeDecrease.Parent = SettingsTab

local RangeIncrease = Instance.new("TextButton")
RangeIncrease.Size = UDim2.new(0, 22, 0, 22)
RangeIncrease.Position = UDim2.new(0, 188, 0, 68)
RangeIncrease.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
RangeIncrease.BorderSizePixel = 0
RangeIncrease.TextColor3 = Color3.fromRGB(255, 255, 255)
RangeIncrease.Text = "+"
RangeIncrease.Font = Enum.Font.SourceSansBold
RangeIncrease.TextSize = 14
RangeIncrease.Parent = SettingsTab

-- FOV Control
local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(1, -20, 0, 16)
FOVLabel.Position = UDim2.new(0, 10, 0, 100)
FOVLabel.BackgroundTransparency = 1
FOVLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FOVLabel.Text = "FOV: " .. FOV
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left
FOVLabel.Font = Enum.Font.SourceSans
FOVLabel.TextSize = 10
FOVLabel.Parent = SettingsTab

local FOVDecrease = Instance.new("TextButton")
FOVDecrease.Size = UDim2.new(0, 22, 0, 22)
FOVDecrease.Position = UDim2.new(0, 10, 0, 118)
FOVDecrease.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FOVDecrease.BorderSizePixel = 0
FOVDecrease.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVDecrease.Text = "-"
FOVDecrease.Font = Enum.Font.SourceSansBold
FOVDecrease.TextSize = 14
FOVDecrease.Parent = SettingsTab

local FOVIncrease = Instance.new("TextButton")
FOVIncrease.Size = UDim2.new(0, 22, 0, 22)
FOVIncrease.Position = UDim2.new(0, 188, 0, 118)
FOVIncrease.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FOVIncrease.BorderSizePixel = 0
FOVIncrease.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVIncrease.Text = "+"
FOVIncrease.Font = Enum.Font.SourceSansBold
FOVIncrease.TextSize = 14
FOVIncrease.Parent = SettingsTab

-- Jump Power Control
local JumpLabel = Instance.new("TextLabel")
JumpLabel.Size = UDim2.new(1, -20, 0, 16)
JumpLabel.Position = UDim2.new(0, 10, 0, 150)
JumpLabel.BackgroundTransparency = 1
JumpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
JumpLabel.Text = "Jump Power: " .. JumpPower
JumpLabel.TextXAlignment = Enum.TextXAlignment.Left
JumpLabel.Font = Enum.Font.SourceSans
JumpLabel.TextSize = 10
JumpLabel.Parent = SettingsTab

local JumpDecrease = Instance.new("TextButton")
JumpDecrease.Size = UDim2.new(0, 22, 0, 22)
JumpDecrease.Position = UDim2.new(0, 10, 0, 168)
JumpDecrease.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
JumpDecrease.BorderSizePixel = 0
JumpDecrease.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpDecrease.Text = "-"
JumpDecrease.Font = Enum.Font.SourceSansBold
JumpDecrease.TextSize = 14
JumpDecrease.Parent = SettingsTab

local JumpIncrease = Instance.new("TextButton")
JumpIncrease.Size = UDim2.new(0, 22, 0, 22)
JumpIncrease.Position = UDim2.new(0, 188, 0, 168)
JumpIncrease.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
JumpIncrease.BorderSizePixel = 0
JumpIncrease.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpIncrease.Text = "+"
JumpIncrease.Font = Enum.Font.SourceSansBold
JumpIncrease.TextSize = 14
JumpIncrease.Parent = SettingsTab

local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, -20, 0, 14)
Footer.Position = UDim2.new(0, 10, 0, 207)
Footer.BackgroundTransparency = 1
Footer.TextColor3 = Color3.fromRGB(80, 80, 80)
Footer.Text = "by kibsss"
Footer.TextXAlignment = Enum.TextXAlignment.Center
Footer.Font = Enum.Font.SourceSans
Footer.TextSize = 9
Footer.Parent = SettingsTab

-- =============================================
-- TAB SWITCHING FUNCTION
-- =============================================
local function switchTab(tab)
    FarmTab.Visible = (tab == 1)
    CharTab.Visible = (tab == 2)
    SettingsTab.Visible = (tab == 3)
    
    Tab1.BackgroundColor3 = (tab == 1) and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(25, 25, 25)
    Tab2.BackgroundColor3 = (tab == 2) and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(25, 25, 25)
    Tab3.BackgroundColor3 = (tab == 3) and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(25, 25, 25)
    
    Tab1.TextColor3 = (tab == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    Tab2.TextColor3 = (tab == 2) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    Tab3.TextColor3 = (tab == 3) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
end

Tab1.MouseButton1Click:Connect(function() switchTab(1) end)
Tab2.MouseButton1Click:Connect(function() switchTab(2) end)
Tab3.MouseButton1Click:Connect(function() switchTab(3) end)

-- =============================================
-- SETTINGS CONTROLS
-- =============================================
RangeDecrease.MouseButton1Click:Connect(function()
    Range = math.max(5, Range - 5)
    RangeLabel.Text = "Farm Range: " .. Range
    RangeInfo.Text = "R:" .. Range
end)

RangeIncrease.MouseButton1Click:Connect(function()
    Range = math.min(100, Range + 5)
    RangeLabel.Text = "Farm Range: " .. Range
    RangeInfo.Text = "R:" .. Range
end)

FOVDecrease.MouseButton1Click:Connect(function()
    FOV = math.max(30, FOV - 5)
    FOVLabel.Text = "FOV: " .. FOV
    applyStats()
end)

FOVIncrease.MouseButton1Click:Connect(function()
    FOV = math.min(120, FOV + 5)
    FOVLabel.Text = "FOV: " .. FOV
    applyStats()
end)

JumpDecrease.MouseButton1Click:Connect(function()
    JumpPower = math.max(25, JumpPower - 5)
    JumpLabel.Text = "Jump Power: " .. JumpPower
    JumpInfo.Text = "J:" .. JumpPower
    applyStats()
end)

JumpIncrease.MouseButton1Click:Connect(function()
    JumpPower = math.min(200, JumpPower + 5)
    JumpLabel.Text = "Jump Power: " .. JumpPower
    JumpInfo.Text = "J:" .. JumpPower
    applyStats()
end)

-- =============================================
-- CHARACTER DATA SCANNER
-- =============================================
local function scanCharacterData()
    CharDataLabel.Text = "🔍 Scanning...\n\n"
    local found = {}
    
    pcall(function()
        -- Check PlayerGui for leaderstats
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, child in pairs(playerGui:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    local text = child.Text or ""
                    if string.find(text, "Bounty") or string.find(text, "Beli") or string.find(text, "Melee") 
                    or string.find(text, "Sword") or string.find(text, "Race") or string.find(text, "Level")
                    or string.find(text, "Fruit") or string.find(text, "Devil") then
                        table.insert(found, "GUI: " .. text)
                    end
                end
            end
        end
        
        -- Check Leaderstats
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("stats") or LocalPlayer:FindFirstChild("Data")
        if leaderstats then
            table.insert(found, "\n📊 Leaderstats found:")
            for _, stat in pairs(leaderstats:GetChildren()) do
                table.insert(found, "  • " .. stat.Name .. ": " .. tostring(stat.Value))
            end
        end
        
        -- Check ReplicatedStorage for data modules
        local rs = game:GetService("ReplicatedStorage")
        for _, child in pairs(rs:GetChildren()) do
            if string.find(string.lower(child.Name), "data") or string.find(string.lower(child.Name), "player") then
                table.insert(found, "\n📦 Found: " .. child.Name .. " (" .. child.ClassName .. ")")
            end
        end
    end)
    
    if #found > 0 then
        CharDataLabel.Text = table.concat(found, "\n")
    else
        CharDataLabel.Text = "❌ No data found.\n\nTry opening the game menu\nor leaderboard, then scan again."
    end
end

ScanBtn.MouseButton1Click:Connect(scanCharacterData)

-- =============================================
-- ANTI AFK - VirtualUser
-- =============================================
game:GetService("Players").LocalPlayer.Idled:connect(function()
    if AntiAFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        AFKStatusLabel.Text = "AFK Prevented!"
        task.wait(2)
        AFKStatusLabel.Text = "Anti-AFK Active"
    end
end)

-- =============================================
-- BUTTON FUNCTIONS
-- =============================================

-- Minimize
local function toggleMinimize()
    Minimized = not Minimized
    MainFrame.Visible = not Minimized
    if Minimized then
        MinBtn.BackgroundColor3 = Color3.fromRGB(30, 130, 30)
    else
        MinBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    end
end
MinBtn.MouseButton1Click:Connect(toggleMinimize)
DashBtn.MouseButton1Click:Connect(toggleMinimize)

-- Farm Toggle
FarmBtn.MouseButton1Click:Connect(function()
    Farming = not Farming
    FarmBtn.Text = Farming and "⏹ STOP FARMING" or "▶ START FARMING"
    FarmBtn.BackgroundColor3 = Farming and Color3.fromRGB(150, 25, 25) or Color3.fromRGB(30, 130, 30)
    StatusLabel.Text = Farming and "● Farming" or "● Ready"
    StatusLabel.TextColor3 = Farming and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(180, 180, 180)
end)

-- Auto Click Toggle
AutoClickBtn.MouseButton1Click:Connect(function()
    AutoClick = not AutoClick
    AutoClickBtn.Text = "🖱 Auto Click: " .. (AutoClick and "ON" or "OFF")
    AutoClickBtn.BackgroundColor3 = AutoClick and Color3.fromRGB(30, 100, 200) or Color3.fromRGB(30, 30, 130)
end)

-- Anti AFK Toggle
AFKBtn.MouseButton1Click:Connect(function()
    AntiAFKEnabled = not AntiAFKEnabled
    AFKBtn.Text = "🔄 Anti AFK: " .. (AntiAFKEnabled and "ON" or "OFF")
    AFKBtn.BackgroundColor3 = AntiAFKEnabled and Color3.fromRGB(30, 100, 30) or Color3.fromRGB(60, 60, 60)
    AFKStatusLabel.Text = AntiAFKEnabled and "Anti-AFK Active" or "Anti-AFK Disabled"
end)

-- Terminate
TermBtn.MouseButton1Click:Connect(function()
    ScriptActive = false
    Farming = false
    AutoClick = false
    getgenv().AntiAfkExecuted = false
    getgenv().zamanbaslaticisi = false
    ScreenGui:Destroy()
end)

-- =============================================
-- UPDATE LOOPS
-- =============================================

-- FPS Update
task.spawn(function()
    while ScriptActive do
        fpsCount = fpsCount + 1
        if tick() - lastFPSUpdate >= 0.5 then
            fps = math.floor(fpsCount / (tick() - lastFPSUpdate))
            fpsCount = 0
            lastFPSUpdate = tick()
            FPSLabel.Text = "FPS: " .. fps
            FPSLabel.TextColor3 = fps >= 50 and Color3.fromRGB(0, 255, 100) or (fps >= 25 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 80, 80))
        end
        task.wait()
    end
end)

-- Ping Update
task.spawn(function()
    while ScriptActive do
        pcall(function()
            local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            PingLabel.Text = "Ping: " .. ping .. "ms"
            PingLabel.TextColor3 = ping <= 80 and Color3.fromRGB(100, 200, 255) or (ping <= 150 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 100, 100))
        end)
        task.wait(1)
    end
end)

-- Timer Update
task.spawn(function()
    while ScriptActive do
        if getgenv().zamanbaslaticisi then
            saniye = saniye + 1
            if saniye >= 60 then saniye = 0; dakika = dakika + 1 end
            if dakika >= 60 then dakika = 0; saat = saat + 1 end
            TimerLabel.Text = saat..":"..dakika..":"..saniye
        end
        task.wait(1)
    end
end)

-- NPC Counter Update
task.spawn(function()
    while ScriptActive do
        local npcs = getNPCsInRange()
        NPCCounterLabel.Text = "NPCs in range: " .. #npcs
        task.wait(0.5)
    end
end)

-- =============================================
-- CORE FUNCTIONS
-- =============================================

-- Apply stats
local function applyStats()
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local h = char:FindFirstChild("Humanoid")
            if h then h.WalkSpeed = WalkSpeed; h.JumpPower = JumpPower end
        end
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = FOV end
    end)
end
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5) applyStats() end)
task.spawn(function() while ScriptActive do applyStats() task.wait(1) end end)

-- Get NPCs
local function getNPCsInRange()
    local char = LocalPlayer.Character
    if not char then return {} end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return {} end
    local nearby = {}
    local npcFolder = Workspace:FindFirstChild("NPCs")
    if npcFolder then
        for _, obj in pairs(npcFolder:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                local npcRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                if npcRoot then
                    local dist = (root.Position - npcRoot.Position).Magnitude
                    if dist <= Range then table.insert(nearby, {root = npcRoot, dist = dist}) end
                end
            end
        end
    end
    table.sort(nearby, function(a, b) return a.dist < b.dist end)
    return nearby
end

-- AOE Farm
task.spawn(function()
    while ScriptActive do
        if Farming then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local npcs = getNPCsInRange()
                if #npcs > 0 then
                    for _, npc in pairs(npcs) do
                        local myRoot = char:FindFirstChild("HumanoidRootPart")
                        if myRoot then
                            myRoot.CFrame = CFrame.lookAt(myRoot.Position, Vector3.new(npc.root.Position.X, myRoot.Position.Y, npc.root.Position.Z))
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                            task.wait(0.05)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        end
                    end
                end
            end)
        end
        task.wait(0.15)
    end
end)

-- Auto Click Loop
task.spawn(function()
    while ScriptActive do
        if AutoClick then
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
        end
        task.wait(ClickSpeed)
    end
end)

applyStats()
print("Ready! Sailor Piece by kibsss | Tabs: Farm | Character | Settings")
