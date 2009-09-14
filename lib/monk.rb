#! /usr/bin/env ruby

require "thor"
require "yaml"

class Monk < Thor
  include Thor::Actions

  [:skip, :pretend, :force, :quiet].each do |task|
    class_options.delete task
  end

  desc "init", "Initialize a Monk application"
  method_option :skeleton, :type => :string, :aliases => "-s"
  def init(target = ".")
    clone(source(options[:skeleton] || "default"), target) ?
      cleanup(target) :
      say_status(:error, clone_error(target))
  end

  desc "show NAME", "Display the repository address for NAME"
  def show(name)
    say_status name, source(name) || "repository not found"
  end

  desc "list", "Lists the configured repositories"
  def list
    monk_config.keys.sort.each do |key|
      show(key)
    end
  end

  desc "add NAME REPOSITORY", "Add the repository to the configuration file"
  def add(name, repository)
    monk_config[name] = repository
    write_monk_config_file
  end

  desc "rm NAME", "Remove the repository from the configuration file"
  def rm(name)
    monk_config.delete(name)
    write_monk_config_file
  end

private

  def clone(source, target)
    if Dir["#{target}/*"].empty?
      say_status :fetching, source
      system "git clone -q --depth 1 #{source} #{target}"
      $?.success?
    end
  end

  def cleanup(target)
    inside(target) { remove_file ".git" }
    say_status :initialized, target
  end

  def source(name = "default")
    monk_config[name]
  end

  def monk_config_file
    @monk_config_file ||= File.join(monk_home, ".monk")
  end

  def monk_config
    @monk_config ||= begin
      write_monk_config_file unless File.exists?(monk_config_file)
      YAML.load_file(monk_config_file)
    end
  end

  def write_monk_config_file
    remove_file monk_config_file
    create_file monk_config_file do
      config = @monk_config || { "default" => "git://github.com/monkrb/skeleton.git" }
      config.to_yaml
    end
  end

  def self.source_root
    "."
  end

  def clone_error(target)
    "Couldn't clone repository into target directory '#{target}'. " +
    "You must have git installed and the target directory must be empty."
  end

  def monk_home
    ENV["MONK_HOME"] || File.join(Thor::Util.user_home)
  end
end
