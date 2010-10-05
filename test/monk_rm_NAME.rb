require File.expand_path("helper", File.dirname(__FILE__))

# monk rm NAME
scope do
  test "remove the named repository from the configuration" do
    monk("add foobar git://github.com/monkrb/foo.git")
    monk("rm foobar")
    out, err = monk("show foobar")
    assert out["repository not found"]
  end
end
