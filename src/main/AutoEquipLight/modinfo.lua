---
--- Created by GEZHIJIE.
--- DateTime: 2024/9/21 23:20
---

name = "Auto Equip Light(自动装备照明)"
description = [[
本地mod，改编的是别人代码，进行了优化
如果功能有什么建议和不足，欢迎留言
马上更新
天黑的时候，自动装备照明工具。
天黑自动装备提灯，火炬。天亮自动卸下。
装备顺序: 提灯 > 火炬 > 制作火炬。
黑暗中，静止不动才会制作火炬。
]]

author = "GEZHIJIE"
version = "1.0"
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
        label = "Is it made in the dark?",
        hover = "是否在黑暗中制作火炬？",
        options = {
            { description = "NO", data = 1, hover = "仅仅装备照亮物品/Only equip illuminated items" },
            { description = "YES", data = 2, hover = "没有照亮物品，制作火炬/Without illuminating the item, make a torch" }
        },
        default = 2,
    },

    {
        name = "ae_delay_time",
        label = "Equipment delay time",
        hover = "装备延迟时间",
        options = {
            { description = "0.20s", data = 0.20, hover = "建议2s或1s" },
            { description = "1s", data = 1, hover = "建议2s或1s" },
            { description = "2s", data = 2, hover = "建议2s或1s" },
            { description = "3s", data = 3, hover = "建议2s或1s" },
            { description = "4s", data = 4, hover = "建议2s或1s" },
            { description = "5s", data = 5, hover = "建议2s或1s" },
        },
        default = 2,
    }
}