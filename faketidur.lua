-- ================== DRIP CLIENT PREMIUM - FAKE SLEEP EDITION ==================

-- ================== LOAD SERVICES ==================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Rayfield Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ================== INITIALIZATION ==================
local Window = Rayfield:CreateWindow({
    Name = "Putzzdev",
    LoadingTitle = "Drip Client Premium",
    LoadingSubtitle = "Fake Sleep & Dead Edition",
    Theme = "Amethyst",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

-- ================== VARIABLES ==================
local _G = {
    AutoSleepDead = false,
    AutoRepairGen = false,
    AutoFarmEXP = false,
    MonsterESP = false,
    PlayerESP = false,
    GenESP = false,
    WalkSpeedEnabled = false,
    JumpPowerEnabled = false,
    NoClipEnabled = false,
}

local customSpeed = 50
local customJump = 50
local monsterDistanceTrigger = 25 -- Jarak monster untuk auto-sleep

-- Storage ESP
local monsterHighlights = {}
local playerHighlights = {}
local genDrawings = {}

-- ================== UTILITY FUNCTIONS ==================

-- Fungsi mencari Monster/Pembunuh di Map
local function getMonster()
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and (string.find(string.lower(obj.Name), "monster") or string.find(string.lower(obj.Name), "killer") or string.find(string.lower(obj.Name), "pembunuh")) then
            return obj
        end
    end
    return nil
end

-- Fungsi mencari Generator di Map
local function findGenerators()
    local gens = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if string.find(string.lower(obj.Name), "generator") or string.find(string.lower(obj.Name), "gen") then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                table.insert(gens, obj)
            end
        end
    end
    return gens
end

-- Fungsi Simulasi Pencet Tombol Tidur / Bangun
local function toggleSleepState(shouldSleep)
    pcall(function()
        -- Cari UI Tombol Tidur/Mati atau langsung tembak Remote Event-nya jika ada
        local localScript = LocalPlayer.PlayerGui:FindFirstChild("MainGui") or LocalPlayer.PlayerGui:FindFirstChild("GameGui")
        -- Jika game menggunakan ProximityPrompt di Kasur masing-masing
        if shouldSleep then
            -- Logika otomatis memicu aksi tidur (pencet tombol / trigger remote)
            game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("Sleep"):FireServer(true)
        else
            game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("Sleep"):FireServer(false)
        end
    end)
end

-- ================== AUTOMATION LOOPS ==================

-- 1. DETEKSI MONSTER + AUTO SLEEP/DEAD
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoSleepDead and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local monster = getMonster()
            
            if monster and monster:FindFirstChild("HumanoidRootPart") then
                local distance = (hrp.Position - monster.HumanoidRootPart.Position).Magnitude
                
                if distance <= monsterDistanceTrigger then
                    -- Monster dekat, langsung pura-pura tidur/mati!
                    toggleSleepState(true)
                else
                    -- Monster menjauh, otomatis bangun buat lanjut bantai!
                    toggleSleepState(false)
                end
            else
                -- Jika monster tidak terdeteksi dekat, pastikan bangun
                toggleSleepState(false)
            end
        end
    end
end)

-- 2. AUTO REPAIR GENERATOR
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoRepairGen and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local gens = findGenerators()
            for _, gen in pairs(gens) do
                if not _G.AutoRepairGen then break end
                
                -- Pastikan aman dari monster sebelum benerin generator
                local monster = getMonster()
                local safe = true
                if monster and monster:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    if (LocalPlayer.Character.HumanoidRootPart.Position - monster.HumanoidRootPart.Position).Magnitude < monsterDistanceTrigger then
                        safe = false
                    end
                end
                
                if safe then
                    pcall(function()
                        local prompt = gen:FindFirstChildOfClass("ProximityPrompt") or gen.Parent:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then
                            -- Teleport super singkat ke generator untuk memperbaiki
                            local originalCF = LocalPlayer.Character.HumanoidRootPart.CFrame
                            LocalPlayer.Character.HumanoidRootPart.CFrame = gen:GetModelCFrame() or gen.CFrame
                            task.wait(0.1)
                            fireproximityprompt(prompt)
                            task.wait(0.1)
                            LocalPlayer.Character.HumanoidRootPart.CFrame = originalCF
                        end
                    end)
                end
            end
        end
    end
end)

-- 3. AUTO FARM EXP / LEVEL UP
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoFarmEXP then
            pcall(function()
                -- Mengirim remote event reward game secara berkala untuk memicu EXP gratis
                local expEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("GiveEXP") or game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("ClaimReward")
                if expEvent then
                    expEvent:FireServer()
                end
            end)
        end
    end
end)

-- ================== ESP CONTROLLERS ==================

RunService.Heartbeat:Connect(function()
    -- Monster Hologram ESP
    if _G.MonsterESP then
        local monster = getMonster()
        if monster and not monsterHighlights[monster] then
            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(0, 255, 0) -- Hijau Full[cite: 3]
            hl.OutlineColor = Color3.fromRGB(0, 255, 0)[cite: 3]
            hl.FillTransparency = 0.4
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Adornee = monster
            hl.Parent = monster
            monsterHighlights[monster] = hl
        end
    else
        for m, hl in pairs(monsterHighlights) do
            if hl then hl:Destroy() end
            monsterHighlights[m] = nil
        end
    end

    -- Player Hologram ESP[cite: 3]
    if _G.PlayerESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and not playerHighlights[p] then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(0, 255, 0) -- Hijau Full[cite: 3]
                hl.OutlineColor = Color3.fromRGB(0, 255, 0)[cite: 3]
                hl.FillTransparency = 0.4
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Adornee = p.Character
                hl.Parent = p.Character
                playerHighlights[p] = hl
            end
        end
    else
        for p, hl in pairs(playerHighlights) do
            if hl then hl:Destroy() end
            playerHighlights[p] = nil
        end
    end
end)

