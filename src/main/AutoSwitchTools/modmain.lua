--设置为全局环境 就不用一个个GLOBAL的写
GLOBAL.setmetatable(env, {
    __index = function(t, k)
        return GLOBAL.rawget(GLOBAL, k)
    end
})
local INV_util = {}
local PLAYER_util = {}
local ENT_util = {}
local POS_util = {}
local EQUIP_util = {}
local EquipSlot = require("equipslotutil")
local GAME_util = {}
local MOD_util = {}
local status, settingscreen = pcall(require, "screens/settingsscreen")
--获取设置
function MOD_util:GetMOption(key, default)
    if rawget(_G, "m_options") and m_options[key] ~= nil then
        return m_options[key]
    else
        return default
    end
end

--[[ function SettingsScreen:SaveData(data, filepath)
    local str = json.encode(data)
    local insz, outsz = SavePersistentString(filepath, str)
end ]]
--修改设置 自带判空
function MOD_util:ChangeMOption(key, v)
    if not rawget(_G, "m_options") then return end
    m_options[key] = v
end

--添加按键，可以在游戏内更改设置
function MOD_util:AddKeyDownHandler(optionkey, defaultkey, fn)
    if not fn then
        fn = defaultkey
        defaultkey = nil
    end
    TheInput:AddMouseButtonHandler(function(button, down, x, y)
        if down and MOD_util:GetMOption(optionkey, defaultkey) == button then
            fn(button, down, x, y)
        end
    end)
    TheInput:AddKeyHandler(function(key, down)
        if down and MOD_util:GetMOption(optionkey, defaultkey) == key then
            fn(key, down)
        end
    end)
end

function MOD_util:AddKeyUpHandler(optionkey, defaultkey, fn)
    if not fn then
        fn = defaultkey
        defaultkey = nil
    end
    TheInput:AddMouseButtonHandler(function(button, down, x, y)
        if not down and MOD_util:GetMOption(optionkey, defaultkey) == button then
            fn(button, down, x, y)
        end
    end)
    TheInput:AddKeyHandler(function(key, down)
        if not down and MOD_util:GetMOption(optionkey, defaultkey) == key then
            fn(key, down)
        end
    end)
end

--模组添加设置
function MOD_util:CanAddSetting()
    print(status, settingscreen, "1screens/settingsscreen")
    return status, settingscreen
end

function MOD_util:CreatePage(pagename, pagedata, forcecreate)
    if not MOD_util:CanAddSetting() then
        return
    end
    settingscreen:CreatePage(pagename, pagedata, forcecreate)
end

--
function MOD_util:StandardPage(pagename, buttonname, order, pagetitle)
    if not MOD_util:CanAddSetting() then
        return
    end
    settingscreen:StandardPage(pagename, buttonname, order, pagetitle)
end

function MOD_util:AddEnableDisableOption(pagename, key, default, description, hover)
    if not MOD_util:CanAddSetting() then
        return
    end
    if default == nil then
        default = true
    end
    settingscreen:AddEnableDisableOption(pagename, key, default, description, hover)
end

function MOD_util:AddKeyBinds(pagename, key, default, description, hover)
    if not MOD_util:CanAddSetting() then
        return
    end
    if default == nil then
        default = true
    end
    settingscreen:AddKeyBinds(pagename, key, default, description, hover)
end

function MOD_util:AddOption(pagename, key, options, default, description, hover)
    if not MOD_util:CanAddSetting() then
        return
    end
    if default == nil then
        default = true
    end
    settingscreen:AddOption(pagename, key, options, default, description, hover)
end

function MOD_util:GetKeyFromConfig(name)
    local a = GetModConfigData(name)
    return a and rawget(GLOBAL, a)
end

function PLAYER_util:IsHoldingItem(item, all)
    return item
        and item:IsValid() and ThePlayer and ThePlayer.replica.inventory and
        ThePlayer.replica.inventory:IsHolding(item, all)
end

function INV_util:GetActiveItem()
    return self:HasInv()
        and ThePlayer.replica.inventory:GetActiveItem()
end

local function isneed(v, prefabs, tags, nottags, fn)
    --[[ print((not prefabs or type(prefabs) == 'string' and v.prefab == prefabs
            or type(prefabs) == 'table' and table.contains(prefabs, v.prefab)),
        (not tags or type(tags) == 'string' and v:HasTag(tags) or type(tags) == 'table' and v:HasOneOfTags(tags)),
        (not nottags or type(nottags) == 'string' and not v:HasTag(nottags) or type(nottags) == 'table'
            and not v:HasOneOfTags(nottags)), (not fn or fn(v))) ]]
    if (not prefabs or type(prefabs) == 'string' and v.prefab == prefabs
            or type(prefabs) == 'table' and table.contains(prefabs, v.prefab))
        and (not tags or type(tags) == 'string' and v:HasTag(tags) or type(tags) == 'table' and v:HasOneOfTags(tags))
        and (not nottags or type(nottags) == 'string' and not v:HasTag(nottags) or type(nottags) == 'table'
            and not v:HasOneOfTags(nottags))
        and (not fn or fn(v)) then
        return true
    end
end
function GAME_util:InGame()
    return ThePlayer and ThePlayer.HUD and not ThePlayer.HUD:HasInputFocus()
end

function ENT_util:FnOrNum(a, ...)
    if type(a) == "function" then
        return a(...)
    else
        return a
    end
end

function EQUIP_util:ToID(name)
    return EquipSlot.ToID(name)
end

function INV_util:FindEmptySlot(con, excludepos, excludecon)
    if not con or con == ThePlayer then
        local inventory = ThePlayer.replica.inventory
        if inventory:IsFull() then
            local backpack = inventory:GetOverflowContainer()
            if backpack and not backpack:IsFull() then
                for i = 1, backpack:GetNumSlots() do
                    if not backpack:GetItemInSlot(i)
                        and (i ~= excludepos or backpack.inst ~= excludecon) then
                        return i, backpack.inst
                    end
                end
            end
        else
            for i = 1, inventory:GetNumSlots() do
                if not inventory:GetItemInSlot(i)
                    and (i ~= excludepos or nil ~= excludecon) then
                    return i
                end
            end
            local backpack = inventory:GetOverflowContainer()
            if backpack and not backpack:IsFull() then
                for i = 1, backpack:GetNumSlots() do
                    if not backpack:GetItemInSlot(i)
                        and (i ~= excludepos or backpack.inst ~= excludecon) then
                        return i, backpack.inst
                    end
                end
            end
        end
    else
        local backpack = con.replica.container
        if not backpack then return end
        for i = 1, backpack:GetNumSlots() do
            if not backpack:GetItemInSlot(i)
                and (i ~= excludepos or backpack.inst ~= excludecon) then
                return i, backpack.inst
            end
        end
    end
