local obj = {}
obj.__index = obj

-- Metadata
obj.name = "AppPositions"
obj.version = "3.0"
obj.author = "Maxence"
obj.license = "MIT"

function obj:init()
    -- Déplace la fenêtre active sur l'écran suivant
    hs.hotkey.bind({ "ctrl", "cmd" }, "M", function()
        local win = hs.window.focusedWindow()
        if not win then return end

        win:moveToScreen(win:screen():next())
        win:maximize()
    end)

    -- Make app fullscreen
    hs.hotkey.bind({"ctrl", "cmd"}, "F", function()
        local win = hs.window.focusedWindow()
        if not win then return end

        -- Reduce window size first to handle cases where it's "stuck" being too large
        win:setSize({w = 100, h = 100})

        -- Then set it to fullscreen
        local screen = win:screen():frame()
        win:setFrame(screen)
    end)
end

return obj
