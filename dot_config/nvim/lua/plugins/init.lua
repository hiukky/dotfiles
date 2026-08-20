return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "vimdoc", "lua", "luadoc", "printf",
        "html", "css", "json", "yaml", "toml",
        "javascript", "typescript", "tsx",
        "bash", "dockerfile", "markdown", "markdown_inline",
        "gitignore", "diff",
      },
    },
  },

  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        -- creates the dir next to the current file if it doesn't exist yet
        dir_path = "assets/images",
        use_absolute_path = false,
      },
    },
    keys = {
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "paste image from clipboard" },
    },
  },
}
