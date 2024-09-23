Assets = {
	Asset("IMAGE", "images/newframe.tex"),
	Asset("ATLAS", "images/newframe.xml"),
	Asset("IMAGE", "images/menu_small.tex"),
	Asset("ATLAS", "images/menu_small.xml"),
	Asset("IMAGE","images/icons/ae_crafttools.tex"),
	Asset("ATLAS", "images/icons/ae_crafttools.xml"),
	Asset("IMAGE","images/icons/ae_boomcritters.tex"),
	Asset("ATLAS", "images/icons/ae_boomcritters.xml"),
	Asset("IMAGE","images/icons/ae_equipweapon.tex"),
	Asset("ATLAS", "images/icons/ae_equipweapon.xml"),
	Asset("IMAGE","images/icons/ae_lightindark.tex"),
	Asset("ATLAS", "images/icons/ae_lightindark.xml"),
	Asset("IMAGE","images/icons/ae_refuelfires.tex"),
	Asset("ATLAS", "images/icons/ae_refuelfires.xml"),
	Asset("IMAGE","images/icons/ae_repairwalls.tex"),
	Asset("ATLAS", "images/icons/ae_repairwalls.xml"),
	Asset("IMAGE","images/icons/ae_replanttrees.tex"),
	Asset("ATLAS", "images/icons/ae_replanttrees.xml"),
	Asset("IMAGE","images/icons/ae_enablemod.tex"),
	Asset("ATLAS", "images/icons/ae_enablemod.xml"),
	Asset("IMAGE","images/icons/ae_switchtools.tex"),
	Asset("ATLAS", "images/icons/ae_switchtools.xml"),
	Asset("IMAGE","images/icons/ae_crafttools_mouse.tex"),
	Asset("ATLAS", "images/icons/ae_crafttools_mouse.xml"),
	Asset("IMAGE","images/icons/ae_alwaysignoresaps.tex"),
	Asset("ATLAS", "images/icons/ae_alwaysignoresaps.xml"),
	Asset("IMAGE","images/icons/ae_use_nearby_tools.tex"),
	Asset("ATLAS", "images/icons/ae_use_nearby_tools.xml")
}

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
local letsDoDebug = true
local hasEquipped = false;

local Backup_GetActionButtonAction

local actsToUse = {
	ACTIONS.NET,
	ACTIONS.DIG,
	ACTIONS.CHOP,
	ACTIONS.MINE
}
local toolsForActionsGold = {
	MINE = "goldenpickaxe",
	DIG = "goldenshovel",
	CHOP = "goldenaxe"
}
local toolsForActions = {
	MINE = "pickaxe",
	DIG = "shovel",
	CHOP = "axe",
	HAMMER="hammer"
}
local aa_seedTypes = {
	deciduoustree = "acorn",
	evergreen = "pinecone",
	evergreen_sparse = "pinecone",
	twiggytree = "twiggy_nut"
}
local aa_saplingTypes = {
	"pinecone_sapling",
	"acorn_sapling",
	"twiggy_nut_sapling"
}
local restrictedPrefabs = {
	"farm_plant_randomseed",
	"farm_plant_cave_banana", "farm_plant_carrot", "farm_plant_corn", "farm_plant_pumpkin", "farm_plant_eggplant", "farm_plant_durian", "farm_plant_pomegranate", "farm_plant_dragonfruit", "farm_plant_berries", "farm_plant_berries_juicy", "farm_plant_fig", "farm_plant_cactus_meat", "farm_plant_watermelon", "farm_plant_kelp", "farm_plant_tomato", "farm_plant_potato", "farm_plant_asparagus", "farm_plant_onion", "farm_plant_garlic", "farm_plant_pepper",
	
	"berrybush", "berrybush2", "grass", "depleted_grass", "sapling","acorn_sapling", "pinecone_sapling", "twiggy_nut_sapling", "blue_mushroom", "green_mushroom", "red_mushroom", "berrybush_juicy",
	"rabbithole","molehill",
	"bambootree", "bamboo", "depleted_bambootree", "bush_vine", "crabhole",
	"trap_tooth", "twiggytree"
}
local weaponsByPriority = {
	nightsword = 5,
	cutlass = 6,
	ruins_bat = 12,
	spear_obsidian = 13,
	tentaclespike = 14,
	nightstick = 15,
	batbat = 16,
	spear_wathgrithr = 17,
	spear = 18,
	spear_poison = 19,
	peg_leg = 20,
	trident = 21,

	machete = 42, goldenmachete = 42.1, obsidianmachete = 42.2,
	multitool_axe_pickaxe = 43,
	axe = 44, goldenaxe = 44.1,
	pickaxe = 44.2, goldenpickaxe = 44.3,
	hammer = 44.4, pitchfork = 44.5, shovel = 44.6, goldenshovel = 44.7,
	lucy = 46
}
-- lighter = 45, but let's not include it, we aren't that sinister
local rangedWeaponsByPriority = {
	boomerang = 1
}

local modOptions = {
	ENABLED = GetModConfigData("ae_enablemod") > 0,
	IGNORE_RESTRICTIONS = GetModConfigData("autoequipignorerestrictions") > 0,
	IGNORE_SAPS = GetModConfigData("ae_alwaysignoresaps") > 0,
	
	TRY_PICKUP_NEARBY_TOOLS = GetModConfigData("ae_use_nearby_tools") > 0,
	SWITCH_TOOLS_AUTO = GetModConfigData("ae_switchtools") == 1 or GetModConfigData("ae_switchtools") == 2,
	SWITCH_TOOLS_MOUSE = GetModConfigData("ae_switchtools") == 1 or GetModConfigData("ae_switchtools") == 3,
	EQUIP_WEAPONS = GetModConfigData("ae_equipweapon") > 0,
	CRITTERS_WITH_BOOMERANG = GetModConfigData("ae_boomcritters") > 0,
	
	CREATE_LIGHT_IN_DARK = GetModConfigData("ae_lightindark") > 1,
	EQUIP_LIGHT_IN_DARK = GetModConfigData("ae_lightindark") > 0,
	
	ECO_MODE = true,
	CRAFT_TOOLS_MOUSE = GetModConfigData("ae_crafttools_mouse") > 0,
	CRAFT_TOOLS_MOUSE_GOLDEN = GetModConfigData("ae_crafttools_mouse") > 1,
	CRAFT_TOOLS_AUTO = GetModConfigData("ae_crafttools") > 0,
	CRAFT_TOOLS_AUTO_GOLDEN = GetModConfigData("ae_crafttools") > 1,
	
	IGNORE_TRAPS = false,
	REACTIVATE_TRAPS = false,
	
	REPLANT_TREES = GetModConfigData("ae_replanttrees") > 0,
	REFUEL_FIRES = GetModConfigData("ae_refuelfires") > 0,
	REFUEL_FIRES_PRIORITIZE = GetModConfigData("ae_refuelfires"),
	REPAIR_WALLS = GetModConfigData("ae_repairwalls") > 0
};

local function IMS( plyctrl )
	return plyctrl.ismastersim
end

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

local KEYBOARDTOGGLEKEY = GetModConfigData("autoequipopeningamesettings") or "C"
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

local function IsDefaultScreen()
	return GLOBAL.TheFrontEnd:GetActiveScreen().name:find("HUD") ~= nil
		and not(GLOBAL.ThePlayer.HUD:IsControllerCraftingOpen() or GLOBAL.ThePlayer.HUD:IsControllerInventoryOpen())
end

local function ShowSettingsMenu( controls )
	if type(GLOBAL.ThePlayer) ~= "table" or type(GLOBAL.ThePlayer.HUD) ~= "table" then return end
	if not IsDefaultScreen() then return end
	
	GLOBAL.TheFrontEnd:PushScreen(AASC(controls))
end


local function DoEquip( inst, tool )
	if( inst == nil or inst.components == nil or inst.components.playercontroller == nil or tool == nil ) then return end
	
	local plcotrl = inst.components.playercontroller
	if( plcotrl and plcotrl.inst and plcotrl.inst.replica and plcotrl.inst.replica.inventory ) then
		if letsDoDebug then print("- Equipping tool/weapon:",tool) end
		delayUnequipASecond = GetTime()+0.25
		hasEquipped = true;
		
		inst.replica.inventory:UseItemFromInvTile(tool)
	else
		if letsDoDebug then print("Tried to equip, but failed.") end
	end
end

local function DoUnequip( plcotrl, force )
	if( plcotrl and plcotrl.inst and plcotrl.inst.replica and plcotrl.inst.replica.inventory ) then -- plcotrl.autoequip_lastequipped ~= nil
		if letsDoDebug then print("- Unequipping tool/weapon") end
		hasEquipped = false;
		hasEquippedType = "";
		plcotrl.inst.replica.inventory:UseItemFromInvTile(plcotrl.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS))
	end
end

local function GetInventory( inst )
	return ( inst.components and inst.components.playercontroller and inst.components.inventory ) or ( inst.replica and inst.replica.inventory )
end

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

local function CustomFindItems( inst, inv, check )
	if not inst or not inv or not check or ( ( not inv.GetItems or not inv:GetItems() ) and not inv.itemslots ) then if letsDoDebug then print("Something went wrong with the inventory...") end return nil end
	local items = inv.GetItems and inv:GetItems() or inv.itemslots
	local zeItem = {}
	
	for k,v in pairs(items) do
		if check(v) then
			table.insert(zeItem,v)
		end
	end
	
	if inv and inv.GetOverflowContainer then
		items = ( inv:GetOverflowContainer() and inv:GetOverflowContainer().GetItems and inv:GetOverflowContainer():GetItems() ) or ( inv:GetOverflowContainer() and inv:GetOverflowContainer().slots ) or nil
		if items then
			for k,v in pairs(items) do
				if check(v) then
					table.insert(zeItem,v)
				end
			end
		end
	end
	
	return zeItem
