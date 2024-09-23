local CHS = locale == "zh" or locale == "zhr"

name = "AutoNightVision(自动夜视)"
description = CHS and [[
仅视觉效果，不能避免被查理攻击！

功能：
1。黑夜的时候有夜视效果
2。鼹鼠帽不再是黑白

对原版的优化：
1。加入 时间段 白天/黄昏/夜晚  提示效果
2。聊天也能按键生效问题 以及不生效问题
3。进游戏自动开启夜视
4。加入语言设置，如果是不是中国的小伙伴，我不知道会不会生效

一般功能都可以进行设置，如果还有那些地方不足欢迎留言

此mod为搬运优化
]] or [[
Only visual effects cannot avoid being attacked by Charlie!

Function:
1. Night vision effect in the dark
2. The mole hat is no longer black and white

For the optimization of the original version:
1. Add daytime/dusk/nighttime reminder effect
2. The issue of button activation and deactivation during chat
3. Automatically turn on night vision when entering the game
4. Add language settings, I don't know if it will take effect if you are not a Chinese partner

General functions can be set, if there are still areas that are insufficient, please feel free to leave a message

This mod is for handling optimization
]]
author = "GEZHIJIE"
version = "1.0.1"
api_version = 10
dst_compatible = true
client_only_mod = true
all_clients_require_mod = false
icon_atlas = "modicon.xml"
icon = "modicon.tex"
priority = -10000



-- 处理绑定键
local KEY_A = 65
local keyslist = {}
local string = ""
for i = 1, 26 do
    local ch = string.char(KEY_A + i - 1)
    keyslist[i] = {description = ch, data = ch}
end

configuration_options = {
    {
        name = "FunctionSettings",
        label = CHS and "功能设置" or "Function Settings",
        options = { {
                        description = "",
                        data = ""
                    } },
        default = ""
    },
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
        name = "ToggleHotkey",
        label = CHS and "快捷键" or "Shortcut Keys",
        options = keyslist,
        default = "N"
    },
    {
        name = "EnterGameAutoOpen",
        label = CHS and "进游戏自动开启" or "Enter Game Auto Open",
        options = {
            { description = CHS and "禁用" or "Disable", data = false },
            { description = CHS and "启用" or "Enable", data = true }
        },
        default = true
    },
    {
        name = "PresentStageWarn",
        label = CHS and "时间阶段提醒" or "Time Stage Reminder",
        options = {
            { description = CHS and "禁用" or "Disable", data = false },
            { description = CHS and "启用" or "Enable", data = true }
        },
        hover = CHS and "就是这一天的三个阶段，到了的时候进行提醒" or "There are three stages of this day, and reminders will be given when the time comes",
        default = true
    },
    {
        name = "AutoSettings",
        label = CHS and "自动设置" or "Auto Settings",
        options = { {
                        description = "",
                        data = ""
                    } },
        default = ""
    },
    {
        name = "AutoEnableAtNight",
        label = CHS and "自动在夜晚时开启" or "Auto enable at night",
        options = {
            { description = CHS and "禁用" or "Disable", data = false },
            { description = CHS and "启用" or "Enable", data = true }
        },
        default = true
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
        default = true
    },

}
