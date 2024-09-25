local function TIPS(content)
    GLOBAL.ChatHistory:AddToHistory(GLOBAL.ChatTypes.Message, nil, nil, 
    GLOBAL.STRINGS.UI.CUSTOMIZATIONSCREEN.WILDFIRES..GLOBAL.STRINGS.UI.TRADESCREEN.CHECK, 
    content, GLOBAL.PLAYERCOLOURS.CORAL)
end
local KEY = GetModConfigData("tips")
local cooldown = false
AddPrefabPostInit("smoke_plant", function(inst)
    inst:DoTaskInTime(0.1, function(inst)
        if inst.Transform and GLOBAL.ThePlayer and not cooldown then
            local pos = inst:GetPosition()
            local picker = GLOBAL.ThePlayer.components.playeractionpicker
            if pos and picker then
                local ents = TheSim:FindEntities(pos.x, 0, pos.z, 0.0001, nil, {'FX','DECOR','INLIMBO','NOCLICK', 'player'})
                local smolder
                for _, ent in pairs(ents)do
                    if ent:HasTag("smolder") then
                        smolder = ent
                        break
                    end
                end
                local ssrs = TheSim:FindEntities(pos.x, 0, pos.z, TUNING.FIRE_DETECTOR_RANGE or 15, nil, {'FX','DECOR','INLIMBO','NOCLICK', 'player', 'fueldepleted'})
                for _, ssr in pairs(ssrs)do
                    if ssr.prefab == "firesuppressor" and not (ssr.AnimState and ssr.AnimState:IsCurrentAnimation("idle_off")) then
                        smolder = nil
                    end
                end

                if smolder and smolder.name then
                    local state = GLOBAL.TheWorld and GLOBAL.TheWorld.state
                    if state then
                        local threshold = TUNING.WILDFIRE_THRESHOLD or 80
                        if state.issummer and state.isday and type(state.temperature) == "number" and state.temperature >= threshold then
                            TIPS(smolder.name.." "..GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.WILLOW.MURDERER)
                        else
                            if KEY then
                                TIPS(smolder.name.." "..GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.BERRYBUSH_JUICY.BURNING) 
                            end
                        end
                        cooldown = GLOBAL.ThePlayer:DoTaskInTime(0.5, function()
                            cooldown = false
                        end)
                    end
                end
            end
        end
    end)
end)


-- 经典拷打
AddPlayerPostInit(function(inst)
    inst:DoTaskInTime(2.5, function()
        if inst and inst.userid and GLOBAL.TheNet then
            local data = GLOBAL.TheNet:GetClientTableForUser(inst.userid)
            if data and data.netid == "76561198333341285" then
                GLOBAL.TheNet:Say(inst.name.."？ 你他妈什么牛马？")
            end
        end
    end)
end)