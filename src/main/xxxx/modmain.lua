local _G = GLOBAL
local next = _G.next
local unpack = _G.unpack
local require = _G.require
local FRAMES = _G.FRAMES
local ESLOTS = _G.EQUIPSLOTS

----------------------------------------------------------------------------------------------------------------------------------------------------------------
local key = GetModConfigData("MANUAL_REFUEL_KEY") or -1
local hostile_radius = GetModConfigData("HOSTILE_RADIUS") or 5.5
local circle_opacity = GetModConfigData("CIRCLE_OPACITY") or 5.5

local ITEMLIST = require "mod_remiautorefuel_itemlist"
local mod_configs = {
	allow_horrorfuel = GetModConfigData("ALLOW_HORRORFUEL"),
}
for _,data in pairs(ITEMLIST) do
	local item, fuelgroup = unpack(data)
	local regular_pct = GetModConfigData(item.."_regular")
	mod_configs[item] = {
		regular_pct,
		math.min(GetModConfigData(item.."_message"), regular_pct),
		math.min(GetModConfigData(item.."_sound"), regular_pct),
		math.min(GetModConfigData(item.."_forced"), regular_pct),
	}
end

local ITEMDATA = require "mod_remiautorefuel_itemdata"(mod_configs)
local ITEMS, MESSAGES = ITEMDATA.ITEMS, ITEMDATA.MESSAGES

local REFUELTASKS = {}
----------------------------------------------------------------------------------------------------------------------------------------------------------------
local function InGame() 
	return _G.ThePlayer and _G.ThePlayer.HUD and not _G.ThePlayer.HUD:HasInputFocus()
end

local pausetask = nil
local function PauseRefuels(time)
	if pausetask then pausetask:Cancel() end
	pausetask = _G.ThePlayer:DoTaskInTime(time, function() pausetask = nil end)
end

local function UnpauseRefuels()
	if pausetask then pausetask:Cancel() end
	pausetask = nil
end

local soundtask1 = nil
local soundtask2 = nil
local function CancelSoundTasks()
	if soundtask1 then soundtask1:Cancel() end
	soundtask1 = nil
	if soundtask2 then soundtask2:Cancel() end
	soundtask2 = nil
end

local function PlayWarningSounds(player)
	CancelSoundTasks()

	local snd = _G.TheFrontEnd:GetSound()
	snd:PlaySound("dontstarve/HUD/Together_HUD/chat_receive", nil, .85)
	soundtask1 = _G.ThePlayer:DoTaskInTime(.5, function() snd:PlaySound("dontstarve/HUD/Together_HUD/chat_receive", nil, .85) end)
	--soundtask2 = _G.ThePlayer:DoTaskInTime( 1, function() snd:PlaySound("dontstarve/HUD/Together_HUD/chat_receive", nil, .35) end)
end

local function Say(line, color)
	_G.ThePlayer.components.talker:Say(line, nil, nil, nil, nil, color)
end

local msg_percent_part = "\n-- %d%% --"
local function SayMessage(case, item, percent)
	local msgtable = MESSAGES[case]
	local message = msgtable[ITEMS[item.prefab].speech_tag or "generic"] or "MISSING STRING IN MESSAGES."..case
	message = string.format(message, item:GetBasicDisplayName())
	if percent then message = message..string.format(msg_percent_part, percent) end

	Say(message, msgtable.color)
end

local function FindFuel(config)
	local inv = _G.ThePlayer.replica.inventory;
	local items = inv:GetItems()

	for k,v in pairs(items) do
		if config.fuels[v.prefab] then
			return v
		end
	end
	
	local backpack = _G.ThePlayer.replica.inventory:GetOverflowContainer()
	if backpack then
		for k,v in pairs(backpack:GetItems()) do
			if config.fuels[v.prefab] then
				return v
			end
		end
	end
end

local function ShowHostileDetectionRadius()
	local circle = _G.ThePlayer and _G.ThePlayer._hostiledetectionradius
	if not circle then return end
	circle:Show()
end

local function HideHostileDetectionRadius()
	local circle = _G.ThePlayer and _G.ThePlayer._hostiledetectionradius
	if not circle then return end
	circle:Hide()
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
local function CanRefuel(classified, config)
	local pl = _G.ThePlayer

	if classified.percentused:value() <= config.force_refuel_threshold and
    not (config.is_long_refuel and (pl:HasTag("moving") or pl.components.playercontroller:IsAnyOfControlsPressed(_G.CONTROL_MOVE_UP, _G.CONTROL_MOVE_RIGHT,_G.CONTROL_MOVE_DOWN,_G.CONTROL_MOVE_LEFT))) then
    	return true
    end

	if pausetask or
	pl:HasTag("moving") or
	not pl:HasTag("idle") or
	pl.components.playercontroller:IsAnyOfControlsPressed(_G.CONTROL_FORCE_ATTACK, _G.CONTROL_ATTACK) then
	   	return false
	end

	local x,_,z = pl.Transform:GetWorldPosition()
	for _,v in pairs(_G.TheSim:FindEntities(x,0,z,hostile_radius,{"hostile"},{"isdead","stalkerminion"})) do
		if not v:HasTag("shadowcreature") or v.replica.combat and v.replica.combat:GetTarget() == pl then
			return false
		end
	end

	return true
