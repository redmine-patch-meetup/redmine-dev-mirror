# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "baz"
  spec.version = "0.0.1"
  spec.authors = ['johndoe', 'janedoe']
  spec.email = ['johndoe@example.org']

  spec.summary = "Baz Plugin"
  spec.description = "This is a gemified plugin for Redmine"
  spec.homepage = "https://example.org/plugins/baz"

  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata['allowed_push_host'] = "https://example.org"

  spec.metadata['redmine_plugin_id'] = "baz_plugin"
  spec.metadata['rubygems_mfa_required'] = "true"
  spec.files = Dir["{app,lib,config,assets,db}/**/*", "init.rb", "Gemfile", "README.rdoc"]
end
