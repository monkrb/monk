require File.expand_path("helper", File.dirname(__FILE__))

# monk init NAME
scope do
  test "fail if the target working directory is not empty" do
    Dir.chdir(root("test", "tmp")) do
      FileUtils.rm_rf("monk-test")
      FileUtils.mkdir("monk-test")

      Dir.chdir("monk-test") do
        FileUtils.touch("foobar")
      end

      out, err = monk("init monk-test")
      assert out.match(/error/)
    end
  end

  test "create a skeleton app in the target directory" do
    Dir.chdir(root("test", "tmp")) do
      FileUtils.rm_rf("monk-test")

      out, err = monk("init monk-test")
      assert out.match(/initialized.* monk-test/)
    end
  end

  test "be able to pull from a url instead of a known skeleton" do
    Dir.chdir(root("test", "tmp")) do
      FileUtils.rm_rf "monk-test"
      out, err = monk("init monk-test --skeleton git://github.com/monkrb/skeleton.git")
      assert out.match(/initialized.* monk-test/)
    end
  end
end