end

function ENT_util:GetPercent(inst)
    local i = 100
    local classified = type(inst) == "table" and inst.replica and inst.replica.inventoryitem and
        inst.replica.inventoryitem.classified
    if classified then
        if inst:HasOneOfTags({ "fresh", "show_spoilage" }) and classified.perish then
            i = math.floor(classified.perish:value() / 0.62)
        elseif classified.percentused then
            i = classified.percentused:value()
        end
    end
    return i
end

function INV_util:CountPrefab(prefabs, tags, nottags, fn, notsearchtab)
    local num = 0
    if not notsearchtab or not notsearchtab.equips then
        for k, v in pairs(ThePlayer.replica.inventory:GetEquips()) do
            if isneed(v, prefabs, tags, nottags, fn) then
                num = num + (v.replica.stackable and v.replica.stackable:StackSize() or 1)
            end
        end
    end
    if not notsearchtab or not notsearchtab.items then
        for k, v in pairs(ThePlayer.replica.inventory:GetItems()) do
            if isneed(v, prefabs, tags, nottags, fn) then
                num = num + (v.replica.stackable and v.replica.stackable:StackSize() or 1)
            end
        end
    end
    if not notsearchtab or not notsearchtab.items then
        local v = ThePlayer.replica.inventory:GetActiveItem()
        if v and isneed(v, prefabs, tags, nottags, fn) then
            num = num + (v.replica.stackable and v.replica.stackable:StackSize() or 1)
        end
    end
    if not notsearchtab or not notsearchtab.container then
        for k, v in pairs(ThePlayer.replica.inventory:GetOpenContainers() or {}) do
            if k and k.replica and k.replica.container then --如果是空表不知道k是不是nil??以防万一还是判定空
                for kkk, vvv in pairs(k.replica.container:GetItems()) do
                    num = num + (vvv.replica.stackable and vvv.replica.stackable:StackSize() or 1)
                end
            end
        end
    end
    return num
end

--a, b, c, d分别为ab为极坐标轴，c为旋转角度，d为距离a的距离（其实就是极坐标轴）
function POS_util:CalculateAimPos(a, b, c, d)
    if not a.x then
        a = a:GetPosition()
    end
    if not b.x then
        b = b:GetPosition()
    end
    local dx, dz = b.x - a.x, b.z - a.z
    local distance = math.sqrt(dx * dx + dz * dz)
    local cos, sin = dx / distance, dz / distance
    local aimdx = d * (math.cos(c) * cos - math.sin(c) * sin)
    local aimdz = d * (math.sin(c) * cos + math.cos(c) * sin)
    local aimx, aimz = a.x + aimdx, a.z + aimdz
    return Vector3(aimx, 0, aimz)
end

function PLAYER_util:CanSeeTarget(ent)
    return ent and (TheSim:GetLightAtPoint(ent:GetPosition().x, 0, ent:GetPosition().z) > TUNING.DARK_CUTOFF
        or ThePlayer.components.playervision.nightvision or ThePlayer.prefab == 'wathom')
end

function INV_util:HasInv(target)
    return ThePlayer
        and ThePlayer.replica.inventory
end

function INV_util:GetHandsEquip(target)
    return self:HasInv(target) and EQUIPSLOTS.HANDS
        and ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
end --GetEquippedItem(EQUIPSLOTS.HEAD)

function ENT_util:CheckDebugString(ent, ...)
    if ent == nil then return end
    local str = ent.entity
        and ent.entity:GetDebugString()
    for k, v in pairs({ ... }) do
        if type(v) == "table" then
            for key, value in pairs(v) do
                if ENT_util:CheckDebugString(ent, value) then
                    return true
                end
            end
        elseif str and string.find(str, v) then
            return true
        end
    end
end

function INV_util:FindInInv(prefabs, tags, nottags, fn, notsearchtab) --如果都是nil会返回一个身上的物品
    if not notsearchtab or not notsearchtab.equips then
        for k, v in pairs(ThePlayer.replica.inventory:GetEquips()) do
            if isneed(v, prefabs, tags, nottags, fn) then
                return v, k, nil
            end
        end
    end
    if not notsearchtab or not notsearchtab.items then
        for k, v in pairs(ThePlayer.replica.inventory:GetItems()) do
            if isneed(v, prefabs, tags, nottags, fn) then
                return v, k, nil
            end
        end
    end
    if not notsearchtab or not notsearchtab.items then
        --[[  local active = ThePlayer.replica.inventory:GetActiveItem()
        if isneed(active, prefabs, tags, nottags, fn) then
            return active
        end ]]
    end
    if not notsearchtab or not notsearchtab.container then
        for k, v in pairs(ThePlayer.replica.inventory:GetOpenContainers() or {}) do
            if k and k.replica and k.replica.container then --如果是空表不知道k是不是nil??以防万一还是判定空
                for kkk, vvv in pairs(k.replica.container:GetItems()) do
                    if isneed(vvv, prefabs, tags, nottags, fn) then
                        return vvv, kkk, k
                    end
                end
            end
        end --Inventory:GetOverflowContainer()
    elseif not notsearchtab or not notsearchtab.backpack then
        local backpack = ThePlayer.replica.inventory:GetOverflowContainer()
        if backpack then
            for kkk, vvv in pairs(backpack:GetItems()) do
                if isneed(vvv, prefabs, tags, nottags, fn) then
                    return vvv, kkk, backpack.inst
                end
            end
        end
    end
end

function INV_util:FindInInventory(prefab, tags, fn) --如果都是nil会返回一个身上的物品
    if not ThePlayer then return end
    for k, v in pairs(ThePlayer.replica.inventory:GetItems()) do
        if isneed(v, prefab, tags, nil, fn) then
            return v, k, nil
        end
    end
    for k, v in pairs(ThePlayer.replica.inventory:GetOpenContainers() or {}) do
        if k and k.replica and k.replica.container then
            for kkk, vvv in pairs(k.replica.container:GetItems()) do
                if isneed(vvv, prefab, tags, nil, fn) then
                    return vvv, kkk, k
                end
            end
        end
    end
end

local ClickEquip = { control_flag = {}, } -- 存储鼠标的
local ClickEquip2 = { control_flag = {}, } -- 存储空格数据的
local closefn = false
ClickEquip.walktoact = GetModConfigData("walktoact") or true
--当目标有这个动作的时候不会更换动作
ClickEquip.blacklist_lmb = {
    ['PLUCK'] = true,
    ["RUMMAGE"] = true,
    ["ACTIVATE"] = true,
    ["PICK"] = true,
}
ClickEquip.blacklist_rmb = {
}
local function isdoingrecipe()
    return ThePlayer and ThePlayer.components.playercontroller and
        ThePlayer.components.playercontroller.placer_recipe
