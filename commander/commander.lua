local commander = require("commander.internal.commander")

commander.register_commands(require("commander.internal.commands"), "Commander")

require("commander.integrations.monarch")

return commander