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
  silent = true,
}
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
-- this is the default on_attach function, which can be overridden below.
local on_attach = function(client, bufnr)
  -- Debug: verify function is being called
  vim.notify("LSP on_attach called for " .. client.name .. " on buffer " .. bufnr, vim.log.levels.INFO)
  
  -- Attach navbuddy only if the server supports documentSymbols
  if client.server_capabilities.documentSymbolProvider then
    local navbuddy = require("nvim-navbuddy")
    navbuddy.attach(client, bufnr)
  end

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  -- Create buffer-local keymaps - use nvim_buf_set_keymap for maximum compatibility
  local bufmap_opts = { noremap = true, silent = true }
  
  -- Go to declaration (will fallback to definition if declaration not supported)
  local success1, err1 = pcall(function()
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>D", "<cmd>lua vim.lsp.buf.declaration()<CR>", bufmap_opts)
  end)
  if not success1 then
    vim.notify("Failed to set <space>D mapping: " .. tostring(err1), vim.log.levels.ERROR)
  end
  
  local success2, err2 = pcall(function()
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>d", "<cmd>lua vim.lsp.buf.definition()<CR>", bufmap_opts)
  end)
  if not success2 then
    vim.notify("Failed to set <space>d mapping: " .. tostring(err2), vim.log.levels.ERROR)
  end
  -- Set remaining mappings with error handling
  local mappings = {
    { "<space>h", "<cmd>lua vim.lsp.buf.hover()<CR>", "hover" },
    { "<space>i", "<cmd>lua vim.lsp.buf.implementation()<CR>", "implementation" },
    { "<C-i>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", "signature_help" },
    { "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", "add_workspace_folder" },
    { "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", "remove_workspace_folder" },
    { "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", "rename" },
    { "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", "code_action" },
    { "<space>gr", "<cmd>lua vim.lsp.buf.references()<CR>", "references" },
    { "<space>f", "<cmd>lua vim.lsp.buf.format({async=true})<CR>", "format" },
  }
  
  for _, mapping in ipairs(mappings) do
    local success, err = pcall(function()
      vim.api.nvim_buf_set_keymap(bufnr, "n", mapping[1], mapping[2], bufmap_opts)
    end)
    if not success then
      vim.notify("Failed to set " .. mapping[3] .. " mapping: " .. tostring(err), vim.log.levels.ERROR)
    end
  end
  
  -- Verify mappings were set
  vim.notify("LSP mappings set for buffer " .. bufnr, vim.log.levels.INFO)
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

-----------------------------------------------------------------
-- END VARIABLE INIT

