# Commander
A drop-in debug console and command system for the [Defold game engine](https://www.defold.com/) with support for popular libraries.

# Contents
1. [Installation](#installation)
2. [Usage](#usage)

# Installation
You can use Commander in your own project by adding it as a [Defold library dependency](https://defold.com/manuals/libraries/). Open your `game.project` file and under `Project > Dependencies` add:

> https://github.com/JustAPotota/Commander/archive/master.zip

Or point to the ZIP file of a specific release such as:
> https://github.com/JustAPotota/Commander/archive/v1.0.zip.

# Usage
### TL;DR:
- Import `commander.commander` into a script and run `commander.init()`
- Add `/commander/console.go` to your boostrap collection
- Add `/commander/inspector.go` to your other collections

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

# Built-in Commands
_You can view this list in-game via the [`help`](#help) command._

## **Commander**
---
### **`help`**
List all available commands.

### **`exit`**`, quit`
Exit the game.

### **`lua`**`, run`
**Arguments**:
- code (`string`) - Lua code to run

Executs the given string as a Lua function using [`loadstring()`](https://www.lua.org/manual/5.1/manual.html#pdf-loadstring). If multiple arguments are passed, they'll be concatenated by spaces.

### **`get_pos`**
**Arguments**
- url (`URL`) - Game object to get the position of

Print the position of the given game object.

## **Monarch**
---
### **`monarch.show`**
**Arguments**:
- id (`string`) - ID of the Monarch screen to show

Show the Monarch screen of the given ID.

### **`monarch.hide`**
**Arguments**:
- id (`string`) - ID of the Monarch screen to hide

Hide the Monarch screen of the given ID.

### **`monarch.clear`**
Hide all Monarch screens.

### **`monarch.top`**
**Arguments**:
- offset (`number?`) - Optional offset from the top of the stack

Print the ID of the screen at the top of the stack.