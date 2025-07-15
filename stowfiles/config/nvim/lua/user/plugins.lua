local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- File explorer with icons
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- Terminal
  { "akinsho/toggleterm.nvim", version = "*", config = true },

  -- Devicons
  { "nvim-tree/nvim-web-devicons" },

  -- GitHub Dark Theme
  { "projekt0n/github-nvim-theme", name = "github-theme", priority = 1000 },
})
