
local UIUtil = import("/lua/ui/uiutil.lua")
local LayoutHelpers = import("/lua/maui/layouthelpers.lua")
local Group = import("/lua/maui/group.lua").Group
local Bitmap = import("/lua/maui/bitmap.lua").Bitmap
local Button = import("/lua/maui/button.lua").Button
local StatusBar = import("/lua/maui/statusbar.lua").StatusBar
local parent = import("/lua/ui/game/economy.lua").savedParent

local style = {
    mass = {
        textColor = 'ffb7e75f',
        barTexture = '/game/resource-bars/mini-mass-bar_bmp.dds',
        iconTexture = '/game/resources/mass_btn_up.dds',
        warningcolor = '8800ff00',
    },
    energy = {
        textColor = 'fff7c70f',
        barTexture = '/game/resource-bars/mini-energy-bar_bmp.dds',
        iconTexture = '/game/resources/energy_btn_up.dds',
        warningcolor = '88ff9000',
    },
}

function SetLayout()
    local GUI = import("/lua/ui/game/economy.lua").GUI
    local parent = import("/lua/ui/game/economy.lua").savedParent

    GUI.bg.panel:SetTexture(UIUtil.UIFile('/game/resource-panel/resources_panel_bmp.dds'))
LayoutHelpers.AtLeftTopIn(GUI.bg.panel, GUI.bg)
--    LayoutHelpers.FillParent(GUI.bg.panel, GUI.bg)

GUI.bg.Height:Set(GUI.bg.panel.Height)
GUI.bg.Width:Set(GUI.bg.panel.Width)
LayoutHelpers.AtLeftTopIn(GUI.bg, parent, 16, 3)
    GUI.bg:DisableHitTest()

    LayoutResourceGroup(GUI.mass, 'mass')
    LayoutResourceGroup(GUI.energy, 'energy')

    LayoutHelpers.AtLeftTopIn(GUI.mass, GUI.bg, 14, 9)
    LayoutHelpers.AtRightIn(GUI.mass, GUI.bg, 20)
    LayoutHelpers.Below(GUI.energy, GUI.mass, 4)
    GUI.energy.Right:Set(GUI.mass.Right)
end

function LayoutResourceGroup(group, groupType)
    group.icon:SetTexture(UIUtil.UIFile(style[groupType].iconTexture))
    if groupType == 'mass' then
        LayoutHelpers.SetWidth(group.icon, 44)
        LayoutHelpers.AtLeftIn(group.icon, group, -14)
    elseif groupType == 'energy' then
        LayoutHelpers.SetWidth(group.icon, 36)
        LayoutHelpers.AtLeftIn(group.icon, group, -10)
    end
    LayoutHelpers.SetHeight(group.icon, 36)
    LayoutHelpers.AtVerticalCenterIn(group.icon, group)

    LayoutHelpers.AtCenterIn(group.warningBG, group, 0, -2)
--    LayoutHelpers.FillParent(group.warningBG, group, 50, -2)

LayoutHelpers.SetDimensions(group.storageBar, 100, 10)
--    LayoutHelpers.SetHeight(group.storageBar, 10)
--    LayoutHelpers.AtRightIn(group.storageBar, group, 180)
    group.storageBar._bar:SetTexture(UIUtil.UIFile(style[groupType].barTexture))
    LayoutHelpers.AtLeftTopIn(group.storageBar, group, 22, 2)

    LayoutHelpers.Below(group.curStorage, group.storageBar)
    LayoutHelpers.AtLeftIn(group.curStorage, group.storageBar)
    group.curStorage:SetColor(style[groupType].textColor)

    LayoutHelpers.Below(group.maxStorage, group.storageBar)
    LayoutHelpers.AtRightIn(group.maxStorage, group.storageBar)
    LayoutHelpers.ResetLeft(group.maxStorage)
    group.maxStorage:SetColor(style[groupType].textColor)

    group.storageTooltipGroup.Left:Set(group.storageBar.Left)
    group.storageTooltipGroup.Right:Set(group.storageBar.Right)
    group.storageTooltipGroup.Top:Set(group.storageBar.Top)
    group.storageTooltipGroup.Bottom:Set(group.maxStorage.Bottom)

LayoutHelpers.RightOf(group.rate, group.storageBar, 4)
--    LayoutHelpers.AtRightIn(group.rate, group, 100)
    LayoutHelpers.AtVerticalCenterIn(group.rate, group)

    LayoutHelpers.AtRightIn(group.income, group, 2)
    LayoutHelpers.AtTopIn(group.income, group)
    group.income:SetColor('ffb7e75f')

    LayoutHelpers.AtRightIn(group.expense, group, 2)
    LayoutHelpers.AtBottomIn(group.expense, group)
    LayoutHelpers.ResetTop(group.expense)
    group.expense:SetColor('fff30017')

    -- Reclaim info
    LayoutHelpers.AtRightIn(group.reclaimDelta, group, 49)
    LayoutHelpers.AtTopIn(group.reclaimDelta, group)
    group.reclaimDelta:SetColor('ffb7e75f')

    LayoutHelpers.AtRightIn(group.reclaimTotal, group, 49)
    LayoutHelpers.AtBottomIn(group.reclaimTotal, group)
    LayoutHelpers.ResetTop(group.reclaimTotal)

    if groupType == 'mass' then
        group.reclaimTotal:SetColor('FFB8F400')
    else
        group.reclaimTotal:SetColor('FFF8C000')
    end

    LayoutHelpers.SetDimensions(group, 296, 25)
end

function InitAnimation()
    local GUI = import("/lua/ui/game/economy.lua").GUI
    local savedParent = import("/lua/ui/game/economy.lua").savedParent
    GUI.bg:Show()
--    GUI.bg:InitAnimation()
    GUI.bg.Left:Set(savedParent.Left()+14)
end
