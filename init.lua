--- Initializes the Hammerspoon script and clears the console.
print("Hammerspoon starting...")
hs.console.clearConsole()

--- Shows a startup alert.
hs.alert.show("Hammerspoon Startup")

--- Requires the configuration file.
-- Make sure the path to config.lua is correct relative to init.lua.
local config = require("config")

--- Load the activity logger module.
require("activity_logger")

print("Hammerspoon script initialized.")
