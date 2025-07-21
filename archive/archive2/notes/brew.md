# Handy homebrew reference for dotfiles and package management

List brew installed with deps:
```sh
brew deps --formula --for-each $(brew leaves) | sed "s/^.*:/$(tput setaf 4)&$(tput sgr0)/"
# or
brew leaves | xargs brew deps --formula --for-each | sed "s/^.*:/$(tput setaf 4)&$(tput sgr0)/"
```
```sh
# include casks
echo -e "\n\033[1;33m### Formulae (with dependencies):\033[0m" && brew leaves | while read f; do echo -e "\033[1;34m$f:\033[0m"; brew deps --formula "$f" | sed 's/^/  - /'; done && echo -e "\n\033[1;33m### Casks:\033[0m" && brew list --cask | sed 's/^/  - /'
```