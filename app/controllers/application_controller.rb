class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true, with: :exception


  before_action :set_locale, :change_session_expiration_time

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def change_session_expiration_time
    request.session_options[:expire_after] = 20.minutes
  end

  def rdaw_local_setup
    unless session[:user]
      session[:user] = {
      'firstName' => 't.',
      'lastName' => 'rex',
      'prsId' => '1154552672',
      'allGroups' => '0;35339;43228;43246;56402;58366',
      # When a user logs in with AppleConnect, your application will know the DSID(unique identifier for an Apple employee)
      # of the logged in user. You will send that DSID to our endpoint. Our endpoint will return some JSON with the store number for that employee.
      'DSID' => "1173232724"
      }
    end
  end
end