end
local function fallfn(target)
    if ThePlayer.replica.rider:IsRiding()
        or TheInput:IsKeyDown(KEY_LALT)
        or INV_util:GetActiveItem()
        or isdoingrecipe()
        or TheInput:GetHUDEntityUnderMouse() or target and target.prefab == 'minisign' or closefn then
        return true
    end
end
local function defaultcheckaction(action)
    if action and action.action and action.action.id ~= 'LOOKAT' and action.action.id ~= 'WALKTO' then
        return true
    end
end
--对于不同的tag实现不同的功能
local tagtable = {
    ['MINE_workable'] = {
        action = ACTIONS.MINE,
        tooltag = 'MINE_tool',
        equiptool = true,
        isleftclick = true,
        selectfn = function(ent)
            if INV_util:FindInInventory(nil, 'MINE_tool') then
                return true
            end
        end,
        fallfn = function(action)
            if action and action.action and (action.action.id == 'MINE' or ClickEquip.blacklist_lmb[action.action.id]) then
                return true
            end
            return false
        end,
        needoncontrol = true
    },
    ['CHOP_workable'] = {
        action = ACTIONS.CHOP,
        tooltag = 'CHOP_tool',
        equiptool = true,
        isleftclick = true,
        selectfn = function(ent)
            if ent and (ent.prefab == 'oceantree' or ent.prefab == 'oceantree_pillar') then
                return false
            end
            if INV_util:FindInInventory(nil, 'CHOP_tool') then
                return true
            end
        end,
        fallfn = function(action)
            local actionid = action and action.action and action.action.id
            if actionid and (actionid == 'CHOP' or ClickEquip.blacklist_lmb[actionid]) then
                return true
            end
            return false
        end,
        needoncontrol = true
    },
    ['DIG_workable'] = {
        action = ACTIONS.DIG,
        tooltag = 'DIG_tool',
        equiptool = true,
        isleftclick = false,
        selectfn = function(ent)
            if INV_util:FindInInventory(nil, 'DIG_tool') then
                return true
            end
        end,
        fallfn = function(action)
            if defaultcheckaction(action) then
                return true
            end
            return false
        end,
        needoncontrol = true
    },
    ['HAMMER_workable'] = {
        action = ACTIONS.HAMMER,
        tooltag = 'HAMMER_tool',
        equiptool = true,
        isleftclick = false,
        selectfn = function(ent)
            if INV_util:FindInInventory(nil, 'HAMMER_tool') then
                return true
            end
        end,
        fallfn = function(action)
            if defaultcheckaction(action) then
                return true
            end
            return false
        end,
        needoncontrol = true
    },
    ['NET_workable'] = {
        action = ACTIONS.NET,
        tooltag = 'NET_tool',
        equiptool = true,
        isleftclick = true,
        selectfn = function(ent)
            if INV_util:FindInInventory(nil, 'NET_tool') then
                return true
            end
        end,
        needoncontrol = true
    },
    ['pickable'] = {
        --action = ACTIONS.SCYTHE,
        tooltag = 'SCYTHE_tool',
        overridestr = STRINGS.RMB .. ':收割',
        --toolprefab = 'voidcloth_scythe',
        --equiptool = true,
        isleftclick = false,
        fallfn = function(action)
            if defaultcheckaction(action) then
                return true
            end
            return false
        end,
        selectfn = function(ent)
            if ent and ent:HasOneOfTags({ "plant", "lichen", "oceanvine", "kelp" }) and INV_util:FindInInventory(nil, 'SCYTHE_tool') then
                return true
            else
                return false
            end
        end,
        needoncontrol = true,
        oncontrolfn = function(act)
            if distsq(ThePlayer:GetPosition(), act.target:GetPosition()) > 2.5 * 2.5 then
                local hand = INV_util:GetHandsEquip()
                local scythe, pos, backpack = INV_util:FindInInventory(nil, 'SCYTHE_tool')
                SendRPCToServer(RPC.TakeActiveItemFromAllOfSlot, pos, backpack)
                if hand then
                    SendRPCToServer(RPC.SwapEquipWithActiveItem)
                    SendRPCToServer(RPC.PutAllOfActiveItemInSlot, pos, backpack)
                else
                    SendRPCToServer(RPC.EquipActiveItem)
                end

                SendRPCToServer(RPC.LeftClick, ACTIONS.SCYTHE.code, act.target:GetPosition().x,
                    act.target:GetPosition().z,
                    act.target, nil, nil, ACTIONS.SCYTHE.canforce, ACTIONS.SCYTHE.mod_name)
                if hand then
                    SendRPCToServer(RPC.TakeActiveItemFromAllOfSlot, pos, backpack)
                    SendRPCToServer(RPC.SwapEquipWithActiveItem)
                else
                    SendRPCToServer(RPC.TakeActiveItemFromEquipSlot, EQUIP_util:ToID('hands'))
                end
                SendRPCToServer(RPC.PutAllOfActiveItemInSlot, pos, backpack)
            else
                local scythe, pos, backpack = INV_util:FindInInventory(nil, 'SCYTHE_tool')
                SendRPCToServer(RPC.ControllerUseItemOnSelfFromInvTile, ACTIONS.EQUIP.code, scythe)
                SendRPCToServer(RPC.LeftClick, ACTIONS.SCYTHE.code, act.target:GetPosition().x,
                    act.target:GetPosition().z,
                    act.target, nil, nil, ACTIONS.SCYTHE.canforce, ACTIONS.SCYTHE.mod_name)
            end
        end,
        needreturn = true,
    },
    ['whackable'] = {
        action = ACTIONS.ATTACK,
        overridestr = '敲击',
        tooltag = 'HAMMER_tool',
        equiptool = true,
        isleftclick = true,
        fallfn = function(action)
            if action and action.action and (action.action.id == 'PICKUP') then
                return true
            end
            return false
        end,
        needoncontrol = true
    },
}
--对于不同的prefab实现不同的功能
local prefabtable = {
    --选中星星放星星！
    ['stafflight'] = {
        --action = ACTIONS.GIVE,
        overridestr = STRINGS.RMB .. ':叠加星星',
        toolprefab = 'yellowstaff',
        isleftclick = false,
        selectfn = function(action)
            local hand = INV_util:GetHandsEquip()
            return not hand or hand.prefab ~= 'yellowstaff'
        end,
        needoncontrol = true,
        oncontrolfn = function(act)
            local item, k, con = INV_util:FindInInventory('yellowstaff')
            local hand = INV_util:GetHandsEquip()
            SendRPCToServer(RPC.TakeActiveItemFromAllOfSlot, k, con, nil)
            if hand then
                SendRPCToServer(RPC.SwapEquipWithActiveItem)
                SendRPCToServer(RPC.PutAllOfActiveItemInSlot, k, con)
            else
                SendRPCToServer(RPC.EquipActiveItem)
            end
            SendRPCToServer(RPC.RightClick, ACTIONS.CASTSPELL.code, act.target:GetPosition().x,
                act.target:GetPosition().z)
            SendRPCToServer(RPC.TakeActiveItemFromEquipSlot, EQUIP_util:ToID('hands'))
            if hand then
                SendRPCToServer(RPC.SwapActiveItemWithSlot, k, con)
                SendRPCToServer(RPC.EquipActiveItem)
            else
                SendRPCToServer(RPC.PutAllOfActiveItemInSlot, k, con)
            end
        end,
        needreturn = true,
    },
    ['atrium_gate'] = { --远古大门需要插上钥匙
        --action = ACTIONS.GIVE,
        overridestr = STRINGS.RMB .. ':插入钥匙',
        toolprefab = 'atrium_key',
        isleftclick = false,
        fallfn = function(action)
            return false
        end,
        needoncontrol = true,
        oncontrolfn = function(act)
            local item, k, con = INV_util:FindInInventory('atrium_key')
            if not INV_util:GetActiveItem() or not PLAYER_util:CanSeeTarget(act.target) then
                SendRPCToServer(RPC.TakeActiveItemFromAllOfSlot, k, con, nil)
                SendRPCToServer(RPC.LeftClick, ACTIONS.GIVE.code, act.target:GetPosition().x, act.target:GetPosition().z,
                    act.target,
                    nil, nil, true)
                SendRPCToServer(RPC.ReturnActiveItem, nil, nil, nil)
            else
                SendRPCToServer(RPC.ControllerUseItemOnSceneFromInvTile, ACTIONS.GIVE.code, item, act.target)
            end
        end,
        needreturn = true,
    },
    ['fossil_stalker'] = { --shadowheart
        --action = ACTIONS.REPAIR,
        overridestr = STRINGS.RMB .. ':修理骨架',
        toolprefab = 'fossil_piece',
        isleftclick = false,
        selectfn = function(ent) --fossil_stalker.zip:1_1
            if not ENT_util:CheckDebugString(ent, '_8') then
                if ENT_util:CheckDebugString(ent, '1_') then
                    return true
                end
            end
            return false
        end,
        needoncontrol = true,
        oncontrolfn = function(act)
            local item, k, con = INV_util:FindInInventory('fossil_piece')
            if not INV_util:GetActiveItem() or not PLAYER_util:CanSeeTarget(act.target) then
                SendRPCToServer(RPC.TakeActiveItemFromAllOfSlot, k, con, nil)
                SendRPCToServer(RPC.LeftClick, ACTIONS.REPAIR.code, act.target:GetPosition().x,
                    act.target:GetPosition().z,
                    act.target,
                    nil, nil, true)
                SendRPCToServer(RPC.ReturnActiveItem, nil, nil, nil)
            else
                SendRPCToServer(RPC.ControllerUseItemOnSceneFromInvTile, ACTIONS.REPAIR.code, item, act.target)
            end
        end,
        needreturn = true,
    },
    ['crabking'] = {
        --action = ACTIONS.ATTACK,
        overridestr = STRINGS.RMB .. ':冰冻',
        tooltag = 'icestaff',
        --toolprefab = 'voidcloth_scythe',
        equiptool = true,
        isleftclick = false,
        needoncontrol = true,
        selectfn = function(ent)
            return INV_util:FindInInv(nil, 'icestaff')
        end,
        oncontrolfn = function(act)
            local pos = act.target:GetPosition()
            SendRPCToServer(RPC.LeftClick, ACTIONS.ATTACK.code, pos.x, pos.z, act.target,
                nil, nil, true)
        end,
        needreturn = true,
    },
    --monkeyqueen
    --pigking
    --antlion
    --moonbase
    --hermitcrab
    --sharkboi
    --siving_thetree
    --dustmoth dustmeringue
    --ancient_altar_broken fixit thulecite thulecite_pieces
}
--对于不同的人物需要实现不同的功能
local playertable = {
    ['wortox'] = {
        -- action = ACTIONS.BLINK,
        overridestr = STRINGS.RMB .. ':精准跳跃',
        overridecolor = WEBCOLOURS.RED,
        toolprefab = 'wortox_soul',
        isleftclick = false,
        fallfn = function(action, ent)
            if not ent then
                return true
            end
            if defaultcheckaction(action) then
                return true
            end
            return false
        end,
        needoncontrol = true,
        oncontrolfn = function(act)
            if act.target then
                SendRPCToServer(RPC.RightClick, ACTIONS.BLINK.code, act.target:GetPosition().x,
                    act.target:GetPosition().z)
            end
        end,
        needreturn = true,
    },
    ['wanda'] = {
        --action = ACTIONS.BLINK,
        overridestr = STRINGS.RMB .. ':回血',
        toolprefab = 'pocketwatch_heal',
        tooltag = 'pocketwatch_inactive',
        isleftclick = false,
        fallfn = function(action, ent)
            if defaultcheckaction(action) then
                return true
            end
            return false
        end,
        needoncontrol = true,
        oncontrolfn = function(act)
            SendRPCToServer(RPC.ControllerUseItemOnSelfFromInvTile, ACTIONS.CAST_POCKETWATCH.code, act.item)
        end,
        needreturn = true,
    },
    ['wathgrithr'] = {
        --action = ACTIONS.BLINK,
        overridestr = function() --wathgrithr_shield
            local hand = INV_util:GetHandsEquip()
            if hand and hand.prefab == 'wathgrithr_shield' then
                return STRINGS.RMB .. ':格挡'
            end
            return STRINGS.RMB .. ':武神突刺'
        end,
        isleftclick = false,
        selectfn = function(ent)
            local hand = INV_util:GetHandsEquip()
            local WathgrithrWeapon = {
                'spear_wathgrithr_lightning',
                'spear_wathgrithr_lightning_charged',
                'wathgrithr_shield',
            }
            ---@diagnostic disable-next-line: undefined-field
            return hand and table.contains(WathgrithrWeapon, hand.prefab) and hand and
                hand.components.aoetargeting:IsEnabled()
        end,
        fallfn = function(action, ent)
            if defaultcheckaction(action) then
                return true
            end
            return false
        end,
        needoncontrol = true,
        oncontrolfn = function(act)
            local pos = POS_util:CalculateAimPos(ThePlayer:GetPosition(), TheInput:GetWorldPosition(), 0, 7.5)
            SendRPCToServer(RPC.RightClick, ACTIONS.CASTAOE.code, pos.x,
                pos.z)
        end,
        needreturn = true,
    },
    ['willow'] = {
        -- action = ACTIONS.ATTACK,
        overridestr = function()
            if ThePlayer.components.skilltreeupdater:IsActivated("willow_allegiance_lunar_fire") then
                return STRINGS.RMB .. ':月焰攻击'
            end
            return STRINGS.RMB .. ':暗影攻击' --dont check because have checked
        end,
        overridecolor = function()
            if ThePlayer.components.skilltreeupdater:IsActivated("willow_allegiance_lunar_fire") then
                return WEBCOLOURS.LIGHTSKYBLUE
            end
            return BLACK
        end,
        toolprefab = 'willow_ember',
        --TUNING.WILLOW_EMBER_SHADOW,     --获取到的工具必须满足TUNING.WILLOW_EMBER_LUNAR
        isleftclick = false,
        selectfn = function(ent)
            local embernum = INV_util.CountPrefab and
                INV_util:CountPrefab('willow_ember', nil, nil, nil, { equips = true, container = true })
                or 100
            if embernum >= TUNING.WILLOW_EMBER_LUNAR then
                return ThePlayer.components.skilltreeupdater:IsActivated("willow_allegiance_lunar_fire") and
                    not ThePlayer.components.spellbookcooldowns:GetSpellCooldownPercent("lunar_fire") or
                    ThePlayer.components.skilltreeupdater:IsActivated("willow_allegiance_shadow_fire") and
                    not ThePlayer.components.spellbookcooldowns:GetSpellCooldownPercent("shadow_fire")
            end
        end,
        fallfn = function(action, ent)
            if defaultcheckaction(action) then
                return true
            end
            return false
        end,
        needoncontrol = true,
        oncontrolfn = function(act)
            local spell = act.item.components.spellbook
            if spell then
                for k, v in pairs(spell.items or {}) do
                    if v.checkcooldown then --checkcooldown区分月火暗影火和其他的小技能
                        local pos = POS_util:CalculateAimPos(ThePlayer:GetPosition(), TheInput:GetWorldPosition(), 0, 7.5)
                        SendRPCToServer(RPC.LeftClick, ACTIONS.CASTAOE.code, pos.x,
                            pos.z, nil,
                            nil, nil, nil, nil, nil,
                            false,
                            act.item, k)
                        break
                    end
                end
            end
        end,
        needreturn = true,
    },
    --todo:wendy abig use medical. maybewrite it in prefabtable?
    ['waxwell'] = {
        --action = ACTIONS.ATTACK,
        overridestr = STRINGS.RMB .. ':暗影囚笼',
        toolprefab = 'waxwelljournal',
        --creatreticule = true,
        toolfn = function(inst)
            local per = ENT_util:GetPercent(inst)
            return not per or per > 0
        end,
        isleftclick = false,
        fallfn = function(action, ent)
            if defaultcheckaction(action) then
                return true
            end
            if ThePlayer:GetCurrentPlatform() then
                return true
            end
            return false
        end,
        needoncontrol = true,
        oncontrolfn = function(act)
            local book = INV_util:FindInInventory('waxwelljournal')
            if not book then return end
            SendRPCToServer(RPC.LeftClick, ACTIONS.CASTAOE.code, TheInput:GetWorldPosition().x,
                TheInput:GetWorldPosition().z,
                nil, nil, nil, nil, nil, nil, false, book, 4)
        end,
        needreturn = true,
    },
}
--对于不同的装备实现不同的功能
local handtable = {
    ['yellowstaff'] = {
        -- action = ACTIONS.CASTSPELL,
        overridestr = STRINGS.RMB .. ':施放法术',
        overridecolor = WEBCOLOURS.RED,
        isleftclick = false,
        fallfn = function(action)
            if defaultcheckaction(action) then
                return true
            end
            return false
        end,
        needoncontrol = true,
        oncontrolfn = function(act)
            SendRPCToServer(RPC.RightClick, ACTIONS.CASTSPELL.code, TheInput:GetWorldPosition().x,
                TheInput:GetWorldPosition().z, nil, nil, nil, nil, nil, nil, nil, false)
        end,
        needreturn = true,
    },
    --
    ['orangestaff'] = --[[ not TheNet:GetIsServer() and ]] {
        --action = ACTIONS.BLINK,
        overridestr = STRINGS.RMB .. ':传送',
        --overridecolor = WEBCOLOURS.RED,
        isleftclick = false,
        fallfn = function(action, ent)
            local iswortox = ThePlayer and ThePlayer:HasTag("soulstealer")
            local soul = iswortox and INV_util:FindInInventory('wortox_soul')

            if defaultcheckaction(action)
                and action.action.id ~= 'BLINK' or (not iswortox or not soul) and not ent
            then
                return true
            end
            --[[  local raction = ThePlayer.components.playercontroller.RMBaction
            if raction and raction.action == ACTIONS.BLINK then
                return true
            end ]]
            return false
        end,
        needoncontrol = true,
        oncontrolfn = function(act)
            local iswortox = ThePlayer and ThePlayer:HasTag("soulstealer")
            local soul = iswortox and INV_util:FindInInventory('wortox_soul')
            local function wortoxjump(aimpos)
                local pos, con = INV_util:FindEmptySlot()
                SendRPCToServer(RPC.TakeActiveItemFromEquipSlot, EQUIP_util:ToID('hands'))
                SendRPCToServer(RPC.PutAllOfActiveItemInSlot, pos, con)
                SendRPCToServer(RPC.RightClick, ACTIONS.BLINK.code,
                    aimpos.x,
                    aimpos.z)
                SendRPCToServer(RPC.TakeActiveItemFromAllOfSlot, pos, con)
                SendRPCToServer(RPC.EquipActiveItem, nil, nil, nil)
            end
            if iswortox and soul and INV_util:FindEmptySlot() then
                wortoxjump(act.target and act.target:GetPosition() or TheInput:GetWorldPosition())
            elseif act.target then
                SendRPCToServer(RPC.RightClick, ACTIONS.BLINK.code, act.target:GetPosition().x,
                    act.target:GetPosition().z, nil, nil, nil, nil, nil, nil, nil, false)
            else
                SendRPCToServer(RPC.RightClick, ACTIONS.BLINK.code, TheInput:GetWorldPosition().x,
                    TheInput:GetWorldPosition().z, nil, nil, nil, nil, nil, nil, nil, false)
            end
        end,
        needreturn = true,
    },
    ['me_spiralspear'] = {
        --action = ACTIONS.BLINK,
        overridestr = STRINGS.RMB .. ':滑铲',
        --overridecolor = WEBCOLOURS.RED,
        isleftclick = false,
        selectfn = function(ent)
            if ACTIONS.DODGE_WALTER and ThePlayer.rightaction2hm
                and (GetTime() - ThePlayer.last_rightaction2hm_time > ThePlayer.rightaction2hm_cooldown
                    or ThePlayer:HasTag("doubledodge2hm")) then
                return true
            end
            return false
        end,
        needoncontrol = true,
        oncontrolfn = function(act)
            local itempos1, con1 = INV_util:FindEmptySlot()
            local mpos = TheInput:GetWorldPosition()
            SendRPCToServer(RPC.TakeActiveItemFromEquipSlot, EQUIP_util:ToID('hands'))
            SendRPCToServer(RPC.PutAllOfActiveItemInSlot, itempos1, con1)
            SendRPCToServer(RPC.RightClick, ACTIONS.DODGE_WALTER.code, mpos.x, mpos.z, nil, nil, nil,
                nil, nil,
                ACTIONS.DODGE_WALTER.mod_name, nil, false)
            SendRPCToServer(RPC.TakeActiveItemFromAllOfSlot, itempos1, con1)
            SendRPCToServer(RPC.EquipActiveItem, nil, nil, nil)
        end,
        needreturn = true,
    },
}
function GLOBAL.AddHandTable(prefab, tab)
    handtable[prefab] = tab
