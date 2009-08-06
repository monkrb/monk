task :test do
  system "cd test && ruby monk_test.rb"
end

task :default => :test

namespace :test do
  task :integration do
    system "cd test && ruby integration_test.rb"
  end
end
