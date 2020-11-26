class Subscription < ApplicationRecord
  belongs_to :event_category
  belongs_to :user
  has_one :event, through: :event_category
  has_one :category, through: :event_category
  validates :status, inclusion: { in: ["Activé", "Désactivé", "En Suspens"] }
end
