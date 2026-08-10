require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Ctrl+S salva, do jeito que todo editor "normal" faz
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>", { desc = "save file" })

-- Ctrl+Z desfaz mesmo em insert mode (sem precisar sair pro normal antes)
map("i", "<C-z>", "<cmd> undo <cr>")
