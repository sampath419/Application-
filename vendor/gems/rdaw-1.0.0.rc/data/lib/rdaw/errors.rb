# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

module Rdaw
  module Errors
    # ===============
    # = Sub modules =
    # ===============
    autoload :Base, 'rdaw/errors/base'
    autoload :InsufficientCoverage, 'rdaw/errors/insufficient_coverage'
    autoload :InvalidSession, 'rdaw/errors/invalid_session'
    autoload :InvalidMockData, 'rdaw/errors/invalid_mock_data'
  end # Errors
end # Rdaw