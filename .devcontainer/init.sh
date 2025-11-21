#!/bin/bash
# Post-creation initialization script for the devcontainer
set -ex
# Install Azure Developer CLI (azd)
curl -fsSL https://aka.ms/install-azd.sh | bash

# Check if src/python directory exists, if not, skip the Python-specific setup
if [ -d "github-graphql-sample" ]; then
    cd github-graphql-sample
    # Create a fresh virtual environment using uv
    uv venv --clear
    source .venv/bin/activate
    # Get Azure environment values and save to .env
    azd env get-values > .env
    # Sync dependencies
    uv sync
else
    echo "Note: github-graphql-sample directory not found. Skipping Python-specific setup."
fi
