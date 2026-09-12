-- accent color shared with hyprland and quickshell via ~/.config/theme/accent
-- (first line, hex). picked up on startup; cycled live with Mod+Ctrl+X.
local function accent()
    local f = io.open(os.getenv("HOME") .. "/.config/theme/accent", "r")
    if not f then return nil end
    local l = f:read("l")
    f:close()
    l = l and l:gsub("[^%x]", "")
    return (l and #l == 6) and ("#" .. l) or nil
end

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
                local acc = accent() or c.mauve
                return {
                    Directory            = { fg = acc },
                    NeoTreeDirectoryIcon = { fg = acc },
                    NeoTreeDirectoryName = { fg = acc },
                    NeoTreeRootName      = { fg = acc, bold = true },
                    Title                = { fg = acc, bold = true },
                    CursorLineNr         = { fg = acc },

                    FloatBorder             = { fg = acc },
                    WinSeparator            = { fg = acc },
                    TelescopeBorder         = { fg = acc },
                    TelescopePromptPrefix   = { fg = acc },
                    TelescopeSelectionCaret = { fg = acc },
                    TelescopeMatching       = { fg = acc, bold = true },
                    CurSearch               = { fg = c.base, bg = acc },
                    IncSearch               = { fg = c.base, bg = acc },
                    AlphaHeader             = { fg = acc },
                    IblScope                = { fg = acc },

                    PmenuSel          = { fg = c.base, bg = acc, bold = true },
                    PmenuThumb        = { bg = acc },
                    CmpItemAbbrMatch      = { fg = acc, bold = true },
                    CmpItemAbbrMatchFuzzy = { fg = acc, bold = true },
                    CmpItemMenu           = { fg = c.overlay0, italic = true },

                    -- completion + docs: give the popups a solid surface and
                    -- keep the border on the same background, so the rounded
                    -- corners have no square frame bleeding around them
                    Pmenu        = { bg = c.mantle },
                    CmpBorder    = { fg = acc, bg = c.mantle },
                    CmpDoc       = { bg = c.mantle },
                    CmpDocBorder = { fg = acc, bg = c.mantle },
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
