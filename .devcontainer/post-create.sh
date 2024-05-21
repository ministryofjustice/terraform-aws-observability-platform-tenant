#!/usr/bin/env bash

# Upgrade Pip
pip install --break-system-packages --upgrade pip

# Install dependencies
pip install --break-system-package --requirement requirements-dev.txt
