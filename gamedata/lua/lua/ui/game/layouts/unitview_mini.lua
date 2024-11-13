local UIUtil = import('/lua/ui/uiutil.lua')
local SkinnableFile = UIUtil.SkinnableFile
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local options = import("/lua/user/prefs.lua").GetFromCurrentProfile('options')
local NinePatch = import("/lua/ui/controls/ninepatch.lua").InitStd
local controls = import('/lua/ui/game/unitview.lua').controls
local consControl = import('/lua/ui/game/construction.lua').controls.constructionGroup
local ordersControls = import('/lua/ui/game/orders.lua').controls
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Border = import('/lua/maui/border.lua').Border

local iconOrder = {
    1, -- combined stats showing mass trend for own units or army icon + nickname for others' units
    2, -- energy trend
--  3, -- unused
--  4, -- kill count
--  6, -- shield % HP
--  7, -- fuel remaining time
    8, -- buildrate
    5, -- tactical/strategic missile count
}

local iconPositions = {
    [1] = {Left =   4, Top =  4},
    [2] = {Left =  64, Top =  4},
    [3] = {Left = 124, Top =  4},

    [4] = {Left =   4, Top = 24},
    [5] = {Left =  64, Top = 24},
    [6] = {Left = 124, Top = 24},

    [7] = {Left =   4, Top = 44},
    [8] = {Left =  64, Top = 44},
    [9] = {Left = 124, Top = 44},
}

local iconTextures = {
    UIUtil.UIFile('/game/unit_view_icons/mass.dds'),
    UIUtil.UIFile('/game/unit_view_icons/energy.dds'),
    UIUtil.UIFile('/game/unit_view_icons/kills.dds'),
    UIUtil.UIFile('/game/unit_view_icons/kills.dds'),
    UIUtil.UIFile('/game/unit_view_icons/missiles.dds'),
    UIUtil.UIFile('/game/unit_view_icons/shield.dds'),
    UIUtil.UIFile('/game/unit_view_icons/fuel.dds'),
    UIUtil.UIFile('/game/unit_view_icons/build.dds'),
}

function UnsetLayout()
    LOG("unitview_mini.UnsetLayout()")

    if controls.stats then
        controls.stats:Hide()
        controls.stats:Destroy()
        controls.stats = false
    end

    controls.shieldBar:Hide()
    if controls.shieldText then
        controls.shieldText:Hide()
    end
    controls.fuelBar:Hide()
end

