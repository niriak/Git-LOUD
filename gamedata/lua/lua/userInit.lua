-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
--
-- This is the user-specific top-level lua initialization file. It is run at initialization time
-- to set up all lua state for the user layer.

-- Init our language from prefs. This applies to both front-end and session init; for
-- the Sim init, the engine sets __language for us.

LOG("*DEBUG UserInit")

__language = GetPreference('options_overrides.language', '')


-- load global functions
doscript '/lua/globalInit.lua'

WaitFrames = coroutine.yield

function WaitSeconds(n)
    local later = CurrentTime() + n
    WaitFrames(1)
    while CurrentTime() < later do
        WaitFrames(1)
    end
end

function PrintText(textData)
    if textData then
        local data = textData
        if type(textData) == 'string' then
            data = {text = textData, size = 14, color = 'ffffffff', duration = 5, location = 'center'}
        end
        import('/lua/ui/game/textdisplay.lua').PrintToScreen(data)
    end
end

-- lets see what this causes

AnyInputCapture = nil
AITarget = nil

DisplayAchievementScreen = nil

OpenURL = nil

PlayTutorialVO = nil

SetMovieVolume = nil
SaveOnlineAchievements = nil
SetOnlineAchievement = nil


-- a table designed to allow communication from different user states to the front end lua state
FrontEndData = {}

-- Prefetch user side data
Prefetcher = CreatePrefetchSet()

