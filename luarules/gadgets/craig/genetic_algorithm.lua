--
-- A simple genetic algorithm for function optimization, in lua
-- Copyright (c) 2009 Jason Brownlee
--
-- It uses a binary string representation, tournament selection,
-- one-point crossover, and point mutations. The test problem is
-- called one max (a string of all ones)
--

function CreateGAMgr()

-- Can not start GA if we don't have waypoints..
if (not gadget.waypointMgr) then
	Spring.Echo("no waypointMgr")
	return false
end

local GAMgr = {}

-- configuration
local problemSize = 64
local mutationRate = 0.005
local crossoverRate = 0.98
local populationSize = 32
local maxGenerations = 20
local selectionTournamentSize = 3
local seed = Spring.GetGameSeconds()

-- speedups
local waypointMgr = gadget.waypointMgr

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  The call-in routines
--

local function printf(...)
	Spring.Echo(string.format(...))

end

local function crossover(a, b)
	if math.random() > crossoverRate then
		return ""..a
	end
	local cut = math.random(a:len()-1)
	local s = ""
	for i=1, cut do
		s = s..a:sub(i,i)
	end
	for i=cut+1, b:len() do
		s = s..b:sub(i,i)
	end
	return s
end

local function mutation(bitstring)
	local s = ""
	for i=1, bitstring:len() do
		local c = bitstring:sub(i,i)
		if math.random() < mutationRate then
			if c == "0"
			then s = s.."1"
			else s = s.."0" end
		else s = s..c end
	end
	return s
end

local function selection(population, fitnesses)
	local pop = {}
	repeat
		local bestString = nil
		local bestFitness = 0
		for i=1, selectionTournamentSize do
			local selection = math.random(#fitnesses)
			if fitnesses[selection] > bestFitness then
				bestFitness = fitnesses[selection]
				bestString = population[selection]
			end
		end
		table.insert(pop, bestString)
	until #pop == #population
	return pop
end

local function reproduce(selected)
	local pop = {}
	for i, p1 in ipairs(selected) do
		local p2 = nil
		if (i%2)==0 then p2=selected[i-1] else p2=selected[i+1] end
		local child = crossover(p1, p2)
		local mutantChild = mutation(child)
		table.insert(pop, mutantChild);
	end
	return pop
end

local function fitness(bitstring)
	local cost = 0
	for i=1, bitstring:len() do
		local c = bitstring:sub(i,i)
		if(c == "1") then cost = cost + 1 end
	end
	return cost
end

local function random_bitstring(length)
	local s = ""
	while s:len() < length do
		if math.random() < 0.5 then
			s = s.."0"
		else
			s = s.."1"
		end
	end
	return s
end

local function getBest(currentBest, population, fitnesses)
	local bestScore = currentBest==nil and 0 or fitness(currentBest)
	local best = currentBest
	for i,f in ipairs(fitnesses) do
		if(f > bestScore) then
			bestScore = f
			best = population[i]
		end
	end
	return best
end

local function evolve()
	local population = {}
	local bestString = nil
	-- initialize the popuation random pool
	for i=1, populationSize do
		table.insert(population, random_bitstring(problemSize))
	end

	-- local fname = "input_population.log"
	-- local f,err = io.open(fname, "w+")
	-- if (not f) then
	-- 	Spring.Echo(err)
	-- end
	-- for k, v in pairs( population ) do
	-- 	f:write("[" .. k .. "]: " .. v .. "; " fitness(v))
	-- 	-- printf("%d, %s, %d\n", k, v, fitness(v))
	-- end
	-- f:close()
	-- Spring.Echo("Saved to: " .. fname)
	-- optimize the population (fixed duration)
	for i=1, maxGenerations do
		-- evaluate
		local fitnesses = {}
		for i,v in ipairs(population) do
			table.insert(fitnesses, fitness(v))
		end
		-- update best
		bestString = getBest(bestString, population, fitnesses)
		-- select
		local tmpPop = selection(population, fitnesses)
		-- reproduce
		population = reproduce(tmpPop)
		printf(">gen %d, best cost=%d [%s]\n", i, fitness(bestString), bestString)
	end
	return bestString
end


--------------------------------------------------------------------------------
--
--  Initialization
--

function GAMgr.run()
		Spring.Echo("starting GA...")
		-- local waypoints = waypointMgr.GetWaypoints()
		Spring.Echo("Genetic Algorithm on OneMax, with xx\n");
		math.randomseed(seed)
		local best = evolve()
		Spring.Echo(string.format("Finished!\nBest solution found had the fitness of %d [%s].\n", fitness(best), best))
		local sidedata = Spring.GetSideData()
		for _,s in ipairs(sidedata) do
			Spring.Echo(s.startUnit)
		end
end

return GAMgr
end

--UNSYNCED