function SetLayout()
    LOG("unitview_mini.SetLayout()")

    -- Name
    LayoutHelpers.AtLeftTopIn(controls.name, controls.bg, 18, 10)
    LayoutHelpers.AtRightIn(controls.name, controls.bg, 22)
    controls.name:SetClipToWidth(true)
    controls.name:SetDropShadow(true)

    -- Icon
    LayoutHelpers.Reset(controls.icon)
    LayoutHelpers.AtLeftTopIn(controls.icon, controls.bg, 12, 34)
    controls.icon.Left:Set(controls.name.Left)
    LayoutHelpers.SetDimensions(controls.icon, 64, 64)
    LayoutHelpers.AtLeftTopIn(controls.stratIcon, controls.icon)

    -- Veterancy icons
    LayoutHelpers.Below(controls.vetIcons[1], controls.icon, 5)
    LayoutHelpers.AtLeftIn(controls.vetIcons[1], controls.icon)
    for index = 2, 5 do
        local i = index
        LayoutHelpers.RightOf(controls.vetIcons[i], controls.vetIcons[i-1], -1)
    end

    -- Stats
    if controls.stats then controls.stats:Destroy() end
    controls.stats = Bitmap(controls.bg)
    LayoutHelpers.AnchorToTop(controls.stats, controls.vetBar, 1)
    controls.stats.Left:Set(controls.healthBar.Left)
    controls.stats.Width:Set(controls.healthBar.Width)
    controls.stats:SetSolidColor('33000000')

    for index = 1, table.getn(controls.statGroups) do
        local i = index
        LayoutHelpers.DepthOverParent(controls.statGroups[i].icon, controls.stats)
        controls.statGroups[i].icon.Left:Set(0)
        controls.statGroups[i].icon.Top:Set(0)
        controls.statGroups[i].icon:SetTexture(iconTextures[i])
        controls.statGroups[i].value.Left:Set(0)
        controls.statGroups[i].value.Top:Set(0)
        controls.statGroups[i].value.Depth:Set(controls.statGroups[i].icon.Depth)
    end

    -- Health
    LayoutHelpers.RightOf(controls.healthBar, controls.icon, 30)
    LayoutHelpers.AnchorToLeft(controls.healthBar, controls.actionIcon, 6)
    LayoutHelpers.ResetWidth(controls.healthBar)
    LayoutHelpers.SetHeight(controls.healthBar, 16)
    controls.healthBar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_bg.dds'))
    controls.healthBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_green.dds'))

    if controls.healthIconBG then controls.healthIconBG:Destroy() end
    controls.healthIconBG = Bitmap(controls.bg, UIUtil.UIFile('/game/panel/panel_brd_m.dds'))
    LayoutHelpers.LeftOf(controls.healthIconBG, controls.healthBar)
    controls.healthIconBG.Width:Set(controls.healthBar.Height)
    controls.healthIconBG.Height:Set(controls.healthBar.Height)

    if controls.healthIcon then controls.healthIcon:Destroy() end
    controls.healthIcon = Bitmap(controls.healthIconBG, UIUtil.UIFile('/game/build-ui/icon-health_bmp.dds'))
    LayoutHelpers.AtCenterIn(controls.healthIcon, controls.healthIconBG)
    LayoutHelpers.SetDimensions(controls.healthIcon, 14, 14)
    LayoutHelpers.DepthOverParent(controls.healthIcon, controls.healthIconBG)

    LayoutHelpers.AtCenterIn(controls.health, controls.healthBar)
    controls.health:SetDropShadow(true)

    -- Shield
    LayoutHelpers.Reset(controls.shieldBar)
    LayoutHelpers.Below(controls.shieldBar, controls.healthBar, 1)
    controls.shieldBar.Left:Set(controls.healthBar.Left)
    controls.shieldBar.Width:Set(controls.healthBar.Width)
    controls.shieldBar.Height:Set(controls.healthBar.Height)
    controls.shieldBar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_bg.dds'))
    controls.shieldBar:SetBorder(1)
    controls.shieldBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/shieldbar.dds'))
    controls.shieldBar:Hide()

    if controls.shieldIconBG then controls.shieldIconBG:Destroy() end
    controls.shieldIconBG = Bitmap(controls.bg, UIUtil.UIFile('/game/panel/panel_brd_m.dds'))
    LayoutHelpers.LeftOf(controls.shieldIconBG, controls.shieldBar)
    controls.shieldIconBG.Width:Set(controls.shieldBar.Height)
    controls.shieldIconBG.Height:Set(controls.shieldBar.Height)

    controls.shieldIcon = controls.statGroups[6].icon
    LayoutHelpers.Reset(controls.shieldIcon)
    LayoutHelpers.AtCenterIn(controls.shieldIcon, controls.shieldIconBG)
    LayoutHelpers.SetDimensions(controls.shieldIcon, 14, 14)
    LayoutHelpers.DepthOverParent(controls.shieldIcon, controls.shieldIconBG)

    if controls.shieldText then
        LayoutHelpers.AtCenterIn(controls.shieldText, controls.shieldBar)
        controls.shieldText:SetColor(UIUtil.fontOverColor)
        controls.shieldText:SetDropShadow(true)
        controls.shieldText:Hide()
    end

    -- Fuel bar
    controls.fuelBar.Width:Set(controls.healthBar.Width)
    controls.fuelBar.Height:Set(controls.healthBar.Height)
    controls.fuelBar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_bg.dds'))
    controls.fuelBar:SetBorder(1)
    controls.fuelBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/fuelbar.dds'))
    controls.fuelBar:Hide()

    if controls.fuelIconBG then controls.fuelIconBG:Destroy() end
    controls.fuelIconBG = Bitmap(controls.bg, UIUtil.UIFile('/game/panel/panel_brd_m.dds'))
    LayoutHelpers.LeftOf(controls.fuelIconBG, controls.fuelBar)
    controls.fuelIconBG.Width:Set(controls.fuelBar.Height)
    controls.fuelIconBG.Height:Set(controls.fuelBar.Height)

    controls.fuelIcon = controls.statGroups[7].icon
    LayoutHelpers.Reset(controls.fuelIcon)
    LayoutHelpers.AtCenterIn(controls.fuelIcon, controls.fuelIconBG)
    LayoutHelpers.SetDimensions(controls.fuelIcon, 14, 14)
    LayoutHelpers.DepthOverParent(controls.fuelIcon, controls.fuelIconBG)

    controls.fuelText = controls.statGroups[7].value
    LayoutHelpers.AtCenterIn(controls.fuelText, controls.fuelBar)
    controls.fuelText:SetColor(UIUtil.fontColor)
    controls.fuelText:SetDropShadow(true)

    -- Veterancy bar
    if controls.vetIconBG then controls.vetIconBG:Destroy() end
    controls.vetIconBG = Bitmap(controls.bg, UIUtil.UIFile('/game/panel/panel_brd_m.dds'))
    LayoutHelpers.LeftOf(controls.vetIconBG, controls.vetBar)
    controls.vetIconBG.Width:Set(controls.healthBar.Height)
    controls.vetIconBG.Height:Set(controls.vetBar.Height)

    controls.vetIcon = controls.statGroups[4].icon
    LayoutHelpers.Reset(controls.vetIcon)
    LayoutHelpers.AtCenterIn(controls.vetIcon, controls.vetIconBG)
    LayoutHelpers.SetDimensions(controls.vetIcon, 14, 14)
    LayoutHelpers.DepthOverParent(controls.vetIcon, controls.vetIconBG)

    LayoutHelpers.Reset(controls.vetBar)
    controls.vetBar:SetBorder(1)
    controls.vetBar.Left:Set(controls.healthBar.Left)
    LayoutHelpers.AtBottomIn(controls.vetBar, controls.bg, 14)
    controls.vetBar.Width:Set(controls.healthBar.Width)
    controls.vetBar.Height:Set(function() return controls.nextVet.Height() + LayoutHelpers.ScaleNumber(1) end)
    controls.vetBar:SetSolidColor(UIUtil.tooltipTitleColor)
    controls.vetBar._bar:SetSolidColor(UIUtil.fontColor)

    LayoutHelpers.CenteredAbove(controls.vetTitle, controls.vetBar, 1)
    controls.vetTitle:SetDropShadow(true)

    LayoutHelpers.AtCenterIn(controls.nextVet, controls.vetBar)
    controls.nextVet:SetColor(UIUtil.fontOverColor)
    controls.nextVet:SetDropShadow(true)

    -- Action
    LayoutHelpers.Reset(controls.actionIcon)
    controls.actionIcon.Top:Set(controls.icon.Top)
    controls.actionIcon.Right:Set(controls.name.Right)
    LayoutHelpers.SetDimensions(controls.actionIcon, 48, 48)
    LayoutHelpers.Below(controls.actionText, controls.actionIcon)
    LayoutHelpers.AtHorizontalCenterIn(controls.actionText, controls.actionIcon)
    controls.actionText:SetDropShadow(true)

    -- Abilities
    LayoutHelpers.AnchorToRight(controls.abilities, controls.bg, 19)
    LayoutHelpers.AtBottomIn(controls.abilities, controls.bg, 50)
    LayoutHelpers.SetDimensions(controls.abilities, 200, 50)

    -- Enhancements
    if controls.enhancement then
        controls.enhancement:Destroy()
    end
    controls.enhancement = Bitmap(controls.bg)
    controls.enhancement:SetTexture(SkinnableFile('/game/panel/panel_brd_m.dds'))
    LayoutHelpers.DepthUnderParent(controls.enhancement, controls.bg)
    LayoutHelpers.AtLeftIn(controls.enhancement, controls.bg, 16)
    LayoutHelpers.AnchorToTop(controls.enhancement, controls.bg, 7)
    LayoutHelpers.SetDimensions(controls.enhancement, 114, 16)
    controls.enhancement.border = Border(controls.enhancement)
    controls.enhancement.border:SetTextures(
        SkinnableFile('/game/panel/panel_brd_vert_l.dds'),
        SkinnableFile('/game/panel/panel_brd_horz_um.dds'),
        SkinnableFile('/game/panel/panel_brd_ul.dds'),
        SkinnableFile('/game/panel/panel_brd_ur.dds'),
        SkinnableFile('/game/panel/panel_brd_ll.dds'),
        SkinnableFile('/game/panel/panel_brd_lr.dds')
    )
    controls.enhancement.border:LayoutAroundControl(controls.enhancement)

