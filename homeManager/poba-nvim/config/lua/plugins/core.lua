return {
	"AstroNvim/astrocore",
	lazy = false, -- disable lazy loading
	priority = 10000, -- load AstroCore first
	opts = {
		options = {
			opt = {
				-- set configuration options  as described below
				relativenumber = false, -- sets vim.opt.relativenumber

				wrap = true,
				breakindent = true,
				breakindentopt = "shift:2",
			},
		},
		-- There is also a command to toggle autochdir <Leader>uA
    -- Configure project root detection, check status with `:AstroRootInfo`
    rooter = {
      enabled = true,
      -- list of detectors in order of prevalence, elements can be:
      --   "lsp" : lsp detection
      --   string[] : a list of directory patterns to look for
      --   fun(bufnr: integer): string|string[] : a function that takes a buffer number and outputs detected roots
      detector = {
        -- "lsp", -- highest priority is getting workspace from running language servers
        -- { ".git", "_darcs", ".hg", ".bzr", ".svn" }, -- next check for a version controlled parent directory
        { "MakeFile", "package.json" }, -- lastly check for known project root files
      },
      -- ignore things from root detection
      ignore = {
        servers = {}, -- list of language server names to ignore (Ex. { "efm" })
        dirs = {}, -- list of directory patterns (Ex. { "~/.cargo/*" })
      },
      -- automatically update working directory (update manually with `:AstroRoot`)
      autochdir = true,
      -- scope of working directory to change ("global"|"tab"|"win")
      scope = "global",
      -- show notification on every working directory change
      notify = true,
    },
	},
}
