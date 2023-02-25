local M = {}

local COMMANDER = "COMMANDER"

M.MESSAGE_RUN_COMMAND = hash("run_command")

---@class Command
---@field name string Name of the command
---@field aliases string[] Alternate names
---@field summary string Short description of what the command does
---@field description string? Full description of what the command does. If not given, the summary will be used instead
---@field parameters Parameter[]
---@field run function(args: any[])

---@class Parameter
---@field name string
---@field description string
---@field type Type
---@field optional bool?

---@class Type
---@field name string
---@field description string

---@class CommandSet
---@field name string
---@field prefix string
---@field commands Command[]

---@type Type
M.TYPE_STRING = {
	name = "string",
	description = "a string"
}
---@type Type
M.TYPE_NUMBER = {
	name = "number",
	description = "a number"
}
---@type Type
M.TYPE_NIL = {
	name = "nil",
	description = "nil"
}
---@type Type
M.TYPE_URL = {
	name = "url",
	description = "a url"
}
---@type Type
M.TYPE_HASH = {
	name = "hash",
	description = "a hash"
}


---@class Message
---@field text string
---@field domain string?
---@field severity Severity

---@enum Severity
M.SEVERITY = {
	DEBUG = 0,
	INFO = 1,
	WARNING = 2,
	ERROR = 3
}


---@param type Type
---@return Type ...
function M.OPTIONAL(type)
	return type, M.TYPE_NIL
end

---@param parameters Parameter[]
---@param type Type
---@return boolean
local function contains_type(parameters, type)
	for _, param in ipairs(parameters) do
		if param.type == type then
			return true
		end
	end
	return false
end

local CONSOLES = {}
local INSPECTORS = {}
local BACKLOG = {}

---@type CommandSet[]
M.commands = {}

---@param value any
---@return boolean
local function is_url(value)
	assert(value.socket ~= nil)
	return true
end

---@param arg any
---@return Type
local function get_type(arg)
	local type_name = type(arg)

	if type_name == "string" then
		return M.TYPE_STRING
	elseif type_name == "number" then
		return M.TYPE_NUMBER
	elseif type_name == "userdata" then
		if pcall(is_url, arg) then
			return M.TYPE_URL
		end
	end

	return M.TYPE_NIL
end

---@param string string
---@param type Type
---@return any?
local function cast_from_string(string, type)
	if type == M.TYPE_NUMBER then
		return tonumber(string)
	elseif type == M.TYPE_HASH then
		return hash(string)
	elseif type == M.TYPE_URL then
		local ok, url = pcall(msg.url, arg)
		if ok then
			return url
		end
	end
end

---@param parameter Parameter
---@param argument any
---@return boolean,any?
local function arg_is_valid(parameter, argument)
	local given = get_type(argument)

	local expected = parameter.type
	if given == expected then return true end

	if given == M.TYPE_NIL and parameter.optional then return true end

	if given == M.TYPE_STRING then
		local cast_arg = cast_from_string(argument, expected)
		if cast_arg then
			return true, cast_arg
		end
	end

	return false
end

---@param i number
---@param parameter Parameter
---@param argument any
---@return string
local function incorrect_type_error(i, parameter, argument)
	local expected = parameter.type.description
	local given = get_type(argument).description

	return ("Argument #%i must be %s, not %s"):format(i, expected, given)
end

---@param command Command
---@param args any[]
---@returns boolean,string?
local function check_args(command, args)
	for i, parameter in ipairs(command.parameters)  do
		local ok, cast_arg = arg_is_valid(parameter, args[i])
		if not ok then
			return false, incorrect_type_error(i, parameter, args[i])
		elseif cast_arg then
			args[i] = cast_arg
		end
	end

	return true
end

---@param message Message
local function broadcast(message)
	for _, console in ipairs(CONSOLES) do
		msg.post(console, "new_message", message)
	end
end

---@param message Message
local function broadcast_or_hold(message)
	if #CONSOLES > 0 then
		broadcast(message)
	else
		table.insert(BACKLOG, message)
	end
end

---@param message string
---@return string, number
local function traceback(message)
	return debug.traceback(message, 2):gsub("\n\t", "\n  ")
end

local function new_message(text, domain, severity)
	local message = {
		text = text or "",
		domain = domain,
		severity = severity
	}
	broadcast_or_hold(message)
end

---@param text string
---@param domain string?
function M.debug(text, domain)
	new_message(text, domain, M.SEVERITY.DEBUG)
end

---@param text string
---@param domain string?
function M.info(text, domain)
	new_message(text, domain, M.SEVERITY.INFO)
