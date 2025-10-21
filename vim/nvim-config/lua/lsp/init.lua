-- mason is an improvement on lsp-installer
-- it keeps the language servers seperate from your system
local mason_ok, mason = pcall(require, "mason")
if not mason_ok then
    return
end
local navbuddy = require("nvim-navbuddy")

-- INIT VARIABLES ------------------------------------
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = {
    noremap = true,
    silent = true
}
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
-- this is the default on_attach function, which can be overridden below.
local on_attach = function(client, bufnr)
    -- Attach navbuddy only if the server supports documentSymbols
    if client.server_capabilities.documentSymbolProvider then
        local navbuddy = require("nvim-navbuddy")
        navbuddy.attach(client, bufnr)
    end

    -- Prefer null-ls for formatting to avoid duplicate providers causing slowdowns.
    if client.name == "eslint" then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
    end

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = {
        noremap = true,
        silent = true,
        buffer = bufnr
    }
    vim.keymap.set("n", "<space>D", vim.lsp.buf.declaration, bufopts)
    vim.keymap.set("n", "<space>d", vim.lsp.buf.definition, bufopts)
    vim.keymap.set("n", "<space>h", vim.lsp.buf.hover, bufopts)
    vim.keymap.set("n", "<space>i", vim.lsp.buf.implementation, bufopts)
    vim.keymap.set("n", "<C-i>", vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
    vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
    vim.keymap.set("n", "<space>gr", vim.lsp.buf.references, bufopts)
    vim.keymap.set("n", "<space>f", function()
        vim.lsp.buf.format({
            async = true
        })
    end, bufopts)
end

local lsp_flags = {
    -- This is the default in Nvim 0.7+
    debounce_text_changes = 150
}

-- mason-lspconfig v2 expects Neovim 0.10's vim.lsp.config and vim.lsp.enable.
-----------------------------------------------------------------
-- END VARIABLE INIT

----------------------------------------------------------------
-- START LSP SETUP FUNCTIONS
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {"lua_ls", "ts_ls", "denols", "cssls", "eslint", "html", "marksman", "jdtls", "tailwindcss"},
    automatic_installation = true,
    automatic_enable = false
})
local lsp_defaults = require("lspconfig.configs")
local lsp_util = require("lspconfig.util")
local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()

local base_opts = {
    on_attach = on_attach,
    capabilities = cmp_capabilities,
    flags = lsp_flags,
    autostart = true,
    native_lsp = {
        enabled = true,
        virtual_text = {
            errors = {"italic"},
            hints = {"italic"},
            warnings = {"italic"},
            information = {"italic"},
            ok = {"italic"}
        },
        underlines = {
            errors = {"underline"},
            hints = {"underline"},
            warnings = {"underline"},
            information = {"underline"},
            ok = {"underline"}
        },
        inlay_hints = {
            background = true
        }
    }
}

local function extend_opts(extra)
    return vim.tbl_deep_extend("force", {}, base_opts, extra or {})
end

local server_specific = {
    lua_ls = function()
        return {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = {"vim"}
                    },
                    workspace = {
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.stdpath("config") .. "/lua"] = true,
                            ["/usr/share/awesome/lib/awful"] = true,
                            ["/usr/share/awesome/lib/beautiful"] = true,
                            ["/usr/share/awesome/lib/gears"] = true,
                            ["/usr/share/awesome/lib/naughty"] = true,
                            ["/usr/share/awesome/lib/wibox"] = true
                        }
                    }
                }
            }
        }
    end,
    tailwindcss = function()
        return {
            settings = {
                tailwindCSS = {
                    lint = {
                        cssConflict = "warning",
                        invalidApply = "error",
                        invalidScreen = "error",
                        invalidVariant = "error",
                        invalidConfigPath = "error"
                    },
                    validate = true
                }
            },
            filetypes = {"html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact"}
        }
    end,
    ts_ls = function()
        return {
            root_dir = lsp_util.root_pattern("package.json"),
            single_file_support = false,
            filetypes = {"typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "javascript.jsx"},
            cmd = {"typescript-language-server", "--stdio"},
            init_options = {
                preferences = {
                    disableSuggestions = false
                },
                tsserver = {
                    useSyntaxServer = "auto"
                }
            },
            settings = {
                typescript = {
                    format = {
                        indentSize = 2,
                        convertTabsToSpaces = true,
                        tabSize = 2
                    },
                    inlayHints = {
                        includeInlayEnumMemberValueHints = true,
                        includeInlayFunctionLikeReturnTypeHints = true,
                        includeInlayFunctionParameterTypeHints = true,
                        includeInlayParameterNameHints = "all",
                        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                        includeInlayPropertyDeclarationTypeHints = true,
                        includeInlayVariableTypeHints = true
                    }
                },
                javascript = {
                    format = {
                        indentSize = 2,
                        convertTabsToSpaces = true,
                        tabSize = 2
                    },
                    inlayHints = {
                        includeInlayEnumMemberValueHints = true,
                        includeInlayFunctionLikeReturnTypeHints = true,
                        includeInlayFunctionParameterTypeHints = true,
                        includeInlayParameterNameHints = "all",
                        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                        includeInlayPropertyDeclarationTypeHints = true,
                        includeInlayVariableTypeHints = true
                    }
                }
            }
        }
    end,
    denols = function()
        return {
            root_dir = lsp_util.root_pattern("deno.json", "deno.jsonc"),
            init_options = {
                lint = true
            },
            suggest = {
                imports = {
                    hosts = {
                        ["https://deno.land"] = true
                    }
                }
            }
        }
    end
}

