-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

-- Keeps nvim's theme in sync with herdr's own [theme] name instead of a
-- hand-picked value that drifts whenever the herdr theme changes.
-- herdr and base46 don't always spell theme names the same way (e.g.
-- herdr's "tokyo-night" vs base46's "tokyonight"), so a few separator
-- variants are tried before giving up and letting NvChad use its default.
local function herdr_theme()
	local f = io.open(vim.fn.expand "~/.config/herdr/config.toml", "r")
	if not f then
		return nil
	end

	local in_theme_section = false
	local name = nil
	for line in f:lines() do
		local section = line:match "^%s*%[([%w_.]+)%]%s*$"
		if section then
			in_theme_section = section == "theme"
		elseif in_theme_section then
			local value = line:match '^%s*name%s*=%s*"([^"]+)"'
			if value then
				name = value
				break
			end
		end
	end
	f:close()
	if not name then
		return nil
	end

	-- Checked as a plain file on disk (not `require`d) because this runs
	-- before lazy.nvim finishes mounting base46 on the runtimepath, so
	-- `require("base46.themes.X")` would false-negative on every theme.
	local themes_dir = vim.fn.stdpath "data" .. "/lazy/base46/lua/base46/themes/"
	local candidates = { name, name:gsub("-", "_"), name:gsub("-", ""), name:gsub("_", "-") }
	for _, candidate in ipairs(candidates) do
		if vim.uv.fs_stat(themes_dir .. candidate .. ".lua") then
			return candidate
		end
	end

	vim.notify("herdr theme '" .. name .. "' has no matching base46 theme, using default", vim.log.levels.INFO)
	return nil
end

M.base46 = {
	theme = herdr_theme(), -- segue o tema ativo do herdr (~/.config/herdr/config.toml)

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }

return M
