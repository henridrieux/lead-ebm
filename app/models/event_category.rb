class EventCategory < ApplicationRecord
  belongs_to :category
  belongs_to :event
  validates :title, presence: true
end
