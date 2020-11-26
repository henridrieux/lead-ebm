class EventCategory < ApplicationRecord
  belongs_to :category
  belongs_to :event
  has_many :subscriptions
  validates :title, presence: true
end

