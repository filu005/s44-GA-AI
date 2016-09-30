function gadget:GetInfo()
	return {
		name = "MainGA",
		desc = "Starter file of GA",
		author = "filip",
		date = "2016",
		license = "GNU General Public License",
  		layer = 0,
		enabled = false
	}
end

------------------------------------------

local save_done

function gadget:GameStart()
    save_done = false
end

------------------------------------------

if (gadgetHandler:IsSyncedCode()) then

function gadget:RecvLuaMsg(msg,player)
    if msg == "save_done" then
        Spring.Echo("save_done!")
        Spring.SendCommands("QuitForce")
    end
end

--------------------------------- unsynced
else

local function concatIndexed(tab,template)
    template = template or '%s,\n'
    local tt = {}
    for _,v in ipairs(tab) do
        tt[#tt+1]=template:format(v)
    end
    return '{\n' .. table.concat(tt) '},'
end

local function save_squadDefs_form_squad_files()
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
                Script.LuaUI.SendDataToFile(squadDefs, "0_" .. fil_filename, filxDefs .. "Defs")
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

VFS.Include("LuaRules/Gadgets/GA/Individual.lua", nil, VFSMODE)

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
    -- math.randomseed( os.time() )
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

-------------------------------------------------
-- based on: log_b(a) = log_c(a) / log_c(b)
-------------------------------------------------
local function logarithm(value, base)
    return math.log(value) / math.log(base)
end

local function chech_damages_against_armor(weapons, armorType)
    for _,weaponInfo in ipairs(weapons) do
        local weaponDefID = weaponInfo.weaponDef
        local weaponDef = WeaponDefs[weaponDefID]
        local damages = weaponDef.damages
        return damages[armorType] or 0
    end
end

local function play_match(individual1, individual2)
    local fighting_unit_idx1, fighting_unit_idx2 = 1, 1
    local fighting_units = {nil, nil} -- unitDefs
    local fitness1, fitness2 = 0, 0

    repeat
        if fighting_units[1] == nil then
            fighting_units[1] = UnitDefNames[individual1.members[fighting_unit_idx1]]
        end

        if fighting_units[2] == nil then
            fighting_units[2] = UnitDefNames[individual2.members[fighting_unit_idx2]]
        end

        local health1 = fighting_units[1].health
        local health2 = fighting_units[2].health

        local armorType1 = fighting_units[1].armorType
        local armorType2 = fighting_units[2].armorType

        local weapons1 = fighting_units[1].weapons
        local weapons2 = fighting_units[2].weapons

        local damages1 = chech_damages_against_armor(weapons1, armorType2)
        local damages2 = chech_damages_against_armor(weapons2, armorType1)

        repeat
            health1 = health1 - damages1
            health2 = health2 - damages2
        until (health1 <= 0 or health2 <= 0)

        if health1 > health2 then
            fitness1 = fitness1 + 1
            fighting_unit_idx1 = fighting_unit_idx1 + 1
            fighting_units[1] = nil
        elseif (health1 == health2) then
            fitness1 = fitness1 + 1
            fighting_unit_idx1 = fighting_unit_idx1 + 1
            fighting_units[1] = nil
        else
            fitness2 = fitness2 + 1
            fighting_unit_idx2 = fighting_unit_idx2 + 1
            fighting_units[2] = nil
        end

        -- Spring.Echo("damages1: " .. damages1 .. ", damages2: " .. damages2)
        -- Spring.Echo("health1: " .. health1 .. ", health2: " .. health2)
    until (fighting_unit_idx1 > #individual1.members or fighting_unit_idx2 > #individual2.members)

    local winner = {}
    if fitness1 > fitness2 then
        winner = individual1
    elseif (fitness1 == fitness2) then
        winner = individual1
    else
        winner = individual2
    end

    return winner
end

local function do_tournament(competitors)
    local tournament_rounds = logarithm(#competitors, 2)

    local match_winners = {}
    for i = 1, tournament_rounds do
        for j = 1, #competitors, 2 do
            local winner = play_match(competitors[j], competitors[j+1])
            table.insert(match_winners, winner)
        end
        competitors = match_winners
    end

    return competitors[1]
end

-------------------------------------------------
-- Funkcja realizuje 1. punkt GA: generuje 0. populacje.
-- no_individuals_per_tournament_ musi być potęgą 2
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
        table.insert(init_population, winner)
    end

    for i = 1, #init_population do
        init_population[i].set_side("FIL" .. i)
    end

    return init_population
end

-------------------------------------------------


-------------------------------------------------
-- see 'units/autogen.lua'
-------------------------------------------------

local squad_defFields = {
    "members",
	"name",
	"description",
	"buildCostMetal",
	"buildPic",
	"buildTime",
	"side",
}

local function format_population_to_squadDefs(squad_name, individual)
    local squadDefs = {}
    local squad_fields = {}

    for i,field in ipairs(squad_defFields) do
        if individual[field] ~= nil then
            squad_fields[field] = individual[field]
        end
    end

    squadDefs[squad_name] = squad_fields

    return squadDefs
end

local function save_squadDefs(squadDefs, side_name, side_idx)
    local filename = side_name .. side_idx
    local filename_lua = filename .. ".lua"
    if (squadDefs ~= nil) then
        Script.LuaUI.SendDataToFile(squadDefs, filename_lua, filename .. "Defs")
        Spring.Echo(filename_lua .." saved!")
    else
        Spring.Echo(filename_lua .." nil!")
    end
end

-------------------------------------------------
-- Zapisz 'winners' jako cztery niezalezne nacje (sides)
-- tj. podmien ich 'configs/side_squad_defs'
-- a pozniej takze buildorder.lua
-------------------------------------------------
local function save_init_popilation_as_squadDefs(init_population)
    -- Spring.Echo("init_population size: " .. #init_population)
    for i = 1, #init_population do
        local squadDefs = format_population_to_squadDefs("fil" .. i .. "_platoon", init_population[i])
        save_squadDefs(squadDefs, "fil", i)
    end
end

------------------------------------------
function gadget:Initialize()
	local name = Game.modName
    name = name .. " -GA squad optimizer starter-"
	Spring.Echo(("Initialize %s"):format(name))
end

function gadget:Update()
    local init_population = generate_init_population(4, 8)

    if ( Script.LuaUI("SendDataToFile") ) then
        if save_done == false then
            save_init_popilation_as_squadDefs(init_population)
            -- save_squadDefs_form_squad_files()
            Spring.SendLuaRulesMsg("save_done")
            save_done = true
        end
    -- else
    --     Spring.Echo("nie ma LuaUI.SendDataToFile !!")
    end
end

function gadget:Shutdown()
    Spring.Echo("zamykam MainGA")
end
------------------------------------------

-- IsSyncedCode()
end