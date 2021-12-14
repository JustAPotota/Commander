local M = {}

local function get_extension(path)
	return path:match("%.([^.]+)$")
end

local function hex_to_vector4(hex)
	local hex = hex:match("^#(.+)") or hex
	local r_hex, g_hex, b_hex = hex:match("(%x%x)(%x%x)(%x%x)")
	local a_hex = hex:match("%x%x%x%x%x%x(%x%x)")

	local r, g, b, a = tonumber(r_hex, 16)/255, tonumber(g_hex, 16)/255, tonumber(b_hex, 16)/255
	if a_hex then
		a = tonumber(a_hex, 16)/255
	end

	-- %.3f doesn't actually shorten numbers in Defold's version of Luaj :/
	return ("vmath.vector4(%.3f, %.3f, %.3f, %.3f)"):format(r, g, b, a or 1)
end

M.hex_to_vector4 = {
	label = "Hex to Vector4",
	locations = {"Edit", "Assets"},
	query = {
		selection = {type = "resource", cardinality = "one"}
	},
	active = function(opts)
		local extension = get_extension(editor.get(opts.selection, "path"))
		return extension == "lua" or extension:find("script")
	end,
	run = function(opts)
		local text = editor.get(opts.selection, "text")

		return {
			{
				action = "set",
				node_id = opts.selection,
				property = "text",
				value = text:gsub("@(#%x%x%x%x%x%x%x?%x?)", function(hex)
					return hex_to_vector4(hex)
				end)
			}
		}
	end
}

return M