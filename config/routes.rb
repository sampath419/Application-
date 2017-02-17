Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


  get 'waste_log/get_store_info/:id' => 'waste_log#get_store_info'
  post 'waste_log/create' => 'waste_log#create'
  delete 'waste_log/delete' => 'waste_log#delete'
  post 'account/logout' => 'account#logout'
  post 'account/feedback_create' => 'account#feedback_create'
  post 'account/setting' => 'account#setting'

  root 'waste_log#index'
end
