#! /usr/bin/env ruby

require "thor"

class Monk < Thor
  include Thor::Actions

  desc "init", "Initialize a Monk application"
  def init(target)
    clone(source, target)
    cleanup(target)
  end

private

  def clone(source, target)
    say_status :fetching, source
    system "git clone -q --depth 1 #{source} #{target}"
  end

  def cleanup(target)
    inside(target) { remove_file ".git" }
    say_status :create, target
  end

  def source
    monk_config["default"]
  end

  def monk_config_file
    @monk_config_file ||= File.join(Thor::Util.user_home, ".monk")
  end

  def monk_config
    @monk_config ||= begin
      write_monk_config_file unless File.exists?(monk_config_file)
      @monk_config = YAML.load_file(monk_config_file)
    end
  end

  def write_monk_config_file
    create_file monk_config_file do
      config = { "default" => "git://github.com/monkrb/skeleton.git" }
      config.to_yaml
    end
  end

  def self.source_root
    "."
  end
end