end

---@param text string
---@param domain string?
function M.warning(text, domain)
	new_message(text, domain, M.SEVERITY.WARNING)
end

---@param text string
---@param domain string?
---@param disable_traceback boolean?
function M.error(text, domain, disable_traceback)
	local text = disable_traceback and text or traceback(text)
	new_message(text, domain, M.SEVERITY.ERROR)
end

---@param command Command
---@return boolean
local function requires_inspector(command)
	return contains_type(command.parameters, M.TYPE_URL)
end

---@param args any[]
---@return url[]
local function get_urls(args)
	local urls = {}
	for _, v in ipairs(args) do
		if type(v) == "userdata" and v.socket then
			table.insert(urls, v)
		end
	end
	return urls
end

---@param urls url[]
---@return boolean
local function has_multiple_sockets(urls)
	local current_socket
	for _, url in ipairs(urls) do
		if current_socket and url.socket ~= current_socket then
			return true
		end
		current_socket = url.socket
	end

	return false
end

---@param name string
---@return Command?
function M.get_command(name)
	for _, set in ipairs(M.commands) do
		for _, command in ipairs(set.commands) do
			local prefix = ""
			if set.prefix then
				prefix = set.prefix .. "."
			end

			if name == prefix .. command.name then return command end
			for _, alias in ipairs(command.aliases) do
				if name == prefix .. alias then return command end
			end
		end
	end
end

---@param url url
---@return url?
local function find_valid_inspector(url)
	for _, inspector in ipairs(INSPECTORS) do
		if url.socket == inspector.socket then
			return inspector
		end
	end
end

local function is_go()
	return pcall(go.get_id)
end

local function run_command(command, args)
	local ok, message = pcall(command.run, args)
	if not ok then
		M.error(message, COMMANDER)
	end
end

---@param command Command
---@param args any[]
local function run_with_inspector(command, args)
	local urls = get_urls(args)
	if #urls == 0 then return run_command(command, args) end
	if has_multiple_sockets(urls) then
		return M.error("Cannot run a command on multiple sockets", COMMANDER)
	end

	local url = urls[1]
	if url.socket == msg.url().socket and is_go() then
		return run_command(command, args)
	end

	local inspector = find_valid_inspector(url)
	if not inspector then
		return M.error("No inspector found in socket with " .. tostring(url.socket), COMMANDER)
	end

	msg.post(inspector, "run_command", { command = command.name, args = args })
end

---@param command Command|string
---@param args any[]
function M.run_command(command, args)
	if type(command) == "string" then
		local maybe_command = M.get_command(command)
		if maybe_command then
			command = maybe_command
		else
			return M.error("Unknown command '" .. command .. "'", COMMANDER)
		end
	end

	if type(command) ~= "table" then
		return M.error("Command must be a table or a string, not " .. get_type(command).description, COMMANDER)
	end
	
	local ok, err = check_args(command, args)
	if not ok then
		return M.error(err, COMMANDER)
	end

	if not requires_inspector(command) then
		return run_command(command, args)
	end
	
	run_with_inspector(command, args)
end

function M.register_console(url)
	table.insert(CONSOLES, url)
	M.info("Registered new console with " .. tostring(url), COMMANDER)

	for i = 1, #BACKLOG do
		broadcast(BACKLOG[i])
		BACKLOG[i] = nil
	end
end

function M.register_inspector(url)
	table.insert(INSPECTORS, url)
	M.info("Registered new inspector with " .. tostring(url), COMMANDER)
end

---@param name string
---@return CommandSet?
local function find_command_set(name)
	for _, set in ipairs(M.commands) do
		if set.name == name then
			return set
		end
	end
end

---@param commands Command[]
---@param group_name string
---@param prefix string?
function M.register_commands(commands, group_name, prefix)
	local set = find_command_set(group_name)
	if set then
		for _, command in ipairs(commands) do
			table.insert(set.commands, command)
		end
	else
		local new_set = {
			name = group_name,
			prefix = prefix,
			commands = commands
		}
		table.insert(M.commands, new_set)
	end
end

local function ext_debug(_, domain, message)
	M.debug(message, domain)
end

local function ext_info(_, domain, message)
	M.info(message, domain)
end

local function ext_warning(_, domain, message)
	M.warning(message, domain)
end

local function ext_error(_, domain, message)
	M.error(message, domain, true)
end

function M.__init()
	if sys.get_config_int("commander.capture_logs", 1) ~= 0 then
		commander_ext.set_listeners(ext_debug, ext_info, ext_warning, ext_error)
	end
end

return M