--    controls.bg:DisableHitTest(true)

    SetBG(controls)
    UpdateStatusBars(controls)
end

--function SetBG(controls)
--    if controls.abilityBG then controls.abilityBG:Destroy() end
--    controls.abilityBG = NinePatch(controls.abilities,
--        UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_m.dds'),
--        UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_ul.dds'),
--        UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_ur.dds'),
--        UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_ll.dds'),
--        UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_lr.dds'),
--        UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_vert_l.dds'),
--        UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_vert_r.dds'),
--        UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_horz_um.dds'),
--        UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_lm.dds')
--)
--
--    controls.abilityBG:Surround(controls.abilities, 3, 5)
--    LayoutHelpers.DepthUnderParent(controls.abilityBG, controls.abilities)
--end
function SetBG(controls)
    controls.abilityBG.TL:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_ul.dds'))
    controls.abilityBG.TL.Right:Set(controls.abilities.Left)
    controls.abilityBG.TL.Bottom:Set(controls.abilities.Top)

    controls.abilityBG.TM:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_horz_um.dds'))
    controls.abilityBG.TM.Right:Set(controls.abilityBG.TL.Right)
    controls.abilityBG.TM.Bottom:Set(controls.abilities.Top)
    controls.abilityBG.TM.Left:Set(controls.abilityBG.TR.Left)

    controls.abilityBG.TR:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_ur.dds'))
    controls.abilityBG.TR.Left:Set(controls.abilities.Right)
    controls.abilityBG.TR.Bottom:Set(controls.abilities.Top)

    controls.abilityBG.ML:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_vert_l.dds'))
    controls.abilityBG.ML.Right:Set(controls.abilities.Left)
    controls.abilityBG.ML.Top:Set(controls.abilityBG.TL.Bottom)
    controls.abilityBG.ML.Bottom:Set(controls.abilityBG.BL.Top)

    controls.abilityBG.M:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_m.dds'))
    controls.abilityBG.M.Top:Set(controls.abilityBG.TM.Bottom)
    controls.abilityBG.M.Left:Set(controls.abilityBG.ML.Right)
    controls.abilityBG.M.Right:Set(controls.abilityBG.MR.Left)
    controls.abilityBG.M.Bottom:Set(controls.abilityBG.BM.Top)

    controls.abilityBG.MR:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_vert_r.dds'))
    controls.abilityBG.MR.Left:Set(controls.abilities.Right)
    controls.abilityBG.MR.Top:Set(controls.abilityBG.TR.Bottom)
    controls.abilityBG.MR.Bottom:Set(controls.abilityBG.BR.Top)

    controls.abilityBG.BL:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_ll.dds'))
    controls.abilityBG.BL.Right:Set(controls.abilities.Left)
    controls.abilityBG.BL.Top:Set(controls.abilities.Bottom)

    controls.abilityBG.BM:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_lm.dds'))
    controls.abilityBG.BM.Right:Set(controls.abilityBG.BL.Right)
    controls.abilityBG.BM.Top:Set(controls.abilities.Bottom)
    controls.abilityBG.BM.Left:Set(controls.abilityBG.BR.Left)

    controls.abilityBG.BR:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_lr.dds'))
    controls.abilityBG.BR.Left:Set(controls.abilities.Right)
    controls.abilityBG.BR.Top:Set(controls.abilities.Bottom)
