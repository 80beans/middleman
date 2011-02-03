Gem::Specification.new do |gem|
  gem.name    = 'middleman'
  gem.version = '1.0.0'
  gem.date    = Date.today.to_s

  gem.summary = "A static site generator utilizing Haml, Sass and providing YUI compression and cache busting."
  gem.description = "A static site generator utilizing Haml, Sass and providing YUI compression and cache busting."

  gem.authors  = ["Thomas Reynolds"]
  gem.email    = "tdreyno@gmail.com"
  gem.homepage = 'http://wiki.github.com/tdreyno/middleman'
  gem.executables       = %w(mm-init mm-build mm-server mm-preview)
  gem.rubyforge_project = "middleman"

  gem.files = Dir['{generators,lib,spec,bin,features,fixtures}/**/*', 'README*', 'LICENSE*', 'Rakefile'] & `git ls-files -z`.split("\0")

  gem.add_dependency("rack",                "~>1.0")
  gem.add_dependency("thin",                "~>1.2.0")
  gem.add_dependency("shotgun",             "~>0.8.0")
  gem.add_dependency("templater",           "~>1.0.0")
  gem.add_dependency("tilt",                "~>1.1")
  gem.add_dependency("sinatra",             "~>1.0")
  gem.add_dependency("padrino-core",        "~>0.9.0")
  gem.add_dependency("padrino-helpers",     "~>0.9.0")
  gem.add_dependency("rack-test",           "~>0.5.0")
  gem.add_dependency("yui-compressor",      "~>0.9.0")
  gem.add_dependency("haml",                "~>3.0")
  gem.add_dependency("compass",             "~>0.11.beta")
  gem.add_dependency("oily_png",            "~>0.0.5")
  gem.add_dependency("lemonade",            "~>0.3.4")
  gem.add_dependency("json_pure",           "~>1.4.0")
  gem.add_dependency("smusher",             "~>0.4.5")
  gem.add_dependency("compass-slickmap",    "~>0.4.0")

  gem.add_development_dependency("cucumber", "~>0.9.2")
  gem.add_development_dependency("rspec",    "~>2.0.0")
end

