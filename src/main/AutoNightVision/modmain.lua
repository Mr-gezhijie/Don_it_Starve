local AutoEnableAtNight = GetModConfigData("AutoEnableAtNight")
local AutoEnableAtDusk = GetModConfigData("AutoEnableAtDusk")
local AutoDisableAtDay = GetModConfigData("AutoDisableAtDay")
local ToggleEnableKey = GetModConfigData("ToggleHotkey")

local function setNightVisionEnabled(inst, bool)
    if bool == inst.local_nightvision then
        return
    end

    inst.local_nightvision = bool

    inst.components.playervision:ForceNightVision(bool)
    inst.components.playervision:SetCustomCCTable(bool and "images/colour_cubes/beaver_vision_cc.tex" or nil)
end

local function autoEnable(inst)
    if GLOBAL.TheWorld.state.phase == "night" and AutoEnableAtNight then
        setNightVisionEnabled(inst, true)
    elseif GLOBAL.TheWorld.state.phase == "dusk" and AutoEnableAtDusk then
        setNightVisionEnabled(inst, true)
    elseif GLOBAL.TheWorld.state.phase == "day" and AutoDisableAtDay and inst.local_nightvision then
        setNightVisionEnabled(inst, false)
    end
end

local function toggle()
    if GLOBAL.ThePlayer.local_nightvision == nil then
        GLOBAL.ThePlayer.local_nightvision = false
    end

    setNightVisionEnabled(GLOBAL.ThePlayer, not GLOBAL.ThePlayer.local_nightvision)
end

AddPlayerPostInit(function(inst)
    inst:WatchWorldState("phase", autoEnable)
    GLOBAL.TheInput:AddKeyDownHandler(ToggleEnableKey, toggle)
end)
