return {
  -- Set colorscheme to use
  colorscheme = "gruvbox",
  -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
  diagnostics = {
    virtual_text = true,
    underline = true,
  },
  lsp = {
    config = {
      clangd = {
        cmd = { "clangd", "--offset-encoding=utf-16" },
      },
      vale = {
        cmd = { "vale", "--lsp" },
        filetypes = { "markdown", "text" },
      },
    },
    -- customize lsp formatting options
    formatting = {
      format_on_save = false, -- enable or disable automatic formatting on save
      },
      timeout_ms = 1000, -- default format timeout
    },
    -- enable servers that you already have installed without mason
    servers = {
      "clangd",
      "bashls",
      "gopls",
      "taplo",
      "marksman",
      "pyright",
      "nil_ls",
      "terraformls",
      "lua_ls",
      "vale",
      "rust_analyzer",
      "gopls",
      "yamlls",
      "denols",
    },
  },
  -- Configure require("lazy").setup() options
  lazy = {
    defaults = { lazy = true },
    performance = {
      rtp = {
        -- customize default disabled vim plugins
        disabled_plugins = { "tohtml", "gzip", "matchit", "zipPlugin", "netrwPlugin", "tarPlugin" },
      },
    },
  },
  -- This function is run last and is a good place to configuring
  -- augroups/autocommands and custom filetypes also this just pure lua so
  -- anything that doesn't fit in the normal config locations above can go here
  polish = function()
    -- Set up custom filetypes
    -- vim.filetype.add {
    --   extension = {
    --     foo = "fooscript",
    --   },
    --   filename = {
    --     ["Foofile"] = "fooscript",
    --   },
    --   pattern = {
    --     ["~/%.config/foo/.*"] = "fooscript",
    --   },
    -- }
  end,
}
