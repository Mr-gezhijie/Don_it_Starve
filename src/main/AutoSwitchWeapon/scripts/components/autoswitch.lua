
local CacheService = require "util/cacheservice"
local Autoswitch = Class(function(self, inst)
    self.inst = inst
    self.chipSlot = 15
    self.isSpinning = false -- false是启用，true是关闭
    self.weaponList = {}
    self.toolList = {}
    self.allowedMap = {
        ["orangestaff"] = true, -- 懒人手杖
        ["cane"] = true, -- 步行手杖
        ["walking_stick"] = true,  -- 木手杖
        ["ruins_bat"] = true, -- 铥矿棒
        ["balloonspeed"] = true, -- 敏捷气球
    }
    self.allowedArr = {
        "orangestaff", -- 懒人手杖
        "cane", -- 步行手杖
        "walking_stick",  -- 木手杖
        "ruins_bat", -- 铥矿棒
        "balloonspeed", -- 敏捷气球
    }
end)
local CHS = true

function Autoswitch:SetWeaponList(weaponList) self.weaponList = weaponList end
function Autoswitch:SetToollList(toolList) self.toolList = toolList end
function Autoswitch:IsAutoActivation(isSpinning) self.isSpinning = isSpinning end
function Autoswitch:IsLanguage(language) CHS = language end
function Autoswitch:SetchipSlot(num) self.chipSlot = num end

function Autoswitch:IsInGame()
    --return ThePlayer ~= nil and TheFrontEnd:GetActiveScreen().name == "HUD"
    return not (TheFrontEnd:GetActiveScreen().name:find("HUD") ~= nil and not (ThePlayer.HUD:IsControllerCraftingOpen() or ThePlayer.HUD:IsControllerInventoryOpen()))
end

local ability_x = CHS and "自动切手杖" or "Automatic cutting cane"
local enable_x = CHS and "启用" or "Enable"
local disable_x = CHS and "禁用" or "Disable"

-- 按键入口
function Autoswitch:SwitchSpinning()
    --if not Autoswitch:IsInGame() then
    if Autoswitch:IsInGame() then
        return
    end
    if self.isSpinning then
        -- 禁用
        ChatHistory:AddToHistory(ChatTypes.Message, nil, nil, ability_x, disable_x, PLAYERCOLOURS.GREEN)
        -- ChatHistory:SendCommandResponse('自动切手杖:关闭')
        self.inst:StopUpdatingComponent(self)
        self.isSpinning = false
        self:IconHide()
    else
        -- 启用
        ChatHistory:AddToHistory(ChatTypes.Message, nil, nil, ability_x, enable_x, PLAYERCOLOURS.GREEN)
        -- ChatHistory:SendCommandResponse('自动切手杖:启动')
        self.inst:StartUpdatingComponent(self)
        self.isSpinning = true
        self:IconHint()
    end
end

function Autoswitch:IconHint()
    if ThePlayer and ThePlayer.HUD and ThePlayer.HUD.controls and
            ThePlayer.HUD.controls.inv and ThePlayer.HUD.controls.inv.inv and
            ThePlayer.HUD.controls.inv.inv[self.chipSlot] then
        ThePlayer.HUD.controls.inv.inv[self.chipSlot]:SetBGImage2(
                "images/icon-autoswitch-hint.xml", "icon-autoswitch-hint.tex")
    end
    if ThePlayer and ThePlayer.SoundEmitter then
        ThePlayer.SoundEmitter:PlaySound("dontstarve/HUD/collect_resource")
    end
end

function Autoswitch:IconHide()
    if ThePlayer and ThePlayer.HUD and ThePlayer.HUD.controls and
            ThePlayer.HUD.controls.inv and ThePlayer.HUD.controls.inv.inv and
            ThePlayer.HUD.controls.inv.inv[self.chipSlot] then
        ThePlayer.HUD.controls.inv.inv[self.chipSlot]:SetBGImage2(
                "images/icon-autoswitch-hide.xml", "icon-autoswitch-hide.tex")
    end
    if ThePlayer and ThePlayer.SoundEmitter then
        ThePlayer.SoundEmitter:PlaySound("dontstarve/HUD/collect_resource")
    end
end

-- 组件缓存用途
function Autoswitch:GetCachedItem(item)
    return CacheService:GetCachedItem(item)
end

-- 获取步行速度？
function Autoswitch:GetWalkspeedMult(item)
    local cachedItem = self:GetCachedItem(item)
    return cachedItem
            and cachedItem.components.equippable
            and cachedItem.components.equippable.walkspeedmult
            or 0
end

