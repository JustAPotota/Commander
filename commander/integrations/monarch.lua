return function(commander)

local utils = require("commander.internal.utils")
local _, monarch = pcall(require, "monarch.monarch")

if type(monarch) ~= "table" then
	commander.warning("Monarch not found, skipping integration", "COMMANDER")
	return
else
	commander.info("Adding Monarch integration", "COMMANDER")
end

local MONARCH = "MONARCH"

local screens = utils.find_upvalue(monarch.screen_exists, "screens")

---@type Command[]
local commands = {
	{
		name = "show",
		aliases = {},
		summary = "Show the Monarch screen of the given ID",
		parameters = {
			{
				name = "id",
				description = "ID of the Monarch screen to show",
				type = commander.TYPE_HASH
			}
		},
		run = function(args)
			monarch.show(args[1])
		end
	},
	{
		name = "hide",
		aliases = {},
		summary = "Hide the Monarch screen of the given ID",
		parameters = {
			{
				name = "id",
				description = "ID of the Monarch screen to hide",
				type = commander.TYPE_HASH
			}
		},
		run = function(args)
			monarch.hide(args[1])
		end
	},
	{
		name = "clear",
		aliases = {},
		summary = "Hide all Monarch screens",
		parameters = {},
		run = function()
			monarch.clear()
		end
	},
	{
		name = "top",
		aliases = {},
		summary = "Print the ID of the screen at the top of the stack",
		parameters = {
			{
				name = "offset",
				description = "Optional offset from the top of the stack",
				type = commander.TYPE_NUMBER,
				optional = true
			}
		},
		run = function(args)
			local offset = args[1]
			commander.info("Top screen: " .. tostring(monarch.top(offset)), MONARCH)
		end
	},
	{
		name = "screens",
		aliases = {},
		summary = "Print the IDs of all registered screens",
		parameters = {},
		run = function()
			commander.info("{", MONARCH)
			for id, properties in pairs(screens) do
				commander.info("  " .. tostring(id) .. ",")
			end
			commander.info("}")
		end
	}
}

return commands

end