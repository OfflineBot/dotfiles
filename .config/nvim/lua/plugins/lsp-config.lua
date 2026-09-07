return {
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        lazy = false,
        opts = {
            auto_install = true,
        },
    },
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        config = function()

            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                underline = true,
                severity_sort = true,
                update_in_insert = false,
            })

            -- let treesitter own the highlighting. rust-analyzer's semantic
            -- tokens otherwise layer on top and leave keywords like `pub` and
            -- `impl` uncolored until the colorscheme is re-applied by hand.
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client then
                        client.server_capabilities.semanticTokensProvider = nil
                    end
                end,
            })

            vim.keymap.set("n", "K", function()
                vim.diagnostic.open_float(nil, { focusable = false })
            end)

            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            vim.lsp.config("*", {
                capabilities = capabilities,
            })


            vim.lsp.config("ts_ls", {
                flags = {
                    debounce_text_changes = 500,
                },
            })
            vim.lsp.config("solargraph", {})
            vim.lsp.config("html", {})
            vim.lsp.config("lua_ls", {})
            vim.lsp.config("clangd", {
                cmd = { "clangd", "--completion-style=detailed" },
            })

            local julia = vim.fn.expand("~/.julia/environments/nvim-lspconfig/bin/julia")
            if vim.fn.filereadable(julia) == 1 then
                local julials_cmd = vim.lsp.config.julials and vim.lsp.config.julials.cmd
                if type(julials_cmd) == "table" then
                    julials_cmd = vim.deepcopy(julials_cmd)
                    julials_cmd[1] = julia
                    vim.lsp.config("julials", { cmd = julials_cmd })
                end
            end

            vim.lsp.config("rust_analyzer", {
                cmd = { "rust-analyzer" },
            })

            vim.lsp.config("basedpyright", {
                settings = {
                    basedpyright = {
                        analysis = {
                            typeCheckingMode = "standard",
                        },
                    },
                },
            })

            vim.lsp.enable({
                "ts_ls",
                "solargraph",
                "html",
                "lua_ls",
                "clangd",
                "julials",
                "rust_analyzer",
                "basedpyright",
            })

            vim.keymap.set("n", "m", function()
              vim.lsp.buf.hover({border="rounded"})
            end, {})
            vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
            vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, {})
            vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
        end,
    },
}
