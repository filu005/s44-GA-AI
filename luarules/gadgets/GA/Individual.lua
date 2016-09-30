-- individual
-- Closure approach

-- genom osobnika reprezentuje jeden squad
function Individual()
	-- public variables defined in 'self'
	local self =
	{
		-- lista numerow oznaczajacych konkretne jednostki
		-- (np. z UnitDefs albo stworze wlasna tablice z jednostkami FILx)
		members = {},
		name = "",
		description = "",
		buildCostMetal = 0,
		buildPic = "FILRifle.png",
		buildTime = 0,
		side = "FIL",
		no_members = 0
	}

	-- private variables
	local build_cost = 0

	-- public methods
	function self.fitness()
		return nil
	end

	function self.set_side(side_)
		self.side = side_
	end

	function self.compute_build_cost()
		local time_cost, metal_cost = 0, 0
		for i=1, #self.members do
			time_cost = time_cost + UnitDefNames[self.members[i]].buildTime
			metal_cost = metal_cost + UnitDefNames[self.members[i]].metalCost
		end
		self.buildTime = time_cost
		self.buildCostMetal = metal_cost
	end

	-- private methods
	local function generate_random_members()
		return nil
	end

	-- return the instance
	return self
end
