# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

$:.unshift File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'simplecov'

SimpleCov.adapters.define 'rdaw' do
  add_filter '/spec/'
  add_group 'Errors',     'rdaw/errors'
end

SimpleCov.start 'rdaw'

SimpleCov.at_exit do
  want_coverage = 1.00
  have_coverage = SimpleCov.result.covered_percent

  if have_coverage < want_coverage
    message = "InsufficientCoverage\n\tHave: '#{have_coverage}%'\n\tWant: '#{want_coverage}%"
    raise Rdaw::Errors::InsufficientCoverage, "\n#{__FILE__}:#{__LINE__}\n#{message}", caller
  end

  SimpleCov.result.format!
end

require 'rdaw'
require 'timecop'

RSpec.configure do |config|
  config.debug = true
  config.mock_with :rspec

  config.before(:each) do
    Timecop.return
  end
end

(['ruby-debug'] + Dir[File.expand_path File.join('..', 'support', '**', '*.rb'), __FILE__]).each { |file| require file }