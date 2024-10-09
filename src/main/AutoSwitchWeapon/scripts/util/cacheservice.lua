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
            Cache[item.prefab] = CacheItem(item)
    end

    return Cache[item.prefab]
end

return CacheService