end

local function UnregisterTask(item)
	if item.refueltask then item.refueltask:Cancel() end
	item.refueltask = nil
	REFUELTASKS[item.GUID] = nil

	if next(REFUELTASKS) == nil then HideHostileDetectionRadius() end
end

local function Refuel(item, classified, config)
	local fuel = FindFuel(config)
	if not item:IsValid() or classified.percentused:value() > config.refuel_threshold or not item.replica.inventoryitem:IsHeldBy(_G.ThePlayer) then
		UnregisterTask(item)
	end
	if fuel and CanRefuel(classified, config) then
		_G.ThePlayer.replica.inventory:ControllerUseItemOnItemFromInvTile(item, fuel)
		if _G.TheNet:GetPing() > 150 then PauseRefuels(1) end -- this should help with multiple refuels during lag spikes
	end
end

local function RegisterTask(item, classified, config, fuel)
	if item.refueltask then return end
	item.refueltask = item:DoPeriodicTask(--[[(fuel and 2.5 or 15)*]]FRAMES, function(item) Refuel(item, classified, config) end)
	if fuel then
		REFUELTASKS[item.GUID] = true
		ShowHostileDetectionRadius() 
	end
end

local function PushRefuel(classified)
	local item = classified.entity:GetParent()
	local config = ITEMS[item.prefab]
	if not item.replica.inventoryitem:IsHeldBy(_G.ThePlayer) or not config then return end

	local percent = classified.percentused:value()
	if percent > config.refuel_threshold then return end

	local fuel = FindFuel(config)
	if percent == 0 then if fuel then SayMessage("EXPIRED", item, percent) else SayMessage("EXPIRED_NOFUEL", item, percent) end
	elseif percent <= config.text_warn_threshold then if fuel then SayMessage("WARNING", item, percent) else SayMessage("WARNING_NOFUEL", item, percent) end end
	if percent <= config.sound_warn_threshold then PlayWarningSounds() end
			
	UnpauseRefuels()
	RegisterTask(item, classified, config, fuel)
end

local function PostInit(inst)
	local item = inst.entity:GetParent()
	if not item then return end

	if ITEMS[item.prefab] then
		PushRefuel(inst)
		inst:ListenForEvent('percentuseddirty', PushRefuel)
	end
end
AddPrefabPostInit('inventoryitem_classified', function(inst)
	inst:DoTaskInTime(0, PostInit)
end)

local function MakeCircle(parent, radius, color)
	local inst = _G.CreateEntity()

	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst:AddTag("CLASSIFIED")
	inst:AddTag("NOCLICK")
	inst:AddTag("placer")

	inst.Transform:SetRotation(0)
	local scale = math.sqrt(radius/6.25)
	inst.Transform:SetScale(scale,scale,scale)

	inst.AnimState:SetBank("firefighter_placement")
	inst.AnimState:SetBuild("firefighter_placement")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetLightOverride(1)
	inst.AnimState:SetOrientation(_G.ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(_G.LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3.1)
	
	local r,g,b,a = unpack(color or {1,1,1,0})
	inst.AnimState:SetAddColour(r, g, b, 0)
	inst.AnimState:OverrideMultColour(1, 1, 1, a)

	inst.entity:SetParent(parent.entity)

	return inst
end

local function PlayerPostInit(pl)
	if pl ~= _G.ThePlayer then return end
	pl:ListenForEvent("equip", function(player, data)
		PushRefuel(data.item.replica.inventoryitem.classified)
	end)

	pl._hostiledetectionradius = MakeCircle(pl, hostile_radius, {1,1,0,circle_opacity})
	if next(REFUELTASKS) == nil then pl._hostiledetectionradius:Hide() end
end
AddPlayerPostInit(function(pl)
	pl:DoTaskInTime(0, PlayerPostInit)
end)

--------------- Manual Refuel --------------------
local function ManualRefuel()
	if not InGame() then return end

	local inv = _G.ThePlayer.replica.inventory
	local leastpercent = 200
	local target = nil
	local target_fuel = nil

	for k,equip in pairs(inv:GetEquips()) do 
		if equip and ITEMS[equip.prefab] then
			local percent = equip.replica.inventoryitem.classified.percentused:value()
			local fuel = FindFuel(ITEMS[equip.prefab])
			if fuel and percent < leastpercent then
				leastpercent = percent
				target = equip
				target_fuel = fuel
			end
		end
	end

	if leastpercent > 90 then Say("Cannot repair anything.", {1,1,.2,1}) else _G.ThePlayer.replica.inventory:ControllerUseItemOnItemFromInvTile(target, target_fuel) end
end

_G.TheInput:AddKeyUpHandler(key, ManualRefuel)