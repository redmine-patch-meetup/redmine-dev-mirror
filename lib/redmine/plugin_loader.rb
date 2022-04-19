# frozen_string_literal: true

# Redmine - project management software
# Copyright (C) 2006-2023  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module Redmine
  class PluginPath
    attr_reader :assets_dir, :initializer, :gemspec

    def initialize(dir, gemspec = nil)
      @dir = dir
      @gemspec = gemspec
      @assets_dir = File.join dir, 'assets'
      @initializer = File.join dir, 'init.rb'
      add_autoload_paths
    end

    def add_autoload_paths
      # Add the plugin directories to rails autoload paths
      engine_cfg = Rails::Engine::Configuration.new(self.to_s)
      engine_cfg.paths.add 'lib', eager_load: true
      engine_cfg.eager_load_paths.each do |dir|
        Rails.autoloaders.main.push_dir dir
        Rails.application.config.watchable_dirs[dir] = [:rb]
      end
    end

    def run_initializer
      load initializer if has_initializer?
    end

    def to_s
      @dir
    end

    def mirror_assets
      return unless has_assets_dir?

      destination = File.join(PluginLoader.public_directory, File.basename(@dir))

      source_files = Dir["#{assets_dir}/**/*"]
      source_dirs = source_files.select { |d| File.directory?(d)}
      source_files -= source_dirs
      unless source_files.empty?
        base_target_dir = File.join(destination, File.dirname(source_files.first).gsub(assets_dir, ''))
        begin
          FileUtils.mkdir_p(base_target_dir)
        rescue => e
          raise "Could not create directory #{base_target_dir}: " + e.message
        end
      end

      source_dirs.each do |dir|
        # strip down these paths so we have simple, relative paths we can
        # add to the destination
        target_dir = File.join(destination, dir.gsub(assets_dir, ''))
        begin
          FileUtils.mkdir_p(target_dir)
        rescue => e
          raise "Could not create directory #{target_dir}: " + e.message
        end
      end
      source_files.each do |file|
        target = File.join(destination, file.gsub(assets_dir, ''))
        unless File.exist?(target) && FileUtils.identical?(file, target)
          FileUtils.cp(file, target)
        end
      rescue => e
        raise "Could not copy #{file} to #{target}: " + e.message
      end
    end

    def has_assets_dir?
      File.directory?(@assets_dir)
    end

    def has_initializer?
      File.file?(@initializer)
    end
  end

  class PluginLoader
    class PluginIdDuplicated < StandardError; end
    # Absolute path to the directory where plugins are located
    cattr_accessor :directory
    self.directory = Rails.root.join('plugins')

    # Absolute path to the plublic directory where plugins assets are copied
    cattr_accessor :public_directory
    self.public_directory = Rails.public_path.join('plugin_assets')

    def self.create_assets_reloader
      plugin_assets_dirs = {}
      directories.each do |dir|
        plugin_assets_dirs[dir.assets_dir] = ['*']
      end
      ActiveSupport::FileUpdateChecker.new([], plugin_assets_dirs) do
        mirror_assets
      end
    end

    def self.load
      setup

      Rails.application.config.to_prepare do
        PluginLoader.directories.each(&:run_initializer)

        Redmine::Hook.call_hook :after_plugins_loaded
      end
    end

    def self.setup
      @plugin_directories = []

      Dir.glob(File.join(directory, '*')).sort.each do |dir|
        next unless File.directory?(dir)

        @plugin_directories << PluginPath.new(dir)
      end

      # If there are plugins under plugins/, do not register a gem with the same name.
      plugin_specs.each do |spec|
        dir = File.join(directory, spec.name)
        if File.directory?(dir)
          warn "WARN: \"#{spec.name}\" plugin installed as gems also exist in the \"#{dir}\" directory; use the ones in \"#{dir}\"."
          next
        end
        @plugin_directories << PluginPath.new(spec.full_gem_path, spec)
      end
    end

    def self.plugin_specs
      specs = Bundler.definition
                     .specs_for([:redmine_extension])
                     .to_a
                     .select{|s| s.name != 'bundler' && !s.metadata['redmine_plugin_id'].nil?}
      duplicates = specs.group_by{|s| s.metadata['redmine_plugin_id']}.reject{|k,v| v.one?}.keys
      raise PluginIdDuplicated.new("#{duplicates.join(",")} Duplicate plugin id") if duplicates.size > 0
      specs
    end

    def self.find_path(plugin_id:, plugin_dir:)
      path = directories.find {|d| d.gemspec.present? && d.gemspec.metadata['redmine_plugin_id'] == plugin_id.to_s }
      if path.nil?
        path = directories.find {|d| d.to_s == plugin_dir}
      end
      path
    end

    def self.directories
      @plugin_directories
    end

    def self.mirror_assets(name=nil)
      if name.present?
        directories.find{|d| d.to_s == File.join(directory, name)}.mirror_assets
      else
        directories.each(&:mirror_assets)
      end
    end
  end
end
