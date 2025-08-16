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
		["0"] = { name = "Ghostty" },
		["8"] = { name = "Slack" },
		["7"] = { name = "Mail" },
		["]"] = { name = "Whatsapp" },
		["-"] = { name = "Spotify" },
		["="] = { name = "Notion" },
		["9"] = { name = "Brave Browser" },
		["\\"] = { name = "Discord" },

		-- Toggle between Dofus and Ankama Launcher
		["'"] = {
			action = function()
				local ankamaBundle = "com.ankama.zaap"
				local dofusBundle = "com.Ankama.Dofus"

				local frontApp = hs.application.frontmostApplication()
				local dofusApp = hs.application.find(dofusBundle)

				if frontApp and frontApp:bundleID() == dofusBundle then
					-- Already in Dofus → switch to Ankama Launcher
					hs.application.launchOrFocusByBundleID(ankamaBundle)
				elseif dofusApp then
					-- Dofus is running but not focused → focus it
					dofusApp:activate()
				else
					-- Dofus not running → open Ankama Launcher
					hs.application.launchOrFocusByBundleID(ankamaBundle)
				end
			end,
		},
	}

	for key, app in pairs(appHotkeys) do
		hs.hotkey.bind({ "ctrl", "cmd" }, key, function()
			if app.action then
				app.action()
			elseif app.bundleID then
				hs.application.launchOrFocusByBundleID(app.bundleID)
			else
				hs.application.launchOrFocus(app.name)
			end
		end)
	end
end

return obj
