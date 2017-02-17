# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

require 'spec_helper'

describe Rdaw::PersonTypeCodes do
  codes = { :APPLE_EMPLOYEE => 1,
            :APPLE_CONTRACTOR => 2,
            :INDEPENDENT_CONTRACTOR => 3,
            :ON_SITE_VENDOR => 4,
            :DEVELOPER => 5,
            :VENDOR => 6,
            :EDUCATION_CUSTOMER => 7,
            :CUSTOMER_LITE => 8,
            :RESELLER=> 9,
            :CUSTOMER => 10,
            :BUSINESS_CUSTOMER => 11,
            :JOB_SEEKER => 12,
            :B2B_CUSTOMER => 13 }

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
end # Rdaw::PersonTypeCodes
