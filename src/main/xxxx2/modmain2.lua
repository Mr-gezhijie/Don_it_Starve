--设置为全局环境 就不用一个个GLOBAL的写
GLOBAL.setmetatable(env, {
    __index = function(t, k)
        return GLOBAL.rawget(GLOBAL, k)
    end
})
local scanlists = {}
scanlists.chester = GetModConfigData("chester") ~= false
scanlists.minotaur = GetModConfigData("minotaur") ~= false
scanlists.bigtentacle = GetModConfigData("bigtentacle") ~= false
scanlists.toadstool = GetModConfigData("toadstool") ~= false
scanlists.archive = GetModConfigData("archive") ~= false
scanlists.rabbithouse = GetModConfigData("rabbithouse") ~= false
scanlists.atrium_gate = GetModConfigData("atrium_gate") ~= false
scanlists.ancient_altar = GetModConfigData("ancient_altar") ~= false
scanlists.resurrent = GetModConfigData("resurrent") ~= false
scanlists.stair = GetModConfigData("stair") ~= false
scanlists.siving = GetModConfigData("siving") ~= false
scanlists.START = GetModConfigData("START") ~= false
scanlists.haqi = GetModConfigData("haqi") ~= false
scanlists.daywalker_cave = GetModConfigData("daywalker_cave") ~= false
scanlists.iceisland = GetModConfigData("iceisland") ~= false
scanlists.pigkin = GetModConfigData("pigkin") ~= false
scanlists.oldgrandma = GetModConfigData("oldgrandma") ~= false
scanlists.monkeyisland = GetModConfigData("monkeyisland") ~= false
scanlists.shadowboss = GetModConfigData("shadowboss") ~= false
scanlists.saltmine = GetModConfigData("saltmine") ~= false
scanlists.bigtree = GetModConfigData("bigtree") ~= false
scanlists.dragonfly = GetModConfigData("dragonfly") ~= false
scanlists.lion = GetModConfigData("lion") ~= false
scanlists.moonbase = GetModConfigData("moonbase") ~= false
scanlists.moonDungeon = GetModConfigData("moonDungeon") ~= false
scanlists.cave = GetModConfigData("cave") ~= false
scanlists.beequeen = GetModConfigData("beequeen") ~= false
scanlists.walrus = GetModConfigData("walrus") ~= false
scanlists.daywalker_master = GetModConfigData("daywalker_master") ~= false
scanlists.TourmalineField = GetModConfigData("TourmalineField") ~= false
scanlists.LilyPatch = GetModConfigData("LilyPatch") ~= false
local MapTiles = {}
local MapTiles_pos = {}
local dipiticks = 0
local havescanedflag = {}
local iceisland
local AlwaysAdd = {
    ["antlion.png"] = true,
    ["resurrection_stone.png"] = true,
    ["sculpture_rookbody_fixed.png"] = true,
}
local MapScenery = {
    lion = {
        [0] = { [0] = WORLD_TILES.DIRT, [1] = WORLD_TILES.DIRT, [2] = WORLD_TILES.DESERT_DIRT, [3] = WORLD_TILES.DESERT_DIRT },
        [1] = { [0] = WORLD_TILES.DESERT_DIRT, [1] = WORLD_TILES.DESERT_DIRT, [2] = WORLD_TILES.DESERT_DIRT, [3] = WORLD_TILES.DIRT },
        [2] = { [0] = WORLD_TILES.DIRT, [1] = WORLD_TILES.DESERT_DIRT, [2] = WORLD_TILES.DESERT_DIRT, [3] = WORLD_TILES.DESERT_DIRT },
        [3] = { [0] = WORLD_TILES.DESERT_DIRT, [1] = WORLD_TILES.DESERT_DIRT, [2] = WORLD_TILES.DESERT_DIRT, [3] = WORLD_TILES.DIRT },
    },
    moonbase = {
        [0] = { [0] = WORLD_TILES.FOREST, [1] = WORLD_TILES.FOREST, [2] = WORLD_TILES.GRASS, [3] = WORLD_TILES.FOREST },
        [1] = { [0] = WORLD_TILES.FOREST, [1] = WORLD_TILES.GRASS, [2] = WORLD_TILES.GRASS, [3] = WORLD_TILES.GRASS },
        [2] = { [0] = WORLD_TILES.GRASS, [1] = WORLD_TILES.GRASS, [2] = WORLD_TILES.GRASS, [3] = WORLD_TILES.GRASS },
        [3] = { [0] = WORLD_TILES.FOREST, [1] = WORLD_TILES.GRASS, [2] = WORLD_TILES.GRASS, [3] = WORLD_TILES.FOREST },
    },
    oldgrandma = {
        [0] = { [0] = WORLD_TILES.SHELLBEACH, [1] = WORLD_TILES.METEOR, [2] = WORLD_TILES.METEOR, [3] = WORLD_TILES.METEOR },
        [3] = { [0] = WORLD_TILES.METEOR, [1] = WORLD_TILES.METEOR, [2] = WORLD_TILES.METEOR, [3] = WORLD_TILES.METEOR, [4] = WORLD_TILES.SHELLBEACH },
        [4] = { [4] = WORLD_TILES.SHELLBEACH },
        [5] = { [1] = WORLD_TILES.METEOR, [2] = WORLD_TILES.SHELLBEACH },
    }
    ,
    dragonfly = {
        [0] = { [0] = WORLD_TILES.DIRT, },
        [2] = { [2] = WORLD_TILES.DESERT_DIRT, [3] = WORLD_TILES.DIRT, [4] = WORLD_TILES.DESERT_DIRT, },
        [3] = { [2] = WORLD_TILES.DESERT_DIRT, [3] = WORLD_TILES.DIRT, [4] = WORLD_TILES.DIRT, },
        [4] = { [2] = WORLD_TILES.DESERT_DIRT, [3] = WORLD_TILES.DIRT, [4] = WORLD_TILES.DESERT_DIRT, },
    },
    shadowboss = {
        [0] = { [0] = WORLD_TILES.CHECKER, [1] = WORLD_TILES.CHECKER, [3] = WORLD_TILES.CHECKER },
        [1] = { [0] = WORLD_TILES.CHECKER, [1] = WORLD_TILES.CARPET, [2] = WORLD_TILES.CARPET, },
        [2] = { [1] = WORLD_TILES.CARPET, [2] = WORLD_TILES.CARPET, [3] = WORLD_TILES.CHECKER },
        [3] = { [0] = WORLD_TILES.CHECKER, [2] = WORLD_TILES.CHECKER, },
    },
    minotaur = {
        [0] = { [0] = WORLD_TILES.BRICK, [9] = WORLD_TILES.BRICK },
        [9] = { [0] = WORLD_TILES.BRICK, [9] = WORLD_TILES.BRICK },
        [4] = { [4] = WORLD_TILES.MUD, [5] = WORLD_TILES.MUD },
        [5] = { [4] = WORLD_TILES.MUD, [5] = WORLD_TILES.MUD },
    },
    bigtentacle = {
        [0] = { [0] = WORLD_TILES.MARSH, [1] = WORLD_TILES.MARSH },
        [1] = { [1] = WORLD_TILES.MARSH, [2] = WORLD_TILES.MARSH, [3] = WORLD_TILES.MARSH, },
        [2] = { [0] = WORLD_TILES.MARSH, [1] = WORLD_TILES.MARSH, [2] = WORLD_TILES.MARSH },
        [3] = { [1] = WORLD_TILES.MARSH, [3] = WORLD_TILES.MARSH, },
    },
    atrium_gate = {
        [0] = { [0] = WORLD_TILES.BRICK, },
        [1] = { [0] = WORLD_TILES.IMPASSABLE, [2] = WORLD_TILES.BRICK },
        [3] = { [0] = WORLD_TILES.UNDERROCK },
        [6] = { [0] = WORLD_TILES.BRICK },
    },
    ancient_altar_broken2 = {
        [0] = { [0] = WORLD_TILES.TILES, [1] = WORLD_TILES.BRICK, [2] = WORLD_TILES.BRICK, [3] = WORLD_TILES.BRICK, },
        [1] = { [0] = WORLD_TILES.BRICK, [1] = WORLD_TILES.BRICK, [2] = WORLD_TILES.BRICK, [3] = WORLD_TILES.BRICK, },
        [2] = { [0] = WORLD_TILES.BRICK, [1] = WORLD_TILES.BRICK, [2] = WORLD_TILES.BRICK, [3] = WORLD_TILES.BRICK, },
        [3] = { [0] = WORLD_TILES.TILES, [1] = WORLD_TILES.BRICK, [2] = WORLD_TILES.BRICK, [3] = WORLD_TILES.BRICK, },
    },
    daywalker = {
        [0] = { [0] = WORLD_TILES.FOREST, [1] = WORLD_TILES.DIRT, [2] = WORLD_TILES.DIRT, [3] = WORLD_TILES.DIRT, },
        [1] = { [0] = WORLD_TILES.DIRT, [1] = WORLD_TILES.DIRT, [2] = WORLD_TILES.DIRT, [3] = WORLD_TILES.FOREST, },
        [2] = { [0] = WORLD_TILES.DIRT, [1] = WORLD_TILES.DIRT, [2] = WORLD_TILES.DIRT, [3] = WORLD_TILES.DIRT, },
        [3] = { [0] = WORLD_TILES.FOREST, [1] = WORLD_TILES.DIRT, [2] = WORLD_TILES.DIRT, [3] = WORLD_TILES.DIRT, },
    },
}
local function matchmap(start_x, start_z, needmatched, positivex, positivez, reversexz) --从某个点开始往xz匹配地图与写好的布局--MapTiles_pos
    local x, z = start_x, start_z
    local minx, minz
    for k, v in pairs(needmatched) do
        if not minx then minx = k end
        for kk, vv in pairs(v) do
            if not minz then minz = kk end
            x = not reversexz and (4 * positivex * (k)) or (4 * positivez * (kk)) + start_x
            z = not reversexz and (4 * positivez * (kk)) or (4 * positivex * (k)) + start_z
            if not reversexz then
                x = 4 * positivex * (k) + start_x
                z = 4 * positivez * (kk) + start_z
                if needmatched[k][kk] == false and MapTiles_pos[x] and (MapTiles_pos[x][z] == needmatched[0][0]) then
                    return false, 0, 0
                elseif needmatched[k][kk] and MapTiles_pos[x] and not (MapTiles_pos[x][z] == needmatched[k][kk]) then
                    return false, 0, 0
                end
            else
                x = 4 * positivez * (kk) + start_x
                z = 4 * positivex * (k) + start_z
                if needmatched[k][kk] == false and MapTiles_pos[x] and (MapTiles_pos[x][z] == needmatched[0][0]) then
                    return false, 0, 0
                elseif needmatched[k][kk] and MapTiles_pos[x] and not (MapTiles_pos[x][z] == needmatched[k][kk]) then
                    return false, 0, 0
                end
            end
        end
    end
    return true, positivex, positivez