end

local function FindTool(inst, inventory, action, checkbp, canswitch )
	if( not canswitch ) then
		return nil;
	end
	return ( inventory and ( inventory.GetItems or inventory.itemslots ) and CustomFindItem( inst, inventory, function(item)
		return item:HasTag(action.id.."_tool") and ( not checkbp or ( checkbp and checkbp(item) ) )
	end) ) or ( inventory and inventory.FindItem and inventory:FindItem(function(item)
		return item:HasTag(action.id.."_tool") and ( not checkbp or ( checkbp and checkbp(item) ) )
	end) ) or ( inventory and inventory.GetOverflowContainer and inventory:GetOverflowContainer() and ( inventory:GetOverflowContainer().GetItems or inventory:GetOverflowContainer().itemslots ) and CustomFindItem( inst, inventory:GetOverflowContainer(), function(item)
		return item:HasTag(action.id.."_tool") and ( not checkbp or ( checkbp and checkbp(item) ) )
	end) ) or nil
end

local function DoMatch( tab, value )
	for k,v in pairs(tab) do
		if( v and value and v == value ) then return true end
	end
	return false
end
local function DoMatchString( tab, value )
	for k,v in pairs(tab) do
		if( string.lower(v) == string.lower(value) ) then return true end
	end
	return false
end

local function FindWorkableEntity(inst, action, radius, ignoreRestriction, usecustomexception)
	if not usecustomexception then
		return GLOBAL.FindEntity(inst, radius, function( entitiy )
			return ( not ignoreRestriction and not DoMatchString(restrictedPrefabs,entitiy.prefab) or ignoreRestriction )
		end, {action.id.."_workable"}, TARGET_EXCLUDE_TAGS)
	elseif usecustomexception and type(usecustomexception) == "table" then
		return GLOBAL.FindEntity(inst, radius, function( entitiy )
			return ( not ignoreRestriction and not DoMatchString(restrictedPrefabs,entitiy.prefab) or ignoreRestriction )
		end, {}, TARGET_EXCLUDE_TAGS, usecustomexception)
	end
end

local function CanAndWhichToolToMake( inst, tool_id, isOverwritting, is_auto )
	if not inst.replica or not inst.replica.builder or not inst.replica.builder.CanBuild or not inst.replica.builder.MakeRecipeFromMenu then return false end
	
	local toolToMake
	
	if( not isOverwritting and ( (is_auto and not modOptions.CRAFT_TOOLS_AUTO_GOLDEN) or (not is_auto and not modOptions.CRAFT_TOOLS_MOUSE_GOLDEN) ) or isOverwritting and ((is_auto and modOptions.CRAFT_TOOLS_AUTO_GOLDEN) or (not is_auto and modOptions.CRAFT_TOOLS_MOUSE_GOLDEN) ) ) then
		if toolsForActionsGold[tool_id] and inst.replica.builder:KnowsRecipe(toolsForActionsGold[tool_id]) and inst.replica.builder:CanBuild(toolsForActionsGold[tool_id]) then
			toolToMake = toolsForActionsGold[tool_id]
		end
		if toolsForActions[tool_id] and inst.replica.builder:KnowsRecipe(toolsForActions[tool_id]) and inst.replica.builder:CanBuild(toolsForActions[tool_id]) then
			toolToMake = toolsForActions[tool_id]
		end
	else
		if toolsForActions[tool_id] and inst.replica.builder:KnowsRecipe(toolsForActions[tool_id]) and inst.replica.builder:CanBuild(toolsForActions[tool_id]) then
			toolToMake = toolsForActions[tool_id]
		end
		if toolsForActionsGold[tool_id] and inst.replica.builder:KnowsRecipe(toolsForActionsGold[tool_id]) and inst.replica.builder:CanBuild(toolsForActionsGold[tool_id]) then
			toolToMake = toolsForActionsGold[tool_id]
		end
	end
	
	return toolToMake ~= nil, toolToMake or nil
end

local function GetAction(inst, target, action, ignorecontrol, searchTarget)
	--print(inst,target,target and target.inst or "error",target and target.components or "error comp",action.id)
	local lrecipe = nil
	local tool
	local thecraftingact
	tool = FindTool(inst,GetInventory(inst), action, nil, modOptions.SWITCH_TOOLS_MOUSE)
	if not tool and modOptions.SWITCH_TOOLS_MOUSE and modOptions.CRAFT_TOOLS_MOUSE and toolsForActions[action.id] then
		local canCraft, whichCraft = CanAndWhichToolToMake(inst,action.id, ( ignorecontrol ~= nil and ignorecontrol ) or ( ignorecontrol == nil and TheInput:IsControlPressed(41) ) or false,false)
		--inst.replica.builder:MakeRecipeFromMenu(AllRecipes[toolsForActions[action.id]])
		if canCraft and whichCraft then
			tool = "craft"
			lrecipe = whichCraft
			thecraftingact = toolsForActions[action.id]
		end
	end
	--print("Finding a tool...", tool or "N/A")
	if not tool then
		return
	elseif type(tool) == "string" then
		tool = nil
	end
	if action == ACTIONS.NET and (not target.components.health or target.components.health:IsDead()) then return end
	if not target:HasTag((action.id).."_workable") then return end --if not target.components.workable and not target.components.hackable then return end
	
	-- if( target.components.hackable and ( ( action == ACTIONS.HACK and not target.components.hackable:IsActionValid(action,false) ) or ( action ~= ACTIONS.HACK and target.components.workable.action ~= action ) ) ) then return end
	-- if( not target:HasTag(action.id.."_workable") ) then return end
	
	local laction = BufferedAction(inst, (not lrecipe and target or nil), action, tool,nil, lrecipe)
	if( lrecipe ) then
		laction.action = ACTIONS.BUILD
		laction.GetActionString = function()
			return "(Craft "..(thecraftingact == lrecipe and "" or "golden " )..thecraftingact..")"
		end
		laction.mod_name = "a-a"
	else
		laction.autoequip = true
	end
	return laction
end

local hasPreferedWeapon = nil
local function IsRangedWeapon( weap ) return ( weap and weap.replica and weap.replica._ and weap.replica._.inventoryitem and weap.replica._.inventoryitem.classified and weap.replica._.inventoryitem.classified.attackrange and weap.replica._.inventoryitem.classified.attackrange:value() > 0 ) or false end
-- Used percent - ThePlayer.replica.inventory:GetItems()[2].replica._.inventoryitem.classified.percentused:value()
local function GetBestWeapon(inst, canBeRanged, ishunting, ignorehand)
	if letsDoDebug then print("- Start finding best weapon -") end
	local inhands = GetInventory(inst):GetEquippedItem(EQUIPSLOTS.HANDS)
	local bestweapon = false
	local isranged
	-- do not replace a ranged weapon
	if inhands and not ignorehand or (hasEquipped and hasEquippedType == "weapon") then return false end
	
	if hasPreferedWeapon and hasPreferedWeapon ~= "" then
	
		local customweapon = GetInventory(inst).FindItem and GetInventory(inst):FindItem(function(item)
			return item.prefab == hasPreferedWeapon
		end) or CustomFindItem(inst, GetInventory(inst), function(item)
			return item.prefab == hasPreferedWeapon
		end)
		
		if customweapon then
			return customweapon, false
		end
	
	end
	
	local weapons = GetInventory(inst).FindItems and GetInventory(inst):FindItems(function(item)
			return item:HasTag("weapon") and ( item.prefab ~= "lighter" )
		end) or CustomFindItems(inst, GetInventory(inst), function(item)
			return item:HasTag("weapon") and ( item.prefab ~= "lighter" )
		end)
	if weapons then
		local highest = 100000
		for k,v in pairs(weapons) do
			if v and ( IsRangedWeapon(v) and canBeRanged or not IsRangedWeapon(v) ) then
				if not bestweapon or ( weaponsByPriority and weaponsByPriority[v.prefab] and weaponsByPriority[v.prefab] < highest ) then
					-- print("switching to "..v.prefab)
					bestweapon = v
					if( weaponsByPriority and weaponsByPriority[v.prefab] and weaponsByPriority[v.prefab] ) then highest = weaponsByPriority[v.prefab] end
					if letsDoDebug then print("Found acceptable weapon", v or "N/A") end
				elseif not bestweapon or ( rangedWeaponsByPriority and rangedWeaponsByPriority[v.prefab] and rangedWeaponsByPriority[v.prefab] < highest ) then
					-- print("switching to "..v.prefab)
					isranged = true
					bestweapon = v
					if( rangedWeaponsByPriority and rangedWeaponsByPriority[v.prefab] and rangedWeaponsByPriority[v.prefab] ) then highest = rangedWeaponsByPriority[v.prefab] end
					if letsDoDebug then print("Found acceptable weapon", v or "N/A") end
				end
				if( modOptions.CRITTERS_WITH_BOOMERANG and ishunting and ( canBeRanged and rangedWeaponsByPriority and rangedWeaponsByPriority[v.prefab] or not canBeRanged ) ) then
					isranged = true
					bestweapon = v
					break
				end
			end
		end
	end

	if inhands and bestweapon and bestweapon == inhands then return false end

	return bestweapon, isranged or false
