require File.expand_path("helper", File.dirname(__FILE__))

# monk show NAME
scope do
  test "display the repository for NAME" do
    out, err = monk("show default")
    assert out["git://github.com/monkrb/skeleton.git"]
  end

  test "display nothing if NAME is not set" do
    out, err = monk("show foobar")
    assert out["repository not found"]
  end
end
