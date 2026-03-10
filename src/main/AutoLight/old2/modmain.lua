---
--- AutoLight 客户端Mod - 正确版本
--- 基于原版逻辑,立即响应,不延迟
---

local GLOBAL = GLOBAL
local GetTime = GLOBAL.GetTime
local pcall = GLOBAL.pcall

-- ============================================================
-- Mod配置
-- ============================================================
local modConfig = {
    enabled = true,
    createLightInDark = GetModConfigData("ae_lightindark") > 1,
    equipLightInDark = GetModConfigData("ae_lightindark") > 0,
    switchDelayTime = GetModConfigData("ae_switch_delay_time"),
    makeDelayTime = GetModConfigData("ae_make_delay_time"),
    noNightPutDownTime = GetModConfigData("ae_no_night_put_down_light_time"),
    encounteringLightTime = GetModConfigData("ae_encountering_light_time"),
    luminousIllumination = GetModConfigData("ae_luminous_illumination"),
}

-- ============================================================
-- 常量
-- ============================================================
local LIGHT_THRESHOLDS = {
    DARKNESS = 0.20,      -- 黑暗阈值(需要照明)
    BRIGHT = 0.30,        -- 明亮阈值(可以卸下)
    FUEL_LOW = 0.05,      -- 燃料低
}

local TORCH_CRAFT_COOLDOWN = 3

-- ============================================================
-- 工具函数
-- ============================================================
local function ShowTips(title, content)
    GLOBAL.ChatHistory:AddToHistory(
            GLOBAL.ChatTypes.Message, nil, nil,
            title, content, GLOBAL.PLAYERCOLOURS.CORAL
    )
end

local function IsLightingTool(item)
    if not item then return false end
    return item:HasTag("lighter") or item:HasTag("light")
end

local function IsMoving()
    return GLOBAL.TheSim:GetDigitalControl(GLOBAL.CONTROL_MOVE_LEFT) or
            GLOBAL.TheSim:GetDigitalControl(GLOBAL.CONTROL_MOVE_RIGHT) or
            GLOBAL.TheSim:GetDigitalControl(GLOBAL.CONTROL_MOVE_DOWN) or
            GLOBAL.TheSim:GetDigitalControl(GLOBAL.CONTROL_MOVE_UP)
end

local function HasShineOutfit(inst)
    local headItem = inst.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HEAD)
    return headItem and headItem.prefab == "molehat"
end

local function GetHandItem(inst)
    return inst.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
end

-- ============================================================
-- 玩家状态管理
-- ============================================================
local function InitPlayerState(inst)
    if not inst.autolight_state then
        inst.autolight_state = {
            checkTimer = 0,
            promptTask = nil,
            justMadeTorch = false,
            lastMakeTorchTime = 0,
            isMakingTorch = false,
            lastHandItem = nil,
            modJustEquipped = false,
        }
    end
    return inst.autolight_state
end

local function CancelTask(state, taskName)
    if state[taskName] then
        state[taskName]:Cancel()
        state[taskName] = nil
    end
end

-- ============================================================
-- 查找最佳光源
-- ============================================================
local function FindBestLightSource(inst)
    local inventory = inst.replica.inventory
    if not inventory then return nil end

    local bestLight = nil
    local bestPriority = 0

    local function checkItem(item)
        if not item or not IsLightingTool(item) then return end

        local priority = 0
        local hasFuel = true

        if item.replica.inventoryitem and item.replica.inventoryitem.classified then
            local fuelPercent = item.replica.inventoryitem.classified.percentused:value()
            hasFuel = fuelPercent > LIGHT_THRESHOLDS.FUEL_LOW
        end

        if item:HasTag("light") and not item:HasTag("lightbattery") then
            priority = hasFuel and 3 or 1
        elseif item:HasTag("lighter") then
            priority = 2
        end

        if priority > bestPriority then
            bestPriority = priority
            bestLight = item
        end
    end

    checkItem(GetHandItem(inst))

    local items = inventory:GetItems()
    if items then
        for _, item in pairs(items) do
            checkItem(item)
            if bestPriority >= 3 then break end
        end
    end

    if bestPriority < 3 and inventory.GetOverflowContainer then
        local overflow = inventory:GetOverflowContainer()
        if overflow and overflow.GetItems then
            local overflowItems = overflow:GetItems()
            if overflowItems then
                for _, item in pairs(overflowItems) do
                    checkItem(item)
                    if bestPriority >= 3 then break end
                end
            end
        end
    end

    return bestLight
end

-- ============================================================
-- 装备/卸下 (使用RPC)
-- ============================================================
local function EquipLight(inst, state, lightItem)
    if not lightItem then return end

    local handItem = GetHandItem(inst)
    if handItem and IsLightingTool(handItem) then
        return
    end

    state.modJustEquipped = true
    GLOBAL.SendRPCToServer(GLOBAL.RPC.EquipActionItem, lightItem)
end

local function UnequipLight(inst)
    local handItem = GetHandItem(inst)

    --if not handItem or not IsLightingTool(handItem) then
    --    return
    --end
    --
    --if handItem.prefab == "lighter" then
    --    return
    --end

    --GLOBAL.SendRPCToServer(GLOBAL.RPC.EquipActionItem, handItem)
    inst.replica.inventory:UseItemFromInvTile(handItem)
end

