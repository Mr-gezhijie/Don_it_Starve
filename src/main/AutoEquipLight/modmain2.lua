---
--- Created by GEZHIJIE.
--- DateTime: 2024/9/21 23:20
---

local GLOBAL = GLOBAL;
local require = GLOBAL.require;
local pcall = GLOBAL.pcall
local ACTIONS = GLOBAL.ACTIONS
local BufferedAction = GLOBAL.BufferedAction
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local TheSim = GLOBAL.TheSim
local FindEntity = GLOBAL.FindEntity
local TheInput = GLOBAL.TheInput
local AllRecipes = GLOBAL.AllRecipes
local GetTime = GLOBAL.GetTime

local AASC = require("widgets/aas_new")
local AALC = require("widgets/aas_lag")
local PlayerProfile = require("playerprofile")

local delayUnequipASecond = 0
local hasEquipped = false;
local letsDoDebug = true

local Backup_GetActionButtonAction

--  正在修改这个
local modOptions = {
    ENABLED = GetModConfigData("ae_enablemod") > 0,
    --IGNORE_RESTRICTIONS = GetModConfigData("autoequipignorerestrictions") > 0,
    --IGNORE_SAPS = GetModConfigData("ae_alwaysignoresaps") > 0,
    --
    --TRY_PICKUP_NEARBY_TOOLS = GetModConfigData("ae_use_nearby_tools") > 0,
    SWITCH_TOOLS_AUTO = GetModConfigData("ae_switchtools") == 1 or GetModConfigData("ae_switchtools") == 2,
    --SWITCH_TOOLS_MOUSE = GetModConfigData("ae_switchtools") == 1 or GetModConfigData("ae_switchtools") == 3,
    --EQUIP_WEAPONS = GetModConfigData("ae_equipweapon") > 0,
    --CRITTERS_WITH_BOOMERANG = GetModConfigData("ae_boomcritters") > 0,

    -- 创建
    CREATE_LIGHT_IN_DARK = GetModConfigData("ae_lightindark") > 1,
    -- 装备
    EQUIP_LIGHT_IN_DARK = GetModConfigData("ae_lightindark") > 0,

    ECO_MODE = true,
    --CRAFT_TOOLS_MOUSE = GetModConfigData("ae_crafttools_mouse") > 0,
    --CRAFT_TOOLS_MOUSE_GOLDEN = GetModConfigData("ae_crafttools_mouse") > 1,
    --CRAFT_TOOLS_AUTO = GetModConfigData("ae_crafttools") > 0,
    --CRAFT_TOOLS_AUTO_GOLDEN = GetModConfigData("ae_crafttools") > 1,
    --
    IGNORE_TRAPS = false,
    REACTIVATE_TRAPS = false,
    --
    --REPLANT_TREES = GetModConfigData("ae_replanttrees") > 0,
    --REFUEL_FIRES = GetModConfigData("ae_refuelfires") > 0,
    --REFUEL_FIRES_PRIORITIZE = GetModConfigData("ae_refuelfires"),
    --REPAIR_WALLS = GetModConfigData("ae_repairwalls") > 0
};

-- Functions --

local forceResetTrap
local forceUnequipTool
local forcePlantSapling
local forcePlantSaplingPlacer
local ToggleModEnabled
local HasShownPredictiveWarning = nil;
local STARTSCALE = 0.25
local NORMSCALE = 1
local controls = nil

-- 有一个按键控制到时候注意一下
-- 自定义键位
local KEYBOARDTOGGLEKEY = GetModConfigData("autoequipopeningamesettings") or "L"
if type(KEYBOARDTOGGLEKEY) == "string" then
    KEYBOARDTOGGLEKEY = KEYBOARDTOGGLEKEY:lower():byte()
end

local TARGET_EXCLUDE_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }
local PICKUP_TARGET_EXCLUDE_TAGS = { "catchable" }
local HAUNT_TARGET_EXCLUDE_TAGS = { "haunted", "catchable" }
for i, v in ipairs(TARGET_EXCLUDE_TAGS) do
    table.insert(PICKUP_TARGET_EXCLUDE_TAGS, v)
    table.insert(HAUNT_TARGET_EXCLUDE_TAGS, v)
end



-- 用于装备工具或者武器的（配置inst物品）
local function DoEquip( inst, tool )
    if( inst == nil or inst.components == nil or inst.components.playercontroller == nil or tool == nil ) then return end

    local plcotrl = inst.components.playercontroller
    if( plcotrl and plcotrl.inst and plcotrl.inst.replica and plcotrl.inst.replica.inventory ) then
        if letsDoDebug then print("- Equipping tool/weapon:",tool) end
        -- 防止过快切换装备
        delayUnequipASecond = GetTime()+0.25
        hasEquipped = true;

        inst.replica.inventory:UseItemFromInvTile(tool)
    else
        if letsDoDebug then print("Tried to equip, but failed.") end
    end
