return {
  "zbirenbaum/copilot.lua",
  dependencies = { "hrsh7th/nvim-cmp" },

  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = false,
        auto_trigger = true,
      },
      panel = { enabled = false },
    })
  end,
}
