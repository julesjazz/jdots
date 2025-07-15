# jdots dotfile goals
I have made extensive changes to the v1 dotfiles plan and removed many of the scripts that were previously set up. I have retained the help section from the previous Makefile with an outline of many desired behaviors. 

> **General**:  
> Backup key configuration files for use across multiple systems.  
> Prioritize security, simplicity, and cross-platform functionality.  

Note: while the initial iteration will be tailored for MacOS, leaave space for expanding this to different Linux/WSL platforms later.  

## General Rules
- avoid using symlinks unless explicitly instructed to
- do not edit configuration files in $HOME or $HOME/.config during the backup process
- GNU Stow will be used for configuration backups and restores
- do not back up `.history`, `.zcompdump`, or any other files that may contain compromising information

## General Process, new environment
1. Check that the package manager is available (homebrew for MacOS)
    - Install this if it isn't already.
2. Install asdf, asdf plugins, and asdf tool versions first along with dependancies for these.
    - do this before other homebrew packages to avoid accidental install of other deps
3. Restore ZSH and Bash configs located in the user home folder, these should contain a conditional pointer to config files in `~/.config/[zsh or bash]`.
4. Download desired ZSH plugins to `~./config/zsh/plugins` as referenced in `.config/.zshrc`
5. Install and restore starship configurations
6. Install homebrew formulas and casks
7. Restore `~/.gitconfig` and `~/.config/git`

## Stow and Makefile
Stow will be used to backup config files to jdots. A makefile will exist in .config that contains commands for backups and restores.
- stowed backups will be located in `jdots/stowfiles`
    - stowed files from `~` will be located in `jdots/stowfiles/home`
    - stowed files from `~/.config` will be located in `jdots/stowfiles/config`

## Scripts
- other than setting up a new environment, typical scripts should execute from their location in `~/.config/scripts/*`
- a one-time script may be added to `jdots/scripts` for deploying a new environment
- this is to avoid making too many extra script files executable during normal maintenance

## Maintenance
- update homebrew and execute scripts in `~/.config/scripts/homebrew`
- run asdf update lts in `~/.config/scripts/`
- run asdf backup
- run security-audit
- offer to add, commit, and push uupdates made to jdots

! More to add later, but this gets us started.