end
local function MachMain(k, kk, match, ignoreopenedmap)
    if ignoreopenedmap then
        if ThePlayer and ThePlayer:CanSeePointOnMiniMap(k, 0, kk) then
            return
        end
    end
    local status, x, z
    local directions = {
        { 1,  1,  false },
        { -1, -1, false },
        { -1, 1,  false },
        { 1,  -1, false },
        { 1,  1,  true },
        { -1, -1, true },
        { -1, 1,  true },
        { 1,  -1, true }
    }
    for _, dir in ipairs(directions) do
        status, x, z = matchmap(k, kk, match, dir[1], dir[2], dir[3])
        if status then
            return status, x, z, dir[3]
        end
    end
end
local function MachCommon(match)
    local x, z, status, reverse
    if not MapTiles[match[0][0]] then return end
    for k, v in pairs(MapTiles[match[0][0]]) do
        for kk, vv in pairs(v) do
            status, x, z, reverse = MachMain(k, kk, match, true)
            if status then
                return status, x, z, reverse, k, kk
            end
        end
    end
end
local function findroom(roomname)
    if TheWorld.topology and TheWorld.topology.ids then
        for k, v in pairs(TheWorld.topology.ids) do
            if v and string.lower(v):find(roomname) or v and v == roomname
                or v and v:find(roomname) then
                --TheWorld.Map:GetNodeIdAtPoint(ThePlayer:GetPosition().x, 0, ThePlayer:GetPosition().z)
                local x, z = TheWorld.topology.nodes[k].x, TheWorld.topology.nodes[k].y
                return x, z
            end
        end
    end
