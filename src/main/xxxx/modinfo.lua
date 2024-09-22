name = "Auto-Refuel Stuff"
description = "This mod will try to keep your magilumiwhatever from running out. Equip, forget, and enjoy."
author = "Remi"
version = "0.5"

forumthread = ""

api_version = 10

dst_compatible = true
client_only_mod = true
all_clients_require_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

local KeybindOptions = {
	{description = "None", data = -1},
	{description = "F1", data = 282},
	{description = "F2", data = 283},
	{description = "F3", data = 284},
	{description = "F4", data = 285},
	{description = "F5", data = 286},
	{description = "F6", data = 287},
	{description = "F7", data = 288},
	{description = "F8", data = 289},
	{description = "F9", data = 290},
	{description = "F10", data = 291},
	{description = "F11", data = 292},
	{description = "F12", data = 293},
	{description = "Z", data = 122},
	{description = "X", data = 120},
	{description = "C", data = 99},
	{description = "V", data = 118},
	{description = "B", data = 98},
	{description = "N", data = 110},
	{description = "M", data = 109},
	{description = "A", data = 97},
	{description = "S", data = 115},
	{description = "D", data = 100},
	{description = "F", data = 102},
	{description = "G", data = 103},
	{description = "H", data = 104},
	{description = "J", data = 106},
	{description = "K", data = 107},
	{description = "L", data = 108},
	{description = "Q", data = 113},
	{description = "W", data = 119},
	{description = "E", data = 101},
	{description = "R", data = 114},
	{description = "T", data = 116},
	{description = "Y", data = 121},
	{description = "U", data = 117},
	{description = "I", data = 105},
	{description = "O", data = 111},
	{description = "P", data = 112},
	{description = "Num 1", data = 257},
	{description = "Num 2", data = 258},
	{description = "Num 3", data = 259},
	{description = "Num 4", data = 260},
	{description = "Num 5", data = 261},
	{description = "Num 6", data = 262},
	{description = "Num 7", data = 263},
	{description = "Num 8", data = 264},
	{description = "Num 9", data = 265},
	{description = "Num 0", data = 256},
	{description = "Num -", data = 269},
	{description = "Num +", data = 270},
	{description = "Num *", data = 268},
	{description = "Num /", data = 267},
	{description = "Num .", data = 266},
	{description = "None", data = -1},
}

function MakeFakeConfig(name, label)
	return {name = name or "fake", label = label or "", hover = "", options = {{description = "", data = -1, hover = ""},}, default = 1}
end

function MakeToggleConfig(prefab, name, default)
	return {
		name = prefab,
		label = name,
		options = {
			{description = "Yes", data = true},
			{description = "No", data = false},
		},
		default = default,
		hover = "Choose if you want this kind of item to be repaired by the mod."
	}
end

function MakeNumConfig(name, label, lower, upper, step, default, hover)
	local options = default >= 0 and {{description = default, data = default},{description = "Disabled", data = -1}} or {{description = "Disabled", data = -1}}
	if default < 0 then default = -1 end

	local index = #options + 1
	for i = lower,upper,step do 
		options[index] = {description = i, data = i}
		index = index+1
	end
	return {
		name = name,
		label = label,
		options = options,
		default = default,
		hover = hover,
	}
end

local function myunpack(tab, idx)
	idx = idx or 1
	if tab[idx+1] ~= nil then
		return tab[idx], myunpack(tab, idx+1)
	else
		return tab[idx]
	end
end

configuration_options = {
	{
		name = "MANUAL_REFUEL_KEY",
		label = "Refuel key",
		options = KeybindOptions,
		default = -1,
		hover = "Select the key to manually refuel your equips with (you may not need this).",
		is_keybind = true,
	},	
	
	{
		name = "HOSTILE_RADIUS",
		label = "Enemy detection radius",
		options = {
			{description = "5.5", data = 5.5}, -- default
			{description =  "0", data =  0}, {description =  "0.5", data =  0.5}, {description =  "1", data =  1}, {description =  "1.5", data =  1.5},
			{description =  "2", data =  2}, {description =  "2.5", data =  2.5}, {description =  "3", data =  3}, {description =  "3.5", data =  3.5},
			{description =  "4", data =  4}, {description =  "4.5", data =  4.5}, {description =  "5", data =  5}, {description =  "5.5", data =  5.5},
			{description =  "6", data =  6}, {description =  "6.5", data =  6.5}, {description =  "7", data =  7}, {description =  "7.5", data =  7.5},
			{description =  "8", data =  8}, {description =  "8.5", data =  8.5}, {description =  "9", data =  9}, {description =  "9.5", data =  9.5},
			{description = "10", data = 10}, {description = "10.5", data = 10.5}, {description = "11", data = 11}, {description = "11.5", data = 11.5},
			{description = "12", data = 12}, {description = "12.5", data = 12.5}, {description = "13", data = 13}, {description = "13.5", data = 13.5},
			{description = "14", data = 14}, {description = "14.5", data = 14.5}, {description = "15", data = 15},
		},
		default = 5.5,
		hover = "Nearby hostile creatures will prevent auto refuels to avoid being attacked.\nChoose how far the mod will look out for enemies (in wall units).",
	},	

	{
		name = "CIRCLE_OPACITY",
		label = "Detection circle opacity",
		options = {
			{description = "0.2", data = 0.2}, -- default
			{description =   "0", data =   0}, {description =  "0.1", data =  0.1}, {description =  "0.2", data =  0.2}, {description =  "0.3", data =  0.3},
			{description = "0.4", data = 0.4}, {description =  "0.5", data =  0.5}, {description =  "0.6", data =  0.6}, {description =  "0.7", data =  0.7},
			{description = "0.8", data = 0.8}, {description =  "0.9", data =  0.9}, {description =    "1", data =    1}, 
		},
		default = .2,
	},


	{
		name = "ALLOW_HORRORFUEL",
		label = "Use pure horror",
		options = {
			{description = "Yes", data = true},
			{description = "No", data = false},
		},
		default = false,
		hover = "Choose whether to allow the mod to refuel items with pure horror.",
	},

}
local next_idx = #configuration_options + 1

