local CHS = locale == "zh" or locale == "zhr"

name = CHS and "本地夜视" or "Local Night Vision"
description = CHS and "仅视觉效果，不能避免被查理攻击！" or "Visual effects only, can not avoid being attacked by Charlie!"
author = "KyuubiRan"
version = "1.0.5"
api_version = 10
dst_compatible = true
client_only_mod = true
all_clients_require_mod = false
icon_atlas = "modicon.xml"
icon = "modicon.tex"
priority = -10000

configuration_options = {
    {
        name = "AutoEnableAtNight",
        label = CHS and "自动在夜晚时开启" or "Auto enable at night",
        options = {
            { description = CHS and "禁用" or "Disable", data = false },
            { description = CHS and "启用" or "Enable", data = true }
        },
        default = false
    },
    {
        name = "AutoEnableAtDusk",
        label = CHS and "自动在黄昏时开启" or "Auto enable at dusk",
        options = {
            { description = CHS and "禁用" or "Disable", data = false },
            { description = CHS and "启用" or "Enable", data = true }
        },
        default = false
    },
    {
        name = "AutoDisableAtDay",
        label = CHS and "自动在白天时关闭" or "Auto disable at dat",
        options = {
            { description = CHS and "禁用" or "Disable", data = false },
            { description = CHS and "启用" or "Enable", data = true }
        },
        default = false
    },
    {
        name = "ToggleHotkey",
        label = CHS and "开启/关闭快捷键" or "Toggle hotkey",
        options = {
            { description = "A", data = 97 },
            { description = "B", data = 98 },
            { description = "C", data = 99 },
            { description = "D", data = 100 },
            { description = "E", data = 101 },
            { description = "F", data = 102 },
            { description = "G", data = 103 },
            { description = "H", data = 104 },
            { description = "I", data = 105 },
            { description = "J", data = 106 },
            { description = "K", data = 107 },
            { description = "L", data = 108 },
            { description = "M", data = 109 },
            { description = "N", data = 110 },
            { description = "O", data = 111 },
            { description = "P", data = 112 },
            { description = "Q", data = 113 },
            { description = "R", data = 114 },
            { description = "S", data = 115 },
            { description = "T", data = 116 },
            { description = "U", data = 117 },
            { description = "V", data = 118 },
            { description = "W", data = 119 },
            { description = "X", data = 120 },
            { description = "Y", data = 121 },
            { description = "Z", data = 122 },
        },
        default = 110
    }
}
