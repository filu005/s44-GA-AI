if addon.InGetInfo then
   return {
      name      = "MainGA";
      desc      = "Starter file of GA";
      author    = "filip";
      date      = "2016";
      license   = "GNU GPL, v2 or later";

      layer     = 0; --math.huge;
      hidden    = true; -- don't show in the widget selector
      api       = true; -- load before all others?
      before    = {"all"}; -- make it loaded before ALL other widgets (-> it must be the first widget that gets loaded!)

      enabled   = true; -- loaded by default?
   }
end

------------------------------------------

require "FILsavetable.lua"

local function concatIndexed(tab,template)
    template = template or '%s,\n'
    local tt = {}
    for _,v in ipairs(tab) do
        tt[#tt+1]=template:format(v)
    end
    return '{\n' .. table.concat(tt) '},'
end

local function save_squadDefs()
    -- local squadDefs = include("LuaRules/Configs/squad_defs.lua")
    local SideFiles = VFS.DirList("luarules/configs/side_squad_defs", "*.lua")

    for _, SideFile in pairs(SideFiles) do
        local squadDefs = {}

        local fil_filepath = string.match(SideFile, "^luarules/configs/side_squad_defs/fil*.lua$")
        if (fil_filepath) then
            Spring.Log('squad defs loader', 'info', " - Processing "..SideFile)
            local tmpTable = VFS.Include(SideFile)
            if tmpTable then
                for morphName, subTable in pairs(tmpTable) do
                    if squadDefs[morphName] == nil then
                        squadDefs[morphName] = {}
                    end
                    local tmpSubTable = squadDefs[morphName]
                    -- add everything to it
                    for paramName, param in pairs(subTable) do
                        if paramName then
                            tmpSubTable[paramName] = param
                        else
                            table.insert(tmpSubTable, param)
                        end
                    end
                end
            end

            local fil_filename = string.match(fil_filepath, "fil*.lua$")
            if (squadDefs ~= nil) then
                local filxDefs = string.match(fil_filename, "fil%d*")
                table.FILsave(squadDefs, "0_" .. fil_filename, filxDefs .. "Defs")
                Spring.Echo("0_" .. fil_filename .." saved!")
            else
                Spring.Echo("0_" .. fil_filename .." nil!")
            end
        end
    end
end

-------------------------------------------------
-- Pobiera zdefiniowane squady z plikow .lua: 'LuaRules/configs/side_squad_defs'.
-- 'prefix' to nazwa nacji ('side'), ktorej squady maja zostac pobrane.
-------------------------------------------------
local function get_side_squdDefs(prefix)
    local SideFiles = VFS.DirList("luarules/configs/side_squad_defs", "*.lua")

    local squadDefs = {}
    for _, SideFile in pairs(SideFiles) do
        local squadDef = {}

        local pre_filepath = string.match(SideFile, "^luarules/configs/side_squad_defs/".. prefix .."*.lua$")
        if (pre_filepath) then
            Spring.Log('squad defs loader', 'info', " - Processing "..SideFile)
            local tmpTable = VFS.Include(SideFile)
            if tmpTable then
                for morphName, subTable in pairs(tmpTable) do
                    if squadDef[morphName] == nil then
                        squadDef[morphName] = {}
                    end
                    local tmpSubTable = squadDef[morphName]
                    -- add everything to it
                    for paramName, param in pairs(subTable) do
                        if paramName then
                            tmpSubTable[paramName] = param
                        else
                            table.insert(tmpSubTable, param)
                        end
                    end
                end
            end

            table.insert(squadDefs, squadDef)
        end
    end

    return squadDefs
end

require "Individual.lua"

local function recursive_search(aTable, search_key)
    for key, value in pairs(aTable) do --unordered search
        if(type(value) == "table") then
            if (key == search_key) then
                return value
            else
                return recursive_search(value, search_key)
            end
        end
    end

    return nil
end

local function get_side_members(squadDefs)
    side_members = {}

    local squad = recursive_search(squadDefs, "members") or {}

    for _, unit in pairs(squad) do
        side_members[unit] = 1
    end

    -- invert keys and values in side_members table
    local temp_tab = {}
    for k, _ in pairs(side_members) do
        table.insert(temp_tab, k)
    end
    side_members = temp_tab

    return side_members
end

local function generate_individuals(side_members, no_individuals)
    math.randomseed( os.time() )

    -- Spring.Echo("side_members: " .. table.concat(side_members, ","))

    local individuals = {}
    local no_units_per_squad = 10

    for i = 1, no_individuals do
        local ind = Individual()
        for j = 1, no_units_per_squad do
            local random_unit = side_members[math.random(1, #side_members)]
            table.insert(ind.members, random_unit)
        end
        ind.compute_build_cost()
        table.insert(individuals, ind)
    end

    return individuals
end

local function do_tournament(competitors)
    local winner = {}

    return winner
end
-------------------------------------------------
-- Funkcja realizuje 1. punkt GA: generuje 0. populacje.
-------------------------------------------------
local function generate_init_population(no_tournaments_, no_individuals_per_tournament_)
    local init_population = {}
    local no_tournaments = no_tournaments_ or 4
    local no_individuals_per_tournament = no_individuals_per_tournament_ or 8
    local side_prefix = "fil"

    local squadDefs = get_side_squdDefs(side_prefix)
    local side_members = get_side_members(squadDefs)

    for i = 1, no_tournaments do
        local competitors = generate_individuals(side_members, no_individuals_per_tournament)
        local winner = do_tournament(competitors)
        -- table.insert(init_population, winner)
    end

    return init_population
end


function addon.Initialize()
	local name = Game.modName
	Spring.Echo(("modName: %s"):format(name))

    local init_population = generate_init_population(4, 8)
    -- save_init_popilation_as_squadDefs(init_population)
    save_squadDefs()
end

function addon.Shutdown()
    Spring.Echo("zamykam MainGA")
end

------------------------------------------

Spring.Echo("laduje MainGA -- zapisuje squadDefs")

-- function addon.MousePress(...)
-- 	--Spring.Echo(...)
-- end