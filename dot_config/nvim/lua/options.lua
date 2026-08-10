require "nvchad.options"

-- add yours here!

local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

-- Recarrega o buffer sozinho quando o arquivo muda no disco (essencial pra
-- acompanhar edições feitas por um agente em outra aba/painel do herdr).
o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  command = "if mode() != 'c' | checktime | endif",
})
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  command = 'echohl WarningMsg | echo "Arquivo recarregado (mudou fora do nvim)" | echohl None',
})

-- Clipboard do sistema, pra copiar/colar entre o nvim e outros paineis/apps
o.clipboard = "unnamedplus"