----------------------------------------------------------------
-- START LSP SETUP FUNCTIONS
local capabilities = require("cmp_nvim_lsp").default_capabilities()
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "rust_analyzer",
    "ts_ls",
    -- "denols",
    "cssls",
    "eslint",
    "html",
    "marksman",
    "jdtls",
    -- "gdscript", --
    "volar",
    "tailwindcss",
  },
  automatic_installation = true,
  handlers = {
    -- Generic handler for any server without a specific configuration.
    function(server_name)
      require("lspconfig")[server_name].setup({
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
            ok = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
            ok = { "underline" },
          },
          inlay_hints = {
            background = true,
          },
        },
      })
    end,
    -- rust_analyzer = function()
    --   require("lspconfig").rust_analyzer.setup({
    --     on_attach = on_attach,
    --   })
    -- end,
    -- gdscript = function()
    --   require 'lspconfig'.gdscript.setup({
    --     on_attach = on_attach
    --   })
    -- end,
    pyright = function()
      require("lspconfig").pyright.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
      })
    end,
    lua_ls = function()
      require("lspconfig").lua_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
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
                ["/usr/share/awesome/lib/wibox"] = true,
              },
            },
          },
        },
      })
    end,
    volar = function()
      require("lspconfig").volar.setup({
        on_attach = on_attach,
        filetypes = { "vue" },
        capabilities = capabilities,
        init_options = {
          typescript = { -- tsdk = vim.fn.expand('$HOME/node_modules/typescript/lib') -- if not using nvm
            vim.fn.expand("$HOME/.nvm/versions/node/*/lib/node_modules/typescript/lib"),
          },
          vue = {
            hybridMode = true, -- Enable template type checking
            complete = {
              codeActionKinds = {
                "quickfix",
                "refactor",
                "refactor.extract",
                "refactor.inline",
                "refactor.rewrite",
              },
            },
          },
        },
      })
    end,
    tailwindcss = function()
      require("lspconfig").tailwindcss.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          tailwindCSS = {
            lint = {
              cssConflict = "warning",
              invalidApply = "error",
              invalidScreen = "error",
              invalidVariant = "error",
              invalidConfigPath = "error",
            },
            validate = true,
          },
        },
        filetypes = {
          "html",
          "css",
          "scss",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "vue",
        },
      })
    end,
    ts_ls = function()
      require("lspconfig").ts_ls.setup({
        on_attach = on_attach,
        root_dir = require("lspconfig").util.root_pattern("package.json"),
        single_file_support = false,
        capabilities = capabilities,
        filetypes = {
          "typescript",
          "typescriptreact",
          "typescript.tsx",
          "javascript",
          "javascriptreact",
          "javascript.jsx",
        },
        cmd = { "typescript-language-server", "--stdio" },
        init_options = {
          preferences = {
            disableSuggestions = false,
          },
          tsserver = {
            useSyntaxServer = "auto",
          },
        },
        settings = {
          typescript = {
            format = {
              indentSize = 2,
              convertTabsToSpaces = true,
              tabSize = 2,
            },
            inlayHints = {
              includeInlayEnumMemberValueHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
          },
          javascript = {
            format = {
              indentSize = 2,
              convertTabsToSpaces = true,
              tabSize = 2,
            },
            inlayHints = {
              includeInlayEnumMemberValueHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
          },
        },
      })
    end,
    -- denols = function()
    --   require("lspconfig").denols.setup({
    --     on_attach = on_attach,
    --     capabilities = capabilities,
    --     root_dir = require("lspconfig").util.root_pattern("deno.json", "deno.jsonc"),
    --     init_options = {
    --       lint = true,
    --     },
    --     suggest = {
    --       imports = {
    --         hosts = {
    --           ["https://deno.land"] = true,
    --         },
    --       },
    --     },
    --   })
    -- end,
  },
})

local null_ls = require("null-ls")

local augroup = vim.api.nvim_create_augroup("LspFormatting", {
  clear = true,
}) -- Added clear = true

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
        "vue",
      },
      -- extra_args = {"--single-quote", "--tab-width", "2", "--print-width", "100"}
    }),
    null_ls.builtins.formatting.stylua,
  },

  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") and client.name == "prettier" then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      --   vim.api.nvim_create_autocmd("BufWritePre", {
      --     group = augroup,
      --     buffer = bufnr,
      --     callback = function()
      --       vim.lsp.buf.format({
      --         bufnr = bufnr,
      --         -- Important: We only call prettier here.
      --         -- If you wanted more, you'd chain or rely on a generic format call.
      --         filter = function(formatting_client)
      --           return formatting_client.name == "prettier"
      --         end,
      --         async = true,
      --       })
      --     end,
      --   })
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
    enabled = true,
  },
})
require("lsp.cmp")

-- Fallback: Also set mappings via autocmd to ensure they're created
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
      return
    end
    
    local bufnr = event.buf
    local bufmap_opts = { noremap = true, silent = true }
    
    -- Set all LSP keymaps
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>D", "<cmd>lua vim.lsp.buf.declaration()<CR>", bufmap_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>d", "<cmd>lua vim.lsp.buf.definition()<CR>", bufmap_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>h", "<cmd>lua vim.lsp.buf.hover()<CR>", bufmap_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>i", "<cmd>lua vim.lsp.buf.implementation()<CR>", bufmap_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-i>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", bufmap_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", bufmap_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", bufmap_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", bufmap_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", bufmap_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>gr", "<cmd>lua vim.lsp.buf.references()<CR>", bufmap_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>f", "<cmd>lua vim.lsp.buf.format({async=true})<CR>", bufmap_opts)
    
    vim.notify("LSP autocmd: Mappings set for " .. client.name .. " on buffer " .. bufnr, vim.log.levels.INFO)
  end,
})
