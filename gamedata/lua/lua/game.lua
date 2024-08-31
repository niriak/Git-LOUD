---  File     :  /lua/game.lua
---  Summary  : Script full of overall game functions
---  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.

VeteranDefault = {
    Level1 = 25,
    Level2 = 100,
    Level3 = 400,
    Level4 = 1200,
    Level5 = 4800,
}

SpecialWepRestricted = false
UnitCatRestricted = false

_UnitRestricted_cache = {}
_UnitRestricted_unitchecked = {}
_UnitRestricted_checked = false

doscript('/lua/BuffFieldDefinitions.lua')

BrewLANLOUDPath = function()
    for i, mod in __active_mods do
        if mod.uid == "25D57D85-7D84-27HT-A501-BR3WL4N000079" then
            return mod.location
        end
    end 
end

BrewLANPath = function()
    for i, mod in __active_mods do
        if mod.uid == "25D57D85-7D84-27HT-A501-BR3WL4N000079" then
            return mod.location
        end
    end 
end

--- Return the total time (in seconds), energy, and mass it will take for the given
--- builder to create a unit of type target_bp.
--- targetData may also be an "Enhancement" section of a units blueprint rather than
--- a full blueprint.
---
--- Modified to calculate the cost of an upgrade. The third argument is the economy section of
--- the unit that is currently upgrading into the new unit. We subtract that cost from the cost
--- of the unit that is being built
---
--- In order to keep backwards compatibility, there is a new option in the blueprint economy section.
--- if DifferentialUpgradeCostCalculation is set to true, the base upgrade cost will be subtracted
---@param builder Unit
---@param targetData UnitBlueprintEconomy
---@param upgradeBaseData UnitBlueprintEconomy
---@return number time
---@return number energy
---@return number mass
function GetConstructEconomyModel(builder, targetData, upgradeBaseData)
    -- 'rate' here is how fast we build relative to a unit with build rate of 1
    local rate = builder:GetBuildRate()
    local buildtime = targetData.BuildTime or 0.1
    local mass = targetData.BuildCostMass or 0
    local energy = targetData.BuildCostEnergy or 0

    if upgradeBaseData and targetData.DifferentialUpgradeCostCalculation then
        -- We cant make a differential on buildtime. Not sure why but if we do it yields incorrect
        -- results. So just mass and energy.
        mass = math.max(mass - upgradeBaseData.BuildCostMass, 0)
        energy = math.max(energy - upgradeBaseData.BuildCostEnergy, 0)
    end

    -- Apply penalties/bonuses to effective costs
    local time_mod = builder.BuildTimeModifier or 0
    local energy_mod = builder.EnergyModifier or 0
    local mass_mod = builder.MassModifier or 0

    buildtime = math.max(buildtime * (100 + time_mod) * 0.01, 0.1)
    energy = math.max(energy * (100 + energy_mod) * 0.01, 0)
    mass = math.max(mass * (100 + mass_mod) * 0.01, 0)

    return buildtime / rate, energy, mass
end

function IsRestricted(unitId, army)
    ScenarioInfo = { Options = { RestrictedCategories = SessionGetScenarioInfo().Options.RestrictedCategories }}
    return UnitRestricted(false, unitId)
end

function UnitRestricted(unit, unitId)
    if ScenarioInfo.Options.RestrictedCategories then     -- if restrictions defined
	
		if unit then
			unitId = unit.BlueprintID
		end

		if _UnitRestricted_cache[unitId] then          -- use cache if available

			return true
		end
		
		if not _UnitRestricted_unitchecked[unitId] then

			CacheRestrictedUnitLists()
		
			for k, cat in UnitCatRestricted do
	
				if EntityCategoryContains( cat, unitId ) then   -- because of this function we need the unit, not the unitId

					_UnitRestricted_cache[unitId] = true
			
					break
				end
			end
			
			_UnitRestricted_unitchecked[unitId] = true

			return _UnitRestricted_cache[unitId]
		
		end
	else
	
		return false
		
	end
	
end

function WeaponRestricted(weaponLabel)

    if not CheckUnitRestrictionsEnabled() then     -- if no restrictions defined then dont bother
        return false
    end
	
    CacheRestrictedUnitLists()
	
    return SpecialWepRestricted[weaponLabel]
end


function NukesRestricted()
    return WeaponRestricted('StrategicMissile')
end


function TacticalMissilesRestricted()
    return WeaponRestricted('TacticalMissile')
end


function CheckUnitRestrictionsEnabled()
    -- tells you whether unit restrictions are enabled
    if ScenarioInfo.Options.RestrictedCategories then return true end
    return false
end

-- modified to make use of a global -- _UnitRestricted_checked
-- which avoids continually rebuilding the restricted units list
-- however - anytime a restriction is added or removed during the
-- game, this global must be reset so that the list can be rebuilt
function CacheRestrictedUnitLists()

	if _UnitRestricted_checked then
		return
	end

    if type(UnitCatRestricted) == 'table' then
        return
    end

    SpecialWepRestricted = {}
    UnitCatRestricted = {}
	
    local restrictedUnits = import('/lua/ui/lobby/restrictedUnitsData.lua').restrictedUnits
    local c
	
    if ScenarioInfo.Options.RestrictedCategories[1] then
        LOG("RESTRICTED UNIT START")
    end

    -- loop through enabled restrictions
    for k, restriction in ScenarioInfo.Options.RestrictedCategories do 

        -- create a list of all unit category restrictions. TO be clear, this results in a table of categories
        -- So, for example:   { categories.TECH1, categories.TECH2, categories.MASSFAB }
        if restrictedUnits[restriction].categories then
        
            LOG("     Restricted Units - "..repr(restriction))  --edUnits[restriction].categories) )
		
            for l, cat in restrictedUnits[restriction].categories do
			
                c = cat
				
                if type(c) == 'string' then
					c = ParseEntityCategory(c)
				end
				
                table.insert( UnitCatRestricted, c )
            end
        end

        -- create a list of restricted special weapons (nukes, tactical missiles)
        if restrictedUnits[restriction].specialweapons[1] then
        
            LOG("     Restricted Weapons "..repr(restrictedUnits[restriction].specialweapons) )
        
            for l, cat in restrictedUnits[restriction].specialweapons do

                -- strategic missiles
                if cat == 'StrategicMissile' or cat == 'strategicmissile' or cat == 'sm' or cat == 'SM' then
                    SpecialWepRestricted['StrategicMissile'] = true

                -- tactical missiles
                elseif cat == 'TacticalMissile' or cat == 'tacticalmissile' or cat == 'tm' or cat == 'TM' then
                    SpecialWepRestricted['TacticalMissile'] = true

                -- mod added weapons
                else
                    SpecialWepRestricted[cat] = true
                end
            end
        end
    end
	
    if ScenarioInfo.Options.RestrictedCategories[1] then
        LOG("RESTRICTED UNIT END")
    end
	
	_UnitRestricted_checked = true
end