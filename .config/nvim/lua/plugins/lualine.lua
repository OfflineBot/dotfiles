return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'catppuccin/nvim' },
    config = function()
        local function accent()
            local f = io.open(os.getenv("HOME") .. "/.config/theme/accent", "r")
            if not f then return '#cba6f7' end
            local l = f:read("l")
            f:close()
            l = l and l:gsub("[^%x]", "")
            return (l and #l == 6) and ("#" .. l) or '#cba6f7'
        end
        local acc = accent()

        local theme = require('lualine.themes.catppuccin-mocha')
        theme.normal.a.bg = acc
        theme.normal.b.fg = acc

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