end
local function CreatMapIcon(x, z, icon, png)
    if not x or not z then
        return
    end
    if not AlwaysAdd[png] and ThePlayer and ThePlayer:CanSeePointOnMiniMap(x, 0, z) then
    elseif not icon then
        local a = CreateEntity()
        a.entity:AddTransform()
        a.entity:AddMiniMapEntity()
        a.Transform:SetPosition(x, 0, z)
        a.MiniMapEntity:SetIcon(png)
        a.MiniMapEntity:SetPriority(11)
        a.MiniMapEntity:SetDrawOverFogOfWar(true)
        a.MiniMapEntity:SetIsProxy(true)
        a.MiniMapEntity:SetEnabled(true)
        a:AddTag("DECOR")
        a:AddTag("CLASSIFIED")
        a:AddTag("NOCLICK")
    else
        icon = CreateEntity()
        icon.entity:AddTransform()
        icon.entity:AddMiniMapEntity()
        icon.Transform:SetPosition(x, 0, z)
        icon.MiniMapEntity:SetIcon(png)
        icon.MiniMapEntity:SetPriority(11)
        icon.MiniMapEntity:SetDrawOverFogOfWar(true)
        icon.MiniMapEntity:SetIsProxy(true)
        icon.MiniMapEntity:SetEnabled(true)
        icon:AddTag("DECOR")
        icon:AddTag("CLASSIFIED")
        icon:AddTag("NOCLICK")
    end
end
local function DataDump1(x, z)
    dipiticks = dipiticks + 1
    local a = TheWorld.Map:GetTileAtPoint(x, 0, z)
    if MapTiles[a] then
        if MapTiles[a][x] then
            MapTiles[a][x][z] = true
        else
            MapTiles[a][x] = {}
            MapTiles[a][x][z] = true
        end
    else
        MapTiles[a] = {}
        MapTiles[a][x] = {}
        MapTiles[a][x][z] = true
    end
end
local function DataDump2(x, z)
    local a = TheWorld.Map:GetTileAtPoint(x, 0, z)
    if not MapTiles_pos[x] then
        MapTiles_pos[x] = {}
        MapTiles_pos[x][z] = a
    else
        MapTiles_pos[x][z] = a
    end
end

