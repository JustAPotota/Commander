# Built-in Commands
_You can view this list in-game via the [`help`](#help) command._

# **Commander**
## help
List all available commands.

## exit/quit
Exit the game.

## lua/run `code`
**Arguments**:
- code (`string`) - Lua code to run

Executes the given string as a Lua function using [`loadstring()`](https://www.lua.org/manual/5.1/manual.html#pdf-loadstring). If multiple arguments are passed, they'll be concatenated by spaces.

## get_pos `url`
**Arguments**
- url (`URL`) - Game object to get the position of

Print the position of the given game object.

# **Monarch**
## monarch.show `id`
**Arguments**:
- id (`string`) - ID of the Monarch screen to show

Show the Monarch screen of the given ID.

## monarch.hide `id`
**Arguments**:
- id (`string`) - ID of the Monarch screen to hide

Hide the Monarch screen of the given ID.

## monarch.clear
Hide all Monarch screens.

## monarch.top `offset`
**Arguments**:
- offset (`number?`) - Optional offset from the top of the stack

Print the ID of the screen at the top of the stack.