---
--- Created by GEZHIJIE.
--- DateTime: 2024/9/21 23:20
---
local CHS = locale == "zh" or locale == "zhr"

name = "AutoLight(自动照明)"
--name = "AAAA"
description = CHS and [[
天黑自动装备照明工具

功能：
1。天黑自动装备照明工具
2。装备顺序：提灯 > 火炬 > 制作火炬
3。带着照明走到有亮处的地方，会自动收起照明
4。没有照明工具自动制作火炬
5。如果身上没有照明，并且在移动，会有提示消息，停下脚步才会制作火炬

注意事项：
1。不要装备两个提灯，会来回切换
2。没有光的情况下，不要拿起火炬，因为会在做一个
3。自动卸下照明，不会拿取上一个装备，建议订阅别的自动装备mod

已知问题：
1。没适配五格
2。例如像鼹鼠帽一样的装备，不会发光，也不会被打，我只知道这个（留言我在加）

现在不能解决的：
1。光照边缘小概率不摘光具，游戏本身问题，一般角度都会这样，必须紧贴光照建筑
2。延时装备光具，大概率不是设置的那个时间（确定游戏bug）

建议搭配Mod:
https://steamcommunity.com/sharedfiles/filedetails/?id=3336583014

此Mod为搬运优化
如果你觉得这个Mod不错，麻烦点个赞！
如果这个Mod，有哪里需要优化
欢迎留言讨论！
]] or [[
Automatic lighting equipment for dark conditions

Function:
1. Automatic lighting equipment for dark conditions
2. Equipment order: Lantern>Torch>Torch making
3. Walking with the lighting to a bright place will automatically retract the lighting
4. No lighting tools to automatically create torches
5. If there is no lighting on the body and it is moving, there will be a prompt message to stop and make a torch

matters needing attention:
1. Do not equip two lanterns, they will switch back and forth
2. Do not pick up the torch when there is no light, as it will make a mistake
3. Automatically remove lighting without taking the previous equipment. It is recommended to subscribe to other automatic equipment mods

Known issues:
1. Not compatible with five grids
2. For example, equipment like a mole hat that doesn't glow and won't get hit, that's all I know

What cannot be solved now:
1. There is a small probability that the lighting edge will not remove the lighting fixtures, which is a problem with the game itself. Generally, the angle will be like this, and it must be closely attached to the lighting building
2. Delay equipment optics, most likely not at the set time (identify game bug)

Suggest pairing with Mod:
https://steamcommunity.com/sharedfiles/filedetails/?id=3336583014

This mod is optimized for handling
If you think this mod is good, please give it a thumbs up!
If there are any areas that need to be optimized for this mod
Welcome to leave a message for discussion!
]]

author = "GEZHIJIE"
version = "2.0.2"
forumthread = ""
api_version_dst = 10
icon_atlas = "modicon.xml"  -- logo地址
icon = "modicon.tex"  -- logo图片

shipwrecked_compatible = false
dont_starve_compatible = false
reign_of_giants_compatible = false
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
    keyslist[i] = { description = ch, data = ch }
end

configuration_options = {
    {
        name = "ae_lightindark",
        label =CHS and "是否在黑暗中制作火炬？" or "Do you make torches in the dark?",
        hover =CHS and "只有停下脚步才会进行制作" or "Only by stopping can we proceed with production",
        options = {
            { description = CHS and "禁用" or "Disable", data = 1, hover =CHS and "仅仅装备照亮物品" or "Only equip illuminated items" },
            { description = CHS and "启用" or "Enable", data = 2, hover = CHS and "没有照亮物品，制作火炬" or "Without illuminating the item, make a torch" }
        },
        default = 2,
    },
    {
        name = "ae_switch_delay_time",
        label = CHS and "黑暗中切换照明" or "Light in the Dark",
        hover = CHS and "处于黑暗中几秒切换照明" or "Switch lighting in the dark for a few seconds",
        options = {
            { description = "0.30s", data = 0.30  },
            { description = "1s", data = 1 },
            { description = "1.5s", data = 1.5 },
            { description = "2s", data = 2 },
            { description = "2.5s", data = 2.5 },
            { description = "3s", data = 3},
            { description = "3.5s", data = 3.5},
            { description = "4s", data = 4 },
            { description = "4.5s", data = 4.5 },
            { description = "5s", data = 5 },
        },
        default = 2,
    },
    {
        name = "ae_make_delay_time",
        label =CHS and "制作火炬提醒" or "Create a torch reminder",
        hover =CHS and "需要火炬的时候，提醒你制作" or "When you need a torch, remind you to make one",
        options = {
            { description = "0.3s", data = 0.30},
            { description = "0.5s", data = 0.50},
            { description = "0.75s", data = 0.75},
            { description = "1s", data = 1},
            { description = "1.5s", data = 1.50},
            { description = "2s", data = 2},
            { description = "2.5s", data = 2.5},
            { description = "3s", data = 3},
            { description = "3.5s", data = 3.5},
            { description = "4s", data = 4},
            { description = "4.5s", data = 4.5},
            { description = "5s", data = 5},
            { description = "20s", data = 20},
        },
        default = 1.50
    },
    {
        name = "ae_no_night_put_down_light_time",
        label = CHS and "不是夜晚放下照明" or "no night down lighting",
        hover = CHS and "不是夜晚，几秒放下照明，因为要烧树"or "Not at night, put down the torch in a few seconds because you want to burn the tree",
        options = {
            { description = "1s", data = 1},
            { description = "2s", data = 2},
            { description = "3s", data = 3},
            { description = "3.5s", data = 3.5},
            { description = "4s", data = 4},
            { description = "4.5s", data = 4.5},
            { description = "5s", data = 5},
            { description = "5.5s", data = 5.5},
            { description = "6s", data = 6},
            { description = "6.5s", data = 6.5},
            { description = "7s", data = 7},
            { description = "20s", data = 20},
        },
        default = 3,
    },
    {
        name = "ae_encountering_light_time",
        label = CHS and "遇到光照放下"or "Encountering light，put down",
        hover = CHS and "遇到光照,卸下照明，数值小了，会小范围光卡脚"or "Encountering lighting, removing the lighting, the value is small, and the light is stuck in a small range",
        options = {
            { description = "0s", data = 0 },
            { description = "0.5s", data = 0.5 },
            { description = "1s", data = 1},
            { description = "1.5s", data = 1.5},
            { description = "2s", data = 2},
            { description = "2.5s", data = 2.5},
            { description = "3s", data = 3},
            { description = "3.5s", data = 3.5},
            { description = "4s", data = 4},
            { description = "4.5s", data = 4.5},
            { description = "5s", data = 5},
            { description = "5.5s", data = 5.5},
            { description = "6s", data = 6},
            { description = "6.5s", data = 6.5},
            { description = "7s", data = 7},
            { description = "20s", data = 20},
        },
        default = 1.5,
    },
    {
        name = "ae_luminous_illumination",
        label = CHS and "走出光马上照明" or "walk out light come lighting",
        hover =CHS and "走出光马上照明" or "Step out of the light and immediately illuminate",
        options = {
            { description = CHS and "禁用" or "Disable", data = false, hover =CHS and "建议这个"or "Suggest this" },
            { description = CHS and "启用" or "Enable", data = true, hover = CHS and "走出光立马照明，卡脚"or "Step out of the light and immediately illuminate，Stuck feet" }
        },
        default = false,
    }
}