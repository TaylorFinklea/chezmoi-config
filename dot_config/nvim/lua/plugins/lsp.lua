return {
    -- LSP Configuration
    {
        "neovim/nvim-lspconfig",
        ---@class PluginLspOpts
        opts = {
            ---@type lspconfig.options
            servers = {
                -- Python
                pyright = {},

                -- Rust
                rust_analyzer = {
                    settings = {
                        ["rust-analyzer"] = {
                            cargo = {
                                allFeatures = true,
                                loadOutDirsFromCheck = true,
                                runBuildScripts = true,
                            },
                            -- Add clippy lints for Rust
                            checkOnSave = {
                                allFeatures = true,
                                command = "cargo",
                                extraArgs = { "clippy" },
                            },
                            procMacro = {
                                enable = true,
                                ignored = {
                                    ["async-trait"] = { "async_trait" },
                                    ["napi-derive"] = { "napi" },
                                    ["async-recursion"] = { "async_recursion" },
                                },
                            },
                        },
                    },
                },

                -- TypeScript/JavaScript
                tsserver = {},
            },

            -- LSP server setup customization
            ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
            setup = {
                -- Custom setup for TypeScript with typescript.nvim
                tsserver = function(_, opts)
                    require("typescript").setup({ server = opts })
                    return true
                end,
            },
        },
    },

    -- TypeScript support with additional features
    {
        "jose-elias-alvarez/typescript.nvim",
        dependencies = { "neovim/nvim-lspconfig" },
        init = function()
            require("lazyvim.util").lsp.on_attach(function(_, buffer)
                vim.keymap.set("n", "<leader>co", "TypescriptOrganizeImports", {
                    buffer = buffer,
                    desc = "Organize Imports"
                })
                vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", {
                    buffer = buffer,
                    desc = "Rename File"
                })
            end)
        end,
    },

    -- Mason tool installer
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                -- Lua
                "stylua",

                -- Shell
                "shellcheck",
                "shfmt",

                -- Python
                "flake8",
                "pyright",

                -- Rust
                "rust-analyzer",
                "rustfmt",

                -- TypeScript/JavaScript
                "typescript-language-server",
            },
        },
    },
}
