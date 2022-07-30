#!/bin/bash

cd /var/lib/redmine
cp .devcontainer/overwrite_files/Gemfile.local Gemfile.local
cp .devcontainer/overwrite_files/database.yml config/database.yml
cp .devcontainer/overwrite_files/configuration.yml config/configuration.yml
cp .devcontainer/overwrite_files/additional_environment.rb config/additional_environment.rb
cp -r .devcontainer/overwrite_files/.vscode .vscode