local function ScanMap()
    local x = 2
    while true do
        local z = 2
        while true do
            if z == 2 then
                DataDump1(x, z)
                DataDump1(4 - x, z)
                --
                DataDump2(x, z)
                DataDump2(4 - x, z)
            else
                DataDump1(x, z)
                DataDump1(x, 4 - z)
                DataDump1(4 - x, z)
                DataDump1(4 - x, 4 - z)
                --
                DataDump2(x, z)
                DataDump2(x, 4 - z)
                DataDump2(4 - x, z)
                DataDump2(4 - x, 4 - z)
            end
            if TheWorld.Map:GetTileAtPoint(x, 0, 4 - z) == WORLD_TILES.INVALID and TheWorld.Map:GetTileAtPoint(x, 0, z) == WORLD_TILES.INVALID then --虚空
                break
            end
            z = z + 4
        end
        if TheWorld.Map:GetTileAtPoint(x, 0, 2) == WORLD_TILES.INVALID and TheWorld.Map:GetTileAtPoint(4 - x, 0, 2) == WORLD_TILES.INVALID then --虚空
            break
        end
        x = x + 4
    end
end
GLOBAL.ScanMap = ScanMap
local function CountRangeNums(x, z, dipi, range)
    local num = 0
    local startX = x - 4 * math.floor(range / 4)
    local startZ = z - 4 * math.floor(range / 4)

    for i = startX, x + 4 * math.floor(range / 4) + 1, 4 do
        for j = startZ, z + 4 * math.floor(range / 4) + 1, 4 do
            if TheWorld.Map:GetTileAtPoint(i, 0, j) == dipi then
                num = num + 1
            end
        end
    end
    return num
end
local function surroundbycheck(x, z, olddipi, dipi, num)
    local direction = {}
    local a = 20
    for i = 1, a do
        local cos = math.cos(2 * math.pi * (i - 1) / a)
        local sin = math.sin(2 * math.pi * (i - 1) / a)
        direction[i] = { 1 * cos, 1 * sin }
    end
    local dirflag = {}
    local count = 0
    for i = 0, num or 5 do
        for ii = 0, num or 5 do
            for k, v in pairs(direction) do
                local tile = TheWorld.Map:GetTileAtPoint(x + i * v[1], 0, z + ii * v[2])
                if dirflag[k] then
                elseif tile and tile == dipi then
                    dirflag[k] = true
                    count = count + 1
                elseif tile and tile ~= olddipi and tile ~= dipi then
                    return false
                end
            end
        end
    end
    return count == #direction
end
--find部分
local function findmiddleopean()
    local middleoceantile = WORLD_TILES.OCEAN_SWELL
    if not MapTiles[middleoceantile] then return end
    for k, v in pairs(MapTiles[middleoceantile]) do
        for kk, vv in pairs(v) do
            if surroundbycheck(k, kk, middleoceantile, WORLD_TILES.OCEAN_COASTAL) then
                print(1111111, k, kk)
                --CreatMapIcon(k, kk, nil, "pigking.png")
            else
                --print(2222)
            end
        end
    end
end
local function findpigkin()
    if not MapTiles[WORLD_TILES.WOODFLOOR] then return end
    local x, z
    for k, v in pairs(MapTiles[WORLD_TILES.WOODFLOOR]) do
        for kk, vv in pairs(v) do
            if ThePlayer and ThePlayer:CanSeePointOnMiniMap(k, 0, kk) then
            elseif CountRangeNums(k, kk, WORLD_TILES.WOODFLOOR, 4) == 8 and CountRangeNums(k + 4, kk + 4, WORLD_TILES.WOODFLOOR, 4) == 8
                and CountRangeNums(k + 4, kk, WORLD_TILES.WOODFLOOR, 4) == 8 and CountRangeNums(k, kk + 4, WORLD_TILES.WOODFLOOR, 4) == 8 then
                x, z = k + 2, kk + 2
                CreatMapIcon(x, z, nil, "pigking.png")
                return
            end
        end
    end
    local x, z = findroom('pigking')
    CreatMapIcon(x, z, nil, "pigking.png")
end
local function findresurrent()
    if not MapTiles[WORLD_TILES.WOODFLOOR] then return end
    local x, z
    local havefoundpos = {}
    havefoundpos[0] = 0
    for k, v in pairs(MapTiles[WORLD_TILES.WOODFLOOR]) do
        for kk, vv in pairs(v) do
            if CountRangeNums(k, kk, WORLD_TILES.WOODFLOOR, 4) == 4 and CountRangeNums(k + 4, kk + 4, WORLD_TILES.WOODFLOOR, 4) == 4
                and CountRangeNums(k + 4, kk, WORLD_TILES.WOODFLOOR, 4) == 4 and CountRangeNums(k, kk + 4, WORLD_TILES.WOODFLOOR, 4) == 4 then
                local a
                for kkk, vvv in pairs(havefoundpos) do
                    if math.sqrt((kkk - k) ^ 2 + (vvv - kk) ^ 2) < 10 then
                        a = true
                        break
                    end
                end
                if not a then
                    x, z = k + 2, kk + 2
                    havefoundpos[x + math.random()] = z
                    CreatMapIcon(x, z, nil, "resurrection_stone.png")
                end
            end
        end
    end
