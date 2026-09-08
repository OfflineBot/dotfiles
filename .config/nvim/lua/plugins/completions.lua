return {
    {
        "hrsh7th/cmp-nvim-lsp"
    },
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
        },
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'onsails/lspkind.nvim',
        },

        config = function()
            local cmp = require("cmp")
            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                preselect = cmp.PreselectMode.None,
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered({
                        border = "rounded",
                        winhighlight = "Normal:Pmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
                    }),
                    documentation = cmp.config.window.bordered({
                        border = "rounded",
                        winhighlight = "Normal:CmpDoc,FloatBorder:CmpDocBorder,Search:None",
                    }),
                },
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = require("lspkind").cmp_format({
                        mode = "symbol_text",
                        maxwidth = 40,
                        ellipsis_char = "…",
                        -- show where the item comes from: rust-analyzer puts
                        -- the source path in labelDetails ("(use std::collections::HashMap)"),
                        -- strip the use-wrapper and show it when it is a real
                        -- module path, otherwise fall back to a source tag
                        before = function(entry, vim_item)
                            local details = entry.completion_item.labelDetails or {}
                            local text = details.detail or details.description or ""
                            -- rust-analyzer marks importable items as
                            -- "(use std::collections::HashMap)"; anything else
                            -- already carrying a module path we take as-is
                            local origin = text:match("^%(use%s+(.-)%)$")
                            if not origin and text:find("::") then
                                origin = text
                            end
                            if origin and origin ~= "" then
                                vim_item.menu = origin
                            else
                                vim_item.menu = ({
                                    nvim_lsp = "[lsp]",
                                    luasnip  = "[snip]",
                                    buffer   = "[buf]",
                                    path     = "[path]",
                                })[entry.source.name]
                            end
                            return vim_item
                        end,
                    }),
                },
                experimental = {
                    ghost_text = true,
                },
                sorting = {
                    priority_weight = 2,
                    comparators = {
                        cmp.config.compare.offset,
                        cmp.config.compare.exact,
                        cmp.config.compare.score,
                        cmp.config.compare.recently_used,
                        cmp.config.compare.locality,
                        cmp.config.compare.kind,
                        cmp.config.compare.sort_text,
                        cmp.config.compare.length,
                        cmp.config.compare.order,
                    },
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<Tab>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" }, 
                    { name = "path" }, 
                }, {
                        { name = "buffer" },
                    }),
            })

            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    { name = 'cmdline' }
                })
            })

            cmp.setup.cmdline({ '/', '?' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })

        end,
    },
}
