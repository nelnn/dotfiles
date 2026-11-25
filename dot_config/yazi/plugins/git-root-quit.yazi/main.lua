--- @sync entry
--- @since 25.6.11
return {
	entry = function()
		local cwd = tostring(cx.active.current.cwd)
		local quoted = "'" .. cwd:gsub("'", "'\\''") .. "'"
		local pipe = io.popen("git -C " .. quoted .. " rev-parse --show-toplevel 2>/dev/null", "r")
		local root = pipe and pipe:read("*l")
		if pipe then
			pipe:close()
		end
		if not root or root == "" then
			ya.notify({ title = "Git root", content = "Not inside a Git working tree", level = "warn", timeout = 3 })
			return
		end
		ya.emit("cd", { root })
		ya.emit("quit", {})
	end,
}
