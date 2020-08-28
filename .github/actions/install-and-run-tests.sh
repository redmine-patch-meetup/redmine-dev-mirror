#!/bin/sh

set -x

bundle install --path vendor/bundle --without minimagick
bundle update
bundle exec rake db:create db:migrate
bundle exec rake test
