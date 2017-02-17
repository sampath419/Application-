# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

require 'spec_helper'

describe Rdaw::Errors do
  subject { described_class }

  its(:constants) { should =~ [:Base, :InvalidSession, :InvalidMockData, :InsufficientCoverage] }
end # Rdaw::Errors