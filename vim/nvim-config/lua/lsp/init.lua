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

-----------------------------------------------------------------
-- END VARIABLE INIT

----------------------------------------------------------------
-- START LSP SETUP FUNCTIONS
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "rust_analyzer", "ts_ls", "denols", "cssls", "eslint", "html", "marksman", "jdtls",
    -- "gdscript", --
     "volar", "tailwindcss" },
  automatic_installation = true,
  handlers = {
    -- Generic handler for any server without a specific configuration.
    function(server_name)
      require('lspconfig')[server_name].setup({
        on_attach = on_attach,
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        flags = lsp_flags,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
            ok = { "italic" }
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
            ok = { "underline" }
          },
          inlay_hints = {
            background = true
          }
        }
      })
    end,
    rust_analyzer = function()
      require('lspconfig').rust_analyzer.setup({
        on_attach = on_attach
      })
    end,
    -- gdscript = function()
    --   require 'lspconfig'.gdscript.setup({
    --     on_attach = on_attach
    --   })
    -- end,
    pyright = function()
      require('lspconfig').pyright.setup({
        on_attach = on_attach,
        flags = lsp_flags
      })
    end,
    lua_ls = function()
      require('lspconfig').lua_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" }
            },
            -- library = { } tells the lua server where some external libs that neovim uses are.
            -- It's VERY useful for hacking on Neovim
            -- You'll get completion on vim. !
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
      })
    end,
    volar = function()
      require('lspconfig').volar.setup({
        on_attach = on_attach,
        filetypes = { 'vue' },
        init_options = {
          typescript = {
            tsdk = vim.fn.expand('$HOME/node_modules/typescript/lib')
            -- Or if using nvm: vim.fn.expand('$HOME/.nvm/versions/node/*/lib/node_modules/typescript/lib')
          },
          vue = {
            hybridMode = true, -- Enable template type checking
            complete = {
              codeActionKinds = { "quickfix", "refactor", "refactor.extract", "refactor.inline",
                "refactor.rewrite" }
            }
          }
        }
      })
    end,
    tailwindcss = function()
      require('lspconfig').tailwindcss.setup({
        on_attach = on_attach,
        capabilities = capabilities,
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
        filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" }
      })
    end,    
    ts_ls = function()
      require('lspconfig').ts_ls.setup({
        on_attach = on_attach,
        root_dir = require('lspconfig').util.root_pattern("package.json"),
        single_file_support = false,
        capabilities = capabilities,
        filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact",
          "javascript.jsx" },
        cmd = { "typescript-language-server", "--stdio" },
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
      })
    end,
    denols = function()
      require('lspconfig').denols.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = require('lspconfig').util.root_pattern("deno.json", "deno.jsonc"),
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
      })
    end
  }
})

local null_ls = require("null-ls")

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.prettier.with({
      filetypes = { "css", "scss", "html", "json", "yaml", "markdown", "graphql", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
      extra_args = { "--single-quote", "--tab-width", "2", "--print-width", "100" }
    }),
    null_ls.builtins.code_actions.eslint,
    null_ls.builtins.diagnostics.eslint.with({
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" }
    }),
    null_ls.builtins.formatting.eslint.with({
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" }
    }),
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({
            bufnr = bufnr,
            filter = function(formatting_client)
              return formatting_client.name == "prettier"
            end,
            async = true,
            callback = function()
              vim.lsp.buf.format({
                bufnr = bufnr,
                filter = function(formatting_client)
                  return formatting_client.name == "eslint"
                end,
              })
            end,
          })
        end,
      })
    end
  end,
})

-- gitlinker https://github.com/ruifm/gitlinker.nvim
require("gitlinker").setup({
  opts = {
    -- Add your configuration options here
    mappings = "<leader>gy", -- Default keymap to generate the link
  },
  callbacks = {
    ["github.com"] = require("gitlinker.hosts").get_github_type_url,
    ["gitlab.com"] = require("gitlinker.hosts").get_gitlab_type_url,
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
  mappings = "<leader>gy",
})

require("nvim-lightbulb").setup({
  autocmd = {
    enabled = true
  }
})
require("lsp.cmp")
