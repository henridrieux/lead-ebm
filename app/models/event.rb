class Event < ApplicationRecord
  has_many :event_categories, dependent: :destroy

  validates :title, presence: true, uniqueness: true
  validates :description, presence: true
  # validates :frequency, presence: true
  # validates :query, presence: true
end
