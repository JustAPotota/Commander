local commander = require("commander.commander")
local _, monarch = pcall(require, "monarch.monarch")

if type(monarch) ~= "table" then
  commander.info("Monarch not found, skipping integration", "COMMANDER")
  return
else
  commander.info("Adding Monarch integration", "COMMANDER")
end

---@type Command[]
local commands = {
  {
    name = "monarch.show",
    aliases = {},
    description = "Show the Monarch screen of the given ID",
    arguments = {
      commander.TYPE_STRING
    },
    run = function(args)
      monarch.show(args[1])
    end
  },
  {
    name = "monarch.hide",
    aliases = {},
    description = "Hide the Monarch screen of the given ID",
    arguments = {
      commander.TYPE_STRING
    },
    run = function(args)
      monarch.hide(args[1])
    end
  },
  {
    name = "monarch.clear",
    aliases = {},
    description = "Hide all Monarch screens",
    arguments = {},
    run = function()
      monarch.clear()
    end
  },
  {
    name = "monarch.top",
    aliases = {},
    description = "Print the ID of the screen at the top of the stack",
    arguments = {
      commander.TYPE_OPTIONAL(commander.TYPE_NUMBER)
    },
    run = function(args)
      local offset = args[1]
      commander.info("Top screen: " .. tostring(monarch.top(offset)), "MONARCH")
    end
  }
}

commander.register_commands(commands, "Monarch")