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

local GROW_TO_TOP = "top"
local GROW_TO_LEFT = "left"
local GROW_TO_RIGHT = "right"
local GROW_TO_BOTTOM = "bottom"

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

        self._pref = prefID
        self._borderSize = 5
        self._cornerSize = 8
        self._sizeLock = false
        self._lockPosition = lockPosition or false

        if lockSize then
            if lockSize.Type != "table" then
                lockSize = {}
            end
            if lockSize.growHorz == GROW_TO_LEFT then
                LayoutHelpers.ResetLeft(self)
            else
                lockSize.growHorz = GROW_TO_RIGHT
                LayoutHelpers.ResetRight(self)
            end
            if lockSize.growVert == GROW_TO_TOP then
                LayoutHelpers.ResetTop(self)
            else
                lockSize.growVert = GROW_TO_BOTTOM
                LayoutHelpers.ResetBottom(self)
            end
        end

        self._lockSize = lockSize
        self._xMin = 0
        self._yMin = 0
        self._isEditable = false
        self._enableHitTest = true

        local texturekey = 'transparent'
        if textureTable then
            texturekey = prefID
            styles.backgrounds[prefID] = textureTable
        end

        -- WINDOW GROUP

        self._windowGroup = Group(self, 'window texture group')
        LayoutHelpers.FillParent(self._windowGroup, self)
        self._windowGroup:DisableHitTest()

        self._window_tl = Bitmap(self._windowGroup, styles.backgrounds[texturekey].tl)
        self._window_tr = Bitmap(self._windowGroup, styles.backgrounds[texturekey].tr)
        self._window_tm = Bitmap(self._windowGroup, styles.backgrounds[texturekey].tm)
        self._window_ml = Bitmap(self._windowGroup, styles.backgrounds[texturekey].ml)
        self._window_m  = Bitmap(self._windowGroup, styles.backgrounds[texturekey].m)
        self._window_mr = Bitmap(self._windowGroup, styles.backgrounds[texturekey].mr)
        self._window_bl = Bitmap(self._windowGroup, styles.backgrounds[texturekey].bl)
        self._window_bm = Bitmap(self._windowGroup, styles.backgrounds[texturekey].bm)
        self._window_br = Bitmap(self._windowGroup, styles.backgrounds[texturekey].br)

        self._window_tl.Top:Set(self.Top)
        self._window_tl.Left:Set(self.Left)
        LayoutHelpers.DepthUnderParent(self._window_tl, self._windowGroup)

        self._window_tr.Top:Set(self.Top)
        self._window_tr.Right:Set(self.Right)
        LayoutHelpers.DepthUnderParent(self._window_tr, self._windowGroup)

        self._window_bl.Bottom:Set(self.Bottom)
        self._window_bl.Left:Set(self.Left)
        LayoutHelpers.DepthUnderParent(self._window_bl, self._windowGroup)

        self._window_br.Bottom:Set(self.Bottom)
        self._window_br.Right:Set(self.Right)
        LayoutHelpers.DepthUnderParent(self._window_br, self._windowGroup)

        self._window_tm.Left:Set(self._window_tl.Right)
        self._window_tm.Right:Set(self._window_tr.Left)
        self._window_tm.Top:Set(self._window_tl.Top)
        LayoutHelpers.DepthUnderParent(self._window_tm, self._windowGroup)

        self._window_bm.Left:Set(self._window_bl.Right)
        self._window_bm.Right:Set(self._window_br.Left)
        self._window_bm.Top:Set(self._window_bl.Top)
        LayoutHelpers.DepthUnderParent(self._window_bm, self._windowGroup)

        self._window_ml.Left:Set(self._window_tl.Left)
        self._window_ml.Top:Set(self._window_tl.Bottom)
        self._window_ml.Bottom:Set(self._window_bl.Top)
        LayoutHelpers.DepthUnderParent(self._window_ml, self._windowGroup)

        self._window_mr.Right:Set(self._window_tr.Right)
        self._window_mr.Top:Set(self._window_tr.Bottom)
        self._window_mr.Bottom:Set(self._window_br.Top)
        LayoutHelpers.DepthUnderParent(self._window_mr, self._windowGroup)

        self._window_m.Top:Set(self._window_tm.Bottom)
        self._window_m.Left:Set(self._window_ml.Right)
        self._window_m.Right:Set(self._window_mr.Left)
        self._window_m.Bottom:Set(self._window_bm.Top)
        LayoutHelpers.DepthUnderParent(self._window_m, self._windowGroup)

        -- RESIZE GROUP

        self._resizeGroup = Group(self, 'window resize group')
        LayoutHelpers.FillParent(self._resizeGroup, self)
        LayoutHelpers.DepthOverParent(self._resizeGroup, self, 100)
        self._resizeGroup:DisableHitTest(true)

        self._resize_tl = Bitmap(self._resizeGroup)
        self._resize_tr = Bitmap(self._resizeGroup)
        self._resize_bl = Bitmap(self._resizeGroup)
        self._resize_br = Bitmap(self._resizeGroup)
        self._resize_tm = Bitmap(self._resizeGroup)
        self._resize_bm = Bitmap(self._resizeGroup)
        self._resize_ml = Bitmap(self._resizeGroup)
        self._resize_mr = Bitmap(self._resizeGroup)

        --Set alpha of resize controls to 0 so that they still get resize events, but are not seen

        self._resize_tl:SetAlpha(0)
        self._resize_tr:SetAlpha(0)
        self._resize_bl:SetAlpha(0)
        self._resize_br:SetAlpha(0)
        self._resize_tm:SetAlpha(0)
        self._resize_bm:SetAlpha(0)
        self._resize_ml:SetAlpha(0)
        self._resize_mr:SetAlpha(0)

        self._resize_tl.Height:Set(self._cornerSize)
        self._resize_tl.Width:Set(self._cornerSize)
        self._resize_tl.Top:Set(self.Top)
        self._resize_tl.Left:Set(self.Left)

        self._resize_tr.Height:Set(self._cornerSize)
        self._resize_tr.Width:Set(self._cornerSize)
        self._resize_tr.Top:Set(self.Top)
        self._resize_tr.Right:Set(self.Right)

        self._resize_bl.Height:Set(self._cornerSize)
        self._resize_bl.Width:Set(self._cornerSize)
        self._resize_bl.Bottom:Set(self.Bottom)
        self._resize_bl.Left:Set(self.Left)

        self._resize_br.Height:Set(self._cornerSize)
        self._resize_br.Width:Set(self._cornerSize)
        self._resize_br.Bottom:Set(self.Bottom)
        self._resize_br.Right:Set(self.Right)

        self._resize_tm.Height:Set(self._borderSize)
        self._resize_tm.Left:Set(self._resize_tl.Right)
        self._resize_tm.Right:Set(self._resize_tr.Left)
        self._resize_tm.Top:Set(self._resize_tl.Top)

        self._resize_bm.Height:Set(self._borderSize)
        self._resize_bm.Left:Set(self._resize_bl.Right)
        self._resize_bm.Right:Set(self._resize_br.Left)
        self._resize_bm.Top:Set(self._resize_bl.Top)

        self._resize_ml.Width:Set(self._borderSize)
        self._resize_ml.Left:Set(self._resize_tl.Left)
        self._resize_ml.Top:Set(self._resize_tl.Bottom)
        self._resize_ml.Bottom:Set(self._resize_bl.Top)

        self._resize_mr.Width:Set(self._borderSize)
        self._resize_mr.Right:Set(self._resize_tr.Right)
        self._resize_mr.Top:Set(self._resize_tr.Bottom)
        self._resize_mr.Bottom:Set(self._resize_br.Top)

        self._resize_tl:SetSolidColor(styles.backgrounds[texturekey].borderColor)
        self._resize_tr:SetSolidColor(styles.backgrounds[texturekey].borderColor)
        self._resize_bl:SetSolidColor(styles.backgrounds[texturekey].borderColor)
        self._resize_br:SetSolidColor(styles.backgrounds[texturekey].borderColor)
        self._resize_tm:SetSolidColor(styles.backgrounds[texturekey].borderColor)
        self._resize_bm:SetSolidColor(styles.backgrounds[texturekey].borderColor)
        self._resize_ml:SetSolidColor(styles.backgrounds[texturekey].borderColor)
        self._resize_mr:SetSolidColor(styles.backgrounds[texturekey].borderColor)

        self.StartSizing = function(event, xControl, yControl)
            local drag = Dragger()
            local x_max = true
            local y_max = true
            if event.MouseX < self._resize_tl.Right() then
                x_max = false
            end
            if event.MouseY < self._resize_tl.Bottom() then
                y_max = false
            end
            local parent = GetFrame(0)
            drag.OnMove = function(dragself, x, y)
                if xControl then
                    local newX
                    if x_max then
                        newX = math.min(math.max(x, self.Left() + self._xMin), parent.Right())
                        newX = math.max(newX, self.Left() + (2*self._window_tl.Width()))
                    else
                        newX = math.min(math.max(x, 0), self.Right() - self._xMin)
                    end
                    xControl:Set(newX)
                end
                if yControl then
                    local newY
                    if y_max then
                        newY = math.min(math.max(y, self.Top() + self._yMin), parent.Bottom())
                        newY = math.max(newY, self.Top() + self._window_bm.Height() + self._window_tm.Height())
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

                if self._lockSize then
                    self.Width:Set(self.Right() - self.Left())
                    self.Height:Set(self.Bottom() - self.Top())

                    if self._lockSize.growHorz == GROW_TO_LEFT then
                        LayoutHelpers.ResetLeft(self)
                    else
                        LayoutHelpers.ResetRight(self)
                    end

                    if self._lockSize.growVert == GROW_TO_TOP then
                        LayoutHelpers.ResetTop(self)
                    else
                        LayoutHelpers.ResetBottom(self)
                    end
                else
                    LayoutHelpers.ResetWidth(self)
                    LayoutHelpers.ResetHeight(self)
                end

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

        self._RolloverHandler = function(control, event, xControl, yControl, cursor, controlID)
