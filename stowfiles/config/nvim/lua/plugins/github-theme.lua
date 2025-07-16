return {
  "projekt0n/github-nvim-theme",
  lazy = false,
  priority = 1000,
  config = function()
    require('github-theme').setup({
      options = {
        -- Compiled file's destination location
        compile_path = vim.fn.stdpath('cache') .. '/github-theme',
        compile_file_suffix = '_compiled',
        hide_end_of_buffer = true, -- Hide the '~' character at the end of the buffer
        hide_nc_statusline = true, -- Override the underline style for non-active statuslines
        transparent = false, -- Disable setting background
        terminal_colors = true, -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
        dim_inactive = false, -- Non focused panes set to alternative background
        module_default = true, -- Default enable value for modules
        styles = {
          comments = 'italic',
          functions = 'NONE',
          keywords = 'NONE',
          variables = 'NONE',
          conditionals = 'NONE',
          constants = 'NONE',
          numbers = 'NONE',
          operators = 'NONE',
          strings = 'NONE',
          types = 'NONE',
        },
        inverse = {
          match_paren = false,
          visual = false,
          search = false,
        },
        darken = {
          floats = false,
          sidebars = {
            enable = true,
            list = {}, -- Apply dark background to specific windows
          },
        },
      }
    })
    
    -- Set the colorscheme to GitHub Dark Default
    vim.cmd('colorscheme github_dark_default')
  end,
}