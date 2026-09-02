local _ = {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",

    dependencies = {
        "nvim-lua/plenary.nvim",
    },

    opts = {
        workspaces = {
        },
    },

    config = function(_, opts)
        require("obsidian").setup(opts)

        vim.keymap.set("n", "gf", function()
            if require("obsidian").util.cursor_on_markdown_link() then
                return "<cmd>ObsidianFollowLink<CR>"
            else
                return "gf"
            end
        end, { noremap = false, expr = true })
    end,
}

return {}
