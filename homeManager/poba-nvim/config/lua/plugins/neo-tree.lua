return {
	"nvim-neo-tree/neo-tree.nvim",
	opts = function (_, opts)
		-- opts.follow_current_file = false
		-- opts.filesystems.follow_current_file.enabled = false
		opts.filesystem.follow_current_file.enabled = false -- this one?!
		-- opts.filesystem.follow_current_file.leave_dirs_open = true
		-- opts.sources = { "filesystem" }
		-- opts.source_selector.sources = { {source = "filesystem"} }
		-- opts.default_source = "filesystem"

		-- opts.filesystem.bind_to_cwd = false -- creates a 2-way binding between vim's cwd and neo-tree's root

		-- opts.buffers.bind_to_cwb = false
		-- opts.buffers.follow_current_file.enabled = false -- this one?!
	end,
}
