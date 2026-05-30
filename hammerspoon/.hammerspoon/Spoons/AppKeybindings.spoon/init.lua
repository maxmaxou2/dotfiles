local obj = {}
obj.__index = obj

-- Metadata
obj.name = "AppKeybindings"
obj.version = "1.2"
obj.author = "Maxence"
obj.homepage = ""
obj.license = "MIT - https://opensource.org/licenses/MIT"

local ALERTER = "/opt/homebrew/bin/alerter"

-- Bundle IDs
local VSCODE_BUNDLE = "com.microsoft.VSCode"
local GHOSTTY_BUNDLE = "com.mitchellh.ghostty"
local MAIL_BUNDLE = "com.apple.mail"

-- Pair definitions
local PAIRS = {}

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
			-- 1. Clear terminal-notifier alerts when Ghostty gets focus
            if bid == GHOSTTY_BUNDLE then
                hs.task.new(ALERTER, nil, {"--remove", "stay-alert"}):start()
            end
			-- 2. Handle pair tracking
			local key = bundleToKey[bid]
			if key then
				setLastFocused(key, bid)
			end
		end
	end)
	self.appWatcher:start()

	local function cycleObsidian()
		local bundleID = "md.obsidian"
		local app = hs.application.get(bundleID)

		if not app then
			hs.application.launchOrFocusByBundleID(bundleID)
			return
		end

		if not app:isFrontmost() then
			app:activate()
			return
		end

		-- Cycle windows if app is already active
		local windows = app:allWindows()
		local standardWindows = {}

		-- Filter for actual vault windows (ignore settings/popups)
		for _, win in ipairs(windows) do
			if win:isStandard() and win:isVisible() then
				table.insert(standardWindows, win)
			end
		end

		if #standardWindows > 1 then
			-- Focusing the last window in Z-order brings it to the front,
			-- effectively rotating the stack.
			standardWindows[#standardWindows]:focus()
		end
	end

	-- Hotkeys ---------------------------------------------------------------
	-- Single-app quick launchers (your existing ones)
	local singleHotkeys = {
		["p"] = { name = "Finder" },
		["o"] = { action = cycleObsidian },
		["w"] = { name = "Whatsapp" },
		["s"] = { name = "Spotify" },
		["d"] = { name = "Discord" },
		["r"] = { name = "Strawberry" },
		["c"] = { name = "Google Chrome" },
		["t"] = { bundleID = GHOSTTY_BUNDLE },
		["v"] = { bundleID = VSCODE_BUNDLE },
		["m"] = { name = "CapCut" },
		["n"] = { bundleID = MAIL_BUNDLE },
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