do
    ---@alias UIBuildQueue UIBuildQueueItem[]

    ---@class UIBuildQueueItem
    ---@field count number
    ---@field id UnitId

    ---@type UserUnit | nil
    local buildQueueOfUnit = nil

    ---@type UIBuildQueue
    local buildQueue = {}

    local OldClearCurrentFactoryForQueueDisplay = _G.ClearCurrentFactoryForQueueDisplay
    local OldSetCurrentFactoryForQueueDisplay = _G.SetCurrentFactoryForQueueDisplay
    local OldDecreaseBuildCountInQueue = _G.DecreaseBuildCountInQueue
    local OldIncreaseBuildCountInQueue = _G.IncreaseBuildCountInQueue

    --- Clears the current build queue
    ---@see DecreaseBuildCountInQueue           # To decrease the build count in the queue
    ---@see IncreaseBuildCountInQueue           # To increase the build count in the queue
    ---@see SetCurrentFactoryForQueueDisplay    # To set the current queue
    ---@see GetCurrentFactoryForQueueDisplay    # To get the current queue
    ---@see ClearCurrentFactoryForQueueDisplay  # To clear the current queue
    _G.ClearCurrentFactoryForQueueDisplay = function()
        buildQueueOfUnit = nil
        buildQueue = {}
        OldClearCurrentFactoryForQueueDisplay()
    end

    --- Defines the current build queue
    ---@see DecreaseBuildCountInQueue           # To decrease the build count in the queue
    ---@see IncreaseBuildCountInQueue           # To increase the build count in the queue
    ---@see SetCurrentFactoryForQueueDisplay    # To set the current queue
    ---@see GetCurrentFactoryForQueueDisplay    # To get the current queue
    ---@see ClearCurrentFactoryForQueueDisplay  # To clear the current queue
    ---@param userUnit UserUnit
    ---@return UIBuildQueue
    _G.SetCurrentFactoryForQueueDisplay = function(userUnit)
        buildQueueOfUnit = userUnit
        buildQueue = OldSetCurrentFactoryForQueueDisplay(userUnit)
        return buildQueue
    end

    --- Retrieve the build queue without changing the global state
    ---@see DecreaseBuildCountInQueue           # To decrease the build count in the queue
    ---@see IncreaseBuildCountInQueue           # To increase the build count in the queue
    ---@see SetCurrentFactoryForQueueDisplay    # To set the current queue
    ---@see GetCurrentFactoryForQueueDisplay    # To get the current queue
    ---@see ClearCurrentFactoryForQueueDisplay  # To clear the current queue
    ---@param userUnit UserUnit
    ---@return UIBuildQueue
    _G.PeekCurrentFactoryForQueueDisplay = function(userUnit)
        if IsDestroyed(userUnit) then
            return {}
        end

        local oldBuildQueueOfUnit = buildQueueOfUnit
        local queue = SetCurrentFactoryForQueueDisplay(userUnit)

        if oldBuildQueueOfUnit then
            SetCurrentFactoryForQueueDisplay(oldBuildQueueOfUnit)
        else
            ClearCurrentFactoryForQueueDisplay()
        end

        return queue
    end

    --- Update the current command queue. Does not update the internal state of the engine - do not use directly!
    ---@see DecreaseBuildCountInQueue           # To decrease the build count in the queue
    ---@see IncreaseBuildCountInQueue           # To increase the build count in the queue
    ---@see SetCurrentFactoryForQueueDisplay    # To set the current queue
    ---@see GetCurrentFactoryForQueueDisplay    # To get the current queue
    ---@see ClearCurrentFactoryForQueueDisplay  # To clear the current queue
    ---@param queue UIBuildQueue
    _G.UpdateCurrentFactoryForQueueDisplay = function(queue)
        buildQueue = queue
    end

    --- Retrieves the current build queue
    ---@see DecreaseBuildCountInQueue           # To decrease the build count in the queue
    ---@see IncreaseBuildCountInQueue           # To increase the build count in the queue
    ---@see SetCurrentFactoryForQueueDisplay    # To set the current queue
    ---@see GetCurrentFactoryForQueueDisplay    # To get the current queue
    ---@see ClearCurrentFactoryForQueueDisplay  # To clear the current queue
    ---@return UIBuildQueue[]
    _G.GetCurrentFactoryForQueueDisplay = function()
        return buildQueue
    end

    --- Decrease the count at a given location of the current build queue
    ---@see DecreaseBuildCountInQueue           # To decrease the build count in the queue
    ---@see IncreaseBuildCountInQueue           # To increase the build count in the queue
    ---@see SetCurrentFactoryForQueueDisplay    # To set the current queue
    ---@see GetCurrentFactoryForQueueDisplay    # To get the current queue
    ---@see ClearCurrentFactoryForQueueDisplay  # To clear the current queue
    ---@param index number
    ---@param count number
    _G.DecreaseBuildCountInQueue = function(index, count)
        if not buildQueueOfUnit then
            WARN("Unable to decrease build queue count when no build queue is set")
            return
        end

        if table.empty(buildQueue) then
            WARN("Unable to decrease build queue is empty")
            return
        end

        if index < 1 then
            WARN("Unable to decrease build queue count when index is smaller than 1")
            return
        end

        if index > table.getn(buildQueue) then
            WARN("Unable to decrease build queue count when queue index is larger than the elements in the queue")
            return
        end

        return OldDecreaseBuildCountInQueue(index, count)
    end

    --- Increase the count at a given location of the current build queue
    ---@see DecreaseBuildCountInQueue           # To decrease the build count in the queue
    ---@see IncreaseBuildCountInQueue           # To increase the build count in the queue
    ---@see SetCurrentFactoryForQueueDisplay    # To set the current queue
    ---@see GetCurrentFactoryForQueueDisplay    # To get the current queue
    ---@see ClearCurrentFactoryForQueueDisplay  # To clear the current queue
    ---@param index number
    ---@param count number
    _G.IncreaseBuildCountInQueue = function(index, count)
        if not buildQueueOfUnit then
            WARN("Unable to increase build queue count when no build queue is set")
            return
        end

        if table.empty(buildQueue) then
            WARN("Unable to increase build queue is empty")
            return
        end

        if table.empty(buildQueue) then
            WARN("Unable to increase build queue count when no build queue is set")
            return
        end

        if index < 1 then
            WARN("Unable to increase build queue count when index is smaller than 1")
            return
        end

        if index > table.getn(buildQueue) then
            WARN("Unable to increase build queue count when queue index is larger than the elements in the queue")
            return
        end

        return OldIncreaseBuildCountInQueue(index, count)
    end
end

LOG("*DEBUG UserInit complete")
