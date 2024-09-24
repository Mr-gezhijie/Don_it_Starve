---
--- Created by GEZHIJIE.
--- DateTime: 2024/9/21 23:20
---

local GLOBAL = GLOBAL;
local pcall = GLOBAL.pcall
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local TheInput = GLOBAL.TheInput
local AllRecipes = GLOBAL.AllRecipes
local GetTime = GLOBAL.GetTime

local delayUnequipASecond = 0
local hasEquipped = false;
local letsDoDebug = true
local forceResetTrap
local forcePlantSapling
local forcePlantSaplingPlacer

--  mod配置
local modOptions = {
    --ENABLED = GetModConfigData("ae_enablemod") > 0,
    ENABLED = true,

    -- 制作
    CREATE_LIGHT_IN_DARK = GetModConfigData("ae_lightindark") > 1,
    -- 装备
    EQUIP_LIGHT_IN_DARK = GetModConfigData("ae_lightindark") > 0,

    -- 切换光具延迟时间
    SWITCH_DELAY_TIME = GetModConfigData("ae_switch_delay_time"),
    -- 制作火把延迟时间
    MAKE_DELAY_TIME = GetModConfigData("ae_make_delay_time"),

};


-- 有一个按键控制到时候注意一下
-- 自定义键位
local KEYBOARDTOGGLEKEY = GetModConfigData("autoequipopeningamesettings") or "L"
if type(KEYBOARDTOGGLEKEY) == "string" then
    KEYBOARDTOGGLEKEY = KEYBOARDTOGGLEKEY:lower():byte()
end

-- 不知道干嘛的
local TARGET_EXCLUDE_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }
local PICKUP_TARGET_EXCLUDE_TAGS = { "catchable" }
local HAUNT_TARGET_EXCLUDE_TAGS = { "haunted", "catchable" }
for i, v in ipairs(TARGET_EXCLUDE_TAGS) do
    table.insert(PICKUP_TARGET_EXCLUDE_TAGS, v)
    table.insert(HAUNT_TARGET_EXCLUDE_TAGS, v)
end


-- 用于装备工具或者武器的（配置inst物品）
local function DoEquip(inst, tool)
    if (inst == nil or inst.components == nil or inst.components.playercontroller == nil or tool == nil) then
        return
    end

    local plcotrl = inst.components.playercontroller
    if (plcotrl and plcotrl.inst and plcotrl.inst.replica and plcotrl.inst.replica.inventory) then
        if letsDoDebug then
            print("-装备工具/武器:", tool)
        end
        -- 防止过快切换装备
        --delayUnequipASecond = GetTime() + 0.20
        --delayUnequipASecond = GetTime() + 0.20
        hasEquipped = true;

        inst.replica.inventory:UseItemFromInvTile(tool)
    else
        if letsDoDebug then
            print("试图装备，但失败了。")
        end
    end
end


-- 查看库存用途
local function GetInventory(inst)
    return (inst.components and inst.components.playercontroller and inst.components.inventory) or (inst.replica and inst.replica.inventory)
end


-- 查找符合的物品
local function CustomFindItem(inst, inv, check)
    local items = inv and inv.GetItems and inv:GetItems() or inv.itemslots or nil
    if not inst or not inv or not check or not items then
        if letsDoDebug then
            print("库存出了点问题。。。")
        end
        return nil
    end

    local zeItem = nil
    local zeIndex = nil

    for k, v in pairs(items) do
        if check(v) then
            zeItem = v
            zeIndex = k
        end
    end

    if inv.GetOverflowContainer and inv:GetOverflowContainer() ~= nil then
        items = inv:GetOverflowContainer() and inv:GetOverflowContainer().GetItems and inv:GetOverflowContainer():GetItems() or inv:GetOverflowContainer().slots or nil
        if items then
            for k, v in pairs(items) do
                if check(v) then
                    zeItem = v
                    zeIndex = k
                end
            end
        end
    end

    if (inst.replica and inst.replica.inventory and inst.replica.inventory.GetEquippedItem and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) and check(inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS))) then
        zeItem = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    end

    if (zeItem ~= nil) then
        zeItem.lastslot = zeIndex
    end
    return zeItem
end

-- 获取装备物品
local function GetEquippedItem(inst, position)
    if inst and inst.replica and inst.replica.inventory then
        return inst.replica.inventory:GetEquippedItem(position)
    end
    return nil
end

