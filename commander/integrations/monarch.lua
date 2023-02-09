local commander = require("commander.internal.commander")
local _, monarch = pcall(require, "monarch.monarch")

if type(monarch) ~= "table" then
	commander.warning("Monarch not found, skipping integration", "COMMANDER")
	return
else
	commander.info("Adding Monarch integration", "COMMANDER")
end

---@type Command[]
local commands = {
	{
		name = "monarch.show",
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
		name = "monarch.hide",
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
		name = "monarch.clear",
		aliases = {},
		summary = "Hide all Monarch screens",
		parameters = {},
		run = function()
			monarch.clear()
		end
	},
	{
		name = "monarch.top",
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
			commander.info("Top screen: " .. tostring(monarch.top(offset)), "MONARCH")
		end
	}
}

commander.register_commands(commands, "Monarch")