-- creates a checkbox that sequentially upgrades mass extractors and energy buildings

local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Tooltip = import('/lua/ui/game/tooltip.lua')
local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Announcement = import('/lua/ui/game/announcement.lua')

-- Global variables
isAutoSelection = false      -- set to true while modifying user selection to issue upgrade command
isAutoUpgradeEnabled = false -- set to true when auto upgrade is enabled
isUpgradeHalted = false      -- set to true when upgrade is halted due to insufficient energy
noUpgradableBuildings = true -- set to true when there are no upgradable buildings
upgradeCheckbox = nil        -- reference to the checkbox
upgradeThread = nil          -- reference to the upgrade thread

-- Textures for different states
local greenNormalTexture = UIUtil.UIFile('/game/resources/mass_btn_up.dds')
local greenDownTexture = UIUtil.UIFile('/game/resources/mass_btn_down.dds')
local greenOverTexture = UIUtil.UIFile('/game/resources/mass_btn_over.dds')
local redNormalTexture = UIUtil.UIFile('/game/resources/energy_btn_up.dds')
local redDownTexture = UIUtil.UIFile('/game/resources/energy_btn_down.dds')
local redOverTexture = UIUtil.UIFile('/game/resources/energy_btn_over.dds')
local greyNormalTexture = UIUtil.UIFile('/game/resources/mass_btn_dis.dds')
local greyDownTexture = UIUtil.UIFile('/game/resources/mass_btn_dis.dds')
local greyOverTexture = UIUtil.UIFile('/game/resources/mass_btn_dis.dds')

function CreateButton(parent)
   -- create the checkbox
   upgradeCheckbox = Checkbox(parent, greenNormalTexture, greenDownTexture, greenOverTexture, greenDownTexture, greyNormalTexture, greyDownTexture)
   LayoutHelpers.AtLeftTopIn(upgradeCheckbox, parent, 340)
   upgradeCheckbox.Depth:Set(4)
   Tooltip.AddCheckboxTooltip(upgradeCheckbox, 'seq_mex_upgrade_toggle')

   -- Set initial state to grey (no buildings to upgrade)
   SetCheckboxState('grey')

   -- Start a thread to check for upgradable buildings
   ForkThread(CheckForUpgradableBuildings)

   -- oncheck handler
   upgradeCheckbox.OnCheck = function(self, checked)
      isAutoUpgradeEnabled = checked

      if checked then
         -- Start the auto upgrade process
         if upgradeThread then
            KillThread(upgradeThread)
         end
         upgradeThread = ForkThread(AutoUpgradeBuildings)
      else
         -- Stop the auto upgrade process
         if upgradeThread then
            KillThread(upgradeThread)
            upgradeThread = nil
         end
      end
   end
end

-- Function to check for upgradable buildings periodically
function CheckForUpgradableBuildings()
   while true do
      local myUnits = import('/lua/ui/game/gamemain.lua').GetSeqUpgradeList()
      local hasUpgradableBuildings = not table.empty(myUnits)

      if hasUpgradableBuildings ~= (not noUpgradableBuildings) then
         noUpgradableBuildings = not hasUpgradableBuildings

         if noUpgradableBuildings then
            -- No buildings to upgrade, set to grey
            SetCheckboxState('grey')
         elseif isUpgradeHalted then
            -- Upgrade halted, set to red
            SetCheckboxState('red')
         else
            -- Buildings to upgrade, set to green
            SetCheckboxState('green')
         end
      end

      WaitSeconds(1)
   end
end

-- Function to set the checkbox state (color)
function SetCheckboxState(state)
   if not upgradeCheckbox then return end

   if state == 'green' then
      upgradeCheckbox:SetNewTextures(greenNormalTexture, greenDownTexture, greenOverTexture, greenDownTexture, greenNormalTexture, greenDownTexture)
   elseif state == 'red' then
      upgradeCheckbox:SetNewTextures(redNormalTexture, redDownTexture, redOverTexture, redDownTexture, redNormalTexture, redDownTexture)
   elseif state == 'grey' then
      upgradeCheckbox:SetNewTextures(greyNormalTexture, greyDownTexture, greyOverTexture, greyDownTexture, greyNormalTexture, greyDownTexture)
   end
