local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

local modPath = '/mods/SupremeScoreBoard/'
local modTextures = modPath..'textures/'
local modScripts  = modPath..'modules/'
local log  = import(modScripts..'ext.logging.lua')

function SetLayout()
    LOG('>>>> HUSSAR: score_mini SetLayout... ')
    local controls = import('/lua/ui/game/score.lua').controls
    local mapGroup = import('/lua/ui/game/score.lua').savedParent
    
    controls.bg:SetEditable(UIUtil.IsEditUI())
    controls.bg.Width:Set(controls.bgTop.Width)
    
    LayoutHelpers.AtRightTopIn(controls.bgTop, controls.bg, 3)
	
    LayoutHelpers.AtLeftTopIn(controls.armyGroup, controls.bgTop, 10, 25)
    controls.armyGroup.Width:Set(controls.armyLines[1].Width)
    
    --LOG('>>>> HUSSAR: score_mini texture panel... ')
    --controls.bgTop:SetTexture(UIUtil.UIFile('/game/score-panel/panel-score_bmp_t.dds'))
    --controls.bgBottom:SetTexture(UIUtil.UIFile('/game/score-panel/panel-score_bmp_b.dds'))
    --controls.bgStretch:SetTexture(UIUtil.UIFile('/game/score-panel/panel-score_bmp_m.dds'))
    
    controls.bgTop:SetTexture(modTextures..'score_top.dds')
    controls.bgBottom:SetTexture(modTextures..'score_bottom.dds')
    controls.bgStretch:SetTexture(modTextures..'score_strech.dds')

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
    
    -- NOTE HUSSAR moved loading icons for timer and unit counter to score.LUA
    
    --LOG('>>>> HUSSAR: score_mini texture time/tank... ')
    LayoutHelpers.AtLeftTopIn(controls.timeIcon, controls.bgTop, 10, 8)
	LayoutHelpers.AnchorToRight(controls.time, controls.timeIcon, 2)
	LayoutHelpers.AtVerticalCenterIn(controls.time, controls.timeIcon)
    
    LayoutHelpers.AtLeftIn(controls.speedIcon, controls.bgTop, 106)
	controls.speedIcon.Top:Set(controls.timeIcon.Top)
	LayoutHelpers.AnchorToRight(controls.speed, controls.speedIcon, 2)
	LayoutHelpers.AtVerticalCenterIn(controls.speed, controls.speedIcon)
    
    LayoutHelpers.AtLeftIn(controls.qualityIcon, controls.bgTop, 182)
	controls.qualityIcon.Top:Set(controls.speedIcon.Top)
	LayoutHelpers.AnchorToRight(controls.quality, controls.qualityIcon, 2)
	LayoutHelpers.AtVerticalCenterIn(controls.quality, controls.qualityIcon)
    
    LayoutHelpers.AtRightIn(controls.unitIcon, controls.bgTop, 10)
	controls.unitIcon.Top:Set(controls.qualityIcon.Top)
    LayoutHelpers.AnchorToLeft(controls.units, controls.unitIcon)
	LayoutHelpers.AtVerticalCenterIn(controls.units, controls.unitIcon)
    
    -- offset Avatars UI by height of the score board
    local avatarGroup = import('/lua/ui/game/avatars.lua').controls.avatarGroup
	LayoutHelpers.AnchorToBottom(avatarGroup, controls.bgBottom, 4)
    
    --LOG('>>>> HUSSAR: score_mini layout lines... ')
    LayoutArmyLines()
end

function LayoutArmyLines()
    local controls = import('/lua/ui/game/score.lua').controls
    if not controls.armyLines then return end

    for index, line in controls.armyLines do
        local i = index
        if controls.armyLines[i] then
            if i == 1 then
                LayoutHelpers.AtLeftTopIn(controls.armyLines[i], controls.armyGroup)
            else
                LayoutHelpers.Below(controls.armyLines[i], controls.armyLines[i-1])
            end
        end
    end
end
    