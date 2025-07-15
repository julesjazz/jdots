-- Colorscheme
vim.cmd("colorscheme github_dark")

-- NvimTree config
require("nvim-tree").setup({})
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

-- ToggleTerm config
require("toggleterm").setup({
  size = 15,
  open_mapping = [[<C-\>]],
  direction = "horizontal",
  start_in_insert = true,
  insert_mappings = true,
  terminal_mappings = true,
})
vim.keymap.set("n", "<leader>t", ":ToggleTerm<CR>", { desc = "Toggle terminal" })
