class WasteLog < ApplicationRecord
  belongs_to :waste_type
  belongs_to :store
  belongs_to :measurement_type
  validates_presence_of :waste_type, :measurement_type

  default_scope { where(is_active: true).order(collection_date: :desc) }

  scope :by_store_last7, lambda { |store_id| where('store_id = ? and created_at > ?', store_id, 7.days.ago) }

  scope :by_store_last30, lambda { |store_id| where('store_id = ? and created_at > ?', store_id, 30.days.ago) }
end