end

-- 查看库存用途
local function GetInventory( inst )
    return ( inst.components and inst.components.playercontroller and inst.components.inventory ) or ( inst.replica and inst.replica.inventory )
end
-- 查找物品
local function CustomFindItem( inst, inv, check )
    local items = inv and inv.GetItems and inv:GetItems() or inv.itemslots or nil
    if not inst or not inv or not check or not items then if letsDoDebug then print("Something went wrong with the inventory...") end return nil end

    local zeItem = nil
    local zeIndex = nil

    for k,v in pairs(items) do
        if check(v) then
            zeItem = v
            zeIndex = k
        end
    end

    if inv.GetOverflowContainer and inv:GetOverflowContainer() ~= nil then
        items = inv:GetOverflowContainer() and inv:GetOverflowContainer().GetItems and inv:GetOverflowContainer():GetItems() or inv:GetOverflowContainer().slots or nil
        if items then
            for k,v in pairs(items) do
                if check(v) then
                    zeItem = v
                    zeIndex = k
                end
            end
        end
    end

    if( inst.replica and inst.replica.inventory and inst.replica.inventory.GetEquippedItem and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) and check(inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)) ) then
        zeItem = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    end

    if(zeItem ~= nil) then zeItem.lastslot = zeIndex end

    return zeItem
end

-- 自动装备和创建光源操作
local tookLightOut = nil
local firstCheckedForDarkness = nil
local function CheckIfInDarkness( inst )
    if( not firstCheckedForDarkness ) then
        if letsDoDebug then print("Oh, it's dark...") end
        firstCheckedForDarkness = GetTime()
    elseif( firstCheckedForDarkness and GetTime() > (firstCheckedForDarkness+2) ) then
        if letsDoDebug then print("That's it, I'm equipping light!") end
        firstCheckedForDarkness = nil

        -- 先查找是否有提灯
        local possibleLights = CustomFindItem(inst, GetInventory(inst), function(item) return item:HasTag("light") and not item:HasTag("lightbattery") end) -- For now, just use whatever can be found
        -- 判断是否有提灯，没有提灯或者燃料，就会查找火把
        if letsDoDebug then print("打印耐久度" .. tostring(possibleLights.replica.inventoryitem.classified.percentused:value()) ) end
        if( possibleLights == nil or possibleLights.replica.inventoryitem.classified.percentused:value() < 1 )then
            possibleLights = CustomFindItem(inst, GetInventory(inst), function(item) return item:HasTag("lighter") end) -- For now, just use whatever can be found
        end


        if( possibleLights ) then
            if possibleLights then
                if letsDoDebug then print("Equipping a light-source!") print(possibleLights) end
                DoEquip(inst,possibleLights)
                tookLightOut = true;
            else
                if letsDoDebug then print("No lights found! Something went wrong...") end
            end
        else
            if( modOptions.CREATE_LIGHT_IN_DARK ) then
                if letsDoDebug then print("No lights found, but attempting to craft a light.") end
                if( inst.replica and inst.replica.builder and inst.replica.builder.CanBuild and inst.replica.builder.MakeRecipeFromMenu and inst.replica.builder:CanBuild("torch") ) then
                    inst.replica.builder:MakeRecipeFromMenu(AllRecipes["torch"])
                    tookLightOut = true;
                end
            else
                if letsDoDebug then print("No lights found.") end
            end
        end
        -- Tag is "lighter"
    end
end

 -- 获取装备物品
local function GetEquippedItem(inst)
    if inst and inst.replica and inst.replica.inventory then
        return inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    end
    return nil
end

-- 有被调用
local function CheckIfOutOfDarkness( inst )
    if(tookLightOut == nil) then return end

    local tool = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS);
    if(tool ~= nil) then
        if(tool:HasTag("lighter") or tool:HasTag("light")  ) then
            inst.replica.inventory:UseItemFromInvTile(inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS))
            tookLightOut = nil;
        end
    end
end

-- 有被调用
local function IsDefaultScreen()
    return GLOBAL.TheFrontEnd:GetActiveScreen().name:find("HUD") ~= nil
            and not(GLOBAL.ThePlayer.HUD:IsControllerCraftingOpen() or GLOBAL.ThePlayer.HUD:IsControllerInventoryOpen())
end

local function IMS( plyctrl )
    return plyctrl.ismastersim
end

