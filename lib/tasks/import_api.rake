namespace :import_api do
  desc "TODO"
  task store: :environment do
    url = 'https://storedirectory.corp.apple.com/api/stores/public'
uri = URI(url)
response = Net::HTTP.get(uri)
        stores = JSON.parse response
        puts stores.first
        store_fields = ['name', 'rollout','sales_org','city', 'country','province']
        stores['content'].each do |store|
          puts store
          store_check = Store.where(rollout: store['rollout'])
          unless(store_check && store_check.size > 0)
          store.select! {|k,v| store_fields.include?(k) }
          Store.create(store)          
        end
      end 
    end
  end
