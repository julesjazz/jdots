
```
- operating systems: mac (gui only), linux (headless and gui - debian and rhel/fedora systems)
- use case profiles: [baseline, infra-dev, dev, music, gaming ... more some day for other dev use cases]
- shells: bash and zsh to be set up baseline, (pwsh, nushell, fish) to be added optionally later
- it will be my intent to add an env deploy script as part of this later that can be called per profile
```

```sh
ansible/
├── inventory/
│   └── localhost
├── playbooks/
│   ├── local.yml               # Entry point
│   └── profiles/
│       ├── baseline.yml        # Minimal shell/tools for all
│       ├── infra-dev.yml       # AWS, Docker, Terraform, etc
│       ├── dev.yml             # Programming tools
│       └── music.yml           # Audio workflows
├── roles/
│   ├── shells/                 # Bash, Zsh, optionally pwsh/fish
│   │   ├── tasks/main.yml
│   │   └── files/shells/
│   ├── terminals/              # Ghostty, Wezterm, iTerm2
│   ├── dotfiles/               # Bootstrap configs
│   ├── packages/               # Brew/apt/dnf with pm-manager.sh fallback
│   └── infra/                  # AWS CLI, Terraform, kubectl, etc.
└── vars/
    └── profiles/
        ├── baseline.yml
        ├── dev.yml
        └── infra-dev.yml
```