-- 有被调用
local function UpdateTreePlacer( info, doremove )
    if(doremove and forcePlantSaplingPlacer) then
        forcePlantSaplingPlacer:Remove()
        return false
    end

    if(forcePlantSaplingPlacer and forcePlantSaplingPlacer:IsValid()) then
        forcePlantSaplingPlacer.Transform:SetPosition(info[2].x,info[2].y,info[2].z)
    else
        forcePlantSaplingPlacer = CreateEntity()

        local seedType = aa_seedTypes[info[1]]

        forcePlantSaplingPlacer:AddTag("FX")
        forcePlantSaplingPlacer.entity:SetCanSleep(false)
        forcePlantSaplingPlacer.persists = false

        forcePlantSaplingPlacer.entity:AddTransform()
        forcePlantSaplingPlacer.entity:AddAnimState()
        forcePlantSaplingPlacer.AnimState:SetBank(seedType)
        forcePlantSaplingPlacer.AnimState:SetBuild(seedType)
        forcePlantSaplingPlacer.AnimState:PlayAnimation("idle_planted", true)
        forcePlantSaplingPlacer.AnimState:SetLightOverride(1)

        forcePlantSaplingPlacer.AnimState:SetAddColour(.25, .25, .25, 0)

        if(forcePlantSaplingPlacer and forcePlantSaplingPlacer:IsValid()) then
            forcePlantSaplingPlacer.Transform:SetPosition(info[2].x,info[2].y,info[2].z)
        end
    end
end

-- 用于卸下工具或者武器的
local function DoUnequip( plcotrl, force )
    if( plcotrl and plcotrl.inst and plcotrl.inst.replica and plcotrl.inst.replica.inventory ) then -- plcotrl.autoequip_lastequipped ~= nil
        if letsDoDebug then print("- Unequipping tool/weapon") end
        hasEquipped = false;
        hasEquippedType = "";
        plcotrl.inst.replica.inventory:UseItemFromInvTile(plcotrl.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS))
    end
end

-- 用于装备工具或者武器的（配置inst物品）
local function DoEquip( inst, tool )
    if( inst == nil or inst.components == nil or inst.components.playercontroller == nil or tool == nil ) then return end

    local plcotrl = inst.components.playercontroller
    if( plcotrl and plcotrl.inst and plcotrl.inst.replica and plcotrl.inst.replica.inventory ) then
        if letsDoDebug then print("- Equipping tool/weapon:",tool) end
        -- 防止过快切换装备
        delayUnequipASecond = GetTime()+0.25
        hasEquipped = true;

        inst.replica.inventory:UseItemFromInvTile(tool)
    else
        if letsDoDebug then print("Tried to equip, but failed.") end
    end
end

-- attached to playercontroller.OnUpdate
-- 照明装备「处理动作」
local function OnUpdate(playercontroller, dt)
    if not playercontroller:IsEnabled() then return end

    -- 是发光衣服
    local isShineOutfit =  false
    -- 使用示例，获取玩家头上的装备物品
    local equipped_hat = GetEquippedItem(playercontroller.inst)
    if equipped_hat and tostring(equipped_hat.prefab) == "molehat" then
        isShineOutfit = true
    end


    -- 查看定义的判断什么时候开灯
    if modOptions.EQUIP_LIGHT_IN_DARK then
        if  not isShineOutfit and GLOBAL.TheWorld.state.isnight and not GLOBAL.TheWorld.state.isfullmoon and playercontroller.inst.LightWatcher and not playercontroller.inst.LightWatcher:IsInLight() then CheckIfInDarkness(playercontroller.inst) elseif(  not (GLOBAL.TheWorld.state.isnight and not GLOBAL.TheWorld.state.isfullmoon and playercontroller.inst.LightWatcher and not playercontroller.inst.LightWatcher:IsInLight()) and firstCheckedForDarkness ) then firstCheckedForDarkness = nil elseif(not GLOBAL.TheWorld.state.isnight and tookLightOut ~= nil) then CheckIfOutOfDarkness(playercontroller.inst) end
    end
    if(HasShownPredictiveWarning == nil) then
        if(PlayerProfile:GetMovementPredictionEnabled() == false) then
            if type(GLOBAL.ThePlayer) == "table" and type(GLOBAL.ThePlayer.HUD) == "table" and IsDefaultScreen() then
                GLOBAL.TheFrontEnd:PushScreen(AALC())
                HasShownPredictiveWarning = true;
            end
        else
            HasShownPredictiveWarning = true;
        end
    end

    -- 如果 有动作，不执行代码
    if( ( IMS(playercontroller) and not playercontroller.inst.sg:HasStateTag("idle") ) or ( not IMS(playercontroller) and not playercontroller.inst:HasTag("idle") ) ) then return end
    if TheInput:IsControlPressed(GLOBAL.CONTROL_PRIMARY) then return end
    if TheInput:IsControlPressed(GLOBAL.CONTROL_SECONDARY) then return end
    if TheInput:IsControlPressed(GLOBAL.CONTROL_ACTION) then return end
    if TheInput:IsControlPressed(GLOBAL.CONTROL_ATTACK) then return end
    if( ( IMS(playercontroller) and playercontroller.inst.sg:HasStateTag("working") ) or ( not IMS(playercontroller) and playercontroller.inst:HasTag("working") ) ) then return end
    if( ( IMS(playercontroller) and playercontroller.inst.sg:HasStateTag("doing") ) or ( not IMS(playercontroller) and playercontroller.inst:HasTag("doing") ) ) then return end
    if( ( IMS(playercontroller) and playercontroller.inst.sg:HasStateTag("attack") ) or ( not IMS(playercontroller) and playercontroller.inst:HasTag("attack") ) ) then return end
    if playercontroller.inst.replica.combat.target ~= nil then return end
    -- print("switch to previous equipped item")

    if( forcePlantSapling ) then forcePlantSapling = nil UpdateTreePlacer(nil,true) if letsDoDebug then print("Resetting tree sapling data!") end end
    if( forceResetTrap ) then forceResetTrap = nil if letsDoDebug then print("Resetting trap data!") end end
    if( forcePlantSaplingPlacer ) then UpdateTreePlacer(nil,true) end

    if not playercontroller.autoequip_lastequipped then return end

    if( playercontroller.autoequip_lastequipped and GetTime() < delayUnequipASecond ) then return end
    if type(playercontroller.autoequip_lastequipped) == "string" then -- and not GetInventory(playercontroller.inst):IsFull()
        DoUnequip(playercontroller)
        playercontroller.inst.autoequip_prioNextTarget = nil
    elseif type(playercontroller.autoequip_lastequipped) == "table" then
        DoEquip(playercontroller.inst,playercontroller.autoequip_lastequipped)
        playercontroller.inst.autoequip_prioNextTarget = nil
    end
    playercontroller.autoequip_lastequipped = nil
    playercontroller.inst.autoequip_prioNextTarget = nil
    playercontroller.inst.autoequip_prioNextAct = nil
