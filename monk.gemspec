Gem::Specification.new do |s|
  s.name              = "monk"
  s.version           = "0.0.7"
  s.summary           = "Monk, the glue framework"
  s.description       = "Monk is a glue framework for web development. It means that instead of installing all the tools you need for your projects, you can rely on a git repository, and Monk will care of the rest."
  s.authors           = ["Damian Janowski", "Michel Martens"]
  s.email             = ["djanowski@dimaion.com", "michel@soveran.com"]
  s.homepage          = "http://monkrb.com"
  s.executables.push("monk")

  s.add_dependency("thor", "~> 0.11")
  s.requirements.push("git")

  s.files = ["LICENSE", "README.markdown", "Rakefile", "bin/monk", "lib/monk.rb", "monk.gemspec", "test/commands.rb", "test/helper.rb", "test/monk_add_NAME_REPOSITORY.rb", "test/monk_init.rb", "test/monk_init_NAME.rb", "test/monk_list.rb", "test/monk_rm_NAME.rb", "test/monk_show_NAME.rb"]
end
