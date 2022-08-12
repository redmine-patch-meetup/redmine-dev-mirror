#!/bin/bash

bundle update
rake generate_secret_token

rake db:migrate
rake redmine:plugins:migrate

rake log:clear
