# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

require 'spec_helper'

describe Rdaw do
  context 'included modules' do
    it 'includes Rdaw::ControllerExtensions and Rdaw::ControllerExtensions::GroupHelpers' do
      described_class.included_modules.should eq [Rdaw::ControllerExtensions, Rdaw::ControllerExtensions::GroupHelpers]
    end
  end # included modules
end # Rdaw