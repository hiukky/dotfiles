require "nvchad.autocmds"

-- Abre a árvore de arquivos sozinha quando o nvim é iniciado numa pasta (ex: `nvim .`)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    if vim.fn.isdirectory(data.file) ~= 1 then
      return
    end
    vim.cmd.cd(data.file)
    require("nvim-tree.api").tree.open()
  end,
})
