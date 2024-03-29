--- Initializes the Hammerspoon script and clears the console.
print("ActivityLogger")

--- Shows a startup alert.
hs.alert.show("ActivityLogger Startup")

--- Requires the configuration file and sets the log file path.
-- Make sure the path to config.lua is correct relative to init.lua.
local config = require("config").activityLogger
local logFilePath = config.logFilePath

--- Sets the DPI of your monitor and converts DPI to pixels per meter.
local dpi = config.dpi -- Set your monitor's DPI.
local pixelsPerMeter = dpi / 0.0254

print("Log file path: " .. logFilePath)

--- Defines process rules for determining activity types.
local processRules = {
    ["Google Chrome Beta"] = {{
        substring = "openai",
        activityType = "Productivity"
    }, {
        substring = "(Incognito)",
        activityType = "Wasting"
    }, {
        substring = "Dmitry (Work)",
        activityType = "Work"
    }},
    ["iTerm2"] = {{
        substring = "",
        activityType = "Development"
    }},
    ["Code"] = {{
        substring = "",
        activityType = "Development"
    }},
    ["Slack"] = {{
        substring = "",
        activityType = "Work"
    }},
    ["loginwindow"] = {{
        substring = "",
        activityType = "Idle"
    }},
    ["Obsidian"] = {{
        substring = "",
        activityType = "Obsidian"
    }},
    ["zoom.us"] = {{
        substring = "",
        activityType = "Obsidian"
    }}
}

print("Process rules defined.")

--- Variables to keep track of the last window info, key presses, mouse movement, and clicks.
local lastWindowInfo = nil
local keyPressCount = 0
local totalMouseDistance = 0
local mouseClicks = 0

--- Stores the last mouse position.
local lastMousePosition = hs.mouse.absolutePosition()

--- Escapes special characters in a string for pattern matching.
-- @param text The string to escape.
-- @return The escaped string.
local function escapePattern(text)
    return text:gsub("([%(%)%.%%%+%-%*%?%[%^%$%]])", "%%%1")
end

--- Rounds a number to a specified number of decimal places.
-- @param num The number to round.
-- @param numDecimalPlaces The number of decimal places.
-- @return The rounded number.
function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

--- Determines the activity type based on the process name and window title.
-- @param processName The name of the process.
-- @param windowTitle The title of the window.
-- @return The determined activity type.
local function activityType(processName, windowTitle)
    local rules = processRules[processName]
    if rules then
        for _, rule in ipairs(rules) do
            local escapedSubstring = escapePattern(rule.substring)
            if rule.substring == "" or windowTitle:find(escapedSubstring) then
                return rule.activityType
            end
        end
    end
    return "Other"
end

--- Updates the total distance the mouse has moved.
local function updateMouseDistance()
    local currentMousePosition = hs.mouse.absolutePosition()
    local dx = currentMousePosition.x - lastMousePosition.x
    local dy = currentMousePosition.y - lastMousePosition.y
    local distancePixels = math.sqrt(dx ^ 2 + dy ^ 2)
    local distanceMeters = distancePixels / pixelsPerMeter
    totalMouseDistance = round(totalMouseDistance + distanceMeters, 2)

    lastMousePosition = currentMousePosition
end

-- Move the counter reset logic to the `logWindowInfo` function right after logging is done
local function logWindowInfo(windowName, frontmostProcess, activity)
    local file = io.open(logFilePath, "a")
    if file then
        local logEntry = {
            ts = os.date("%Y-%m-%d %H:%M:%S"),
            activity_type = activity,
            process_name = frontmostProcess,
            window_title = windowName,
            key_press_count = keyPressCount,
            mouse_distance = totalMouseDistance,
            mouse_clicks = mouseClicks -- Added mouse clicks count
        }
        local jsonString = hs.json.encode(logEntry)
        file:write(jsonString .. "\n")
        file:close()

        -- Reset counters here ensures they are associated with the correct window
        keyPressCount = 0
        totalMouseDistance = 0
        mouseClicks = 0
    else
        hs.alert.show("Error opening log file")
    end
end

--- Checks the active window and logs information if it has changed.
local function checkActiveWindow()
    updateMouseDistance()

    local win = hs.window.frontmostWindow()
    if win then
        local app = win:application()
        if app then
            local windowName = win:title()
            local frontmostProcess = app:name()
            local currentWindowInfo = windowName .. " - " .. frontmostProcess
            -- Check if the window information has changed
            if currentWindowInfo ~= lastWindowInfo then
                -- Log the information for the previous window before updating lastWindowInfo
                if lastWindowInfo then
                    logWindowInfo(lastWindowName, lastFrontmostProcess, lastActivityType)
                end
                -- Update the information for the current window
                lastWindowName = windowName
                lastFrontmostProcess = frontmostProcess
                lastActivityType = activityType(frontmostProcess, windowName)
                lastWindowInfo = currentWindowInfo
            end
        end
    end
    -- Reset counters after logging but outside the condition checking for window change
    -- This ensures counters are ready for accumulation for the next window.
end

--- Keyboard event handler for counting key presses.
keys = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
    keyPressCount = keyPressCount + 1
    return false
end):start()

--- Mouse event handler for counting clicks.
mouses = hs.eventtap.new({hs.eventtap.event.types.leftMouseDown, hs.eventtap.event.types.rightMouseDown},
    function(event)
        mouseClicks = mouseClicks + 1
        return false
    end):start()

--- Global timer to prevent garbage collection, important for long-running scripts.
globalTimer = hs.timer.doEvery(0.1, checkActiveWindow):start()
