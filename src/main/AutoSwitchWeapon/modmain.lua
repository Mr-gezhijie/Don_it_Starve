local KEY_SWITCH = GLOBAL["KEY_" .. GetModConfigData("KEY_SWITCH")]
local CHIP_SLOT = GLOBAL.tonumber(GetModConfigData("CHIP_SLOT"))

Assets = {
    Asset("IMAGE", "images/icon-autoswitch-hide.tex"),
    Asset("IMAGE", "images/icon-autoswitch-hint.tex"),
    Asset("ATLAS", "images/icon-autoswitch-hide.xml"),
    Asset("ATLAS", "images/icon-autoswitch-hint.xml")
}

local WEAPON_LIST = {
    blowdart_fire = 8,
    blowdart_sleep = 8,
    blowdart_pipe = 8,
    blowdart_yellow = 8,
    blowdart_walrus = 8,
    firestaff = 8,
    icestaff = 8,
    firepen = 8,
    houndstooth_blowpipe = 12,
    staff_lunarplant = 8,
    pocketwatch_weapon = TUNING.WHIP_RANGE,
    whip = TUNING.WHIP_RANGE,
    bullkelp_root = TUNING.BULLKELP_ROOT_RANGE,
}

-- 不切换手杖的物品列表
local TOOL_LIST = {
    torch = true,
    lantern = true,
    umbrella = true,
    grass_umbrella = true,
}

AddPrefabPostInit("player_classified", function(inst)
    inst:DoTaskInTime(0.5, function(inst)
        if GLOBAL.ThePlayer then
            GLOBAL.ThePlayer:AddComponent("autoswitch")
            GLOBAL.ThePlayer.components.autoswitch:SetchipSlot(CHIP_SLOT)
            GLOBAL.ThePlayer.components.autoswitch:SetWeaponList(WEAPON_LIST)
            GLOBAL.ThePlayer.components.autoswitch:SetWeaponList(TOOL_LIST)
            GLOBAL.ThePlayer.components.autoswitch:SwitchSpinning()
        end
    end)
end)

GLOBAL.TheInput:AddKeyUpHandler(KEY_SWITCH, function()
    if GLOBAL.TheWorld and GLOBAL.ThePlayer and
        GLOBAL.ThePlayer.components.autoswitch then
        GLOBAL.ThePlayer.components.autoswitch:SwitchSpinning()
    end
end)
