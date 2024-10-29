local UIUtil = import('/lua/ui/uiutil.lua')
local SkinnableFile = UIUtil.SkinnableFile
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local options = import("/lua/user/prefs.lua").GetFromCurrentProfile('options')
local controls = import('/lua/ui/game/unitview.lua').controls
local consControl = import('/lua/ui/game/construction.lua').controls.constructionGroup
local ordersControls = import('/lua/ui/game/orders.lua').controls
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Border = import('/lua/maui/border.lua').Border

local iconOrder = { 1, 2, 8, 4, 5, 6, 7 }

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

--local iconPositions = {
--    [1] = {Left =  70, Top = 60}, -- combined stats showing mass trend for own units or army icon + nickname for others' units
--    [2] = {Left =  70, Top = 78}, -- energy trend
--    [8] = {Left =  70, Top = 96}, -- buildrate
--
--    [4] = {Left = 130, Top = 60}, -- kill count
--    [6] = {Left = 130, Top = 78}, -- unused (shield % HP)
--    [5] = {Left = 130, Top = 96}, -- tactical/strategic missile count
--
--    [3] = {Left = 190, Top = 60}, -- unused (vet xp)
--    [7] = {Left = 190, Top = 78}, -- fuel remaining time
--}
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

    controls.bg:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/build-over-back_bmp2.dds'))
    LayoutHelpers.AtLeftIn(controls.bg, controls.parent)
    LayoutHelpers.AtBottomIn(controls.bg, controls.parent)

    controls.bracket:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/bracket-unit_bmp2.dds'))
    LayoutHelpers.AtLeftTopIn(controls.bracket, controls.bg, -18, -2)

    if controls.bracketMid then
        controls.bracketMid:Destroy()
        controls.bracketMid = false
    end
    if controls.bracketMax then
        controls.bracketMax:Destroy()
        controls.bracketMax = false
    end

    -- Name
    LayoutHelpers.AtLeftTopIn(controls.name, controls.bg, 16, 14)
    LayoutHelpers.AtRightIn(controls.name, controls.bg, 16)
    controls.name:SetClipToWidth(true)
    controls.name:SetDropShadow(true)

    -- Icon
    LayoutHelpers.AtLeftTopIn(controls.icon, controls.bg, 12, 34)
    LayoutHelpers.SetDimensions(controls.icon, 48, 48)
    LayoutHelpers.AtLeftTopIn(controls.stratIcon, controls.icon)

    -- Health
    LayoutHelpers.RightOf(controls.healthBar, controls.icon, 6)
    LayoutHelpers.SetDimensions(controls.healthBar, 188, 16)
    controls.healthBar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_bg.dds'))
    controls.healthBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_green.dds'))

    LayoutHelpers.AtCenterIn(controls.health, controls.healthBar)
    controls.health:SetDropShadow(true)

    -- Shield
    LayoutHelpers.Reset(controls.shieldBar)
    controls.shieldBar.Width:Set(controls.healthBar.Width)
    controls.shieldBar.Height:Set(controls.healthBar.Height)
    LayoutHelpers.Below(controls.shieldBar, controls.healthBar, 1)

    controls.shieldBar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_bg.dds'))
    controls.shieldBar:SetBorder(1)
    controls.shieldBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/shieldbar.dds'))
    controls.shieldBar:Hide()

    if controls.shieldText then
        LayoutHelpers.AtCenterIn(controls.shieldText, controls.shieldBar)
        controls.shieldText:SetColor(UIUtil.fontOverColor)
        controls.shieldText:SetDropShadow(true)
        controls.shieldText:Hide()
    end

    -- Fuel
    controls.fuelBar.Width:Set(controls.healthBar.Width)
    LayoutHelpers.SetHeight(controls.fuelBar, 4)
    LayoutHelpers.Below(controls.fuelBar, controls.healthBar, 1)
    controls.fuelBar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_bg.dds'))
    controls.fuelBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/fuelbar.dds'))
    controls.fuelBar:Hide()

    -- Veterancy icons
    LayoutHelpers.Below(controls.vetIcons[1], controls.icon, 5)
    LayoutHelpers.AtLeftIn(controls.vetIcons[1], controls.icon, -5)
    for index = 2, 5 do
        local i = index
        LayoutHelpers.RightOf(controls.vetIcons[i], controls.vetIcons[i-1], -3)
    end

    -- Veterancy bar
    controls.vetBar:SetBorder(1)
    controls.vetBar.Left:Set(controls.healthBar.Left)
    controls.vetBar.Width:Set(controls.healthBar.Width)
    controls.vetBar.Height:Set(function() return controls.nextVet.Height() + LayoutHelpers.ScaleNumber(1) end)
    LayoutHelpers.AtBottomIn(controls.vetBar, controls.bg, 12)
    controls.vetBar:SetSolidColor(UIUtil.tooltipTitleColor)
    controls.vetBar._bar:SetSolidColor(UIUtil.fontColor)

    LayoutHelpers.CenteredAbove(controls.vetTitle, controls.vetBar, 1)
    controls.vetTitle:SetDropShadow(true)

    LayoutHelpers.AtCenterIn(controls.nextVet, controls.vetBar)
    controls.nextVet:SetColor(UIUtil.fontOverColor)
    controls.nextVet:SetDropShadow(true)

    -- Stats
    if controls.stats then
        controls.stats:Destroy()
    end
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

    -- Action
    LayoutHelpers.AtLeftTopIn(controls.actionIcon, controls.bg, 261, 34)
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

    SetBG(controls)
    UpdateStatusBars(controls)
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
    -- Show text "Veterancy" only until first star
--    controls.vetTitle:SetHidden(controls.vetBar:IsHidden() or not controls.vetIcons[1]:IsHidden())

    if options.gui_detailed_unitview ~= 0 then
        controls.vetTitle:Hide()
        controls.statGroups[4].icon:Hide()
        controls.statGroups[4].value:Hide()
    end

    -- fuel/build
    if controls.shieldBar:IsHidden() then
        LayoutHelpers.AtLeftTopIn(controls.fuelBar, controls.shieldBar)
    else
        LayoutHelpers.CenteredBelow(controls.fuelBar, controls.shieldBar, 1)
    end

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
end
