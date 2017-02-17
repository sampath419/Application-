# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

# PersonTypeCodes module holds the possible values returned by <tt>DSAuthWeb</tt>. The raw values provided by
# this service are made available to you via <tt>daw_session_data['prsTypeCode']</tt>.
module Rdaw::PersonTypeCodes
  # =========================
  # = Internal person types =
  # =========================
  APPLE_EMPLOYEE          = 1
  APPLE_CONTRACTOR        = 2
  INDEPENDENT_CONTRACTOR  = 3
  ON_SITE_VENDOR          = 4

  # =========================
  # = External person types =
  # =========================
  DEVELOPER               = 5
  VENDOR                  = 6
  EDUCATION_CUSTOMER      = 7
  CUSTOMER_LITE           = 8
  RESELLER                = 9
  CUSTOMER                = 10
  BUSINESS_CUSTOMER       = 11
  JOB_SEEKER              = 12
  B2B_CUSTOMER            = 13

  # Given a <tt>person type code</tt>, return its string representation.
  #
  # == Behaviors
  # * Returns <tt>nil</tt> when <tt>nil</tt> is passed as the lookup <tt>code</tt>;
  # * Returns <tt>nil</tt> if no person type constant is found for it.
  #
  # == Examples
  #
  #   Rdaw::PersonTypeCodes.to_const_name(1) #=> 'APPLE_EMPLOYEE'
  #
  #   Rdaw::PersonTypeCodes.to_const_name(1337) #=> nil
  #
  # *Note:* This is a <tt>module_function</tt>.
  def to_const_name(code)
    return nil unless code
    name = constants.select { |c| const_get(c) == code.to_i }.first.to_s
    name.present? ? name : nil
  end
  module_function :to_const_name
end
