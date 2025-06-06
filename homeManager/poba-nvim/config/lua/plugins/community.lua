return {
	-- Add the community repository of plugin specifications
	"AstroNvim/astrocommunity",
	branch = "main",
	-- example of imporing a plugin, comment out to use it or add your own
	-- available plugins can be found at https://github.com/AstroNvim/astrocommunity
	{ import = "astrocommunity.completion.copilot-lua" },
	{ import = "astrocommunity.completion.copilot-lua-cmp" },
	{ import = "astrocommunity.completion.cmp-tmux" },
	{
		"zbirenbaum/copilot.lua",
		opts = {
			filetypes = {
				gitcommit = true,
			},
		},
	},
	{ import = "astrocommunity.project.project-nvim" },
	{ import = "astrocommunity.pack.go" },
	{
		"ray-x/go.nvim",
		-- don't install go binaries with the plugin
		-- instead we install these with nix: https://github.com/ray-x/go.nvim#go-binaries-install-and-update
		build = "true",
	},
	{ import = "astrocommunity.pack.bash" },
	{ import = "astrocommunity.pack.lua" },
	{ import = "astrocommunity.pack.markdown" },
	{ import = "astrocommunity.pack.nix" },
	{ import = "astrocommunity.pack.python" },
	{ import = "astrocommunity.pack.rust" },
	{ import = "astrocommunity.pack.toml" },
	{ import = "astrocommunity.pack.yaml" },
	{ import = "astrocommunity.pack.zig" },
	{ import = "astrocommunity.editing-support.rainbow-delimiters-nvim" },
	{ import = "astrocommunity.editing-support.auto-save-nvim" },
	{ import = "astrocommunity.motion.nvim-surround" },
 { import = "astrocommunity.colorscheme.gruvbox-nvim" },
 { import = "astrocommunity.colorscheme.melange-nvim" },
 { import = "astrocommunity.colorscheme.monokai-pro-nvim" },
 { import = "astrocommunity.colorscheme.everforest" },
 { import = "astrocommunity.colorscheme.sonokai" }, -- very nice with let g:sonokai_style = "espresso"
}