local itemdata = {
	{"yellowamulet",		"Magilumiwhatever",	 	  25, 25,  9,  9},
	{"orangeamulet",		"The Lazy Forager",	 	  25, 25,  9,  9},
	{"lantern",				"Lantern",			 	  25, 25,  9,  9},
	{"minerhat",			"Miner Hat",		 	  25, 25,  9,  9},
	{"armorskeleton",		"Bone Armor",		 	  75, 41, 25, 15},
	{"molehat",				"Moggles",			 	  25, 25,  9,  9},
	{"lighter",				"Willow's Lighter",	 	  25, 25,  9,  9},
	{"pocketwatch_weapon",	"Alarming Clock",	 	  75, 25, 11,  5},
	{"voidcloth_scythe",	"Shadow Reaper",	 	   5,  5,  5, -1},
	{"armor_voidcloth",		"Void Robe",		 	  15, 15, 15, -1},
	{"voidclothhat",		"Void Cowl",		 	  15, 15, 15, -1},
	{"sword_lunarplant",	"Brightshade Sword", 	   5,  5,  5, -1},
	{"staff_lunarplant",	"Brightshade Staff", 	  11, 11, 11, -1},
	{"pickaxe_lunarplant",	"Brightshade Smasher", 	   1,  1,  1, -1},
	{"shovel_lunarplant",	"Brightshade Shoevel", 	   1,  1,  1, -1},
	{"armor_lunarplant",	"Brightshade Armor", 	  15, 15, 15, -1},
	{"lunarplanthat",		"Brightshade Helm", 	  15, 15, 15, -1},
	{"armorwagpunk",		"W.A.R.B.I.S. Armor", 	  15, 15, 15, -1},
	{"wagpunkhat",			"W.A.R.B.I.S. Head Gear", 15, 15, 15, -1},
	{"storage_robot",		"W.O.B.O.T.", 			   1,  1, -1, -1},
	{"voidcloth_boomerang",	"Gloomerang", 			   5,  5,  5, -1},
	{"shadow_battleaxe",	"Shadow Maul",	 		   7,  7,  7,  1},
	{"eyemaskhat",			"Eye Mask", 			  61, 41, 21, -1},
	{"shieldofterror",		"Shield of Terror", 	  61, 41, 21, -1},
	{"beargervest",			"Hibearnation Vest", 	  37, 15,  9, -1},
	{"armorslurper",		"Hunger Belt", 			  27, 15,  9, -1},
	{"bernie_inactive",		"Bernie",	 			   5,  5, -1, -1},
}
for i = 1,#itemdata do
	local name, label, reg, msg, snd, frc = myunpack(itemdata[i])
	configuration_options[next_idx] = MakeFakeConfig(name.."_header",   label)
	configuration_options[next_idx+1] = MakeNumConfig(name.."_regular", "Refuel %", 0, 90, 2, reg, "The mod will refuel item upon reaching this percent.")
	configuration_options[next_idx+2] = MakeNumConfig(name.."_message", "Warning message %", 0, 90, 2, msg, "The mod will display a message upon reaching this percent.")
	configuration_options[next_idx+3] = MakeNumConfig(name.."_sound",   "Warning sound %", 0, 90, 2, snd, "The mod will play a sound upon reaching this percent.")
	configuration_options[next_idx+4] = MakeNumConfig(name.."_forced",  "Force refuel %", 0, 90, 2, frc, "The mod will forcefully refuel item upon reaching this percent.")
	next_idx = next_idx + 5
end