end


-- 整条线完成了修改
local originalFunctions = {}
local shouldToggleEnabled = nil
local function addPlayerController( inst )
    local controller = inst

    -- 这里应该是四个不同的功能
    originalFunctions.OnUpdate = controller.OnUpdate; -- 照明
    --originalFunctions.GetActionButtonAction = controller.GetActionButtonAction; -- 自动切换工具
    --originalFunctions.DoAction = controller.DoAction; -- 建造？
    --originalFunctions.DoAttackButton = controller.DoAttackButton; -- 攻击

    -- Ooooooo

    controller.OnUpdate = function(salf, dt)
        originalFunctions.OnUpdate(salf,dt)
        --if(shouldToggleEnabled ~= nil) then
        --    -- 记录上次用的是什么
        --    ToggleModEnabled(salf,shouldToggleEnabled);
        --    shouldToggleEnabled=nil;
        --    return;
        --end
        if(modOptions.ENABLED) then
            -- 在这里调用了
            local successflag, retvalue = pcall(OnUpdate, salf, dt)
            if not successflag then
                if letsDoDebug then print(retvalue) end
            end
        end
    end

    --controller.GetActionButtonAction = function(salf,forced)
    --    --print("Action button")
    --    local bufferedaction = originalFunctions.GetActionButtonAction(salf,forced or salf.autoequip_prioNextTarget or nil)
    --    local successflag, retvalue = pcall(GetActionButtonAction, salf, forced or salf.autoequip_prioNextTarget or nil, bufferedaction)
    --    if not successflag then
    --        if letsDoDebug then print("Ran default ABA with: ",bufferedaction) end
    --        return bufferedaction
    --    else
    --        if letsDoDebug then print("Ran custom ABA with: ",retvalue) end
    --        return retvalue
    --    end
    --end
    --
    --controller.DoAction = function(salf, bufferedaction)
    --    --print("Action")
    --    local successflag, retvalue = pcall(DoAction, salf, bufferedaction)
    --    if( successflag and retvalue ) then
    --        if letsDoDebug then print("Worked, sending:", retvalue) end
    --        if( retvalue and type(retvalue) == "string" and retvalue == "empty" ) then
    --            originalFunctions.DoAction(salf,nil)
    --        else
    --            originalFunctions.DoAction(salf,retvalue)
    --        end
    --    else
    --        if letsDoDebug then print("Failed") end
    --        originalFunctions.DoAction(salf,bufferedaction)
    --    end
    --end
    --
    --controller.DoAttackButton = function(salf)
    --    local successflag, retvalue = pcall(DoAttackButton, salf)
    --    if not successflag then
    --        if letsDoDebug then print(retvalue) end
    --    end
    --    originalFunctions.DoAttackButton(salf)
    --end
end

AddClassPostConstruct("components/playercontroller", addPlayerController)