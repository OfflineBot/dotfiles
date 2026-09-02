return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").install({ "rust", "lua", "python", "ron", "wgsl" })

            vim.api.nvim_create_autocmd("FileType", {
                callback = function(ev)
                    local lang = vim.treesitter.language.get_lang(ev.match)
                    if not lang or not pcall(vim.treesitter.language.add, lang) then
                        return
                    end
                    if not pcall(vim.treesitter.start, ev.buf, lang) then
                        return
                    end
                    vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    }
}
