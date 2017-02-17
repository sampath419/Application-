# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

require 'rdaw'

class RdawMiddleware
  def initialize(p_app)
    @app = p_app
  end
  
  def call(p_env)
    rdaw_session = p_env['rack.session'][:rdaw]
    # redirect to before_post_url if it was set, otherwise behave normally
    if rdaw_session && rdaw_session.include?(:before_post_url)
      res = [
        302,
        {'Location' => Rdaw::recover_non_get(rdaw_session)},
        []
      ]
    else
      res = @app.call(p_env)
    end
    return res
  end
end