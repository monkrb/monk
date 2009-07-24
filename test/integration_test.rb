require "rubygems"
require "contest"
require "open3"
require "socket"
require "hpricot"

ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))

class TestMonk < Test::Unit::TestCase
  def root(*args)
    File.join(ROOT, *args)
  end

  def sh(cmd)
    out, err = nil

    Open3.popen3(cmd) do |_in, _out, _err|
      out = _out.read
      err = _err.read
    end

    [out, err]
  end

  def monk(args = nil)
    sh("ruby -rubygems #{root "bin/monk"} #{args}")
  end

  context "monk init" do
    def listening?(host, port)
      begin
        socket = TCPSocket.new(host, port)
        socket.close unless socket.nil?
        true
      rescue Errno::ECONNREFUSED,
             Errno::EBADF,           # Windows
             Errno::EADDRNOTAVAIL    # Windows
        false
      end
    end

    def wait_for_service(host, port, timeout = 5)
      start_time = Time.now

      until listening?(host, port)
        if timeout && (Time.now > (start_time + timeout))
          raise SocketError.new("Socket did not open within #{timeout} seconds")
        end
      end
    end

    def assert_url(url)
      assert_match /200 OK/, sh("curl -I 0.0.0.0:4567#{url}").first.split("\n").first
    end

    should "create a skeleton app with all tests passing" do
      if listening?("0.0.0.0", 4567)
        suspects = sh("lsof -i :4567").first.split("\n")[1..-1].map {|s| s[/^.+?(\d+)/, 1] }
        flunk "There is another server running on 0.0.0.0:4567. Suspect PIDs: #{suspects.join(", ")}"
      end

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

          exec("ruby init.rb 2>&1 >/dev/null") if fork.nil?
          wait_for_service("0.0.0.0", 4567)

          doc = Hpricot(sh("curl 0.0.0.0:4567").first)

          assert_match /Hello, world/, doc.at("body").inner_text

          # Make sure all referenced URLs in the layout respond correctly.
          doc.search("//*[@href]").each do |node|
            assert_url node.attributes["href"]
          end

          doc.search("//*[@src]").each do |node|
            assert_url node.attributes["src"]
          end
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
