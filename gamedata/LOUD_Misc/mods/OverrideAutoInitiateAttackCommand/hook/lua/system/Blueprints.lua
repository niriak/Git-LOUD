do
    local OldModBlueprints = ModBlueprints

    function ModBlueprints(all_blueprints)
        OldModBlueprints(all_blueprints)

        for _, mod in __active_mods do
            if mod.uid == "6f735b66-cc0e-49d3-b449-88df73bd6ca1" then
                local units = all_blueprints.Unit
                LOG("*OAIAC mod.config=" .. repr(mod.config))
                for key, value in mod.config do
                    LOG("*OAIAC config.item{key=" .. key .. ", config.value=" .. tostring(value) .. "}")
                    if value ~= "default" then
                        SetAutoInitiateAttackCommand(units, key, value == 'on')
                    end
                end
            end
        end
    end

    function SetAutoInitiateAttackCommand(units, key, value)
        local unit = units[key]
        if unit then
            for i, weapon in unit.Weapon do
                LOG("*OAIAC Set auto-initiate-attack-command to " .. tostring(value) .. " for unit " .. key .. " and weapon " .. weapon.Label)
                weapon.AutoInitiateAttackCommand = value
            end
        else
            LOG("*OAIAC Skipping unknown unit " .. key)
        end
    end
end
