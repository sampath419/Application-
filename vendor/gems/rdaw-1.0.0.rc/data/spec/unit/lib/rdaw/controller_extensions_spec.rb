# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

require 'spec_helper'

describe Rdaw do
  let(:logger)      { ActionController::Logger.new }
  let(:cookies)     { { 'myacinfo' => 'mysecret' } }
  let(:url_prefix)  { 'https://daw-uat.apple.com/cgi-bin/WebObjects/DSAuthWeb.woa/wa' }
  let(:id_key)      { 'key' }
  let(:app_id)      { 1337 }
  let(:password)    { 'pass' }

  subject { DummyRdawController.new }

  context 'class methods' do
    describe '.recover_non_get' do
      let(:session) { { :before_post_url => 'http://lagos.apple.com/' } }
      let(:url)     { 'http://lagos.apple.com/?rdr=1' }

      it 'is a class method' do
        Rdaw.should respond_to :recover_non_get
      end

      it 'receives two parameters, one of which is optional' do
        described_class.method(:recover_non_get).parameters.should eq [[:req, :p_rdaw_session], [:opt, :p_logger]]
      end

      it 'raises a Rdaw::Errors::InvalidSession if the session is blank' do
        [nil, {}].each do |v|
          expect { described_class.recover_non_get v }.to raise_error Rdaw::Errors::InvalidSession
        end
      end

      it 'uses RECOVER_FLAG when available' do
        described_class.const_set :RECOVER_FLAG, 'dummy=1'
        described_class.should_receive(:const_defined?).with(:RECOVER_FLAG).and_return true
        described_class.recover_non_get(session, logger).should eq 'http://lagos.apple.com/?dummy=1'
        described_class.send :remove_const, :RECOVER_FLAG
      end

      it 'sets recover_flag to rdr=1 unless RECOVER_FLAG is available' do
        described_class.should_receive(:const_defined?).with(:RECOVER_FLAG).and_return false
        described_class.recover_non_get(session, logger).should eq url
      end

      it 'collects :before_post_url from session' do
        session.should_receive(:delete).with(:before_post_url).and_return 'http://lagos.apple.com/'
        described_class.recover_non_get(session, logger).should eq url
      end

      it 'uses & as connector if the URL already contains a querystring' do
        session[:before_post_url] = 'http://lagos.apple.com/?dummy=1'
        described_class.recover_non_get(session, logger).should eq 'http://lagos.apple.com/?dummy=1&rdr=1'
      end

      it 'logs the action to the provided logger' do
        logger.should_receive(:debug).once.with("\n[rdaw] recovering from incomplete non-get request.")
        described_class.recover_non_get(session, logger).should eq url
      end

      it 'defaults to ActionController::Base.logger when no logger is provided' do
        ActionController::Base.should_receive(:logger).once.and_return ActionController::Logger.new
        described_class.recover_non_get(session).should eq url
      end
    end # .recover_non_get
  end # class methods

  context 'instance methods' do
    describe '#rdaw_session' do
      it 'returns the value of session[:rdaw]' do
        subject.session = { :rdaw => true }
        subject.rdaw_session.should eq true
      end

      it 'sets and memoizes session[:rdaw] to Hash.new should it not be present' do
        subject.session = Hash.new
        subject.rdaw_session.should eq Hash.new
        subject.rdaw_session.object_id.should eq subject.rdaw_session.object_id
      end
    end # rdaw_session

    describe '#rdaw_session=' do
      it 'requires a value to be passed as a parameter' do
        subject.method(:rdaw_session=).parameters.should eq [[:req, :value]]
      end

      it 'sets the value of session[:rdaw]' do
        subject.session = Hash.new
        subject.rdaw_session = :dummy
        subject.rdaw_session.should eq :dummy
      end
    end # rdaw_session=

    describe '#daw_login_prompt' do
      let(:expected)    { 'https://daw-uat.apple.com/cgi-bin/WebObjects/DSAuthWeb.woa/wa/login?appIdKey=key&dummy' }

      before(:each) do
        described_class.const_set :DAW_URL_PREFIX, url_prefix
        described_class.const_set :APP_ID_KEY, id_key
        subject.should_receive(:rdaw_logout).and_return true
      end

      it 'adds an entry to the debug logger when called' do
        logger.should_receive(:debug).once.with '[rdaw] redirecting to login form.'
        subject.should_receive(:logger).once.and_return logger
        subject.should_receive(:encoded_daw_return_path).and_return '&dummy'
        subject.should_receive(:redirect_to).once.with expected
        subject.daw_login_prompt.should be_false
      end

      it 'overrides url with the value returned by rdaw_login_url' do
        subject.should_receive(:respond_to?).with(:rdaw_login_url, true).and_return true
        subject.should_receive(:rdaw_login_url).and_return 'http://apple.com/'
        subject.should_not_receive(:encoded_daw_return_path)
        subject.should_receive(:redirect_to).once.with 'http://apple.com/'
        subject.daw_login_prompt.should be_false
      end

      it 'constructs the url if rdaw_login_url is not present' do
        subject.should_receive(:encoded_daw_return_path).and_return '&dummy'
        subject.should_receive(:redirect_to).once.with expected
        subject.daw_login_prompt.should be_false
      end

      it 'appends &rv if APP_RV present' do
        described_class.const_set :APP_RV, 'myrv'
        subject.should_receive(:encoded_daw_return_path).and_return '&dummy'
        subject.should_receive(:redirect_to).once.with "#{expected}&rv=myrv"
        subject.daw_login_prompt.should be_false
        described_class.send :remove_const, :APP_RV
      end

      it 'uses DAW_EXTERNAL_URL_PREFIX instead of DAW_URL_PREFIX if defined' do
        external_url_prefix = 'https://daw.apple.com/cgi-bin/WebObjects/DSAuthWeb.woa/wa'
        external_redirect = "#{external_url_prefix}/login?appIdKey=key&dummy"
        described_class.const_set :DAW_EXTERNAL_URL_PREFIX, external_url_prefix

        subject.should_receive(:encoded_daw_return_path).and_return '&dummy'
        subject.should_receive(:redirect_to).once.with external_redirect
        subject.daw_login_prompt.should be_false

        described_class.send :remove_const, :DAW_EXTERNAL_URL_PREFIX
      end

      after(:each) { [:DAW_URL_PREFIX, :APP_ID_KEY].each { |c| described_class.send :remove_const, c } }
    end # daw_login_prompt

    describe '#encoded_daw_return_path' do
      let(:request) { double(:request) }
      let(:encoded_url) { 'http%3A%2F%2Fapple.com%2F' }

      before(:each) { subject.stub!(:request).and_return request }

      it 'uses the fullpath if Rails::Version < 3' do
        url = 'http://apple.com/fullpath'
        request.should_not_receive(:request_uri)
        request.should_receive(:fullpath).and_return url
        URI.should_receive(:encode).once.with(url, URI::PATTERN::RESERVED).and_return "#{encoded_url}fullpath"
        subject.encoded_daw_return_path.should eq "&path=#{encoded_url}fullpath"
      end

      it 'uses the request_uri if Rails::Version > 3' do
        url = 'http://apple.com/uri'
        Rails::VERSION.send :remove_const, :MAJOR
        Rails::VERSION.const_set :MAJOR, 2
        request.should_not_receive(:fullpath)
        request.should_receive(:request_uri).and_return url
        URI.should_receive(:encode).once.with(url, URI::PATTERN::RESERVED).and_return "#{encoded_url}uri"
        subject.encoded_daw_return_path.should eq "&path=#{encoded_url}uri"
        Rails::VERSION.send :remove_const, :MAJOR
        Rails::VERSION.const_set :MAJOR, 3
      end
    end # encoded_daw_return_path

    describe '#cached_daw_session_valid?' do
      let(:session) { { :login_time => '20110101', :hash => 'e9fe51f94eadabf54dbf2fbbd57188b9abee436e' } }

      before(:each) do
        subject.stub!(:rdaw_session).and_return session
        subject.stub!(:cookies).and_return cookies
      end

      it 'checks if rdaw_session includes :login_time' do
        session.should_receive(:include?).with(:login_time).and_return true
        subject.cached_daw_session_valid?
      end

      it 'parses the login_time' do
        time = Time.parse session[:login_time]

        Time.should_receive(:parse).with(session[:login_time]).and_return time
        subject.cached_daw_session_valid?.should be_false
      end

      it 'adds the corresponding log entry whenever the session is invalid' do
        subject.stub_chain(:logger, :debug).and_return true
        subject.should_receive(:session_timeout).once.and_return 1
        subject.logger.should_receive(:debug).with '[rdaw] session expired or invalid'
        subject.cached_daw_session_valid?.should be_false
      end

      it 'does not log the session as invalid if it is valid' do
        subject.stub_chain(:logger, :debug).and_return true
        subject.should_receive(:session_timeout).once.and_return 99999999
        subject.should_not_receive(:debug).with '[rdaw] session expired or invalid'
        subject.cached_daw_session_valid?.should be_true
      end

      it 'adds the corresponding log entry if the cookie has changed' do
        msg = "[rdaw] session invalidated because myacinfo cookie changed"
        subject.stub!(:hashcookie).and_return 'invalid_cookie_value'
        subject.stub_chain(:logger, :debug).and_return true
        subject.logger.should_receive(:debug).with msg
        subject.cached_daw_session_valid?.should be_false
      end

      it 'does not log the cookie as invalid when it is valid' do
        msg = "[rdaw] session invalidated because myacinfo cookie changed"
        subject.stub_chain(:logger, :debug).and_return true
        subject.logger.should_not_receive(:debug).with msg
        subject.cached_daw_session_valid?.should be_false
      end
    end # cached_daw_session_valid

    describe '#hashcookie' do
      it 'returns nil if the cookie is not set' do
        subject.stub!(:cookies).and_return Hash.new
        subject.hashcookie.should be_nil
      end

      it 'returns the SHA1 hashdigest for the cookie\'s value' do
        subject.stub!(:cookies).and_return({ 'myacinfo' => 'secret' })
        subject.hashcookie.should eq 'e5e9fa1ba31ecd1ae84f75caaa474f3a663f05f4'
      end
    end # hashcookie

    describe '#session_timeout' do
      it 'defaults to 300' do
        subject.session_timeout.should be 300
      end

      it 'returns the value of SESSION_TIMEOUT_SECONDS when defined' do
        described_class.const_set :SESSION_TIMEOUT_SECONDS, 1337
        subject.session_timeout.should be 1337
        described_class.send :remove_const, :SESSION_TIMEOUT_SECONDS
      end
    end # session_timeout

    describe '#create_daw_session' do
      let(:session)       { { :before_post_url => 'http://lagos.apple.com/' } }
      let(:request_hash)  { { "status"=>"0", "firstName"=>"Vladimir", "lastName"=>"Chernis" } }
      let(:request)       { double(:request, :remote_ip => '1.4.76.77', :fullpath => 'fullpath') }
      let(:url)           { 'https://daw-uat.apple.com/cgi-bin/WebObjects/DSAuthWeb.woa/wa/validate?ip=1.4.76.77&appId=1337&cookie=mysecret&appAdminPassword=pass&func=firstName;nickName;lastName;allGroups;prsId;employeeId;prsTypeCode;divisionNum;departmentNum;isManager;emailAddress;phoneOfficeCountryDialCode;phoneOfficeAreaCode;phoneOfficeNumber;phoneOfficeExtension;addressOfficialMailstopName;officialCountryCd;addressOfficialCity;addressOfficialLineFirst;addressOfficialLineSecond;addressOfficialPostalCode;addressOfficialStateProvince;phoneMobileAreaCode;phoneMobileCountryDialCode;phoneMobileExtension;phoneMobileNumber&path=fullpath' }

      before(:each) do
        described_class.const_set :DAW_URL_PREFIX,      url_prefix
        described_class.const_set :APP_ID,              app_id
        described_class.const_set :APP_ADMIN_PASSWORD,  password
        subject.stub!(:cookies).and_return cookies
        subject.stub!(:request).and_return request
      end

      it 'returns nil if the daw cookie is not present' do
        subject.stub!(:cookies).and_return Hash.new
        subject.should_receive(:denied).and_return nil
        subject.create_daw_session
      end

      it 'uses the default list of properties to retrieve when DAW_FUNC is not defined' do
        subject.session = session
        Rdaw::Request.should_receive(:get_hash).once.
          with(URI.parse(url), instance_of(ActionController::Logger)).and_return request_hash
        subject.create_daw_session.should be_true
      end

      it 'uses the value of DAW_FUNC when available' do
        url = 'https://daw-uat.apple.com/cgi-bin/WebObjects/DSAuthWeb.woa/wa/validate?ip=1.4.76.77&appId=1337&cookie=mysecret&appAdminPassword=pass&func=firstName&path=fullpath'
        described_class.const_set :DAW_FUNC, 'firstName'
        subject.session = session
        Rdaw::Request.should_receive(:get_hash).once.
          with(URI.parse(url), instance_of(ActionController::Logger)).and_return request_hash
        subject.create_daw_session.should be_true
        described_class.send :remove_const, :DAW_FUNC
      end

      it 'clears the old session and updates session data on success' do
        subject.session = session
        Rdaw::Request.should_receive(:get_hash).and_return({ 'status' => '0' })
        subject.should_receive(:clear_rdaw_session)

        Time.use_zone('UTC') do
          Timecop.freeze(Time.now) do
            subject.create_daw_session.should be_true
            subject.rdaw_session.should eq({ :daw_data => { 'status' => '0' },
                                             :login_time => Time.now.to_s,
                                             :hash => 'e9fe51f94eadabf54dbf2fbbd57188b9abee436e' })
          end
        end
      end

      it 'denies the request when daw does not report a successful authentication' do
        subject.session = session
        Rdaw::Request.should_receive(:get_hash).and_return({ 'status' => '12' })
        subject.should_not_receive :clear_rdaw_session
        subject.should_receive :denied
        subject.create_daw_session.should be_false
      end

      after(:each) do
        described_class.send :remove_const, :DAW_URL_PREFIX
        described_class.send :remove_const, :APP_ID
        described_class.send :remove_const, :APP_ADMIN_PASSWORD
      end
    end # create_daw_session

    describe '#rdaw_auth' do
      context 'REMOTE MODE' do
        it 'checks if the cached session is valid' do
          subject.should_receive(:rdaw_local_mode?).and_return false
          subject.should_receive(:cached_daw_session_valid?).and_return true
          subject.rdaw_auth.should be_true
        end

        it 'creates a daw session if the cached session is not valid' do
          subject.should_receive(:rdaw_local_mode?).and_return false
          subject.should_receive(:cached_daw_session_valid?).and_return false
          subject.should_receive(:create_daw_session).and_return true
          subject.rdaw_auth.should be_true
        end
      end # REMOTE MODE

      context 'LOCAL MODE' do
        let(:data) { { 'firstName' => 't.', 'lastName' => 'rex', 'prsId' => '1154552672', 'allGroups' => '0;1337' } }

        before(:each) { subject.session = Hash.new }

        it 'asserts if we are running in local mode' do
          subject.should_receive(:rdaw_local_mode?).once.and_return true
          subject.should_receive(:respond_to?).once.with(:rdaw_local_setup, true).and_return true
          subject.should_receive(:rdaw_local_setup).exactly(1).times.and_return data
          subject.rdaw_auth.should be_true
        end

        it 'raises an error if rdaw_local_setup is not a Hash' do
          subject.should_receive(:rdaw_local_mode?).once.and_return true
          subject.should_receive(:respond_to?).once.with(:rdaw_local_setup, true).and_return true
          data.should_receive(:is_a?).with(Hash).and_return false
          subject.should_receive(:rdaw_local_setup).exactly(1).times.and_return data
          expect { subject.rdaw_auth }.to raise_error Rdaw::Errors::InvalidMockData,
            'rdaw_local_setup must return a Hash containing the mock session data.'
        end

        it 'assigns the mock data to rdaw_session' do
          subject.should_receive(:rdaw_local_mode?).once.and_return true
          subject.should_receive(:respond_to?).once.with(:rdaw_local_setup, true).and_return true
          subject.should_receive(:rdaw_local_setup).exactly(1).times.and_return data

          Time.use_zone('UTC') do
            Timecop.freeze(Time.now) do
              subject.rdaw_auth.should be_true
              subject.rdaw_session[:daw_data].should eq data
              subject.rdaw_session[:login_time].should eq Time.now.to_s
            end
          end
        end
      end # LOCAL MODE
    end # rdaw_auth

    describe 'rdaw_local_mode?' do
      let(:request) { double(:request, :local? => true) }

      it 'uses local_request? when available' do
        subject.should_receive(:respond_to?).with(:local_request?).and_return true
        subject.should_receive(:local_request?).and_return true
        subject.rdaw_local_mode?.should be_true
      end

      it 'uses request.local when local_request? is not available' do
        subject.should_receive(:respond_to?).with(:local_request?).and_return false
        subject.should_receive(:request).and_return request
        request.should_receive(:local?).and_return true
        subject.rdaw_local_mode?.should be_true
      end
    end # rdaw_local_mode?

    describe '#daw_session_data' do
      it 'returns @daw_session if it is already set' do
        subject.instance_variable_set :@daw_session, :dummy
        subject.daw_session_data.should eq :dummy
      end

      it 'raises an error if @daw_session is not set and if cached_daw_session_valid is false' do
        subject.should_receive(:cached_daw_session_valid?).and_return false
        expect { subject.daw_session_data }.to raise_error RuntimeError
      end

      it 'raises an error if @daw_session is not set and rdaw_session[:daw_data] is nil' do
        subject.should_receive(:cached_daw_session_valid?).and_return true
        subject.should_receive(:rdaw_session).and_return({})
        expect { subject.daw_session_data }.to raise_error RuntimeError
      end
    end # daw_session_data

    describe '#rdaw_logout' do
      let(:cookies) { double(:cookies, :[] => 'secret') }

      before(:each) do
        subject.stub!(:cookies).and_return cookies
        subject.should_receive(:clear_rdaw_session).and_return true
      end

      it 'deletes the cookie and clears the session' do
        subject.cookies.should_receive(:delete).and_return true
        subject.rdaw_logout
      end

      it 'gets the cookie name from daw_cookie_name' do
        subject.stub!(:daw_cookie_name).and_return 'lagos'
        cookies.should_receive(:delete).with('lagos', :domain => '.apple.com').and_return true
        subject.rdaw_logout
      end
    end # rdaw_logout

    describe '#denied' do
      it 'sets rdaw_session[:before_post_url] if it is non GET method' do
        subject.session = Hash.new
        subject.stub!(:request).and_return double(:request,
                                                  :method => :post,
                                                  :env => { 'HTTP_REFERER' => 'http://apple.com' })
        subject.should_receive(:daw_login_prompt).and_return true
        subject.denied
        subject.rdaw_session[:before_post_url].should eq 'http://apple.com'
      end

      it 'get methods do not define rdaw_session[:before_post_url]' do
        subject.session = Hash.new
        subject.stub!(:request).and_return double(:request, :method => :get)
        subject.should_receive(:daw_login_prompt).and_return true
        subject.denied
        subject.rdaw_session[:before_post_url].should be_nil
      end

      it 'executes the method defined in Rdaw::ERROR_HANDLER_MNAME, rather than daw_login_prompt, if available' do
        subject.stub!(:request).and_return double(:request, :method => :get)
        Rdaw.const_set :ERROR_HANDLER_MNAME, 'dummy_method'
        subject.should_receive(:respond_to?).with('dummy_method').and_return true
        subject.should_receive(:daw_status).exactly(3).times.and_return 12
        subject.should_receive(:send).with('dummy_method', { :status_code => 12, :status_text => 'NO_ACCESS' })
        subject.denied.should be_false
      end
    end # denied

    describe '#non_get_methods' do
      it 'returns the list of HTTP methods that are not GET' do
        subject.non_get_methods.should eq [:post, :put, :delete]
      end
    end # non_get_methods

    describe '#daw_cookie_name' do
      it 'returns the cookie name defined in Rdaw::DAW_COOKIE_NAME when available' do
        Rdaw.const_set :DAW_COOKIE_NAME, 'dummy'
        subject.daw_cookie_name.should eq 'dummy'
        Rdaw.send :remove_const, :DAW_COOKIE_NAME
      end

      it 'defaults to myacinfo' do
        subject.daw_cookie_name.should eq 'myacinfo'
      end
    end # daw_cookie_name
  end # instance methods
end # Rdaw