function Autoswitch:OnUpdate(dt)
    -- 如果在聊天，或者，在骑牛，我们就什么也不做
    if not (ThePlayer.replica.rider.classified ~= nil and ThePlayer.replica.rider.classified.ridermount:value()) then
        if not self:IsInGame() then
            local handItem = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if self:IsAttacking() then
                -- 装备武器
                self:TryEquipWeaponItem()  -- 铥矿棒也得切换
            elseif  self:IsMoving() and ( (handItem and handItem.prefab == "ruins_bat" ) or not self:IsCaneItem(handItem))  then
                -- 手里不是手杖，并且在移动，
                self:TryEquipCaneItem()
            end
        end
    end
end

-- 检查是否为武器
function Autoswitch:IsWeaponItem(item)
    return item and item:HasTag("weapon") and
            not (item.prefab == "cane" or item.prefab == "orangestaff")
end

function Autoswitch:IsCaneItem(item)
    -- 检查物品是否有加速属性
    -- return item and (item.prefab == "cane" or item.prefab == "orangestaff")
    return self:GetWalkspeedMult(item) > 1 and (item and item.prefab ~= "yellowamulet")
end

function Autoswitch:IsToolItem(item)
    return self.toolList[item.prefab] or (item and item:HasTag("dumbbell"))
end

function Autoswitch:IsStatueItem(item)
    return item and item:HasTag("heavy") and item:HasTag("_equippable")
end

function Autoswitch:IsMoving()
    return TheSim:GetDigitalControl(CONTROL_MOVE_LEFT) or
            TheSim:GetDigitalControl(CONTROL_MOVE_RIGHT) or
            TheSim:GetDigitalControl(CONTROL_MOVE_DOWN) or
            TheSim:GetDigitalControl(CONTROL_MOVE_UP)
end

-- 设置攻击距离的
function Autoswitch:CalcRange(weapon)
    return 3 + ((weapon and self.weaponList[weapon.prefab]) or 1)
end

-- 按下攻击后，判断是否可攻击
function Autoswitch:IsAttacking()
    if TheSim:GetDigitalControl(CONTROL_ATTACK) or TheSim:GetDigitalControl(CONTROL_CONTROLLER_ATTACK) or TheSim:GetDigitalControl(CONTROL_MENU_MISC_1) then
        local x, y, z = ThePlayer:GetPosition():Get()
        local weapon = ThePlayer.replica.inventory:GetItemInSlot(self.chipSlot)
        return next(TheSim:FindEntities(x, y, z, self:CalcRange(weapon), nil, {
            "abigail", "player", "structure", "wall"
        }, { "_combat", "hostile" }))
    else
        return false
    end
end

-- 手杖优先级排序TWO
function Autoswitch:AcceleraEquipSort(sortedItems,inventoryList)
    -- 先加速物品
    for prefab, key in pairs(self.allowedArr) do
        for i, itemPrefab in ipairs(inventoryList) do
            if itemPrefab.prefab == key then
                table.insert(sortedItems, inventoryList[i])
                table.remove(inventoryList, i)
                break
            end
        end
    end
end

-- 手杖优先级排序ONE
function Autoswitch:AcceleraEquipFinalSort(inventoryList)
    -- mod的优先，再次是游戏加速装备
    local yesGameEquipmentList = {} -- 游戏里的加速装备
    local gameEquipmentList = {} -- mod里的游戏加速装备

    for  _, item in pairs(inventoryList) do
        if self:IsCaneItem(item) then
            if self.allowedMap[item.prefab] then
                table.insert(yesGameEquipmentList,item)
            else
                table.insert(gameEquipmentList,item)
            end
        end
    end

    self:AcceleraEquipSort(gameEquipmentList,yesGameEquipmentList)

    return gameEquipmentList
end

-- 装备武器
function Autoswitch:TryEquipWeaponItem()
    local item = ThePlayer.replica.inventory:GetItemInSlot(self.chipSlot)
    if self:IsWeaponItem(item) then
        SendRPCToServer(RPC.EquipActionItem, item)
    end
end

function Autoswitch:TryEquipCaneItem()
    -- 不知道因为什么，反正这个获取的是无序的
    local inventoryList = ThePlayer.replica.inventory:GetItems()

    local handItem = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    -- 如果手持XXX则不切换手杖
    if handItem and self:IsToolItem(handItem) then
        return
    end

    -- 如果在背东西，不切手杖
    local bodyItem = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if bodyItem and self:IsStatueItem(bodyItem) then
        return
    end

    -- 筛选优先级
    local gameEquipmentList = self:AcceleraEquipFinalSort(inventoryList)

    -- 最终装备
    for _, item in pairs(gameEquipmentList) do
            SendRPCToServer(RPC.EquipActionItem, item)
            return
    end
end

return Autoswitch
