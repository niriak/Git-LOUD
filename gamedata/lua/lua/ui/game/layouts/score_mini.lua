local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

function SetLayout()
    local controls = import('/lua/ui/game/score.lua').controls
    local mapGroup = import('/lua/ui/game/score.lua').savedParent

    controls.bg:SetEditable(UIUtil.IsEditUI())
    controls.bg.Width:Set(controls.bgTop.Width)

    LayoutHelpers.AtRightTopIn(controls.bgTop, controls.bg, 3)
    LayoutHelpers.AtLeftTopIn(controls.armyGroup, controls.bgTop, 10, 25)
    controls.armyGroup.Width:Set(controls.armyLines[1].Width)

    controls.bgTop:SetTexture(UIUtil.UIFile('/game/score-panel/panel-score_bmp_t.dds'))
    controls.bgBottom:SetTexture(UIUtil.UIFile('/game/score-panel/panel-score_bmp_b.dds'))
    controls.bgStretch:SetTexture(UIUtil.UIFile('/game/score-panel/panel-score_bmp_m.dds'))

    controls.bgBottom.Top:Set(function() return math.max(controls.armyGroup.Bottom() - LayoutHelpers.ScaleNumber(14), controls.bgTop.Bottom()) end)
    controls.bgBottom.Right:Set(controls.bgTop.Right)
    controls.bgStretch.Top:Set(controls.bgTop.Bottom)
    controls.bgStretch.Bottom:Set(controls.bgBottom.Top)
    controls.bgStretch.Right:Set(controls.bgTop.Right)

    controls.bg.Height:Set(function() return controls.bgBottom.Bottom() - controls.bgTop.Top() end)
    controls.armyGroup.Height:Set(function() 
        local totHeight = 0
        for _, line in controls.armyLines do
            totHeight = totHeight + line.Height()
        end
        return math.max(totHeight, LayoutHelpers.ScaleNumber(50))
    end)

    LayoutHelpers.AtLeftTopIn(controls.timeIcon, controls.bgTop, 10, 6)
    controls.timeIcon:SetTexture(UIUtil.UIFile('/game/unit_view_icons/time.dds'))
    LayoutHelpers.RightOf(controls.time, controls.timeIcon)

    LayoutHelpers.AtRightTopIn(controls.unitIcon, controls.bgTop, 10, 6)
    controls.unitIcon:SetTexture(UIUtil.UIFile('/dialogs/score-overlay/tank_bmp.dds'))
    LayoutHelpers.LeftOf(controls.units, controls.unitIcon)

    LayoutHelpers.SetDimensions(controls.timeIcon, controls.timeIcon.BitmapWidth() * .8, controls.timeIcon.BitmapHeight() * .8)
    LayoutHelpers.SetDimensions(controls.unitIcon, controls.unitIcon.BitmapWidth() * .9, controls.unitIcon.BitmapHeight() * .9)

    LayoutArmyLines()
end

function LayoutArmyLines()
    local controls = import('/lua/ui/game/score.lua').controls

    for index, line in controls.armyLines do
        local i = index
        if i == 1 then
            LayoutHelpers.AtLeftTopIn(controls.armyLines[i], controls.armyGroup)
        else
            LayoutHelpers.Below(controls.armyLines[i], controls.armyLines[i-1])
        end
    end
end