end
local function findoldgrandma()
    local status, x, z, reverse, k, kk = MachCommon(MapScenery.oldgrandma)
    if status then
        if reverse then
            CreatMapIcon(k + 6 * z, kk + 10 * x, nil, "hermitcrab_home2.png")
        else
            CreatMapIcon(k + 10 * x, kk + 6 * z, nil, "hermitcrab_home2.png")
        end
        return
    end
    local x, z = findroom('StaticLayoutIsland:HermitcrabIsland')
    CreatMapIcon(x, z, nil, "hermitcrab_home2.png")
end
local function finmonkeyisland()
    local x, z = findroom('StaticLayoutIsland:MonkeyIsland')
    CreatMapIcon(x, z, nil, "monkey_queen.png")
end
local function findmoonDungeon()
    local x, z = findroom('MoonIsland_Mine:0:MoonDungeonPosition')
    if x and z then
        CreatMapIcon(x, z, nil, "moondungeon.tex")
    else
        local x, z = findroom('moonisland_beach')
        CreatMapIcon(x, z, nil, "star_trap.png")
    end
end
local function finmoonbase()
    local status, x, z, reverse, k, kk = MachCommon(MapScenery.moonbase)
    if status then
        if reverse then
            CreatMapIcon(k + 6.75 * z, kk + 6.88 * x, nil, "moonbase.png")
        else
            CreatMapIcon(k + 6.75 * x, kk + 6.88 * z, nil, "moonbase.png")
        end
        return
    end
    --这里如果找不到就模糊匹配
    local x, z = findroom('moonbase')
    CreatMapIcon(x, z, nil, "moonbase.png")
end

local function findcave()
    local x, z
    if not MapTiles[WORLD_TILES.DIRT] then return end
    for k, v in pairs(MapTiles[WORLD_TILES.DIRT]) do
        for kk, vv in pairs(v) do
            if CountRangeNums(k, kk, WORLD_TILES.DIRT, 4) == 8 and CountRangeNums(k + 4, kk + 4, WORLD_TILES.DIRT, 4) == 8
                and CountRangeNums(k + 4, kk, WORLD_TILES.DIRT, 4) == 8 and CountRangeNums(k, kk + 4, WORLD_TILES.DIRT, 4) == 8
                and CountRangeNums(k, kk, WORLD_TILES.DIRT, 8) == 12 then
                x, z = k + 2, kk + 2
                CreatMapIcon(x, z, nil, "cave_closed.png")
            end
        end
    end
end
local function findoasis()
    local x, z = findroom('oasis')
    CreatMapIcon(x, z, nil, "oasis.png")
end
local function findlion()
    local status, x, z, reverse, k, kk = MachCommon(MapScenery.lion)
    if status then
        if reverse then
            CreatMapIcon(k + 6 * z, kk + 6 * x, nil, "antlion.png")
        else
            CreatMapIcon(k + 6 * x, kk + 6 * z, nil, "antlion.png")
        end
        return
    end
    --这里如果找不到就模糊匹配
    local x, z = findroom('antlion')
    CreatMapIcon(x, z, nil, "antlion.png")
end
local function finddragonfly()
    local status, x, z, reverse, k, kk = MachCommon(MapScenery.dragonfly)
    if status then
        if reverse then
            CreatMapIcon(k - 1.25 * z, kk + 1.07 * x, nil, "lava_pond.png")
        else
            CreatMapIcon(k + 1.07 * x, kk - 1.25 * z, nil, "lava_pond.png")
        end
        return
    end
    --这里如果找不到就模糊匹配
    local x, z = findroom('dragonfly')
    CreatMapIcon(x, z, nil, "lava_pond.png")
end
local function findshadowboss()
    local match = MapScenery.shadowboss
    local x, z, status, reverse
    if not MapTiles[MapScenery.shadowboss[0][0]] then return end
    for k, v in pairs(MapTiles[MapScenery.shadowboss[0][0]]) do
        for kk, vv in pairs(v) do
            status, x, z, reverse = MachMain(k, kk, match)
            if status then
                if reverse then
                    CreatMapIcon(k + 6 * z, kk + 6 * x, nil, "sculpture_rookbody_fixed.png")
                else
                    CreatMapIcon(k + 6 * x, kk + 6 * z, nil, "sculpture_rookbody_fixed.png")
                end
            end
        end
    end
end
local function findsaltmine()
    if not MapTiles[WORLD_TILES.OCEAN_BRINEPOOL] then return end
    local x, z
    local havefoundpos = {}
    havefoundpos[0] = 0
    for k, v in pairs(MapTiles[WORLD_TILES.OCEAN_BRINEPOOL]) do
        for kk, vv in pairs(v) do
            if CountRangeNums(k, kk, WORLD_TILES.OCEAN_BRINEPOOL, 4) >= 2 then
                local a
                for kkk, vvv in pairs(havefoundpos) do
                    if math.sqrt((kkk - k) ^ 2 + (vvv - kk) ^ 2) < 100 then
                        a = true
                        break
                    end
                end
                if not a then
                    x, z = k, kk
                    havefoundpos[x + math.random()] = z
                    CreatMapIcon(x, z, nil, "saltstack.png")
                end
            end
        end
    end
