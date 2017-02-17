# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

class DummyRdawController
  include ::Rdaw

  def session
    @session
  end

  def session=(session)
    @session = session
  end

  def logger
    ActionController::Logger.new
  end
end