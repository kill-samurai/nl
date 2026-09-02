return {
  -- Autocomplete
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },

    opts = {
      keymap = {
        preset = "super-tab",
      },

      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },

        menu = {
          auto_show = true,
        },

        ghost_text = {
          enabled = true,
        },
      },

      signature = {
        enabled = true,
      },

      sources = {
        default = {
          "lsp",
          "path",
          "snippets",
          "buffer",
        },
      },

      fuzzy = {
        implementation = "prefer_rust_with_warning",
     },
    },
  },

  -- Mason
  {
    "mason-org/mason.nvim",
    opts = {},
  },

  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },

    opts = {
      ensure_installed = {
        -- JavaScript / TypeScript / JSX / TSX
        "vtsls",

        -- HTML
        "html",

        -- Python
        "pyright",

        -- Bash / Shell
        "bashls",
      },

      automatic_enable = false,
    },
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",

    dependencies = {
      "saghen/blink.cmp",
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },

    config = function()
      ------------------------------------------------------------
      -- Completion capabilities
      ------------------------------------------------------------

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      ------------------------------------------------------------
      -- JavaScript / TypeScript / JSX / TSX
      ------------------------------------------------------------

      vim.lsp.config("vtsls", {
        capabilities = capabilities,

        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        },

        settings = {
          typescript = {
            suggest = {
              completeFunctionCalls = true,
            },

            inlayHints = {
              parameterNames = {
                enabled = "literals",
              },

              parameterTypes = {
                enabled = true,
              },

              variableTypes = {
                enabled = true,
              },

              propertyDeclarationTypes = {
                enabled = true,
              },

              functionLikeReturnTypes = {
                enabled = true,
              },
            },
          },

          javascript = {
            suggest = {
              completeFunctionCalls = true,
            },

            inlayHints = {
              parameterNames = {
                enabled = "literals",
              },

              parameterTypes = {
                enabled = true,
              },

              variableTypes = {
                enabled = true,
              },

              propertyDeclarationTypes = {
                enabled = true,
              },

              functionLikeReturnTypes = {
                enabled = true,
              },
            },
          },
        },
      })

      ------------------------------------------------------------
      -- HTML
      ------------------------------------------------------------

      vim.lsp.config("html", {
        capabilities = capabilities,

        filetypes = {
          "html",
        },
      })

      ------------------------------------------------------------
      -- Python
      ------------------------------------------------------------

      vim.lsp.config("pyright", {
        capabilities = capabilities,

        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              typeCheckingMode = "basic",
              autoImportCompletions = true,
              diagnosticMode = "openFilesOnly",
            },
          },
        },
      })

      ------------------------------------------------------------
      -- Bash / Shell
      ------------------------------------------------------------

      vim.lsp.config("bashls", {
        capabilities = capabilities,

        filetypes = {
          "sh",
          "bash",
          "zsh",
        },
      })

      ------------------------------------------------------------
      -- Enable LSP servers
      ------------------------------------------------------------

      vim.lsp.enable({
        "vtsls",
        "html",
        "pyright",
        "bashls",
      })

      ------------------------------------------------------------
      -- Diagnostics
      ------------------------------------------------------------

      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,

        float = {
          border = "rounded",
          source = true,
        },
      })

      ------------------------------------------------------------
      -- LSP keybindings
      ------------------------------------------------------------

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local opts = {
            buffer = event.buf,
            silent = true,
          }

          -- Go to definition
          vim.keymap.set(
            "n",
            "gd",
            vim.lsp.buf.definition,
            vim.tbl_extend("force", opts, {
              desc = "Go to definition",
            })
          )

          -- Go to declaration
          vim.keymap.set(
            "n",
            "gD",
            vim.lsp.buf.declaration,
            vim.tbl_extend("force", opts, {
              desc = "Go to declaration",
            })
          )

          -- Find references
          vim.keymap.set(
            "n",
            "gr",
            vim.lsp.buf.references,
            vim.tbl_extend("force", opts, {
              desc = "References",
            })
          )

          -- Go to implementation
          vim.keymap.set(
            "n",
            "gi",
            vim.lsp.buf.implementation,
            vim.tbl_extend("force", opts, {
              desc = "Go to implementation",
            })
          )

          -- Hover documentation
          vim.keymap.set(
            "n",
            "K",
            vim.lsp.buf.hover,
            vim.tbl_extend("force", opts, {
              desc = "Documentation",
            })
          )

          -- Code actions
          vim.keymap.set(
            "n",
            "<leader>ca",
            vim.lsp.buf.code_action,
            vim.tbl_extend("force", opts, {
              desc = "Code action",
            })
          )

          -- Rename symbol
          vim.keymap.set(
            "n",
            "<leader>rn",
            vim.lsp.buf.rename,
            vim.tbl_extend("force", opts, {
              desc = "Rename",
            })
          )

          -- Show diagnostic
          vim.keymap.set(
            "n",
            "<leader>d",
            vim.diagnostic.open_float,
            vim.tbl_extend("force", opts, {
              desc = "Diagnostic",
            })
          )

          -- Previous diagnostic
          vim.keymap.set(
            "n",
            "[d",
            function()
              vim.diagnostic.jump({
                count = -1,
                float = true,
              })
            end,
            vim.tbl_extend("force", opts, {
              desc = "Previous diagnostic",
            })
          )

          -- Next diagnostic
          vim.keymap.set(
            "n",
            "]d",
            function()
              vim.diagnostic.jump({
                count = 1,
                float = true,
              })
            end,
            vim.tbl_extend("force", opts, {
              desc = "Next diagnostic",
            })
          )
        end,
      })
    end,
  },
}
