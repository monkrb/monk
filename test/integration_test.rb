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

    should "create a skeleton app with all tests passing" do
      Dir.chdir("/tmp") do
        FileUtils.rm_rf("monk-test")

        out, err = monk("init monk-test")

        Dir.chdir("monk-test") do
          FileUtils.rm_rf(".git")

          # TODO Try once the repository contains a proper skeleton.
          # system("rake")
          # assert_equal 0, $?
        end
      end
    end
  end
end
