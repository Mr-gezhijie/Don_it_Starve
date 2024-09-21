---
--- Created by GEZHIJIE.
--- DateTime: 2024/9/21 23:20
---
name = "Auto Equip Light(自动装备照亮)"
description = "天黑的时候，自动装备照明工具"
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
    keyslist[i] = {description = ch, data = ch}
end

configuration_options = {
    -- 设置 绑定键
    {
        name="autoequipopeningamesettings",
        label="Binding key(绑定键)",
        -- longlabel="Which button should open the in-game settings menu?",
        options = keyslist,
        default="L",
        hover="Modify binding key「修改绑定键」"
    },

    -- 是否启动
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
        name="ae_lightindark",
        label="Make light in the dark?",
        -- longlabel="(BETA) Make light when standing in darkness?",
        hover="(BETA) This feature is very basic and will be built upon later.",
        options={
            {description="No", data=0},
            {description="仅装备", data=1},
            {description="制作装备", data=2}
        },
        default=0,
    }
}