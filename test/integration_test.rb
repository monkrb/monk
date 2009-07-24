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
      sh_bg(cmd)

      if wait_for_service("0.0.0.0", port)
        @ports_to_close << port
      end

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
        assert out[/create.* monk-test/]

        Dir.chdir("monk-test") do
          assert !File.directory?(".git")

          FileUtils.cp("config/settings.example.yml", "config/settings.yml")
          FileUtils.cp("config/redis/development.example.conf", "config/redis/development.conf")
          FileUtils.cp("config/redis/test.example.conf", "config/redis/test.conf")

          sh "redis-server config/redis/test.conf"
          wait_for_service("0.0.0.0", 6380)

          sh "dep vendor monk-glue"

          assert sh("rake")

          sh "redis-server config/redis/development.conf"
          wait_for_service("0.0.0.0", 6379)

          test_server "ruby init.rb", 4567
          test_server "rackup", 9292
        end
      end
    end

    teardown do
      sh "kill #{@ports_to_close.map {|p| suspects(p) }.flatten.join(" ")}" unless @ports_to_close.empty?
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
