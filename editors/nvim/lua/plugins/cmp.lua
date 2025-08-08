return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {

      -- Fuentes de completado
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "petertriho/cmp-git",
      "Exafunction/windsurf.nvim",
    },

    config = function(_, opts)
      local cmp = require("cmp")

      -- Configuración base
      opts = vim.tbl_deep_extend("force", {
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        sources = {
          { name = "luasnip", group_index = 1 }, -- Máxima prioridad (snippets)
          { name = "nvim_lsp", group_index = 1 }, -- Máxima prioridad (LSP)
          { name = "emmet_vim", group_index = 1 }, -- Add Emmet as high priority source
          { name = "codeium", group_index = 2 }, -- Prioridad media (IA)
          { name = "buffer", keyword_length = 1 }, -- Bajo prioridad pero rápido
          { name = "path", keyword_length = 1 }, -- Bajo prioridad pero rápido
          { name = "nvim_lua", keyword_length = 1 }, -- Bajo prioridad pero rápido
        },
        mapping = {
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif require("luasnip").expand_or_jumpable() then
              require("luasnip").expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<C-y>"] = cmp.mapping(function()
            -- Emmet expand mapping
            if vim.fn["emmet#expandAbbrIntelligent"](1) == 1 then
              return "<C-y>"
            else
              return cmp.mapping.confirm({ select = true })()
            end
          end, { "i", "s" }),
        },
        formatting = {
          format = require("lspkind").cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
            show_labelDetails = true,
            symbol_map = {
              -- Copilot = "",
              Codeium = "",
              emmet_vim = "", -- Emmet icon
            },
            menu = {
              -- copilot = "[Copilot]",
              luasnip = "[Snip]",
              codeium = "[Codeium]",
              emmet_vim = "[Emmet]", -- Emmet menu entry
              nvim_lsp = "[LSP]",
              buffer = "[Buf]",
              path = "[Path]",
              nvim_lua = "[Lua]",
            },
          }),
        },
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
          native_menu = false,
        },
        sorting = {
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
        completion = {
          completeopt = "menu,menuone,noinsert,noselect",
          keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]],
          keyword_length = 1, -- Valor consistente
        },
        window = {
          completion = cmp.config.window.bordered({
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          }),
          documentation = cmp.config.window.bordered({
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          }),
        },
      }, opts or {})

      -- Configuración de cmp-git con manejo de errores
      local ok, _ = pcall(require, "cmp_git")
      if ok then
        require("cmp_git").setup()
      end

      -- Enable Emmet for specific filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "html", "css", "javascript", "typescript", "javascriptreact", "typescriptreact", "svelte", "vue" },
        callback = function()
          vim.cmd("EmmetInstall")
        end,
      })
    end,
  },
}
