class AccountController < ApplicationController
  include Rdaw
  if(Rails.env == 'development')
    before_action :rdaw_local_setup, :only => [:feedback, :setting, :logout]
  else
    before_action :rdaw_auth
  end

  def feedback_create
    feedback = Feedback.create(user_id: session[:user]['DSID'],
                               ratting: params[:ratings],
                               content: params[:content])
    render :json => {code: feedback}
  end

  def setting
    setting = Setting.find_or_create_by(user_id: session[:user]['DSID'])
    setting_status = setting.update(measurement_type_id: params[:measurement_type_id])
    render :json => {code: setting_status}
  end

  def logout
    session[:user] = nil
    redirect_to '/'
  end
end