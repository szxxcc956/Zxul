--=== SPEED HUB CUSTOM - CHLOE X EDITION (BUAT HP) ===--
-- Versi: 1.0 (Optimized for Mobile)
-- Support: Escape Tsunami For Brainrot

-- Load Library Chloe X
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/TesterX14/XXXX/refs/heads/main/Library"))()

-- Tunggu bentar biar library load
task.wait(1)

-- Setup Config
CURRENT_VERSION = "1.0"
LoadConfigFromFile()

-- Window Utama
local Window = Library:CreateWindow("Speed Hub | Escape Tsunami")

--=== VARIABEL ===--
local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Humanoid = Char.Humanoid

-- Base Position
local Spawn = workspace:FindFirstChild("Spawn") or workspace:FindFirstChild("Base")
getgenv().BasePosition = Spawn and Spawn.CFrame or Root.CFrame

-- Options
local Options = {
    AutoFarm = false,
    MinRarity = 1,
    FarmRadius = 200,
    ReturnToBase = true,
    CollectDelay = 0.5,
    AutoBring = false,
    BringRadius = 100,
    WalkSpeed = 16,
    JumpPower = 50,
    FlyMode = false,
    NoClip = false,
    InfiniteJump = false,
    RemoveWalls = false,
    AntiTsunami = false,
    ESPEnabled = false
}

--=== FUNGSI UTILITY ===--
function TweenTo(Position, Speed)
    Speed = Speed or Options.WalkSpeed * 3
    local Tween = game:GetService("TweenService"):Create(
        Root,
        TweenInfo.new((Root.Position - Position).Magnitude / Speed),
        {CFrame = CFrame.new(Position)}
    )
    Tween:Play()
    return Tween
end

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

--=== TAB FARM ===--
local FarmTab = Window:CreateTab("Farm", Icons.loop)

-- Toggle Auto Farm
FarmTab:AddToggle("AutoFarm", {
    Title = "Auto Farm Brainrot",
    Description = "Cari & collect brainrot otomatis",
    Default = false
}, function(v)
    Options.AutoFarm = v
    
    while Options.AutoFarm do
        task.wait(0.3)
        
        local BestItem, BestScore = nil, -1e9
        for _, Obj in pairs(workspace:GetDescendants()) do
            local IsTarget = (Obj:IsA("Model") and Obj:FindFirstChild("Humanoid") and Obj.Name:find("Brainrot")) or
                            (Obj:IsA("Part") and (Obj.Name:find("LuckyBlock") or Obj.Name:find("Lucky Block")))
            
            if IsTarget then
                local Rarity = GetRarity(Obj.Name)
                if Rarity >= Options.MinRarity then
                    local Score = (Rarity * 100) - (Root.Position - Obj.Position).Magnitude
                    if Score > BestScore and (Root.Position - Obj.Position).Magnitude < Options.FarmRadius then
                        BestScore, BestItem = Score, Obj
                    end
                end
            end
        end
        
        if BestItem then
            TweenTo(BestItem.Position)
            task.wait(0.2)
            CollectItem(BestItem)
            task.wait(Options.CollectDelay)
            
            if Options.ReturnToBase then
                TweenTo(getgenv().BasePosition.Position)
                task.wait(0.5)
            end
        else
            if Options.ReturnToBase then
                TweenTo(getgenv().BasePosition.Position)
            end
            task.wait(1)
        end
    end
end)

-- Slider Farm Radius
FarmTab:AddSlider("FarmRadius", {
    Title = "Farm Radius",
    Description = "Jarak maksimal cari item",
    Min = 50,
    Max = 500,
    Default = 200,
    Increase = 10,
    Suffix = "studs"
}, function(v)
    Options.FarmRadius = v
end)

-- Dropdown Rarity
FarmTab:AddDropdown("MinRarity", {
    Title = "Minimum Rarity",
    Description = "Rarity minimal yang diambil",
    Values = {"1 Common","2 Uncommon","3 Rare","4 Epic","5 Legendary",
              "6 Mythical","7 Cosmic","8 Secret","9 Celestial","10 Divine"},
    Default = 1
}, function(v)
    Options.MinRarity = tonumber(v:sub(1,2))
end)

-- Delay Slider
FarmTab:AddSlider("CollectDelay", {
    Title = "Collect Delay",
    Description = "Jeda setelah collect",
    Min = 0.1,
    Max = 2,
    Default = 0.5,
    Increase = 0.1,
    Suffix = "dtk"
}, function(v)
    Options.CollectDelay = v
end)

