



return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        opts = {
            flavour = "mocha",
            transparent_background = true,
            compile = { enabled = false },
            integrations = {
                treesitter = true,
                neotree = true,
            },
            custom_highlights = function(c)
                return {
                    Directory            = { fg = c.mauve },
                    NeoTreeDirectoryIcon = { fg = c.mauve },
                    NeoTreeDirectoryName = { fg = c.mauve },
                    NeoTreeRootName      = { fg = c.mauve, bold = true },
                    Title                = { fg = c.mauve, bold = true },
                    CursorLineNr         = { fg = c.mauve },

                    FloatBorder             = { fg = c.mauve },
                    WinSeparator            = { fg = c.mauve },
                    TelescopeBorder         = { fg = c.mauve },
                    TelescopePromptPrefix   = { fg = c.mauve },
                    TelescopeSelectionCaret = { fg = c.mauve },
                    TelescopeMatching       = { fg = c.mauve, bold = true },
                    CurSearch               = { fg = c.base, bg = c.mauve },
                    IncSearch               = { fg = c.base, bg = c.mauve },
                    AlphaHeader             = { fg = c.mauve },
                    IblScope                = { fg = c.mauve },

                    PmenuSel          = { fg = c.base, bg = c.mauve, bold = true },
                    PmenuThumb        = { bg = c.mauve },
                    CmpItemAbbrMatch      = { fg = c.mauve, bold = true },
                    CmpItemAbbrMatchFuzzy = { fg = c.mauve, bold = true },
                    CmpItemMenu           = { fg = c.overlay0, italic = true },

                    -- completion + docs: give the popups a solid surface and
                    -- keep the border on the same background, so the rounded
                    -- corners have no square frame bleeding around them
                    Pmenu        = { bg = c.mantle },
                    CmpBorder    = { fg = c.mauve, bg = c.mantle },
                    CmpDoc       = { bg = c.mantle },
                    CmpDocBorder = { fg = c.mauve, bg = c.mantle },
                }
            end,
        },
    },
    {
        "serenity",
        name = "serenity",
        dir = vim.fn.stdpath("config"),
        lazy = false,
        priority = 999,
        config = function() end,
    },
}