-- ============================================================
-- 制作火把
-- ============================================================
local function MakeTorch(inst, state)
    local currentTime = GetTime()

    if currentTime - state.lastMakeTorchTime < TORCH_CRAFT_COOLDOWN then
        return false
    end

    if state.isMakingTorch then
        return false
    end

    local builder = inst.replica.builder
    if not builder or not builder:CanBuild("torch") then
        return false
    end

    state.isMakingTorch = true
    state.lastMakeTorchTime = currentTime

    builder:MakeRecipeFromMenu(GLOBAL.AllRecipes["torch"])
    state.justMadeTorch = true

    GLOBAL.TheWorld:DoTaskInTime(0.5, function()
        state.isMakingTorch = false
    end)

    return true
end

local function HandleTorchProduction(inst, state)
    if not modConfig.createLightInDark then return end

    if IsMoving() then
        if not state.promptTask then
            state.promptTask = GLOBAL.TheWorld:DoTaskInTime(modConfig.makeDelayTime, function()
                ShowTips("警告：你处于黑暗", "快停下脚步，我在为你制作火炬！")
                state.promptTask = nil
            end)
        end
    else
        MakeTorch(inst, state)
    end
end

-- ============================================================
-- 检查低燃料
-- ============================================================
local function CheckLowFuelLight(inst)
    local handItem = GetHandItem(inst)

    if not handItem or not handItem:HasTag("light") then
        return
    end

    if handItem.replica.inventoryitem and handItem.replica.inventoryitem.classified then
        local fuelPercent = handItem.replica.inventoryitem.classified.percentused:value()

        if fuelPercent <= LIGHT_THRESHOLDS.FUEL_LOW then
            UnequipLight(inst)
        end
    end
end

-- ============================================================
-- 检测系统自动装备(白天烧树)
-- ============================================================
local function DetectTemporaryEquip(inst, state)
    GLOBAL.TheWorld:DoTaskInTime(1, function()
        local currentHandItem = GetHandItem(inst)

        if currentHandItem ~= state.lastHandItem then
            local wasLighting = state.lastHandItem and IsLightingTool(state.lastHandItem)
            local isLighting = currentHandItem and IsLightingTool(currentHandItem)

            -- 从非照明 → 照明
            if not wasLighting and isLighting then
                -- 不是mod装备的 = 系统或玩家装备的
                if not state.modJustEquipped then
                    -- 白天或满月
                    local isDaytime = not GLOBAL.TheWorld.state.isnight or GLOBAL.TheWorld.state.isfullmoon

                    if isDaytime then
                        -- 检测是否在移动(烧树场景)
                        if not IsMoving() then
                            -- 没在移动,可能是手动装备,立即卸下
                            UnequipLight(inst)
                        end
                        -- 如果在移动,不管(烧树场景,让玩家去点)
                    end
                end

                state.modJustEquipped = false
            end

            state.lastHandItem = currentHandItem
        end
    end)
end

-- ============================================================
-- 主检查逻辑
-- ============================================================
local function CheckLighting(inst, state)
    if not modConfig.enabled or not modConfig.equipLightInDark then
        return
    end

    if not inst.LightWatcher then return end

    -- 1. 检查低燃料
    CheckLowFuelLight(inst)

    -- 2. 检测白天临时装备
    DetectTemporaryEquip(inst, state)

    -- 3. 获取环境信息
    local isNight = GLOBAL.TheWorld.state.isnight and not GLOBAL.TheWorld.state.isfullmoon
    local hasShine = HasShineOutfit(inst)
    local lightValue = inst.LightWatcher:GetLightValue()
    local lightAngle = inst.LightWatcher:GetLightAngle()
    local handItem = GetHandItem(inst)

    -- 4. 夜晚逻辑
    if isNight and not hasShine then
        -- 黑暗中 → 立即装备灯
        if lightValue <= LIGHT_THRESHOLDS.DARKNESS then
            local bestLight = FindBestLightSource(inst)

            if bestLight then
                EquipLight(inst, state, bestLight)
            else
                HandleTorchProduction(inst, state)
            end

            -- 明亮处 → 立即卸下灯
        elseif lightAngle and lightAngle ~= 0 and lightValue > LIGHT_THRESHOLDS.BRIGHT then
            if handItem and IsLightingTool(handItem) then
                UnequipLight(inst)
            end
        end

        -- 5. 白天/满月 → 卸下光源
    elseif not isNight or GLOBAL.TheWorld.state.isfullmoon then
        if handItem and IsLightingTool(handItem) then
            UnequipLight(inst)
        end
    end
end

-- ============================================================
-- 主更新函数
-- ============================================================
local function OnUpdate(playercontroller, dt)
    local inst = playercontroller.inst
    if not inst then return end

    local state = InitPlayerState(inst)

    -- 每0.5秒检查一次
    state.checkTimer = state.checkTimer + dt
    if state.checkTimer < 0.5 then
        return
    end
    state.checkTimer = 0

    local success, err = pcall(CheckLighting, inst, state)
    if not success then
        print("[AutoLight] Error:", err)
    end
end

-- ============================================================
-- Hook PlayerController
-- ============================================================
local originalOnUpdate = nil

AddClassPostConstruct("components/playercontroller", function(self)
    originalOnUpdate = self.OnUpdate

    self.OnUpdate = function(inst, dt)
        if originalOnUpdate then
            originalOnUpdate(inst, dt)
        end

        if not inst.inst then return end

        local success, err = pcall(OnUpdate, inst, dt)
        if not success then
            print("[AutoLight] OnUpdate Error:", err)
        end
    end
end)

print("[AutoLight] 客户端Mod已加载 - 立即响应版本")