end

-- Function to automatically upgrade buildings
function AutoUpgradeBuildings()
   while isAutoUpgradeEnabled do
      local myUnits = import('/lua/ui/game/gamemain.lua').GetSeqUpgradeList()

      if not table.empty(myUnits) then
         -- Reset halted state
         if isUpgradeHalted then
            isUpgradeHalted = false
            SetCheckboxState('green')
         end

         -- Upgrade buildings
         UpgradeBuildings(myUnits)
      end

      WaitSeconds(1)
   end
end

local commandmode = import('/lua/ui/game/commandmode.lua')

-- Function to check if there's enough energy to support a mass extractor upgrade
function HasEnoughEnergyForUpgrade(unit)
   -- Get the current energy income and storage
   local econData = GetEconomyTotals()
   local simFrequency = GetSimTicksPerSecond()
   local currentEnergyIncome = econData.income['ENERGY'] * simFrequency
   local currentEnergyUsage = econData.lastUseActual['ENERGY'] * simFrequency
   local availableEnergyIncome = currentEnergyIncome - currentEnergyUsage

   -- Check if the unit is a mass extractor
   local bp = unit:GetBlueprint()
   if bp.Economy and bp.Economy.ProductionType == 'MASS' then
      -- Get the upgrade blueprint
      local upgradeBp = __blueprints[bp.General.UpgradesTo]

      -- If it's a mass extractor upgrade, check energy requirements
      if upgradeBp and upgradeBp.Economy and upgradeBp.Economy.MaintenanceConsumptionPerSecondEnergy then
         local currentEnergyUsage = 0
         if bp.Economy.MaintenanceConsumptionPerSecondEnergy then
            currentEnergyUsage = bp.Economy.MaintenanceConsumptionPerSecondEnergy
         end

         local upgradeEnergyUsage = upgradeBp.Economy.MaintenanceConsumptionPerSecondEnergy
         local additionalEnergyNeeded = upgradeEnergyUsage - currentEnergyUsage

         -- Check if we have enough energy income to support the upgrade
         if additionalEnergyNeeded > availableEnergyIncome then
            return false
         end
      end
   end

   return true
end

function UpgradeBuildings(units)
   for index, unit in ipairs(units) do
      if not unit:IsDead() then
         -- Check if there's enough energy for the upgrade (for mass extractors)
         if not HasEnoughEnergyForUpgrade(unit) then
            -- Not enough energy, halt the upgrade process
            if isAutoUpgradeEnabled and not isUpgradeHalted then
               isUpgradeHalted = true
               SetCheckboxState('red')

               -- Notify the player
               Announcement.CreateAnnouncement(
                  'Upgrade Process Halted: Not enough energy available to power the upgraded mass extractor. Upgrade process halted until more energy is available.',
                  upgradeCheckbox
               )
            end

            -- Skip this unit and continue with the next one
            continue
         elseif isAutoUpgradeEnabled and isUpgradeHalted then
            -- We have enough energy now, resume the upgrade process
            isUpgradeHalted = false
            SetCheckboxState('green')

            -- Notify the player
            Announcement.CreateAnnouncement(
               'Upgrade Process Resumed: Enough energy is now available. Upgrade process resumed.',
               upgradeCheckbox
            )
         end

         -- save current selection
         local selection = GetSelectedUnits()

         local currentCommand = commandmode.GetCommandMode()
         isAutoSelection = true

         -- select unit and issue upgrade command
         SelectUnits( {unit} )
         IssueBlueprintCommand("UNITCOMMAND_Upgrade", unit:GetBlueprint().General.UpgradesTo, 1, false)
         -- lua IssueUpgrade({unit}, unit:GetBlueprint().General.UpgradesTo)

         -- restore previous selection
         SelectUnits(selection)

         commandmode.StartCommandMode(currentCommand[1], currentCommand[2])
         isAutoSelection = false

         -- loop until unit is upgraded or dead (both are conveniently checked by IsDead())
         while not unit:IsDead() do
            -- return if upgrade was stopped
            if unit:IsIdle() then
               return
            end
            WaitSeconds(1)
         end
      end
   end
end 
