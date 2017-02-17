class WasteLogController < ApplicationController
  include WasteLogHelper
  include Rdaw
  if(Rails.env == 'development')
    before_action :rdaw_local_setup, :only => [:index, :create, :logout]
  else
    before_action :rdaw_auth
  end

  LBS_VALUE =  2.2

  def index
    @measurement_types = MeasurementType.all
    @default = Setting.find_by(user_id: session[:user]['DSID'])
    @default_measurement = (@default && @default.measurement_type_id) || @measurement_types.first.id
    @stores = Store.all
    @waste_types = WasteType.all
    unless params[:locale]
      params[:locale] ='en'      
    end
    if(@stores.size > 0)
      @waste_logs,@graph_data,@graph_hash = get_waste_log_data(@stores.first.rollout)
    end
  end

  def create
    measurement_type = MeasurementType.find(params[:measurement_type_id]).name
    if(measurement_type.downcase == 'kgs')
      params[:quantity] = params[:quantity].to_f * LBS_VALUE
    end
    WasteLog.create(waste_log_params)
    @waste_logs,@graph_data,@graph_hash = get_waste_log_data(params[:store_id])
    respond_to do |format|
      format.js
    end
  end

  def delete
    waste_log = WasteLog.find(params[:id])
    waste_log.update(is_active: false)
    @waste_logs,@graph_data,@graph_hash = get_waste_log_data(waste_log.store_id)
    respond_to do |format|
      format.js
    end
  end

  def get_store_info
    @waste_logs,@graph_data,@graph_hash = get_waste_log_data(params[:id],params[:days])
    render partial: 'log_entry', locals: { logs: @waste_logs, graph_data: @graph_data, graph_hash: @graph_hash, filter_day: params[:days] }
  end


  private
  def waste_log_params
    params['collection_date'] =  Date.strptime(params['collection_date'],'%m/%d/%Y')
    params['user_id'] = session[:user]['DSID']
    params['firstName'] = session[:user]['firstName']
    params['lastName'] = session[:user]['lastName']
    params[:store_id] = params[:store_id].split('__')[0]
    params.permit(:collection_date, :waste_type_id, :quantity, :store_id, :measurement_type_id, :user_id, :firstName, :lastName)
  end
end
