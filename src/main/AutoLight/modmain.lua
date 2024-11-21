---
--- Created by GEZHIJIE.
--- DateTime: 2024/9/21 23:20
---

local GLOBAL = GLOBAL;
local pcall = GLOBAL.pcall

local RPC = GLOBAL.RPC
local ACTIONS = GLOBAL.ACTIONS
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local SendRPCToServer = GLOBAL.SendRPCToServer
local TheInput = GLOBAL.TheInput
local AllRecipes = GLOBAL.AllRecipes
local GetTime = GLOBAL.GetTime

local delayUnequipASecond = 0
local hasEquipped = false;
local letsDoDebug = true


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
    -- 不是夜晚几秒放下照明
    NO_NIGHT_PUT_DOWN_LIGHT_TIME = GetModConfigData("ae_no_night_put_down_light_time"),
    -- 遇到光延时几秒
    ENCOUNTERING_LIGHT_TIME = GetModConfigData("ae_encountering_light_time"),
    -- 是否刚出光就照明
    LUMINOUS_ILLUMINATION = GetModConfigData("ae_luminous_illumination"),


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


-- 检查参数用的，就这样吧，不改了
local function GetInventory(inst)
    return (inst.components and inst.components.playercontroller and inst.components.inventory) or (inst.replica and inst.replica.inventory)
end

-- 会话
local function TIPS(title, content)
    GLOBAL.ChatHistory:AddToHistory(GLOBAL.ChatTypes.Message, nil, nil,
            title,
            content, GLOBAL.PLAYERCOLOURS.CORAL)
end

-- 判断是否移动
local function  IsMover()
    return GLOBAL.TheSim:GetDigitalControl(GLOBAL.CONTROL_MOVE_LEFT) or
            GLOBAL.TheSim:GetDigitalControl(GLOBAL.CONTROL_MOVE_RIGHT) or
            GLOBAL.TheSim:GetDigitalControl(GLOBAL.CONTROL_MOVE_DOWN) or
            GLOBAL.TheSim:GetDigitalControl(GLOBAL.CONTROL_MOVE_UP)
end

-- 判断是否照具
local function IsCheckIfLighting(tool)
    if (tool:HasTag("lighter")
            or tool:HasTag("light")) then
        return true
    else
        return false
    end
end

-- 获取，指定位置物品，inst是玩家，position是部位
local function GetEquippedItem(inst, position)
    if inst and inst.replica and inst.replica.inventory then
        return inst.replica.inventory:GetEquippedItem(position)
    end
    return nil
end

-- 把物品装备到手上
local function DoEquip(inst, tool)
    if (inst == nil or inst.components == nil or inst.components.playercontroller == nil or tool == nil) then
        return
    end
    local plcotrl = inst.components.playercontroller
    if (plcotrl and plcotrl.inst and plcotrl.inst.replica and plcotrl.inst.replica.inventory) then
        hasEquipped = true;
        inst.replica.inventory:UseItemFromInvTile(tool)
    end
end

-- 用于卸下工具或者武器的
local function DoUnequip(inst)
    if (inst and inst.replica and inst.replica.inventory) then
        hasEquipped = false;
        local handEquipment =  GetEquippedItem(inst,EQUIPSLOTS.HANDS)
        --// 判断手中的东西，如果是火女的武器，就不卸下
        if handEquipment and IsCheckIfLighting(handEquipment) and handEquipment.prefab ~= "lighter" then
            inst.replica.inventory:UseItemFromInvTile(handEquipment)
        end
    end
end

local function IMS(plyctrl)
    return plyctrl.ismastersim
end


-- --------------------------------------------------------------
-- --------------------------------------------------------------
-- 查找符合的物品
local function CustomFindItem(inst, inv, check)
    local items = inv and inv.GetItems and inv:GetItems() or inv.itemslots or nil
    if not inst or not inv or not check or not items then
        if letsDoDebug then
            --print("库存出了点问题。。。")
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


-- --------------------------------------------------------------
-- --------------------------------------------------------------
-- 是否不会发光，但是不会攻击的衣服
local function IsShineOutfit(inst)
    -- 是发光衣服
    local isShineOutfit = false
    -- 使用示例，获取玩家头上的装备物品
    local equipped_hat = GetEquippedItem(inst, EQUIPSLOTS.HEAD)
    if equipped_hat and tostring(equipped_hat.prefab) == "molehat" then
        isShineOutfit = true
    end
    return isShineOutfit
end


-- --------------------------------------------------------------
-- 延迟
local isJustMakeTorch = false
local isCutLightDelay = true
local isProductionPromptDelay = true

-- 该切换装备了
local function CutLight(inst,tool)
    local handEquipment =  GetEquippedItem(inst,EQUIPSLOTS.HANDS)
    if handEquipment  then
        -- 先卸掉旧的
        if not IsCheckIfLighting(handEquipment) then
            --把手上的物品放到装备栏
            DoUnequip(inst)
        else
            return
        end
        -- 装备工具
        DoEquip(inst, tool)
    else
        -- 装备工具
        DoEquip(inst, tool)
    end
end
local function CutLightDelay(inst,tool)
    if isCutLightDelay then
        isCutLightDelay = false
        --print("开始了延迟")
        GLOBAL.TheWorld:DoTaskInTime(modOptions.SWITCH_DELAY_TIME, function()
            if not IsShineOutfit(inst)
                    and GLOBAL.TheWorld.state.isnight
                    and not GLOBAL.TheWorld.state.isfullmoon
                    and inst.LightWatcher
                    and inst.LightWatcher:GetLightValue() <= 0.20 then
                CutLight(inst,tool)
            end
            isCutLightDelay = true
            --print("延迟结束了")
        end)
    end
    if isJustMakeTorch then
        CutLight(inst,tool)
        isJustMakeTorch = false
    end
