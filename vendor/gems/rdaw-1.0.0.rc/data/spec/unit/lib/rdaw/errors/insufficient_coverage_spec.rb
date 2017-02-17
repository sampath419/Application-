# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

require 'spec_helper'

describe Rdaw::Errors::InsufficientCoverage do
  describe 'class method' do
    subject { described_class }

    its(:superclass) { should be Rdaw::Errors::Base }
  end # class method
end # Rdaw::Errors::InsufficientCoverage