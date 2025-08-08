return {
  "akinsho/nvim-toggleterm.lua",
  cmd = { "TermExec", "ToggleTerm" },
  config = function()
    require("toggleterm").setup({
      hide_numbers = false,
      shade_filetypes = {},
      shade_terminals = true,
      start_in_insert = true,
      insert_mappings = false,
      persist_size = true,
      direction = "horizontal",
      close_on_exit = true,
      shell = "zsh",
      float_opts = {
        border = "curved",
        winblend = 3,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    })
  end,
}
