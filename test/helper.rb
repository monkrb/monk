require "rubygems"
require "cutest"
require "fileutils"

ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))

$:.unshift ROOT

require "test/commands"

include Commands

def root(*args)
  File.join(ROOT, *args)
end

def monk(args = nil)
  sh("env MONK_HOME=#{File.join(ROOT, "test", "tmp")} ruby -rubygems #{root "bin/monk"} #{args}")
end

prepare do
  dot_monk = File.join(ROOT, "test", "tmp", ".monk")

  FileUtils.rm(dot_monk) if File.exist?(dot_monk)
end
