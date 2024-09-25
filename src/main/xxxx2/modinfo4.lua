name = "扫描地图"
author = "萌萌的新"

description =
[[扫描地图，增加部分资源点图标

新更新：虫洞显示
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

version = "1.1.20"
server_filter_tags = {}
local null_options = {
	{ description = "", data = "" }
}
local function MakeOptions(name, label)
	return {
		name = name,
		label = label or '',
		options = {
			{ description = "开启", data = true },
			{ description = "关闭", data = false },
		},
		default = true,
	}
end
configuration_options =

{
	{
		name = "allsetting",
		label = "通用搜索设置",
		options = { {
			description = "",
			data = ""
		} },
		default = ""
	},
	MakeOptions("resurrent", "标记试金石"),
	{
		name = "mastersetting",
		label = "地面搜索设置",
		options = { {
			description = "",
			data = ""
		} },
		default = ""
	},
	MakeOptions("chester", "标记切斯特"),
	MakeOptions("iceisland", "标记冰岛"),
	MakeOptions("pigkin", "标记猪王"),
	MakeOptions("oldgrandma", "标记寄居蟹隐士岛"),
	MakeOptions("monkeyisland", "标记猴岛"),
	MakeOptions("shadowboss", "标记暗影三基佬底座"),
	MakeOptions("saltmine", "标记盐矿"),
	MakeOptions("bigtree", "标记水中木"),
	MakeOptions("dragonfly", "标记龙蝇"),
	MakeOptions("lion", "标记蚁狮"),
	MakeOptions("moonbase", "标记月台"),
	MakeOptions("cave", "标记洞穴入口"),
	MakeOptions("beequeen", "标记蜂后"),
	MakeOptions("walrus", "标记海象"),
	MakeOptions("daywalker_master", "标记拾荒疯猪"),
	{
		name = "cavesetting",
		label = "洞穴搜索设置",
		options = { {
			description = "",
			data = ""
		} },
		default = ""
	},
	MakeOptions("minotaur", "标记远古犀牛"),
	MakeOptions("bigtentacle", "标记大触手"),
	MakeOptions("toadstool", "标记毒菌蟾蜍"),
	MakeOptions("archive", "标记档案馆"),
	MakeOptions("rabbithouse", "标记兔屋"),
	MakeOptions("atrium_gate", "标记远古大门"),
	MakeOptions("ancient_altar", "标记远古塔"),
	MakeOptions("stair", "标记楼梯"),
	MakeOptions("START", "标记出生门"),
	MakeOptions("haqi", "标记哈奇"),
	MakeOptions("daywalker_cave", "标记噩梦疯猪"),





	{
		name = "mods",
		label = "模组相关设置",
		options = { {
			description = "",
			data = ""
		} },
		default = ""
	},
	MakeOptions("TourmalineField", "标记棱镜电气台"),
	MakeOptions("LilyPatch", "标记棱镜花丛位置"), MakeOptions("moonDungeon", "标记棱镜月之地下城"), MakeOptions("siving", "标记棱镜子规神木岩"),
}