end

--  ----------------------------------------------------
-- 该制作火炬了
local function Production(inst)
    -- 制作火把
    if (inst.replica and inst.replica.builder and inst.replica.builder.CanBuild and inst.replica.builder.MakeRecipeFromMenu and inst.replica.builder:CanBuild("torch")) then
        inst.replica.builder:MakeRecipeFromMenu(AllRecipes["torch"])
        isJustMakeTorch = true
    end
end
local function ProductionHandle(inst)
    -- 判断是否正在移动
    --print("是否在移动"..tostring(IsMover()))
    if IsMover() then
        -- 提示延迟一秒
        if isProductionPromptDelay then
            isProductionPromptDelay = false
            GLOBAL.TheWorld:DoTaskInTime(modOptions.MAKE_DELAY_TIME, function()
                TIPS("警告：你处于黑暗","快停下脚步，我在为你制作火炬！！！")
                --GLOBAL.ChatHistory:SendCommandResponse("警告：你处于黑暗快停下脚步，我在为你制作火炬！！！")
                isProductionPromptDelay = true
            end)
        end
    else
        --print("正在制作火炬")
        Production(inst)
    end

end




-- --------------------------------------------------------------
-- --------------------------------------------------------------
-- 查询照明装备
local function CheckIfInDarkness(inst)

    -- 提灯没燃料了，立马卸下
    local handEquipment =  GetEquippedItem(inst,EQUIPSLOTS.HANDS)
    if  handEquipment and handEquipment:HasTag("light") and handEquipment.replica.inventoryitem.classified.percentused:value() < 1 then
        if (inst and inst.replica and inst.replica.inventory) then
                inst.replica.inventory:UseItemFromInvTile(handEquipment)
        end
    end

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
            if inst.LightWatcher:GetLightValue() <= 0.15 then
                if  modOptions.LUMINOUS_ILLUMINATION and  inst.LightWatcher:GetLightAngle() and inst.LightWatcher:GetLightAngle() ~= 0 then
                    CutLight(inst,possibleLights)
                    return
                end
                -- 切换装备
                CutLightDelay(inst,possibleLights)
            end
        end
    else
        if (modOptions.CREATE_LIGHT_IN_DARK) then
            -- 制作火炬
            ProductionHandle(inst)

        end
    end
end


-- --------------------------------------------------------------
-- --------------------------------------------------------------
-- 照明装备「处理动作」【开关】
local noNightPutDownLightTimeDelay = true
local encounteringLightTimeDelay =true
local function OnUpdate(playercontroller, dt)

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

    local handEquipment =  GetEquippedItem(playercontroller.inst,EQUIPSLOTS.HANDS)

    -- 查看定义的判断什么时候开灯
    if modOptions.EQUIP_LIGHT_IN_DARK then
        if not IsShineOutfit(playercontroller.inst)
                and GLOBAL.TheWorld.state.isnight
                and not GLOBAL.TheWorld.state.isfullmoon
                and playercontroller.inst.LightWatcher
                and playercontroller.inst.LightWatcher:GetLightValue() <= 0.20 then
            -- 判定处于没有照明状态
            --print("没有光照，要照明了---")
            CheckIfInDarkness(playercontroller.inst)
            -- 是天黑，并且附近有光，卸下
        elseif (GLOBAL.TheWorld.state.isnight and not GLOBAL.TheWorld.state.isfullmoon) then
            -- 人物携带灯都是0.73
            if playercontroller.inst.LightWatcher:GetLightAngle()
                    and playercontroller.inst.LightWatcher:GetLightAngle() ~= 0
                    and playercontroller.inst.LightWatcher:GetLightValue() > 0.88
                    and handEquipment
                    and IsCheckIfLighting(handEquipment) then
                --print("走卸下---")
                -- 拒绝小范围光明卡脚，例如萤火虫，蘑菇树
                if encounteringLightTimeDelay then
                    encounteringLightTimeDelay = false
                    GLOBAL.TheWorld:DoTaskInTime(modOptions.ENCOUNTERING_LIGHT_TIME, function()
                        if playercontroller.inst.LightWatcher:GetLightAngle()
                                and playercontroller.inst.LightWatcher:GetLightAngle() ~= 0
                                and playercontroller.inst.LightWatcher:GetLightValue() > 0.88
                                and handEquipment
                                and IsCheckIfLighting(handEquipment) then
                            DoUnequip(playercontroller.inst)
                        end
                        encounteringLightTimeDelay = true
                    end)
                end
            end
        elseif (not GLOBAL.TheWorld.state.isnight) or GLOBAL.TheWorld.state.isfullmoon then
            -- 不是夜晚，走到操作
            if noNightPutDownLightTimeDelay then
                noNightPutDownLightTimeDelay = false
                GLOBAL.TheWorld:DoTaskInTime(modOptions.NO_NIGHT_PUT_DOWN_LIGHT_TIME, function()
                    DoUnequip(playercontroller.inst)
                    noNightPutDownLightTimeDelay = true
                end)
            end

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
end

-- --------------------------------------------------------------
-- --------------------------------------------------------------
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