--=== TAB BASE ===--
local BaseTab = Window:CreateTab("Base", Icons.bag)

BaseTab:AddToggle("ReturnToBase", {
    Title = "Return to Base",
    Description = "Balik ke base setelah collect",
    Default = true
}, function(v)
    Options.ReturnToBase = v
end)

BaseTab:AddButton("Set Base", function()
    getgenv().BasePosition = Root.CFrame
    Library:MakeNotify({
        Title = "Base Set",
        Description = "Posisi base tersimpan",
        Color = Color3.fromRGB(0, 255, 0),
        Time = 2
    })
end)

BaseTab:AddButton("Teleport to Base", function()
    TweenTo(getgenv().BasePosition.Position)
end)

-- Auto Money
BaseTab:AddToggle("AutoMoney", {
    Title = "Auto Collect Money",
    Description = "Kumpulin uang di sekitar base",
    Default = false
}, function(v)
    Options.AutoMoney = v
    
    while Options.AutoMoney do
        task.wait(2)
        for _, Obj in pairs(workspace:GetDescendants()) do
            if Obj:IsA("BasePart") and (Obj.Name:find("Money") or Obj.Name:find("Coin") or 
               Obj.BrickColor == BrickColor.new("Bright yellow")) then
               
                if (Obj.Position - getgenv().BasePosition.Position).Magnitude < 50 then
                    TweenTo(Obj.Position)
                    task.wait(0.1)
                    firetouchinterest(Root, Obj, 0)
                    firetouchinterest(Root, Obj, 1)
                end
            end
        end
    end
end)

--=== TAB AUTO BRING ===--
local BringTab = Window:CreateTab("Bring", Icons.gps)

BringTab:AddToggle("AutoBring", {
    Title = "Auto Bring Items",
    Description = "Mindahin item ke player",
    Default = false
}, function(v)
    Options.AutoBring = v
    
    while Options.AutoBring do
        task.wait(0.2)
        for _, Obj in pairs(workspace:GetDescendants()) do
            local IsTarget = (Obj:IsA("Model") and Obj:FindFirstChild("Humanoid") and Obj.Name:find("Brainrot")) or
                            (Obj:IsA("Part") and (Obj.Name:find("LuckyBlock") or Obj.Name:find("Lucky Block")))
            
            if IsTarget and (Root.Position - Obj.Position).Magnitude < Options.BringRadius then
                local OldPos = Root.CFrame
                Root.CFrame = Obj.CFrame * CFrame.new(0, 2, 0)
                task.wait(0.05)
                CollectItem(Obj)
                Root.CFrame = OldPos
            end
        end
    end
end)

BringTab:AddSlider("BringRadius", {
    Title = "Bring Radius",
    Min = 10,
    Max = 500,
    Default = 100,
    Increase = 10,
    Suffix = "studs"
}, function(v)
    Options.BringRadius = v
end)

--=== TAB MOVEMENT ===--
local MoveTab = Window:CreateTab("Move", Icons.player)

MoveTab:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Min = 16,
    Max = 500,
    Default = 16,
    Increase = 5,
    Suffix = "studs/s"
}, function(v)
    Options.WalkSpeed = v
    Humanoid.WalkSpeed = v
end)

MoveTab:AddSlider("JumpPower", {
    Title = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Increase = 10
}, function(v)
    Options.JumpPower = v
    Humanoid.JumpPower = v
end)

MoveTab:AddToggle("FlyMode", {
    Title = "Fly Mode",
    Default = false
}, function(v)
    Options.FlyMode = v
    
    if v then
        local BV = Instance.new("BodyVelocity")
        BV.Parent = Root
        BV.MaxForce = Vector3.new(4000, 4000, 4000)
        
        spawn(function()
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
        end)
    end
end)

MoveTab:AddToggle("NoClip", {
    Title = "NoClip",
    Default = false
}, function(v)
    Options.NoClip = v
end)

MoveTab:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Default = false
}, function(v)
    Options.InfiniteJump = v
end)

-- Jump Handler
game:GetService("UserInputService").JumpRequest:Connect(function()
    if Options.InfiniteJump then
        Humanoid:ChangeState("Jumping")
    end
end)

-- Noclip Handler
game:GetService("RunService").Stepped:Connect(function()
    if Options.NoClip and Char then
        for _, Part in pairs(Char:GetDescendants()) do
            if Part:IsA("BasePart") then
                Part.CanCollide = false
            end
        end
    end
end)

