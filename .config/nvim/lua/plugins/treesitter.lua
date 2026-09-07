return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").install({
                "rust", "lua", "python", "ron", "wgsl",
                "markdown", "markdown_inline",
            })

            local function start(buf, lang)
                if not lang or not pcall(vim.treesitter.language.add, lang) then
                    return
                end
                if not pcall(vim.treesitter.start, buf, lang) then
                    return
                end
                vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end

            vim.api.nvim_create_autocmd("FileType", {
                callback = function(ev)
                    start(ev.buf, vim.treesitter.language.get_lang(ev.match))
                end,
            })

            -- buffers already open before this ran (the file passed on the
            -- command line fires FileType before the plugin is loaded)
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) then
                    local ft = vim.bo[buf].filetype
                    if ft ~= "" then
                        start(buf, vim.treesitter.language.get_lang(ft))
                    end
                end
            end
        end,
    }
}