-- 用于卸下工具或者武器的
local function DoUnequip(inst, force)
    if (inst and inst.replica and inst.replica.inventory) then

        hasEquipped = false;
        hasEquippedType = "";
        if inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
            inst.replica.inventory:UseItemFromInvTile(inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS))
        end
    end
end

-- 查询照明装备
local tookLightOut = nil
local firstCheckedForDarkness = nil
local isJustMakeTorch = true

local function CheckIfInDarkness(inst)
    --if (not firstCheckedForDarkness) then
    if letsDoDebug then
        --print("哦，天黑了")
    end
    if not firstCheckedForDarkness then
        firstCheckedForDarkness = GetTime()
    end
    --elseif (firstCheckedForDarkness and GetTime() > (firstCheckedForDarkness + modOptions.DELAY_TIME)) then
    --elseif (firstCheckedForDarkness and GetTime() > (firstCheckedForDarkness + modOptions.DELAY_TIME)) then
    if letsDoDebug then
        --print("就是这样，我在装备光！")
    end
    --firstCheckedForDarkness = nil



    -- 先查找是否有提灯
    local possibleLights = CustomFindItem(inst, GetInventory(inst), function(item)
        return item:HasTag("light") and not item:HasTag("lightbattery")
    end)
    -- 判断是否有提灯，没有提灯或者燃料，就会查找火把
    if (possibleLights == nil or possibleLights.replica.inventoryitem.classified.percentused:value() < 1) then
        possibleLights = CustomFindItem(inst, GetInventory(inst), function(item)
            return item:HasTag("lighter")
        end)
    end

    -- 如果为空，就是什么也没有找到
    if (possibleLights) then
        if possibleLights then
            --if letsDoDebug then
            --    print("已经配备了光源！")
            --end

            if letsDoDebug then
                print("XXXXX！" .. tostring(isJustMakeTorch) .. "现在时间" .. GLOBAL.GetTime() .. "延迟时间" .. (firstCheckedForDarkness + modOptions.SWITCH_DELAY_TIME))
            end
            --if letsDoDebug then
            --    print("AAAAAA！" .. tostring(isJustMakeTorch or (firstCheckedForDarkness and GetTime() > (firstCheckedForDarkness + modOptions.SWITCH_DELAY_TIME))))
            --end

            -- 冷却时间
            -- 如何是刚制作的火把，就不用冷却了，立马装备
            --if (isJustMakeTorch or (firstCheckedForDarkness and GetTime() > (firstCheckedForDarkness + modOptions.SWITCH_DELAY_TIME))) then
            if  (firstCheckedForDarkness and GLOBAL.GetTime() > (firstCheckedForDarkness + modOptions.SWITCH_DELAY_TIME)) then
                if letsDoDebug then
                    print("正在切换中！")
                end




                if GetEquippedItem(inst, EQUIPSLOTS.HANDS)  then
                    -- 先卸掉旧的
                    if  (not GetEquippedItem(inst, EQUIPSLOTS.HANDS):HasTag("light") and not GetEquippedItem(inst, EQUIPSLOTS.HANDS):HasTag("lighter")) then

                        --把手上的物品放到装备栏
                        DoUnequip(inst)
                    else
                        firstCheckedForDarkness = nil
                        return
                    end
                    -- 装备工具
                    DoEquip(inst, possibleLights)
                    tookLightOut = true;
                    firstCheckedForDarkness = nil
                    --isJustMakeTorch = false
                else
                    -- 装备工具
                    DoEquip(inst, possibleLights)
                    tookLightOut = true;
                    firstCheckedForDarkness = nil
                    --isJustMakeTorch = false
                end




            end

        else
            if letsDoDebug then
                print("没有找到灯！出了点问题。。。")
            end
        end
    else
        if (modOptions.CREATE_LIGHT_IN_DARK) then
            if letsDoDebug then
                print("没有找到灯，但正在尝试制作灯。")
            end
            --if isJustMakeTorch then
            --    return
            --end

            if (firstCheckedForDarkness and GLOBAL.GetTime() > (firstCheckedForDarkness + modOptions.MAKE_DELAY_TIME)) then
                -- 制作火把
                if (inst.replica and inst.replica.builder and inst.replica.builder.CanBuild and inst.replica.builder.MakeRecipeFromMenu and inst.replica.builder:CanBuild("torch")) then

                    if GetEquippedItem(inst, EQUIPSLOTS.HANDS)  then
                        -- 先卸掉旧的
                        if  (not GetEquippedItem(inst, EQUIPSLOTS.HANDS):HasTag("light") and not GetEquippedItem(inst, EQUIPSLOTS.HANDS):HasTag("lighter")) then
                            --把手上的物品放到装备栏
                            DoUnequip(inst)
                        else
                            firstCheckedForDarkness = nil
                            return
                        end
                    end

                    GLOBAL.TheWorld:DoTaskInTime(1.50, function()
                        print("延迟0.25秒后执行的代码")
                        isJustMakeTorch = true
                    end)

                    if isJustMakeTorch then
                        isJustMakeTorch = false
                        inst.replica.builder:MakeRecipeFromMenu(AllRecipes["torch"])
                        tookLightOut = true;
                    end



                end
                firstCheckedForDarkness = nil
            end
        else
            if letsDoDebug then
                print("没有找到灯。")
            end
        end
    end
    --if letsDoDebug then
    --    print("出去了。。。。")
    --end
    --end
