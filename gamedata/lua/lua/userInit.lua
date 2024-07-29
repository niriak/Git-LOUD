-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
--
-- This is the user-specific top-level lua initialization file. It is run at initialization time
-- to set up all lua state for the user layer.

-- Init our language from prefs. This applies to both front-end and session init; for
-- the Sim init, the engine sets __language for us.

LOG("*DEBUG UserInit")

__language = GetPreference('options_overrides.language', '')
-- Build language select options
__installedlanguages = DiskFindFiles("/loc/", '*strings_db.lua')
for index, language in __installedlanguages do
    language = string.upper(string.gsub(language, ".*/(.*)/.*", "%1"))
    __installedlanguages[index] = { text = language, key = language }
end

-- load global functions
doscript '/lua/globalInit.lua'

-- Do we have an custom language set inside user-options ?
local selectedlanguage = import("/lua/user/prefs.lua").GetFromCurrentProfile('options').selectedlanguage
if selectedlanguage ~= nil then
    __language = selectedlanguage
    SetPreference('options_overrides.language', __language)
    doscript '/lua/system/Localization.lua'
end

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


LOG("*DEBUG UserInit complete")

