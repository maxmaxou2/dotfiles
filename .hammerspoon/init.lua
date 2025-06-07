hs.loadSpoon("ReloadConfiguration"):start()
hs.loadSpoon("AppKeybindings"):init()
hs.loadSpoon("AppPositions"):init()
hs.loadSpoon("GraphicalKeyLogger"):init()

-- Make app fullscreen
hs.hotkey.bind({"ctrl", "cmd"}, "F", function()
    local win = hs.window.focusedWindow()
    if not win then return end
    local screen = win:screen():frame()
    win:setFrame(screen)
end)

hs.alert.show("Hammerspoon config loaded")
