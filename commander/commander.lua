local commander = require("commander.internal.commander")

commander.register_commands(require("commander.internal.commands"), "Commander")

function commander.init()
  commander.__init()
  require("commander.integrations.monarch")
end

return commander