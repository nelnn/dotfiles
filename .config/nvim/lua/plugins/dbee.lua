return {
  "kndndrj/nvim-dbee",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  build = function()
    -- Install tries to automatically detect the install method.
    -- if it fails, try calling it with one of these parameters:
    --    "curl", "wget", "bitsadmin", "go"
    require("dbee").install()
  end,
  config = function()
    require("dbee").setup({
      sources = {
        require("dbee.sources").FileSource:new(vim.fn.stdpath("cache") .. "/dbee/persistence.json"),
      },
    })
    vim.keymap.set("n", "<leader>eq", ":lua require('dbee').toggle()<CR>")
    vim.keymap.set("n", "<leader>es", function()
      local input = vim.fn.input("File name: ")
      if input == "" then
        return
      end
      local filename = input .. "-" .. os.date("%Y-%m-%d") .. ".csv"
      local extra_arg = vim.fn.expand("~/Documents/sql-outputs/") .. filename
      require("dbee").store("csv", "file", { extra_arg = extra_arg })
    end, { desc = "Save as csv" })
  end,
}
