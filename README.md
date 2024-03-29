# Commander
A debug console and command system for the [Defold game engine](https://www.defold.com/) with support for popular libraries.

# Contents
1. [**Installation**](#installation)
2. [**Usage**](#usage)
3. [**Built-in Commands**](/COMMANDS.md)
4. [**API Reference**](#api-reference)

# Installation
You can use Commander in your own project by adding it as a [Defold library dependency](https://defold.com/manuals/libraries/). Open your `game.project` file and under `Project > Dependencies` add:

> https://github.com/JustAPotota/Commander/archive/refs/heads/main.zip

Or point to the ZIP file of a specific release such as:
> https://github.com/JustAPotota/Commander/archive/refs/tags/v1.2.0.zip

# Usage
### TL;DR:
- Import the module via `local commander = require("commander.commander")` and run `commander.init()`
- Add `console.go` to your boostrap collection
  - Or `imgui_console.go` if you're using the [ImGUI extension](https://github.com/britzl/extension-imgui)
- Add `inspector.go` to your other collections
- Use `/builtins/input/all.input_binding` or add the following bindings:
  - Backspace -> `key_backspace`
  - Enter -> `key_enter`
  - Grave -> `key_grave`
  - Up/Down/Left/Right -> `key_up`/`key_down`/`key_left`/`key_right`
  - Button 1/Button Left -> `touch`
  - Text -> `text`

---

To initialize Commander, import the module and run `commander.init()` in one of your scripts:
```lua
local commander = require("commander.commander")

function init(self)
    commander.init()
end
```
Now you can run commands via `commander.run_command()`, for example:
```lua
commander.run_command("help")
```
However, nothing will be printed out to Defold's console. Commander uses its own console system so you'll need some way to receive and display the output log. The simplest way is to add `/commander/console.go` to your main collection, which shows the output and comes with a text box to enter commands:

![Screenshot of the built-in console](/assets/console.png)

_Press the grave/backtick key (`) to toggle the console._

Some commands (like the built-in [`get_pos`](#get_pos) command) need to access objects and components using the [`go`](https://defold.com/ref/stable/go/) functions, but those don't work between collections. To get around this, add `/commander/inspector.go` to each of your collections so Commander can access them. You only need to add it to collections that are loaded through proxies, also called "sockets" or "game worlds".

# Project Settings
Paste the following into your `game.project` file:
```ini
[commander]
# Show messages from Defold's console in Commander
capture_logs = 1

# Force-enable the ability to print hashes, even in release builds
# If disabled, hashes will be displayed as '<unknown>'
enable_reverse_hash = 1
```
Set an option to `0` to disable it. If not specified, both options will be enabled (recommended).

# API Reference

## commander.init()
Takes care of any initialization that needs to be done, like setting up integrations and the log listener extension (if `commander.capture_logs` is set). 

## commander.run_command(`command`, `args`)
**Arguments**:
- command (`Command` | `string`) - Either a Command table or the name of a command
- args (`any[]`) - Arguments to be passed to the command

Runs the given command with the given arguments. If `command` is a string, it will use [`commander.get_command()`](#commanderget_commandname) to search it by name. All strings in the given arguments will be cast to the correct type, if possible.

**Examples**
```lua
commander.run("help")

commander.run("get_pos", { "my_go" })
```

## commander.get_command(`name`)
**Arguments**:
- name (`string`) - Name of the command

**Returns**:
- command (`Command?`) - Command with the given name or `nil` if it can't be found

Searches for the command with the given name in `commander.commands` and returns it if it was found, or `nil` if it wasn't.

## commander.register_commands(`commands`, `domain`)
**Arguments**:
- commands (`Command[]`) - Array of commands to register
- domain (`string`) - Human-readable name for this group of commands, e.g. `"Commander"` or `"Monarch"`

Adds a new command set to `commander.commands` with the given commands and domain.

## commander.register_console(`url`)
**Arguments**:
- url (`url`) - Address of the console script

Registers the given script as a console. See the section on consoles for more information.

## commander.register_inspector(`url`)
**Arguments**:
- url (`url`) - Address of the inspector script

Registers the given script as an inspector. Only intended to be used by `/commander/inspector.go`.

---
### commander.debug(`text`, `domain`)
### commander.info(`text`, `domain`)
### commander.warning(`text`, `domain`)
### commander.error(`text`, `domain`, `disable_traceback`)
**Arguments**:
- text (`string`) - Message to log
- domain (`string?`) - Optional name to prepend to the message, e.g. `"SCRIPT"` or `"COMMANDER"`
- disable_traceback (`bool?`) - Set to `true` to disable automatically adding a stack traceback

Sends the given message to all registered consoles for them to process or display. The name of the function represents the log level. For error messages, a stack traceback will automatically be appended using [`debug.traceback()`](http://www.lua.org/manual/5.2/manual.html#pdf-debug.traceback) unless `disable_traceback` is set to `true`.
