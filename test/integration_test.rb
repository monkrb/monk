require "rubygems"
require "contest"
require "hpricot"

ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))

$:.unshift ROOT

require "test/commands"

class TestMonk < Test::Unit::TestCase
  include Test::Commands

  def root(*args)
    File.join(ROOT, *args)
  end

  def monk(args = nil)
    sh("ruby -rubygems #{root "bin/monk"} #{args}")
  end

  context "monk init" do
    setup do
      @ports_to_close = []
    end

    def assert_url(url)
      assert_match /200 OK/, sh("curl -I 0.0.0.0:4567#{url}").first.split("\n").first
    end

    def test_server(cmd, port)
      binary = cmd[/^(.+?)( |$)/, 1]

      flunk "Can't find `#{binary}`." unless system("which #{binary} > /dev/null")

      kill_suspects(port)
      sh_bg(cmd)

      # Mark the port for closing on teardown, just in case the build fails.
      @ports_to_close << port if wait_for_service("0.0.0.0", port)

      doc = Hpricot(sh("curl 0.0.0.0:#{port}").first)

      assert_match /Hello, world/, doc.at("body").inner_text

      # Make sure all referenced URLs in the layout respond correctly.
      doc.search("//*[@href]").each do |node|
        assert_url node.attributes["href"]
      end

      doc.search("//*[@src]").each do |node|
        assert_url node.attributes["src"]
      end
    end

    should "create a skeleton app with all tests passing" do
      flunk "There is another server running on 0.0.0.0:4567. Suspect PIDs: #{suspects(4567).join(", ")}" if listening?("0.0.0.0", 4567)
      flunk "There is another server running on 0.0.0.0:9292. Suspect PIDs: #{suspects(9292).join(", ")}" if listening?("0.0.0.0", 9292)

      Dir.chdir(root("test", "tmp")) do
        FileUtils.rm_rf("monk-test")

        out, err = monk("init monk-test")
        assert_match /create.* monk-test/, out

        Dir.chdir("monk-test") do
          assert !File.directory?(".git")

          FileUtils.cp("config/settings.example.yml", "config/settings.yml")
          FileUtils.cp("config/redis/development.example.conf", "config/redis/development.conf")
          FileUtils.cp("config/redis/test.example.conf", "config/redis/test.conf")

          # Load Redis.
          sh "redis-server config/redis/test.conf"
          wait_for_service("0.0.0.0", 6380)

          sh "redis-server config/redis/development.conf"
          wait_for_service("0.0.0.0", 6379)

          # Vendor missing dependencies.
          sh "dep vendor monk-glue"

          assert sh("rake"), "the build didn't pass."
          assert sh("rake1.9"), "the build didn't pass under Ruby 1.9."

          test_server "ruby init.rb", 4567
          test_server "rackup", 9292

          test_server "ruby1.9 init.rb", 4567
          test_server "rackup1.9", 9292
        end
      end
    end

    def kill_suspects(port)
      list = suspects(port)

      sh "kill -9 #{list.join(" ")}" unless list.empty?
    end

    teardown do
      @ports_to_close.each do |port|
        kill_suspects port
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
