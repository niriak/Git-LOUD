----------------------------------------------------------------------------------------------------
----   Generic Window ClassUI
----------------------------------------------------------------------------------------------------


local UIUtil = import("/lua/ui/uiutil.lua")
local Group = import("/lua/maui/group.lua").Group
local Bitmap = import("/lua/maui/bitmap.lua").Bitmap
local Text = import("/lua/maui/text.lua").Text
local Button = import("/lua/maui/button.lua").Button
local Dragger = import("/lua/maui/dragger.lua").Dragger
local Checkbox = import("/lua/maui/checkbox.lua").Checkbox
local LayoutHelpers = import("/lua/maui/layouthelpers.lua")
local Prefs = import("/lua/user/prefs.lua")

-- default style set
styles = {
    backgrounds = {
        transparent = {
            borderColor = 'ff415055',
        },
    },
    cursorFunc = UIUtil.GetCursor,
}

---@class UIGroup : Group
UIGroup = Class(Group) {

    __init = function(self, parent, lockSize, lockPosition, prefID, defaultPosition, textureTable)
        Group.__init(self, parent, tostring(prefID))

        self._resizeGroup = Group(self, 'window resize group')
        LayoutHelpers.FillParent(self._resizeGroup, self)
        LayoutHelpers.DepthOverParent(self._resizeGroup, self, 100)
        self._resizeGroup:DisableHitTest(true)

        self.tl = Bitmap(self._resizeGroup)
        self.tr = Bitmap(self._resizeGroup)
        self.bl = Bitmap(self._resizeGroup)
        self.br = Bitmap(self._resizeGroup)
        self.tm = Bitmap(self._resizeGroup)
        self.bm = Bitmap(self._resizeGroup)
        self.ml = Bitmap(self._resizeGroup)
        self.mr = Bitmap(self._resizeGroup)

        self._pref = prefID
        self._borderSize = 5
        self._cornerSize = 8
        self._sizeLock = false
        self._lockPosition = lockPosition or false
        self._lockSize = lockSize or false
        self._xMin = 0
        self._yMin = 0
        self._isEditable = false
        self._enableHitTest = true

        --Set alpha of resize controls to 0 so that they still get resize events, but are not seen

        self.tl:SetAlpha(0)
        self.tr:SetAlpha(0)
        self.bl:SetAlpha(0)
        self.br:SetAlpha(0)
        self.tm:SetAlpha(0)
        self.bm:SetAlpha(0)
        self.ml:SetAlpha(0)
        self.mr:SetAlpha(0)

        self.tl.Height:Set(self._cornerSize)
        self.tl.Width:Set(self._cornerSize)
        self.tl.Top:Set(self.Top)
        self.tl.Left:Set(self.Left)

        self.tr.Height:Set(self._cornerSize)
        self.tr.Width:Set(self._cornerSize)
        self.tr.Top:Set(self.Top)
        self.tr.Right:Set(self.Right)

        self.bl.Height:Set(self._cornerSize)
        self.bl.Width:Set(self._cornerSize)
        self.bl.Bottom:Set(self.Bottom)
        self.bl.Left:Set(self.Left)

        self.br.Height:Set(self._cornerSize)
        self.br.Width:Set(self._cornerSize)
        self.br.Bottom:Set(self.Bottom)
        self.br.Right:Set(self.Right)

        self.tm.Height:Set(self._borderSize)
        self.tm.Left:Set(self.tl.Right)
        self.tm.Right:Set(self.tr.Left)
        self.tm.Top:Set(self.tl.Top)

        self.bm.Height:Set(self._borderSize)
        self.bm.Left:Set(self.bl.Right)
        self.bm.Right:Set(self.br.Left)
        self.bm.Top:Set(self.bl.Top)

        self.ml.Width:Set(self._borderSize)
        self.ml.Left:Set(self.tl.Left)
        self.ml.Top:Set(self.tl.Bottom)
        self.ml.Bottom:Set(self.bl.Top)

        self.mr.Width:Set(self._borderSize)
        self.mr.Right:Set(self.tr.Right)
        self.mr.Top:Set(self.tr.Bottom)
        self.mr.Bottom:Set(self.br.Top)

        local texturekey = 'transparent'
        if textureTable then
            texturekey = prefID
            styles.backgrounds[prefID] = textureTable
        end

        self.tl:SetSolidColor(styles.backgrounds[texturekey].borderColor)
        self.tr:SetSolidColor(styles.backgrounds[texturekey].borderColor)
        self.bl:SetSolidColor(styles.backgrounds[texturekey].borderColor)
        self.br:SetSolidColor(styles.backgrounds[texturekey].borderColor)
        self.tm:SetSolidColor(styles.backgrounds[texturekey].borderColor)
        self.bm:SetSolidColor(styles.backgrounds[texturekey].borderColor)
        self.ml:SetSolidColor(styles.backgrounds[texturekey].borderColor)
        self.mr:SetSolidColor(styles.backgrounds[texturekey].borderColor)

        self._windowGroup = Group(self, 'window texture group')
        LayoutHelpers.FillParent(self._windowGroup, self)
        self._windowGroup:DisableHitTest()

        self.window_tl = Bitmap(self._windowGroup, styles.backgrounds[texturekey].tl)
        self.window_tr = Bitmap(self._windowGroup, styles.backgrounds[texturekey].tr)
        self.window_tm = Bitmap(self._windowGroup, styles.backgrounds[texturekey].tm)
        self.window_ml = Bitmap(self._windowGroup, styles.backgrounds[texturekey].ml)
        self.window_m  = Bitmap(self._windowGroup, styles.backgrounds[texturekey].m)
        self.window_mr = Bitmap(self._windowGroup, styles.backgrounds[texturekey].mr)
        self.window_bl = Bitmap(self._windowGroup, styles.backgrounds[texturekey].bl)
        self.window_bm = Bitmap(self._windowGroup, styles.backgrounds[texturekey].bm)
        self.window_br = Bitmap(self._windowGroup, styles.backgrounds[texturekey].br)

        self.window_tl.Top:Set(self.Top)
        self.window_tl.Left:Set(self.Left)
        LayoutHelpers.DepthUnderParent(self.window_tl, self._windowGroup)

        self.window_tr.Top:Set(self.Top)
        self.window_tr.Right:Set(self.Right)
        LayoutHelpers.DepthUnderParent(self.window_tr, self._windowGroup)

        self.window_bl.Bottom:Set(self.Bottom)
        self.window_bl.Left:Set(self.Left)
        LayoutHelpers.DepthUnderParent(self.window_bl, self._windowGroup)

        self.window_br.Bottom:Set(self.Bottom)
        self.window_br.Right:Set(self.Right)
        LayoutHelpers.DepthUnderParent(self.window_br, self._windowGroup)

        self.window_tm.Left:Set(self.window_tl.Right)
        self.window_tm.Right:Set(self.window_tr.Left)
        self.window_tm.Top:Set(self.window_tl.Top)
        LayoutHelpers.DepthUnderParent(self.window_tm, self._windowGroup)

        self.window_bm.Left:Set(self.window_bl.Right)
        self.window_bm.Right:Set(self.window_br.Left)
        self.window_bm.Top:Set(self.window_bl.Top)
        LayoutHelpers.DepthUnderParent(self.window_bm, self._windowGroup)

        self.window_ml.Left:Set(self.window_tl.Left)
        self.window_ml.Top:Set(self.window_tl.Bottom)
        self.window_ml.Bottom:Set(self.window_bl.Top)
        LayoutHelpers.DepthUnderParent(self.window_ml, self._windowGroup)

        self.window_mr.Right:Set(self.window_tr.Right)
        self.window_mr.Top:Set(self.window_tr.Bottom)
        self.window_mr.Bottom:Set(self.window_br.Top)
        LayoutHelpers.DepthUnderParent(self.window_mr, self._windowGroup)

        self.window_m.Top:Set(self.window_tm.Bottom)
        self.window_m.Left:Set(self.window_ml.Right)
        self.window_m.Right:Set(self.window_mr.Left)
        self.window_m.Bottom:Set(self.window_bm.Top)
        LayoutHelpers.DepthUnderParent(self.window_m, self._windowGroup)

        self._moveGroup = Group(self, 'window move group')
        LayoutHelpers.Layouter(self._moveGroup)
            :Top(self.tm.Bottom)
            :Left(self.ml.Right)
            :Height(function() return self.bm.Top() - self.tm.Bottom() end)
            :Width(function() return self.mr.Left() - self.ml.Right() end)
            :Right(self.mr.Left)
            :Bottom(self.bm.Top)
            :Over(self, 100)

        self.StartSizing = function(event, xControl, yControl)
            local drag = Dragger()
            local x_max = true
            local y_max = true
            if event.MouseX < self.tl.Right() then
                x_max = false
            end
            if event.MouseY < self.tl.Bottom() then
                y_max = false
            end
            drag.OnMove = function(dragself, x, y)
                if xControl then
                    local newX
                    if x_max then
                        newX = math.min(math.max(x, self.Left() + self._xMin), parent.Right())
                        newX = math.max(newX, self.Left() + (2*self.window_tl.Width()))
                    else
                        newX = math.min(math.max(x, 0), self.Right() - self._xMin)
                    end
                    xControl:Set(newX)
                end
                if yControl then
                    local newY
                    if y_max then
                        newY = math.min(math.max(y, self.Top() + self._yMin), parent.Bottom())
                        newY = math.max(newY, self.Top() + self.window_bm.Height() + self.window_tm.Height())
                    else
                        newY = math.min(math.max(y, 0), self.Bottom() - self._yMin)
                    end
                    yControl:Set(newY)
                end
                self:OnResize(x, y, not self._sizeLock)
                if not self._sizeLock then
                    self._sizeLock = true
                end
            end
            drag.OnRelease = function(dragself)
                self._sizeLock = false
                self._resizeGroup:SetAlpha(0, true)
                GetCursor():Reset()
--                LayoutHelpers.ResetWidth(self)
--                LayoutHelpers.ResetHeight(self)
                drag:Destroy()
                self:SaveWindowLocation()
                self:OnResizeSet()
            end
            drag.OnCancel = function(dragself)
                self._sizeLock = false
                GetCursor():Reset()
                drag:Destroy()
            end
            PostDragger(self:GetRootFrame(), event.KeyCode, drag)
        end

        self.RolloverHandler = function(control, event, xControl, yControl, cursor, controlID)
            if self._lockSize then return end
            if not self._sizeLock then
                if event.Type == 'MouseEnter' then
                    self._resizeGroup:SetAlpha(1, true)
                    GetCursor():SetTexture(styles.cursorFunc(cursor))
                elseif event.Type == 'MouseExit' then
                    self._resizeGroup:SetAlpha(0, true)
                    GetCursor():Reset()
                elseif event.Type == 'ButtonPress' then
                    self.StartSizing(event, xControl, yControl)
                end
            end
        end

        self.br.HandleEvent = function(control, event)
            self.RolloverHandler(control, event, self.Right, self.Bottom, 'NW_SE', 'br')
        end
        self.bl.HandleEvent = function(control, event)
            self.RolloverHandler(control, event, self.Left, self.Bottom, 'NE_SW', 'bl')
        end
        self.bm.HandleEvent = function(control, event)
            self.RolloverHandler(control, event, nil, self.Bottom, 'N_S', 'bm')
        end
        self.tr.HandleEvent = function(control, event)
            self.RolloverHandler(control, event, self.Right, self.Top, 'NE_SW', 'tr')
        end
        self.tl.HandleEvent = function(control, event)
            self.RolloverHandler(control, event, self.Left, self.Top, 'NW_SE', 'tl')
        end
        self.tm.HandleEvent = function(control, event)
            self.RolloverHandler(control, event, nil, self.Top, 'N_S', 'tm')
        end
        self.mr.HandleEvent = function(control, event)
            self.RolloverHandler(control, event, self.Right, nil, 'W_E', 'mr')
        end
        self.ml.HandleEvent = function(control, event)
            self.RolloverHandler(control, event, self.Left, nil, 'W_E', 'ml')
        end

        self._moveGroup.HandleEvent = function(control, event)
            if not self._sizeLock then
                if event.Type == 'ButtonPress' then
                    if self._lockPosition then return end
                    local drag = Dragger()
                    local offX = event.MouseX - self.Left()
                    local offY = event.MouseY - self.Top()
                    local height = self.Height()
                    local width = self.Width()
                    drag.OnMove = function(dragself, x, y)
                        self.Left:Set(math.min(math.max(x-offX, parent.Left()), parent.Right() - self.Width()))
                        self.Top:Set(math.min(math.max(y-offY, parent.Top()), parent.Bottom() - self.Height()))
                        local tempRight = self.Left() + width
                        local tempBottom = self.Top() + height
                        self.Right:Set(tempRight)
                        self.Bottom:Set(tempBottom)
                        self:OnMove(x, y, not self._sizeLock)
                        if not self._sizeLock then
                            GetCursor():SetTexture(styles.cursorFunc('MOVE_WINDOW'))
                            self._sizeLock = true
                        end
                    end
                    drag.OnRelease = function(dragself)
                        self._sizeLock = false
                        GetCursor():Reset()
                        drag:Destroy()
                        self:SaveWindowLocation()
                        self:OnMoveSet()
                    end
                    drag.OnCancel = function(dragself)
                        self._sizeLock = false
                        GetCursor():Reset()
                        drag:Destroy()
                    end
                    PostDragger(self:GetRootFrame(), event.KeyCode, drag)
                end
            end
            if event.Type == 'WheelRotation' then
                self:OnMouseWheel(event.WheelRotation)
            end
        end
        self.OnHide = function(control, hidden)
            control._resizeGroup:SetHidden(hidden)
            control:OnHideWindow(control, hidden)
        end

        local OldHeightOnDirty = parent.Height.OnDirty
        local OldWidthOnDirty = parent.Width.OnDirty
--        parent.Height.OnDirty = function(var)
--            if self.Bottom() > parent.Bottom() then
--                local Height = math.min(self.Height(), parent.Height())
--                self.Bottom:Set(parent.Bottom())
--                self.Top:Set(self.Bottom() - Height)
--            end
--            if OldHeightOnDirty then
--                OldHeightOnDirty(var)
--            end
--            self:SaveWindowLocation()
--        end
--        parent.Width.OnDirty = function(var)
--            if self.Right() > parent.Right() then
--                local Width = math.min(self.Width(), parent.Width())
--                self.Right:Set(parent.Right())
--                self.Left:Set(self.Right() - Width)
--            end
--            if OldWidthOnDirty then
--                OldWidthOnDirty(var)
--            end
--            self:SaveWindowLocation()
--        end

        -- attempt to retrieve location of window in preference file
        local location = Prefs.GetFromCurrentProfile(prefID)
        if location then
            local top = location.top 
            local left = location.left 
            local width = location.width 
            local height = location.height 

            -- we can scale these accordingly as we applied the inverse on saving
            self.Left:Set(LayoutHelpers.ScaleNumber(left))
            self.Top:Set(LayoutHelpers.ScaleNumber(top))
            self.Width:Set(LayoutHelpers.ScaleNumber(width))
            self.Height:Set(LayoutHelpers.ScaleNumber(height))
            LayoutHelpers.ResetRight(self)
            LayoutHelpers.ResetBottom(self)
        elseif defaultPosition then
            -- Scale only if it's a number, else it's already scaled lazyvar
            if type(defaultPosition.Left) == 'number' then
                self.Left:Set(LayoutHelpers.ScaleNumber(defaultPosition.Left))
                self.Top:Set(LayoutHelpers.ScaleNumber(defaultPosition.Top))
                self.Bottom:Set(LayoutHelpers.ScaleNumber(defaultPosition.Bottom))
                self.Right:Set(LayoutHelpers.ScaleNumber(defaultPosition.Right))
            else
                self.Left:Set(defaultPosition.Left)
                self.Top:Set(defaultPosition.Top)
                self.Bottom:Set(defaultPosition.Bottom)
                self.Right:Set(defaultPosition.Right)
            end
        end

        self:SetEditable(false)
    end,

    ---@param self Window
    ---@param alpha number
    ---@param affectChildren boolean
    SetAlpha = function(self, alpha, affectChildren)
        affectChildren = affectChildren or false
        Group.SetAlpha(self, alpha, affectChildren)

        -- guarantee that the resize bars remain transparent
        self._resizeGroup:SetAlpha(0, true)

        -- hide component if not visible to disable event handlers
        if alpha == 0 then
            self:Hide()
        elseif self:IsHidden() then
            self:Show()
        end
    end,

    SaveWindowLocation = function(self)
        if self._pref then
            LOG("custom SaveWindowLocation " .. tostring(self.Left()) .. "x" .. tostring(self.Top()) .. " of window '" .. self._pref .. "'")
            Prefs.SetToCurrentProfile(
                self._pref, 
                {
                    -- invert the scale on these numbers, that allows us to apply the scale again when we read it from the preference file
                    left = LayoutHelpers.InvScaleNumber(self.Left()),
                    top = LayoutHelpers.InvScaleNumber(self.Top()),
                    width = LayoutHelpers.InvScaleNumber(self.Width()),
                    height = LayoutHelpers.InvScaleNumber(self.Height())
                }
            )
        end
    end,

    ApplyWindowTextures = function(self, textures)
        self.window_tl:SetTexture(textures.tl)
        self.window_tr:SetTexture(textures.tr)
        self.window_tm:SetTexture(textures.tm)
        self.window_ml:SetTexture(textures.ml)
        self.window_m:SetTexture(textures.m)
        self.window_mr:SetTexture(textures.mr)
        self.window_bl:SetTexture(textures.bl)
        self.window_bm:SetTexture(textures.bm)
        self.window_br:SetTexture(textures.br)
    end,

    SetSizeLock = function(self, locked)
        self._lockSize = locked
    end,

    SetPositionLock = function(self, locked)
        self._lockPosition = locked
    end,

    SetMinimumResize = function(self, xDimension, yDimension)
        self._xMin = LayoutHelpers.ScaleNumber(xDimension) or 0
        self._yMin = LayoutHelpers.ScaleNumber(yDimension) or 0
    end,

    SetWindowAlpha = function(self, alpha)
        self._windowGroup:SetAlpha(alpha, true)
    end,

    OnDestroy = function(self)
        self._resizeGroup:Destroy()
    end,

    EnableHitTest = function(self, affectChildren)
--        affectChildren = affectChildren or false
--        Group.EnableHitTest(self, affectChildren)
--
--        self._resizeGroup:DisableHitTest()
--        self._windowGroup:DisableHitTest()
--
--        if not self._isEditable then
--            self._moveGroup:DisableHitTest()
--        end
    end,

    DisableHitTest = function(self, affectChildren)
--        affectChildren = affectChildren or false
--        Group.DisableHitTest(self, affectChildren)
--
--        self._resizeGroup:DisableHitTest()
--        self._windowGroup:DisableHitTest()
--
--        if self._isEditable then
--            self._moveGroup:EnableHitTest()
--        end
    end,

--    Show = function(self)
--        Group.Show(self)
--        self._resizeGroup:Hide()
--        self._moveGroup:Hide()
--    end,

--    SetHidden = function(self, isHidden)
--        isHidden = isHidden or false
--        Group.SetHidden(self, isHidden)
--        self._resizeGroup:Hide()
--        self._moveGroup:Hide()
--    end,

    SetEditable = function(self, isEditable)
--        self._sizeLock = not isEditable
        self._isEditable = isEditable

        if isEditable then
            self._windowGroup:DisableHitTest(true)
            self._resizeGroup:DisableHitTest(true)
            self._moveGroup:EnableHitTest(true)

            self._resizeGroup:Show()
            self._moveGroup:Show()
        else
            self._windowGroup:DisableHitTest(true)
            self._resizeGroup:DisableHitTest(true)
            self._moveGroup:DisableHitTest(true)

            self._resizeGroup:Hide()
            self._moveGroup:Hide()
        end
    end,

    InitAnimation = function(self)
        self:Show()
        self:SetNeedsFrameUpdate(true)

        local alpha = 0
        self.OnFrame = function(self, delta)
            alpha = alpha + delta*3
            if alpha >= 1 then
                self:SetAlpha(1)
                self:SetNeedsFrameUpdate(false)
            else
                self:SetAlpha(alpha)
            end
        end
    end,

    -- The following are functions that can be overloaded
    OnResize = function(self, x, y, firstFrame) end,
    OnResizeSet = function(self) end,

    OnMove = function(self, x, y, firstFrame) end,
    OnMoveSet = function(self) end,

    OnMouseWheel = function(self, rotation) end,

    OnHideWindow = function(self, hidden) end,
}