-- Generator Text ESP
RunService.RenderStepped:Connect(function()
    if _G.GenESP and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = LocalPlayer.Character.HumanoidRootPart.Position
        local gens = findGenerators()
        
        for gen, text in pairs(genDrawings) do
            if not gen or not gen.Parent then
                text.Visible = false
                text:Remove()
                genDrawings[gen] = nil
            end
        end
        
        for _, gen in pairs(gens) do
            local pos = gen:IsA("Model") and gen:GetModelCFrame().Position or gen.Position
            local vector, onScreen = Camera:WorldToViewportPoint(pos)
            
            if onScreen then
                local distance = (myPos - pos).Magnitude
                if not genDrawings[gen] then
                    local text = Drawing.new("Text")
                    text.Size = 14
                    text.Color = Color3.fromRGB(255, 50, 50)
                    text.Center = true
                    text.Outline = true
                    genDrawings[gen] = text
                end
                
                local draw = genDrawings[gen]
                draw.Position = Vector2.new(vector.X, vector.Y)
                draw.Text = "⚙️ Generator [" .. math.floor(distance) .. "m]"
                draw.Visible = true
            else
                if genDrawings[gen] then genDrawings[gen].Visible = false end
            end
        end
    else
        for _, text in pairs(genDrawings) do text.Visible = false end
    end
end)

-- Character Mods Loop[cite: 3]
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if _G.WalkSpeedEnabled then hum.WalkSpeed = customSpeed end[cite: 3]
        if _G.JumpPowerEnabled then hum.UseJumpPower = true; hum.JumpPower = customJump end[cite: 3]
    end
    if _G.NoClipEnabled and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end[cite: 3]
        end
    end
end)

-- ================== UI TABS & ELEMENTS ==================

-- TAB UTAMA
local TabMain = Window:CreateTab("Main & Auto", "zap")

TabMain:CreateToggle({
    Name = "Auto Pretend Sleep/Dead 🛌",
    CurrentValue = false,
    Flag = "AutoSleepFlag",
    Callback = function(state)
        _G.AutoSleepDead = state
    end,
})

TabMain:CreateToggle({
    Name = "Auto Repair Generator ⚙️",
    CurrentValue = false,
    Flag = "AutoGenFlag",
    Callback = function(state)
        _G.AutoRepairGen = state
    end,
})

TabMain:CreateToggle({
    Name = "Auto Farm EXP Level 📈",
    CurrentValue = false,
    Flag = "AutoEXPFlag",
    Callback = function(state)
        _G.AutoFarmEXP = state
    end,
})

-- TAB VISUAL
local TabESP = Window:CreateTab("Visual ESP", "eye")

TabESP:CreateToggle({
    Name = "Monster Hologram ESP 🟢",
    CurrentValue = false,
    Flag = "MonsterESPFlag",
    Callback = function(state)
        _G.MonsterESP = state
    end,
})

TabESP:CreateToggle({
    Name = "Player Hologram ESP 🟢",
    CurrentValue = false,
    Flag = "PlayerESPFlag",
    Callback = function(state)
        _G.PlayerESP = state
    end,
})

TabESP:CreateToggle({
    Name = "Generator ESP ⚙️",
    CurrentValue = false,
    Flag = "GenESPFlag",
    Callback = function(state)
        _G.GenESP = state
    end,
})

-- TAB PLAYER
local TabPlayer = Window:CreateTab("Player Hack", "user")[cite: 3]

TabPlayer:CreateToggle({
    Name = "Enable Speed Hack",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(state)
        _G.WalkSpeedEnabled = state
        if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        end
    end,
})

TabPlayer:CreateSlider({
    Name = "Speed Value",
    Range = {16, 250},
    Increment = 1,
    CurrentValue = customSpeed,
    Flag = "SpeedSlider",
    Callback = function(val) customSpeed = val end,
})

TabPlayer:CreateDivider()[cite: 3]

TabPlayer:CreateToggle({
    Name = "Enable Jump Hack",
    CurrentValue = false,
    Flag = "JumpToggle",
    Callback = function(state)
        _G.JumpPowerEnabled = state
        if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = 50
        end
    end,
})

TabPlayer:CreateSlider({
    Name = "Jump Value",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = customJump,
    Flag = "JumpSlider",
    Callback = function(val) customJump = val end,
})

TabPlayer:CreateDivider()[cite: 3]

TabPlayer:CreateToggle({
    Name = "NoClip (Tembus Tembok)",
    CurrentValue = false,
    Flag = "NoClipFlag",
    Callback = function(state) _G.NoClipEnabled = state end,
})

-- Notification Load
Rayfield:Notify({
    Title = "Drip Client Ready",
    Content = "Script siap bantai game Pura-Pura Tidur!",
    Duration = 3,
    Image = 4483362458
})