end

local function AutoEquipItem(playercontroller, bufferedaction, isranged)
	if not bufferedaction then return end
	if not bufferedaction.invobject then return end
	if not playercontroller.autoequip_lastequipped and not isranged then
		playercontroller.autoequip_lastequipped = GetInventory(playercontroller.inst):GetEquippedItem(EQUIPSLOTS.HANDS)
		if not playercontroller.autoequip_lastequipped then playercontroller.autoequip_lastequipped = "empty" end
	end
	
	DoEquip(playercontroller.inst,bufferedaction.invobject)
end

local function DoAutoEquipItem( playercontroller, tool, deta )
	if letsDoDebug then print("Forcing equip of: ",playercontroller,tool,deta) end
	if deta ~= nil then
		local tempAction = BufferedAction(playercontroller.inst, playercontroller.inst, ACTIONS.EQUIP, tool)
		table.insert(tempAction.onsuccess,deta);
		AutoEquipItem(playercontroller, tempAction, false)
	else
		local tempAction = BufferedAction(playercontroller.inst, playercontroller.inst, ACTIONS.EQUIP, tool)
		AutoEquipItem(playercontroller, tempAction, false)
	end
end

local function AutoEquipBestWeapon(playercontroller, target, isForced, bufferedaction)
	local bestweapon
	local isranged

	if(hasEquipped == true and hasEquippedType == "weapon") then
		return;
	end

	if( target ) then
		if( target:HasTag("hostile") or target:HasTag("monster") or target:HasTag("largecreature") ) then
			bestweapon, isranged = GetBestWeapon(playercontroller.inst, false, false, modOptions.EQUIP_WEAPONS)
		elseif( target:HasTag("insect") or target:HasTag("smallcreature") or target:HasTag("flying") ) then
			bestweapon, isranged = GetBestWeapon(playercontroller.inst, true, true )
		else
			bestweapon, isranged = GetBestWeapon(playercontroller.inst, false, false, modOptions.EQUIP_WEAPONS)
		end
	else
		bestweapon, isranged = GetBestWeapon(playercontroller.inst, false)
	end
	if letsDoDebug then print("Found a best weapon", bestweapon or "N/A") end
	if not bestweapon or bestweapon == GetInventory(playercontroller.inst):GetEquippedItem(EQUIPSLOTS.HANDS) then return end
	bufferedaction.invobject = bestweapon
	hasEquippedType = "weapon";
	AutoEquipItem(playercontroller, bufferedaction, isranged)
end

local tookLightOut = nil
local firstCheckedForDarkness = nil
local function CheckIfInDarkness( inst )
	if( not firstCheckedForDarkness ) then
		if letsDoDebug then print("Oh, it's dark...") end
		firstCheckedForDarkness = GetTime()
	elseif( firstCheckedForDarkness and GetTime() > (firstCheckedForDarkness+2) ) then
		if letsDoDebug then print("That's it, I'm equipping light!") end
		firstCheckedForDarkness = nil
		
		local possibleLights = CustomFindItem(inst, GetInventory(inst), function(item) return item:HasTag("lighter") end) -- For now, just use whatever can be found
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

local function CheckIfOutOfDarkness( inst )
	if(tookLightOut == nil) then return end

	local tool = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS);
	if(tool ~= nil and tool:HasTag("lighter")) then
		inst.replica.inventory:UseItemFromInvTile(inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS))
		tookLightOut = nil;
	end
end

local CreateEntity = GLOBAL.CreateEntity

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

-- attached to playercontroller.OnUpdate
local function OnUpdate(playercontroller, dt)
	if not playercontroller:IsEnabled() then return end
	if modOptions.EQUIP_LIGHT_IN_DARK then
		if GLOBAL.TheWorld.state.isnight and not GLOBAL.TheWorld.state.isfullmoon and playercontroller.inst.LightWatcher and not playercontroller.inst.LightWatcher:IsInLight() then CheckIfInDarkness(playercontroller.inst) elseif(  not (GLOBAL.TheWorld.state.isnight and not GLOBAL.TheWorld.state.isfullmoon and playercontroller.inst.LightWatcher and not playercontroller.inst.LightWatcher:IsInLight()) and firstCheckedForDarkness ) then firstCheckedForDarkness = nil elseif(not GLOBAL.TheWorld.state.isnight and tookLightOut ~= nil) then CheckIfOutOfDarkness(playercontroller.inst) end
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

local function GenerateNewBufferedAction( playercontroller, doforce, ignore_targets, musthave, donthave )
	local successflag, retvalue = pcall(Backup_GetActionButtonAction, playercontroller, doforce or nil, ignore_targets or nil, musthave or nil, donthave or nil)
	if( not successflag ) then
		if letsDoDebug then print("Something went wrong...", retvalue) end
		return nil
	else
		return retvalue
	end
end

local alreadyCheckedMods = {}
local function CustomCheckForMod( lemodname )
	if letsDoDebug then print("Checking for mod:",lemodname) end

	if( alreadyCheckedMods[lemodname] ~= nil ) then
		
		return alreadyCheckedMods[lemodname]
	elseif( alreadyCheckedMods[lemodname] == nil ) then
		local KnownModIndex = KnownModIndex or GLOBAL.KnownModIndex
		alreadyCheckedMods[lemodname] = ( ( KnownModIndex:GetModActualName(lemodname) and true ) or false )
		
		return alreadyCheckedMods[lemodname]
	end
	
	return false
end

local RPC = GLOBAL.RPC
local SendRPCToServer = GLOBAL.SendRPCToServer

local function DoCustomModifications( buffered, playercontroller, ignore )
	if not buffered or not buffered.action or not buffered.target or not buffered.target.prefab then if letsDoDebug then print("Eh, not all needed info was here", buffered,buffered.action,buffered.target,buffered.target.prefab) end return end
	if letsDoDebug then print("= Doing custom modifications:", buffered,buffered.action,buffered.target,buffered.target.prefab) end
	if( buffered.target.prefab == "trap_teeth" and buffered.action == ACTIONS.PICKUP ) then
		if( buffered.target:HasTag("minesprung") ) then
			buffered.action = ACTIONS.RESETMINE
			local position = TheInput:GetWorldPosition()
			local controlmods = playercontroller:EncodeControlMods()
			buffered.preview_cb = function()
				SendRPCToServer(RPC.RightClick, buffered.action.code, position.x, position.z, buffered.target, false, controlmods, nil, buffered.action.mod_name)
			end
			
			playercontroller:DoAction(buffered)
			
			return "end"
		elseif( not buffered.target:HasTag("minesprung") and not ignore and modOptions.IGNORE_TRAPS ) then
			if letsDoDebug then print("Finding new buffer...") end
			local x, y, z = playercontroller.inst.Transform:GetWorldPosition()
			local ignoreTraps = TheSim:FindEntities(x, y, z, 8, nil, {"trapsprung","minesprung"}, {"trap"})
			return GenerateNewBufferedAction(playercontroller, nil, ignoreTraps)
		end
	elseif( buffered.target.prefab == "trap" and buffered.action == ACTIONS.PICKUP and not ignore and modOptions.IGNORE_TRAPS ) then
		if letsDoDebug then print("Finding new buffer...") end
		local x, y, z = playercontroller.inst.Transform:GetWorldPosition()
		local ignoreTraps = TheSim:FindEntities(x, y, z, 8, nil, {"trapsprung","minesprung"}, {"trap"})
		return GenerateNewBufferedAction(playercontroller, nil, ignoreTraps)
		
	elseif( buffered.action == ACTIONS.PICK and ( (buffered.target.prefab == "grass") or (buffered.target.prefab == "sapling") or (buffered.target.prefab == "reeds") ) and CustomCheckForMod("Scythestest") and not ignore ) then
		if letsDoDebug then print("Finding new buffer...") end
		
		local tool
		if( inst.replica and inst.replica.inventory and inst.replica.inventory.GetEquippedItem and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ) then
			tool = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		elseif( inst.components and inst.components.inventory ) then
			tool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		end
		if ( not tool or ( tool and not tool:HasTag("mower") ) ) and ( inst.components and inst.components.playercontroller ) then
			
			local thetool = CustomFindItem(inst, GetInventory(inst), function(itm) return itm:HasTag("mower") end)
			if thetool then
				if letsDoDebug then print("Force equipping sychte") end
				
				DoAutoEquipItem(inst.components.playercontroller, thetool, doonsuccess )
				buffered.invobject = thetool
				return buffered
			end
		else
			if letsDoDebug then print("Already has sychte equipped") end
		end
		
	elseif( buffered.target.prefab and table.contains(aa_saplingTypes,buffered.target.prefab) and buffered.action == ACTIONS.DIG and not ignore and modOptions.IGNORE_SAPS ) then
		return false
	end
	return buffered
end

local lastActionDone

