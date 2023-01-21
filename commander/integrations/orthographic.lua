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
		description = "Print a list of all camera IDs",
		arguments = {},
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
		description = "Print the zoom level of the given camera",
		arguments = {
			commander.TYPE_OPTIONAL(commander.TYPE_HASH)
		},
		run = function(args)
			commander.info(tostring(ortho.get_zoom(args[1])), ORTHOGRAPHIC)
		end
	}
}

commander.register_commands(commands, "Orthographic")