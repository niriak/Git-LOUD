local units = {
    { faction="Cybran", id = "brl0401", name = "Basilisk" },
    { faction="Cybran", id = "brmt3ava", name = "Avalanche Mk.2" },
    { faction="Seraphim", id = "brpexshbm", name = "Thaez-Atha" },
    { faction="Seraphim", id = "ssl0405", name = "Suedath-Zmara" },
}

config = {}
for i,unit in units do
    item = {
        default = 1,
        label = "[" .. unit.faction .. "] " .. unit.name,
        key = unit.id,
        values = {
            {
                text = 'Default',
                key = 'default',
            },
            {
                text = 'Enabled',
                key = 'on',
            },
            {
                text = 'Disabled',
                key = 'off',
            }
        }
    }
    config[i] = item
end
