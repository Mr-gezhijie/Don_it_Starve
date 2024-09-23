name = "Auto Actions"
description = "Will automatically equip the tool fit for the task at hand. A few examples:\n- Hold space and get everything done without removing your finger.\n- Attack and enemy and it'll equip your best weapon.\n- Attack a critter and it'll use a boomerang, if you have one.\n- Stand in the darkness and it'll equip a light-source, if one exists in your inventory.\n(Holding space won't dig up saplings, bushes and such, but can be overwritten by also holding down CTRL)\n\nIf any bugs comes up or there's something you would like to get implemented, then leave a comment on the Workshop of this mod and I'll take a look at it :)\n\nThis mod was originally made by noobler, but has been customized and made into a client-mod by Jespercal."
author = "Jespercal"
version = "1.2.4.9"
forumthread = ""
api_version_dst = 10
icon_atlas = "modicon.xml"
icon = "modicon.tex"

shipwrecked_compatible = false
dont_starve_compatible = true
reign_of_giants_compatible = true
dst_compatible = true

client_only_mod = true
all_clients_require_mod = false

api_version = 6
api_version_dst = 10

priority = 0

local KEY_A = 65
local keyslist = {}
local string = ""
for i = 1, 26 do
	local ch = string.char(KEY_A + i - 1)
	keyslist[i] = {description = ch, data = ch}
end

configuration_options = {
	{
		name="autoequipopeningamesettings",
		label="Button to open settings?",
		-- longlabel="Which button should open the in-game settings menu?",
		options = keyslist,
		default="P",
		hover="Changing this from in-game won't work. Sorry."
	},
	{
		name="ae_enablemod",
		label="Enable mod?",
		-- longlabel="This allows you to completely disable the mod from in-game. No use outside of the in-game menu.",
		options = {
			{description="No",data=0},
			{description="Yes",data=1}
		},
		hover="This has no use outside of the in-game settings menu.",
		default=1
	},
	{
		name="ae_switchtools",
		label="Enable tool switching?",
		options = {
			{description="No",data=0},
			{description="Yes - Both",data=1},
			{description="Yes - Space only",data=2},
			{description="Yes - Mouse only",data=3}
		},
		hover="Allows automatically switching of tools to allow more actions. Required for most features.",
		default=1
	},
	{
		name="ae_use_nearby_tools",
		label="Try use nearby tools?",
		options = {
			{description="No",data=0},
			{description="Yes",data=1}
		},
		hover="Allows the character to pickup a nearby tool, if it can be used for an action, like an axe for cutting a tree.",
		default=1
	},
	{
		name="autoequipignorerestrictions",
		label="CTRL + Space overwrites?",
		-- longlabel="CTRL + Space overwrites restrictions? Like digging up saplings",
		options = {
			{description="No", data=0},
			{description="Yes", data=1},
		},
		hover="An example, if enabled, holding CTRL and pressing Space will dig up saplings and grass.",
		default=1
	},
	{
		name="ae_equipweapon",
		label="Equip weapon on combat?",
		-- longlabel="Equip best weapon when engaging enemies?",
		hover="'NOTE: If enabled, it will only equip something if your hands are empty.",
		options={
			{description="No", data=0},
			{description="Yes", data=1}
		},
		default=1,
	},
	{
		name="ae_crafttools",
		label="Automatically craft tools?",
		-- longlabel="Automatically craft needed tools for tasks?",
		options={
			{description="No", data=0},
			{description="Yes", data=1},
			{description="Yes and Golden", data=2}
		},
		default=1,
	},
	{
		name="ae_crafttools_mouse",
		label="Show craft tool option?",
		-- longlabel="Automatically craft needed tools for tasks?",
		options={
			{description="No", data=0},
			{description="Yes", data=1},
			{description="Yes - Golden", data=2}
		},
		default=1,
	},
	{
		name="ae_replanttrees",
		label="Auto re-plant trees?",
		-- longlabel="Automatically re-plant trees after digging up stumps?",
		hover="NOTE: You HAVE to hold the action button after digging up the stump, otherwise it won't re-plant it!",
		options={
			{description="No", data=0},
			{description="Yes", data=1}
		},
		default=1,
	},
	{
		name="ae_alwaysignoresaps",
		label="Ignore saplings completely?",
		-- longlabel="Ignore digging saplings, even if a shovel is equipped?",
		hover="Will ignore saplings when holding space, even if a shovel is equipped. Useful for planting many saplings.",
		options={
			{description="No", data=0},
			{description="Yes", data=1}
		},
		default=0,
	},
	{
		name="ae_refuelfires",
		label="Re-fuel fires with right-click?",
		-- longlabel="(BETA) Enable re-fueling fires with right-click?",
		hover="BURN-ORDER: Preferred > Two other choices > Anything else burnable",
		options={
			{description="No", data=0},
			{description="Yes - Logs", data=1, hover="Will prefer to use Logs as fuel, else it'll go from backpack, then from right to left."},
			{description="Yes - Twigs", data=2, hover="Will prefer to use Twigs as fuel, else it'll go from backpack, then from right to left."},
			{description="Yes - Grass", data=3, hover="Will prefer to use Cut-Grass as fuel, else it'll go from backpack, then from right to left."}
		},
		default=0,
	},
	{
		name="ae_repairwalls",
		label="Repair walls with right-click?",
		-- longlabel="(BETA) Enable repair walls with right-click?",
		hover="NOTE: You need walls in your inventory when doing this.",
		options={
			{description="No", data=0},
			{description="Yes", data=1}
		},
		default=0,
	},
	{
		name="ae_boomcritters",
		label="Use boomerang on critters?",
		options={
			{description="No", data=0},
			{description="Yes", data=1}
		},
		default=0,
	},
	{
		name="ae_lightindark",
		label="Make light in the dark?",
		-- longlabel="(BETA) Make light when standing in darkness?",
		hover="(BETA) This feature is very basic and will be built upon later.",
		options={
			{description="No", data=0},
			{description="Equip only", data=1},
			{description="Craft and Equip", data=2}
		},
		default=0,
	}
}