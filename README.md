# Commander
A small collection of useful commands you can add to your Defold editor script.

# Installation
You can use Commander in your own project by adding it as a Defold library dependency. Open your game.project file and in the dependencies field add:

https://github.com/JustAPotota/Commander/archive/main.zip

Or point to the ZIP file of a specific release, like https://github.com/JustAPotota/Commander/archive/v1.0.0.zip.

# Usage
The [`commander` module](commander/commander.lua) returns pre-built commands that you can easily slot into an editor script. As an example, you can add the `hex_to_vector4` command via:
```lua
local commander = require("commander.commander")

local M = {}

function M.get_commands()
    return {
        commander.hex_to_vector4,
        -- Other commands here
    }
end

return M

```

## commander.hex_to_vector4
Converts all hex codes prefixed with `@` to a `vmath.vector4()`.

### Example
```lua
msg.post("@render:", "clear_color", { color = @#3498db })

-- Supports alpha too!
gui.set_color(my_node, @#2c3e5080)
```
converts to:
```lua
msg.post("@render:", "clear_color", { color = vmath.vector4(0.203, 0.596, 0.858, 1.0) })

-- Supports alpha too!
gui.set_color(my_node, vmath.vector4(0.172, 0.243, 0.313, 0.501))
```
