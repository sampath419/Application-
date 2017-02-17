# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

require 'spec_helper'

describe Rdaw::Request do
  context 'class methods' do
    describe '.get_hash' do
      let(:url) { 'https://daw-uat.apple.com/cgi-bin/WebObjects/DSAuthWeb.woa/wa/validate?ip=1.4.76.77&appId=1337&cookie=mysecret&appAdminPassword=pass&func=firstName;nickName;lastName;allGroups;prsId;employeeId;prsTypeCode;divisionNum;departmentNum;isManager;emailAddress;phoneOfficeCountryDialCode;phoneOfficeAreaCode;phoneOfficeNumber;phoneOfficeExtension;addressOfficialMailstopName;officialCountryCd;addressOfficialCity;addressOfficialLineFirst;addressOfficialLineSecond;addressOfficialPostalCode;addressOfficialStateProvince;phoneMobileAreaCode;phoneMobileCountryDialCode;phoneMobileExtension;phoneMobileNumber&path=fullpath' }
      let(:logger) { double(:logger, :debug => true) }
      let(:uri) { URI.parse url }
      let!(:request) { Net::HTTP.new uri.host, uri.port }
      let(:response) do
        double :response, :body => "status=-20203\nreason=The application you have selected does not exist.\n"
      end
      let(:response_hash) { { 'status'=>'-20203', 'reason'=> 'The application you have selected does not exist.' } }

      before(:each) { Net::HTTP.should_receive(:new).and_return request }

      it 'creates and configures an HTTP request' do
        request.should_receive(:use_ssl=).with true
        request.should_receive(:verify_mode=).with OpenSSL::SSL::VERIFY_PEER
        request.should_receive(:get).and_return response
        described_class.get_hash uri, logger
      end

      it 'retrieves the response from the server' do
        request.should_receive(:get).once.with(uri.request_uri).and_return response
        described_class.get_hash uri, logger
      end

      it 'handles errors of type Request Timeout and returns denied' do
        request.should_receive(:get).once.with(uri.request_uri).and_raise Timeout::Error
        logger.should_receive(:error)
        described_class.should_receive(:denied).and_return :dummy_deneid
        described_class.get_hash(uri, logger).should eq :dummy_deneid
      end

      it 'successful requests log how long they took' do
        request.should_receive(:get).once.with(uri.request_uri).and_return response
        logger.should_receive(:debug).with(an_instance_of(String)) do |a|
          a.should =~ /\[rdaw\] validation roundtrip complete in(.*)ms./
        end
        described_class.get_hash uri, logger
      end

      it 'attempts to force the encoding of response.body to UTF-8' do
        request.should_receive(:get).once.with(uri.request_uri).and_return response
        response.body.should_receive(:force_encoding).with 'utf-8'
        described_class.get_hash uri, logger
      end

      it 'parses the body into a hash' do
        request.should_receive(:get).once.with(uri.request_uri).and_return response
        described_class.get_hash(uri, logger).should eq response_hash
      end

      it 'adds a log entry for each invalid key or value' do
        response.stub!(:body).and_return "=-20203\nreason="
        request.should_receive(:get).once.with(uri.request_uri).and_return response
        logger.should_receive(:debug).with(an_instance_of(String)) do |a|
          a.should =~ /\[rdaw\] validation roundtrip complete in(.*)ms./
        end
        logger.should_receive(:debug).with("[rdaw] ignoring malformed response line: =-20203\n.")
        logger.should_receive(:debug).with("[rdaw] ignoring malformed response line: reason=.")
        described_class.get_hash(uri, logger)
      end
    end # .get_hash
  end # class methods
end # Rdaw::Request
