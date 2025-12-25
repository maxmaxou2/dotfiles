local obj = {}
obj.__index = obj

-- Metadata
obj.name = "AppKeybindings"
obj.version = "1.2"
obj.author = "Maxence"
obj.homepage = ""
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Bundle IDs
local VSCODE_BUNDLE = "com.microsoft.VSCode"
local GHOSTTY_BUNDLE = "com.mitchellh.ghostty"
local MAIL_BUNDLE = "com.apple.mail"
local CALENDAR_BUNDLE = "com.apple.iCal"

-- Pair definitions
local PAIRS = {
	vscode_ghostty = {
		a = { name = "VS Code", bundle = VSCODE_BUNDLE },
		b = { name = "Ghostty", bundle = GHOSTTY_BUNDLE },
		settingsKey = "AppKeybindings.lastFocused.vscode_ghostty",
		hotkey = "0",
	},
	mail_calendar = {
		a = { name = "Mail", bundle = MAIL_BUNDLE },
		b = { name = "Calendar", bundle = CALENDAR_BUNDLE },
		settingsKey = "AppKeybindings.lastFocused.mail_calendar",
		hotkey = "7",
	},
}

-- Helpers
local function getLastFocused(settingsKey, defaultBundle)
	return hs.settings.get(settingsKey) or defaultBundle
end

local function setLastFocused(settingsKey, bundle)
	hs.settings.set(settingsKey, bundle)
end

local function isFrontmostBundle(bundle)
	local frontApp = hs.application.frontmostApplication()
	return frontApp and frontApp:bundleID() == bundle
end

local function appIsRunning(bundle)
	return hs.application.get(bundle) ~= nil
end

local function focusBundle(bundle)
	hs.application.launchOrFocusByBundleID(bundle)
end

local function togglePair(pair)
	local A = pair.a.bundle
	local B = pair.b.bundle
	local key = pair.settingsKey

	if isFrontmostBundle(A) then
		focusBundle(B)
		setLastFocused(key, B)
		return
	elseif isFrontmostBundle(B) then
		focusBundle(A)
		setLastFocused(key, A)
		return
	end

	local aRunning = appIsRunning(A)
	local bRunning = appIsRunning(B)

	if aRunning and bRunning then
		local target = getLastFocused(key, A)
		focusBundle(target)
		setLastFocused(key, target)
	elseif aRunning then
		focusBundle(A)
		setLastFocused(key, A)
	elseif bRunning then
		focusBundle(B)
		setLastFocused(key, B)
	else
		local target = getLastFocused(key, A)
		focusBundle(target)
		setLastFocused(key, target)
	end
end

-- Build a lookup: bundleID -> settingsKey for watcher updates
local function buildBundleToKeyMap()
	local map = {}
	for _, pair in pairs(PAIRS) do
		map[pair.a.bundle] = pair.settingsKey
		map[pair.b.bundle] = pair.settingsKey
	end
	return map
end

function obj:init()
	-- App watcher to update the proper pair's last-focused on activation
	local bundleToKey = buildBundleToKeyMap()

	self.appWatcher = hs.application.watcher.new(function(appName, event, app)
		if event == hs.application.watcher.activated and app then
			local bid = app:bundleID()
			local key = bundleToKey[bid]
			if key then
				setLastFocused(key, bid)
			end
		end
	end)
	self.appWatcher:start()

	-- Hotkeys ---------------------------------------------------------------
	-- Single-app quick launchers (your existing ones)
	local singleHotkeys = {
		["8"] = { name = "TickTick" },
		["6"] = { name = "Slack" },
		["]"] = { name = "Whatsapp" },
		["-"] = { name = "Spotify" },
		["="] = { name = "Notion" },
		["9"] = { name = "Brave Browser" },
		["\\"] = { name = "Discord" },
		-- ["'"] = { -- Toggle between Dofus and Ankama Launcher
		-- 	action = function()
		-- 		local ankamaBundle = "com.ankama.zaap"
		-- 		local dofusBundle = "com.Ankama.Dofus"
		-- 		local frontApp = hs.application.frontmostApplication()
		-- 		local frontBid = frontApp and frontApp:bundleID()
		--
		-- 		if frontBid == dofusBundle then
		-- 			hs.application.launchOrFocusByBundleID(ankamaBundle)
		-- 		elseif hs.application.get(dofusBundle) then
		-- 			hs.application.get(dofusBundle):activate()
		-- 		else
		-- 			hs.application.launchOrFocusByBundleID(ankamaBundle)
		-- 		end
		-- 	end,
		-- },
		["'"] = {
			action = function()
				local app = hs.application.get("java")

				if app then
					-- Method 1: Try to find the specific window and focus it
					-- Java apps often have invisible helper windows, so we look for one with "Minecraft" in the title
					local found = false
					for _, win in pairs(app:allWindows()) do
						-- Check for "Minecraft" in title OR if it's a standard window
						if string.find(win:title(), "Minecraft") or win:isStandard() then
							win:raise() -- Bring layer to front
							win:focus() -- Force switch to its Space
							found = true
							break
						end
					end

					-- Fallback: If we couldn't find a specific window, force activate the app
					if not found then
						app:activate(true) -- 'true' attempts to force the OS to switch
					end
				else
					hs.application.launchOrFocusByBundleID("org.prismlauncher.PrismLauncher")
				end
			end,
		},
	}

	-- Bind single-app hotkeys
	for key, spec in pairs(singleHotkeys) do
		hs.hotkey.bind({ "ctrl", "cmd" }, key, function()
			if spec.action then
				spec.action()
			elseif spec.bundleID then
				hs.application.launchOrFocusByBundleID(spec.bundleID)
			else
				hs.application.launchOrFocus(spec.name)
			end
		end)
	end

	-- Bind pair toggles from the PAIRS table
	for _, pair in pairs(PAIRS) do
		hs.hotkey.bind({ "ctrl", "cmd" }, pair.hotkey, function()
			togglePair(pair)
		end)
	end
end

return obj
