require "rubygems"
require "contest"
require "open3"

BINARY = File.expand_path(File.join(File.dirname(__FILE__), "..", "bin", "monk"))

class TestMonk < Test::Unit::TestCase
  context "monk init" do
    def monk(args = nil)
      out, err = nil

      Open3.popen3("ruby -rubygems #{BINARY} #{args}") do |stdin, stdout, stderr|
        out = stdout.read
        err = stderr.read
      end

      [out, err]
    end

    def sh(cmd)
      # puts cmd
      %x{#{cmd}}
    end

    should "create a skeleton app with all tests passing" do
      Dir.chdir("/tmp") do
        FileUtils.rm_rf("monk-test")

        out, err = monk("init monk-test")
        assert out[/create.* monk-test/]

        Dir.chdir("monk-test") do
          assert !File.directory?(".git")

          FileUtils.cp("config/settings.example.yml", "config/settings.yml")
          FileUtils.cp("config/redis/test.example.conf", "config/redis/test.conf")

          assert sh("redis-server config/redis/test.conf")

          sh "dep vendor glue"

          assert sh("rake")
        end
      end
    end
  end
end
