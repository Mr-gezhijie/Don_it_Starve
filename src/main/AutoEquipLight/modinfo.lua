---
--- Created by GEZHIJIE.
--- DateTime: 2024/9/21 23:20
---

name = "Auto Equip Light(自动装备照明)"
--name = "AAAA"
description = [[
天黑自动装备照明工具

功能：
1。天黑自动装备照明工具
2。没有照明工具自动制作火把
3。带着照具走到有亮处的地方，会自动收起照具
4。装备顺序：提灯 > 火炬 > 制作火炬。

注意事项：
1。只要遇到光就会摘下照具，遇到萤火虫就会，卡一下脚
2。没有光的情况下，不要拿起火炬，因为会在做一个

已知/并要解决问题：
1。遇到光卡脚
2。卸下光具，拿起不会拿起上一个装备
3。没适配五格
4。现在优化只有火炬/提灯
5。加入别的装备判断，例如头戴，胸带
6。翻译问题
7。mod设置，增加设置
5。mod设置，解释问题

现在不能解决的：
1。光照边缘小概率不摘光具（貌似游戏bug）
2。延时装备光具，大概率不是设置的那个时间（确定游戏bug）

一般功能都可以进行设置，如果还有那些地方不足欢迎留言
此mod为搬运优化
]]

author = "GEZHIJIE"
version = "1.2.0"
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
        name = "ae_switch_delay_time",
        label = "Equipment delay time",
        hover = "切换光具延迟时间",
        options = {
            { description = "0.30s", data = 0.30, hover = "建议2s或1s" },
            { description = "1s", data = 1, hover = "建议2s或1s" },
            { description = "1.5s", data = 1.5, hover = "建议2s或1s" },
            { description = "2s", data = 2, hover = "建议2s或1s" },
            { description = "2.5s", data = 2.5, hover = "建议2s或1s" },
            { description = "3s", data = 3, hover = "建议2s或1s" },
            { description = "3.5s", data = 3.5, hover = "建议2s或1s" },
            { description = "4s", data = 4, hover = "建议2s或1s" },
            { description = "5s", data = 5, hover = "建议2s或1s" },
        },
        default = 2,
    },
    {
        name = "ae_make_delay_time",
        label = "Equipment delay time",
        hover = "制作火把延迟时间",
        options = {
            { description = "0.3s", data = 0.30, hover = "" },
            { description = "0.5s", data = 0.50, hover = "" },
            { description = "0.75s", data = 0.75, hover = "" },
            { description = "1s", data = 1, hover = "" },
            { description = "1.5s", data = 1.50, hover = "" },
            { description = "2s", data = 2, hover = "" },
            { description = "2.5s", data = 2.5, hover = "" },
            { description = "3s", data = 3, hover = "" },

        },
        default = 0.75,
    }
}