local managed_servers = {
    "lua_ls",
    "ts_ls",
    "denols",
    "cssls",
    "eslint",
    "html",
    "marksman",
    "jdtls",
    "tailwindcss",
    "pyright"
}

for _, server_name in ipairs(managed_servers) do
    local defaults = {}
    local default_entry = lsp_defaults[server_name]
    if default_entry and default_entry.default_config then
        defaults = vim.deepcopy(default_entry.default_config)
    end
    local extra = server_specific[server_name] and server_specific[server_name]() or nil
    vim.lsp.config(server_name, vim.tbl_deep_extend("force", defaults, extend_opts(extra)))
    vim.schedule(function()
        pcall(vim.lsp.enable, server_name)
    end)
end

local null_ls = require("null-ls")

local augroup = vim.api.nvim_create_augroup("UserNullLsFormat", { clear = true })

local format_filetypes = {
    javascript = true,
    javascriptreact = true,
    typescript = true,
    typescriptreact = true,
    css = true,
    scss = true,
    html = true,
    json = true,
    yaml = true,
    markdown = true,
    graphql = true,
}

vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    callback = function(opts)
        local bufnr = opts.buf
        local ft = vim.bo[bufnr].filetype
        if not format_filetypes[ft] then
            return
        end

        local has_null_ls = false
        local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
        for _, client in ipairs(clients) do
            if client.name == "null-ls" and client.supports_method("textDocument/formatting") then
                has_null_ls = true
                break
            end
        end

        if not has_null_ls then
            vim.notify(string.format("[null-ls] skipping format for %s (null-ls not attached)", ft), vim.log.levels.INFO)
            return
        end

        vim.notify(string.format("[null-ls] formatting %s", ft), vim.log.levels.INFO)
        vim.lsp.buf.format({
            bufnr = bufnr,
            filter = function(client)
                return client.name == "null-ls"
            end,
            async = false,
            timeout_ms = 5000,
        })
    end,
})

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.prettier.with({
            filetypes = {
                "css",
                "scss",
                "html",
                "json",
                "yaml",
                "markdown",
                "graphql",
                "javascript",
                "javascriptreact",
                "typescript",
                "typescriptreact",
            },
            extra_args = {"--single-quote", "--tab-width", "2", "--print-width", "100"},
        }),
        null_ls.builtins.code_actions.eslint,
        null_ls.builtins.diagnostics.eslint.with({
            filetypes = {"javascript", "javascriptreact", "typescript", "typescriptreact"},
        }),
    },
})

-- gitlinker https://github.com/ruifm/gitlinker.nvim
require("gitlinker").setup({
    opts = {
        -- Add your configuration options here
        mappings = "<leader>gy" -- Default keymap to generate the link
    },
    callbacks = {
        ["github.com"] = require("gitlinker.hosts").get_github_type_url,
        ["gitlab.com"] = require("gitlinker.hosts").get_gitlab_type_url
        -- Add more hosts if needed
    },
    -- Default remote to use
    remote = nil,
    -- Default branch to use
    branch = "main",
    -- Default action to perform
    action_callback = require("gitlinker.actions").open_in_browser,
    -- Print the URL after performing the action
    print_url = true,
    -- Mapping to call the action
    mappings = "<leader>gy"
})

require("nvim-lightbulb").setup({
    autocmd = {
        enabled = true
    }
})
require("lsp.cmp")
