local commander = require("commander.commander")

return {
  {
		name = "help",
		aliases = {},
		description = "List available commands",
		arguments = {},
		run = function(args)
			commander.info("Available commands:")
      for _, set in ipairs(commander.commands) do
        commander.info(set.domain)
        for _, command in ipairs(set.commands) do
          local name = command.name
          if #command.aliases > 0 then
            name = name .. ", " .. table.concat(command.aliases, ", ")
          end

          local args = ""
          for _, arg_type in ipairs(command.arguments) do
            local arg = " "
            if arg_type.optional then
              arg = arg .. ("[%s]"):format(arg_type.name)
            else
              arg = arg .. ("<%s>"):format(arg_type.name)
            end
            args = args .. arg
          end

          local full_name = name .. args
          full_name = full_name .. (" "):rep(25 - #full_name)
  
          commander.info("    " .. full_name .. " - " .. command.description)
        end
      end
		end
	},
	{
		name = "exit",
		aliases = { "quit" },
		description = "Exit the game",
		arguments = {},
		run = function(args)
			sys.exit(1)
		end
	},
	{
		name = "lua",
		aliases = { "run" },
		description = "Run the given Lua code",
		arguments = {
			commander.TYPE_STRING
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
		arguments = {
			commander.TYPE_URL
		},
		run = function(args)
      commander.info(tostring(go.get_position(args[1])))
		end
	}
}