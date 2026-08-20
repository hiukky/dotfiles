require "nvchad.options"

-- add yours here!

local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

-- Auto-reload the buffer when the file changes on disk (essential for
-- following edits made by an agent in another herdr tab/pane).
o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  command = "if mode() != 'c' | checktime | endif",
})
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  command = 'echohl WarningMsg | echo "File reloaded (changed outside nvim)" | echohl None',
})

-- System clipboard, so copy/paste works between nvim and other panes/apps
o.clipboard = "unnamedplus"