end

local lastent, lasthand, lasthentworktable, lasthandworktable
local function selectwork(ent , determine)
    if determine then
        if not GAME_util:InGame() then return end
        if fallfn(ent) then
            return
        end
    end
    if lastent ~= ent then
        lastent = ent
        if ent then
            local tab = prefabtable[ent.prefab]
            if tab and (not tab.selectfn or tab.selectfn(ent)) then
                lasthentworktable = tab
                return tab
            end
            for k, v in pairs(tagtable) do
                if ent:HasTag(k) and (not v.selectfn or v.selectfn(ent)) then
                    lasthentworktable = v
                    return v
                end
            end
        end
        lasthentworktable = nil
    elseif lastent and lasthentworktable then
        return lasthentworktable
    end

    local hand = INV_util:GetHandsEquip()
    if lasthand ~= hand then
        lasthand = hand
        if hand then
            local etab = handtable[hand.prefab]
            if etab and (not etab.selectfn or etab.selectfn(ent)) then
                lasthandworktable = etab
                return handtable[hand.prefab]
            end
        end
        lasthandworktable = nil
    elseif lasthand and lasthandworktable then
        return lasthandworktable
    end
    local ptab = playertable[ThePlayer.prefab]
    if ptab and (not ptab.selectfn or ptab.selectfn(ent)) then
        return playertable[ThePlayer.prefab]
    end
