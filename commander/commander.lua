local M = {}

local COMMANDER = "COMMANDER"

M.MESSAGE_RUN_COMMAND = hash("run_command")

---@class Argument
---@field name string
---@field desc string
---@field any_of boolean?
---@field optional boolean?
---@field types Argument[]?

M.TYPE_STRING = {
	name = "string",
  desc = "a string"
}
M.TYPE_NUMBER = {
	name = "number",
  desc = "a number"
}
M.TYPE_NIL = {
	name = "nil",
  desc = "nil"
}
M.TYPE_URL = {
	name = "URL",
  desc = "a URL"
}

---@param ... Argument
function M.TYPE_ANY_OF(...)
	local types = { ... }

	if #types == 0 then
		return M.TYPE_NIL
	elseif #types == 1 then
		return types[1]
	end

	local desc = ""
	if #types == 2 then
		desc = ("either %s or %s"):format(types[1].desc, types[2].desc)
	else
		for i, t in ipairs(types) do
			if i == #types then
				desc = desc .. "or " .. t.desc
			else
				desc = desc .. t.desc .. ", "
			end
		end
	end

  local name = ""
  for i, t in ipairs(types) do
    name = name .. t.name
    if i < #types then
      name = name .. "|"
    end
  end

	return {
		any_of = true,
		types = types,
    name = name,
		desc = desc
	}
end

---@param arg_type Argument
---@return Argument
function M.TYPE_OPTIONAL(arg_type)
  return {
    name = arg_type.name,
    desc = arg_type.desc,
    optional = true
  }
end

---@param arguments Argument[]
---@param arg_type Argument
---@return boolean
local function has_arg_type(arguments, arg_type)
	for _, arg in ipairs(arguments) do
		if arg == arg_type then
			return true
		elseif arg.types then
			return has_arg_type(arg.types, arg_type)
		end
	end
  return false
end

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

local CONSOLES = {}
local INSPECTORS = {}
local BACKLOG = {}

---@class Command
---@field name string
---@field aliases string[]
---@field description string
---@field arguments Argument[]
---@field run function(args: any[])

---@class CommandSet
---@field domain string
---@field commands Command[]

---@type CommandSet[]
M.commands = {}

---@param value any
---@return boolean
local function is_url(value)
  assert(value.socket ~= nil)
  return true
end

---@param arg any
---@return Argument
local function arg_type(arg)
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

---@param expected Argument
---@param arg any
---@return boolean,any?
local function arg_matches(expected, arg)
	local given = arg_type(arg)

	if given == expected then return true end

	if expected.any_of then
		for _, t in ipairs(expected.types) do
			if arg_matches(t, arg) then
				return true
			end
		end
	end

	if expected == M.TYPE_NUMBER and given == M.TYPE_STRING then
		local str = tostring(arg)
		if str then
			return true, str
		end
	elseif expected == M.TYPE_URL and given == M.TYPE_STRING then
		local ok, url = pcall(msg.url, arg)
		if ok then
			return true, url
		end
	end

	return false
end

---@param command Command
---@param args any[]
---@returns boolean
local function check_args(command, args)
	for i, expected in ipairs(command.arguments) do
		local given = arg_type(args[i])
		local ok, cast_arg = arg_matches(expected, args[i])
		if not ok then
			return false, ("Argument #%i must be %s, not %s"):format(i, expected.desc, given.desc)
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
	return has_arg_type(command.arguments, M.TYPE_URL)
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
      if name == command.name then return command end
      for _, alias in ipairs(command.aliases) do
        if name == alias then return command end
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

---@param command Command|string
---@param args any[]
function M.run_command(command, args)
  local command_name = command
	if type(command) == "string" then
		local maybe_command = M.get_command(command)
		if maybe_command then
			command = maybe_command
		else
			return M.error("Unknown command '" .. command .. "'", COMMANDER)
		end
	end

	if type(command) ~= "table" then
		return M.error("Command must be a table or a string, not " .. arg_type(command).name, COMMANDER)
	end
  
	local ok, err = check_args(command, args)

	if ok then
    if requires_inspector(command) then
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

      msg.post(inspector, "run_command", { command = command_name, args = args })
    else
      run_command(command, args)
    end
	else
		M.error(err, COMMANDER)
	end
end

function M.register_console(url)
	table.insert(CONSOLES, url)
	M.info("Registered new console with " .. tostring(url), COMMANDER)
	M.info("Type 'help' to view all available commands", COMMANDER)

  for i = 1, #BACKLOG do
    broadcast(BACKLOG[i])
    BACKLOG[i] = nil
  end
end

function M.register_inspector(url)
	table.insert(INSPECTORS, url)
	M.info("Registered new inspector with " .. tostring(url), COMMANDER)
end

---@param domain string
---@return CommandSet?
local function find_command_set(domain)
  for _, set in ipairs(M.commands) do
    if set.domain == domain then
      return set
    end
  end
end

---@param commands Command[]
---@param domain string
function M.register_commands(commands, domain)
  local set = find_command_set(domain)
  if set then
    for _, command in ipairs(commands) do
      table.insert(set.commands, command)
    end
  else
    local new_set = {
      domain = domain,
      commands = commands
    }
    table.insert(M.commands, new_set)
  end
end
M.register_commands(require("commander.commands"), "Commander")

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

function M.init()
	if sys.get_config_int("commander.capture_logs", 1) ~= 0 then
		commander_ext.set_listeners(ext_debug, ext_info, ext_warning, ext_error)
	end
end

return M
