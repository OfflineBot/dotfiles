return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
    },

    config = function()
        local function accent()
            local f = io.open(os.getenv("HOME") .. "/.config/theme/accent", "r")
            if not f then return "#cba6f7" end
            local l = f:read("l")
            f:close()
            l = l and l:gsub("[^%x]", "")
            return (l and #l == 6) and ("#" .. l) or "#cba6f7"
        end
        vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = accent(), bg = "NONE" })
        require('noice').setup({
            notify = {
                enabled = false,
                view = "notify",
            },
            messages = {
                enabled = false,
            },
            presets = {
                long_message_to_split = true,
                lsp_doc_border = true,
            },
            cmdline = {
                enabled = true,
                view = "cmdline_popup",
                format = {},
            },
            views = {
                cmdline_popup = {
                    win_options = {
                        winhighlight = {
                            FloatBorder = "FloatBorder"
                        },
                    },
                    position = {
                        row = 1,
                        col = "50%",
                    },
                    size = {
                        width = "50%",
                        height = 1,
                    },
                    border = {
                        style = "rounded",
                        padding = { 0, 1 },
                    },
                },
            },
        })
    end
}

