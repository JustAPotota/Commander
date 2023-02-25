local commander = require("commander.internal.commander")

---@param s string
---@return string
local function add_period(s)
	if not s:sub( -1, -1):find("[%.%?!]") then
		s = s .. "."
	end
	return s
end

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
		description = "Execute the given string as a Lua function using loadstring(). If multiple arguments are passed, they'll be concatenated by spaces",
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
	},
	{
		name = "generate_docs",
		aliases = {},
		summary = "Write command documentation to 'COMMANDS.generated.md'",
		parameters = {},
		run = function(args)
			local command_sets = commander.commands
			local output = "# Built-in Commands\n_You can view this list in-game via the [`help`](#help) command._\n\n"
			for _, set in ipairs(command_sets) do
				output = output .. ("# **%s**\n"):format(set.name)
				for _, command in ipairs(set.commands) do
					local prefix = ""
					if set.prefix then
						prefix = set.prefix .. "."
					end

					local name = prefix .. command.name
					if #command.aliases > 0 then
						name = name .. "/" .. prefix .. table.concat(command.aliases, ", ")
					end

					for _, param in ipairs(command.parameters) do
						name = name .. (" `%s%s`"):format(param.name, param.optional and "?" or "")
					end

					output = output .. ("## %s\n\n"):format(name)
					if #command.parameters > 0 then
						output = output .. "**Parameters**\n"
						for _, param in ipairs(command.parameters) do
							output = output ..
								("- %s (`%s%s`) - %s\n"):format(param.name, param.type.name, param.optional and "?" or "",
									add_period(param.description))
						end
						output = output .. "\n"
					end

					output = output .. add_period(command.description or command.summary) .. "\n"
				end
			end

			local file = assert(io.open("COMMANDS.generated.md", "w"))
			file:write(output)
			file:close()

			commander.info("Wrote documentation to 'COMMANDS.generated.md'", "COMMANDER")
		end
	}
}
