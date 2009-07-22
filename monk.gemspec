Gem::Specification.new do |s|
  s.name              = "monk"
  s.version           = "0.0.1"
  s.summary           = "Monk, the glue framework"
  s.description       = "Monk is a glue framework for web development. It means that instead of installing all the tools you need for your projects, you can rely on a git repository and a list of dependencies, and Monk will care of the rest. By default, it ships with a Sinatra application that includes Contest, Stories, Webrat, Ohm and some other niceties, along with a structure and helpful documentation to get your hands wet in no time."
  s.authors           = ["Damian Janowski", "Michel Martens"]
  s.email             = ["djanowski@dimaion.com", "michel@soveran.com"]
  s.homepage          = "http://monkrb.com"

  s.rubyforge_project = "monk"

  s.executables << "monk"

  s.add_dependency("wycats-thor", "~> 0.11")
  s.add_dependency("dependencies", ">= 0.0.4")
  s.requirements << "git"

  s.files = ["README.markdown", "Rakefile", "bin/monk", "lib/monk/logger.rb", "lib/monk/reloader.rb", "lib/monk/settings.rb", "lib/monk.rb", "monk.gemspec", "test/integration_test.rb", "test/sinatra_test.rb"]
end
