# README

This README would normally document whatever steps are necessary to get the
application up and running.

* Ruby version 2.4.0
* Rails Version 5.0.1
* Postgresql 9.6.1


* Database  Postgresql

* Database initialization

1.Add the 'postgresql' gem to your Gemfile
   gem 'pg'

2.Then open a terminal window in the root directory of your application and run
   bundle install

3.Now edit your Rails application's config/database.yml
 
production:
   adapter: postgresql
   encoding: utf8
   database: the_ production_database_name
   username: your_user
   password: your_database_password
   host: 192.168.0.14(Ex)
   port: 5432(EX)
   pool: 10

 development:
   adapter: postgresql
   encoding: utf8
   database: the_ development_database_name
   username: your_user
   password: your_database_password
   host: 192.168.0.14
   port: 5432
   pool: 10
 TEST:
   adapter: postgresql
   encoding: utf8
   database: the_Test_database_name
   username: your_user
   password: your_database_password
   host: 192.168.0.14
   port: 5432
   pool: 10

Before running rake tasks need to define the environment (RAILS_ENV=production/test)

rake db:drop
rake db:create
rake db:migrate
rake db:seed
rake import_api:store


* How to run the test suite (Pilot)

* Pilot enable for stores using store ID
   
   Store.where('rollout NOT IN (?)',['R001','R002','R009','R010'] ).each{|store| store.update(:pilot_enable=>false)}

Here we have to give store ID that which store you want to enable 

* If you want to add another stores
   
   Store.where('rollout IN (?)',['R015','R016','R017','R018'] ).each{|store| store.update(:pilot_enable=>true)}

* After finish the test we have to enable all the stores
   
   Store.all.each{|store|store.update(:pilot_enable=>true)}



Web Accessibility(Keyboard Access)

* Tab: Move to the next element.
* Shift+Tab: Move to the previous element.
* Arrow keys: change selected menu item, or activate sub-menu.
* Escape: cancel menus without changing selection.


* Store        - Control+Alt+S
* WasteType    - Control+1 (OCC Cardboard)
               - Control+2 (Classic Recycling)
               - Control+3 (Organic Waste)
               - Control+4 (Other Operational Waste)
* Date         - Control+Alt+D
* Enter Weight - Control+Alt+W
* Kgs          - Control+Alt+K
* Lbs          - Control+Alt+L
* Log Waste    - Control+Alt+E
* Last7days    - Control+Alt+M
* Last30days   - Control+Alt+N
* Country      - Control+Alt+C
* User         - Control+Alt+U
* WasteTypes   - Control+Alt+T
* Feedback     - Control+Alt+F
* Settings     - Control+Alt+Q
* Logout       - Control+Alt+X



* ...