--=== TAB WORLD ===--
local WorldTab = Window:CreateTab("World", Icons.strom)

WorldTab:AddToggle("AntiTsunami", {
    Title = "Auto Avoid Tsunami",
    Default = false
}, function(v)
    Options.AntiTsunami = v
    
    while Options.AntiTsunami do
        task.wait(0.5)
        local Water = workspace:FindFirstChild("Water") or workspace:FindFirstChild("Tsunami") or workspace:FindFirstChild("Wave")
        
        if Water and Water:IsA("Part") and (Root.Position - Water.Position).Magnitude < 50 then
            local Safe, Highest = nil, 0
            for _, Obj in pairs(workspace:GetDescendants()) do
                if Obj:IsA("Part") and Obj.Position.Y > Highest then
                    Highest, Safe = Obj.Position.Y, Obj
                end
            end
            TweenTo((Safe or Root.Position + Vector3.new(0, 200, 0)).Position + Vector3.new(0, 5, 0))
        end
    end
end)

WorldTab:AddToggle("RemoveWalls", {
    Title = "Remove Walls/Barriers",
    Default = false
}, function(v)
    Options.RemoveWalls = v
    
    for _, Obj in pairs(workspace:GetDescendants()) do
        if Obj:IsA("Part") and (Obj.Name:find("Wall") or Obj.Name:find("Barrier") or Obj.Name:find("VIP") or Obj.Name:find("Obstacle")) then
            Obj.CanCollide = not v
            Obj.Transparency = v and 0.8 or 0
        end
    end
end)

--=== TAB ESP ===--
local ESPTab = Window:CreateTab("ESP", Icons.eyes)

ESPTab:AddToggle("ESPEnabled", {
    Title = "Enable ESP",
    Description = "Lihat item tembus dinding",
    Default = false
}, function(v)
    Options.ESPEnabled = v
    
    if v then
        spawn(function()
            while Options.ESPEnabled do
                for _, Obj in pairs(workspace:GetDescendants()) do
                    if Obj:IsA("Model") and Obj:FindFirstChild("Humanoid") and Obj.Name:find("Brainrot") then
                        if not Obj:FindFirstChild("Highlight") then
                            local Highlight = Instance.new("Highlight")
                            Highlight.Parent = Obj
                            Highlight.FillColor = Color3.new(1, 0, 0)
                            Highlight.FillTransparency = 0.5
                        end
                    end
                end
                task.wait(2)
            end
            
            for _, Obj in pairs(workspace:GetDescendants()) do
                if Obj:IsA("Highlight") then Obj:Destroy() end
            end
        end)
    end
end)

--=== TAB TELEPORT ===--
local TPTab = Window:CreateTab("Teleport", Icons.gps)

TPTab:AddButton("To Base", function()
    TweenTo(getgenv().BasePosition.Position)
end)

TPTab:AddButton("To Safe Zone", function()
    local Safe, Highest = nil, 0
    for _, Obj in pairs(workspace:GetDescendants()) do
        if Obj:IsA("Part") and Obj.Position.Y > Highest then
            Highest, Safe = Obj.Position.Y, Obj
        end
    end
    TweenTo((Safe or Root.Position + Vector3.new(0, 200, 0)).Position + Vector3.new(0, 5, 0))
end)

TPTab:AddButton("To Spawn", function()
    local Spawn = workspace:FindFirstChild("Spawn") or workspace:FindFirstChild("Base")
    if Spawn then TweenTo(Spawn.Position + Vector3.new(0, 5, 0)) end
end)

--=== SAVE CONFIG ===--
Elements = {
    AutoFarm = FarmTab,
    FarmRadius = FarmTab,
    MinRarity = FarmTab,
    CollectDelay = FarmTab,
    ReturnToBase = BaseTab,
    AutoMoney = BaseTab,
    AutoBring = BringTab,
    BringRadius = BringTab,
    WalkSpeed = MoveTab,
    JumpPower = MoveTab,
    FlyMode = MoveTab,
    NoClip = MoveTab,
    InfiniteJump = MoveTab,
    AntiTsunami = WorldTab,
    RemoveWalls = WorldTab,
    ESPEnabled = ESPTab
}

LoadConfigElements()

-- Notifikasi Siap
Library:MakeNotify({
    Title = "Speed Hub Ready!",
    Description = "Tekan icon untuk buka menu",
    Color = Color3.fromRGB(0, 255, 255),
    Time = 3
})