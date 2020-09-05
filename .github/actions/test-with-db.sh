#!/bin/bash

set -x

database=$1

cp ./config/database.$database.yml ./config/database.yml
bundle install --path vendor/bundle --without minimagick
bundle update
bundle exec rake db:create db:migrate
bundle exec rake test