local doTimeDelay = 0
local doNext = 0
local forceNextAction = false
-- attached to playercontroller.GetActionButtonAction
local function GetActionButtonAction(playercontroller, forced, bufferedaction)
	if not playercontroller or not playercontroller:IsEnabled() then return end
	--print("start action 2")
	
	if( doTimeDelay and doTimeDelay > GetTime() ) then
		return
	elseif( doTimeDelay and doTimeDelay <= GetTime() ) then
		doTimeDelay = nil
	end
	
	if( playercontroller:IsDoingOrWorking() ) then if letsDoDebug then print("[Is working!]") end return end
	
	if( forceUnequipTool and lastActionDone and forceUnequipTool == lastActionDone ) then
		DoUnequip(playercontroller)
		forceUnequipTool = nil
	end
	
	if letsDoDebug then print("\n------------------------------------------------------") end
	
	lastActionDone = bufferedaction and bufferedaction.action or nil
	
	if( forcePlantSapling and modOptions.REPLANT_TREES ) then
		if letsDoDebug then print("Doing plant") end
		if( forcePlantSapling[1] and forcePlantSapling[2] and ( not forcePlantSapling[3] or forcePlantSapling[3] and not forcePlantSapling[3]:IsValid() ) and aa_seedTypes and aa_seedTypes[forcePlantSapling[1]] and GetInventory(playercontroller.inst) and CustomFindItem(playercontroller.inst, GetInventory(playercontroller.inst), function(itm) return itm.prefab and itm.prefab == aa_seedTypes[forcePlantSapling[1]] end) ~= nil ) then
			UpdateTreePlacer(forcePlantSapling)
			
			local seedType = aa_seedTypes[forcePlantSapling[1]]
			local seed = CustomFindItem(playercontroller.inst, GetInventory(playercontroller.inst), function(itm) return itm.prefab and itm.prefab == seedType end)
			if( GLOBAL.TheWorld.Map:CanDeployPlantAtPoint(forcePlantSapling[2], seed) ) then
				if letsDoDebug then print("Planting plant") end
				local pos = forcePlantSapling[2]
				if( IMS(playercontroller) ) then
					local act = BufferedAction( playercontroller.inst, nil, ACTIONS.DEPLOY, seed, pos, nil )
					playercontroller.inst.components.locomotor:PushAction(act,true)
				else
					local act = BufferedAction( playercontroller.inst, nil, ACTIONS.DEPLOY, seed, pos, nil )
					act.preview_cb = function()
						--SendRPCToServer(RPC.RightClick, act.action.code, pos.x, pos.z, act.target, false, controlmods, nil, act.action.mod_name)
						SendRPCToServer(RPC.ControllerActionButtonDeploy, seed, pos.x, pos.z)
					end
					playercontroller:DoAction(act)
				end
				
				forcePlantSapling = nil
				UpdateTreePlacer(nil,true)
				doTimeDelay = GetTime() + 0.75
				return
			else
				if letsDoDebug then print("Searching for pickup for plant") end
				local pos = forcePlantSapling[2]
				
				local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, {"_inventoryitem"})
				if ents and ents[1] ~= nil then
					if letsDoDebug then print("Found, now running") end
					return GenerateNewBufferedAction(playercontroller, ents[1])
				end
			end
		elseif( not forcePlantSapling[1] or not forcePlantSapling[2] ) then
			forcePlantSapling = nil
			UpdateTreePlacer(nil,true)
		end
	elseif( forceResetTrap and modOptions.REACTIVATE_TRAPS ) then
		-- trapsprung
		if letsDoDebug then print("Doing re-trap") end
		if( forceResetTrap[1] and forceResetTrap[2] and GetInventory(playercontroller.inst) and CustomFindItem(playercontroller.inst, GetInventory(playercontroller.inst), function(itm) return itm.prefab and itm.prefab == forceResetTrap[1] end) ~= nil ) then
			local seed = CustomFindItem(playercontroller.inst, GetInventory(playercontroller.inst), function(itm) return itm.prefab and itm.prefab == forceResetTrap[1] end)
			if( seed ) then
				if letsDoDebug then print("Resetting trap") end
				local pos = forceResetTrap[2]
				if( IMS(playercontroller) ) then
					local act = BufferedAction( playercontroller.inst, nil, ACTIONS.DROP, seed, pos, nil )
					playercontroller.inst.components.locomotor:PushAction(act,true)
				else
					local act = BufferedAction( playercontroller.inst, nil, ACTIONS.DROP, seed, pos, nil )
					act.preview_cb = function()
						SendRPCToServer(RPC.DropItemFromInvTile, seed, true)
					end
					playercontroller:DoAction(act)
				end
				
				forceResetTrap = nil
				doTimeDelay = GetTime() + 0.75
				return
			end
		elseif( not forceResetTrap[1] or not forceResetTrap[2] ) then
			forceResetTrap = nil
		end
	end
	
	if( bufferedaction and bufferedaction.action and bufferedaction.action.id and bufferedaction.action == ACTIONS.CATCH ) then
		if letsDoDebug then print("No matter what, always catch before anything else!") end
		return bufferedaction
	end
	
	--print("start action 3")
	if letsDoDebug then print("Starting to find action!") end
	if letsDoDebug then print("Starting with tool/weapon:",playercontroller.inst.replica and playercontroller.inst.replica.inventory and playercontroller.inst.replica.inventory.GetEquippedItem and playercontroller.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or "None") end
	
	local shouldIgnoreRestrictions = modOptions.IGNORE_RESTRICTIONS and playercontroller:IsControlPressed(41)
	
	if letsDoDebug then print("Pre-Buffered info:",bufferedaction or "N/A") end
	
	
	if bufferedaction ~= nil then bufferedaction = DoCustomModifications(bufferedaction,playercontroller,shouldIgnoreRestrictions) end
	if type(bufferedaction) == "string" and bufferedaction == "end" then return end
	
	if letsDoDebug then print("Post-Buffered info:",bufferedaction or "N/A") end
	
	if letsDoDebug then print("[Trying to find a new action]") end
	
	local tool
	local target
	
	
	local shouldMakeToolLater
	local shouldGetToolLater

	if letsDoDebug then print("Doing economic mode") end

	local foundSomething
	local canUseActions = {}
	local toolsOfActions = {}
	local actionOfChoice
	
	for k, v in pairs(actsToUse) do
		if v and v.id then
			local letool
			
			if( v == ACTIONS.CHOP ) then
				letool = FindTool(playercontroller.inst,GetInventory(playercontroller.inst), ACTIONS.CHOP, function(itm) return ( itm.prefab and itm.prefab == "lucy" ) end,modOptions.SWITCH_TOOLS_AUTO)
			end
			
			if not letool then letool = FindTool(playercontroller.inst,GetInventory(playercontroller.inst), v, nil, modOptions.SWITCH_TOOLS_AUTO) end
			
			if modOptions.SWITCH_TOOLS_AUTO and letool then
				table.insert(canUseActions, (v.id).."_workable")
				toolsOfActions[(v.id).."_workable"] = letool
				foundSomething = true
			elseif modOptions.SWITCH_TOOLS_AUTO and modOptions.TRY_PICKUP_NEARBY_TOOLS and GLOBAL.FindEntity(playercontroller.inst, 8, function( entitiy ) return true end, {"weapon",(v.id).."_tool"}, TARGET_EXCLUDE_TAGS) then
				table.insert(canUseActions, (v.id).."_workable")
				local canCraft, makeCraft = CanAndWhichToolToMake(playercontroller.inst,v.id,nil,true)
				toolsOfActions[(v.id).."_workable"] = "pickup"
				foundSomething = true
				if letsDoDebug then print("Can pick-up tool") end
			elseif modOptions.SWITCH_TOOLS_AUTO and modOptions.CRAFT_TOOLS_AUTO and CanAndWhichToolToMake(playercontroller.inst,v.id) then
				table.insert(canUseActions, (v.id).."_workable")
				local canCraft, makeCraft = CanAndWhichToolToMake(playercontroller.inst,v.id,nil,true)
				toolsOfActions[(v.id).."_workable"] = "craft"
				foundSomething = true
				if letsDoDebug then print("Can make a tool") end
			end
		end
	end
	
	if foundSomething then
	
		if letsDoDebug then
			print("Search gave:")
			for k,v in pairs(canUseActions) do
				print("-",v)
			end
		end
		
		target = FindWorkableEntity(playercontroller.inst, nil, playercontroller.directwalking and 3 or 6, shouldIgnoreRestrictions, canUseActions)
		if target and target ~= nil then
			for k, v in pairs(actsToUse) do
				local leid = v.id
				if( target and target:HasTag(leid.."_workable") and toolsOfActions[leid.."_workable"] ~= nil ) then
					if modOptions.TRY_PICKUP_NEARBY_TOOLS and type(toolsOfActions[leid.."_workable"]) == "string" and toolsOfActions[leid.."_workable"] == "pickup" then
						shouldGetToolLater = leid
					elseif modOptions.CRAFT_TOOLS_AUTO and type(toolsOfActions[leid.."_workable"]) == "string" and toolsOfActions[leid.."_workable"] == "craft" then
						shouldMakeToolLater = leid
					elseif modOptions.SWITCH_TOOLS_AUTO and toolsOfActions[leid.."_workable"] and type(toolsOfActions[leid.."_workable"]) ~= "string" then
						tool = toolsOfActions[leid.."_workable"]
						actionOfChoice = v
					end
				end
			end
			
			if target and tool and actionOfChoice then
				playercontroller.inst.autoequip_actiontodo = actionOfChoice
			end
		end
	
	else
	
		if letsDoDebug then print("Found nothing...") end
	
	end
	
	if letsDoDebug then print("Economic mode ending") end
	
	if letsDoDebug then print("Result:",target or "n/a",tool or "n/a", target and bufferedaction and bufferedaction.target and bufferedaction.target == target or "n/a" ) end
	
	if( target and shouldMakeToolLater ) then
		if( bufferedaction and bufferedaction.target ) then
			if playercontroller.inst:GetDistanceSqToInst(bufferedaction.target) > playercontroller.inst:GetDistanceSqToInst(target) then
				local canCraft, doCraft = CanAndWhichToolToMake(playercontroller.inst,shouldMakeToolLater,nil,true)
				if canCraft and doCraft then
					playercontroller.inst.replica.builder:MakeRecipeFromMenu(AllRecipes[doCraft])
				end
				return
			end
		else
			local canCraft, doCraft = CanAndWhichToolToMake(playercontroller.inst,shouldMakeToolLater,nil,true)
			if canCraft and doCraft then
				playercontroller.inst.replica.builder:MakeRecipeFromMenu(AllRecipes[doCraft])
			end
			return
		end
	elseif( target and shouldGetToolLater ) then
		local closestTool = GLOBAL.FindEntity(playercontroller.inst, 8, function( entitiy ) return true end, {"weapon",shouldGetToolLater.."_tool"}, TARGET_EXCLUDE_TAGS)
		if closestTool then
			local pos = closestTool:GetPosition()
			if( bufferedaction and bufferedaction.target ) then
				if playercontroller.inst:GetDistanceSqToInst(bufferedaction.target) > playercontroller.inst:GetDistanceSqToInst(target) then
					return GenerateNewBufferedAction(playercontroller, closestTool)
				end
			else
				return GenerateNewBufferedAction(playercontroller, closestTool)
			end
		end
	end
	
	if tool and target and ( not bufferedaction or ( bufferedaction and bufferedaction.target ~= target ) ) then
	
		if letsDoDebug then print("Possible new action: ",target,tool) end
	
		if bufferedaction and bufferedaction.target and bufferedaction.action then
			if playercontroller.inst:GetDistanceSqToInst(bufferedaction.target) < playercontroller.inst:GetDistanceSqToInst(target) then
				if letsDoDebug then print("Doing action 1") end
				playercontroller.inst.autoequip_prioNextTarget = bufferedaction.target
				playercontroller.inst.autoequip_prioNextAct = bufferedaction.action
				doTimeDelay = GetTime()+0.25
				return bufferedaction
			else
				if letsDoDebug then print("Another action",tostring(tool), tostring(target), "is closer") end
			end
		else
			if letsDoDebug then print("Doing new action", tostring(tool), tostring(target)) end
		end
	
		if not playercontroller.autoequip_lastequipped then
			playercontroller.autoequip_lastequipped = GetInventory(playercontroller.inst):GetEquippedItem(EQUIPSLOTS.HANDS)
			if not playercontroller.autoequip_lastequipped then playercontroller.autoequip_lastequipped = "empty" end
		end
		
		--playercontroller.inst.components.locomotor:PushAction(BufferedAction(playercontroller.inst, target, playercontroller.inst.autoequip_actiontodo, tool), true)
		
		local newAction = BufferedAction(playercontroller.inst, target, ACTIONS.WALKTO)
		
		if( playercontroller.inst.autoequip_actiontodo and GetInventory(playercontroller.inst):GetEquippedItem(EQUIPSLOTS.HANDS) and type(GetInventory(playercontroller.inst):GetEquippedItem(EQUIPSLOTS.HANDS)) == "table" and GetInventory(playercontroller.inst):GetEquippedItem(EQUIPSLOTS.HANDS):HasTag((playercontroller.inst.autoequip_actiontodo.id).."_tool") ) then
			if letsDoDebug then print("Well... you already have the needed tool, so get started.") end
			playercontroller.inst.autoequip_prioNextTarget = target
			playercontroller.inst.autoequip_prioNextAct = playercontroller.inst.autoequip_actiontodo
			doNext = 4
		else
			--playercontroller.inst.components.locomotor:PushAction(BufferedAction(playercontroller.inst, nil, ACTIONS.EQUIP, tool), true)
			DoEquip(playercontroller.inst,tool) --todo : Check for dropping tool
			playercontroller.inst.autoequip_prioNextTarget = target
			playercontroller.inst.autoequip_prioNextAct = playercontroller.inst.autoequip_actiontodo
			if( playercontroller.inst.autoequip_prioNextAct.id == "DIG" or playercontroller.inst.autoequip_prioNextAct.id == "dig" ) then
				forceUnequipTool = playercontroller.inst.autoequip_prioNextAct
				if target and target.GetPosition and target.prefab and aa_seedTypes and aa_seedTypes[target.prefab] and modOptions.REPLANT_TREES then
					local thepos = target:GetPosition()
					if thepos then
						forcePlantSapling = {
							target.prefab,
							thepos,
							target
						}
						if letsDoDebug then print("SEED-TYPE:", target.prefab) end
						forceNextAction = {"unequip"}
						--forceNextAction = {"tree_root"}
					else
						forceNextAction = {"unequip"}
					end
				else
					forceNextAction = {"tree"}
				end
			end
			if letsDoDebug then print("Equipped tool, now we just have to use it next.", ACTIONS.EQUIP, tool) end
			doTimeDelay = GetTime()+0.25
		end
		
		return newAction

	else
	
		--if bufferedaction then if letsDoDebug then print("Doing another action") end doTimeDelay = GetTime()+1 return bufferedaction end
		if bufferedaction then
			if letsDoDebug then print("Doing another action") end
			if bufferedaction and bufferedaction.target and bufferedaction.action then
				if modOptions.REPLANT_TREES and bufferedaction.action == ACTIONS.DIG and bufferedaction.target.GetPosition and bufferedaction.target.prefab and aa_seedTypes and aa_seedTypes[bufferedaction.target.prefab] then
					local thepos = bufferedaction.target:GetPosition()
					if thepos then
						forcePlantSapling = {
							bufferedaction.target.prefab,
							thepos,
							target
						}
						UpdateTreePlacer(forcePlantSapling)
						
						if letsDoDebug then print("SEED-TYPE:", bufferedaction.target.prefab) end
					end
				elseif bufferedaction.action == ACTIONS.CHECKTRAP and bufferedaction.target.GetPosition and bufferedaction.target.prefab and modOptions.REACTIVATE_TRAPS then
					local thepos = bufferedaction.target:GetPosition()
					if thepos then
						forceResetTrap = {
							bufferedaction.target.prefab,
							thepos
						}
						doTimeDelay = GetTime() + 0.75
					end
				end
			end
				
			return bufferedaction
		end
	end