end
local function isneed(v, prefabs, tags, nottags, fn)
    if (not prefabs or type(prefabs) == 'string' and v.prefab == prefabs
            ---@diagnostic disable-next-line: undefined-field
            or type(prefabs) == 'table' and table.contains(prefabs, v.prefab))
        and (not tags or type(tags) == 'string' and v:HasTag(tags) or type(tags) == 'table' and v:HasOneOfTags(tags))
        and (not nottags or type(nottags) == 'string' and not v:HasTag(nottags) or type(nottags) == 'table'
            and not v:HasOneOfTags(nottags))
        and (not fn or fn(v)) then
        return true
    end
end

-- 我的函数
local TARGET_EXCLUDE_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }
local TARGET_CONTAIN_TAGS = { "CHOP_workable", "MINE_workable" }
local function queryVicinity()
    -- 附近有树才会操作的选项
    if ThePlayer and ThePlayer.Transform then
        -- 获取我自己的坐标
        local xx, yy, zz = ThePlayer.Transform:GetWorldPosition()
        -- 搜索我附近是否有树
        local ent2 = FindEntity(ThePlayer, 6, nil, nil, TARGET_EXCLUDE_TAGS,TARGET_CONTAIN_TAGS)
        -- 附近有树了，我才会走

        if ent2 and ent2.prefab ~= "twiggytree" and ent2.prefab ~= "statueglommer" then
            -- 计算坐标偏差
            local x,y,z =  ent2.Transform:GetWorldPosition()
            local offset = 0.5
            if ent2:HasTag("MINE_workable") -- 不等于小范围的,处理石头的
                    --and ent2.prefab ~= "moonrock_pieces"
                    and ent2.prefab ~= "marbleshrub"
                    and ent2.prefab ~= "marbletree"
                    and ent2.prefab ~= "lunarrift_crystal_small"
            then
                -- 岩石树
                if ent2.prefab == "rock_petrified_tree" and (ent2.AnimState:GetCurrentBankName() == "petrified_tree_short" or ent2.AnimState:GetCurrentBankName() == "petrified_tree_old") then
                    offset = 0.5
                    -- 月球风暴
                elseif ent2.prefab == "moonstorm_glass_nub" then
                    offset = 0.2
                    -- 大理石雕像，水里的垃圾，中等的树,还有地下的一些石头
                elseif ent2.prefab == "shell_cluster" or (ent2.prefab == "rock_petrified_tree" and ent2.AnimState:GetCurrentBankName() == "petrified_tree")
                        or ent2.prefab == "statuemaxwell"
                        or ent2.prefab == "statueharp"
                        or ent2.prefab == "sculpture_knightbody"
                        or ent2.prefab == "sculpture_bishopbody"
                        or ent2.prefab == "statue_marble"
                        or ent2.prefab == "archive_moon_statue"
                        or string.find(ent2.prefab, "statue_marble_%a*")
                        or string.find(ent2.prefab, "ruins_statue_%a*")
                        or ent2.prefab == "cavein_boulder"
                        or ent2.prefab == "dustmothden"
                then
                    offset = 0.8
                    -- 蜘蛛巢/大理石雕像很大的那个
                elseif ent2.prefab == "spiderhole" or ent2.prefab == "spiderhole_rock"
                        or ent2.prefab == "moonspiderden" or ent2.prefab == "moonspider_spike"
                        or ent2.prefab == "pond_cave" then
                    offset = 1.8
                    -- 月球岩石碎片
                elseif ent2.prefab == "moonrock_pieces" then
                    offset = 0.4
                elseif ent2.prefab == "sculpture_rookbody" then
                    offset = 1.5
                else
                    offset = 1
                end
            end

            -- 浮木树，月球树
            if ent2:HasTag("CHOP_workable")  -- 计算树的
                    and (ent2.prefab == "driftwood_small1"
                    or ent2.prefab == "driftwood_small2"
                    or ent2.prefab == "moon_tree") then
                offset = 1
            elseif ent2:HasTag("CHOP_workable") and (
                    ent2.prefab == "toadstool_cap"
                            or ent2.prefab == "toadstool_cap_dark"
            ) then
                offset = 0.8
            end

            -- 计算最终应该走到哪个地方--排除碰撞体积
            local target_x = x + offset * (xx - x > 0 and 1 or -1)
            local target_z = z + offset * (zz - z > 0 and 1 or -1)

            local pos2 =  Vector3(target_x,0,target_z)
            -- 查询我的坐标 附近的其他物品
            local excludeLabelItems = { "FX", "NOCLICK", "DECOR", "INLIMBO", "CHOP_workable", "MINE_workable" }
            local contieneLabelItems = { "pickable","_inventoryitem"}
            local ent_x = TheSim:FindEntities(xx, yy, zz, 6, nil, excludeLabelItems,contieneLabelItems)[1]

            -- 有其他物品就会走
            if ent_x  then
                -- 其他物品坐标
                local x1,y1,z1 =  ent_x.Transform:GetWorldPosition()
                local article1 = math.sqrt((xx - x1)^2 + (yy - y1)^2 + (zz - z1)^2)
                local article = math.sqrt((xx - x)^2 + (yy - y)^2 + (zz - z)^2)

                -- 树离得近就走这个
                if article < article1 then
                    --print("x1---")
                    local worktable2 = selectwork(ent2,false)
                    ClickEquip2.control_flag = { worktable = worktable2, lmb = true , physicalObject = ent2 ,pos2 = pos2}
                    ClickEquip2.overridelmbstr = nil
                    ClickEquip2.overridermbstr = nil
                    --pos = pos2
                else
                    -- 树离得远，去捡其他东西
                    --print("x2")
                    ClickEquip2.overridelmbstr, ClickEquip2.overridermbstr, ClickEquip2.overridelmbcolor, ClickEquip2.overridermbcolor =
                    nil, nil, nil, nil
                    ClickEquip2.control_flag = {}
                    if ClickEquip2.reticule then
                        ClickEquip2.reticule:Remove()
                        ClickEquip2.reticule = nil
                    end
                end
            else
                -- 附近没东西走这个
                --print("x3----")
                local worktable2 = selectwork(ent2,false)
                ClickEquip2.control_flag = { worktable = worktable2, lmb = true , physicalObject = ent2,pos2 = pos2}
                ClickEquip2.overridelmbstr = nil
                ClickEquip2.overridermbstr = nil
                --pos = pos2
            end
        else
            -- 附近什么都没有，走这个
            --print("x4")
            ClickEquip2.overridelmbstr, ClickEquip2.overridermbstr, ClickEquip2.overridelmbcolor, ClickEquip2.overridermbcolor =
            nil, nil, nil, nil
            ClickEquip2.control_flag = {}
            if ClickEquip2.reticule then
                ClickEquip2.reticule:Remove()
                ClickEquip2.reticule = nil
            end
        end
    end
