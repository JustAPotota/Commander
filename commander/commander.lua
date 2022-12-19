local M = {}

M.TYPE_STRING = {
	name = "a string"
}
M.TYPE_NUMBER = {
	name = "a number"
}
M.TYPE_NIL = {
	name = "nil"
}
local TYPE_MAP = {
	string = M.TYPE_STRING,
	number = M.TYPE_NUMBER
}

M.LEVEL_DEBUG = 0
M.LEVEL_INFO = 1
M.LEVEL_WARNING = 2
M.LEVEL_ERROR = 3

local CONSOLES = {}
local BACKLOG = {}

M.commands = {
	{
		name = "help",
		aliases = {},
		description = "List available commands",
		arguments = {
			--M.TYPE_STRING
		},
		run = function(args)
			M.info("Available commands:")
			for _, command in ipairs(M.commands) do
				local name = command.name
				if #command.aliases > 0 then
					name = name .. ", " .. table.concat(command.aliases, ", ")
				end
				
				M.info("    " .. name .. " - " .. command.description)
			end
		end
	}
}

local function arg_type(arg)
	local type = type(arg)
	return TYPE_MAP[type] or M.TYPE_NIL
end

local function check_args(command, args)
	for i, expected in ipairs(command.arguments) do
		local given = arg_type(args[i])
		if given ~= expected then
			if expected == M.TYPE_NUMBER and given == M.TYPE_STRING then
				args[i] = tonumber(args[i])
				if not args[i] then
					return false, ("Argument #%i must be %s, not %s"):format(i, expected.name, given.name)
				end
			else
				return false, ("Argument #%i must be %s, not %s"):format(i, expected.name, given.name)
			end
		end
	end

	return true
end

local function broadcast(message)
	for _, console in ipairs(CONSOLES) do
		msg.post(console, "new_message", message)
	end
end

local function broadcast_or_hold(message)
	if #CONSOLES > 0 then
		broadcast(message)
	else
		table.insert(BACKLOG, message)
	end
end

function M.debug(text)
	local message = {
		text = text,
		level = M.LEVEL_DEBUG
	}
	broadcast_or_hold(message)
end

function M.info(text)
	local message = {
		text = text,
		level = M.LEVEL_INFO
	}
	broadcast_or_hold(message)
end

function M.warning(text)
	local message = {
		text = text,
		level = M.LEVEL_WARNING
	}
	broadcast_or_hold(message)
end

function M.error(text)
	local message = {
		text = text,
		level = M.LEVEL_ERROR
	}
	broadcast_or_hold(message)
end

function M.get_command(name)
	for _, command in ipairs(M.commands) do
		if name == command.name then return command end
		for _, alias in ipairs(command.aliases) do
			if name == alias then return command end
		end
	end
end

function M.run_command(command, args)
	if type(command) == "string" then
		local maybe_command = M.get_command(command)
		if maybe_command then
			command = maybe_command
		else
			return M.error("Unknown command '" .. command .. "'")
		end
	end

	if type(command) ~= "table" then
		return M.error("Command must be a table or a string, not " .. arg_type(command).name)
	end

	local ok, err = check_args(command, args)

	if ok then
		command.run(args)
	else
		M.error(err)
	end
end

function M.register_console(url)
	table.insert(CONSOLES, url)
	M.info("Registered new console " .. tostring(url))
	M.info("Type 'help' to view all available commands")
end

local function ext_debug(_, domain, message)
	M.debug(message)
end

local function ext_info(_, domain, message)
	M.info(message)
end

local function ext_warning(_, domain, message)
	M.warning(message)
end

local function ext_error(_, domain, message)
	M.error(message)
end

function M.init()
	if sys.get_config_int("commander.capture_logs", 1) ~= 0 then
		commander_ext.set_listeners(ext_debug, ext_info, ext_warning, ext_error)
	end
end

return M