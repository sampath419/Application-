class Store < ApplicationRecord
  has_many :waste_logs

  default_scope { order(rollout: :asc) }
end