end



local lastselectitem = nil
AddComponentPostInit("playeractionpicker", function(self, inst)
    local old = self.DoGetMouseActions
    function self:DoGetMouseActions(position, target, spellbook)
        local actiondate = {}
        --储存一下本来的动作 lmb and rmb
        actiondate.lmb, actiondate.rmb = old(self, position, target, spellbook)
        --获取动作的对象，如果有传入的实体就用传入的实体
        local ent = target or TheInput:GetWorldEntityUnderMouse()
        --获得写好的worktable {action overridestr overridecolor isleftclick selectfn needoncontrol oncontrolfn needreturn}
        local worktable = selectwork(ent,true)
        local item = worktable and lastselectitem and PLAYER_util:IsHoldingItem(lastselectitem, true) and
            isneed(lastselectitem, worktable.toolprefab, worktable.tooltag, worktable.nottag, worktable.toolfn) and
            lastselectitem or
            worktable and
            INV_util:FindInInv(worktable.toolprefab, worktable.tooltag, worktable.nottag, worktable.toolfn)
        ---@diagnostic disable-next-line: redundant-parameter

        -- 查询附近物品，并加以记录
        queryVicinity()

        if worktable and (not worktable.fallfn or not worktable.fallfn(actiondate[worktable.isleftclick and 'lmb' or 'rmb'], ent))
            and item then
            lastselectitem = item
            local pos = TheInput:GetWorldPosition()
            --todo 左右键同时生效
            if worktable.isleftclick == true then
                if worktable.action then --noaction then not override it
                    actiondate.lmb = BufferedAction(ThePlayer, ent, worktable.action, nil, pos)
                end
                ClickEquip.control_flag = { worktable = worktable, lmb = true }
                ClickEquip.overridelmbstr = ENT_util:FnOrNum(worktable.overridestr, ent)
                ClickEquip.overridermbstr = nil
                ClickEquip.overridelmbcolor = ENT_util:FnOrNum(worktable.overridecolor, ent)
            else
                ClickEquip.control_flag = { worktable = worktable, rmb = true }
                if worktable.action then
                    actiondate.rmb = BufferedAction(ThePlayer, ent, worktable.action, nil, pos)
                end
                ClickEquip.overridelmbstr = nil
                ClickEquip.overridermbstr = ENT_util:FnOrNum(worktable.overridestr, ent)
                ClickEquip.overridermbcolor = ENT_util:FnOrNum(worktable.overridecolor, ent)
            end
            --辅助圈
            if worktable.creatreticule and TheInput:IsKeyDown(KEY_LCTRL) then
                if not ClickEquip.reticule then
                    ClickEquip.reticule = SpawnPrefab(worktable.reticuleprefab or "reticuleaoe")
                end
                local mpos = TheInput:GetWorldPosition()
                ClickEquip.reticule.Transform:SetPosition(mpos.x, mpos.y, mpos.z)
                ClickEquip.reticule.AnimState:SetMultColour(204 / 255, 131 / 255, 57 / 255, 1)
            else
                if ClickEquip.reticule then
                    ClickEquip.reticule:Remove()
                    ClickEquip.reticule = nil
                end
            end
        else
            ClickEquip.overridelmbstr, ClickEquip.overridermbstr, ClickEquip.overridelmbcolor, ClickEquip.overridermbcolor =
                nil, nil, nil, nil
            ClickEquip.control_flag = {}
            if ClickEquip.reticule then
                ClickEquip.reticule:Remove()
                ClickEquip.reticule = nil
            end
        end
        --克雷的走向动作 这个bug克雷似乎已经修复了，但是我懒得删
        if ClickEquip.walktoact and actiondate.lmb == nil and ent and not ent:HasTag("boat") then
            if ent.name == "MISSING NAME" then
                --print('这个b没有名字', v.prefab)
                ent.name = ent.prefab
            end
            actiondate.lmb = BufferedAction(ThePlayer, ent, ACTIONS.WALKTO)
        end
        return actiondate.lmb, actiondate.rmb
    end
end)


