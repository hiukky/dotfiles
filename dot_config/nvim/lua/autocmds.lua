require "nvchad.autocmds"

-- Auto-open the file tree when nvim starts in a directory (e.g. `nvim .`)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    if vim.fn.isdirectory(data.file) ~= 1 then
      return
    end
    vim.cmd.cd(data.file)
    require("nvim-tree.api").tree.open()
  end,
})
