# dotfiles updated workflow

Assuming dotfiles have been downloaded from git.
# New System Install
1. set up .env files
    - fill this out appropriately
2. install asdf via package manager
3. install core asdf tools (python mostly)
4. start ansible to update and deploy
    - ansible should handle installs from there
    - TODO: unsure of ansible handling config options
# Backup and update
1. set up backup method and schedule
    - TODO: how to sync backups?
2. set up global update method and schedule
    - TODO: how to push to git
    - autopush?
    - branch per computer or lean on ansible to config this

# Add security check
1. bake-in security to backup and update process

# Wrap it up.
1. move to secure repo
2. test on other computers

## Other
- backup and restore scripts for terminal and IDE apps
    - ref tldr/tealdeer also
- method to auto load and update zsh and similar plugins 
