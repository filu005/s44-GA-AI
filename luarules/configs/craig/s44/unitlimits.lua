-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

-- Do not limit units spawned through LUA! (infantry that is build in platoons,
-- deployed supply trucks, deployed guns, etc.)

-- On easy, limit both engineers and buildings until I've made an economy
-- manager that can tell the AI whether it has sufficient income to build
-- (and sustain) a particular building (factory).
-- (AI doesn't use resource cheat in easy)

-- On medium, limit engineers (much) more then on hard.

-- On hard, losen restrictions a bit more.

-- Format: unitname = { easy limit, medium limit, hard limit }
local unitLimits = UnitBag{
	-- engineers
	filhqengineer        = { 2, 2, 4 },
	gbrhqengineer        = { 2, 2, 4 },
	gbrmatadorengvehicle = 1,
	gerhqengineer        = { 2, 2, 4 },
	gersdkfz9            = 1,
	ruscommissar         = { 4, 4, 5 }, --2 for flag capping + 2-3 for base building
	rusengineer          = { 1, 2, 2 },
	rusk31               = 1,
	ushqengineer         = { 2, 2, 4 },
	usgmcengvehicle      = 1,
	jpnhqengineer		= { 2, 2, 4 },
	jpnriki		      = 1,
	itahqengineer         = { 2, 2, 4 },
	itabreda41	      = 1,
	-- buildings
	filbarracks    = { 3, 3, 4 },
	gbrbarracks    = { 3, 3, 4 },
	gerbarracks    = { 3, 3, 4 },
	rusbarracks    = { 3, 3, 4 },
	usbarracks     = { 3, 3, 4 },
	jpnbarracks     = { 3, 3, 4 },
	itabarracks     = { 3, 3, 3 },
	gbrstorage     = 10,
	gerstorage     = 10,
	russtorage     = 10,
	usstorage      = 10,
	jpnstorage      = 10,
	itastorage      = 10,
	gbrsupplydepot = { 1, 1, 2 },
	gersupplydepot = { 1, 1, 2 },
	russupplydepot = { 1, 1, 2 },
	ussupplydepot  = { 1, 1, 2 },
	jpnsupplydepot  = { 1, 1, 2 },
	itasupplydepot  = { 1, 1, 2 },
	gbrtankyard    = { 1, 2, 4 },
	gertankyard    = { 1, 2, 4 },
	rustankyard    = { 1, 2, 4 },
	ustankyard     = { 1, 2, 4 },
	jpntankyard     = { 1, 2, 4 },
	itatankyard     = { 1, 2, 3 },
	gbrvehicleyard = { 1, 1, 2 },
	gervehicleyard = { 1, 1, 2 },
	rusvehicleyard = { 1, 1, 2 },
	usvehicleyard  = { 1, 1, 2 },
	jpnvehicleyard  = { 1, 1, 2 },
	itavehicleyard  = { 1, 1, 2 },
	itatankyard1     = { 0, 1, 2 },
	itaspyard     = { 0, 1, 1 },
	itaelitebarracks     = { 0, 1, 2 },
}

-- Convert to format expected by C.R.A.I.G., based on the difficulty.
local difficultyTable = { easy = 1, medium = 2, hard = 3 }
local difficultyIndex = difficultyTable[gadget.difficulty] or 3
gadget.unitLimits = {}
for k,v in pairs(unitLimits) do
	if (type(v) == "table") then
		gadget.unitLimits[k] = v[difficultyIndex]
	else
		gadget.unitLimits[k] = v
	end
end
