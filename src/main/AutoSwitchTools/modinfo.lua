
local CHS = locale == "zh" or locale == "zhr"
--name = "AAAAAAAAAAAAAAAAAA"
name = "AutoSwitchTools 自动切换工具"
author = "GEZHIJIE"

description = CHS and [[
自动装备所需的工具

功能：
1。点击一个可工作的物品自动切装备（斧子稿子铲子锤子捕虫网镰刀）
2。按住空格可砍树和挖矿
3。对于部分物品有右键功能（比如右键远古大门插钥匙）
4。对于不同的角色右键可以做他们的动作（小恶魔和女武神和威洛）

对原版的优化：
1。我之多加了一个，按住空格可砍树和挖矿

此mod为搬运优化
]] or [[
Tools required for automatic equipment

Function:
1. Click on a working item to automatically cut equipment (axe, draft, shovel, hammer, insect catching net, sickle)
2. Press and hold the space to cut down trees and mine
3. For some items, there is a right-click function (such as right clicking on the ancient gate to insert the key)
4. Right click on different characters to perform their actions (Little Devil, Valkyrie, and Willow)

Optimization of the original version:
1. I added one more, hold down the space to chop down trees and mine

This mod is for handling optimization
]]
forumthread = ""
api_version = 10

all_clients_require_mod = false
client_only_mod = true

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

version = "1.1.7"
server_filter_tags = {}
local null_options = {
	{ description = "", data = "" }
}

configuration_options =
{
	{
		name = "walktoact",
		label = "改回克雷的走向动作",
		hover = "给群友写的，走路的时候也能选中实体",
		options =
		{
			-- {description = "自动", data = "auto"},
			{ description = "启用", data = true },
			{ description = "关闭", data = false },
		},
		default = true,
	},
}