end



-- 检查是否走出黑暗
local function CheckIfOutOfDarkness(inst)
    if (tookLightOut == nil) then
        return
    end

    local tool = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS);
    if (tool ~= nil) then
        if (tool:HasTag("lighter") or tool:HasTag("light")) then
            -- 卸下？
            inst.replica.inventory:UseItemFromInvTile(inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS))
            tookLightOut = nil;
        end
    end
end

local function IMS(plyctrl)
    return plyctrl.ismastersim
end

-- ------ -----
-- 获取玩家的位置
--local player_pos
--
---- 获取环境中的光照强度，排除火炬的光照
--local function get_environment_light_level(x,y,z, radius)
--    print("阐述1 ："..tostring(x,y,z))
--    local light_level = 0
--    local entities = GLOBAL.TheWorld:FindEntities(x,y,z, radius, {"lighter"})
--    print("阐述2 ："..tostring(entities))
--
--    local center_pos= GLOBAL.ThePlayer:GetPosition()
--
--    for i, entity in ipairs(entities) do
--        if entity.prefab ~= "torch" then
--            local light = entity.components.lighter
--            if light then
--                light_level = light_level + light:CalculateLightForPoint(center_pos)
--            end
--        end
--    end
--    return light_level
--end
--
--local function check_light_level()
--    local x, y ,z =  GLOBAL.ThePlayer:GetPosition()
--    local light_level = get_environment_light_level(x,y,z, 15)
--    local MIN_LIGHT_LEVEL = 14 -- 假设最小光照阈值为14
--    if light_level < MIN_LIGHT_LEVEL then
--        print("环境光照不足")
--    else
--        print("环境光照充足")
--    end
--end


-- --------- -------

