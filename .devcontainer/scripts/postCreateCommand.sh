#!/bin/bash

cp .devcontainer/files/Gemfile.local Gemfile.local
cp .devcontainer/files/database.yml config/database.yml
cp .devcontainer/files/configuration.yml config/configuration.yml
cp .devcontainer/files/additional_environment.rb config/additional_environment.rb
cp -r .devcontainer/files/.vscode .vscode

sudo mkdir /logs
sudo touch /logs/redmine.log
sudo chown -R vscode /logs

bundle install

rake db:create
