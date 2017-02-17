# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

require 'spec_helper'

describe Rdaw::StatusCodes do
  codes = { :SUCCESS => 0,
            :INVALID_IP => 1,
            :IP_NOT_SUPPLIED => 2,
            :INVALID_SESSION => 3,
            :EXPIRED_SESSION => 4,
            :INVALID_APP_ID => 5,
            :COOKIE_NOT_SUPPLIED => 6,
            :CAN_NOT_KEEP_ALIVE => 7,
            :BAD_ALLGROUP_PARAM_SUPPLIED => 8,
            :LOGIN_EXPIRED => 10,
            :NO_ACCESS => 12,
            :DS_AUTH_WEB_UNDER_MAINTENANCE => 99 }

  context 'constants' do
    codes.each do |key, value|
      describe key do
        it "is set with value '#{value}'" do
          described_class.const_get(key).should be value
        end
      end # key
    end
  end # constants

  context 'module functions' do
    describe '.to_const_name(code)' do
      it_behaves_like('.to_const_name') { let(:codes) { codes } }
    end # .to_const_name(p_code)
  end # module functions
end # Rdaw::StatusCodes
