
-- Compile LaTeX with Tectonic
local function tectonic_build()
  -- Save the current buffer
  vim.cmd("write")
  local filename = vim.fn.expand("%:p")
  -- Check if zathura is already running with this PDF
  local check_zathura = string.format("pgrep -f 'zathura.*%s.pdf'", vim.fn.expand("%:p:r"))
  local zathura_pid = vim.fn.system(check_zathura)

  -- Compile with tectonic
  local compile_cmd = string.format("tectonic -X compile %s", filename)
  local output = vim.fn.system(compile_cmd)
  local exit_code = vim.v.shell_error

  if exit_code ~= 0 then
    vim.notify("Error: " .. output, vim.log.levels.ERROR)
    return
  end

  -- If zathura isn't running, start it
  if zathura_pid == "" then
    local open_cmd = string.format("zathura %s.pdf &", vim.fn.expand("%:p:r"))
    vim.fn.system(open_cmd)
  end

  vim.notify("Rendered", vim.log.levels.INFO)
end

-- LSPAttach autocmd to set up LaTeX-specific keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("CompileLatex", {}),
  callback = function(ev)
    vim.keymap.set("n", "<leader>lb", tectonic_build,
      { buffer = ev.bufnr, desc = "Build LaTeX with Tectonic" })
  end,
})
