# frozen_string_literal: true

Redmine::Plugin.register :baz_plugin do
  name "This name should be overwritten with gemspec 'summary'"
  author_url "https://example.org/this_url_should_not_be_overwritten_with_gemspec"
end
