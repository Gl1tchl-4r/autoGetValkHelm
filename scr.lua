task.spawn(function ()
    local args = {
        "SetTeam",
        "Marines"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    if game.PlaceId ~= 7449423635 then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelZou")
    else
        return
    end
end)

repeat wait() until game:IsLoaded() and game.Players.LocalPlayer.Character

local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local eliteHunter = game:GetService("ReplicatedStorage")
local eliteHunter1 = workspace:WaitForChild("Enemies")
local activeElite = nil
local castleIsland = Vector3.new(-5398.70263671875, 1088.790283203125, -2602.19921875)
local uptimeSeconds = workspace.DistributedGameTime
local uptimeMinutes = math.floor((uptimeSeconds % 3600) / 60)  -- นาทีส่วนที่เหลือ
_G.autoElite = true
_G.autoChest = false
_G.main = false
_G.farm = false
_G.fastattack = false

if table.find(_G.Configs["Main"], player.Name) then
    _G.main = true
elseif table.find(_G.Configs["Farm"], player.Name) then
    _G.farm = true
end

spawn(function ()
    for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
        v:Disable()
    end
end)

spawn(function()
    while task.wait(60) do
        uptimeSeconds = workspace.DistributedGameTime
        uptimeMinutes = math.floor((uptimeSeconds % 3600) / 60)  -- นาทีส่วนที่เหลือ
        print(uptimeMinutes .. " min")
        if uptimeMinutes == 242 then
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

local function teleportTo(targetCFrame)
    hrp.CFrame = targetCFrame
end

function tweenTo(POs, speed, useTpForClose)
    speed = speed or 350
    useTpForClose = useTpForClose or true
    
    hrp.Anchored = false
    local targetCFrame = typeof(POs) == "Vector3" and CFrame.new(POs) or POs
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    if distance < 100 and useTpForClose then
        teleportTo(targetCFrame)
        return
    end
    
    if distance < 5 then
        return
    end
    
    humanoid.PlatformStand = true
    
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P = 10000
    bodyGyro.D = 1000
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = hrp
    
    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
    
    local tween = TweenService:Create(hrp, TweenInfo.new(distance/speed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
    
    bodyGyro:Destroy()
    bodyVelocity:Destroy()
    humanoid.PlatformStand = false
    -- hrp.Anchored = true
    
    task.wait()
    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            v.CanCollide = true
        end
    end
end

local function fastAttack()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer
    
    -- Cache modules
    local CombatUtil, CombatController, Anims
    pcall(function()
        CombatUtil = require(ReplicatedStorage.Modules.CombatUtil)
        CombatController = require(ReplicatedStorage.Controllers.CombatController)
        Anims = require(ReplicatedStorage.Util.Anims)
    end)
    
    -- Setup Combat & Camera
    pcall(function() rawset(CombatUtil, "CanCharacterMeleeAoe", function() return 15 end) end)
    pcall(function()
        require(ReplicatedStorage.Util.CameraShaker.Main.CameraShakeInstance).CameraShakeState = {
            FadingIn = 3, FadingOut = 2, Sustained = 0, Inactive = 1
        }
    end)
    
    -- หาอาวุธ melee
    local function getMeleeWeapon()
        local character = LocalPlayer.Character
        local tool = character and character:FindFirstChildOfClass("Tool")
        if tool and (tool.ToolTip == "Melee" or tool.ToolTip == "Sword") then return tool end
        
        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.ToolTip == "Melee" or tool.ToolTip == "Sword") then
                return tool
            end
        end
    end
    
    -- ปรับแต่งอาวุธ
    local function setupWeapon(weapon)
        if not weapon or not CombatUtil then return end
        
        pcall(function()
            local data = CombatUtil:GetWeaponData(weapon.Name)
            if not data then return end
            
            data.HitboxMagnitude = 60
            data.SwingSound = ""
            data.HitSound = ""
            
            local combo = data.Moveset and data.Moveset.Basic and data.Moveset.Basic[1]
            if combo then
                data.Moveset.Basic = {combo}
                
                for _, animId in pairs(combo) do
                    if tostring(animId):find("rbxassetid") and Anims and Anims.Cached then
                        local character = LocalPlayer.Character
                        local cached = character and Anims.Cached[character] and Anims.Cached[character][tostring(animId)]
                        if cached and cached._Object then
                            pcall(function()
                                local mt = getrawmetatable(cached._Object)
                                setreadonly(mt, false)
                                local oldIndex = mt.__index
                                mt.__index = function(t, k) return k == "Length" and 0.1 or oldIndex(t, k) end
                                setreadonly(mt, true)
                            end)
                        end
                        break
                    end
                end
            end
        end)
    end
    
    -- Variables
    local currentWeapon, lastWeaponCheck, lastAttackTime = nil, 0, 0
    
    -- Setup initial weapon
    local weapon = getMeleeWeapon()
    if weapon then
        setupWeapon(weapon)
        currentWeapon = weapon.Name
    end
    
    -- Main loop
    RunService.Heartbeat:Connect(function()
        if not _G.fastattack then return end
        
        local now = tick()
        
        -- Check weapon change every 2 seconds
        if now - lastWeaponCheck > 2 then
            local newWeapon = getMeleeWeapon()
            if newWeapon and (not currentWeapon or newWeapon.Name ~= currentWeapon) then
                setupWeapon(newWeapon)
                currentWeapon = newWeapon.Name
            end
            lastWeaponCheck = now
        end
        
        -- Attack with delay
        if now - lastAttackTime < 0.12 then return end
        
        pcall(function()
            local character = LocalPlayer.Character
            local tool = character and character:FindFirstChildOfClass("Tool")
            if tool and (tool.ToolTip == "Melee" or tool.ToolTip == "Sword") and CombatController then
                CombatController:Attack(tool, {
                    UserInputType = Enum.UserInputType.MouseButton1,
                    UserInputState = Enum.UserInputState.Begin
                })
                lastAttackTime = now
            end
        end)
    end)
end

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
    {name = "Castle on the Sea", pos = Vector3.new(-5495.14501953125, 313.83465576171875, -2845.745849609375)},
    {name = "Sea of Treats1", pos = Vector3.new(-2192.566650390625, 85.58361053466797, -10380.228515625)},
    {name = "Sea of Treats2", pos = Vector3.new(-763.7967529296875, 126.93671417236328, -11074.91796875)},
    {name = "Sea of Treats3", pos = Vector3.new(-2249.046875, 219.07373046875, -12382.04296875)},
    {name = "Sea of Treats4", pos = Vector3.new(184.73313903808594, 126.65753936767578, -12771.9677734375)},
    {name = "Great Tree", pos = Vector3.new(2760.646484375, 509.26861572265625, -7397.189453125)},
    {name = "Hydra Island", pos = Vector3.new(5584.1767578125, 1005.2504272460938, 81.14107513427734)},
    {name = "Port Town", pos = Vector3.new(-387.56634521484375, 233.68856811523438, 6378.72021484375)},
    {name = "Haunted Castle", pos = Vector3.new(-9514.5126953125, 164.0460662841797, 5786.6748046875)},
    {name = "Tiki Outpost", pos = Vector3.new(-16552.021484375, 201.71981811523438, 558.6769409179688)},
    {name = "Floating Turtle", pos = Vector3.new(-12252.904296875, 331.7889099121094, -9091.529296875)}
}

local islandIndex = 0

local function collectChests()
    while task.wait(0.1) do
        pcall(function()
            local chest = workspace.ChestModels:GetChildren()
            local countChest = #chest
            if countChest == 0 then
                task.wait(0.5)
                if #workspace.ChestModels:GetChildren() == 0 then
                    islandIndex = islandIndex + 1
                    if islandIndex > #islandList then
                        islandIndex = 1
                    end
                    local newIsland = islandList[islandIndex]
                    print(newIsland.name)
                    repeat  task.wait()
                        tweenTo(newIsland.pos)
                    until hrh.Position == newIsland.pos
                end
            else
                for _, v in pairs(chest) do
                    if v:FindFirstChild("PushBox") and v.PushBox:FindFirstChild("TouchInterest") then
                        tweenTo(v.RootPart.CFrame)
                    end
                end
            end
        end)
    end
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
                        tweenTo(v.CFrame)
                    until v.Part.BrickColor.Name == "Lime green"
                elseif v.Name == "Part" and v.BrickColor.Name == "Hot pink" then
                    activeHaki("Winter Sky")
                    print(2)
                    repeat task.wait(0.1)
                        tweenTo(v.CFrame)
                    until v.Part.BrickColor.Name == "Lime green"
                elseif v.Name == "Part" and v.BrickColor.Name == "Really red" then
                    activeHaki("Pure Red")
                    print(3)
                    repeat task.wait()
                        tweenTo(v.CFrame)
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
    end
end

local function attackRipIndra()
    pcall(function ()
        if ripindraSpawn() then
            local indra = workspace.Enemies:FindFirstChild("rip_indra True Form")
            repeat task.wait()
                indra.Humanoid.JumpPower = 0
                indra.Humanoid.WalkSpeed = 0
                tweenTo(CFrame.new(indra.HumanoidRootPart.CFrame))
                equipTool("Melee")
            until indra.Humanoid.Health >= 0 and not indra.Parent
        end
    end)
end

local function equipTool(typeTool)
    pcall(function()
        local backpack = game:GetService("Players").LocalPlayer.Backpack:GetChildren()
        for _, v in pairs(backpack) do
            if v:IsA("Tool") and v.ToolTip == typeTool then
                humanoid:EquipTool(v)
            end
        end
    end)
end

local reachedCastle = false

if _G.main and game.PlaceId == 7449423635 then
    print('mainMode')
    fastAttack()
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
                            tweenTo(elitePos * CFrame.new(0,20,0))
                            equipTool("Melee")
                            _G.fastattack = true
                        until activeElite.Humanoid.Health <= 0 or not activeElite.Parent or game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == false
                        _G.fastattack = false
                    end
                end
            end)
        elseif _G.autoChest and _G.autoElite == false and uptimeMinutes >= 241 then
            repeat task.wait()
                collectChests()
            until hasGodChalice()
            _G.autoChest = false
        end
        if hasGodChalice() then
            _G.autoElite = false
            if hrp.CFrame.Position ~= castleIsland and not reachedCastle then
                repeat task.wait()
                    tweenTo(castleIsland)
                until hrp.CFrame.Position == castleIsland
                print("reachedCastle")
                reachedCastle = true
            else
                if hrp.CFrame.Position == castleIsland and reachedCastle then
                    print("here tapHaki")
                    tapHaki()
                    repeat  task.wait(0.1)
                        tweenTo(CFrame.new(-5559.47607, 313.981659, -2664.13965, -0.423708141, -2.67357763e-08, 0.905798793, -7.12683104e-08, 1, -3.82114251e-09, -0.905798793, -6.61737971e-08, -0.423708141))
                    until ripindraSpawn()
                    _G.fastattack = true
                    attackRipIndra()
                    _G.fastattack = false
                    return
                end
            end
        end
    end
end

if _G.farm and game.PlaceId == 7449423635 then
    print('farmMode')
    fastAttack()
    while task.wait() do
        pcall(function()
            if hrp.CFrame.Position ~= castleIsland and not reachedCastle then
                repeat task.wait()
                    tweenTo(castleIsland)
                until hrp.CFrame.Position == castleIsland
                reachedCastle = true
            else
                if hrp.CFrame.Position == castleIsland and reachedCastle then
                    repeat
                        task.wait(0.5)
                    until ripindraSpawn()
                    _G.fastattack = true
                    attackRipIndra()
                    _G.fastattack = false
                end
            end
        end)
    end
end