-- 空格按键触发操作
local function spaceKeyTriggersOperation()
    local worktable = ClickEquip2.control_flag.worktable
    local physicalObject = ClickEquip2.control_flag.physicalObject
    if TheInput:IsControlPressed(GLOBAL.CONTROL_ACTION) or TheInput:IsKeyDown(KEY_SPACE) then
        if  worktable and physicalObject  then --确保是应该切的
            local pos2 = ClickEquip2.control_flag.pos2
            local tool = INV_util:FindInInv(worktable.toolprefab, worktable.tooltag, worktable.nottag, worktable.toolfn)
            if tool and ENT_util:FnOrNum(worktable.equiptool, tool) then
                SendRPCToServer(RPC.ControllerUseItemOnSelfFromInvTile, ACTIONS.EQUIP.code, tool)
            end
            --if worktable.oncontrolfn then
            --    worktable.oncontrolfn({ item = tool, target = physicalObject })
            --end
            if worktable.needreturn then
                return
            end
            -- 处理行动动作
            local action_x =  BufferedAction(ThePlayer,nil,  ACTIONS.WALKTO,nil ,pos2)
            if action_x then
                ThePlayer.components.playercontroller:DoAction(action_x)
            end
        end
    end
end




AddComponentPostInit("playercontroller", function(self, inst)
    if inst ~= ThePlayer then return end
    local OldOnControl = self.OnControl                --这里是人物按的时候实现功能
    local controltable = {
        [rawget(GLOBAL, "CONTROL_PRIMARY")] = true,    --CONTROL_PRIMARY
        [rawget(GLOBAL, "CONTROL_SECONDARY")] = false, --CONTROL_SECONDARY
    }
    self.OnControl = function(self, control, down)
        --print('OnControl', down and controltable[control] ~= nil, control, down)
        if (controltable[control] ~= nil or TheInput:IsKeyDown(KEY_LSHIFT))  then
            ---111
            local ent = TheInput:GetWorldEntityUnderMouse()
            local worktable = ClickEquip.control_flag.worktable
            if not ThePlayer.HUD:IsMapScreenOpen() --开了排队论
                and worktable and (worktable.isleftclick == controltable[control]) and worktable.needoncontrol then
                if ClickEquip.control_flag[controltable[control] and 'lmb' or 'rmb'] then --确保是应该切的
                    local tool = INV_util:FindInInv(worktable.toolprefab, worktable.tooltag, worktable.nottag,
                        worktable.toolfn)
                    if tool and ENT_util:FnOrNum(worktable.equiptool, tool) then
                        SendRPCToServer(RPC.ControllerUseItemOnSelfFromInvTile, ACTIONS.EQUIP.code, tool)
                    end
                    if worktable.oncontrolfn then
                        worktable.oncontrolfn({ item = tool, target = ent })
                    end
                    if worktable.needreturn then
                        return
                    end
                end
            end
        end

        -- 处理空格键
        spaceKeyTriggersOperation()

        return OldOnControl(self, control, down)
    end
end)

