# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

$:.push File.expand_path '../lib', __FILE__

Gem::Specification.new do |s|
  s.name        = 'rdaw'
  s.version     = '1.0.0.rc'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Vladimir Chernis', 'Team Lagos', 'Huzefa Mogri']
  s.email       = ['vchernis@apple.com', 'team-lagos@group.apple.com', 'huzefam@apple.com']
  s.homepage    = 'http://lagos.apple.com/'
  s.summary     = %q{Provides AppleConnect / DSAuthWeb authentication to Ruby on Rails applications.}
  s.description = %q{An AppleConnect/DSAuthWeb gateway written in Ruby.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # External runtime dependencies
  s.add_dependency 'i18n'
  s.add_dependency 'activesupport'

  # External development dependencies
  s.add_development_dependency 'rake',          '~> 0.9.2'
  s.add_development_dependency 'rspec',         '~> 2.7.0'
  s.add_development_dependency 'ruby-debug19',  '~> 0.11.6'
  s.add_development_dependency 'simplecov',     '~> 0.5.4'
  s.add_development_dependency 'timecop',       '~> 0.3.5'
  s.add_development_dependency 'tzinfo',        '~> 0.3.31'
end
