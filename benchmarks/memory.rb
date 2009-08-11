require "fileutils"

FREE_MEMORY = ENV["FREE_MEMORY"] || "sysctl -n hw.usermem"
puts %Q{Using `#{FREE_MEMORY}` to measure free memory. Change using the FREE_MEMORY env variable.}
puts %Q{$ env FREE_MEMORY="free | awk '/Mem/ { print $4 }'" ruby benchmarks/memory.rb}

module Test
end

require File.join(File.dirname(__FILE__), "..", "test", "commands")

class Array
  def sum
    inject(nil) do |sum, x|
      sum ? sum + x : x
    end
  end

  def mean
    sum / size
  end
end

def compare_memory
  memory_used - (yield; memory_used)
end

def memory_used
  `#{FREE_MEMORY}`.to_f / 1024.0
end

class Example
  include Test::Commands

  attr :app_name
  attr :port
  attr :pid

  def initialize(app_name, port)
    @app_name = app_name
    @port = port
  end

  def binary
  end

  def binary_arguments
  end

  def generate_app
    system "#{binary} #{app_name} #{binary_arguments} >/dev/null"
  end

  def bootstrap_app

  end

  def start_server
    @pid = sh_bg("thin start -e production -p #{port} #{server_arguments}")
  end

  def server_arguments
  end

  def exercise
    start_server
    wait
    `curl 0.0.0.0:#{port} -s`
  end

  def wait
    wait_for_service("0.0.0.0", port, 10)
  end

  def inspect
    "#{app_name} (#{self.class})"
  end
end

class Rails < Example
  def binary
    "rails"
  end

  def binary_arguments
    "-q"
  end

  def bootstrap_app
    FileUtils.rm("public/index.html")
  end
end

class Monk < Example
  def binary
    "monk init"
  end

  def bootstrap_app
    FileUtils.cp("config/settings.example.yml", "config/settings.yml")
    FileUtils.cp("config/redis/test.example.conf", "config/redis/production.conf")
  end

  def server_arguments
    "-R config.ru"
  end
end

examples = [
  Monk.new("monk-app", 3001),
  Rails.new("rails-app", 3000)
]

Dir.chdir(File.dirname(__FILE__)) do
  FileUtils.mkdir("tmp") unless File.exist?("tmp")

  Dir.chdir("tmp") do

    examples.each do |example|
      FileUtils.rm_rf(example.app_name)

      example.generate_app

      Dir.chdir(example.app_name) do
        example.bootstrap_app
      end
    end

    examples.each do |example|
      Dir.chdir(example.app_name) do
        print example.inspect
        print " "

        puts Array.new(10) {
          mem = compare_memory do
            example.exercise
          end

          system "kill #{example.pid}"

          mem
        }.mean
      end
    end
  end
end
