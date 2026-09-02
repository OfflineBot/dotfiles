return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'catppuccin/nvim' },
    config = function()
        local theme = require('lualine.themes.catppuccin-mocha')
        theme.normal.a.bg = '#cba6f7'
        theme.normal.b.fg = '#cba6f7'

        require('lualine').setup({
            options = {
                theme = theme
            },
            sections = {
                lualine_a = {'mode'},
                lualine_b = {'branch', 'diff', 'diagnostics'},
                lualine_c = {'filename'},
                lualine_x = {'encoding', 'fileformat', 'filetype'},
                lualine_y = {'progress'},
                lualine_z = {'location', {
                    function()
                        return os.date("%H:%M")
                    end,
                    icon = '󰥔'
                }}
            },
        })
    end
}
