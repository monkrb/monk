require "rack/reloader"

# TODO Add documentation.
class Monk::Reloader < Rack::Reloader
  def safe_load(file, mtime, stderr = $stderr)
    super
    Monk.reset!
    super(Monk.app_file, mtime, stderr)
  end
end
