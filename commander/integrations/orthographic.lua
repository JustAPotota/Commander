local commander = require("commander.internal.commander")
local _, ortho = pcall(require, "orthographic.camera")

if type(ortho) ~= "table" then
	commander.warning("Orthographic not found, skipping integration", "COMMANDER")
	return
else
	commander.info("Adding Orthographic integration", "COMMANDER")
end

local ORTHOGRAPHIC = "ORTHOGRAPHIC"

---@type Command[]
local commands = {
	{
		name = "ortho.get_cameras",
		aliases = {},
		summary = "Print a list of all camera IDs",
		parameters = {},
		run = function()
			commander.info("{", ORTHOGRAPHIC)
			for _, id in ipairs(ortho.get_cameras()) do
				commander.info("  " .. tostring(id) .. ",")
			end
			commander.info("}")
		end
	},
	{
		name = "ortho.get_zoom",
		aliases = {},
		summary = "Print the zoom level of the given camera",
		parameters = {
			{
				name = "id",
				description = "ID of the camera to use. Not required if there's only one",
				type = commander.TYPE_HASH,
				optional = true
			}
		},
		run = function(args)
			commander.info(tostring(ortho.get_zoom(args[1])), ORTHOGRAPHIC)
		end
	},
	{
		name = "ortho.set_zoom",
		aliases = {},
		summary = "Set the zoom level of the given camera",
		parameters = {
			{
				name = "zoom",
				description = "Zoom level to set",
				type = commander.TYPE_NUMBER
			},
			{
				name = "id",
				description = "ID of the camera to use. Not required if there's only one",
				type = commander.TYPE_HASH,
				optional = true
			}
		},
		run = function(args)
			ortho.set_zoom(args[2], args[1])
		end
	}
}

commander.register_commands(commands, "Orthographic")