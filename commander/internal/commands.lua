local commander = require("commander.internal.commander")

return {
	{
		name = "help",
		aliases = {},
		description = "List available commands",
		parameters = {},
		run = function(args)
			commander.info("Available commands:")
			for _, set in ipairs(commander.commands) do
				commander.info(set.domain)
				for _, command in ipairs(set.commands) do
					local name = command.name
					if #command.aliases > 0 then
						name = name .. ", " .. table.concat(command.aliases, ", ")
					end

					local params = ""
					for _, parameter in ipairs(command.parameters) do
						params = params .. " " .. parameter.type.name .. (parameter.optional and "?" or "")
					end

					local full_name = name .. params
					full_name = full_name .. (" "):rep(25 - #full_name)

					commander.info(("    %s - %s"):format(full_name, command.description))
				end
			end
		end
	},
	{
		name = "exit",
		aliases = { "quit" },
		description = "Exit the game",
		parameters = {},
		run = function(args)
			sys.exit(1)
		end
	},
	{
		name = "lua",
		aliases = { "run" },
		description = "Run the given Lua code",
		parameters = {
			{
				name = "code",
				description = "Lua code to run",
				type = commander.TYPE_STRING 
			}
		},
		run = function(args)
			local code = table.concat(args, " ")
			local func = assert(loadstring(code))
			func()
		end
	},
	{
		name = "get_pos",
		aliases = {},
		description = "Print the position of the given game object",
		parameters = {
			{
				name = "url",
				description = "Game object to print the position of",
				type = commander.TYPE_URL
			}
		},
		run = function(args)
			commander.info(tostring(go.get_position(args[1])))
		end
	}
}