end
local function findbigtree()
    if not MapTiles[WORLD_TILES.OCEAN_WATERLOG] then return end
    local x, z
    local havefoundpos = {}
    havefoundpos[0] = 0
    for k, v in pairs(MapTiles[WORLD_TILES.OCEAN_WATERLOG]) do
        for kk, vv in pairs(v) do
            if CountRangeNums(k, kk, WORLD_TILES.OCEAN_WATERLOG, 4) >= 2 then
                local a
                for kkk, vvv in pairs(havefoundpos) do
                    if math.sqrt((kkk - k) ^ 2 + (vvv - kk) ^ 2) < 150 then
                        a = true
                        break
                    end
                end
                if not a then
                    x, z = k, kk
                    havefoundpos[x + math.random()] = z
                    CreatMapIcon(x, z, nil, "oceantree_pillar.png")
                end
            end
        end
    end
end
--地下部分
local function findminotaur()
    local status, x, z, reverse, k, kk = MachCommon(MapScenery.minotaur)
    if status then
        if reverse then
            CreatMapIcon(k + 18 * z, kk + 18 * x, nil, "minotaurchest.png")
        else
            CreatMapIcon(k + 18 * x, kk + 18 * z, nil, "minotaurchest.png")
        end
        return
    end
    --TheLabyrinth:0:RuinedGuarden
    local x, z = findroom('TheLabyrinth:0:RuinedGuarden')
    CreatMapIcon(x, z, nil, "minotaurchest.png")
end
local function findbigtentacle()
    local match = MapScenery.bigtentacle
    local x, z, status, reverse
    if not MapTiles[MapScenery.bigtentacle[0][0]] then return end
    for k, v in pairs(MapTiles[MapScenery.bigtentacle[0][0]]) do
        for kk, vv in pairs(v) do
            if CountRangeNums(k, kk, WORLD_TILES.MARSH, 12) <= 11 then
                status, x, z, reverse = MachMain(k, kk, match, true)
                if status then
                    if reverse then
                        CreatMapIcon(k + 6 * z, kk + 6 * x, nil, "tentacle_pillar.png")
                    else
                        CreatMapIcon(k + 6 * x, kk + 6 * z, nil, "tentacle_pillar.png")
                    end
                end
            end
        end
    end
end
local function findtoadstool()
    local x, z = findroom('ToadStoolTask2:0:ToadstoolArenaCave')
    CreatMapIcon(x, z, nil, "toadstool_cap.png")
    local x, z = findroom('ToadStoolTask1:2:ToadstoolArenaMud')
    CreatMapIcon(x, z, nil, "toadstool_cap.png")
    local x, z = findroom('ToadStoolTask3:2:ToadstoolArenaMud')
    CreatMapIcon(x, z, nil, "toadstool_cap.png")
end
local function finarchive()
    local x, z = findroom('ArchiveMaze:0:ArchiveMazeRooms')
    CreatMapIcon(x, z, nil, "archive_runes.png")
end
local function findrabbithouse()
    if TheWorld.topology and TheWorld.topology.ids then
        for k, v in pairs(TheWorld.topology.ids) do
            if v and string.lower(v):find('rabbit')
                and not string.find(v, 'hole')
                and not string.find(v, 'MudWithRabbit')
                and not string.find(v, 'RabbitSpiderWar')
                and not string.find(v, 'PitRoom') then
                local x, z = TheWorld.topology.nodes[k].x, TheWorld.topology.nodes[k].y
                CreatMapIcon(x, z, nil, "rabbit_house.png")
            end
        end
    end
end
local function findatrium_gate()
    local status, x, z, reverse, k, kk = MachCommon(MapScenery.atrium_gate)
    if status then
        if reverse then
            CreatMapIcon(k + 12 * z, kk + 12 * x, nil, "atrium_gate.png")
        else
            CreatMapIcon(k + 12 * x, kk + 12 * z, nil, "atrium_gate.png")
        end
        return
    end
end
local function findancient_altar_broken()
    if TheWorld.topology and TheWorld.topology.ids then
        for k, v in pairs(TheWorld.topology.ids) do
            if v and string.lower(v):find('brokenaltar') then
                local x, z = TheWorld.topology.nodes[k].x, TheWorld.topology.nodes[k].y
                CreatMapIcon(x, z, nil, "tab_crafting_table.png")
            end
        end
    end
    local match = MapScenery.ancient_altar_broken2
    local x, z, status, reverse
    local havefoundpos = {}
    havefoundpos[10000] = 0
    if not MapTiles[MapScenery.ancient_altar_broken2[0][0]] then return end
    for k, v in pairs(MapTiles[MapScenery.ancient_altar_broken2[0][0]]) do
        for kk, vv in pairs(v) do
            local a
            for kkk, vvv in pairs(havefoundpos) do
                if math.sqrt((kkk - k) ^ 2 + (vvv - kk) ^ 2) <= 20 then
                    a = true
                    break
                end
            end
            if not a then
                status, x, z, reverse = MachMain(k, kk, match, true)
                if status then
                    havefoundpos[k + math.random()] = kk
                    if reverse then
                        CreatMapIcon(k + 7 * z, kk + 6 * x, nil, "tab_crafting_table.png")
                    else
                        CreatMapIcon(k + 6 * x, kk + 7 * z, nil, "tab_crafting_table.png")
                    end
                end
            end
        end
    end
