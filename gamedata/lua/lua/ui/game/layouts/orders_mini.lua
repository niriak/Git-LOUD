
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local GameCommon = import('/lua/ui/game/gamecommon.lua')

local Grid_Params = import('/lua/ui/game/orders.lua').Get_Grid_Params()

local numSlots = Grid_Params.Grid.numSlots
local firstAltSlot = Grid_Params.Grid.firstAltSlot
local vertRows = Grid_Params.Grid.vertRows
local horzRows = Grid_Params.Grid.horzRows
local vertCols = Grid_Params.Grid.vertCols
local horzCols = Grid_Params.Grid.horzCols

function SetLayout()
    local controls = import('/lua/ui/game/orders.lua').controls

    controls.bg:SetTexture(UIUtil.SkinnableFile('/game/orders-panel/order-panel_bmp.dds'))

    LayoutHelpers.SetDimensions(controls.orderButtonGrid, GameCommon.iconWidth * horzCols, GameCommon.iconHeight * horzRows)
    LayoutHelpers.AtCenterIn(controls.orderButtonGrid, controls.bg, 0, -1)
    controls.orderButtonGrid:AppendRows(horzRows)
    controls.orderButtonGrid:AppendCols(horzCols)

    controls.bg.Width:Set(Grid_Params.Order_Slots.panelsize.width)
    controls.bg.Height:Set(Grid_Params.Order_Slots.panelsize.height)
    LayoutHelpers.SetDimensions(controls.orderButtonGrid, Grid_Params.Order_Slots.iconsize.width * Grid_Params.Grid.horzCols, Grid_Params.Order_Slots.iconsize.height * Grid_Params.Grid.horzRows)
    LayoutHelpers.AtLeftTopIn(controls.orderButtonGrid, controls.bg, 10, 12)

    controls.bg.Mini = function(state)
        controls.bg:SetHidden(state)
        controls.orderButtonGrid:SetHidden(state)
    end
end
