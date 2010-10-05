require File.expand_path("helper", File.dirname(__FILE__))

# monk init
scope do
  test "fail if the current working directory is not empty" do
    Dir.chdir(root("test", "tmp")) do
      FileUtils.rm_rf("monk-test")
      FileUtils.mkdir("monk-test")


      Dir.chdir("monk-test") do
        FileUtils.touch("foobar")
        out, err = monk("init")
        assert out.match(/error/)
      end
    end
  end

  test "create a skeleton app in the working directory" do
    Dir.chdir(root("test", "tmp")) do
      FileUtils.rm_rf("monk-test")
      FileUtils.mkdir("monk-test")

      Dir.chdir("monk-test") do
        out, err = monk("init")
        assert out.match(/initialized/)
      end
    end
  end

  test "use an alternative skeleton if the option is provided" do
    Dir.chdir(root("test", "tmp")) do
      FileUtils.rm_rf("monk-test")
      FileUtils.mkdir("monk-test")

      monk("add foobar git://github.com/monkrb/skeleton.git")

      Dir.chdir("monk-test") do
        out, err = monk("init -s foobar")
        assert out.match(/initialized/)
      end
    end
  end
end
