require File.expand_path("helper", File.dirname(__FILE__))

# monk add NAME REPOSITORY
scope do
  test "add the named repository to the configuration" do
    monk("add foobar git://github.com/monkrb/foo.git")
    out, err = monk("show foobar")
    assert out["foobar"]
    assert out["git://github.com/monkrb/foo.git"]
    monk("rm foobar")
  end

  test "allow to fetch from the added repository when using the skeleton parameter" do
    monk("add glue git://github.com/monkrb/glue.git")

    Dir.chdir(root("test", "tmp")) do
      FileUtils.rm_rf("monk-test")
      FileUtils.mkdir("monk-test")

      out, err = monk("init monk-test --skeleton glue")
      assert out.match(/initialized/)
      assert out.match(/glue.git/)
    end
  end

  test "allow to fetch from the added repository when using the s parameter" do
    monk("add glue git://github.com/monkrb/glue.git")

    Dir.chdir(root("test", "tmp")) do
      FileUtils.rm_rf("monk-test")
      FileUtils.mkdir("monk-test")

      out, err = monk("init monk-test -s glue")
      assert out.match(/initialized/)
      assert out.match(/glue.git/)
    end
  end
end
