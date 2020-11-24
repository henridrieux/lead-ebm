class Event < ApplicationRecord
  validates :title, presence: true
  validates :description, presence: true
  validates :frequency, presence: true
  validates :query, presence: true
end
