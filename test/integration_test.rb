require "rubygems"
require "contest"
require "open3"

BINARY = File.expand_path(File.join(File.dirname(__FILE__), "..", "bin", "monk"))
TMP = File.expand_path(File.join(File.dirname(__FILE__), "tmp"))

class TestMonk < Test::Unit::TestCase
  def monk(args = nil)
    out, err = nil

    Open3.popen3("ruby -rubygems #{BINARY} #{args}") do |stdin, stdout, stderr|
      out = stdout.read
      err = stderr.read
    end

    [out, err]
  end

  def sh(cmd)
    %x{#{cmd}}
  end

  context "monk init" do
    should "create a skeleton app with all tests passing" do
      Dir.chdir(TMP) do
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

  context "monk show NAME" do
    should "display the repository for NAME" do
      out, err = monk("show default")
      assert out["git://github.com/monkrb/skeleton.git"]
    end

    should "display nothing if NAME is not set" do
      out, err = monk("show foobar")
      assert out["repository not found"]
    end
  end

  context "monk list" do
    should "display the configured repositories" do
      out, err = monk("list")
      assert out["default"]
      assert out["git://github.com/monkrb/skeleton.git"]
    end
  end

  context "monk add NAME REPOSITORY" do
    should "add the named repository to the configuration" do
      monk("add foobar git://github.com/monkrb/foo.git")
      out, err = monk("show foobar")
      assert out["foobar"]
      assert out["git://github.com/monkrb/foo.git"]
      monk("rm foobar")
    end
  end

  context "monk rm NAME" do
    should "remove the named repository from the configuration" do
      monk("add foobar git://github.com/monkrb/foo.git")
      monk("rm foobar")
      out, err = monk("show foobar")
      assert out["repository not found"]
    end
  end
end