local playercontroller333
-- 照明装备「处理动作」【开关】
local function OnUpdate(playercontroller, dt)

    -- 不知道是什么，反正开了他，Y键就不执行了
    --if not playercontroller:IsEnabled() then
    --    return
    --end

    -- 是发光衣服
    local isShineOutfit = false
    -- 使用示例，获取玩家头上的装备物品
    local equipped_hat = GetEquippedItem(playercontroller.inst, EQUIPSLOTS.HEAD)
    if equipped_hat and tostring(equipped_hat.prefab) == "molehat" then
        isShineOutfit = true
    end

    if letsDoDebug then
        --if playercontroller.inst.LightWatcher:GetLightAngle() then
        --    print("角度：" .. tostring(playercontroller.inst.LightWatcher:GetLightAngle()))
        --end
        --if playercontroller.inst.LightWatcher:GetLightValue() then
        --    print("光照值" .. tostring(playercontroller.inst.LightWatcher:GetLightValue()))
        --end

        --if playercontroller.inst.LightWatcher:GetTimeInDark() then
        --    print("黑暗时长" .. tostring(playercontroller.inst.LightWatcher:GetTimeInDark()))
        --end
        --if playercontroller.inst.LightWatcher:GetTimeInLight() then
        --    print("光照时长：" .. tostring(playercontroller.inst.LightWatcher:GetTimeInLight()))
        --end
        --if playercontroller.inst.LightWatcher:IsInLight() then
        --    print("是否有光----：" .. tostring(playercontroller.inst.LightWatcher:IsInLight()))
        --end
    end


    -- 查看定义的判断什么时候开灯
    if modOptions.EQUIP_LIGHT_IN_DARK then
        if not isShineOutfit
                and GLOBAL.TheWorld.state.isnight
                and not GLOBAL.TheWorld.state.isfullmoon
                and playercontroller.inst.LightWatcher
                and playercontroller.inst.LightWatcher:GetLightValue() <= 0.15 then
            -- 判定处于没有照明状态
            CheckIfInDarkness(playercontroller.inst)
        elseif (GLOBAL.TheWorld.state.isnight and not GLOBAL.TheWorld.state.isfullmoon) then
            -- 人物携带灯都是0.73
            if playercontroller.inst.LightWatcher:GetLightAngle()
                    and playercontroller.inst.LightWatcher:GetLightAngle() ~= 0
                    and playercontroller.inst.LightWatcher:GetLightValue() > 0.88
                    --and playercontroller.inst.LightWatcher:GetLightValue() < 1
                    and GetEquippedItem(playercontroller.inst, EQUIPSLOTS.HANDS)
                    and ( GetEquippedItem(playercontroller.inst, EQUIPSLOTS.HANDS):HasTag("light") or GetEquippedItem(playercontroller.inst, EQUIPSLOTS.HANDS):HasTag("lighter")) then


                DoUnequip(playercontroller.inst)
                --isJustMakeTorch = false
                --TheSim:DoTaskInTime(0.20, function()
                --    print("延迟1秒后执行的代码")
                --    -- 在这里添加你想要延迟执行的代码
                --end)
                firstCheckedForDarkness = GLOBAL.GetTime()
            end

            --if letsDoDebug then
            --    print("走了吗？？？")
            --end


        elseif (not GLOBAL.TheWorld.state.isnight and tookLightOut ~= nil) then
            if letsDoDebug then
                print("走了吗22222？？？")
            end
            -- 检测是否走出黑暗
            CheckIfOutOfDarkness(playercontroller.inst)
            firstCheckedForDarkness = null
        end
    end

    -- 不知道什么东西
    if ((IMS(playercontroller) and not playercontroller.inst.sg:HasStateTag("idle")) or (not IMS(playercontroller) and not playercontroller.inst:HasTag("idle"))) then
        return
    end
    if TheInput:IsControlPressed(GLOBAL.CONTROL_PRIMARY) then
        return
    end
    if TheInput:IsControlPressed(GLOBAL.CONTROL_SECONDARY) then
        return
    end
    if TheInput:IsControlPressed(GLOBAL.CONTROL_ACTION) then
        return
    end
    if TheInput:IsControlPressed(GLOBAL.CONTROL_ATTACK) then
        return
    end
    if ((IMS(playercontroller) and playercontroller.inst.sg:HasStateTag("working")) or (not IMS(playercontroller) and playercontroller.inst:HasTag("working"))) then
        return
    end
    if ((IMS(playercontroller) and playercontroller.inst.sg:HasStateTag("doing")) or (not IMS(playercontroller) and playercontroller.inst:HasTag("doing"))) then
        return
    end
    if ((IMS(playercontroller) and playercontroller.inst.sg:HasStateTag("attack")) or (not IMS(playercontroller) and playercontroller.inst:HasTag("attack"))) then
        return
    end
    if playercontroller.inst.replica.combat.target ~= nil then
        return
    end

    if not playercontroller.autoequip_lastequipped then
        return
    end

    if (playercontroller.autoequip_lastequipped and GLOBAL.GetTime() < delayUnequipASecond) then
        return
    end

    -- 想处理上次的装备，但是没生效
    if letsDoDebug then
        print("这个是什么「autoequip_lastequipped」" .. tostring(playercontroller.autoequip_lastequipped))
        print("这个是什么「autoequip_prioNextTarget」" .. tostring(playercontroller.inst.autoequip_prioNextTarget))
    end

    if type(playercontroller.autoequip_lastequipped) == "string" then
        -- 卸下工具
        DoUnequip(playercontroller.inst)
        playercontroller.inst.autoequip_prioNextTarget = nil
    elseif type(playercontroller.autoequip_lastequipped) == "table" then
        --装备工具
        DoEquip(playercontroller.inst, playercontroller.autoequip_lastequipped)
        playercontroller.inst.autoequip_prioNextTarget = nil
    end


end


-- 主程序
local originalFunctions = {}
local function addPlayerController(inst)
    local controller = inst

    originalFunctions.OnUpdate = controller.OnUpdate; -- 照明
    controller.OnUpdate = function(salf, dt)
        originalFunctions.OnUpdate(salf, dt)
        if (modOptions.ENABLED) then
            -- 调用自动照明
            local successflag, retvalue = pcall(OnUpdate, salf, dt)
            if not successflag then
                if letsDoDebug then
                    print(retvalue)
                end
            end
        end
    end
end

AddClassPostConstruct("components/playercontroller", addPlayerController)
