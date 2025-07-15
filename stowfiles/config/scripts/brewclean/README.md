# Brew Cleanup Scripts

This directory contains scripts for managing Homebrew packages and maintaining your brew environment.

## Scripts

### `brewclean.sh`
Comprehensive Homebrew cleanup script that:
- Updates Homebrew
- Upgrades all packages
- Cleans up old versions and cache
- Removes orphaned dependencies
- Runs `brew doctor` to check for issues
- Generates a changelog of package changes
- Saves the current brew list to `brewlist.txt`

### `install-brew-packages.sh`
Installs brew formulas and casks listed in brew list files:
- Automatically detects computer-specific or master brew list
- Extracts formulas and casks from the brew list
- Checks which packages are already installed
- Installs missing packages with confirmation
- Verifies the installation
- Provides colored output and error handling

### `sync-brew-lists.sh`
Manages synchronization between master and computer-specific brew lists:
- Syncs new packages from computer to master list
- Syncs missing packages from master to computer list
- Shows differences between master and computer lists
- Lists all available brew list files
- Provides merge functionality for multi-computer setups

## Usage

### From Makefile (Recommended)
```bash
# Clean up Homebrew and generate brew lists
make brewclean

# Install packages from brew list
make brew-install

# Sync brew lists
make brew-sync-to-master     # Add new packages to master
make brew-sync-from-master   # Get missing packages from master
make brew-sync-diff          # Show differences
make brew-sync-list          # List all brew list files

# Complete new computer setup (includes brew installation)
make setup-new
```

### Direct script execution
```bash
# Make scripts executable
chmod +x scripts/brewclean/*.sh

# Run cleanup
./scripts/brewclean/brewclean.sh

# Install packages
./scripts/brewclean/install-brew-packages.sh

# Sync brew lists
./scripts/brewclean/sync-brew-lists.sh to-master     # Add to master
./scripts/brewclean/sync-brew-lists.sh from-master   # Get from master
./scripts/brewclean/sync-brew-lists.sh diff          # Show differences
./scripts/brewclean/sync-brew-lists.sh list          # List files
```

## Files

### `brewlist.txt` (Master List)
Contains the master list of brew formulas and casks that should be available across all computers. This serves as the authoritative source for package management.

### `brewlist-{hostname}.txt` (Computer-Specific Lists)
Contains the brew list for a specific computer, identified by hostname. These files track what's actually installed on each computer and can be synced with the master list.

Both file types have the same structure:
```
# Brew Cleanup - [Date]
## Master List / Computer: [hostname]
## Added Formulas
- package1
- package2

## Removed Formulas
- package3

## Added Casks
- cask1

## Removed Casks
- cask2

---

# Brew formulas ----------------------------------------
[list of all formulas]

# Brew Casks ----------------------------------------
[list of all casks]

# Generated on: [date]
# Computer: [hostname] (for computer-specific files)
```

## New Computer Setup

When setting up jdots on a new computer, the `setup-new` target will:

1. Check if Homebrew is installed and install it if needed
2. Install all formulas and casks from the appropriate brew list (computer-specific or master)
3. Install additional dependencies for the dotfiles
4. Set up the stow packages
5. Configure shell settings
6. Verify the installation

This ensures that your new computer has all the same brew packages as your current setup.

## Multi-Computer Workflow

For managing brew packages across multiple computers:

1. **On each computer**: Run `make brewclean` to generate computer-specific brew lists
2. **Sync to master**: Run `make brew-sync-to-master` to add new packages to the master list
3. **On other computers**: Run `make brew-sync-from-master` to get new packages from master
4. **Check differences**: Run `make brew-sync-diff` to see what's different between computers
5. **Install missing packages**: Run `make brew-install` to install packages from the appropriate list

This workflow allows you to:
- Maintain a master list of all packages you use
- Track what's actually installed on each computer
- Easily sync new packages between computers
- Keep computers in sync with the master list

## Maintenance

Regular maintenance should include:
- Running `make brewclean` to clean up and update brew lists
- Running `make brew-sync-to-master` to sync new packages to master
- Running `make brew-sync-from-master` to get new packages from master
- Running `make brew-install` to install missing packages
- Running `make maintenance` for full system maintenance

## Troubleshooting

### Common Issues

1. **Permission denied errors**
   - Make sure scripts are executable: `chmod +x scripts/brewclean/*.sh`

2. **Homebrew not found**
   - The setup script will automatically install Homebrew if needed

3. **Package installation failures**
   - Some packages may require additional dependencies or system requirements
   - Check the error messages for specific issues

4. **Brew list parsing issues**
   - If `brewlist.txt` is corrupted, run `make brewclean` to regenerate it

### Getting Help

- Check Homebrew status: `brew doctor`
- View installed packages: `brew list`
- Check for issues: `make health-check` 