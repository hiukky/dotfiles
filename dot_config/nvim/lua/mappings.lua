require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Ctrl+S saves, like every "normal" editor does
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>", { desc = "save file" })

-- Ctrl+Z undoes even in insert mode (no need to leave to normal first)
map("i", "<C-z>", "<cmd> undo <cr>")