--            LOG ("custom _RolloverHandler.controlID=" .. controlID ..", event.type=" .. event.Type)
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

        self._resize_br.HandleEvent = function(control, event)
            self._RolloverHandler(control, event, self.Right, self.Bottom, 'NW_SE', 'br')
        end
        self._resize_bl.HandleEvent = function(control, event)
            self._RolloverHandler(control, event, self.Left, self.Bottom, 'NE_SW', 'bl')
        end
        self._resize_bm.HandleEvent = function(control, event)
            self._RolloverHandler(control, event, nil, self.Bottom, 'N_S', 'bm')
        end
        self._resize_tr.HandleEvent = function(control, event)
            self._RolloverHandler(control, event, self.Right, self.Top, 'NE_SW', 'tr')
        end
        self._resize_tl.HandleEvent = function(control, event)
            self._RolloverHandler(control, event, self.Left, self.Top, 'NW_SE', 'tl')
        end
        self._resize_tm.HandleEvent = function(control, event)
            self._RolloverHandler(control, event, nil, self.Top, 'N_S', 'tm')
        end
        self._resize_mr.HandleEvent = function(control, event)
            self._RolloverHandler(control, event, self.Right, nil, 'W_E', 'mr')
        end
        self._resize_ml.HandleEvent = function(control, event)
            self._RolloverHandler(control, event, self.Left, nil, 'W_E', 'ml')
        end

        -- REPOSITION GROUP

        self._repositionGroup = Group(self, 'window reposition group')
        LayoutHelpers.Layouter(self._repositionGroup)
            :Top(self._resize_tm.Bottom)
            :Left(self._resize_ml.Right)
            :Height(function() return self._resize_bm.Top() - self._resize_tm.Bottom() end)
            :Width(function() return self._resize_mr.Left() - self._resize_ml.Right() end)
            :Right(self._resize_mr.Left)
            :Bottom(self._resize_bm.Top)
            :Over(self, 101)

        self._repositionGroup.HandleEvent = function(control, event)
