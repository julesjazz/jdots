# LazyVim Setup Guide

## Prerequisites Check
You already have:
- ✅ Neovim installed via brew
- ✅ Node.js (24.4.0) via asdf
- ✅ Python (3.13.5t) via asdf
- ✅ Rust (1.88.0) via asdf

## Step 1: Backup Existing Config (if any)
```bash
# Backup your existing neovim config if it exists
mv ~/.config/nvim ~/.config/nvim.bak

# Also backup your local state and cache
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

## Step 2: Install LazyVim
```bash
# Clone the LazyVim starter template
git clone https://github.com/LazyVim/starter ~/.config/nvim

# Remove the .git folder to make it your own
rm -rf ~/.config/nvim/.git
```

## Step 3: Install Additional Dependencies
LazyVim works better with these tools (install via brew):

```bash
# Essential tools for LazyVim
brew install ripgrep fd lazygit

# Optional but recommended
brew install fzf bat delta bottom
```

## Step 4: First Launch
```bash
# Launch neovim - LazyVim will automatically install plugins
nvim
```

On first launch, LazyVim will:
- Install the lazy.nvim plugin manager
- Download and install all configured plugins
- Set up language servers and tools

## Step 5: Post-Setup Configuration

### Check Health
Once everything is installed, run:
```vim
:checkhealth
```
This will show you what's working and what might need attention.

### Key LazyVim Features You'll Have:
- **Plugin Manager**: Lazy.nvim for fast plugin management
- **LSP Support**: Built-in Language Server Protocol support
- **Treesitter**: Advanced syntax highlighting
- **Telescope**: Fuzzy finder for files, symbols, etc.
- **Which-key**: Keybinding helper
- **Git Integration**: Via lazygit and other git tools
- **Terminal**: Integrated terminal support

### Common Keybindings:
- `<Space>` - Main leader key
- `<Space>ff` - Find files
- `<Space>fg` - Live grep
- `<Space>gg` - Open lazygit
- `<Space>e` - Toggle file explorer
- `<Space>l` - Open lazy plugin manager

## Step 6: Customization
Your config structure will be:
```
~/.config/nvim/
├── init.lua
├── lua/
│   ├── config/
│   │   ├── autocmds.lua
│   │   ├── keymaps.lua
│   │   ├── lazy.lua
│   │   └── options.lua
│   └── plugins/
│       └── (custom plugin configs)
└── stylua.toml
```

To customize:
1. Edit `lua/config/options.lua` for Neovim options
2. Edit `lua/config/keymaps.lua` for custom keybindings
3. Add new plugins in `lua/plugins/` directory

## Language Server Setup
LazyVim includes mason.nvim for easy LSP installation. Based on your asdf setup:

```vim
# In neovim, install language servers:
:Mason
```
```
Based on your file types, here are the essential Neovim plugins for syntax highlighting:
Core Language Support
lua-- JavaScript/TypeScript ecosystem
{ 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' }
-- Enable: javascript, typescript, tsx, jsx

-- Python
-- (Built into Treesitter)

-- C#/.NET
{ 'OmniSharp/omnisharp-vim' }

-- Ruby
-- (Built into Treesitter)

-- SQL
{ 'tpope/vim-dadbod' }  -- SQL execution
{ 'kristijanhusak/vim-dadbod-ui' }  -- SQL UI
-- (SQL syntax is built into Treesitter)

-- Shell scripting
-- (Built into Treesitter - bash, sh)
Configuration & Infrastructure
lua-- Terraform
{ 'hashivim/vim-terraform' }

-- Docker
{ 'ekalinin/Dockerfile.vim' }

-- YAML (Kubernetes, CI/CD)
{ 'stephpy/vim-yaml' }

-- PowerShell
{ 'PProvost/vim-ps1' }

-- TOML
{ 'cespare/vim-toml' }
Web Development
lua-- Svelte
{ 'evanleck/vim-svelte' }

-- SCSS/SASS
{ 'cakebaker/scss-syntax.vim' }

-- HTML/CSS (enhanced)
{ 'hail2u/vim-css3-syntax' }
DevOps & Utilities
lua-- Jenkinsfile
{ 'martinda/Jenkinsfile-vim-syntax' }

-- Makefile (enhanced)
{ 'peterhoeg/vim-qml' }

-- JSON with comments
{ 'kevinoid/vim-jsonc' }
One-liner Treesitter setup for LazyVim:
lua-- Add to ~/.config/nvim/lua/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "javascript", "typescript", "tsx", "jsx",
      "python", "bash", "ruby", "sql", "css", "scss",
      "html", "json", "yaml", "toml", "xml", "dockerfile",
      "terraform", "markdown", "svelte"
    }
  }
}
The SQL support includes both syntax highlighting (via Treesitter) and the excellent vim-dadbod plugin for actually running SQL queries directly from Neovim, which is very useful for database work.
```

Common servers for your stack:
- `gopls` (Go)
- `typescript-language-server` (Node.js/TypeScript)
- `pylsp` or `pyright` (Python)
- `rust-analyzer` (Rust)
- `terraform-ls` (Terraform)
- `yaml-language-server` (YAML/Kubernetes)

## Troubleshooting
- If plugins fail to install, try `:Lazy sync`
- For LSP issues, check `:LspInfo` and `:Mason`
- For Treesitter issues, try `:TSUpdate`

## Next Steps
1. Explore the default configuration
2. Customize keybindings and options
3. Add plugins specific to your workflow
4. Set up project-specific configurations