AddClassPostConstruct("widgets/hoverer", function(inst)
    local oldset = inst.text.SetString
    if oldset then
        function inst.text:SetString(str)
            str = ClickEquip.overridelmbstr or str
            return oldset(self, str)
        end
    end

    local oldsetcolor = inst.text.SetColour
    if oldsetcolor then
        function inst.text:SetColour(...)
            if ClickEquip.overridelmbcolor then
                return oldsetcolor(self, unpack(ClickEquip.overridelmbcolor))
            end
            return oldsetcolor(self, ...)
        end
    end

    --self.text:SetColour
    local oldset2 = inst.secondarytext.SetString
    if oldset2 then
        function inst.secondarytext:SetString(secondarystr)
            if ClickEquip.overridermbcolor and self.SetColour then
                self:SetColour(unpack(ClickEquip.overridermbcolor))
            elseif self.SetColour then
                self:SetColour(unpack(NORMAL_TEXT_COLOUR)) --NORMAL_TEXT_COLOUR
            end
            secondarystr = ClickEquip.overridermbstr or secondarystr
            return oldset2(self, secondarystr)
        end
    end
    local old2Hide = inst.secondarytext.Hide
    if old2Hide then
        function inst.secondarytext:Hide()
            if ClickEquip.overridermbstr then
                self:SetString(ClickEquip.overridermbstr)
                self:Show()
                if ClickEquip.overridermbcolor then
                    self:SetColour(unpack(ClickEquip.overridermbcolor))
                end
                return
            end
            return old2Hide(self)
        end
    end
end)
--让鼠标可以选中noclick的物品
local banprefab = {
    ['farm_soil'] = true,
    ['nutrients_overlay_visual'] = true,
    ['nutrients_overlay'] = true,
    ['icefishing_hole'] = true,
    ['lightrays_canopy'] = true,
    ['archive_orchestrina_base'] = true,
    ['archive_orchestrina_main'] = true,
    ['lavaarena_lootbeacon'] = true,
    ['lavaarena_portal_activefx'] = true,
}
local oldgetent = GLOBAL.Sim.GetEntitiesAtScreenPoint
function GLOBAL.Sim:GetEntitiesAtScreenPoint(...)
    local result = oldgetent(self, ...)
    if result and result[1] == nil and (TheInput:IsKeyDown(KEY_LCTRL) or TheInput:IsKeyDown(KEY_LALT))
        and MOD_util:GetMOption("clickequip_select", true) then
        local change = nil
        local mpos = TheInput:GetWorldPosition()
        for k, v in pairs(TheSim:FindEntities(mpos.x, 0, mpos.z, 5)) do
            v = v.client_forward_target or v
            if v and v:HasTag('NOCLICK') and v.prefab and not banprefab[v.prefab] then
                if v.name == "MISSING NAME" then
                    --print('这个b没有名字', v.prefab)
                    v.name = v.prefab
                end
                v:RemoveTag('NOCLICK')
                change = true
            end
        end
        result = change and oldgetent(self, ...) or result
    end
    return result
end

--------------------模组设置界面-------------------
if MOD_util:CanAddSetting() then
    local pagename = "点击切装备"
    local pageorder = 1
    local buttonname = pagename
    local pagetitle = pagename .. "设置"
    local enabledisableoption = { { text = "禁用", data = false }, { text = "启用", data = true } }
    local function MakeOption(key, describe, default)
        if default == nil then default = true end
        return {
            description = describe,
            key = key,
            default = default,
            options = enabledisableoption,
        }
    end
    MOD_util:CreatePage(pagename, {
        title = pagetitle,
        buttondata = { name = buttonname },
        order = pageorder,
        all_options = {
            {
                description = "启用或禁用点击切装备(此局游戏生效)\n如果你想一直关掉，为什么不去外面关模组呢？",
                onclickfn = function()
                    closefn = not closefn
                end
            },
            MakeOption("clickequip_select", "选择不可选中物品(需要按住CTRL)", true),
        }
    })
end
