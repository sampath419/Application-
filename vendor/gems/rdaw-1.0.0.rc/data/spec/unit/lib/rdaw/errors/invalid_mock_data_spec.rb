# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

require 'spec_helper'

describe Rdaw::Errors::InvalidMockData do
  describe 'class method' do
    subject { described_class }

    its(:superclass) { should be Rdaw::Errors::Base }
  end # class method
end # Rdaw::Errors::InvalidMockData