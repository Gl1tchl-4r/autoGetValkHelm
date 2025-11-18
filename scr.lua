repeat wait() until game:IsLoaded() and game.Players.LocalPlayer and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Main (minimal)")

task.spawn(function ()
    local args = {
        "SetTeam",
        "Marines"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
        
    repeat wait() until game:IsLoaded() and game.Players.LocalPlayer.Character
        
    if game.PlaceId ~= 7449423635 then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelZou")
    else
        return
    end
end)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")
local eliteHunter = game:GetService("ReplicatedStorage")
local eliteHunter1 = workspace:WaitForChild("Enemies")
local activeElite = nil
local castleIsland = CFrame.new(-5398.70263671875, 1088.790283203125, -2602.19921875)
local uptimeSeconds = workspace.DistributedGameTime
local uptimeMinutes = math.floor(uptimeSeconds / 60)
_G.autoElite = true
_G.autoChest = false
_G.main = false
_G.farm = false
_G.autoGetElite = true

if table.find(_G.Configs["Main"], player.Name) then
    _G.main = true
elseif table.find(_G.Configs["Farm"], player.Name) then
    _G.farm = true
end


-- Anti AFK
spawn(function ()
    for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
        v:Disable()
    end
end)

spawn(function()
    while task.wait(60) do
        uptimeSeconds = workspace.DistributedGameTime
        uptimeMinutes = math.floor(uptimeSeconds / 60)
        print(uptimeMinutes .. " min")
        if uptimeMinutes >= 242 then
            _G.autoElite = false
            _G.autoChest = true
            return
        end
    end
end)

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    hrp = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    if _G.currentStabilizer then
        _G.currentStabilizer:Disconnect()
        _G.currentStabilizer = nil
    end
end)

RunService.Heartbeat:Connect(function ()
    pcall(function ()
        if true and character and workspace:FindFirstChild("TweenPart") then
            hrp.CFrame = workspace.TweenPart.CFrame
        end
    end)
end)


local function creatTweenPart()
    local part = Instance.new("Part")
    part.Size = Vector3.new(1, 1, 1)
    part.Anchored = true
    part.CanCollide = false
    part.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
    part.Transparency = 1
    part.Name = "TweenPart"
    part.Parent = workspace
    return part
end

local function tween(pos)
    local TweenPart = game.Workspace:FindFirstChild("TweenPart")
    if not TweenPart then TweenPart = creatTweenPart()end
    if (hrp.Position - (pos.Position or pos)).Magnitude < 60 then
        TweenPart.CFrame = pos
        return
    end
    if TweenPart.CFrame ~= game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame then
        TweenPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
    end
    local distance = (pos.Position - hrp.Position).Magnitude
    local TweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(distance / 350, Enum.EasingStyle.Linear)
    local startTween = TweenService:Create(TweenPart, tweenInfo, { CFrame = pos })
    startTween:Play()
    startTween.Completed:Wait()
end

