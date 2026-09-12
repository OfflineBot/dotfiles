return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
        "catppuccin/nvim",
	},
	config = function()
        if vim.g.neotree_auto_close == nil then
            vim.g.neotree_auto_close = true
        end

        require("neo-tree").setup({
            filesystem = {
                window = {
                    position = "right",
                },
                filtered_items = {
                    visible = true,
                    hide_dotfiles = false,
                },
            },
            filters = {
                custom = { "node_modules" }
            },
            event_handlers = {
                {
                    event = "file_opened",
                    handler = function(file_path)
                        if vim.g.neotree_auto_close then
                            require("neo-tree.command").execute({ action = "close" })
                        end
                    end,
                }
            },
        })
		vim.api.nvim_create_user_command("ToggleAutoClose", function()
			vim.g.neotree_auto_close = not vim.g.neotree_auto_close
			vim.notify(
				"Neo-tree auto close: " .. (vim.g.neotree_auto_close and "on" or "off"),
				vim.log.levels.INFO
			)
		end, { desc = "Toggle whether neo-tree closes when a file is opened" })

		vim.keymap.set("n", "<C-n>", "<Cmd>Neotree filesystem toggle right<CR>", {})
		vim.keymap.set("n", "<leader>bf", "<Cmd>Neotree buffers reveal float<CR>", {})

		vim.api.nvim_create_autocmd("QuitPre", {
			callback = function()
				local non_floating = {}
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					if vim.api.nvim_win_get_config(win).relative == "" then
						table.insert(non_floating, win)
					end
				end
				local only_neotree = true
				local has_neotree = false
				for _, win in ipairs(non_floating) do
					local buf = vim.api.nvim_win_get_buf(win)
					if vim.bo[buf].filetype == "neo-tree" then
						has_neotree = true
					else
						only_neotree = false
					end
				end
				if has_neotree and only_neotree then
					vim.cmd("Neotree close")
				end
			end,
		})
	end,
}

