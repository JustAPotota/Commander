local commander = require("commander.internal.commander")

return {
	{
		name = "help",
		aliases = {},
		summary = "List available commands",
		parameters = {},
		run = function(args)
			commander.info("Available commands:")
			for _, set in ipairs(commander.commands) do
				commander.info(set.name)
				for _, command in ipairs(set.commands) do
					local prefix = ""
					if set.prefix then
						prefix = set.prefix .. "."
					end
					
					local name = prefix .. command.name
					if #command.aliases > 0 then
						name = name .. ", " .. prefix .. table.concat(command.aliases, ", ")
					end

					local params = ""
					for _, parameter in ipairs(command.parameters) do
						params = params .. " " .. parameter.type.name .. (parameter.optional and "?" or "")
					end

					local full_name = name .. params
					full_name = full_name .. (" "):rep(25 - #full_name)

					commander.info(("    %s - %s"):format(full_name, command.summary))
				end
			end
		end
	},
	{
		name = "exit",
		aliases = { "quit" },
		summary = "Exit the game",
		parameters = {},
		run = function(args)
			sys.exit(1)
		end
	},
	{
		name = "lua",
		aliases = { "run" },
		summary = "Run the given Lua code",
		description = "Executes the given string as a Lua function using loadstring(). If multiple arguments are passed, they'll be concatenated by spaces.",
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
		summary = "Print the position of the given game object",
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