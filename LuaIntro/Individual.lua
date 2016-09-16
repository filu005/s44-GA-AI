-- individual
-- Closure approach
module("individual", package.seeall)


-- genom osobnika reprezentuje jeden squad
function Individual()
	-- public variables defined in 'self'
	local self =
	{
		-- lista numerow oznaczajacych konkretne jednostki
		-- (np. z UnitDefs albo stworze wlasna tablice z jednostkami FILx)
		members = {},
		no_members = 0
	}

	-- private variables
	local build_cost = 0

	-- public methods
	function self.fitness()
		return nil
	end

	-- private methods
	local function compute_build_cost()
		return nil
	end

	local function generate_random_members()
		return nil
	end

	-- return the instance
	return self
end
