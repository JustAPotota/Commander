# Built-in Commands
_You can view this list in-game via the [`help`](#help) command._

# **Commander**
## help

List available commands.
## exit/quit

Exit the game.
## lua/run `code`

**Parameters**
- code (`string`) - Lua code to run.

Execute the given string as a Lua function using loadstring(). If multiple arguments are passed, they'll be concatenated by spaces.
## get_pos `url`

**Parameters**
- url (`url`) - Game object to print the position of.

Print the position of the given game object.
## generate_docs

Write command documentation to 'COMMANDS.generated.md'.
# **Monarch**
## monarch.show `id`

**Parameters**
- id (`hash`) - ID of the Monarch screen to show.

Show the Monarch screen of the given ID.
## monarch.hide `id`

**Parameters**
- id (`hash`) - ID of the Monarch screen to hide.

Hide the Monarch screen of the given ID.
## monarch.clear

Hide all Monarch screens.
## monarch.top `offset?`

**Parameters**
- offset (`number?`) - Optional offset from the top of the stack.

Print the ID of the screen at the top of the stack.
## monarch.screens

Print info about all registered screens.
# **Orthographic**
## ortho.get_cameras

Print a list of all camera IDs.
## ortho.get_view `id?`

**Parameters**
- id (`hash?`) - ID of the camera to use. Not required if there's only one.

Print the view matrix of the given camera.
## ortho.get_viewport `id?`

**Parameters**
- id (`hash?`) - ID of the camera to use. Not required if there's only one.

Print the viewport of the given camera.
## ortho.get_projection `id?`

**Parameters**
- id (`hash?`) - ID of the camera to use. Not required if there's only one.

Print the projection matrix of the given camera.
## ortho.get_zoom `id?`

**Parameters**
- id (`hash?`) - ID of the camera to use. Not required if there's only one.

Print the zoom level of the given camera.
## ortho.get_projection_id `id?`

**Parameters**
- id (`hash?`) - ID of the camera to use. Not required if there's only one.

Print the projection ID of the given camera.
## ortho.shake `id?`

**Parameters**
- id (`hash?`) - ID of the camera to use. Not required if there's only one.

Shake the given camera.
## ortho.set_zoom `zoom` `id?`

**Parameters**
- zoom (`number`) - Zoom level to set.
- id (`hash?`) - ID of the camera to use. Not required if there's only one.

Set the zoom level of the given camera.
