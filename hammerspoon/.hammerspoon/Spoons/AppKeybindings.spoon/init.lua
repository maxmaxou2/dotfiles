local obj = {}
obj.__index = obj

-- Metadata
obj.name = "AppKeybindings"
obj.version = "1.1"
obj.author = "Maxence"
obj.homepage = ""
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Bundle IDs
local VSCODE_BUNDLE  = "com.microsoft.VSCode"       -- use "com.microsoft.VSCodeInsiders" if needed
local GHOSTTY_BUNDLE = "com.mitchellh.ghostty"
local MAIL_BUNDLE  = "com.apple.mail"       -- use "com.microsoft.VSCodeInsiders" if needed
local CALENDAR_BUNDLE = "com.apple.iCal"

-- Key used to persist last-focused choice between the pair
local LAST_FOCUS_KEY = "AppKeybindings.lastFocusedVSCodeOrGhostty"

function obj:init()
  ---------------------------------------------------------------------------
  -- Track which of the pair was most recently focused (and persist it)
  ---------------------------------------------------------------------------
  local function setLastFocused(bundle)
    self.lastFocusedPair = bundle
    hs.settings.set(LAST_FOCUS_KEY, bundle)
  end

  -- Load persisted value (fallback to Ghostty if none yet)
  self.lastFocusedPair = hs.settings.get(LAST_FOCUS_KEY) or GHOSTTY_BUNDLE

  -- Watch app activations to keep last-focused in sync
  self.appWatcher = hs.application.watcher.new(function(appName, event, app)
    if event == hs.application.watcher.activated and app then
      local bid = app:bundleID()
      if bid == VSCODE_BUNDLE or bid == GHOSTTY_BUNDLE then
        setLastFocused(bid)
      end
    end
  end)
  self.appWatcher:start()

  ---------------------------------------------------------------------------
  -- Hotkeys
  ---------------------------------------------------------------------------
  local appHotkeys = {
    ["8"] = { name = "Slack" },
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
          hs.application.launchOrFocusByBundleID(ankamaBundle)
        elseif dofusApp then
          dofusApp:activate()
        else
          hs.application.launchOrFocusByBundleID(ankamaBundle)
        end
      end,
    },

    -- ctrl+cmd+7 — switch between Calendar and Mail
    ["7"] = {
      action = function()
        local frontApp = hs.application.frontmostApplication()
        local frontBid = frontApp and frontApp:bundleID() or nil

        local mailApp  = hs.application.find(MAIL_BUNDLE)
        local calendarApp  = hs.application.find(CALENDAR_BUNDLE)

        -- If one of the pair is focused, toggle to the other
        if frontBid == MAIL_BUNDLE then
          hs.application.launchOrFocusByBundleID(CALENDAR_BUNDLE)
          setLastFocused(CALENDAR_BUNDLE)
          return
        elseif frontBid == CALENDAR_BUNDLE then
          hs.application.launchOrFocusByBundleID(MAIL_BUNDLE)
          setLastFocused(MAIL_BUNDLE)
          return
        end

        -- Neither is focused:
        -- - If both are running, focus whichever was last focused (persisted)
        -- - If only one is running, focus that
        -- - If neither is running, launch the last-focused choice
        if mailApp and calendarApp then
          local target = (self.lastFocusedPair == MAIL_BUNDLE) and MAIL_BUNDLE or CALENDAR_BUNDLE
          hs.application.launchOrFocusByBundleID(target)
          setLastFocused(target)
        elseif calendarApp then
          calendarApp:activate()
          setLastFocused(CALENDAR_BUNDLE)
        elseif mailApp then
          mailApp:activate()
          setLastFocused(MAIL_BUNDLE)
        else
          local target = self.lastFocusedPair or CALENDAR_BUNDLE
          hs.application.launchOrFocusByBundleID(target)
          setLastFocused(target)
        end
      end,
    },

    -- ctrl+cmd+0 — switch between VS Code and Ghostty
    ["0"] = {
      action = function()
        local frontApp = hs.application.frontmostApplication()
        local frontBid = frontApp and frontApp:bundleID() or nil

        local vsApp  = hs.application.find(VSCODE_BUNDLE)
        local ghApp  = hs.application.find(GHOSTTY_BUNDLE)

        -- If one of the pair is focused, toggle to the other
        if frontBid == VSCODE_BUNDLE then
          hs.application.launchOrFocusByBundleID(GHOSTTY_BUNDLE)
          setLastFocused(GHOSTTY_BUNDLE)
          return
        elseif frontBid == GHOSTTY_BUNDLE then
          hs.application.launchOrFocusByBundleID(VSCODE_BUNDLE)
          setLastFocused(VSCODE_BUNDLE)
          return
        end

        -- Neither is focused:
        -- - If both are running, focus whichever was last focused (persisted)
        -- - If only one is running, focus that
        -- - If neither is running, launch the last-focused choice
        if vsApp and ghApp then
          local target = (self.lastFocusedPair == VSCODE_BUNDLE) and VSCODE_BUNDLE or GHOSTTY_BUNDLE
          hs.application.launchOrFocusByBundleID(target)
          setLastFocused(target)
        elseif ghApp then
          ghApp:activate()
          setLastFocused(GHOSTTY_BUNDLE)
        elseif vsApp then
          vsApp:activate()
          setLastFocused(VSCODE_BUNDLE)
        else
          local target = self.lastFocusedPair or GHOSTTY_BUNDLE
          hs.application.launchOrFocusByBundleID(target)
          setLastFocused(target)
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
