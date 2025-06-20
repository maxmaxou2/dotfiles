local obj = {}
obj.__index = obj

-- Metadata
obj.name = "GraphicalKeyLogger"
obj.version = "1.0"
obj.author = "Maxence"
obj.homepage = ""
obj.license = "MIT - https://opensource.org/licenses/MIT"

function obj:init()
    -- Output buffer size and positions to cycle through
    local OUTPUT_SIZE = 30
    local positions = {
        { x = 0, y = 0, w = 0, h = 0 },
        { x = 1, y = 0, w = 1, h = 0 },
        { x = 1, y = 1, w = 1, h = 0.25 },
        { x = 0, y = 1, w = 0, h = 0.25 },
    }

    local showingKeys = false
    local displayCanvas = nil
    local output = ""
    local CHAR_W = 17
    local CHAR_H = 30
    local OFFSET = 10
    local BOX_SIZE = (OUTPUT_SIZE+1) * CHAR_W
    local BOX_HEIGHT = CHAR_H + OFFSET * 2

    local function updateDisplay(text)
        if displayCanvas then
            displayCanvas:replaceElements({
                {
                    type = "rectangle",
                    id = "background",
                    frame = { x = 0, y = 0, w = BOX_SIZE, h = BOX_HEIGHT },
                    action = "fill",
                    fillColor = { red = 0, green = 0, blue = 0, alpha = 0.5 },
                    roundedRectRadii = { xRadius = OFFSET, yRadius = OFFSET },
                    trackMouseDown = true,
                    trackMouseUp = true,
                    trackMouseMove = true,
                },
                {
                    type = "text",
                    id = "keyDisplay",
                    frame = { x = OFFSET, y = OFFSET, w = BOX_SIZE, h = BOX_HEIGHT },
                    text = text,
                    textColor = { white = 1 },
                    textFont = "Menlo",
                    textSize = 28,
                    textAlignment = "left"
                }
            })
        end
    end
    local function createDisplay()
        if displayCanvas then
            displayCanvas:delete()
        end

        displayCanvas = hs.canvas.new({ x = 100, y = 100, w = BOX_SIZE, h = BOX_HEIGHT })
        updateDisplay(output)
        displayCanvas:show()
    end

    function utf8_right(str, n)
        local len = utf8.len(str)
        if not len or len <= n then return str end
        local startByte = utf8.offset(str, len - n + 1)
        return str:sub(startByte)
    end

    local keyCodes = {
        ["\27"] = "esc",
        ["\t"]  = "⇥",
        ["\n"]  = "⏎",
        ["\r"]  = "⏎",
        ["\127"] = "⌫",
        [" "] = "␣",
        ["shift"] = "⇧",
        ["cmd"] = "⌘",
        ["ctrl"] = "⌃",
        ["alt"] = "⌥",
        ["return"] = "↩",
        ["delete"] = "⌫",
        ["up"] = "↑",
        ["down"] = "↓",
        ["left"] = "←",
        ["right"] = "→",
        ["capslock"] = "⇪"
    }
    local modifiers = { "ctrl", "alt", "cmd", "fn" }
    eventtap = hs.eventtap.new({
        hs.eventtap.event.types.keyDown,
        hs.eventtap.event.types.flagsChanged,
    }, function(event)
        local key = event:getCharacters(true)
        if event:getType() == hs.eventtap.event.types.keyDown then
            local flags = event:getFlags()

            -- Modifiers handler (special case for escape)
            local parts = {}
            local has_modifier = key == "\27"
            for _, mod in ipairs(modifiers) do
                if flags[mod] then
                    has_modifier = true
                    table.insert(parts, keyCodes[mod] or mod)
                end
            end
            table.insert(parts, keyCodes[key] or key)

            -- Separate modified sequences from plain keys
            local text = table.concat(parts, "")
            if has_modifier then
                if output:sub(-1) ~= " " then
                    text = " " .. text
                end
                output = output .. text .. " "
            else
                output = output .. text
            end
            output = utf8_right(output, OUTPUT_SIZE)
            updateDisplay(output)
        end

        return false
    end)

    local function startKeyLogger()
        createDisplay()
        eventtap:start()
    end

    local function stopKeyLogger()
        eventtap:stop()
        if displayCanvas then
            displayCanvas:delete()
        end
    end

    local currentIndex = 1
    local screen = hs.screen.mainScreen()
    hs.hotkey.bind({ "ctrl", "cmd" }, "K", function()
        if currentIndex > #positions then
            stopKeyLogger()
            currentIndex = 1
            return
        elseif currentIndex == 1 then
            startKeyLogger()
        end
        if displayCanvas then
            local frame = screen:frame()
            local pos = positions[currentIndex]
            local canvasFrame = displayCanvas:frame()
            local newFrame = {
                x = frame.w * pos.x - BOX_SIZE * pos.w,
                y = frame.h * pos.y - BOX_HEIGHT * pos.h,
                w = canvasFrame.w,
                h = canvasFrame.h,
            }
            displayCanvas:frame(newFrame)
        end
        currentIndex = currentIndex + 1
    end)
end

return obj
