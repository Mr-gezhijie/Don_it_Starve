name = "AAAAAAAAAAAAAAAAAA"
author = "萌萌的新"

description =
[[包含以下要素，
1.点击一个可工作的物品自动切装备（斧子稿子铲子锤子捕虫网镰刀）
2.对于部分物品有右键功能（比如右键远古大门插钥匙）
3.对于不同的角色右键可以做他们的动作（小恶魔和女武神和威洛）
]]
forumthread = ""
api_version = 10

all_clients_require_mod = false
client_only_mod = true

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false

icon_atlas = "icn.xml"
icon = "icn.tex"

version = "1.1.39"
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