end
local function findancient_altar()
    local x, z = findroom('SacredAltar:2:Altar')
    if x and z then
        CreatMapIcon(x, z, nil, "tab_crafting_table.png") --"tab_crafting_table.png"
        CreatMapIcon(x + 10, z, nil, "sacred_chest.png")
        return
    end
end
local function findbeequeen()
    local x, z = findroom('beequeen')
    CreatMapIcon(x, z, nil, "beequeenhivegrown.png")
end
local function findwalrus()
    local num = 0
    if TheWorld.topology and TheWorld.topology.ids then
        for k, v in pairs(TheWorld.topology.ids) do
            if v and string.lower(v):find('walrus') then
                local x, z = TheWorld.topology.nodes[k].x, TheWorld.topology.nodes[k].y
                CreatMapIcon(x, z, nil, "igloo.png")
                num = num + 1
            end
        end
    end
    print('海象巢穴数量：', num)
end
local function findiceisland()
    local x, z
    if not MapTiles[WORLD_TILES.OCEAN_ICE] then return end
    for k, v in pairs(MapTiles[WORLD_TILES.OCEAN_ICE]) do
        for kk, vv in pairs(v) do
            if CountRangeNums(k, kk, WORLD_TILES.OCEAN_ICE, 4) >= 1 then
                x, z = k, kk
                break
            end
        end
    end
    if iceisland then
        iceisland.Transform:SetPosition(x, 0, z)
    else
        iceisland = CreateEntity()
        iceisland.entity:AddTransform()
        iceisland.entity:AddMiniMapEntity()
        iceisland.Transform:SetPosition(x, 0, z)
        iceisland.MiniMapEntity:SetIcon("iceboulder.png")
        iceisland.MiniMapEntity:SetPriority(11)
        iceisland.MiniMapEntity:SetDrawOverFogOfWar(true)
        iceisland.MiniMapEntity:SetIsProxy(true)
        iceisland.MiniMapEntity:SetEnabled(true)
        iceisland:AddTag("DECOR")
        iceisland:AddTag("CLASSIFIED")
        iceisland:AddTag("NOCLICK")
    end
end
local function findstair()
    if TheWorld.topology and TheWorld.topology.ids then
        for k, v in pairs(TheWorld.topology.ids) do
            if v and string.find(v, 'CaveExitRoom') then
                --TheWorld.Map:GetNodeIdAtPoint(ThePlayer:GetPosition().x, 0, ThePlayer:GetPosition().z)
                local x, z = TheWorld.topology.nodes[k].x, TheWorld.topology.nodes[k].y
                CreatMapIcon(x, z, nil, "cave_open2.png")
            end
        end
    end
end
local function findsiving()
    local x, z = findroom('sivingsource')
    CreatMapIcon(x, z, nil, "siving_thetree.tex")
end
local function findSTART()
    local x, z = findroom('START')
    CreatMapIcon(x, z, nil, "portal_dst.png")
end
local function findchest()
    local x, z = findroom('Frogs and bugs:0:GrassyMoleColony')
    CreatMapIcon(x, z, nil, "chester.png")
    if x then return end
    x, z = findroom('Befriend the pigs:0:Marsh')
    CreatMapIcon(x, z, nil, "chester.png")
    if x then return end
    x, z = findroom('Magic meadow:2:Clearing')
    CreatMapIcon(x, z, nil, "chester.png")
    --Magic meadow:2:Clearing	
    --
end
local function findlgland()
    --[[ local x, z = findroom('StaticLayoutIsland:LgIsland')
    CreatMapIcon(x, z, nil, "lg_penquan.png") ]]
    --dont know png
end
local function findmydaywalker()
    local status, x, z, reverse, k, kk = MachCommon(MapScenery.daywalker)
    if status then
        if reverse then
            CreatMapIcon(k + 6 * z, kk + 6 * x, nil, "junk_pile_big.png")
        else
            CreatMapIcon(k + 6 * x, kk + 6 * z, nil, "junk_pile_big.png")
        end
        return
    end
end
local function findmyhaqi()
    local x, z = findroom('MudPit:0:SlurtlePlains')
    CreatMapIcon(x, z, nil, "hutch.png")
