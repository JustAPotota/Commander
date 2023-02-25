local M = {}

---@param fn function
---@param key string
---@return any?
function M.find_upvalue(fn, key)
	local info = debug.getinfo(fn, "u")
	for i = 1,info.nups do
		local upvalue_key, value = debug.getupvalue(fn, i)
		if upvalue_key == key then
			return value
		end
	end
end

return M