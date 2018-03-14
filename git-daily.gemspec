# -*- encoding: utf-8; mode: ruby -*-
$:.push File.expand_path("../lib", __FILE__)
require "git-daily/version"

Gem::Specification.new do |s|
  s.name        = "git-daily"
  s.version     = Git::Daily::VERSION
  s.licenses    = ['MIT']
  s.authors     = ["Koichiro Ohba"]
  s.email       = ["koichiro@meadowy.org"]
  s.homepage    = "https://github.com/koichiro/git-daily"
  s.summary     = %q{git-daily on ruby is a tool which helps you to do daily workflow easier on Git.}
  s.description = %q{git-daily on Ruby is a tool which helps you to do daily workflow easier on Git. This is the Ruby version. The original PHP version is here: https://github.com/sotarok/git-daily}

  s.rubyforge_project = "git-daily"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