end

local function DoAction(playercontroller, bufferedaction)
	if not bufferedaction then return end
	if not bufferedaction.action then return end
	if bufferedaction.action == ACTIONS.ATTACK and modOptions.EQUIP_WEAPONS then
		AutoEquipBestWeapon(playercontroller, bufferedaction.target or nil, TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_ATTACK), bufferedaction)
		return
	end
	
	if letsDoDebug then
		print("\n-------------------------------------\n",playercontroller,bufferedaction,bufferedaction.action.id)
		for k,v in pairs(bufferedaction) do
			print("-",k,v)
		end
	end
	
	if bufferedaction.action == ACTIONS.BUILD and bufferedaction.mod_name and bufferedaction.mod_name == "a-a" then
		local inst = playercontroller.inst
		if inst.replica and inst.replica.builder and inst.replica.builder.CanBuild and inst.replica.builder.MakeRecipeFromMenu and inst.replica.builder:KnowsRecipe(bufferedaction.recipe) and inst.replica.builder:CanBuild(bufferedaction.recipe) then
			inst.replica.builder:MakeRecipeFromMenu(AllRecipes[bufferedaction.recipe])
			return
		end
	end
	
	if bufferedaction.action == ACTIONS.REPAIR and bufferedaction.mod_name and bufferedaction.mod_name == "a-a" then
		if not playercontroller.ismastersim then
            local position = playercontroller.inst:GetPosition()
            local mouseover = bufferedaction.target
            local controlmods = playercontroller:EncodeControlMods()
            if playercontroller:CanLocomote() then
				if letsDoDebug then print("Ran shit") end
				bufferedaction.mod_name = ""
                bufferedaction.preview_cb = function()
					SendRPCToServer(RPC.ControllerUseItemOnSceneFromInvTile, bufferedaction.action.code, bufferedaction.invobject, bufferedaction.target, nil)
				end
				return bufferedaction
            end
        end
	end
	
	if ( bufferedaction.action == ACTIONS.ADDFUEL or bufferedaction.action == ACTIONS.ADDWETFUEL ) and bufferedaction.mod_name and bufferedaction.mod_name == "a-a" then
		if not playercontroller.ismastersim then
            local position = playercontroller.inst:GetPosition()
            local mouseover = bufferedaction.target
            local controlmods = playercontroller:EncodeControlMods()
            if playercontroller:CanLocomote() then
				if letsDoDebug then print("Ran shit") end
				bufferedaction.mod_name = ""
                bufferedaction.preview_cb = function()
					SendRPCToServer(RPC.ControllerUseItemOnSceneFromInvTile, bufferedaction.action.code, bufferedaction.invobject, bufferedaction.target, nil)
				end
				return bufferedaction
            end
        end
	end
	
	if bufferedaction.action == ACTIONS.COOK and bufferedaction.mod_name and bufferedaction.mod_name == "a-a" then
		if not playercontroller.ismastersim then
            local position = playercontroller.inst:GetPosition()
            local mouseover = bufferedaction.target
            local controlmods = playercontroller:EncodeControlMods()
            if playercontroller:CanLocomote() then
				if letsDoDebug then print("Ran shit") end
				bufferedaction.mod_name = ""
                bufferedaction.preview_cb = function()
					SendRPCToServer(RPC.ControllerUseItemOnSceneFromInvTile, bufferedaction.action.code, bufferedaction.invobject, bufferedaction.target, nil)
				end
				return bufferedaction
            end
        end
	end
	
	if not bufferedaction.autoequip then return end
	if not bufferedaction.invobject then return end
	if playercontroller.inst and GetInventory and GetInventory(playercontroller.inst) and GetInventory(playercontroller.inst).GetEquippedItem and GetInventory(playercontroller.inst):GetEquippedItem(EQUIPSLOTS.HANDS) and GetInventory(playercontroller.inst):GetEquippedItem(EQUIPSLOTS.HANDS) == bufferedaction.invobject then return end
	AutoEquipItem(playercontroller, bufferedaction)
