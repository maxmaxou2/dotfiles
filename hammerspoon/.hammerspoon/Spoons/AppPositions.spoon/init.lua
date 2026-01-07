local obj = {}
obj.__index = obj

-- Metadata
obj.name = "AppKeybindings"
obj.version = "2.0"
obj.author = "Maxence"
obj.license = "MIT"

-- On utilise hs.settings pour que les positions soient sauvegardées même après redémarrage
local settings = hs.settings

function obj:init()
    --------------------------------------------------------------------------------
    -- 1. FONCTIONS UTILITAIRES
    --------------------------------------------------------------------------------
    
    local function getScreenId(screen)
        if not screen then return nil end
        return screen:getUUID() or screen:name()
    end

    -- Sauvegarde la position d'une application
    local function saveWindowScreen(appName, screen)
        if not appName or not screen then return end
        
        -- On charge la table existante, ou on en crée une vide
        local savedMap = settings.get("savedWindowScreens") or {}
        
        -- On met à jour
        savedMap[appName] = getScreenId(screen)
        
        -- On sauvegarde dans les settings persistants
        settings.set("savedWindowScreens", savedMap)
        -- print("Position sauvegardée pour : " .. appName .. " sur " .. screen:name()) -- Décommenter pour debug
    end

    -- Récupère l'écran sauvegardé pour une app
    local function getSavedScreen(appName)
        local savedMap = settings.get("savedWindowScreens") or {}
        local screenId = savedMap[appName]
        
        if not screenId then return nil end

        -- On cherche l'écran qui correspond à l'ID sauvegardé
        for _, screen in ipairs(hs.screen.allScreens()) do
            if getScreenId(screen) == screenId then
                return screen
            end
        end
        return nil -- L'écran sauvegardé n'est pas connecté actuellement
    end

    -- Fonction principale pour restaurer les positions
    local function restorePositions()
        -- print("Tentative de restauration des fenêtres...")
        for _, win in ipairs(hs.window.allWindows()) do
            local app = win:application()
            if app then
                local appName = app:name()
                local savedScreen = getSavedScreen(appName)
                local currentScreen = win:screen()

                -- Si on connait l'écran cible, qu'il est différent de l'actuel, et qu'il existe
                if savedScreen and currentScreen and (currentScreen:id() ~= savedScreen:id()) then
                    win:moveToScreen(savedScreen)
                    win:maximize() -- On maximise comme demandé
                end
            end
        end
    end

    --------------------------------------------------------------------------------
    -- 2. DÉCLENCHEURS (WATCHERS)
    --------------------------------------------------------------------------------

    -- A. Raccourci Manuel (Gardé de ton script original)
    hs.hotkey.bind({ "ctrl", "cmd" }, "M", function()
        local win = hs.window.focusedWindow()
        if not win then return end

        local nextScreen = win:screen():next()
        win:moveToScreen(nextScreen)
        win:maximize()

        local appName = win:application():name()
        saveWindowScreen(appName, nextScreen)
        hs.alert.show("Écran sauvegardé pour " .. appName)
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

    -- B. Sauvegarde Automatique quand l'utilisateur touche une fenêtre
    -- Cela permet de mémoriser où tu mets tes fenêtres sans faire Cmd+Ctrl+M
    self.windowFilter = hs.window.filter.new():setDefaultFilter()
    self.windowFilter:subscribe(hs.window.filter.windowFocused, function(win)
        if win then
            saveWindowScreen(win:application():name(), win:screen())
        end
    end)

    -- C. Gestion des Écrans (Débranchement / Rebranchement)
    self.screenWatcher = hs.screen.watcher.new(function()
        -- Le délai de 3 secondes est CRUCIAL. macOS met du temps à initialiser les écrans.
        hs.timer.doAfter(3, restorePositions)
    end):start()

    -- D. Gestion de la Veille (Sleep / Wake)
    self.caffeinateWatcher = hs.caffeinate.watcher.new(function(eventType)
        if (eventType == hs.caffeinate.watcher.systemDidWake) then
            -- Attendre que le mac se réveille complètement et reconnecte les écrans.
            -- On lance deux fois, car parfois la fenêtre principale n'est pas restaurée du premier coup.
            hs.timer.doAfter(2, restorePositions)
            hs.timer.doAfter(4, restorePositions)
        end
    end):start()

end

return obj
