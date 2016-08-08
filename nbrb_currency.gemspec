# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'nbrb_currency'
  s.version     = '1.0.1'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Aleks Grebennik']
  s.email       = ['aleks.grebennik@gmail.com']
  s.homepage    = 'http://github.com/slbug/nbrb_currency'
  s.summary     = 'Calculates exchange rates based on rates from National Bank of the Republic of Belarus. Money gem compatible.'
  s.description = 'This gem reads exchange rates from the National Bank of the Republic of Belarus website. It uses it to calculates exchange rates. It is compatible with the money gem'

  s.required_rubygems_version = '>= 1.3.6'

  s.add_dependency 'nokogiri'
  s.add_dependency 'money', '~> 6.7.1'
  s.add_dependency 'monetize'

  s.add_development_dependency 'rspec', '>= 3.5.0'
  s.add_development_dependency 'rspec-mocks'
  s.add_development_dependency 'rr'
  s.add_development_dependency 'shoulda'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
end