--            LOG ("custom _repositionGroup.HandleEvent.event.Type=" .. event.Type)
            if not self._sizeLock then
                if event.Type == 'MouseEnter' then
                    GetCursor():SetTexture(styles.cursorFunc('MOVE_WINDOW'))
                elseif event.Type == 'MouseExit' then
                    GetCursor():Reset()
                elseif event.Type == 'ButtonPress' then
                    if self._lockPosition then return end
                    local drag = Dragger()
                    local offX = event.MouseX - self.Left()
                    local offY = event.MouseY - self.Top()
                    local height = self.Height()
                    local width = self.Width()
                    local parent = GetFrame(0)
                    drag.OnMove = function(dragself, x, y)
                        self.Left:Set(math.min(math.max(x-offX, parent.Left()), parent.Right() - self.Width()))
                        self.Top:Set(math.min(math.max(y-offY, parent.Top()), parent.Bottom() - self.Height()))
                        local tempRight = self.Left() + width
                        local tempBottom = self.Top() + height
                        self.Right:Set(tempRight)
                        self.Bottom:Set(tempBottom)
                        self:OnMove(x, y, not self._sizeLock)
                        if not self._sizeLock then
--                            GetCursor():SetTexture(styles.cursorFunc('MOVE_WINDOW'))
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
        end

        -- MISC
        self.HandleEvent = function(control, event)
            if event.Type == 'WheelRotation' then
                self:OnMouseWheel(event.WheelRotation)
            end
        end

        self.OnHide = function(control, hidden)
            control._resizeGroup:SetHidden(hidden)
            control:OnHideWindow(control, hidden)
        end

        -- attempt to retrieve location of window in preference file
        local groupid = Prefs.GetFromCurrentProfile("uigroup")
        local location = groupid[self._pref]
        if groupid and location then
            local top = location.top 
            local left = location.left 
            local width = location.width 
            local height = location.height 
            local growHorz = location.growHorz
            local growVert = location.growVert

            -- we can scale these accordingly as we applied the inverse on saving
            self.Left:Set(LayoutHelpers.ScaleNumber(left))
            self.Top:Set(LayoutHelpers.ScaleNumber(top))
            self.Width:Set(LayoutHelpers.ScaleNumber(width))
            self.Height:Set(LayoutHelpers.ScaleNumber(height))
            LayoutHelpers.ResetRight(self)
            LayoutHelpers.ResetBottom(self)

            if growHorz or growVert then
                if growHorz == GROW_TO_LEFT then
                    self.Right:Set(self.Left() + self.Width())
                    LayoutHelpers.ResetLeft(self)
                end
                if growVert == GROW_TO_TOP then
                    self.Bottom:Set(self.Top() + self.Height())
                    LayoutHelpers.ResetTop(self)
                end
                self._lockSize = { growHorz = growHorz, growVert = growVert }
            end
        elseif defaultPosition then
            -- call the provided function that sets all coords
            if defaultPosition.All then
                defaultPosition.All(self, parent)

            -- Scale only if it's a number, else it's already scaled lazyvar
            elseif type(defaultPosition.Left) == 'number' then
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
--        WARN("SetAlpha pref=" .. self._pref .. ", alpha=" .. tostring(alpha) .. ", affectChildren=" .. tostring(affectChildren) .. ", _SetAlpha=" .. tostring(self._SetAlpha))
        affectChildren = affectChildren or false
        Group.SetAlpha(self, alpha, false)

        if affectChildren then
            -- Workaround for Group.SetAlpha() NOT calling an overriden SetAlpha() function on children?!
            -- Group.SetAlpha(self, alpha, affectChildren)
            if self._SetAlpha then return end
            self._SetAlpha = true
            Group.ApplyFunction(self, function(control) control:SetAlpha(alpha, affectChildren) end)
            self._SetAlpha = false
        end

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
--            LOG("custom SaveWindowLocation " .. tostring(self.Left()) .. "x" .. tostring(self.Top()) .. " of window '" .. self._pref .. "'")
            local groupid = Prefs.GetFromCurrentProfile("uigroup") or {}
            local settings = {
                -- invert the scale on these numbers, that allows us to apply the scale again when we read it from the preference file
                left = LayoutHelpers.InvScaleNumber(self.Left()),
                top = LayoutHelpers.InvScaleNumber(self.Top()),
                width = LayoutHelpers.InvScaleNumber(self.Width()),
                height = LayoutHelpers.InvScaleNumber(self.Height())
            }
            if self._lockSize then
                settings["growHorz"] = self._lockSize.growHorz
                settings["growVert"] = self._lockSize.growVert
            end
            groupid[self._pref] = settings
            Prefs.SetToCurrentProfile("uigroup", groupid)
        end
    end,

    ApplyWindowTextures = function(self, textures)
        self._window_tl:SetTexture(textures.tl)
        self._window_tr:SetTexture(textures.tr)
        self._window_tm:SetTexture(textures.tm)
        self._window_ml:SetTexture(textures.ml)
        self._window_m:SetTexture(textures.m)
        self._window_mr:SetTexture(textures.mr)
        self._window_bl:SetTexture(textures.bl)
        self._window_bm:SetTexture(textures.bm)
        self._window_br:SetTexture(textures.br)
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

    SetTexture = function(self, texture)
        self._window_m:SetTexture(texture)
        self.Width:SetFunction(function() return ScaleNumber(self._window_m.BitmapWidth()) end)
        self.Height:SetFunction(function() return ScaleNumber(self._window_m.BitmapHeight()) end)
    end,

    SetEditable = function(self, isEditable)
--        self._sizeLock = not isEditable
        self._isEditable = isEditable

        if isEditable then
            if not self._lockSize then
                self._resizeGroup:EnableHitTest(true)
                self._resizeGroup:DisableHitTest(false)
                self._resizeGroup:Show()
            end
            if not self._lockPosition then
                self._repositionGroup:EnableHitTest(true)
                self._repositionGroup:Show()
            end
        else
            self._resizeGroup:DisableHitTest(true)
            self._repositionGroup:DisableHitTest(true)

            self._resizeGroup:Hide()
            self._repositionGroup:Hide()
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
