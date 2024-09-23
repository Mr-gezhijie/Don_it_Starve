local AutoEnableAtNight = GetModConfigData("AutoEnableAtNight")
local AutoEnableAtDusk = GetModConfigData("AutoEnableAtDusk")
local AutoDisableAtDay = GetModConfigData("AutoDisableAtDay")
local EnterGameAutoOpen = GetModConfigData("EnterGameAutoOpen")
local PresentStageWarn = GetModConfigData("PresentStageWarn")
local CHS = GetModConfigData("Language")

local function setNightVisionEnabled(inst, bool)
    if bool == inst.local_nightvision then
        return
    end

    inst.local_nightvision = bool

    inst.components.playervision:ForceNightVision(bool)
    inst.components.playervision:SetCustomCCTable(bool and "images/colour_cubes/beaver_vision_cc.tex" or nil)
end

local function TIPS(title, content)
    GLOBAL.ChatHistory:AddToHistory(GLOBAL.ChatTypes.Message, nil, nil,
            title,
            content, GLOBAL.PLAYERCOLOURS.CORAL)
end

local function autoEnable(inst)
    if PresentStageWarn then
        local title = CHS and "现时间阶段：" or "At this time stage:"
        local c_night = CHS and "夜晚" or "NIGHT"
        local c_dusk = CHS and "黄昏" or "DUSK"
        local c_day = CHS and "白昼" or "DAY"
        local symbol = " !!!!!!!!"

        if GLOBAL.TheWorld.state.phase == "night" then
            TIPS(title, c_night .. symbol)
        elseif GLOBAL.TheWorld.state.phase == "dusk" then
            TIPS(title, c_dusk .. symbol)
        elseif GLOBAL.TheWorld.state.phase == "day" then
            TIPS(title, c_day .. symbol)
        end
    end

    if GLOBAL.TheWorld.state.phase == "night" and AutoEnableAtNight then
        setNightVisionEnabled(inst, true)
    elseif GLOBAL.TheWorld.state.phase == "dusk" and AutoEnableAtDusk then
        setNightVisionEnabled(inst, true)
    elseif GLOBAL.TheWorld.state.phase == "day" and AutoDisableAtDay and inst.local_nightvision then
        setNightVisionEnabled(inst, false)
    end
end

local function toggle()
    -- 聊天不生效功能
    if not (GLOBAL.TheFrontEnd:GetActiveScreen().name:find("HUD") ~= nil and not (GLOBAL.ThePlayer.HUD:IsControllerCraftingOpen() or GLOBAL.ThePlayer.HUD:IsControllerInventoryOpen())) then
        return
    end
    if GLOBAL.ThePlayer.local_nightvision == nil then
        GLOBAL.ThePlayer.local_nightvision = false
    end
    setNightVisionEnabled(GLOBAL.ThePlayer, not GLOBAL.ThePlayer.local_nightvision)
end

-- 自定义键位
local ToggleEnableKey = GetModConfigData("ToggleHotkey") or "N"
if type(ToggleEnableKey) == "string" then
    ToggleEnableKey = ToggleEnableKey:lower():byte()
end

AddPlayerPostInit(function(inst)
    inst:WatchWorldState("phase", autoEnable)
    if EnterGameAutoOpen then
        setNightVisionEnabled(inst, true)
    end
    GLOBAL.TheInput:AddKeyDownHandler(ToggleEnableKey, toggle)
end)