end

function PositionWindow()
    -- Nothing to do
end

function UpdateStatusBars(controls)
    -- Hide redundancy
    if options.gui_detailed_unitview ~= 0 then
        controls.vetTitle:Hide()
        controls.statGroups[4].value:Hide() -- kils
        controls.statGroups[6].value:Hide() -- shield
    end

    -- shield
    controls.shieldIcon:SetHidden(controls.shieldBar:IsHidden())
    controls.shieldIconBG:SetHidden(controls.shieldBar:IsHidden())

    -- fuel/build
    if not controls.fuelBar:IsHidden() and controls.fuelIcon:IsHidden() then
        controls.fuelIcon:SetTexture(iconTextures[8]) -- build icon
    else
        controls.fuelIcon:SetTexture(iconTextures[7]) -- fuel icon
    end

    local fuelIconIsHidden = controls.fuelIcon:IsHidden()
    controls.fuelIcon:SetHidden(controls.fuelBar:IsHidden())
    controls.fuelIconBG:SetHidden(controls.fuelBar:IsHidden())
    controls.fuelText:SetHidden(fuelIconIsHidden)

    if controls.shieldBar:IsHidden() then
        LayoutHelpers.AtLeftTopIn(controls.fuelBar, controls.shieldBar)
    else
        LayoutHelpers.CenteredBelow(controls.fuelBar, controls.shieldBar, 1)
    end
    LayoutHelpers.AtCenterIn(controls.fuelText, controls.fuelBar)

    -- veterancy
    controls.vetIcon:SetHidden(controls.vetBar:IsHidden())
    controls.vetIconBG:SetHidden(controls.vetBar:IsHidden())

    -- Stats
    if not controls.fuelBar:IsHidden() then
        LayoutHelpers.AnchorToBottom(controls.stats, controls.fuelBar, 1)
    elseif not controls.shieldBar:IsHidden() then
        LayoutHelpers.AnchorToBottom(controls.stats, controls.shieldBar, 1)
    else
        LayoutHelpers.AnchorToBottom(controls.stats, controls.healthBar, 1)
    end

    local statGroups = {}
    for index = 1, table.getn(iconOrder) do
        local i = iconOrder[index];
        if controls.statGroups[i].value and not controls.statGroups[i].value:IsHidden() then
            table.insert(statGroups, controls.statGroups[i])
        end
    end
    for index = 1, table.getn(statGroups) do
        local i = index
        LayoutHelpers.AtLeftTopIn(statGroups[i].icon, controls.stats, iconPositions[i].Left, iconPositions[i].Top)
        LayoutHelpers.RightOf(statGroups[i].value, statGroups[i].icon, 5)
        LayoutHelpers.AtVerticalCenterIn(statGroups[i].value, statGroups[i].icon)
        statGroups[i].value:SetDropShadow(true)
    end

    -- Enhancements
    controls.enhancement:SetHidden(
        controls.enhancements['LCH']:IsHidden() and
        controls.enhancements['Command']:IsHidden() and
        controls.enhancements['RCH']:IsHidden() and
        controls.enhancements['Back']:IsHidden()
    )
end