end

-- attached to playercontroller.DoAttackButton
local function DoAttackButton(playercontroller)
	local isForced = TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_ATTACK)
	local target = playercontroller:GetAttackTarget(isForced)
	if target and playercontroller.inst.replica.combat.target ~= target and modOptions.EQUIP_WEAPONS then
		local bufferedaction = BufferedAction(playercontroller.inst, target, ACTIONS.ATTACK)
		AutoEquipBestWeapon(playercontroller, target, isForced, bufferedaction)
		-- playercontroller.inst.components.locomotor:PushAction(bufferedaction, true)
	end
end

-- attached to playercontroller.GetClickActions
local function GetClickActions(playeractionpicker,position, target, actions, spellbook)
	if not target then return actions end
	if not actions then return actions end
	if TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then return actions end
	if letsDoDebug then print(tostring(actions)) end
	local action
	-- print("Getting info...",target,actions)
	for k,v in ipairs(actions) do
		if letsDoDebug then print("Actionn: " .. tostring(v.action.str)) end
		if v.action == ACTIONS.ATTACK then
			action = GetAction(playeractionpicker.inst, target, ACTIONS.NET)
		end
		if not action and v.action == ACTIONS.ATTACK then
			action = GetAction(playeractionpicker.inst, target, ACTIONS.NET)
		end
		if not action and (v.action == ACTIONS.LOOKAT or v.action == ACTIONS.WALKTO) then
			action = GetAction(playeractionpicker.inst, target, ACTIONS.CHOP)
		end
		if not action and (v.action == ACTIONS.LOOKAT or v.action == ACTIONS.WALKTO) then
			action = GetAction(playeractionpicker.inst, target, ACTIONS.MINE)
		end
		if not action and (v.action == ACTIONS.LOOKAT or v.action == ACTIONS.WALKTO) and ACTIONS.HACK then
			action = GetAction(playeractionpicker.inst, target, ACTIONS.HACK)
		end
		if action then
			actions[k] = action
			action = nil
		end
	end
	
	--print("End result:", action, actions)
	return actions
end

local function CanRepairWall( inst, target )
	if( not inst or not target or not GetInventory(inst) ) then return false end
	if( target and target.replica and target.replica._ and target.replica._.health and target.replica._.health._isnotfull and target.replica._.health._isnotfull.value and target.replica._.health._isnotfull:value() ~= true ) then return false end
	
	local mat = ( target:HasTag("moonrock") and "moonrock" ) or ( target:HasTag("ruins") and "ruins" ) or ( target:HasTag("stone") and "stone" ) or ( target:HasTag("wood") and "wood" ) or ( target:HasTag("grass") and "hay" ) or nil
	if not mat then return false end
	
	local wallitem = CustomFindItem(inst, GetInventory(inst), function(itm) return itm.prefab and itm.prefab == ("wall_"..mat.."_item") end)
	if not wallitem then return false end
	
	
	return wallitem
end

local function CanFeedFire( inst, target )
	if( not inst or not target or not GetInventory(inst) or not modOptions.REFUEL_FIRES ) then return false end
	
	local settin = modOptions.REFUEL_FIRES_PRIORITIZE
	
	local preferred = {
		"log",
		"twigs",
		"cutgrass"
	}
	
	local fuelitem
	
	fuelitem = CustomFindItem(inst, GetInventory(inst), function(itm)
		return itm.HasTag and itm:HasTag("BURNABLE_fuel") and itm.prefab and itm.prefab == (preferred and preferred[settin] or "NA")
	end)
	
	if not fuelitem then
		fuelitem = CustomFindItem(inst, GetInventory(inst), function(itm)
			return itm.HasTag and itm:HasTag("BURNABLE_fuel") and itm.prefab and ( itm.prefab == "log" or itm.prefab == "twigs" or itm.prefab == "cutgrass" )
		end)
	end
	
	if not fuelitem then
		fuelitem = CustomFindItem(inst, GetInventory(inst), function(itm)
			return itm.HasTag and itm:HasTag("BURNABLE_fuel")
		end)
	end
	
	if not fuelitem then return false end
	
	
	return fuelitem
end

-- attached to playercontroller.GetRightClickActions
local function GetRightClickActions(playeractionpicker, position, target, actions, spellbook)
	if not target then return actions end
	if not actions then return actions end
	if TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then return actions end
	
	local forceToFront = TheInput:IsControlPressed(41)
	
	local action
	for k,v in ipairs(actions) do
		if( ( v.action == ACTIONS.LOOKAT or v.action == ACTIONS.WALKTO or v.action == ACTIONS.PICK ) or forceToFront ) then
			action = GetAction(playeractionpicker.inst, target, ACTIONS.DIG, true)
		end
		if not action and ( target:HasTag("wall") and CanRepairWall(playeractionpicker.inst,target) and modOptions.REPAIR_WALLS ) then
			action = BufferedAction(playeractionpicker.inst, target, ACTIONS.REPAIR, CanRepairWall(playeractionpicker.inst,target))
			action.mod_name = "a-a"
		end
		if not action and ( target:HasTag("campfire") and CanFeedFire(playeractionpicker.inst,target) and modOptions.REFUEL_FIRES ) and not forceToFront then
			local available_fuel = CanFeedFire(playeractionpicker.inst,target)
			
			if available_fuel and available_fuel.replica and available_fuel.replica._ and available_fuel.replica._.inventoryitem and available_fuel.replica._.inventoryitem._iswet and available_fuel.replica._.inventoryitem._iswet:value() == true then
				action = BufferedAction(playeractionpicker.inst, target, ACTIONS.ADDWETFUEL, available_fuel)
				action.GetActionString = function()
					return "Add Wet Fuel("..(available_fuel and available_fuel.name or "ERROR")..")"
				end
			else
				action = BufferedAction(playeractionpicker.inst, target, ACTIONS.ADDFUEL, available_fuel)
				action.GetActionString = function()
					return "Add Fuel("..(available_fuel and available_fuel.name or "ERROR")..")"
				end
			end
			action.mod_name = "a-a"
		end
		
		-- print("Debugging: "..tostring(not action).." "..tostring( target:HasTag("cookable") ).." - "..tostring( GLOBAL.FindEntity(playeractionpicker.inst, 6, function( ent ) return ent.HasTag and ent:HasTag("cooker") end, {}, TARGET_EXCLUDE_TAGS) ))
		if not action and ( ( v.action == ACTIONS.LOOKAT or v.action == ACTIONS.WALKTO or v.action == ACTIONS.PICK ) or forceToFront ) then
			action = GetAction(playeractionpicker.inst, target, ACTIONS.HAMMER, true)
		end
		if action then
			actions[k] = action
			action = nil
		end
	end
	
	return actions
end


local originalFunctions = {}
local originalFunctionsPicker = {}

local function addPlayeractionpicker( inst, inst2, inst3 )

	local controller = inst
	
	originalFunctionsPicker.GetLeftClickActions = controller.GetLeftClickActions;
	originalFunctionsPicker.GetRightClickActions = controller.GetRightClickActions;

	controller.GetLeftClickActions = function(selfs, position, target, spellbook)
		local actions = originalFunctionsPicker.GetLeftClickActions(selfs,position,target, spellbook)
		local successflag, retvalue = pcall(GetClickActions, selfs, position, target, actions, spellbook)
		if not successflag then
			if letsDoDebug then print(retvalue) end
			return actions
		else
			return retvalue
		end
	end

	controller.GetRightClickActions = function(selfs, position, target, spellbook)
		local actions = originalFunctionsPicker.GetRightClickActions(selfs,position,target, spellbook)
		local successflag, retvalue = pcall(GetRightClickActions, selfs, position, target, actions, spellbook)
		if not successflag then
			if letsDoDebug then print(retvalue) end
			return actions
		else
			return retvalue
		end
	end
	
end
AddClassPostConstruct("components/playeractionpicker", addPlayeractionpicker)

