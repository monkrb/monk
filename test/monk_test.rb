require File.join(File.dirname(__FILE__), "test_helper")

class TestMonk < Test::Unit::TestCase
  context "monk init NAME" do
    should "fail if the target working directory is not empty" do
      Dir.chdir(root("test", "tmp")) do
        FileUtils.rm_rf("monk-test")
        FileUtils.mkdir("monk-test")

        Dir.chdir("monk-test") do
          FileUtils.touch("foobar")
        end

        out, err = monk("init monk-test")
        assert_match /error/, out
      end
    end

    should "create a skeleton app in the target directory" do
      Dir.chdir(root("test", "tmp")) do
        FileUtils.rm_rf("monk-test")

        out, err = monk("init monk-test")
        assert_match /initialized.* monk-test/, out
      end
    end
  end

  context "monk init" do
    should "fail if the current working directory is not empty" do
      Dir.chdir(root("test", "tmp")) do
        FileUtils.rm_rf("monk-test")
        FileUtils.mkdir("monk-test")


        Dir.chdir("monk-test") do
          FileUtils.touch("foobar")
          out, err = monk("init")
          assert_match /error/, out
        end
      end
    end

    should "create a skeleton app in the working directory" do
      Dir.chdir(root("test", "tmp")) do
        FileUtils.rm_rf("monk-test")
        FileUtils.mkdir("monk-test")

        Dir.chdir("monk-test") do
          out, err = monk("init")
          assert_match /initialized/, out
        end
      end
    end

    should "use an alternative skeleton if the option is provided" do
      Dir.chdir(root("test", "tmp")) do
        FileUtils.rm_rf("monk-test")
        FileUtils.mkdir("monk-test")

        monk("add foobar git://github.com/monkrb/skeleton.git")

        Dir.chdir("monk-test") do
          out, err = monk("init -s foobar")
          assert_match /initialized/, out
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

    should "allow to fetch from the added repository when using the skeleton parameter" do
      monk("add glue git://github.com/monkrb/glue.git")

      Dir.chdir(root("test", "tmp")) do
        FileUtils.rm_rf("monk-test")
        FileUtils.mkdir("monk-test")

        out, err = monk("init monk-test --skeleton glue")
        assert_match /initialized/, out
        assert_match /glue.git/, out
      end
    end

    should "allow to fetch from the added repository when using the s parameter" do
      monk("add glue git://github.com/monkrb/glue.git")

      Dir.chdir(root("test", "tmp")) do
        FileUtils.rm_rf("monk-test")
        FileUtils.mkdir("monk-test")

        out, err = monk("init monk-test -s glue")
        assert_match /initialized/, out
        assert_match /glue.git/, out
      end
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
