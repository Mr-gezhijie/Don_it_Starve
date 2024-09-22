local itemlist = require "mod_remiautorefuel_itemlist"

local FUELGROUPS = {
	nfuel = {nightmarefuel = true},
	bulbs = {lightbulb = true},
	embers = {willow_ember = true},
	lunarkits = {lunarplant_kit = true},
	shadowkits = {voidcloth_kit = true},
	sewing = {sewing_kit = true, sewing_tape = true},
	worms = {wormlight = true, wormlight_lesser = true},
	nastyfood = {monstermeat = true, cookedmonstermeat = true, monstermeat_dried = true, spoiled_food = true},
	engineer = {wagpunkbits_kit = true},
	petaxe = {voidcloth_kit = true},
}

local SPEECHTAGS = {
	nfuel = "generic",
	bulbs = "generic",
	embers = "generic",
	lunarkits = "repair_with_kit",
	shadowkits = "repair_with_kit",
	sewing = "sew",
	worms = "generic",
	nastyfood = "feed",
	engineer = "engineer",
	petaxe = "petaxe",
}

local LONGREFUELS = {
	nfuel = false,
	bulbs = false,
	embers = false,
	lunarkits = true,
	shadowkits = true,
	sewing = true,
	worms = false,
	nastyfood = true,
	engineer = true,
	petaxe = true,
}

local MESSAGES = {
	WARNING = {
		color = {1,1,.2,1},
		generic = "Time to give my %s some fuel.",
		repair_with_kit = "Time to patch my %s once again.",
		feed = "Time to feed my %s something nasty.",
		sew = "Time to give my %s another stitch.",
		engineer = "Time to tighten the bolts on my %s.",
		petaxe = "I must take care of my %s before it's too late!",
	},

	WARNING_NOFUEL = {
		color = {1,.2,.2,1},
		generic = "I have nothing to refuel my %s with!",
		repair_with_kit = "I have run out of kits for my %s!",
		feed = "I'm out of food for my %s!",
		sew = "I don't have anything to fix my %s up with!",
		engineer = "I've no tools for my %s!",
		petaxe = "My %s is nearly at its limit!",
	},

	EXPIRED = {
		color = {1,1,.2,1},
		generic = "My %s has run out of juice!",
		repair_with_kit = "My %s is broken! I need to back off.",
		feed = "And there goes my %s.",
		sew = "My %s has fallen apart!",
		engineer = "My %s is in complete disrepair.",
		petaxe = "Oh dear, I've pushed my %s too hard...",
	},

	EXPIRED_NOFUEL = {
		color = {1,.2,.2,1},
		generic = "I have nothing to refuel my %s with!",
		repair_with_kit = "I have run out of kits for my %s!",
		feed = "I'm out of food for my %s!",
		sew = "I don't have anything to fix my %s up with!",
		engineer = "I've no tools for my %s!",
		petaxe = "I need a kit to bring my %s back...",
	},
}

local function Config(fuelgroup, refuel_threshold, text_warn_threshold, sound_warn_threshold, force_refuel_threshold)
	return refuel_threshold >= 0 and {
		refuel_threshold = refuel_threshold,
		text_warn_threshold = text_warn_threshold,
		sound_warn_threshold = sound_warn_threshold,
		force_refuel_threshold = force_refuel_threshold,
		fuels = FUELGROUPS[fuelgroup],
		speech_tag = SPEECHTAGS[fuelgroup],
		is_long_refuel = LONGREFUELS[fuelgroup],
	}
	or nil -- refuel threshold being below zero essentially means the mod will never try to refuel the item, so why support the item in the first place?
end

local ITEMS = {}
local function SetupItemData(mod_configs)
	if mod_configs.allow_horrorfuel then FUELGROUPS.nfuel.horrorfuel = true end

	for _,data in pairs(itemlist) do
		local item, fuelgroup = unpack(data)
		ITEMS[item] = Config(fuelgroup, unpack(mod_configs[item]))
	end

	return {
		ITEMS = ITEMS,
		MESSAGES = MESSAGES,
	}
end

return SetupItemData