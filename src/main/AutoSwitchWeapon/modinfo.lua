local CHS = locale == "zh" or locale == "zhr"

name = "AutoSwitchWeapon 自动切换武器"
-- name = "AAAA"
description = CHS and [[
自动切换手杖和武器

功能：
1.行走自动切换手杖
2.攻击自动切换武器
3.按照武器存放位置切换
4.设置里可取消是否行走切换法杖

对原版的优化：
1.搬运雕像不会切手杖
2.启动游戏自动开启
3.增加不切手杖物品
4.不切手杖物品可设置里进行设置（如果缺少，请留言，我进行添加）

建议搭配Mod:
https://steamcommunity.com/sharedfiles/filedetails/?id=1598084686
https://steamcommunity.com/sharedfiles/filedetails/?id=3335860234

此Mod为搬运优化
原Mod地址：https://steamcommunity.com/sharedfiles/filedetails/?id=3225478506
原原Mod地址：https://steamcommunity.com/sharedfiles/filedetails/?id=2781167240

如果你觉得这个Mod不错，麻烦点个赞！
如果这个Mod，有哪里需要优化
欢迎留言讨论！
]] or [[
Automatically switch between cane and weapon

Function:
1. Automatic switching of walking cane
2. Automatic weapon switching during attack
3. Switch according to the storage location of the weapon
4. In the settings, you can cancel whether to walk or switch the wand

Optimization of the original version:
1. When moving statues, one cannot cut a cane
2. Automatically start the game
3. Add non cutting cane items
4. Non cutting cane items can be set in the settings (if missing, please leave a message and I will add it)

Suggest pairing with Mod:
https://steamcommunity.com/sharedfiles/filedetails/?id=1598084686 https://steamcommunity.com/sharedfiles/filedetails/?id=3335860234

This mod is optimized for handling
Original Mod Address: https://steamcommunity.com/sharedfiles/filedetails/?id=3225478506
Original Mod Address: https://steamcommunity.com/sharedfiles/filedetails/?id=2781167240

If you think this mod is good, please give it a thumbs up!
If there are any areas that need to be optimized for this mod
Welcome to leave a message for discussion!
]]

author = "GEZHIJIE"
version = "1.3.2"

forumthread = ""

api_version = 10

all_clients_require_mod = false

client_only_mod = true

dst_compatible = true

icon_atlas = "icon.xml"
icon = "icon.tex"

local KEY_OPTIONS = {}
local KEY_LIST = {
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O",
    "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
}
for i = 1, 26 do
    KEY_OPTIONS[i] = { description = KEY_LIST[i], data = KEY_LIST[i] }
end

local SLOT_OPTIONS = {}
local SLOT_LIST = {
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14",
    "15"
}
for i = 1, 15 do
    SLOT_OPTIONS[i] = { description = SLOT_LIST[i], data = SLOT_LIST[i] }
end

