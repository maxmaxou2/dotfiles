local obj = {}
obj.__index = obj

-- Metadata
obj.name = "AppKeybindings"
obj.version = "1.0"
obj.author = "Maxence"
obj.homepage = ""
obj.license = "MIT - https://opensource.org/licenses/MIT"

function obj:init()
    local appHotkeys = {
        ["0"] = "Ghostty",
        ["8"] = "Slack",
        ["-"] = "Spotify",
        ["="] = "Notion",
        ["9"] = "Brave Browser",
        ["\\"] = "Karabiner-Elements",
    }

    for key, app in pairs(appHotkeys) do
        hs.hotkey.bind({"ctrl", "cmd"}, key, function()
            hs.application.launchOrFocus(app)
        end)
    end
end

return obj

