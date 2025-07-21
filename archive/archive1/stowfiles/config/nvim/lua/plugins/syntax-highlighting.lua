-- ~/.config/nvim/lua/plugins/syntax-highlighting.lua
-- Complete syntax highlighting setup for your file types
-- Supports: AWS, GCloud, Azure, GitLab, Kubernetes, and general cloud development
--
-- Cloud Platform Coverage:
-- • AWS: CloudFormation, SAM, CDK, CLI configs
-- • GCloud: Cloud Build, Deployment Manager, gcloud configs  
-- • Azure: ARM templates, DevOps pipelines, PowerShell
-- • GitLab: CI/CD pipelines, GitLab Runner configs
-- • Kubernetes: Manifests, Helm charts, Kustomize, CRDs, Operators
-- • Shell: Bash, Zsh, Fish, Nushell support
-- • General: Terraform, Docker, Kubernetes, Helm

return {
  -- Treesitter - handles most syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-context",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    opts = {
      ensure_installed = {
        -- Core languages (confirmed working)
        "javascript", "typescript", "tsx",
        "python", "bash", "ruby", "sql", "css", "scss",
        "html", "json", "yaml", "toml", "xml", "dockerfile",
        "terraform", "markdown", "svelte", "lua", "vim",
        "go", "c_sharp", "powershell",
        
        -- DevOps/Cloud (confirmed working)
        "hcl", "proto", "graphql", "jsonnet",
        "make", "diff", "gitignore", "gitattributes", "gitcommit",
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
    },
  },

  -- Specialized plugins for languages not fully covered by Treesitter
  {
    "hashivim/vim-terraform",
    ft = { "terraform", "tf", "tfvars" },
    config = function()
      vim.g.terraform_align = 1
      vim.g.terraform_fmt_on_save = 1
    end,
  },

  {
    "PProvost/vim-ps1",
    ft = { "ps1", "psm1", "psd1" },
  },

  {
    "evanleck/vim-svelte",
    ft = "svelte",
  },

  {
    "cespare/vim-toml",
    ft = "toml",
  },

  {
    "ekalinin/Dockerfile.vim",
    ft = "dockerfile",
  },

  {
    "martinda/Jenkinsfile-vim-syntax",
    ft = "Jenkinsfile",
  },

  -- SQL tools (optional but useful)
  {
    "tpope/vim-dadbod",
    ft = "sql",
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
  },

  -- Enhanced web development
  {
    "hail2u/vim-css3-syntax",
    ft = { "css", "scss", "sass" },
  },

  {
    "cakebaker/scss-syntax.vim",
    ft = { "scss", "sass" },
  },

  -- GraphQL (common in modern web development)
  {
    "jparise/vim-graphql",
    ft = { "graphql", "gql" },
  },

  -- JSON with comments support
  {
    "kevinoid/vim-jsonc",
    ft = { "json", "jsonc" },
  },

  -- YAML enhancements
  {
    "stephpy/vim-yaml",
    ft = { "yaml", "yml" },
  },

  -- Kubernetes/Helm YAML validation
  {
    "towolf/vim-helm",
    ft = { "yaml", "yml" },
  },

  -- Kubernetes enhanced YAML support
  {
    "andrewstuart/vim-kubernetes",
    ft = { "yaml", "yml" },
  },

  -- Kustomize support
  {
    "Glench/Vim-Jinja2-Syntax",
    ft = { "yaml", "yml", "j2" },
  },

  -- Kubernetes enhanced YAML support with folding
  {
    "pedrohdz/vim-yaml-folds",
    ft = { "yaml", "yml" },
    config = function()
      vim.g.yaml_folds = 1
    end,
  },

  -- Go (many Kubernetes tools written in Go)
  {
    "ray-x/go.nvim",
    ft = { "go", "gomod", "gosum" },
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
  },

  -- Skaffold (Kubernetes CI/CD)
  {
    "vim-scripts/yaml.vim",
    ft = { "yaml", "yml" },
  },

  -- GitHub Actions workflow files
  {
    "yasuhiroki/github-actions-yaml.vim",
    ft = { "yaml", "yml" },
  },

  -- GitLab CI/CD
  {
    "aklt/plantuml-syntax",
    ft = { "yaml", "yml" },
  },

  -- AWS CloudFormation
  {
    "luochen1990/rainbow", -- Helps with nested CloudFormation
    ft = { "yaml", "yml", "json" },
  },

  -- Cloud Build (Google Cloud)
  {
    "cappyzawa/starlark.vim",
    ft = { "star", "bzl", "BUILD" },
  },

  -- Azure ARM Templates & DevOps
  {
    "PProvost/vim-ps1", -- Already included above but worth noting for Azure
    ft = { "ps1", "psm1", "psd1" },
  },

  -- Nginx configuration
  {
    "chr4/nginx.vim",
    ft = { "nginx", "conf" },
  },

  -- Ansible playbooks
  {
    "pearofducks/ansible-vim",
    ft = { "yaml", "yml" },
  },

  -- Packer (HashiCorp) templates
  {
    "hashivim/vim-packer",
    ft = { "pkr.hcl", "pkr.json" },
  },

  -- HCL (HashiCorp Configuration Language) - for Consul, Vault, etc.
  {
    "hashivim/vim-hashicorp-tools",
    ft = { "hcl", "nomad", "consul", "vault" },
  },

  -- Protocol Buffers (common in cloud APIs)
  {
    "uarun/vim-protobuf",
    ft = { "proto" },
  },

  -- OpenAPI/Swagger specifications (enhanced YAML support)
  {
    "cuducos/yaml.nvim",
    ft = { "yaml", "yml" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
    },
  },

  -- REST API files (common with OpenAPI)
  {
    "diepm/vim-rest-console",
    ft = { "rest", "http" },
  },

  -- Jsonnet (used in some cloud configurations)
  {
    "google/vim-jsonnet",
    ft = { "jsonnet", "libsonnet" },
  },

  -- JQ (JSON processor - useful for cloud APIs)
  {
    "vito-c/jq.vim",
    ft = { "jq" },
  },

  -- .env files (common in cloud deployments)
  {
    "tpope/vim-dotenv",
    ft = { "env" },
  },

  -- Enhanced shell support
  {
    "chrisbra/vim-zsh",
    ft = { "zsh", "sh" },
  },

  {
    "dag/vim-fish",
    ft = { "fish" },
  },

  {
    "LhKipp/nvim-nu",
    ft = { "nu" },
  },

  -- C# support (if you want more than just syntax)
  {
    "OmniSharp/omnisharp-vim",
    ft = { "cs", "csx", "csproj", "sln", "slnx", "props", "csproj", "vb", "vbproj", "fsproj", "fsx", "fsi" },
    build = function()
      -- Only build if dotnet is available
      if vim.fn.executable('dotnet') == 1 then
        return "dotnet build"
      end
    end,
    config = function()
      vim.g.OmniSharp_highlight_types = 2
      vim.g.OmniSharp_selector_ui = 'telescope'
    end,
  },
}