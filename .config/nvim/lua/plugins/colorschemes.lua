-- return {
--     "neanias/everforest-nvim",
--     version = false,
--     lazy = false,
--     priority = 1000,
--     config = function()
--         require("everforest").setup({
--             background = "hard",
--             transparent_background_level = 1
--         })
--         vim.cmd([[colorscheme everforest]])
--     end,
-- }

return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha",
            transparent_background = true,
            compile = {
                enabled = false,  -- DISABLE COMPILATION
            },
            integrations = {
                treesitter = true,
                neotree = true,
                -- Add any other integrations you use
            },
        })

        vim.cmd.colorscheme "catppuccin-mocha"

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "*",
            callback = function()
                vim.schedule(function()
                    vim.cmd.colorscheme "catppuccin-mocha"
                end)
            end,
        })
    end
}
