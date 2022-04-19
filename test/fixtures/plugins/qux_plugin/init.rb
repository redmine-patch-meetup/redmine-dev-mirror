# frozen_string_literal: true

Redmine::Plugin.register :baz_plugin do
  name "This name should be overwritten with gemspec 'summary'"
end
