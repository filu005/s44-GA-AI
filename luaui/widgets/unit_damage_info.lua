--[[
Game.armorTypes =
{
	[1] = "armouredvehicles",
	[2] = "bunkers",
	[3] = "guns",
	[4] = "hardplanes",
	[5] = "heavyplanes",
	[6] = "heavytanks",
	[7] = "infantry",
	[8] = "lightbuildings",
	[9] = "lighttanks",
	[10] = "mediumtanks",
	[11] = "mines",
	[12] = "planes",
	[13] = "sandbags",
	[14] = "ships",
	[15] = "shipturrets",
	[16] = "squadspawners",
	[17] = "unarmouredvehicles"
}
]]
function widget:GetInfo()
    return {
        name      = "UnitDamageInfo",
        version   = "1.0",
        desc      = "prints damage of unit vs unit",
        author    = "Pope Brian IX",
        date      = "2000 BC",
        license   = "Je suis une pamplemousse",
        layer     = 0,
        enabled   = false
   }
end


function widget:Initialize()
	local t_out = {}

    for unitDefID, unitDef in pairs(UnitDefs) do
        local weapons = unitDef.weapons
        Spring.Echo("unit " .. unitDef.name .. " with unitDefID " .. unitDefID .. " has:")

        Spring.Echo(" armorType " .. unitDef.armorType .. " (which is armorClass " .. Game.armorTypes[unitDef.armorType] .. ")")

        local modCats = ""
        for k,_ in pairs(unitDef.modCategories) do
            modCats = modCats .. " " .. k
        end
        Spring.Echo(" modCategories: " .. modCats)

		local t_weapons = {}
        for i,weaponInfo in ipairs(weapons) do
            local weaponDefID = weaponInfo.weaponDef


            Spring.Echo(" weapon " .. i .. " with weaponDefID " .. weaponDefID)

            local badTargets = ""
            for modCat,_ in pairs(weaponInfo.badTargets) do
                badTargets = badTargets .. " " .. modCat
            end
            Spring.Echo("  with bad target categories: " .. badTargets)

            local onlyTargets = ""
            for modCat,_ in pairs(weaponInfo.onlyTargets) do
                onlyTargets = onlyTargets .. " " .. modCat
            end
            Spring.Echo("  with only target categories: " .. onlyTargets)

            Spring.Echo("  with damages:")
            local t_damages = PrintWeaponDamages(weaponDefID) -- not nil!

			t_weapons["weapons"] = t_damages--WeaponDefs[weaponDefID].name
			t_weapons["armorType"] = Game.armorTypes[unitDef.armorType]
        end

		t_out[unitDef.name] = t_weapons
    end
	table.save(t_out, "games\\s44-v2.0_0.sdd\\luaui\\t_out.lua", "-- generated by table.save")
end

function PrintWeaponDamages(weaponDefID)
    local weaponDef = WeaponDefs[weaponDefID]
    local damages = weaponDef.damages
	local t_damages = {}
    for armorType,damage in pairs(damages) do
        if type(damage)=="number" then -- this table also contains other damage related info e.g. craterboost, but all number keys match armour defs
            Spring.Echo("   " .. damage .. " damage to armorType " .. armorType)
			table.insert(t_damages, string.format("%d damage to armorType: %s", damage, armorType))
			-- t_damages[weaponDef.name] = string.format("%d damage to armorType: %s", damage, armorType)
        end
    end
	return t_damages
end