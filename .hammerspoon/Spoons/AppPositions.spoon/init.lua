local obj = {}
obj.__index = obj

-- Metadata
obj.name = "AppKeybindings"
obj.version = "1.0"
obj.author = "Maxence"
obj.homepage = ""
obj.license = "MIT - https://opensource.org/licenses/MIT"

function obj:init()
    -- Autosave the position of apps
    local savedWindowScreens = {}

    local function getScreenId(screen)
        return screen:getUUID() or screen:name()
    end

    local function saveWindowScreen(appName, screen)
        savedWindowScreens[appName] = getScreenId(screen)
    end

    local function getSavedScreen(appName)
        local screenId = savedWindowScreens[appName]
        if not screenId then return nil end

        for _, screen in ipairs(hs.screen.allScreens()) do
            if getScreenId(screen) == screenId then
                return screen
            end
        end

        return nil
    end

    hs.hotkey.bind({ "ctrl", "cmd" }, "M", function()
        local win = hs.window.focusedWindow()
        if not win then return end

        local nextScreen = win:screen():next()
        win:moveToScreen(nextScreen)
        win:maximize()

        local appName = win:application():name()
        saveWindowScreen(appName, nextScreen)
    end)

    hs.screen.watcher.new(function()
        for _, win in ipairs(hs.window.allWindows()) do
            local appName = win:application():name()
            local savedScreen = getSavedScreen(appName)

            if savedScreen and win:screen() ~= savedScreen then
                win:moveToScreen(savedScreen)
                win:maximize()
            end
        end
    end):start()
end

return obj
