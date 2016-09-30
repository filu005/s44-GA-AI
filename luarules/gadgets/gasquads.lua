function gadget:GetInfo()
	return {
		name = "GASquads",
		desc = "GA for squad optimization",
		author = "filip",
		date = "2016",
		license = "GNU General Public License",
  		layer = 0,
		enabled = true
	}
end

------------------------------------------
GA = {}

include("LuaRules/Gadgets/GA/GA.lua")

function gadget:GameStart()
    GA = CreateGAMgr()
end

function gadget:TeamDied(teamID)
    Spring.Echo("team " .. teamID .. " died!!!!!!!!")
end

local team_death_time = {}

----------------------------------- synced

if (gadgetHandler:IsSyncedCode()) then

local getGameSeconds = Spring.GetGameSeconds
local getTeamInfo = Spring.GetTeamInfo

function gadget:GameFrame(f)
    for _,teamID in ipairs(Spring.GetTeamList()) do
        if teamID ~= gaiaTeamID then
            local units_no = Spring.GetTeamUnitCount(teamID)
            local _,_,is_dead,_,side,allianceID = getTeamInfo(teamID)

            if units_no <= 0 and team_death_time[side] == nil then
                Spring.Echo(side .. " dead!")
                team_death_time[side] = getGameSeconds()
            end


        end
    end

    
end

--------------------------------- unsynced
else

------------------------------------------


function gadget:Initialize()
    name = "-GA squad optimizer-"
    Spring.Echo(("Initialize %s"):format(name))
end

------------------------------------------
local getTeamInfo = Spring.GetTeamInfo
local getGameSeconds = Spring.GetGameSeconds
local gaiaTeamID = Spring.GetGaiaTeamID()

------------------------------------------
-- from game_end.lua
------------------------------------------

function gadget:Update()
    for _,teamID in ipairs(Spring.GetTeamList()) do
        if teamID ~= gaiaTeamID then
            local _,_,is_dead,_,side,allianceID = getTeamInfo(teamID)

            if is_dead and team_death_time[side] == nil then
                Spring.Echo(side .. " dead!")
                team_death_time[side] = getGameSeconds()
            end


        end
    end
end
------------------------------------------


function gadget:Shutdown()
    local team_time = {}

    GA.run()
    
    local gaiaTeamID = Spring.GetGaiaTeamID()
    for i,teamID in ipairs(Spring.GetTeamList()) do
        if teamID ~= gaiaTeamID then

            -- https://springrts.com/wiki/Lua_SyncedRead#Player.2CTeam.2CAlly_Lists.2FInfo
            local max = Spring.GetTeamStatsHistory(teamID)
            local stats = Spring.GetTeamStatsHistory(teamID, 0, max)

            team_time[teamID] = stats[max].time

            if stats[max].unitsProduced <= stats[max].unitsDied then
                Spring.Echo("stats of dead: " .. (stats[max].unitsProduced - stats[max].unitsDied))                
            end

            Spring.Echo("team " .. teamID .. " damage: " .. team_time[teamID])
        end
    end

    Spring.Echo("team_death_time len: " .. #team_death_time)

    for side,death_time in pairs(team_death_time) do
        Spring.Echo("death of " .. side .. " in: " .. death_time)
    end
    
end
------------------------------------------

-- IsSyncedCode() else
end