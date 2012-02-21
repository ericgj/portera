require File.expand_path('lib/portera/version',File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name         = "portera"
  s.version      = Portera::Version::STRING
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Eric Gjertsen"]
  s.email        = ["ericgj72@gmail.com"]
  s.homepage     = "http://github.com/ericgj/portera"
  s.summary      = "Group event coordination"
  s.description  = ""

  s.files        = `git ls-files -c`.split("\n") - ['portera.gemspec']
  s.require_path = 'lib'
  s.rubyforge_project = 'portera'
  s.required_rubygems_version = '>= 1.3.6'
  s.required_ruby_version = '>= 1.9.2'

  s.add_runtime_dependency 'tempr', '>= 0.1.4'
  s.add_runtime_dependency 'erubis'
  s.add_runtime_dependency 'tilt'
  
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
  
end
