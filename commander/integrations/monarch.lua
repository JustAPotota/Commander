local commander = require("commander.commander")
local _, monarch = pcall(require, "monarch.monarch")

if type(monarch) ~= "table" then
  commander.info("Monarch not found, skipping integration")
  return
else
  commander.info("Adding Monarch integration")
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
  }
}

commander.register_commands(commands)

return M