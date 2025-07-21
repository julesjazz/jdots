-- ~/.config/nvim/lua/plugins/terminal-keybind.lua
-- Add cmd-shift-t (Mac) or alt-shift-t (Windows/Linux) to toggle terminal
-- Opens terminal in project root directory

return {
  "akinsho/toggleterm.nvim",
  keys = function()
    local keys = {}
    
    -- Function to find project root
    local function get_project_root()
      local root_patterns = { ".git", "package.json", "Cargo.toml", "pyproject.toml", "go.mod", ".project", ".root" }
      local current_file = vim.fn.expand("%:p")
      local current_dir = vim.fn.fnamemodify(current_file, ":h")
      
      -- If no file is open, use current working directory
      if current_file == "" then
        current_dir = vim.fn.getcwd()
      end
      
      -- Look for root patterns
      local root = vim.fs.find(root_patterns, {
        path = current_dir,
        upward = true,
      })[1]
      
      if root then
        return vim.fn.fnamemodify(root, ":h")
      end
      
      -- Fallback to current working directory
      return vim.fn.getcwd()
    end
    
    -- Detect operating system
    local is_mac = vim.fn.has("macunix") == 1
    
    if is_mac then
      -- Mac: cmd-shift-t
      keys[#keys + 1] = {
        "<D-S-t>",
        function()
          local root_dir = get_project_root()
          require("toggleterm").toggle(nil, nil, root_dir)
        end,
        desc = "Toggle Terminal (Project Root)",
        mode = { "n", "t" }
      }
    else
      -- Windows/Linux: alt-shift-t
      keys[#keys + 1] = {
        "<A-S-t>",
        function()
          local root_dir = get_project_root()
          require("toggleterm").toggle(nil, nil, root_dir)
        end,
        desc = "Toggle Terminal (Project Root)",
        mode = { "n", "t" }
      }
    end
    
    return keys
  end,
  
  config = function()
    require("toggleterm").setup({
      -- Your terminal configuration here
      size = 20,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_terminals = true,
      start_in_insert = true,
      persist_size = true,
      direction = "horizontal", -- or "vertical", "float"
      close_on_exit = true,
      shell = vim.o.shell,
      auto_scroll = true,
    })
  end,
}