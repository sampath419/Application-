# -*- coding: utf-8 -*-
#
# = Rdaw
# Copyright 2011 Apple Inc. All rights reserved.
#

# Methods included in your controller.
module Rdaw::ControllerExtensions
  autoload :GroupHelpers, 'rdaw/controller_extensions/group_helpers'
  include GroupHelpers

  def self.included(klass) # :nodoc:
    klass.extend ClassMethods
  end

  # Methods to be included in <tt>Rdaw</tt>.
  module ClassMethods
    # Constructs the URL for DSAuthWeb non-get recovery.
    #
    # == Defaults
    # * <tt>logger</tt> defaults to <tt>ActionController::Base.logger</tt>.
    #
    # == Exceptions
    # * <tt>ArgumentError</tt> unless <tt>session</tt> is passed as first parameter;
    # * <tt>Rdaw::Errors::InvalidSession</tt> if <tt>session</tt> is blank.
    #
    # == Examples
    # Invoking <tt>recover_non_get</tt> without a logger:
    #   Rdaw::recover_non_get({ :before_post_url => 'http://lagos.apple.com/' }) #=> http://lagos.apple.com/?rdr=1
    #
    # Invoking <tt>recover_non_get</tt> with a logger:
    #   Rdaw::recover_non_get({ :before_post_url => 'http://lagos.apple.com/' },
    #                         Logger.new) #=> http://lagos.apple.com/?rdr=1
    #
    # *Note:* This is a <tt>module_function</tt>.
    def recover_non_get(p_rdaw_session, p_logger = nil)
      (p_logger || ActionController::Base.logger).debug "\n[rdaw] recovering from incomplete non-get request."
      raise Rdaw::Errors::InvalidSession if p_rdaw_session.blank?

      Array.new.tap do |a|
        a << p_rdaw_session.delete(:before_post_url)
        a << (a.first.include?('?') ? '&' : '?')
        a << (Rdaw.const_defined?(:RECOVER_FLAG) ? Rdaw::RECOVER_FLAG : 'rdr=1')
      end.join
    end
  end

  # Looks up and returns the value of the key <tt>:rdaw</tt> in <tt>session</tt>.
  #
  # == Defaults
  # * Sets <tt>session[:rdaw]</tt> to <tt>Hash.new</tt> should it be nil.
  def rdaw_session
    session[:rdaw] ||= Hash.new
  end

  # Sets the value of <tt>session[:rdaw]</tt>.
  def rdaw_session=(value)
    session[:rdaw] = value
  end

  # Redirects the user to DSAuthWeb for authentication and returns <tt>false</tt>.
  #
  # == Constants used to construct the URL
  # * <tt>DAW_URL_PREFIX</tt> represents the base URL (e.g. http://apple.com/)
  # * <tt>APP_ID_KEY</tt> your DAW Application Key
  # * <tt>APP_RV</tt> *optional* integer indicating which of the returns URLs to use
  # * <tt>DAW_EXTERNAL_URL_PREFIX</tt> *optional* supersedes <tt>DAW_URL_PREFIX</tt> for the base URL (e.g. http://apple.com/)
  #
  # == Overriding the URL constructor
  # Application that wish to construct the URL elsewhere should create a method named <tt>rdaw_login_url</tt>.
  #
  #   class ApplicationController < ActionController::Base
  #     private
  #       def rdaw_login_url
  #         'https://mylogin.apple.com/?key=x'
  #       end
  #   end
  def daw_login_prompt
    logger.debug '[rdaw] redirecting to login form.'
    rdaw_logout

    if respond_to?(:rdaw_login_url, true)
      url = rdaw_login_url
    else
      prefix = Rdaw.const_defined?('DAW_EXTERNAL_URL_PREFIX') ? Rdaw::DAW_EXTERNAL_URL_PREFIX : Rdaw::DAW_URL_PREFIX
      url = [prefix, '/login?appIdKey=', Rdaw::APP_ID_KEY, encoded_daw_return_path].tap do |a|
        a << "&rv=#{Rdaw::APP_RV}" if Rdaw.const_defined?('APP_RV')
      end.join
    end

    redirect_to(url) and return false
  end

  # Encodes <tt>request</tt> URL using the <tt>URI</tt> class and returns it as a <tt>path</tt>.
  #
  # == Behaviors
  # * <tt>request.request_uri</tt> is used when Rails Version is lower than 3
  # * <tt>request.fullpath</tt> is used when Rails Version is greater than 3
  #
  # == Example
  #   self.encoded_daw_return_path #=> "&path=http%3A%2F%2Fapple.com"
  def encoded_daw_return_path
    uri = Rails::VERSION::MAJOR < 3 ? request.request_uri : request.fullpath
    "&path=#{URI.encode(uri, URI::PATTERN::RESERVED)}"
  end

  # Checks if the current daw_session is valid.
  def cached_daw_session_valid?
    login_time_set  = rdaw_session.include?(:login_time)
    session_age     = Time.now - Time.parse(rdaw_session[:login_time]) if login_time_set
    is_valid        = login_time_set && session_age < session_timeout

    logger.debug('[rdaw] session expired or invalid') unless is_valid
    cookie_changed = hashcookie != rdaw_session[:hash]
    logger.debug("[rdaw] session invalidated because #{daw_cookie_name} cookie changed") if cookie_changed

    is_valid && !cookie_changed
  end

  # Returns the cookie's <tt>SHA1</tt> hash or nil, if the cookie is not set.
  def hashcookie
    cookies[daw_cookie_name] && Digest::SHA1.hexdigest(cookies[daw_cookie_name])
  end

  # Returns the default session timeout defined by <tt>SESSION_TIMEOUT_SECONDS</tt>.
  #
  # == Defaults
  # * Returns <tt>300</tt> if SESSION_TIMEOUT_SECONDS is not defined.
  def session_timeout
    Rdaw.const_defined?(:SESSION_TIMEOUT_SECONDS) ? Rdaw::SESSION_TIMEOUT_SECONDS : 300
  end

  # Creates a new DAW session accessible via <tt>rdaw_session</tt>. This method also creates <tt>@daw_session</tt>
  # with DAW's raw response data.
  #
  # == Constants
  # * <tt>DAW_FUNC</tt> semicolon separated list of DAW properties to retrieve
  # * <tt>DAW_URL_PREFIX</tt> represents the base URL (e.g. http://apple.com/)
  # * <tt>APP_ID</tt> your DAW application ID
  # * <tt>APP_ADMIN_PASSWORD</tt> your DAW application password
  def create_daw_session
    daw_cookie = cookies[daw_cookie_name]
    return denied if daw_cookie.nil?
    encoded_daw_cookie = URI.encode(daw_cookie, URI::PATTERN::RESERVED)

    logger.debug('[rdaw] validating auth token in cookie with DAW endpoint')

    daw_func = Rdaw.const_defined?('DAW_FUNC') ? Rdaw::DAW_FUNC : 'firstName;nickName;lastName;allGroups;prsId;employeeId;prsTypeCode;divisionNum;departmentNum;isManager;emailAddress;phoneOfficeCountryDialCode;phoneOfficeAreaCode;phoneOfficeNumber;phoneOfficeExtension;addressOfficialMailstopName;officialCountryCd;addressOfficialCity;addressOfficialLineFirst;addressOfficialLineSecond;addressOfficialPostalCode;addressOfficialStateProvince;phoneMobileAreaCode;phoneMobileCountryDialCode;phoneMobileExtension;phoneMobileNumber'

    path_components = [ Rdaw::DAW_URL_PREFIX,
                        '/validate?ip=',
                        request.remote_ip,
                        '&appId=',
                        Rdaw::APP_ID,
                        '&cookie=',
                        encoded_daw_cookie,
                        '&appAdminPassword=',
                        Rdaw::APP_ADMIN_PASSWORD,
                        '&func=',
                        daw_func,
                        encoded_daw_return_path]

    @daw_session = Rdaw::Request.get_hash URI.parse(path_components.join), logger

    if daw_status.present? && Rdaw::StatusCodes::SUCCESS == daw_status.to_i
      clear_rdaw_session

      rdaw_session[:daw_data]   = @daw_session
      rdaw_session[:login_time] = Time.now.to_s
      rdaw_session[:hash]       = hashcookie

      logger.debug "[rdaw] caching new session for #{session_timeout} sec."
      return true
    else
      return denied
    end
  end

  # <tt>before_filter</tt> to use in your controllers in order force your end-users to authenticate via DSAuthWeb.
  #
  # == Examples
  #   class ApplicationController < ActionController::Base
  #     include Rdaw
  #     before_filter :rdaw_auth
  #   end
  #
  # == Local and Remote modes
  # This method will operate in local mode if <tt>rdaw_local_mode?</tt> is true and if your controller implements <tt>rdaw_local_setup</tt>.
  #
  # In all other situations, this method will execute in remote mode.
  #
  # == Exceptions
  #   * <tt>Rdaw::Errors::InvalidMockData</tt> can be raised when operating in local mode using an invalid local setup Hash.
  def rdaw_auth
    logger.debug('[rdaw] entering rdaw_auth')

    return (cached_daw_session_valid? || create_daw_session) unless rdaw_local_mode? &&
      respond_to?(:rdaw_local_setup, true)

    logger.debug('[rdaw] operating in local mode')

    mock_session_hash = rdaw_local_setup

    unless mock_session_hash.is_a? Hash
      raise Rdaw::Errors::InvalidMockData.new('rdaw_local_setup must return a Hash containing the mock session data.')
    end

    rdaw_session[:daw_data], rdaw_session[:login_time] = mock_session_hash, Time.now.to_s
  end

  # Checks if <tt>Rdaw</tt> is operating in local mode abstracting the diferences between Ruby on Rails v2 and v3.
  def rdaw_local_mode?
    respond_to?(:local_request?) ? local_request? : request.local?
  end

  # Clears <tt>rdaw_session</tt>.
  def clear_rdaw_session
    if rdaw_session
      logger.debug('[rdaw] killing old session')
      rdaw_session.delete_if { |k, v| :before_post_url != k }
    end
  end

  # Returns <tt>@daw_session</tt> if set, or an empty <tt>Hash</tt>
  def daw_session_data
    @daw_session ||= (cached_daw_session_valid? && rdaw_session[:daw_data])
    raise RuntimeError.new('Please call rdaw_auth before any other rdaw methods.') unless @daw_session
    @daw_session
  end

  # Clears the DAW cookie, getting its name from <tt>daw_cookie_name</tt> and clears the DAW session with <tt>clear_rdaw_session</tt>.
  def rdaw_logout
    logger.debug("[rdaw] killing #{daw_cookie_name} cookie for *.apple.com") if cookies[daw_cookie_name]
    cookies.delete(daw_cookie_name, :domain => '.apple.com')
    clear_rdaw_session
  end

  # Returns the value of <tt>status</tt> in hash <tt>@daw_session</tt>.
  #
  # == Defaults
  # * Uses an empty hash should <tt>@daw_status</tt> be nil.
  def daw_status
    (@daw_session || {})['status']
  end

  # Handles the denial of Authentication Requests.
  #
  # == Behaviors
  # * <tt>GET</tt> methods will not set <tt>rdaw_session[:before_post_url]</tt>
  # * Non <tt>GET</tt> methods (as defined by <tt>non_get_methods</tt>) set <tt>rdaw_session[:before_post_url]</tt> with <tt>request.env['HTTP_REFERER']</tt>
  #
  # == Constants
  # * <tt>Rdaw::ERROR_HANDLER_MNAME</tt> defines the method to be used for the authentication process instead of </tt>daw_login_prompt</tt>.
  def denied
    logger.debug("[rdaw] access denied (#{Rdaw::StatusCodes::to_const_name(daw_status) || daw_status || 'no status code'})")
    logger.debug("[rdaw] see documentation for ERROR_HANDLER_MNAME if unauthorized users shouldn't be sent back to the login prompt")

    # save HTTP request method and POST data for when the user logs back in after timeoout
    if non_get_methods.include?(request.method.downcase.to_sym)
      logger.debug("[rdaw] interrupted #{request.method} detected, saving referer")
      rdaw_session[:before_post_url] = request.env['HTTP_REFERER']
    end

    return daw_login_prompt unless Rdaw.const_defined?('ERROR_HANDLER_MNAME') && respond_to?(Rdaw::ERROR_HANDLER_MNAME)

    send(Rdaw::ERROR_HANDLER_MNAME,
         { :status_code => daw_status,
           :status_text => Rdaw::StatusCodes::to_const_name(daw_status) }) and return false
  end

  # Returns the list of HTTP methods that are not GET.
  def non_get_methods
    [:post, :put, :delete]
  end

   # Returns DAW cookie name set in <tt>Rdaw::DAW_COOKIE_NAME</tt>.
   #
   # == Defaults
   # * Returns <tt>myacinfo</tt> if <tt>Rdaw::DAW_COOKIE_NAME</tt> is not set.
   #
   # == Constants
   # <tt>Rdaw::DAW_COOKIE_NAME</tt> holds DAW's cookie name.
  def daw_cookie_name
    Rdaw.const_defined?('DAW_COOKIE_NAME') ? Rdaw::DAW_COOKIE_NAME : 'myacinfo'
  end
end # Rdaw::ControllerExtensions
