# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
if WasteType.all.size == 0
  WasteType.create([{name: 'occCardboard',title: 'OCC / Cardboard'},
                    {name: 'classicRecycling',title: 'Classic Recycling'},
                  {name: 'organicWaste',title: 'Organic Waste'},
                  {name: 'operationalWaste',title: 'Other Operational Waste'}])
end
if MeasurementType.all.size == 0
  MeasurementType.create([{name: 'Kgs'},
                          {name: 'Lbs'}])
end