end
local function findmydaywalker_cave()
    --"daywalker_pillar.png"
    local x, z = findroom('MudLights:3:LightPlantField')
    CreatMapIcon(x, z, nil, "daywalker_pillar.png")
    local x, z = findroom('MudLights:4:LightPlantField')
    CreatMapIcon(x, z, nil, "daywalker_pillar.png")
    local x, z = findroom('MudLights:5:LightPlantField')
    CreatMapIcon(x, z, nil, "daywalker_pillar.png")
end
local function findmyTourmalineField()
    local x, z = findroom('TourmalineField')
    CreatMapIcon(x, z, nil, "elecourmaline.tex")
end
local function findmyLilyPatch()
    local x, z = findroom('LilyPatch')
    CreatMapIcon(x, z, nil, "lilybush.tex")
end
local function mainf(update)
    if not TUNING.mapthread then
        TUNING.mapthread = StartThread(function()
            if true then
                ScanMap()
                dipiticks = 0
                if TheWorld:HasTag("cave") then
                    if update then
                    else
                        --"agronssword.tex"
                        if scanlists.minotaur then
                            findminotaur()
                        end
                        if scanlists.bigtentacle then
                            findbigtentacle()
                        end
                        if scanlists.toadstool then
                            findtoadstool()
                        end
                        if scanlists.archive then
                            finarchive()
                        end
                        if scanlists.rabbithouse then
                            findrabbithouse()
                        end
                        if scanlists.atrium_gate then
                            findatrium_gate()
                        end
                        if scanlists.ancient_altar then
                            findancient_altar_broken()
                            findancient_altar()
                        end
                        if scanlists.resurrent then
                            findresurrent()
                        end
                        if scanlists.stair then
                            findstair()
                        end
                        if scanlists.siving then
                            findsiving()
                        end
                        if scanlists.START then
                            findSTART()
                        end
                        --哈奇
                        if scanlists.haqi then
                            findmyhaqi()
                        end
                        if scanlists.daywalker_cave then
                            findmydaywalker_cave()
                        end
                    end
                else
                    if update then
                        if scanlists.iceisland then
                            findiceisland()
                        end
                    else
                        if scanlists.pigkin then
                            findpigkin()
                        end
                        if scanlists.resurrent then
                            findresurrent()
                        end
                        if scanlists.oldgrandma then
                            findoldgrandma()
                        end
                        if scanlists.monkeyisland then
                            finmonkeyisland()
                        end
                        --findlunarportal() --为了这个醋包的饺子！--时代的眼泪！！！！
                        if scanlists.shadowboss then
                            findshadowboss()
                        end
                        if scanlists.saltmine then
                            findsaltmine()
                        end
                        if scanlists.bigtree then
                            findbigtree()
                        end
                        if scanlists.dragonfly then
                            finddragonfly()
                        end
                        if scanlists.lion then
                            findlion()
                        end
                        if scanlists.moonbase then
                            finmoonbase()
                        end
                        if scanlists.moonDungeon then
                            findmoonDungeon()
                        end
                        if scanlists.cave then
                            findcave()
                        end
                        if scanlists.beequeen then
                            findbeequeen()
                        end
                        if scanlists.chester then
                            findchest()
                        end
                        if scanlists.walrus then
                            findwalrus()
                        end
                        if scanlists.iceisland then
                            findiceisland()
                        end
                        --
                        if scanlists.daywalker_master then
                            findmydaywalker()
                        end
                        --
                        if scanlists.TourmalineField then
                            findmyTourmalineField()
                        end
                        if scanlists.LilyPatch then
                            findmyLilyPatch()
                        end
                    end
                end
            end
            MapTiles = {} --释放内存
            MapTiles_pos = {}
            KillThreadsWithID(TUNING.mapthread.id)
            TUNING.mapthread:SetList(nil)
            TUNING.mapthread = nil
        end, "mapthread")
    end
end
AddPrefabPostInit("world", function(world)
    local a = true
    world:ListenForEvent("playeractivated", function()
        if a then
            mainf()
            a = false
        else
            mainf(true)
        end
    end)
end)

if not TheNet:GetIsServer() then
    --
    AddPrefabPostInit("globalmapiconseeable", function(inst)
        if inst.faricon then return end

        local MiniMapEntity = inst.MiniMapEntity
        if MiniMapEntity and inst.Transform then --ThePlayer:CanSeePointOnMiniMap(x, 0, z)
            inst:DoTaskInTime(0, function()
                local x, y, z = inst.Transform:GetWorldPosition()
                if not ThePlayer or not ThePlayer:CanSeePointOnMiniMap(x, 0, z) then
                    local a = CreateEntity()
                    a.entity:AddTransform()
                    a.entity:AddMiniMapEntity()
                    a.entity:SetParent(inst.entity)
                    a.MiniMapEntity:CopyIcon(MiniMapEntity)
                    a.MiniMapEntity:SetDrawOverFogOfWar(true)
                    a.MiniMapEntity:SetIsProxy(true)
                    a.MiniMapEntity:SetEnabled(true)
                    a:AddTag("DECOR")
                    a:AddTag("CLASSIFIED")
                    a:AddTag("NOCLICK")
                    inst.faricon = a
                end
            end)
        end
    end)
end
