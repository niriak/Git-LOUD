local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local options = import("/lua/user/prefs.lua").GetFromCurrentProfile('options')
local controls = import('/lua/ui/game/unitview.lua').controls
local consControl = import('/lua/ui/game/construction.lua').controls.constructionGroup
local ordersControls = import('/lua/ui/game/orders.lua').controls

local iconPositions = {
    [1] = {Left = 70, Top = 155},
    [2] = {Left = 70, Top = 170},
    [3] = {Left = 190, Top = 160},
    [4] = {Left = 130, Top = 155},
    [5] = {Left = 130, Top = 185},
    [6] = {Left = 130, Top = 170},
    [7] = {Left = 190, Top = 185},
    [8] = {Left = 70, Top = 185},
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

function SetLayout()
    controls.bg:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/build-over-back_bmp.dds'))
    LayoutHelpers.AtLeftIn(controls.bg, controls.parent)
    LayoutHelpers.AtBottomIn(controls.bg, controls.parent)

    controls.bracket:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/bracket-unit_bmp.dds'))
    LayoutHelpers.AtLeftTopIn(controls.bracket, controls.bg, -18, -2)

    if controls.bracketMid then
        controls.bracketMid:Destroy()
        controls.bracketMid = false
    end
    if controls.bracketMax then
        controls.bracketMax:Destroy()
        controls.bracketMax = false
    end

    LayoutHelpers.AtLeftTopIn(controls.name, controls.bg, 16, 14)
    LayoutHelpers.AtRightIn(controls.name, controls.bg, 16)
    controls.name:SetClipToWidth(true)
    controls.name:SetDropShadow(true)

    LayoutHelpers.AtLeftTopIn(controls.icon, controls.bg, 12, 34)
    LayoutHelpers.SetDimensions(controls.icon, 48, 48)
    LayoutHelpers.AtLeftTopIn(controls.stratIcon, controls.icon)

    LayoutHelpers.Below(controls.vetIcons[1], controls.icon, 5)
    LayoutHelpers.AtLeftIn(controls.vetIcons[1], controls.icon, -5)
    for index = 2, 5 do
        local i = index
        LayoutHelpers.RightOf(controls.vetIcons[i], controls.vetIcons[i-1], -3)
    end

    -- health bar
    LayoutHelpers.RightOf(controls.healthBar, controls.icon, 6)
    LayoutHelpers.SetDimensions(controls.healthBar, 188, 16)
    controls.healthBar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_bg.dds'))
    controls.healthBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_green.dds'))

    LayoutHelpers.AtCenterIn(controls.health, controls.healthBar)
    controls.health:SetDropShadow(true)

    -- shield bar
    LayoutHelpers.Below(controls.shieldBar, controls.healthBar, 2)
    controls.shieldBar.Width:Set(controls.healthBar.Width)
    LayoutHelpers.SetHeight(controls.shieldBar, 2)
    controls.shieldBar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_bg.dds'))
    controls.shieldBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/shieldbar.dds'))

    if options.gui_detailed_unitview ~= 0 then
        LayoutHelpers.CenteredBelow(controls.shieldText, controls.shieldBar, 2)
        controls.shieldText:SetDropShadow(true)
        LayoutHelpers.AnchorToBottom(controls.fuelBar, controls.shieldText, 2)
    else
        LayoutHelpers.AnchorToBottom(controls.fuelBar, controls.shieldBar, 2)
    end

    -- fuel bar
    controls.fuelBar.Left:Set(controls.shieldBar.Left)
    controls.fuelBar.Width:Set(controls.healthBar.Width)
    LayoutHelpers.SetHeight(controls.fuelBar, 2)
    controls.fuelBar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_bg.dds'))
    controls.fuelBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/fuelbar.dds'))

    local fuelStatGroup = controls.statGroups[7]
    if fuelStatGroup.value then
        fuelStatGroup.icon:SetTexture(iconTextures[7])
        LayoutHelpers.CenteredBelow(fuelStatGroup.icon, controls.fuelBar, 2)

        LayoutHelpers.RightOf(fuelStatGroup.value, fuelStatGroup.icon, 5)
        LayoutHelpers.AtVerticalCenterIn(fuelStatGroup.value, fuelStatGroup.icon)
        fuelStatGroup.value:SetDropShadow(true)
    end

    -- veterancy bar
    controls.vetBar.Width:Set(controls.icon.Width)
    LayoutHelpers.SetHeight(controls.vetBar, 2)
    LayoutHelpers.Below(controls.vetBar, controls.icon, 2)
    controls.vetBar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_bg.dds'))
    controls.vetBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/fuelbar.dds'))

    LayoutHelpers.Below(controls.nextVet, controls.vetBar)
    controls.nextVet:SetDropShadow(true)
    LayoutHelpers.Above(controls.vetTitle, controls.vetBar)
    controls.vetTitle:SetDropShadow(true)

--    for index = 1, table.getn(iconPositions) do
--        local i = index
--        if iconPositions[i] then
--            LayoutHelpers.AtLeftTopIn(controls.statGroups[i].icon, controls.bg, iconPositions[i].Left, iconPositions[i].Top)
--        else
--            LayoutHelpers.Below(controls.statGroups[i].icon, controls.statGroups[i-1].icon, 5)
--        end
--        controls.statGroups[i].icon:SetTexture(iconTextures[i])
--        LayoutHelpers.RightOf(controls.statGroups[i].value, controls.statGroups[i].icon, 5)
--        LayoutHelpers.AtVerticalCenterIn(controls.statGroups[i].value, controls.statGroups[i].icon)
--        controls.statGroups[i].value:SetDropShadow(true)
--    end
    LayoutHelpers.AtLeftTopIn(controls.actionIcon, controls.bg, 261, 34)
    LayoutHelpers.SetDimensions(controls.actionIcon, 48, 48)
    LayoutHelpers.Below(controls.actionText, controls.actionIcon)
    LayoutHelpers.AtHorizontalCenterIn(controls.actionText, controls.actionIcon)

    LayoutHelpers.AnchorToRight(controls.abilities, controls.bg, 19)
    LayoutHelpers.AtBottomIn(controls.abilities, controls.bg, 50)
    LayoutHelpers.SetDimensions(controls.abilities, 200, 50)

    SetBG(controls)

    if options.gui_detailed_unitview ~= 0 then
--        LayoutHelpers.CenteredBelow(controls.shieldText, controls.shieldBar,2)
    else
        LayoutHelpers.AtLeftTopIn(controls.statGroups[1].icon, controls.bg, 70, 60)
        LayoutHelpers.AtLeftTopIn(controls.statGroups[2].icon, controls.bg, 70, 80)
    end
end

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
    if consControl:IsHidden() then
        LayoutHelpers.AtBottomIn(controls.bg, controls.parent)
        LayoutHelpers.AtBottomIn(controls.abilities, controls.bg, 24)
    else
        if ordersControls.bg then
            LayoutHelpers.AtBottomIn(controls.bg, controls.parent, 120)
            LayoutHelpers.AtBottomIn(controls.abilities, controls.bg, 42)
        else
            -- Replay? Anyway, the orders control does not exist so the construction control is all the way to the left.
            -- The construction control is taller than the orders control, so we have to move unit view higher.
            LayoutHelpers.AtBottomIn(controls.bg, controls.parent, 140)
            LayoutHelpers.AtLeftIn(controls.bg, controls.parent, 18)
        end
    end
    LayoutHelpers.AtLeftIn(controls.bg, controls.parent, 17)
end

function UpdateStatusBars(controls)
--    if options.gui_detailed_unitview ~= 0 and controls.store == 1 then
--        LayoutHelpers.CenteredBelow(controls.shieldText, controls.shieldBar, -2.5)
--        LayoutHelpers.CenteredBelow(controls.fuelBar, controls.shieldBar, 3)
--    elseif options.gui_detailed_unitview ~= 0 then
--        LayoutHelpers.CenteredBelow(controls.fuelBar, controls.shieldBar, 2)
--        LayoutHelpers.CenteredBelow(controls.shieldText, controls.shieldBar, 2)
--    end
end
