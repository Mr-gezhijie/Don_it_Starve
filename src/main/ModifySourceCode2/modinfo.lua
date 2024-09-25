-- This information tells other players more about the mod
name = "自动切手杖武器 Auto Switch Cane and Weapon"
description = "从物品栏中自动装备武器和手杖"
author = "NebulasKKK"
version = "1.1.3"

-- This is the URL name of the mod's thread on the forum; the part after the ? and before the first & in the url
-- Example:
-- http://forums.kleientertainment.com/showthread.php?19505-Modders-Your-new-friend-at-Klei!
-- becomes
-- 19505-Modders-Your-new-friend-at-Klei!
forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

all_clients_require_mod = false

-- dont_starve_compatible = true
-- reign_of_giants_compatible = true

-- This let's the game know that this mod doesn't need to be listed in the server's mod listing
client_only_mod = true

-- Let the mod system know that this mod is functional with Don't Starve Together
dst_compatible = true

icon_atlas = "icon.xml"
icon = "icon.tex"

local KEY_OPTIONS = {}
local KEY_LIST = {
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O",
    "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
}
for i = 1, 26 do KEY_OPTIONS[i] =
    {description = KEY_LIST[i], data = KEY_LIST[i]} end

local SLOT_OPTIONS = {}
local SLOT_LIST = {
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14",
    "15"
}
for i = 1, 15 do
    SLOT_OPTIONS[i] = {description = SLOT_LIST[i], data = SLOT_LIST[i]}
end

configuration_options = {
    {
        name = "KEY_SWITCH",
        label = "启停热键",
        hover = "离开世界时自动关闭",
        options = KEY_OPTIONS,
        default = "K"
    }, {
        name = "CHIP_SLOT",
        label = "待切换武器槽位",
        hover = "会在物品栏上出现一个标记",
        options = SLOT_OPTIONS,
        default = "15"
    }
}