configuration_options = {
    {
        name = "Language",
        label = CHS and "语言" or "Language",
        options = {
            { description ="简体中文" , data = true },
            { description = "English" , data = false }
        },
        default = CHS
    },
    {
        name = "KEY_SWITCH",
        label = CHS and "启停热键" or "Start stop hotkey",
        options = KEY_OPTIONS,
        default = "K"
    },
    {
        name = "isActivation",
        label = CHS and "进游戏自动开启" or "Enter game auto open",
        hover = CHS and "进入游戏自动开启" or "Automatically start when entering the game",
        options = {
            { description = CHS and "禁用" or "Disable", data = false },
            { description = CHS and "启用" or "Enable", data = true }
        },
        default = true,
    },
    {
        name = "CHIP_SLOT",
        label = CHS and "待切换武器槽位" or "To switch weapon slots",
        hover = CHS and "会在物品栏上出现一个标记" or "A mark will appear on the inventory list",
        options = SLOT_OPTIONS,
        default = "15"
    },
    {
        name = "x1",
        label = CHS and "以下物品不切换" or "Follow items do not switch",
        options = { {
                        description = "",
                        data = ""
                    } },
        default = ""
    },
    {
        name = "torch",
        label = CHS and "火炬" or "torch",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
        },
        default = true,
    },
    {
        name = "lantern",
        label = CHS and "提灯" or "lantern",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
        },
        default = true,
    },
    {
        name = "umbrella",
        label = CHS and "猪皮伞" or "umbrella",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
        },
        default = true,
    },
    {
        name = "grass_umbrella",
        label = CHS and "花伞" or "grass_umbrella",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
        },
        default = true,
    },
    {
        name = "lighter",
        label = CHS and "薇洛的打火机" or "Willow's lighter",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "reskin_tool",
        label = CHS and "清洁扫把" or "reskin_tool",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "bugnet",
        label = CHS and "捕虫网" or "bugnet",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "shovel",
        label = CHS and "铲子" or "shovel",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "goldenshovel",
        label = CHS and "黄金铲子" or "goldenshovel",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "pitchfork",
        label = CHS and "干草叉" or "pitchfork",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "goldenpitchfork",
        label = CHS and "黄金干草叉" or "goldenpitchfork",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "wateringcan",
        label = CHS and "浇水壶" or "wateringcan",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "premiumwateringcan",
        label = CHS and "鸟嘴壶" or "premiumwateringcan",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "farm_hoe",
        label = CHS and "园艺锄" or "farm_hoe",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "golden_farm_hoe",
        label = CHS and "黄金园艺锄" or "golden_farm_hoe",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "oar",
        label = CHS and "浆" or "oar",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "oar_driftwood",
        label = CHS and "浮木浆" or "oar_driftwood",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "malbatross_beak",
        label = CHS and "邪天翁喙" or "malbatross_beak",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "oceanfishingrod",
        label = CHS and "海钓杆" or "oceanfishingrod",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "voidcloth_umbrella",
        label = CHS and "暗影伞" or "voidcloth_umbrella",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "voidcloth_scythe",
        label = CHS and "暗影镰刀" or "voidcloth_scythe",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "telestaff",
        label = CHS and "传送魔杖" or "telestaff",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "stars_staff",
        label = CHS and "唤星/月者法杖" or "stars_staff",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "fires_ice_staff",
        label = CHS and "冰/火法杖" or "fires_ice_staff",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "boomerang",
        label = CHS and "回旋镖" or "boomerang",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "spear_wathgrithr_lightning",
        label = CHS and "奔雷矛" or "spear_wathgrithr_lightning",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "nightstick",
        label = CHS and "晨星锤" or "nightstick",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "sleep_fire_yellow_blowdart",
        label = CHS and "催眠/火焰/雷电吹箭" or "sleep_fire_yellow_blowdart",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "trident",
        label = CHS and "刺耳三叉戟" or "trident",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "staff_tornado",
        label = CHS and "天气风向标" or "staff_tornado",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "moonglassaxe",
        label = CHS and "月光玻璃斧" or "moonglassaxe",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "multitool_axe_pickaxe",
        label = CHS and "多用斧稿" or "multitool_axe_pickaxe",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "staff_lunarplant",
        label = CHS and "亮茄魔杖" or "staff_lunarplant",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "houndstooth_blowpipe",
        label = CHS and "嚎炮弹" or "houndstooth_blowpipe",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "bomb_lunarplant",
        label = CHS and "亮茄炸弹" or "bomb_lunarplant",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "shovel_lunarplant",
        label = CHS and "亮茄锄铲" or "shovel_lunarplant",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "pickaxe_lunarplant",
        label = CHS and "亮茄粉碎者" or "pickaxe_lunarplant",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = false,
    },
    {
        name = "minifan",
        label = CHS and "旋转的风扇（小风车）" or "minifan",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "balloon",
        label = CHS and "普通气球" or "balloon",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "balloonparty",
        label = CHS and "派对气球" or "balloonparty",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "balloonspeed",
        label = CHS and "迅捷气球" or "balloonspeed",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },
    {
        name = "winona_telebrella",
        label = CHS and "女工-传送伞" or "winona_telebrella",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover = CHS and "会自动切换手杖" or "Will automatically switch the cane" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "不会自动切换手杖" or "Will not automatically switch canes" }
        },
        default = true,
    },

}