local shouldToggleEnabled = nil
local function addPlayerController( inst )
	local controller = inst

	originalFunctions.OnUpdate = controller.OnUpdate;
	originalFunctions.GetActionButtonAction = controller.GetActionButtonAction;
	originalFunctions.DoAction = controller.DoAction;
	originalFunctions.DoAttackButton = controller.DoAttackButton;

	-- Ooooooo

	controller.OnUpdate = function(salf, dt)
		originalFunctions.OnUpdate(salf,dt)
		if(shouldToggleEnabled ~= nil) then
			ToggleModEnabled(salf,shouldToggleEnabled);
			shouldToggleEnabled=nil;
			return;
		end
		if(modOptions.ENABLED) then
			local successflag, retvalue = pcall(OnUpdate, salf, dt)
			if not successflag then
				if letsDoDebug then print(retvalue) end
			end
		end
	end

	controller.GetActionButtonAction = function(salf,forced)
		--print("Action button")
		local bufferedaction = originalFunctions.GetActionButtonAction(salf,forced or salf.autoequip_prioNextTarget or nil)
		local successflag, retvalue = pcall(GetActionButtonAction, salf, forced or salf.autoequip_prioNextTarget or nil, bufferedaction)
		if not successflag then
			if letsDoDebug then print("Ran default ABA with: ",bufferedaction) end
			return bufferedaction
		else
			if letsDoDebug then print("Ran custom ABA with: ",retvalue) end
			return retvalue
		end
	end

	controller.DoAction = function(salf, bufferedaction)
		--print("Action")
		local successflag, retvalue = pcall(DoAction, salf, bufferedaction)
		if( successflag and retvalue ) then
			if letsDoDebug then print("Worked, sending:", retvalue) end
			if( retvalue and type(retvalue) == "string" and retvalue == "empty" ) then
				originalFunctions.DoAction(salf,nil)
			else
				originalFunctions.DoAction(salf,retvalue)
			end
		else
			if letsDoDebug then print("Failed") end
			originalFunctions.DoAction(salf,bufferedaction)
		end
	end

	controller.DoAttackButton = function(salf)
		local successflag, retvalue = pcall(DoAttackButton, salf)
		if not successflag then
			if letsDoDebug then print(retvalue) end
		end
		originalFunctions.DoAttackButton(salf)
	end
end
AddClassPostConstruct("components/playercontroller", addPlayerController)

function ToggleModEnabled( controller, state )

	local playctrl = controller.inst.components.playercontroller
	local playpick = controller.inst.components.playeractionpicker

	if(state == true) then
	
		playctrl.GetActionButtonAction = function(salf,forced)
			--print("Action button")
			local bufferedaction = originalFunctions.GetActionButtonAction(salf,forced or salf.autoequip_prioNextTarget or nil)
			local successflag, retvalue = pcall(GetActionButtonAction, salf, forced or salf.autoequip_prioNextTarget or nil, bufferedaction)
			if not successflag then
				-- print(retvalue)
				return bufferedaction
			else
				return retvalue
			end
		end

		playctrl.DoAction = function(salf, bufferedaction)
			--print("Action")
			local successflag, retvalue = pcall(DoAction, salf, bufferedaction)
			if( successflag and retvalue ) then
				if letsDoDebug then print("Worked, sending:", retvalue) end
				if( retvalue and type(retvalue) == "string" and retvalue == "empty" ) then
					originalFunctions.DoAction(salf,nil)
				else
					originalFunctions.DoAction(salf,retvalue)
				end
			else
				if letsDoDebug then print("Failed") end
				originalFunctions.DoAction(salf,bufferedaction)
			end
		end

		playctrl.DoAttackButton = function(salf)
			local successflag, retvalue = pcall(DoAttackButton, salf)
			if not successflag then
				if letsDoDebug then print(retvalue) end
			end
			originalFunctions.DoAttackButton(salf)
		end
		
		playpick.GetLeftClickActions = function(self, position, target, spellbook)
			local actions = originalFunctionsPicker.GetLeftClickActions(self,position,target, spellbook)
			local successflag, retvalue = pcall(GetClickActions, self, position, target, actions, spellbook)
			if not successflag then
				if letsDoDebug then print(retvalue) end
				return actions
			else
				return retvalue
			end
		end

		playpick.GetRightClickActions = function(self, position, target, spellbook)
			local actions = originalFunctionsPicker.GetRightClickActions(self,position,target, spellbook)
			local successflag, retvalue = pcall(GetRightClickActions, self, position, target, actions, spellbook)
			if not successflag then
				if letsDoDebug then print(retvalue) end
				return actions
			else
				return retvalue
			end
		end
	
	else
	
		playctrl.GetActionButtonAction = originalFunctions.GetActionButtonAction

		playctrl.DoAction = originalFunctions.DoAction

		playctrl.DoAttackButton = originalFunctions.DoAttackButton
		
		playpick.GetLeftClickActions = originalFunctionsPicker.GetLeftClickActions

		playpick.GetRightClickActions = originalFunctionsPicker.GetRightClickActions
	
	end

end


local function GetPickupAction(target, tool)
    if target:HasTag("smolder") then
        return ACTIONS.SMOTHER
    elseif tool ~= nil then
        for k, v in pairs(GLOBAL and GLOBAL.TOOLACTIONS or {}) do
            if target:HasTag(k.."_workable") then
                if tool:HasTag(k.."_tool") then
                    return ACTIONS[k]
                end
                break
            end
        end
    end
    if target:HasTag("trapsprung") then
        return ACTIONS.CHECKTRAP
    elseif target:HasTag("inactive") then
        return ACTIONS.ACTIVATE
    elseif target.replica.inventoryitem ~= nil and
        target.replica.inventoryitem:CanBePickedUp() and
        not (target:HasTag("catchable") or target:HasTag("fire")) then
        return ACTIONS.PICKUP 
    elseif target:HasTag("pickable") and not target:HasTag("fire") then
        return ACTIONS.PICK 
    elseif target:HasTag("harvestable") then
        return ACTIONS.HARVEST
    elseif target:HasTag("readyforharvest") or
        (target:HasTag("notreadyforharvest") and target:HasTag("withered")) then
        return ACTIONS.HARVEST
    elseif target:HasTag("dried") and not target:HasTag("burnt") then
        return ACTIONS.HARVEST
    elseif target:HasTag("donecooking") and not target:HasTag("burnt") then
        return ACTIONS.HARVEST
    elseif tool ~= nil and tool:HasTag("unsaddler") and target:HasTag("saddled") and (not target.replica.health or not target.replica.health:IsDead()) then
        return ACTIONS.UNSADDLE
    elseif tool ~= nil and tool:HasTag("brush") and target:HasTag("brushable") and (not target.replica.health or not target.replica.health:IsDead()) then
        return ACTIONS.BRUSH
    end
    --no action found
end

local CanEntitySeeTarget = GLOBAL.CanEntitySeeTarget

Backup_GetActionButtonAction = function(self, force_target, ignore_targets, musthave, donthave)
    --Don't want to spam the action button before the server actually starts the buffered action
    --Also check if playercontroller is enabled
    --Also check if force_target is still valid
    if (not self.ismastersim and (self.remote_controls[CONTROL_ACTION] or 0) > 0) or
        not self:IsEnabled() or
        (force_target ~= nil and (not force_target.entity:IsVisible() or force_target:HasTag("INLIMBO") or force_target:HasTag("NOCLICK"))) then
        --"DECOR" should never change, should be safe to skip that check
        return

    elseif self.actionbuttonoverride ~= nil then
        local buffaction, usedefault = self.actionbuttonoverride(self.inst, force_target)
        if not usedefault or buffaction ~= nil then
            return buffaction
        end

    elseif not self:IsDoingOrWorking() then
        local force_target_distsq = force_target ~= nil and self.inst:GetDistanceSqToInst(force_target) or nil

        if self.inst:HasTag("playerghost") then
            --haunt
            if force_target == nil then
                local target = FindEntity(self.inst, self.directwalking and 3 or 6, GLOBAL.ValidateHaunt, nil, HAUNT_TARGET_EXCLUDE_TAGS)
                if CanEntitySeeTarget(self.inst, target) then
                    return BufferedAction(self.inst, target, ACTIONS.HAUNT)
                end
            elseif force_target_distsq <= (self.directwalking and 9 or 36) and
                not (force_target:HasTag("haunted") or force_target:HasTag("catchable")) and
                ValidateHaunt(force_target) then
                return BufferedAction(self.inst, force_target, ACTIONS.HAUNT)
            end
            return
        end

        local tool = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

        --bug catching (has to go before combat)
        if tool ~= nil and tool:HasTag(ACTIONS.NET.id.."_tool") then
            if force_target == nil then
                local target = FindEntity(self.inst, 5, ValidateBugNet, { "_health", ACTIONS.NET.id.."_workable" }, TARGET_EXCLUDE_TAGS)
                if CanEntitySeeTarget(self.inst, target) then
                    return BufferedAction(self.inst, target, ACTIONS.NET, tool)
                end
            elseif force_target_distsq <= 25 and
                force_target.replica.health ~= nil and
                ValidateBugNet(force_target) and
                force_target:HasTag(ACTIONS.NET.id.."_workable") then
                return BufferedAction(self.inst, force_target, ACTIONS.NET, tool)
            end
        end

        --catching
        if self.inst:HasTag("cancatch") then
            if force_target == nil then
                local target = FindEntity(self.inst, 10, nil, { "catchable" }, TARGET_EXCLUDE_TAGS)
                if CanEntitySeeTarget(self.inst, target) then
                    return BufferedAction(self.inst, target, ACTIONS.CATCH)
                end
            elseif force_target_distsq <= 100 and
                force_target:HasTag("catchable") then
                return BufferedAction(self.inst, force_target, ACTIONS.CATCH)
            end
        end

        --unstick
        if force_target == nil then
            local target = FindEntity(self.inst, self.directwalking and 3 or 6, nil, { "pinned" }, TARGET_EXCLUDE_TAGS)
            if CanEntitySeeTarget(self.inst, target) then
                return BufferedAction(self.inst, target, ACTIONS.UNPIN)
            end
        elseif force_target_distsq <= (self.directwalking and 9 or 36) and
            force_target:HasTag("pinned") then
            return BufferedAction(self.inst, force_target, ACTIONS.UNPIN)
        end

        --misc: pickup, tool work, smother
        if force_target == nil then
            local pickup_tags =
            {
                "_inventoryitem",
                "pickable",
                "donecooking",
                "readyforharvest",
                "notreadyforharvest",
                "harvestable",
                "trapsprung",
                "dried",
                "inactive",
                "smolder",
                "saddled",
                "brushable",
            }
            if tool ~= nil then
                for k, v in pairs(TOOLACTIONS) do
                    if tool:HasTag(k.."_tool") then
                        table.insert(pickup_tags, k.."_workable")
                    end
                end
            end
            local x, y, z = self.inst.Transform:GetWorldPosition()
			
			local exclude = PICKUP_TARGET_EXCLUDE_TAGS
			if donthave and type(donthave) == "table" then
				for k,v in pairs(donthave) do
					table.insert(exclude,v)
				end
			end
			
            local ents = TheSim:FindEntities(x, y, z, self.directwalking and 3 or 6, musthave or nil, exclude, pickup_tags)
            for i, v in ipairs(ents) do
                if v ~= self.inst and v.entity:IsVisible() and CanEntitySeeTarget(self.inst, v) and ( ignore_targets == nil or ( ignore_targets ~= nil and not DoMatch(ignore_targets, v) ) ) then
                    local action = GetPickupAction(v, tool)
                    if action ~= nil then
                        return BufferedAction(self.inst, v, action, action ~= ACTIONS.SMOTHER and tool or nil)
                    end
                end
            end
        elseif force_target_distsq <= (self.directwalking and 9 or 36) then
            local action = GetPickupAction(force_target, tool)
            if action ~= nil then
                return BufferedAction(self.inst, force_target, action, action ~= ACTIONS.SMOTHER and tool or nil)
            end
        end
    end
