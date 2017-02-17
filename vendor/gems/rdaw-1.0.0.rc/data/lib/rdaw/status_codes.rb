# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

# StatusCodes module holds the possible status values returned by <tt>DSAuthWeb</tt>. The raw values provided by
# this service are made available to you via <tt>daw_session_data['status']</tt> or simply <tt>daw_status</tt>.
module Rdaw::StatusCodes
  SUCCESS                       = 0
  INVALID_IP                    = 1
  IP_NOT_SUPPLIED               = 2
  INVALID_SESSION               = 3
  EXPIRED_SESSION               = 4
  INVALID_APP_ID                = 5
  COOKIE_NOT_SUPPLIED           = 6
  CAN_NOT_KEEP_ALIVE            = 7
  BAD_ALLGROUP_PARAM_SUPPLIED   = 8
  LOGIN_EXPIRED                 = 10
  NO_ACCESS                     = 12
  DS_AUTH_WEB_UNDER_MAINTENANCE = 99

  # Given a <tt>status code</tt>, return its status string representation.
  #
  # == Behaviors
  # * Returns <tt>nil</tt> when <tt>nil</tt> is passed as the lookup <tt>code</tt>;
  # * Returns <tt>nil</tt> if no status constant is found for it.
  #
  # == Examples
  #
  #   Rdaw::StatusCodes.to_const_name(0) #=> 'SUCCESS'
  #
  #   Rdaw::StatusCodes.to_const_name(1337) #=> nil
  #
  # *Note:* This is a <tt>module_function</tt>.
  def to_const_name(code)
    return nil unless code
    name = constants.select { |c| const_get(c) == code.to_i }.first.to_s
    name.present? ? name : nil
  end
  module_function :to_const_name
end
