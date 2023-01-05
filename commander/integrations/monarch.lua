local commander = require("commander.commander")
local _, monarch = pcall(require, "monarch.monarch")

if type(monarch) ~= "table" then
  commander.info("Monarch not found, skipping integration", "COMMANDER")
  return
else
  commander.info("Adding Monarch integration", "COMMANDER")
end

local M = {}

---@type Command[]
local commands = {
  {
    name = "show",
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
    name = "hide",
    aliases = {},
    description = "Hide the Monarch screen of the given ID",
    arguments = {
      commander.TYPE_STRING
    },
    run = function(args)
      monarch.hide(args[1])
    end
  }
}

commander.register_commands(commands, "Monarch")

return M