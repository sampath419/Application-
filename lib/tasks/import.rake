namespace :import do
  desc "TODO"
  task store: :environment do
    File.open('store_details.json', 'r') do |file|
      file.each do |json_list|
        stores = JSON.parse json_list
        store_fields = ['name', 'rollout','sales_org','city', 'country','province']
        stores['content'].each do |store|
          store_check = Store.where(rollout: store['rollout'])
          unless(store_check && store_check.size > 0)
            store.select! {|k,v| store_fields.include?(k) }
            Store.create(store)
          end
        end
      end
    end
  end

end
