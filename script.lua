--=== SPEED HUB CUSTOM - BY (NAMA LO) ===--
-- Versi: 1.1.0 (Dengan fitur balik ke base)
-- Support: Escape Tsunami For Brainrot

-- Load Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

-- Window Utama
local Window = Library:CreateWindow({
    Title = "Speed Hub Custom | Escape Tsunami",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- Tabs
local Tabs = {
    Farm = Window:CreateTab("Farm"),
    Base = Window:CreateTab("Base"),
    Player = Window:CreateTab("Player"),
    World = Window:CreateTab("World"),
    ESP = Window:CreateTab("ESP"),
    Teleport = Window:CreateTab("TP"),
    Settings = Window:CreateTab("Settings")
}

--=== VARIABEL ===--
local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Humanoid = Char.Humanoid

-- Base Position (default di spawn)
local Spawn = workspace:FindFirstChild("Spawn") or workspace:FindFirstChild("Base")
getgenv().BasePosition = Spawn and Spawn.CFrame or Root.CFrame

-- Options
local Options = {
    -- Farm
    AutoFarm = false,
    MinRarity = 1,
    FarmRadius = 200,
    ReturnToBase = true,  -- <== FITUR BARU
    CollectDelay = 0.5,
    
    -- Bring
    AutoBring = false,
    BringRadius = 100,
    
    -- Player
    WalkSpeed = 16,
    JumpPower = 50,
    FlyMode = false,
    NoClip = false,
    InfiniteJump = false,
    
    -- World
    RemoveWalls = false,
    AntiTsunami = false,
    
    -- ESP
    ESPEnabled = false
}

--=== FUNGSI UTILITY ===--

-- Tween movement
function TweenTo(Position, Speed)
    Speed = Speed or Options.WalkSpeed * 3
    local Distance = (Root.Position - Position).Magnitude
    local Time = Distance / Speed
    
    local Tween = game:GetService("TweenService"):Create(
        Root,
        TweenInfo.new(Time, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(Position)}
    )
    Tween:Play()
    return Tween
end

-- Get rarity
function GetRarity(Name)
    Name = Name:lower()
    if Name:find("divine") then return 10
    elseif Name:find("celestial") then return 9
    elseif Name:find("secret") then return 8
    elseif Name:find("cosmic") then return 7
    elseif Name:find("mythical") then return 6
    elseif Name:find("legendary") then return 5
    elseif Name:find("epic") then return 4
    elseif Name:find("rare") then return 3
    elseif Name:find("uncommon") then return 2
    else return 1 end
end

-- Fungsi collect item
function CollectItem(Item)
    if Item:IsA("Model") then
        for _, Part in pairs(Item:GetDescendants()) do
            if Part:IsA("BasePart") then
                firetouchinterest(Root, Part, 0)
                firetouchinterest(Root, Part, 1)
            end
        end
    else
        firetouchinterest(Root, Item, 0)
        firetouchinterest(Root, Item, 1)
    end
end

--=== [TAB FARM] ===--
local FarmSection = Tabs.Farm:AddLeftGroupbox("Auto Farm")

-- Toggle Auto Farm (DENGAN FITUR BALIK KE BASE)
FarmSection:AddToggle("AutoFarm", {
    Text = "Auto Farm Brainrot",
    Default = false,
    Tooltip = "Otomatis cari dan collect brainrot, lalu balik ke base"
}):OnChanged(function()
    Options.AutoFarm = Options.AutoFarmValue
    
    while Options.AutoFarm do
        task.wait(0.3)
        
        -- Cari item terbaik
        local BestItem = nil
        local BestScore = -math.huge
        
        for _, Obj in pairs(workspace:GetDescendants()) do
            local IsTarget = (Obj:IsA("Model") and Obj:FindFirstChild("Humanoid") and Obj.Name:find("Brainrot")) or
                            (Obj:IsA("Part") and (Obj.Name:find("LuckyBlock") or Obj.Name:find("Lucky Block")))
            
            if IsTarget then
                local Rarity = GetRarity(Obj.Name)
                if Rarity >= Options.MinRarity then
                    local Distance = (Root.Position - Obj.Position).Magnitude
                    local Score = (Rarity * 100) - Distance
                    
                    if Score > BestScore and Distance < Options.FarmRadius then
                        BestScore = Score
                        BestItem = Obj
                    end
                end
            end
        end
        
        -- Kalo nemu item
        if BestItem then
            -- 1. GERAK KE ITEM
            TweenTo(BestItem.Position)
            task.wait(0.2)
            
            -- 2. COLLECT ITEM
            CollectItem(BestItem)
            
            -- 3. DELAY BENTAR
            task.wait(Options.CollectDelay)
            
            -- 4. BALIK KE BASE (FITUR UTAMA)
            if Options.ReturnToBase then
                TweenTo(getgenv().BasePosition.Position)
                task.wait(0.5) -- Kasih waktu buat nyampe base
            end
        else
            -- Kalo ga ada item, stay di base
            if Options.ReturnToBase then
                TweenTo(getgenv().BasePosition.Position)
            end
            task.wait(1)
        end
    end
end)

-- Slider radius
FarmSection:AddSlider("FarmRadius", {
    Text = "Farm Radius",
    Default = 200,
    Min = 50,
    Max = 500,
    Round = 1,
    Suffix = "studs"
}):OnChanged(function(v) Options.FarmRadius = v end)

-- Dropdown rarity
FarmSection:AddDropdown("MinRarity", {
    Text = "Minimum Rarity",
    Default = 1,
    Values = {
        "1 - Common", "2 - Uncommon", "3 - Rare", "4 - Epic",
        "5 - Legendary", "6 - Mythical", "7 - Cosmic", "8 - Secret",
        "9 - Celestial", "10 - Divine"
    },
    Multi = false
}):OnChanged(function(v) Options.MinRarity = tonumber(v:sub(1,2)) end)

-- Slider delay
FarmSection:AddSlider("CollectDelay", {
    Text = "Collect Delay",
    Default = 0.5,
    Min = 0.1,
    Max = 2,
    Round = 2,
    Suffix = "detik"
}):OnChanged(function(v) Options.CollectDelay = v end)

--=== [TAB BASE] - FITUR BASE (BARU) ===--
local BaseSection = Tabs.Base:AddLeftGroupbox("Base Settings")

-- Toggle balik ke base (FITUR UTAMA)
BaseSection:AddToggle("ReturnToBase", {
    Text = "Return to Base After Collect",
    Default = true,
    Tooltip = "Setelah collect item, otomatis balik ke base"
}):OnChanged(function(v)
    Options.ReturnToBase = v
end)

-- Tombol set base position
BaseSection:AddButton({
    Text = "Set Current Position as Base",
    Func = function()
        getgenv().BasePosition = Root.CFrame
        Library:Notify("Base position saved!")
    end
})

-- Tombol teleport ke base
BaseSection:AddButton({
    Text = "Teleport to Base",
    Func = function()
        TweenTo(getgenv().BasePosition.Position)
    end
})

-- Tampilkan posisi base
BaseSection:AddLabel("Base Position: " .. string.format("%.1f, %.1f, %.1f", 
    getgenv().BasePosition.X, 
    getgenv().BasePosition.Y, 
    getgenv().BasePosition.Z
))

--=== [TAB FARM] - AUTO BRING ===--
local BringSection = Tabs.Farm:AddRightGroupbox("Auto Bring")

FarmSection:AddToggle("AutoBring", {
    Text = "Auto Bring Items",
    Default = false,
    Tooltip = "Mindahin item ke posisi player (alternatif)"
}):OnChanged(function()
    Options.AutoBring = Options.AutoBringValue
    
    while Options.AutoBring do
        task.wait(0.2)
        
        for _, Obj in pairs(workspace:GetDescendants()) do
            local IsTarget = (Obj:IsA("Model") and Obj:FindFirstChild("Humanoid") and Obj.Name:find("Brainrot")) or
                            (Obj:IsA("Part") and (Obj.Name:find("LuckyBlock") or Obj.Name:find("Lucky Block")))
            
            if IsTarget then
                local Distance = (Root.Position - Obj.Position).Magnitude
                if Distance < Options.BringRadius then
                    -- Simpan posisi lama
                    local OldPos = Root.CFrame
                    
                    -- Pindah ke item bentar
                    Root.CFrame = Obj.CFrame * CFrame.new(0, 2, 0)
                    task.wait(0.05)
                    
                    -- Collect
                    CollectItem(Obj)
                    
                    -- Balik ke posisi semula
                    Root.CFrame = OldPos
                end
            end
        end
    end
end)

BringSection:AddSlider("BringRadius", {
    Text = "Bring Radius",
    Default = 100,
    Min = 10,
    Max = 500,
    Round = 1,
    Suffix = "studs"
}):OnChanged(function(v) Options.BringRadius = v end)

--=== [TAB BASE] - AUTO COLLECT MONEY ===--
local MoneySection = Tabs.Base:AddRightGroupbox("Base Money")

MoneySection:AddToggle("AutoMoney", {
    Text = "Auto Collect Money in Base",
    Default = false,
    Tooltip = "Otomatis ngumpulin uang di sekitar base"
}):OnChanged(function()
    Options.AutoMoney = Options.AutoMoneyValue
    
    while Options.AutoMoney do
        task.wait(2)
        
        for _, Obj in pairs(workspace:GetDescendants()) do
            if Obj:IsA("BasePart") and (Obj.Name:find("Money") or Obj.Name:find("Coin") or 
               Obj.BrickColor == BrickColor.new("Bright yellow")) then
               
                local DistanceFromBase = (Obj.Position - getgenv().BasePosition.Position).Magnitude
                if DistanceFromBase < 50 then
                    TweenTo(Obj.Position)
                    task.wait(0.1)
                    firetouchinterest(Root, Obj, 0)
                    firetouchinterest(Root, Obj, 1)
                end
            end
        end
    end
end)

--=== [TAB PLAYER] ===--
local MoveSection = Tabs.Player:AddLeftGroupbox("Movement")

MoveSection:AddSlider("WalkSpeed", {
    Text = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 500,
    Round = 1,
    Suffix = "studs/s"
}):OnChanged(function(v)
    Options.WalkSpeed = v
    Humanoid.WalkSpeed = v
end)

MoveSection:AddSlider("JumpPower", {
    Text = "Jump Power",
    Default = 50,
    Min = 50,
    Max = 500,
    Round = 1
}):OnChanged(function(v)
    Options.JumpPower = v
    Humanoid.JumpPower = v
end)

MoveSection:AddToggle("FlyMode", {
    Text = "Fly Mode",
    Default = false
}):OnChanged(function()
    Options.FlyMode = Options.FlyModeValue
    
    if Options.FlyMode then
        local BV = Instance.new("BodyVelocity")
        BV.Parent = Root
        BV.MaxForce = Vector3.new(4000, 4000, 4000)
        BV.Velocity = Vector3.new(0, 0, 0)
        
        coroutine.wrap(function()
            while Options.FlyMode do
                task.wait()
                local MoveDir = Vector3.new(0, 0, 0)
                local Input = game:GetService("UserInputService")
                
                if Input:IsKeyDown(Enum.KeyCode.W) then
                    MoveDir = MoveDir + workspace.CurrentCamera.CFrame.LookVector
                end
                if Input:IsKeyDown(Enum.KeyCode.S) then
                    MoveDir = MoveDir - workspace.CurrentCamera.CFrame.LookVector
                end
                if Input:IsKeyDown(Enum.KeyCode.A) then
                    MoveDir = MoveDir - workspace.CurrentCamera.CFrame.RightVector
                end
                if Input:IsKeyDown(Enum.KeyCode.D) then
                    MoveDir = MoveDir + workspace.CurrentCamera.CFrame.RightVector
                end
                if Input:IsKeyDown(Enum.KeyCode.Space) then
                    MoveDir = MoveDir + Vector3.new(0, 1, 0)
                end
                if Input:IsKeyDown(Enum.KeyCode.LeftControl) then
                    MoveDir = MoveDir + Vector3.new(0, -1, 0)
                end
                
                BV.Velocity = MoveDir * 50
            end
            BV:Destroy()
        end)()
    end
end)

MoveSection:AddToggle("NoClip", {
    Text = "NoClip",
    Default = false
}):OnChanged(function()
    Options.NoClip = Options.NoClipValue
end)

MoveSection:AddToggle("InfiniteJump", {
    Text = "Infinite Jump",
    Default = false
}):OnChanged(function()
    Options.InfiniteJump = Options.InfiniteJumpValue
end)

-- Jump handler
game:GetService("UserInputService").JumpRequest:Connect(function()
    if Options.InfiniteJump then
        Humanoid:ChangeState("Jumping")
    end
end)

-- Noclip handler
game:GetService("RunService").Stepped:Connect(function()
    if Options.NoClip and Char then
        for _, Part in pairs(Char:GetDescendants()) do
            if Part:IsA("BasePart") then
                Part.CanCollide = false
            end
        end
    end
end)

--=== [TAB WORLD] ===--
local WorldSection = Tabs.World:AddLeftGroupbox("World Settings")

WorldSection:AddToggle("AntiTsunami", {
    Text = "Auto Avoid Tsunami",
    Default = false
}):OnChanged(function()
    Options.AntiTsunami = Options.AntiTsunamiValue
    
    while Options.AntiTsunami do
        task.wait(0.5)
        local Water = workspace:FindFirstChild("Water") or workspace:FindFirstChild("Tsunami") or workspace:FindFirstChild("Wave")
        
        if Water and Water:IsA("Part") then
            local Distance = (Root.Position - Water.Position).Magnitude
            if Distance < 50 then
                -- Cari tempat tinggi
                local SafeSpot = nil
                local HighestY = 0
                
                for _, Obj in pairs(workspace:GetDescendants()) do
                    if Obj:IsA("Part") and Obj.Position.Y > HighestY then
                        HighestY = Obj.Position.Y
                        SafeSpot = Obj
                    end
                end
                
                if SafeSpot then
                    TweenTo(SafeSpot.Position + Vector3.new(0, 5, 0))
                else
                    TweenTo(Root.Position + Vector3.new(0, 200, 0))
                end
            end
        end
    end
end)

WorldSection:AddToggle("RemoveWalls", {
    Text = "Remove Walls/Barriers",
    Default = false
}):OnChanged(function()
    Options.RemoveWalls = Options.RemoveWallsValue
    
    for _, Obj in pairs(workspace:GetDescendants()) do
        if Obj:IsA("Part") and (Obj.Name:find("Wall") or Obj.Name:find("Barrier") or Obj.Name:find("VIP") or Obj.Name:find("Obstacle")) then
            Obj.CanCollide = not Options.RemoveWalls
            Obj.Transparency = Options.RemoveWalls and 0.8 or 0
        end
    end
end)

--=== [TAB ESP] ===--
local ESPSection = Tabs.ESP:AddLeftGroupbox("ESP Settings")

ESPSection:AddToggle("ESPEnabled", {
    Text = "Enable ESP",
    Default = false
}):OnChanged(function()
    Options.ESPEnabled = Options.ESPEnabledValue
    
    if Options.ESPEnabled then
        coroutine.wrap(function()
            while Options.ESPEnabled do
                for _, Obj in pairs(workspace:GetDescendants()) do
                    if Obj:IsA("Model") and Obj:FindFirstChild("Humanoid") and Obj.Name:find("Brainrot") then
                        if not Obj:FindFirstChild("Highlight") then
                            local Highlight = Instance.new("Highlight")
                            Highlight.Parent = Obj
                            
                            -- Warna berdasarkan rarity
                            local Rarity = GetRarity(Obj.Name)
                            if Rarity >= 8 then Highlight.FillColor = Color3.new(1, 1, 0) -- Secret/Celestial (Kuning)
                            elseif Rarity >= 6 then Highlight.FillColor = Color3.new(1, 0, 0) -- Mythical+ (Merah)
                            elseif Rarity >= 4 then Highlight.FillColor = Color3.new(0, 0, 1) -- Epic+ (Biru)
                            else Highlight.FillColor = Color3.new(0, 1, 0) end -- Common-Green
                            
                            Highlight.FillTransparency = 0.5
                        end
                    elseif Obj:IsA("Part") and (Obj.Name:find("LuckyBlock") or Obj.Name:find("Lucky Block")) then
                        if not Obj:FindFirstChild("Highlight") then
                            local Highlight = Instance.new("Highlight")
                            Highlight.Parent = Obj
                            Highlight.FillColor = Color3.new(1, 1, 0) -- Kuning untuk lucky block
                            Highlight.FillTransparency = 0.5
                        end
                    end
                end
                task.wait(2)
            end
            
            -- Cleanup
            for _, Obj in pairs(workspace:GetDescendants()) do
                if Obj:IsA("Highlight") then
                    Obj:Destroy()
                end
            end
        end)()
    end
end)

--=== [TAB TELEPORT] ===--
local TPSection = Tabs.Teleport:AddLeftGroupbox("Quick Teleport")

TPSection:AddButton({
    Text = "Teleport to Base",
    Func = function()
        TweenTo(getgenv().BasePosition.Position)
    end
})

TPSection:AddButton({
    Text = "Teleport to Safe Zone",
    Func = function()
        local Highest = 0
        local Safe = nil
        
        for _, Obj in pairs(workspace:GetDescendants()) do
            if Obj:IsA("Part") and Obj.Position.Y > Highest then
                Highest = Obj.Position.Y
                Safe = Obj
            end
        end
        
        if Safe then
            TweenTo(Safe.Position + Vector3.new(0, 5, 0))
        end
    end
})

TPSection:AddButton({
    Text = "Teleport to Spawn",
    Func = function()
        local Spawn = workspace:FindFirstChild("Spawn") or workspace:FindFirstChild("Base")
        if Spawn then
            TweenTo(Spawn.Position + Vector3.new(0, 5, 0))
        end
    end
})

--=== [TAB SETTINGS] ===--
local SettingsSection = Tabs.Settings:AddLeftGroupbox("Settings")

-- Theme manager
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SettingsSection:AddButton({
    Text = "Load Theme",
    Func = function()
        ThemeManager:LoadSettings()
    end
})

SettingsSection:AddButton({
    Text = "Save Theme",
    Func = function()
        ThemeManager:SaveSettings()
    end
})

-- Keybind
Library:SetKeybindTable({
    Toggle = {
        Text = "Toggle Menu",
        Key = "RightShift",
        Callback = function()
            Library:Toggle()
        end
    }
})

-- Save manager
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
ThemeManager:SetIgnoreIndexes({})

--=== FINISH ===--
Library:Notify("Speed Hub Custom loaded! Press RightShift to toggle")