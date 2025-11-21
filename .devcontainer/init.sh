#!/bin/bash
# Post-creation initialization script for the devcontainer
set -ex
# Install Azure Developer CLI (azd)
curl -fsSL https://aka.ms/install-azd.sh | bash