local function getEnemies(range)
    local targets = {}
    local pos = player.Character:GetPivot().Position
    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
        local root = enemy:FindFirstChild("HumanoidRootPart")
        local humanoid = enemy:FindFirstChild("Humanoid")
        if root and humanoid and humanoid.Health > 0 then
            if (root.Position - pos).Magnitude <= range then
                table.insert(targets, enemy)
            end
        end
    end
    return targets
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function attack()
    local char = player.Character
    if not char or not char:FindFirstChildOfClass("Tool") then return end
    
    local enemies = getEnemies(60)
    if #enemies == 0 then return end
    
    local modules = ReplicatedStorage.Modules
    local attackEvent = modules.Net["RE/RegisterAttack"]
    local hitEvent = modules.Net["RE/RegisterHit"]
    
    local targets, mainTarget = {}, nil
    local limbs = {"RightLowerArm", "RightUpperArm", "LeftLowerArm", "LeftUpperArm", "RightHand", "LeftHand"}
    
    for _, enemy in pairs(enemies) do
        local hitbox = enemy:FindFirstChild(limbs[math.random(#limbs)]) or enemy.PrimaryPart
        if hitbox then
            table.insert(targets, {enemy, hitbox})
            mainTarget = hitbox
        end
    end
    
    if mainTarget then
        attackEvent:FireServer(0)
        
        local success, combatThread = pcall(function()
            return require(modules.Flags).COMBAT_REMOTE_THREAD
        end)
        
        local hitFunc
        if getsenv then
            local env = getsenv(player.PlayerScripts:FindFirstChildOfClass("LocalScript"))
            if env then hitFunc = env._G.SendHitsToServer end
        end
        
        if success and combatThread and hitFunc then
            hitFunc(mainTarget, targets)
        else
            hitEvent:FireServer(mainTarget, targets)
        end
    end
end

spawn(function()
    while true do
        if player.Character then
            attack()
        end
        task.wait(0.1)
    end
end)

local function getEnemies()
    if _G.autoGetElite then
        pcall(function()
            local Diablo = eliteHunter:FindFirstChild("Diablo")
            local Deandre = eliteHunter:FindFirstChild("Deandre")
            local Urban = eliteHunter:FindFirstChild("Urban")
            local Diablo1 = eliteHunter1:FindFirstChild("Diablo")
            local Deandre1 = eliteHunter1:FindFirstChild("Deandre")
            local Urban1 = eliteHunter1:FindFirstChild("Urban")
            if Diablo then
                activeElite = Diablo
            elseif Deandre then
                activeElite = Deandre
            elseif Urban then
                activeElite = Urban
            elseif Diablo1 then
                activeElite = Diablo1
            elseif Deandre1 then
                activeElite = Deandre1
            elseif Urban1 then
                activeElite = Urban1
            else
                activeElite = nil
            end
        end)
    end
end

local islandList = {
    {name = "Castle on the Sea", pos = CFrame.new(-5495.14501953125, 313.83465576171875, -2845.745849609375)},
    {name = "Sea of Treats1", pos = CFrame.new(-2192.566650390625, 85.58361053466797, -10380.228515625)},
    {name = "Sea of Treats2", pos = CFrame.new(-763.7967529296875, 126.93671417236328, -11074.91796875)},
    {name = "Sea of Treats3", pos = CFrame.new(-2249.046875, 219.07373046875, -12382.04296875)},
    {name = "Sea of Treats4", pos = CFrame.new(184.73313903808594, 126.65753936767578, -12771.9677734375)},
    {name = "Great Tree", pos = CFrame.new(2760.646484375, 509.26861572265625, -7397.189453125)},
    {name = "Hydra Island", pos = CFrame.new(5584.1767578125, 1005.2504272460938, 81.14107513427734)},
    {name = "Port Town", pos = CFrame.new(-387.56634521484375, 233.68856811523438, 6378.72021484375)},
    {name = "Haunted Castle", pos = CFrame.new(-9514.5126953125, 164.0460662841797, 5786.6748046875)},
    {name = "Tiki Outpost", pos = CFrame.new(-16552.021484375, 201.71981811523438, 558.6769409179688)},
    {name = "Floating Turtle", pos = CFrame.new(-12252.904296875, 331.7889099121094, -9091.529296875)}
}

local islandIndex = 0

local function collectChests()
    pcall(function()
        local chest = workspace.ChestModels:GetChildren()
        local countChest = #chest
        if countChest == 0 then
            if #workspace.ChestModels:GetChildren() == 0 then
                islandIndex = islandIndex + 1
                if islandIndex > #islandList then
                    islandIndex = 1
                end
                local newIsland = islandList[islandIndex]
                print(newIsland.name)
                repeat task.wait()
                    tween(newIsland.pos)
                until (hrp.Position - newIsland.pos).Magnitude <= 10
            end
        else
            for _, v in pairs(chest) do
                if v:FindFirstChild("PushBox") and v.PushBox:FindFirstChild("TouchInterest") then
                    tween(v.RootPart.CFrame)
                    task.wait(0.1)
                end
            end
        end
    end)
end

local function hasGodChalice()
    if game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("God's Chalice") then
        return true
    end
end

local function activeHaki(color)
    local args = {
    	{
    		StorageName = color,
    		Type = "AuraSkin",
    		Context = "Equip"
    	}
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/FruitCustomizerRF"):InvokeServer(unpack(args))
end

local function tapHaki()
    pcall(function ()
        local partHaki = workspace.Map["Boat Castle"].Summoner.Circle:GetChildren()
        local allGreen = true
        for i,v in pairs(partHaki) do
            if v.Name == "Part" then
                if v.Name == "Part" and v.BrickColor.Name == "Oyster" then
                    activeHaki("Snow White")
                    print(1)
                    repeat task.wait(0.1)
                        tween(v.CFrame)
                    until v.Part.BrickColor.Name == "Lime green"
                elseif v.Name == "Part" and v.BrickColor.Name == "Hot pink" then
                    activeHaki("Winter Sky")
                    print(2)
                    repeat task.wait(0.1)
                        tween(v.CFrame)
                    until v.Part.BrickColor.Name == "Lime green"
                elseif v.Name == "Part" and v.BrickColor.Name == "Really red" then
                    activeHaki("Pure Red")
                    print(3)
                    repeat task.wait()
                        tween(v.CFrame)
                    until v.Part.BrickColor.Name == "Lime green"
                end
                if v.Part.BrickColor.Name ~= "Lime green" then
                    allGreen = false
                end
            end
        end
        if allGreen then
            print('bye')
            return
        end
    end)
end

local function ripindraSpawn()
    if workspace.Enemies:FindFirstChild("rip_indra True Form") then
        return true
    else
        return false
    end
end

local function equipTool(typeTool)
    pcall(function()
        local backpack = game:GetService("Players").LocalPlayer.Backpack:GetChildren()
        for _, v in pairs(backpack) do
            if v:IsA("Tool") and (v.ToolTip == typeTool or v.Name == typeTool) then
                humanoid:EquipTool(v)
            end
        end
    end)
end

local function attackRipIndra()
    pcall(function ()
        local indra = workspace.Enemies:FindFirstChild("rip_indra True Form")
        if not indra then print("indra not spawn") return end
        repeat task.wait()
            indra.Humanoid.JumpPower = 0
            indra.Humanoid.WalkSpeed = 0
            tween(indra.HumanoidRootPart.CFrame * CFrame.new(0,20,0))
            equipTool("Melee")
        until not workspace.Enemies:FindFirstChild("rip_indra True Form") and not game:GetService("Players").LocalPlayer.PlayerGui.TransformationHUD.BossBar.Visible
        print("Rip_indra die")
    end)
end

local reachedCastle = false

if _G.main and game.PlaceId == 7449423635 then
    print('mainMode')
    attack()
    while task.wait() do
        if _G.autoElite then
            pcall(function ()
                if not activeElite or not activeElite:FindFirstChild("HumanoidRootPart") then
                    getEnemies()
                    task.wait(1)
                else
                    if game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == false then
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("EliteHunter")
                    else
                        repeat task.wait()
                            local elitePos = activeElite.HumanoidRootPart.CFrame
                            activeElite.Humanoid.JumpPower = 0
                            activeElite.Humanoid.WalkSpeed = 0
                            tween(elitePos * CFrame.new(0,20,0))
                            equipTool("Melee")
                        until activeElite.Humanoid.Health <= 0 or not activeElite.Parent or game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == false
                    end
                end
            end)
        elseif _G.autoChest and _G.autoElite == false and uptimeMinutes >= 242 then
            repeat task.wait()
                collectChests()
            until hasGodChalice()
            _G.autoChest = false
        end
        if hasGodChalice() or ripindraSpawn() then
            _G.autoElite = false
            if not reachedCastle then
                repeat task.wait()
                    tween(castleIsland)
                until (hrp.Position - castleIsland.Position).Magnitude <= 5
                print("reachedCastle")
                reachedCastle = true
            else
                if reachedCastle and not workspace.Enemies:FindFirstChild("rip_indra True Form") then
                    print("here tapHaki")
                    tapHaki()
                    print("allgreen Haki")
                    repeat task.wait(0.1)
                        tween(CFrame.new(-5559.47607, 313.981659, -2664.13965, -0.423708141, -2.67357763e-08, 0.905798793, -7.12683104e-08, 1, -3.82114251e-09, -0.905798793, -6.61737971e-08, -0.423708141))
                        equipTool("God's Chalice")
                    until ripindraSpawn() or workspace.Enemies:FindFirstChild("rip_indra True Form")
                elseif ripindraSpawn() then 
                    print("Rip_indra spawned")
                    repeat task.wait()
                        print("attacking rip indra")
                        attackRipIndra()
                    until not workspace.Enemies:FindFirstChild("rip_indra True Form") and not game:GetService("Players").LocalPlayer.PlayerGui.TransformationHUD.BossBar.Visible
                    return
                end
            end
        end
    end
end

if _G.farm and game.PlaceId == 7449423635 then
    print('farmMode')
    attack()
    while task.wait() do
        pcall(function()
            if not reachedCastle then
                repeat task.wait()
                    tween(castleIsland)
                until (hrp.Position - castleIsland.Position).Magnitude <= 5
                print("reachedCastle")
                reachedCastle = true
            else
                if reachedCastle and not workspace.Enemies:FindFirstChild("rip_indra True Form") then
                    repeat
                        task.wait(0.5)
                        print('wait for ripindraSpawn')
                    until ripindraSpawn()
                elseif ripindraSpawn() then
                    print("Rip_indra spawned")
                    repeat task.wait()
                        print("attacking rip indra")
                        attackRipIndra()
                    until not workspace.Enemies:FindFirstChild("rip_indra True Form") and not game:GetService("Players").LocalPlayer.PlayerGui.TransformationHUD.BossBar.Visible
                end
            end
        end)
    end
end
