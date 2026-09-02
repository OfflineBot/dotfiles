



return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = true,
        priority = 1000,
        opts = {
            flavour = "mocha",
            transparent_background = true,
            compile = { enabled = false },
            integrations = {
                treesitter = true,
                neotree = true,
            },
        },
    },
    {
        "serenity",
        name = "serenity",
        dir = vim.fn.stdpath("config"),
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("serenity")
        end,
    },
}
