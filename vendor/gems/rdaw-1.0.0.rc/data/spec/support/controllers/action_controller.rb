# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

module ActionController
  class Logger
    def debug(*args)
      true
    end
    
    def error(*args)
      true
    end
  end

  class Base
    def self.logger
      Logger.new
    end
  end # Base
end # ActionController