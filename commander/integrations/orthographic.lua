local commander = require("commander.internal.commander")
local _, ortho = pcall(require, "orthographic.camera")

if type(ortho) ~= "table" then
	commander.warning("Orthographic not found, skipping integration", "COMMANDER")
	return
else
	commander.info("Adding Orthographic integration", "COMMANDER")
end

local ORTHOGRAPHIC = "ORTHOGRAPHIC"

local PARAM_CAMERA_ID = {
	name = "id",
	description = "ID of the camera to use. Not required if there's only one",
	type = commander.TYPE_HASH,
	optional = true
}

---Returns whether or not the given camera exists, also logging an error if it doesn't.
---@param camera_id hash
---@return bool
local function valid_camera(camera_id)
	local ok, _ = pcall(ortho.get_zoom, camera_id)
	if not ok then
		commander.error("Invalid camera ID '" .. tostring(camera_id) .. "'. Use 'ortho.get_cameras' to list valid IDs",
			ORTHOGRAPHIC)
	end
	return ok
end

local function make_get_command(fn_name, description)
	return {
		name = fn_name,
		aliases = {},
		summary = "Print the " .. description .. " of the given camera",
		parameters = { PARAM_CAMERA_ID },
		run = function(args)
			local camera_id = args[1]
			if not valid_camera(camera_id) then return end
			commander.info(tostring(ortho[fn_name](camera_id)), ORTHOGRAPHIC)
		end
	}
end

---@type Command[]
local commands = {
	{
		name = "get_cameras",
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
	make_get_command("get_view", "view matrix"),
	make_get_command("get_viewport", "viewport"),
	make_get_command("get_projection", "projection matrix"),
	make_get_command("get_zoom", "zoom level"),
	make_get_command("get_projection_id", "projection ID"),
	{
		name = "shake",
		aliases = {},
		summary = "Shake the given camera",
		parameters = {
			PARAM_CAMERA_ID,
		},
		run = function(args)
			if not valid_camera(args[1]) then return end
			ortho.shake(args[1])
		end
	},
	{
		name = "set_zoom",
		aliases = {},
		summary = "Set the zoom level of the given camera",
		parameters = {
			{
				name = "zoom",
				description = "Zoom level to set",
				type = commander.TYPE_NUMBER
			},
			PARAM_CAMERA_ID
		},
		run = function(args)
			if not valid_camera(args[2]) then return end
			ortho.set_zoom(args[2], args[1])
		end
	}
}

commander.register_commands(commands, "Orthographic", "ortho")
