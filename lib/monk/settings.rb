require 'yaml'

# TODO Add documentation.
def settings(key)
  $settings ||= YAML.load_file(root_path("config", "settings.yml"))[RACK_ENV.to_sym]

  unless $settings.include?(key)
    message = "No setting defined for #{key.inspect}."
    defined?(logger) ? logger.warn(message) : $stderr.puts(message)
  end

  $settings[key]
end