end

local function UpdateSettings()

	if(modOptions.ENABLED ~= (GetModConfigData("ae_enablemod") == 1 or false)) then
		modOptions.ENABLED = (GetModConfigData("ae_enablemod") == 1 or false);
		shouldToggleEnabled = (GetModConfigData("ae_enablemod") == 1 or false);
	end
	--rem ae_ignoreRestrictions = GetModConfigData("autoequipignorerestrictions") or 1
	modOptions.IGNORE_RESTRICTIONS = GetModConfigData("autoequipignorerestrictions") > 0;
	--rem ae_weapons = GetModConfigData("ae_equipweapon") or 1
	modOptions.TRY_PICKUP_NEARBY_TOOLS = GetModConfigData("ae_use_nearby_tools") > 0;

	modOptions.SWITCH_TOOLS_AUTO = GetModConfigData("ae_switchtools") == 1 or GetModConfigData("ae_switchtools") == 2;
	modOptions.SWITCH_TOOLS_MOUSE = GetModConfigData("ae_switchtools") == 1 or GetModConfigData("ae_switchtools") == 3;

	modOptions.EQUIP_WEAPONS = GetModConfigData("ae_equipweapon") > 0;
	--rem ae_huntwithboomerang = GetModConfigData("ae_boomcritters") or 0
	modOptions.CRITTERS_WITH_BOOMERANG = GetModConfigData("ae_boomcritters") > 0;
	--rem ae_givelight = GetModConfigData("ae_lightindark") or 0
	modOptions.EQUIP_LIGHT_IN_DARK = GetModConfigData("ae_lightindark") > 0;
	modOptions.CREATE_LIGHT_IN_DARK = GetModConfigData("ae_lightindark") > 1;

	--rem aa_canCraftToolsAutomatically = GetModConfigData("ae_crafttools") > 0 or false
	modOptions.CRAFT_TOOLS_AUTO = GetModConfigData("ae_crafttools") > 0;
	modOptions.CRAFT_TOOLS_AUTO_GOLDEN = GetModConfigData("ae_crafttools") > 1;
	modOptions.CRAFT_TOOLS_MOUSE = GetModConfigData("ae_crafttools_mouse") > 0;
	modOptions.CRAFT_TOOLS_MOUSE_GOLDEN = GetModConfigData("ae_crafttools_mouse") > 1;
	--rem aa_useGoldenTools = GetModConfigData("ae_crafttools") > 1 or false

	--rem aa_ignoreTraps = false --GetModConfigData("autoequipignoretraps") and GetModConfigData("autoequipignoretraps") > 0 or false
	modOptions.IGNORE_TRAPS = false;
	--rem aa_reactiveTraps = false --GetModConfigData("autoequipreactivatetraps") and GetModConfigData("autoequipreactivatetraps") > 0 or false
	modOptions.REACTIVATE_TRAPS = false;
	--rem aa_replantTrees = GetModConfigData("ae_replanttrees") and GetModConfigData("ae_replanttrees") > 0 or false
	modOptions.REPLANT_TREES = GetModConfigData("ae_replanttrees") > 0;
	
	modOptions.REFUEL_FIRES = GetModConfigData("ae_refuelfires") > 0;
	--rem aa_refueli = GetModConfigData("ae_refuelfires");
	modOptions.REFUEL_FIRES_PRIORITIZE = GetModConfigData("ae_refuelfires");
	--rem aa_repairwalls = GetModConfigData("ae_repairwalls") and GetModConfigData("ae_repairwalls") > 0 or false
	modOptions.REPAIR_WALLS = GetModConfigData("ae_repairwalls") > 0;
	
	--rem aa_completelyignore = GetModConfigData("ae_alwaysignoresaps") and GetModConfigData("ae_alwaysignoresaps") > 0 or false
	modOptions.IGNORE_SAPS = GetModConfigData("ae_alwaysignoresaps") > 0;
	
	print("Settings have been updated!")
end

local handlers_applied = false
local function AddAASettings( self )
	controls = self -- this just makes controls available in the rest of the modmain's functions
	inst = GLOBAL.ThePlayer
	
	if not handlers_applied then
		-- Keyboard controls
		GLOBAL.TheInput:AddKeyDownHandler(KEYBOARDTOGGLEKEY, function()
			if TheInput and TheInput.IsControlPressed and TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
				if(modOptions.EQUIP_WEAPONS) then
					local bestweapon = GetInventory(inst):GetEquippedItem(EQUIPSLOTS.HANDS)
					if( bestweapon and ( not hasPreferedWeapon or hasPreferedWeapon ~= bestweapon.prefab ) ) then
						hasPreferedWeapon = bestweapon.prefab
						inst.components.talker:Say("I'll use this "..tostring(bestweapon.name or "N/A").." as my primary weapon.", 5, true, true, true)
					elseif( bestweapon and hasPreferedWeapon and hasPreferedWeapon == bestweapon.prefab ) then
						hasPreferedWeapon = nil
						inst.components.talker:Say("I'll now use whatever strongest, standard weapon that I have.", 5, true, true, true)
					end
				else
					inst.components.talker:Say("Auto-equipping a weapon is disabled in the mod's settings.", 5, true, true, true)
				end
			else
				ShowSettingsMenu(controls)
			end
		end)
		handlers_applied = true
	end
	
	AddUserCommand("aa", {
		prettyname = nil,
		desc = nil,
		permission = GLOBAL.COMMAND_PERMISSION.USER,
		slash = true,   
		usermenu = false,
		servermenu = false,
		params = {},
		localfn = function()
			ShowSettingsMenu(controls);
		end
	})

	AddUserCommand("autowep", {
		prettyname = nil,
		desc = nil,
		permission = GLOBAL.COMMAND_PERMISSION.USER,
		slash = true,   
		usermenu = false,
		servermenu = false,
		params = {},
		localfn = function()
			local inst = GLOBAL.ThePlayer;
			if(modOptions.EQUIP_WEAPONS) then
				local bestweapon = GetInventory(inst):GetEquippedItem(EQUIPSLOTS.HANDS)
				if( bestweapon and ( not hasPreferedWeapon or hasPreferedWeapon ~= bestweapon.prefab ) ) then
					hasPreferedWeapon = bestweapon.prefab
					inst.components.talker:Say("I'll use this "..tostring(bestweapon.name or "N/A").." as my primary weapon.", 5, true, true, true)
				elseif( bestweapon and hasPreferedWeapon and hasPreferedWeapon == bestweapon.prefab ) then
					hasPreferedWeapon = nil
					inst.components.talker:Say("I'll now use whatever strongest, standard weapon that I have.", 5, true, true, true)
				end
			else
				inst.components.talker:Say("Auto-equipping a weapon is disabled in the mod's settings.", 5, true, true, true)
			end
		end
	})

	AddUserCommand("unequip", {
		prettyname = nil,
		desc = nil,
		permission = GLOBAL.COMMAND_PERMISSION.USER,
		slash = true,   
		usermenu = false,
		servermenu = false,
		params = {},
		localfn = function()
			CheckIfOutOfDarkness(GLOBAL.ThePlayer);
		end
	})
	
	local OldOnUpdate = controls.OnUpdate
	local function OnUpdate(...)
		OldOnUpdate(...)
		if controls.updatesettings then
			controls.updatesettings = false
			UpdateSettings()
		end
	end
	controls.OnUpdate = OnUpdate
	
end

local AA_DEBUG = {
	GUM = function()
		return TheInput:GetWorldEntityUnderMouse();
	end,
	CanFeedFire = CanFeedFire
}
GLOBAL.AA_DEBUG = AA_DEBUG;

AddClassPostConstruct( "widgets/controls", AddAASettings )