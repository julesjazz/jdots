#!/bin/bash
set -euo pipefail

# Update asdf plugins
asdf plugin update --all

# Node.js: install and set latest LTS
asdf install nodejs lts || true
latest_node=$(asdf list all nodejs | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -1)
asdf install nodejs $latest_node
asdf set nodejs $latest_node

# Python: install and set latest stable
latest_python=$(asdf list all python | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -1)
asdf install python $latest_python
asdf set python $latest_python

# Terraform: install and set latest stable
latest_tf=$(asdf list all terraform | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -1)
asdf install terraform $latest_tf
asdf set terraform $latest_tf

# Reshim all
asdf reshim

echo "Updated asdf tools to latest LTS/stable versions:"
asdf current 