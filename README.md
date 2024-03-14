# Hammerspoon Key and Mouse Activity Logger

This project is a Hammerspoon script designed to log key presses, mouse movements, and mouse clicks, along with tracking the active window's title and the associated process name. It's particularly useful for monitoring your computer interaction throughout the day for productivity analysis or simply to have insights into your computer usage patterns.

## Features

- Logs every key press while any application window is active.
- Tracks the total distance moved by the mouse in meters and logs it.
- Counts the number of mouse clicks.
- Identifies the active window and its process name, logging this information alongside the activity data.
- Stores all logged information in a specified log file in JSON format for easy parsing and analysis.

## Prerequisites

Before you can use this script, you need to have Hammerspoon installed on your macOS. Hammerspoon is a tool for powerful automation of OS X. It bridges various system level APIs into a Lua scripting engine, allowing you to script many aspects of your interaction with the system.

## Installation

1. **Install Hammerspoon**

First, download and install Hammerspoon from [http://www.hammerspoon.org/](http://www.hammerspoon.org/).

2. **Clone the Repository**
Clone this repository to your local machine in a location of your choice:

```bash
git clone https://github.com/zudochkin/hammerspoon-activity-logger.git
```

3. **Configure Hammerspoon**
Navigate to your Hammerspoon configuration directory, typically located at ~/.hammerspoon/.
If you have an existing init.lua file, you may want to back it up before proceeding.
Copy the init.lua file from this project into the ~/.hammerspoon/ directory.
Create a config.lua file in the same directory to store configurations like the log file path.

```lua
-- config.lua
local config = {}
config.logFilePath = "/path/to/your/logfile.txt"
return config
```

Replace /path/to/your/logfile.txt with the actual path where you want the log file to be saved.

4. **Reload Hammerspoon Configuration**
After copying the files, open Hammerspoon and use the Reload Config option from the Hammerspoon menu in the menu bar. This will start the logging script.

## Usage

Once the Hammerspoon script is running, it will automatically log all key presses, mouse movements, and mouse clicks, along with the active window's title and process name, to the specified log file. The log file will be updated in real-time as you use your computer.

You'll see in log file

```json
{"process_name":"iTerm2","key_press_count":7,"window_title":"tail -f ActiveWindow.txt","ts":"2024-03-14 11:23:12","activity_type":"Development","mouse_clicks":1,"mouse_distance":0.050000000000000003}
{"process_name":"Safari","key_press_count":0,"window_title":"Rounding to 2 decimal places? - Scripting Helpers","ts":"2024-03-14 11:23:16","activity_type":"Other","mouse_clicks":2,"mouse_distance":0.14000000000000001}
{"process_name":"Code","key_press_count":192,"window_title":"init.lua — add-id-to-tasks","ts":"2024-03-14 11:23:20","activity_type":"Development","mouse_clicks":3,"mouse_distance":0.20000000000000001}
```

## Customization

You can customize the DPI setting in the init.lua file to match your monitor's DPI for accurate mouse movement tracking:

```lua
local dpi = 160 -- Adjust this value to match your monitor's DPI.
```

## Contributing

Contributions to this project are welcome! Feel free to fork the repository, make changes, and submit pull requests with improvements or bug fixes.