Gem::Specification.new do |s|
  s.name = "fittings"
  s.version = "0.2.4.RC1"

  s.authors = ["Edwin Cruz", "Colin Shield"]
  s.date = %q{2011-09-06}
  s.description = %q{implement custom keys independently of environment}
  s.email = %q{eng@stitchfix.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.homepage = %q{http://github.com/stitchfix/fittings}
  s.licenses = ["MIT"]
  s.summary = %q{Manage settings per environment}
  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "rdoc"
  s.add_development_dependency('rspec_junit_formatter')
end
