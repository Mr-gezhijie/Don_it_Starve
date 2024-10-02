local CacheService, Cache = {}, {}
local ComponentsUsed = {
    "edible",
    "healer",
    "weapon",
    "finiteuses",
    "armor",
    "resistance",
    "equippable",
    "spellcaster",
    "fueled",
    "tool",
    "terraformer",
    "projectile",
    "complexprojectile",
    "perishable",
    "tradable",
}

local function CacheItem(item)
    if not item then
        return
    end

    local cacheItem = {
        components = {}
    }

    for i = 1, #ComponentsUsed do
        if item.components[ComponentsUsed[i]] then
            cacheItem.components[ComponentsUsed[i]] = item.components[ComponentsUsed[i]]
        end
    end

    return cacheItem
end

local NotAllowed = {
    ["blueprint"] = true,
    ["terrarium"] = true
}

local function AllowCache(item)
    return item
            and not NotAllowed[item.prefab]
end

function CacheService:GetCachedItem(item)
    if not AllowCache(item) then
        return nil
    end

    if not Cache[item.prefab] then
        local sim = TheWorld.ismastersim
        TheWorld.ismastersim = true

        local status, err = pcall(SpawnPrefab, item.prefab)
        if status then
            local clone = SpawnPrefab(item.prefab)
            Cache[item.prefab] = CacheItem(clone)
            clone:Remove()
            TheWorld.ismastersim = sim
        else
            Cache[item.prefab] = CacheItem(item)
            TheWorld.ismastersim = sim
        end

    end

    return Cache[item.prefab]
end

return CacheService
