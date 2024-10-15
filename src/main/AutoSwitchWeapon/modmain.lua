local KEY_SWITCH = GLOBAL["KEY_" .. GetModConfigData("KEY_SWITCH")]
local CHIP_SLOT = GLOBAL.tonumber(GetModConfigData("CHIP_SLOT"))
local IS_ACTIVATION = not GetModConfigData("isActivation")
local LANGUAGE = not GetModConfigData("Language")

Assets = {
    Asset("IMAGE", "images/icon-autoswitch-hide.tex"),
    Asset("IMAGE", "images/icon-autoswitch-hint.tex"),
    Asset("ATLAS", "images/icon-autoswitch-hide.xml"),
    Asset("ATLAS", "images/icon-autoswitch-hint.xml")
}

local WEAPON_LIST = {
    blowdart_fire = 8, -- 吹箭-火
    blowdart_sleep = 8, -- 吹箭-催眠
    blowdart_pipe = 8, -- 吹箭
    blowdart_yellow = 8, -- 吹箭-雷电
    blowdart_walrus = 8, -- 吹箭-海象？？？？？
    firestaff = 8, -- 火魔杖
    icestaff = 8, -- 冰魔杖
    firepen = 8,
    houndstooth_blowpipe = 12, -- 狗牙吹箭
    staff_lunarplant = 8, -- 亮茄魔杖
    pocketwatch_weapon = TUNING.WHIP_RANGE, -- 怀表武器范围
    whip = TUNING.WHIP_RANGE, -- 鞭子
    bullkelp_root = TUNING.BULLKELP_ROOT_RANGE, -- 海带根

    voidcloth_boomerang = 10, -- 阴郁回旋镖
    boomerang =12, -- 回旋镖
    slingshot = 10, -- 可靠的弹弓 --角色专属的
    bomb_lunarplant = 8, --亮茄炸弹

    -- mod
    danzhu_staff = 10,  -- 孤岛抽奖，弹珠法杖
}

-- 不切换手杖的物品列表
local TOOL_LIST = {
    torch = GetModConfigData("torch"), -- 火炬
    lantern = GetModConfigData("lantern"), -- 提灯
    umbrella = GetModConfigData("umbrella"), -- 猪皮伞
    grass_umbrella = GetModConfigData("grass_umbrella"), -- 花伞
    -- 我新加入的
    lighter = GetModConfigData("lighter"), -- 薇洛的打火机
    reskin_tool = GetModConfigData("reskin_tool"), -- 清洁扫把
    bugnet = GetModConfigData("bugnet"), -- 捕虫网
    shovel = GetModConfigData("shovel"), -- 铲子
    goldenshovel = GetModConfigData("goldenshovel"), -- 黄金铲子
    pitchfork = GetModConfigData("pitchfork"), -- 干草叉
    goldenpitchfork = GetModConfigData("goldenpitchfork"), -- 黄金干草叉
    wateringcan = GetModConfigData("wateringcan"), -- 浇水壶
    premiumwateringcan = GetModConfigData("premiumwateringcan"), -- 鸟嘴壶
    farm_hoe = GetModConfigData("farm_hoe"), -- 园艺锄
    golden_farm_hoe = GetModConfigData("golden_farm_hoe"), -- 黄金园艺锄
    oar = GetModConfigData("oar"), -- 浆
    oar_driftwood = GetModConfigData("oar_driftwood"), -- 浮木浆
    malbatross_beak = GetModConfigData("malbatross_beak"), -- 邪天翁喙
    oceanfishingrod = GetModConfigData("oceanfishingrod"), -- 海钓杆
    voidcloth_umbrella = GetModConfigData("voidcloth_umbrella"), -- 暗影伞
    voidcloth_scythe = GetModConfigData("voidcloth_scythe"), -- 暗影镰刀
    telestaff = GetModConfigData("telestaff"), -- 传送魔杖

    yellowstaff = GetModConfigData("stars_staff"), -- 唤星者法杖
    opalstaff = GetModConfigData("stars_staff"), -- 唤月者法杖
    firestaff = GetModConfigData("fires_ice_staff"), -- 火魔杖
    icestaff = GetModConfigData("fires_ice_staff"), -- 冰魔杖
    boomerang = GetModConfigData("boomerang"), -- 回旋镖
    spear_wathgrithr_lightning = GetModConfigData("spear_wathgrithr_lightning"), -- 奔雷矛
    nightstick = GetModConfigData("nightstick"), -- 晨星锤
    blowdart_sleep = GetModConfigData("sleep_fire_yellow_blowdart"), -- 催眠吹箭
    blowdart_fire = GetModConfigData("sleep_fire_yellow_blowdart"), -- 火焰吹箭
    blowdart_yellow = GetModConfigData("sleep_fire_yellow_blowdart"), -- 雷电吹箭
    trident = GetModConfigData("trident"), -- 刺耳三叉戟
    staff_tornado = GetModConfigData("staff_tornado"), -- 天气风向标

    moonglassaxe = GetModConfigData("moonglassaxe"), -- 月光玻璃斧
    multitool_axe_pickaxe = GetModConfigData("multitool_axe_pickaxe"), -- 多用斧稿
    staff_lunarplant = GetModConfigData("staff_lunarplant"), -- 亮茄魔杖
    houndstooth_blowpipe = GetModConfigData("houndstooth_blowpipe"), -- 嚎炮弹
    bomb_lunarplant = GetModConfigData("bomb_lunarplant"), -- 亮茄炸弹
    shovel_lunarplant = GetModConfigData("shovel_lunarplant"), -- 亮茄锄铲
    pickaxe_lunarplant = GetModConfigData("pickaxe_lunarplant"), -- 亮茄粉碎者
    minifan = GetModConfigData("minifan"), -- 旋转的风扇（小风车）
    balloon = GetModConfigData("balloon"), -- 气球
    balloonparty = GetModConfigData("balloonparty"), -- 派对气球
    balloonspeed = GetModConfigData("balloonspeed"), -- 迅捷气球

}


AddPrefabPostInit("player_classified", function(inst)
    inst:DoTaskInTime(0.5, function(inst)
        if GLOBAL.ThePlayer then
            GLOBAL.ThePlayer:AddComponent("autoswitch")
            GLOBAL.ThePlayer.components.autoswitch:SetchipSlot(CHIP_SLOT)
            GLOBAL.ThePlayer.components.autoswitch:SetWeaponList(WEAPON_LIST)
            GLOBAL.ThePlayer.components.autoswitch:SetToollList(TOOL_LIST)
            GLOBAL.ThePlayer.components.autoswitch:IsAutoActivation(IS_ACTIVATION)
            GLOBAL.ThePlayer.components.autoswitch:IsLanguage(LANGUAGE)
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
